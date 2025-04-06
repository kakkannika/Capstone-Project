

## Getting Started

### Prerequisites
- Flutter SDK (version ^3.5.3)
- Dart SDK
- Firebase account
- Google Maps API key
- Firebase CLI

### Installation
1. Clone the repository
2. Create a `.env` file in the root directory with the following keys:
   ```
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   ```
3. Run `flutter pub get` to install dependencies
4. Configure Firebase using Firebase CLI or manual setup
5. Run the app with `flutter run`

### Quick Firebase Setup with CLI
1. **Install Firebase CLI** (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```
   
2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Install FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. **Set up Firebase in your Flutter project** (from your project directory):
   ```bash
   # Create a new Firebase project
   firebase projects:create your-project-name
   
   # Configure Flutter project with Firebase
   flutterfire configure --project=your-project-name
   ```

That's it! Your Firebase project is now set up and linked to your Flutter application.

## Dependencies
This project uses the following packages:

### Firebase Services
- **firebase_core:** ^3.11.0 - Core Firebase functionality
- **firebase_auth:** ^5.4.2 - Firebase authentication
- **cloud_firestore:** ^5.6.4 - Firestore database services
- **firebase_storage:** ^12.4.4 - Firebase cloud storage
- **firebase_admin:** ^0.3.0+1 - Admin SDK for Firebase

### Authentication
- **google_sign_in:** ^6.2.2 - Google authentication
- **flutter_facebook_auth:** ^7.1.1 - Facebook authentication
- **pinput:** ^5.0.1 - PIN input for verification codes
- **intl_phone_field:** ^3.2.0 - International phone number input

### Maps & Location
- **google_maps_flutter:** ^2.10.1 - Google Maps integration
- **geolocator:** ^13.0.2 - Geolocation services
- **location:** ^8.0.0 - Location tracking
- **flutter_polyline_points:** ^2.1.0 - Drawing routes on maps
- **latlong2:** ^0.9.1 - Geographical coordinates

### State Management
- **provider:** ^6.1.2 - State management
- **get:** ^4.7.2 - GetX state management

### UI Components
- **flutter_slidable:** ^4.0.0 - Slidable list items
- **carousel_slider:** ^5.0.0 - Image carousels
- **cached_network_image:** ^3.4.1 - Image caching
- **cupertino_icons:** ^1.0.8 - iOS style icons
- **iconsax:** ^0.0.8 - Icon pack

### Utilities
- **http:** ^1.3.0 - HTTP requests
- **dio:** ^5.8.0+1 - HTTP client
- **shared_preferences:** ^2.5.2 - Local storage
- **intl:** ^0.19.0 - Internationalization and formatting
- **flutter_dotenv:** ^5.2.1 - Environment variable management
- **url_launcher:** ^6.3.1 - URL launching
- **image_picker:** ^1.1.2 - Image selection
- **file_picker:** ^9.0.2 - File selection
- **fluttertoast:** ^8.2.12 - Toast notifications
- **json_annotation:** ^4.9.0 - JSON serialization



## License
This project is proprietary and confidential.

## Contact
For more information, contact dertamapp@gmail.com
