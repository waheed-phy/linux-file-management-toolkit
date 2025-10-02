# Linux File Management Toolkit

A comprehensive collection of bash and Python scripts for organizing, managing, and cleaning up files on Linux systems. Perfect for dealing with messy downloads folders, duplicate images, unorganized media libraries, and more.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Python](https://img.shields.io/badge/python-3.6+-blue.svg)](https://www.python.org/downloads/)

## 📋 Table of Contents

- [Features](#features)
- [Scripts Overview](#scripts-overview)
- [Installation](#installation)
- [Usage](#usage)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

- 🗂️ **Organize files by extension** - Automatically sort files into folders
- 🔍 **Find specific files** - Search through thousands of HTML files for bookmarks
- 🖼️ **Remove duplicate images** - Keep only highest resolution versions
- 📝 **Rename by metadata** - Rename PDF and MP3 files using their title metadata
- 🚀 **Fast and efficient** - Handle thousands of files quickly
- 🛡️ **Safe operations** - Move instead of delete, with preview options

## 📜 Scripts Overview

### 1. Organize Files by Extension (`organize_files.sh`)

Automatically organizes files into folders based on their file extensions.

**What it does:**
- Scans a directory for all files
- Creates folders named after each file extension (e.g., `pdf`, `jpg`, `txt`)
- Moves files into their respective extension folders
- Files without extensions go to `no_extension` folder
- Skips directories and the script itself

**Usage:**
```bash
# Organize current directory
./organize_files.sh

# Organize specific directory
./organize_files.sh /path/to/messy/folder
```

**Example:**
```
Before:
/downloads/
  ├── document.pdf
  ├── photo.jpg
  ├── song.mp3
  └── notes.txt

After:
/downloads/
  ├── pdf/
  │   └── document.pdf
  ├── jpg/
  │   └── photo.jpg
  ├── mp3/
  │   └── song.mp3
  └── txt/
      └── notes.txt
```

---

### 2. Find Bookmark Files (`find_bookmarks.sh`)

Searches through thousands of HTML files to find your browser bookmarks based on specific website keywords.

**What it does:**
- Searches HTML files for specific website keywords
- Identifies files containing 2+ matching keywords (configurable)
- Copies potential bookmark files to a separate folder
- Shows which keywords were found in each file

**Default keywords:** gmail, google, matlab, hec, daad, daraz

**Usage:**
```bash
./find_bookmarks.sh

# Or specify a directory
./find_bookmarks.sh /path/to/html/files
```

**Customize keywords:**
Edit the `KEYWORDS` array in the script:
```bash
KEYWORDS=("gmail" "google" "your-site" "another-site")
```

**Output:**
- Creates `found_bookmarks/` folder
- Copies matching files with detailed report
- Shows match count for each file

---

### 3. Find and Remove Duplicate Images (`find_duplicate_images.py`)

Intelligently finds duplicate images and keeps only the highest resolution version.

**What it does:**
- Detects **exact duplicates** (identical files)
- Detects **visual duplicates** (similar images using perceptual hashing)
- Compares image resolutions (width × height)
- Keeps the highest resolution version
- Moves duplicates to a `delete` folder for review

**Supported formats:** PNG, JPG, JPEG

**Usage:**
```bash
# Process current directory
python3 find_duplicate_images.py

# Process specific directory
python3 find_duplicate_images.py /path/to/images
```

**How it works:**
1. Scans all images in the directory
2. Generates file hashes (MD5) for exact matches
3. Generates perceptual hashes for visual similarity
4. Groups duplicates together
5. Compares resolutions and keeps the best quality
6. Moves lower quality copies to `delete/` folder

**Example output:**
```
Found 3 duplicate(s):
  - photo_small.jpg: 921600 pixels
  - photo_medium.jpg: 2073600 pixels
  - photo_large.jpg: 8294400 pixels
  ✓ Keeping: photo_large.jpg (8294400 pixels)
  → Moved to delete: photo_small.jpg
  → Moved to delete: photo_medium.jpg
```

---

### 4. Rename Files by Metadata (`rename_by_metadata.sh`)

Renames PDF and MP3 files based on their embedded metadata titles.

**What it does:**
- Reads the "Title" property from file metadata
- Renames files to match their metadata title
- Cleans filenames (removes invalid characters)
- Handles duplicate names automatically
- Skips files without titles

**Supports:**
- PDF files (using `pdfinfo` or `exiftool`)
- MP3 files (using `id3v2` or `exiftool`)

**Usage:**
```bash
# Rename PDF files
./rename_by_metadata.sh /path/to/pdfs pdf

# Rename MP3 files
./rename_by_metadata.sh /path/to/music mp3

# Use current directory
./rename_by_metadata.sh . pdf
```

**Example:**
```
Before: 
  ├── 1a2b3c4d5e.pdf (Title: "Research Paper on AI")
  ├── track01.mp3 (Title: "Bohemian Rhapsody")

After:
  ├── Research Paper on AI.pdf
  ├── Bohemian Rhapsody.mp3
```

**Features:**
- Color-coded output (green for success, yellow for warnings)
- Prevents overwriting existing files
- Shows detailed progress report
- Safe: never deletes original files

---

## 🚀 Installation

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/linux-file-management-toolkit.git
cd linux-file-management-toolkit
```

### 2. Make scripts executable
```bash
chmod +x *.sh
```

### 3. Install dependencies

**For all scripts:**
```bash
# Update package list
sudo apt update
```

**For organize_files.sh and find_bookmarks.sh:**
No additional dependencies needed (uses built-in bash tools)

**For find_duplicate_images.py:**
```bash
# Install Python3 and pip (if not already installed)
sudo apt install python3 python3-pip

# Install Pillow library
pip3 install pillow
```

**For rename_by_metadata.sh:**

Option 1 - PDF and MP3 specific tools:
```bash
# For PDF files
sudo apt install poppler-utils

# For MP3 files
sudo apt install id3v2
```

Option 2 - Universal tool (works for both):
```bash
sudo apt install libimage-exiftool-perl
```

---

## 📦 Requirements

### System Requirements
- Linux-based operating system (Ubuntu, Debian, Fedora, Arch, etc.)
- Bash shell (version 4.0+)
- Python 3.6+ (for image duplicate finder)

### Dependencies by Script

| Script | Dependencies | Install Command |
|--------|-------------|-----------------|
| `organize_files.sh` | None (built-in) | - |
| `find_bookmarks.sh` | None (built-in) | - |
| `find_duplicate_images.py` | Python3, Pillow | `pip3 install pillow` |
| `rename_by_metadata.sh` | pdfinfo, id3v2 or exiftool | `sudo apt install poppler-utils id3v2` |

---

## 💡 Usage Tips

### Best Practices

1. **Always test on a small folder first** before running on large directories
2. **Review moved/deleted files** before permanently removing them
3. **Backup important data** before running batch operations
4. **Check script output** for errors or warnings

### Common Use Cases

**Cleaning up Downloads folder:**
```bash
cd ~/Downloads
./organize_files.sh
```

**Finding lost bookmarks:**
```bash
./find_bookmarks.sh ~/Documents/old_browser_data
```

**Organizing photo collection:**
```bash
python3 find_duplicate_images.py ~/Pictures
```

**Fixing messy music library:**
```bash
./rename_by_metadata.sh ~/Music mp3
```

### Combining Scripts

You can chain scripts together for powerful workflows:

```bash
# 1. Organize files by extension
./organize_files.sh ~/Downloads

# 2. Find duplicates in images folder
python3 find_duplicate_images.py ~/Downloads/jpg

# 3. Rename MP3 files by metadata
./rename_by_metadata.sh ~/Downloads/mp3 mp3
```

---

## 🔧 Customization

### Modify Keywords in find_bookmarks.sh

Edit line 18 to add your own keywords:
```bash
KEYWORDS=("your-site" "another-site" "custom-keyword")
```

### Change Minimum Match Count

Edit line 36 to require more or fewer keyword matches:
```bash
if [ $matches -ge 2 ]; then  # Change 2 to your preferred number
```

### Adjust Perceptual Hash Size

In `find_duplicate_images.py`, line 18:
```python
img = img.resize((8, 8), Image.Resampling.LANCZOS)  # Increase for stricter matching
```

---

## 🐛 Troubleshooting

### "Permission denied" error
```bash
chmod +x script_name.sh
```

### "Command not found" for Python script
```bash
python3 script_name.py  # Use python3 instead of python
```

### PDF metadata not found
```bash
# Test if pdfinfo works
pdfinfo your_file.pdf

# If not, install it
sudo apt install poppler-utils
```

### MP3 metadata not found
```bash
# Test if id3v2 works
id3v2 -l your_file.mp3

# If not, install it
sudo apt install id3v2
```

---

## 📝 Example Workflows

### Workflow 1: Complete Download Folder Cleanup
```bash
cd ~/Downloads

# Step 1: Organize by extension
./organize_files.sh

# Step 2: Clean up images
python3 find_duplicate_images.py jpg/
python3 find_duplicate_images.py png/

# Step 3: Rename media files
./rename_by_metadata.sh pdf/ pdf
./rename_by_metadata.sh mp3/ mp3
```

### Workflow 2: Find Lost Browser Data
```bash
# Organize HTML files first
./organize_files.sh ~/Documents/old_data

# Search for bookmarks
./find_bookmarks.sh ~/Documents/old_data/html

# Check the found_bookmarks folder
ls -lh ~/Documents/old_data/html/found_bookmarks/
```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Test thoroughly
5. Commit your changes (`git commit -am 'Add new feature'`)
6. Push to the branch (`git push origin feature/improvement`)
7. Open a Pull Request

### Ideas for Contributions
- Add support for more file types
- Improve duplicate detection algorithms
- Add GUI interface
- Create Windows PowerShell versions
- Add more metadata sources
- Improve error handling

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⭐ Support

If you find these scripts helpful, please consider:
- Starring the repository ⭐
- Sharing with others who might benefit
- Reporting bugs or suggesting features
- Contributing improvements

---

## 📧 Contact

For questions, suggestions, or issues:
- Open an issue on GitHub
- Submit a pull request
- Star the repo if you find it useful!

---

## 🙏 Acknowledgments

- Built for the Linux community
- Inspired by common file management challenges
- Uses standard Linux tools and Python libraries

---

**Made with ❤️ for Linux users who love automation**
