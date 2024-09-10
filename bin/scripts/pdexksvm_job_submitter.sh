#!/bin/bash

ID=$1;
DIR=$2;

SCRIPT=/home/coma/bin/scripts/pbs_pdexksvm.sh

cd $DIR;

qsub -v PBS_PDEXKSVM_ID=$ID,PBS_PDEXKSVM_DIR=$DIR $SCRIPT
