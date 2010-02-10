#!/bin/bash

echo "--importing data--"
cd ../script
find ../test/real_data -name "*.csv" -print0 | xargs -0 -n 1 python ./importer.py -n 0 -i
cd ../test
