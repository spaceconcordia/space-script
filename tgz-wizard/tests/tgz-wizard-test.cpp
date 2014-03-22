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
#include "dirUtl.h"
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
        #ifdef DEBUG
        printf("[CHILD]");
        printf("%s %s %s %s %s %s", tgzWizard, app, "-l", logs, "-t", tgz);
        #endif

        execl(tgzWizard, tgzWizard, app, "-l", logs, "-t", tgz, (char*)NULL);
    }else{
        wait(&status); 
        CHECK(0 == status);

        printf(untarCmd);
        system(untarCmd);       // untar int /logs
        

        int sizeSrc = getDirSize(testfiles);
        int sizeDest = getDirSize(logs);

        CHECK(sizeDest == sizeSrc);
    }
}

TEST(TgzWizardTestGroup, testExtractErrorWarning){
    int pid = fork();
    int status = 0;
    const char* app = "Error-Warning";
    char untarCmd[CMD_BUFFER] = {0};
    sprintf(untarCmd, "cat %s/%s*.tgz* | tar zx -C %s", tgz, app, logs);

    if (pid == 0){  // child process
        printf("[CHILD]");
        printf("%s %s %s %s %s %s", tgzWizard, app, "-l", logs, "-t", tgz);
        execl(tgzWizard, tgzWizard, app, "-l", logs, "-t", tgz, (char*)NULL);
    }else{
        wait(&status); 
        CHECK(0 == status);

        printf(untarCmd);
        system(untarCmd); 
        FAIL("TODO");
        // check that :: grep '(ERROR|WARNING)' errFile | wc -l   ==   meme grep allOtherFiles | wc -l
        
    }
}




TEST_GROUP(DirUtlTestGroup)
{
    void setup(){
    }
    void teardown(){
    }
};


TEST(DirUtlTestGroup, testGetDirSize_SizeIsRight){
    int size = getDirSize(testfiles);    
    char duCmd[CMD_BUFFER] = {0};
    sprintf(duCmd, "du -b %s", testfiles);

    #ifdef DEBUG
        printf("size of %s : %d\n", testfiles, size);
    #endif

    char cmdOut[CMD_BUFFER] = {0};
    FILE *cmd = popen(duCmd,"r");

    while (fgets(cmdOut, sizeof(cmdOut), cmd) != 0) {
        /*...*/
    }
   
    int sizeWithDuCmd = atoi(cmdOut); 
    
    pclose(cmd);
    
    #ifdef DEBUG
        printf("%d == %d\n", size, sizeWithDuCmd);
    #endif
    CHECK(size == sizeWithDuCmd);

}
