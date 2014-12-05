#!/bin/bash
#
# Description: handles pacman and the aur



#region PACKAGES

# [--confirm] {pkgs}
function get_option() {
    
    local confirm="";
    
    if [[ $1 != --confirm ]]; then
        confirm="--noconfirm";
        shift;
    fi
          
    pacman -Q $confirm --cachedir $(get_cache_path) "$@"        
}

function aur_option() {
      :
}

# String find_option(String pkg)
function find_option() {
    
    local pkg=$1;
    
    pacman -Ss $pkg;
    
}

#endregion

#region UPDATES

# returns the current cache-path (based on update)
function get_cache_path() {
:
}

function check_for_update() {
:
}



# void update_option(UpdateType type, (Date or int or Day) value) : *see UpdateType
function update_option() {
:
}

# String date_option ("--all" displayAll)
function date_option() {
      :
}

#region Doc: 
UPDATE_INFO

## "TYPES"
#    Date
#       <Year> <Month> <Day> [Time]

#    WeekDay: enum
#       Sunday | Monday | Tuesday | Wednesday | Thursday | Friday | Saturday
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

function repo_option() {
      :
}

# <command...>
function key_option() {
    pacman-key "$@"
}

#endregion