#!/bin/bash
#
# Description: basic option handling



# list of all options
declare OPTIONS="help \
                do if ask \
                on set unset tags \
                get aur find key \
                sync update date repo ";

# list of options that get logged
declare LOG_OPTIONS="do if ask \
                     on set unset \
                     get aur key \
                     sync update repo "; 

declare LOG=false;


# void process(String command, String[] args)
function process() {
    
    local option="$1"; shift;    
    
    if option_defined $option; then
    
        if option_log_defined $option; then LOG=true; fi                
        
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


# void do_option(String command) : errors
function do_option() {

    local command="$1";
    shift;
    
    confirm_no_options "$@";
    
    eval "$command";
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
    
    ask "$prompt (y/n)? " "y";
    #read -p "$prompt (y/n)? " result;
    
    if [[ $? == 1 ]]; then
        process "$@";
    fi
}