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

function __drm_help() {
	__drman_echo_no_colour ""
	__drman_echo_no_colour "Usage: drm <command> [candidate] [version]"
	__drman_echo_no_colour "       drm offline <enable|disable>"
	__drman_echo_no_colour ""
	__drman_echo_no_colour "   commands:"
	__drman_echo_no_colour "       install   or i    <candidate> [version] [local-path]"
	__drman_echo_no_colour "       uninstall or rm   <candidate> <version>"
	__drman_echo_no_colour "       list      or ls   [candidate]"
	__drman_echo_no_colour "       use       or u    <candidate> <version>"
	__drman_echo_no_colour "       default   or d    <candidate> [version]"
	__drman_echo_no_colour "       home      or h    <candidate> <version>"
	__drman_echo_no_colour "       current   or c    [candidate]"
	__drman_echo_no_colour "       upgrade   or ug   [candidate]"
	__drman_echo_no_colour "       version   or v"
	__drman_echo_no_colour "       broadcast or b"
	__drman_echo_no_colour "       help"
	__drman_echo_no_colour "       offline           [enable|disable]"
	__drman_echo_no_colour "       selfupdate        [force]"
	__drman_echo_no_colour "       update"
	__drman_echo_no_colour "       flush             <broadcast|archives|temp>"
	__drman_echo_no_colour ""
	__drman_echo_no_colour "   candidate  :  the SDK to install: groovy, scala, grails, gradle, kotlin, etc."
	__drman_echo_no_colour "                 use list command for comprehensive list of candidates"
	__drman_echo_no_colour "                 eg: \$ drm  list"
	__drman_echo_no_colour "   version    :  where optional, defaults to latest stable if not provided"
	__drman_echo_no_colour "                 eg: \$ drm  install groovy"
	__drman_echo_no_colour "   local-path :  optional path to an existing local installation"
	__drman_echo_no_colour "                 eg: \$ drm  install groovy 2.4.13-local /opt/groovy-2.4.13"
	__drman_echo_no_colour ""
}
