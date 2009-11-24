#!/bin/bash

echo "--importing data--"
cd ../script
find ../test/test_data -name "*.csv" -print0 | xargs -0 -n 1 ./importer.py -n 2 -i
cd ../test
