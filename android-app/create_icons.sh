#!/bin/bash

# Create placeholder launcher icons for all densities
# These use XML drawables so no external tools needed

echo "Creating launcher icon resources..."

# Create directories
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/mipmap-mdpi
mkdir -p app/src/main/res/mipmap-hdpi
mkdir -p app/src/main/res/mipmap-xhdpi
mkdir -p app/src/main/res/mipmap-xxhdpi
mkdir -p app/src/main/res/mipmap-xxxhdpi
mkdir -p app/src/main/res/mipmap-anydpi-v26

# Launcher icon references are already created as XML vectors
# Android Studio will use the vector drawables we created

echo "✓ Launcher icon structure created"
echo "✓ Using vector drawables for all densities"
echo ""
echo "To add custom PNG icons:"
echo "1. Create PNG files in each mipmap-* folder"
echo "2. Sizes: mdpi(48x48), hdpi(72x72), xhdpi(96x96), xxhdpi(144x144), xxxhdpi(192x192)"
echo "3. Name them ic_launcher.png and ic_launcher_round.png"
