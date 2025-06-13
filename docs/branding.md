# Branding Assets

This document describes how the branding assets (logos, favicons) were created and how to update them if needed.

## Logo Files

The project uses three main SVG files for branding in the `public/` directory:
- `logo-black.svg` - Main logo in black
- `logo-white.svg` - Main logo in white
- `logo-collapsed.svg` - Collapsed/favicon version of the logo

These SVG files are generated from two source PNG files (also in `public/`):
- `7gen-logo-original.png` - Original logo image
- `7gen-favicon-192.png` - Favicon/collapsed version

## Creating SVG Files with Embedded PNGs

The SVG files are created by embedding base64-encoded PNG files directly in the SVG. This approach ensures high image quality while maintaining the benefits of SVG scalability.

### Generation Process

1. First, generate base64 data from the PNG files:
```bash
base64 -i 7gen-logo-original.png -o logo-original-base64.txt
base64 -i 7gen-favicon-192.png -o favicon-base64.txt
```

2. Create the SVG files using the following commands:

For `logo-black.svg`:
```bash
cat > logo-black.svg << 'EOL'
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg width="100%" height="100%" viewBox="0 0 200 50" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <image
    width="100%"
    height="100%"
    preserveAspectRatio="xMidYMid meet"
    xlink:href="data:image/png;base64,'$(cat logo-original-base64.txt)'"/>
</svg>
EOL
```

For `logo-collapsed.svg`:
```bash
cat > logo-collapsed.svg << 'EOL'
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg width="100%" height="100%" viewBox="0 0 192 192" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <image
    width="100%"
    height="100%"
    preserveAspectRatio="xMidYMid meet"
    xlink:href="data:image/png;base64,'$(cat favicon-base64.txt)'"/>
</svg>
EOL
```

3. Copy the black logo to create the white version:
```bash
cp logo-black.svg logo-white.svg
```

## Notes

- The viewBox dimensions in the SVG files should match the aspect ratio of your PNG files
- The `preserveAspectRatio="xMidYMid meet"` ensures proper scaling
- Both black and white logos use the same base image, as the color is controlled by CSS in the application