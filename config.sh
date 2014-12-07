#!/bin/bash
#
# Description: Handles basic logarch configuration

# void setup_caches()
function setup_cache() {
    path=$CACHE_PATH;
    
    mkdir -v $path/packages;
    mkdir -v $path/updates;
    
    touch tags.dat
    
    touch repos.dat    
}

# String get_cache_path();
function get_cache_path() {
    echo "../_debug"
}



# String to_padded_number(int value);
function to_padded_number() {   
    printf %010d $1;
}

# int to_unpadded_number(String paddedNumber)
function to_unpadded_number() {
    echo $((10#$1));
}


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

# String sync_path_from_index(int index);
function sync_path_from_index() {
    echo "$SYNC_PATH/$(to_padded_number $current)";
}


# String current_sync_path()
function current_sync_path() {

    local current=$(last_sync_index);
    
    if [[ $current == -1 ]]; then
        make_sync_path 0;        
    else
        sync_path_from_index $current;
    fi       
}

# void move_next_sync_path();
function move_next_sync_path() {
    SYNC_PATH=$(next_sync_path);
}

# String next_sync_path()
function next_sync_path() {

    local current=$(last_sync_index);
    
    (( current++ ));
    
    make_sync_path $current;    
}

# String make_sync_path(int index)
function make_sync_path() {
        
    local path=$(to_padded_number $1);
    
    mkdir -pv $SYNC_PATH/$path;
        
    echo $path;
}


declare CACHE_PATH="$(get_cache_path)";

declare PKG_PATH="$CACHE_PATH/pkg";

declare SYNC_PATH="$CACHE_PATH/sync"

declare CURRENT_SYNC_PATH=$(current_sync_path);
echo $CURRENT_SYNC_PATH;