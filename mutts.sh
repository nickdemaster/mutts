#1/bin/bash

set -m # Enable Job Control

# Here is the usage
usage() { 

cat << EOF
usage: $0 [-t <number>] [-r <number>] [-d <number>]
 This script is a wrapper for the mysql 
 OPTIONS:
    -h        Show this message
    -t        Number of threads of the test to run (default: 1)
    -r        Number of times to run the test (default: 1)
    -p        Initial thread spawn delay in seconds (default: 10)
EOF

echo "" 
exit 1;

}

#regex for integer
re='^[0-9]+$'

#setting defaults
t=1
r=1
d=10

#get arguments and set variable
while getopts ":r:t:d:" o; do
    case "${o}" in
        t)
           t=${OPTARG}
            ;;
        r)
           r=${OPTARG}
            ;;
        d)
           d=${OPTARG}
            ;;

        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

#logic checking around variable
if [ -z "${t}" ] || [ -z "${r}" ] || [ -z "${d}" ]; then
    usage
fi

if ! [[ $t =~ $re ]]; then
    usage
fi

if ! [[ $r =~ $re ]]; then
    usage
fi

if ! [[ $d =~ $re ]]; then
    usage
fi

#feedback to use running
echo "Threads     = $t"
echo "Runs/Thread = $r"
echo "Start Delay = $d"

$set nicer names
threads=$t
runs=$r
delay=$d

#get runtime of master and add delay for thread start times
masterStart=$(date +%s)
masterInitiate=$((masterStart + $delay))

#spawn worker threads
for i in `seq $threads`; do # start in parallel
 
  ./mutts_worker.sh $masterInitiate $runs &  

done


# Wait for all parallel jobs to finish
while [ 1 ]; do fg 2> /dev/null; [ $? == 1 ] && break; done