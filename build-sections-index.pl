#!/usr/bin/env perl

use warnings;

open(INDEX, '>sections.idx') or die "Couldn't open section index file";

while(<>) {
  print INDEX "$1\t$ARGV\n" if /<A href="https:\/\/gate\.ac\.uk\/userguide\/([^"?]*)(?:\?gateVersion=[^"]*)?" title="Permanent link/;
}

close INDEX;
