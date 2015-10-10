pcap-scripts
============

Miscellaneous scripts for manipulating pcaps

If you should happen to find this, you may want to make sure they do what you want by reading the code.  Many of these overwrite the original file!
A number of different packages are required like bash4, tshark, tcptrace, bittwist

## Things you can do with these scripts

* Replace all occurrences of an IP with another IP of your choosing
* Replace all occurrences of a TCP port number with another of your choosing
* Replace all occurrences of a MAC address with a random, valid MAC generated for each unique MAC seen in the file
* Reduce pcap file(s) to a single TCP conversation, ideally complete (SYN->FIN|RST) .. Will prompt to select one if there are >1
* Display a list of all TCP conversations in a pcap, using tcptrace to determine the client/server relationship
