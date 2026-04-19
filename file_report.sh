#!/bin/bash

echo "Enter folder path:"
read -r folder

if [ ! -d "$folder" ]; then
    echo "Error: Directory not found"
    exit 1
fi

output="/home/vr/Desktop/files_report_$(date +%Y%m%d_%H%M%S).txt"

{
    echo "=== FILE REPORT ==="
    echo "Folder: $folder"
    echo "Generated: $(date)"
    echo "=========================="
    echo ""
    echo "=== SUMMARY ==="
    echo "Total files: $(find "$folder" -type f | wc -l)"
    echo "Total directories: $(find "$folder" -type d | wc -l)"
    echo "Total size: $(du -sh "$folder" | cut -f1)"
    echo ""
    echo "=== FILE TYPES ==="
    find "$folder" -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn
    echo ""
    echo "=== FILES LIST ==="
    printf "%-50s %-15s %15s %20s %20s\n" "FILE" "TYPE" "SIZE" "MODIFIED" "CREATED"
    echo "------------------------------------------------------------------------------------------------------------------"
    
    while IFS= read -r file; do
        filename=$(basename "$file")
        filetype=$(file -b "$file" | cut -d',' -f1)
        size=$(du -h "$file" | cut -f1)
        modified=$(stat -c '%y' "$file" 2>/dev/null | cut -d'.' -f1 || stat -f '%Sm' "$file" 2>/dev/null)
        created=$(stat -c '%w' "$file" 2>/dev/null | cut -d'.' -f1 || stat -f '%Sc' "$file" 2>/dev/null)
        
        printf "%-50s %-15s %15s %20s %20s\n" "$filename" "$filetype" "$size" "$modified" "$created"
    done < <(find "$folder" -type f)
    
} > "$output"

echo "Report saved to: $output"
