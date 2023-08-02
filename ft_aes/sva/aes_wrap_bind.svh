bind aes_wrap aes_wrap_prop
	#(
		.DATA_W (DATA_W),
		.KEY_L (KEY_L),
		.NO_ROUNDS (NO_ROUNDS),
		.ASSERT_INPUTS (0)
	) u_aes_wrap_sva(.*);