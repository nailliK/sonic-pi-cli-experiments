#!/bin/bash

watch_directory="./src"

function run_sonic_pi {
  echo "Restarting Sonic Pi"

  sed '/# -- IGNORE_START/,/# -- IGNORE_END/d' "$watch_directory/main.rb" | sonic_pi
}

run_sonic_pi # Run on initial start
#
#last_run_time=$(date +%s)
#
#fswatch -0 "$watch_directory" | while read -d "" event; do
#  current_time=$(date +%s)
#  time_diff=$((current_time - last_run_time))
#
#  if [ $time_diff -gt 1 ]; then
#    run_sonic_pi
#    last_run_time=$current_time
#  fi
#done
