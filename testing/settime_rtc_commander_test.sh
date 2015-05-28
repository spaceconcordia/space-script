dir="/home/pipes/"
echo -n -e "\x06" > $dir/Inet-w-com-r

echo -n -e "\x30\x64\x00\x00\x00\x00" > $dir/Dnet-w-com-r

echo -n -e "\xFF" > $dir/Inet-w-com-r

echo -n -e "\x01" > $dir/Inet-w-com-r

echo -n -e "\x21" > $dir/Dnet-w-com-r

echo -n -e "\xFF" > $dir/Inet-w-com-r
