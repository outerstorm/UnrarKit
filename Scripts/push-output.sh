#!/bin/bash

declare exitCode;

$(npm bin)/travis-after-all
exitCode=$?

if [ $exitCode -eq 0 ]; then
    echo "Build succeeded"
else
    echo "Build not done yet, or failed"
fi
