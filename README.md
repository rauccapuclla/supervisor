# Supervisor
Bash shell script that check if service is running in a regular interval and started if the service is down.

## Usage
```
$./supervisor.sh [waittime] [attempts] [procname] [interval]
```
### Parameters:

waittime: Wait time in seconds between attempts to restart service  
attempts: Number of attempts before giving up  
procname: Service name (used by systemctl)  
interval: Check interval of the process in seconds  
