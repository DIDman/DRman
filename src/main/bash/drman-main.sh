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

function drm() {

	COMMAND="$1"
	QUALIFIER="$2"

	case "$COMMAND" in
	l)
		COMMAND="list"
		;;
	ls)
		COMMAND="list"
		;;
	v)
		COMMAND="version"
		;;
	u)
		COMMAND="use"
		;;
	i)
		COMMAND="install"
		;;
	rm)
		COMMAND="uninstall"
		;;
	c)
		COMMAND="current"
		;;
	ug)
		COMMAND="upgrade"
		;;
	d)
		COMMAND="default"
		;;
	b)
		COMMAND="broadcast"
		;;
	h)
		COMMAND="home"
		;;
	gvcr)
		COMMAND="githubVCR"
		;;
	vcr)
		COMMAND="vcr"
		;;
	did)
		COMMAND="did"
	;;
	esac

	if [[ "$COMMAND" == "home" ]]; then
		__drm_home "$QUALIFIER" "$3"
		return $?
	fi

	#
	# Various sanity checks and default settings
	#

	# Check version and candidates cache
	if [[ "$COMMAND" != "update" ]]; then
		___drman_check_candidates_cache "$DRMAN_CANDIDATES_CACHE" || return 1
		___drman_check_version_cache
	fi

	# Always presume internet availability
	DRMAN_AVAILABLE="true"
	if [ -z "$DRMAN_OFFLINE_MODE" ]; then
		DRMAN_OFFLINE_MODE="false"
	fi

	# ...unless proven otherwise
	__drman_update_broadcast_and_service_availability

	# Load the drman config if it exists.
	if [ -f "${DRMAN_DIR}/etc/config" ]; then
		source "${DRMAN_DIR}/etc/config"
	fi

	# no command provided
	if [[ -z "$COMMAND" ]]; then
		__drm_help
		return 1
	fi

	# Check if it is a valid command
	CMD_FOUND=""
	CMD_TARGET="${DRMAN_DIR}/src/drman-${COMMAND}.sh"
	if [[ -f "$CMD_TARGET" ]]; then
		CMD_FOUND="$CMD_TARGET"
	fi

	# Check if it is a sourced function
	CMD_TARGET="${DRMAN_DIR}/ext/drman-${COMMAND}.sh"
	if [[ -f "$CMD_TARGET" ]]; then
		CMD_FOUND="$CMD_TARGET"
	fi

	# couldn't find the command
	if [[ -z "$CMD_FOUND" ]]; then
		echo "Invalid command: $COMMAND"
		__drm_help
	fi

	# Check whether the candidate exists
	local drman_valid_candidate=$(echo ${DRMAN_CANDIDATES[@]} | grep -w "$QUALIFIER")
	if [[ -n "$QUALIFIER" && "$COMMAND" != "offline" && "$COMMAND" != "flush" && "$COMMAND" != "selfupdate" && -z "$drman_valid_candidate" ]]; then
		echo ""
		__drman_echo_red "Stop! $QUALIFIER is not a valid candidate."
		return 1
	fi

	# Validate offline qualifier
	if [[ "$COMMAND" == "offline" && -n "$QUALIFIER" && -z $(echo "enable disable" | grep -w "$QUALIFIER") ]]; then
		echo ""
		__drman_echo_red "Stop! $QUALIFIER is not a valid offline mode."
	fi

	# Check whether the command exists as an internal function...
	#
	# NOTE Internal commands use underscores rather than hyphens,
	# hence the name conversion as the first step here.
	CONVERTED_CMD_NAME=$(echo "$COMMAND" | tr '-' '_')

	# Store the return code of the requested command
	local final_rc=0

	# Execute the requested command
	if [ -n "$CMD_FOUND" ]; then
		# It's available as a shell function
		__drm_"$CONVERTED_CMD_NAME" "$QUALIFIER" "$3" "$4"
		final_rc=$?
	fi

	# Attempt upgrade after all is done
	if [[ "$COMMAND" != "selfupdate" ]]; then
		__drman_auto_update "$DRMAN_REMOTE_VERSION" "$DRMAN_VERSION"
	fi
	return $final_rc
}
