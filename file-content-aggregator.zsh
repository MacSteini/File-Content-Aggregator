#!/usr/bin/env zsh
#
# File Content Aggregator v1.0
#
# Author:
# Name: Marco Steinbrecher
# Email: fcascript@steinbrecher.co
# GitHub: https://github.com/macsteini/file-content-aggregator
#
# Description:
# This script combines the names and cleaned content of all non-hidden files
# in a directory into a single output file named "combined.txt".
# It optionally filters files by specified extensions.
# Hidden files, the output file itself, and the script file are excluded.
#
# Features:
# - Combines content of all non-hidden files in the current directory
# - Supports filtering by specific file extensions (e.g., "txt,csv")
# - Cleans file content by removing BOMs and carriage return characters
# - Produces a summary of processed files, grouped by extension
#
# Example Usage:
# - Combine all files:
#   ./file-content-aggregator.zsh
# - Combine only ".txt" and ".csv" files:
#   extensions="txt,csv" ./file-content-aggregator.zsh
#
# MIT Licence:
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Define the name of the output file
outfile="combined.txt"

# Define the extensions variable (if any specific file extensions are required to filter)
extensions=""

# Remove the existing output file to start fresh
rm -f "$outfile"

# Check if the script is executed as a command in the shell or from a script file
if [[ "$0" == "-bash" || "$0" == "-zsh" ]]; then
    echo "Executed as a command in the shell."
else
    # Get the script's filename if executed from a file
    script_name=$(basename "$0")
    echo "Executed from a script file: $script_name"
fi

# Initialise an array for extension filters
ext_filters=()

# Declare an associative array to keep track of counts by file extension
typeset -A ext_counts

# Initialise the counter for the total number of processed files
count=0

# If extensions are specified, create an array of them and prepare filters for the find command
if [[ -n "$extensions" ]]; then
    # Split the extensions string into an array, assuming comma separation
    ext_array=("${(@s/,/)extensions}")
    for ext in "${ext_array[@]}"; do
        # Append extension filter patterns to the ext_filters array
        ext_filters+=(-name "*.$ext")
    done
fi

# Use LC_ALL=C to ensure consistent locale behaviour (important for sorting and string operations)
# Find files meeting the specified criteria:
# - Regular files
# - Matching the extension filters (if specified)
# - Excluding hidden paths
# - Excluding the output file and script name
LC_ALL=C find . -type f \
    $([[ -n "$extensions" ]] && printf "%s" "\( ${ext_filters[@]} -o -false \)") \
    -not -path '*/.*' \
    -not -name "$outfile" \
    -not -name "$script_name" \
    -print0 | while IFS= read -r -d '' file; do
        # Append a file header to the output file
        printf "###\n### %s\n###\n\n" "$file" >> "$outfile"

        # Remove UTF-8 BOM (if present) and normalise line endings in the file content before appending it
        sed '1s/^\xEF\xBB\xBF//; s/\r$//' "$file" >> "$outfile"

        # Add a blank line after the file content
        printf "\n\n" >> "$outfile"

        # Extract the file extension and update the count for this extension
        ext="${file##*.}"
        ((ext_counts["$ext"]++))

        # Increment the total processed file count
        count=$((count + 1))
    done

# Print a summary of the processing
echo "Processing complete. $count files processed. Split by extension:"
for ext in ${(k)ext_counts}; do
    # Print the count of files for each extension
    echo "$ext: ${ext_counts[$ext]} files"
done

# Indicate the location of the output file
echo "Output written to $outfile."