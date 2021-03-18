#!/bin/bash
set -eux -o pipefail

PARAMS=""
while (( "$#" )); do
  case "$1" in
  -f|--gpg-private-key)
  GPG_PRIVATE_KEY=$2
  shift 2
  ;;
  --) # end argument parsing
  shift
  break
  ;;
  -*|--*=) # unsupported flags
  echo "Error: Unsupported flag $1" >&2
  exit 1
  ;;
  *) # preserve positional arguments
  PARAMS="$PARAMS $1"
  shift
  ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"
echo $GPG_PRIVATE_KEY | tr "|" "\n" > private64.key
base64 --decode private64.key > gpg_private.key

cat /home/aptly/gpg_private.key
cat /home/aptly/gpg_public.key

gpg --allow-secret-key-import --import /home/aptly/gpg_private.key
gpg --import /home/aptly/gpg_public.key
printenv

exec "$@"