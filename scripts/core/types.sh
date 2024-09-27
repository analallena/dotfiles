#!/usr/bin/env bash

types::is_int() {
  local -r input=${1}

  number_regex='^[0-9]+$'
  [[ ${input} =~ ${number_regex} ]] && echo "true" || echo "false"
}
