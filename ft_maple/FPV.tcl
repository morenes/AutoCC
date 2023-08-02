# Set paths to DUT root and FT root (edit if needed)
set AUTOCC_ROOT $env(AUTOCC_ROOT)
set DUT_ROOT ${AUTOCC_ROOT}/openpiton/maple/rtl

# Analyze design under verification files (no edit)
set DUT_PATH ${DUT_ROOT}/
set SRC_PATH0 ${DUT_ROOT}/../../piton/design/common/rtl
set SRC_PATH1 ${DUT_ROOT}/../../piton/design/chip/tile/common/rtl
set SRC_PATH2 ${DUT_ROOT}/../../piton/design/chip/tile/l15/rtl
set SRC_PATH3 ${DUT_ROOT}/../../piton/design/chip/tile/ariane/src/common_cells/src
set INC_PATH ${DUT_ROOT}/../../piton/design/include
set PROP_PATH ${AUTOCC_ROOT}/ft_maple/sva

set_elaborate_single_run_mode off

# Analyze property files
analyze -clear
analyze -sv12 -f ${AUTOCC_ROOT}/ft_maple/files.vc

# Elaborate design and properties
elaborate -top is_core_wrap

# Set up Clocks and Resets
clock clk_gated
reset -expression (!rst_n_f)

# Get design information to check general complexity
get_design_info

set_word_level_reduction on
set_prove_time_limit 72h

autoprove -all -bg

# Report proof results
report
