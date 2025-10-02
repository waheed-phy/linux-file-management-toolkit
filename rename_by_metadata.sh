#!/bin/bash

# Script to rename PDF and MP3 files based on their metadata title

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

show_usage() {
    echo "Usage: $0 <directory> <file_type>"
    echo "  file_type: 'pdf' or 'mp3'"
    echo
    echo "Examples:"
    echo "  $0 /path/to/pdfs pdf"
    echo "  $0 /path/to/music mp3"
    echo "  $0 . pdf  (current directory)"
}

# Check arguments
if [ $# -lt 2 ]; then
    show_usage
    exit 1
fi

TARGET_DIR="$1"
FILE_TYPE="$2"

# Validate directory
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Directory '$TARGET_DIR' does not exist${NC}"
    exit 1
fi

# Validate file type
if [ "$FILE_TYPE" != "pdf" ] && [ "$FILE_TYPE" != "mp3" ]; then
    echo -e "${RED}Error: File type must be 'pdf' or 'mp3'${NC}"
    show_usage
    exit 1
fi

cd "$TARGET_DIR" || exit 1

echo "=========================================="
echo "Renaming $FILE_TYPE files in: $(pwd)"
echo "=========================================="
echo

# Check for required tools
if [ "$FILE_TYPE" = "pdf" ]; then
    if ! command -v pdfinfo &> /dev/null && ! command -v exiftool &> /dev/null; then
        echo -e "${RED}Error: Neither 'pdfinfo' nor 'exiftool' found.${NC}"
        echo "Install one of them:"
        echo "  sudo apt install poppler-utils  (for pdfinfo)"
        echo "  sudo apt install libimage-exiftool-perl  (for exiftool)"
        exit 1
    fi
fi

if [ "$FILE_TYPE" = "mp3" ]; then
    if ! command -v id3v2 &> /dev/null && ! command -v exiftool &> /dev/null; then
        echo -e "${RED}Error: Neither 'id3v2' nor 'exiftool' found.${NC}"
        echo "Install one of them:"
        echo "  sudo apt install id3v2  (for id3v2)"
        echo "  sudo apt install libimage-exiftool-perl  (for exiftool)"
        exit 1
    fi
fi

renamed_count=0
skipped_count=0
error_count=0

# Function to clean filename (remove invalid characters)
clean_filename() {
    local filename="$1"
    # Remove or replace invalid characters
    filename=$(echo "$filename" | sed 's/[\/\\:*?"<>|]/_/g')
    # Remove leading/trailing spaces and dots
    filename=$(echo "$filename" | sed 's/^[. ]*//; s/[. ]*$//')
    # Replace multiple spaces with single space
    filename=$(echo "$filename" | tr -s ' ')
    echo "$filename"
}

# Process PDF files
if [ "$FILE_TYPE" = "pdf" ]; then
    for file in *.pdf; do
        [ -f "$file" ] || continue
        
        echo "Processing: $file"
        
        # Try to get title using pdfinfo first
        title=""
        if command -v pdfinfo &> /dev/null; then
            title=$(pdfinfo "$file" 2>/dev/null | grep -i "^Title:" | sed 's/^Title:[ ]*//')
        fi
        
        # If pdfinfo didn't work or title is empty, try exiftool
        if [ -z "$title" ] && command -v exiftool &> /dev/null; then
            title=$(exiftool -Title -s -s -s "$file" 2>/dev/null)
        fi
        
        # Check if title was found and is not empty
        if [ -z "$title" ] || [ "$title" = "-" ]; then
            echo -e "  ${YELLOW}⚠ No title found, skipping${NC}"
            skipped_count=$((skipped_count + 1))
            echo
            continue
        fi
        
        # Clean the title
        clean_title=$(clean_filename "$title")
        new_filename="${clean_title}.pdf"
        
        # Check if new filename already exists
        if [ "$file" = "$new_filename" ]; then
            echo -e "  ${YELLOW}⚠ Already has correct name, skipping${NC}"
            skipped_count=$((skipped_count + 1))
            echo
            continue
        fi
        
        if [ -f "$new_filename" ]; then
            # Add number to avoid overwriting
            counter=1
            while [ -f "${clean_title}_${counter}.pdf" ]; do
                counter=$((counter + 1))
            done
            new_filename="${clean_title}_${counter}.pdf"
        fi
        
        # Rename the file
        mv "$file" "$new_filename"
        echo -e "  ${GREEN}✓ Renamed to: $new_filename${NC}"
        renamed_count=$((renamed_count + 1))
        echo
    done
fi

# Process MP3 files
if [ "$FILE_TYPE" = "mp3" ]; then
    for file in *.mp3; do
        [ -f "$file" ] || continue
        
        echo "Processing: $file"
        
        # Try to get title using id3v2 first
        title=""
        if command -v id3v2 &> /dev/null; then
            title=$(id3v2 -l "$file" 2>/dev/null | grep -i "^TIT2" | sed 's/^TIT2[^:]*: //')
        fi
        
        # If id3v2 didn't work or title is empty, try exiftool
        if [ -z "$title" ] && command -v exiftool &> /dev/null; then
            title=$(exiftool -Title -s -s -s "$file" 2>/dev/null)
        fi
        
        # Check if title was found and is not empty
        if [ -z "$title" ] || [ "$title" = "-" ]; then
            echo -e "  ${YELLOW}⚠ No title found, skipping${NC}"
            skipped_count=$((skipped_count + 1))
            echo
            continue
        fi
        
        # Clean the title
        clean_title=$(clean_filename "$title")
        new_filename="${clean_title}.mp3"
        
        # Check if new filename already exists
        if [ "$file" = "$new_filename" ]; then
            echo -e "  ${YELLOW}⚠ Already has correct name, skipping${NC}"
            skipped_count=$((skipped_count + 1))
            echo
            continue
        fi
        
        if [ -f "$new_filename" ]; then
            # Add number to avoid overwriting
            counter=1
            while [ -f "${clean_title}_${counter}.mp3" ]; do
                counter=$((counter + 1))
            done
            new_filename="${clean_title}_${counter}.mp3"
        fi
        
        # Rename the file
        mv "$file" "$new_filename"
        echo -e "  ${GREEN}✓ Renamed to: $new_filename${NC}"
        renamed_count=$((renamed_count + 1))
        echo
    done
fi

echo "=========================================="
echo "✅ COMPLETE!"
echo "=========================================="
echo "Files renamed: $renamed_count"
echo "Files skipped: $skipped_count"
echo "Errors: $error_count"