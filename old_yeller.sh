#!/bin/bash

## This is the heavy handed kill switch that finds the pid for the parent and kills the mutts parent and the child processes, immediately.  USE WITH EXTREME CAUTION ESPECIALLY WITH SCRIPTS THAT MAKE SYSTEM, PROGRAMMATIC, or PERMANENT MODIFICATIONS ##

#get parent pid of the mutts process
pidnum=$(pgrep "mutts.sh")

#kill parent and children
pkill -TERM -P $pidnum
