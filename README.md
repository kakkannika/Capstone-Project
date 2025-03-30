# tourism_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment Setup

This app uses environment variables to manage API keys and sensitive information.

### Setting up API Keys

1. Create a `.env` file in the root of the project
2. Add the following variables to your `.env` file:

```
# Google Maps API Keys
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

Note: Never commit your `.env` file to version control. It is already included in the `.gitignore` file.

### For Development

When working on the app in debug mode, you can also set environment variables using launch arguments:

```
flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_api_key_here
```
