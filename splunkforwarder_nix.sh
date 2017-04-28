#!/bin/sh

HOSTS_FILE="forwarders"
WGET_CMD="wget -O splunkforwarder-6.5.3-36937ad027d4-linux-2.6-x86_64.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=6.5.3&product=universalforwarder&filename=splunkforwarder-6.5.3-36937ad027d4-linux-2.6-x86_64.rpm&wget=true'"
RPM_FILE="splunkforwarder-6.5.3-36937ad027d4-linux-2.6-x86_64.rpm"
DEPLOY_SERVER="192.168.0.202:8089"
SSH_PUBLIC_KEY="/Users/jmirza/.ssh/jmirza.pub"
REMOTE_USER="root"
PASSWORD="Password1"

REMOTE_SCRIPT="
cd /tmp
$WGET_CMD
rpm -ivh $RPM_FILE

chown -R splunk:splunk /opt/splunkforwarder

### /opt/splunkforwarder/bin/splunk enable boot-start
/opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt
/opt/splunkforwarder/bin/splunk set deploy-poll \"$DEPLOY_SERVER\" --accept-license --answer-yes --auto-ports --no-prompt  -auth admin:changeme
/opt/splunkforwarder/bin/splunk edit user admin -password $PASSWORD -auth admin:changeme
/opt/splunkforwarder/bin/splunk restart
"

echo "In 5 seconds, will run the following script on each remote host:"
echo
echo "===================="
echo "$REMOTE_SCRIPT"
echo "===================="
echo
sleep 2
echo "Reading host logins from $HOSTS_FILE"
echo
echo "Starting."
for DST in `cat "$HOSTS_FILE"`; do
     echo "------------------- SSH KEY STUFF -------------------"
     cat $SSH_PUBLIC_KEY | ssh $REMOTE_USER@$DST 'umask 0077; mkdir -p .ssh; cat >> .ssh/authorized_keys && echo "Key copied"'
     ssh $DST -l $REMOTE_USER echo "------ If you only typed the password once then key based auth is working.--------------"
     echo "------------------- Starting Install -------------------"
  if [ -z "$DST" ]; then
  continue;
  fi
 echo "---------------------------"
 echo "Installing to $DST"
  	ssh "root@$DST" "$REMOTE_SCRIPT"
done
echo "---------------------------"
echo "Done"
