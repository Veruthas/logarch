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

# int log(int val)
function log() {
    
    local value=$1;
    local result=-1;
    
    while (( value > 0 )); do
        (( value /= 10 )); (( result++ ));
    done
    
    echo $result;
}

# HACK: Using eval for functional-style programming

# void process_file(String file, String command, String? init)
function process_file() {

    local file=$1;
    local command="$2";
    local init="$3";
    
    [[ ! -e $file ]] && terminate 1 "file not found: '$file'";
        
    
    [[ -n "$init" ]] && eval "$init";
    
    local line=;
    local index=0;    
        
    local contents="$(cat $file)";            
    
    while IFS= read -r line || [[ -n $line ]]; do
        
        eval "$command";
        
        (( index++ ));
        echo "$index; $line" >> test_data
    done <<< "$contents";        
}

# void clear_file(String file)
function clear_file() {
    > $1;
}

# int correct_index(int index, int max, int? min)
function correct_index() {
    local index=$1;
    local max=$2;
    local min=$3;
        
    [[ -z $min ]] && min=0;    
    (( index < 0 )) && index=$(( $max + $index));
    (( index < 0 )) && index=$min;
    (( index > max )) && index=$max;
    
    echo $index;
}

# void num_file(String file, int from, int start, int count)
function num_file() {

    local file=$1; shift;
    local from=0;  [[ -n $1 ]] && from=$1; shift;
    local start=0; [[ -n $1 ]] && start=$1; shift;
    local end=-1;  [[ -n $1 ]] && end=$1; shift;   
    
    local init="local total=\$(wc -l < \$file); \
                local width=\${#total}; \
                local from=$from; \
                local start=\$(correct_index $start \$total); \
                local end=\$(correct_index $end \$total); \
                local i=0;";
    
    local command='(( index >= start && index < end )) && \
                   { i=$((index + from)); \
                     printf "%*s" $(( width - ${#i} )); \
                     printf "$i: %s\n" "$line"; }';
    
    process_file $file "$command" "$init"
}

# void list_file(String file, int start, int end)
function list_file() {
    local file=$1; shift;
    local start=0; [[ -n $1 ]] && start=$1; shift;
    local end=-1;  [[ -n $1 ]] && end=$1; shift;   
    
    local init="local total=\$(wc -l < \$file); \
                local start=\$(correct_index $start \$total); \
                local end=\$(correct_index $end \$total);";                
    
    local command='(( index >= start && index < end )) && echo "$line";'
    
    process_file $file "$command" "$init"
}

