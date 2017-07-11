#!/bin/bash
# This script will update a jse or soe site for developmemt
sitename=$1

# hosting can be either local or sites
hosting=$2

# put in options
#while getopts 's:n:' opt; do
#    case $opt in
#        s)  service="$OPTARG" ;;
#        n)  node="$OPTARG"    ;;
#        *)  exit 1            ;;
#    esac
#done


if [ -z "$sitename" ]; then
  echo "usage: jse2soe.sh <sitename> <local|sites>";
  exit
fi

if [ -z "$hosting" ]; then
  echo "usage: jse2soe.sh <sitename>  <local|sites>";
  exit
fi

if [ $hosting == 'sites' ]; then
  docroot='/var/www'
  siteroot=${docroot}/ds_${sitename}/public_html
else
  if [ $hosting == 'local' ]; then
    docroot='/Users/cjwest/Documents/htdocs'
    siteroot=${docroot}/${sitename}

    echo "Local configuration"
    cd ${siteroot}
    drush vset stanford_sites_allow_features_generate TRUE
    drush dis webauth webauth_extras -y
  else
    echo "usage: jse2soe.sh <sitename> <local|sites>";
    exit
  fi
fi


location='default'
stanfordroot=${siteroot}/sites/${location}/modules/stanford
contribroot=${siteroot}/sites/${location}/modules/contrib
libraryroot=${siteroot}/sites/${location}/libraries

echo "Backing up "${sitename}
drush arb

# Install dependencies
cd ${libraryroot}
if [ ! -d "chosen" ]; then
  mkdir chosen
  cd chosen
  wget https://github.com/harvesthq/chosen/releases/download/v1.7.0/chosen_v1.7.0.zip
  unzip chosen_v1.7.0.zip
  rm -f chosen_v1.7.0.zip
  cd ${libraryroot}
  chmod 755 chosen/*
fi

cd ${contribroot}
if [ ! -d "field_group_link" ]; then
  drush dl field_group_link --destination=sites/${location}/modules/contrib
fi

cd ${contribroot}
if [ ! -d "chosen" ]; then
  drush dl chosen --destination=sites/${location}/modules/contrib
fi

cd ${contribroot}
if [ ! -d "regions" ]; then
  drush dl regions --destination=sites/${location}/modules/contrib
fi

cd ${contribroot}
if [ ! -d "views_load_more" ]; then
  drush dl regions --destination=sites/${location}/modules/contrib
fi


cd ${stanfordroot}
if [ ! -d "${stanfordroot}/stanford_image_styles" ]; then
  git clone https://github.com/SU-SWS/stanford_image_styles.git
fi
cd ${stanfordroot}/stanford_image_styles
git fetch
git checkout Redesign
git pull origin Redesign

cd ${stanfordroot}
if [ ! -d "${stanfordroot}/stanford_image" ]; then
  git clone https://github.com/SU-SWS/stanford_image.git
fi
cd ${stanfordroot}/stanford_image
git fetch
git checkout redesign
git pull origin redesign

cd ${stanfordroot}
if [ ! -d "stanford_help" ]; then
  git clone https://github.com/SU-SWS/stanford_help.git
fi
cd ${stanfordroot}/stanford_help
git checkout 7.x-1.1
cd ${stanfordroot}

if [ ! -d "stanford_magazine" ]; then
  git clone https://github.com/SU-SWS/stanford_magazine.git
fi
cd ${stanfordroot}/stanford_magazine
git fetch --tags
git checkout tags/7.x-1.0-alpha1

cd ${stanfordroot}/stanford_jumpstart_engineering
git fetch
git checkout redesign
git pull origin redesign

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

if [ ! -d "${stanfordroot}/stanford_page" ]; then
  git clone https://github.com/SU-SWS/stanford_page.git
fi
cd ${stanfordroot}/stanford_page
git fetch
git checkout 7.x-2.x-dev
git pull origin 7.x-2.x-dev
cd ${stanfordroot}

if [ ! -d "${stanfordroot}/stanford_landing_page" ]; then
  git clone https://github.com/SU-SWS/stanford_landing_page.git
fi
cd ${stanfordroot}/stanford_landing_page
git fetch
git checkout 7.x-1.x
git pull origin 7.x-1.x
cd ${stanfordroot}

if [ ! -d "${stanfordroot}/stanford_soe_regions" ]; then
  git clone https://github.com/SU-SOE/stanford_soe_regions.git
fi
cd ${stanfordroot}/stanford_soe_regions
git fetch --tags
git checkout tags/7.x-1.0-alpha1
cd ${stanfordroot}

if [ ! -d "${stanfordroot}/stanford_field_formatters" ]; then
  git clone https://github.com/SU-SWS/stanford_field_formatters.git
fi
cd ${stanfordroot}/stanford_field_formatters
git fetch
git checkout 7.x-1.x
git pull origin 7.x-1.x
cd ${stanfordroot}

if [ ! -d "${stanfordroot}/stanford_bean_types" ]; then
  git clone https://github.com/SU-SWS/stanford_bean_types.git
fi
cd ${stanfordroot}/stanford_bean_types
git fetch
git checkout redesign-cjw
git pull origin redesign-cjw
cd ${stanfordroot}

drush updb -y
drush rr


drush en chosen views_load_more field_group_link -y
drush cc all
drush en nobots -y
drush cc all
drush en ds_ui -y
drush en context_list_active -y
drush cc all
drush en stanford_soe_regions stanford_help -y
drush cc all
drush en stanford_magazine stanford_magazine_issue_views -y
drush cc all
drush en stanford_magazine_issue -y
drush cc all
drush en stanford_soe_helper_magazine -y
drush cc all
drush en stanford_soe_helper_landing_page -y
drush cc all
drush en stanford_soe_helper_page -y
drush cc all
drush en stanford_soe_helper_event -y
drush cc all
drush en stanford_bean_types_call_to_action stanford_bean_types_call_to_action_administration -y
drush cc all
drush fr stanford_image_styles stanford_image -y --force
drush fr stanford_magazine stanford_magazine_issue -y --force
drush fr stanford_soe_helper_magazine  -y --force
drush fr stanford_soe_helper_event stanford_soe_helper_page stanford_soe_helper_landing_page -y --force
drush fr stanford_bean_types_call_to_action stanford_bean_types_call_to_action_administration -y --force
drush cc all

# drush role-add-perm 'user-role' 'permission'
drush role-add-perm 'editor' 'create stanford_magazine_article content'
drush role-add-perm 'editor' 'edit own stanford_magazine_article content'
drush role-add-perm 'editor' 'delete own stanford_magazine_article content'
drush role-add-perm 'editor' 'edit any stanford_magazine_article content'

drush role-add-perm 'site owner' 'create stanford_magazine_article content'
drush role-add-perm 'site owner' 'edit own stanford_magazine_article content'
drush role-add-perm 'site owner' 'delete own stanford_magazine_article content'
drush role-add-perm 'site owner' 'edit any stanford_magazine_article content'
drush role-add-perm 'site owner' 'delete any stanford_magazine_article content'

drush role-add-perm 'editor' 'create stanford_magazine_issue content'
drush role-add-perm 'editor' 'edit own stanford_magazine_issue content'
drush role-add-perm 'editor' 'delete own stanford_magazine_issue content'
drush role-add-perm 'editor' 'edit any stanford_magazine_issue content'

drush role-add-perm 'site owner' 'create stanford_magazine_issue content'
drush role-add-perm 'site owner' 'edit own stanford_magazine_issue content'
drush role-add-perm 'site owner' 'delete own stanford_magazine_issue content'
drush role-add-perm 'site owner' 'edit any stanford_magazine_issue content'
drush role-add-perm 'site owner' 'delete any stanford_magazine_issue content'

echo "Time to configure!"
echo "******************"
echo
echo "If this is a developmemt site, disable Solr indexing"
echo " - admin/config/search/search_api/index/solr_nodes_now/edit"
echo " - Check the Read Only box"
echo
echo "If this is a JSE site: Configure Display Suite"
echo " - Navigate to admin/structure/ds/list/extras"
echo " - Select region to block"
echo " - Select 'Page title options'"
echo
echo "*Configure Taxonomies"
echo " - admin/structure/taxonomy_manager/voc/soe_accent_color - pink orange turquoise"
echo " - admin/structure/taxonomy_manager/voc/stanford_magazine_topics"
echo " - admin/structure/taxonomy_manager/voc/stanford_mag_issue_layout - featured left featured right featured center"
echo " - admin/structure/taxonomy_manager/voc/stanford_mag_issue_series"
echo
echo "*Stanford Help"
echo " - Create help page at site-help"
echo
echo "*Stanford Page*"
echo " - Navigate to Stanford Page:"
echo " - admin/structure/types/manage/stanford-page/display/"
echo " - Enable Full Content"
echo " - Navigate to full content"
echo " - Select a layout: one column"
echo " - Configure Block regions"
echo "   - Enter region names"
echo "     - Stanford Page Featured Image"
echo "     - Stanford Page Title"
echo " - Hide Title"
echo "   - Select 'Custom page title'"
echo "   - For Page title, select 'Hide'"
echo "   - Save"
echo " - Move the title field into the new Title region"
echo " - Move the Featured image field into the new Image region "
echo " - Configure featured Image:"
echo "   - verify: Field collection items"
echo "   - view mode 'stanford_fw_banner_tall_caption'"
echo "   - Remove link text: 'edit', 'delete','add'"
echo " - Configure the Accent Color"
echo "   - Move accent color into the bottom banner region"
echo "   - Edit the accent color field and set a default color"
echo " - Save"
echo
echo " *Event*"
echo " - Navigate to Stanford Event:"
echo " - admin/structure/types/manage/stanford-event/display/"
echo " - Enable Full Content"
echo " - Navigate to  full content"
echo " - Select a layout: one column"
echo " - Select Block regions"
echo " - Enter region name - Stanford Event Title"
echo " - Move the title field into the new region"
echo " - Select 'Custom page title'"
echo " - For Page title, select 'Hide'"
echo " - Save"
echo
echo
echo "*Landing Page*"
echo " - Navigate to Stanford Landing Page"
echo " - admin/structure/types/manage/stanford-landing-page/display/"
echo " - Enable Full Content"
echo " - Navigate to  full content"
echo " - Select a layout: one column"
echo " - Select Block regions"
echo " - Enter region name - Stanford Landing Page Title"
echo " - Move the title field into the new region"
echo " - Adjust other fields as necessary"
echo " - Select 'Custom page title'"
echo " - For Page title, select 'Hide'"
echo " - Save"
echo
echo "*Stanford Magazine Article"
echo " - Configure layout"
echo "   - Navigate to Stanford Landing Page"
echo "   - admin/structure/types/manage/stanford-landing-page/display/"
echo "   - Enable Full Content"
echo "   - Navigate to  full content"
echo "   - Move Date and Byline Wrapper above publishing date and byline"
echo " - Configure the Departments"
echo "   - Select a layout: one column"
echo "   - Select Block regions"
echo "   - Enter region name - Related Departments"
echo "   - Move 'Department' below Related Departments"
echo "   - In the 'Format' dropdown, select 'Separated'"
echo " - Configure the Accent Color"
echo "   - Navigate to admin/structure/types/manage/stanford_magazine_article/fields/field_s_mag_article_accent_color"
echo "   - Edit the accent color field and set a default color"
echo "   - Move accent color above the department field"
echo
echo "*Stanford Magazine Issue"
echo " - Configure the Accent Color"
echo "   - Navigate to admin/structure/types/manage/stanford-magazine-issue/fields/field_s_mag_issue_accent_color"
echo "   - set a default color"
echo "   - Move accent color above the article fields"
echo " - Configure layout terms"
echo "   - Navigate to admin/structure/types/manage/stanford_magazine_issue/fields/field_s_mag_issue_layout"
echo "   - set a default layout"
echo
echo "*Stanford Call to Action blocks"
echo " - Configure layout"
echo "   - Navigate to Stanford Call to Action blocks"
echo "   - admin/structure/block-types/manage/stanford-call-to-action/display"
echo "   - Enable Full Content"
echo "   - Navigate to full content"
echo "   - Move fields and field groups (Link group (Image style (Image, Icon), Title style(title)))"
echo
echo '*Disable block titles*'
echo " Navigate to an instance of each of these content types and set block title to <none>"
echo " - event"
echo " - Stanford page"
echo " - landing page"
echo
echo "*Permissions*"
echo "admin/people/permissions"
echo "- Add permissions for site owner for:"
echo " - Taxonomies: "
echo "    - Magazine Issue Layout, "
echo "    - Magazine Series, "
echo "    - Magazine Topics, "
echo "    - Magazine Eyebrow, "
echo "    - Department"
echo ""
echo " - Default image FT"
echo ""
echo "*Stanford Bean Types Call to Action"
echo "Replace color taxonomy with the SoE Accent Color"
