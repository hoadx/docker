#!/bin/sh
# vim:sw=4:ts=4:et

set -e

if test $CHANGE_OWNER -gt 0
then
        ORIGPASSWD=$(cat /etc/passwd | grep $USERNAME)
        ORIG_UID=$(echo $ORIGPASSWD | cut -f3 -d:)
        ORIG_GID=$(echo $ORIGPASSWD | cut -f4 -d:)

        if [ \("$USER_ID" != "$ORIG_UID"\) -o \("$GROUP_ID" != "$ORIG_GID"\) ]; then
                sed -i -e "s/:$ORIG_UID:$ORIG_GID:/:$USER_ID:$GROUP_ID:/" /etc/passwd
                sed -i -e "s/$USERNAME:x:$ORIG_GID:/$USERNAME:x:$GROUP_ID:/" /etc/group
                ORIG_HOME=$(echo $ORIGPASSWD | cut -f6 -d:)
                chown -R ${USER_ID}:${GROUP_ID} ${ORIG_HOME}
        fi
fi

if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    exec 3>&1
else
    exec 3>/dev/null
fi

if [ "$1" = "nginx" -o "$1" = "nginx-debug" ]; then
    if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
        echo >&3 "$0: /docker-entrypoint.d/ is not empty, will attempt to perform configuration"

        echo >&3 "$0: Looking for shell scripts in /docker-entrypoint.d/"
        find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        echo >&3 "$0: Launching $f";
                        "$f"
                    else
                        # warn on shell scripts without exec bit
                        echo >&3 "$0: Ignoring $f, not executable";
                    fi
                    ;;
                *) echo >&3 "$0: Ignoring $f";;
            esac
        done

        echo >&3 "$0: Configuration complete; ready for start up"
    else
        echo >&3 "$0: No files found in /docker-entrypoint.d/, skipping configuration"
    fi
fi

exec "$@"
