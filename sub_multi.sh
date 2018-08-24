#!/bin/bash

##
#declare -a node_array=('compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-0-2:ppn=1' 'compute-0-3:ppn=1' 'compute-0-4:ppn=1' 'compute-1-0:ppn=1' 'compute-1-1:ppn=1' 'compute-1-2:ppn=1' 'compute-1-3:ppn=1' 'compute-1-4:ppn=1' 'compute-1-5:ppn=1' 'compute-1-6:ppn=1' 'compute-1-7:ppn=1' 'compute-1-8:ppn=1')






## declare -a node_array=('compute-0-4:ppn=1' 'compute-1-0:ppn=1' 'compute-1-1:ppn=1' 'compute-1-2:ppn=1'  'compute-1-7:ppn=1' 'compute-1-6:ppn=1'  'compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-0-2:ppn=1' 'compute-0-3:ppn=1' 'compute-1-3:ppn=1' 'compute-1-4:ppn=1' 'compute-1-5:ppn=1' 'compute-1-10:ppn=1' 'compute-1-9:ppn=1' 'compute-1-8:ppn=1')

## declare -a node_array=('compute-0-4:ppn=1' 'compute-1-0:ppn=1' 'compute-1-1:ppn=1' 'compute-1-2:ppn=1'  'compute-1-7:ppn=1' 'compute-1-9:ppn=1'  'compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-0-2:ppn=1' 'compute-0-3:ppn=1' 'compute-1-3:ppn=1' 'compute-1-4:ppn=1' 'compute-1-5:ppn=1' 'compute-1-10:ppn=1' 'compute-1-6:ppn=1' 'compute-1-8:ppn=1')


# set for 30, 40
# declare -a node_array=('compute-0-4:ppn=1' 'compute-1-0:ppn=1' 'compute-1-1:ppn=1' 'compute-1-2:ppn=1'  'compute-1-7:ppn=1' 'compute-1-9:ppn=1')

# set for 50, 60
# declare -a node_array=('compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-0-2:ppn=1' 'compute-0-3:ppn=1' 'compute-1-3:ppn=1' 'compute-1-4:ppn=1')

#declare -a node_array=('compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-0-2:ppn=1' 'compute-0-3:ppn=1' 'compute-0-4:ppn=1' 'compute-1-0:ppn=1' 'compute-1-1:ppn=1' 'compute-1-2:ppn=1' 'compute-1-3:ppn=1' 'compute-1-4:ppn=1')



#declare -a node_array=('compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-0-2:ppn=1' 'compute-0-3:ppn=1' 'compute-0-4:ppn=1' 'compute-1-5:ppn=1')

#declare -a node_array=('compute-0-3:ppn=1' 'compute-0-4:ppn=1' 'compute-1-5:ppn=1' 'compute-1-8:ppn=1' 'compute-1-9:ppn=1' 'compute-1-0:ppn=1' )

#declare -a node_array=('compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-0-2:ppn=1' 'compute-0-3:ppn=1' 'compute-0-4:ppn=1' 'compute-1-5:ppn=1' 'compute-1-8:ppn=1' 'compute-1-9:ppn=1' 'compute-1-0:ppn=1' )


#declare -a node_array=('compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-1-0:ppn=1' 'compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-1-0:ppn=1')






#declare -a node_array=('compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-0-2:ppn=1' 'compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-0-2:ppn=1')

declare -a node_array=('compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-0-2:ppn=1' 'compute-0-3:ppn=1' 'compute-0-4:ppn=1' 'compute-1-0:ppn=1' 'compute-1-1:ppn=1' 'compute-1-2:ppn=1' 'compute-1-3:ppn=1' 'compute-1-4:ppn=1' 'compute-1-5:ppn=1' 'compute-1-6:ppn=1' 'compute-1-7:ppn=1' 'compute-1-8:ppn=1' 'compute-1-9:ppn=1' 'compute-0-0:ppn=1' 'compute-1-0:ppn=1' 'compute-0-1:ppn=1' 'compute-0-2:ppn=1' 'compute-0-3:ppn=1' 'compute-0-4:ppn=1' 'compute-1-1:ppn=1' 'compute-1-2:ppn=1' 'compute-1-3:ppn=1' 'compute-1-4:ppn=1' 'compute-1-5:ppn=1' 'compute-1-6:ppn=1' 'compute-1-7:ppn=1' 'compute-1-8:ppn=1' 'compute-1-9:ppn=1')

#declare -a node_array=('compute-0-3:ppn=1' 'compute-0-4:ppn=1' 'compute-1-0:ppn=1' 'compute-0-3:ppn=1' 'compute-0-4:ppn=1' 'compute-1-0:ppn=1')
#declare -a node_array=('compute-1-6:ppn=1' 'compute-1-7:ppn=1' 'compute-1-8:ppn=1' 'compute-1-6:ppn=1' 'compute-1-7:ppn=1' 'compute-1-8:ppn=1')

node_length=${#node_array[@]}
cut=6


ii=0

for q in "0.5" "1.0" "1.5" "2.0" "2.5" "3.0" "3.5" "4.0" "4.5" "5.0"  ; do

	# for diff in "2.00" "2.50" "3.00" "3.50" "4.00" "4.50" "5.00" "5.50" "6.00"; do
	for diff in "2.25" "2.75" "3.25" "3.75" "4.25" "4.75" "5.25" "5.75"; do
		ii=$(( $ii + 1 ))
		##echo $ii

		if (( $ii > 0 )); then
			this_node=${node_array[0]}
		fi

		if (( $ii > $cut )); then
			this_node=${node_array[1]}
		fi

		if [ "$ii" -gt $(($cut * 2)) ]; then
			this_node=${node_array[2]}
		fi

		if [ "$ii" -gt $(($cut * 3)) ]; then
			this_node=${node_array[3]}
		fi

		if [ "$ii" -gt $(($cut * 4)) ]; then
			this_node=${node_array[4]}
		fi

		if [ "$ii" -gt $(($cut * 5)) ]; then
			this_node=${node_array[5]}
		fi

		if [ "$ii" -gt $(($cut * 6)) ]; then
			this_node=${node_array[6]}
		fi

		if [ "$ii" -gt $(($cut * 7)) ]; then
			this_node=${node_array[7]}
		fi

		if [ "$ii" -gt $(($cut * 8)) ]; then
			this_node=${node_array[8]}
		fi

		if [ "$ii" -gt $(($cut * 9)) ]; then
			this_node=${node_array[9]}
		fi

		if [ "$ii" -gt $(($cut * 10)) ]; then
			this_node=${node_array[10]}
		fi

		if [ "$ii" -gt $(($cut * 11)) ]; then
			this_node=${node_array[11]}
		fi

		if [ "$ii" -gt $(($cut * 12)) ]; then
			this_node=${node_array[12]}
		fi

		if [ "$ii" -gt $(($cut * 13)) ]; then
			this_node=${node_array[13]}
		fi

		if [ "$ii" -gt $(($cut * 14)) ]; then
			this_node=${node_array[14]}
		fi

		if [ "$ii" -gt $(($cut * 15)) ]; then
			this_node=${node_array[15]}
		fi

		# new for limited processors
		if [ "$ii" -gt $(($cut * 16)) ]; then
			this_node=${node_array[16]}
		fi

		if [ "$ii" -gt $(($cut * 17)) ]; then
			this_node=${node_array[17]}
		fi

		if [ "$ii" -gt $(($cut * 18)) ]; then
			this_node=${node_array[18]}
		fi

		if [ "$ii" -gt $(($cut * 19)) ]; then
			this_node=${node_array[19]}
		fi

		if [ "$ii" -gt $(($cut * 20)) ]; then
			this_node=${node_array[20]}
		fi

		if [ "$ii" -gt $(($cut * 21)) ]; then
			this_node=${node_array[21]}
		fi

		if [ "$ii" -gt $(($cut * 22)) ]; then
			this_node=${node_array[22]}
		fi

		if [ "$ii" -gt $(($cut * 23)) ]; then
			this_node=${node_array[23]}
		fi

		if [ "$ii" -gt $(($cut * 24)) ]; then
			this_node=${node_array[24]}
		fi

		echo "q_"$q"_diff_"$diff

 		qsub -N "q_"$q"_diff_"$diff -l nodes=$this_node -v PARAM_Q=$q,PARAM_T_DIFF=$diff box_sub.csh
	done
done

#qsub -N swi_1050_diff_1100 -v PARAM_SW_DIFF='10.50',PARAM_T_DIFF='11.00' box_sub.csh
