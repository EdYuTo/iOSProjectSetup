#!/bin/bash

SAMPLE_DIR="ProjectContent"
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

find $SAMPLE_DIR -name "*$PROJECT_NAME_CONSTANT*" -type d | while read directory; do
    newfile=$(echo "$directory" | sed "s/$PROJECT_NAME_CONSTANT/$PROJECT_NAME_INPUT/g")
    mv "$directory" "$newfile"
done

find $SAMPLE_DIR -name "*$PROJECT_NAME_CONSTANT*" -type f | while read file; do
    newfile=$(echo "$file" | sed "s/$PROJECT_NAME_CONSTANT/$PROJECT_NAME_INPUT/g")
    mv "$file" "$newfile"
done

find $SAMPLE_DIR -type f | while read file; do
    newfile=$(sed "s/$PROJECT_NAME_CONSTANT/$PROJECT_NAME_INPUT/g" $file)
    newfile=$(echo "$newfile" | sed "s/$BUNDLE_PREFIX_CONSTANT/$BUNDLE_PREFIX_INPUT/g")
    newfile=$(echo "$newfile" | sed "s/$DEVELOPMENT_TEAM_CONSTANT/$DEVELOPMENT_TEAM_INPUT/g")
    newfile=$(echo "$newfile" | sed "s/$DATE_CONSTANT/$LOCALIZED_DATE/g")
    echo "$newfile" > $file
done
