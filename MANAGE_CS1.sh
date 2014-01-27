#!/bin/bash
# DEPENDENCIES:
command -v git >/dev/null 2>&1 || { echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }
command -v g++ >/dev/null 2>&1 || { echo >&2 "I require g++ but it's not installed.  Aborting."; exit 1; }
command -v gcc >/dev/null 2>&1 || { echo >&2 "I require gcc but it's not installed.  Aborting."; exit 1; }
#http://en.wikibooks.org/wiki/Bash_Shell_Scripting/Whiptail
#http://snipplr.com/view/63919/
#API="https://api.github.com"
#GITHUBLIST=`curl --silent -u $USER:$PASS ${API}/orgs/${ORG}/repos -q | grep name | awk -F': "' '{print $2}' | sed -e 's/",//g'`
READ_DIR=$(readlink -f "$0")
CURRENT_DIR=$(dirname "$READ_DIR")
project_name='https://github.com/spaceconcordia/'
RepoList[0]='baby-cron'
RepoList[1]='space-commander'
RepoList[2]='space-jobs'
RepoList[3]='space-netman'
RepoList[4]='space-script'
RepoList[5]='space-tools'
RepoList[8]='space-timer-lib'
RepoList[9]='acs'
RepoList[10]='SRT'
RepoList[11]='mail_arc'

confirm () {
    read -r -p "${1:-[y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

cs1-inst-mbcc () {
   cd $CURRENT_DIR/Microblaze
   sh xsc-devkit-installer-lit.sh 
}

cs1-clone () {
    printf "git clone %s%s .\n" $project_name $1; 
    git clone $project_name$item $1
}

cs1-update () {
    cd $1
    printf "git pull origin master #%s\n" $1; 
    git pull origin master 
    cd $CURRENT_DIR
}

cs1-build-pc () {
    cd $CURRENT_DIR/space-script
    printf "sh get-libs-PC.sh\n"
    sh get-libs-PC.sh
    echo "Building Commander..."
    cd $CURRENT_DIR/space-commander
    make buildBin
    echo "Building Netman..."
    cd $CURRENT_DIR/space-netman
    make
    mkdir -p $CURRENT_DIR/BUILD/PC
    cp $CURRENT_DIR/space-commander/bin/space-commander $CURRENT_DIR/BUILD/PC/
    cp $CURRENT_DIR/space-netman/bin/gnd $CURRENT_DIR/BUILD/PC/
    cp $CURRENT_DIR/space-netman/bin/sat $CURRENT_DIR/BUILD/PC/
    cd $CURRENT_DIR
    echo 'Binaries left in $CURRENT_DIR/BUILD/PC'
}

cs1-build-q6 () {
    cd $CURRENT_DIR/space-script
    printf "sh get-libs-Q6.sh\n"
    sh get-libs-Q6.sh
    echo "Building Commander..."
    cd $CURRENT_DIR/space-commander
    make buildQ6
    echo "Building Netman..."
    cd $CURRENT_DIR/space-netman
    make Q6
    mkdir -p $CURRENT_DIR/BUILD/Q6
    cp $CURRENT_DIR/space-commander/bin/space-commanderQ6 $CURRENT_DIR/BUILD/Q6/
    cd $CURRENT_DIR/space-netman
    make Q6
    cp $CURRENT_DIR/space-netman/bin/gnd-mbcc $CURRENT_DIR/BUILD/Q6/
    cp $CURRENT_DIR/space-netman/bin/sat-mbcc $CURRENT_DIR/BUILD/Q6/
    cd $CURRENT_DIR
    echo 'Binaries left in $CURRENT_DIR/BUILD/Q6'
}

echo "Repo size: ${#RepoList[*]}"
echo "Current Dir: $CURRENT_DIR"
if [ -d $item ]; then
    for item in ${RepoList[*]}
    do
        cd $item
        CHANGED=$(git diff-index --name-only HEAD --)
        if [ -n "$CHANGED" ]; then
            printf "%s has changes\n" $item
        fi;
        cd $CURRENT_DIR
    done;
fi;
echo "---"
echo "Clone missing projects?";
confirm && clone=1;

echo "Update cloned projects?";
confirm && update=1;

for item in ${RepoList[*]}
do
    if [ $clone ]; then
        if [ ! -d "$item" ]; then 
            cs1-clone $item
        fi;
    fi;
    if [ $update ]; then
        if [ -d "$item" ]; then 
            cs1-update $item
        fi;
    fi;
done;

echo "(Re)install Microblaze Environment?"
confirm && cs1-inst-mbcc

echo "Build project for PC?";
confirm && buildPC=1;

echo "Build project for Q6?";
confirm && buildQ6=1;

if [ $buildPC ]; then
    if [ -d "space-script" ]; then
        cs1-build-pc
    fi;
fi;

if [ $buildQ6 ]; then
    if [ -d "space-script" ]; then
        cs1-build-q6
    fi;
fi;
