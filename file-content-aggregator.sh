#!/usr/bin/env bash
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
#   ./file-content-aggregator.sh
# - Combine only ".txt" and ".log" files:
#   extensions="txt,log" ./file-content-aggregator.sh
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

# Define the name of the output file.
outfile="combined.txt"

# Specify file extensions to filter. If empty, all files will be considered.
extensions=""

# Remove any existing output file to avoid appending to old data.
rm -f "$outfile"

# Check if the script is executed from the shell or as a script file.
if [[ "$0" == "-bash" || "$0" == "-zsh" ]]; then
    echo "Executed as a command in the shell."
else
    script_name=$(basename "$0")  # Get the script file name.
    echo "Executed from a script file: $script_name"
fi

# Declare an associative array to keep track of file extensions and their counts.
declare -A ext_counts
count=0  # Counter for total processed files.
ext_filters=()  # Array to hold extension-based find filters.

# If extensions are specified, parse them into an array for filtering.
if [[ -n "$extensions" ]]; then
    IFS=',' read -ra ext_array <<< "$extensions"  # Split extensions by comma.
    for ext in "${ext_array[@]}"; do
        ext_filters+=(-name "*.$ext")  # Add each extension to the filter array.
    done
fi

# Construct the base `find` command to locate files.
find_cmd="find . -type f"  # Search for regular files.

# If extensions are specified, add filtering to the find command.
[[ -n "$extensions" ]] && find_cmd+=" \( ${ext_filters[@]} -o -false \)"

# Exclude hidden files, the output file, and the script itself from the search.
find_cmd+=" -not -path '*/.*' -not -name '$outfile' -not -name '$script_name' -print0"

# Execute the constructed `find` command and process each file.
eval "$find_cmd" | while IFS= read -r -d '' file; do
    # Add a header with the file name to the output file.
    printf "###\n### %s\n###\n\n" "$file" >> "$outfile"

    # Copy the file content to the output file, handling encoding issues.
    sed '1s/^\xEF\xBB\xBF//; s/\r$//' "$file" >> "$outfile"

    # Append two blank lines to separate file contents.
    printf "\n\n" >> "$outfile"

    # Extract the file's extension.
    ext="${file##*.}"

    # Update the count of files for this extension.
    ext_counts["$ext"]=$((ext_counts["$ext"] + 1))

    # Increment the total file count.
    count=$((count + 1))
done

# Display a summary of the processing.
echo "Processing complete. $count files processed. Split by extension:"

# List the number of files processed for each extension.
for ext in "${!ext_counts[@]}"; do
    echo "$ext: ${ext_counts[$ext]} files"
done

# Inform the user where the combined output is written.
echo "Output written to $outfile."