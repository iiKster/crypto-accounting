#!/bin/bash

# Expanse.tech doesn't offer a JSON API to grab so one has to be fetched from the pool.

oldPay=0
int=0
# start loop
while [  $int -lt 500 ]; do

        # Get the values from dwarfpool / coingecko json api
        # and assign them to variables
        lastPay=$(curl -s http://dwarfpool.com/exp/api?wallet=YourWalletAddressHere | jq -r '.last_payment_amount')
        expBtcValue=$(curl -s https://api.coingecko.com/api/v3/coins/expanse | jq -r '.market_data .current_price .btc')
        btcEurValue=$(curl -s https://api.coingecko.com/api/v3/exchange_rates | jq -r '.rates .eur .value')

        # Get current date
        date=`date +%d.%m.%Y`
        if [ "$lastPay" != "" ]


                if [ "$lastPay" != "$oldPay" ]
                then
                        #Print the stuff to a file
                        # If you run the script with @reboot from crontab please specify the full path to the file
                        echo -e $date "," $lastPay "," $expBtcValue "," $btcEurValue >> /home/pi/ExpLog.txt
                        oldPay=$lastPay
                fi
        fi
     #   let int=int+1
     #   echo $int
        sleep 5m

done
