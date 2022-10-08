#!/usr/bin/env bash

## Change root path
cd "$(dirname "$0")/../" || exit

NEXUS_API=http://127.0.0.1/service/rest/v1
source .env

if [ -z "$NEXUS_USERNAME" ]; then
    read -p "Enter Nexus's username: " NEXUS_USERNAME
fi

if [ -z "$NEXUS_PASSWORD" ]; then
    read -sp "Enter Nexus's password: " NEXUS_PASSWORD
fi

echo
echo "Delete old repositories"
repos=( "maven-central" "maven-public" "maven-releases" "maven-snapshots" "nuget-group" "nuget-hosted" "nuget.org-proxy" )
for name in "${repos[@]}"; do
    curl -X DELETE "$NEXUS_API/repositories/$name" -u $NEXUS_USERNAME:$NEXUS_PASSWORD
done
