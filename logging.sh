#!/bin/bash
#
# Description: Logging functions

declare LOG=false;

declare SUPRESS_LOG=false;

declare LOG_EXTRA_DATA="";

# void enable_log()
function enable_logging() {    
    LOG=true;
}

# void disable_log()
function disable_logging() {
    LOG=false;
}

function reset_logging() {
    LOG=false;
    SUPRESS_LOG=false;
}

function suppress_logging() {
    SUPRESS_LOG=true;
}

# void log_data(String[] args)
function log_data() {    
    if $SUPRESS_LOG; then
        echo "Logging suppressed" >&2;
    elif $LOG; then
        echo "Logging" >&2;
    else
        echo "Not Logging" >&2;
    fi
}

