#!/usr/bin/env bats
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

load test_helper

@test "all entrypoints should be the same" {
  run diff -q "${DOCKERFILES_ALLINONE}/assets/docker-entrypoint.sh" "${DOCKERFILES_ADMIN}/assets/docker-entrypoint.sh"
  [ "${status}" -eq 0 ]

  run diff -q "${DOCKERFILES_ALLINONE}/assets/docker-entrypoint.sh" "${DOCKERFILES_ADMINPRESENTATION}/assets/docker-entrypoint.sh"
  [ "${status}" -eq 0 ]

  run diff -q "${DOCKERFILES_ALLINONE}/assets/docker-entrypoint.sh" "${DOCKERFILES_INGEST}/assets/docker-entrypoint.sh"
  [ "${status}" -eq 0 ]

  run diff -q "${DOCKERFILES_ALLINONE}/assets/docker-entrypoint.sh" "${DOCKERFILES_PRESENTATION}/assets/docker-entrypoint.sh"
  [ "${status}" -eq 0 ]

  run diff -q "${DOCKERFILES_ALLINONE}/assets/docker-entrypoint.sh" "${DOCKERFILES_WORKER}/assets/docker-entrypoint.sh"
  [ "${status}" -eq 0 ]

  run diff -q "${DOCKERFILES_ALLINONE}/assets/docker-entrypoint.sh" "${DOCKERFILES_BUILD}/assets/build/docker-entrypoint.sh"
  [ "${status}" -eq 0 ]
}

@test "all healthcheck scripts should be the same" {
  run diff -q "${DOCKERFILES_ALLINONE}/assets/docker-healthcheck.sh" "${DOCKERFILES_ADMIN}/assets/docker-healthcheck.sh"
  [ "${status}" -eq 0 ]

  run diff -q "${DOCKERFILES_ALLINONE}/assets/docker-healthcheck.sh" "${DOCKERFILES_ADMINPRESENTATION}/assets/docker-healthcheck.sh"
  [ "${status}" -eq 0 ]

  run diff -q "${DOCKERFILES_ALLINONE}/assets/docker-healthcheck.sh" "${DOCKERFILES_INGEST}/assets/docker-healthcheck.sh"
  [ "${status}" -eq 0 ]

  run diff -q "${DOCKERFILES_ALLINONE}/assets/docker-healthcheck.sh" "${DOCKERFILES_PRESENTATION}/assets/docker-healthcheck.sh"
  [ "${status}" -eq 0 ]

  run diff -q "${DOCKERFILES_ALLINONE}/assets/docker-healthcheck.sh" "${DOCKERFILES_WORKER}/assets/docker-healthcheck.sh"
  [ "${status}" -eq 0 ]
}

@test "all Dockerfiles should be the same" {
  allinone=$(grep -vE '(OPENCAST_DISTRIBUTION|org.label-schema)' "${DOCKERFILES_ALLINONE}/Dockerfile")
  admin=$(grep -vE '(OPENCAST_DISTRIBUTION|org.label-schema)' "${DOCKERFILES_ADMIN}/Dockerfile")
  adminpresentation=$(grep -vE '(OPENCAST_DISTRIBUTION|org.label-schema)' "${DOCKERFILES_ADMINPRESENTATION}/Dockerfile")
  ingest=$(grep -vE '(OPENCAST_DISTRIBUTION|org.label-schema)' "${DOCKERFILES_INGEST}/Dockerfile")
  presentation=$(grep -vE '(OPENCAST_DISTRIBUTION|org.label-schema)' "${DOCKERFILES_PRESENTATION}/Dockerfile")
  worker=$(grep -vE '(OPENCAST_DISTRIBUTION|org.label-schema)' "${DOCKERFILES_WORKER}/Dockerfile")

  run test "${allinone}" = "${admin}"
  [ "${status}" -eq 0 ]

  run test "${allinone}" = "${adminpresentation}"
  [ "${status}" -eq 0 ]

  run test "${allinone}" = "${ingest}"
  [ "${status}" -eq 0 ]

  run test "${allinone}" = "${presentation}"
  [ "${status}" -eq 0 ]

  run test "${allinone}" = "${worker}"
  [ "${status}" -eq 0 ]
}

@test "all scripts should be the same" {
  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_ADMIN}/assets/scripts"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_ADMINPRESENTATION}/assets/scripts"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_INGEST}/assets/scripts"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_PRESENTATION}/assets/scripts"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_WORKER}/assets/scripts"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_BUILD}/assets/build/scripts"
  [ "${status}" -eq 0 ]
}

@test "all support files should be the same" {
  run diff -qr "${DOCKERFILES_ALLINONE}/assets/support" "${DOCKERFILES_ADMIN}/assets/support"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/support" "${DOCKERFILES_ADMINPRESENTATION}/assets/support"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/support" "${DOCKERFILES_INGEST}/assets/support"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/support" "${DOCKERFILES_PRESENTATION}/assets/support"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/support" "${DOCKERFILES_WORKER}/assets/support"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/support" "${DOCKERFILES_BUILD}/assets/build/support"
  [ "${status}" -eq 0 ]
}

@test "build image should have the same distribution assets" {
  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/allinone" "${DOCKERFILES_BUILD}/assets/build/etc/develop" \
           -x org.ops4j.pax.logging.cfg
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/allinone" "${DOCKERFILES_ALLINONE}/assets/etc"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/admin" "${DOCKERFILES_ADMIN}/assets/etc"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/adminpresentation" "${DOCKERFILES_ADMINPRESENTATION}/assets/etc"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/ingest" "${DOCKERFILES_INGEST}/assets/etc"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/presentation" "${DOCKERFILES_PRESENTATION}/assets/etc"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/worker" "${DOCKERFILES_WORKER}/assets/etc"
  [ "${status}" -eq 0 ]
}
