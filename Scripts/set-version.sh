#!/bin/bash

# Usage: set-version.sh <version-number>
#
# Updates the main plist file, then tags the build in Git, using the release notes from CHANGELOG.md

# Only continue if the repo has no changes
CHANGED_FILE_COUNT=$(git status --porcelain --untracked-files=no | wc -l)
if [ $CHANGED_FILE_COUNT -gt 0 ]; then
    echo "Please commit or discard any changes before continuing"
    exit 1
fi

# Require a single argument to be passed in
if [ "$#" -ne 1 ]; then
    echo "Please pass the desired version number as an argument"
    exit 1
fi

# Remove the "-beta#" from the end of the version number
[[ $1 =~ ^([0-9\.]+)(\-beta[0-9]*)?$ ]]
RELEASE_VERSION=${BASH_REMATCH[1]}

# Require release notes to be written
RELEASE_NOTES=$(sed "/^## $RELEASE_VERSION$/,/^##/!d;//d;/^$/d" CHANGELOG.md)
if [ -z "$RELEASE_NOTES" ]; then
    echo "Please add release notes for v$1 into CHANGELOG.md"
    exit 1
fi

echo "Updating version numbers in plist to '$1'.."
agvtool new-version -all "$1" # CFBundleVersion
agvtool new-marketing-version "$1" # CFBundleShortVersionString

echo "Committing updated plist..."
git commit -m "Updated plist to v$1" Resources

# Revert changes to other plist files
git checkout .

echo "Tagging build..."
git tag $1 -m "$RELEASE_NOTES"