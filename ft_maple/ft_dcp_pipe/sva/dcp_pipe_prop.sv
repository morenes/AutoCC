`include "dcp.h"


module dcp_pipe_prop
#(
		parameter ASSERT_INPUTS = 0)
 (
		input wire clk,
		input wire rst_n,
		input wire [`HOME_ALLOC_METHOD_WIDTH-1:0] home_alloc_method,
		input wire [`HOME_ID_WIDTH-1:0] system_tile_count,
		
		
		// Update TLB from DCP
		input  wire                            tlb_update, //output
		input  wire                            tlb_conf_ptbase, //output
		input  wire                            tlb_disable, //output
		input  wire                            tlb_flush, //output

		input  wire [63:0]                     conf_data, //output
		
		// TLB req/res iface
		input  wire                            tlb_req, //output
		input  wire                            tlb_ack,
		input  wire                            tlb_exc_val,
		input  wire [`TLB_SRC_NUM  -1:0]       tlb_ptw_src,
		input  wire [`DCP_VADDR    -1:0]       tlb_vaddr, //output
		input  wire [`DCP_PADDR    -1:0]       tlb_paddr,
		
		// Snoop TLB entries from DCP
		input  wire                            tlb_snoop_val, //output
		input  wire [63:0]                     tlb_snoop_entry, 
	
		
		// NOC1 - Outgoing Atomic op request to L2 
		input  wire                          dcp_noc1buffer_rdy,
		input  wire                          dcp_noc1buffer_val, //output
		input  wire [`MSG_TYPE_WIDTH-1:0]    dcp_noc1buffer_type, //output
		input  wire [`DCP_MSHRID_WIDTH -1:0] dcp_noc1buffer_mshrid, //output
		input  wire [`DCP_PADDR_MASK       ] dcp_noc1buffer_address, //output
		input  wire [`DCP_UNPARAM_2_0      ] dcp_noc1buffer_size, //output
		input  wire [`PACKET_HOME_ID_WIDTH-1:0] dcp_noc1buffer_homeid, //output
		input  wire [`MSG_AMO_MASK_WIDTH-1:0] dcp_noc1buffer_write_mask, //output
		input  wire [`DCP_UNPARAM_63_0     ] dcp_noc1buffer_data_0, //output
		input  wire [`DCP_UNPARAM_63_0     ] dcp_noc1buffer_data_1, //output
		
		// NOC2 - Outgoing TLoad op request to DRAM or Store ACK 
		input  wire                          dcp_noc2buffer_rdy,
		input  wire                          dcp_noc2buffer_val, //output
		input  wire [`MSG_TYPE_WIDTH   -1:0] dcp_noc2buffer_type, //output
		input  wire [`DCP_MSHRID_WIDTH -1:0] dcp_noc2buffer_mshrid, //output
		input  wire [`DCP_PADDR_MASK       ] dcp_noc2buffer_address, //output
		input  wire [`DCP_UNPARAM_63_0     ] dcp_noc2buffer_data, //output
		input  wire [`PACKET_HOME_ID_WIDTH-1:0] dcp_noc2buffer_homeid, //output
		input  wire [`MSG_SRC_FBITS_WIDTH -1:0] dcp_noc2buffer_fbits, //output
		
		// NOC1 - Incoming Load/Store requests
		input  wire                          noc1decoder_dcp_val,
		input  wire                          noc1decoder_dcp_ack, //output
		input  wire [`DCP_MSHRID_WIDTH -1:0] noc1decoder_dcp_mshrid,
		input  wire [`MSG_TYPE_WIDTH   -1:0] noc1decoder_dcp_reqtype,
		input  wire [`DCP_UNPARAM_63_0     ] noc1decoder_dcp_data,
		input  wire [`DCP_PADDR_MASK       ] noc1decoder_dcp_address,
		input  wire [`MSG_DATA_SIZE_WIDTH-1:0]  noc1decoder_dcp_size,  
		input  wire [`MSG_SRC_X_WIDTH  -1:0]    noc1decoder_dcp_src_x,  
		input  wire [`MSG_SRC_Y_WIDTH  -1:0]    noc1decoder_dcp_src_y,  
		input  wire [`MSG_SRC_CHIPID_WIDTH-1:0] noc1decoder_dcp_chipid,
		input  wire [`MSG_SRC_FBITS_WIDTH- 1:0] noc1decoder_dcp_fbits,
		
		// NOC2 - Atomic op response from L2
		input  wire                          noc2decoder_dcp_val,
		input  wire                          noc2decoder_dcp_ack, //output
		input  wire [`DCP_MSHRID_WIDTH -1:0] noc2decoder_dcp_mshrid,
		input  wire [`MSG_LENGTH_WIDTH -1:0] noc2decoder_dcp_length,
		input  wire [`MSG_TYPE_WIDTH   -1:0] noc2decoder_dcp_reqtype,
		input  wire [`DCP_NOC_RES_DATA_SIZE-1:0] noc2decoder_dcp_data,
		
		// NOC3 - TLoad response from DRAM
		input  wire                          noc3decoder_dcp_val,
		input  wire                          noc3decoder_dcp_ack, //output
		input  wire [`DCP_MSHRID_WIDTH -1:0] noc3decoder_dcp_mshrid,
		input  wire [`MSG_TYPE_WIDTH   -1:0] noc3decoder_dcp_reqtype,
		input  wire [`DCP_NOC_RES_DATA_SIZE-1:0] noc3decoder_dcp_data
	);

//==============================================================================
// Local Parameters
//==============================================================================

genvar j;
default clocking cb @(posedge clk);
endclocking
default disable iff (!rst_n);

// Re-defined wires 
wire store_val;
wire store_rdy;
wire load_val;
wire load_rdy;
wire tlb_exc_transid;
wire tlb_get_val;
wire tlb_get_transid;
wire [1:0] tlb_get_data;
wire tlb_set_val;
wire tlb_set_transid;
wire [1:0] tlb_set_data;
wire dcp_noc2bufferack_val;
wire dcp_noc2bufferack_rdy;
wire [`DCP_MSHRID_WIDTH-1:0] dcp_noc2bufferack_transid;
wire dcp_noc1bufferout_val;
wire dcp_noc1bufferout_rdy;
wire [`DCP_MSHRID_WIDTH-1:0] dcp_noc1bufferout_transid;
wire [`DCP_MSHRID_WIDTH-1:0] noc2decoder_dcp_transid;
wire dcp_noc2bufferout_val;
wire dcp_noc2bufferout_rdy;
wire [`DCP_MSHRID_WIDTH-1:0] dcp_noc2bufferout_transid;

// Symbolics and Handshake signals
wire [0:0] symb_tlb_get_transid;
am__symb_tlb_get_transid_stable: assume property($stable(symb_tlb_get_transid));
wire tlb_set_hsk = tlb_set_val;
wire tlb_get_hsk = tlb_get_val;
wire [`DCP_MSHRID_WIDTH-1:0] symb_noc1decoder_dcp_mshrid;
am__symb_noc1decoder_dcp_mshrid_stable: assume property($stable(symb_noc1decoder_dcp_mshrid));
wire dcp_noc2bufferack_hsk = dcp_noc2bufferack_val && dcp_noc2bufferack_rdy;
wire noc1decoder_dcp_hsk = noc1decoder_dcp_val && noc1decoder_dcp_ack;
wire [`DCP_MSHRID_WIDTH-1:0] symb_dcp_noc1bufferout_transid;
am__symb_dcp_noc1bufferout_transid_stable: assume property($stable(symb_dcp_noc1bufferout_transid));
wire noc2decoder_dcp_hsk = noc2decoder_dcp_val && noc2decoder_dcp_ack;
wire dcp_noc1bufferout_hsk = dcp_noc1bufferout_val && dcp_noc1bufferout_rdy;
wire [0:0] symb_tlb_exc_transid;
am__symb_tlb_exc_transid_stable: assume property($stable(symb_tlb_exc_transid));
wire tlb_exc_hsk = tlb_exc_val;
wire [`DCP_MSHRID_WIDTH-1:0] symb_dcp_noc2bufferout_transid;
am__symb_dcp_noc2bufferout_transid_stable: assume property($stable(symb_dcp_noc2bufferout_transid));
wire noc3decoder_dcp_hsk = noc3decoder_dcp_val && noc3decoder_dcp_ack;
wire dcp_noc2bufferout_hsk = dcp_noc2bufferout_val && dcp_noc2bufferout_rdy;

//==============================================================================
// Modeling
//==============================================================================

// Modeling outstanding request for exc_req
reg [2**(0+1)-1:0] exc_req_outstanding_req_r;
reg [2**(0+1)-1:0][1:0] exc_req_outstanding_req_data_r;

always_ff @(posedge clk) begin
	if(!rst_n) begin
		exc_req_outstanding_req_r <= '0;
	end else begin
		if (tlb_get_hsk) begin
			exc_req_outstanding_req_r[tlb_get_transid] <= 1'b1;
			exc_req_outstanding_req_data_r[tlb_get_transid] <= tlb_get_data;
		end
		if (tlb_set_hsk) begin
			exc_req_outstanding_req_r[tlb_set_transid] <= 1'b0;
		end
	end
end


generate
if (ASSERT_INPUTS) begin : exc_req_gen
	as__exc_req1: assert property (!exc_req_outstanding_req_r[symb_tlb_get_transid] |-> !(tlb_set_hsk && (tlb_set_transid == symb_tlb_get_transid)));
	as__exc_req2: assert property (exc_req_outstanding_req_r[symb_tlb_get_transid] |-> s_eventually(tlb_set_hsk && (tlb_set_transid == symb_tlb_get_transid)&&
	 (tlb_set_data == exc_req_outstanding_req_data_r[symb_tlb_get_transid]) ));
end else begin : exc_req_else_gen
	for ( j = 0; j < 2**(0+1); j = j + 1) begin : exc_req_for_gen
		// co__exc_req: cover property (exc_req_outstanding_req_r[j]);
		am__exc_req1: assume property (!exc_req_outstanding_req_r[j] |-> !(tlb_set_val && (tlb_set_transid == j)));
		am__exc_req2: assume property (exc_req_outstanding_req_r[j] |-> s_eventually(tlb_set_val && (tlb_set_transid == j)&&
	 (tlb_set_data == exc_req_outstanding_req_data_r[j]) ));
	end
end
endgenerate

// Modeling incoming request for noc1in
if (ASSERT_INPUTS) begin
	as__noc1in_fairness: assert property (dcp_noc2bufferack_val |-> s_eventually(dcp_noc2bufferack_rdy));
end else begin
	am__noc1in_fairness: assume property (dcp_noc2bufferack_val |-> s_eventually(dcp_noc2bufferack_rdy));
end

// Generate sampling signals and model
reg [3:0] noc1in_mshrid_sampled;
wire noc1in_mshrid_set = noc1decoder_dcp_hsk && noc1decoder_dcp_mshrid == symb_noc1decoder_dcp_mshrid;
wire noc1in_mshrid_response = dcp_noc2bufferack_hsk && dcp_noc2bufferack_transid == symb_noc1decoder_dcp_mshrid;

always_ff @(posedge clk) begin
	if(!rst_n) begin
		noc1in_mshrid_sampled <= '0;
	end else if (noc1in_mshrid_set || noc1in_mshrid_response ) begin
		noc1in_mshrid_sampled <= noc1in_mshrid_sampled + noc1in_mshrid_set - noc1in_mshrid_response;
	end
end
// co__noc1in_mshrid_sampled: cover property (|noc1in_mshrid_sampled);
if (ASSERT_INPUTS) begin
	as__noc1in_mshrid_sample_no_overflow: assert property (noc1in_mshrid_sampled != '1 || !noc1in_mshrid_set);
end else begin
	am__noc1in_mshrid_sample_no_overflow: assume property (noc1in_mshrid_sampled != '1 || !noc1in_mshrid_set);
end


// Assert that if valid eventually ready or dropped valid
as__noc1in_mshrid_hsk_or_drop: assert property (noc1decoder_dcp_val |-> s_eventually(!noc1decoder_dcp_val || noc1decoder_dcp_ack));
// Assert that every request has a response and that every reponse has a request
as__noc1in_mshrid_eventual_response: assert property (|noc1in_mshrid_sampled |-> s_eventually(dcp_noc2bufferack_val && (dcp_noc2bufferack_transid == symb_noc1decoder_dcp_mshrid) ));
as__noc1in_mshrid_was_a_request: assert property (noc1in_mshrid_response |-> noc1in_mshrid_set || noc1in_mshrid_sampled);

// Modeling outstanding request for noc1out
reg [2**(`DCP_MSHRID_WIDTH-1+1)-1:0] noc1out_outstanding_req_r;

always_ff @(posedge clk) begin
	if(!rst_n) begin
		noc1out_outstanding_req_r <= '0;
	end else begin
		if (dcp_noc1bufferout_hsk) begin
			noc1out_outstanding_req_r[dcp_noc1bufferout_transid] <= 1'b1;
		end
		if (noc2decoder_dcp_hsk) begin
			noc1out_outstanding_req_r[noc2decoder_dcp_transid] <= 1'b0;
		end
	end
end


generate
if (ASSERT_INPUTS) begin : noc1out_gen
	as__noc1out1: assert property (!noc1out_outstanding_req_r[symb_dcp_noc1bufferout_transid] |-> !(noc2decoder_dcp_hsk && (noc2decoder_dcp_transid == symb_dcp_noc1bufferout_transid)));
	as__noc1out2: assert property (noc1out_outstanding_req_r[symb_dcp_noc1bufferout_transid] |-> s_eventually(noc2decoder_dcp_hsk && (noc2decoder_dcp_transid == symb_dcp_noc1bufferout_transid)));
end else begin : noc1out_else_gen
	am__noc1out_fairness: assume property (dcp_noc1bufferout_val |-> s_eventually(dcp_noc1bufferout_rdy));
	for ( j = 0; j < 2**(`DCP_MSHRID_WIDTH-1+1); j = j + 1) begin : noc1out_for_gen
		// co__noc1out: cover property (noc1out_outstanding_req_r[j]);
		am__noc1out1: assume property (!noc1out_outstanding_req_r[j] |-> !(noc2decoder_dcp_val && (noc2decoder_dcp_transid == j)));
		am__noc1out2: assume property (noc1out_outstanding_req_r[j] |-> s_eventually(noc2decoder_dcp_val && (noc2decoder_dcp_transid == j)));
	end
end
endgenerate

// Modeling outstanding request for exc_val
reg [2**(0+1)-1:0] exc_val_outstanding_req_r;

always_ff @(posedge clk) begin
	if(!rst_n) begin
		exc_val_outstanding_req_r <= '0;
	end else begin
		if (tlb_exc_hsk) begin
			exc_val_outstanding_req_r[tlb_exc_transid] <= 1'b1;
		end
		if (tlb_get_hsk) begin
			exc_val_outstanding_req_r[tlb_get_transid] <= 1'b0;
		end
	end
end


generate
if (ASSERT_INPUTS) begin : exc_val_gen
	as__exc_val1: assert property (!exc_val_outstanding_req_r[symb_tlb_exc_transid] |-> !(tlb_get_hsk && (tlb_get_transid == symb_tlb_exc_transid)));
	as__exc_val2: assert property (exc_val_outstanding_req_r[symb_tlb_exc_transid] |-> s_eventually(tlb_get_hsk && (tlb_get_transid == symb_tlb_exc_transid)));
end else begin : exc_val_else_gen
	for ( j = 0; j < 2**(0+1); j = j + 1) begin : exc_val_for_gen
		// co__exc_val: cover property (exc_val_outstanding_req_r[j]);
		am__exc_val1: assume property (!exc_val_outstanding_req_r[j] |-> !(tlb_get_val && (tlb_get_transid == j)));
		am__exc_val2: assume property (exc_val_outstanding_req_r[j] |-> s_eventually(tlb_get_val && (tlb_get_transid == j)));
	end
end
endgenerate

// Modeling outstanding request for noc2out
reg [2**(`DCP_MSHRID_WIDTH-1+1)-1:0] noc2out_outstanding_req_r;

always_ff @(posedge clk) begin
	if(!rst_n) begin
		noc2out_outstanding_req_r <= '0;
	end else begin
		if (dcp_noc2bufferout_hsk) begin
			noc2out_outstanding_req_r[dcp_noc2bufferout_transid] <= 1'b1;
		end
		if (noc3decoder_dcp_hsk) begin
			noc2out_outstanding_req_r[noc3decoder_dcp_mshrid] <= 1'b0;
		end
	end
end


generate
if (ASSERT_INPUTS) begin : noc2out_gen
	as__noc2out1: assert property (!noc2out_outstanding_req_r[symb_dcp_noc2bufferout_transid] |-> !(noc3decoder_dcp_hsk && (noc3decoder_dcp_mshrid == symb_dcp_noc2bufferout_transid)));
	as__noc2out2: assert property (noc2out_outstanding_req_r[symb_dcp_noc2bufferout_transid] |-> s_eventually(noc3decoder_dcp_hsk && (noc3decoder_dcp_mshrid == symb_dcp_noc2bufferout_transid)));
end else begin : noc2out_else_gen
	am__noc2out_fairness: assume property (dcp_noc2bufferout_val |-> s_eventually(dcp_noc2bufferout_rdy));
	for ( j = 0; j < 2**(`DCP_MSHRID_WIDTH-1+1); j = j + 1) begin : noc2out_for_gen
		// co__noc2out: cover property (noc2out_outstanding_req_r[j]);
		am__noc2out1: assume property (!noc2out_outstanding_req_r[j] |-> !(noc3decoder_dcp_val && (noc3decoder_dcp_mshrid == j)));
		am__noc2out2: assume property (noc2out_outstanding_req_r[j] |-> s_eventually(noc3decoder_dcp_val && (noc3decoder_dcp_mshrid == j)));
	end
end
endgenerate

assign load_val = dcp_noc2buffer_val && dcp_noc2buffer_type == `DCP_NOC2_LOAD_ACK;
assign tlb_get_transid = dcp_pipe.tlb_exc_src;
assign tlb_exc_transid = tlb_ptw_src[1];
assign tlb_set_transid = dcp_pipe.tlb_mmpage_src_oh[1];
assign dcp_noc2bufferout_transid = dcp_noc2buffer_mshrid;
assign tlb_get_data = dcp_pipe.tlb_exc_src_oh;
assign dcp_noc1bufferout_transid = dcp_noc1buffer_mshrid[`DCP_MSHRID_WIDTH-1:0];
assign tlb_set_data = dcp_pipe.tlb_mmpage_src_oh;
assign tlb_get_val = dcp_pipe.tlb_get_pfault;
assign dcp_noc1bufferout_rdy = dcp_noc1buffer_rdy;
assign dcp_noc2bufferack_transid = dcp_noc2buffer_mshrid;
assign noc2decoder_dcp_transid = noc2decoder_dcp_mshrid[`DCP_MSHRID_WIDTH-1:0];
assign tlb_set_val = dcp_pipe.tlb_conf_mmpage;
assign dcp_noc2bufferout_val = dcp_noc2buffer_val && dcp_noc2buffer_type == `DCP_NOC2_LOAD_REQ64;
assign store_rdy = dcp_noc2buffer_rdy;
assign dcp_noc1bufferout_val = dcp_noc1buffer_val;
assign dcp_noc2bufferack_rdy = dcp_noc2buffer_rdy;
assign store_val = dcp_noc2buffer_val && dcp_noc2buffer_type == `DCP_NOC2_STORE_ACK;
assign dcp_noc2bufferout_rdy = dcp_noc2buffer_rdy;
assign dcp_noc2bufferack_val = dcp_noc2buffer_val && (dcp_noc2buffer_type==`DCP_NOC2_STORE_ACK || dcp_noc2buffer_type == `DCP_NOC2_LOAD_ACK);
assign load_rdy = dcp_noc2buffer_rdy;

//====DESIGNER-ADDED-SVA====//
endmodule