#!/bin/bash

SRC_FILE="source.txt"
TARGET_FILE="output.txt"

: > "$TARGET_FILE"
sleep 3
cat "$SRC_FILE" > "$TARGET_FILE"