#!/bin/bash           

LIBRARY=$1
STERMSFILE=$2
TEMPTERMFILE="terms"

cat $STERMSFILE | while read TERM           
do           
  echo "$TERM"
  echo $TERM > $TEMPTERMFILE
  echo "Doing: " $TEMPTERMFILE ${LIBRARY}_${TERM// /_}.bib $LIBRARY
  ruby SLR.rb $TEMPTERMFILE ${LIBRARY}_${TERM// /_}.bib $LIBRARY
done
