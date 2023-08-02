`include "define.tmp.h"
`include "dmbr_define.v"
`include "l15.tmp.h"
`include "jtag.vh"
`include "dcp.h"
`include "is.h"

module is_core_prop
#(
		parameter ASSERT_INPUTS = 0)
 (
		
		input  wire                                 clk_gated,
		input  wire                                 rst_n_f,
		input  wire [31:0]                          config_system_tile_count,
		input  wire [`HOME_ALLOC_METHOD_WIDTH-1:0]  config_home_alloc_method,
		input  wire [`NOC_CHIPID_WIDTH-1:0]         config_chipid,
		input  wire [`NOC_X_WIDTH-1:0]              config_coreid_x,
		input  wire [`NOC_Y_WIDTH-1:0]              config_coreid_y,
		input  wire                                 splitter_dev1_vr_noc1_val_2,
		input  wire                                 splitter_dev1_vr_noc1_val,
		input  wire [`NOC_DATA_WIDTH-1:0]           splitter_dev1_vr_noc1_dat_2,
		input  wire [`NOC_DATA_WIDTH-1:0]           splitter_dev1_vr_noc1_dat,
		input  wire                                 splitter_dev1_vr_noc1_rdy_2,
		input  wire                                 splitter_dev1_vr_noc1_rdy, //output
		input  wire                                 dev1_merger_vr_noc1_val_2,
		input  wire                                 dev1_merger_vr_noc1_val,   //output
		input  wire [`NOC_DATA_WIDTH-1:0]           dev1_merger_vr_noc1_dat_2,
		input  wire [`NOC_DATA_WIDTH-1:0]           dev1_merger_vr_noc1_dat,   //output
		input  wire                                 dev1_merger_vr_noc1_rdy_2,
		input  wire                                 dev1_merger_vr_noc1_rdy,  
		input  wire                                 splitter_dev1_vr_noc2_val_2,
		input  wire                                 splitter_dev1_vr_noc2_val,
		input  wire [`NOC_DATA_WIDTH-1:0]           splitter_dev1_vr_noc2_dat_2,
		input  wire [`NOC_DATA_WIDTH-1:0]           splitter_dev1_vr_noc2_dat,
		input  wire                                 splitter_dev1_vr_noc2_rdy_2,
		input  wire                                 splitter_dev1_vr_noc2_rdy, //output
		input  wire                                 dev1_merger_vr_noc2_val_2,
		input  wire                                 dev1_merger_vr_noc2_val,   //output
		input  wire [`NOC_DATA_WIDTH-1:0]           dev1_merger_vr_noc2_dat_2,
		input  wire [`NOC_DATA_WIDTH-1:0]           dev1_merger_vr_noc2_dat,   //output
		input  wire                                 dev1_merger_vr_noc2_rdy_2,
		input  wire                                 dev1_merger_vr_noc2_rdy,  
		input  wire                                 splitter_dev1_vr_noc3_val_2,
		input  wire                                 splitter_dev1_vr_noc3_val,
		input  wire [`NOC_DATA_WIDTH-1:0]           splitter_dev1_vr_noc3_dat_2,
		input  wire [`NOC_DATA_WIDTH-1:0]           splitter_dev1_vr_noc3_dat,
		input  wire                                 splitter_dev1_vr_noc3_rdy_2,
		input  wire                                 splitter_dev1_vr_noc3_rdy, //output
		input  wire                                 l15_transducer_ack_2,
		input  wire                                 l15_transducer_ack,
		input  wire                                 l15_transducer_header_ack_2,
		input  wire                                 l15_transducer_header_ack,
		
		input  wire                                 transducer_l15_val_2,
		input  wire                                 transducer_l15_val, //output
		input  wire [`PCX_REQTYPE_WIDTH-1:0]        transducer_l15_rqtype_2,
		input  wire [`PCX_REQTYPE_WIDTH-1:0]        transducer_l15_rqtype, //output
		input  wire [`L15_AMO_OP_WIDTH-1:0]         transducer_l15_amo_op_2,
		input  wire [`L15_AMO_OP_WIDTH-1:0]         transducer_l15_amo_op, //output
		input  wire [`PCX_SIZE_FIELD_WIDTH-1:0]     transducer_l15_size_2,
		input  wire [`PCX_SIZE_FIELD_WIDTH-1:0]     transducer_l15_size, //output
		input  wire [`L15_PADDR_HI:0]               transducer_l15_address_2,
		input  wire [`L15_PADDR_HI:0]               transducer_l15_address, //output
		input  wire [63:0]                          transducer_l15_data_2,
		input  wire [63:0]                          transducer_l15_data, //output
		input  wire                                 transducer_l15_nc_2,
		input  wire                                 transducer_l15_nc, //output
		input  wire [`L15_THREADID_MASK]            transducer_l15_threadid_2,
		input  wire [`L15_THREADID_MASK]            transducer_l15_threadid, //output
		input  wire                                 transducer_l15_prefetch_2,
		input  wire                                 transducer_l15_prefetch, //output
		input  wire                                 transducer_l15_blockstore_2,
		input  wire                                 transducer_l15_blockstore, //output
		input  wire                                 transducer_l15_blockinitstore_2,
		input  wire                                 transducer_l15_blockinitstore, //output
		input  wire [1:0]                           transducer_l15_l1rplway_2,
		input  wire [1:0]                           transducer_l15_l1rplway, //output
		input  wire                                 transducer_l15_invalidate_cacheline_2,
		input  wire                                 transducer_l15_invalidate_cacheline, //output
		input  wire [`TLB_CSM_WIDTH-1:0]            transducer_l15_csm_data_2,
		input  wire [`TLB_CSM_WIDTH-1:0]            transducer_l15_csm_data, //output
		input  wire [63:0]                          transducer_l15_data_next_entry_2,
		input  wire [63:0]                          transducer_l15_data_next_entry, //output
		input  wire                                 transducer_l15_req_ack_2,
		input  wire                                 transducer_l15_req_ack, //output
		
		
		input wire                                  l15_transducer_val_2,
		input wire                                  l15_transducer_val,
		input wire [3:0]                            l15_transducer_returntype_2,
		input wire [3:0]                            l15_transducer_returntype,
		input wire [`L15_THREADID_MASK]             l15_transducer_threadid_2,
		input wire [`L15_THREADID_MASK]             l15_transducer_threadid,
		input wire [63:0]                           l15_transducer_data_0_2,
		input wire [63:0]                           l15_transducer_data_0,
		input wire [63:0]                           l15_transducer_data_1_2,
		input wire [63:0]                           l15_transducer_data_1
		
	);

//==============================================================================
// Local Parameters
//==============================================================================

genvar j;
default clocking cb @(posedge clk_gated);
endclocking
default disable iff (!rst_n_f);


wire flush_begin, flush_end, io_equal;
reg flush_began;
reg flush_ended;
reg [4:0] equal_cnt;
always_ff @(posedge clk_gated) begin
	if (!rst_n_f) begin
		flush_began   <= '0;
		flush_ended   <= '0;
		equal_cnt     <= '0;
	end else begin
		flush_began   <= flush_begin || flush_began;
		flush_ended   <= flush_began && flush_end || flush_ended;
		equal_cnt	 <= io_equal ? equal_cnt + 1 : '0;
	end
end

as__dev1_merger_vr_noc1_val: assert property (flush_ended |-> (dev1_merger_vr_noc1_val == dev1_merger_vr_noc1_val_2));
as__dev1_merger_vr_noc2_val: assert property (flush_ended |-> (dev1_merger_vr_noc2_val == dev1_merger_vr_noc2_val_2));


am__splitter_dev1_vr_noc2_dat: assume property (flush_began |-> (splitter_dev1_vr_noc2_dat == splitter_dev1_vr_noc2_dat_2));
am__l15_transducer_data_1: assume property (flush_began |-> (l15_transducer_data_1 == l15_transducer_data_1_2));
am__l15_transducer_data_0: assume property (flush_began |-> (l15_transducer_data_0 == l15_transducer_data_0_2));
am__l15_transducer_val: assume property (flush_began |-> (l15_transducer_val == l15_transducer_val_2));
am__splitter_dev1_vr_noc3_val: assume property (flush_began |-> (splitter_dev1_vr_noc3_val == splitter_dev1_vr_noc3_val_2));
am__splitter_dev1_vr_noc3_dat: assume property (flush_began |-> (splitter_dev1_vr_noc3_dat == splitter_dev1_vr_noc3_dat_2));
am__dev1_merger_vr_noc2_rdy: assume property (flush_began |-> (dev1_merger_vr_noc2_rdy == dev1_merger_vr_noc2_rdy_2));
am__l15_transducer_ack: assume property (flush_began |-> (l15_transducer_ack == l15_transducer_ack_2));
am__l15_transducer_returntype: assume property (flush_began |-> (l15_transducer_returntype == l15_transducer_returntype_2));
am__splitter_dev1_vr_noc1_val: assume property (flush_began |-> (splitter_dev1_vr_noc1_val == splitter_dev1_vr_noc1_val_2));
am__l15_transducer_threadid: assume property (flush_began |-> (l15_transducer_threadid == l15_transducer_threadid_2));
am__splitter_dev1_vr_noc1_dat: assume property (flush_began |-> (splitter_dev1_vr_noc1_dat == splitter_dev1_vr_noc1_dat_2));
am__l15_transducer_header_ack: assume property (flush_began |-> (l15_transducer_header_ack == l15_transducer_header_ack_2));
am__splitter_dev1_vr_noc2_val: assume property (flush_began |-> (splitter_dev1_vr_noc2_val == splitter_dev1_vr_noc2_val_2));
am__dev1_merger_vr_noc1_rdy: assume property (flush_began |-> (dev1_merger_vr_noc1_rdy == dev1_merger_vr_noc1_rdy_2));

assign io_equal = splitter_dev1_vr_noc2_rdy == splitter_dev1_vr_noc2_rdy_2 &&
 transducer_l15_data == transducer_l15_data_2 &&
 splitter_dev1_vr_noc2_dat == splitter_dev1_vr_noc2_dat_2 &&
 transducer_l15_address == transducer_l15_address_2 &&
 transducer_l15_threadid == transducer_l15_threadid_2 &&
 l15_transducer_data_1 == l15_transducer_data_1_2 &&
 dev1_merger_vr_noc2_val == dev1_merger_vr_noc2_val_2 &&
 dev1_merger_vr_noc1_dat == dev1_merger_vr_noc1_dat_2 &&
 splitter_dev1_vr_noc1_rdy == splitter_dev1_vr_noc1_rdy_2 &&
 l15_transducer_data_0 == l15_transducer_data_0_2 &&
 transducer_l15_blockinitstore == transducer_l15_blockinitstore_2 &&
 l15_transducer_val == l15_transducer_val_2 &&
 transducer_l15_l1rplway == transducer_l15_l1rplway_2 &&
 splitter_dev1_vr_noc3_val == splitter_dev1_vr_noc3_val_2 &&
 splitter_dev1_vr_noc3_dat == splitter_dev1_vr_noc3_dat_2 &&
 dev1_merger_vr_noc2_dat == dev1_merger_vr_noc2_dat_2 &&
 transducer_l15_blockstore == transducer_l15_blockstore_2 &&
 dev1_merger_vr_noc2_rdy == dev1_merger_vr_noc2_rdy_2 &&
 transducer_l15_amo_op == transducer_l15_amo_op_2 &&
 dev1_merger_vr_noc1_val == dev1_merger_vr_noc1_val_2 &&
 transducer_l15_invalidate_cacheline == transducer_l15_invalidate_cacheline_2 &&
 transducer_l15_data_next_entry == transducer_l15_data_next_entry_2 &&
 transducer_l15_size == transducer_l15_size_2 &&
 transducer_l15_prefetch == transducer_l15_prefetch_2 &&
 l15_transducer_ack == l15_transducer_ack_2 &&
 splitter_dev1_vr_noc3_rdy == splitter_dev1_vr_noc3_rdy_2 &&
 transducer_l15_nc == transducer_l15_nc_2 &&
 transducer_l15_req_ack == transducer_l15_req_ack_2 &&
 l15_transducer_returntype == l15_transducer_returntype_2 &&
 splitter_dev1_vr_noc1_val == splitter_dev1_vr_noc1_val_2 &&
 transducer_l15_csm_data == transducer_l15_csm_data_2 &&
 l15_transducer_threadid == l15_transducer_threadid_2 &&
 transducer_l15_rqtype == transducer_l15_rqtype_2 &&
 splitter_dev1_vr_noc1_dat == splitter_dev1_vr_noc1_dat_2 &&
 l15_transducer_header_ack == l15_transducer_header_ack_2 &&
 splitter_dev1_vr_noc2_val == splitter_dev1_vr_noc2_val_2 &&
 transducer_l15_val == transducer_l15_val_2 &&
 dev1_merger_vr_noc1_rdy == dev1_merger_vr_noc1_rdy_2 &&
1'b1;
//==============================================================================
// Modeling
//==============================================================================


//====DESIGNER-ADDED-SVA====//
assign flush_begin = (equal_cnt>5'd8) && io_equal && u_is_core.dcp.u_pipe.c0_invalidate && u_is_core2.dcp.u_pipe.c0_invalidate;
wire inv_done = !u_is_core.dcp.u_pipe.invalidate && !u_is_core2.dcp.u_pipe.invalidate;
wire no_noc1 = u_is_core.dcp.u_pipe.u_dcp_pipe_sva.noc1out_outstanding_req_r=='0 && u_is_core2.dcp.u_pipe.u_dcp_pipe_sva.noc1out_outstanding_req_r=='0;
wire no_noc2 = u_is_core.dcp.u_pipe.u_dcp_pipe_sva.noc2out_outstanding_req_r=='0 && u_is_core2.dcp.u_pipe.u_dcp_pipe_sva.noc2out_outstanding_req_r=='0;
wire no_req = !transducer_l15_val && !transducer_l15_val_2 && !dev1_merger_vr_noc2_val && !dev1_merger_vr_noc2_val_2 && !dev1_merger_vr_noc1_val && !dev1_merger_vr_noc1_val_2;

assign flush_end = inv_done && no_noc2 && no_noc1 && no_req;

endmodule