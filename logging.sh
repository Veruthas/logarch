#!/bin/bash
#
# Description: Logging functions

declare LOG=false;

declare LOG_EXTRA_DATA="";


# void reset_log_status()
function reset_log_status() {
    LOG=false;
    LOG_EXTRA_DATA="";
}

# void add_log_extra(String data)
function add_log_extra() {
    LOG_EXTRA_DATA+="$@";
}

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
}

