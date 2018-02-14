#!/bin/sh
#
# The makefile renames tao_main.html to index.html, but cross references in
# footnotes leave links to tao_main.html#blah in the footnote HTML files.  This
# script fixes these links to point to the correct file.

for file in tao_main?*.html; do
  perl -i -pe 's/href="tao_main.html/href=".\//g' $file
done
