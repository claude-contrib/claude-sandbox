#!/usr/bin/env bash

jq -n '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: "You are running inside a Docker container as user '\''claude'\'' (home: /home/claude). The working directory path is a bind mount from the host — it does not reflect your user identity."
  }
}'
