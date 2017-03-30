#!/bin/bash

set -m # Enable Job Control

# Here is the usage
usage() { 

cat << EOF

usage: $0 [-t <number>] [-r <number>] [-d <number>] ([-p <number>] or [-q <number-number>]) [-s] -j <jobfile> -l <logfile>

example (static sleep): ./mutts.sh -r 1 -t 1 -d 5 -p 100 -j jobfile.txt
example (random sleep): ./mutts.sh -r 1 -t 1 -d 5 -q 10-500 -j jobfile.txt 
 
 This script is a wrapper for the multi-threaded tester (mutts).
   
 This will run a (series of) command(s) in the <jobfile> over a specified number of threads (-t), a set number of times (-r), with either a set sleep interval (-p), or a random sleep interval (-q)
 
 OPTIONS:
    -h        Show this message
    -t        Number of threads of the test to run (default: 1)
    -r        Number of times to run the test (default: 1)
    -d        Initial thread spawn delay in seconds (default: 10)
    -j        Job file location
    -p        Pause (ms) after each complete run, applies to all threads (default: 0)
    -q        Random pause (ms) interval within specified range, for each thread, after each run. Input takes interval range, i.e. 1-1000
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
p=0
q=

#get arguments and set variable
while getopts ":r:t:d:j:l:p:q:s" o; do
    case "${o}" in
        t) t=${OPTARG} ;;
        r) r=${OPTARG} ;;
        d) d=${OPTARG} ;;
        p) p=${OPTARG} ;;
    	q) q=${OPTARG} ;;
        s) s=true ;;
        j) j=${OPTARG} ;;
        l) l=${OPTARG} ;;
        *) usage ;;
    esac
done
shift $((OPTIND-1))

threaddelay=$p

#split range if q exists, then check if q range is integer and that q1 is less than q2
if ! [[ -z "${q}" ]]; then
    
    if [[ "$p" -gt 0 ]]; then 
      echo ""
      echo "ERROR: -p option is also set, please unset either -p or -q"
      echo ""
      usage
    fi
    
    q1=$(echo "$q" | cut -d- -f1 )
    q2=$(echo "$q" | cut -d- -f2 )
    
    if [[ -z "${q1}" ]]; then
      usage
    fi
    
    if [[ -z "${q2}" ]]; then
       usage
    fi   
    
     
    if ! [[ $q1 =~ $re ]]; then
      echo ""
      echo "ERROR: $q1 is not an integer"
      echo ""
      usage
    fi
    
    if ! [[ $q2 =~ $re ]]; then
      echo ""
      echo "ERROR: $q2 is not an integer"
      echo ""
      usage
    fi
    
    if [[ $q1 -gt $q2 ]]; then
      echo "Start of random range must be less than end: $q1 !< $q2"
      usage
    fi
    
    if [[ $q1 -eq $q2 ]]; then
      echo "Values in range must differ: $q1 == $q2"
      usage
    fi
    
    threaddelay=$q


fi


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

if ! [[ $p =~ $re ]]; then
    usage
fi

#echo "P is a number"

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
echo "Run Sleep = $threaddelay"
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
      ./mutts_worker.sh $masterInitiate $runs $jobfile $threaddelay  >> $logfile 2>&1 & 

    else
      ./mutts_worker.sh $masterInitiate $runs $jobfile $threaddelay > /dev/null &
    fi 
  else
    if [[ -n "$logfile" ]]; then
      > $logfile
      ./mutts_worker.sh $masterInitiate $runs $jobfile $threaddelay | tee -a $logfile &
    else
      ./mutts_worker.sh $masterInitiate $runs $jobfile $threaddelay &
    fi
  fi

done


# Wait for all parallel jobs to finish
while [ 1 ]; do fg 2> /dev/null; [ $? == 1 ] && break; done