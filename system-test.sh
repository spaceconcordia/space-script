rm /home/logs/*

sh createLogsFile.sh

#Gettime Command
echo -n -e \\x01 > Inet-w-com-r
echo -n -e \\x31 > Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r

echo -n -e \\x01 > Inet-w-com-r
echo -n -e \\x21 > Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r

sleep 1

# Gettime Command again
echo -n -e \\x01 > Inet-w-com-r
echo -n -e \\x31 > Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r

echo -n -e \\x01 > Inet-w-com-r
echo -n -e \\x21 > Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r

sleep 1

#Getlog Command 

#ACS 10 bytes

echo -n -e \\x5 > Inet-w-com-r
echo -n -e \\x33\\x30\\x30\\x31\\x30 > Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r

echo -n -e \\x01 > Inet-w-com-r
echo -n -e \\x21 > Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r

sleep 1

#ACS 25 bytes
echo -n -e \\x5 > Inet-w-com-r
echo -n -e \\x33\\x30\\x30\\x32\\x35 > Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r

echo -n -e \\x01 > Inet-w-com-r
echo -n -e \\x21 > Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r

sleep 1

#ACS 100 bytes
echo -n -e \\x5 > Inet-w-com-r
echo -n -e \\x33\\x30\\x31\\x30\\x30 > Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r

echo -n -e \\x01 > Inet-w-com-r
echo -n -e \\x21 > Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r

sleep 1

#Update command

sh update.sh

sleep 2

#Decode command

echo -n -e \\x36 > Inet-w-com-r
echo -n -e \\x36\\x30\\x30\\x31\\x36\\x2f\\x68\\x6f\\x6d\\x65\\x2f\\x74\\x65\\x6d\\x70\\x2f\\x68\\x65\\x6c\\x6c\\x6f\\x30\\x32\\x30\\x2f\\x68\\x6f\\x6d\\x65\\x2f\\x61\\x70\\x70\\x73\\x2f\\x6e\\x65\\x77\\x2f\\x68\\x65\\x6c\\x6c\\x6f\\x30\\x30\\x30\\x30\\x30\\x30\\x34\\x36\\x38\\x38 > Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r

echo -n -e \\x01 > Inet-w-com-r
echo -n -e \\x21 > Dnet-w-com-r
echo -n -e \\xFF > Inet-w-com-r


