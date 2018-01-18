#!/bin/bash


declare -a node_array=('compute-0-0:ppn=1' 'compute-0-1:ppn=1' 'compute-0-2:ppn=1' 'compute-0-3:ppn=1' 'compute-0-4:ppn=1' 'compute-1-0:ppn=1' 'compute-1-1:ppn=1')
node_length=${#node_array[@]}

ii=0
for q in "1.0" "2.0" "3.0" "4.0"; do
	for diff in "10.00" "10.25" "10.50" "10.75" "11.00" "11.25" "11.50" "11.75"; do
		ii=$(( $ii + 1 ))
		##echo $ii

		if [ "$ii" -lt 11 ]; then
			this_node=${node_array[0]}
			##echo $this_node
		fi

		if [ "$ii" -ge 11 ] && [ "$ii" -lt 22 ]; then
			this_node=${node_array[1]}
			##echo $this_node
		fi

		if [ "$ii" -ge 22 ] && [ "$ii" -lt 33 ]; then
			this_node=${node_array[2]}
			##echo $this_node
		fi

		echo "q_"$q"_diff_"$diff

 		qsub -N "q_"$q"_diff_"$diff -l nodes=$this_node -v PARAM_Q=$q,PARAM_T_DIFF=$diff box_sub.csh
	done
done

#qsub -N swi_1050_diff_1100 -v PARAM_SW_DIFF='10.50',PARAM_T_DIFF='11.00' box_sub.csh
