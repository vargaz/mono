#
# This should be called before AC_OUTPUT, it takes one parameter, the list of
# Makefiles to generate
#
AC_DEFUN([MK_INIT],
[
	# Collect automake conditionals, and add a make var for them
	am_conditionals=
	if test x$enable_shared = xyes; then
	   am_conditionals="$am_conditionals enable_shared"
	fi
	if test x$enable_static = xyes; then
	   am_conditionals="$am_conditionals enable_static"
	fi
	for var in $ac_subst_vars; do
		# Each automake conditional is mapped to two autoconf vars named <cond>_TRUE and
		# <cond>_FALSE.
		if echo $var | grep -q '_TRUE$'; then
			cond=`echo $var | sed -e 's/_TRUE//g'`
			true_cond=$var
			false_cond=`echo $var | sed -e 's/_TRUE/_FALSE/g'`
			if echo $ac_subst_vars | grep -q $false_cond; then
				if test x${!true_cond} = x; then
					am_conditionals="$am_conditionals $cond"
				fi
			fi
		fi
	done

    # Create conf.mk.in
(
echo "abs_top_srcdir = @abs_top_srcdir@"
echo "abs_top_builddir = @abs_top_builddir@"
for var in $ac_subst_vars; do
  echo "$var = @$var@"
done
for var in $am_conditionals; do
  echo "$var = yes"
done
echo "include @abs_top_srcdir@/mk/pre.mk"
) > conf.mk.in

    conf_mk=conf.mk
  	AC_CONFIG_FILES([$conf_mk])

	# Create makefiles
	# This will run after automake overriding the Makefiles	
	AC_CONFIG_COMMANDS([mk], [
	for file in $makefiles; do
	   if test ! -f $file.am; then
	   	  echo "$file has no corresponding $file.am."
		  exit 1
	   fi   
	   # Convert automake conditionals to make conditionals
	   rm -f mk.tmp
	   sed -e 's,^if ,ifdef ,g' < $file.am > mk.tmp
	   sed -e 's,^else.*,else ,g' < mk.tmp > mk.tmp.2
	   sed -e 's,^endif.*,endif ,g' < mk.tmp.2 > mk.tmp
	   rm -f mk.tmp.2

	   mk_top_builddir=`echo $file | sed -e 's,[[^/]],,g' | sed -e 's,/,../,g'`
	   if test x$mk_top_builddir = x; then
	   	  mk_top_builddir=.
	   fi

	   rm -f $file

	   echo '#############################' >> $file
	   echo '#Generated by configure.in from Makefile.am, do not edit' >> $file
	   echo '#############################' >> $file
	   echo '' >> $file
	   echo "top_builddir = $mk_top_builddir" >> $file
	   echo 'include $(top_builddir)/conf.mk' >> $file
	   echo '' >> $file
	   echo '#############################' >> $file
	   echo '# <begin Makefile.am>' >> $file
	   echo '#############################' >> $file
	   echo '' >> $file
	   
	   cat mk.tmp >> $file

	   echo '' >> $file
	   echo '#############################' >> $file
	   echo '# <end Makefile.am>' >> $file
	   echo '#############################' >> $file
	   echo '' >> $file	   
	   echo 'include $(top_srcdir)/mk/rules.mk' >> $file

	   echo "[mk] $file"
	done
	], [makefiles="$1"])
])
