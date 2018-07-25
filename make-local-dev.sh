#!/bin/bash
# This script updates
#  1) the .htaccess file for local use
#  2) the settings.php
# Run this file from the webroot

now=`date +%s`
here=`pwd`
htaccessFile='.htaccess-'${now}
settingsFile='settings.php-'${now}

# echo 'Updating .htaccess and making backup: '${htaccessFile}
#mv .htaccess ${htaccessFile}
#cat $htaccessFile | sed 's/^  RewriteBase*/  RewriteBase \/ \'$'\n''  # CJW RewriteBase/' > .htaccess 


# echo 'Updating settings.php and making backup: '${settingsFile}
cd sites/default
mv settings.php ${settingsFile}
cat ${settingsFile} | sed 's/^$base_url*/# CJW $base_url/' > settings.php
cd ${here}
