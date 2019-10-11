#!/bin/bash

set -e

echo
echo "  'Git Merge Action' is using the following input:"
echo "      - stable_branch = '$INPUT_STABLE_BRANCH'"
echo "      - development_branch = '$INPUT_DEVELOPMENT_BRANCH'"
echo "      - allow_ff = $INPUT_ALLOW_FF"
echo "      - ff_only = $INPUT_FF_ONLY"
echo "      - allow_forks = $INPUT_ALLOW_FORKS"
echo "      - user_name = $INPUT_USER_NAME"
echo "      - user_email = $INPUT_USER_EMAIL"
echo

if [[ -z "${!INPUT_PUSH_TOKEN}" ]]; then
  echo "Set the ${INPUT_PUSH_TOKEN} env variable."
  exit 1
fi

FF_MODE="--no-ff"

if ! $INPUT_ALLOW_FORKS; then
  if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "Set the GITHUB_TOKEN env variable."
    exit 1
  fi
  URI=https://api.github.com
  API_HEADER="Accept: application/vnd.github.v3+json"
  AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
  pr_resp=$(curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/$GITHUB_REPOSITORY")
  if [[ "$(echo "$pr_resp" | jq -r .fork)" != "false" ]]; then
    echo "Git Merge Action is disabled for forks (use the 'allow_forks' option to enable it)."
    exit 0
  fi
fi

git remote set-url origin https://x-access-token:${!INPUT_PUSH_TOKEN}@github.com/$GITHUB_REPOSITORY.git
git config --global user.name "$INPUT_USER_NAME"
git config --global user.email "$INPUT_USER_EMAIL"

set -o xtrace

git fetch origin $INPUT_DEVELOPMENT_BRANCH
git checkout -b $INPUT_DEVELOPMENT_BRANCH origin/$INPUT_DEVELOPMENT_BRANCH

git fetch origin $INPUT_STABLE_BRANCH
git checkout -b $INPUT_STABLE_BRANCH origin/$INPUT_STABLE_BRANCH

if git merge-base --is-ancestor $INPUT_DEVELOPMENT_BRANCH $INPUT_STABLE_BRANCH; then
  echo "No merge is necessary"
  exit 0
fi;

set +o xtrace
echo
echo "  'Git Merge Action' is trying to merge the '$INPUT_DEVELOPMENT_BRANCH' branch ($(git log -1 --pretty=%H $INPUT_DEVELOPMENT_BRANCH))"
echo "  into the '$INPUT_STABLE_BRANCH' branch ($(git log -1 --pretty=%H $INPUT_STABLE_BRANCH))"
echo
set -o xtrace

# Do the merge
git merge $FF_MODE --no-edit $INPUT_DEVELOPMENT_BRANCH

# Push the branch
git push origin $INPUT_STABLE_BRANCH
