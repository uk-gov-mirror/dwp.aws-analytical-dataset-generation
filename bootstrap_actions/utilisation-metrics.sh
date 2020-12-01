#!/bin/bash

if [[ $(grep "isMaster" /mnt/var/lib/info/instance.json | grep true) ]]; then
    export namespace_prefix="Master"
else
    export namespace_prefix="Nodes"
fi
METRICS_FILEPATH=/opt/emr/metrics/

touch $$METRICS_FILEPATH$${1}_$${namespace_prefix}_free_memory.csv
touch $$METRICS_FILEPATH$${1}_$${namespace_prefix}_cpu_utilisation.csv
touch $$METRICS_FILEPATH$${1}_$${namespace_prefix}_free_disk.csv
touch $$METRICS_FILEPATH$${1}_$${namespace_prefix}_received_bytes.csv
touch $$METRICS_FILEPATH$${1}_$${namespace_prefix}_transferred_bytes.csv

send_loop()
{
    while :
        do
            echo "$${namespace_prefix}","`free -m | awk -v RS="" '{print $10 "+" $17 "+" $21}' | bc`">>$METRICS_FILEPATH$${1}_$${namespace_prefix}_free_memory.csv
            echo "$${namespace_prefix}","`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}' | bc`">>$METRICS_FILEPATH$${1}_$${namespace_prefix}_cpu_utilisation.csv
            echo "$${namespace_prefix}","`df --output=avail / | grep -v Avail| bc`">>$METRICS_FILEPATH$${1}_$${namespace_prefix}_free_disk.csv
            echo "$${namespace_prefix}","`ifconfig eth0 | grep -oP "(?<=RX bytes:)([0-9]*)" | bc`">>$METRICS_FILEPATH$${1}_$${namespace_prefix}_received_bytes.csv
            echo "$${namespace_prefix}","`ifconfig eth0 | grep -oP "(?<=TX bytes:)([0-9]*)" | bc`">>$METRICS_FILEPATH$${1}_$${namespace_prefix}_transferred_bytes.csv
            sleep $${2}
        done
}
send_loop ${app_name} ${sleep_time} &amp;

