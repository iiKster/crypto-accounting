#!/bin/bash
# Graft from Hashwault
# Author: iiKster,  July 11 2018
# Write a CSV file of your payments from Hashvault when mining graft.
# The CSV file contains: Date,  Payout in GRFT, GRFT/BTC value, BTC/Euro value
# Be sure to put in your GRFT address and path to the datafile to get some results
# Data is fetched from Hashvault and Coingecko JOSN API


oldTime=0
int=0
# start loop
while [  $int -lt 500 ]; do

        # Get the values from Hashvault / Coingecko json api
        # and assign them to variables
        lastTime=$(curl -s https://graft.hashvault.pro/api/miner/YourAddress/payments?page | jq -r '.[0]$
        lastPay=$(curl -s https://graft.hashvault.pro/api/miner/YourAddress/payments?page | jq -r '.[0] $
        grftBtcValue=$(curl -s https://api.coingecko.com/api/v3/coins/graft-blockchain | jq -r '.market_data .current_price .btc')
#-------------FIAT------------
        btcEurValue=$(curl -s https://api.coingecko.com/api/v3/exchange_rates | jq -r '.rates .eur .value')

#-------------DATE------------
        # Get current date
        date=`date +%d.%m.%Y`

        payment(){ awk "BEGIN { print "$*" }"; }

# Format the payout to coins
        div=10000000000
        payment=$(awk 'BEGIN {print ('$lastPay'/'$div')}')


        #Graft value to BTC is so low the JSON output was 2.234e-6, let's AWK it to a float with 15 decimals
        grftBtcValueFloat=$(awk -v grftBtcValue="$grftBtcValue" 'BEGIN { printf("%.16f\n", grftBtcValue) }' </dev/null)

        if [ "$lastTime" != "" ]
        then

                if [ "$lastTime" != "$oldTime" ]
                then
                        #Print the stuff to a file
                        # If you run the script with @reboot from crontab please specify the full path to the file
                        echo -e $date","$payment","$grftBtcValueFloat","$btcEurValue >> /PATH/TO/grftLog.txt
                        oldTime=$lastTime
                fi
        fi
        sleep 1m

done
