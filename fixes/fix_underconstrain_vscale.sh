#!/bin/bash

# Check that $AUTOCC_ROOT is set
if [ -z "$AUTOCC_ROOT" ]; then
    echo "ERROR: \$AUTOCC_ROOT is not set"
    exit 1
fi

# Check if the last two lines of the file $AUTOCC_ROOT/ft_vscale_core/sva/vscale_core_prop.sv are : //====DESIGNER-ADDED-SVA====// endmodule
# If not, add them
tail -n 3 $AUTOCC_ROOT/ft_vscale_core/sva/vscale_core_prop.sv | grep "====DESIGNER-ADDED-SVA===="
if [ $? -ne 0 ]; then
    echo "NOTHING TO DO, PROPERTIES ALREADY ADDED"
else
    sed -i '$d' $AUTOCC_ROOT/ft_vscale_core/sva/vscale_core_prop.sv
    cat $AUTOCC_ROOT/fixes/VSCALE_CEX_FIX >> $AUTOCC_ROOT/ft_vscale_core/sva/vscale_core_prop.sv
    echo "PROPERTIES ADDED"
fi