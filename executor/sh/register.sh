#!/usr/bin/env sh

role="$1"
executor="template"

# If executor program is present don't bother with the install
if ! carburator has program "$executor"; then
    carburator print terminal warn \
        "Missing required program $executor. Trying to install with package manager..."
else
    carburator print terminal success "$executor found from the $role node."
    exit 0
fi

# App installation tasks on a client node. Runs first, runs as normal user.
if [ "$role" = 'client' ]; then
    carburator print terminal info \
        "Executing register script on a client node"

    carburator prompt yes-no \
        "Should we try to install $executor on your computer?" \
            --yes-val "Yes try to install with a script" \
            --no-val "No, I'll install everything myself"; exitcode=$?

    if [ $exitcode -ne 0 ]; then
        exit 120
    fi

    if carburator has program apt; then
        sudo apt-get -y update
        sudo apt-get -y install "$executor"

    elif carburator has program pacman; then
        sudo pacman update
        sudo pacman -Sy "$executor"

    elif carburator has program yum; then
        sudo yum makecache --refresh
        sudo yum install epel-release
        sudo yum install "$executor"

    elif carburator has program dnf; then
        sudo dnf makecache --refresh
        sudo dnf -y install "$executor"

    else
        carburator print terminal error \
            "Unable to detect package manager from localhost OS"
        exit 120
    fi    
fi

# App installation tasks on remote server node. Runs as root.
if [ "$role" = 'server' ]; then
    carburator print terminal info \
        "Executing register script on a server node"

    if carburator has program apt; then
        apt-get -y update
        apt-get -y install "$executor"

    elif carburator has program pacman; then
        pacman update
        pacman -Sy "$executor"

    elif carburator has program yum; then
        yum makecache --refresh
        yum install epel-release
        yum install "$executor"

    elif carburator has program dnf; then
        dnf makecache --refresh
        dnf -y install "$executor"

    else
        carburator print terminal error \
            "Unable to detect package manager from server node OS"
        exit 120
    fi
fi
