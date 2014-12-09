#!/bin/bash
#
# Description: basic option handling


declare OPTIONS="";

# void add_option(String option)
function add_option() {
    OPTIONS+="$1 ";
}

# void process(String[] args)
function process_line() {
    
    disable_log;
    
    process "$@";
    
    log_data "$@";      
}

# void process(String command, String[] args)
function process() {
    
    local option="$1"; shift;    
    
    if option_defined $option; then
                      
        ${option}_option "$@";
        
    else
    
        echo "invalid option -- '$option'."
        
        echo "type 'help' to see options."   
        
        return 1;        
        
    fi
}



# bool option_defined(String option)
function option_defined() {
    contains_item $1 "$OPTIONS";
}

# bool option_log_defined(String option)
function option_log_defined() {
    contains_item $1 "$LOG_OPTIONS"
}



declare UNEMPTY_OPTION_ERROR="invalid argument: ";
function confirm_no_options() {
    confirm_empty "$UNEMPTY_OPTION_ERROR" "$@";
}



#region BASIC OPTIONS

add_option "do"
# void do_option(String command) : errors
function do_option() {

    local command="$1";
    shift;
    
    confirm_no_options "$@";
    
    eval "$command";
    
    enable_log;
}

add_option "if"
# void if_option(String command, String[] options)
function if_option() {  

    local command="$1";
    shift;
    
    if eval "$command"; then 
        process "$@";
    fi
}

add_option "ask";
# void ask_option(String prompt, String[] options)
function ask_option() {
    local prompt=$1;
    shift;
    
    local result=$(ask "$prompt (y/n)? " "y n");
    
    if [[ $result == y ]]; then
        process "$@";
    fi
}

add_option "edit";
#void edit_option(String file, (
#                               --list  | 
#                               --clear | 
#                              (--remove, int line) |
#                              (--append, string text) |
#                              (--prepend, string text) |
#                              (--insert, int line, string text) |
#                              (--modify, int line, int position)))
function edit_option() {
:

}

#endregion