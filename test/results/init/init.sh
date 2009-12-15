#!/bin/sh

[ -f init.xls ] && rm init.xls
[ -f init.xls ] && exit 1
[ -f init.csv ] && rm init.csv
[ -f init.csv ] && exit 1

mix_0.pl -import inst_aa_e-e.vhd ddrv4-e.vhd init.xls

status=$?
echo "**** import returned: $status"
#
# compare against init-target.csv:
# this diff returns >8< if no diffs are present!
# (date lines)
num_lines=`diff init.csv init-target.csv | wc -l`

exit `expr $num_lines + $status - 8`

#!End
