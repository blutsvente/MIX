##############################################################
#              MIX-Documentation Makefile
##############################################################

TEX = pdflatex

ARCHIVER = tar

all: userref develdoc

userref: MIX_Userreference.tex
	$(TEX) $<

develdoc: MIX_Development_doc.tex
	$(TEX) $<

i2cdoc: MIX-I2C-Spec.tex
	$(TEX) $<

clean:
	del *~ *.aux *.dvi *.log *.toc
