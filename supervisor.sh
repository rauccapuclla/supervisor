#!/bin/bash

logfile="/tmp/supervisor.log"

#Parameters
waittime=$1
attempts=$2
procname=$3
interval=$4

die () {
    echo "$@" | tee -a $logfile
    exit 1
}

isnumber () {
    if ! [[ $1 =~ ^[0-9]+$ ]] ; then
        die "ERROR: Parameter $1 must be a numeric"
    fi
}

checkservice () {
    #Using systemctl
    
    if [ -f /etc/init.d/$1 ]; then
        echo "$(systemctl is-active $1)"
    else
        echo "null"
    fi
}

if [ -z $waittime ]  || [ -z $attempts ] || [ -z $procname ] || [ -z $interval ]; then
    echo "Usage: $0 [waittime] [attempts] [procname] [interval]"
    echo "Only $# parameters has been given"
else
    #validate is parameters are numbers
    isnumber $waittime
    isnumber $attempts
    isnumber $interval

    #validate id process exists and is running
    while $true
    do
        status=$(checkservice $procname)

        if [ $status == "null" ]; then
            die "ERROR: service $procname doesn't exists"
        fi

        if [ $status == "inactive" ]; then
            echo $(date +"%m-%d-%Y %H:%M") ": service $procname is $status" | tee -a $logfile
            counter=0
            until [ $counter -eq $attempts ]
            do
                echo $(date +"%m-%d-%Y %H:%M") ": starting service $procname" | tee -a $logfile
                service $procname start
                echo $(date +"%m-%d-%Y %H:%M") ": waiting interval" | tee $logfile
                sleep $waittime
                if [ "$(checkservice $procname)" == "active" ]; then
                    echo $(date +"%m-%d-%Y %H:%M") ": service $procname has started" | tee -a $logfile
                    break
                fi                
                ((counter++))
                echo $(date +"%m-%d-%Y %H:%M") ": attempt $counter to start service" | tee -a $logfile
            done
            if [ $counter -eq $attempts ]; then
                die "ERROR: " $(date +"%m-%d-%Y %H:%M") ": Giving up after $attempts"
            fi
        fi
        echo $(date +"%m-%d-%Y %H:%M") ": service $procname is active" | tee -a $logfile
        sleep $interval
    done
fi
