#!/bin/bash
#
# Description: handles nodes and branching


function create_root() {
:
}

# String get_next_node_id();
function get_next_node_id() {
    local -r search_string='[0-9]+';
    
    local items=($NODE_PATH/$search_string);
    
    local -r id_length=10;
    
    if [[ "${items[@]}" == "$search_string" ]]; then
        pad_number 0 $id_length;
    else
        local id=$(base name "${items[-1]}");
        id=$(unpad_number $id);
        pad_number $((id + 1)) $id_length;
    fi
}

function get_current_id() {

    basename "$CURRENT_NODE_PATH";

}

# String create_node(String name)
function create_node() {
       
    local id=$(get_next_node_id);
    local name=${1:-$(echo "TODO: GET CURRENT NAME")}; 
    local date=$(get_now_timestamp);
    
    mkdir -v "$NODE_PATH/$id";
    
    last=$(realpath $CURRENT_NODE_PATH);
    
    new="$NODE_PATH/$id";
        
    basename $last >> "$next/last_node.dat";
    echo "$id" >> "$last/next_node.dat";
    
    echo "$name" >> "$new/node_info.dat";
    echo "$id" >> "$new/node_info.dat";
    echo "$date" >> "$new/node_info.dat";
    
    echo $id;
}

# void move_to_node(String id)
function move_to_node() {
    rm -v "$CURRENT_NODE_PATH";
    ln -s "$NODE_PATH/$1" "$CURRENT_NODE_PATH";
}

# void setup_empty_node(String id)
function setup_empty_node() {
    local node="$NODE_PATH/$1";
    local last="$path/last";
    
    ln -s "$last/sync" "$node/sync";
    [[ -e "$last/gnupg" ]] && ln -s "$last/gnupg" "$node/gnupg"
    
    cp "$last/arm_server.dat" "$node/arm_server.dat";
    
    cp "$last/sync_info.dat" "$node/sync_info.dat"
    
    [[ -e "$last/auto_sync.dat" ]] && cp "$last/auto_sync.dat" "$node";
    
    mkdir "$node/aur";
    
    touch trace.dat;    
}

# void setup_sync_node(String id);
function setup_sync_node() {
    local node="$NODE_PATH/$1";
    local last="$path/last";
    
    cp -r "$ARCH_SYNC_PATH" "$node";
    [[ -e "$ARCH_KEY_PATH" ]] && cp -r "$ARCH_KEY_PATH" "$node";
    
    
}


# void setup_sync_date(String id, int timestamp)
function set_sync_date() {
    local id=$1;
    local timestamp=$2;
    
    local node="$NODE_PATH/id";
    
    echo $timestamp > "$node/sync_date.dat";
    
    local datepath=$(date --date=@$timestamp +%Y/%m/%d)
    echo "Server=http://seblu.net/a/arm//$repo/os/$arch" >> "$node/arm_server.dat";
}

# void write_auto_file(int id, int next-seconds, (months|weeks|days), int num)
function write_auto_file() {
    local file="$NODE_PATH/$1/auto_sync.dat";
    > "$file"
    echo "$2" >> "$file";
    echo "$3" >> "$file";
    echo "$4" >> "$file";
}


# void disable_auto_sync(String id)
function disable_auto_sync() {
    local node="$NODE_PATH/$1";
    
    [[ -e "$node/auto_sync.dat" ]] && rm "$node/auto_sync.dat";
}


# void auto_option(off | ((month|week|days), 
#                           [--num, int n] 
#                           [--from, (last | now | 
#                                (int month, [int day=1 [int year=<now.year>]]])
function auto_option() {
    
    local id=$(get_current_id);
    local type=$1; shift;
    local num=1;
    local from=;
    
    if [[ "$type" == 'off' ]]; then
        auto_option_off $id;
        
        confirm_no_options "$@";
    
        disable_auto_sync="$id";
    else
        if [[ "$1" == --num ]]; then
            verify_integer "$2" "--num"
            num=$2;
            shift;
        fi
        
        if [[ "$1" == --from ]]; then
            if [[ "$2" == 'now' ]]; then
                from=$(get_now_timestamp);
            elif [[ "$2" == 'last' ]]; then
                from=$(get_last_sync_timestamp);
            else                
                from=$(get_date_timestamp $month ${3:-} ${4:-});
            fi
        else
            from=$(get_last_sync_timestamp);
        fi
    fi
}

# String get_last_sync_timestamp()
function get_last_sync_timestamp() {
:
}

function check_for_updates() {
:
}