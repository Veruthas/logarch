#!/bin/bash
#
# Description: Handles basic logarch configuration

# String get_cache_path()
function get_cache_path() {
    echo ../_debug/;
}

# void setup_caches
function setup_cache() {
    path=$(get_cache_path)
    
    mkdir -v $path/packages;
    mkdir -v $path/updates;
    
    touch tags.dat
    
    touch repos.dat    
}