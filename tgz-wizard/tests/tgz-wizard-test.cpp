//******************************************/
//  SPACE CONCORDIA 2013
//
//
//******************************************/
#include "CppUTest/TestHarness.h"
#include <cstdio>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string>
#include <fileIO.h>
using namespace std;
//************************************************************
//************************************************************
//              TgzWizardTestGroup
//************************************************************
//************************************************************
#define CMD_BUFFER 400
const char* testfiles = "./tests/testfiles";        // sample log files, don't delete!
const char* logs = "./tests/test-logs";
const char* tgz = "./tests/test-tgz";
const char* tgzWizard = "./tgzWizard.sh";
TEST_GROUP(TgzWizardTestGroup)
{
    void setup(){
        mkdir(logs, 0775);
        mkdir(tgz, 0775);
        CopyDirRecursively(testfiles, logs);
    }
    void teardown(){
        DeleteDirectoryContent(logs);
        DeleteDirectoryContent(tgz);
        remove(logs);
        remove(tgz);
    }
};
//----------------------------------------------
//  StartUpdate 
//----------------------------------------------
TEST(TgzWizardTestGroup, testTgzWizard){
    int pid = fork();
    int status = 0;
    const char* app = "Watch-Puppy";
    char untarCmd[CMD_BUFFER] = {0};
    sprintf(untarCmd, "cat %s/%s*.tgz* | tar zx -C %s", tgz, app, logs);

    if (pid < 0){
        FAIL("fork() has failed");
        return;
    }

    if (pid == 0){  // child process
        printf("[CHILD]");
        printf("%s %s %s %s %s %s", tgzWizard, app, "-l", logs, "-t", tgz);
        execl(tgzWizard, tgzWizard, app, "-l", logs, "-t", tgz, (char*)NULL);
    }else{
        wait(&status); 
        CHECK(0 == status);

        printf(untarCmd);
        system(untarCmd); 
        
        struct stat strSt;
        stat(testfiles, &strSt);
        struct stat destSt;
        stat(logs, &destSt);

        CHECK(strSt.st_size == destSt.st_size);
    }
}

TEST(TgzWizardTestGroup, testExtractErrorWarning){
    FAIL("TODO");
}
