#!/bin/bash

echo "Update sarted:";
date;
echo "===============================================================";
PREFIX=/home/coma/bin

INPUT=$PREFIX/data/input
OUTPUT=$PREFIX/data/output

SOFTWARE=$PREFIX/software
SCRIPTS=$PREFIX/scripts

HERE=`pwd`
VERBOSE_MODE=1
POSITIONS=$INPUT/positions.list
## Creates PDEXK profiles
PDEXK_HHM=$OUTPUT/PDEXK_hhm


#rm -fr $PDEXK_HHM
#mkdir $PDEXK_HHM

#for i in `cat $INPUT/pdexk_in_scop.list`;
#do
#  if [[ -f "$INPUT/scop_hhm/$i.hhm" ]];
#  then
#      cp $INPUT/scop_hhm/$i.hhm $PDEXK_HHM/.;
#  else
#      echo "ERR: can't find $INPUT/scop_hhm/$i.hhm.";
#  fi;
#done;

#cd $PDEXK_HHM;
#for i in $INPUT/pdexk_seq_not_in_scop/*.seq;
#do
#  B=`basename $i .seq`;
#  cp $i .;
#  $SOFTWARE/hhsearch/buildali.pl $B.seq -v $VERBOSE_MODE;
#  $SOFTWARE/hhsearch/hhmake -i $B.a3m -v $VERBOSE_MODE;
#done;
#cd $HERE;
# End of creation PDEXK profiles
## Creates negative data profiles
NEGATIVE_HHM=$OUTPUT/negative_hhm

#rm -fr $NEGATIVE_HHM
#mkdir $NEGATIVE_HHM

#cd $NEGATIVE_HHM;
#for i in $INPUT/negative_seq/*.seq;
#do
#  B=`basename $i .seq`;
#  cp $i .;
#  $SOFTWARE/hhsearch/buildali.pl $B.seq -v $VERBOSE_MODE;
#  $SOFTWARE/hhsearch/hhmake -i $B.a3m -v $VERBOSE_MODE;
#done;
#cd $HERE;
# End of creation negative data profiles
## Profile database and HHM list creation
PROFILE_DATABASE=$OUTPUT/scop_pdexk.database
#cat $INPUT/scop_hhm/*.hhm > $PROFILE_DATABASE;

#for i in $INPUT/pdexk_seq_not_in_scop/*.seq;
#do
#  B=`basename $i .seq`;
#  cat $PDEXK_HHM/$B.hhm >> $PROFILE_DATABASE;
#done;

SCOP_PDEXK_HHM_LIST=$OUTPUT/scop_pdexk.hhm_list;
#ls $INPUT/scop_hhm/*.hhm > $SCOP_PDEXK_HHM_LIST;
#ls $PDEXK_HHM/*.hhm >> $SCOP_PDEXK_HHM_LIST;

NEGATIVE_HHM_LIST=$OUTPUT/negative.hhm_list;
#ls $NEGATIVE_HHM/*.hhm > $NEGATIVE_HHM_LIST;
# End of profile database and HHM list creation
## Profile comparison
SCOP_PDEXK_OUT=$OUTPUT/scop_pdexk_out

#rm -fr $SCOP_PDEXK_OUT;
#mkdir $SCOP_PDEXK_OUT;

#cd $SCOP_PDEXK_OUT;
#for i in $PDEXK_HHM/*.hhm; 
#do
#  B=`basename $i .hhm`;
#  $SOFTWARE/hhsearch/hhsearch -i $i -d $PROFILE_DATABASE -o $B.out -ssm 4 -v $VERBOSE_MODE;
#done;
#cd $HERE;

NEGATIVE_OUT=$OUTPUT/negative_out

#rm -fr $NEGATIVE_OUT;
#mkdir $NEGATIVE_OUT;

#cd $NEGATIVE_OUT;
#for i in $NEGATIVE_HHM/*.hhm; 
#do
#  B=`basename $i .hhm`;
#  $SOFTWARE/hhsearch/hhsearch -i $i -d $PROFILE_DATABASE -o $B.out -ssm 4 -v $VERBOSE_MODE;
#done;
#cd $HERE;

# End of profile cmparison
#=========================================================================
# A function to train SVM
function TRAIN_SVM 
{
    local USE_E_POS=$1;
    local LOWER_THRESHOLD=$2;
    local UPPER_THRESHOLD=$3;
    local OUTPUT=$4;
    local NAME=$5;
    local SVM_PATH=$6;

    local POSITIVE_LBL=1;
    local NEGATIVE_LBL=2;
    
    for i in $SCOP_PDEXK_OUT/*.out;
      do
      $SCRIPTS/hhsvm/SVMNegativeData -i $i \
	  -p $POSITIONS \
	  -q $SCOP_PDEXK_HHM_LIST \
	  -t $SCOP_PDEXK_HHM_LIST \
	  -c $NEGATIVE_LBL \
	  -n 1 \
	  $USE_E_POS;
    done > $OUTPUT/$NAME.negative_comm;  

    if [[ -n "$(find $NEGATIVE_OUT -name '*.out' )" ]]; then
      for i in $NEGATIVE_OUT/*.out;
        do
        $SCRIPTS/hhsvm/SVMPositiveData -i $i \
	    -p $POSITIONS \
	    -q $NEGATIVE_HHM_LIST \
	    -t $SCOP_PDEXK_HHM_LIST \
	    -c $NEGATIVE_LBL \
	    -n 1 \
	    $USE_E_POS;
      done >> $OUTPUT/$NAME.negative_comm;
    fi

    for i in $SCOP_PDEXK_OUT/*.out;
      do
      $SCRIPTS/hhsvm/SVMPositiveData -i $i \
	  -p $POSITIONS \
	  -q $SCOP_PDEXK_HHM_LIST \
	  -t $SCOP_PDEXK_HHM_LIST \
	  -l $LOWER_THRESHOLD \
	  -u $UPPER_THRESHOLD \
	  -m "train" \
	  -c $POSITIVE_LBL \
	  -n 1 \
	  $USE_E_POS;
    done > $OUTPUT/$NAME.positive_comm;
  
    cat $OUTPUT/$NAME.positive_comm $OUTPUT/$NAME.negative_comm > $OUTPUT/$NAME.data_comm;
    awk -F ' #' '{print $1}' $OUTPUT/$NAME.data_comm > $OUTPUT/$NAME.data;
    
    $SVM_PATH/svm-scale -s $OUTPUT/$NAME.norm_par $OUTPUT/$NAME.data > $OUTPUT/$NAME.scaled;
    $SVM_PATH/svm-train -t 5 -v 10 -c 2 $OUTPUT/$NAME.scaled > $OUTPUT/$NAME.train_info;
    
    $SVM_PATH/svm-train -t 5 -b 1 -c 2 $OUTPUT/$NAME.scaled $OUTPUT/$NAME.mdl;
    echo "-n 1 $USE_E_POS" > $OUTPUT/$NAME.params;
    grep "Cross Validation Accuracy" $OUTPUT/$NAME.train_info | awk -F ' ' '{print $5}' > $OUTPUT/$NAME.desc;
}  
# End of function
#=========================================================================
# Creates classificators
CLASSIFIERS=$OUTPUT/classifiers
rm -fr $CLASSIFIERS;
mkdir $CLASSIFIERS;

TRAIN_SVM "-e 0" \
    50 \
    100 \
    $CLASSIFIERS \
    SVM-1 \
    $SOFTWARE/libsvm-infensemble-2.8;

TRAIN_SVM "-e 1" \
    50 \
    100 \
    $CLASSIFIERS \
    SVM-2 \
    $SOFTWARE/libsvm-infensemble-2.8;

TRAIN_SVM "-e 0" \
    70 \
    100 \
    $CLASSIFIERS \
    SVM-3 \
    $SOFTWARE/libsvm-infensemble-2.8;

TRAIN_SVM "-e 1" \
    70 \
    100 \
    $CLASSIFIERS \
    SVM-4 \
    $SOFTWARE/libsvm-infensemble-2.8;

TRAIN_SVM "-e 1" \
    80 \
    100 \
    $CLASSIFIERS \
    SVM-5 \
    $SOFTWARE/libsvm-infensemble-2.8;
echo "===============================================================";
echo "Update finished:";
date;
