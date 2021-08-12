#!/bin/bash
# Concatenates hourly zipped files into a daily zipped file.

# user input:
station=${1}  # station code
initDoy=${2}  # initial day of year
finalDoy=${3} # final day of year
year=${4}  # year (two- or four-digit)



####dirOut=${6:-$dirIn}  # output data directory


#for dayoy in {$initDayoy..$finalDayoy};do
for (( Dayoy=$initDoy; Dayoy<=$finalDoy; Dayoy++ ))
do

    #verify number of 0's
    if [[ ${#Dayoy} -eq 1 ]]; then
        Doy="00$Dayoy"
    elif [[ ${#Dayoy} -eq 2 ]];then
        Doy="0$Dayoy"
    fi

    ./ftp_merge.sh "$station" "$Doy" "$year"
    
done


exit
