#!/bin/bash

# Login to ghcr.io and pull the latest epg-grabber
# echo $PAT | docker login ghcr.io -u $GHCR_USER --password-stdin
docker login ghcr.io -u bertperrisor -p $PAT
docker pull ghcr.io/mediahomes/epg-grabber:latest

# Execute grabber and check if it succeeds
# docker run -d -e EPG_CONFIG=my -e EPG_DAYS=7 ghcr.io/mediahomes/epg-grabber

docker ps -aq | while read line
do
	if ! docker top $line &>/dev/null
	then
        	echo "Container" $line "crashed unexpectedly."
        exit 1
    fi
done

# Wait until execution completes
until [[ -z $(docker ps -q) ]]
do
  sleep 3
done

# Wait before running another container
# sleep 60

docker run -d -e EPG_CONFIG=premium -e EPG_DAYS=7 ghcr.io/mediahomes/epg-grabber

# Check if containers are running succesfully
docker ps -aq | while read line
do
	if ! docker top $line &>/dev/null
	then
        	echo "Container" $line "crashed unexpectedly."
        exit 1
    fi
done

# Wait until execution completes
until [[ -z $(docker ps -q) ]]
do
  sleep 3
done

# Teardown
docker container prune -f
docker image prune -f
docker volume prune -f

sleep 60

# Shutdown
sudo shutdown
