#!/usr/bin/env bats

load test_helper

@test "all scripts should be the same" {
  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_ADMIN}/assets/scripts"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_PRESENTATION}/assets/scripts"
  [ "${status}" -eq 0 ]

  run diff -qr "${DOCKERFILES_ALLINONE}/assets/scripts" "${DOCKERFILES_WORKER}/assets/scripts"
  [ "${status}" -eq 0 ]
}
