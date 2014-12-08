#!/bin/bash
#
# Description: utility functions

# void terminate(int errorCode, String prompt)
function terminate() {
    echo "ERROR: $2" >&2;
    exit $1;
}

# bool contains_item(String item, String[] list)
function contains_item() {
    local item=$1; shift;
    local -a list=("$@");
    
    for val in $list; do        
        [[ $item == $val ]] && return 0;            
    done
    return 1;
}

# (void|exit) confirm_empty(String message, String[] args_to_check)
function confirm_empty() {
    local message=$1; shift;
    
    if [[ -n "$@" ]]; then
        terminate 1 "$message'$@'";
    fi
}

# String ask(String message, String[] responses)
function ask() {
    local prompt=$1; shift;    
    local result;
    
    read -p "$prompt" result;
    
    local i=1;
    
    for response in $@; do        
        if [[ $response == $result ]]; then
            echo $result; 
            return;
        fi
    done
    
    echo noresult
    return 1;
}


# void insert_lines(String file, int index, int count, String[] lines)
function insert_lines() {
    local file=$1;        
    local index=$2;   # index of 0 is prepend, <0 || >lc is append, else is insert 
    local count=$3;
    
    shift 3;
        
    [[ -e $file ]] && local total=$(wc -l < $file) || local total=0;
    
    local i=0;
    
    # append
    if (( index < 0 )) || (( index  >= total )); then        
        for (( ; i < count; i++ )); do
            printf "%s\n" "$1" >> $file;
            shift;
        done
        
    # prepend/insert
    else        
        # use a here-string
        local data=$(cat $file);
    
        # clear the file
        > $file;
        
        while read -r line; do
        
            if (( $i == index )); then
                local j=0;
                for (( ; j < count; j++ )); do
                    printf "%s\n" "$1" >> $file;
                    shift;
                done
            fi
            
            printf "%s\n" "$line" >> $file;
            
            (( i++ ));
        
        done <<< "$data"
        
        # HACK: This is to keep it consistent, otherwise change (index >= total) to '>'
        printf "\n" >> $file; 
    fi       
    
    # TODO: think this function is inefficient (counting line multiple times, herestring...)
}