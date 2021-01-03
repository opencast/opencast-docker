#!/bin/bash
#
# Copyright 2018 The WWU eLectures Team All rights reserved.
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

set -o errexit
set -o pipefail

WAITING_TIME=30

fail() {
  >&2 echo "$@"
  exit 1
}

if [ "${DAY_OF_WEEK}" != "*" ]; then
  if [ "${DAY_OF_WEEK}" != $(date "+%w") ]; then
    echo "Not sheduled today; exit"
    exit
  else
    echo "Waiting ${WAITING_TIME}m for daily image builds"
    for i in $(seq "${WAITING_TIME}"); do
      sleep 60
      echo "."
    done
    echo
  fi
fi

# Get trigger ID
trigger_id=$(\
  curl -sLf "https://quay.io/api/v1/repository/opencast/${OPENCAST_DISTRIBUTION}/trigger" \
       -H "Authorization: Bearer ${QUAY_ACCESS_TOKEN}" \
    | jq -Mr ".triggers[0].id" 2> /dev/null
)
test "${trigger_id}" != "null" || fail "Repository has no triggers"

# Start trigger
curl -sLf -X "POST" "https://quay.io/api/v1/repository/opencast/${OPENCAST_DISTRIBUTION}/trigger/${trigger_id}/start" \
     -o /dev/null \
     -H "Authorization: Bearer ${QUAY_ACCESS_TOKEN}" \
     -H "Content-Type: application/json" \
     -d "{\"branch_name\": \"${OPENCAST_VERSION}\"}" > /dev/null 2>&1 || fail "Failed to start trigger"
echo "Started trigger"
