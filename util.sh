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
    
    for val in "$@"; do                
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

# bool is_integer(String value)
function is_integer() {
    [[ $1 =~ ^-?[0-9]+$ ]] && return 0 || return 1;
}

# void verify_file(String value, String error)
function verify_integer() {
    ! is_integer $1 && terminate 1 "expecting $2 ('$1')";    
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

# int log(int val)
function log() {
    
    local value=$1;
    local result=-1;
    
    while (( value > 0 )); do
        (( value /= 10 )); (( result++ ));
    done
    
    echo $result;
}

# String pad_number(int value, int zeroes)
function pad_number() {
  local value=${1:-0};
  local zeroes=${2:-1};
  
  printf "%0${zeroes}d" "$1";
}

# int unpad_number(String value)
function unpad_number {
    echo $((10#$1));
}