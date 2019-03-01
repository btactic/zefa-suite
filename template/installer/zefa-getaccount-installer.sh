#!/bin/bash

# Copyright (C) 2019 BTACTIC,SCCL
# 
# Bugs and feedback: https://github.com/btactic/zefa-getaccount
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.

set -e
# if you want to trace your script uncomment the following line
#set -x

ZIMBRA_EXTENSIONS_PATH="/opt/zimbra/lib/ext"

ZEFA_EXTENSION_SUBNAME="Getaccount"
ZEFA_EXTENSION_SUBNAME_LOWERCASE=$(echo "${ZEFA_EXTENSION_SUBNAME}" | tr '[:upper:]' '[:lower:]')
ZEFA_EXTENSION_NAME="ZEFA's ${ZEFA_EXTENSION_SUBNAME} extension"
ZEFA_EXTENSION_DIRNAME="Zefa${ZEFA_EXTENSION_SUBNAME}"
ZEFA_EXTENSION_JARNAME="Zefa${ZEFA_EXTENSION_SUBNAME}"
ZEFA_ADMIN_ZIMLET_VENDOR="com_btactic"
ZEFA_ADMIN_ZIMLET_FILENAME="${ZEFA_ADMIN_ZIMLET_VENDOR}_zefa${ZEFA_EXTENSION_SUBNAME_LOWERCASE}_admin"
# Optional override for zefa admin zimlet filename if above options do not match your naming conventions
#ZEFA_ADMIN_ZIMLET_FILENAME="com_btactic_getaccount_admin"

ZEFA_GITREMOTE="git://github.com"
ZEFA_GITREPO_USER="btactic"
ZEFA_GITREPO_NAME="zefa-getaccount"
ZEFA_GITREPO_BRANCH="master"
ZEFA_GITREPO_URL="${ZEFA_GITREMOTE}/${ZEFA_GITREPO_USER}/${ZEFA_GITREPO_NAME}"

# Optional override for git remote if above options do not match your naming conventions
#ZEFA_GITREPO_URL="git://github.com/btactic/zefa-getaccount"
#ZEFA_GITREPO_BRANCH="master"

echo "${ZEFA_EXTENSION_NAME} installer"

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ -z "$1"  ]
then
   one=$(whiptail --title "${ZEFA_EXTENSION_NAME}" --checklist "Choose components to install. CLI commands are always installed." 15 60 4 \
   "Admin Zimlet and extension" "" on \
    --clear 3>&1 1>&2 2>&3)
   if [ "$?" = "1" ]
   then
      echo "cancelled by user"
      exit 0
   fi   
   #Change bash script parameter, aka one cannot do something like 1=$(whiptail....) to set $1
   set -- "$one" "$2"
fi

echo "Check if git and zip are installed."
set +e
YUM_CMD=$(which yum)
APT_CMD=$(which apt-get)
GIT_CMD=$(which git)
ZIP_CMD=$(which zip)
ANT_CMD=$(which ant)
set -e 

if [[ -z $GIT_CMD ]] || [[ -z $ZIP_CMD ]] || [[ -z $ANT_CMD ]] ; then
   if [[ ! -z $YUM_CMD ]]; then
      yum install -y git zip newt ant
   else
      apt-get install -y git zip ant
   fi
fi

TMPFOLDER="$(mktemp -d /tmp/${ZEFA_EXTENSION_DIRNAME}-installer.XXXXXXXX)"
echo "Download ${ZEFA_EXTENSION_NAME} to $TMPFOLDER"
cd $TMPFOLDER
git clone --depth=1 "${ZEFA_GITREPO_URL}" -b "${ZEFA_GITREPO_BRANCH}"
cd "${ZEFA_GITREPO_NAME}"

if [[ $1 == *"Admin Zimlet and extension"* ]]
then
   echo "Deploy admin Zimlet"
   su - zimbra -c "zmzimletctl undeploy ${ZEFA_ADMIN_ZIMLET_FILENAME}"
   rm -f /tmp/"${ZEFA_ADMIN_ZIMLET_FILENAME}".zip
   cd "${ZEFA_ADMIN_ZIMLET_FILENAME}"
   zip -r /tmp/"${ZEFA_ADMIN_ZIMLET_FILENAME}".zip *
   cd ..
   su - zimbra -c "zmzimletctl deploy /tmp/${ZEFA_ADMIN_ZIMLET_FILENAME}.zip"
   echo "Build Java server extension"
   TMPBUILDFOLDER="$(mktemp -d /tmp/${ZEFA_EXTENSION_DIRNAME}-build.XXXXXXXX)"
   cp -r extension/${ZEFA_EXTENSION_DIRNAME}/ $TMPBUILDFOLDER
   chown zimbra:zimbra $TMPBUILDFOLDER
   chown -R zimbra:zimbra $TMPBUILDFOLDER/*
   su - zimbra -c "cd ${TMPBUILDFOLDER}/${ZEFA_EXTENSION_DIRNAME} ; ${ANT_CMD}"

   echo "Deploy Java server extension"
   rm -Rf "${ZIMBRA_EXTENSIONS_PATH}"/${ZEFA_EXTENSION_DIRNAME}
   mkdir -p "${ZIMBRA_EXTENSIONS_PATH}"/${ZEFA_EXTENSION_DIRNAME}
   cp -v ${TMPBUILDFOLDER}/${ZEFA_EXTENSION_DIRNAME}/dist/${ZEFA_EXTENSION_JARNAME}.jar "${ZIMBRA_EXTENSIONS_PATH}"/${ZEFA_EXTENSION_DIRNAME}/
fi

echo "Deploy CLI tools"
cp -rv bin/* /usr/local/sbin/


echo "Flushing Zimlet Cache"
su - zimbra -c "zmprov fc all"

echo "--------------------------------------------------------------------------------------------------------------
${ZEFA_EXTENSION_NAME} installed successful"

if [[ $1 == *"X-Authenticated-User header"* ]] || [[ $1 == *"Admin Zimlet and extension"* ]];
then
echo "You still need to restart some services to load the changes:"
fi

if [[ $1 == *"Admin Zimlet and extension"* ]]
then
   echo "su - zimbra -c \"zmmailboxdctl restart\""
fi

rm -Rf $TMPFOLDER
rm -Rf $TMPBUILDFOLDER
