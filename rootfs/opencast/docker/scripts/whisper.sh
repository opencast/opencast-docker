#!/bin/sh
#
# Copyright 2016 The University of Münster eLectures Team All rights reserved.
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

WHISPER_CPP_DOWNLOAD_GGML_MODEL="${WHISPER_CPP_DOWNLOAD_GGML_MODEL:-}"
WHISPER_CPP_DOWNLOAD_VAD_MODEL="${WHISPER_CPP_DOWNLOAD_VAD_MODEL:-}"

opencast_whisper_init() {
  echo "Run opencast_whisper_init"

  if [ -n "${WHISPER_CPP_DOWNLOAD_GGML_MODEL}" ]; then
    opencast_whisper_cpp_download_ggml_model "$WHISPER_CPP_DOWNLOAD_GGML_MODEL" &
  fi
  if [ -n "${WHISPER_CPP_DOWNLOAD_VAD_MODEL}" ]; then
    opencast_whisper_cpp_download_vad_model "$WHISPER_CPP_DOWNLOAD_VAD_MODEL" &
  fi
}

opencast_whisper_cpp_download_ggml_model() {
  model=$1
  echo "Run opencast_whisper_cpp_download_ggml_model '$model'"

  set +e
  out=$(whisper-ggml-model-download "$model" 2>&1)
  ec=$?
  set -e
  if [ $ec -ne 0 ]; then
    echo "Failed opencast_whisper_cpp_download_ggml_model '$model':"
    printf "%s\n" "$out"
    return $ec
  fi

  echo "Finished opencast_whisper_cpp_download_ggml_model '$model'"
}

opencast_whisper_cpp_download_vad_model() {
  model=$1
  echo "Run opencast_whisper_cpp_download_vad_model '$model'"

  set +e
  out=$(whisper-download-vad-model "$model" 2>&1)
  ec=$?
  set -e
  if [ $ec -ne 0 ]; then
    echo "Failed opencast_whisper_cpp_download_vad_model '$model':"
    printf "%s\n" "$out"
    return $ec
  fi

  echo "Finished opencast_whisper_cpp_download_vad_model '$model'"
}
