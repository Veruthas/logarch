#!/bin/bash
#
# Description: handles pacman and the aur


declare SYNC_CHANGED_PATH="$SYNC_PATH/sync_changed"

declare -r SYNC_SERVER_FILE="$SYNC_PATH/arm_path";

declare -r SPECIAL_REPOS="testing core extra \
                          community_testing community \
                          multilib-testing multilib";

declare -r PACMAN_CONF_BASE="$CACHE_PATH/base.conf"
declare -r PACMAN_REPO_FILE="$CACHE_PATH/repos.conf"
declare -r PACMAN_CONF_FILE="../_debug/pacman.conf"; #/etc/pacman.conf


# bool sync_changed
function sync_changed() {    
    [[ -e $SYNC_CHANGED_PATH ]] && return 0 || return 1;
}

# void set_sync_changed();
function set_sync_changed() {
    touch $SYNC_CHANGED_PATH;
}

# void clear_sync_changed();
function clear_sync_changed() {
    [[ -e $SYNC_CHANGED_PATH ]] && rm $SYNC_CHANGED_PATH;
}


function update() {    
:
}

# void sync_arch(bool? force=false) : errors
function sync_arch() {   
    
    local force=;
    [[ -z $1 ]] && force=false || force=true;
    
    # TODO: remove after debug
    set_sync_changed;
    
    if $force || sync_changed; then
        
        echo "Syncing repository info..."
        
        move_next_sync_path        
        
        cp -rv /etc/pacman.d/gnupg "$CURRENT_SYNC_PATH";
        cp -rv /var/lib/pacman/sync "$CURRENT_SYNC_PATH";
        chmod a+r  "$CURRENT_SYNC_PATH" -Rv
        
        enable_log;
        
        clear_sync_changed;
        
    else
        
        terminate 1 "sync information has not been changed, exiting"
        
    fi
}

# void add_repository((--top|--bottom|--index int Index) position, 
#                     String name, String? server, String? siglevel)
function add_repository() {
    
    local position=$1; shift;
    local index=;
    
    case $position in
        --top)
            index=0;
        ;;
        --bottom)
            index=-1;
        ;;
        --index)
            index=$1; shift;            
            (( index *= 4 ));                      
        ;;
        *)
            terminate 1 "missing repository destination";
        ;;
    esac

    local name=$1;
    local location=$2;
    local siglevel=$3;
        
    if contains_item $name "$SPECIAL_REPOS"; then
        name="[$name]";        
        location="Include = $SYNC_SERVER_FILE"
        siglevel="#SigLevel = Optional TrustAll";
    else
        name="[$name]"
        
        location="Server = $location"
        
        if [[ -n $siglevel ]]; then
            siglevel="SigLevel = $siglevel";
        else
            siglevel="#SigLevel = Optional TrustAll";
        fi
    fi        
        
    
    # insert the lines
    insert_lines "$PACMAN_REPO_FILE" $index 4 "$name" "$location" "$siglevel"
    
    cat "$PACMAN_CONF_BASE" "$PACMAN_REPO_FILE" > "$PACMAN_CONF_FILE";
    
    set_sync_changed;
    
    enable_log;        
}

# void add_key(String[] commands)
function add_key() {

    pacman-key "$@";
    
    enable_log;
    
    set_sync_changed;
}




#region SYNC OPTIONS

# void update_option(UpdateType type, (Date or int or Day) value) : *see UpdateType
function update_option() {
    
    # check for args
        
    # check if server update required
    
    # check if sync required
    :
}


#endregion

#region REPOSITORY OPTIONS

# void repo_option((--bottom|--top|--index, int index), String name, String url, String? siglevel)
function repo_option() {
    add_repository "$@";
}

# void key_option(String key_data)
function key_option() {
    add_key "$@"
}

#endregion

#region PACKAGE OPTIONS

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

