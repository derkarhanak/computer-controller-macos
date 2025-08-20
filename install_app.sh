#!/bin/bash

echo "📱 Installing Computer Controller to Applications folder..."

# Copy the app to Applications
cp -R "Computer Controller.app" "/Applications/"

# Make sure it's executable
chmod +x "/Applications/Computer Controller.app/Contents/MacOS/ComputerController"

echo "✅ Computer Controller has been installed to Applications!"
echo "You can now launch it from Launchpad or Applications folder."
echo ""
echo "To run it now, use: open '/Applications/Computer Controller.app'"
