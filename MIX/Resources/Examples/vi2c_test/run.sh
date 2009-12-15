#!/bin/sh
. /tools/Modules/default/init/bash; module unload msd
module load mix/2.0
mix example-top.xls vi2c_test.xls
