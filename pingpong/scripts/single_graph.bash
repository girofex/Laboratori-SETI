#!/bin/bash

set -e
 
declare -a head 
declare -a tail
declare -a protocols=( "tcp" "udp" )

declare Latency Bandwith

rm -f ../data/${protocols[0]}_throughput.png
rm -f ../data/${protocols[1]}_throughput.png

for i in ${protocols[@]}; do
    head=($(head -n 1 ../data/${i}_throughput.dat))
	tail=($(tail -n 1 ../data/${i}_throughput.dat))	

    N1=${head[0]}
    N2=${tail[0]}

    TN1=${head[2]}
    TN2=${tail[2]}

    Delay_N1=$(echo "scale=9 ; $N1/$TN1" | bc)
    Delay_N2=$(echo "scale=9 ; $N2/$TN2" | bc)
   
    Latency=$(echo "scale=9 ; ($Delay_N1*$N2 - $Delay_N2*$N1)/($N2 - $N1)" | bc)
    Bandwidth=$(echo "scale=9 ; ($N2 - $N1)/($Delay_N2 - $Delay_N1)" | bc)
   
    echo "Protocol" $i
    echo "Latency:" ${Latency} ", and Bandwith:" ${Bandwidth}

    gnuplot <<-eNDgNUPLOTcOMMAND

	        set term png size 900, 700
	        set output "../data/${i}_single_graph.png"
	        set logscale x 2
	        set logscale y 10
	        set xlabel "msg size (B)"
	        set ylabel "throughput (KB/s)"
	        set title "Location data"
			set grid
			lbf(x) = x / ( $Latency + x / $Bandwidth )
			plot lbf(x) title "${i} median throughput" \
			    with linespoints
			clear
		eNDgNUPLOTcOMMAND
done
exit 0