#!/usr/bin/env bash

########################
# summarizePcaps.sh   #
# phreakocious, 2012 #
#####################

#
# Requires bash4, tshark, tcptrace
# Build an IP to MAC table from the pcap file using tshark for only TCP traffic
# Determine the client/server relationship for the sessions with tcptrace
# Mulitcast and broadcast are not included
# Print a single line for each conversation in the format described
# ASSUMPTION -- For every IP seen in the pcap, only a single MAC is present
#               (this is not necessarily the case in the real world!)
#

set -e
shopt -s expand_aliases

(sed -r 2>/dev/null) || alias sed=gsed

if [ "$*" == "" ]; then
    echo usage: $0 file1.pcap [file2.pcap...]
    echo
    exit
fi

declare -A IPTOMAC

echo
echo \# filename clientmac clientip clientport  servermac serverip serverport


for FILE in $*; do

      while read MAC IP; do
            #echo "mac=$MAC ip=$IP"
            IPTOMAC[$IP]=$MAC
      done < <(tshark -Tfields -e eth.src -e ip.src -e eth.dst -e ip.dst -r $FILE -R tcp 2> >(grep -v dangerous) |
               awk '{print $1,$2; print $3,$4}' |
               sort | uniq)

    tcptrace -n $FILE |
        egrep '^\s+[0-9]:' |
        sed -r -e 's/^\s+[0-9]:\s//' -e 's/:/ /g' -e 's/\s+-\s+/ /' -e 's/\s+\(.*//' |
        while read CLIENTIP CLIENTPORT SERVERIP SERVERPORT; do
            echo "$FILE ${IPTOMAC[$CLIENTIP]} $CLIENTIP $CLIENTPORT  ${IPTOMAC[$SERVERIP]} $SERVERIP $SERVERPORT"
        done

    done

echo
