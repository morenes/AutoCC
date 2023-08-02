# Set paths to DUT root and FT root (edit if needed)
set AUTOCC_ROOT $env(AUTOCC_ROOT)
set DUT_ROOT ${AUTOCC_ROOT}/cva6/core

# Analyze design under verification files (no edit)
set DUT_PATH ${DUT_ROOT}/
set SRC_PATH0 ${DUT_ROOT}/../corev_apu
set SRC_PATH1 ${DUT_ROOT}/../common/local/util
set SRC_PATH2 ${DUT_ROOT}/../vendor/pulp-platform/common_cells/src
set SRC_PATH3 ${DUT_ROOT}/mmu_sv39
set INC_PATH ${DUT_ROOT}/include
set PROP_PATH ${AUTOCC_ROOT}/ft_cva6/sva

set_elaborate_single_run_mode off

# Analyze property files
analyze -clear
analyze -sv12 -f ${AUTOCC_ROOT}/ft_cva6/files.vc

# Elaborate design and properties
elaborate -top cva6_wrap

# Set up Clocks and Resets
clock clk_i
reset -expression (!rst_ni)

set_prove_time_limit 72h
autoprove -all -bg
report
