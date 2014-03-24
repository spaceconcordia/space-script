/* !SCHEDULE_COMMAND_H */
/*
 * =====================================================================================
 *
 *       Filename:  schedule-command.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  14-03-23 06:33:23 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  YOUR NAME (), 
 *   Organization:  
 *
 * =====================================================================================
 */
#ifndef SCHEDULE_COMMAND_H
#define SCHEDULE_COMMAND_H

std::string sysexec(char* orig_cmd); 
int cancelJob(const int job_id);
int addJob(char * date_time, char * executable);

#endif 
