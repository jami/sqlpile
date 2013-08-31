sqlpile
=======

sqlpile is a little bash script that help you to deploy databases changes. If you have 
different server for ci, uat or dev testing you have to deploy db changes alot. 
With this changes you migrate your database to another release version. 
But how to deploy this from the source tree without reimporting the whole database or truncating the current dataset. 
In most cases there are ci server that build projects. One of the build targets could be the sqlpile script!

This program deploy and track database changes.

Features
========

 * helper for database migrating tasks
 * compose mysql import from filtered scripts
 * track imported scripts
 * normalizing script fragments (NYI)

Usage
=====

In your data / db folder you can create a file structure that sqlpile can handle.
Filenames must have the format '\d{3}-.*.sql'

    ./sqlpile.sh --create /home/jami/sqlpile/test/data-db

    tree data-db
    data-db/
    ├── 000-cleaning.sql
    ├── 100-structure.sql
    ├── 200-modify.sql
    ├── 300-constraints.sql
    └── 400-data.sql

The priority and naming is only a suggestion. There is a little example int the test/ forlder.
Now deploy this stuff!?

    ./sqlpile.sh --verbose --new --user deployment --password xxxxxx /home/jami/sqlpile/test/data-db
    sqlpile 1.0.0
    working folder: /home/jami/sqlpile/test/data-db
    filter mode: append
    append 000-cleaning.sql
    append 100-structure.sql
    append 200-modify.sql
    append 300-constraints.sql
    append 400-data.sql
    write composer sql /home/jami/sqlpile/test/data-db/compose.sql

The compose.sql contains all changes for this update deployment (import sql dump). 
Completed scripts are stored in the .sqlpile file so the scripts won't run twice.
If you want a complete reimport do the following

    ./sqlpile.sh --all --user deployment --password xxxxxx /home/jami/sqlpile/test/data-db

In this case the .sqlpile file will be ignored. Also you can just test your current changes without touching the database.

    ./sqlpile.sh --new --test /home/jami/sqlpile/test/data-db

The result will be in the compose.sql

Parameter
=========
 
 * -a, --all use all sql files
 * -n, --new use new sql files
 * -t, --test test only. no use of sql driver
 * -c, --create creates a sql file scaffold in the folder
 * -v, --verbose verbose
 * -u, --user database username
 * -p, --password database password
 * -o, --output composer output filename



