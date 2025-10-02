#!/usr/bin/env python3

"""
Script to find duplicate images and move lower resolution copies to a 'delete' folder.
Keeps only the highest resolution version of each duplicate.
"""

import os
import hashlib
from PIL import Image
from collections import defaultdict
import shutil

def get_image_hash(filepath):
    """Generate perceptual hash of an image for duplicate detection."""
    try:
        img = Image.open(filepath)
        # Resize to small size for comparison (ignores minor differences)
        img = img.resize((8, 8), Image.Resampling.LANCZOS)
        # Convert to grayscale
        img = img.convert('L')
        # Get pixel data
        pixels = list(img.getdata())
        # Create hash from average
        avg = sum(pixels) / len(pixels)
        bits = ''.join('1' if pixel > avg else '0' for pixel in pixels)
        return bits
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return None

def get_file_hash(filepath):
    """Generate MD5 hash of file for exact duplicate detection."""
    hash_md5 = hashlib.md5()
    try:
        with open(filepath, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
    except Exception as e:
        print(f"Error hashing {filepath}: {e}")
        return None

def get_image_resolution(filepath):
    """Get image resolution (width * height)."""
    try:
        with Image.open(filepath) as img:
            return img.size[0] * img.size[1]
    except Exception as e:
        print(f"Error getting resolution for {filepath}: {e}")
        return 0

def find_and_move_duplicates(directory="."):
    """Find duplicate images and move lower resolution copies to 'delete' folder."""
    
    # Create delete folder
    delete_folder = os.path.join(directory, "delete")
    os.makedirs(delete_folder, exist_ok=True)
    
    print("Scanning for images...")
    print("=" * 50)
    
    # Get all image files
    image_files = []
    for filename in os.listdir(directory):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            filepath = os.path.join(directory, filename)
            if os.path.isfile(filepath):
                image_files.append(filepath)
    
    print(f"Found {len(image_files)} images")
    print()
    
    # First pass: Find exact duplicates by file hash
    print("Step 1: Finding exact duplicates...")
    file_hashes = defaultdict(list)
    
    for filepath in image_files:
        file_hash = get_file_hash(filepath)
        if file_hash:
            file_hashes[file_hash].append(filepath)
    
    # Second pass: Find similar images by perceptual hash
    print("Step 2: Finding similar images...")
    perceptual_hashes = defaultdict(list)
    
    for filepath in image_files:
        img_hash = get_image_hash(filepath)
        if img_hash:
            perceptual_hashes[img_hash].append(filepath)
    
    # Process duplicates
    print()
    print("=" * 50)
    print("Processing duplicates...")
    print("=" * 50)
    print()
    
    moved_count = 0
    kept_count = 0
    
    # Combine both hash methods
    all_duplicates = {}
    
    # Add exact duplicates
    for hash_val, files in file_hashes.items():
        if len(files) > 1:
            all_duplicates[hash_val] = files
    
    # Add perceptual duplicates (if not already in exact duplicates)
    for hash_val, files in perceptual_hashes.items():
        if len(files) > 1:
            # Check if these files are already in exact duplicates
            already_found = False
            for existing_files in all_duplicates.values():
                if set(files) == set(existing_files):
                    already_found = True
                    break
            if not already_found:
                all_duplicates[f"perceptual_{hash_val}"] = files
    
    # Process each group of duplicates
    for hash_val, duplicate_files in all_duplicates.items():
        if len(duplicate_files) <= 1:
            continue
        
        print(f"Found {len(duplicate_files)} duplicate(s):")
        
        # Get resolution for each file
        file_resolutions = {}
        for filepath in duplicate_files:
            resolution = get_image_resolution(filepath)
            file_resolutions[filepath] = resolution
            filename = os.path.basename(filepath)
            print(f"  - {filename}: {resolution} pixels")
        
        # Find the highest resolution file
        highest_res_file = max(file_resolutions, key=file_resolutions.get)
        highest_res = file_resolutions[highest_res_file]
        
        print(f"  ✓ Keeping: {os.path.basename(highest_res_file)} ({highest_res} pixels)")
        kept_count += 1
        
        # Move all others to delete folder
        for filepath in duplicate_files:
            if filepath != highest_res_file:
                filename = os.path.basename(filepath)
                dest_path = os.path.join(delete_folder, filename)
                
                # Handle filename conflicts in delete folder
                counter = 1
                base, ext = os.path.splitext(filename)
                while os.path.exists(dest_path):
                    dest_path = os.path.join(delete_folder, f"{base}_{counter}{ext}")
                    counter += 1
                
                shutil.move(filepath, dest_path)
                print(f"  → Moved to delete: {filename}")
                moved_count += 1
        
        print()
    
    print("=" * 50)
    print("✅ COMPLETE!")
    print("=" * 50)
    print(f"Total duplicate groups found: {len(all_duplicates)}")
    print(f"Images kept: {kept_count}")
    print(f"Images moved to 'delete' folder: {moved_count}")
    print(f"Unique images remaining: {len(image_files) - moved_count}")
    print()
    print(f"Review files in '{delete_folder}' before permanently deleting.")

if __name__ == "__main__":
    import sys
    
    # Get directory from command line argument or use current directory
    target_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    
    if not os.path.isdir(target_dir):
        print(f"Error: '{target_dir}' is not a valid directory")
        sys.exit(1)
    
    find_and_move_duplicates(target_dir)