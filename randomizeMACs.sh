#!/bin/bash

########################
# randomizeMACs.sh    #
# phreakocious, 2012 #
#####################

#
# Requires bash4, tshark, hexdump, bittwist
# Replaces each unique MAC in a pcap file with a randomly selected one
# It doesn't create a new file, so you might want to save your originals
#

FILE=$1

if [ "$FILE" == "" ]; then
	echo
	echo usage: randomizeMacs.sh pcapfile
	echo
	exit
fi

declare -A MACMAP


# Generate a random MAC address from 5 bytes of /dev/urandom
randommac() { printf 00 && dd if=/dev/urandom bs=5 count=1 2>/dev/null | hexdump -ve '/1 ":%02x"' ; }


echo
echo "-- Processing $FILE --"

# Use tshark to strip out all of the mac addresses, parse and uniq them, shove them into associative array
for MAC in `tshark -Tfields -e eth.src -e eth.dst -r $FILE 2>/dev/null | 
            sed -e 's/\t/\n/' | 
            grep -ve "ff:ff:ff:ff:ff:ff" -e "00:00:00:00:00:00" -e '^01:00:5e.*' -e '^01:00:0c:cc:cc' | 
            sort | uniq`; do
		MACMAP[$MAC]=`randommac`
done


# Use bittwiste to edit the file until all MACs have been upated
for ORIGMAC in "${!MACMAP[@]}"; do
	NEWMAC="${MACMAP[$ORIGMAC]}"
	echo "-- Changing $ORIGMAC to $NEWMAC --"
	bittwiste -I $FILE -O tmp-$FILE-randomMac.pcap -T eth -d $ORIGMAC,$NEWMAC -s $ORIGMAC,$NEWMAC 2>/dev/null
	mv tmp-$FILE-randomMac.pcap $FILE
done

