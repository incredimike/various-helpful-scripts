#!/bin/bash
#
# bu2cloudfiles.sh (v0.1) - Incremental Encrypted backups to Rackspace Cloud Files
#   Mike Walker <mike [ at ] incredimike [ point ] com>
#
# Inspired by the following:
#   john's blog: http://blog.jtclark.ca/2010/02/backup-mysql-to-rackspace-cloud-files-with-duplicity/
#   simplebashbu: http://simplebashbu.sourceforge.net/
#
### REQUIREMENTS:
#
#  * A Rackspace account with Cloud Files (http://rackspacecloud.com)
#  * duplicity (http://duplicity.nongnu.org/)
#  * Rackspace Cloud Files Python API (https://github.com/rackspace/python-cloudfiles)
# 
### INSTALLATION
# 
#  1. Log into your Rackspace Cloud management portal
#    i. Go to [ Hosting -> Cloud Files -> Add Container ] and name your container something relevant like "ServerBackup"
#   ii. Go to [ Your Account -> API Access ] and obtain an API key and note it for later.
#
#   [TODO: Finish this...]
#
### USAGE:
#
#   Running a Backup
#   $ ./bu2cloudfiles 
# 
#   Restoring backups
#   $ ./bu2cloudfiles restore
#
### WHAT'S LEFT TO DO?
#
#  * Prune, delete after backup, or otherwise deal with backup folder size
#

# Start configuring below...

# Backup Directory
  BACKUPDIR="/backup"

# Restore Directory
  RESTOREDIR="/backup/restore"

# File systems to back up
 FILESYSTEMS="/home /etc /var/mail /var/www"

# Enable Cloudfiles uploads?
  CLOUDFILES_ENABLE=1

# Rackspace Cloudfiles Username
  CLOUDFILES_USERNAME=some_user

# Cloudfiles API Key
  CLOUDFILES_APIKEY=some_key

# Container Name. Create in Dashboard -> Cloud Files ->Add Container
  CLOUDFILES_CONTAINER=some_container

# Passphrase for duplicity backups, set blank for none
  DUPLICITY_PASSPHRASE=some_passphrase

# Verbosity
  VERBOSE=1

####################################################
# Do not edit past this point :)
####################################################

export CLOUDFILES_USERNAME=$CLOUDFILES_USERNAME
export CLOUDFILES_APIKEY=$CLOUDFILES_APIKEY
export PASSPHRASE=$DUPLICITY_PASSPHRASE
TODAY=`date +"%Y-%m-%d"`

if [ $VERBOSE -eq 1 ]; then
  TAR_VERBOSE="--verbose"
  DUP_VERBOSE="--verbosity 9"
fi

## RESTORE
if [ $1 = "restore" ]; then

  TODAYSRESTOREDIR=$RESTOREDIR/$TODAY
  if [ ! -d $TODAYSRESTOREDIR ]; then
    mkdir -p $TODAYSRESTOREDIR
  fi
  duplicity ${DUP_VERBOSE} cf+http://${CLOUDFILES_CONTAINER} ${TODAYSRESTOREDIR}

else
  ## BACKUP

  TODAYSBACKUPDIR=$BACKUPDIR/$TODAY
  if [ ! -d $TODAYSBACKUPDIR ]; then
    mkdir -p $TODAYSBACKUPDIR
  fi
  for BACKUPFILES in $FILESYSTEMS
  do
    #Create the filename; replace / with .
    WITHOUTSLASHES=`echo $BACKUPFILES | tr "/" "."`
    WITHOUTLEADINGDOT=`echo $WITHOUTSLASHES | cut -b2-`
    OUTFILENAME=$WITHOUTLEADINGDOT.`date +"%m%d%Y_%s"`.tgz
    OUTFILE=$TODAYSBACKUPDIR/$OUTFILENAME
    tar --create $TAR_VERBOSE \
      --gzip \
      --file $OUTFILE \
      $BACKUPFILES
  done

  if [ $CLOUDFILES_ENABLE -eq 1 ]; then
    duplicity $DUP_VERBOSE ${TODAYSBACKUPDIR} cf+http://${CLOUDFILES_CONTAINER}
  fi

fi
