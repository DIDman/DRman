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

function __drm_current() {
	local candidate="$1"

	echo ""
	if [ -n "$candidate" ]; then
		__drman_determine_current_version "$candidate"
		if [ -n "$CURRENT" ]; then
			__drman_echo_no_colour "Using ${candidate} version ${CURRENT}"
		else
			__drman_echo_red "Not using any version of ${candidate}"
		fi
	else
		local installed_count=0
		for ((i = 0; i <= ${#DRMAN_CANDIDATES[*]}; i++)); do
			# Eliminate empty entries due to incompatibility
			if [[ -n ${DRMAN_CANDIDATES[${i}]} ]]; then
				__drman_determine_current_version "${DRMAN_CANDIDATES[${i}]}"
				if [ -n "$CURRENT" ]; then
					if [ ${installed_count} -eq 0 ]; then
						__drman_echo_no_colour 'Using:'
						echo ""
					fi
					__drman_echo_no_colour "${DRMAN_CANDIDATES[${i}]}: ${CURRENT}"
					((installed_count += 1))
				fi
			fi
		done

		if [ ${installed_count} -eq 0 ]; then
			__drman_echo_no_colour 'No candidates are in use'
		fi
	fi
}

function __drman_determine_current_version() {
	local candidate present

	candidate="$1"
	present=$(__drman_path_contains "${DRMAN_CANDIDATES_DIR}/${candidate}")
	if [[ "$present" == 'true' ]]; then
		if [[ "$solaris" == true ]]; then
			CURRENT=$(echo $PATH | gsed -r "s|${DRMAN_CANDIDATES_DIR}/${candidate}/([^/]+)/bin|!!\1!!|1" | gsed -r "s|^.*!!(.+)!!.*$|\1|g")
		elif [[ "$darwin" == true ]]; then
			CURRENT=$(echo $PATH | sed -E "s|${DRMAN_CANDIDATES_DIR}/${candidate}/([^/]+)/bin|!!\1!!|1" | sed -E "s|^.*!!(.+)!!.*$|\1|g")
		else
			CURRENT=$(echo $PATH | sed -r "s|${DRMAN_CANDIDATES_DIR}/${candidate}/([^/]+)/bin|!!\1!!|1" | sed -r "s|^.*!!(.+)!!.*$|\1|g")
		fi

		if [[ "$CURRENT" == "current" ]]; then
			CURRENT=$(readlink "${DRMAN_CANDIDATES_DIR}/${candidate}/current" | sed "s!${DRMAN_CANDIDATES_DIR}/${candidate}/!!g")
		fi
	else
		CURRENT=""
	fi
}
