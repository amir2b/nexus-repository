#!/usr/bin/env bash

## Change root path
cd "$(dirname "$0")/../" || exit

NEXUS_API=http://127.0.0.1/service/rest/v1
source .env

curl --silent -X PUT "$NEXUS_API/security/realms/active" -u $NEXUS_USERNAME:$NEXUS_PASSWORD -H 'Content-Type: application/json' -d '[
    "NexusAuthenticatingRealm", "NexusAuthorizingRealm", "DockerToken"
]'

echo
echo
echo "Create docker blob stores:"
curl --silent -X POST "$NEXUS_API/blobstores/file" -u $NEXUS_USERNAME:$NEXUS_PASSWORD -H 'Content-Type: application/json' -d '{
    "name": "docker",
    "path": "docker"
}'

echo
echo
echo "Create raw blob stores:"
curl --silent -X POST "$NEXUS_API/blobstores/file" -u $NEXUS_USERNAME:$NEXUS_PASSWORD -H 'Content-Type: application/json' -d '{
    "name": "raw",
    "path": "raw"
}'

TEMPLATE=$(cat nexus/templates/docker.json)
repos=(
    "docker HUB https://registry-1.docker.io"
    "iranserver REGISTRY https://docker.iranserver.com"
    "iranrepo REGISTRY https://docker.iranrepo.ir"
    "dockerir REGISTRY https://registry.docker.ir"
    "dockerhub REGISTRY https://dockerhub.ir"
    "dockerregistry REGISTRY https://m.docker-registry.ir"
)
for repo in "${repos[@]}"; do
    repo=( $repo )
    TEMP=$( echo $TEMPLATE | sed "s,\$DOCKER,${repo[0]}," | sed "s,\$TYPE,${repo[1]}," | sed "s,\$URL,${repo[2]},")
    echo
    echo
    echo "Create docker '${repo[0]}' repositorie:"
    curl --silent -X POST "$NEXUS_API/repositories/docker/proxy" -u $NEXUS_USERNAME:$NEXUS_PASSWORD -H 'Content-Type: application/json' -d "$TEMP"

    curl --silent -X POST "$NEXUS_API/repositories/docker-${repo[0]}/health-check" -u $NEXUS_USERNAME:$NEXUS_PASSWORD
done

echo
echo
echo "Create docker group:"
curl --silent -X POST "$NEXUS_API/repositories/docker/group" -u $NEXUS_USERNAME:$NEXUS_PASSWORD -H 'Content-Type: application/json' -d '{
    "name": "docker",
    "docker": {
        "v1Enabled": true,
        "forceBasicAuth": false,
        "httpPort": 8080
    },
    "storage": {
        "blobStoreName": "docker",
        "strictContentTypeValidation": true
    },
    "group": {
        "memberNames": [ "docker-iranserver", "docker-iranrepo", "docker-dockerir", "docker-dockerhub", "docker-dockerregistry", "docker-docker" ]
    },
    "online": true
}'

echo
echo
echo "Create docker raw:"
curl --silent -X POST "$NEXUS_API/repositories/raw/proxy" -u $NEXUS_USERNAME:$NEXUS_PASSWORD -H 'Content-Type: application/json' -d '{
    "name": "raw-docker",
    "raw": {
        "contentDisposition": "ATTACHMENT"
    },
    "proxy": {
        "remoteUrl": "https://download.docker.com",
        "contentMaxAge": 1440,
        "metadataMaxAge": 1440
    },
    "storage": {
        "blobStoreName": "raw",
        "strictContentTypeValidation": true
    },
    "cleanup": null,
    "online": true,
    "negativeCache": {
        "enabled": true,
        "timeToLive": 1440
    },
    "httpClient": {
        "blocked": false,
        "autoBlock": true
    }
}'
