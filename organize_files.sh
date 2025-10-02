#!/bin/bash

# Script to organize files by extension into separate folders

# Get the directory to organize (defaults to current directory)
TARGET_DIR="${1:-.}"

# Change to the target directory
cd "$TARGET_DIR" || exit 1

echo "Organizing files in: $(pwd)"

# Loop through all files (not directories)
for file in *; do
    # Skip if it's a directory or the script itself
    if [ -d "$file" ] || [ "$file" = "$(basename "$0")" ]; then
        continue
    fi
    
    # Get the file extension (everything after the last dot)
    extension="${file##*.}"
    
    # If file has no extension, use "no_extension" as folder name
    if [ "$extension" = "$file" ]; then
        extension="no_extension"
    fi
    
    # Create the directory if it doesn't exist
    if [ ! -d "$extension" ]; then
        mkdir "$extension"
        echo "Created folder: $extension"
    fi
    
    # Move the file to the appropriate folder
    mv "$file" "$extension/"
    echo "Moved: $file -> $extension/"
done

echo "Organization complete!"