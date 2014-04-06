setup () {
  rm /home/logs/*

  killall /home/test/read-pipes.sh
  killall /home/pipes/Icom-w-net-r
  killall /home/pipes/Dcom-w-net-r

  echo "Read Pipes"
  sh /home/test/read-pipes.sh &

  echo "Create Logs"
  sh createLogsFile.sh

  mkdir -p /var/log/telemetryPowerLog
}

teardown () {
  read-pipes.sh
}

readpwrad7998 () {
  /home/apps/current/jobs/read-pwr-ad7998
  cat /var/log/telemetryPowerLog/*
}

getlogacs10 () {
  #ACS 10 bytes
  echo "GetLog command - 10 bytes"

  echo -n -e \\x5 > /home/pipes/Inet-w-com-r
  echo -n -e \\x33\\x30\\x30\\x31\\x30 > /home/pipes/Dnet-w-com-r
  echo -n -e \\xFF > /home/pipes/Inet-w-com-r

  echo -n -e \\x01 > /home/pipes/Inet-w-com-r
  echo -n -e \\x21 > /home/pipes/Dnet-w-com-r
  echo -n -e \\xFF > /home/pipes/Inet-w-com-r
}

getlogacs25 () {
  #ACS 25 bytes
  echo "GetLog command - 25 bytes"

  echo -n -e \\x5 > /home/pipes/Inet-w-com-r
  echo -n -e \\x33\\x30\\x30\\x32\\x35 > /home/pipes/Dnet-w-com-r
  echo -n -e \\xFF > Inet-w-com-r

  echo -n -e \\x01 > /home/pipes/Inet-w-com-r
  echo -n -e \\x21 > /home/pipes/Dnet-w-com-r
  echo -n -e \\xFF > /home/pipes/Inet-w-com-r
}

getlogacs100 () {
  #ACS 100 bytes
  echo "GetLog command - 100 bytes"

  echo -n -e \\x5 > /home/pipes/Inet-w-com-r
  echo -n -e \\x33\\x30\\x31\\x30\\x30 > /home/pipes/Dnet-w-com-r
  echo -n -e \\xFF > /home/pipes/Inet-w-com-r

  echo -n -e \\x01 > /home/pipes/Inet-w-com-r
  echo -n -e \\x21 > /home/pipes/Dnet-w-com-r
  echo -n -e \\xFF > /home/pipes/Inet-w-com-r
}

#Update command

update () {
  echo "Update command"
  sh update.sh
}


gettime () {
  echo "GetTime Command"
  #Gettime Command
  echo -n -e \\x01 > /home/pipes/Inet-w-com-r
  echo -n -e \\x31 > /home/pipes/Dnet-w-com-r
  echo -n -e \\xFF > /home/pipes/Inet-w-com-r

  echo -n -e \\x01 > /home/pipes/Inet-w-com-r
  echo -n -e \\x21 > /home/pipes/Dnet-w-com-r
  echo -n -e \\xFF > /home/pipes/Inet-w-com-r
}

decode () {
  #Decode command
  echo "Decode command"

  echo -n -e \\x3c > /home/pipes/Inet-w-com-r
  echo -n -e \\x36\\x31\\x30\\x31\\x36\\x2f\\x68\\x6f\\x6d\\x65\\x2f\\x74\\x65\\x6d\\x70\\x2f\\x68\\x65\\x6c\\x6c\\x6f\\x30\\x32\\x36\\x2f\\x68\\x6f\\x6d\\x65\\x2f\\x61\\x70\\x70\\x73\\x2f\\x6e\\x65\\x77\\x2f\\x68\\x65\\x6c\\x6c\\x6f\\x2f\\x68\\x65\\x6c\\x6c\\x6f\\x30\\x30\\x30\\x30\\x30\\x30\\x34\\x36\\x38\\x38 > /home/pipes/Dnet-w-com-r
  echo -n -e \\xFF > /home/pipes/Inet-w-com-r

  echo -n -e \\x01 > /home/pipes/Inet-w-com-r
  echo -n -e \\x21 > /home/pipes/Dnet-w-com-r
  echo -n -e \\xFF > /home/pipes/Inet-w-com-r
}

sigint_handler () {
    echo " >> Caught SIGINT, breaking current loop";
    break;
}

setup

running=1;
until [ $running = 0 ]; do
    trap sigint_handler 2 
    echo "OPTIONS:"
    echo "Enter 0 to execute gettime";
    echo "Enter 1 to 10 bytes from acs log";
    echo "Enter 2 to 25 bytes from acs log";
    echo "Enter 3 to 100 bytes from acs log";
    echo "Enter 4 to demo update";
    echo "Enter 5 to demo decode";
    echo "Enter 6 to read pwr-ad7998 sensor";
    echo "Enter q to quit";
    read reply;
    case "$reply" in 
        0)  gettime; 
            ;;
        1)  getlogacs10;
            ;;
        2)  getlogacs25;
            ;;
        3)  getlogacs100;
            ;;
        4)  update;
            ;;        
        5)  decode;
            ;;
        6)  readpwrad7998;
            ;;            
        q)  running=0;
            teardown;
            echo "Exiting...";
            exit 1;
            ;;
    esac;
done;
cleanup;
