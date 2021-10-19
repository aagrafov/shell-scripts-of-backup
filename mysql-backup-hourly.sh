#!/bin/bash

# Скрипт для резервного копирования БД Mysql и синхронизации файлов через Rsync
# c отправкой уведомлений

# Конфигурация

mysql_user='root'

# Более надежно использовать --single-transaction, вместо --lock-tables=false

mysql_params='--single-transaction'
backup_dir='/home/bitrix/backup/db/hourly/'
# storage_dir='/mnt/backup/db/hourly/'
# rsync_output='/home/bitrix/backup/rsync_hourly.log'

# admin_mail='grafovaa@serconsrus.com'
databases='sitemanager'

# Проверка директории $backup_dir

if [[ ! -d $backup_dir ]]; then
    mkdir -p "$backup_dir"
fi

# Проверка доступности MySQL, иначе выход

ping=$(mysqladmin ping -u root 2>/dev/null)
if [ "$ping" != "mysqld is alive" ]; then
        echo "Error: Unable to connected to MySQL Server, exiting !"
        exit 1
fi

mydate=$(date '+%Y-%m-%d_%H%M%S')
dbname=sitemanager.${mydate}.sql.gz

cd $backup_dir

# Дамп базы данных
# $mysql_password не используется переопределение идет в файле /etc/my.cnf для [mysqldump]

mysqldump $mysql_params -u$mysql_user $databases | gzip -9 > $dbname

# cp "$backup_dir$dbname" "$storage_dir$dbname.download"
# mv "$storage_dir$dbname.download" "$storage_dir$dbname"

# rm -fr $backup_dir*.sql.gz
find $storage_dir -name "*.sql.gz" -type f -mtime +0 -exec rm {} \; > /dev/null 2>&1

# Синхронизация файлов $backup_dir/$dbname с $storage_dir и удаление файлов через rsync

#rsync -avpze --progress --stats --delete $backup_dir $storage_dir > $rsync_output

# Отправление уведомления после успешного создания файлов в каталоге $backup_dir и $storage_dir

#scriptname=`basename $0`
#dumpstat=`ls -lh $backup_dir`
#dumpstat_storage=`ls -lh $storage_dir`
#rsync=`cat $rsync_output`
#host=intranet.atc

#if [[ -n "$admin_mail" && -f "$backup_dir/$dbname" && -f "$storage_dir/$dbname" ]]; then
#	/bin/mail -s "Резервное копирование БД(1) на $host" "$admin_mail" <<EOF
#$scriptname был завершен успешно.

#Список файлов в $backup_dir:
#$dumpstat

#Список файлов в $storage_dir:
#$dumpstat_storage

#Синхронизация файлов через rsync:
#$rsync


#EOF
#elif [ -n "$admin_mail" ]; then
#	/bin/mail -s "Резервное копирование БД(0) на $host" "$admin_mail" <<EOF
#$scriptname был завершен с ошибкой!

#Невозможно создать файл в $backup_dir или $storage_dir

#Синхронизация файлов через rsync:
#$rsync

#EOF
#fi
