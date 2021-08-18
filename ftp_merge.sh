#!/bin/bash

#How to use this script

#In your prompt/terminal, insert:

# script name
# station code
# day of year 
# four digit year

#example: <script name> <station code> <day of year> <four digit year>

#example of using: ftp_merge.sh STBR 020 2021

##################### SCRIPT START #########################

# file extension suffix
suffix='O'

#ftp credentials to download files
ftp_host_download="200.145.185.149"
ftp_user_download="nievinski"
ftp_pass_download="M@m@0Papaya"

#objetivo
ftp_host_upload=143.54.248.215
ftp_port_upload=2121
ftp_user_upload=stbr
ftp_pass_upload=F3l1p3

#ftp credentials to upload files (TESTING)
#ftp_host_upload="ftp.dlptest.com"
#ftp_user_upload="dlpuser"
#ftp_pass_upload="rNrKYTX9g7z3RgJRmxWuGHbeu"

#User's input:
station=${1}  
doy=${2}  # day of year. Precisa acrescentar 0 na frente caso o dia desejado seja menor do que 100
fourDigitYear=${3}


if [ $# -eq 0 ] #test if was not inserted parameters by user

then

station="STBR"
fourDigitYear=$(date +%Y)

doy=$(date +%j)


	if [ $doy -eq 1 ] #test if is the first day of the year
	then
		let doy=365
	else
		let "doy--"
	fi


##falta tratar o caso do ano bisexto

else

	if [ -z "$1" ]; then
	echo "Please, insert station code"
	echo "Using example: <script name> <station code> <day of year> <four year digit>"
	echo "Example: ftp_merge.sh STBR 020 2021"
	exit
	fi

	if [ -z "$2" ]; then
	echo "Please, insert day of year"
	echo "Using example: <script name> <station code> <day of year> <four year digit>"
	echo "Example: ftp_merge.sh STBR 020 2021"
	exit
	fi

	if [ -z "$3" ]; then

	echo "Please, insert four year digit"
	echo "Using example: <script name> <station code> <day of year> <four year digit>"
	echo "Example: ftp_merge.sh STBR 020 2021"
	exit
	fi


	if [[ ${#3} -lt 4 ]]; then
	echo "Please, insert FOUR year digit"
	echo "Using example: <script name> <station code> <day of year> <four year digit>"
	echo "Example: ftp_merge.sh STBR 020 2021"
	fi


fi

#example: <script name> <station code> <day of year> <four year digit>

#example of using: ftp_merge.sh STBR 020 2021



twoDigityear=${fourDigitYear: -2} #using to access data on server
localDirTemp="`pwd`/TemporaryDirectory"

if [[ ${#doy} -eq 1 ]]; then
        doy="00$doy"
    elif [[ ${#doy} -eq 2 ]];then
        doy="0$doy"
fi


remoteDirectoryName="${twoDigityear}${doy}"


#fileName = [cod_estacao(STBR)] + [DIA] + [hora/letra (a-x)] + [ano_(2 dígitos)] [.gz]

echo "Creating temporary directory"	
	mkdir -p "$localDirTemp"

if [[ $? == 0 ]]
then 

	echo "Local temporary directory created"
	echo "                       "
	echo ":::::::::::::::::::::::"
	echo "                       "
	echo "Connecting to server to get daily files" 

else
	echo "Cannot create temporary directory. Check your inputs."
fi


######################################################################
#CONNECT TO SERVER AND DOWNLOAD FILES TO TEMPORARY FOLDER
######################################################################	

ftp -n $ftp_host_download<<END_FTP_SCRIPT
        user $ftp_user_download $ftp_pass_download
      
	passive
	
	prompt
	
	cd $fourDigitYear
	 
	cd $remoteDirectoryName         
       	lcd $localDirTemp
        	
       	mget "*${twoDigityear}_.gz"
       	bye
END_FTP_SCRIPT


######################################################################
#UNZIP ALL FILES OF THE DAY
######################################################################



echo "Unzipping files"

cd $localDirTemp

for a in $station$doy*;
do 

gunzip -d $a

done


######################################################################
#CONNECT ALL FILES OF THE DAY INTO ONE SINGLE

#como há a ideia de fazer paralelismo entre os dias, fazer a concatenação utilizando o nome da estação
#não usar "*."

######################################################################

rm *.gz #remove os arquivos originais e os não descompactados


echo $station$doy_*



cat $station$doy* > $station$doy.$twoDigityear'_'

cd ..

######################################################################
#CONVERT TO RINEX
######################################################################

mkdir -p "OUT_RINEX"

fileNameRINEX=$station$doy'0'.$twoDigityear$suffix


./teqc -sep sbf `pwd`/TemporaryDirectory/$station$doy.$twoDigityear'_' >  `pwd`/"OUT_RINEX"/$fileNameRINEX



rm -rf $localDirTemp #delet temporary directory



######################################################################
#ZIP
######################################################################

gzip -k `pwd`/"OUT_RINEX"/$fileNameRINEX


######################################################################
#UPLOAD TO SERVER
######################################################################


ftp -n $ftp_host_upload $ftp_port_upload<<END_FTP_SCRIPT
        user $ftp_user_upload $ftp_pass_upload
      
	binary
	hash
	debug on
	passive	
	prompt      
  
       	lcd `pwd`/OUT_RINEX/
        	
       	put "$fileNameRINEX.gz"
       	bye

END_FTP_SCRIPT
