#!/bin/zsh

# Mermaid CLI helper: render .mmd files to SVGs into a sibling out/ directory
function mermaid() {
    if ! command -v mmdc >/dev/null 2>&1; then
        echo "❌ Mermaid CLI (mmdc) not found. Install: npm i -g @mermaid-js/mermaid-cli"
        return 127
    fi

    if [[ $# -eq 0 ]]; then
        echo "Usage: mermaid <file1.mmd> [file2.mmd ...]"
        return 1
    fi

    local exit_code=0

    for file in "$@"; do
        if [[ ! -f "$file" ]]; then
            echo "⚠️  Skipping: '$file' is not a file"
            exit_code=1
            continue
        fi

        # Only handle .mmd files
        if [[ "${file##*.}" != "mmd" ]]; then
            echo "⚠️  Skipping: '$file' is not a .mmd file"
            exit_code=1
            continue
        fi

        local dirpath
        dirpath="$(cd "$(dirname "$file")" && pwd)"
        local basename
        basename="${${file##*/}%.*}"
        local out_dir="$dirpath/out"
        local out_file="$out_dir/$basename.svg"

        mkdir -p "$out_dir" || { echo "❌ Failed to create '$out_dir'"; exit_code=1; continue; }

        echo "🧪 Rendering: $file → $out_file"
        mmdc -i "$file" -o "$out_file"
        if [[ $? -eq 0 ]]; then
            echo "✅ Wrote: $out_file"
        else
            echo "❌ Failed: $file"
            exit_code=1
        fi
    done

    return $exit_code
}


