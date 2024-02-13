#!/bin/bash
#
## This is a script that automates GitHub operations, such as:
## logging in, staying logged in, creating working folders,
## creating repositories, choosing and creating licensing,
#
#
#
#
#    Git-Repocreater2.bash to instantly create repositories on GitHub.
#    Copyright (C) 2024 GitHub.com/Zeph53
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#
#
#
## Launching parameters
# Using --help option will show a help menu with directions then exit
if [[ "$1" == "--help" ||\
      "$1" == "-h" ]]
then
  printf "Usage:
Add a file or folder to the command as an argument.
After following the on screen directions, out comes a repository on GitHub!

To upload a file to Github:
git-repocreater2.bash \"/home/user/scripts/a-script-i-wanna-backup.sh\"

To upload a directory to Github:
git-repocreater2.bash \"/home/user/scripts/a-directory-i-wanna-backup\"

Options:
--help                Display this help menu then exit.




Git-Repocreater2.bash
Copyright (C) 2024 GitHub.com/Zeph53
This program comes with ABSOLUTELY NO WARRANTY!
This is free software, and you are welcome to
redistribute it under certain conditions.
See \"https://www.gnu.org/licenses/gpl-3.0.txt\"
"
  exit 1
# Using --shit will bring up a shit usage menu then exit
elif [[ "$1" == "--shit" ]]
then
  printf 'Usage:
shit
'
  exit 1
file
# Warn the user that the script must include a file or directory as an argument
else
  if [[ ! -e "$1" ]]
  then
    printf "Add a file or folder to the command as an argument.\n"
    exit 1
  fi
fi
#
## Logging into GitHub using GH
# Check if user is logged in
if ! gh auth status &> /dev/null
then
  printf "You are not authenticated with GitHub.\n"  
  while true
  do
    # Prompt user for Personal Access Token until provided
    read -r -e -p "GitHub Personal Access Token: " "gh_pat"
    # Check if token is empty
    if [[ -z "$gh_pat" ]]
    then
      printf "Token cannot be empty.\n"
    else
      # Attempt to login using token variable
      if ! printf "$gh_pat" | gh auth login --with-token &> /dev/null
      then
        printf "Failed to authenticate with GitHub. Please try again.\n"
      else
        printf "Successfully authenticated with GitHub.\n"
        gh config set git_protocol https &> /dev/null
        gh auth setup-git &> /dev/null
        break 1
      fi
    fi
  done
else
  # Tell the user they are already logged in
  printf "You are already authenticated with GitHub.\n"
fi
#
## Generating a .netrc file with an access token in it. 
#
## Creating a repository
# Generating a name for the new repository
if [[ -e "$1" ]]
then
  while true
  do
    # Create temp file and generate repo name out of file or directory name
    repo_name_temp="$(mktemp)"
    printf "$1" | awk -F '/' '{printf$NF}' > "$repo_name_temp"
    # Flag to tell the script not to prompt user when empty name
    repo_name_empty_msg_shown=false
    # Prompt the user to alter the repo name of the file/dir in the command argument
    if ! "$repo_name_empty_msg_shown"
    then
      printf "Modify the name of the new repository:\n"
    fi
    while true
    do
      # Use temp file as prompt to read user's modification
      read -r -e -i "$(cat "$repo_name_temp")" "repo_name"
      if [[ -z "$repo_name" ]]
      then
        # Prevent user from using an empty repo name
        printf "Repository name cannot be empty.\n"
        # Flag to prevent loop from displaying same message
        repo_name_empty_msg_shown=true
      else
        break 1
      fi
    done
    # Confirm with the user if the name is correct
    while true
    do
      if [[ -z "$chosen_name_message_shown" ]]
      then
        printf "The chosen name for the new repository is: \"$repo_name\".\n"
      fi
      printf "Is this correct? Yes/No: "
      read -r "confirm_repo_name"
      if [[ "$confirm_repo_name" == "yes" ||\
            "$confirm_repo_name" == "y" ]]
      then
        break 2 
      elif [[ "$confirm_repo_name" == "no" ||\
              "$confirm_repo_name" == "n" ]]
      then
        break 1
      else
        chosen_name_message_shown=true
      fi
    done
    # Clean up temp file
    rm -r "$repo_name_temp" &> /dev/null
  done
fi
#
## Creating a working directory
# Check for existing repo with same name
if ! [[ -d "$HOME/.github/$repo_name.git" ]]
then
  printf "Local repository does not exist at: \"$HOME/.github/$repo_name.git\". Creating it.\n"
  # Create a repo directory and copy contents of the argument to it
  mkdir -p "$HOME/.github/$repo_name.git"
  repo_dir_exists=true
else
  printf "Repository directory exists at: \"$HOME/.github/$repo_name.git\".\n"
  repo_dir_exists=true
fi
filename="$(basename "$1")"
if [[ -e "$HOME/.github/$repo_name.git/$filename" ]]
then
  printf "\"$filename\" already exists in \"$repo_name.git/$filename\".\n"
  filename_exists=true
else
  printf "\"$filename\" does not exists in \"$HOME/.github/$repo_name.git/$filename\".\n"
fi
# Check to see if selected file is different from what's in the repo already
if [[ "$repo_dir_exists"  == "true" ||\
      "$filename_exists" == "true" ]]
then
  if ! diff --brief "$1" "$HOME/.github/$repo_name.git/$filename" &> /dev/null
  then
    printf "\"$filename\" differs from \"$repo_name.git/$filename\".\n"
    filename_differs_from_repo=true
  fi
fi
# Forcefully copy file into repository, overwriting previous file
if [[ "$repo_dir_exists" == "true" ||\
      "$filename_differs_from_repo" == "true" ]]
then
  while [[ -z "$content_copied_to_repo" ]]
  do
    printf "Copying \"$filename\" into \"$HOME/.github/$repo_name.git/$filename\".\n"
    if cp --force --recursive "$1" "$HOME/.github/$repo_name.git"
    then
      printf "File or directory successfully copied into repository.\n"
      content_copied_to_repo=true
      break 1
    fi
  done
else
  printf "\"$filename\" is the same as \"$HOME/.github/$repo_name.git/$filename\".\n"
  printf "Not copying file or directory added as argument.\n"
fi
#
## Choosing a license template, editing it, or making your own.
# The license list as of 2024 February 08
license_names="\
[A] GNU Affero General Public License v3.0 (agpl-3.0)
[B] Apache License 2.0 (apache-2.0)
[C] BSD 2-Clause \"Simplified\" License (bsd-2-clause)
[D] BSD 3-Clause \"New\" or \"Revised\" License (bsd-3-clause)
[E] Boost Software License 1.0 (bsl-1.0)
[F] Creative Commons Zero v1.0 Universal (cc0-1.0)
[G] Eclipse Public License 2.0 (epl-2.0)
[H] GNU General Public License v2.0 (gpl-2.0)
[I] GNU General Public License v3.0 (gpl-3.0)
[J] GNU Lesser General Public License v2.1 (lgpl-2.1)
[K] MIT License (mit)
[L] Mozilla Public License 2.0 (mpl-2.0)
[M] The Unlicense (unlicense)"
# Check to see if the license.md file already exists inside of the repository
if [[ -f "$HOME/.github/$repo_name.git/LICENSE.MD" ]]
then
  printf "\"LICENSE.MD\" file already exists inside of the repository directory.\n"
  lic_file_exists_repo=true
else
  printf "\"LICENSE.MD\" file does not exist inside of the repository directory.\n"
  lic_file_exists_repo=false
fi
# Confirm if wanting to download a new license file
if [[ "$lic_file_exists_repo" == "true" ]]
then
  while true
  do
    printf "Do you want to select/download another license file? Yes/No: "
    read -r "select_new_license"
    select_new_license="$(printf "%s" "$select_new_license" | tr '[:upper:]' '[:lower:]')"
    if [[ "$select_new_license" == yes ||\
          "$select_new_license" == y ]]
    then
      select_new_license_confirmed=true
      break 1
    elif [[ "$select_new_license" == no ||\
            "$select_new_license" == n ]]
    then
      select_new_license_confirmed=false
      break 1
    fi
  done
else
  # If LICENSE.MD doesn't exist, no need to prompt for selecting another license
  select_new_license_confirmed=true
fi
# After confirmation, select a license template, display it, confirm if correct
while [[ "$select_new_license_confirmed" == "true" ||\
         "$selected_license_confirmed" == "false" ]]
do
  if [[ "$select_new_license_confirmed" == "true" ||\
        "$lic_file_exists_repo" == "false" ]]
  then
    if [[ -z "$selected_license_confirmed" ]]
    then
      printf "%s\n" "$license_names"
    fi
    while true
    do
      printf "Enter the letter for the license template you want to use: "
      read -r "selected_letter"
      selected_letter=$(echo "$selected_letter" | tr '[:lower:]' '[:upper:]')
      if [[ "$selected_letter" =~ ^[A-M]$ ]]
      then
        selected_license_file="$(printf "%s" "$license_names" | grep "\[$selected_letter\]")"
        printf "The chosen license for the new repository is: \"$selected_license_file\".\n"
        while true
        do
          printf "Is this correct? Yes/No: "
          read -r "confirm_selected_license"
          confirm_selected_license="$(echo "$confirm_selected_license" | tr '[:upper:]' '[:lower:]')"
          if [[ "$confirm_selected_license" == yes ||\
                "$confirm_selected_license" == y ]]
          then
            selected_license_confirmed=true
            break 4
          elif [[ "$confirm_selected_license" == no ||\
                  "$confirm_selected_license" == n ]]
          then
            selected_license_confirmed=false
            break 1
          fi
        done
      fi
    done
  fi
done
# Non case sensitive letter selection options for url generation
if [[ "$selected_license_confirmed" == "true" ]]
then
  case $selected_letter in
    [Aa]) license_file_url="https://www.gnu.org/licenses/agpl-3.0.txt";;
    [Bb]) license_file_url="https://www.apache.org/licenses/LICENSE-2.0.txt";;
    [Cc]) license_file_url="https://spdx.org/licenses/BSD-2-Clause.txt";;
    [Dd]) license_file_url="https://spdx.org/licenses/BSD-3-Clause.txt";;
    [Ee]) license_file_url="https://www.boost.org/LICENSE_1_0.txt";;
    [Ff]) license_file_url="https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt";;
    [Gg]) license_file_url="https://www.eclipse.org/org/documents/epl-2.0/EPL-2.0.txt";;
    [Hh]) license_file_url="https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt";;
    [Ii]) license_file_url="https://www.gnu.org/licenses/gpl-3.0.txt";;
    [Jj]) license_file_url="https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt";;
    [Kk]) license_file_url="https://www.mit.edu/~amini/LICENSE.md";;
    [Ll]) license_file_url="https://www.mozilla.org/media/MPL/2.0/index.815ca599c9df.txt";;
    [Mm]) license_file_url="https://unlicense.org/UNLICENSE";;
    *) printf "URL for selected license file does not exist.\n" && exit;;
  esac
fi
# Check if license file exists, if not, downloads it. 
if [[ -n "$license_file_url" ||\
      "$select_new_license_confirmed" == "true" ]]
then
  license_name="$(printf "%s" "$license_names" | grep -oP "$selected_letter\]\K[^)]+")"
  license_file_name="$(echo "$license_name" | awk -F '(' '{print $1}' | awk '{$1=$1};1').txt"
  license_file_path="$HOME/.github/LICENSES/${license_file_name}"
  if [[ -f "$license_file_path" ]]
  then
    printf "Selected license already exists at \"$license_file_path\".\n"
    lic_file_exists_dir=true
  else
    printf "Selected license does not exist at \"$license_file_path\". Downloading it.\n"
    lic_file_exists_dir=false
    while ! [[ -f "$license_file_path" ]]
    do
      wget --quiet "$license_file_url" -O "$license_file_path"
      if [[ -f "$license_file_path" ]]
      then
        printf "Download complete and saved at \"$license_file_path\".\n"
        lic_file_exists_dir=true
        break 1
      fi
    done
  fi
fi
# Check if license.md in repo is different from the downloaded license file
if [[ "$lic_file_exists_dir" == "true" && "$lic_file_exists_repo" == "true" ]]
then
  if ! diff --brief "$license_file_path" "$HOME/.github/$repo_name.git/LICENSE.MD" &> /dev/null
  then
    printf "\"LICENSE.MD\" file is different from the selected license.\n"
    license_file_differs=true
  else
    printf "\"LICENSE.MD\" file is the same as the selected license.\n"
    license_file_differs=false
  fi
fi
# Confirm if overwrite license.md with downloaded licence file
while [[ "$lic_file_exists_repo" == "true" && "$license_file_differs" == "true" ]]
do
  printf "Would you still like to copy the selected license to \"LICENSE.MD\"? Yes/No: "
  read -r "confirm_copy_license"
  confirm_copy_license="$(echo "$confirm_copy_license" | tr '[:upper:]' '[:lower:]')"
  if [[ "$confirm_copy_license" == yes ||\
        "$confirm_copy_license" == y ]]
  then
    copy_license_confirmed=true
    break 1
  elif [[ "$confirm_copy_license" == no ||\
          "$confirm_copy_license" == n ]]
  then
    copy_license_confirmed=false
    break 1
  fi
done
# Copy downloaded license file from license dir to repo dir after confirmation
if [[ "$lic_file_exists_dir" == "true" &&\
 "$copy_license_confirmed" == "true" ||\
 "$lic_file_exists_repo" == "false" ]]
then
  while true
  do
    if [[ -f "$HOME/.github/$repo_name.git/LICENSE.MD" ]]
    then
      rm --force "$HOME/.github/$repo_name.git/LICENSE.MD"
      printf "Removed existing \"LICENSE.MD\"\n"
    fi
    cp --force "$license_file_path" "$HOME/.github/$repo_name.git/LICENSE.MD"
    if [[ -f "$HOME/.github/$repo_name.git/LICENSE.MD" ]]
    then
      printf "Copy to repository complete from \"$license_file_path\".\n"
      copied_license_file=true
      lic_file_exists_repo=true
      break 1
    fi
  done
fi
# Confirm to edit the license.md in repo
while [[ "$lic_file_exists_repo" == "true" ]]
do
  printf "Would you like to edit the \"LICENSE.MD\" file using Nano text editor? Yes/No: "
  read -r "confirm_edit_license"
  confirm_edit_license="$(echo "$confirm_edit_license" | tr '[:upper:]' '[:lower:]')"
  if [[ "$confirm_edit_license" == yes ||\
   "$confirm_edit_license" == y ]]
  then
    edit_license_confirmed=true
    break 1
  elif [[ "$confirm_edit_license" == no ||\
   "$confirm_edit_license" == n ]]
  then
    edit_license_confirmed=false
    break 1
  fi
done
# Open license.md in repo with nano after confirmation
if [[ "$edit_license_confirmed" == "true" ]]
then
  while [[ -z "$license_edited" ]]
  do
  nano -q -E -I -i "$HOME/.github/$repo_name.git/LICENSE.MD"
  license_edited=true
  done
fi
#
## Creating a README.MD file
#
## Creating the remote git repository on GitHub
# Initialize a local git repository
if [[ "$lic_file_exists_repo" == "true" ]]
then
  while [[ -z "$repo_git_init" ]]
  do
    git init "$HOME/.github/$repo_name.git" &> /dev/null
    if [[ -d "$HOME/.github/$repo_name.git/.git" ]]
    then
      printf "Initialized local Git repository.\n"
      repo_git_init=true
    fi
  done
fi
# Add files to staging in the local git repository
if [[ "$repo_git_init" == "true" ]]
then
  while [[ -z "$repo_git_added_all" ]]
  do
    if git -C "$HOME/.github/$repo_name.git" add -A
    then
      status="$(git -C "$HOME/.github/$repo_name.git" status --porcelain)"
      status_count="$(printf "$status\n" | wc -l)"
      if [[ "$status_count" -gt 0 ]]
      then
        printf "Added "$status_count" files to staging from \"$HOME/.github/$repo_name.git\".\n"
      else
        printf "No files were staged for commit.\n"
      fi
      repo_git_added_all=true
      break 1
    fi
  done
fi
# Index files from staging to be ready for commit to GitHub
if [[ "$repo_git_added_all" == "true" ]]
then
  if ! git -C "$HOME/.github/$repo_name.git" commit -m "commit" | grep "changed"
  then
    printf "There was nothing to commit that wasn't already commited.\n"
  fi
  repo_git_commited_all=true
fi
# Check to see if repository exists already on GitHub
if [[ "$repo_git_commited_all" == "true" ]]
then
  git_username="$(cat ~/.config/gh/hosts.yml | awk '/user:/ {printf $NF}')"
  git_repo_url="https://github.com/$git_username/$repo_name"
  if gh repo view "$git_username/$repo_name" --json name &> /dev/null
  then
    printf "Repository already exists at: \"$git_repo_url\"\n"
    git_repo_exists=true
  else
    printf "Repository doesn't exist at: \"$git_repo_url\".\n"
    git_repo_exists=false
  fi
fi
# Create a remote repository
if [[ "$repo_git_commited_all" == "true" &&\
      "$git_repo_exists" == "false" ]]
then
  printf "Attempting to create a new repository on GitHub.\n"
  if gh repo create "$repo_name" --source "$HOME/.github/$repo_name.git" --public
  then
    printf "GitHub repository successfully created at: \"$git_repo_url\"\n"
    git_repo_created=true
  else
    printf "GitHub repository creation failed at: \"$git_repo_url\"\n"
  fi
fi






#
## Creating a description for your repository
if [[ "$git_repo_created" == "true" ||\
      "$git_repo_exists" == "true" ]]
then
  current_description="$(gh repo view "$git_username/$repo_name" --json "description" |\
    awk -F '"' '{print $4}')"
  while [[ -z "$description_exceeds_limit" ||\
           "$description_exceeds_limit" == "true" ]]
  do
    printf "Edit the description for \"$git_repo_url\". 350 characters max.\n"
    if [[ -z "$current_description" ]]
    then
      current_description="$(printf "No description, website, or topics provided. ")"
    fi
    if [[ "$description_exceeds_limit" == "true" ]]
    then
      current_description="$edited_description"
    fi
    read -r -e -i "$current_description" "edited_description"
    if (( ${#edited_description} >= 0 &&\
      ${#edited_description} <= 350 ))
    then
      printf "Description saved.\n"
      description_saved="true"
      description_exceeds_limit="false"
      break 1
    else
      printf "Description exceeds the 350 character limit.\n"
      description_exceeds_limit="true"
    fi    
  done
fi
if [[ "$description_saved" == "true" ]]
then
  printf "Description: \"$edited_description\"\n"
fi





# Forcefully push all local files to remote repository
if [[ "$git_repo_created" == "true" ||\
      "$git_repo_exists" == "true" &&\
      "$description_saved" == "true" ]]
then
  printf "Pushing changes to GitHub...\n"
  git -C "$HOME/.github/$repo_name.git" push -f --set-upstream "$git_repo_url" master
  git_repo_pushed=true
fi
# Check if the content was indeed pushed to GitHub
if [[ "$git_repo_pushed" == "true" ]]
then
  printf "Checking if the content was pushed to GitHub...\n"
  latest_commit="$(git -C "$HOME/.github/$repo_name.git" rev-parse HEAD)"
  if [[ "$previous_commit" != "$latest_commit" ]]
  then
    printf "\"$filename\" successfully pushed to GitHub at: \"$git_repo_url\"\n"
  else
    printf "No new commits detected. \"$filename\" may not have been pushed successfully.\n"
  fi
fi
