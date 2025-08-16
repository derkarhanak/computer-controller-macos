#!/bin/bash

echo "🚀 Installing Computer Controller..."

# Check if Applications directory exists
if [ ! -d "/Applications" ]; then
    echo "❌ Applications directory not found"
    exit 1
fi

# Copy the app to Applications
echo "📁 Copying Computer Controller to Applications..."
cp -R "Computer Controller.app" "/Applications/"

# Make sure it's executable
chmod +x "/Applications/Computer Controller.app/Contents/MacOS/ComputerController"

echo "✅ Computer Controller has been installed!"
echo "🎉 You can now find it in your Applications folder"
echo ""
echo "To use the app:"
echo "1. Open Computer Controller from Applications"
echo "2. Go to Settings & Tools tab"
echo "3. Enter your DeepSeek API key"
echo "4. Switch to Computer Control tab"
echo "5. Type commands like 'Create a folder called Test on Desktop'"
echo ""
echo "Note: The app may need Full Disk Access permission for file operations."
echo "You can grant this in System Preferences > Security & Privacy > Privacy > Full Disk Access"
