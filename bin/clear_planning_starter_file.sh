#!/bin/bash
readonly script_version="1.2.0"
# clear_planning_starter_file.sh
# Created by:  luciano.ventura@gmail.com   2014_09_10



##############################################
#                                            #
# crontab to run every month, first midnight #
#                                            #
##############################################



# read global profile
. /etc/profile
# read local profile
.  ~/.bash_profile



# exit codes
readonly SUCCESS=0
readonly FAILURE=1



# utility to send email
readonly util_dir=/u01/Oracle/home_infra/utility
readonly send_email=$util_dir/send_email.sh



# infra hyperion email 
readonly eml_inf_grp="your_email@your_domain"



# logs directory
readonly starter_dir=/u01/Oracle/Middleware/user_projects/epmsystem_$(hostname -s)/diagnostics/logs/starter
# enter logs dir
cd $starter_dir



# list all start-planning files
readonly file_list=$(ls start-Planning*.log | sort)



# flag: if any file could not be treated, send failure email.
process_status=$SUCCESS



for start_file in $file_list; do                            # process all files in $file_list
     
    cat $start_file | gzip > $start_file.gz                 # gzip log while planning is still running
     
    if gzip --test $start_file.gz &>/dev/null; then         # if gzip file is OK, clean it
         
        : > $start_file                                     # clean file
    else
        process_status=$FAILURE
    fi
done



# list all start planning files
email_message=$(ls -lht start-Planning*)



# check final status and the email tittle 
if [ $process_status == $SUCCESS ]; then
    email_title="HYP SPV DEV Clear Planning starter log file SUCCESS"
else
    email_title="HYP SPV DEV Clear Planning starter log file FAILURE"
fi



$send_email "$eml_inf_grp" "$email_title" "$email_message" /dev/null /dev/null



exit $process_status


