#!/bin/bash
#
## This is a script that automates GitHub operations, such as:
## logging in, staying logged in, creating working folders,
## creating repositories, creating and editing descriptions, 
## choosing and creating licensing,
#
#
#
#
#    Git-Repocreater2 to instantly create repositories on GitHub.
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
if
  [[ "$1" == "--help" ]] ||
  [[ "$1" == "-h" ]]
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




Git-Repocreater2
Copyright (C) 2024 GitHub.com/Zeph53
This program comes with ABSOLUTELY NO WARRANTY!
This is free software, and you are welcome to
redistribute it under certain conditions.
See \"https://www.gnu.org/licenses/gpl-3.0.txt\"
"
  exit 1
elif
  [[ ! -e "$1" ]]
then
  printf "Add a file or folder to the command as an argument.\n"
  printf "Use \"--help\" for help.\n"
  exit 1
fi
#
## Function to check to see if still connected to the internet,
## or at least to github.com
check_connection() {
  if
    [[ "$connected_internet" == "true" ]]
  then
    true
  else
    printf "Testing \"www.GitHub.com\" connection.\n"
  fi
  while
    ! ping -i 0.25 -W 2 -c 4 "www.github.com" &> /dev/null
  do
    printf "Can't connect to \"www.GitHub.com\".\n"
    connected_internet="false"
    seconds=5
    while
      [ $seconds -gt 0 ]
    do
      printf "\rTrying again in: %02d seconds." $seconds
      sleep 1
      : $((seconds--))
    done
    printf "\n"
  done
  if
    [[ "$connected_internet" == "true" ]]
  then
    true
  else
    printf "Connected to \"www.GitHub.com\".\n"
  fi
  connected_internet="true"
}
#
## Disclaimer GNU General Public License v3.0 (gpl-3.0)
printf \
'This program comes with ABSOLUTELY NO WARRANTY!\n'
printf \
'This is free software, and you are welcome to redistribute it under certain conditions.\n'
#
#
#
#
## Logging into GitHub using GH
# Check if user is logged in, or log in
if
  [[ -z "$connected_internet" ]]
then
  check_connection
fi
if
  [[ "$connected_internet" == "true" ]] &&
  ! gh auth status &> /dev/null
then
  printf "You are not authenticated with GitHub.\n"  
  while
    true
  do
    read -r -e -p "GitHub Personal Access Token: " "gh_pat"
    if
      [[ -z "$gh_pat" ]]
    then
      printf "Token cannot be empty.\n"
      unset "gh_pat"
    else
      if
        ! printf "$gh_pat" | gh auth login --with-token &> /dev/null
      then
        printf "Failed to authenticate with GitHub. Please try again.\n"
        unset "gh_pat"
      else
        printf "Successfully authenticated with GitHub.\n"
        unset "gh_pat"
        gh config set git_protocol https &> /dev/null
        gh auth setup-git &> /dev/null
        break 1
      fi
    fi
  done
else
  printf "You are already authenticated with GitHub.\n"
fi
# Generating a .netrc file with an access token in it
#
#
#
#
## Creating a local repository
# Generating a name for the new repository
if
  [[ -e "$1" ]]
then
  while
    [[ -z "$confirm_repo_name" ]] ||
    [[ "$confirm_repo_name" == "false" ]]
  do
    if
      [[ -z "$repo_names_remote_listed" ]] &&
      check_connection
    then
      repo_names_remote_list="$(gh repo list)"
      repo_names_remote_list_numbered=""
      counter="1"
      while
        IFS="$'\t'" read -r "repo"
      do
        repo_name="$(printf "$repo" | awk -F '\t' '{split($1, arr, "/"); print arr[2]}')"
        repo_names_remote_list_numbered+="$counter. $repo_name"$'\n'
        ((counter++))
      done <<< "$repo_names_remote_list"
      printf "Existing remote GitHub repository names: \n"
      printf "%s" "$repo_names_remote_list_numbered"
      repo_names_remote_listed="true"
    fi
    if
      [[ -z "$repo_names_local_listed" ]]
    then
      for repo in "$HOME"/.github/*/.git
      do
        if
          [[ -d "$repo" ]]
        then
          printf "Existing local GitHub repository names: \n"
          if
            git -C "$(dirname "$repo")" status &>/dev/null
          then
            printf "$(dirname "$repo")\n" | awk -F '/' '{gsub(/\.git$/,"", $NF); print $NF}'
          fi
        fi
      done
      repo_names_local_listed="true"
    fi
    if
      [[ -z "$repo_name_set" ]]
    then
      repo_name="$(printf "$1" | awk -F '/' '{print $NF}')"
    fi
    if
      [[ -z "$enter_name_shown" ]]
    then
      printf "Enter a name to use for the repository: \n"
      enter_name_shown="true"
    fi
    if
      true
    then
      read -r -e -i "$(printf "$repo_name")" "repo_name"
      repo_name_set="true"
    fi
    if
      [[ $repo_name =~ ^[0-9]+$ && $repo_name -ge 1 && $repo_name -le $((counter - 1)) ]]
    then
      selected_repo="$(printf "$repo_names_remote_list" | awk -v num="$repo_name" 'NR==num {split($1, arr, "/"); print arr[2]}')"
      printf "$selected_repo\n"
      repo_name="$selected_repo"
      unset "repo_name_set"
    fi
    if
      [[ -z "$repo_name" ]]
    then
      printf "Repository name cannot be empty.\n"
      unset "repo_name_set"
    elif
      [[ "$repo_name" =~ [^[:alnum:]._-] ]]
    then
      printf "Repository name can only contain \"A-Z\" \"0-9\" \"period .\" \"hyphen -\" or \"underscore _\".\n"
    elif
      (( "${#repo_name}" >= "100" ))
    then
      printf "Repository name cannot be more than 100 characters.\n"
    else
      while
        true
      do
        printf "Is this correct? Yes/No: "
        read -r "confirm_repo_name"
        confirm_repo_name="$(printf "%s" "$confirm_repo_name" | tr '[:upper:]' '[:lower:]')"
        if
          [[ "$confirm_repo_name" == "yes" ]] ||
          [[ "$confirm_repo_name" == "y" ]]
        then
          confirm_repo_name="true"
          break 2
        elif
          [[ "$confirm_repo_name" == "no" ]] ||
          [[ "$confirm_repo_name" == "n" ]]
        then
          confirm_repo_name="false"
          break 1
        fi
      done
    fi
  done
fi
#
#
#
#
## Creating a staging directory
# Check for existing repo with same name
if
  ! [[ -d "$HOME/.github/$repo_name.git" ]]
then
  printf "Local repository does not exist at: \"$HOME/.github/$repo_name.git\". Creating it.\n"
  mkdir -p "$HOME/.github/$repo_name.git"
  repo_dir_exists="true"
else
  printf "Repository directory exists at: \"$HOME/.github/$repo_name.git\".\n"
  repo_dir_exists="true"
fi
filename="$(basename "$1")"
if
  [[ -e "$HOME/.github/$repo_name.git/$filename" ]]
then
  printf "\"$filename\" already exists in \"$repo_name.git/$filename\".\n"
  filename_exists="true"
else
  printf "\"$filename\" does not exists in \"$repo_name.git/$filename\".\n"
fi
# Check to see if selected file is different from what's in the repo already
if
  [[ "$repo_dir_exists"  == "true" ]] &&
  [[ "$filename_exists" == "true" ]]
then
  if
    ! diff --brief "$1" "$HOME/.github/$repo_name.git/$filename" &> /dev/null
  then
    printf "\"$filename\" differs from \"$repo_name.git/$filename\".\n"
    filename_differs_from_repo="true"
  else
    printf "\"$filename\" is the same as \"$repo_name.git/$filename\".\n"
  fi
fi
# Forcefully copy file into repository, overwriting previous file
if
  [[ "$repo_dir_exists" == "true" ]]
then
  if
    [[ -z "$filename_exists" ]] ||
    [[ "$filename_differs_from_repo" == "true" ]]
   then
    while
      [[ -z "$content_copied_to_repo" ]]
    do
      printf "Copying \"$filename\" into \"$repo_name.git/$filename\".\n"
      if
        cp --force --recursive "$1" "$HOME/.github/$repo_name.git"
      then
        printf "\"$filename\" successfully copied to \"$repo_name.git/$filename.\n"
        content_copied_to_repo="true"
        break
      fi
    done
  fi
fi
#
#
#
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
if
  [[ -f "$HOME/.github/$repo_name.git/LICENSE.MD" ]]
then
  printf "\"LICENSE.MD\" file already exists inside of \"$repo_name.git/LICENSE.MD\".\n"
  lic_file_exists_repo="true"
else
  printf "\"LICENSE.MD\" file does not exist inside of \"$repo_name.git/LICENSE.MD\".\n"
  lic_file_exists_repo="false"
fi
# If not existing in repo, check to see if license.md happens to exists on GitHub already
git_username="$(cat ~/.config/gh/hosts.yml | awk '/user:/ {printf $NF}')"
if
  [[ "$lic_file_exists_repo" == "false" ]]
then
  lic_file_github_url="https://raw.githubusercontent.com/$git_username/$repo_name/master/LICENSE.MD"
  if
    check_connection
  then
    if
      wget --spider "$lic_file_github_url" &> /dev/null
    then
      printf "\"LICENSE.MD\" does exists on the GitHub repository.\n"
      lic_file_exist_github_url="true"
    else
      printf "\"LICENSE.MD\" does not exist at \"$lic_file_github_url\".\n"
    fi
  fi
fi
# When the license.md exists on GitHub and not in the local repository, download it
if
  [[ "$lic_file_exist_github_url" == "true" ]] &&
  [[ "$lic_file_exists_repo" == "false" ]]
then
  printf "Downloading \"LICENSE.MD\" from \"$lic_file_github_url\".\n"
  while
    [[ -z "$lic_file_github_url_wget" ]]
  do
    if
      check_connection
    then
      wget --quiet "$lic_file_github_url" -O "$HOME/.github/$repo_name.git/LICENSE.MD"
      if
        [[ -f "$HOME/.github/$repo_name.git/LICENSE.MD" ]]
      then
        printf "\"LICENSE.MD\" downloaded from \"$lic_file_github_url\".\n"
        lic_file_exists_repo="true"
        lic_file_github_url_wget="true"
      fi
    fi
  done
fi
# Confirm if wanting to download a new license file
if
  [[ "$lic_file_exists_repo" == "true" ]]
then
  while
    true
  do
    printf "Do you want to select/download another license file? Yes/No: "
    read -r "select_new_license"
    select_new_license="$(printf "%s" "$select_new_license" | tr '[:upper:]' '[:lower:]')"
    if
      [[ "$select_new_license" == "yes" ]] ||
      [[ "$select_new_license" == "y" ]]
    then
      select_new_license_confirmed="true"
      break 1
    elif
      [[ "$select_new_license" == "no" ]] ||
      [[ "$select_new_license" == "n" ]]
    then
      select_new_license_confirmed="false"
      break 1
    fi
  done
else
  select_new_license_confirmed="true"
fi
# After confirmation unless existing, select a license template, display it, confirm if correct
while
  [[ "$select_new_license_confirmed" == "true" ]] ||
  [[ "$selected_license_confirmed" == "false" ]]
do
  if
    [[ "$select_new_license_confirmed" == "true" ]] ||
    [[ "$lic_file_exists_repo" == "false" ]]
  then
    if
      [[ -z "$selected_license_confirmed" ]]
    then
      printf "%s\n" "$license_names"
    fi
    while
      true
    do
      printf "Enter the letter for the license template you want to use: "
      read -r "selected_letter"
      selected_letter=$(printf "$selected_letter" | tr '[:lower:]' '[:upper:]')
      if
        [[ "$selected_letter" =~ ^[A-M]$ ]]
      then
        selected_license_file="$(printf "%s" "$license_names" | grep "\[$selected_letter\]")"
        printf "The chosen license for the new repository is: \"$selected_license_file\".\n"
        while
          true
        do
          printf "Is this correct? Yes/No: "
          read -r "confirm_selected_license"
          confirm_selected_license="$(printf "$confirm_selected_license" | tr '[:upper:]' '[:lower:]')"
          if
            [[ "$confirm_selected_license" == "yes" ]] ||
            [[ "$confirm_selected_license" == "y" ]]
          then
            selected_license_confirmed="true"
            break 3
          elif
            [[ "$confirm_selected_license" == "no" ]] ||
            [[ "$confirm_selected_license" == "n" ]]
          then
            selected_license_confirmed="false"
            break 1
          fi
        done
      fi
    done
  fi
done
# Non case sensitive letter selection options for url generation
if
  [[ "$selected_license_confirmed" == "true" ]]
then
  case "$selected_letter" in
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
if
  [[ -n "$license_file_url" ]] ||
  [[ "$select_new_license_confirmed" == "true" ]]
then
  license_name="$(printf "%s" "$license_names" | grep -oP "$selected_letter\]\K[^)]+")"
  license_file_name="$(printf "$license_name" | awk -F '(' '{print $1}' | awk '{$1=$1};1').txt"
  license_file_path="$HOME/.github/LICENSES/${license_file_name}"
  if
    [[ -f "$license_file_path" ]]
  then
    printf "Selected license already exists at \"$license_file_path\".\n"
    lic_file_exists_dir="true"
  else
    printf "Selected license does not exist at \"$license_file_path\". Downloading it.\n"
    lic_file_exists_dir="false"
    while
      ! [[ -f "$license_file_path" ]]
    do
      if
        check_connection
      then
        printf "Downloading.\n"
        wget --quiet "$license_file_url" -O "$license_file_path"
      fi
      if
        [[ -f "$license_file_path" ]]
      then
        printf "Download complete and saved at \"$license_file_path\".\n"
        lic_file_exists_dir="true"
        break 1
      fi
    done
  fi
fi
# Check if license.md in repo is different from the downloaded license file
if
  [[ "$lic_file_exists_dir" == "true" ]] && 
  [[ "$lic_file_exists_repo" == "true" ]]
then
  if
    ! diff --brief "$license_file_path" "$HOME/.github/$repo_name.git/LICENSE.MD" &> /dev/null
  then
    printf "\"LICENSE.MD\" file is different from the selected license.\n"
    license_file_differs="true"
  else
    printf "\"LICENSE.MD\" file is the same as the selected license.\n"
    license_file_differs="false"
  fi
fi
# Confirm if overwrite license.md with downloaded licence file
while
  [[ "$lic_file_exists_repo" == "true" ]] &&
  [[ "$license_file_differs" == "true" ]]
do
  printf "Would you still like to copy the selected license to \"LICENSE.MD\"? Yes/No: "
  read -r "confirm_copy_license"
  confirm_copy_license="$(printf "$confirm_copy_license" | tr '[:upper:]' '[:lower:]')"
  if
    [[ "$confirm_copy_license" == "yes" ]] ||
    [[ "$confirm_copy_license" == "y" ]]
  then
    copy_license_confirmed="true"
    break 1
  elif
    [[ "$confirm_copy_license" == "no" ]] ||
    [[ "$confirm_copy_license" == "n" ]]
  then
    copy_license_confirmed="false"
    break 1
  fi
done
# Copy downloaded license file from license dir to repo dir after confirmation
if
  [[ "$lic_file_exists_dir" == "true" ]] &&
  [[ "$copy_license_confirmed" == "true" ]] ||
  [[ "$lic_file_exists_repo" == "false" ]]
then
  while
    true
  do
    if
      [[ -f "$HOME/.github/$repo_name.git/LICENSE.MD" ]]
    then
      rm --force "$HOME/.github/$repo_name.git/LICENSE.MD"
      printf "Removed existing \"LICENSE.MD\" from \"$repo_name.git/LICENSE.MD\".\n"
    fi
    cp --force "$license_file_path" "$HOME/.github/$repo_name.git/LICENSE.MD"
    if
      [[ -f "$HOME/.github/$repo_name.git/LICENSE.MD" ]]
    then
      printf "Copy \"LICENSE.MD\" to repository completed from \"$license_file_path\".\n"
      copied_license_file="true"
      lic_file_exists_repo="true"
      break 1
    fi
  done
fi
# Confirm to edit the license.md in repo with nano
while
  [[ "$lic_file_exists_repo" == "true" ]]
do
  printf "Would you like to edit the \"LICENSE.MD\" file using Nano text editor? Yes/No: "
  read -r "confirm_edit_license"
  confirm_edit_license="$(printf "$confirm_edit_license" | tr '[:upper:]' '[:lower:]')"
  if
    [[ "$confirm_edit_license" == "yes" ]] ||
    [[ "$confirm_edit_license" == "y" ]]
  then
    edit_license_confirmed="true"
    break 1
  elif
    [[ "$confirm_edit_license" == "no" ]] ||
    [[ "$confirm_edit_license" == "n" ]]
  then
    edit_license_confirmed="false"
    break 1
  fi
done
# Open license.md in repo with nano after confirmation
if
  [[ "$edit_license_confirmed" == "true" ]]
then
  while
    [[ -z "$license_edited" ]]
  do
    nano -E -Y markdown -S -a -i -l -m -q "$HOME/.github/$repo_name.git/LICENSE.MD"
    license_edited="true"
  done
fi
#
#
#
#
## Creating a README.MD file
# Check for existing readme.md in repo
if
  [[ -f "$HOME/.github/$repo_name.git/README.MD" ]]
then
  printf "\"README.MD\" exists inside of \"$repo_name.git/README.MD\".\n"
  readme_file_exists_repo="true"
else
  printf "\"README.MD\" does not exist inside of \"$repo_name.git/README.MD\".\n"
fi
# If not existing in repo, check to see if readme.md exists on GitHub
if
  [[ -z "$readme_file_exists_repo" ]]
then
  readme_file_url="https://raw.githubusercontent.com/$git_username/$repo_name/master/README.MD"
  if
    check_connection
  then
    if
      wget --spider "$readme_file_url" &> /dev/null
    then
      printf "\"README.MD\" does exists on the \"$readme_file_url\".\n"
      readme_file_exist_url="true"
    else
      printf "\"README.MD\" does not exist at \"$readme_file_url\".\n"
    fi
  fi
fi
# When the readme.md exists on GitHub and not in the local repository, download it
if
  [[ "$readme_file_exist_url" == "true" ]] &&
  [[ -z "$readme_file_exists_repo" ]]
then
  printf "Downloading existing \"README.MD\" from \"$readme_file_url\".\n"
  while
    [[ -z "$readme_file_url_wget" ]]
  do
    if
      check_connection
    then
      wget --quiet "$readme_file_url" -O "$HOME/.github/$repo_name.git/README.MD"
      if
        [[ -f "$HOME/.github/$repo_name.git/README.MD" ]]
      then
        printf "Existing \"README.MD\" downloaded from \"$readme_file_url\".\n"
        readme_file_url_wget="true"
      fi
    fi
  done
fi
# When the readme.md doesn't exist on the local repo or the GitHub repo ask to create one
if
  [[ -z "$readme_file_exists_repo" ]] &&
  [[ -z "$readme_file_exists_url" ]] &&
  [[ -z "$readme_file_url_wget" ]]
then
  while
    [[ -z "$create_readme_confirmed" ]]
  do
    printf "Create an empty \"README.MD\" file in the local repository? Yes/No: "
    read -r "confirm_create_readme"
    confirm_create_readme="$(printf "$confirm_create_readme" | tr '[:upper:]' '[:lower:]')"
    if
      [[ "$confirm_create_readme" == "yes" ]] ||
      [[ "$confirm_create_readme" == "y" ]]
    then
      create_readme_confirmed="true"
      break 1
    elif
      [[ "$confirm_create_readme" == "no" ]] ||
      [[ "$confirm_create_readme" == "n" ]]
    then
      create_readme_confirmed="false"
      break 1
    fi
  done
fi
# After confirmation, create a blank readme.md file with the repo name in it
if
  [[ "$create_readme_confirmed" == "true" ]]
then
  while
    [[ -z "$readme_file_exists_repo" ]]
  do
    touch "$HOME/.github/$repo_name.git/README.MD"
    printf "# $repo_name\n" > "$HOME/.github/$repo_name.git/README.MD"
    if
      [[ -f "$HOME/.github/$repo_name.git/README.MD" ]]
    then
      printf "\"README.MD\" file successfully created.\n"
      readme_file_exists_repo="true"
    fi
  done
fi
# Confirm to edit the readme.md in repo with nano
while
  [[ "$readme_file_exists_repo" == "true" ]]
do
  printf "Would you like to edit the \"README.MD\" file using Nano text editor? Yes/No: "
  read -r "confirm_edit_readme"
  confirm_edit_readme="$(printf "$confirm_edit_readme" | tr '[:upper:]' '[:lower:]')"
  if
    [[ "$confirm_edit_readme" == "yes" ]] ||
    [[ "$confirm_edit_readme" == "y" ]]
  then
    edit_readme_confirmed="true"
    break 1
  elif
    [[ "$confirm_edit_readme" == "no" ]] ||
    [[ "$confirm_edit_readme" == "n" ]]
  then
    edit_readme_confirmed="false"
    break 1
  fi
done
# Open readme.md in repo with nano after confirmation
if
  [[ "$edit_readme_confirmed" == "true" ]]
then
  while
    [[ -z "$readme_edited" ]]
  do
    nano -E -Y markdown -S -a -i -l -m -q "$HOME/.github/$repo_name.git/README.MD"
    readme_edited="true"
  done
fi
#
#
#
#
## Creating the remote git repository on GitHub
# Initialize a local git repository
if
  [[ "$lic_file_exists_repo" == "true" ]]
then
  while
    [[ -z "$repo_git_init" ]]
  do
    git init "$HOME/.github/$repo_name.git" &> /dev/null
    if
      [[ -d "$HOME/.github/$repo_name.git/.git" ]]
    then
      printf "Initialized local Git repository.\n"
      repo_git_init="true"
    fi
  done
fi
# Add files to staging in the local git repository
if
  [[ "$repo_git_init" == "true" ]]
then
  while
    [[ -z "$repo_git_added_all" ]]
  do
    if
      git -C "$HOME/.github/$repo_name.git" add -A
    then
      status="$(git -C "$HOME/.github/$repo_name.git" status --porcelain)"
      status_count="$(printf "$status\n" | wc -l)"
      if
        [[ "$status_count" -gt 0 ]]
      then
        printf "Added "$status_count" files to staging from \"$repo_name.git\".\n"
      else
        printf "No files were staged for commit.\n"
      fi
      repo_git_added_all="true"
      break 1
    fi
  done
fi
#
## Selecting an email for the repository
# Gather all associated emails
while
  [[ -z "$public_events_data" ]]
do
  if
    check_connection
  then
    public_events_data="$(curl -s "https://api.github.com/users/$git_username/events/public")"
  fi
done
if
  [[ -n "$public_events_data" ]]
then
  remote_emails_list="$(printf "%s" "$public_events_data" | awk -F '"' '/"email":/{print $4}' | sort -u | grep -v '^$')"
  local_emails_list="$(git -C "$HOME/.github/$repo_name.git" log --all --format='%aE' | sort -u)"
  global_email="$(git -C "$HOME/.github/$repo_name.git" config --global user.email)"
  local_repo_email="$(git -C "$HOME/.github/$repo_name.git" config --local user.email)"
  emails_list_gathered="true"
fi
# Number each email found with a number
if
  [[ "$emails_list_gathered" == "true" ]]
then
  declare -A email_numbers
  email_count=1
  for email in $remote_emails_list
  do
    if
      [[ ! -v email_numbers["$email"] ]]
    then
      email_numbers["$email"]=$email_count
      ((email_count++))
    fi
  done
  for email in $local_emails_list
  do
    if
      [[ ! -v email_numbers["$email"] ]]
    then
      email_numbers["$email"]=$email_count
      ((email_count++))
    fi
  done
  if
    [[ -n "$global_email" ]]
  then
    if
      [[ ! -v email_numbers["$global_email"] ]]
    then
      email_numbers["$global_email"]=$email_count
      ((email_count++))
    fi
  fi
  if
    [[ -n "$local_repo_email" ]]
  then
    if
      [[ ! -v email_numbers["$local_repo_email"] ]]
    then
      email_numbers["$local_repo_email"]=$email_count
      ((email_count++))
    fi
  fi
  email_list_numbered="true"
fi
# Display each email found with the number
if
  [[ "$email_list_numbered" == "true" ]]
then
  printf "Email addresses publicly associated with \"$git_username\": \n"
  for email in $remote_emails_list
  do
    printf " %s. %s\n" "${email_numbers[$email]}" "$email"
  done
  printf "Email addresses locally associated with \"$repo_name.git\": \n"
  for email in $local_emails_list
  do
    printf " %s. %s\n" "${email_numbers[$email]}" "$email"
  done
  if
    [[ -n "$global_email" ]]
  then
    printf "Email address globally defined for Git operations: \n"
    printf " %s. %s\n" "${email_numbers[$global_email]}" "$global_email"
  else
    printf "Email address to globally use for Git operations is not configured. \n"
  fi
  if
    [[ -n "$local_repo_email" ]]
  then
    printf "Email address currently assigned to \"$repo_name\": \n"
    printf " %s. %s\n" "${email_numbers[$local_repo_email]}" "$local_repo_email"
  else
    printf "Email address assigned to \"$repo_name\" is not configured. \n"
  fi
fi
# Determine what the default email should be for preloaded text
if
  [[ -n "$local_repo_email" ]]
then
  default_email="$local_repo_email"
elif
  [[ -n "$global_email" ]]
then
  default_email="$global_email"
elif
  [[ -z "$local_repo_email" ]] &&
  [[ -z "$global_email" ]]
then
  unconfigured_email="unconfigured"
  default_email="$unconfigured_email"
  not_configured_email="true"
fi
# Prompt the user to select a valid email address
while
  [[ -z "$selected_email_input_confirmed" ]] ||
  [[ "$selected_email_input_confirmed" == "false" ]]
do
  while
    [[ -z "$email_valid" ]] ||
    [[ "$email_valid" == "false" ]]
  do
    if
      [[ -z "$enter_email_shown" ]]
    then
      printf "Enter a corresponding number or a custom email address to assign to \"$repo_name\": \n"
      enter_email_shown="true"
    fi
    read -r -e -i "$default_email" "selected_email_input"
    if
      [[ "$selected_email_input" =~ ^[0-9]+$ ]]
    then
      if
        [[ "${email_numbers[@]}" =~ (^|[[:space:]])"$selected_email_input"($|[[:space:]]) ]]
      then
        for email in "${!email_numbers[@]}"
        do
          if
            [[ "${email_numbers[$email]}" == "$selected_email_input" ]]
          then
            selected_email="$email"
            printf "%s\n" "$selected_email"
            email_valid="true"
          fi
        done
      else
        printf "Selected number is invalid.\n"
        email_valid="false"
      fi
    elif
      [[ "$selected_email_input" =~ .+@.+\..+ ]]
    then
      selected_email="$selected_email_input"
      email_valid="true"
    else
      printf "Invalid email format.\n"
      email_valid="false"
    fi
  done
  while
    true
  do
    printf "Is this correct? Yes/No: "
    read -r "confirm_selected_email_input"
    confirm_selected_email_input="$(printf "%s" "$confirm_selected_email_input" | tr '[:upper:]' '[:lower:]')"
    if
      [[ "$confirm_selected_email_input" == "yes" ]] ||
      [[ "$confirm_selected_email_input" == "y" ]]
    then
      selected_email_input_confirmed="true"
      break 2
    elif
      [[ "$confirm_selected_email_input" == "no" ]] ||
      [[ "$confirm_selected_email_input" == "n" ]]
    then
      selected_email_input_confirmed="false"
      email_valid="false"
      break 1
    fi
  done
done
# Gather all associated usernames
if
  [[ -n "$public_events_data" ]]
then
  remote_username_list="$(printf "%s" "$public_events_data" | awk -F '"' '/"author":/,/},/{if ($0 ~ /"name":/) print $4}' | sort -u)"
  local_username_list="$(git -C "$HOME/.github/$repo_name.git" log --all --format='%aN' | sort -u)"
  global_username="$(git -C "$HOME/.github/$repo_name.git" config --global user.name)"
  local_repo_username="$(git -C "$HOME/.github/$repo_name.git" config --local user.name)"
  usernames_list_gathered="true"
fi
# Number each username found with a number
if
  [[ "$usernames_list_gathered" == "true" ]]
then
  declare -A username_numbers
  username_count=1
  for username in $remote_username_list
  do
    if
      [[ ! -v username_numbers["$username"] ]]
    then
      username_numbers["$username"]=$username_count
      ((username_count++))
    fi
  done
  for username in $local_username_list
  do
    if
      [[ ! -v username_numbers["$username"] ]]
    then
      username_numbers["$username"]=$username_count
      ((username_count++))
    fi
  done
  if
    [[ -n "$global_username" ]]
  then
    if
      [[ ! -v username_numbers["$global_username"] ]]
    then
      username_numbers["$global_username"]=$username_count
      ((username_count++))
    fi
  fi
  if
    [[ -n "$local_repo_username" ]]
  then
    if
      [[ ! -v username_numbers["$local_repo_username"] ]]
    then
      username_numbers["$local_repo_username"]=$username_count
      ((username_count++))
    fi
  fi
  username_list_numbered="true"
fi
# Display each username found with the number
if
  [[ "$username_list_numbered" == "true" ]]
then
  printf "Usernames publicly associated with \"$git_username\": \n"
  for username in $remote_username_list
  do
    printf " %s. %s\n" "${username_numbers[$username]}" "$username"
  done
  printf "Usernames locally associated with \"$repo_name.git\": \n"
  for username in $local_username_list
  do
    printf " %s. %s\n" "${username_numbers[$username]}" "$username"
  done
  if
    [[ -n "$global_username" ]]
  then
    printf "Username globally defined for Git operations: \n"
    printf " %s. %s\n" "${username_numbers[$global_username]}" "$global_username"
  else
    printf "Username to globally use for Git operations is not configured. \n"
  fi
  if
    [[ -n "$local_repo_username" ]]
  then
    printf "Username currently assigned to \"$repo_name\": \n"
    printf " %s. %s\n" "${username_numbers[$local_repo_username]}" "$local_repo_username"
  else
    printf "Username assigned to \"$repo_name\" is not configured. \n"
  fi
fi
# Determine what the default username should be for preloaded text
if
  [[ -n "$local_repo_username" ]]
then
  default_username="$local_repo_username"
elif
  [[ -n "$global_username" ]]
then
  default_username="$global_username"
elif
  [[ -z "$local_repo_username" ]] &&
  [[ -z "$global_username" ]]
then
  unconfigured_username="unconfigured"
  default_username="$unconfigured_username"
  not_configured_username="true"
fi
# Prompt the user to select a valid username
while
  [[ -z "$selected_username_input_confirmed" ]] ||
  [[ "$selected_username_input_confirmed" == "false" ]]
do
  while
    [[ -z "$username_valid" ]] ||
    [[ "$username_valid" == "false" ]]
  do
    if
      [[ -z "$enter_username_shown" ]]
    then
      printf "Enter a corresponding number or a custom username to assign to \"$repo_name\": \n"
      enter_username_shown="true"
    fi
    read -r -e -i "$default_username" "selected_username_input"
    if
      [[ "$selected_username_input" =~ ^[0-9]+$ ]]
    then
      if
        [[ "${username_numbers[@]}" =~ (^|[[:space:]])"$selected_username_input"($|[[:space:]]) ]]
      then
        for username in "${!username_numbers[@]}"
        do
          if
            [[ "${username_numbers[$username]}" == "$selected_username_input" ]]
          then
            selected_username="$username"
            printf "%s\n" "$selected_username"
            username_valid="true"
          fi
        done
      else
        printf "Selected number is invalid.\n"
        username_valid="false"
      fi
    elif
      [[ "$selected_username_input" =~ ^[a-zA-Z0-9-]+$ ]] &&
      [[ "${#selected_username_input}" -ge 1 ]] &&
      [[ "${#selected_username_input}" -le 39 ]]
    then
      selected_username="$selected_username_input"
      username_valid="true"
    else
      if
        [[ "${#selected_username_input}" -ge 39 ]]
      then
        printf "Username can not be more than 39 characters. \n"
        username_valid="false"
      elif
        [[ "${#selected_username_input}" -le 1 ]]
      then
        printf "Username can not be less than 1 character. \n"
        username_valid="false"
      elif
        [[ ! "$selected_username_input" =~ ^[a-zA-Z0-9-]+$ ]]
      then
        printf "Username can only include characters \"a-z\", \"A-Z\", \"0-9\", \"hyphen(-)\". \n"
        username_valid="false"
      fi
    fi
    selected_username_input_confirmed=""
    while
      [[ "$username_valid" == "true" ]] &&
      [[ -z "$selected_username_input_confirmed" ]] 
    do
      printf "Is this correct? Yes/No: "
      read -r "confirm_selected_username_input"
      confirm_selected_username_input="$(printf "%s" "$confirm_selected_username_input" | tr '[:upper:]' '[:lower:]')"
      if
        [[ "$confirm_selected_username_input" == "yes" ]] ||
        [[ "$confirm_selected_username_input" == "y" ]]
      then
        selected_username_input_confirmed="true"
      elif
        [[ "$confirm_selected_username_input" == "no" ]] ||
        [[ "$confirm_selected_username_input" == "n" ]]
      then
        selected_username_input_confirmed="false"
        username_valid="false"
      fi
    done
  done
done
# Set useConfigOnly for local repository
while
  [[ -z "$use_user_conf_only" ]]
do
  user_conf_only="$(git -C "$HOME/.github/$repo_name.git" config --local user.useConfigOnly)"
  if
    [[ -z "$user_conf_only" ]] ||
    [[ "$user_conf_only" == "false" ]] ||
    [[ "$user_conf_only" == "False" ]]
  then
    git -C "$HOME/.github/$repo_name.git" config --local user.useConfigOnly true
    if
      user_conf_only="$(git -C "$HOME/.github/$repo_name.git" config --local user.useConfigOnly)"
    then
      printf "useConfigOnly for \"$repo_name\" set to: \"$user_conf_only\". \n"
      use_user_conf_only="true"
    fi
  else
    printf "useConfigOnly for \"$repo_name\" is already set to \"$user_conf_only\". \n"
    use_user_conf_only="true"
  fi
done
# Check to see if the selections are different from the one already set and change them if so
if
  [[ "$local_repo_username" = "$selected_username" ]]
then
  printf "Local repository username is already \"$selected_username\". \n"
  local_repo_username_unchanged="true"
else
  printf "Local repository username is different from \"$selected_username\". \n"
  git -C "$HOME/.github/$repo_name.git" config --local user.name "$selected_username"
fi
if
  [[ "$local_repo_email" = "$selected_email" ]]
then
  printf "Local repository email is already \"$selected_email\". \n"
  local_repo_email_unchanged="true"
else
  printf "Local repository email is different from \"$selected_email\". \n"
  git -C "$HOME/.github/$repo_name.git" config --local user.email "$selected_email"
fi
# Tell the user the repository was updated with the new changes
if
  [[ -z "$local_repo_username_unchanged" ]] &&
  [[ "$(git -C "$HOME/.github/$repo_name.git" config --local user.name)" == "$selected_username" ]]
then
  printf "\"$selected_username\" configured with \"$repo_name\"\n"
fi
if
  [[ -z "$local_repo_email_unchanged" ]] &&
  [[ "$(git -C "$HOME/.github/$repo_name.git" config --local user.email)" == "$selected_email" ]]
then
  printf "\"$selected_email\" configured with \"$repo_name\"\n"
fi
# Request the user to create a custom Git commit message
if
  [[ "$repo_git_added_all" == "true" ]]
then
  commit_message_template="$(git config --global --get-all commit.template)"
  if
    [[ -f "$HOME/.github/$repo_name.git/.git/COMMIT_EDITMSG" ]]
  then
    existing_commit_message="$(head -n 1 "$HOME/.github/$repo_name.git/.git/COMMIT_EDITMSG")"
    default_commit_message="$existing_commit_message"
  elif
    [[ -n "$commit_message_template" ]]
  then
    default_commit_message="$commit_message_template"
  else
    default_commit_message="Initial commit"
  fi
  while
    [[ -z "$commit_message_commited" ]]
  do
    if
      [[ -z "$edit_commit_message_shown" ]]
      [[ -z "$commit_message" ]] || 
      [[ -n "$commit_message" ]]
    then
      printf "Edit the commit message. 50 characters max.\n"
      edit_commit_message_shown="true"
      if
        [[ -n "$commit_message" ]]
      then
        default_commit_message="$commit_message"
      fi
      read -r -e -i "$default_commit_message" "commit_message"
      if
        (( "${#commit_message}" >= "1" )) &&
        (( "${#commit_message}" <= "50" ))
      then
        commit_message_commited="true"
      else
        printf "Commit message must be between 1 and 50 characters.\n"
      fi
    fi
  done
fi
# Index files from staging to be ready for commit to GitHub
if
  [[ "$repo_git_added_all" == "true" ]] &&
  [[ "$commit_message_commited" == "true" ]]
then
  if
    ! git -C "$HOME/.github/$repo_name.git" commit --author "$selected_username <$selected_email>" -m "$commit_message" | grep "changed"
  then
    printf "There was nothing to commit that wasn't already committed.\n"
  fi
  repo_git_commited_all="true"
fi
# Check to see if repository exists already on GitHub
if
  [[ "$repo_git_commited_all" == "true" ]]
then
  git_repo_url="https://github.com/$git_username/$repo_name"
  if
    check_connection
  then
    if
      gh repo view "$git_username/$repo_name" --json name &> /dev/null
    then
      printf "Repository already exists at: \"$git_repo_url\"\n"
      git_repo_exists="true"
    else
      printf "Repository doesn't exist at: \"$git_repo_url\".\n"
      git_repo_exists="false"
    fi
  fi
fi
# Create a remote repository
if
  [[ "$repo_git_commited_all" == "true" ]] &&
  [[ "$git_repo_exists" == "false" ]]
then
  while
    [[ -z "$git_repo_created" ]]
  do
    printf "Attempting to create a new repository on GitHub.\n"
    if
      git -C "$HOME/.github/$repo_name.git" remote | grep "origin" &> /dev/null
    then
      printf "Removing existing remote origin references.\n"
      git -C "$HOME/.github/$repo_name.git" remote remove origin &> /dev/null
    fi
    if
      check_connection
    then
      if
        gh repo create "$repo_name" --source "$HOME/.github/$repo_name.git" --public &> /dev/null
      then
        printf "GitHub repository successfully created at: \"$git_repo_url\".\n"
        git_repo_created="true"
      else
        printf "GitHub repository creation failed at: \"$git_repo_url\".\n"
      fi
    fi
  done
fi
#
#
#
#
# Creating a description for your repository
while
  [[ -z "$confirm_edited_description" ]] ||
  [[ "$confirm_edited_description" == "false" ]]
do
  if
    [[ "$git_repo_created" == "true" ]] ||
    [[ "$git_repo_exists" == "true" ]]
  then
    default_description="No description, website, or topics provided."
    if
      [[ -z "$edited_description_empty" ]]
    then
      if
        check_connection
      then
        existing_description="$(gh repo view "$git_username/$repo_name" --json "description" | awk -F '"' '{print $4}')"
      fi
      if
        [[ -z "$existing_description" ]]
      then
        current_description="$default_description"
      elif
        [[ -n "$existing_description" ]]
      then
        current_description="$existing_description"
      fi
    fi
    printf "Edit the repository description, 350 characters max: \n"
    read -r -e -i "$current_description" "edited_description"
    if
      [[ -z "$edited_description" ]]
    then
      printf "\nRepository description can not be empty, setting it to default.\n"
      current_description="$default_description"
      edited_description_empty="true"
    elif
      (( "${#edited_description}" >= "350" ))
    then
      printf "Repository description can not be more than 350 characters.\n"
    else
      if
        [[ "$edited_description" == "$default_description" ]]
      then
        edited_description=" "
      fi
      while
        true
      do
        printf "Is this correct? Yes/No: "
        read -r "confirm_edited_description"
        confirm_edited_description="$(printf "%s" "$confirm_edited_description" | tr '[:upper:]' '[:lower:]')"
        if
          [[ "$confirm_edited_description" == "yes" ]] ||
          [[ "$confirm_edited_description" == "y" ]]
        then
          confirm_edited_description="true"
          break 2
        elif
          [[ "$confirm_edited_description" == "no" ]] ||
          [[ "$confirm_edited_description" == "n" ]]
        then
          confirm_edited_description="false"
          break 1
        fi
      done
    fi
  fi
done
# Check to see if the new description is different from the old one
if
  [[ "$confirm_edited_description" == "true" ]] &&
  [[ "$edited_description" != "$existing_description" ]]
then
  edited_description_differs="true"
fi
# Push the new description to GitHub if it's different from the default
if
  [[ "$edited_description_differs" == "true" ]]
then
  if
    [[ -n "$edited_description" ]]
  then
    while
      [[ -z "$description_uploaded" ]]
    do
      if
        check_connection
      then
        if
          gh repo edit "$git_username/$repo_name" --description "$edited_description" &> /dev/null
        then
          printf "Description successfully updated.\n"
          description_uploaded="true"
        fi
      fi
    done
  fi
fi
#
#
#
#
# Check to see what the current commit hash is
if
  [[ "$git_repo_created" == "true" ]] ||
  [[ "$git_repo_exists" == "true" ]] &&
  [[ "$confirm_edited_description" == "true" ]]
then
  printf "Checking GitHub for the latest commit hash.\n"
  previous_commit="$(git -C "$HOME/.github/$repo_name.git" rev-parse origin/master)"
  before_commit_check="true"
fi
# Forcefully push all local files to remote repository
if
  [[ "$before_commit_check" == "true" ]]
then
  printf "Pushing changes to GitHub.\n"
  if
    check_connection
  then
    if
      git -C "$HOME/.github/$repo_name.git" push -f --set-upstream "$git_repo_url" master &> /dev/null
    then
      printf "Pushed \"$filename\" to \"$git_repo_url\".\n"
      git_repo_pushed="true"
    fi
  fi
fi
# Check to see what the latest commit hash is
if
  [[ "$git_repo_pushed" == "true" ]]
then
  printf "Checking GitHub for the latest commit hash.\n"
  latest_commit="$(git -C "$HOME/.github/$repo_name.git" rev-parse HEAD)"
  after_commit_check="true"
fi
# Comparing the old hash vs the new hash
if
  [[ "$previous_commit" != "$latest_commit" ]]
then
  printf "\"$filename\" successfully pushed to GitHub at: \"$git_repo_url\".\n"
else
  printf "No new commits detected. \"$filename\" may not have been pushed.\n"
fi
