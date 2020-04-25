#!/usr/bin/env bash

#
#   Copyright 2020 the original author or authors.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# set env vars if not set

if [ -z "$DRMAN_NAMESPACE" ]; then
	export DRMAN_NAMESPACE="DIDman"
fi

if [ -z "$DRMAN_CANDIDATE_BRANCH" ]; then
	export DRMAN_CANDIDATE_BRANCH="candidate"
fi

if [ -z "$DRMAN_CANDIDATE_REPO_VERSION" ]; then
	export DRMAN_CANDIDATE_REPO_VERSION="0"
fi