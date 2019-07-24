#!/bin/bash

# NOTE: Expects ISSN_LANG and UNIX_LANG to be defined
OUTPUT_FILE="jabbrv-ltwa-${UNIX_LANG}.ldf";

# Below is a list of LaTeX replacements for UTF-8 combining diacritical marks and unusual symbols.
# Note that only characters found in the LTWA database are included below
# (to save processing time for my poor computer)
#            \`              \'              \^              \~              \=
REPLACECHAR=('\(.\)\xCC\x80' '\(.\)\xCC\x81' '\(.\)\xCC\x82' '\(.\)\xCC\x83' '\(.\)\xCC\x84' \
#            \u              \.
             '\(.\)\xCC\x86' '\(.\)\xCC\x87'                                                 \
#            \"              \v              \J@C            \c
             '\(.\)\xCC\x88' '\(.\)\xCC\x8C' '\(.\)\xCC\xA1' '\(.\)\xCC\xA7'                 \
#            \oe             \textlefthalfring
             'œ'             'ʿ'                                                             \
             'ʹ');
REPLACEMENT=('\\`\1'         "\\\\'\1"       '\\^\1'         '\\~\1'         '\\=\1'         \
             '\\u \1'        '\\.\1'                                                         \
             '\\"\1'         '\\v \1'        '\\J@C \1'      '\\c \1'                        \
             '\\oe '         '\\textlefthalfring '                                           \
             "'");
REPLACE_RULES="";
MAXRULES=$((${#REPLACECHAR[@]}-1));
for J in `seq 0 ${MAXRULES}`; do
	REPLACE_RULES="${REPLACE_RULES};s/${REPLACECHAR[$J]}/${REPLACEMENT[$J]}/g";
done

REPLACE_ODD="";
# almost the entire LTWA uses "combining" diacritical marks, except for limited instances of:
REPLACE_ODD="${REPLACE_ODD};s/Â/A\xCC\x82/g"; # capital A with circumflex (Â)
REPLACE_ODD="${REPLACE_ODD};s/á/a\xCC\x81/g"; # lowercase a with acute accent (á)
REPLACE_ODD="${REPLACE_ODD};s/ā/a\xCC\x84/g"; # lowercase a with overline (ā)
REPLACE_ODD="${REPLACE_ODD};s/ä/a\xCC\x88/g"; # lowercase a with umlauts (ä)
REPLACE_ODD="${REPLACE_ODD};s/è/e\xCC\x80/g"; # lowercase e with backtick (è)
REPLACE_ODD="${REPLACE_ODD};s/é/e\xCC\x81/g"; # lowercase e with forward tick (é)
REPLACE_ODD="${REPLACE_ODD};s/ì/i\xCC\x80/g"; # lowercase i with backtick (ì)
REPLACE_ODD="${REPLACE_ODD};s/í/i\xCC\x81/g"; # lowercase i with forward tick (í)
REPLACE_ODD="${REPLACE_ODD};s/ñ/n\xCC\x84/g"; # lowercase n with overline (ñ)
REPLACE_ODD="${REPLACE_ODD};s/Ö/O\xCC\x88/g"; # capital O with umlauts (Ö)
REPLACE_ODD="${REPLACE_ODD};s/ó/o\xCC\x81/g"; # lowercase o with forward tick (ó)
REPLACE_ODD="${REPLACE_ODD};s/ö/o\xCC\x88/g"; # lowercase o with umlauts (ö)
REPLACE_ODD="${REPLACE_ODD};s/ú/u\xCC\x81/g"; # lowercase u with forward tick (ú)
REPLACE_ODD="${REPLACE_ODD};s/û/u\xCC\x82/g"; # lowercase u with circumflex (û)
REPLACE_ODD="${REPLACE_ODD};s/ü/u\xCC\x88/g"; # lowercase u with umlauts (ü)
REPLACE_ODD="${REPLACE_ODD};s/š/s\xCC\x8C/g"; # lowercase s with caron (š)

# replace the "Not Applicable" entries with something that can easily be distinguished from normal
# abbreviations (we remove all periods, so n.a. becomes "na" - which is a legit abbreviation)
REPLACE_NA="s/\(.*\)\tn.a.\t\(.*\)/\1\t-\t\2/g";

# remove all the entries that start with a dash or a single quote
REPLACE_NONLETTER="/^[-']/d";

HEADER="%% Copyright 2010-2019 Erich E. Hoover
%% E-mail: erich.e.hoover@gmail.com
%% 
%% =============================================
%% IMPORTANT NOTICE:
%% 
%% This work may be distributed and/or modified under the conditions
%% of the LaTeX Project Public License, either version 1.3c of this
%% license or (at your option) any later version.
%% The latest version of this license is available at
%%   http://www.latex-project.org/lppl.txt
%% =============================================
%% The List of Title Word Abbreviations below is automatically
%% generated from the ISSN LTWA database, publicly accessible from
%% their website:
%%   http://www.issn.org/2-22660-LTWA.php
";
echo "${HEADER}" > ${OUTPUT_FILE};
ENTRIES=$(cat lang_data.txt | sed -e "${REPLACE_ODD};${REPLACE_NA};${REPLACE_NONLETTER}");
I=0;
export IFS=$'\r\n'
for ENTRY in ${ENTRIES}; do
    I=$((I+1));
    if [ "${I}" -eq "1" ]; then continue; fi
	# Remove punctuation:
	ENTRY=`echo "${ENTRY}" | sed 's/\.//g'`;
	# Pull out the applicable languages, title, and abbreviation:
    OLDIFS=${IFS}
    export IFS=$'\t'
    while [ 1 ]; do
        read TITLE ABBRV LANGS;
        break;
    done < <(echo "${ENTRY}")
    export IFS=${OLDIFS}
	# See if one of the languages is the one we're interested in outputting
    OLDIFS=${IFS}
    export IFS=' '
	for ELANG in `echo "${LANGS}" | sed 's/,/\ /g'`; do
		if [ "${ELANG}" = "${ISSN_LANG}" ]; then
			# Capitalize the first letter of the title and the abbreviation"
			TITLE=`echo "${TITLE:0:1}" | tr a-z A-Z`"${TITLE:1}";
			ABBRV=`echo "${ABBRV:0:1}" | tr a-z A-Z`"${ABBRV:1}";
			# Replace UTF-8 characters with LaTeX equivalents:
			TITLE=`echo "${TITLE}" | sed -e "${REPLACE_RULES}"`;
			ABBRV=`echo "${ABBRV}" | sed -e "${REPLACE_RULES}"`;
            # Non-applicable entries are exceptions to the regular rules, we define these with a
            # \DefineJournalWordException rather than \DefineJournalAbbreviation
            TYPE="Abbreviation";
            if [ "${ABBRV}" = "-" ]; then
                TYPE="WordException";
                ABBRV="${TITLE}";
            fi
			# Check to see if the title ends with a dash
			FIRST="${TITLE%?}";
			if [ "${TITLE:${#FIRST}}" = "-" ]; then
				# Output the "matching" entry:
				TITLE=`echo "${TITLE}" | sed -e 's/-$//'`;
                if [ "${TYPE}" = "WordException" ]; then
                    # we currently do not support partial exceptions, so comment them out
                    echo -n "%" >> ${OUTPUT_FILE};
                fi
				echo "\DefineJournalPartial${TYPE}{${TITLE}}{${ABBRV}}" >> ${OUTPUT_FILE};
			else
				# Output the normal entry:
				echo "\DefineJournal${TYPE}{${TITLE}}{${ABBRV}}" >> ${OUTPUT_FILE};
			fi
			break;
		fi
	done
    export IFS=${OLDIFS}
done

