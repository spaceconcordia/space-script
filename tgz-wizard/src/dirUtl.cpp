#include <string.h>
#include <cstdio>
#include <dirent.h>
#include <sys/stat.h>
#include <stdlib.h>

static const int PATH_BUFFER_SIZE = 500;

/*************************************************************************************************
* PURPOSE : some helper functions to test the tgz-wizard
*
*
**************************************************************************************************/
int getDirSize(const char* path){
    int totalSize = 0;          // in bytes
    struct dirent* entry = 0;
    struct stat statbuf; 
    DIR* dir = opendir(path);
    char curPathBuffer[PATH_BUFFER_SIZE] = {0};


    while ((entry = readdir(dir))){ 
        strcpy(curPathBuffer, path);
        strcat(curPathBuffer, "/");
        strcat(curPathBuffer, entry->d_name);
        #ifdef DEBUG
            printf("%s\n", curPathBuffer);
        #endif

        if (entry->d_type == DT_DIR         // it is a DIR => recursive call!
                        && strncmp(entry->d_name, ".", 1) != 0 
                                && strncmp(entry->d_name,"..",2) !=0)
        {
            totalSize += getDirSize(curPathBuffer);
        }
        else
        {
            if (stat(curPathBuffer, &statbuf) == -1)
                continue; 
            
            if (strncmp(entry->d_name,"..",2) !=0){
                totalSize += statbuf.st_size;
            }
        }
    }

    return totalSize;
}


bool diff(const char* file_path1, const char* file_path2){
    bool result = true;
    char c1 = 0;
    char c2 = 0;
    FILE* file1 = fopen(file_path1, "r");
    FILE* file2 = fopen(file_path2, "r");

    if (!file1 || !file2){
        fprintf(stderr, "%s%s%s\n", __FILE__, ":",  " : error opening the files"); // __LINE__ ?
        exit(1);
    }
    
    while (1){
        if (c1 == EOF && c2 == EOF){
            break;
        }

        c1 = fgetc(file1);
        c2 = fgetc(file2);
            
        if (c1 != c2){
            result = false;
        }
    }


    if(!(fclose(file1) == 0 && fclose(file2) == 0)){
        fprintf(stderr, "%s%s\n", __FILE__, " Can't close the file");
    }

    return result;
}

