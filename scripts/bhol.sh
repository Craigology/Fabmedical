#!/bin/bash

function replace_json_field {
    tmpfile=/tmp/tmp.json
    cp $1 $tmpfile
    jq "$2 |= \"$3\"" $tmpfile > $1
    rm "$tmpfile"
}

# Check if SUFFIX envvar exists
if [[ -z "${MCW_SUFFIX}" ]]; then
    echo "Please set the MCW_SUFFIX environment variable to a unique three character string."
    exit 1
fi

if [[ -z "${MCW_GITHUB_USERNAME}" ]]; then
    echo "Please set the MCW_GITHUB_USERNAME environment variable to your Github Username"
    exit 1
fi

if [[ -z "${MCW_GITHUB_TOKEN}" ]]; then
    echo "Please set the MCW_GITHUB_TOKEN environment variable to your Github Token"
    exit 1
fi

if [[ -z "${MCW_GITHUB_URL}" ]]; then
    MCW_GITHUB_URL=https://$MCW_GITHUB_TOKEN@github.com/$MCW_GITHUB_USERNAME/Fabmedical.git
fi

git config --global user.email "$MCW_GITHUB_EMAIL"
git config --global user.name "$MCW_GITHUB_USERNAME"

cp -R ~/MCW-Cloud-native-applications/Hands-on\ lab/lab-files/developer ~/Fabmedical
cd ~/Fabmedical
git init
git remote add origin $MCW_GITHUB_URL

git config --global --unset credential.helper
git config --global credential.helper store

# Configuring github workflows
cd ~/Fabmedical
sed -i "s/\[SUFFIX\]/$MCW_SUFFIX/g" ~/Fabmedical/.github/workflows/content-init.yml
sed -i "s/\[SUFFIX\]/$MCW_SUFFIX/g" ~/Fabmedical/.github/workflows/content-api.yml
sed -i "s/\[SUFFIX\]/$MCW_SUFFIX/g" ~/Fabmedical/.github/workflows/content-web.yml

# Commit changes
git add .
git commit -m "Initial Commit"

# Get ACR credentials and add them as secrets to Github
ACR_CREDENTIALS=$(az acr credential show -n fabmedical$MCW_SUFFIX)
ACR_USERNAME=$(jq -r -n '$input.username' --argjson input "$ACR_CREDENTIALS")
ACR_PASSWORD=$(jq -r -n '$input.passwords[0].value' --argjson input "$ACR_CREDENTIALS")

GITHUB_TOKEN=$MCW_GITHUB_TOKEN
cd ~/Fabmedical
echo $GITHUB_TOKEN | gh auth login --with-token
gh secret set ACR_USERNAME -b "$ACR_USERNAME"
gh secret set ACR_PASSWORD -b "$ACR_PASSWORD" 

# Committing repository
cd ~/Fabmedical
git branch -m master main
git push -u origin main
