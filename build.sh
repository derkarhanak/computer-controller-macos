#!/bin/bash

# Computer Controller Build Script
# This script helps build and run the macOS app

echo "🚀 Building Computer Controller macOS App..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or not in PATH"
    echo "Please install Xcode from the App Store and try again"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "ComputerController.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    echo "Make sure ComputerController.xcodeproj exists in the current directory"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
xcodebuild clean -project ComputerController.xcodeproj -scheme ComputerController

# Build the project
echo "🔨 Building project..."
xcodebuild build -project ComputerController.xcodeproj -scheme ComputerController -configuration Debug

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🎯 To run the app:"
    echo "1. Open ComputerController.xcodeproj in Xcode"
    echo "2. Press ⌘+R to run, or"
    echo "3. Use the Product menu → Run"
    echo ""
    echo "📱 The app will be built to:"
    echo "   ~/Library/Developer/Xcode/DerivedData/ComputerController-*/Build/Products/Debug/ComputerController.app"
    echo ""
    echo "🔑 Don't forget to:"
    echo "1. Set your DeepSeek API key in the Settings tab"
    echo "2. Grant necessary permissions when prompted"
    echo "3. Test with simple operations first"
else
    echo "❌ Build failed!"
    echo "Please check the error messages above and fix any issues"
    exit 1
fi
