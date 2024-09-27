#!/usr/bin/env bash

_region_in() {
  local region=${1}
  shift 1
  local valid_region=("$@")

  if [[ ! " ${valid_region[*]} " =~ " ${region} " ]]; then
    echo "<region> (${region}) must be in (${valid_region[*]})"
    exit 2
  fi
}

_environment_in() {
  local environment=${1}
  shift 1
  local valid_environments=("$@")

  if [[ ! " ${valid_environments[*]} " =~ " ${environment} " ]]; then
    echo "<environment> (${environment}) must be in (${valid_environments[*]})"
    exit 2
  fi
}

env::check_valid_region() {
  local region=${1}
  local allowed_regions=("region1 region2")
  _region_in "${region}" "${allowed_regions[@]}"
}

env::check_valid_environment() {
  local environment=${1}
  local allowed_environments=("local dev ppe prod")
  _environment_in "${environment}" "${allowed_environments[@]}"
}
