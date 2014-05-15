/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*
* AUTHORS : Space Concordia 2014, Joseph 
*
* TITLE : tgz-wizard-test.cpp
*
*----------------------------------------------------------------------------*/
#include <cstdio>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string>
#include <fileIO.h>

#include "CppUTest/TestHarness.h"
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
const char* tgzWizard = "./tgzWizard";

TEST_GROUP(TgzWizardTestGroup)
{
    void setup()
    {
        mkdir(logs, 0775);
        mkdir(tgz, 0775);
        CopyDirRecursively(testfiles, logs);
    }

    void teardown()
    {
        DeleteDirectoryContent(logs);
        DeleteDirectoryContent(tgz);
        remove(logs);
        remove(tgz);
    }
};

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*
* GROUP : TgzWizardTestGroup 
*
* NAME : tarOneFile_defaultOpt
* 
*-----------------------------------------------------------------------------*/
TEST(TgzWizardTestGroup, tarOneFile_defaultOpt)
{
    int pid = fork();
    int status = 0;
    const char* filename = "Updater20140101";
    char untarCmd[CMD_BUFFER] = {0};
    sprintf(untarCmd, "cat %s/%s.0.tgz* | tar zx -C %s", tgz, filename, logs);

    if (pid < 0){
        FAIL("fork() has failed");
        return;
    }

    if (pid == 0){  // child process
        #ifdef DEBUG
            printf("[CHILD]");
            printf("%s %s %s %s %s %s %s", tgzWizard, "-f", filename, "-l", logs, "-t", tgz);
        #endif

        execl(tgzWizard, tgzWizard, "-f", filename, "-l", logs, "-t", tgz, (char*)NULL);
    } else {
        wait(&status); 
        CHECK(0 == status);

        #ifdef DEBUG
            printf(untarCmd);
        #endif
        system(untarCmd);       // untar in /logs
        
#define PATH_BUF 100
        char file1[PATH_BUF] = {'\0'};
        char file2[PATH_BUF] = {'\0'};

        snprintf(file1, PATH_BUF, "%s/%s.log", testfiles, filename);
        snprintf(file2, PATH_BUF, "%s/%s.log", logs, filename);

        CHECK(diff(file1, file2));
    }
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*
* GROUP : TgzWizardTestGroup 
*
* NAME : 
* 
*-----------------------------------------------------------------------------*/
TEST(TgzWizardTestGroup, testExtractErrorWarning)
{
    FAIL("TODO");
    return;

    int pid = fork();
    int status = 0;
    const char* app = "Error-Warning";
    char untarCmd[CMD_BUFFER] = {0};
    sprintf(untarCmd, "cat %s/%s*.tgz* | tar zx -C %s", tgz, app, logs);

    if (pid == 0){  // child process
        printf("[CHILD]");
        printf("%s %s %s %s %s %s", tgzWizard, app, "-l", logs, "-t", tgz);
        execl(tgzWizard, tgzWizard, app, "-l", logs, "-t", tgz, (char*)NULL);
    } else {
        wait(&status); 
        CHECK(0 == status);

        printf("%s", untarCmd);
        system(untarCmd); 
        // check that :: grep '(ERROR|WARNING)' errFile | wc -l   ==   meme grep allOtherFiles | wc -l
        
    }
}

//************************************************************
//************************************************************
//              DirUtlTestGroup
//************************************************************
//************************************************************
TEST_GROUP(DirUtlTestGroup)
{
    void setup(){
    }
    void teardown(){
    }
};

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*
* GROUP : DirUtlTestGroup 
*
* NAME : testDiff_filesAreIdentical_returnsTrue
* 
*-----------------------------------------------------------------------------*/
TEST(DirUtlTestGroup, testDiff_filesAreIdentical_returnsTrue)
{
    const char* data = "asdfsadf;lkj1243;lkjsdf";

    FILE* file1 = fopen("a.txt", "w+");    
    fprintf(file1, "%s", data);
    fclose(file1);

    FILE* file2 = fopen("b.txt", "w+");
    fprintf(file2, "%s", data);
    fclose(file2);

    CHECK(diff("a.txt", "b.txt"));

    remove("a.txt");
    remove("b.txt");
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*
* GROUP : DirUtlTestGroup 
*
* NAME : testDiff_filesAreNOTIdentical_returnsFalse
* 
*-----------------------------------------------------------------------------*/
TEST(DirUtlTestGroup, testDiff_filesAreNOTIdentical_returnsFalse)
{
    const char* data = "asdfsadf;lkj1243;lkjsdf";

    FILE* file1 = fopen("a.txt", "w+");    
    fprintf(file1, "%s", data);
    fclose(file1);

    FILE* file2 = fopen("b.txt", "w+");
    fprintf(file2, "%s", "BAD DATA!");
    fclose(file2);


    CHECK(!diff("a.txt", "b.txt"));

    remove("a.txt"); 
    remove("b.txt");
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*
* GROUP : DirUtlTestGroup 
*
* NAME : testGetDirSize_SizeIsRight
* 
*-----------------------------------------------------------------------------*/
TEST(DirUtlTestGroup, testGetDirSize_SizeIsRight)
{
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
