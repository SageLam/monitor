#!/bin/bash

usage="usage: $0 [eno1|bond0|...]"
INTERVAL=10
INFLUXDB_HOST='127.0.0.1'
INFLUXDB_PORT=8086

ETH=$1

if [[ -z $ETH ]]; then
    echo $usage
	exit 1
fi

# 验证网卡是否up
tmp=`ifconfig $ETH`
if [ $? -ne 0 ]; then
    echo "ERROR [$ETH]: Device not found"
    exit 2
fi

rxrt=`ifconfig $ETH | grep RX | grep TX`
rx_before=`echo $rxrt | awk '{print $2}'|cut -c7-`
tx_before=`echo $rxrt | awk '{print $6}' |cut -c7-`

while : ; do
        time=`date "+%Y-%m-%d %H:%M:%S"`

        sleep $INTERVAL

        rxrt=`ifconfig $ETH | grep RX | grep TX`
        rx_after=`echo $rxrt | awk '{print $2}'|cut -c7-`
        tx_after=`echo $rxrt | awk '{print $6}' |cut -c7-`

        rx_result=$[(${rx_after}-${rx_before})/128/$INTERVAL]
        tx_result=$[(${tx_after}-${tx_before})/128/$INTERVAL]
        echo "${time}+${INTERVAL} [${ETH}] NowInSpeed: ${rx_result}kbps NowOutSpeed: ${tx_result}kbps"

        #params="Now_In_Speed=$rx_result,Now_OUt_Speed=$tx_result"
        #curl -i -XPOST "http://${INFLUXDB_HOST}:${INFLUXDB_PORT}/write?db=monitordb" --data-binary "net,host=${HOST},eth=${ETH} ${params}"

        rx_before=$rx_after
        tx_before=$tx_after
done