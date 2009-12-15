#!/bin/csh -f
set dirs = (scd mcd no_clock_gating read_pipeline)
foreach dir ($dirs)
	cp -f ../../sxc_input/reg_shell/${dir}/rs_*.v ${dir}
	cp -f ../../sxc_input/reg_shell/${dir}/mix* ${dir}
	cp -f ../../sxc_input/reg_shell/${dir}/reg_shell-mixed* ${dir}
        /bin/rm ${dir}/*~
	cvs ci -m"updated" ${dir}
end
