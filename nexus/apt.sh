#!/usr/bin/env bash

## Change root path
cd "$(dirname "$0")/../" || exit

NEXUS_API=http://127.0.0.1/service/rest/v1
source .env

echo
echo
echo "Create apt blob stores:"
curl --silent -X POST "$NEXUS_API/blobstores/file" -u $NEXUS_USERNAME:$NEXUS_PASSWORD -H 'Content-Type: application/json' -d '{
    "name": "apt",
    "path": "apt"
}'

TEMPLATE=$(cat nexus/templates/apt.json)
repos=(
    "Jammy http://archive.ubuntu.com/ubuntu/"
    "focal http://archive.ubuntu.com/ubuntu/"
    "bionic http://archive.ubuntu.com/ubuntu/"
    "xenial http://archive.ubuntu.com/ubuntu/"
    "trusty http://archive.ubuntu.com/ubuntu/"
    "kinetic http://archive.ubuntu.com/ubuntu/"
    "docker https://download.docker.com/linux/ubuntu"
)
for repo in "${repos[@]}"; do
    repo=( $repo )
    TEMP=$( echo $TEMPLATE | sed "s,\$REPOSITORY,${repo[0]},g" | sed "s,\$URL,${repo[1]}," )
    echo
    echo
    echo "Create apt '${repo[0]}' repositorie:"
    curl --silent -X POST "$NEXUS_API/repositories/apt/proxy" -u $NEXUS_USERNAME:$NEXUS_PASSWORD -H 'Content-Type: application/json' -d "$TEMP"

    curl --silent -X POST "$NEXUS_API/repositories/apt-${repo[0]}/health-check" -u $NEXUS_USERNAME:$NEXUS_PASSWORD
done
