#!/bin/bash

# based on:
# - https://gist.github.com/domenic/ec8b0fc8ab45f39403dd
# - http://www.steveklabnik.com/automatically_update_github_pages_with_travis_example/

set -o errexit -o nounset

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "Skipping deploy: pull request."
  exit 1
fi

if [ "$TRAVIS_BRANCH" != "master" -a "$TRAVIS_BRANCH" != "dev" ]; then
  echo "Skipping deploy: branch not master or dev."
  exit 1
fi

REV=$(git rev-parse --short HEAD)

mkdir ../build
mkdir ../build/staging

copy_assets () { cp -r vendor favicon.png index.html bundle.js $1 }

git checkout dev
npm run build
copy_assets ../build/staging

git checkout master
npm run build
copy_assets ../build

cd ../build

git init
git config user.name "CI"
git config user.email "ci@rollcall.audio"

git add -A .
git commit -m "Auto-build of ${REV}"
git push -f "https://${GH_TOKEN}@${GH_REF}" HEAD:gh-pages > /dev/null 2>&1

echo "✔ Deployed successfully."
