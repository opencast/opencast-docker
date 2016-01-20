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

ORG_OPENCASTPROJECT_ADMIN_EMAIL="${ORG_OPENCASTPROJECT_ADMIN_EMAIL:-admin@localhost}"

if Opencast::Helper::Dist::allinone; then
  ORG_OPENCASTPROJECT_FILE_REPO_URL='${org.opencastproject.server.url}'
else
  ORG_OPENCASTPROJECT_FILE_REPO_URL='${org.opencastproject.admin.ui.url}'
fi

Opencast::Opencast::Check() {
  echo "Run Opencast::Opencast::Check"
  Opencast::Helper::CheckForVariables \
    "ORG_OPENCASTPROJECT_SERVER_URL" \
    "ORG_OPENCASTPROJECT_SECURITY_ADMIN_USER" \
    "ORG_OPENCASTPROJECT_SECURITY_ADMIN_PASS" \
    "ORG_OPENCASTPROJECT_SECURITY_DIGEST_USER" \
    "ORG_OPENCASTPROJECT_SECURITY_DIGEST_PASS" \
    "ORG_OPENCASTPROJECT_FILE_REPO_URL"

  if ! Opencast::Helper::Dist::allinone; then
    Opencast::Helper::CheckForVariables \
      "PROP_ORG_OPENCASTPROJECT_ADMIN_UI_URL" \
      "PROP_ORG_OPENCASTPROJECT_ENGAGE_UI_URL"
  fi
}

Opencast::Opencast::Configure() {
  echo "Run Opencast::Opencast::Configure"
  Opencast::Helper::ReplaceInfile "etc/custom.properties" \
    "ORG_OPENCASTPROJECT_ADMIN_EMAIL" \
    "ORG_OPENCASTPROJECT_SERVER_URL" \
    "ORG_OPENCASTPROJECT_SECURITY_ADMIN_USER" \
    "ORG_OPENCASTPROJECT_SECURITY_ADMIN_PASS" \
    "ORG_OPENCASTPROJECT_SECURITY_DIGEST_USER" \
    "ORG_OPENCASTPROJECT_SECURITY_DIGEST_PASS" \
    "ORG_OPENCASTPROJECT_FILE_REPO_URL"

  if ! Opencast::Helper::Dist::allinone; then
    Opencast::Helper::ReplaceInfile "etc/org.opencastproject.organization-mh_default_org.cfg" \
      "PROP_ORG_OPENCASTPROJECT_ADMIN_UI_URL" \
      "PROP_ORG_OPENCASTPROJECT_ENGAGE_UI_URL"
  fi
}
