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

echo $GPG_PUBLIC_KEY | tr "|" "\n" > /home/github/public64.key
base64 --decode /home/github/public64.key > /home/github/gpg_public.key

if [ ! -z "$ROOT_CA" ]
then
    echo $ROOT_CA | tr "|" "\n" > /home/github/Root_CA_64.crt
    base64 --decode /home/github/Root_CA_64.crt > /home/github/Company_Root_CA_X1.crt

    mkdir /usr/local/share/ca-certificates/extra \
    && cp /home/github/Company_Root_CA_X1.crt /usr/local/share/ca-certificates/extra/Company_Root_CA_X1.crt \
    && update-ca-certificates
fi

gpg --allow-secret-key-import --import /home/github/gpg_private.key
gpg --import /home/github/gpg_public.key
printenv
envsubst < /home/github/.aptly.conf > /github/home/.aptly.conf

exec "$@"