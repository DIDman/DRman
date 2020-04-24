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

function __drman_echo_debug() {
	if [[ "$drman_debug_mode" == 'true' ]]; then
		echo "$1"
	fi
}

function __drman_secure_curl() {
	if [[ "${drman_insecure_ssl}" == 'true' ]]; then
		curl --insecure --silent --location "$1"
	else
		curl --silent --location "$1"
	fi
}

function __drman_secure_curl_download() {
	local curl_params="--progress-bar --location"
	if [[ "${drman_insecure_ssl}" == 'true' ]]; then
		curl_params="$curl_params --insecure"
	fi

	if [[ ! -z "${drman_curl_retry}" ]]; then
		curl_params="--retry ${drman_curl_retry} ${curl_params}"
	fi

	if [[ ! -z "${drman_curl_retry_max_time}" ]]; then
		curl_params="--retry-max-time ${drman_curl_retry_max_time} ${curl_params}"
	fi

	if [[ "${drman_curl_continue}" == 'true' ]]; then
		curl_params="-C - ${curl_params}"
	fi

	if [[ "${drman_debug_mode}" == 'true' ]]; then
		curl_params="--verbose ${curl_params}"
	fi

	if [[ "$zsh_shell" == 'true' ]]; then
		curl ${=curl_params} "$@"
	else
		curl ${curl_params} "$@"
	fi
}

function __drman_secure_curl_with_timeouts() {
	if [[ "${drman_insecure_ssl}" == 'true' ]]; then
		curl --insecure --silent --location --connect-timeout ${drman_curl_connect_timeout} --max-time ${drman_curl_max_time} "$1"
	else
		curl --silent --location --connect-timeout ${drman_curl_connect_timeout} --max-time ${drman_curl_max_time} "$1"
	fi
}

function __drman_page() {
	if [[ -n "$PAGER" ]]; then
		"$@" | eval $PAGER
	elif command -v less >& /dev/null; then
		"$@" | less
	else
		"$@"
	fi
}

function __drman_echo() {
	if [[ "$drman_colour_enable" == 'false' ]]; then
		echo -e "$2"
	else
		echo -e "\033[1;$1$2\033[0m"
	fi
}

function __drman_echo_red() {
	__drman_echo "31m" "$1"
}

function __drman_echo_no_colour() {
	echo "$1"
}

function __drman_echo_yellow() {
	__drman_echo "33m" "$1"
}

function __drman_echo_green() {
	__drman_echo "32m" "$1"
}

function __drman_echo_cyan() {
	__drman_echo "36m" "$1"
}

function __drman_echo_confirm() {
	if [[ "$drman_colour_enable" == 'false' ]]; then
		echo -n "$1"
	else
		echo -e -n "\033[1;33m$1\033[0m"
	fi
}

function __drman_legacy_bash_message() {
	__drman_echo_red "An outdated version of bash was detected on your system!"
	echo ""
	__drman_echo_red "We recommend upgrading to bash 4.x, you have:"
	echo ""
	__drman_echo_yellow "  $BASH_VERSION"
	echo ""
	__drman_echo_yellow "Need to use brute force to replace candidates..."
}
