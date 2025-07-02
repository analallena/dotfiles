#!/usr/bin/env bash

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}

function awp() {
  RED='\033[0;31m'
  NC='\033[0m' # No Color

  declare -a profiles
  output=$(aws configure list-profiles | sort)
  profiles=(${output})

  default_option=""
  test -n "${AWS_PROFILE}" && default_option="--selected ${AWS_PROFILE}"
  selected_profile=$(echo ${profiles[@]} | tr ' ' '\n' | gum choose --ordered --select-if-one --height 15 ${default_option} --header "AWS profiles (${#profiles[@]})")

  [[ -z "${selected_profile}" ]] && return 1 || export AWS_PROFILE=${selected_profile}

  if [ ${?} -eq 0 ]; then
    # Check if we already loged in
    aws_account_id=$(aws sts get-caller-identity --query "Account" --output text 2> /dev/null)
    if [ ${?} -ne 0 ];  then
      aws sso login
      if [ ${?} -ne 0 ];  then
        exit ${?}
      fi
      aws_account_id=$(aws sts get-caller-identity --query "Account" --output text 2> /dev/null)
    fi
    echo "\"${AWS_PROFILE}\",\"${aws_account_id}\"" | gum table --print --columns "Profile,Account"
    if [[ "${1}" == "-d" ]]; then
      aws configure list
    fi
  else
    exit ${?}
  fi
}

function commitandpush() {
  git pull
  echo "Message $1"
  message=$1
  branch=${message%)*}
  branch=${branch//(//}

  echo "Branch $branch"
  git checkout -b $branch

  if [ $# -eq 2 ]; then
    git commit -m "$1" -m "$2"
  else
    git commit -m "$1"
  fi

  git push -u origin HEAD

  gh pr create --title "My New Feature" --body "This PR introduces a new feature that does X." --label "enhancement" --base main
}

function createterraformmodule() {
  mkdir -p modules/$1
  cd modules/$1
  touch README.md
  touch main.tf
  touch variables.tf
  touch outputs.tf
  cd ../..
  git add .
  git commit -m "Add $1 terraform module scheleton"
  git push
}

pullmain()
{
  cd $1
  git stash
  git checkout main
  git pull
  cd ..
}

function pullall()
{
  folders=*/

  for folder in $folders
  do
  	if [ -f $folder/.git/config ]; then
  	  echo "Updating $folder"
  		pullmain $folder
  	fi
  done
}

function deletebranches()
{
   git branch
}

function createSSHKey() {
  ssh-keygen -t rsa -b 2048 -f "$1"
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
  pbcopy < ~/.ssh/id_rsa.pub
  echo "Public key copied to clipboard"
}
