#!/bin/bash

#ingest passed in parameters from mutts.sh - goTime is the time that we want to actually start the threads work
#num runs is the number of times to run 
goTime=$1
numruns=$2
jobfile=$3
delay=$4

#if $delay is a range, will set q1 and q2 based off cut.  If $delay is single int, will set both q1 and q2 the same 
  q1=$(echo $delay | cut -d- -f1 )
  q2=$(echo $delay | cut -d- -f2 )
    
    if ! [[ $q1 -eq q2 ]]; then 
    
      if [[ -z "${q1}" ]]; then
        exit 1;
      fi
    
      if [[ -z "${q2}" ]]; then
        exit 1;
      fi   
    
      if ! [[ $q1 =~ $re ]]; then
        exit 1;
      fi
    
      if ! [[ $q2 =~ $re ]]; then
        exit 1;
      fi
    
      if [[ $q1 -gt $q2 ]]; then
        exit 1;
      fi
    
      if [[ $q1 -eq $q2 ]]; then
        exit 1;
      fi
     
  fi


#wait until time has hit goTime
while [ $(date +%s) -lt $goTime ]; do

  echo "$BASHPID : waiting..."
  sleep 1

done

#feedback to user that its time to start
echo "$BASHPID : done waiting"
   
  for i in  `seq 1 $numruns `; do
  
    #echo "$BASHPID : THIS IS RUN $i"
    
    ## START COMMAND PATH TO TEST HERE
    
    #start process timer
    procStart=$(($(date +%s%N)/1000000))
    
    ######
    source $jobfile
    ######  
  
    #end process timer
    procEnd=$(($(date +%s%N)/1000000))
    
    #get difference of timers
    procTime=$(( procEnd - procStart))
  
    echo "$BASHPID : Total Process Time : $procTime"

    if ! [[ $q1 -eq q2 ]]; then 
    
      threaddelay_ms=$(shuf -i$q1-$q2 -n 1)
      threaddelay_s=$(echo "scale=3;${threaddelay_ms}/1000" | bc)
    
    else
      threaddelay_ms=$delay
      threaddelay_s=$(echo "scale=3;${delay}/1000" | bc)
    
    fi


    if [ "$threaddelay_ms" -gt "0" ]; then 
      echo "sleeping $threaddelay_s s ($threaddelay_ms ms)"
      sleep $threaddelay_s;
    fi
    

  done