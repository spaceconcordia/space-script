cd ..
CS1=$(pwd)
NETMAN_DIR="$CS1/space-netman"
echo "CS1 Dir: $CS1"

if [ "$#" -ne 1 ]; then
  echo "Enter the build environment"
  read 1 
fi

confirm-build-q6 () {
if [ "$1"="Q6" ]; then
 true
 ;;
else
  false
 ;;
fi
}

set -e # exit on errors or failed steps

setup-netman () {
  echo "Netman Dir: $NETMAN_DIR"
  mkdir -p $NETMAN_DIR/lib/include
  mkdir -p $NETMAN_DIR/bin
}

build-shakespeare () {
  echo '\n Building shakespeare...\n'
  cd $CS1/space-lib/shakespeare
  mkdir -p $CS1/space-lib/shakespeare/lib
  echo "cd: \c"
  pwd
  cp inc/shakespeare.h $NETMAN_DIR/lib/include
  confirm-build-q6 && sh mbcc-compile-lib-static.sh || sh x86-compile-lib-static.sh
  cp lib/libshakespeare.a $NETMAN_DIR/lib
}

build-helium () {
  # Builds libhe100.a 
  echo '\n Building HE-100 Library...\n'
  cd $CS1/HE100-lib/C
  mkdir -p $CS1/HE100-lib/C/lib
  echo "cd: \c" 
  pwd
  sh x86-compile-lib-static-cpp.sh
  cp lib/libhe100-cpp.a $NETMAN_DIR/lib
  cp inc/SC_he100.h $NETMAN_DIR/lib/include
  cd $NETMAN_DIR/lib 
  mv libhe100-cpp.a libhe100.a
}

build-timer () {
  # Timer library
  echo '\n Building timer Library...\n'
  cd $NETMAN_DIR
  cd $CS1/space-timer-lib 
  mkdir -p $CS1/space-timer-lib/lib
  echo "cd: \c" 
  pwd
  sh x86-compile-lib-static-cpp.sh
  cp lib/libtimer.a $NETMAN_DIR/lib
  cp inc/timer.h $NETMAN_DIR/lib/include
}

build-commander () {
  # namedpipe & commander
  echo '\n Building Namedpipes and commander...\n'
  cd $CS1/space-commander
  mkdir -p $CS1/space-commander/lib
  mkdir -p $CS1/space-commander/bin
  echo "cd: \c" 
  pwd
  cp include/Net2Com.h $NETMAN_DIR/lib/include
  cp include/NamedPipe.h $NETMAN_DIR/lib/include
  make buildBin
  cp bin/space-commander $NETMAN_DIR/bin
  make staticlibs.tar
  cp staticlibs.tar $NETMAN_DIR/lib
  cd $NETMAN_DIR/lib
  tar -xf staticlibs.tar
  rm staticlibs.tar
}

setup-netman
build-shakespeare
build-helium
build-timer
build-commander

cd $NETMAN_DIR/lib
ls -al
