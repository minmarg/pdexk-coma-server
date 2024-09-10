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

#PBS -N pbs_pdexkrec_update

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

#PBS -l mem=612mb

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

PREFIX=/home/coma/bin

$PREFIX/scripts/pdexkrec_update.sh >& $PREFIX/scripts/update-`date +%Y-%m-%d`.log

exit 0

