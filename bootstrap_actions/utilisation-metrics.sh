#!/bin/bash

if [[ $(grep "isMaster" /mnt/var/lib/info/instance.json | grep true) ]]; then
    export namespace_prefix="master"
else
    export namespace_prefix="nodes"
fi
METRICS_FILEPATH="/opt/emr/metrics/"
send_loop()
{
    while :
        do
            echo "$${1}_$${namespace_prefix}_free_memory","`free -m | awk -v RS="" '{print $10 "+" $17 "+" $21}' | bc`">>$METRICS_FILEPATH$${1}_$${namespace_prefix}_free_memory.csv
            echo "$${1}_$${namespace_prefix}_cpu_utilisation","`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}' | bc`">>$METRICS_FILEPATH$${1}_$${namespace_prefix}_cpu_utilisation.csv
            echo "$${1}_$${namespace_prefix}_free_disk","`df --output=avail / | grep -v Avail| bc`">>$METRICS_FILEPATH$${1}_$${namespace_prefix}_free_disk.csv
            echo "$${1}_$${namespace_prefix}_received_bytes","`ifconfig eth0 | grep -oP "(?<=RX bytes:)([0-9]*)" | bc`">>$METRICS_FILEPATH$${1}_$${namespace_prefix}_received_bytes.csv
            echo "$${1}_$${namespace_prefix}_transferred_bytes","`ifconfig eth0 | grep -oP "(?<=TX bytes:)([0-9]*)" | bc`">>$METRICS_FILEPATH$${1}_$${namespace_prefix}_transferred_bytes.csv
            sleep $${2}
        done
}
send_loop ${app_name} ${sleep_time} &amp;

