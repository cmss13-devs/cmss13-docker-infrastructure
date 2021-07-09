#!/bin/bash
# First argument: name of instance, which is used to keep the repo + for systemd
# Then a list of git-url|refspec to be used
# The first will be fetched, then others attempted to rebase onto it
# Without any specified, just update current base branch

BASEDIR=`dirname "$0"`
INSTANCE_NAME="${1:-default}"

INSTANCE_DIR="$BASEDIR/repositories/$INSTANCE_NAME/"
BASE_REPO_URL=`echo "$2" | cut -d'|' -f 1`
BASE_REPO_BRANCH=`echo "$2" | cut -d'|' -f 2`
if [ ! -n "$BASE_REPO_BRANCH" ]; then
  BASE_REPO_BRANCH="dev"
fi
shift
shift

# Start by getting the base repository
if [ ! -d "$INSTANCE_DIR" ]; then
  if [ ! -n "$BASE_REPO_URL" ] || [ ! -n "$BASE_REPO_BRANCH" ]; then
    echo "No existing local repository found for this instance, and no URL given - cannot proceed."
    exit 1
  fi
  cd "$BASEDIR/repositories"
  git clone --branch "$BASE_REPO_BRANCH" "$BASE_REPO_URL" "$INSTANCE_NAME"  || exit 1
  cd "$INSTANCE_NAME"
else
  cd "$INSTANCE_DIR"
  if [ -n "$BASE_REPO_URL" ] && [ -n "$BASE_REPO_BRANCH" ]; then
    git pull --force "$BASE_REPO_URL" "$BASE_REPO_BRANCH:$BASE_REPO_BRANCH" || exit 1
  else
    git pull --force || exit 1
  fi
  git checkout "$BASE_REPO_BRANCH"
fi

# Tack on anything else we want by rebase
for arg in "$@"; do
  EXTRA_REPO_URL=`echo "$arg" | cut -d'|' -f 1`
  EXTRA_REPO_BRANCH=`echo "$arg" | cut -d'|' -f 2`
  git fetch "$EXTRA_REPO_URL" "$EXTRA_REPO_BRANCH" || exit 1 
  git rebase "$BASE_REPO_BRANCH" FETCH_HEAD || exit 1
  shift
done

# Build source to docker image
DOCKER_BUILDKIT=1 docker build --target cm-runner --tag "cm13-${INSTANCE_NAME}" . || exit 1

