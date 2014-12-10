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


* **file** \<name\> _<option>_ _{args}_

        <name>                                      the name of the file
        
        
        '--do      <command> [--init <init>]'[--from start [count]]               
                                                    <init> is run once; 
                                                    for every line, evals 'command' 
                                                    vars: $file, $contents, $line, $index, $command, $init
                                                    last command of command and init should not end in a semi-colon                        
        
        '--list  [--from start [count]]'            prints file from start [unlogged]
        '--num   [--base #] [--from start [count]]' prints line-numbered file (counting from 'from') from start to end
                                                    base is the starting number of the lines
        
        '--clear'                                   clears all lines of file        
        
        '--remove  <index> [n=1]'                   removes n lines from line# index        
                
        '--insert  <index> <n> {text}'              inserts n lines at line index        
        '--append  <n> {text}'                      appends n lines, using text
        '--prepend <n> {text}'                      inserts n lines to top of file
                
        '--inject  <index> <position> <text>        injects line with text at (index, position)        
        '--snip    <index> <position> <length>      snips out text within a line
        
        '--replace <i0> <p0> <i1> <p1> <n> {text}   removes text from (i0, p0) to (i1, p1) and inserts n lines
        
        
        for any index or position i,             
            when i >=0
                if i  <  0,          the action is a prepend
                if i  <  length,     the action is an insert
                if i  >= length,     the action is an append
                
            when i < 0 
                if (length - i)  == length - 1,  the action is an append
                if (length - i)  <  length - 1,  the action is an insert
                if (length - i)  <  0,           the action is a prepend
        
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
    
            day         (1-31) [hh=00 [mm=00]]
            month       (same as 'day 01 00 00')
    
            weekday     ((1-7) | sunday | monday | tuesday | wednesday | thursday | friday | saturday) [hh [mm]]
            week        (same as 'weekday sunday 00 00)*
            
            time        hh [mm=00]
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
        no variables should be assumed public, save those mentioned explicitely (ex: in the file 'do' option)
        
## *File Layout*    
    /etc/logarch.d/
        logarch.conf            -- defines cache path ('declare CACHE_PATH=<CACHE PATH>')
                
        node/ -> <cache>/<#>/   -- link to <Cache Path>/nodes/<##########>

        var/  -> <var>/<#>/     -- link to system specific data
        
        
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
                                                