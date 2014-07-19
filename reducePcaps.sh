#!/bin/bash

########################
# reducePcaps.sh      #
# phreakocious, 2012 #
#####################

#
# Requires bash4, tcptrace, tshark
# Reduce PCAP file(s) to a single, complete (SYN->FIN) TCP conversation
# If a single complete conversation isn't found, the user will be prompted to select one
# It doesn't create a new file, so you might want to save your originals
#

reduce() {
	PCAP=$1
	STRING=$2
	echo -e "$STRING" | sed -r -e 's/^\s+[0-9]:\s//' -e 's/:/ /g' -e 's/\s+-\s+/ /' -e 's/\s+\(.*//' | while read CLIENTIP CLIENTPORT SERVERIP SERVERPORT; do
		#echo "client ip: $CLIENTIP  client port: $CLIENTPORT  server ip: $SERVERIP  server port: $SERVERPORT"
		tcpdump -n -r $PCAP -w TMP-$PCAP host $CLIENTIP and host $SERVERIP and port $CLIENTPORT and port $SERVERPORT >/dev/null 2>&1
		mv TMP-$PCAP $PCAP
	done
}

echo

if [ "$*" == "" ]; then
	echo usage: $0 file1.pcap [file2.pcap...]
	echo
	exit
fi

for FILE in $*; do
	TCPTRACE=`tcptrace -n $FILE | egrep '^\s+[0-9]:'`
	SESSIONS=`echo -e "$TCPTRACE" | wc -l`
        COMPLETE=`echo -e "$TCPTRACE" | grep 'complete' | wc -l`

	case "$SESSIONS" in

	0)	echo $FILE contains NO TCP sessions!
		continue
		;;

	1)	if [ "$COMPLETE" -eq 1 ]; then
			echo $FILE contains a single complete TCP session!
		else
			echo "$FILE contains a single TCP session, but it's NOT complete!"
		fi
		continue
		;;

	*) 	if [ "$COMPLETE" == 0 || "$COMPLETE" -gt 1 ]; then
			echo -e "$TCPTRACE"
			printf  "$FILE contains $SESSIONS TCP sessions, select one to keep:"
			read KEEP
			KEEPER=`echo -e "$TCPTRACE" | egrep "^\s+$KEEP:"`
			reduce $FILE "$KEEPER"
		fi

		if [ "$COMPLETE" == 1 ]; then
			echo $FILE contains $SESSIONS TCP sessions, and only one is complete, keeping it!
			KEEPER=`echo -e "$TCPTRACE" | grep "complete"`
			reduce $FILE "$KEEPER"
		fi
		;;
	esac
done
		
echo
