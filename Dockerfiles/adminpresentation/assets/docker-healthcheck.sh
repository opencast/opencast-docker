#!/bin/sh
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

OPENCAST_API="http://127.0.0.1:8080"
DIGEST_USER=$(awk -F "=" '/org\.opencastproject\.security\.digest\.user/ {print $2}' "${OPENCAST_CONFIG}/custom.properties" | tr -d ' ')
DIGEST_PASSWORD=$(awk -F "=" '/org\.opencastproject\.security\.digest\.pass/ {print $2}' "${OPENCAST_CONFIG}/custom.properties" | tr -d ' ')

for ENDPOINT in "services/health" "broker/status"; do
  HTTP_CODE=$(curl \
    -sw '%{http_code}' \
    -o /dev/null \
    --digest \
    -u "${DIGEST_USER}:${DIGEST_PASSWORD}" \
    -H 'X-Requested-Auth: Digest' \
    -H 'X-Opencast-Matterhorn-Authorization: true' \
    --max-time 5 \
    "${OPENCAST_API}/${ENDPOINT}" \
  )

  [                     $? ] || exit 1
  [ "${HTTP_CODE}" -ge 200 ] && \
  [ "${HTTP_CODE}" -lt 300 ] || exit 1
done

exit 0
