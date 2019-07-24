#!/bin/bash

## IMPORTANT NOTE:
## Pass "redownload" as the first flag to redownload the LTWA, ie:
## 	./download-abbrv.sh redownload

LTWA_URL="https://www.issn.org/wp-content/uploads/2013/09/LTWA_20160915.txt";
ISSN_LANGUAGES=("mul" "eng" "ger" "fre" "spa");
UNIX_LANGUAGES=("all" "en"  "de"  "fr"  "es" );
MAXLANG=$((${#ISSN_LANGUAGES[@]}-1));

if [ ! -f lang_data.txt ] || [ "$1" = "redownload" ]; then
	echo "Downloading LTWA Database...";
	rm lang_data.txt 2> /dev/null;
	wget --no-check-certificate -O - "${LTWA_URL}" | iconv -f UTF-16LE -t UTF-8 > lang_data.txt;
fi

for I in `seq 0 ${MAXLANG}`; do
	ISSN_LANG=${ISSN_LANGUAGES[$I]};
	UNIX_LANG=${UNIX_LANGUAGES[$I]};
	echo "Working on Language '${UNIX_LANG}'...";
	. ./extract-abbrv-lang.sh;
done
