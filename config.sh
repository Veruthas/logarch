#!/bin/bash
#
# Description: Handles basic logarch configuration

declare CACHE_PATH="../_debug";

# void setup_caches
function setup_cache() {
    path=$CACHE_PATH;
    
    mkdir -v $path/packages;
    mkdir -v $path/updates;
    
    touch tags.dat
    
    touch repos.dat    
}