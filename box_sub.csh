#!/bin/tcsh
#
# richardd, 7 Oct 11
#
# converted to tcsh, 17 Oct 11
#
# example PBS script for berserker
#
# put this script in the same directory as the program
# you want to run.
#
# set the name of the job
##PBS -N jj_mix_1e14.5
#
# set the output and error files

## CHANGE END OF PATH HERE!
#PBS -o /data/navah/bb_output/z_group_dd_full_70/$PBS_JOBNAME/e_out0.txt
#PBS -e /data/navah/bb_output/z_group_dd_full_70/$PBS_JOBNAME/e_err0.txt
#PBS -m abe -M navah@uchicago.edu
# set the number of nodes to use, and number of processors
# to use per node


###PBS -l nodes=compute-1-6:ppn=1

# in this example, I'm using the intel compilers and mvapich2
#
# bring in the module settings

sleep 10s
source /etc/profile.d/modules.csh
module load intel/intel-12
module load mpi/mvapich2/intel




# model parameters go here i guess
set PARAM_TEMP     = '100'

set PARAM_TRA      = '11.00'
set PARAM_XB       = '-2.00'
set PARAM_EXP      = '2.0e-4'
# set PARAM_EXP      = '0.0'
set PARAM_EXP1     = '1.0e-15'

set PARAM_SW_DIFF  = '11.0'

set PARAM_REACT_TEMP = '70.0'

#set PARAM_Q = '1.0'
#set PARAM_T_DIFF = '11.5'


## CHANGE END OF PATH HERE!
set PARAM_PATH = '/data/navah/bb_output/z_group_dd_full_70/'$PBS_JOBNAME'/'

echo $PARAM_PATH
# set PROGNAME to the name of your program
set PROGNAME=basalt_box

# figure out which mpiexec to use
set LAUNCH=/usr/mpi/intel/openmpi-1.4.3-qlc/bin/mpirun

# working directory
set WORKDIR=${HOME}
# set WORKDIR=/data/navah/summer16/basalt_box
set WORKDIR=/home/navah/basalt_box

set NCPU=`wc -l < $PBS_NODEFILE`
set NNODES=`uniq $PBS_NODEFILE | wc -l`
# set this to zero to turn OFF debugging, 1 to turn it on
set PERMDIR=${HOME}
set SERVPERMDIR=${PBS_O_HOST}:${PERMDIR}

set DEBUG=1
if ( $DEBUG ) then
	echo ------------------------------------------------------
	echo ' This job is allocated on '${NCPU}' cpu(s)'
	echo 'Job is running on node(s): '
	cat $PBS_NODEFILE
	echo ------------------------------------------------------
	echo PBS: qsub is running on $PBS_O_HOST
	echo PBS: originating queue is $PBS_O_QUEUE
	echo PBS: executing queue is $PBS_QUEUE
	echo PBS: working directory is $PBS_O_WORKDIR
	echo PBS: execution mode is $PBS_ENVIRONMENT
	echo PBS: job identifier is $PBS_JOBID
	echo PBS: job name is $PBS_JOBNAME
	echo PBS: node file is $PBS_NODEFILE
	echo PBS: number of nodes is $NNODES
	echo PBS: current home directory is $PBS_O_HOME
	echo PBS: PATH = $PBS_O_PATH
	echo ------------------------------------------------------
	echo workdir is $WORKDIR
	echo permdir is $PERMDIR
	echo servpermdir is $SERVPERMDIR
	echo ------------------------------------------------------
	echo 'Job is running on node(s): '
	cat $PBS_NODEFILE
	echo ------------------------------------------------------
	echo ${LAUNCH} -n {$NCPU} -f ${PBS_NODEFILE} ${WORKDIR}/${PROGNAME}
	echo ' '
	echo ' '
endif

echo $NCPU
echo $PBS_NODEFILE
echo $PARAM_PATH

# run the program

# set SCRDIR=/state/partition1/navah/${PBS_JOBID}/
# mkdir -p $SCRDIR
#
#
# cd $SCRDIR
cd ${WORKDIR}
#echo $PARAM_PATH'secondary_mat*.txt'
find $PARAM_PATH -name 'z_secondary_mat*.txt' -exec rm -f {} \;
wait
${LAUNCH} -n {$NCPU} -hostfile ${PBS_NODEFILE} ${WORKDIR}/${PROGNAME} ${PARAM_PATH} ${PARAM_TEMP} ${PARAM_TRA} ${PARAM_XB} ${PARAM_EXP} ${PARAM_EXP1} ${PARAM_SW_DIFF} ${PARAM_T_DIFF} ${PARAM_Q} ${PARAM_REACT_TEMP}



# wait
# ssh $PBS_NODEFILE
# cd $SCRDIR
# mv * $PARAM_PATH
