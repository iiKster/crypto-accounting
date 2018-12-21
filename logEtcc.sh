#!/bin/bash
# Log ETCC payments from pool.crypto-court.com
# Author: iiKster,  Deceber 21 2018
# The CSV file contains: Date, Payout in ETCC, ETCC/BTC value
# Be sure to put in your ETCC address and path to the datafile to get some results
# Data is fetched from pool.crypto-court.com and Coingecko JOSN API


oldTime=0
int=0
# start loop
while [  $int -lt 500 ]; do

        # Get the values from pool.crypto-court.com / Coingecko json api
        # and assign them to variables
        lastTime=$(curl -s https://pool.crypto-court.com/api/accounts/0xYOUR_ADDRESS | jq -r ' .payments [0].timestamp')
        lastPay=$(curl -s https://pool.crypto-court.com/api/accounts/0xYOUR_ADDRESS | jq -r ' .payments [0].amount')
        etccBtcValue=$(curl -s https://api.coingecko.com/api/v3/coins/etcc | jq -r '.market_data .current_price .btc')
        btcEurValue=$(curl -s https://api.coingecko.com/api/v3/exchange_rates | jq -r '.rates .eur .value')

        # Get current date
        date=`date +%d.%m.%Y`

        payment(){ awk "BEGIN { print "$*" }"; }

# Reformat the payout to coins
        div=1000000000
        payment=$(awk 'BEGIN {print ('$lastPay'/'$div')}')


        #ETCC value to BTC might be so low the JSON output would be 2.234e-6, lets AWK it to a float with 15 decimals
        etccBtcValueFloat=$(awk -v etccBtcValue="$ethoBtcValue" 'BEGIN { printf("%.16f\n", etccBtcValue) }' </dev/null)



        if [ "$lastTime" != "" ]
        then

                if [ "$lastTime" != "$oldTime" ]
                then
                        #Print the stuff to a file
                        # If you run the script with @reboot from crontab please specify the full path to the file
                        echo -e $date","$payment","$etccBtcValueFloat","$btcEurValue >> /home/pi/EtccLog.txt
                        oldTime=$lastTime
                fi
        fi
     #   let int=int+1
#        echo $int
        sleep 1m

done
