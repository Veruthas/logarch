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

# String create_node(String name) | returns path of new node
function create_node() {
       
    local id=$(get_next_node_id);
    local name=${1:-$(get_now)}; 
    local date=$(get_timestamp);
    
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

# void see_auto_sync(String id, int num, (1..31) day, bool last)
function set_monthly_sync() {
:
}

# void set_weekly_sync(String id, int num, (1..7) day, bool last)
function set_weekly_sync() {
:
}

# void set_daily_sync(String id, int num, (--now | --last | --from YYYY MM DD))
function set_daily_sync() {
:
}

# void disable_auto_sync(String id)
function disable_auto_sync() {
    local node="$NODE_PATH/$1";
    
    [[ -e "$node/auto_sync.dat" ]] && rm "$node/auto_sync.dat";
}


# void auto_option(--months [--num n=1] [--day (1..31)=1];
#                  --weeks  [--num n=1] [--day (1..7|sunday|monday|tuesday|wednesday|thursday|friday|saturday)=1]
#                  --days   [--num n=1] [--now | --last | --from YYYY MM DD]=--now
#                  --off)
function auto_option() {
    
    local id=$(get_current_id);
    
    local type=$1; shift;    
    
    case $type in
        --months)
            set_auto_months "$id" "$@";
        ;;
        --weeks)
            set_auto_weeks "$id" "$@";
        ;;
        --days)
            set_auto_days "$id" "$@";
        ;;
        --off)
            disable_auto_sync "$id" "$@";
        ;;
    esac
}

# void auto_option_months(String id, [--num n=1] [--day (1-31)=1] [--last])
function auto_option_months() {
    local id=$1; shift;
    local num=1;
    local day=1;
    local last=false;
    
    if [[ "$1" == "--num" ]]; then
        verify_integer "$2" "number of months";
        (( num < 1 )) && terminate 1 "--num must be greater than 0";
        num=$2;
        shift 2;
    fi
    
    if [[ "$1" == "--day" ]]; then
        verify_integer "$2" "day of the month (1-31)";        
        day=$2;
        (( day < 1 || day > 31 )) && terminate 1 "--day must be from (1..31)";
        shift 2;
    fi
    
    if [[ "$1" == "--last" ]]; then
        last=true;
        shift;    
    fi
    
    confirm_no_options "$@";
    
    set_auto_months "$id" "$num" "$day" "$last";
}

# void auto_option_weeks(String id, [--num n=1] [--day (1-7|<weekday>)=1] [--last])
function auto_option_weeks() {
    local id=$1; shift;
}

# void auto_option_days(String id, [--num n=1] [--now | --from YYYY MM DD]=<--from LAST>
function auto_options_days() {
    local id=$1; shift;
}


# void auto_option_off(String id)
function auto_option_off() {
    local id=$1; shift;
    
    confirm_no_options "$@";
    
    disable_auto_sync="$id";
}

