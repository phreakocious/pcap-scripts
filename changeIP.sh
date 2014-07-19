#!/bin/bash

########################
# changeIP.sh         #
# phreakocious, 2012 #
#####################

#
# Requires bittwist
# Replaces each occurrence of an IP in a pcap file with another IP 
# It doesn't create a new file, so you might want to save your originals
#

FILE=$1
OLDIP=$2
NEWIP=$3

if [ "$NEWIP" == "" ]; then
	echo
	echo usage: changeIP.sh pcapfile oldip newip
	echo
	exit
fi

echo
echo "-- Processing $FILE --"
echo "-- Changing $OLDIP to $NEWIP --"
echo

bittwiste -I $FILE -O tmp-$FILE-changeIP.pcap -T ip -d $OLDIP,$NEWIP -s $OLDIP,$NEWIP 2>/dev/null
mv tmp-$FILE-changeIP.pcap $FILE

