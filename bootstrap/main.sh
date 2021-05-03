#!/bin/bash 

# Login to ghcr.io and pull the latest epg-grabber
# echo $PAT | docker login ghcr.io -u $GHCR_USER --password-stdin
docker login ghcr.io -u bertperrisor -p $PAT
docker pull ghcr.io/mediahomes/epg-grabber:latest

# Execute grabber and check if it succeeds
RUN1=$(docker run -d -e EPG_CONFIG=my -e EPG_DAYS=7 ghcr.io/mediahomes/epg-grabber)
if ! docker top $RUN1 &>/dev/null
then
    echo "Container crashed unexpectedly."
    return 1
fi

# Wait before running another container
sleep 60

RUN2$=$(docker run -d -e EPG_CONFIG=premium -e EPG_DAYS=7 ghcr.io/mediahomes/epg-grabber)
if ! docker top $RUN2 &>/dev/null
then
    echo "Container crashed unexpectedly."
    return 1
fi

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
