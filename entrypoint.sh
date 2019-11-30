#!/bin/sh

set -e

# создаем директорию для файлов тимспика
test -d /data/files || mkdir -p /data/files && chown teamspeak:teamspeak /data/files

# директория для логов тимспика
test -d /data/logs || mkdir -p /data/logs && chown teamspeak:teamspeak /data/logs

# создаем символические ссылки для всех файлов и директорий в дате
cd "${TS_DIRECTORY}"
for i in /data/*
do
  ln -sf "${i}" .
done

# удаляем битые ссылки
find -L "${TS_DIRECTORY}" -type l -delete

# создаем сиволические ссылки для статических файлов
STATIC_FILES="query_ip_whitelist.txt query_ip_blacklist.txt ts3server.ini ts3server.sqlitedb ts3server.sqlitedb-shm ts3server.sqlitedb-wal .ts3server_license_accepted"

for i in ${STATIC_FILES}
do
  ln -sf /data/"${i}" .
done

# чекаем принята ли лицензия
if [ -f "${TS_DIRECTORY}/.ts3server_license_accepted" ] || [ "$(echo "$*" | grep -q "license_accepted=1"; echo $?)" = "0" ] || [ "${TS3SERVER_LICENSE}" = "accept" ]
then
  echo "Vse zaebis"
else
  echo "Primi licensiyu dolboeb"
fi

export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"
exec /sbin/tini -- ./ts3server "$@"
