#!/bin/ash
# Mednafen-Server Startup Script
#
# Server Files: /home/mednafen

export LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH

clear

readonly s_config_file=$HOME/server.conf

echo "░█▄█░█▀▀░█▀▄░█▀█░█▀█░█▀▀░█▀▀░█▀█░░░░░█▀▀░█▀▀░█▀▄░█░█░█▀▀░█▀▄"
echo "░█░█░█▀▀░█░█░█░█░█▀█░█▀▀░█▀▀░█░█░▄▄▄░▀▀█░█▀▀░█▀▄░▀▄▀░█▀▀░█▀▄"
echo "░▀░▀░▀▀▀░▀▀░░▀░▀░▀░▀░▀░░░▀▀▀░▀░▀░░░░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀"

# Generates the config file if it doesn't exists
if [ ! -f "$s_config_file" ]; then
  echo "Generating new configuration file: ${s_config_file}"
  printf "%s %i\n%s %i\n%s %i\n%s %i\n%s %i\n%s %i\n%s %i\n" \
    "maxclients" ${MDFNSV_MAXCLIENTS} \
    "connecttimeout" ${MDFNSV_CONNECTTIMEOUT} \
    "port" ${MDFNSV_PORT} \
    "idletimeout" ${MDFNSV_IDLETIMEOUT} \
    "maxcmdpayload" ${MDFNSV_MAXCMDPAYLOAD} \
    "minsendqsize" ${MDFNSV_MINSENDQSIZE} \
    "maxsendqsize" ${MDFNSV_MAXSENDQSIZE} \
  >$s_config_file
else
  echo "Using existing configuration file: ${s_config_file}"
fi

if [ ! "x$MDFNSV_ISPUBLIC" = "x" ] \
 && [ "$MDFNSV_ISPUBLIC" = 1 ]; then
  # Removes the line containing the password if present
  # in the config file
  if ( grep -q 'password' $s_config_file ); then
    sed -i '/password /d' $s_config_file
  fi
else
  # Sets the password if given
  # The environment variable take precedence over the docker secret
  s_password="${MDFNSV_PASSWORD}"

  if [ "x$s_password" = "x" ] \
   && [ -f "/run/secrets/mednafenserver" ]; then
    s_password=$(cat "/run/secrets/mednafenserver")
  fi

  # Replaces or appends the password in the config file
  if [ ! "x$s_password" = "x" ]; then
    if ( grep -q 'password' $s_config_file ); then
      sed -i "/password /c\password ${s_password}" $s_config_file
      echo "Password updated in the configuration file"
    else
      echo "password ${s_password}" >> $s_config_file
      echo "Password added in the configuration file"
    fi
    unset MDFNSV_PASSWORD
    unset s_password
  fi
fi

$HOME/mednafen-server $s_config_file