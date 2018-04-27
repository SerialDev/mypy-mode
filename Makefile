EMACS ?= emacs
CASK ?= cask

all: test

test: clean
	${MAKE} unit
	${MAKE} compile
	${MAKE} clean

unit:
	${CASK} exec ert-runner

compile:
	${CASK} exec ${EMACS} -Q -batch -f batch-byte-compile sdev-mypy.el

clean:
	rm -f sdev-mypy.elc

.PHONY:        all test unit compile clean
