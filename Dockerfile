FROM alpine:latest

LABEL repository="http://github.com/wfsiqueira/github-action-merge"
LABEL homepage="http://github.com/wfsiqueira/github-action-merge"
LABEL "com.github.actions.name"="Action Merge"
LABEL "com.github.actions.description"="Automatically merge branch."
LABEL "com.github.actions.icon"="git-merge"
LABEL "com.github.actions.color"="orange"

RUN apk --no-cache add bash curl git jq

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
