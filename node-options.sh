#!/bin/bash
#
# Description: handles nodes and branching

# String create_node(String name) | returns path of new node
function create_node() {
    local name=${1:-$(get_now)};    
    local id=$(get_next_node_id);
    local date=$(get_timestamp);
    
    mkdir -v "$NODE_PATH/$id";
    
    last=$(realpath $CURRENT_NODE_PATH);
    
    new="$NODE_PATH/$id";
            
    ln -s $last $new/last;
    
    echo "$name" >> "$new/node_info.dat";
    echo "$id" >> "$new/node_info.dat";
    echo "$date" >> "$new/node_info.dat";
    
    echo $id;
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

# void move_to_node(String id)
function move_to_node() {
    rm -v $CURRENT_NODE_PATH 
    ln -s $CURRENT_NODE_PATH $new;
}


# void setup_empty_node(String id)
function setup_empty_node() {
    local node="$NODE_PATH/$1";
    local last="$path/last";
    
    ln -s "$last/sync" "$node/sync";
    [[ -e "$last/gnupg" ]] && ln -s "$last/gnupg" "$node/gnupg"
    
    cp "$last/arm_server.dat" "$node/arm_sever.dat";
    
    cp "$last/sync_info.dat" "$node/sync_info.dat"
    
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