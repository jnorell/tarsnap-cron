#!/bin/bash

# Tarsnap backup script
# Written by Tim Bishop, 2009.
# Modified by Pronoiac, 2014. 

if [ -z "${CONFIG}"  -o  ! -f "${CONFIG}" ] ; then
    # Directories to backup - set in
    CONFIG=/etc/tarsnap-cron.conf
    # CONFIG=tarsnap-cron.conf
fi

# note: this evals the config file, which can present a security issue
# unless it's locked with the right permissions - e.g. not world-writable
if [ ! -r "$CONFIG" ] ; then 
    echo "ERROR: Couldn't read config file $CONFIG"
    echo Exiting now!
    exit 1
fi

source $CONFIG

timestamp=`date +%Y-%m-%d-%H%M`

# the last part of the suffix is now specified on the command line
# cron should call this with daily, weekly, monthly, as appropriate
# typical suffix: 2014-02-22-1920-daily
if [ $# -ne 0 ]
then
  SUFFIX=$timestamp-$1
else
  SUFFIX=$timestamp
fi

# end of config


# Do backups
echo Starting backups. 

for BACKUP in "${BACKUP_ARRAY[@]}"; do
    SPLIT=(${BACKUP//=/ })
    # typical label & path: www and /var/www
    label=${SPLIT[0]}
    path=${SPLIT[1]}
    echo "==> create $PREFIX-$label-$SUFFIX"
    if [ -n "${PRESERVE_PATH}" -a "${PRESERVE_PATH}" != "0" -a "${PRESERVE_PATH}" != "false" ] ; then
        $TARSNAP $EXTRA_PARAMETERS -c -f $PREFIX-$label-$SUFFIX $path
    else
      cd $path && \
        $TARSNAP $EXTRA_PARAMETERS -c -f $PREFIX-$label-$SUFFIX .
    fi
done
