CC=gcc
CXX=g++
CXX_FLAGS=-fpermissive
MICROCC=microblazeel-xilinx-linux-gnu-gcc
MICROPP=microblazeel-xilinx-linux-gnu-g++
BEAGLECC=arm-linux-gnueabi-g++
#CFLAGS=-static
MICROCFLAGS=-mcpu=v8.40.b -mxl-barrel-shift -mxl-multiply-high -mxl-pattern-compare -mno-xl-soft-mul -mno-xl-soft-div -mxl-float-sqrt -mhard-float -mxl-float-convert -mlittle-endian -Wall
DEBUGFLAGS=-ggdb -g -gdwarf-2 -g3 #gdwarf-2 + g3 provides macro info to gdb
INCPATH=-I./inc/
MICROINCPATH=-I./inc/Q6/
PCINCPATH=-I./inc/PC/
BBINCPATH=-I./inc/BB/
LIBPATH=-L./lib

buildBin:
	$(CXX) $(CXX_FLAGS) $(INCPATH) $(PCINCPATH) $(LIBPATH) $(DEBUGFLAGS) -static -c src/schedule-command.cpp -o lib/schedule-command.o 

buildQ6:
	$(MICROPP) $(CXX_FLAGS) $(MICROCFLAGS) $(INCPATH) $(MICROINCPATH) $(LIBPATH) $(DEBUGFLAGS) -static -c src/schedule-command.cpp -o lib/schedule-command-mbcc.o 

buildBB:
	$(BEAGLECC) $(CXX_FLAGS) $(INCPATH) $(BBINCPATH) $(LIBPATH) $(DEBUGFLAGS) -static -c src/schedule-command.cpp -o lib/schedule-command-BB.o 
