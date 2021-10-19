#! /usr/bin/env python

import os
import shutil
import subprocess
import time

username = 'bitrix0'
password = 'lgeng6V{AGPysSo4&0cl'
hostname = 'localhost'
database = 'sitemanager'
backup_dir = '/home/bitrix/backup/db/'
#storage_dir = '/mnt/backup/db/'
timestamp = time.strftime('%Y-%m-%d_%H%M%S')

print "Creating backup folder %s" % backup_dir
if not os.path.exists(backup_dir):
    os.makedirs(backup_dir)

os.chdir(backup_dir)
filename = "sitemanager.%s.sql" % timestamp
print "Backing up %s" % filename
try:
    p1 = subprocess.Popen(
        "mysqldump -u%s -p%s -h%s --single-transaction %s" % (username, password, hostname, database),
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    p2 = subprocess.Popen("gzip -c -9 > %s.gz" % filename, stdin=p1.stdout, shell=True)
    p1.stdout.close()  # Allow p1 to receive a SIGPIPE if p2 exits.
    output = p1.stderr.read()
    if output == '':
        print("Backing up %s success!" % filename)
    else:
        print(output)
        exit(1)
except subprocess.CalledProcessError as e:
    print("Error: process exited with status %s" % e.returncode)

shutil.copy(backup_dir + str(filename + ".gz"), storage_dir + str(filename + ".download"))
print("Copy files: " + backup_dir + str(filename + ".gz"), storage_dir + str(filename + ".download"))

#shutil.move(storage_dir + str(filename + ".download"), storage_dir + str(filename + ".gz"))
#print("Move files: " + storage_dir + str(filename + ".download"), storage_dir + str(filename + ".gz"))

shutil.rmtree(backup_dir)

p3 = subprocess.Popen("find %s -name '*.sql.gz' -type f -mtime +1 -exec rm {} \;" % storage_dir,
                      stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
p3.communicate()
if p3.returncode == 0:
    print("Delete files success!")
else:
    print(p3.returncode)
    exit(1)
