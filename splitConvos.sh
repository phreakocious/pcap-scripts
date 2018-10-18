#!/usr/bin/env bash

###########################
# splitConvos.sh         #
# phreakocious, 10/2018 #
########################

#
# Requires bash, tshark, capinfos, tcpsplit
# Produces a separate capture file for each conversation in the provided pcap
# Creates a temporary directory, copies the pcap there, converts to pcap format if necesary
#

source_pcap=$1
protocol=${2:-tcp}   #TODO: support doing all protocols

[ ! -f "$source_pcap" ] && echo "File '$source_pcap' doesn't seem to exist" && exit 1


get_format() { pcap=$1 ; capinfos -t "$pcap" | awk '/File type/ { print $NF }' ; }

convert_to_pcap() {   # tcpsplit only likes the older pcap format...
    pcap=$1
    echo -e "Converting to pcap format"
    tshark -n -r "$pcap" -F pcap -w tmp_convert_pcap
    mv tmp_convert_pcap "$pcap"
}

split() {   #TODO: just replace tcpsplit..................
    pcap=$1
    tcpsplit "$pcap" "${pcap}___%d" 250          # tcpsplit is a piece of shit and needs file count up front... get 250..
    find . -size 24c -exec rm {} + 2>/dev/null   # and delete the empty ones manually...  #NOTE: 24 bytes seems consistent.. maybe not
    ls -1 "${pcap}___"* | sort -n -t_ -k4
}

get_convos() {
    pcap=$1 ; proto=$2
    tshark -q -n -z conv,$proto -r "$pcap" | awk '/<->/ {print $1, $3}'
}

clean_up() {
    echo -e "\nDeleting $tmp_dir "
    rm -rf "$tmp_dir"
    exit
}


pcap=$(basename "$source_pcap")
split_name="${pcap}__${protocol}_split"

old_dir=$(pwd)
tmp_dir=$(mktemp -d) || exit 1

mkdir "$tmp_dir/$split_name"

echo -e "Copying $pcap to $tmp_dir/ "
cp "$source_pcap" "$tmp_dir"
cd "$tmp_dir"

get_format "$pcap" | grep -qFx 'pcap' || convert_to_pcap "$pcap"

echo -e "Splitting\n"
for split_pcap in $(split "$pcap"); do
    get_convos $split_pcap $protocol | while read convo; do
        echo "  $split_pcap $protocol $convo"
        new_name=${protocol}_${convo// /__}.pcap
        mv "$split_pcap" "$split_name/$new_name"
    done
done


cd "$old_dir"
rmdir "$tmp_dir/$split_name" 2>/dev/null && printf "No $protocol conversations found. " && clean_up

ts=$(date +%Y%m%d-%H%M%S)
tar_file="${split_name}_${ts}.tar"

echo
while read -n1 -p "'s' to save convos to '$tar_file', 'd' to delete working dir, 'q' to bail... " yn; do
    echo
    case $yn in
        [SsYy]* ) echo -e "\nSaving to $tar_file" ; tar cf "$tar_file" -C "$tmp_dir" "$split_name" ; break ;;
        [DdNn]* ) break ;;
        [QqXx]* ) echo -e "\nQuitting.  Files still exists in $tmp_dir\n" ; exit ;;
    esac
done


clean_up