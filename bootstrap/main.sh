#!/bin/bash
# Test push

LOGDIR="/home/ec2-user/logs"
CONTAINERDIR="/var/lib/docker/containers"

docker login ghcr.io -u bertperrisor -p $PAT
docker pull ghcr.io/mediahomes/epg-grabber:latest

# Execute grabber and check if it succeeds
docker run -d -e EPG_CONFIG=my -e EPG_DAYS=7 ghcr.io/mediahomes/epg-grabber

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

docker run -d -e EPG_CONFIG=premium -e EPG_DAYS=7 ghcr.io/mediahomes/epg-grabber

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

# Send logs to GitHub
cd $LOGDIR
git pull
rm -fr *

cd $CONTAINERDIR
sudo find . -name \*.log -exec cp {} $LOGDIR \;

cd $LOGDIR
git add . && git commit -am "New logs"
git push

# Teardown
docker container prune -f
docker image prune -f
docker volume prune -f

sleep 60

# Shutdown
sudo shutdown
