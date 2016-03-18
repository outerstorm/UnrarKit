#!/bin/bash

declare exitCode;

$(npm bin)/travis-after-all
exitCode=$?

if [ $exitCode -ne 0 ]; then
    echo -e "\n\nAll builds not done yet, or failed"
    exit 0
fi

echo "Branch: '$TRAVIS_TAG'"

if [ -z "$TRAVIS_TAG" ]; then
    echo -e "\nBuild is not tagged"
    exit 0
fi

pod spec lint --fail-fast

if [ $? -ne 0 ]; then
    echo -e "\nPodspec failed lint"
    exit 0
fi

# Make non-master builds pre-release
if [ "$TRAVIS_BRANCH" -ne "master" ] && [[ $TRAVIS_TAG != *"beta"* ]]; then
    echo -e "\nBranch build not tagged with 'beta'"
    exit 0
fi

echo -e "\nPushing to CocoaPods\n"
#pod trunk push