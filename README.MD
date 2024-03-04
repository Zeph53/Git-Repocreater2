# Git-Repocreater2  

## Requirements  
    GNU/UNIX Debian (Testing)
    Git
    GH

## Installation  
Clone this repository, and then refer to the "Usage" section.  
#### Open a terminal:  
    git clone https://github.com/Zeph53/Git-Repocreater2/
    cd Git-Repocreater2/

If you really wanted to, it can be added to "/usr/bin". Which makes it globally executable within Bash.  
#### Open a terminal:  
    git clone https://github.com/Zeph53/Git-Repocreater2/
    cp -r Git-Repocreater2/git-repocreater2.bash /usr/bin/
    gio trash --force Git-Repocreater2/

## Usage  
Simply execute the script with the file or directory that you would like to turn into a repository as an argument.  
#### Open a terminal:  
    git-repocreater2.bash '/directory/or/file/that/should/be/repository'
Or execute the script with "--help"  
#### Open a terminal:  
    git-repocreater2.bash --help  

## Updates  
    Started on a README.MD.
    Added a check for an existing LICENSE.MD on Github when the local repository doesn't have one.
    Unset secretive token immediately after use.
## Queue  
    Completely rewrite logging in and repository name generation.
    Add custom description for custom commit messages.
    Improve default empty README.MD
    Add option for custom license.
    If any problems staying signed in with Git, generate a .netrc file as well.
    Add an option to log out of GH and Git at the end.




This program comes with ABSOLUTELY NO WARRANTY!  
This is free software, and you are welcome to redistribute it under certain conditions.  
