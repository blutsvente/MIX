# $Id: Makefile,v 1.3 2009/02/10 12:46:52 lutscher Exp $
#
# Makefile for calling MIX for SCC register-master
#

PRODUCT          = frcs
PRODUCT_upcase   = $(shell echo ${PRODUCT} | tr '[a-z]' '[A-Z]')
PRFX             = $(PRODUCT)_rs

SRC_SCC_DIR      = .

VPATH            = .:v:e:include

# options for MIC32 registers (if not already in mix.cfg)
EOPTIONS_MIC32   = -conf "reg_shell.type=E_VR_AD" -conf 'reg_shell.e_vr_ad.vplan_ref=MIC32 SCI Registers' -conf 'conn.req=optional'

# mix executable can be overridden for debugging
# MIX              = 	. /tools/Modules/default/init/bash; module unload msd; mix
# MIX              = mix
MIX              = mix_1.pl
RM               = rm -f

#
# Product-specific parameters
#
include scs_video_$(PRODUCT).mk

# DEPEND_GLOB = Makefile scs_io_$(PRODUCT).mk scs_vd_$(PRODUCT).mk scs_video_$(PRODUCT).mk
DEPEND_GLOB = Makefile scs_video_$(PRODUCT).mk

#
# User Targets
#
all: vlog_files e_files

vlog_files: ${PRFX}_scs_video_sci_scc.v

e_files: regdef_sci_scc.e

clean:
	-$(RM) mix.log e/*.e v/*.v mix.log rtl_libs.xml *.dat include/*.vh

#
# Subordinate targets - HDL register-shells
#

# SCC register-shells
${PRFX}_scs_video_sci_scc.v: SCC-register_master.xls mix.cfg $(DEPEND_GLOB)
	$(MIX) -conf 'reg_shell.clone.number=$(SCS_VIDEO_SCC_CLIENTS)' -conf 'reg_shell.regshell_prefix=$(PRFX)_scs_video'  $<

#
# Subordinate targets - e reg-files
#

# build all e regfiles, the e-code also uses a non-cloned regspace
regdef_sci_scc.e: SCC-register_master.xls mix.cfg
	$(MIX) -conf 'reg_shell.clone.number=0' $(EOPTIONS_MIC32) $<

#
# end
#
