#!/bin/bash

echo

# Only potentially push to CocoaPods when it's a tagged build
if [ -z "$TRAVIS_TAG" ]; then
    echo -e "\nBuild is not tagged"
    exit 0
fi

# Make sure tag name looks like a version number
if ! [[ $TRAVIS_TAG =~ ^[0-9\.]+(\-beta[0-9]*)?$ ]]; then
    echo -e "\nBranch build not a valid version number: $TRAVIS_TAG"
    exit 0
else
    echo -e "\nTag looks like a version number: $TRAVIS_TAG"
fi

$(npm bin)/travis-after-all
exitCode=$?

if [ $exitCode -ne 0 ]; then
    echo -e "\nThis or another matrixed job has failed"
    exit 0
fi

echo -e "\nLinting podspec..."
pod spec lint --fail-fast

if [ $? -ne 0 ]; then
    echo -e "\nPodspec failed lint (tag probably doesn't match version). Run again with --verbose to troubleshoot"
    exit 0
fi

echo -e "\nPushing to CocoaPods\n"
#echo $COCOAPODS_TRUNK_TOKEN
#pod trunk push