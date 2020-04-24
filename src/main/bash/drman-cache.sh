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

function ___drman_check_candidates_cache() {
	local candidates_cache="$1"
	if [[ -f "$candidates_cache" && -n "$(cat "$candidates_cache")" && -n "$(find "$candidates_cache" -mmin +$((24 * 60 * 30)))" ]]; then
		__drman_echo_yellow 'We periodically need to update the local cache. Please run:'
		echo ''
		__drman_echo_no_colour '  $ drm  update'
		echo ''
		return 0
	elif [[ -f "$candidates_cache" && -z "$(cat "$candidates_cache")" ]]; then
		__drman_echo_red 'WARNING: Cache is corrupt. DRMAN cannot be used until updated.'
		echo ''
		__drman_echo_no_colour '  $ drm  update'
		echo ''
		return 1
	else
		__drman_echo_debug "No update at this time. Using existing cache: $DRMAN_CANDIDATES_CSV"
		return 0
	fi
}

function ___drman_check_version_cache() {
	local version_url
	local version_file="${DRMAN_DIR}/var/version"

	if [[ "$drman_beta_channel" != "true" && -f "$version_file" && -z "$(find "$version_file" -mmin +$((60 * 24)))" ]]; then
		__drman_echo_debug "Not refreshing version cache now..."
		DRMAN_REMOTE_VERSION=$(cat "$version_file")
	else
		__drman_echo_debug "Version cache needs updating..."
		if [[ "$drman_beta_channel" == "true" ]]; then
			__drman_echo_debug "Refreshing version cache with BETA version."
			version_url="${DRMAN_CANDIDATES_API}/broker/download/drman/version/beta"
		else
			__drman_echo_debug "Refreshing version cache with STABLE version."
			version_url="${DRMAN_CANDIDATES_API}/broker/download/drman/version/stable"
		fi

		DRMAN_REMOTE_VERSION=$(__drman_secure_curl_with_timeouts "$version_url")
		if [[ -z "$DRMAN_REMOTE_VERSION" || -n "$(echo "$DRMAN_REMOTE_VERSION" | tr '[:upper:]' '[:lower:]' | grep 'html')" ]]; then
			__drman_echo_debug "Version information corrupt or empty! Ignoring: $DRMAN_REMOTE_VERSION"
			DRMAN_REMOTE_VERSION="$DRMAN_VERSION"
		else
			__drman_echo_debug "Overwriting version cache with: $DRMAN_REMOTE_VERSION"
			echo "${DRMAN_REMOTE_VERSION}" | tee "$version_file" > /dev/null
		fi
	fi
}
