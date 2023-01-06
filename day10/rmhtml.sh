#!/bin/sh
sed 's/<[^>]*>//g' | sed 's/ &nbsp;/'"$(printf '\t')"'/g' | tr '\t' '\n' | grep -vE '^$'
