#!/bin/bash
#
# Copyright 2016 The WWU eLectures Team All rights reserved.
#
# Licensed under the Educational Community License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
#     http://opensource.org/licenses/ECL-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
