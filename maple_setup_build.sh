#!/bin/bash

# Make sure that PITON_ROOT is set
if [ -z "$PITON_ROOT" ]; then
    echo "ERROR: \$PITON_ROOT is not set"
    echo "Source ariane_setup.sh first"
else
    # Make sure that AUTOCC_ROOT is set
    if [ -z "$AUTOCC_ROOT" ]; then
        echo "ERROR: \$AUTOCC_ROOT is not set"
        echo "Set AUTOCC_ROOT to the root of the AutoCC repository"
    else
        export DUT_ROOT=$PITON_ROOT/maple/rtl
        echo "DUT_ROOT set to $DUT_ROOT"

        cd $PITON_ROOT;

        # if maple folder does not exist
        if [ ! -d "maple" ]; then
            git clone https://github.com/PrincetonUniversity/maple.git
            cd maple; git checkout 2abe2d06c367c15910181ad4f3e7f0c59af32b64
            cd $AUTOCC_ROOT
            python autocc.py -f is_core.v -m autocc_only_wrap
            rm -rf $AUTOCC_ROOT/ft_is_core
        fi

        cd $PITON_ROOT;
        sed -i 's/python$/python2/' piton/design/chip/tile/ariane/bootrom/Makefile;
        sed -i 's/python$/python2/' piton/design/chip/tile/ariane/openpiton/bootrom/linux/Makefile;

        cd $PITON_ROOT/build;
        sims -sys=manycore -ariane -decoupling -vcs_build -x_tiles=4 -y_tiles=1 -config_rtl=MINIMAL_MONITORING;
        echo ""
        echo "Finished BUILDING RTL"
        echo ""
        cd $PITON_ROOT/maple
    fi
fi