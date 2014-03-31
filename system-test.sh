rm /home/logs/*

killall /home/test/read-pipes.sh
killall /home/pipes/Icom-w-net-r
killall /home/pipes/Dcom-w-net-r

echo "Read Pipes"
sh /home/test/read-pipes.sh &

echo "Create Logs"
sh createLogsFile.sh

echo "GetTime Command"
#Gettime Command
echo -n -e \\x01 > /home/pipes/Inet-w-com-r
echo -n -e \\x31 > /home/pipes/Dnet-w-com-r
echo -n -e \\xFF > /home/pipes/Inet-w-com-r

echo -n -e \\x01 > /home/pipes/Inet-w-com-r
echo -n -e \\x21 > /home/pipes/Dnet-w-com-r
echo -n -e \\xFF > /home/pipes/Inet-w-com-r

sleep 1

echo "GetTime Command Again"
# Gettime Command again
echo -n -e \\x01 > /home/pipes/Inet-w-com-r
echo -n -e \\x31 > /home/pipes/Dnet-w-com-r
echo -n -e \\xFF > /home/pipes/Inet-w-com-r

echo -n -e \\x01 > /home/pipes/Inet-w-com-r
echo -n -e \\x21 > /home/pipes/Dnet-w-com-r
echo -n -e \\xFF > /home/pipes/Inet-w-com-r

sleep 1

#Getlog Command 

#ACS 10 bytes
echo "GetLog command - 10 bytes"

echo -n -e \\x5 > /home/pipes/Inet-w-com-r
echo -n -e \\x33\\x30\\x30\\x31\\x30 > /home/pipes/Dnet-w-com-r
echo -n -e \\xFF > /home/pipes/Inet-w-com-r

echo -n -e \\x01 > /home/pipes/Inet-w-com-r
echo -n -e \\x21 > /home/pipes/Dnet-w-com-r
echo -n -e \\xFF > /home/pipes/Inet-w-com-r

sleep 1

#ACS 25 bytes
echo "GetLog command - 25 bytes"

echo -n -e \\x5 > /home/pipes/Inet-w-com-r
echo -n -e \\x33\\x30\\x30\\x32\\x35 > /home/pipes/Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r

echo -n -e \\x01 > /home/pipes/Inet-w-com-r
echo -n -e \\x21 > /home/pipes/Dnet-w-com-r
echo -n -e \\xFF > /home/pipes/Inet-w-com-r

sleep 1

#ACS 100 bytes
echo "GetLog command - 100 bytes"

echo -n -e \\x5 > /home/pipes/Inet-w-com-r
echo -n -e \\x33\\x30\\x31\\x30\\x30 > /home/pipes/Dnet-w-com-r
echo -n -e \\xFF > /home/pipes/Inet-w-com-r

echo -n -e \\x01 > /home/pipes/Inet-w-com-r
echo -n -e \\x21 > /home/pipes/Dnet-w-com-r
echo -n -e \\xFF > /home/pipes/Inet-w-com-r

sleep 1

#Update command

echo "Update command"
sh update.sh

sleep 2

#Decode command

echo "Decode command"

echo -n -e \\x3c > /home/pipes/Inet-w-com-r
echo -n -e \\x36\\x31\\x30\\x31\\x36\\x2f\\x68\\x6f\\x6d\\x65\\x2f\\x74\\x65\\x6d\\x70\\x2f\\x68\\x65\\x6c\\x6c\\x6f\\x30\\x32\\x36\\x2f\\x68\\x6f\\x6d\\x65\\x2f\\x61\\x70\\x70\\x73\\x2f\\x6e\\x65\\x77\\x2f\\x68\\x65\\x6c\\x6c\\x6f\\x2f\\x68\\x65\\x6c\\x6c\\x6f\\x30\\x30\\x30\\x30\\x30\\x30\\x34\\x36\\x38\\x38 > /home/pipes/Dnet-w-com-r
echo -n -e \\xFF > /home/pipes/Inet-w-com-r

echo -n -e \\x01 > /home/pipes/Inet-w-com-r
echo -n -e \\x21 > /home/pipes/Dnet-w-com-r
echo -n -e \\xFF > /home/pipes/Inet-w-com-r
