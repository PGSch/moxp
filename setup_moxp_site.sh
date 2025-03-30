#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
# Prevent errors in a pipeline from being masked.
set -euo pipefail

echo "Starting MOXP website structure setup..."

# --- Configuration ---
TARGET_DIR="moxp-website"
SOURCE_DIR="docs"

# --- Safety Checks ---
if [ -d "$TARGET_DIR" ]; then
    echo "Error: Target directory '$TARGET_DIR' already exists."
    echo "Please remove or rename it before running this script."
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' not found in the current location."
    echo "Make sure you are running this script from the project root."
    exit 1
fi

# --- Create Directory Structure ---
echo "Creating base directory: '$TARGET_DIR'"
mkdir "$TARGET_DIR"

echo "Creating subdirectories: css, js, images, assets/fonts"
mkdir -p "$TARGET_DIR/css"
mkdir -p "$TARGET_DIR/js"
mkdir -p "$TARGET_DIR/images"
mkdir -p "$TARGET_DIR/assets/fonts" # As per proposed structure

# --- Move Existing Assets ---
echo "Moving assets from '$SOURCE_DIR' to '$TARGET_DIR/images/'..."

# Use check before moving to avoid errors if a file is missing
[ -f "$SOURCE_DIR/favicon.png" ] && mv "$SOURCE_DIR/favicon.png" "$TARGET_DIR/images/" && echo "  Moved favicon.png" || echo "  Warning: favicon.png not found in $SOURCE_DIR."
[ -f "$SOURCE_DIR/supernovablackhole_red.png" ] && mv "$SOURCE_DIR/supernovablackhole_red.png" "$TARGET_DIR/images/" && echo "  Moved supernovablackhole_red.png" || echo "  Warning: supernovablackhole_red.png not found in $SOURCE_DIR."
[ -f "$SOURCE_DIR/universe.jpg" ] && mv "$SOURCE_DIR/universe.jpg" "$TARGET_DIR/images/" && echo "  Moved universe.jpg" || echo "  Warning: universe.jpg not found in $SOURCE_DIR."

# --- Backup Old Index ---
echo "Backing up existing '$SOURCE_DIR/index.html'..."
if [ -f "$SOURCE_DIR/index.html" ]; then
    mv "$SOURCE_DIR/index.html" "$TARGET_DIR/index_single_page_backup.html"
    echo "  Original index.html moved to '$TARGET_DIR/index_single_page_backup.html'"
else
    echo "  Warning: $SOURCE_DIR/index.html not found. No backup created."
fi

# --- Create New Placeholder Files ---
echo "Creating new placeholder HTML, CSS, and JS files..."
touch "$TARGET_DIR/index.html"
touch "$TARGET_DIR/about.html"
touch "$TARGET_DIR/features.html"
touch "$TARGET_DIR/technology.html"
touch "$TARGET_DIR/community.html"
touch "$TARGET_DIR/get-moxp.html"
touch "$TARGET_DIR/contact.html"
touch "$TARGET_DIR/css/style.css"
touch "$TARGET_DIR/js/main.js"

# --- Add Basic Boilerplate Content ---
echo "Adding basic HTML boilerplate to new pages..."
current_year=$(date +%Y) # Get current year for footer

# List of new HTML files (excluding the backup)
html_files=(
    "$TARGET_DIR/index.html"
    "$TARGET_DIR/about.html"
    "$TARGET_DIR/features.html"
    "$TARGET_DIR/technology.html"
    "$TARGET_DIR/community.html"
    "$TARGET_DIR/get-moxp.html"
    "$TARGET_DIR/contact.html"
)

for html_file in "${html_files[@]}"; do
    # Extract base name and create a title (e.g., about -> About)
    base_name=$(basename "$html_file" .html)
    page_title=$(echo "$base_name" | sed -e "s/\b\(.\)/\u\1/g" -e "s/-/ /g")
    if [[ "$base_name" == "index" ]]; then
      page_title="Homepage"
    elif [[ "$base_name" == "get-moxp" ]]; then
      page_title="Get MOXP"
    fi

    cat << EOF > "$html_file"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MOXP - ${page_title}</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
    </head>
<body>
    <header>
        <h1><a href="index.html">MOXP</a></h1>
        <nav>
            <ul>
                <li><a href="index.html">Home</a></li>
                <li><a href="about.html">About</a></li>
                <li><a href="features.html">Features</a></li>
                <li><a href="technology.html">Technology</a></li>
                <li><a href="community.html">Community</a></li>
                <li><a href="get-moxp.html">Get MOXP</a></li>
                <li><a href="contact.html">Contact</a></li>
            </ul>
        </nav>
    </header>

    <main>
        <h2>${page_title}</h2>
        <p>Content for the MOXP ${page_title} page.</p>
        </main>

    <footer>
        <p>&copy; ${current_year} MOXP. All rights reserved.</p>
        </footer>

    <script src="js/main.js"></script>
</body>
</html>
EOF
done
echo "  Basic HTML structure added."

echo "Adding placeholder comments to CSS/JS files..."
echo "/* Main Stylesheet for MOXP Website */" > "$TARGET_DIR/css/style.css"
echo "body { font-family: sans-serif; /* TODO: Add base styles */ }" >> "$TARGET_DIR/css/style.css"

echo "// Main JavaScript for MOXP Website" > "$TARGET_DIR/js/main.js"
echo "// TODO: Add mobile menu toggle, animations, etc." >> "$TARGET_DIR/js/main.js"

# --- Clean Up Original Directory ---
echo "Cleaning up original '$SOURCE_DIR' directory..."
# Check if the source directory is now empty before removing
if [ -d "$SOURCE_DIR" ] && [ -z "$(ls -A $SOURCE_DIR)" ]; then
    rmdir "$SOURCE_DIR"
    echo "  Removed empty '$SOURCE_DIR' directory."
elif [ -d "$SOURCE_DIR" ]; then
    echo "  Warning: '$SOURCE_DIR' directory is not empty. Manual cleanup might be needed."
    echo "  Files remaining in '$SOURCE_DIR':"
    ls -A "$SOURCE_DIR"
else
     echo "  '$SOURCE_DIR' directory does not exist anymore."
fi

# --- Completion Message ---
echo "-------------------------------------"
echo "✅ Setup complete!"
echo "New website structure created in '$TARGET_DIR/'."
echo "Your original single-page site is backed up at '$TARGET_DIR/index_single_page_backup.html'."
echo ""
echo "Next steps:"
echo "1.  'cd $TARGET_DIR' to enter the new website directory."
echo "2.  Fill in the content for each .html file."
echo "3.  Add your styles to css/style.css (or set up Tailwind)."
echo "4.  Implement JavaScript functionality in js/main.js."
echo "5.  Review your .gitignore, LICENSE, and README.md outside the '$TARGET_DIR' folder."
echo "-------------------------------------"

exit 0
