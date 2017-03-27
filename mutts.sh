#!/bin/bash

set -m # Enable Job Control

# Here is the usage
usage() { 

cat << EOF
usage: $0 [-t <number>] [-r <number>] [-d <number>] [-s] -j <jobfile>
 This script is a wrapper for the multi-threaded tester (mutts).
   
 This will run a (series of) command(s) in the <jobfile> over a specified number of threads (-t), a set number of times (-r)
 
 OPTIONS:
    -h        Show this message
    -t        Number of threads of the test to run (default: 1)
    -r        Number of times to run the test (default: 1)
    -d        Initial thread spawn delay in seconds (default: 10)
    -j        Job file location
    -p        Pause for  
    -s        Make output silent
    -l        Write inside output to file location

EOF

exit 1;

}

#regex for integer
re='^[0-9]+$'

#setting defaults
t=1
r=1
d=10
s=false
l=

#get arguments and set variable
while getopts ":r:t:d:j:l:s" o; do
    case "${o}" in
        t) t=${OPTARG} ;;
        r) r=${OPTARG} ;;
        d) d=${OPTARG} ;;
        s) s=true ;;
        j) j=${OPTARG} ;;
        l) l=${OPTARG} ;;
        *) usage ;;
    esac
done
shift $((OPTIND-1))

#logic checking around variable
if [[ -z "${t}" ]] || [[ -z "${r}" ]] || [[ -z "${d}" ]] ; then
    usage
fi

#echo "POPULATION PASSED"

if ! [[ $t =~ $re ]]; then
    usage
fi

#echo "T is a number"

if ! [[ $r =~ $re ]]; then
    usage
fi

#echo "R is a number"

if ! [[ $d =~ $re ]]; then
    usage
fi

#echo "D is a number"


if ! [[ -f $j ]]; then
    usage
fi


#feedback to use running
echo "Threads     = $t"
echo "Runs/Thread = $r"
echo "Start Delay = $d"
echo "Job File    = $j"
echo "Output Mode = $s"
echo "Logfile     = $l"


#set nicer names
threads=$t
runs=$r
delay=$d
jobfile=$j
logfile=$l

#get runtime of master and add delay for thread start times
masterStart=$(date +%s)
masterInitiate=$((masterStart + $delay))

#spawn worker threads
for i in `seq $threads`; do # start in parallel
  if [[ $s = true ]]; then
    if [[ -n "$logfile" ]]; then
      > $logfile
      ./mutts_worker.sh $masterInitiate $runs $jobfile >> $logfile 2>&1 & 

    else
      ./mutts_worker.sh $masterInitiate $runs $jobfile > /dev/null &
    fi 
  else
    if [[ -n "$logfile" ]]; then
      > $logfile
      ./mutts_worker.sh $masterInitiate $runs $jobfile | tee -a $logfile &
    else
      ./mutts_worker.sh $masterInitiate $runs $jobfile &
    fi
  fi

done


# Wait for all parallel jobs to finish
while [ 1 ]; do fg 2> /dev/null; [ $? == 1 ] && break; done