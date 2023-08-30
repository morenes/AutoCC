#!/bin/bash
set -euo pipefail

# Define the directories
DIR=$DUT_ROOT

# Define the filename
FILENAME=vscale_ctrl.v

# Define the old and new lines
OLD_LINE='|| (fence_i && store_in_WB) || (uses_md && !md_req_ready);'
NEW_LINES='|| (fence_i && store_in_WB) || (uses_md_unkilled && !md_req_ready)\n|| (dmem_en_unkilled && dmem_wait);'

# Escape ampersand characters
OLD_LINE=$(echo "$OLD_LINE" | sed 's/&/\\&/g')
NEW_LINES=$(echo "$NEW_LINES" | sed 's/&/\\&/g')

# Replace the old line with new lines in the file in DIR
sed -i "s#${OLD_LINE}#${NEW_LINES}#g" "$DIR/$FILENAME"

echo "The file $FILENAME in $DIR has been updated."
