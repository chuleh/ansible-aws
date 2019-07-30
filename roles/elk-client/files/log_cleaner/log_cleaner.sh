#!/bin/bash
#==============================================================================
# IDENTIFICATION DIVISION
#        ID SVN:   $Id$
#          FILE:  log_cleaner.sh
#         USAGE:  ./config 
#   DESCRIPTION:  Compress the mentioned logs and sends them to a external storage
#       OPTIONS:  ---
#  REQUIREMENTS:  dateutils (apt-get install dateutils or yum install dateutils)
#				  s3cmd (apt-get install s3cmd) and a AWS Key able to write S3 bucket
#          BUGS:  ---
#         NOTES:  ---
#          TODO:  ---
#        AUTHOR:  Ricardo Barbosa, ricardo.barbosa@nubeliu.com
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  17/08/2017 10:23 AM BRT
#      REVISION:  17/08/2017 10:23 AM BRT 
#===============================================================================

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Preparing env
DATE=`date +"%Y-%m-%d"`
if [ ! -f ${HERE}/config ]; then
	echo "No configfile was found"
  exit 0
else
  source ${HERE}/config
  export GLOBIGNORE=$EXCEPTION_FILES
  # Creating directories
	BKP_STORAGE_FULL_DIR="${BKP_STORAGE_DIR}${DATE}"
	mkdir -p ${BKP_STORAGE_FULL_DIR}/
	cd ${BKP_STORAGE_FULL_DIR} 
	mkdir ${LOG_TYPES}
#  if [ ! -w ${BKP_STORAGE_DIR} ]; then 
#    echo "ERR: Backup directory is not writeable"; 
#    exit 0; 
#  fi
fi



#### Here we go ####
#Run logrotate once
logrotate -f /etc/logrotate.conf

#### Compressing and Saving data #######

# NODE
# Read all log types
# Read directory list
for BACKUP_DIR in ${NODEJS_LOG[@]}; do
	if [ -d ${BACKUP_DIR} ]; then
		gzip ${BACKUP_DIR}/${BACKUPED_FILES}
		# Reflects directory structure
		mkdir -p ${BKP_STORAGE_FULL_DIR}/NODEJS_LOG/${BACKUP_DIR}
		# Moves all compress data too reflected directory
		mv ${BACKUP_DIR}/*.gz ${BKP_STORAGE_FULL_DIR}/NODEJS_LOG/${BACKUP_DIR}/
	fi
done


# JAVA
# Read all log types
# Read directory list
for BACKUP_DIR in ${JAVA_LOG[@]}; do
	if [ -d ${BACKUP_DIR} ]; then
		gzip ${BACKUP_DIR}/${BACKUPED_FILES}
		# Reflects directory structure
		mkdir -p ${BKP_STORAGE_FULL_DIR}/JAVA_LOG/${BACKUP_DIR}
		# Moves all compress data too reflected directory
		mv ${BACKUP_DIR}/*.gz ${BKP_STORAGE_FULL_DIR}/JAVA_LOG/${BACKUP_DIR}/
	fi
done


# KANNEL
# Read all log types
# Read directory list
for BACKUP_DIR in ${KANNEL_LOG[@]}; do
	if [ -d ${BACKUP_DIR} ]; then
		gzip ${BACKUP_DIR}/${BACKUPED_FILES}
		# Reflects directory structure
		mkdir -p ${BKP_STORAGE_FULL_DIR}/KANNEL_LOG/${BACKUP_DIR}
		# Moves all compress data too reflected directory
		mv ${BACKUP_DIR}/*.gz ${BKP_STORAGE_FULL_DIR}/KANNEL_LOG/${BACKUP_DIR}/
	fi
done


# MYSQL
# Read all log types
# Read directory list
for BACKUP_DIR in ${MYSQL_LOG[@]};do
	if [ -d ${BACKUP_DIR} ]; then
		gzip ${BACKUP_DIR}
		mkdir -p ${BKP_STORAGE_FULL_DIR}/MYSQL_LOG/${BACKUP_DIR}
		# Reflects directory structure
		mv ${BACKUP_DIR}/*.gz ${BKP_STORAGE_FULL_DIR}/MYSQL_LOG/${BACKUP_DIR}/
	elif [[ -e ${BACKUP_DIR} ]]; then
		mkdir -p ${BKP_STORAGE_FULL_DIR}/MYSQL_LOG/${BACKUP_DIR}
		gzip ${BACKUP_DIR}.*
		# Moves all compress data too reflected directory
		mv ${BACKUP_DIR}*.gz ${BKP_STORAGE_FULL_DIR}/MYSQL_LOG/${BACKUP_DIR}/
	fi
done


# WEBSERVER
# Read all log types
# Read directory list
for BACKUP_DIR in ${WEBSERVER_LOG[@]};  do
	if [ -d ${BACKUP_DIR} ]; then
		gzip ${BACKUP_DIR}/${BACKUPED_FILES}
		# Reflects directory structure
		mkdir -p ${BKP_STORAGE_FULL_DIR}/WEBSERVER_LOG/${BACKUP_DIR}
		# Moves all compress data too reflected directory
		mv ${BACKUP_DIR}/*.gz ${BKP_STORAGE_FULL_DIR}/WEBSERVER_LOG/${BACKUP_DIR}/
	fi
done


# SERVICES
# Read all log types
# Read directory list
for BACKUP_DIR in  ${SERVICES_LOG[@]}; do
	if [ -d ${BACKUP_DIR} ]; then
		gzip ${BACKUP_DIR}/${BACKUPED_FILES}
		# Reflects directory structure
		mkdir -p ${BKP_STORAGE_FULL_DIR}/SERVICES_LOG/${BACKUP_DIR}
		# Moves all compress data too reflected directory
		mv ${BACKUP_DIR}/*.gz ${BKP_STORAGE_FULL_DIR}/SERVICES_LOG/${BACKUP_DIR}/
	fi
done


# ES
# Read all log types
# Read directory list
for BACKUP_DIR in ${ES_LOG[@]}; do
	if [ -d ${BACKUP_DIR} ]; then
		gzip ${BACKUP_DIR}/${BACKUPED_FILES}
		# Reflects directory structure
		mkdir -p ${BKP_STORAGE_FULL_DIR}/ES_LOG/${BACKUP_DIR}
		# Moves all compress data too reflected directory
		mv ${BACKUP_DIR}/*.gz ${BKP_STORAGE_FULL_DIR}/ES_LOG/${BACKUP_DIR}/
	fi
done


# Sending all data to remote storage
s3cmd sync ${BKP_STORAGE_DIR}/ ${S3_LOCATION}$(hostname;)/ --skip-existing --recursive

#excluding files
#/bin/rm -fr ${BKP_STORAGE_FULL_DIR}/