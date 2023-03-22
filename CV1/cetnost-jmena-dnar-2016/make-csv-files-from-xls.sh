#!/bin/sh

FILE_XLS=${1:-cetnost-jmena-dnar.xls}
FILE_CSV=${FILE_XLS%.xls}.csv
FILE_CSV_HEAD=${FILE_CSV%.csv}.head.csv
FILE_CSV_TAIL=${FILE_CSV%.csv}.tail.csv

# convert the active sheet to CSV (Field Separator 44=','; Text Delimiter 34='"'; Character Set 76=utf8)
libreoffice --convert-to "csv:Text - txt - csv (StarCalc):44,34,76" ${FILE_XLS}
# wait for the end of the convert operation
sleep 5
# remove the 2nd, the 3rd and the last two columns
sed -i -e 's/^\([^,]*\),[^,]*,[^,]*,/\1,/g' -e 's/,[^,]*,[^,]*$//g' ${FILE_CSV}
# split
#head -n 1 ${FILE_CSV} > ${FILE_CSV_HEAD}
#tail -n +2 ${FILE_CSV} > ${FILE_CSV_TAIL}
