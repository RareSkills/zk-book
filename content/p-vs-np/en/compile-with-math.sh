#!/bin/bash

# Script to compile markdown files with LaTeX Unicode math symbol support
# Usage: ./compile-with-math.sh input.md [output.pdf]

if [ $# -lt 1 ]; then
    echo "Usage: $0 input.md [output.pdf]"
    echo "Example: $0 p-vs-np.md p-vs-np.pdf"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-${INPUT_FILE%.md}.pdf}"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATH_SYMBOLS_FILE="$SCRIPT_DIR/math-symbols.tex"

# Check if math-symbols.tex exists
if [ ! -f "$MATH_SYMBOLS_FILE" ]; then
    echo "Error: math-symbols.tex not found in script directory!"
    exit 1
fi

echo "Compiling $INPUT_FILE to $OUTPUT_FILE with Unicode math symbol support..."

# Compile with pandoc using XeLaTeX and math symbols header
pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" --toc --pdf-engine=xelatex -H "$MATH_SYMBOLS_FILE"

# Check if compilation was successful
if [ $? -eq 0 ]; then
    echo "Success! PDF created: $OUTPUT_FILE"
    ls -la "$OUTPUT_FILE"
else
    echo "Error: PDF compilation failed!"
    exit 1
fi
