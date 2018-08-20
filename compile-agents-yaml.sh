#!/bin/bash -eu
#
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "# THIS FILE IS AUTO-GENERATED DO NOT EDIT" > agents.yaml

GLOBIGNORE="rbac-setup.yaml:agents.yaml"
for f in *.yaml; do
  cat $f
  echo -e "\n---"
done >> agents.yaml

echo "agents.yaml has been generated for you."

git add agents.yaml

