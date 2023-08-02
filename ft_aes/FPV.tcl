# Set paths to DUT root and FT root (edit if needed)
set AUTOCC_ROOT $env(AUTOCC_ROOT)
set DUT_ROOT ${AUTOCC_ROOT}/aes

# Analyze design under verification files (no edit)
set DUT_PATH ${DUT_ROOT}/
set PROP_PATH ${AUTOCC_ROOT}/ft_aes/sva

set_elaborate_single_run_mode off

# Analyze property files
analyze -clear
analyze -sv12 -f ${AUTOCC_ROOT}/ft_aes/files.vc

# Elaborate design and properties
elaborate -top aes_wrap

# Set up Clocks and Resets
clock clk
reset -expression (!reset_n)

set_prove_time_limit 72h

autoprove -all -bg
