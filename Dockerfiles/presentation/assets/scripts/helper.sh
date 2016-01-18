#!/bin/bash
set -e

Opencast::Helper::Dist::admin() {
  test "${OPENCAST_DISTRIBUTION}" = "admin"
}

Opencast::Helper::Dist::allinone() {
  test "${OPENCAST_DISTRIBUTION}" = "allinone"
}

Opencast::Helper::Dist::presentation() {
  test "${OPENCAST_DISTRIBUTION}" = "presentation"
}

Opencast::Helper::Dist::worker() {
  test "${OPENCAST_DISTRIBUTION}" = "worker"
}

Opencast::Helper::CustomConfig() {
  test -d "${OPENCAST_CUSTOM_CONFIG}"
}

Opencast::Helper::CopyCustomConfig() {
  rm -rf "${OPENCAST_CONFIG}"
  cp -r "${OPENCAST_CUSTOM_CONFIG}" "${OPENCAST_CONFIG}"
}

Opencast::Helper::CheckForVariables() {
  for var in "$@"; do
    if test -z "${!var}"; then
      echo >&2 "error: missing Opencast ${var} environment variables"
      echo >&2 "  Did you forget to -e ${var}=value ?"
      exit 1
    fi
  done
}

# Replaces {{$2...}} with $!2... in file $1
Opencast::Helper::ReplaceInfile() {
  local file="$1"
  shift
  for var in "$@"; do
    sed -ri "s|[{]{2}${var}[}]{2}|${!var}|g" "${file}"
  done
}

# Deletes lines containing {{$2...}} in file $1
Opencast::Helper::DeleteInfile() {
  local file="$1"
  shift
  for var in "$@"; do
    sed -ri "/[{]{2}${var}[}]{2}/d" "${file}"
  done
}
