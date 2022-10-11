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
    "path": "/nexus-data/blobs/apt"
}'

TEMPLATE=$(cat nexus/templates/apt.json)
repos=( "Jammy" "focal" "bionic" "xenial" "trusty" "kinetic" )
for name in "${repos[@]}"; do
    echo
    echo
    echo "Create apt '$name' repositorie:"
    curl --silent -X POST "$NEXUS_API/repositories/apt/proxy" -u $NEXUS_USERNAME:$NEXUS_PASSWORD -H 'Content-Type: application/json' -d "$(echo $TEMPLATE | sed "s/\$REPOSITORY/$name/g")"

    curl --silent -X POST "$NEXUS_API/repositories/apt-$name/health-check" -u $NEXUS_USERNAME:$NEXUS_PASSWORD
done
