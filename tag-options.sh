#!/bin/bash
#
# Description: handles the tag options (used for conditions)

declare -A TAGS=();     # cached tags from file

declare TAG_FILE="$CACHE_PATH/tags.dat";

declare TAGS_LOADED;    # flag to see if flags already cached


#region TAG UTIL
# void load_tags() : TAG_FILE-> TAGS
function load_tags() {

    if [[ -z $TAGS_LOADED ]]; then

        [ ! -e $TAG_FILE ] && touch $TAG_FILE;
        
        local raw_tags=$(cat $TAG_FILE);
        local tag=;
        
        for tag in $raw_tags; do
            TAGS[$tag]=$tag;
        done
        
        TAGS_LOADED=true;
    fi
}

# void save_tags() : TAGS -> TAG_FILE
function save_tags() {
    load_tags;
    echo ${!TAGS[@]} > $TAG_FILE;
}


# void add_tags(String[] tags) : save_tags
function add_tags() {    
    
    load_tags;
    
    local tag=;
    
    for tag in $@; do
        TAGS[$tag]=$tag;
    done
    
    print_tags "tags: ";
    
    save_tags;
}

# void remove_tags(String[] args) : save_tags
function remove_tags() {

    load_tags;
    
    local tag=;
    
    for tag in $@; do
        unset TAGS[$tag];
    done
    
    print_tags "tags: ";
    
    save_tags;
}


# void print_tags(String preface);
function print_tags() {
    
    load_tags;
    
    if [[ -z ${TAGS[@]} ]]; then
        echo $1 "<no tags defined>"
    else
        echo $1 ${TAGS[@]};
    fi
}


# bool tag_defined(String tag);
function tag_defined() {

    load_tags;    
    
    contains_item "$1" "${TAGS[@]}";    
}
#endregion

#region TAG OPTIONS

# void on_option(String tag, String[] args)
function on_option() {
    local tag=$1;
    shift;
    
    if tag_defined $tag; then
        process "$@";
    fi
}

# void set_option(String[] tags)
function set_option() {    
    
    add_tags "$@";
    
    enable_log();
}

# void unset_option(String[] tags)
function unset_option() {
    
    remove_tags "$@";
    
    enable_log();
}

# String tags() : errors
function tags_option() {

    confirm_no_options "$@";
    
    print_tags "tags: ";    
}

#endregion