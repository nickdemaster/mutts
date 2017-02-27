#!/bin/bash

#ingest passed in parameters from mutts.sh - goTime is the time that we want to actually start the threads work
#num runs is the number of times to run 
goTime=$1
numruns=$2

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
    
    randUser=$(shuf -i1-25000 -n 1)
    mysql --socket=/var/mysql/db-test/mysql.sock -P3301 -u $randUser -p$randUser --execute="select '1' from \`$randUser\`.\`$randUser\`;" 2>&1 | grep -v "Warning: Using a password"   
    
    #end process timer
    procEnd=$(($(date +%s%N)/1000000))
    
    #get difference of timers
    procTime=$(( procEnd - procStart))
  
    echo "$BASHPID : Total Process Time : $procTime"

  done