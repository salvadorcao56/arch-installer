#!/bin/bash
set -e

loadkeys es

source modules/log.sh
source modules/menu.sh
source modules/wifi.sh
source modules/disk.sh
source modules/system.sh
source modules/user.sh
source modules/desktop.sh
source modules/packages.sh
source modules/dotfiles.sh
source modules/boot.sh
source modules/security.sh
source modules/snapshots.sh

init_log
main_menu
