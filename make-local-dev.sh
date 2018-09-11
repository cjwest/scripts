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

chmod -R 777 *.*
if [ ! -d "sites/default/modules/stanford"]; then
  mkdir sites/default/modules/stanford
fi

if [ ! -d "sites/default/modules/contrib"]; then
  mkdir sites/default/modules/contrib
fi
chmod -R 777 *

# echo 'Updating .htaccess and making backup: '${htaccessFile}
mv .htaccess ${htaccessFile}
cat $htaccessFile | sed 's/^  RewriteBase*/  RewriteBase \/ \'$'\n''  # CJW RewriteBase/' > .htaccess


# echo 'Updating settings.php and making backup: '${settingsFile}
cd ${here}
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

# Update modules for php 7
cd ${here}
if [ -d "sites/default/modules/contrib/diff" ]; then
  drush dl diff --destination=sites/default/modules/contrib -y;
  drush rr
fi

# Update field_group to 7.x-1.6
cd ${here}
if [ -d "sites/default/modules/contrib/field_group" ]; then
  drush dl field_group --destination=sites/default/modules/contrib -y;
  drush rr
 fi

# Get & enable development modules
if [ -d "sites/default/modules/contrib/devel" ]; then
  drush dl devel --destination=sites/default/modules/contrib -y
fi
if [ -d "sites/default/modules/contrib/environment_indicator" ]; then
  drush dl environment_indicator --destination=sites/default/modules/contrib
fi
drush rr
drush dis webauth -y
drush en devel environment_indicator -y

drush vset stanford_memory_limit 4G
drush vset error_level 2
drush vset stanford_sites_allow_features_generate TRUE

cd ${here}
drush sql-dump > ${now}.sql
drush uli

echo "Site updated. Please check that you have the right database"
