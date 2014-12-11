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

# HACK: Using eval for functional-style programming


# void process_file(String file, String command, String? init)
# defines: file, contents, line, index, command, init
function do_file() {

    local -r file=$1; verify_file $file;
    
    local -r command="$2";
    local -r init="$3";
    
    echo init: \'$init\';echo command: \'$command\';
    
    
    local -r contents="$(cat $file)";         
    
    [[ -n "$init" ]] && eval "$init";    
    
    local line=;
    local index=0;    
                   
    
    while IFS= read -r line || [[ -n $line ]]; do    
        eval "$command";
        
        (( index++ ));
        
    done <<< "$contents";        
}

# int correct_index(int index, int max, int? min)
function correct_index() {
    local index=${1:-0};
    local max=${2:-0};
    local min=${3:-0};
        
    (( index < 0 )) && index=$(( $max + $index + 1));
    (( index < 0 )) && index=$min;
    (( index > max )) && index=$max;
    
    echo $index;
}

# void num_file(String file, int from, int start, int count)
function num_file() {

    local file=$1;     

    local length=$(file_length $file);
    
    local width=${#length};
    
    local from=${2:-0};
    
    local start=$(correct_index ${3:-0} $length);
    
    local count=${4:-$((length - start))};
        
            
    local command="if (( \$index >= $start && \$index < $((start + count)) )); then \
                     local i=\$((index + $from)); \
                     printf '%*s' \$(($width - \${#i})); \
                     printf \"\$i: %s\n\" \"\$line\"; \
                  fi";
    
    do_file $file "$command" "$init";
}

# void list_file(String file, int start, int count)
function list_file() {
    local file=$1; shift;
    local start=$2;
    local end=$3;
                   
    local command='echo "$line"'
    
    do_sub_file $file "$start" "$end" "$command";
}

# void clear_file(String file)
function clear_file() {
    > $1;
}

# void remove_from_file(String file, int index, int? count)
function remove_from_file() {
        
    local file=$1; verify_file $file;
    
    local width=$(wc -l < $file);
    
    local index=$(correct_index $2 $width);
    local count=${3:-1};
    
    local init="> $file"
    
    local command="(( index < $index || index >= $((index + count)) )) && \
                    echo \"\$line\" >> \$file";
      
    do_file "$file" "$command" "$init";
}

# void append_to_file(String file, int count, String... lines)
function append_to_file() {

    echo $file
    local file=$1;
    local count=${2:-0}
    shift 2;

    local i=0;
    
    for (( ; i < count; i++ )); do
        printf "%s\n" "$1" >> $file;
        shift;
    done
}

# void prepend_to_file(String file, int count, String... lines)
function prepend_to_file() {

    local file=$1;
    local count=${2:-0}
    shift 2;
    
    local content="$(cat $file)";
    
    > $file
    
    local i=0;
    for (( ; i < count; i++ )); do
        printf "%s\n" "$1" >> $file;
        shift;
    done
    
    printf "$content" >> $file
}

# void insert_in_file(String file, int index, int count, String... text)
function insert_in_file() {

    local file=$1;    
    local total=$(file_length $file);
    local index=$(correct_index ${2:-0} $total);
    local count=${3:-0};
    shift 3;    
    
    if (( index == 0 )); then
        prepend_to_file "$file" "$count" "$@";
    elif (( index == total )); then
        append_to_file "$file" "$count" "$@";
    else
        local init="> $file; local lines=("
        
        for text in $@; do
            init+="\"$1\" ";
            shift;
        done
        
        init+=")"
        
        local command="if (( \$index == $index )); then \
                        local i=0; \
                        for (( ; i < $count; i++ )); do \
                            printf '%s\n' \"\${lines[\$i]}\" >> $file; \
                        done; \
                    fi; \
                    printf '%s\n' \$line >> $file";
                        
        do_file $file "$command" "$init";
    fi
}

# void modify_in_file(String file, int index, int position, String text)
function modify_in_file() {

    local file=$1;
    local total=$(file_length $file);
    local index=$(correct_index ${2:-0} $total);
    local position=${3:-0};
    local text=$4;
    
    local init="> $file";
    
    local command="if (( \$index == $index )); then \
                     local position=\$(correct_index $position \${#line}); \
                     printf '%s%s%s\n' \${line:0:\$position} \"$text\" \${line:\$position} >> $file; \
                   else \
                     printf '%s\n' \$line >> $file; \
                   fi;";
                   
    do_file "$file" "$command" "$init";
}

# void snip_in_file(String file, int index, int position, int length)
function snip_in_file() {
:
}

# void replace_in_file(String file, int index, int position, String text)
function replace_in_file() {
:
}