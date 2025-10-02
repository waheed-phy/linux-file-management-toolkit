#!/bin/bash

# Script to find bookmark files containing specific websites

TARGET_DIR="${1:-.}"
cd "$TARGET_DIR" || exit 1

echo "Searching for bookmark files in: $(pwd)"
echo "========================================"
echo

# Create output folder
BOOKMARK_FOLDER="found_bookmarks"
mkdir -p "$BOOKMARK_FOLDER"

# Keywords to search for
KEYWORDS=("gmail" "google" "matlab" "hec" "daad" "daraz")

FOUND_COUNT=0

echo "Looking for files containing at least 2 of these sites:"
echo "gmail, google, matlab, hec, daad, daraz"
echo
echo "----------------------------------------"
echo

# Loop through all HTML files
for file in *.html; do
    [ -f "$file" ] || continue
    
    # Count how many keywords are found in this file
    matches=0
    found_keywords=""
    
    for keyword in "${KEYWORDS[@]}"; do
        if grep -q -i "$keyword" "$file" 2>/dev/null; then
            matches=$((matches + 1))
            found_keywords="$found_keywords $keyword"
        fi
    done
    
    # If 2 or more keywords found, copy the file
    if [ $matches -ge 2 ]; then
        echo "✓ Found: $file"
        echo "  Matches ($matches):$found_keywords"
        
        # Copy to bookmark folder
        cp "$file" "$BOOKMARK_FOLDER/"
        echo "  → Copied to $BOOKMARK_FOLDER/"
        FOUND_COUNT=$((FOUND_COUNT + 1))
        echo
    fi
done

echo "========================================"
echo "✅ SEARCH COMPLETE!"
echo "========================================"
echo
echo "Total files found: $FOUND_COUNT"
echo "Location: $BOOKMARK_FOLDER/"
echo
if [ $FOUND_COUNT -eq 0 ]; then
    echo "⚠ No files found with 2+ matching keywords."
    echo "Try checking a few files manually or adjust the keywords."
else
    echo "Review the files in '$BOOKMARK_FOLDER/' folder."
fi