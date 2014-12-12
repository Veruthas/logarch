#!/bin/bash
#
# Description: date utility functions

declare -r SECONDS_PER_MINUTE=60;
declare -r SECONDS_PER_HOUR=$((60 * SECONDS_PER_MINUTE));
declare -r SECONDS_PER_DAY=$((24 * SECONDS_PER_HOUR));
declare -r SECONDS_PER_WEEK=$((7 * SECONDS_PER_DAY));

declare -r NICE_DATE_STRING='%A, %B %d %Y, %r %Z';

# int get_timestamp()
function get_timestamp() {
    date -u +%s;
}

# String get_now()
function get_now() {
    date +$NICE_DATE_STRING
}

# String get_nice_date(int seconds, String options)
function to_nice_date() {
    date --date=@$1 $2 +$NICE_DATE_STRING
}
# String to_local(int seconds)
function to_local() {
    to_nice_date $1;
}

# String to_utc(int seconds)
function to_utc() {
    to_nice_date $1 -u;
}

# int from_date_string(String date)
function from_date_string() {
    date --date="$1" +%s;
}

# int add_hours(int seconds, int hours=1)
function add_hours() {
    local seconds=$1;
    local hours=${2:-1}
    
    seconds=$((seconds + $((SECONDS_PER_HOUR * hours)) ));
    
    date -u --date=@$seconds +%s;
}

# int add_days(int seconds, int days=1)
function add_days() {
    local seconds=$1;
    local days=${2:-1};
    
    seconds=$(( seconds + $((SECONDS_PER_DAY * days))));
    
    date -u --date=@$seconds +%s;
}

# int add_month(int seconds, int months=1)
function add_months() {
    local seconds=$1;
    
    local month=$(date -u --date=@$1 +%m);
    local year=$(date -u --date=@$1 +%Y);
    local day=$(date -u --date=@$1 +%d);
    local time=$(date -u --date=@$1 +%T);
    
    local months=$(( month + ${2:-1} - 1 )); 
    
    year=$(( year + $(( months / 12 )) ));    
    month=$(( $(( months % 12 )) + 1));
     
    date --date="$month/$day/$year $time UTC" +%s;    
}


# int floor_hour(int seconds)
function floor_hour() {
    local seconds=$1;
        
    date --date=@$seconds "+%m/%d/%Y %H:00:00 UTC";
}

# int floor_day(int seconds)
function floor_day() {
    date --date=@$seconds "+%m/%d/%Y 00:00:00 UTC";
}

# int floor_month(int seconds)
function floor_month() {
    date --date=@$seconds "+%m/01/%Y 00:00:00 UTC";
}

