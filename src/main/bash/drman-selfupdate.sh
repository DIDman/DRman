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

function __drm_selfupdate() {
	local force_selfupdate

	force_selfupdate="$1"
	if [[ "$DRMAN_AVAILABLE" == "false" ]]; then
		echo "This command is not available while offline."
	elif [[ "$DRMAN_REMOTE_VERSION" == "$DRMAN_VERSION" && "$force_selfupdate" != "force" ]]; then
		echo "No update available at this time."
	else
		export drman_debug_mode
		export drman_beta_channel
		__drman_secure_curl "${DRMAN_CANDIDATES_API}/selfupdate?beta=${drman_beta_channel}" | bash
	fi

	unset DRMAN_FORCE_SELFUPDATE
}

function __drman_auto_update() {
	local remote_version version delay_upgrade

	remote_version="$1"
	version="$2"
	delay_upgrade="${DRMAN_DIR}/var/delay_upgrade"

	if [[ -n "$(find "$delay_upgrade" -mtime +1)" && "$remote_version" != "$version" ]]; then
		echo ""
		echo ""
		__drman_echo_yellow "ATTENTION: A new version of DRMAN is available..."
		echo ""
		__drman_echo_no_colour "The current version is $remote_version, but you have $version."
		echo ""

		if [[ "$drman_auto_selfupdate" != "true" ]]; then
			__drman_echo_confirm "Would you like to upgrade now? (Y/n): "
			read upgrade
		fi

		if [[ -z "$upgrade" ]]; then
			upgrade="Y"
		fi

		if [[ "$upgrade" == "Y" || "$upgrade" == "y" ]]; then
			__drm_selfupdate
			unset upgrade
		else
			__drman_echo_no_colour "Not upgrading today..."
		fi

		touch "$delay_upgrade"
	fi
}
