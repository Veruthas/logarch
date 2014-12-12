#!/bin/bash
#
# Description: Handles basic logarch path and configuration


declare -r CONF_PATH='../_debug';

declare -r VAR_PATH="$CONF_PATH/var";

declare -r CACHE_PATH="$CONF_PATH/cache";

declare -r PKG_PATH="$CACHE_PATH/pkgs";

declare -r NODE_PATH="$CACHE_PATH/nodes";

declare -r CURRENT_NODE_PATH="$CONF_PATH/node";



declare -r ARCH_SYNC_PATH="/var/lib/pacman/sync"
declare -r ARCH_KEY_PATH="/etc/pacman.d/gnupg";

# void create_cache_folder(String path)
function create_cache_folder() {
    mkdir -p "$1" -v;
    
    mkdir "$1/pkgs" -v;
    
    mkdir "$1/nodes" -v;
}