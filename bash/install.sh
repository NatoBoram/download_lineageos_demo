#!/bin/sh

flutter build apk --target-platform=android-arm64
flutter install build/app/outputs/apk/release/app-release.apk
