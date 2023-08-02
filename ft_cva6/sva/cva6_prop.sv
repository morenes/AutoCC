import ariane_pkg::*;
module cva6_prop
 #(
		parameter ASSERT_INPUTS = 0,
		parameter ariane_pkg::ariane_cfg_t ArianeCfg     = ariane_pkg::ArianeDefaultConfig,
		parameter int unsigned AxiAddrWidth = ariane_axi::AddrWidth,
		parameter int unsigned AxiDataWidth = ariane_axi::DataWidth,
		parameter int unsigned AxiIdWidth   = ariane_axi::IdWidth,
		parameter type axi_ar_chan_t = ariane_axi::ar_chan_t,
		parameter type axi_aw_chan_t = ariane_axi::aw_chan_t,
		parameter type axi_w_chan_t  = ariane_axi::w_chan_t,
		parameter type axi_req_t = ariane_axi::req_t,
		parameter type axi_rsp_t = ariane_axi::resp_t
) (
		input  logic                         clk_i,
		input  logic                         rst_ni,
		// Core ID, Cluster ID and boot address are considered more or less static
		input  logic [riscv::VLEN-1:0]       boot_addr_i,  // reset boot address
		input  logic [riscv::XLEN-1:0]       hart_id_i,    // hart id in a multicore environment (reflected in a CSR)
		
		// Interrupt inputs
		input  logic [1:0]                   irq_i,        // level sensitive IR lines, mip & sip (async)
		input  logic                         ipi_i,        // inter-processor interrupts (async)
		// Timer facilities
		input  logic                         time_irq_i,   // timer interrupt in (async)
		input  logic                         debug_req_i,  // debug request (async)
		// RISC-V formal interface port (`rvfi`):
		// Can be left open when formal tracing is not needed.
		input  ariane_rvfi_pkg::rvfi_port_t  rvfi_o_2,
		input  ariane_rvfi_pkg::rvfi_port_t  rvfi_o, //output
		input  cvxif_pkg::cvxif_req_t        cvxif_req_o_2,
		input  cvxif_pkg::cvxif_req_t        cvxif_req_o, //output
		input  cvxif_pkg::cvxif_resp_t       cvxif_resp_i_2,
		input  cvxif_pkg::cvxif_resp_t       cvxif_resp_i,
		// L15 (memory side)
		input  wt_cache_pkg::l15_req_t       l15_req_o_2,
		input  wt_cache_pkg::l15_req_t       l15_req_o, //output
		input  wt_cache_pkg::l15_rtrn_t      l15_rtrn_i_2,
		input  wt_cache_pkg::l15_rtrn_t      l15_rtrn_i,
		// memory side, AXI Master
		input  axi_req_t                     axi_req_o_2,
		input  axi_req_t                     axi_req_o, //output
		input  axi_rsp_t                     axi_resp_i_2,
		input  axi_rsp_t                     axi_resp_i
	);

//==============================================================================
// Local Parameters
//==============================================================================

genvar j;
default clocking cb @(posedge clk_i);
endclocking
default disable iff (!rst_ni);


//====DESIGNER-ADDED-SVA====//

// Assumptions to account for the lack of an OS:
// Force RF contents to be the same:
wire rf_same = ariane1.issue_stage_i.i_issue_read_operands.gen_asic_regfile.i_ariane_regfile.mem == ariane2.issue_stage_i.i_issue_read_operands.gen_asic_regfile.i_ariane_regfile.mem;


// The architectural state (RFs, CSRs) should be properly restored on the cycle the flush completes.
wire arch_restored = (ariane1.i_frontend.i_instr_queue.pc_q == ariane2.i_frontend.i_instr_queue.pc_q) && 
					 (ariane1.i_frontend.npc_q == ariane2.i_frontend.npc_q) && 
					 rf_same &&
					 (ariane1.i_frontend.i_instr_queue.addr_i[0] == ariane2.i_frontend.i_instr_queue.addr_i[0]) &&
					 (ariane1.i_frontend.i_instr_queue.addr_i[1] == ariane2.i_frontend.i_instr_queue.addr_i[1]);


// Asserted when CSR inputs and outputs are the same.
wire csr_equal = // INPUTS
				(ariane1.commit_instr_id_commit == ariane2.commit_instr_id_commit) &&
				(ariane1.commit_ack == ariane2.commit_ack) &&
				(ariane1.boot_addr_i == ariane2.boot_addr_i) &&
				(ariane1.ex_commit == ariane2.ex_commit) &&
				(ariane1.csr_op_commit_csr == ariane2.csr_op_commit_csr) &&
				(ariane1.csr_write_fflags_commit_cs == ariane2.csr_write_fflags_commit_cs) &&
				(ariane1.dirty_fp_state == ariane2.dirty_fp_state) &&
				(ariane1.csr_addr_ex_csr == ariane2.csr_addr_ex_csr) &&
				(ariane1.csr_wdata_commit_csr == ariane2.csr_wdata_commit_csr) &&
				(ariane1.pc_commit == ariane2.pc_commit) &&
				(ariane1.data_perf_csr == ariane2.data_perf_csr) &&
				
				// OUTPUTS
				(ariane1.flush_csr_ctrl == ariane2.flush_csr_ctrl) &&
				(ariane1.halt_csr_ctrl == ariane2.halt_csr_ctrl) &&
				(ariane1.csr_rdata_csr_commit == ariane2.csr_rdata_csr_commit) &&
				(ariane1.csr_exception_csr_commit == ariane2.csr_exception_csr_commit) &&
				(ariane1.epc_commit_pcgen == ariane2.epc_commit_pcgen) &&
				(ariane1.eret == ariane2.eret) &&
				(ariane1.set_debug_pc == ariane2.set_debug_pc) &&
				(ariane1.trap_vector_base_commit_pcgen == ariane2.trap_vector_base_commit_pcgen) &&
				(ariane1.priv_lvl == ariane2.priv_lvl) &&
				(ariane1.fs == ariane2.fs) &&
				(ariane1.fflags_csr_commit == ariane2.fflags_csr_commit) &&
				(ariane1.frm_csr_id_issue_ex == ariane2.frm_csr_id_issue_ex) &&
				(ariane1.fprec_csr_ex == ariane2.fprec_csr_ex) &&
				(ariane1.irq_ctrl_csr_id == ariane2.irq_ctrl_csr_id) &&
				(ariane1.ld_st_priv_lvl_csr_ex == ariane2.ld_st_priv_lvl_csr_ex) &&
				(ariane1.enable_translation_csr_ex == ariane2.enable_translation_csr_ex) &&
				(ariane1.en_ld_st_translation_csr_ex == ariane2.en_ld_st_translation_csr_ex) &&
				(ariane1.sum_csr_ex == ariane2.sum_csr_ex) &&
				(ariane1.mxr_csr_ex == ariane2.mxr_csr_ex) &&
				(ariane1.satp_ppn_csr_ex == ariane2.satp_ppn_csr_ex) &&
				(ariane1.asid_csr_ex == ariane2.asid_csr_ex) &&
				(ariane1.tvm_csr_id == ariane2.tvm_csr_id) &&
				(ariane1.tw_csr_id == ariane2.tw_csr_id) &&
				(ariane1.tsr_csr_id == ariane2.tsr_csr_id) &&
				(ariane1.debug_mode == ariane2.debug_mode) &&
				(ariane1.single_step_csr_commit == ariane2.single_step_csr_commit) &&
				(ariane1.dcache_en_csr_nbdcache == ariane2.dcache_en_csr_nbdcache) &&
				(ariane1.icache_en_csr == ariane2.icache_en_csr) &&
				(ariane1.addr_csr_perf == ariane2.addr_csr_perf) &&
				(ariane1.data_csr_perf == ariane2.data_csr_perf) &&
				(ariane1.we_csr_perf == ariane2.we_csr_perf) &&
				(ariane1.fence_t_src_sel_csr_ctrl == ariane2.fence_t_src_sel_csr_ctrl) &&
				(ariane1.fence_t_pad_csr_ctrl == ariane2.fence_t_pad_csr_ctrl) &&
				(ariane1.pmpcfg == ariane2.pmpcfg) &&
				(ariane1.pmpaddr == ariane2.pmpaddr);

wire flush1_done = ariane1.controller_i.fence_t_state_q==ariane1.controller_i.RST_UARCH && ariane1.controller_i.fence_t_state_d==ariane1.controller_i.IDLE;
wire flush2_done = ariane2.controller_i.fence_t_state_q==ariane2.controller_i.RST_UARCH && ariane2.controller_i.fence_t_state_d==ariane2.controller_i.IDLE;

co__state1: cover property (ariane1.controller_i.fence_t_state_q==ariane1.controller_i.FLUSH_DCACHE);
co__state3: cover property (ariane1.controller_i.fence_t_state_q==ariane1.controller_i.RST_UARCH);
co__state4: cover property (ariane1.controller_i.fence_t_state_q==ariane1.controller_i.PAD);
co__fence_active: cover property (ariane1.controller_i.fence_active_q);
co__fence_t: cover property (ariane1.controller_i.fence_t_i);

wire both_flush_done = flush1_done && flush2_done;
// Latches a 1 when the flush has completed.
reg spy_mode;
reg [4:0] equal_cnt;
wire io_equal;
wire precondition_equal = io_equal && csr_equal && arch_restored;

wire still_equal_after_period = precondition_equal && (equal_cnt >= 5'd6);

always_ff @(posedge clk_i) begin
	if (!rst_ni) begin
		spy_mode 	   <= '0;
		equal_cnt  <= '0;
	end else begin
		spy_mode      <= still_equal_after_period || spy_mode;
		equal_cnt  <= ((both_flush_done || equal_cnt>0) && precondition_equal) ? equal_cnt + 1 : '0;
	end
end

// Assert that inputs are equal:
as__commit_instr_i: assert property (spy_mode |-> (ariane1.commit_instr_id_commit == ariane2.commit_instr_id_commit));
as__commit_ack_i: assert property (spy_mode |-> (ariane1.commit_ack == ariane2.commit_ack));
as__boot_addr_i: assert property (spy_mode |-> (ariane1.boot_addr_i == ariane2.boot_addr_i));
as__ex_i: assert property (spy_mode |-> (ariane1.ex_commit == ariane2.ex_commit));
as__csr_op_i: assert property (spy_mode |-> (ariane1.csr_op_commit_csr == ariane2.csr_op_commit_csr));
as__csr_write_fflags_i: assert property (spy_mode |-> (ariane1.csr_write_fflags_commit_cs == ariane2.csr_write_fflags_commit_cs));
as__dirty_fp_state_i: assert property (spy_mode |-> (ariane1.dirty_fp_state == ariane2.dirty_fp_state));
as__csr_addr_i: assert property (spy_mode |-> (ariane1.csr_addr_ex_csr == ariane2.csr_addr_ex_csr));
as__csr_wdata_i: assert property (spy_mode |-> (ariane1.csr_wdata_commit_csr == ariane2.csr_wdata_commit_csr));
as__pc_i: assert property (spy_mode |-> (ariane1.pc_commit == ariane2.pc_commit));



wire assume_csr = spy_mode || ariane1.controller_i.fence_t_state_q!=ariane1.controller_i.IDLE || ariane2.controller_i.fence_t_state_q!=ariane2.controller_i.IDLE;
// Assume that the input from the performance counters are equal (perf_counters blackboxed):
am__perf_data_i: assume property (assume_csr |-> (ariane1.data_perf_csr == ariane2.data_perf_csr));
// Assume that the outputs are equal:
am__flush_o: assume property (assume_csr |-> (ariane1.flush_csr_ctrl == ariane2.flush_csr_ctrl));
am__halt_csr_o: assume property (assume_csr |-> (ariane1.halt_csr_ctrl == ariane2.halt_csr_ctrl));
am__csr_rdata_o: assume property (assume_csr |-> (ariane1.csr_rdata_csr_commit == ariane2.csr_rdata_csr_commit));
am__csr_exception_o: assume property (assume_csr |-> (ariane1.csr_exception_csr_commit == ariane2.csr_exception_csr_commit));
am__epc_o: assume property (assume_csr |-> (ariane1.epc_commit_pcgen == ariane2.epc_commit_pcgen));
am__eret_o: assume property (assume_csr |-> (ariane1.eret == ariane2.eret));
am__set_debug_pc_o: assume property (assume_csr |-> (ariane1.set_debug_pc == ariane2.set_debug_pc));
am__trap_vector_base_o: assume property (assume_csr |-> (ariane1.trap_vector_base_commit_pcgen == ariane2.trap_vector_base_commit_pcgen));
am__priv_lvl_o: assume property (assume_csr |-> (ariane1.priv_lvl == ariane2.priv_lvl));
am__fs_o: assume property (assume_csr |-> (ariane1.fs == ariane2.fs));
am__fflags_o: assume property (assume_csr |-> (ariane1.fflags_csr_commit == ariane2.fflags_csr_commit));
am__frm_o: assume property (assume_csr |-> (ariane1.frm_csr_id_issue_ex == ariane2.frm_csr_id_issue_ex));
am__fprec_o: assume property (assume_csr |-> (ariane1.fprec_csr_ex == ariane2.fprec_csr_ex));
am__irq_ctrl_o: assume property (assume_csr |-> (ariane1.irq_ctrl_csr_id == ariane2.irq_ctrl_csr_id));
am__ld_st_priv_lvl_o: assume property (assume_csr |-> (ariane1.ld_st_priv_lvl_csr_ex == ariane2.ld_st_priv_lvl_csr_ex));
am__en_translation_o: assume property (assume_csr |-> (ariane1.enable_translation_csr_ex == ariane2.enable_translation_csr_ex));
am__en_ld_st_translation_o: assume property (assume_csr |-> (ariane1.en_ld_st_translation_csr_ex == ariane2.en_ld_st_translation_csr_ex));
am__sum_o: assume property (assume_csr |-> (ariane1.sum_csr_ex == ariane2.sum_csr_ex));
am__mxr_o: assume property (assume_csr |-> (ariane1.mxr_csr_ex == ariane2.mxr_csr_ex));
am__satp_ppn_o: assume property (assume_csr |-> (ariane1.satp_ppn_csr_ex == ariane2.satp_ppn_csr_ex));
am__asid_o: assume property (assume_csr |-> (ariane1.asid_csr_ex == ariane2.asid_csr_ex));
am__tvm_o: assume property (assume_csr |-> (ariane1.tvm_csr_id == ariane2.tvm_csr_id));
am__tw_o: assume property (assume_csr |-> (ariane1.tw_csr_id == ariane2.tw_csr_id));
am__tsr_o: assume property (assume_csr |-> (ariane1.tsr_csr_id == ariane2.tsr_csr_id));
am__debug_mode_o: assume property (assume_csr |-> (ariane1.debug_mode == ariane2.debug_mode));
am__single_step_o: assume property (assume_csr |-> (ariane1.single_step_csr_commit == ariane2.single_step_csr_commit));
am__dcache_en_o: assume property (assume_csr |-> (ariane1.dcache_en_csr_nbdcache == ariane2.dcache_en_csr_nbdcache));
am__icache_en_o: assume property (assume_csr |-> (ariane1.icache_en_csr == ariane2.icache_en_csr));
am__perf_addr_o: assume property (assume_csr |-> (ariane1.addr_csr_perf == ariane2.addr_csr_perf));
am__perf_data_o: assume property (assume_csr |-> (ariane1.data_csr_perf == ariane2.data_csr_perf));
am__perf_we_o: assume property (assume_csr |-> (ariane1.we_csr_perf == ariane2.we_csr_perf));
am__perf_en_o: assume property (assume_csr |-> (ariane1.fence_t_pad_csr_ctrl == ariane2.fence_t_pad_csr_ctrl));
am__fence_t_src_sel_o: assume property (assume_csr |-> (ariane1.fence_t_src_sel_csr_ctrl == ariane2.fence_t_src_sel_csr_ctrl));
am__pmpcfg_o: assume property (assume_csr |-> (ariane1.pmpcfg == ariane2.pmpcfg));
am__pmpaddr_o: assume property (assume_csr |-> (ariane1.pmpaddr == ariane2.pmpaddr));


wire axi_input_equal =  (axi_resp_i == axi_resp_i_2);
wire cvxif_input_equal = (cvxif_resp_i == cvxif_resp_i_2);
assign io_equal = (axi_req_o == axi_req_o_2) && axi_input_equal && cvxif_input_equal;

// ASSERT ALL OUTPUTS
as__AXI_w_valid_equal: assert property (spy_mode |-> axi_req_o.w_valid == axi_req_o_2.w_valid);
as__AXI_w_equal: assert property (spy_mode && axi_req_o.w_valid |-> axi_req_o.w == axi_req_o_2.w);
as__AXI_ar_valid_equal: assert property (spy_mode |-> axi_req_o.ar_valid == axi_req_o_2.ar_valid);
as__AXI_ar_equal: assert property (spy_mode && axi_req_o.ar_valid |-> axi_req_o_2.ar == axi_req_o_2.ar);
as__AXI_aw_valid_equal: assert property (spy_mode |-> axi_req_o.aw_valid == axi_req_o_2.aw_valid);
as__AXI_aw_equal: assert property (spy_mode && axi_req_o.aw_valid |-> axi_req_o.aw == axi_req_o_2.aw);

wire arch_same_post = (ariane1.i_frontend.i_instr_queue.pc_q == ariane2.i_frontend.i_instr_queue.pc_q);
as__PC_equal: assert property (spy_mode |-> arch_same_post);


// Inputs are the same to both cores after the flush.
am__AXI_input_same: assume property (spy_mode |-> axi_input_equal);
am_XIF_input_same: assume property (spy_mode |-> cvxif_input_equal);


//////////////////////////
//// OTHER ASSUMPIONS ////
//////////////////////////

// Have val and rdy come on the same cycle for reads.
am__axi_ready1: assume property (ariane1.axi_req_o.ar_valid |-> ariane1.axi_resp_i.ar_ready);
am__axi_ready2: assume property (ariane2.axi_req_o.ar_valid |-> ariane2.axi_resp_i.ar_ready);

// Forbid usage of the MUL unit.

am__m0a: assume property (1'b0 == ariane1.ex_stage_i.mult_valid_i);  
am__m0b: assume property (1'b0 == ariane2.ex_stage_i.mult_valid_i);
am__m1a: assume property (1'b0 == ariane1.ex_stage_i.mult_valid);
am__m1b: assume property (1'b0 == ariane2.ex_stage_i.mult_valid);

// Assume output from the MUL unit is the same.
am__m2: assume property (spy_mode |-> ariane1.ex_stage_i.mult_result   == ariane2.ex_stage_i.mult_result);
am__m3: assume property (spy_mode |-> ariane1.ex_stage_i.mult_ready    == ariane2.ex_stage_i.mult_ready);
am__m4: assume property (spy_mode |-> ariane1.ex_stage_i.mult_trans_id == ariane2.ex_stage_i.mult_trans_id);


// Assume outputs from perf_counters are the same (perf_counters is blackboxed).
am__f1: assume property (spy_mode |-> ariane1.ex_stage_i.fpu_trans_id_o  == ariane2.ex_stage_i.fpu_trans_id_o);
am__f2: assume property (spy_mode |-> ariane1.ex_stage_i.fpu_result_o    == ariane2.ex_stage_i.fpu_result_o);
am__f3: assume property (spy_mode |-> ariane1.ex_stage_i.fpu_valid_o     == ariane2.ex_stage_i.fpu_valid_o);
am__f4: assume property (spy_mode |-> ariane1.ex_stage_i.fpu_exception_o == ariane2.ex_stage_i.fpu_exception_o);
am__f5: assume property (spy_mode |-> ariane1.ex_stage_i.fpu_ready_o     == ariane2.ex_stage_i.fpu_ready_o);

endmodule