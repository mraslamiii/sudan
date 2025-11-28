#!/bin/bash

# Script to build Android APK for release
# This creates an APK that can be installed directly on devices

echo "🔨 Building Android APK..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build the APK
echo "🏗️  Building release APK..."
flutter build apk --release

echo "✅ Build complete!"
echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "To install on a connected device:"
echo "  adb install build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "Or transfer the APK to your tablet and install it manually."

