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


* **edit** \<file\> (--list | --clear | --remove # | (--append|--prepend|--insert #) \<line\> | --modify # # \<data\>)

        <file>                  the name of the file to edit
        
        '--list'                prints a line-numbered view of the file [unlogged]
        '--clear'               clears all lines of file
        '--remove' #            removes line no. # from file        
        '--append <line>'       appends <line>
        '--prepend <line>'      inserts <line> to top of file
        '--insert # <line>'     inserts line at given index (# < 0 || # > lines is an append)
        '--modify # # <data>'   modifies the line $1 at position $2 with data 
                                    ($1 < 0 || $1 > lines is an append and $2 is ignored)
                                    ($2 < 0 || $2 > length is added to end of line)

#### *tag options*
* **on**    \<tag\> &nbsp;&nbsp;...
        
        IF tag defined > ...
    
* **[un]set**   {tag}

        SETS or UNSETS the supplied tags
       
* **tags**
 
        list the defined tags [unlogged]
        
#### *node options*
* **node** [--to # | --list | --this | --index #]

        (nothing)               creates a new node, without syncing/upgrading
                                (results in a fork if the same cache is used on different systems)
        
        --to #                  confirms that # is in the same branch, traces until then
        --list                  prints out headers of all nodes in current branch 
        --index #               prints out information about node at index (--list on invalid index)
        --this                  prints out information about current sync        
        
            node info: <TODO>

        [unlogged]
        
* **sync** [*--date* YYYY MM DD]

        --date (or nothing)     syncs either to today or to specified date, and upgrades
        
            if date is before current sync date, verify before doing (y/n)
        
        [unlogged]
        
* **auto** \<args\>
    
        <args>:
            hours       ##
    
            days        ##
    
            day         (1-31) [hh [mm]]
            month       (same as 'day 01 00 00')
    
            weekday     ((1-7) | sunday | monday | tuesday | wednesday | thursday | friday | saturday) [hh [mm]]
            week        (same as 'weekday sunday 00 00)*
            
            time        hh [mm]
            daily       (same as 'time 00 00')    
            
            off         (turns off automatic syncing)
        

        sets the interval to auto-sync

        when interval has been reached, will ask before a <package option> whether to:
            * turn auto-syncing off
            * sync
                
        if interval has gone by since last sync date (auto set to monday, when last sync was sunday)
        will ask whether to:
            * wait until next interval
            * sync

* **conf** *(same args as __edit__ with the [besides <file>])* | '--[un]comment #'

        '--[un]comment #'       comments/uncomments a line with a '#'
            

* **repo** --list | --clear | --remove # | ((--append|--prepend|--insert #) *\<arg[s]\>*) 
    
    *\<args\>*:

    * (core | community | extra | multilib | testing | community-testing | extra-testing | multilib-testing)
    * <name\> <server\> [siglevel]
    
            '--list'            prints a numbered list of current repositories  [unlogged]
            '--clear'           removes all repositories
            '--remove #'        removes repository at given index
            '--append <args>'   adds repository at end of list
            '--prepend <args>'  inserts repository to beginning of list
            '--insert # <args>' inserts repository at given index (# < 0 || # > lines is an append)
            
            
            special-name servers 'Include = arm_server.dat', and have 'SigLevel = PackageRequired'

* **key** \<command\>

        simply logs and executes 'pacman-key <command>'

#### *package options*

* **pkg** [--confirm] [--options <options\>]{pkgs}

        [only logged on success]
    
* **aur** \<aur-pkg\>

        downloads a package and installs it and its official dependencies
        (unofficial aur dependencies MUST be installed using aur FIRST)
        
        [only logged on success]
    
* **find** \<pkg\>

        looks for package [unlogged]

## *File Layout*    
    /etc/logarch.d/
        logarch.conf            -- defines cache path ('declare CACHE_PATH=<CACHE PATH>')
                
        node/ -> <cache>/<#>/   -- link to <Cache Path>/nodes/<##########>

        var/  -> <var>/<#>/            
        
        
    <Cache Path>/
        packages/                   -- contains all the downloaded packages
    
        nodes/                      -- contains the sync nodes
            <###########>/              -- 10 digit id of node (created sequentially)
                        
                last/ -> <#>/               -- link to last node
            
                sync/                       -- copy of /var/lib/pacman/sync/
                [gnupg/]                    -- copy of /etc/pacman.d/gnupg/
            
                aur/                        -- all aur installations per node
            
                arm_server.dat              -- calculated arch rollback machine server                                            
                                               Server=http://seblu.net/a/arm/YYYY/MM/DD/$repo/os/$arch
                                            
                info.dat                    -- sync info, also used for auto-syncing
                                               <format>
                                                 YYYY MM DD                                                 
                                                 YYYY MM DD hh mm ss (if auto, is next time to check for)
                                                 (hours | days | day | weekday | time) (to calculate next)
                                                 <args>            
                                                                 
                trace.dat                   -- log of all the commands
                                               
                tags.dat                    -- list of all tags (copied to each node)
                
                                                  
    <Variable Path>                 -- per installation files
        nodes/
            <##########>/
            
                pacman-base.dat             -- file with the extra non-repo pacman.conf info
                
                pacman-repo.dat             -- file listing pacman.conf's repositories
                
                log.dat                     -- extra info of on all commands
                                               <format>