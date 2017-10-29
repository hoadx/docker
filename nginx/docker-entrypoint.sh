#!/bin/sh
set -e

if test $USER_ID -gt 0
then                  
        ORIGPASSWD=$(cat /etc/passwd | grep www)
        ORIG_UID=$(echo $ORIGPASSWD | cut -f3 -d:)
        ORIG_GID=$(echo $ORIGPASSWD | cut -f4 -d:)
                                                  
        USER_ID=${USER_ID:=$ORIG_UID}
        GROUP_ID=${GROUP_ID:=$ORIG_GID}
                                       
        if [ \("$USER_ID" != "$ORIG_UID"\) -o \("$GROUP_ID" != "$ORIG_GID"\) ]; then
        echo "go here"                                                      
                sed -i -e "s/:$ORIG_UID:$ORIG_GID:/:$USER_ID:$GROUP_ID:/" /etc/passwd
                sed -i -e "s/www:x:$ORIG_GID:/www:x:$GROUP_ID:/" /etc/group          
                ORIG_HOME=$(echo $ORIGPASSWD | cut -f6 -d:)                
                chown -R ${USER_ID}:${GROUP_ID} ${ORIG_HOME}
        fi                                                  
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- nginx "$@"
fi

exec "$@"
