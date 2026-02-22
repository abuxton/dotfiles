#!/usr/bin/env bash
# Productivity helper functions
# POSIX-compatible shell functions for productivity tools

# Quick todo management
todo() {
  if [ -z "$1" ]; then
    cat ~/.todo 2>/dev/null || echo "No todos yet"
  else
    echo "- $*" >> ~/.todo
    echo "Todo added"
  fi
}

# Mark todo as done (removes first matching todo)
done_todo() {
  if [ -z "$1" ]; then
    echo "Usage: done_todo <number or partial match>"
    return 1
  fi
  sed -i.bak "/$1/d" ~/.todo
  echo "Todo marked as done"
}

# Quick timer
timer() {
  local seconds="${1:-60}"
  echo "Timer started for $seconds seconds..."
  sleep "$seconds"
  echo "Timer finished!"
}

# Clear and reset terminal
reset_terminal() {
  clear && printf '\033[3J'
}
