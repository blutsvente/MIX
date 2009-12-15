#!/bin/sh
. /tools/Modules/default/init/bash; module unload msd
module load mix/2.0
# perl -x ~/work/MIX/mix_1.pl $* registermaster_template_frcv_urac.xls
# perl -x ~/work/MIX/mix_1.pl $* test_urac.xls
mix test_urac.xls
