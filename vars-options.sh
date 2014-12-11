#!/bin/bash
#
# Description: used to [un]define variables for use in <command>s
#              variables are stored in 

declare -A VARS=();

declare VARS_FILE="$VAR_PATH/vars.dat";

declare VARS_LOADED=false;

# void load_vars() : VAR_FILE -> VARS
function load_vars() {

    if ! $VARS_LOADED; then

        VARS=();
        
        [[ ! -e "$VARS_FILE" ]] && touch "$VARS_FILE";
        
        local name=;
        
        while IFS= read -r line; do
            if [[ -z "$name" ]]; then
                name="$line";
            else
                VARS["$name"]="$line";
                unset name;
            fi        
        done < "$VARS_FILE";
    
        VARS_LOADED=true;
    fi
:
}

# void save vars() : VARS -> VAR_FILE
function save_vars() {
    > "$VARS_FILE";
    
    local var=;
    for var in "${!VARS[@]}"; do
        echo "$var" >> "$VARS_FILE";
        echo "${VARS[$var]}" >> "$VARS_FILE";
    done
}

# void define_var(String name, String value)
function define_var() {
    
    load_vars;
    
    VARS["$1"]="$2";
    
    save_vars;
}

# void undefine_var(String name);
function undefine_var() {
        
    load_vars;
    
    unset VARS[$1];
    
    save_vars;
}

# ? var_defined(String name);
function var_defined() {    
        
    load_vars;
    
    [[ -n "${VARS[$1]}" ]] && return 0 || return 1;
}

OPTIONS+=("set");
#void define_option(String name, [--val, String value | --from, String command])
function set_option() {
    local name="$1"; shift;
    
    local value=true;
    
    if [[ "$1" == '--val' ]]; then
        value="$2"; shift 2;        
    elif [[ "$1" == '--from' ]]; then
        value="$(eval '$2')"; shift 2;
    fi
    
    confirm_no_options "$@";
    
    define_var "$name" "$value";
    
    enable_logging;
}

OPTIONS+=("unset");
# void undefine_option(String name);
function undefine_option() {
    local name=$1; shift;
    
    confirm_no_options "$@";
    
    undefine_var "$1";
    
    enable_logging;
}

OPTIONS+=("on");
# void on_option(String name, ...)
function on_option() {
    
    local name="$1"; shift
    
    var_defined "$name" && process "$@";        
}

OPTIONS+=("vars");
# void vars_option()
function vars_option() {
    
    confirm_no_options "$@";
    
    load_vars;
    
    local var;
    for var in "${!VARS[@]}"; do
        echo "[$var] = '${VARS[$var]}'";
    done
}

