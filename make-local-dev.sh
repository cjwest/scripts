#!/bin/bash
# This script updates
#  1) the .htaccess file for local use
#  2) the settings.php
#  3) Apply patches and update to latest
# Run this file from the webroot

now=`date +%s`
here=`pwd`
htaccessFile='.htaccess-'${now}
settingsFile='settings.php-'${now}

# echo 'Updating .htaccess and making backup: '${htaccessFile}
mv .htaccess ${htaccessFile}
cat $htaccessFile | sed 's/^  RewriteBase*/  RewriteBase \/ \'$'\n''  # CJW RewriteBase/' > .htaccess 


# echo 'Updating settings.php and making backup: '${settingsFile}
cd sites/default
mv settings.php ${settingsFile}
cat ${settingsFile} | sed 's/^$base_url*/# CJW $base_url/' > settings.php
cd ${here}

# echo 'Applying patches'
cd sites/all/modules/contrib/custom_meta
wget https://www.drupal.org/files/issues/2018-04-30/2909861-5.patch 
# git apply 2909861-5.patch 
patch < 2909861-5.patch

cd ${here}
cd sites/all/modules/contrib/webform/components
wget https://www.drupal.org/files/issues/webform-2811063-47.patch 
# git apply webform-2811063-47.patch 
patch < webform-2811063-47.patch

# Update field_group to 7.x-1.6
cd ${here}
drush dl field_group --destination=sites/default/modules/contrib -y;
drush rr

