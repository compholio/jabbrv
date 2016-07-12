#!/bin/bash

# NOTE: Expects ISSN_LANG and UNIX_LANG to be defined
OUTPUT_FILE="jabbrv-ltwa-${UNIX_LANG}.ldf";

# Below is a rather large list of LaTeX replacements for UTF-8 Characters,
# note that only characters found in the LTWA database are included below
# (to save processing time for my poor computer)
#            \`              \'              \^              \~              \=
REPLACECHAR=('\(.\)\xCC\x80' '\(.\)\xCC\x81' '\(.\)\xCC\x82' '\(.\)\xCC\x83' '\(.\)\xCC\x84' \
#            \"              \v              \J@C            \c
             '\(.\)\xCC\x88' '\(.\)\xCC\x8C' '\(.\)\xCC\xA1' '\(.\)\xCC\xA7'                 \
#            \=a             \"a             \^A
             'ā'             'ä'             'Â'                                             \
#            \'e
             'é'                                                                             \
#            \`i             \'i
             'ì'             'í'                                                             \
#            \'o             \oe             \"o
             'ó'             'œ'             'ö'                                             \
#            \'u             \^u             \"u
             'ú'             'û'             'ü'                                             \
#            \v s
             'š'                                                                             \
             'ʹ');
REPLACEMENT=('\\`\1'         "\\\\'\1"       '\\^\1'         '\\~\1'         '\\=\1'         \
             '\\"\1'         '\\v \1'        '\\J@C \1'      '\\c \1'                        \
             '\\=a'          '\\"a'          '\\^A'                                          \
             "\\\\'e"                                                                        \
             '\\`i'          "\\\\'i"                                                        \
             "\\\\'o"        '\\oe '         '\\"o'                                          \
             "\\\\'u"        '\\^u'          '\\"u'                                          \
             '\\v s'                                                                         \
             "'");
REPLACE_RULES="";
MAXRULES=$((${#REPLACECHAR[@]}-1));
for J in `seq 0 ${MAXRULES}`; do
	REPLACE_RULES="${REPLACE_RULES};s/${REPLACECHAR[$J]}/${REPLACEMENT[$J]}/g";
done
#REPLACE_RULES="${REPLACE_RULES:1}";
# For testing:
#echo "${REPLACE_RULES}";
#TEST="<td>èlement-<td>elem.<td>rus,fre,eng<td>";
#TEST=`echo "${TEST}" | awk 'BEGIN { FS = "<td>" } ; { print $2 }'`;
#TEST="èpidemiolog- ébénisterie";
#TEST=`echo "${TEST:0:1}" | tr a-z A-Z`"${TEST:1}";
#echo "${TEST}" | sed -e "${REPLACE_RULES:1}";
#exit 0;

HEADER="%% Copyright 2010 Erich Hoover
%% E-mail: ehoover@mines.edu
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
%% generatedfrom the ISSN LTWA database, publicly accessible from
%% their website:
%%   http://www.issn.org/2-22660-LTWA.php
";
echo "${HEADER}" > ${OUTPUT_FILE};
ENTRIES=`cat lang_data.txt`;
for ENTRY in ${ENTRIES}; do
	# Remove punctuation:
	ENTRY=`echo "${ENTRY}" | sed 's/\.//g'`;
	# Pull out the applicable languages for testing:
	LANGS=`echo "${ENTRY}" | awk 'BEGIN { FS = "<td>" } ; { print $4 }'`;
	# See if one of the languages is the one we're interested in outputting
	for ELANG in `echo "${LANGS}" | sed 's/,/\ /g'`; do
		if [ "${ELANG}" = "${ISSN_LANG}" ]; then
			# Pull out the title and abbreviation:
			TITLE=`echo "${ENTRY}" | awk 'BEGIN { FS = "<td>" } ; { print $2 }'`;
			ABBRV=`echo "${ENTRY}" | awk 'BEGIN { FS = "<td>" } ; { print $3 }'`;
			# Capitalize the first letter of the title and the abbreviation"
			TITLE=`echo "${TITLE:0:1}" | tr a-z A-Z`"${TITLE:1}";
			ABBRV=`echo "${ABBRV:0:1}" | tr a-z A-Z`"${ABBRV:1}";
			# Replace UTF-8 characters with LaTeX equivalents:
			TITLE=`echo "${TITLE}" | sed -e "${REPLACE_RULES}"`;
			ABBRV=`echo "${ABBRV}" | sed -e "${REPLACE_RULES}"`;
			# Check to see if the title ends with a dash
			FIRST="${TITLE%?}";
			if [ "${TITLE:${#FIRST}}" = "-" ]; then
				# Output the "matching" entry:
				TITLE=`echo "${TITLE}" | sed -e 's/-$//'`;
				echo "\DefineJournalPartialAbbreviation{${TITLE}}{${ABBRV}}" >> ${OUTPUT_FILE};
			else
				# Output the normal entry:
				echo "\DefineJournalAbbreviation{${TITLE}}{${ABBRV}}" >> ${OUTPUT_FILE};
			fi
			break;
		fi
	done
done

