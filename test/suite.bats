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

  run diff -q "${DOCKERFILES_ALLINONE}/assets/docker-entrypoint.sh" "${DOCKERFILES_ADMINWORKER}/assets/docker-entrypoint.sh"
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

@test "all Dockerfiles should be the same" {
  allinone=$(grep -v 'OPENCAST_DISTRIBUTION="' "${DOCKERFILES_ALLINONE}/Dockerfile")
  admin=$(grep -v 'OPENCAST_DISTRIBUTION="' "${DOCKERFILES_ADMIN}/Dockerfile")
  adminworker=$(grep -v 'OPENCAST_DISTRIBUTION="' "${DOCKERFILES_ADMINWORKER}/Dockerfile")
  ingest=$(grep -v 'OPENCAST_DISTRIBUTION="' "${DOCKERFILES_INGEST}/Dockerfile")
  presentation=$(grep -v 'OPENCAST_DISTRIBUTION="' "${DOCKERFILES_PRESENTATION}/Dockerfile")
  worker=$(grep -v 'OPENCAST_DISTRIBUTION="' "${DOCKERFILES_WORKER}/Dockerfile")

  run test "${allinone}" = "${admin}"
  [ "${status}" -eq 0 ]

  run test "${allinone}" = "${adminworker}"
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

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_ADMINWORKER}/assets/scripts"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_INGEST}/assets/scripts"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_PRESENTATION}/assets/scripts"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_WORKER}/assets/scripts"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_BUILD}/assets/build/scripts/"
  [ "${status}" -eq 0 ]
}

@test "build image should have the same distribution assets" {
  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/allinone" "${DOCKERFILES_ALLINONE}/assets/etc"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/admin" "${DOCKERFILES_ADMIN}/assets/etc"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/adminworker" "${DOCKERFILES_ADMINWORKER}/assets/etc"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/ingest" "${DOCKERFILES_INGEST}/assets/etc"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/presentation" "${DOCKERFILES_PRESENTATION}/assets/etc"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_BUILD}/assets/build/etc/worker" "${DOCKERFILES_WORKER}/assets/etc"
  [ "${status}" -eq 0 ]
}
