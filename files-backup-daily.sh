#!/bin/bash

# Скрипт для резервного копирования файлов из директории local/public и синхронизации файлов через Rsync
# c отправкой уведомлений

# Конфигурация

backup_dir_local='/home/bitrix/backup/files/local/daily/'
backup_dir_public='/home/bitrix/backup/files/public/daily/'
exclude_bitrix='/home/bitrix/www/bitrix'
exclude_upload='/home/bitrix/www/upload'
exclude_local='/home/bitrix/www/local'
exclude_git='/home/bitrix/www/.git'

admin_mail='grafovaa@serconsrus.com'

# Проверка директории $backup_dir

if [ ! -d $backup_dir ]; then
    mkdir -p "$backup_dir"
fi

#Префикс и формат даты для файла

mydate=$(date '+%Y-%m-%d_%H%M%S')
filename_local=local.${mydate}.gz
filename_public=public.${mydate}.gz

cd $backup_dir_local

# Удаление файлов local в $backup_dir_local более 5 дней назад

find $backup_dir_local -name "*.gz" -type f -mtime +5 -exec rm {} \; > /dev/null 2>&1

scriptname=`basename $0`
dumpstat=`ls -lh $backup_dir_local`
host=bitrix

sender="bitrix@serconsrus.com"
subject="files backup"

tar -czvf $filename_local /home/bitrix/www/local/

if [[ -n "$admin_mail" && -f "$backup_dir_local/$filename_local" ]]; then
	/bin/mail -s "Резервное копирование файлов /local/ на $host success" "$admin_mail" <<EOF
$scriptname был завершен успешно.

Список файлов в $backup_dir_local:
$dumpstat

EOF
elif [ -n "$admin_mail" ]; then
	/bin/mail -s "Резервное копирование файлов /local/ на $host failed" "$admin_mail" <<EOF
$scriptname был завершен с ошибкой!

Невозможно создать файл в $backup_dir_local

EOF
fi


cd $backup_dir_public

# Удаление файлов local в $backup_dir_public более 5 дней назад

find $backup_dir_public -name "*.gz" -type f -mtime +5 -exec rm {} \; > /dev/null 2>&1

scriptname=`basename $0`
dumpstat=`ls -lh $backup_dir_public`

tar -czvf $filename_public /home/bitrix/www/ --exclude $exclude_bitrix --exclude $exclude_upload --exclude $exclude_local --exclude $exclude_git

if [[ -n "$admin_mail" && -f "$backup_dir_public/$filename_public" ]]; then
	/bin/mail -s "Резервное копирование файлов /public/ на $host success" "$admin_mail" <<EOF
$scriptname был завершен успешно.

Список файлов в $backup_dir_public:
$dumpstat

EOF
elif [ -n "$admin_mail" ]; then
	/bin/mail -s "Резервное копирование файлов /public/ на $host failed" "$admin_mail" <<EOF
$scriptname был завершен с ошибкой!

Невозможно создать файл в $backup_dir_public

EOF
fi
