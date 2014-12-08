#!/bin/bash
#
# Description: utility functions

# void terminate(int errorCode, String prompt)
function terminate() {
    echo "$2" >&2;
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

# void insert_line(String file, int index, String line)
function insert_line() {
    local file=$1; 
    local index=$2; shift 2;
    local line="$1";
    
    local total_lines=$(wc -l < $file);
    
    echo $line
    if [[ $index -le $total_lines ]]; then
        echo $line >> $file;
    else
        sed -i "$index i\\$line" $file;   
    fi;
}

#void insert_lines(String file, int index, String[] lines)
function insert_lines() {
    local file=$1
    local index=$2;
    shift 2;
    
    echo $file;
    
    [[ ! -e "$file" ]] && local total_lines=0 || local total_lines=$(wc -l < $file);
    
        
    while [[ -n $1 ]]; do  
    
        if [[ $index -ge $total_lines ]]; then            
            echo $1 >> $file;
        else
            sed -i "$index i\\$line" $file;   
        fi;
        
        shift;
        echo $index
        (( index++ ))
    done
}