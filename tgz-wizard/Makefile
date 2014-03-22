CXX = g++
MICROCC=microblazeel-xilinx-linux-gnu-g++
BB = arm-linux-gnueabi-g++
CPPUTEST_HOME = .
UPDATER_PATH  = ../../space-updater


CPPFLAGS += -Wall -I$(CPPUTEST_HOME)/include
CXXFLAGS += -include $(CPPUTEST_HOME)/include/CppUTest/MemoryLeakDetectorNewMacros.h
CFLAGS += -include $(CPPUTEST_HOME)/include/CppUTest/MemoryLeakDetectorMallocMacros.h
LD_LIBRARIES = -L$(CPPUTEST_HOME)/lib -lCppUTest -lCppUTestExt
MICROCFLAGS=-mcpu=v8.40.b -mxl-barrel-shift -mxl-multiply-high -mxl-pattern-compare -mno-xl-soft-mul -mno-xl-soft-div -mxl-float-sqrt -mhard-float -mxl-float-convert -mlittle-endian -Wall
INCLUDE = -I$(UPDATER_PATH)/include -I./include



#
# 	Compilation for CppUTest
#

test : init fileIO.o dirUtl.o AllTests

fileIO.o: $(UPDATER_PATH)/src/fileIO.cpp $(UPDATER_PATH)/include/fileIO.h
	$(CXX) $(INCLUDE) -c $< -o ./bin/$@

dirUtl.o: src/dirUtl.cpp include/dirUtl.h
	$(CXX) $(INCLUDE) -c $< -o ./bin/$@

AllTests: tests/AllTests.cpp tests/tgz-wizard-test.cpp ./bin/fileIO.o ./bin/dirUtl.o
	$(CXX) $(CFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDE) -o AllTests $^ $(LD_LIBRARIES)

init :
	mkdir -p "./bin"

#
# CleanUp
#
clean :
	rm -f *.o *~ ./bin/*.o

cleanAll:
	rm -f *.o *~ ./bin/*.o
	rm -f AllTests PC-Updater Updater-Q6
