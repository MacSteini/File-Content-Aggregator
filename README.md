# File Content Aggregator

`zsh` and `bash` scripts that combine the names and cleaned content of all non-hidden files in a folder into a single output file, excluding the output file and the script itself.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Usage Instructions](#usage-instructions)
- [How It Works](#how-it-works)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Licence](#licence)

## Overview

This project automates the creation of a combined file. The script reads through all non-hidden files in the current folder and appends their cleaned content to the output file, ensuring compatibility and clarity.

Additional functionality includes:

- File extension filtering
- Recursive folder traversal
- Dynamic count of processed files by file type

## Features

- Compatible with **macOS** and the **zsh** shell
- Cleans file content by removing BOMs and carriage return characters
- Excludes hidden files, folders, the output file, and the script file itself
- Supports:
  - File extension filtering (e.g., only .txt files)
  - Recursive folder traversal
  - Dynamic count of processed files by extension
- Generates a file with headers and cleaned content for each file

## Requirements

- **Operating System**: macOS or Linux
- **Shell**: _zsh_ or _bash_ (v4.0+)
- **Tools Required**:
  - `find`
  - `sed`
  - `printf`

These tools are included by default in macOS and most Linux distributions.

## Usage Instructions

1. Open the terminal on your macOS device.
1. Go to the folder with the files to process:
   ```bash
   cd /path/to/your/folder
   ```
1. Choose one of the following options:
   1. Run the command in the zsh shell:
      ```zsh
      outfile="combined.txt";extensions="";rm -f "$outfile";[[ "$0" == "-bash" || "$0" == "-zsh" ]] && echo "Executed as a command in the shell." || { script_name=$(basename "$0"); echo "Executed from a script file: $script_name"; };ext_filters=();typeset -A ext_counts;count=0;if [[ -n "$extensions" ]]; then ext_array=("${(@s/,/)extensions}");for ext in "${ext_array[@]}";do ext_filters+=(-name "*.$ext");done;fi;LC_ALL=C find . -type f $([[ -n "$extensions" ]] && printf "%s" "\( ${ext_filters[@]} -o -false \)") -not -path '*/.*' -not -name "$outfile" -not -name "$script_name" -print0 | while IFS= read -r -d '' file;do printf "###\n### %s\n###\n\n" "$file" >> "$outfile";sed '1s/^\xEF\xBB\xBF//; s/\r$//' "$file" >> "$outfile";printf "\n\n" >> "$outfile";ext="${file##*.}";((ext_counts["$ext"]++));count=$((count + 1));done;echo "Processing complete. $count files processed. Split by extension:";for ext in ${(k)ext_counts};do echo "$ext: ${ext_counts[$ext]} files";done;echo "Output written to $outfile."
      ```
   1. Run the following command in the bash shell:
      ```bash
      outfile="combined.txt"; extensions=""; rm -f "$outfile"; [[ "$0" == "-bash" || "$0" == "-zsh" ]] && echo "Executed as a command in the shell." || { script_name=$(basename "$0"); echo "Executed from a script file: $script_name"; }; declare -A ext_counts; count=0; ext_filters=(); if [[ -n "$extensions" ]]; then IFS=',' read -ra ext_array <<< "$extensions"; for ext in "${ext_array[@]}"; do ext_filters+=(-name "*.$ext"); done; fi; find_cmd="find . -type f"; [[ -n "$extensions" ]] && find_cmd+=" \( ${ext_filters[@]} -o -false \)"; find_cmd+=" -not -path '*/.*' -not -name '$outfile' -not -name '$script_name' -print0"; eval "$find_cmd" | while IFS= read -r -d '' file; do printf "###\n### %s\n###\n\n" "$file" >> "$outfile"; sed '1s/^\xEF\xBB\xBF//; s/\r$//' "$file" >> "$outfile"; printf "\n\n" >> "$outfile"; ext="${file##*.}"; ext_counts["$ext"]=$((ext_counts["$ext"] + 1)); count=$((count + 1)); done; echo "Processing complete. $count files processed. Split by extension:"; for ext in "${!ext_counts[@]}"; do echo "$ext: ${ext_counts[$ext]} files"; done; echo "Output written to $outfile."
      ```
   1. Save and execute the scripts as a file:
      1. Save the zsh or bash script in the folder with the files to process
      1. Make it executable: `chmod +x ./file-content-aggregator.zsh` resp. `chmod +x file-content-aggregator.sh`
      1. Run the script: `./file-content-aggregator.zsh` resp. `./file-content-aggregator.sh`

## How It Works

1. **Initialisation:**
   - Sets the output file and optional file extensions
   - Excludes hidden files, the output file, and the script file itself
1. **File Selection:**
   - Dynamically includes all files if extensions are empty
   - Otherwise, filters files based on specified extensions
1. **File Processing:**
   - Iterates through selected files
   - For each file:
     - Appends a header with the file name
     - Cleans the file content by removing BOM and carriage returns
     - Counts files by extension
1. **Completion:**
   - Outputs a summary of processed files by extension

## Troubleshooting

- **Permission denied:** Update folder permissions with `chmod` if required and ensure the script has executable permissions: `chmod +x ./file-content-aggregator.zsh` resp. `chmod +x ./file-content-aggregator.sh`
- **Output file not generated:** Verify that the `find`, `sed`, and `printf` commands are working on your system by testing them individually
- **Empty output:** Ensure your file extension filters or folder contain matching files

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork this repository
1. Create a feature branch: `git checkout -b feature-branch`
1. Commit your changes: `git commit -m "Add feature"`
1. Push the branch: `git push origin feature-branch`
1. Submit a pull request

Please ensure all changes are well-documented and tested.

**Suggestions for improvements are highly encouraged!** Please ensure that your contributions adhere to the project’s coding standards and include appropriate documentation.

## Licence

This project is licenced under the [MIT Licence](https://opensource.org/license/mit "MIT Licence"). You are free to use, modify, and distribute this project in compliance with the licence terms.
