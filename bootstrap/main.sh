#!/bin/bash
# Test push

# exit

LOGDIR="/home/ec2-user/logs"
CONTAINERDIR="/var/lib/docker/containers"

# Wait until execution completes
wait_container () {
	until [[ -z $(docker ps -q) ]]
	do
	  sleep 3
	done
}

# Check if container ran succesfully
check_container () {
	docker ps -aq | while read line
	do
		if ! docker top $line &>/dev/null
		then
			echo "Container" $line "crashed unexpectedly."
		exit 1
	    fi
	done
}

# Send logs
send_logs () {
	cd $LOGDIR
	git pull
	rm -fr *

	cd $CONTAINERDIR
	sudo find . -name \*.log -exec cp {} $LOGDIR \;

	cd $LOGDIR
	sudo chown -R ec2-user:ec2-user .
	git add . && git commit -am "New logs"
	git push
}

docker login ghcr.io -u bertperrisor -p $PAT
docker pull ghcr.io/mediahomes/epg-grabber:latest

# Execute grabber and check if it succeeds

docker run -d -e EPG_CONFIG=premium -e EPG_DAYS=7 ghcr.io/mediahomes/epg-grabber && check_container

wait_container

docker run -d -e EPG_CONFIG=my -e EPG_DAYS=7 ghcr.io/mediahomes/epg-grabber && check_container

wait_container

send_logs

# Teardown
docker container prune -f
docker image prune -f
docker volume prune -f

sleep 60

# Shutdown
sudo shutdown
