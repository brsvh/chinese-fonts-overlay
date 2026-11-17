AC_PREREQ([2.69])
AC_INIT([chinese-fonts-site], [0.1.0],
        [https://github.com/brsvh/chinese-fonts-overlay/issues])
AC_CONFIG_SRCDIR([module/chinese-fonts-overlay-site/command.scm])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE([foreign 1.16 subdir-objects dist-xz no-dist-gzip])
AC_PROG_CC
PKG_PROG_PKG_CONFIG
PKG_CHECK_MODULES([FONT],
                  [pangocairo pangofc fontconfig cairo freetype2 glib-2.0])
AC_PATH_PROG([GUILE], [guile])
AS_IF([test -z "$GUILE"], [AC_MSG_ERROR([Guile 3 is required])])
AC_MSG_CHECKING([for Guile 3, guile-json and guile-gcrypt])
AS_IF(["$GUILE" --no-auto-compile -c '
        (use-modules (json) (gcrypt hash))
        (exit (string-prefix? "3." (version)))'],
      [AC_MSG_RESULT([yes])],
      [AC_MSG_ERROR([Guile 3 with guile-json and guile-gcrypt is required])])
AC_PATH_PROG([HOOT], [hoot])
AS_IF([test -z "$HOOT"], [AC_MSG_ERROR([Guile Hoot is required])])
AC_ARG_VAR([CATALOG], [evaluated public font catalog JSON])
AC_ARG_VAR([PREVIEWS], [private font renderer input JSON])
AC_ARG_VAR([SOURCE_ROOT],
           [repository checkout for source permalinks and metadata updates])
AC_ARG_VAR([SOURCE_REVISION],
           [full source commit SHA, required without a Git checkout])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
