#!/bin/bash
set -eux -o pipefail
pwd
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
echo $GPG_PRIVATE_KEY | tr "|" "\n" > /home/github/private64.key
base64 --decode /home/github/private64.key > /home/github/gpg_private.key

cat /home/github/gpg_private.key
cat /home/github/gpg_public.key
whoami
echo $UID $HOME
gpg --allow-secret-key-import --import /home/github/gpg_private.key
gpg --import /home/github/gpg_public.key
printenv
cp /home/github/.aptly.conf /github/home/.aptly.conf
cat /github/home/.aptly.conf

exec "$@"