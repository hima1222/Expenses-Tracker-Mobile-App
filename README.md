# Smart Expense Tracker

A comprehensive Flutter application for tracking personal expenses with Firebase backend integration.

## Features

### Authentication
- User registration and login
- Secure authentication with Firebase Auth
- Automatic session management

### Transaction Management
- Add income and expense transactions
- Categorize transactions (Food, Travel, Bills, Entertainment, Other)
- Date-based transaction tracking
- Real-time transaction updates

### Dashboard
- Monthly balance overview
- Income and expense tracking
- Recent transactions display
- Editable monthly income

### Budget Management
- Set monthly budget limits
- Track spending against budget
- Budget status indicators (On Track, Nearing Limit, Exceeded)
- Real-time budget monitoring

### Reports & Analytics
- Weekly and monthly expense reports
- Category-wise expense breakdown
- Visual progress indicators
- Spending trend analysis

### Profile Management
- User profile display
- Account settings
- Secure logout functionality

## Backend Architecture

### Firebase Services Used
- **Firebase Authentication**: User registration, login, and session management
- **Cloud Firestore**: Real-time database for transactions, budgets, and user profiles
- **Firebase Storage**: File storage for future enhancements

### Database Structure
```
users/{userId}/
├── profile: { name, email, monthlyBudget, createdAt }
├── transactions/{transactionId}/
│   ├── type: "income" | "expense"
│   ├── category: string
│   ├── amount: number
│   ├── date: timestamp
│   └── notes: string
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Firebase CLI
- Android Studio / VS Code
- Google account for Firebase

### 1. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new Firebase project
3. Enable Authentication:
   - Go to Authentication > Sign-in method
   - Enable Email/Password provider
4. Enable Firestore:
   - Go to Firestore Database
   - Create database in production mode
5. Add Flutter app:
   - Go to Project settings > General
   - Click "Add app" > Flutter
   - Follow the instructions to add Firebase configuration

### 2. Flutter Configuration

1. **For Android**:
   - Download `google-services.json` from Firebase console
   - Place it in `android/app/google-services.json`

2. **For iOS**:
   - Download `GoogleService-Info.plist` from Firebase console
   - Place it in `ios/Runner/GoogleService-Info.plist`

3. **For Web**:
   - Update `lib/services/firebase_config.dart` with your web Firebase config

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

## Firebase Security Rules

Add these security rules to your Firestore database:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Environment Variables

Update `lib/services/firebase_config.dart` with your Firebase configuration:

```dart
// For Web
FirebaseOptions(
  apiKey: "your-web-api-key",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef123456",
)
```

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Features Overview

### User Authentication Flow
1. Splash screen checks authentication state
2. Unauthenticated users see login/register options
3. Authenticated users go directly to dashboard

### Transaction Management
- Add transactions with type, category, amount, date, and notes
- Real-time sync across all user devices
- Automatic calculation of balances and budgets

### Budget Tracking
- Set monthly budget in profile/budget screen
- Real-time monitoring of spending vs budget
- Visual indicators for budget status

### Reports & Analytics
- Category-wise expense breakdown
- Weekly/monthly view toggles
- Progress bars and percentage calculations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@expense-tracker.com or create an issue in the repository.
