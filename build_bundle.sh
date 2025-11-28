#!/bin/bash

# Script to build Android App Bundle (AAB) for release
# This creates a bundle that can be uploaded to Google Play Store

echo "🔨 Building Android App Bundle (AAB)..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build the app bundle
echo "🏗️  Building release bundle..."
flutter build appbundle --release

echo "✅ Build complete!"
echo "📱 App bundle location: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "To install on a device, use:"
echo "  flutter build apk --release"
echo "  Then install: build/app/outputs/flutter-apk/app-release.apk"

