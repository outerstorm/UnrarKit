#!/bin/bash

declare exitCode;

$(npm bin)/travis-after-all
exitCode=$?

if [ $exitCode -eq 0 ]; then
    echo -e "\n\nBuild succeeded"
else
    echo -e "\n\nBuild not done yet, or failed"
fi
