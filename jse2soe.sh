#!/bin/bash
# This script will update a jse or soe site for developmemt
sitename=$1

f [! -z ${sitename+x} ]; then
  echo "usage: jse2soe.sh <sitename>";
  exit;
fi
docroot='/Users/cjwest/Documents/htdocs'
# Set location to 'all' or 'default'
location='all'
# On local:
siteroot=${docroot}/${sitename}
# On sites:
#siteroot=${docroot}/${sitename}/public_html

stanfordroot=${docroot}/${sitename}/sites/${location}/modules/stanford
contribroot=${docroot}/${sitename}/sites/${location}/modules/contrib

drush arb

# Install dependencies
cd ${contribroot}
if [ ! -d "video_embed_field" ]; then
  drush dl video_embed_field --destination=sites/${location}/modules/contrib
fi
#if [ ! -d "chosen" ]; then
#drush dl chosen --destination=sites/${location}/modules/contrib
#fi
#if [ ! -d "blockreference" ]; then
#  drush dl blockreference --destination=sites/${location}/modules/contrib
#fi
if [ ! -d "paragraphs" ]; then
  drush dl paragraphs --destination=sites/${location}/modules/contrib
fi

cd ${stanfordroot}
if [ ! -d "stanford_magazine" ]; then
  git clone https://github.com/SU-SWS/stanford_magazine.git
fi
cd stanford_magazine
git checkout 7.x-1.x

cd ${stanfordroot}
if [ ! -d "stanford_soe_helper" ]; then
  git clone https://github.com/SU-SOE/stanford_soe_helper.git
fi
cd ${stanfordroot}/stanford_soe_helper
git fetch
git checkout redesign
git pull origin redesign
cd ${stanfordroot}

if [ ! -d "${stanfordroot}/stanford_paragraph_types" ]; then
  git clone https://github.com/SU-SWS/stanford_paragraph_types.git
fi
cd ${stanfordroot}/stanford_paragraph_types
git fetch
git checkout 7.x-1.x
git pull origin 7.x-1.x
cd ${stanfordroot}

cd ${stanfordroot}/stanford_page
git fetch
git checkout 7.x-2.x-dev
git pull origin 7.x-2.x-dev
cd ${stanfordroot}

cd ${stanfordroot}/stanford_landing_page
git fetch
git checkout 7.x-1.x
git pull origin 7.x-1.x
cd ${stanfordroot}

drush rr

drush en ds_ui -y
drush en context_list_active -y
drush cc all
drush en stanford_magazine -y
drush cc all
drush en stanford_soe_helper_landing_page -y
drush cc all
drush en stanford_soe_helper_page -y
drush cc all
drush en nobots -y
drush cc all

echo Disable Solr indexing
echo - admin/config/search/search_api/index/solr_nodes_now/edit
echo - Check the Read Only box
echo - Navigate to admin/structure/ds/list/extras
echo - Select region to block
echo
echo *Stanford Page*
echo - Navigate to Stanford Page - admin/structure/types/manage/stanford-page/display/
echo - Enable Full Content
echo - Select full content
echo - Select a layout: one column
echo - Select Block regions
echo - Enter region name - Stanford Page Title
echo - Move the title int0 the new region
echo - Save
echo