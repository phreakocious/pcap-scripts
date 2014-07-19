#!/bin/bash

########################
# randomizeIPs.sh     #
# phreakocious, 2013 #
#####################

#
# Requires bash4, tshark, hexdump, bittwist
# Replaces each unique IP in a pcap file with a randomly selected one
# It doesn't create a new file, so you might want to save your originals
#


FILE=$1
SUBNET=$2

if [ "$SUBNET" == "" ]; then
	echo
	echo usage: $0 pcapfile subnet
	echo
	exit
fi

declare -A IPMAP


randomip()  { printf $SUBNET".$(( $RANDOM % 253 + 1 ))"; }


echo
echo "-- Processing $FILE --"

# Use tshark to strip out all of the IP addresses, parse and uniq them, shove them into associative array -- We skip multicast because it would break lots of things
for IP in `tshark -Tfields -e ip.src -e ip.dst -r $FILE 2>/dev/null | 
            sed -e 's/\t/\n/' | 
	    grep -ve '^224.*' |
            sort | uniq`; do
		IPMAP[$IP]=`randomip`
done


# Use bittwiste to edit the file until all IPs have been updated
for ORIGIP in "${!IPMAP[@]}"; do
	NEWIP="${IPMAP[$ORIGIP]}"
	echo "-- Changing $ORIGIP to $NEWIP --"
	bittwiste -I $FILE -O tmp-$FILE-randomIP.pcap -T ip -d $ORIGIP,$NEWIP -s $ORIGIP,$NEWIP 2>/dev/null
	mv tmp-$FILE-randomIP.pcap $FILE
done

