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
if [ -z "$DRMAN_VERSION" ]; then
	export DRMAN_VERSION="@DRMAN_VERSION@"
fi

if [ -z "$DRMAN_NAMESPACE" ]; then
	export DRMAN_NAMESPACE="@DRMAN_NAMESPACE@"
fi

if [ -z "$DRMAN_CANDIDATE_BRANCH" ]; then
	export DRMAN_CANDIDATE_BRANCH="@DRMAN_CANDIDATE_BRANCH@"
fi

if [ -z "$DRMAN_CANDIDATE_REPO_VERSION" ]; then
	export DRMAN_CANDIDATE_REPO_VERSION="@DRMAN_CANDIDATE_REPO_VERSION@"
fi


if [ -z "$DRMAN_CANDIDATES_API" ]; then
	export DRMAN_CANDIDATES_API="@DRMAN_CANDIDATES_API@"
fi

if [ -z "$DRMAN_DIR" ]; then
	export DRMAN_DIR="$HOME/.drman"
fi

if [ -z "$DRMAN_PLUGINS_DIR" ]; then
	export DRMAN_PLUGINS_DIR="$DRMAN_DIR/plugins"
fi

# infer platform
DRMAN_PLATFORM="$(uname)"
if [[ "$DRMAN_PLATFORM" == 'Linux' ]]; then
	if [[ "$(uname -m)" == 'i686' ]]; then
		DRMAN_PLATFORM+='32'
	else
		DRMAN_PLATFORM+='64'
	fi
fi
export DRMAN_PLATFORM

# OS specific support (must be 'true' or 'false').
cygwin=false
darwin=false
solaris=false
freebsd=false
case "${DRMAN_PLATFORM}" in
	CYGWIN*)
		cygwin=true
		;;
	Darwin*)
		darwin=true
		;;
	SunOS*)
		solaris=true
		;;
	FreeBSD*)
		freebsd=true
esac

# Determine shell
zsh_shell=false
bash_shell=false

if [[ -n "$ZSH_VERSION" ]]; then
	zsh_shell=true
else
	bash_shell=true
fi

# Source drman module scripts and extension files.
#
# Extension files are prefixed with 'drman-' and found in the ext/ folder.
# Use this if extensions are written with the functional approach and want
# to use functions in the main drman script. For more details, refer to
# <https://github.com/drman/drman-extensions>.
OLD_IFS="$IFS"
IFS=$'\n'
scripts=($(find "${DRMAN_DIR}/src" "${DRMAN_DIR}/ext" -type f -name 'drman-*'))
for f in "${scripts[@]}"; do
	source "$f"
done
IFS="$OLD_IFS"
unset scripts f

# Load the drman config if it exists.
if [ -f "${DRMAN_DIR}/etc/config" ]; then
	source "${DRMAN_DIR}/etc/config"
fi

# Create upgrade delay file if it doesn't exist
if [[ ! -f "${DRMAN_DIR}/var/delay_upgrade" ]]; then
	touch "${DRMAN_DIR}/var/delay_upgrade"
fi

# set curl connect-timeout and max-time
if [[ -z "$drman_curl_connect_timeout" ]]; then drman_curl_connect_timeout=7; fi
if [[ -z "$drman_curl_max_time" ]]; then drman_curl_max_time=10; fi

# set curl retry
if [[ -z "${drman_curl_retry}" ]]; then drman_curl_retry=0; fi

# set curl retry max time in seconds
if [[ -z "${drman_curl_retry_max_time}" ]]; then drman_curl_retry_max_time=60; fi

# set curl to continue downloading automatically
if [[ -z "${drman_curl_continue}" ]]; then drman_curl_continue=true; fi

# Read list of candidates and set array
DRMAN_CANDIDATES_CACHE="${DRMAN_DIR}/var/candidates"
DRMAN_CANDIDATES_CSV=$(<"$DRMAN_CANDIDATES_CACHE")
__drman_echo_debug "Setting candidates csv: $DRMAN_CANDIDATES_CSV"
if [[ "$zsh_shell" == 'true' ]]; then
	DRMAN_CANDIDATES=(${(s:,:)DRMAN_CANDIDATES_CSV})
else
	OLD_IFS="$IFS"
	IFS=","
	DRMAN_CANDIDATES=(${DRMAN_CANDIDATES_CSV})
	IFS="$OLD_IFS"
fi

export DRMAN_CANDIDATES_DIR="${DRMAN_DIR}/candidates"

for candidate_name in "${DRMAN_CANDIDATES[@]}"; do
	candidate_dir="${DRMAN_CANDIDATES_DIR}/${candidate_name}/current"
	if [[ -h "$candidate_dir" || -d "${candidate_dir}" ]]; then
		__drman_export_candidate_home "$candidate_name" "$candidate_dir"
		__drman_prepend_candidate_to_path "$candidate_dir"
	fi
done
unset OLD_IFS candidate_name candidate_dir
export PATH
