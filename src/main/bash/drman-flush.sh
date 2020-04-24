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

function __drm_flush() {
	local qualifier="$1"

	case "$qualifier" in
	broadcast)
		if [[ -f "${DRMAN_DIR}/var/broadcast_id" ]]; then
			rm "${DRMAN_DIR}/var/broadcast_id"
			rm "${DRMAN_DIR}/var/broadcast"
			__drman_echo_green "Broadcast has been flushed."
		else
			__drman_echo_no_colour "No prior broadcast found so not flushed."
		fi
		;;
	version)
		if [[ -f "${DRMAN_DIR}/var/version" ]]; then
			rm "${DRMAN_DIR}/var/version"
			__drman_echo_green "Version file has been flushed."
		fi
		;;
	archives)
		__drman_cleanup_folder "archives"
		;;
	temp)
		__drman_cleanup_folder "tmp"
		;;
	tmp)
		__drman_cleanup_folder "tmp"
		;;
	*)
		__drman_echo_red "Stop! Please specify what you want to flush."
		;;
	esac
}

function __drman_cleanup_folder() {
	local folder="$1"
	drman_cleanup_dir="${DRMAN_DIR}/${folder}"
	drman_cleanup_disk_usage=$(du -sh "$drman_cleanup_dir")
	drman_cleanup_count=$(ls -1 "$drman_cleanup_dir" | wc -l)

	rm -rf "${DRMAN_DIR}/${folder}"
	mkdir "${DRMAN_DIR}/${folder}"

	__drman_echo_green "${drman_cleanup_count} archive(s) flushed, freeing ${drman_cleanup_disk_usage}."
}
