 file: regdef_fe1.e
 created automatically by /home/lutscher/work/MIX/mix_0.pl

<'
reg_def FE_YCDET_M_0X0 MIC_FE_YCDET_M 0x0 {
    reg_fld hole              : uint(bits:20) : RW : 0 : cov ; -- lsb position  12
    reg_fld dummy_fe          : uint(bits: 3) : RW : 0 : cov ; -- lsb position   9
    reg_fld dgates            : uint(bits: 5) : RW : 0 : cov ; -- lsb position   4
    reg_fld dgatel            : uint(bits: 4) : RW : 0 : cov ; -- lsb position   0
};
reg_def FE_YCDET_M_0X4 MIC_FE_YCDET_M 0x4 {
    reg_fld hole              : uint(bits:31) : RW : 0 : cov ; -- lsb position   1
    reg_fld cvbsdetect        : uint(bits: 1) : RW : 0 : cov ; -- lsb position   0
};
reg_def FE_YCDET_M_0X8 MIC_FE_YCDET_M 0x8 {
    reg_fld hole              : uint(bits:21) : R  : 0 : cov ; -- lsb position  11
    reg_fld sha_r_test        : uint(bits: 8) : R  : 0 : cov ; -- lsb position   3
    reg_fld usr_r_test        : uint(bits: 1) : R  : 0 : cov ; -- lsb position   2
    reg_fld ycdetect          : uint(bits: 1) : R  : 0 : cov ; -- lsb position   1
    reg_fld hole              : uint(bits: 1) : RW : 0 : cov ; -- lsb position   0
};
reg_def FE_MVDET_M_0XC MIC_FE_MVDET_M 0x12 {
    reg_fld hole              : uint(bits:21) : RW : 0 : cov ; -- lsb position  11
    reg_fld mvstop            : uint(bits: 6) : RW : 0 : cov ; -- lsb position   5
    reg_fld mvstart           : uint(bits: 5) : RW : 0 : cov ; -- lsb position   0
};
reg_def FE_MVDET_M_0X10 MIC_FE_MVDET_M 0x16 {
    reg_fld hole              : uint(bits:17) : RW : 0 : cov ; -- lsb position  15
    reg_fld usr_rw_test       : uint(bits: 4) : RW : 0 : cov ; -- lsb position  11
    reg_fld hole              : uint(bits:11) : RW : 0 : cov ; -- lsb position   0
};
reg_def FE_MVDET_M_0X14 MIC_FE_MVDET_M 0x20 {
    reg_fld sha_rw2           : uint(bits:32) : RW : 0 : cov ; -- lsb position   0
};
reg_def FE_MVDET_M_0X18 MIC_FE_MVDET_M 0x24 {
    reg_fld hole              : uint(bits:16) : RW : 0 : cov ; -- lsb position  16
    reg_fld wd_16_test        : uint(bits:16) : RW : 0 : cov ; -- lsb position   0
};
reg_def FE_MVDET_M_0X1C MIC_FE_MVDET_M 0x28 {
    reg_fld hole              : uint(bits:24) : W  : 0 : cov ; -- lsb position   8
    reg_fld wd_16_test2       : uint(bits: 8) : W  : 0 : cov ; -- lsb position   0
};
reg_def FE_MVDET_M_0X20 MIC_FE_MVDET_M 0x32 {
    reg_fld hole              : uint(bits: 8) : W  : 0 : cov ; -- lsb position  24
    reg_fld sha_w_test        : uint(bits: 4) : W  : 0 : cov ; -- lsb position  20
    reg_fld w_test            : uint(bits: 4) : W  : 0 : cov ; -- lsb position  16
    reg_fld hole              : uint(bits:12) : W  : 0 : cov ; -- lsb position   4
    reg_fld usr_w_test        : uint(bits: 4) : W  : 0 : cov ; -- lsb position   0
};
reg_def FE_MVDET_M_0X24 MIC_FE_MVDET_M 0x36 {
    reg_fld hole              : uint(bits:29) : R  : 0 : cov ; -- lsb position   3
    reg_fld r_test            : uint(bits: 3) : R  : 0 : cov ; -- lsb position   0
};
'>
