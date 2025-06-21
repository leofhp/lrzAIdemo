#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "Available resources on lrz-cpu:"

scontrol show node | awk -v red="$RED" -v yellow="$YELLOW" -v green="$GREEN" -v nc="$NC" '
/NodeName=/ {
  match($0, /NodeName=(cpu-[0-9]+)/, n)
  if (n[1] != "") {
    node = n[1]
    keep = 1
  } else {
    keep = 0
  }
}
/State=/ && keep {
  match($0, /State=([A-Z]+)/, s)
  state = s[1]
}
/CPUAlloc=/ && keep {
  match($0, /CPUAlloc=([0-9]+)/, a)
  match($0, /CPUTot=([0-9]+)/, b)
  cpu_alloc = a[1]
  cpu_tot = b[1]
  cpu_free = cpu_tot - cpu_alloc
}
/RealMemory=/ && keep {
  match($0, /RealMemory=([0-9]+)/, m)
  match($0, /AllocMem=([0-9]+)/, am)

  mem_total_mb = m[1]
  mem_alloc_mb = am[1]
  mem_free_mb = mem_total_mb - mem_alloc_mb
  mem_total_gb = int(mem_total_mb / 1024)
  mem_free_gb = int(mem_free_mb / 1024)

  if (cpu_free == cpu_tot && mem_free_gb == mem_total_gb) {
    color = green
  } else if (cpu_free == 0 || mem_free_gb == 0) {
    color = red
  } else {
    color = yellow
  }

  printf "%s%-s: %2d out of %2d cores available, %4dGB out of %4dGB memory free%s\n",
         color, node, cpu_free, cpu_tot, mem_free_gb, mem_total_gb, nc
}'