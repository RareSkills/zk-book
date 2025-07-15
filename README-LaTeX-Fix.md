# LaTeX Unicode Math Symbol Support

This project includes fixes for LaTeX compilation issues with Unicode mathematical symbols in markdown files.

## Problem

When compiling markdown files to PDF using pandoc, certain Unicode mathematical symbols (≠, ∧, ∨) would cause font warnings or display incorrectly because the default LaTeX fonts don't support these characters.

## Solution

### Files Added

1. **`math-symbols.tex`** - LaTeX header file that maps Unicode symbols to standard LaTeX commands
2. **`compile-markdown.sh`** - Universal script to compile any markdown file with Unicode math support

### How It Works

The `math-symbols.tex` file includes:
- Unicode character mappings for mathematical symbols
- Standard LaTeX symbol replacements (≠ → \neq, ∧ → \land, ∨ → \lor)
- Better equation formatting support

### Usage

#### From Project Root

```bash
# Compile any markdown file
./compile-markdown.sh content/p-vs-np/en/p-vs-np.md

# Specify custom output name
./compile-markdown.sh content/finite-fields/en/finite-fields.md my-output.pdf
```

#### From Any Directory

```bash
# Using pandoc directly with the math symbols header
pandoc input.md -o output.pdf --toc --pdf-engine=xelatex -H /path/to/math-symbols.tex
```

### Equation Formatting Improvements

The solution also includes fixes for long equations that would overflow page margins:
- Long equations are broken into multiple lines using `\\quad` for proper indentation
- The `\allowdisplaybreaks` command allows equations to break across pages if needed

### Example

Before: Unicode symbols would show as missing characters or cause compilation errors
After: Symbols display correctly as proper mathematical notation

## Requirements

- pandoc
- XeLaTeX (part of a standard LaTeX distribution)
- Standard LaTeX packages: amsmath, newunicodechar

## Files Modified

- `content/p-vs-np/en/p-vs-np.md` - Fixed overly long equations by breaking them into multiple lines
- Added proper indentation for complex mathematical expressions

## Testing

The solution has been tested with:
- p-vs-np.md file containing complex mathematical formulas
- Various Unicode mathematical symbols (≠, ∧, ∨)
- Long equations that previously overflowed page margins

All tests pass successfully with clean PDF output and no LaTeX warnings.
