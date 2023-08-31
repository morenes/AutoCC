
![LOGO](https://github.com/morenes/AutoCC/assets/55038083/6f578a9e-36ae-4641-8585-ca38cf50346f)

# Requirements

- **JasperGold (JG) 2019.12 or newer** (tested with 2019.12 and 2021.03). To run the Formal Testbenches.
- **VCS Simulator** (tested with vcs-mx/O-2018.09-SP2). Only for the MAPLE use case to reproduce the covert-channel in RTL simulation.
- **Python 2+.** To run AutoCC and also for the RTL simulation.

# Installation

    git clone https://github.com/morenes/AutoCC.git;
    git checkout v1.0;
    cd AutoCC;
    export AUTOCC_ROOT=$PWD;

    which jg;
    alias jg='<LICENSE_PATH>/jasper_2021.03/bin/jg'; # Or the version that you are using

# Use cases

## **Vscale 32-bit core:** *Generating testbench and fixing underconstrains*

Clone the VSCALE repo

    cd $AUTOCC_ROOT
    git clone https://github.com/LGTMCU/vscale.git


Fixes a combinational loop in the original RTL that prevents JasperGold (JG) from running.

    export DUT_ROOT=$PWD/vscale/src/main/verilog;
    ./fixes/fix_combo_loop_vscale_rtl.sh

Generate the Vscale Formal Testbench (FT) using AutoCC.

    python3 autocc.py -f vscale_core.v  -i vscale_ctrl_constants.vh;


Run JG on the generated testbench.

    jg ft_vscale_core/FPV.tcl -proj projs/vscale_init &

**CEX.** The tool should find a CEX (of at least 6 cycles) to the assertion *as__dmem_hwrite*

**GUI.** Clicking on the assertion the GUI opens a waveform window. To visualize the CEX, we add a list of signals to the waveform window. We can use the signal list in the file vscale.sig. To load the signal list, go to **File > Load Signal List**, and select vscale.sig from the sigs folder.

**Waveform.** In the waveform we would see spy_mode starting in cycle 5. Then, hwrite  signal is different in the last cycle because the opcode was different a cycle before (ctrl.opcode).
This is because the PC is different (PC_IF), since the branch was taken in one universe and not in the other, because the register file data was different (regfile.data).

**FIX.** 
As described in the paper, this is an underconstraint in the testbench, since the testbench does not constrain the register file data to be the same in both universes when the spy_mode starts. We fix this by adding conditions to the testbench and re-running JG.

    ./fixes/fix_underconstrain_vscale.sh;
    jg ft_vscale_core/FPV.tcl -proj projs/vscale_fixed &



## **CVA6 application-class RISCV-64 core:** *Uncovering and fixing hardware bugs*

Clone the CVA6 repo and checkout the commit without fixes

    cd $AUTOCC_ROOT;
    git clone -b autocc https://github.com/morenes/cva6.git

Run JG on the CVA6 testbench:

    jg ft_cva6/FPV.tcl -proj projs/cva6_orig &


### CEX1 - Leaks invalid I-Cache data to the next PC

The tool should have found a CEX to the assertion *as__AXI_ar_valid_equal*
in under 30 minutes with a depth of 76 cycles.

**GUI.** Clicking on the assertion the GUI opens a waveform window. To visualize the CEX, we add the list of signals cva6_c1.sig from the sigs folder.

**Waveform.** In the waveform we would see the PC being different because  instr_compressed had a different value. This propagated based on garbagged data being read from the icache during an exception.

**FIX.** 
Zero out data coming from the i-cache if the line is not a hit.
We apply the fix by checking out a branch with the patch already included.

    cd cva6; git checkout autocc_fix_cex1; cd ..;
    jg ft_cva6/FPV.tcl -proj projs/cva6_fix_cex1 &

### CEX2 - Wrong transition in the FSM of the PTW

The tool should have found a CEX to the assertion *as__AXI_ar_valid_equal*
in under 6 hours with a depth of 80 cycles.

**GUI.** We add the list of signals cva6_c2.sig from the sigs folder.

**Waveform.** In the waveform we would see ariane1.ex_stage_i.lsu_i.gen_mmu_sv39.i_cva6_mmu.i_ptw.state_q transitioning from *WAIT_VALID* to *IDLE*, which is an illegal FSM transition caused by ariane1.ex_stage_i.lsu_i.gen_mmu_sv39.i_cva6_mmu.i_ptw.flush_i being set while the PTW is waiting for a response.

**FIX.**
Update the FSM to remain in *WAIT_VALID* even when flush_i is set.
Fix applied to upstream CVA6 (github.com/openhwgroup/cva6/pull/1184)
We apply the fix by checking out a branch with the patch already included.

    cd cva6; git checkout autocc_fix_cex2; cd ..;
    jg ft_cva6/FPV.tcl -proj projs/cva6_fix_cex2 &

The previous CEX trace should not be found anymore due to the fix. We have not continued debugging possible CEXs that may appear to this or other assertions.



## **MAPLE memory-engine:** *Uncovering, reproducing in RTL Simulation and fixing a covert channel*

### Installing OpenPiton with MAPLE inside it

Clone and building the OpenPiton repo

    cd $AUTOCC_ROOT
    git clone -b openpiton-maple https://github.com/PrincetonUniversity/openpiton.git
    cd openpiton;
    source piton/ariane_setup.sh;
    source piton/ariane_build_tools.sh; # Takes ~5-10 minutes

Clone and build the MAPLE repo

    source ../maple_setup_build.sh # Takes ~1 minute

### Run MAPLE's Formal Testbench (FT)

To run JG on MAPLE's FT, we do:

    cd $AUTOCC_ROOT
    jg ft_maple/FPV.tcl -proj projs/maple_not_fixed &

While JG is running, we can reproduce the covert channel (that we will find with the CEX) in RTL Simulation at the system-level using OpenPiton.


### Reproducing the covert channel in RTL Simulation

To run the attack that reveal the secret key, we do the following:

        cd openpiton/maple;
        ./run_test.sh 4;

The recovered secret should be 0xdeadbeef.
The reported cycle count should be less than 6000 cycles.


We now apply the fixes to close the covert channel.

        git checkout fa614fc;
        source ../../maple_setup_build.sh
        ./run_test.sh 4;

The recovered secret should be 0x00000000. This indicates that the secret cannot be extracted using this channel anymore

### CEX on the FT

In the meantime, we have been running JG on MAPLE's Formal Testbench with the Design-under-test (DUT) being MAPLE's RTL before applying the fixes.
In less than 30 minutes we should find a CEX at depth 21, where the assertion *as__dev1_merger_vr_noc1_val* fails.





## **AES encryption accelerator.** *Achieving full-proof*

Clone the AES repo:

    cd $AUTOCC_ROOT
    git clone https://github.com/morenes/aes.git

We run JG on the AES testbench, with the DUT being the RTL of the AES accelerator.
This testbench already includes the architectural modeling described in Section 4.4 of the paper, to avoid spurious CEXs.
The result of this run should be full-proof, i.e., no CEXs found, in less than 6 hours.

    jg ft_aes_wrap/FPV.tcl -proj projs/aes &
