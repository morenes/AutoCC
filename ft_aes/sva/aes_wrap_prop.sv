module aes_wrap_prop
 #(
		parameter ASSERT_INPUTS = 0,
		parameter DATA_W = 128,      //data width
		parameter KEY_L = 128,       //key length
		parameter NO_ROUNDS = 10     //number of rounds
)(
		input clk,                       //system clock
		input reset_n,                     //asynch reset_n
		input flush,
		
		input data_valid_in,             //data valid signal
		input cipherkey_valid_in,        //cipher key valid signal
		input [KEY_L-1:0] cipher_key,    //cipher key
		input [DATA_W-1:0] plain_text,   //plain text
		input  valid_out,                //input  valid signal //output
		input  [DATA_W-1:0] cipher_text,  //cipher text //output
		
		input data_valid_in2,             //data valid signal
		input cipherkey_valid_in2,        //cipher key valid signal
		input [KEY_L-1:0] cipher_key2,    //cipher key
		input [DATA_W-1:0] plain_text2,   //plain text
		input  valid_out2,                //input  valid signal //output
		input  [DATA_W-1:0] cipher_text2  //cipher text //output
	);

//==============================================================================
// Local Parameters
//==============================================================================

genvar j;
default clocking cb @(posedge clk);
endclocking
default disable iff (!reset_n);

// Re-defined wires 

// Symbolics and Handshake signals

//==============================================================================
// Modeling
//==============================================================================


//====DESIGNER-ADDED-SVA====//

wire architectural_state_eq = flush && aes_top.valid_round_data=='0 && aes_top2.valid_round_data=='0 && 
	aes_top.valid_sub2shift=='0 && aes_top2.valid_sub2shift=='0 &&
	aes_top.valid_shift2key=='0 && aes_top2.valid_shift2key=='0 &&
	aes_top.ROUND[0].U_ROUND.valid_mix2key=='0 && aes_top2.ROUND[0].U_ROUND.valid_mix2key=='0 &&
	aes_top.ROUND[0].U_ROUND.valid_sub2shift=='0 && aes_top2.ROUND[0].U_ROUND.valid_sub2shift=='0 &&
	aes_top.ROUND[0].U_ROUND.valid_shift2mix=='0 && aes_top2.ROUND[0].U_ROUND.valid_shift2mix=='0 &&
	aes_top.ROUND[1].U_ROUND.valid_mix2key=='0   && aes_top2.ROUND[1].U_ROUND.valid_mix2key=='0 &&
	aes_top.ROUND[1].U_ROUND.valid_sub2shift=='0 && aes_top2.ROUND[1].U_ROUND.valid_sub2shift=='0 &&
	aes_top.ROUND[1].U_ROUND.valid_shift2mix=='0 && aes_top2.ROUND[1].U_ROUND.valid_shift2mix=='0 &&
	aes_top.ROUND[2].U_ROUND.valid_mix2key=='0   && aes_top2.ROUND[2].U_ROUND.valid_mix2key=='0 &&
	aes_top.ROUND[2].U_ROUND.valid_sub2shift=='0 && aes_top2.ROUND[2].U_ROUND.valid_sub2shift=='0 &&
	aes_top.ROUND[2].U_ROUND.valid_shift2mix=='0 && aes_top2.ROUND[2].U_ROUND.valid_shift2mix=='0 &&
	aes_top.ROUND[3].U_ROUND.valid_mix2key=='0   && aes_top2.ROUND[3].U_ROUND.valid_mix2key=='0 &&
	aes_top.ROUND[3].U_ROUND.valid_sub2shift=='0 && aes_top2.ROUND[3].U_ROUND.valid_sub2shift=='0 &&
	aes_top.ROUND[3].U_ROUND.valid_shift2mix=='0 && aes_top2.ROUND[3].U_ROUND.valid_shift2mix=='0 &&
	aes_top.ROUND[4].U_ROUND.valid_mix2key=='0   && aes_top2.ROUND[4].U_ROUND.valid_mix2key=='0 &&
	aes_top.ROUND[4].U_ROUND.valid_sub2shift=='0 && aes_top2.ROUND[4].U_ROUND.valid_sub2shift=='0 &&
	aes_top.ROUND[4].U_ROUND.valid_shift2mix=='0 && aes_top2.ROUND[4].U_ROUND.valid_shift2mix=='0 &&
	aes_top.ROUND[5].U_ROUND.valid_mix2key=='0   && aes_top2.ROUND[5].U_ROUND.valid_mix2key=='0 &&
	aes_top.ROUND[5].U_ROUND.valid_sub2shift=='0 && aes_top2.ROUND[5].U_ROUND.valid_sub2shift=='0 &&
	aes_top.ROUND[5].U_ROUND.valid_shift2mix=='0 && aes_top2.ROUND[5].U_ROUND.valid_shift2mix=='0 &&
	aes_top.ROUND[6].U_ROUND.valid_mix2key=='0   && aes_top2.ROUND[6].U_ROUND.valid_mix2key=='0 &&
	aes_top.ROUND[6].U_ROUND.valid_sub2shift=='0 && aes_top2.ROUND[6].U_ROUND.valid_sub2shift=='0 &&
	aes_top.ROUND[6].U_ROUND.valid_shift2mix=='0 && aes_top2.ROUND[6].U_ROUND.valid_shift2mix=='0 &&
	aes_top.ROUND[7].U_ROUND.valid_mix2key=='0   && aes_top2.ROUND[7].U_ROUND.valid_mix2key=='0 &&
	aes_top.ROUND[7].U_ROUND.valid_sub2shift=='0 && aes_top2.ROUND[7].U_ROUND.valid_sub2shift=='0 &&
	aes_top.ROUND[7].U_ROUND.valid_shift2mix=='0 && aes_top2.ROUND[7].U_ROUND.valid_shift2mix=='0 &&
	aes_top.ROUND[8].U_ROUND.valid_mix2key=='0   && aes_top2.ROUND[8].U_ROUND.valid_mix2key=='0 &&
	aes_top.ROUND[8].U_ROUND.valid_sub2shift=='0 && aes_top2.ROUND[8].U_ROUND.valid_sub2shift=='0 &&
	aes_top.ROUND[8].U_ROUND.valid_shift2mix=='0 && aes_top2.ROUND[8].U_ROUND.valid_shift2mix=='0 &&
	aes_top.valid_shift2key_delayed=='0 && aes_top2.valid_shift2key_delayed=='0;

wire io_equal = aes_top.valid_out=='0 && aes_top2.valid_out=='0 && aes_top.data_valid_in=='0 && aes_top2.data_valid_in=='0;

wire transfer_cond = architectural_state_eq && io_equal;

localparam THRESHOLD = 1;
reg [$clog2(THRESHOLD):0] equal_cnt;
wire spy_starts = transfer_cond && equal_cnt >= THRESHOLD;
reg spy_mode;
wire flush_done; //Set free by default (anytime) USER may set the conditions that indicate the flush has finished for both 

always_ff @(posedge clk) begin
	if (!reset_n) begin
		spy_mode     <= '0;
		equal_cnt  <= '0;
	end else begin
		spy_mode     <= spy_starts || spy_mode;
		equal_cnt <= (flush_done || equal_cnt>0) && transfer_cond ? equal_cnt + 1 : '0;
	end
end

// Make sure that cores are making the same AXI requests after the flush.
as__valid_out_same: assert property (spy_mode |-> (valid_out == valid_out2));
as__cipher_text_same: assert property (spy_mode && valid_out |-> (cipher_text == cipher_text2));

am__data_valid_in_same: assume property (spy_mode |-> (data_valid_in == data_valid_in2));
am__cipherkey_valid_in_same: assume property (spy_mode |-> (cipherkey_valid_in == cipherkey_valid_in2));
am__cipher_key_same: assume property (spy_mode |-> (cipher_key == cipher_key2));
am__plain_text_same: assume property (spy_mode |-> (plain_text == plain_text2));

endmodule