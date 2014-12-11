#!/bin/bash
#
# Description: Handles basic logarch configuration


declare -r CONF_PATH='../_debug';

declare -r VAR_PATH="$CONF_PATH/var";
declare -r CACHE_PATH="$CONF_PATH/cache";
declare -r NODE_PATH="$CONF_PATH/node";


# String last_sync_index(int value);
function last_sync_index() {

    local syncs=($SYNC_PATH/[0-9]*);
        
    local current;
    
    if [[ "${syncs[@]}" == "$SYNC_PATH/[0-9]*" ]]; then
        current=-1;        
    else        
        current=${syncs[-1]};
        current=$(basename $current);
        current=$(to_unpadded_number $current)        
    fi  
    
    echo $current;
}