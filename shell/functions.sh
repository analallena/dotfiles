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
  selected_profile=$(echo ${profiles[@]} | tr ' ' '\n' | gum choose ${default_option})

  [[ -z "${selected_profile}" ]] && return 1 || export AWS_PROFILE=${selected_profile}

  if [ ${?} -eq 0 ]; then
    aws sts get-caller-identity --query "Account" >& /dev/null
    if [ ${?} -eq 0 ];  then
      aws configure list
    else
      aws sso login && aws configure list
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
  git checkout main
  git branch -d $branch
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
