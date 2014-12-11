#!/bin/bash

# void verify_file(String file) : terminate
function verify_file() {
    [[ ! -e $1 ]] && terminate 1 "file not found: '$1'";
}

# int file_length(String file)
function file_length() {
    #[[ -e $1 ]] && wc -l < $1 || echo 0;    
    local count=0;
    if [[ -e $1 ]]; then
        while read -r || [[ -n "$REPLY" ]]; do
            (( count++ ));
        done < "$1";
    fi
    
    echo $count;
}

# int adjust_index(int index, int max, int? min)
function adjust_index() {
    local index=${1:-0};
    local max=${2:-0};
    local min=${3:-0}

    (( index < 0 )) && index=$(( $max + $index + 1));
    (( index < 0 )) && index=$min;
    (( index > max )) && index=$max;
    
    echo $index;
}

# void clear_file(String file)
function clear_file() {
    > $1;
}

declare DEBUG=true;

# void do_to_file(String file, String command, String pre, String post, int start?, int? count, int? length)
function do_to_file() {
    
    # subfile
    local -r file="$1"; [[ ! -e $file ]] && touch $file;    
    local -r length=${7:-$(file_length $file)};
    local -r start=$(adjust_index ${5:-0} $length); # eliminate?
    local -r count=${6:-$length};
    
    # commands
    local -r command="$2";        
    local -r pre="$3";
    local -r post="$4";   
    
    if [[ -n $DEBUG ]]; then
        echo file="$file";
        echo pre-command: $pre;
        echo command: "$command";
        echo post-command: "$post";
        echo start: "$start";
        echo count: "$count";
        echo length: "$length";
    fi
    
    local -r contents="$(cat $file)";
    
    eval "$pre";
    
    local line="";
    local index=0;
    
    while IFS= read -r line || [[ -n $line ]]; do
    
        if (( index >= start && index < start + count )); then
            eval "$command";
        fi
        
        (( index++ ))
    
    done <<< "$contents";
    
    eval "$post";
}

OPTIONS+=("file");
function file_option() {

    local file=$1; 
    local suboption="$2"; 
    shift 2;
    
    case $suboption in
        --do)
            file_do_option "$file" "$@";
        ;;   
        --list)
            file_list_option "$file" "$@";
        ;;
        --clear)
            file_clear_option "$file" "$@";
        ;;
        --replace)
            file_replace_option "$file" "$@";
        ;;
        --remove)
            file_remove_option "$file" "$@";
        ;;
        --append)
            file_append_option "$file" "$@";
        ;;
        --prepend)
            file_prepend_option "$file" "$@";
        ;;
        --insert)
            file_insert_option "$file" "$@";
        ;;
        --swap)
            file_swap_option "$file" "$@";
        ;;
        --snip)
            file_snip_option "$file" "$@";
        ;;
        --inject)
            file_inject_option "$file" "$@";
        ;;
        *)
            terminate 1 "invalid sub-option '$suboption'";
        ;;
    esac
}

# void file_option(String file, 
#                 String command, [--pre, String command], [--post, String command] 
#                 [--from, int start, int? count])
function file_do_option() {
    local file="$1";
    local command="$2"; shift 2;
    
    local pre;
    local post;
    local start;
    local count;
    
    [[ "$1" == '--pre'  ]] && { pre="$2"; shift 2; };
    [[ "$1" == '--post' ]] && { post="$2"; shift 2; };
    [[ "$1" == '--from' ]] && { start="$2"; count="$3"; shift 3; };
    
    confirm_empty "invalid option:" "$@";
    
    do_to_file "$file" "$command" "$pre" "$post" "$start" "$count";
}

# void list_option(String file,
#                 [--num, int first]
#                 [--from, int start, int? count])
function file_list_option() {

    local file=$1; shift;
    
    local pre=;
    local command=;    
    
    if [[ "$1" == "--num" ]]; then
        local from=$2; shift 2;
        
        pre="local width=\${#length}";
        
        command="local i=\$((index + $from)); \
                 local indent=\$(( width - \${#i} )); \
                 printf '%*s' \$indent; \
                 printf \"\$i: \$line\n\"" ;                 
        
    else
        command="echo \$line";
    fi
    
    local start=;
    local count=;
    
    if [[ "$1" == "--from" ]]; then
        start="$2";
        count="$3";
        shift 3;
    fi
    
    confirm_no_options "$@";
    
    do_to_file "$file" "$command" "$pre" "" "$start" "$count";
:
}

# void list_option(String file)
function file_clear_option() {
    
    local file=$1; shift;
    
    confirm_no_options "$@";
    
    clear_file $file;
}

# void file_replace_option(String file, int index, int rem, int ins, String... text)
function file_replace_option() {
    local file=$file; shift; 
    local length=$(file_length $file);
    
    verify_integer $1 "line index"; 
    local index=$(adjust_index $1 $length); shift;
    
    verify_integer $1 "number of lines to remove";    
    local rem=$1; shift;
    
    verify_integer $1 "number of lines to insert";
    local ins=$1; shift;
    
    if (( $index == $length )); then
        file_append_option "$file" "$ins" "$@";
    else
    
        local items="";
        local item=;        
        for item in "$@"; do
            items+="\"$item\" ";
        done;        
        
        local pre="local -r list=($items); > $file; local rem=0";
        
        local command="if (( \$index == $index )); then \
                        local i=0; \
                        for (( ; i < $ins; i++ )); do \
                            echo \"\${list[\$i]}\" >> $file; \
                        done; \
                        rem=$rem; \
                    fi; \
                    (( rem > 0 )) && (( rem-- )) || echo \"\$line\" >> $file ";
        
        do_to_file "$file" "$command" "$pre" "" "" "" "$length";
    fi
}

# void file_remove_option(String file, int index, int? n)
function file_remove_option() {
    local file=$1; shift;
    local length=$(file_length $file);
    
    verify_integer $1 "line index"; 
    local index=$(adjust_index $1 $length); shift;
    
    if [[ -n $1 ]]; then
        verify_integer $1 "number of lines to remove";
        local n=$1; shift;
    fi
    
    confirm_no_options "$@";
    
    local pre="> $file";
    
    local command="(( \$index < $index || \$index >= $(($index + n)) )) && \
                    echo "\$line" >> $file;";
    
    do_to_file "$file" "$command" "$pre" "" "" "" "$length";
}

# void file_append_option(String file, int n, String... text)
function file_append_option() {
    local file=$1; shift;
    
    verify_integer $1 "number of lines to prepend";    
    local n=$1; shift;
    
    for (( ; n > 0; n-- )); do
        printf '%s\n' "$1" >> $file;
        shift;
    done
    
}

# void file_prepend_option(String file, int n, String... text)
function file_prepend_option() {
    local file=$1; shift;
        
    verify_integer $1 "number of lines to prepend";
    local n=$1; shift;
    
    local content=$(cat $file);
    
    clear_file $file;
    
    for (( ; n > 0; n-- )); do
        printf '%s\n' "$1" >> $file; 
        shift;
    done;
    
    printf "$content" >> $file;
}

# void file_insert_option(String file, int index, int n, String... text)
function file_insert_option() {
    local file=$1; shift;
    local length=$(file_length $file);
    
    verify_integer $1 "line index"; 
    local index=$(adjust_index $1 $length); shift;
        
    verify_integer $1 "number of lines to insert"; 
    local n=$1; shift;            
    
    if (( index == 0 )); then
        file_prepend_option "$file" "$n" "$@";
    elif (( index == length )); then
        file_append_option "$file" "$n" "$@";
    else
        local items="";
        local item=;        
        for item in "$@"; do
            items+="\"$item\" ";
        done;
        
        
        local pre="local -r list=($items); > $file";
        
        local command="if (( \$index == $index )); then \
                          local i=0; \
                          for (( ; i < $n; i++ )); do \
                             echo \"\${list[\$i]}\" >> $file; \
                          done; \
                       fi; \
                       echo \"\$line\" >> $file";
        
        do_to_file "$file" "$command" "$pre" "" "" "" "$length";
    fi
}


# void file_swap_option(String file, int index, int pos, int rem, String text)
function file_swap_option() {
    local file=$1; shift;
    
    verify_integer $1 "line index";     
    local lindex=$1; shift;
    
    verify_integer $1 "line position"; 
    local pos=$1; shift;
    
    verify_integer $1 "amount to remove"; 
    local rem=$1; shift;
        
    local text=$1; shift;
    
    confirm_no_options "$@";
    
    local pre="local lindex=\$(adjust_index $lindex \$length); > $file";
    
    local command="if (( index == lindex )); then \
                     local pos=\$(adjust_index $pos \${#line}); \
                     echo \"\${line:0:\$pos}$text\${line:\$((pos + $rem))}\" >> $file;\
                   else \
                     echo \"\$line\" >> $file; \
                   fi";
                   
                   
    do_to_file "$file" "$command" "$pre";
}

# void file_snip_option(String file, int index, int pos, int rem)
function file_snip_option() {
    file_swap_option $1 $2 $3 $4;
}

# void file_inject_option(String file, int index, int pos, String text)
function file_inject_option() {
    file_swap_option $1 $2 $3 0 "$4";
}