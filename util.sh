#!/bin/bash
#
# Description: utility functions



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
        echo "$message'$@'"
        exit 1;
    fi
}

# int ask(String message, String[] responses)
function ask() {
    local prompt=$1; shift;    
    local result;
    
    read -p "$prompt" result;
    
    local i=1;
    
    for response in "$@"; do
        [[ $response == $result ]] && return $i;
    done
    
    return 0;
}