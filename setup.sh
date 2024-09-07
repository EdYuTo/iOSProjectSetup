#!/bin/bash

SAMPLE_DIR="ProjectContent"
GITHUB_REPO_NAME="iOSProjectSetup"
GITHUB_REPO_URL="https://github.com/EdYuTo/iOSProjectSetup.git"
PROJECT_NAME_CONSTANT="__PROJECTNAMEIDENTIFIER__"
BUNDLE_PREFIX_CONSTANT="__PROJECTBUNDLEPREFIX__"
DEVELOPMENT_TEAM_CONSTANT="__PROJECTDEVELOPMENTTEAM__"
DATE_CONSTANT="__DATEIDENTIFIER__"

PROJECT_NAME_INPUT=
BUNDLE_PREFIX_INPUT=
DEVELOPMENT_TEAM_INPUT=
LOCALIZED_DATE=$(date +%x | sed 's/\//\\\//g')

read -p "What's your project's name? " PROJECT_NAME_INPUT
read -p "What's your bundle prefix? e.g com.test " BUNDLE_PREFIX_INPUT
echo "What's your development team id? You can leave this blank"
echo "or find it here https://developer.apple.com/account under 'Membership details'"
read DEVELOPMENT_TEAM_INPUT

if [ -d $PROJECT_NAME_INPUT ]; then
  echo "Error: Project already exists in this directory, try choosing a new project name"
  exit -1
fi

git clone --no-checkout $GITHUB_REPO_URL $GITHUB_REPO_NAME && cd $GITHUB_REPO_NAME
git sparse-checkout init --no-cone && git sparse-checkout set $SAMPLE_DIR
git checkout main
mv $SAMPLE_DIR ../$PROJECT_NAME_INPUT
cd ../ && rm -rf iOSProjectSetup

find $PROJECT_NAME_INPUT -name "*$PROJECT_NAME_CONSTANT*" -type d | while read directory; do
    newfile=$(echo "$directory" | sed "s/$PROJECT_NAME_CONSTANT/$PROJECT_NAME_INPUT/g")
    mv "$directory" "$newfile"
done

find $PROJECT_NAME_INPUT -name "*$PROJECT_NAME_CONSTANT*" -type f | while read file; do
    newfile=$(echo "$file" | sed "s/$PROJECT_NAME_CONSTANT/$PROJECT_NAME_INPUT/g")
    mv "$file" "$newfile"
done

find $PROJECT_NAME_INPUT -type f | while read file; do
    newfile=$(sed "s/$PROJECT_NAME_CONSTANT/$PROJECT_NAME_INPUT/g" $file)
    newfile=$(echo "$newfile" | sed "s/$BUNDLE_PREFIX_CONSTANT/$BUNDLE_PREFIX_INPUT/g")
    newfile=$(echo "$newfile" | sed "s/$DEVELOPMENT_TEAM_CONSTANT/$DEVELOPMENT_TEAM_INPUT/g")
    newfile=$(echo "$newfile" | sed "s/$DATE_CONSTANT/$LOCALIZED_DATE/g")
    echo "$newfile" > $file
done
