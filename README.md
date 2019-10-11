# Merge Action

Automatically merge the development branch into the stable one.

If the merge is not necessary, the action will do nothing.
If the merge fails due to conflicts, the action will fail, and the repository
maintainer should perform the merge manually.

## Installation

To enable the action simply create the `.github/workflows/github-action-merge.yml`
file with the following content:

```yml
name: 'Action Merge'

on:
  schedule:
    - cron:  '0 0 * * *'

jobs:
  nightly-merge:

    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v1

    - name: Action Merge
      uses: wfsiqueira/github-action-merge@v1.0.0
      with:
        stable_branch: 'master'
        development_branch: 'develop'
        allow_ff: false
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Even though this action was created to run as a scheduled workflow,
[`on`](https://help.github.com/en/articles/workflow-syntax-for-github-actions#on)
can be replaced by any other trigger.
For example, this will run the action whenever something is pushed on the
`master` branch:

```yml
on:
  push:
    branches:
      - master
```

## Parameters

### `stable_branch`

The name of the stable branch (default `master`).

### `development_branch`

The name of the development branch (default `develop`).

### `allow_ff`

Allow fast forward merge (default `false`). If not enabled, merges will use
`--no-ff`.

### `ff_only`

Refuse to merge and exit unless the current HEAD is already up to date or the
merge can be resolved as a fast-forward (default `false`).
Requires `allow_ff=true`.

### `allow_forks`

Allow action to run on forks (default `false`).

### `user_name`

User name for git commits.

### `user_email`

User email for git commits.

### `push_token`

Environment variable containing the token to use for push (default
`GITHUB_TOKEN`).
Useful for pushing on protected branches.
Using a secret to store this variable value is strongly recommended, since this
value will be printed in the logs.
The `GITHUB_TOKEN` is still used for API calls, therefore both token should be
available.

```yml
      with:
        push_token: 'GH_TOKEN'
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        FOO_TOKEN: ${{ secrets.GH_TOKEN }}
```
