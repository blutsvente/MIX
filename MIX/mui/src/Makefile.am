## Process this file with automake to produce Makefile.in

INCLUDES = \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	@PACKAGE_CFLAGS@

bin_PROGRAMS = mui

mui_SOURCES = \
	main.c \
	support.c support.h \
	user-interface.c user-interface.h \
	callbacks.c callbacks.h \
	mix-interface.c mix-interface.h \
	files.c	files.h

mui_LDADD = @PACKAGE_LIBS@ $(INTLLIBS)

