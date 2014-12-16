#!/bin/bash
#
# Description: date utility functions
# All functions assume utc dates

declare -r SECONDS_PER_MINUTE=60;
declare -r SECONDS_PER_HOUR=$((60 * SECONDS_PER_MINUTE));
declare -r SECONDS_PER_DAY=$((24 * SECONDS_PER_HOUR));
declare -r SECONDS_PER_WEEK=$((7 * SECONDS_PER_DAY));

declare -r NICE_DATE_STRING='%A, %B %d %Y, %r %Z';

# int get_now_timestamp()
function get_now_timestamp() {
    date -u +%s;
}

# int time_to_pattern(int seconds, String pattern)
function time_to_pattern() {
    local seconds=$1;    
    local pattern=$2;
    local new_date=$(date -u --date=@$seconds +"$pattern");
    date -u --date="$new_date" +%s;
}

# int to_date_timestamp(int month, [int day]=1, [int year]=now)
function get_date_timestamp() {
    local month=$1;
    local day=${2:-1};
    local year=${3:-$(date +%Y)};
    
    date --date="$month/$day/$year" +%s;
}


# int floor_minute(int seconds)
function floor_minute() {
    time_to_pattern $1 '%m/%d/%Y %H:%M:00';
}

# int floor_hour(int seconds)
function floor_hour() {
    time_to_pattern $1 '%m/%d/%Y %H:00:00';
}

# int floor_day(int seconds)
function floor_day() {
    time_to_pattern $1 '%m/%d/%Y';
}

# int floor_month(int seconds)
function floor_month() {
    time_to_pattern $1 '%m/01/%Y';
}

function floor_year() {
    time_to_pattern $1 '01/01/%Y';
}


# int days_in_month(1-12 month, int year)
function days_in_month() {
    local month=$1;
    local year=$2;
    
    case $month in
        1|3|5|7|8|10|12)
            echo 31;
        ;;
        4|6|9|11)
            echo 30;
        ;;
        2)
            is_leap_year $year && echo 29 || echo 28;
        ;;
        *)
            echo 0;
        ;;
    esac
}

# bool is_leap_year(int year) 
function is_leap_year() {
    local year=$1;
    
    # every 4 years, unless its divisible by 100 and not 400
    (( year % 4 == 0 )) && (( year % 100 != 0 )) || (( year % 400 == 0 )) \
        && return 0 \
        || return 1;
}

# void verify_date(int year, int month, int day) : error
function verify_date() {
    local year=$1;
    local month=$2;
    local day=$3;
    
    verify_integer "$year" "year";
    verify_integer "$month" "month"
    verify_integer "$day" "day";    
            
    case $month in
    
        1|3|5|7|8|10|12)
            (( day < 1 && day > 31 )) && terminate 1 "days of month #$month are (1-31)"
        ;;
        2)
            if (( day == 29 )); then
                if ! is_leap_year $year; then                
                   terminate "days of month in year $year #2 are (1-28)"
                fi 
                
            elif (( day < 1 && day > 30 )); then
                terminate "days of month #2 are (1-28/29)";
            fi
        ;;
        4|6|9|11)
            terminate 1 "days of month #$month are (1-30)";
        ;;
        *)
            terminate 1 "month must be (1-12)";
        ;;
    esac
}



# int get_utc_yearmonth(int seconds)
function get_utc_year() {
    local seconds=$1;
    date -u --date='@$seconds' +'%Y';
}

# int get_utc_month(int seconds)
function get_utc_month() {
    local seconds=$1;
    date -u --date='@$seconds' +'%m';
}

# int get_utc_day(int seconds)
function get_utc_day() {
    local seconds=$1;
    date -u --date='@$seconds' +'%d';
}


# int get_local_year(int seconds)
function get_local_year() {
    local seconds=$1;
    date --date='@$seconds' +'%Y';
}

# int get_local_month(int seconds)
function get_local_month() {
    local seconds=$1;
    date --date='@$seconds' +'%m';
}

# int get_local_day(int seconds)
function get_local_day() {
    local seconds=$1;
    date --date='@$seconds' +'%d';
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
    
    local months=${2:-1};
    
    local delta_months=$((month - 1 + months));
        
    # subtracting
    if (( delta_months < 0 )); then
        # years are the amount of 12s + 1 (-1 is really 11 in the count of months)
        (( delta_months++ ));
        
        local delta_years=$(( $((delta_months / 12)) - 1));
        
        year=$((year + $delta_years));
        
        month=$(( 12 + $((delta_months % 12)) ));    
        
    # adding
    else
        local delta_months=$((month - 1 + months));
        
        local delta_years=$((delta_months / 12 ));
        
        year=$((year + $delta_years));
        
        month=$((1 + $((delta_months % 12)) ));    
    fi
     
    date --date="$month/$day/$year $time UTC" +%s;    
}



# String get_nice_date(int seconds, String options)
function to_nice_date() {
    date --date=@"$1" +"$NICE_DATE_STRING" $2;
}

# String get_now()
function nice_now() {
    date +"$NICE_DATE_STRING";
}

# String nice_local(int seconds)
function nice_local() {
    to_nice_date $1;
}

# String nice_utc(int seconds)
function nice_utc() {
    to_nice_date $1 -u;
}

# int from_date_string(String date)
function from_date_string() {
    date --date="$1" +%s;
}