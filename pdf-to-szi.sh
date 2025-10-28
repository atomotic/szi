#!/bin/bash

set -euo pipefail

# Script to convert PDF to SZI format using mutool and vips
# Usage: ./pdf-to-szi.sh /path/to/file.pdf

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Initialize variables
WORK_DIR=""

# Function to print error messages
error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to print success messages
success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to print info messages
info() {
    echo -e "${YELLOW}$1${NC}"
}

# Function to cleanup on error or interrupt
cleanup() {
    if [ -n "$WORK_DIR" ] && [ -d "$WORK_DIR" ]; then
        info "Cleaning up temporary files..."
        rm -f "$WORK_DIR"/*.png
    fi
}

# Set up trap to cleanup on exit or interrupt
trap cleanup EXIT INT TERM

# Validate argument count
if [ $# -ne 1 ]; then
    error "Usage: $0 <path-to-pdf-file>"
fi

PDF_FILE="$1"

# Check if file exists
if [ ! -f "$PDF_FILE" ]; then
    error "File not found: $PDF_FILE"
fi

# Check if file is a PDF
if [[ "$PDF_FILE" != *.pdf && "$PDF_FILE" != *.PDF ]]; then
    error "File does not appear to be a PDF: $PDF_FILE"
fi

# Check if required tools are installed
command -v mutool &> /dev/null || error "mutool is not installed. Please install mupdf-tools."
command -v vips &> /dev/null || error "vips is not installed. Please install libvips."

# Get directory and filename
DIR="$(cd "$(dirname "$PDF_FILE")" && pwd)"
BASENAME="$(basename "$PDF_FILE" .pdf)"
BASENAME="${BASENAME%.PDF}"

# Set working directory (use same directory as PDF)
WORK_DIR="$DIR"

info "Converting PDF to PNG images..."
info "Input: $PDF_FILE"

# Change to working directory
cd "$WORK_DIR"

# Convert PDF pages to PNG images at 300 DPI
if ! mutool draw -r 300 -o "img%d.png" "$PDF_FILE"; then
    error "Failed to convert PDF to PNG images"
fi

# Check if any PNG files were created
if ! ls img*.png 1> /dev/null 2>&1; then
    error "No PNG files were created from the PDF"
fi

PNG_COUNT=$(ls img*.png 2>/dev/null | wc -l)
info "Successfully created $PNG_COUNT PNG images"

info "Joining images with vips..."

# Create temporary DZ file
TEMP_DZ="${BASENAME}.dz"
SZI_FILE="${BASENAME}.szi"

# Join PNG files into a deep zoom image
# Using proper quoting to handle filenames with spaces
if ! vips arrayjoin "$(ls img*.png | tr '\n' ' ' | sed 's/ $//')" "$TEMP_DZ" --across 4 --background "255, 255, 255"; then
    error "Failed to join images with vips"
fi

# Check if DZ file was created
if [ ! -f "$TEMP_DZ" ]; then
    error "Failed to create deep zoom file"
fi

info "Renaming to SZI format..."

# Rename DZ to SZI
if ! mv "$TEMP_DZ" "$SZI_FILE"; then
    error "Failed to rename file to SZI"
fi

info "Removing temporary PNG files..."

# Remove PNG files
rm -f img*.png

# Verify final output
if [ ! -f "$SZI_FILE" ]; then
    error "Final SZI file was not created"
fi

success "✓ Conversion complete!"
success "Output file: $SZI_FILE"
echo "Size: $(du -h "$SZI_FILE" | cut -f1)"
