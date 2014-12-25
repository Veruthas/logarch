**logarch**
=======

### An Arch-Linux-installation logger written in bash

Uses a tree-like log structure to log every pkg/aur install, sync, and update (and various other Arch Linux maintenance actions).

## Commands
### **logstrap**
   - format is: **logstrap** \<option\>

trace <var-path=/var/lib/logarch> <cache-path> <ID>
    traces a branch to a node:    
    
create <var-path=/var/lib/logarch> <cache-path> <sync-date=now> <auto=off> <logarch-script>


### **logarch**
   - format is: **logarch** \<option\> ...

    any logged command will automatically create a fork if the current node has children
    
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
* **node** [--name <name>] [--sync [now | YYYY MM DD]]

        creates a new node, without syncing/upgrading
        --name                  sets the node name, the default is the current date string
        --sync                  syncs and upgrades, optionally changing the repos to the date supplied                
                                if explicit date is earlier than date of current sync, will ask to verify
        [unlogged]
        
        
* **auto** (off | ((months | weeks | days) [--num n]=1 [ --from (now | last | MM [DD [YYYY]]) ] )
    
        off                         turns off automatic syncing
        month | weeks | days       
        
        *(For dates past the days in that month (29/30/31 in Feb, 31 in Apr/Jun/Sep/Nov) auto the last day of that month.)

        sets the interval to auto-sync

        when interval has been reached, will ask before a <package option> whether to:
            * turn auto-syncing off (convert to absolute date)
            * sync
                
        if interval has gone by since last sync date (auto set to monday, when last sync was sunday)
        will ask whether to:
            * wait until next interval
            * sync
        
        [unlogged]
           
* **conf** [--clear] <option> <value>

    Edits the [option] part of the pacman.conf file
    
    (see man 5 pacman.conf for details...)
    
        --clear <option>     clear any of the options (giving defaults when it exists)
            
        <options>                                    

            <Pkg Handling>
            --hold  <pkg>        'HoldPkg   = <pkg> ...'    (--clear --hold <pkg>)
        
            --ipkg  <pkg>        'IgnorePkg = <pkg> ...'    (--clear --ipkg <pkg>)
            --igrp  <grp>        'IgnoreGroup = <grp> ...'  (--clear --igrp <grp>)
            --noup  <file>       'NoUpgrade = <file> ...'
            --noex  <file>       'NoExtract = <file> ...'                                   
        
            --keep (ins|cur)     'CleanMethod = KeepInstalled &| KeepCurrent'  (default)        
                    
            --delta (0.0-2.0)    'UseDelta = (0.0-2.0)'     (default=0.7)
            
            --arch <arch>        'Architecture = <arch>'    (default=auto) (i686|x86_64|...)    
            --arch32             'Architecture = i686'
            --arch64             'Architecture = x86_64'
            
            --sig [--local|--remote] <sig_check> <sig_allowed>    
                                'SigLevel           = <sig_check> <sig_allowed>'
                                'LocalFileSigLevel  = <sig_check> <sig_allowed>'
                                'RemoteFileSigLevel = <sig_check> <sig_allowed>'
            
            --xfer <command>     'XferCommand = <command>'
            --wget               'XferCommand = /usr/bin/wget --passive-ftp -c -O %o %u'
            --curl               'XferCommand = /usr/bin/curl -C - -f %u > %o'

            <Misc>
            --verbose            'VerbosePkgLists'
            --space              'CheckSpace'
            --total              'TotalDownload'
            --color              'Color'
            --syslog             'UseSysLog'

        <Other (not implemented yet, since these are hardwired for the time being            
            <Paths>              <Corresponds To>:               
            --root  <path>       'RootDir   = <path>'       (default=/)
            --db    <path>       'DBPath    = <path>'       (default=/usr/local/var/lib/pacman/)
            --cache <path>       'CacheDir  = <path>'       (default=/usr/local/var/cache/pacman/pkg/)
            --gpg   <path>       'GPGDir    = <path>'       (default=/usr/local/etc/pacman.d/gnupg/)
            --log   <file>       'LogFile   = <file>'       (default=/usr/local/var/log/pacman.log)
                        
            --include <file>     'Include = <file>'         (--clear --include <file>)

    
* **repo** --list | --clear | --remove # | ((--append|--prepend|--insert #) *\<arg[s]\>*) 
    
        '--list'            prints a numbered list of current repositories  [unlogged]
        '--clear'           removes all repositories
        '--remove #'        removes repository at given index
        
        '--append <args>'   adds repository at end of list
        '--prepend <args>'  inserts repository to beginning of list
        '--insert # <args>' inserts repository at given index 
            
            <args>:

            * (core | community | extra | multilib | testing | community-testing | extra-testing | multilib-testing)
            * <name> <server> <sig_check> <sig_allowed>
        
                
                
                <name>            <The name of the repository>
                <server>          <The URL of the repository>
                <sig_check>     = [Package|Database](Optional|Never|Required)=Optional
                <sig_allowed>   = [Package|Database](TrustedOnly|TrustAll)=TrustedOnly
                
                * see 'file' information for how indices are handled
                
                special-name servers 'Include = arm_server.dat', and have 'SigLevel = PackageRequired'

* **key** \<command\>

        simply logs and executes 'pacman-key <command>'
        
#### *package options*

* **pkg** [--confirm] {pkgs}

        [only logged on success]
    
* **aur** \<aur-pkg\>

        downloads a package and installs it and its official dependencies
        (unofficial aur dependencies MUST be installed using aur FIRST)
        
        [only logged on success]
    
* **find** \<pkg\>

        looks for package [unlogged]

*(add more, this is just the basics)*
        
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
                                        
                sync/                       -- copy of /var/lib/pacman/sync/
                [gnupg/]                    -- copy of /etc/pacman.d/gnupg/                                        
                aur/                        -- all aur installations per node
                
                node_info.dat               -- information about the node
                                               <format>                                                 
                                                 id
                                                 name
                                                 date_created
                                                 
                last_node.dat               -- the parent node ide
                next_node.dat               -- all node ids after this node                
                
                
                arm_server.dat              -- calculated arch rollback machine server                                            
                                               Server=http://seblu.net/a/arm/YYYY/MM/DD/$repo/os/$arch
                 
                sync_date.dat               -- current <utc-timestamp>    
                
                [auto_sync.dat]             -- information about auto-sync intervals  
                                               <format>                                            
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
                
                