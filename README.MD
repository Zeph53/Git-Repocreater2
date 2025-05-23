github forcing the use of 2fa now. i don't own a cellphone and i won't be buying one just to create free stuff.
i won't be relying on third party password managers, or less-than-functional authentication apps either.

it was an interesting run on gitHub for like 7 years. 
not a single comment, reaction, issue report, star, feedback of any kind..
still tried sending things out there..

if i can't access any of the stuff that i've made due to github's forcing of 2fa, then none of you can either.




## Git-Repocreater2.bash  
This is a Bourne Again Shell (.bash) script that automates various actions regarding repository generation on GitHub using GIT and GH (GitHub CLI). It's a work in progress but near full functionality is available.  

Creating repositories on GitHub of random files and directories has never been easier or faster!  

It uses the directory path or file path passed to it as an argument and then creates a GitHub repository of the same content.  

It has also been designed to be used with existing GitHub repositories, or even partially created ones.  

Please report any bugs.  
#### The script is *currently capable* of performing the following tasks:  
    Logging into GitHub CLI with a Personal Access Token.
    Automatically configuring various GH (GitHub CLI) and GIT options.
    Creating a name for the new repository, or selecting a previous name.
    Automatically creating a staging directory, in "$HOME/.github/NAMESPECIFIC_STAGINGDIRECTORY.git"
    Automatically copying the contents of the passed argument into staging directory.
    Automatically creating a cache directory of license files.
    Selecting and automatically downloading LICENSE.MD templates into cache directory.
    Automatically copying LICENSE.MD templates to staging directory.
    Creating new README.MD files.
    Automatically checking for existing LICENSE.MD and README.MD files from GitHub, downloading them instead.
    Automatically synchronizing the most recently edited README.MD between the local README.MD, the committed README.MD, and the remote README.MD on GitHub.
    Manually editing LICENSE.MD and README.MD files currently set for staging with seamlessly with NANO.
    Automatically initiating local repository and indexing all files from staging directory.
    Creating or selecting a Git commit author name and email address.
    Creating a custom Git commit message.
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
    Automatically synchronizing the most recently edited README.MD between the local README.MD, the committed README.MD, and the remote README.MD on GitHub.
    Added a default custom commit message for README.MD.
    Added a prompt for a custom commit message for an altered README.MD.
    Replaced "Yes/No:" IF structured confirmation prompts with a single function.
    An author name and email address can now be used when committing changes, previously used email addresses and author names can be selected using a numbered shortcut, or enter a new author name and email.
    Existing repository names are now printed at repository name creation, you can also use the number corresponding with the existing name to use that name instead of creating a new one.
    Removed some internet connection checks for "optimization".
    Corrected issue where creation of repository would fail if there was existing remote origin references in local repository.
    Removed trailing whitespaces from while and if statements.
    Removed silly newlines within command substituted variables. There are now some "long lines", and better ways to fix them.
    Cleaned up some printf messages.
    When asked to edit text files, Nano now uses correct syntax, and other options.
    Fixed typo in previous commit hash gathering.
    There is now a default description.
    Description generation rewrite.
    Fixed bug where the existing LICENSE.MD url on GitHub was being executed as a command.
    Fixed bug where existing non different file was getting overwritten anyway.
    Cleaned up the check_internet function.
    Additional README.MD improvements.
    Completely rewrite repository name generation, now complies with GitHub.
    README.MD improvements.
    Started on a README.MD.
    Added a check for an existing LICENSE.MD on Github when the local repository doesn't have one.
    Unset secretive token immediately after use.
## Queue  
    Improve script consistency, rewrite sections to be more universal with other sections.
    Automatically open the GitHub webpage for the secret authentication key when current key is expired.
    Correctly detect .MD vs .md file extension, will be changed to .MD.
    Correctly detect MAIN vs MASTER GitHub repository branches.
    README.MD sync echoing is kinda spammy.
    Will need to clean up numbered selector for existing repository names.
    Add many debug messages, such as error codes.
    Check to see if README.MD was updated via GitHub, download/merge that instead.
    Unset all variables after use, for "security".
    Add non interactive mode functioning on argument options.
    Check to see if secret token has correct GitHub scopes access.
    Remove some of the "Yes/No" confirmations.
    Rewrite logging in. 
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
