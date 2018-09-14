#!/bin/bash

# A script that checks your NRG Coin balance with a set intervall (5 min as default) and writes the changes to a  CSV file,
# the file contains the date, payout amount in coins, the coin/BTC value and Euro/value.
# If you want to use a different FIAT currency or date format please edit the code under the lines  ---DATE--- and ---FIAT---
# All the echo lines that has been commented out are used for testing / debugging.
# If you run the script with the @reboot flag from crontab please specify the full path to the file.
# Dependencies: Curl, JQ, AWK  (run "sudo apt-get install curl"  and  "sudo apt-get install jq"

# The script is free to use but I don't mind if you treat me to a Gin (tonic)  GZqfL7xZPZ3hYcMFnfgtEcNkofKimJbks1

oldBal=0.0
int=0
# start loop
while [  $int -lt 500 ]; do

        # Get the values from Gin block explorer / Coingecko json api and assign them to variables
        # Please enter your wallet address below
        curBal=$(curl -sk https://explore.energi.network/ext/getaddress/EHozqg9KjYcgK3JVYnE96CezyLAEx5ZKV8 | jq -r '.received')
        nrgBtcValue=$(curl -s https://api.coingecko.com/api/v3/coins/energi | jq -r '.market_data .current_price .btc')
        #nrg value to BTC is so low the JSON output was 9.234e-5, lets AWK it to a float with 15 decimals
        nrgBtcValueFloat=$(awk -v nrgBtcValue="$nrgBtcValue" 'BEGIN { printf("%.16f\n", nrgBtcValue) }' </dev/null)
echo $curBal
echo $nrgBtcValueFloat

#  --------------FIAT--------------   Change the ".eur" to something else like ".usd" / ".gbp" / ".sek" ...
        btcEurValue=$(curl -s https://api.coingecko.com/api/v3/exchange_rates | jq -r '.rates .eur .value')

        # Get current date
#  --------------Date--------------   Change the "+%d.%m.%Y`" (day month year) to "+%m.%d.%Y`" or "+%y.%m.%d`"
        date=`date +%d.%m.%Y`

       # if [ "$curBal" != "$oldBal" ]

        # Bash dosn't handle float, so this is a bit messy...
        # Check if you have made payments from the wallet
        if (( $(awk 'BEGIN {print ('$curBal' < '$oldBal')}') )); then
                curBal=$oldBal
                # echo "Payment made"
        fi

        # Check if you have been payed
        if (( $(awk 'BEGIN {print ('$oldBal' < '$curBal')}') )); then
                payout=`echo - | awk '{print '$curBal' - '$oldBal'}'`


                #Print the stuff to a file
                # If you run the script with @reboot from crontab please specify the full path to the file
                echo -e $date "," $payout "," $nrgBtcValueFloat "," $btcEurValue >> /home/pi/NrgLog.txt
                oldBal=$curBal
       fi

        # 1 min interval, enough accuracy for me.  Can be set to something less if needed (lots of traffic in and out)
        sleep 1m

done
