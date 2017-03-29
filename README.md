# mutts
Multi-threaded tester script


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