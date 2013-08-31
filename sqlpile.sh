#!/bin/bash

VERSION="1.0.0"

dbuse=1
dbuser="sqlpile"
dbpass=
dbname=
verbose=0

dbfuncimport="mysqlimport"

history=".sqlpile"
historylist=( )
opmode=0
opdir=`pwd`
opoutput="compose.sql"
historyfile="${opdir}/${history}"

function mysqlimport {
    local dumpfile="$1"
    `mysql -u "${dbuser}" -p${dbpass} < "${dumpfile}"`
}
    
function nop {
    return 0
}

function echo_v {
    if [ $verbose == "1" ]; then
        echo "$1"
    fi
}

function readhistoryfile {
    if [ -s "$historyfile" ]; then
        echo_v "read history $historyfile"
        local tmp=$IFS
        IFS=$'\n'

        while read file; do
            if [ -f "${opdir}/${file}" ]; then
                historylist+=( $file )
            fi
        done < "$historyfile"

        IFS=$tmp
    fi
}

function historycontains {
    local key=$1
    for value in ${historylist[@]}; do
        if [ "$value" == "$key" ]; then
            echo "true"
            return 1
        fi
    done

    echo "false"
    return 0
}

function writehistoryfile {    
    local tmp=$IFS
    IFS=$'\n'
    for file in "${historylist[@]}"; do
        echo "$file"
    done > "$historyfile"
    IFS=$tmp
}

function deploy {
    local output="${opdir}/${opoutput}"
    local outputbuffer=""

    if [ "${opmode}" == "scaffold" ]; then
        local sffiles=( "000-cleaning.sql" "100-structure.sql" "200-modify.sql" "300-constraints.sql" "400-data.sql" )
        for f in "${sffiles[@]}"; do
            if [ ! -s "${opdir}/${f}" ]; then
                echo_v "creating scaffold file ${opdir}/${f}"
                touch "${opdir}/${f}"
            fi
        done

        return 0
    fi

    local files=`find "$opdir" -maxdepth 1 -regextype posix-egrep -regex '.*[0-9]{3}\-[^\/]*\.sql$' | sort`
    
    for f in $files; do
        local filename=$(basename "$f")
        local new=0

        if [ $(historycontains "$filename") == "false" ]; then
            historylist+=( "$filename" )
            new=1
        fi

        case "$opmode" in
            append )
                if [ $new -eq 1 ]; then
                    echo_v "append ${filename}"
                    outputbuffer+=$(cat "${opdir}/${filename}")
                    outputbuffer+=$'\n'
                fi
            ;;
            all )
                echo_v "append ${filename}"
                outputbuffer+=$(cat "${opdir}/${filename}")
                outputbuffer+=$'\n'
            ;;
        esac                
    done    

    echo_v "write composer sql ${output}"
    echo "${outputbuffer}" > "${output}"
    ${dbfuncimport} "${output}"
}

function showhelp {
    echo "sqlpile [OPTION] [FOLDER]"
    echo "Helper to migrated and deploy sql"
    echo -e " -a, --all\t\tuse all sql files"
    echo -e " -n, --new\t\tuse new sql files"
    echo -e " -t, --test\t\ttest only. no use of sql driver"
    echo -e " -c, --create\t\tcreates a sql file scaffold in the folder"
    echo -e " -v, --verbose\t\tverbose"
    echo -e " -u, --user\t\tdatabase username"
    echo -e " -p, --password\t\tdatabase password"
    echo -e " -o, --output\t\tcomposer output filename"
}

OPT=$(getopt -o o:u:p:cantv -l "output:,user:,password:,create,all,new,test,verbose" -n "sqlpile.sh" -- "$@")
eval set -- "$OPT"
while true; do
    case "$1" in
        -u|--user )
            dbuser=$2
            shift 2
        ;;
        -p|--password )
            dbpass=$2
            shift 2
        ;;
        -a|--all )
            echo "set opmode all"
            opmode="all"
            shift
        ;;
        -n|--new )
            opmode="append"
            shift
        ;;
        -c|--create )
            opmode="scaffold"
            shift
        ;;
        -o|--output )
            opoutput=$2
            shift 2
        ;;
        -t|--test )
            dbfuncimport="nop"
            shift
        ;;
        -v|--verbose )
            verbose=1
            shift
        ;;
        --)
            shift
        ;;
        *)
            if [ ${#1} -gt 1 ]; then
                opdir="$1"
            fi
            shift 1
            break
        ;;
    esac 
done;

echo_v "sqlpile $VERSION"
echo_v "working folder: $opdir"
echo_v "filter mode: $opmode"

if [ "$opmode" == "0" ]; then
    echo "Either -a, -n or -c is required"
    showhelp
    exit 1
fi

opdir=`readlink -f "$opdir"`

if [ ! -d "$opdir" ]; then
    echo "$opdir is not a directory"
    exit 1
fi
historyfile="${opdir}/${history}"

readhistoryfile

deploy

writehistoryfile