/*
 * =====================================================================================
 *
 *       Filename:  schedule-command.cpp
 *
 *    Description:  Command to interact with at scheduling
 *
 *        Version:  1.0
 *        Created:  14-03-23 06:32:08 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  YOUR NAME (), 
 *   Organization:  
 *
 * =====================================================================================
 */

#define CMD_BUFFER_LEN 190
#define AT_RUNNER "/media/Data/Development/Space/CONSAT1/space-script/at-runner/at-runner.sh"
//#define AT_RUNNER "/home/spaceconcordia/CONSAT1/space-script/at-runner/at-runner.sh"

#include <stdlib.h>
#include <string>
#include <iostream>
#include <stdio.h>

/**
 * Function to execute a command and get output
 */
std::string sysexec(char* orig_cmd) {
  char command[CMD_BUFFER_LEN] = {0};
  sprintf(command, orig_cmd, "2>&1"); // redirect stderr to stdout

  FILE * exec_pipe = popen(command, "r");
  if (!exec_pipe) return "ERROR, failed to open pipe";
  char buffer[CMD_BUFFER_LEN];
  std::string result = "";
  while( !feof(exec_pipe) ) {
    if ( fgets(buffer, CMD_BUFFER_LEN, exec_pipe) != NULL ) {
      result+=buffer;
    }
  }
  pclose(exec_pipe);
  return result;
}

int cancelJob(const int job_id) {
  char cancel_job_command[CMD_BUFFER_LEN] = {0}; 
  sprintf(cancel_job_command, "atrm %d", job_id);
  std::string output = sysexec(cancel_job_command);
  printf ( "Output: %s",output.c_str() );
  return 0;
}

int addJob(char * date_time, char * executable) {
  char add_job_command[CMD_BUFFER_LEN] = {0};
  sprintf(add_job_command, "sh %s %s %s", AT_RUNNER, date_time, executable);
  std::string output = sysexec(add_job_command);
  printf ( "Output: %s",output.c_str() );
  return 0;
}
