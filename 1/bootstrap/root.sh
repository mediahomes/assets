#!/bin/bash
# Download the latest bootstrap main.sh
MAIN_BOOTSTRAP="https://mediahomes.github.io/epg-config-files/bootstrap/main.sh"

# Execute bootstrap
curl MAIN_BOOTSTRAP -o $HOME/main.sh
