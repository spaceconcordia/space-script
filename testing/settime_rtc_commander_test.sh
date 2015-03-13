dir="/home/pipes/"
echo -n -e \x01 > $dir/Inet-w-com-r

echo -n -e \x30\xD8\x56\xB1\x18 > $dir/Dnet-w-com-r

echo -n -e \xFF > $dir/Inet-w-com-r

echo -n -e \x01 > $dir/Inet-w-com-r

echo -n -e \x21 > $dir/Dnet-w-com-r

echo -n -e \xFF > $dir/Inet-w-com-r
