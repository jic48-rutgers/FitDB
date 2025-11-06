#!/bin/bash
# Script to expand SOURCE commands in SQL files
# Usage: expand_sources.sh <input_file>

# Read input file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Check if line contains SOURCE command
    pattern='^SOURCE[[:space:]]+([^;]+)[[:space:]]*;'
    if [[ "$line" =~ $pattern ]]; then
        # Extract the file path from SOURCE command
        source_file="${BASH_REMATCH[1]}"
        # Remove leading/trailing whitespace from file path
        source_file=$(echo "$source_file" | xargs)
        # Include the source file contents
        if [ -f "$source_file" ]; then
            # Include as SQL comment (appears in log file)
            echo "-- =========================================="
            echo "-- Loading: $source_file"
            echo "-- =========================================="
            cat "$source_file"
        else
            echo "-- ERROR: Source file not found: $source_file" >&2
            exit 1
        fi
    else
        # Output the line as-is
        echo "$line"
    fi
done < "$1"

