**logarch**
=======

### An Arch-Linux-installation logger written in bash

Uses a tree-like log structure to log every pkg/aur install, sync, and update (and various other Arch Linux maintenance actions).

## Commands
### **logstrap**
   - used to set up the logarch configuration and pacstrap the system
   - TODO: Add options

### **logarch**
   - format is: **logarch** \<option\> ...
   
#### *basic options*
* **do**    \<command\>
    
        DO the supplied command
            translate to 'eval <command>'
        
* **if**    \<command\> &nbsp;&nbsp;  ...

        IF command yields (bash) true > ...
            translates to 'if eval <command>; then logarch ...'
        
* **ask**   \<prompt\>&nbsp;&nbsp; ...
        
        ASKS a (y/n) question, if answer is yes > ...
            translates to 'if $(ask $prompt) == 'y'; then logarch...'

* **ignore** ...

        Processes what follows with logging it (if logged)
        
#### *file options*

* **file** \<name\> _<option>_ _{args}_

        <name>                                      the name of the file
        
        
        '--do  <command> [--pre <command>] [--post <command>] [--from start [count]]'
                                                    --pre is eval'd before the file is looped through
                                                    --post is eval'd after                                                    
                                                    VARS: $!file, $!length, $!start, $!count, $line, $index
        
        '--list  [--num #][--from start [count]]'   [unlogged] prints file from start, --num adds line-numbers starting from #
        
        '--clear'                                   clears all lines of file        
        
        Whole-Line Edit:
        '--replace <index> <m> <n> {text}'          removes m lines and inserts n lines
        '--remove  <index> [n=1]'                   removes n lines from line# index                
        '--append  <n> {text}'                      appends n lines, using text
        '--prepend <n> {text}'                      inserts n lines to top of file
        '--insert  <index> <n> {text}'              inserts n lines at line index                        
        
        Partial-Line Edit:
        '--swap <index> <pos> rem <text>'           snips out and injects text
        '--snip     <index> <pos> rem'              snips out text within a line
        '--inject   <index> <pos> <text>'           injects line with text at (index, position)        
        
        for any index or position i,             
            when i >=0
                if i  <  0,          the action is a prepend
                if i  <  length,     the action is an insert
                if i  >= length,     the action is an append
                
            when i < 0 
                if (length - i)  == length - 1,  the action is an append
                if (length - i)  <  length - 1,  the action is an insert
                if (length - i)  <  0,           the action is a prepend

#### *variable options*
* **set** \<name\> [--val \<value\> | --from \<command\>]

    Defines a variable in the VARS associative array (for use in on or <command>)
    
        <nothing>   sets <name> to 'true'
        --val       uses the literal string supplied
        --from      evals it and sets it the result (watch for '');        
        
        
* **unset** \<name\>
    Removes variable from VARS
        
* **on**    \<name\> &nbsp;&nbsp;...
        
    IF <var> defined  ...

* **vars**

    lists defined variables
        
#### *node options*
* **node** [--name <name> | --list | --info [#] | --to ID]

        (nothing)               creates a new node, without syncing/upgrading                                
        --name                  sets the node name, the default is a date string
        --list                  prints out numbered list of headers of all nodes in current branch 
        --info [index]          prints out node info at either current or # node
        --to ID                 verifies that current node leads to node ID, and then traces to it.
        
        if (nothing), ask for a name, defaults to date string
        
        [unlogged]
        
* **sync** [--name <name>] [--date YYYY MM DD]

        --date (or nothing)     syncs either to today or to specified date, and upgrades
        
        verify if supplied date is older than current sync
        
        asks for a name (defaults to date string)
        
        [unlogged]
        
* **auto** \<args\> 
    
        <args>:                                    
            off       (turns off automatic syncing)
                                                                     
            months    [--num n=1] [--day (1-31)=1] <query last?>
                *(For dates past the days in that month (29/30/31 in Feb, 31 in Apr/Jun/Sep/Nov) auto the last day of that month.)
            
            weeks     [--num n=1] [--day (1-7 | sunday | monday | tuesday | wednesday | thursday | friday | saturday)=1] <query last?>
                every weekday x, at the supplied 
            
            days      [--num n=1] <query from when (now|last sync|other date)?>
            

        sets the interval to auto-sync

        when interval has been reached, will ask before a <package option> whether to:
            * turn auto-syncing off (convert to absolute date)
            * sync
                
        if interval has gone by since last sync date (auto set to monday, when last sync was sunday)
        will ask whether to:
            * wait until next interval
            * sync
        
        [unlogged]
           
* **conf** *(uses the file option, auto-supplies the config filename)*

            
* **repo** --list | --clear | --remove # | ((--append|--prepend|--insert #) *\<arg[s]\>*) 
    
    *\<args\>*:

    * (core | community | extra | multilib | testing | community-testing | extra-testing | multilib-testing)
    * \<name\> \<server\> [siglevel=PackageRequired]
    
            '--list'            prints a numbered list of current repositories  [unlogged]
            '--clear'           removes all repositories
            '--remove #'        removes repository at given index
            '--append <args>'   adds repository at end of list
            '--prepend <args>'  inserts repository to beginning of list
            '--insert # <args>' inserts repository at given index 
            
            * see 'file' information for how indices are handled
            
            special-name servers 'Include = arm_server.dat', and have 'SigLevel = PackageRequired'

* **key** \<command\>

        simply logs and executes 'pacman-key <command>'

        
* **flatten** [--to #]
    extracts and combines all files to either current node, or # from root
    
* **extract** [--to #]
    extracts log to either current node, or # from root
        
#### *package options*

* **pkg** [--confirm] [--options <options\>]{pkgs}

        [only logged on success]
    
* **aur** \<aur-pkg\>

        downloads a package and installs it and its official dependencies
        (unofficial aur dependencies MUST be installed using aur FIRST)
        
        [only logged on success]
    
* **find** \<pkg\>

        looks for package [unlogged]

## *Variables*        
        no variables should be assumed public, save those mentioned explicitely (ex: in the file 'do' option, or the VARS associative array)
        
## *File Layout*    
    /etc/logarch.d/
        
        var/   -> <var>          -- link to system specific data
        
        cache/ -> <cache>        -- link to the cache directory
        
        node/  -> <cache>/<#>/   -- link to <Cache Path>/nodes/<##########>
        
        
    <Variable Path>                 -- per installation files
                
            vars.dat                    -- list of all variables
                                            <format>
                                                <name>
                                                <value>
                
            pacman-base.dat             -- file with the extra non-repo pacman.conf info
            
            pacman-repo.dat             -- file listing pacman.conf's repositories                                
                                                           
        
    <Cache Path>/
        pkgs/                       -- contains all the downloaded packages
    
        nodes/                      -- contains the sync nodes
            <###########>/              -- 10 digit id of node (created sequentially)
                        
                last/ -> <#>/               -- link to last node
                
                node_info.dat               -- information about the node
                                               <format>
                                                 name
                                                 id
                                                 date_created
                
                               
                sync/                       -- copy of /var/lib/pacman/sync/
                [gnupg/]                    -- copy of /etc/pacman.d/gnupg/            
                
            
                aur/                        -- all aur installations per node
                
                                                 
                arm_server.dat              -- calculated arch rollback machine server                                            
                                               Server=http://seblu.net/a/arm/YYYY/MM/DD/$repo/os/$arch
                 
                sync_date.dat               current <utc-timestamp>    
                
                [auto_sync.dat]                  <format>                                            
                                                 next <utc-timestamp>
                                                 (months|weeks|days)
                                                 num
                                                 [day]
                                                 
                                                    
                trace.dat                   -- log of all the commands 
                                               <format>
                                                command
                                                start (utc-timestap)
                                                end   (utc-timestamp)
                                                
                pkgs.dat                    -- log of all packages installed
                