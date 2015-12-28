#!/bin/bash
set -e

Opencast::MySQL::PrintDDL() {
  cat /opencast/docs/scripts/ddl/mysql5.sql
}
