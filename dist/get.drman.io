#!/bin/bash
#
#   Copyright 2020 DIDregman
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

#Install: stable
DRMAN_DIST_BRANCH=${DRMAN_DIST_BRANCH:-dist}
DRMAN_NAMESPACE=${DRMAN_NAMESPACE:-DIDman}
# Global variables
DRMAN_SERVICE="https://raw.githubusercontent.com/${DRMAN_NAMESPACE}/DRman/${DRMAN_DIST_BRANCH}"

DRMAN_VERSION="0.0.1-a8"
DRMAN_PLATFORM=$(uname)

if [ -z "$DRMAN_DIR" ]; then
    DRMAN_DIR="$HOME/.drman"
fi

# Local variables
drman_bin_folder="${DRMAN_DIR}/bin"
drman_src_folder="${DRMAN_DIR}/src"
drman_tmp_folder="${DRMAN_DIR}/tmp"
drman_stage_folder="${drman_tmp_folder}/stage"
drman_zip_file="${drman_tmp_folder}/drman-${DRMAN_VERSION}.zip"
drman_ext_folder="${DRMAN_DIR}/ext"
drman_etc_folder="${DRMAN_DIR}/etc"
drman_var_folder="${DRMAN_DIR}/var"
drman_archives_folder="${DRMAN_DIR}/archives"
drman_candidates_folder="${DRMAN_DIR}/candidates"
drman_config_file="${drman_etc_folder}/config"
drman_bash_profile="${HOME}/.bash_profile"
drman_profile="${HOME}/.profile"
drman_bashrc="${HOME}/.bashrc"
drman_zshrc="${HOME}/.zshrc"

drman_init_snippet=$( cat << EOF
#THIS MUST BE AT THE END OF THE FILE FOR DRMAN TO WORK!!!
export DRMAN_DIR="$DRMAN_DIR"
[[ -s "${DRMAN_DIR}/bin/drman-init.sh" ]] && source "${DRMAN_DIR}/bin/drman-init.sh"
EOF
)

# OS specific support (must be 'true' or 'false').
cygwin=false;
darwin=false;
solaris=false;
freebsd=false;
case "$(uname)" in
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


echo ''
echo 'DIDregman a.k.a DRM '
echo ''

# Sanity checks

echo "Looking for a previous installation of DRMAN..."
if [ -d "$DRMAN_DIR" ]; then
	echo "DRMAN found."
	echo ""
	echo "======================================================================================================"
	echo " You already have DRMAN installed."
	echo " DRMAN was found at:"
	echo ""
	echo "    ${DRMAN_DIR}"
	echo ""
	echo " Please consider running the following if you need to upgrade."
	echo ""
	echo "    $ drm selfupdate force"
	echo ""
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Looking for unzip..."
if [ -z $(which unzip) ]; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install unzip on your system using your favourite package manager."
	echo ""
	echo " Restart after installing unzip."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Looking for zip..."
if [ -z $(which zip) ]; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install zip on your system using your favourite package manager."
	echo ""
	echo " Restart after installing zip."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Looking for curl..."
if [ -z $(which curl) ]; then
	echo "Not found."
	echo ""
	echo "======================================================================================================"
	echo " Please install curl on your system using your favourite package manager."
	echo ""
	echo " Restart after installing curl."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

if [[ "$solaris" == true ]]; then
	echo "Looking for gsed..."
	if [ -z $(which gsed) ]; then
		echo "Not found."
		echo ""
		echo "======================================================================================================"
		echo " Please install gsed on your solaris system."
		echo ""
		echo " DRMAN uses gsed extensively."
		echo ""
		echo " Restart after installing gsed."
		echo "======================================================================================================"
		echo ""
		exit 1
	fi
else
	echo "Looking for sed..."
	if [ -z $(which sed) ]; then
		echo "Not found."
		echo ""
		echo "======================================================================================================"
		echo " Please install sed on your system using your favourite package manager."
		echo ""
		echo " Restart after installing sed."
		echo "======================================================================================================"
		echo ""
		exit 1
	fi
fi


echo "Installing DRMAN scripts..."


# Create directory structure

echo "Create distribution directories..."
mkdir -p "$drman_bin_folder"
mkdir -p "$drman_src_folder"
mkdir -p "$drman_tmp_folder"
mkdir -p "$drman_stage_folder"
mkdir -p "$drman_ext_folder"
mkdir -p "$drman_etc_folder"
mkdir -p "$drman_var_folder"
mkdir -p "$drman_archives_folder"
mkdir -p "$drman_candidates_folder"

echo "Getting available candidates..."
DRMAN_CANDIDATES_CSV=$(curl -s "${DRMAN_SERVICE}/candidates/all")
echo "$DRMAN_CANDIDATES_CSV" > "${DRMAN_DIR}/var/candidates"

echo "Prime the config file..."
touch "$drman_config_file"
echo "drman_auto_answer=false" >> "$drman_config_file"
echo "drman_auto_selfupdate=false" >> "$drman_config_file"
echo "drman_insecure_ssl=false" >> "$drman_config_file"
echo "drman_curl_connect_timeout=7" >> "$drman_config_file"
echo "drman_curl_max_time=10" >> "$drman_config_file"
echo "drman_beta_channel=false" >> "$drman_config_file"
echo "drman_debug_mode=false" >> "$drman_config_file"
echo "drman_colour_enable=true" >> "$drman_config_file"

echo "Download script archive..."

# TODO
# curl --location --progress-bar "${DRMAN_SERVICE}/dist/install/${DRMAN_VERSION}/${DRMAN_PLATFORM}" > "$drman_zip_file"
echo 'curl --location --progress-bar "${DRMAN_SERVICE}/dist/drman-latest.zip" > "$drman_zip_file"'
curl --location --progress-bar "${DRMAN_SERVICE}/dist/drman-latest.zip" > "$drman_zip_file"

ARCHIVE_OK=$(unzip -qt "$drman_zip_file" | grep 'No errors detected in compressed data')
if [[ -z "$ARCHIVE_OK" ]]; then
	echo "Downloaded zip archive corrupt. Are you connected to the internet?"
	echo ""
	echo "If problems persist, please ask for help on our Slack:"
	echo "* easy sign up: https://slack.drman.io/"
	echo "* report on channel: https://drman.slack.com/app_redirect?channel=user-issues"
	rm -rf "$DRMAN_DIR"
	exit 2
fi

echo "Extract script archive..."
if [[ "$cygwin" == 'true' ]]; then
	echo "Cygwin detected - normalizing paths for unzip..."
	drman_zip_file=$(cygpath -w "$drman_zip_file")
	drman_stage_folder=$(cygpath -w "$drman_stage_folder")
fi
echo unzip -qo "$drman_zip_file" -d "$drman_stage_folder"
unzip -qo "$drman_zip_file" -d "$drman_stage_folder"


echo "Install scripts..."
mv "${drman_stage_folder}/drman-init.sh" "$drman_bin_folder"
mv "$drman_stage_folder"/drman-* "$drman_src_folder"

echo "Set version to $DRMAN_VERSION ..."
echo "$DRMAN_VERSION" > "${DRMAN_DIR}/var/version"


if [[ $darwin == true ]]; then
  touch "$drman_bash_profile"
  echo "Attempt update of login bash profile on OSX..."
  if [[ -z $(grep 'drman-init.sh' "$drman_bash_profile") ]]; then
    echo -e "\n$drman_init_snippet" >> "$drman_bash_profile"
    echo "Added drman init snippet to $drman_bash_profile"
  fi
else
  echo "Attempt update of interactive bash profile on regular UNIX..."
  touch "${drman_bashrc}"
  if [[ -z $(grep 'drman-init.sh' "$drman_bashrc") ]]; then
      echo -e "\n$drman_init_snippet" >> "$drman_bashrc"
      echo "Added drman init snippet to $drman_bashrc"
  fi
fi

echo "Attempt update of zsh profile..."
touch "$drman_zshrc"
if [[ -z $(grep 'drman-init.sh' "$drman_zshrc") ]]; then
    echo -e "\n$drman_init_snippet" >> "$drman_zshrc"
    echo "Updated existing ${drman_zshrc}"
fi


echo -e "\n\n\nAll done!\n\n"

echo "Please open a new terminal, or run the following in the existing one:"
echo ""
echo "    source \"${DRMAN_DIR}/bin/drman-init.sh\""
echo ""
echo "Then issue the following command:"
echo ""
echo "    drm help"
echo ""
echo "Enjoy!!!"