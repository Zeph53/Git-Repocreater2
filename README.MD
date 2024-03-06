# Git-Repocreater2  
This is a Bourne Again Shell (.bash) script that automates various actions regarding repository generation on GitHub using GIT and GH (GitHub CLI). It's a work in progress but near full functionality is available.  

Creating repositories on GitHub of random files and directories has never been easier or faster!  

It uses the directory path or file path passed to it as an argument and then creates a GitHub repository of the same content.  

It has also been designed to be used with existing GitHub repositories, or even partially created ones.  

Please report any bugs.  
#### The script is *currently capable* of performing the following tasks:  
    Logging into GitHub CLI with a Personal Access Token.
    Automatically configuring various GH (GitHub CLI) and GIT options.
    Creating a name for the new repository.
    Automatically creating a staging directory, in "$HOME/.github/NAMESPECIFIC_STAGINGDIRECTORY.git"
    Automatically copying the contents of the passed argument into staging directory.
    Automatically creating a cache directory of license files.
    Selecting and automatically downloading LICENSE.MD templates into cache directory.
    Automatically copying LICENSE.MD templates to staging directory.
    Creating new README.MD files.
    Checking for existing LICENSE.MD and README.MD files from GitHub, downloading them instead.
    Manually editing LICENSE.MD and README.MD files currently set for staging with NANO.
    Automatically initiating local repository and indexing all files from staging directory.
    Prompting for a custom Git Commit message.
    Automatically creating and checking for the remote repository on GitHub.
    Creating and editing the GitHub repository description, which would be in the "About" box on GitHub.
    Automatically pushing all indexed files from staging directory to newly created repository on GitHub.
    Confirming via GitHub commit hashes, if the file or directory was indeed pushed to the GitHub repository.
    It even checks for a working internet connection via ping to GitHub before attempting anything.

## Requirements  
    GNU/UNIX Debian (Testing)
    GIT
    GH

## Installation  
Clone this repository, and then refer to the "Usage" section.  
#### Clone this repository:  
    git clone https://github.com/Zeph53/Git-Repocreater2/
    cd Git-Repocreater2/
If you really wanted to, it can be added to "/usr/bin". Which makes it globally executable within Bash.  
#### Install to /usr/bin:  
    git clone https://github.com/Zeph53/Git-Repocreater2/
    cp -r Git-Repocreater2/git-repocreater2.bash /usr/bin/
    gio trash --force Git-Repocreater2/

## Usage  
Simply execute the script with the file or directory that you would like to turn into a repository as an argument.  
#### Run the script with the argument  
    git-repocreater2.bash '/directory/or/file/that/should/be/repository'
#### Or execute the script with "--help":  
    git-repocreater2.bash --help  

## Updates  
    Additional README.MD improvements.
    Completely rewrite repository name generation. Name generation now complies with GitHub.
    README.MD improvements.
    Started on a README.MD.
    Added a check for an existing LICENSE.MD on Github when the local repository doesn't have one.
    Unset secretive token immediately after use.
## Queue  
    Unset all variables after use, for "security".
    Add non interactive mode functioning on argument options.
    Check to see if secret token has correct GitHub scopes access.
    Remove some of the "Yes/No" confirmations.
    Rewrite logging in. 
    **** Rewrite repository name generation.
    Add custom description for custom commit messages.
    Improve default empty README.MD
    Add option for custom LICENSE.MD.
    If any problems staying signed in with Git, generate a .netrc file as well.
    Add an option to log out of GH and Git at the end.

## Disclaimer  
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
