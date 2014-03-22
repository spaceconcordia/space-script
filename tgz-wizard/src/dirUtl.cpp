#include <string.h>
#include <cstdio>
#include <dirent.h>
#include <sys/stat.h>

static const int PATH_BUFFER_SIZE = 500;

/*************************************************************************************************
* PURPOSE : Returns the size of a directory. 
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


