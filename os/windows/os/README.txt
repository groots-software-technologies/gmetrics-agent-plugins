
# Windows plugin addition.

Downlaod windows plugin and config file from following url.
https://github.com/grootsadmin/groots-metrics/tree/alpha/gmetrics-remote-plugin/os/windows/os

# Pre-requisite packages. 

# NOTE: Before Installation ask to client shall we install following packages on windows system.

- Install .net framework Min 3.5. (https://dotnet.microsoft.com/download/dotnet-framework/)
- Install python package 2.7 or 3.x (https://www.python.org/downloads/windows/)
- Open port 5666 in firewall server level and infra level.

1. Copy "nsclient.ini" file on remote host under following path.

C:\Program Files\NSClient++

2. Copy remote plugins under following path which is on github.

C:\Program Files\NSClient++\scripts\custom

3. Restart nsclient service on windows remote host.

4. Add windows host on gmetrics server default port is 5666.
$ telnet <REMOTE HOST> 5666

$ telnet <PUBLIC IP> 5666
Trying x.x.x.x...
Connected to x.x.x.x.
Escape character is '^]'.
^]q

telnet> q
Connection closed.

$ /groots/monitoring/config_files/libexec/check_metrics -2 -H <PUBLIC IP>
I (0.5.2.35 2018-01-28) seem to be doing fine...

$ time /groots/monitoring/config_files/libexec/check_metrics -2 -H <PUBLIC IP> -t 6000 -c check_host -a "127.0.0.1 5 3000,70 4000,80"
OK: - PKT-LS=0%, RT-AV=0ms|'rta'=0ms;3000;4000 'pl'=0%;70;80

real    0m5.179s
user    0m0.004s
sys     0m0.002s

5. Reload nagios/gmetrics service and test performace data

NOTE :
     Do not change windows "hosts.cfg" and "os_metrics.cfg" file contenet, only add hostname.
     Also, Now onward use windows NSClient default port is "5666".
