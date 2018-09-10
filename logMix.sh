#!/bin/bash
# Log incomming Mix payments from minerpool.net

oldPay=0
int=0
div=1000000000
# start loop
while [  $int -lt 500 ]; do

        # Get the values from dwarfpool / coingecko json api
        # and assign them to variables
        lastPay=$(curl -s http://mix.minerpool.net/api/accounts/YOUR_WALLET | jq -r '.payments[0] .amount')

        # Reformat paymebnt output to coins, not some long integer
        payment=$(awk 'BEGIN {print ('$lastPay'/'$div')}')

        mixBtcValue=$(curl -s https://api.coingecko.com/api/v3/coins/mix | jq -r '.market_data .current_price .btc')
        btcEurValue=$(curl -s https://api.coingecko.com/api/v3/exchange_rates | jq -r '.rates .eur .value')


        #Mix value to BTC is so low the JSON output was 9.234e-5, lets AWK it to a float with 15 decimals
        mixBtcValueFloat=$(awk -v mixBtcValue="$mixBtcValue" 'BEGIN { printf("%.16f\n", mixBtcValue) }' </dev/null)

        # Get current date
        date=`date +%d.%m.%Y`
        if [ "$lastPay" != "" ]
        then

                if [ "$lastPay" != "$oldPay" ]
                then
                        #Print the stuff to a file
                        # If you run the script with @reboot from crontab please specify the full path to the file
                        echo -e $date","$payment","$mixBtcValueFloat","$btcEurValue >> /home/pi/MixLog.txt
                        oldPay=$lastPay
                fi
        fi
        sleep 1m

done
