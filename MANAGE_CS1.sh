#!/bin/bash
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; fi;
#http://en.wikibooks.org/wiki/Bash_Shell_Scripting/Whiptail
#http://snipplr.com/view/63919/
#API="https://api.github.com"
#GITHUBLIST=`curl --silent -u $USER:$PASS ${API}/orgs/${ORG}/repos -q | grep name | awk -F': "' '{print $2}' | sed -e 's/",//g'`

declare -a SysReqs=('git' 'g++' 'gcc')
for item in ${SysReqs[*]}; do command -v $item >/dev/null 2>&1 || { echo >&2 "I require $item but it's not installed.  Aborting."; exit 1; }; done

READ_DIR=$(readlink -f "$0")
CURRENT_DIR=$(dirname "$READ_DIR")
project_name='https://github.com/spaceconcordia/'
declare -a RepoList=('acs' 'baby-cron' 'ground-commander' 'HE100-lib' 'mail_arc' 'space-commander' 'space-lib' 'space-jobs' 'space-netman' 'space-script' 'space-tools' 'space-timer-lib' 'SRT')

#check-errors () {
    #Fatal 
    #error
    #No such file or directory
    #make: *** [target] Error 1
#}

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

for item in ${RepoList[*]}
    do
    if [ -d "$item" ]; then
        cd $item
        CHANGED=$(git diff-index --name-only HEAD --)
        if [ -n "$CHANGED" ]; then
            echo "---"
            printf "%s has local changes\n" $item
            git status
        fi;
        cd $CURRENT_DIR
    fi;
done;

echo "---"
echo "Clone missing projects?";
confirm && clone=1;

echo "Pull updates for cloned projects?";
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
