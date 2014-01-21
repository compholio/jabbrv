#!/bin/sh

FILE_FOLDER=`dirname $0`;
FILE_NAME=`basename $0`;

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

# Make sure the user has the appropriate permissions
SUDO_TEST=`sudo -n echo "test" 2> /dev/null`;
if [ "${SUDO_TEST}" != "test" ]; then
	message "ERROR" "Super user permissions are required to continue, instead run:";
	message "EMERR" "sudo ./${FILE_NAME}";
	exit;
fi

# Choose an installation folder
if [ "$#" -gt "1" ]; then
	message "ERROR" "Unhandled number of arguments passed to script.";
	exit;
elif [ "$#" -eq "1" ]; then
	BASE_FOLDER="$1";
	echo "using custom folder: ${BASE_FOLDER}";
else
	if [ -d "/usr/share/texmf-texlive" ]; then
		BASE_FOLDER="/usr/local/share/texmf";
	else
		BASE_FOLDER="/usr/local/texlive";
		if [ ! -d "${BASE_FOLDER}" ]; then
			BASE_FOLDER="${HOME}/Library/texmf";
		else
			message "ERROR" "Could not find a LaTeX installation folder, you're likely running an unhandled LaTeX distribution.";
			exit;
		fi
	fi
fi

# Detect the package updater
HASH_UPDATER=`which texhash`;
if [ "${HASH_UPDATER}" = "" ]; then
	message "ERROR" "The system is using an unknown TeX hash updating application.";
	exit;
fi

INSTALL_LTX_FOLDER="${BASE_FOLDER}/tex/latex/jabbrv";
INSTALL_BST_FOLDER="${BASE_FOLDER}/bibtex/bst/jabbrv";

# Copy installation files
FOLDER=`cd ${FILE_FOLDER}/; pwd`;
sudo mkdir -p "${INSTALL_LTX_FOLDER}";
sudo mkdir -p "${INSTALL_BST_FOLDER}";
sudo cp "${FOLDER}/"*.sty "${INSTALL_LTX_FOLDER}/";
sudo cp "${FOLDER}/"*.ldf "${INSTALL_LTX_FOLDER}/";
sudo cp "${FOLDER}/"*.bst "${INSTALL_BST_FOLDER}/";

# Update the package list
sudo ${HASH_UPDATER};

