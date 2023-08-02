<?xml version="1.0" encoding="UTF-8"?>
<wavelist version="3">
  <insertion-point-position>22</insertion-point-position>
  <wave>
    <expr>clk_i</expr>
    <label/>
    <radix/>
  </wave>
  <wave>
    <expr>u_cva6_sva.rst_ni</expr>
    <label/>
    <radix/>
  </wave>
  <wave>
    <expr>u_cva6_sva.arch_restored</expr>
    <label/>
    <radix/>
  </wave>
  <wave>
    <expr>u_cva6_sva.csr_equal</expr>
    <label/>
    <radix/>
  </wave>
  <wave>
    <expr>u_cva6_sva.io_equal</expr>
    <label/>
    <radix/>
  </wave>
  <wave collapsed="true">
    <expr>u_cva6_sva.equal_cnt</expr>
    <label/>
    <radix/>
  </wave>
  <wave>
    <expr>u_cva6_sva.still_equal_after_period</expr>
    <label/>
    <radix/>
  </wave>
  <wave>
    <expr>u_cva6_sva.both_flush_done</expr>
    <label/>
    <radix/>
  </wave>
  <wave>
    <expr>u_cva6_sva.check</expr>
    <label/>
    <radix/>
  </wave>
  <group collapsed="false">
    <expr/>
    <label>&lt;&lt;Target&gt;&gt;::tx</label>
    <wave collapsed="true">
      <expr>ariane1.controller_i.fence_t_state_q</expr>
      <label/>
      <radix>ariane1.controller_i.fence_t_state_q</radix>
    </wave>
    <wave collapsed="true">
      <expr>ariane2.controller_i.fence_t_state_q</expr>
      <label/>
      <radix>ariane2.controller_i.fence_t_state_q</radix>
    </wave>
    <wave collapsed="true">
      <expr>ariane1.genblk3.i_cache_subsystem.i_cva6_icache.dreq_o.data</expr>
      <label/>
      <radix/>
    </wave>
    <wave collapsed="true">
      <expr>ariane2.genblk3.i_cache_subsystem.i_cva6_icache.dreq_o.data</expr>
      <label/>
      <radix/>
    </wave>
    <wave collapsed="true">
      <expr>ariane1.genblk3.i_cache_subsystem.i_cva6_icache.cl_hit</expr>
      <label/>
      <radix/>
    </wave>
    <wave collapsed="true">
      <expr>ariane2.genblk3.i_cache_subsystem.i_cva6_icache.cl_hit</expr>
      <label/>
      <radix/>
    </wave>
    <wave>
      <expr>ariane1.genblk3.i_cache_subsystem.i_cva6_icache.areq_i.fetch_exception.valid</expr>
      <label/>
      <radix/>
    </wave>
    <wave>
      <expr>ariane2.genblk3.i_cache_subsystem.i_cva6_icache.areq_i.fetch_exception.valid</expr>
      <label/>
      <radix/>
    </wave>
    <wave>
      <expr>ariane1.i_frontend.i_instr_realign.instr_is_compressed[0]</expr>
      <label/>
      <radix/>
    </wave>
    <wave>
      <expr>ariane2.i_frontend.i_instr_realign.instr_is_compressed[0]</expr>
      <label/>
      <radix/>
    </wave>
  </group>
  <wave collapsed="true">
    <expr>ariane1.i_frontend.npc_q</expr>
    <label/>
    <radix/>
  </wave>
  <wave collapsed="true">
    <expr>ariane2.i_frontend.npc_q</expr>
    <label/>
    <radix/>
  </wave>
  <highlightlist>
    <!--Users can remove the highlightlist block if they want to load the signal save file into older version of JasperGold-->
    <highlight>
      <expr>ariane1.ex_stage_i.lsu_i.gen_mmu_sv39.i_cva6_mmu.i_ptw.flush_i</expr>
      <color>builtin_red</color>
    </highlight>
    <highlight>
      <expr>ariane1.genblk3.i_cache_subsystem.i_cva6_icache.mem_data_req_o</expr>
      <color>builtin_red</color>
    </highlight>
  </highlightlist>
</wavelist>
