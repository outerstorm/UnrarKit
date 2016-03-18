#!/bin/bash

declare exitCode;

$(npm bin)/travis-after-all
exitCode=$?

echo

if [ $exitCode -ne 0 ]; then
    echo -e "\nAll builds not done yet, or failed"
    exit 0
fi

if [ -z "$TRAVIS_TAG" ]; then
    echo -e "\nBuild is not tagged"
    exit 0
fi

echo -e "\nLinting podspec..."
pod spec lint --fail-fast

if [ $? -ne 0 ]; then
    echo -e "\nPodspec failed lint (tag probably doesn't match version). Run again with --verbose to troubleshoot"
    exit 0
fi

# Make non-master builds pre-release
if [ "$TRAVIS_BRANCH" -ne "master" ] || [[ "$TRAVIS_TAG" != *"beta"* ]]; then
    echo -e "\nBranch build not tagged with 'beta'"
    exit 0
fi

echo -e "\nPushing to CocoaPods\n"
#pod trunk push