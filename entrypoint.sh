#!/bin/bash

set -e

echo 'Installing bundles...'
cd ${INPUT_SITE_LOCATION}
gem install bundler
bundle install
bundle list | grep "middleman ("

echo 'Building site...'
bundle exec middleman build

echo 'Publishing site...'
cd ${INPUT_BUILD_LOCATION}
remote_repo="https://${INPUT_GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${INPUT_GITHUB_REPOSITORY}.git" && \
remote_branch=${INPUT_REMOTE_BRANCH}
git init
git config user.name "${INPUT_GITHUB_ACTOR}"
git config user.email "${INPUT_GITHUB_ACTOR}@users.noreply.github.com"
if [[ -n "${INPUT_CNAME_DOMAIN}" ]];
then
  echo "Creating CNAME"
  echo "${INPUT_CNAME_DOMAIN}" > CNAME
fi
echo "Creating .nojekyll file"
touch .nojekyll
echo 'Files to Commit:'
ls -l
git add .
echo 'Committing files...'
git commit -m'Middleman build' > /dev/null 2>&1
echo "Pushing... to $remote_repo master:$remote_branch"
git push --force $remote_repo master:$remote_branch > /dev/null 2>&1
echo "Removing git..."
rm -fr .git
cd -
echo 'Done'
