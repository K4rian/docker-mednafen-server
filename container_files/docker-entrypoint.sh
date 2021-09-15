#!/bin/bash

declare -r MDFNSV_CONFFILE_DEFAULT="$HOME/server.conf.default"

if [ ! -f "$MDFNSV_CONFFILE_DEFAULT" ]; then
    printf "[ERROR]Default config file not found.\n"
    exit 1
fi

declare -r MDFNSV_CONFFILE="$HOME/server.conf"

if [ ! -f "$MDFNSV_CONFFILE" ]; then
    cp $MDFNSV_CONFFILE_DEFAULT $MDFNSV_CONFFILE

    # Read the configuration file and declare all properties as global conf variables
    while read -r line; do
        if [[ ! ${line::1} =~ ^[[:alnum:]]+$ ]]
        then
            continue
        fi

        a_line=($(echo $line | tr $"\t" "\n"))
        s_key="${a_line[0]}"
        s_value="${a_line[1]}"

        if [[ $s_value == *";"* ]]; then
            a_value=($(echo $s_value | tr ";" "\n"))
            s_value="${a_value[0]}"
        fi

        printf -v "$s_key" "%s" "$s_value"
    done < $MDFNSV_CONFFILE

    if [ -z ${password+x} ]; then
        declare -g "password"
    fi

    # Update the password variable if the corresponding docker secret has been given
    if [ -f "/run/secrets/mednafenserver" ]; then
        password=$(<"/run/secrets/mednafenserver")
    fi

    # Update the conf variables with the env variables values
    if [ ! -z ${MDFNSV_MAXCLIENTS+x} ]; then
        maxclients=$MDFNSV_MAXCLIENTS
        unset MDFNSV_MAXCLIENTS
    fi

    if [ ! -z ${MDFNSV_CONNECTTIMEOUT+x} ]; then
        connecttimeout=$MDFNSV_CONNECTTIMEOUT
        unset MDFNSV_CONNECTTIMEOUT
    fi

    if [ ! -z ${MDFNSV_PORT+x} ]; then
        port=$MDFNSV_PORT
        unset MDFNSV_PORT
    fi

    if [ ! -z ${MDFNSV_IDLETIMEOUT+x} ]; then
        idletimeout=$MDFNSV_IDLETIMEOUT
        unset MDFNSV_IDLETIMEOUT
    fi

    if [ ! -z ${MDFNSV_MAXCMDPAYLOAD+x} ]; then
        maxcmdpayload=$MDFNSV_MAXCMDPAYLOAD
        unset MDFNSV_MAXCMDPAYLOAD
    fi

    if [ ! -z ${MDFNSV_MINSENDQSIZE+x} ]; then
        minsendqsize=$MDFNSV_MINSENDQSIZE
        unset MDFNSV_MINSENDQSIZE
    fi

    if [ ! -z ${MDFNSV_MAXSENDQSIZE+x} ]; then
        maxsendqsize=$MDFNSV_MAXSENDQSIZE
        unset MDFNSV_MAXSENDQSIZE
    fi

    # Takes precedence over the docker secret
    if [ ! -z ${MDFNSV_PASSWORD+x} ]; then
        password=$MDFNSV_PASSWORD
        unset MDFNSV_PASSWORD
    fi

    # Save all conf variables to the server configuration file
    printf -v current_date '%(%Y-%m-%d|%T)T' -1
    printf "; %s\n%s %i\n%s %i\n%s %i\n%s %i\n%s %i\n%s %i\n%s %i" \
      $current_date \
      "maxclients" $maxclients \
      "connecttimeout" $connecttimeout \
      "port" $port \
      "idletimeout" $idletimeout \
      "maxcmdpayload" $maxcmdpayload \
      "minsendqsize" $minsendqsize \
      "maxsendqsize" $maxsendqsize \
    >$MDFNSV_CONFFILE

    if [[ $password ]]; then
        printf "\npassword %s" $password >>$MDFNSV_CONFFILE
        unset $password
    fi
fi

# Start the server
$HOME/mednafen-server $MDFNSV_CONFFILE