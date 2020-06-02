#!/bin/bash

#############################################################
# Script name: bmc_error_check.sh
# Description: Finds known error "AH00256" in tideway log.
# - error due to BMC updates installing as root instead of tideway acct.
# - if error found, sends email to BMC admin group.
# Date created: 3/12/2019
#############################################################

LOGFILE=/tmp/bmc_errorcheck_script.log
IPCMD=$(ip a | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")
TIME=$(date)
BEGINTXT="Error check starting ########################"
ENDTXT="Error check completed ########################"
ERRORCMD='cat /usr/tideway/log/tw_svc_security.log | grep -i AH00526'
NUMERRORS='cat /usr/tideway/log/tw_svc_security.log | grep -i AH00526 | wc -l'
ERRORS=$(eval ${NUMERRORS})

# Email settings
SUBJECT="BMC Discovery ssl.conf error found."
TO="root"
MESSAGE="/tmp/message.txt"

# Get location from IP/subnet info
case ${IPCMD} in
*10.12.*) LOCATION=SanAntonio
;;
*192.168.*) LOCATION=LosAngeles
;;
*) LOCATION=NOTFOUND
esac

# Check the tw_svc_security.log for error and send email
echo "${TIME} : ${BEGINTXT}" >> ${LOGFILE}
if [[ "${ERRORS}" -lt 1 ]]
then
  echo "Error not found. exiting..."
else
  eval ${ERRORCMD} >> ${LOGFILE}
  echo "Location of BMC appliance: ${LOCATION}" >> ${MESSAGE}
  echo "Error/s found in /usr/tideway/log/tw_svc_security.log" >> ${MESSAGE}
  echo "${ENDTXT}" >> ${LOGFILE}
  tail -20 /tmp/bmc_errorcheck_script.log >> ${MESSAGE}
  /usr/bin/mail -s "${SUBJECT}" "${TO}" < ${MESSAGE}
rm ${MESSAGE}
fi

