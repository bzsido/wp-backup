# Wordpress Backup

This is a bash script intended to make backups of Wordpress installations. Such a backup consists of two parts:

- Mysql Database Dump
- File Backup using SSH

The script can also make local file backups on a server.

Furthermore you can specify a directory for your logs and your website credentials. The credentials for each website need to be placed in a separate text file. The values should be separated by simple spaces.

The SSH password is of course not included, use private-public key-pairs!

The order of the credentials should be the following:
SITENAME FTPUSER FTPADDR DOCROOT DBADDR DBUSER DBNAME DBPWD

Notice that the password of the database is stored in plain text. Use this script with a restricted backup user whose only permissions are:

- SELECT
- LOCK TABLE
- SHOW VIEW


