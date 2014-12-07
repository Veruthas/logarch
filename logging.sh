#!/bin/bash
#
# Description: Logging functions

declare LOG=false;

declare LOG_EXTRA_DATA="";

# void enable_log()
function enable_log() {    
    LOG=true;
}

# void disable_log()
function disable_log() {
    LOG=false;
}

# void log_data(String[] args)
function log_data() {    
    if $LOG; then
        echo "Logging" >&2;
    fi
}

