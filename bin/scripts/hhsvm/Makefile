# When 'make test' is invoked, a TARGET executable will be run for
# every file in inputs that has extension ${EXT}. The outputs will be
# compared with the sample outputs files in ./outputs/*${OUT}, and any
# differences will be recorded in ./outputs/*${DIFF} #

# ==============================================================================
# $Author: Mindaugas.Laganeckas $
# $Date: 2009-03-10 14:54:18 +0200 (Tue, 10 Mar 2009) $
# $Revision: 2 $
# $HeadURL: http://pdexkperltoolkit.googlecode.com/svn/trunk/hhsvm/Makefile $
# ==============================================================================


OPT		       = .opt
OUT		       = .out
DIFF		   = .diff

OUTPUT_DIR     = ./outputs
SCRIPT_TST_DIR = ./tests

SCRIPT_TESTS   = ${wildcard ${SCRIPT_TST_DIR}/*${OPT}}
SCRIPT_OUTPUTS = ${SCRIPT_TESTS:${SCRIPT_TST_DIR}/%${OPT}=${OUTPUT_DIR}/%${OUT}}
SCRIPT_DIFFS   =${SCRIPT_TESTS:${SCRIPT_TST_DIR}/%${OPT}=${OUTPUT_DIR}/%${DIFF}}

#------------------------------------------------------------------------------

.PHONY: outputs tests clean cleanAll listdiff

.PHONY: o t c l all
all: tests
o: outputs
t: tests
c: clean
l: listdiff

tests: ${SCRIPT_DIFFS}

${OUTPUT_DIR}/%${DIFF}: ${SCRIPT_TST_DIR}/%${OPT}
	-@printf "%-60s " "$<:" ; \
	./$(shell echo $* | sed -e 's/_[0-9]*$$//') \
	    $(shell grep -v '^#' ${word 1, $<}) \
	2>&1 \
	| diff ${OUTPUT_DIR}/$*${OUT} - > $@ ; \
	if [ $$? = 0 ]; then echo "OK"; else echo "FAILED:"; cat $@; fi

outputs: ${SCRIPT_OUTPUTS}

${OUTPUT_DIR}/%${OUT}: ${SCRIPT_TST_DIR}/%${OPT}
	-@test -f $@ || echo "$@:"
	-@test -f $@ || \
	./$(shell echo $* | sed -e 's/_[0-9]*$$//') \
	    $(shell grep -v '^#' ${word 1, $<}) \
	2>&1 \
	| tee $@
	-@touch $@

listdiff:

	@-( test -d ${OUTPUT_DIR} && \
	    ls -l ${OUTPUT_DIR}/*${DIFF} | awk '{if( $$5 > 0 ) print}' ) || \
	    true

#------------------------------------------------------------------------------

clean:
	rm -f *~
	rm -f ${SCRIPT_DIFFS}
cleanAll: clean
	rm -f ${SCRIPT_OUTPUTS}

