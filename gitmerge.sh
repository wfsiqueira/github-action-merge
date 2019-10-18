#!/bin/bash

GITHUB_TOKEN="$1"
STABLE_BRANCH="$2"
MERGE_BRANCH="$3"
USER_NAME="GitHub Merge Action"
USER_EMAIL="actions@enesolucoes.com.br"
GITHUB_ORG="$4"
GITHUB_REPOSITORY="$5"


echo
echo "   'Git Merge' is using the following input:"
echo "      - GITHUB_REPOSITORY = $GITHUB_REPOSITORY"
echo "      - STABLE_BRANCH = $STABLE_BRANCH"
echo "      - MERGE_BRANCH = $MERGE_BRANCH"
echo "      - USER_NAME = $USER_NAME"
echo "      - USER_EMAIL = $USER_EMAIL"
echo "      - GITHUB_TOKEN = $GITHUB_TOKEN"
echo
echo "    Git Merge from $MERGE_BRANCH to $STABLE_BRANCH"
echo      

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Set the GITHUB_TOKEN env variable."
    exit 1
fi

URI=https://api.github.com
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
pr_resp=$(curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/$GITHUB_REPOSITORY")

git remote set-url origin https://x-access-token:$GITHUB_TOKEN@github.com/$GITHUB_ORG/$GITHUB_REPOSITORY.git
git config --global user.name "$USER_NAME"
git config --global user.email "$USER_EMAIL"

git checkout $MERGE_BRANCH
git fetch -p
#git reset —hard origin/$MERGE_BRANCH

git checkout $STABLE_BRANCH
git fetch -p
#git reset —hard origin/$STABLE_BRANCH

if git merge-base --is-ancestor $MERGE_BRANCH $STABLE_BRANCH; then
  echo "  Status $?"
  echo
  echo "  'No merge is necessary'"
  echo
  exit 0
else
  echo "  Status $?"
  echo
  echo "  Git Merge Action is trying to merge the '$MERGE_BRANCH' branch ($(git log -1 --pretty=%H $MERGE_BRANCH))"
  echo "  into the '$STABLE_BRANCH' branch ($(git log -1 --pretty=%H $STABLE_BRANCH))"
  echo

  git merge --no-ff --no-edit $MERGE_BRANCH
  git push origin $STABLE_BRANCH
fi
