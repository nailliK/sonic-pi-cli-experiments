#!/bin/bash

watch_directory="./src"
buffer_file="./tmp/buffer.rb"

include_files=(
  "$watch_directory/lib/functions.rb"
  "$watch_directory/lib/generators/drum.rb"
  "$watch_directory/lib/drum_sequences/hip_hop.rb"
  "$watch_directory/main.rb"
)

function include_files {
  > "$buffer_file"

  for file in "${include_files[@]}"; do
    cat "$file" >> "$buffer_file"
  done
}

function run_sonic_pi {
  echo "Restarting Sonic Pi"

  sonic_pi stop
  include_files

  cat "$buffer_file" | sonic_pi
}

run_sonic_pi # Run on initial start
last_run_time=$(date +%s)

fswatch -0 "$watch_directory" | while read -d "" event; do
  current_time=$(date +%s)
  time_diff=$((current_time - last_run_time))

  if [ $time_diff -gt 1 ]; then
    run_sonic_pi
    last_run_time=$current_time
  fi
done
