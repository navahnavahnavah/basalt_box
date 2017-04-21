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
#PBS -N chamber_minerals
#
# set the output and error files
## PBS -o /data/navah/summer16/basalt_box/mOutG.txt
## PBS -e /data/navah/summer16/basalt_box/mErrG.txt
#PBS -o /home/navah/basalt_box/mOutG.txt
#PBS -e /home/navah/basalt_box/mErrG.txt
#PBS -m abe -M navah@uchicago.edu
# set the number of nodes to use, and number of processors
# to use per node


#PBS -l nodes=compute-1-4:ppn=1

# or, if using only one node, you can do it this way too
##PBS -l ncpus=5

# NEW STUFF MAY 2016

# in this example, I'm using the intel compilers and mvapich2
#
# bring in the module settings

sleep 10s 
source /etc/profile.d/modules.csh
module load intel/intel-12
module load mpi/mvapich2/intel

  
 

# model parameters go here i guess
set PARAM_TEMP='100'

# set PARAM_PATH='/data/navah/summer16/basalt_box/output/test0/'
#set PARAM_PATH='/home/navah/basalt_box/output/stages0/'
set PARAM_OL_NUM = 0
set PARAM_PYR_NUM = 0
set PARAM_PLAG_NUM = 0

set PARAM_TRA='11.00'
set PARAM_XB='-2.00'
set PARAM_EXP='0.001'
set PARAM_EXP1='0.0001'

if (${PARAM_OL_NUM} == 0) then
	set PARAM_OL = "-f,MgO,1.0,FeO,1.0,SiO2,1.0"
endif
if (${PARAM_OL_NUM} == 1) then
	set PARAM_OL = "-f,MgO,2.0,SiO2,1.0"
endif
if (${PARAM_OL_NUM} == 2) then
	set PARAM_OL = "-f,FeO,2.0,SiO2,1.0"
endif

echo $PARAM_OL

if (${PARAM_PYR_NUM} == 0) then
	set PARAM_PYR = "-f,CaO,1.0,MgO,1.0,SiO2,2.0"
endif
if (${PARAM_PYR_NUM} == 1) then
	set PARAM_PYR = "-f,CaO,1.0,FeO,1.0,SiO2,2.0"
endif
if (${PARAM_PYR_NUM} == 2) then
	set PARAM_PYR = "-f,CaO,1.0,MgO,1.0,SiO2,2.0"
endif
if (${PARAM_PYR_NUM} == 3) then
	set PARAM_PYR = "-f,FeO,1.0,MgO,1.0,SiO2,2.0"
endif
if (${PARAM_PYR_NUM} == 4) then
	set PARAM_PYR = "-f,MgO,2.0,SiO2,2.0"
endif
if (${PARAM_PYR_NUM} == 5) then
	set PARAM_PYR = "-f,FeO,2.0,SiO2,2.0"
endif
if (${PARAM_PYR_NUM} == 6) then
	set PARAM_PYR = "-f,CaO,2.0,SiO2,2.0"
endif

echo $PARAM_PYR

if (${PARAM_PLAG_NUM} == 0) then
	set PARAM_PLAG = "-f,NaAlSi3O8,0.5,CaAl2Si2O8,0.5"
endif
if (${PARAM_PLAG_NUM} == 1) then
	set PARAM_PLAG = "-f,CaAl2Si2O8,1.0"
endif

echo $PARAM_PLAG



# set PARAM_PATH='/home/navah/basalt_box/output/mins/batch1/ol'${PARAM_OL_NUM}'_pyr'${PARAM_PYR_NUM}'_plag'${PARAM_PLAG_NUM}'/'
set PARAM_PATH='/home/navah/basalt_box/output/deter/batch1/tra'${PARAM_TRA}'_xb'${PARAM_XB}'/'
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
find $PARAM_PATH -name 'secondary_mat*.txt' -exec rm -f {} \;
wait
${LAUNCH} -n {$NCPU} -hostfile ${PBS_NODEFILE} ${WORKDIR}/${PROGNAME} ${PARAM_PATH} ${PARAM_TEMP} ${PARAM_TRA} ${PARAM_XB} ${PARAM_EXP} ${PARAM_EXP1} $PARAM_OL $PARAM_PYR $PARAM_PLAG
#${LAUNCH} -n {$NCPU} -hostfile ${PBS_NODEFILE} ${WORKDIR}/${PROGNAME} ${SCRDIR} ${PARAM_TEMP} ${PARAM_TRA} ${PARAM_XB}

# wait
# ssh $PBS_NODEFILE
# cd $SCRDIR
# mv * $PARAM_PATH
