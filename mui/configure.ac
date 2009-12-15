AC_INIT([mui], [0.0.1], [alexander.bauer@micronas.com])
AM_INIT_AUTOMAKE(AC_PACKAGE_NAME, AC_PACKAGE_VERSION)

AC_CONFIG_HEADER([src/config.h])

AC_PREREQ(2.59)
AC_CONFIG_SRCDIR([src/main.c])


AC_PROG_CC
LIBTOOL="$LIBTOOL --silent"
AC_PROG_INSTALL


#----------------------------------------------------------------
# Check for Perl5
#----------------------------------------------------------------

PERLBIN=

AC_ARG_WITH(perl5,[  --with-perl5=path       Set location of Perl5 executable],[ PERLBIN="$withval"], [PERLBIN=])

# First figure out what the name of Perl5 is
if test -z "$PERLBIN"; then
AC_CHECK_PROGS(PERL, perl perl5.6.1 perl5.6.0 perl5.004 perl5.003 perl5.002 perl5.001 perl5 perl)
else
PERL="$PERLBIN"
fi

AC_MSG_CHECKING(for Perl5 ccopts)
PERL5_CCOPTS=`$PERL -MExtUtils::Embed -e ccopts`
if test "$PERL5_CCOPTS" = "" ; then
AC_MSG_RESULT(not found)
else
AC_MSG_RESULT($PERL5_CCOPTS)
fi

AC_MSG_CHECKING(for Perl5 ldopts)
PERL5_LDOPTS=`$PERL -MExtUtils::Embed -e ldopts`
if test "$PERL5_LDOPTS" = "" ; then
AC_MSG_RESULT(not found)
else
AC_MSG_RESULT($PERL5_LDOPTS)
fi

AC_SUBST(PERL)
AC_SUBST(PERL5_LDOPTS)
AC_SUBST(PERL5_CCOPTS)

#----------------------------------------------------------------
# Check for pkg-config
#----------------------------------------------------------------

AC_PATH_PROG(PKG_CONFIG, pkg-config)
if test "$PKG_CONFIG" = "" ; then
    AC_MSG_ERROR([*** could not find the pkg-config utility ***
            *** please install the pkg-config package ***])
fi

#----------------------------------------------------------------
# Check for gtk+-2.0 using pkg-config
#----------------------------------------------------------------

AC_SUBST(GTK_LDFLAGS, [`$PKG_CONFIG --libs gtk+-2.0`])
if test "$GTK_LDFLAGS" = ""; then
    AC_MSG_ERROR([*** could not find pkg-config info for the gtk+-2.0 library ***
    *** please check that gtk+ 2 is installed])
fi

AC_SUBST(GLIB_LDFLAGS, [`$PKG_CONFIG --libs glib-2.0`])
if test "$GLIB_LDFLAGS" = ""; then
    AC_MSG_ERROR([*** could not find pkg-config info for the glib-2.0 library ***
    *** please check that glib-2 is installed])
fi

AC_SUBST(CPPFLAGS, "$CPPFLAGS `$PKG_CONFIG --cflags-only-I gtk+-2.0`")

AC_CHECK_HEADER([gtk/gtk.h],
    AC_SUBST(GTK_INCLUDE),
    AC_MSG_ERROR([*** gtk.h header file not found ***
            please verify that gtk+-2.0 is installed***]))

AC_CHECK_HEADER([glib.h],
    AC_SUBST(GTK_INCLUDE),
    AC_MSG_ERROR([*** glib.h header file not found ***
            please verify that glib-2.0 is installed***]))
			
# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h string.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_CONST
AC_C_INLINE
AC_TYPE_SIZE_T
AC_HEADER_TIME

# Checks for library functions.
AC_FUNC_MALLOC

AC_CONFIG_FILES([Makefile
                 src/Makefile])
AC_OUTPUT

echo
echo
echo Package: $PACKAGE-$VERSION
echo
echo
echo PERL: $PERL
echo
echo PERL5_CCOPTS: $PERL5_CCOPTS
echo
echo PERL5_LDOPTS: $PERL5_LDOPTS
echo
echo GTK_LDFLAGS: $GTK_LDFLAGS
echo
echo GLIB_LDFLAGS: $GLIB_LDFLAGS
echo
echo configure complete, now type \'make\' to compile
echo
