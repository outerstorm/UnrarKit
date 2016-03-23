#!/bin/bash

# Usage: set-version.sh <version-number>
#
# Updates the main plist file, then tags the build in Git, using the release notes from CHANGELOG.md

# Did this script change since the last commit?
THIS_FILE_REGEX='.*Scripts/set-version\.sh.*'
THIS_FILE_CHANGED=$(git status --porcelain --untracked-files=no | grep $THIS_FILE_REGEX | wc -l)

# Only continue if the repo has no changes (excluding this script)
CHANGED_FILE_COUNT=$(git status --porcelain --untracked-files=no | grep -v $THIS_FILE_REGEX | wc -l)
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

if [ "$THIS_FILE_CHANGED" -gt 0 ]; then
    echo -e "\n\n\033[1;33mNot committing to Git, as this script isn't final. Commit it to continue\033[0m"
    exit 2
fi

echo "Committing updated plist..."
git commit -m "Updated plist to v$1" Resources

# Revert changes to other plist files
git checkout .

echo "Tagging build..."
git tag $1 -m "$RELEASE_NOTES"