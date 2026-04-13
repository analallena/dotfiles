#!/bin/bash

# Usage: ./rename_files.sh /path/to/folder

rename_files(){

  FOLDER="$1"
  if [ -z "$FOLDER" ] || [ ! -d "$FOLDER" ]; then
    echo "Usage: $0 /path/to/folder"
    exit 1
  fi

  BASENAME=$(basename "$FOLDER")
  LETTERS=( {a..z} )
  i=0

  for FILE in "$FOLDER"/*; do
    if [ -f "$FILE" ]; then
      EXT="${FILE##*.}"
      NEWNAME="${BASENAME}_${LETTERS[$i]}.${EXT}"
      mv "$FILE" "$FOLDER/$NEWNAME"
      ((i++))
    fi
  done

}