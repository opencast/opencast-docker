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

source "${OPENCAST_SCRIPTS}/helper.sh"
source "${OPENCAST_SCRIPTS}/opencast.sh"
source "${OPENCAST_SCRIPTS}/activemq.sh"
source "${OPENCAST_SCRIPTS}/db.sh"
source "${OPENCAST_SCRIPTS}/hsql.sh"
source "${OPENCAST_SCRIPTS}/jdbc.sh"
source "${OPENCAST_SCRIPTS}/mysql.sh"

Opencast::Main::Check() {
  echo "Run Opencast::Main::Check"

  Opencast::Opencast::Check
  Opencast::ActiveMQ::Check
  Opencast::DB::Check
}

Opencast::Main::Configure() {
  echo "Run Opencast::Main::Configure"

  Opencast::Opencast::Configure
  Opencast::ActiveMQ::Configure
  Opencast::DB::Configure
}

Opencast::Main::Init() {
  echo "Run Opencast::Main::Init"

  if Opencast::Helper::CustomConfig; then
    echo "Found custom config in ${OPENCAST_CUSTOM_CONFIG}"
    echo "Run Opencast::Helper::CopyCustomConfig"
    Opencast::Helper::CopyCustomConfig
  else
    echo "No custom config found"
    Opencast::Main::Check
    Opencast::Main::Configure
  fi
}

Opencast::Main::Start() {
  echo "Run Opencast::Main::Start"
  exec "bin/start-opencast" "server"
}

case ${1} in
  app:init)
    Opencast::Main::Init
    ;;
  app:start)
    Opencast::Main::Init
    Opencast::Main::Start
    ;;
  app:print:activemq.xml)
    Opencast::ActiveMQ::PrintActivemq.xml
    ;;
  app:print:dll)
    Opencast::DB::PrintDDL
    ;;
  app:help)
    echo "Usage:"
    echo "  app:help                Prints the usage information"
    echo "  app:print:dll           Prints SQL commands to set up the database"
    echo "  app:print:activemq.xml  Prints the configuration for ActiveMQ"
    echo "  app:init                Checks and configures Opencast but does not run it"
    echo "  app:start               Starts Opencast"
    echo "  [cmd] [args...]         Runs [cmd] with given arguments"
    ;;
  *)
    exec "$@"
    ;;
esac
