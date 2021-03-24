# override PREFIX, Scheme, and LIB as necessary
PREFIX=/usr

# scheme executable
Scheme=$(PREFIX)/bin/scheme

# target location for stex
LIB=$(PREFIX)/lib/stex$(shell head -n 1 src/VERSION)

m := $(shell echo '(machine-type)' | $(Scheme) -q)
ifeq ("$m","")
  $(error cannot determine machine-type for Scheme=$(Scheme))
endif

# installation owner
InstallOwner:=$(shell whoami)

# installation group
InstallGroup:=${InstallOwner}

Install=./sbin/install -o "${InstallOwner}" -g "${InstallGroup}"

exec = $m/scheme-prep $m/html-prep $m/fixbibtex

all: $(exec)

$m/scheme-prep: src/dsm.ss src/preplib.ss src/script.ss src/scheme-prep.ss src/VERSION
	if [ ! -d $m ] ; then mkdir $m ; fi
	sed -e 's;^#! /usr/bin/scheme --program;#! $(Scheme) --program;' src/scheme-prep.ss > $m/scheme-prep.ss
	echo '(reset-handler abort) (library-directories (quote "src::$m")) (compile-imported-libraries #t) (generate-wpo-files #t) (compile-program "$m/scheme-prep.ss") (compile-whole-program "$m/scheme-prep.wpo" "$m/scheme-prep")' | $(Scheme) -q
	chmod 755 $m/scheme-prep

$m/html-prep: src/dsm.ss src/preplib.ss src/script.ss src/html-prep.ss src/VERSION
	if [ ! -d $m ] ; then mkdir $m ; fi
	sed -e 's;^#! /usr/bin/scheme --program;#! $(Scheme) --program;' src/html-prep.ss > $m/html-prep.ss
	echo '(reset-handler abort) (library-directories (quote "src::$m")) (compile-imported-libraries #t) (generate-wpo-files #t) (compile-program "$m/html-prep.ss") (compile-whole-program "$m/html-prep.wpo" "$m/html-prep")' | $(Scheme) -q
	chmod 755 $m/html-prep

$m/fixbibtex: src/script.ss src/fixbibtex.ss src/VERSION
	-if [ ! -d $m ] ; then mkdir $m ; fi
	sed -e 's;^#! /usr/bin/scheme --program;#! $(Scheme) --program;' src/fixbibtex.ss > $m/fixbibtex.ss
	echo '(reset-handler abort) (library-directories (quote "src::$m")) (compile-imported-libraries #t) (generate-wpo-files #t) (compile-program "$m/fixbibtex.ss") (compile-whole-program "$m/fixbibtex.wpo" "$m/fixbibtex")' | $(Scheme) -q
	chmod 755 $m/fixbibtex

install: $(exec)
	$(Install) -m 755 -d $(LIB)
	$(Install) -m 755 -d $(LIB)/inputs
	$(Install) -m 644 inputs/* $(LIB)/inputs
	$(Install) -m 755 -d $(LIB)/gifs
	$(Install) -m 644 gifs/* $(LIB)/gifs
	$(Install) -m 755 -d $(LIB)/math
	$(Install) -m 644 math/* $(LIB)/math
	$(Install) -m 755 -d $(LIB)/$m
	$(Install) -m 755 $(exec) $(LIB)/$m
	$(Install) -m 644 Mf-stex $(LIB)/Mf-stex
	sed -e 's;^STEXLIB=.*;STEXLIB=$(LIB);' Makefile.template > Makefile.template.out
	$(Install) -m 644 Makefile.template.out $(LIB)/Makefile.template

uninstall:
	/bin/rm -rf $(LIB)

clean:
	/bin/rm -f Make.out Makefile.template.out

distclean: clean
	/bin/rm -rf $m
