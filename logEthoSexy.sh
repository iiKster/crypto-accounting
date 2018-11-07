#!/bin/bash
# Log Ether-1 payments from pool.sexy
# Author: iiKster,  November 7 2018
# The CSV file contains: Date, Payout in Etho, Etho/BTC value
# Be sure to put in your Etho address and path to the datafile to get some results
# Data is fetched from pool.sexy and Coingecko JOSN API


oldTime=0
int=0
# start loop
while [  $int -lt 500 ]; do

        # Get the values from Pool.sexy / Coingecko json api
        # and assign them to variables
        lastTime=$(curl -s http://mining-etho.pool.sexy/api/accounts/0xYOUR_ADDRESS | jq -r ' .data .miner_stats .payments [0].timestamp')
        lastPay=$(curl -s http://mining-etho.pool.sexy/api/accounts/0x0xYOUR_ADDRESS | jq -r ' .data .miner_stats .payments [0].amount')
        ethoBtcValue=$(curl -s https://api.coingecko.com/api/v3/coins/ether-1 | jq -r '.market_data .current_price .btc')
        btcEurValue=$(curl -s https://api.coingecko.com/api/v3/exchange_rates | jq -r '.rates .eur .value')

        # Get current date
        date=`date +%d.%m.%Y`

        payment(){ awk "BEGIN { print "$*" }"; }

# Reformat the payout to coins
        div=1000000000
        payment=$(awk 'BEGIN {print ('$lastPay'/'$div')}')


        #Etho value to BTC might be so low the JSON output would be 2.234e-6, lets AWK it to a float with 15 decimals
        ethoBtcValueFloat=$(awk -v ethoBtcValue="$ethoBtcValue" 'BEGIN { printf("%.16f\n", ethoBtcValue) }' </dev/null)



        if [ "$lastTime" != "" ]
        then

                if [ "$lastTime" != "$oldTime" ]
                then
                        #Print the stuff to a file
                        # If you run the script with @reboot from crontab please specify the full path to the file
                        echo -e $date","$payment","$ethoBtcValueFloat","$btcEurValue >> /home/pi/EthoLog.txt
                        oldTime=$lastTime
                fi
        fi
     #   let int=int+1
#        echo $int
        sleep 1m

done
