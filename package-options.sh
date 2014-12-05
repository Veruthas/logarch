#!/bin/bash
#
# Description: handles pacman and the aur



#region PACKAGES

# void get_option([--confirm], [--options, String options], String[] pkgs) : errors
function get_option() {            
    
    local confirm;
    [[ $1 == --confirm ]] && shift || confirm="--noconfirm";
          
    local options;
    [[ $1 == --options ]] && ( options="$2"; shift 2 );
    
    local cache_path=$(get_cache_path);
    
    local current=$(get_current_pkgs)        
    
    pacman -Q $confirm --cachedir cache_path "$@"
    
    local difference=$(compary_pkgs $current);
}

# void aur_option(String pkg) : errors
function aur_option() {
      :
}

# String find_option(String pkg)
function find_option() {
    
    local pkg=$1;
    
    pacman -Ss $pkg;
    
}

#endregion

#region SYNC

# String get_cache_path()
function get_cache_path() {
    :
}

# bool check_for_update()
function check_for_update() {
    :
}

#region UPDATE_OPTIONS

# void sync()
function sync_option() {
    confirm_no_options "$@";
}

# void update_option(UpdateType type, (Date or int or Day) value) : *see UpdateType
function update_option() {
:
}


# String date_option (["--all"])
function date_option() {
      :
}

#endregion

#region Doc: Update time points

## "TYPES"
#    Date
#       <Year> <Month> <Day> [Time]

#    WeekDay: enum
#       sunday|monday|tuesday|wednesday|thursday|friday|saturday
#       - also takes a number 1-7

#    Time
#       <Hour=00> [<Minute=00>]

#    UpdateType:
#       absolute  (Date)            => abs YYYY MM DD hh mm

#       days      (int)             => days ##

#       date*     (01-31) [Time]    => date DD hh mm
#       month*                      => date 01 00 00

#       weekday*  (WeekDay) [Time]  => week DAY    hh mm
#       week*                       => week Sunday 00 00

#       time*     (Time)            => time hh mm
#       daily*                      => time 12 00


# types marked with a '*' are relative, meaning when the time expires 
#(when the new time is reached), an update is required (or can be moved to absolute)

# absolute: NEVER requires an upgrade, though aur will suggest it

# days: after # days, update will be required

# date:
#   if the number is greater than the number of days in that month
#     (ex: 29 or 30 in leap for febuary, 31 for 30 day months), day 1 of the next month
#     will require an upgrade
#   otherwise
#     when # is reached, require upgrade (date 1, on every 1st day of the month, update)

# month: is the same is 'date 1'


# weekday: updates whenver that day is encountered

# week: is the same as 'weekday Sunday' or 'weekday 1'


# time: updates when time next day is reached

# daily: same as 12:00am

#endregion



#endregion


#region REPOSITORY

# void repo_option((--bottom|--top|--index, int index), String name, String url, String? siglevel)
function repo_option() {
      :
}

# void key_option(String key_data)
function key_option() {
    pacman-key "$@"
}

#endregion