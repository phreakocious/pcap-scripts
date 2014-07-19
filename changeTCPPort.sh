#!/bin/bash

########################
# changeTCPPort.sh    #
# phreakocious, 2012 #
#####################

#
# Requires bittwiste from bittwist package
# Replaces each occurrence of an TCP port in a pcap file with another number 
# It doesn't create a new file, so you might want to save your originals
#

FILE=$1
OLD=$2
NEW=$3

if [ "$NEW" == "" ]; then
	echo
	echo usage: $0 pcapfile oldport newport
	echo
	exit
fi

echo
echo "-- Processing $FILE --"
echo "-- Changing $OLD to $NEW --"
echo

bittwiste -I $FILE -O tmp-$FILE-changeTCPPort.pcap -T ip -d $OLD,$NEW -s $OLD,$NEW 2>/dev/null
mv tmp-$FILE-changeTCPPort.pcap $FILE

