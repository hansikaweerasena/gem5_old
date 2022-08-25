export nodes=$1
export rows=$2
export iterations=$3
export simCycles=$4
export dest_folder=$5
export benchmark=$6
export benchmark2=$7

echo "Running traffic corelation($benchmark benchmark) data for and rows : " $nodes " " $rows 
echo "Running $benchmark2 acessing 3 MCs."

export is_apply_cf=false
export cw=""
export cw_flag=""
if [[ "$apply_cf" == "-cw" ]]; then
    is_apply_cf=true 
    cw="c"
    cw_flag="--enable-add-chaff"
fi

export delay=""
export delay_flag=""
if [[ "$apply_delay" == "-delay" ]]; then
    delay="d"
    delay_flag="--enable-add-delay"
fi


for i in $( eval echo {0..$(($nodes-1))})
do
    for j in $( eval echo {0..$(($nodes-1))})
    do
        if [[ ("$is_apply_cf" = true ) && (($j -eq $(($i-1))) || ($j -eq $(($i+1))) || ($j -eq $(($i+$rows))) || ($j -eq $(($i-$rows))))]]; then
            continue
        fi
        if [ $i -eq $j ]; then
            continue
        fi
        for k in $( eval echo {0..$(($iterations-1))})
        do
            export def_mc=$(( $RANDOM % $nodes + 0 ))
            while [[ ($def_mc -eq $(($i))) || ($def_mc -eq $(($j))) ]]
            do
                export def_mc=$(( $RANDOM % $nodes + 0 ))
            done
            export mem21=$(( $RANDOM % $nodes + 0 ))
            while [[ ($mem21 -eq $(($i))) || ($mem21 -eq $(($j))) || ($mem21 -eq $(($def_mc))) ]]
            do
                export mem21=$(( $RANDOM % $nodes + 0 ))
            done
            export mem22=$(( $RANDOM % $nodes + 0 ))
            while [[ ($mem22 -eq $(($i))) || ($mem22 -eq $(($j))) || ($mem22 -eq $(($mem21))) || ($mem22 -eq $(($def_mc))) ]]
            do
                export mem22=$(( $RANDOM % $nodes + 0 ))
            done
            export mem23=$(( $RANDOM % $nodes + 0 ))
            while [[ ($mem23 -eq $(($i))) || ($mem23 -eq $(($j))) || ($mem23 -eq $(($mem21))) || ($mem23 -eq $(($mem22))) || ($mem23 -eq $(($def_mc))) ]]
            do
                export mem23=$(( $RANDOM % $nodes + 0 ))
            done
            export src2=$(( $RANDOM % $nodes + 0 ))
            while [[ ($src2 -eq $(($i))) || ($src2 -eq $(($j))) || ($src2 -eq $(($mem21))) || ($src2 -eq $(($mem22))) || ($src2 -eq $(($mem23))) || ($src2 -eq $(($def_mc))) ]]
            do
                export src2=$(( $RANDOM % $nodes + 0 ))
            done
            export out_filename="${nodes}_${i}_${j}_${k}_${mem21}_${mem22}_${mem23}_${def_mc}.txt" 
            ../build/X86/gem5.opt -d $dest_folder/"${nodes}_nodes_${cw}${delay}_${benchmark}_${benchmark2}"/${i}_${j} --debug-file=$out_filename --debug-flag=Hello ../configs/example/se_n_cores.py --num-src-dst-pair=2 --dir-mp-src1=$i --dir-mp-mem1=$j --dir-mp-src2=$src2 --dir-mp-mem21=$mem21 --dir-mp-mem22=$mem22 --dir-mp-mem23=$mem23 --dir-mp-default=$def_mc --num-cpus=$nodes --num-dir=$nodes --cpu-type=timing --cpu-clock=2GHz --caches --l1d_size=1kB --l1i_size=1kB --l2cache --num-l2caches=16 --l2_size=8kB --mem-type=RubyMemoryControl --mem-size=4GB --ruby --topology=Mesh_XY --mesh-rows=$rows --network=garnet2.0 --rel-max-tick=$simCycles -c "/gem5/gem5/dummy_pr;/gem5/gem5/benchmarks/${benchmark};/gem5/gem5/benchmarks/${benchmark2}"
        done
        rm -r $dest_folder/"${nodes}_nodes_${cw}${delay}_${benchmark}_${benchmark2}"/${i}_${j}/*.ini
        rm -r $dest_folder/"${nodes}_nodes_${cw}${delay}_${benchmark}_${benchmark2}"/${i}_${j}/*.json
    done
done



# for c-style 

# for (( i = 0; i < $nodes; i++))
# do
#     for (( j = 0; j < $nodes; j++))
#     do
#         if (($i == $j)); then
#             continue
#         fi
#         for (( k = 0; k < $iterations; k++))
#         do
#             # out_filename = "${nodes}_${i}_${j}_${k}.txt" 
#             # ../build/X86_DeepCorr/gem5.debug --debug-file=raw_dd/"${nodes}_nodes"/out_filename --debug-flags=GarnetSyntheticTraffic2,Hello ../configs/example/garnet_synth_traffic.py --cor-p1=$i --cor-p2=$j --num-cpus=4 --num-dirs=4 --network=garnet2.0 --topology=Mesh_XY --mesh-rows=2 --sim-cycles=1000  --synthetic=uniform_random --injectionrate=0.01
#             echo $i $j
#         done
#     done
# done