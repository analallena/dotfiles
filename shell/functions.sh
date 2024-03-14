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
  echo "Message $1"
    message=$1
    branch=${message%)*}
    branch=${branch//(//}

    echo "Branch $branch"
    git checkout -b $branch
    git commit -m "$1"
    git push -u origin HEAD
    git checkout main
    git branch -d $branch
}
