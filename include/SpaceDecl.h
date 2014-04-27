/*=============================================================================
*
*   FILE        : SpaceDecl.h
*
*   AUTHOR      : Space Concordia 2014 
*
*   PURPOSE     : This header contains Global Symbols. Always include BEFORE
*                 other includes.
*
*
*============================================================================*/
#ifndef SPACE_CONCORDIA_DECL_H
#define SPACE_CONCORDIA_DECL_H

#include <limits.h>


#ifndef CS1_UTEST           /* add -DCS1_UTEST to the ENV flag in the makefile to active the test environment */

#define CS1_APPS            "/home/apps"
#define CS1_LOGS            "/home/logs"
#define CS1_TGZ             "/home/tgz"
#define CS1_PIPES           "/home/pipes"
#define CS1_WATCH_PUPPY_PID "/home/pids/watch-puppy.pid"
#define NDEBUG              /* disable assertion (assert.h) in production version */

#else
/*
* For unit testing, we prefer not using the real path, instead create directory on the fly.
* define CS1_UTEST before including SpaceDecl.h and create/remove test directories in setup()/teardown() 
*/
#define CS1_APPS            "./apps"
#define CS1_LOGS            "./logs"
#define CS1_TGZ             "./tgz"
#define CS1_PIPES           "./pipes"
#define CS1_WATCH_PUPPY_PID "./pids/watch-puppy.pid"

#endif



#define CS1_MAX_FRAME_SIZE 190
#define CS1_TGZ_MAX CS1_MAX_FRAME_SIZE

/* From limits.h */
#define CS1_NAME_MAX NAME_MAX           /* 255 chars in a file name */
#define CS1_PATH_MAX PATH_MAX           /* 4096 chars in a path name including nul */





#endif
