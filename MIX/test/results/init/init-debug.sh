#!/bin/sh

[ -f init.xls ] && rm init.xls
[ -f init.xls ] && exit 1
perl -x -d `which mix_0.pl` -import inst_aa_e-e.vhd ddrv4-e.vhd init.xls

exit $?
#!End
