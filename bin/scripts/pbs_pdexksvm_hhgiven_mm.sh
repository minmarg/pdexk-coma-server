#!/bin/bash

###############################################################
#                                                             #
#    Shell script for submitting a MPICH parallel job to the  #
#    PBS queue at Vilkas using the qsub command.              #
#                                                             #
###############################################################

#     Remarks: A line beginning with # is a comment.
#              A line beginning with #PBS is a PBS directive.
#              PBS directives must come first; any directives
#                 after the first executable statement are ignored.
#
   
##########################
#                        #
#   The PBS directives   #
#                        #
##########################

#          Set the name of the job (up to 15 characters, 
#          no blank spaces, start with alphanumeric character)

#PBS -N pbs_pdexksvm

#          By default, the standard output and error streams are sent
#          to files in the current working directory with names:
#              job_name.osequence_number  <-  output stream
#              job_name.esequence_number  <-  error stream
#          where job_name is the name of the job and sequence_number 
#          is the job number assigned when the job is submitted.
#          Use the directives below to change the files to which the
#          standard output and error streams are sent.

#    #PBS -o stdout_file
#    #PBS -e stderr_file

#          The directive below directs that the standard output and
#          error streams are to be merged, intermixed, as standard
#          output. 

#PBS -j oe

#          Specify the maximum cpu and wall clock time.
#          Format:   hhhh:mm:ss   hours:minutes:seconds
#          Be sure to specify a reasonable value here.
#          If the job does not finish by the time reached,
#          the job is terminated.


#PBS -l walltime=90:00:00

#PBS -l cput=90:00:00

#PBS -l mem=62mb

#          PBS can send informative email messages to you about the
#          status of your job.  Specify a string which consists of
#          either the single character "n" (no mail), or one or more
#          of the characters "a" (send mail when job is aborted),
#          "b" (send mail when job begins), and "e" (send mail when
#          job terminates).  The default is "a" if not specified.
#          You should also specify the email address to which the
#          message should be send via the -M option.


## -------------------------------------------------------------------

## To request more than one node and more than one CPU has only sense
## when MPI processes are to be launched
##

#PBS -l nodes=1:ppn=1

prefix=/home/mindaugas/projects/svm-PDEXK-200712/minlag
HHSEARCHLOC=/usr/local/install/HHsearch/HHsearch1.5.0

PRO_DATABASE=$prefix/data/output/scop_pdexk.database
POSITIONS=$prefix/data/input/positions.list
CLASSIFIERS=$prefix/data/output/classifiers
PDEXK_HHM=$prefix/data/output/scop_pdexk.hhm_list

VERBOSE_MODE=1

TMP_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.tmp

#Input 
INPUT_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.fas
PARAM_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.par

#Logs
LOG_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.log
ERR_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.err

#HHsearch output
MSA_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.a3m
MSA_FASTA_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.fasta
#touch $MSA_FASTA_FILE
PRO_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.hhm
OUT_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.out
#touch $OUT_FILE
FILT_A3M_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.filt_a3m
FILT_FAS_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.filt_fas

#PDEXK SVM Perl toolkit output
ALN_FILE_TMP=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.aln_tmp
ALN_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.aln
#Default message
#echo ">No_PDEXK" > $ALN_FILE;
#echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" >> $ALN_FILE;

#SVM output
HHM_LIST_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.hhm_list

#SVM classification directory
SVM_DIR=$PBS_PDEXKSVM_DIR/svm_classification
#mkdir -p $SVM_DIR 1>> $LOG_FILE 2>> $ERR_FILE
SVM_OUT_FILE=$PBS_PDEXKSVM_DIR/$PBS_PDEXKSVM_ID.svm
#touch $SVM_OUT_FILE

#Checking input format
INPUT_FORMAT=`grep -P "INPUT_TYPE" $PARAM_FILE | awk -F '=' '{print $2}'`;
SEARCH_STRATEGY=`grep -P "SEARCH_STRATEGY" $PARAM_FILE | awk -F '=' '{print $2}'`;

#Building MSA ==============================================================================================
#if [[ "$INPUT_FORMAT" = "fasta" ]];
#then
#    if [[ "$SEARCH_STRATEGY" = "NO_PSI_BLAST" ]];
#    then
#	$HHSEARCHLOC/addpsipred.pl $INPUT_FILE -fas 1>> $LOG_FILE 2>> $ERR_FILE;
#    else
#	$HHSEARCHLOC/buildali.pl $INPUT_FILE -fas -v $VERBOSE_MODE 1>> $LOG_FILE 2>> $ERR_FILE;
#    fi
#else
#    echo "ERR: Cannot recognize input file format: $INPUT_FORMAT!" >> $ERR_FILE;
#fi;
#End of building MSA =======================================================================================

if [[ -e "$MSA_FILE" ]];
then
    #Making profile
#    $HHSEARCHLOC/hhmake -i $MSA_FILE -v $VERBOSE_MODE 1>> $LOG_FILE 2>> $ERR_FILE
    #Converting final MSA to fasta
#    $HHSEARCHLOC/reformat.pl a3m fas $MSA_FILE $MSA_FASTA_FILE 1>> $LOG_FILE 2>> $ERR_FILE

    if [[ -e "$PRO_FILE" ]];
    then
	#Searching
#	$HHSEARCHLOC/hhsearch -i $PRO_FILE -d $PRO_DATABASE -v $VERBOSE_MODE -o $OUT_FILE -ssm 4 1>> $LOG_FILE 2>> $ERR_FILE
	#Filtering
#	$HHSEARCHLOC/hhfilter -i $MSA_FILE -o $FILT_A3M_FILE -id 90 -cov 0 -qid 0 -qsc -20.00 -diff 100 1>> $LOG_FILE 2>> $ERR_FILE
	#Converting to FASTA
#	$HHSEARCHLOC/reformat.pl a3m fas $FILT_A3M_FILE $FILT_FAS_FILE 1>> $LOG_FILE 2>> $ERR_FILE
	#Making alignment of the alignments
#	${prefix}/scripts/hhsvm/SequenceAligner -i $OUT_FILE -m $PRO_FILE -f $FILT_FAS_FILE -p $POSITIONS -l 2 -n 3 > $ALN_FILE_TMP 2>> $ERR_FILE
#	ALN_FILE_TMP_CONTENT=`cat $ALN_FILE_TMP`;
#	if [[ "$ALN_FILE_TMP_CONTENT" != "" ]];
#	then
#	    ${prefix}/scripts/hhsvm/FragmentCutter -f $ALN_FILE_TMP -m -o -n > $ALN_FILE 2>> $ERR_FILE
#	fi;

	#Classification ===========================================================================================
#	ls $PRO_FILE > $HHM_LIST_FILE 2>> $ERR_FILE

        rm -f $SVM_DIR/* ##{{MM}}
        cat /dev/null >$SVM_OUT_FILE ##{{MM}}
        cat /dev/null >$SVM_OUT_FILE ##{{MM}}

	for i in $CLASSIFIERS/*.mdl; 
	do 
	  BASENAME=`basename $i .mdl`;
	  CLASSIFICATION_PARAMS=`cat $CLASSIFIERS/$BASENAME.params`;
	  ${prefix}/scripts/hhsvm/SVMPositiveData -i $OUT_FILE \
	                                          -p $POSITIONS \
	                                          -q $HHM_LIST_FILE \
                                                  -t $PDEXK_HHM \
                                                     $CLASSIFICATION_PARAMS \
                                                  -m "test" > $SVM_DIR/$BASENAME.svm_comm 2>> $ERR_FILE;
	  awk -F ' #' '{print $1}' $SVM_DIR/$BASENAME.svm_comm > $SVM_DIR/$BASENAME.svm 2>> $ERR_FILE;
	  ${prefix}/software/libsvm-infensemble-2.8/svm-scale -r $CLASSIFIERS/$BASENAME.norm_par $SVM_DIR/$BASENAME.svm > $SVM_DIR/$BASENAME.scaled 2>> $ERR_FILE;
	  ${prefix}/software/libsvm-infensemble-2.8/svm-predict -b 1 $SVM_DIR/$BASENAME.scaled $i $SVM_DIR/$BASENAME.out 1>> $LOG_FILE 2>> $ERR_FILE;

	  DESCRIPTION=`cat $CLASSIFIERS/$BASENAME.desc`;
	  PROBABILITY=`${prefix}/scripts/hhsvm/ResultsAnalysator $SVM_DIR/$BASENAME.out | awk -F ' ' '{print $3}'`;
	  echo "$BASENAME training_acc:$DESCRIPTION predicted_prob:$PROBABILITY" >> $SVM_OUT_FILE 2>> $ERR_FILE;
	done;
	#End of classification =======================================================================================
    else
	echo "ERR: Profile creation failed!" >> $ERR_FILE
    fi;
else
    echo "ERR: Multiple sequence alignment creation failed!" >> $ERR_FILE
fi

exit 0

