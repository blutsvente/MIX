
bin_PROGRAMS = mui

mui_SOURCES = \
	main.c \
	mix.c mix.h \
	mainwindow.c mainwindow.h \
	hiertree.c hiertree.h \
	iopadview.c iopadview.h \
	i2cview.c i2cview.h \
	callbacks.c callbacks.h \
        support.c support.h \
	settings.c settings.h \
	options.h

mui_CPPFLAGS = @PERL5_CCOPTS@

mui_LDADD = @GTK_LDFLAGS@ @PERL5_LDOPTS@ @GLIB_LDFLAGS@
