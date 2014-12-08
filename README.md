logarch
=======

An Arch Linux installation logging program written in bash


do    <command>

if    <command> ...                                 -- (unlogged) 
ask   <prompt>  ...                                 -- (unlogged) asks yes/no question

on    <tag>     ...                                 -- (unlogged) 

set   {tags}
unset {tags}

tags                                                -- (unlogged) prints out tags

help                                                -- (unlogged) print out list of commands


-- pacman commands
get    [--confirm] [--options <options>] {pkgs}     -- get the packages, require update if date has passed 
aur    <pkg>                                        -- requires getting other aur dependencies by itself; if frozen, will inform and ask
find   <pkg>                                        -- (unlogged) query database for package

# sync commands
update
        (absolute)                                  -- locks a relative into absolute
        (date) <year> <month> <day>
        (today)
        (yesterday)
        
        (hours)        
        (days)     <#days>
        
        (day)      (01-31) [hour [minute]]
        (month)
        
        (weekday)  (1-7) | (sunday|monday|tuesday|wednesday|thursday|friday|saturday)
        (week)
        
        (time)     hour [minute]
        (daily)

date    [--all]                                           -- (unlogged) echo database date

# repos
repo   (--bottom|--top|--index #) <name> <url> [siglevel] -- adds the server to the bottom or top, or # position in list; warn if frozen, display frozen date and time difference                                                        

key    <stuff>                                            -- pacman-key <stuff>
        



File layout:
/etc/logarch.conf
    -- Line 1: location of cache folder    

    sync_changed
    server_file         --link to recent server_file
        
<cache folder>
    packages/
        <all packages>
    
    sync/
        sync_changed
        
        <#>/            
            sync/       -- copy
            gnupg/      -- copy
            
            server_file -- calculated url to mirror
            
            date.dat    -- update info
                
            

<log folder>
        <#>.dat             -- logged commands, corresponds to sync number
            <command>
            "Start: <YYYY/MM/DD-HH:MM:SS>"
            "End:   <YYYY/MM/DD-HH:MM:SS>"

    
    
    
    tags.dat   -- quoted tags
    
    base.conf  -- pre-repo pacman.conf file
    
    repos.conf
        (testing | core | extra | community-testing | community | multilib-testing | multilib | <name> )       
        <Server> or <Include>   -- on special named, Server argument is ignored
        <siglevel> | #SigLevel = Optional TrustAll
        <blank>
    
    
    


