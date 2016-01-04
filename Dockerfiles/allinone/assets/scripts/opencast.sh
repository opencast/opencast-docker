#!/bin/bash
set -e

ORG_OPENCASTPROJECT_ADMIN_EMAIL="${ORG_OPENCASTPROJECT_ADMIN_EMAIL:-admin@localhost}"

if Opencast::Helper::Dist::allinone; then
  ORG_OPENCASTPROJECT_FILE_REPO_URL='${org.opencastproject.server.url}'
else
  ORG_OPENCASTPROJECT_FILE_REPO_URL='${org.opencastproject.admin.ui.url}'
fi

Opencast::Opencast::Check() {
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
