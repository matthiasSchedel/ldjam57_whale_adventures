#!/bin/bash
# godot_itch_deploy.sh
# Builds a Godot game for browser and uploads it to itch.io

set -e # Exit on any error

# ======= CONFIGURATION =======
# Edit these variables for your project
GAME_NAME="adventures-of-little-whale"
ITCH_USERNAME="matthiasschedel"        # Your itch.io username
ITCH_GAME="adventures-of-little-whale" # Your itch.io game URL path
GODOT_PATH="godot"                     # Path to Godot executable (use "godot" if in PATH)
EXPORT_PRESET="HTML5"                  # Name of your export preset
BUILD_DIR="./builds/web"               # Directory to store the build
GAME_VERSION=$(date +"%Y.%m.%d.%H%M")  # Automated versioning

# Optional: HTML file modifications
GAME_TITLE="Adventures of little Whale" # Title that appears in the browser tab
CUSTOM_BACKGROUND_COLOR="#000080"       # Background color for the web page - use ocean blue #000080

# ======= FUNCTIONS =======

check_dependencies() {
    echo "Checking dependencies..."

    # Check for Godot
    if ! command -v "$GODOT_PATH" &>/dev/null; then
        echo "Error: Godot executable not found at $GODOT_PATH"
        echo "Edit the GODOT_PATH variable or make sure Godot is installed and in your PATH"
        exit 1
    fi

    # Check for Butler
    if ! command -v butler &>/dev/null; then
        echo "Error: Butler not found"
        echo "Please install Butler (itch.io's command-line tool)"
        echo "See: https://itch.io/docs/butler/"
        exit 1
    fi

    # if ! butler status &>/dev/null; then
    #     echo "Butler is not logged in. Please run 'butler login' first."
    #     exit 1
    # fi
    # Check for project.godot file
    if [ ! -f "project.godot" ]; then
        echo "Error: project.godot not found in current directory"
        echo "Please run this script from your Godot project directory"
        exit 1
    fi

    # Check for export preset
    if ! "$GODOT_PATH" --headless --quiet --script-execute scripts/check_export_preset.gd 2>/dev/null; then
        echo "Creating a temporary script to check for export presets..."
        mkdir -p scripts
        cat >scripts/check_export_preset.gd <<EOF
tool
extends SceneTree

func _init():
    var has_preset = false
    var settings = ConfigFile.new()
    if settings.load("export_presets.cfg") == OK:
        for section in settings.get_sections():
            if settings.get_value(section, "name") == "$EXPORT_PRESET":
                has_preset = true
                break
    
    if not has_preset:
        print("Error: Export preset '$EXPORT_PRESET' not found")
        print("Please create an HTML5 export preset in Godot's Export menu")
        quit(1)
    
    quit(0)
EOF

        if ! "$GODOT_PATH" --headless --script scripts/check_export_preset.gd; then
            exit 1
        fi
    fi

    echo "All dependencies satisfied!"
}

build_game() {
    echo "Building game for HTML5..."

    # Create build directory if it doesn't exist
    mkdir -p "$BUILD_DIR"

    # Export the game using Godot CLI
    "$GODOT_PATH" --headless --export "$EXPORT_PRESET" "$BUILD_DIR/index.html"

    # Check if export was successful
    if [ ! -f "$BUILD_DIR/index.html" ]; then
        echo "Error: Export failed - index.html not found in build directory"
        exit 1
    fi

    echo "Game successfully built at $BUILD_DIR"
}

optimize_for_web() {
    echo "Optimizing for web..."

    # Update the HTML title if needed
    if [ -n "$GAME_TITLE" ]; then
        sed -i.bak "s/<title>Godot Engine<\/title>/<title>$GAME_TITLE<\/title>/" "$BUILD_DIR/index.html"
        rm "$BUILD_DIR/index.html.bak"
    fi

    # Update background color if needed
    if [ -n "$CUSTOM_BACKGROUND_COLOR" ]; then
        sed -i.bak "s/background-color: #333333;/background-color: $CUSTOM_BACKGROUND_COLOR;/" "$BUILD_DIR/index.html"
        rm "$BUILD_DIR/index.html.bak"
    fi

    # Add custom loading screen (optional)
    # Uncomment and modify if you want to customize the loading screen
    # cat > "$BUILD_DIR/custom_loading.css" << EOF
    # .godot_loading {
    #     background-image: url('loading.png');
    #     background-size: contain;
    #     background-position: center;
    #     background-repeat: no-repeat;
    # }
    # EOF
    #
    # sed -i.bak "/<style type=\"text\/css\">/r $BUILD_DIR/custom_loading.css" "$BUILD_DIR/index.html"
    # rm "$BUILD_DIR/custom_loading.css" "$BUILD_DIR/index.html.bak"

    echo "Web optimization complete"
}

compress_build() {
    echo "Compressing build..."

    # For itch.io, we can upload the directory directly with Butler,
    # but creating a zip can be useful for backup or manual upload

    cd "$BUILD_DIR/.."
    zip -r "${GAME_NAME}_web_${GAME_VERSION}.zip" "$(basename "$BUILD_DIR")"
    cd - >/dev/null

    echo "Build compressed to $(dirname "$BUILD_DIR")/${GAME_NAME}_web_${GAME_VERSION}.zip"
}

upload_to_itch() {
    echo "Uploading to itch.io..."

    # Upload using Butler (no need to zip, Butler handles it)
    butler push "$BUILD_DIR" "$ITCH_USERNAME/$ITCH_GAME:html5" \
        --userversion "$GAME_VERSION"

    echo "Game successfully uploaded to https://$ITCH_USERNAME.itch.io/$ITCH_GAME"
}

# ======= MAIN SCRIPT =======

echo "===== Godot to Itch.io Deployment Tool ====="
echo "Game: $GAME_NAME (version $GAME_VERSION)"
echo "Target: https://$ITCH_USERNAME.itch.io/$ITCH_GAME"
echo "============================================="

check_dependencies
build_game
optimize_for_web
compress_build
upload_to_itch

echo "Deployment process complete!"
echo "Your game is now available at: https://$ITCH_USERNAME.itch.io/$ITCH_GAME"
