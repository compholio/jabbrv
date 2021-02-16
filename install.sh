#!/bin/sh

FILE_FOLDER=`dirname $0`;
FILE_NAME=`basename $0`;
SUDO="";

message() {
	TYPE="$1";
	MESSAGE="$2";
	if [ "${TYPE}" = "ERROR" ]; then
		echo "${TYPE}: ${MESSAGE}" 1>&2;
	elif [ "${TYPE}" = "EMERR" ]; then
		echo "${MESSAGE}" 1>&2;
	else
		echo "${TYPE}: ${MESSAGE}";
	fi
}

# Choose an installation folder
if [ "$#" -gt "1" ]; then
	message "ERROR" "Unhandled number of arguments passed to script.";
	exit 1;
elif [ "$#" -eq "1" ]; then
	BASE_FOLDER="$1";
	echo "using custom folder: ${BASE_FOLDER}";
else
	TEX_FOLDER="/usr/share/texmf-texlive";
	BASE_FOLDER="/usr/local/share/texmf";
	if [ ! -d "${TEX_FOLDER}" ]; then
		TEX_FOLDER="/Library/TeX";
		BASE_FOLDER="${HOME}/Library/texmf";
	fi
	if [ ! -d "${TEX_FOLDER}" ]; then
		TEX_FOLDER="/usr/local/texlive";
		BASE_FOLDER="${TEX_FOLDER}";
	fi
	if [ ! -d "${TEX_FOLDER}" ]; then
		message "ERROR" "Could not find a LaTeX installation folder, you're likely running an unhandled LaTeX distribution.";
		exit 1;
	fi
fi

# Check that base folder exists
if [ ! -w "$BASE_FOLDER" ]; then
	message "ERROR" "Directory `${BASE_FOLDER}` does not exist.";
	exit 1;
fi

# Detect the package updater
HASH_UPDATER=`which texhash`;
if [ "${HASH_UPDATER}" = "" ]; then
	message "ERROR" "The system is using an unknown TeX hash updating application.";
	exit 1;
fi

INSTALL_LTX_FOLDER="${BASE_FOLDER}/tex/latex/jabbrv";
INSTALL_BST_FOLDER="${BASE_FOLDER}/bibtex/bst/jabbrv";

# Make sure the user has the appropriate permissions
if [ ! -w "$BASE_FOLDER" ]; then
	SUDO="sudo";
	SUDO_TEST=`$SUDO -n echo "test" 2> /dev/null`;
	if [ "${SUDO_TEST}" != "test" ]; then
		message "ERROR" "Super user permissions are required to continue; instead run:";
		message "EMERR" "$SUDO ./${FILE_NAME}";
		exit 1;
	fi
fi

# Copy installation files
FOLDER=`cd ${FILE_FOLDER}/; pwd`;
$SUDO mkdir -p "${INSTALL_LTX_FOLDER}";
$SUDO mkdir -p "${INSTALL_BST_FOLDER}";
$SUDO cp "${FOLDER}/"*.sty "${INSTALL_LTX_FOLDER}/";
$SUDO cp "${FOLDER}/"*.ldf "${INSTALL_LTX_FOLDER}/";
$SUDO cp "${FOLDER}/"*.bst "${INSTALL_BST_FOLDER}/";

# Update the package list
sudo ${HASH_UPDATER};
