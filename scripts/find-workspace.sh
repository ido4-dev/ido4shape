#!/bin/bash
# Shared utility: find the .ido4shape workspace directory
# Outputs the path to .ido4shape/ or exits silently if not found

# In Cowork VM: look for mounted user directories
if [ -d "/sessions" ]; then
  for dir in /sessions/*/mnt/*/; do
    [ -d "$dir" ] || continue
    case "$dir" in
      */.local-plugins/*|*/.claude/*|*/.skills/*) continue ;;
    esac
    if [ -d "${dir}.ido4shape" ]; then
      echo "${dir}.ido4shape"
      exit 0
    fi
  done
fi

# Fallback: check current directory
if [ -d ".ido4shape" ]; then
  echo ".ido4shape"
  exit 0
fi

# Fallback: check parent directories (up to 3 levels)
DIR="$(pwd)"
for i in 1 2 3; do
  DIR="$(dirname "$DIR")"
  if [ -d "$DIR/.ido4shape" ]; then
    echo "$DIR/.ido4shape"
    exit 0
  fi
done

# Not found
exit 1
