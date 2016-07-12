#!/bin/bash

## IMPORTANT NOTE:
## Pass "redownload" as the first flag to redownload the LTWA, ie:
## 	./download-abbrv.sh redownload

ISSN_LANGUAGES=("mul" "eng" "ger" "fre" "spa");
UNIX_LANGUAGES=("all" "en"  "de"  "fr"  "es" );
MAXLANG=$((${#ISSN_LANGUAGES[@]}-1));

if [ ! -f lang_data.txt ] || [ "$1" = "redownload" ]; then
	echo "Downloading LTWA Database...";
	rm lang_data.txt 2> /dev/null;
	for LETTER in `echo {a..z}`; do
		ENTRIES=`wget -O - http://www.issn.org/2-22661-LTWA-online.php?letter=${LETTER} | grep '<tr><td>' | grep -v 'n.a.' | sed 's/\///g' | sed 's/<tr>//g' | sed 's/<td><td>/<td>/g' | sed 's/,\ /,/g' | sed 's/\ /\&nbsp;/g'`;
		echo "${ENTRIES}" >> lang_data.txt;
	done
fi

for I in `seq 0 ${MAXLANG}`; do
	ISSN_LANG=${ISSN_LANGUAGES[$I]};
	UNIX_LANG=${UNIX_LANGUAGES[$I]};
	echo "Working on Language '${UNIX_LANG}'...";
	. ./extract-abbrv-lang.sh;
done
#cp *.ldf ../jabbrv/;

