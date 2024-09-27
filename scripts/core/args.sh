#!/bin/user/env bash

args::total_is() {
  total_expected="${1}"
  arguments="${@:2}"

  total_arguments=0
  for argument in ${arguments[*]}; do
    total_arguments=$((total_arguments + 1))
  done

  [[ $total_arguments -eq $total_expected ]]
}

args::has_no_args() {
  args::total_is 0 "$@"
}

args::verify_jwt_http_auth() {
  if [ -z $JWT_AUTH_TOKEN ]; then
    echo "JWT_AUTH_TOKEN environment variable not set"
    exit 1
  fi
}

args::belongs_to() {
  local value="${1}"
  local array="${@:2}"
  [[ ${array[@]} =~ $value ]]
}
