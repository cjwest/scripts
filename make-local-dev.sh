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
 
mkdir sites/default/modules/stanford 
mkdir sites/default/modules/contrib
chmod -r 777 *

# echo 'Updating .htaccess and making backup: '${htaccessFile}
mv .htaccess ${htaccessFile}
cat $htaccessFile | sed 's/^  RewriteBase*/  RewriteBase \/ \'$'\n''  # CJW RewriteBase/' > .htaccess 


# echo 'Updating settings.php and making backup: '${settingsFile}
cd sites/default
mv settings.php ${settingsFile}
cat ${settingsFile} | sed 's/^$base_url*/# CJW $base_url/' > settings.php

# echo 'Applying patches'
cd ${here}
if [ -d "sites/all/modules/contrib/custom_meta" ]; then
  cd sites/all/modules/contrib/custom_meta
  wget https://www.drupal.org/files/issues/2018-04-30/2909861-5.patch 
  # git apply 2909861-5.patch 
  patch < 2909861-5.patch
fi

cd ${here}
if [ -d "sites/all/modules/contrib/webform/components" ]; then
  cd sites/all/modules/contrib/webform/components
  wget https://www.drupal.org/files/issues/webform-2811063-47.patch 
  # git apply webform-2811063-47.patch 
  patch < webform-2811063-47.patch
fi

# Update field_group to 7.x-1.6
cd ${here}
drush dl field_group --destination=sites/default/modules/contrib -y;

drush rr
drush dis webauth -y
drush vset stanford_memory_limit 4G
drush vset error_level 2
drush vset stanford_sites_allow_features_generate TRUE

# Get & enable development modules
drush dl devel --destination=sites/default/modules/contrib -y 
drush dl environment_indicator --destination=sites/default/modules/contrib 
drush rr 
drush en devel environment_indicator -y 

cd ${here}
drush sql-dump > ${now}.sql
drush uli

echo "Site updated. Please check that you have the right database"

