#!/bin/bash

watch_directory="./"

# Watch for file changes and execute the script
fswatch -0 "$watch_directory" | while IFS= read -d "" event; do
    echo "File Changed. Restarting"
    cat main.rb | sonic_pi
done