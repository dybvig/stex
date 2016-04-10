VERSION=1.1

# location of scheme or petite executable
BIN=/usr/bin

# target location for stex
LIB=/usr/lib/stex$(VERSION)

Scheme = $(shell if [ -e $(BIN)/scheme ]; then echo $(BIN)/scheme; else echo $(BIN)/petite; fi)
m := $(shell echo '(machine-type)' | $(Scheme) -q)

Install=./sbin/install

exec = $m/scheme-prep $m/html-prep $m/fixbibtex

all: $(exec)

$m/scheme-prep: src/dsm.ss src/preplib.ss src/scheme-prep.ss
	if [ ! -d $m ] ; then mkdir $m ; fi
	sed -e 's;^#! /usr/bin/petite --program;#! $(Scheme) --program;' src/scheme-prep.ss > $m/scheme-prep.ss
ifeq "$(Scheme)" "$(BIN)/scheme"
	echo '(reset-handler abort) (source-directories (quote ("src"))) (compile-program "$m/scheme-prep.ss" "$m/scheme-prep")' | $(Scheme) -q
else
	echo '(reset-handler abort) (source-directories (quote ("src"))) (expand-script "$m/scheme-prep.ss" "$m/scheme-prep")' | $(Scheme) -q expand-script.ss
endif
	chmod 711 $m/scheme-prep

$m/html-prep: src/dsm.ss src/preplib.ss src/html-prep.ss
	if [ ! -d $m ] ; then mkdir $m ; fi
	sed -e 's;^#! /usr/bin/petite --program;#! $(Scheme) --program;' src/html-prep.ss > $m/html-prep.ss
ifeq "$(Scheme)" "$(BIN)/scheme"
	echo '(reset-handler abort) (source-directories (quote ("src")))(compile-program "$m/html-prep.ss" "$m/html-prep")' | $(Scheme) -q
else
	echo '(reset-handler abort) (source-directories (quote ("src")))(expand-script "$m/html-prep.ss" "$m/html-prep")' | $(Scheme) -q expand-script.ss
endif
	chmod 711 $m/html-prep

$m/fixbibtex: src/fixbibtex.ss
	-if [ ! -d $m ] ; then mkdir $m ; fi
	sed -e 's;^#! /usr/bin/petite --program;#! $(Scheme) --program;' src/fixbibtex.ss > $m/fixbibtex.ss
ifeq "$(Scheme)" "$(BIN)/scheme"
	echo '(reset-handler abort) (source-directories (quote ("src")))(compile-program "$m/fixbibtex.ss" "$m/fixbibtex")' | $(Scheme) -q
else
	echo '(reset-handler abort) (source-directories (quote ("src")))(expand-script "$m/fixbibtex.ss" "$m/fixbibtex")' | $(Scheme) -q expand-script.ss
endif
	chmod 755 $m/fixbibtex

install: $(exec)
	$(Install) -o root -g root -m 755 -d $(LIB)
	$(Install) -o root -g root -m 755 -d $(LIB)/inputs
	$(Install) -o root -g root -m 644 inputs/* $(LIB)/inputs
	$(Install) -o root -g root -m 755 -d $(LIB)/gifs
	$(Install) -o root -g root -m 644 gifs/* $(LIB)/gifs
	$(Install) -o root -g root -m 755 -d $(LIB)/math
	$(Install) -o root -g root -m 644 math/* $(LIB)/math
	$(Install) -o root -g root -m 755 -d $(LIB)/$m
	$(Install) -o root -g root -m 644 $(exec) $(LIB)/$m
	(umask 022; sed -e 's;^LIB=.*;LIB=$(LIB);' Mf-stex > $(LIB)/Mf-stex)
	(umask 022; sed -e 's;include ~/stex/Mf-stex;include $(LIB)/Mf-stex;' Makefile.template > $(LIB)/Makefile.template)

uninstall:
	/bin/rm -rf $(LIB)

clean:
	/bin/rm -f Make.out

distclean: clean
	/bin/rm -rf $m
