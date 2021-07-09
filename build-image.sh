#!/bin/bash
# First argument: name of instance, which is used to keep the repo + for systemd
# Then a list of git-url|refspec to be used
# The first will be fetched, then others attempted to rebase onto it
# Without any specified, just update current base branch

BASEDIR=`dirname "$0"`
if [ ! -n "$1" ]; then
  INSTANCE_NAME="${1:-default}"
fi

INSTANCE_DIR="$BASEDIR/repositories/$INSTANCE_NAME"
BASE_REPO_URL=`cut -d'|' -f 1 "$2"`
BASE_REPO_BRANCH=`cut -d'|' -f 2 "$2"`
if [ ! -n "$BASE_REPO_BRANCH" ]; then
  BASE_REPO_BRANCH="dev"
fi
shift 3

# Start by getting the base repository
if [ ! -d "$INSTANCE_DIR" ]; then
  if [ ! -n "$BASE_REPO_URL" || ! -n "$BASE_REPO_BRANCH" ]; then
    echo "No existing local repository found for this instance, and no URL given - cannot proceed."
    exit 1
  fi
  cd "$BASEDIR/repositories"
  git clone "$BASE_REPO_URL" "$BASE_REPO_BRANCH" || exit 1
  cd "$INSTANCE_DIR"
else
  cd "$INSTANCE_DIR"
  git pull --force "$BASE_REPO_URL" "$BASE_REPO_BRANCH:$BASE_REPO_BRANCH"
  git checkout "$BASE_REPO_BRANCH"
fi

# Tack on anything else we want by rebase
for arg in "$@"; do
  EXTRA_REPO_URL=`cut -d'|' -f 1 "$1"`
  EXTRA_REPO_BRANCH=`cut -d'|' -f 2 "$1"`
  git fetch "$EXTRA_REPO_URL" "$EXTRA_REPO_BRANCH" || exit 1
  git rebase "$BASE_REPO_BRANCH" FETCH_HEAD || exit 1
done

# Build source to docker image
docker build --target "cm13-${INSTANCE_NAME}" . || exit 1
