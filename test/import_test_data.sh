#!/bin/bash

if [ ! -e test_data/banks.csv ] ||
    [ ! -e test_data/oil_1995.csv ] ||
    [ ! -e test_data/oil_1996.csv ] ||
    [ ! -e test_data/oil_1997.csv ] ||
    [ ! -e test_data/oil_1998.csv ] ||
    [ ! -e test_data/oil_1999.csv ] ||
    [ ! -e test_data/oil_2000.csv ] ||
    [ ! -e test_data/whales.csv ]
then
    if [ ! -e test_data.tgz ]
    then
	echo "test_data.tgz missing.  get it."
	exit 1
    fi
    echo "--unzipping test data--"
    tar zxvf test_data.tgz
    echo ""
fi

echo "--importing data--"
find test_data -name "*.csv" -print0 | xargs -0 -n 1 ./importer.py -n 2 -i