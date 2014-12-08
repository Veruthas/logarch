#!/bin/bash
#
# Description: basic option handling



# list of all options
declare OPTIONS="help \
                do if ask \
                on set unset tags \
                get aur find key \
                sync update date repo ";

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

# void process(String[] args)
function process_line() {
    
    disable_log;
    
    process "$@";
    
    log_data "$@";      
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
# void do_option(String command) : errors
function do_option() {

    local command="$1";
    shift;
    
    confirm_no_options "$@";
    
    eval "$command";
    
    enable_log;
}

# void if_option(String command, String[] options)
function if_option() {  

    local command="$1";
    shift;
    
    if eval "$command"; then 
        process "$@";
    fi
}

# void ask_option(String prompt, String[] options)
function ask_option() {
    local prompt=$1;
    shift;
    
    local result=$(ask "$prompt (y/n)? " "y n");
    
    if [[ $result == y ]]; then
        process "$@";
    fi
}

#endregion