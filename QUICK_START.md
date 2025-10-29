# Campus Hub - Quick Start Guide

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extension
- Java 17+ (for backend)
- Maven (for backend)

### 1. Backend Setup

```bash
cd Backend

# Configure application.properties or use environment variables
# Set database connection, email service, Cloudinary credentials

# Build and run
mvn clean install
mvn spring-boot:run

# Backend will start on http://localhost:8080
```

### 2. Flutter Setup

```bash
# Install dependencies
flutter pub get

# Configure API endpoint (optional)
# Create .env file in root:
echo "API_BASE_URL=http://10.0.2.2:8080" > .env

# Or use --dart-define:
# flutter run --dart-define=API_BASE_URL=http://your-backend-url:8080
```

### 3. Run the App

#### For Android Emulator:
```bash
flutter run
# Default API base URL is http://10.0.2.2:8080 (emulator localhost)
```

#### For Physical Device:
```bash
# Update API_BASE_URL to your computer's local IP
flutter run --dart-define=API_BASE_URL=http://192.168.1.x:8080
```

#### For iOS Simulator:
```bash
flutter run
# Update API_BASE_URL to http://localhost:8080 or your IP
```

## 📱 User Flow

### First Time User
1. **Sign Up**
   - Tap "Create an account" on login screen
   - Enter name, email, password
   - Submit and receive verification email

2. **Verify Account**
   - Check email for verification code
   - Enter code in verification screen
   - Tap "Verify" to activate account
   - Can resend code if needed

3. **Login**
   - Return to login screen
   - Enter verified email and password
   - Access the app

### Main Features

#### Browse Resources
- **Home** → **Browse** tab
- Search resources by name or description
- Filter by category (Books, Electronics, etc.)
- Filter by type (Share, Donate)
- Tap any resource to view details

#### Request a Resource
- Open resource detail screen
- Review information and select return date
- Tap "Request to Borrow"
- Wait for lender approval

#### Upload a Resource
- Tap the **Upload** floating action button
- Fill in resource details:
  - Name (required)
  - Description (required)
  - Category (dropdown)
  - Type: Share or Donate
  - Image (required)
- Submit to list your resource

#### Manage Requests
- Tap **Notifications** icon (bell) in top bar
- **Received** tab: Requests from others for your items
  - Approve or Decline each request
- **Sent** tab: Your requests to borrow items
  - Track status (Pending, Approved, Declined)

#### Track Transactions
- **Menu** (3 dots) → **Transactions**
- **Borrowed** tab: Items you're borrowing
  - Mark as returned when done
- **Lent** tab: Items you've lent
  - Confirm or decline returns

#### My Items
- **Home** → **My Items** tab
- View all your uploaded resources
- Delete items you no longer offer
- Check status (Available, In Use, etc.)

#### Profile
- Tap **Profile** icon in top bar
- View activity statistics
- Access notifications and transactions
- Logout

## 🎨 Features Overview

### ✅ Authentication
- Email-based signup
- Email verification with OTP
- JWT token-based authentication
- Secure token storage
- Auto-login on app restart

### ✅ Resource Management
- Upload with image
- Category-based organization
- Type selection (Share/Donate)
- Search and filter
- Edit and delete

### ✅ Request System
- Request to borrow items
- Approve/decline requests
- Track request status
- Automatic notifications

### ✅ Transaction Tracking
- Monitor borrowed items
- Monitor lent items
- Return workflow with confirmation
- Dispute handling

### ✅ User Experience
- Material 3 design
- Pull-to-refresh lists
- Loading indicators
- Error handling
- Empty state messages
- Confirmation dialogs
- Status badges
- Search functionality
- Image caching

## 🔧 Configuration

### API Base URL Priority
1. `.env` file: `API_BASE_URL=http://your-url`
2. Dart define: `--dart-define=API_BASE_URL=http://your-url`
3. Default: `http://10.0.2.2:8080` (Android emulator)

### Environment Variables
Create a `.env` file in the project root:
```env
API_BASE_URL=http://10.0.2.2:8080
```

## 🐛 Troubleshooting

### Cannot connect to backend
- **Emulator**: Use `http://10.0.2.2:8080`
- **Physical device**: Use your computer's local IP
- **iOS Simulator**: Use `http://localhost:8080` or your IP
- Ensure backend is running on port 8080
- Check firewall settings

### Images not loading
- Verify Cloudinary configuration in backend
- Check network connectivity
- Ensure backend is uploading images correctly

### Login fails after signup
- Ensure email verification is complete
- Check backend logs for verification errors
- Try resending verification code

### Token expired
- Logout and login again
- Backend token expiration is configurable

### Build errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📊 Testing

### Run unit tests
```bash
flutter test
```

### Run with verbose logging
```bash
flutter run -v
```

### Check for issues
```bash
flutter analyze
```

## 🔐 Security Notes

- JWT tokens stored in `FlutterSecureStorage`
- All authenticated requests include `Authorization` header
- Backend validates tokens on every request
- Logout clears stored token
- Sensitive data never logged in production

## 📝 Known Limitations

- Images required for resource upload
- No offline mode (requires network)
- Single image per resource
- No direct messaging between users
- No push notifications (future enhancement)

## 🎯 Next Steps After Setup

1. Create a test account
2. Verify your email
3. Upload a few test resources
4. Create another test account to test request flow
5. Test the complete borrow-return cycle

## 💡 Tips

- Use clear, descriptive names for resources
- Add detailed descriptions to help others
- Set realistic return dates when requesting
- Respond promptly to requests for your items
- Confirm returns quickly to keep items available

## 📞 Support

For issues or questions:
- Check `REFACTOR_SUMMARY.md` for architecture details
- Check `API_VERIFICATION.md` for backend integration details
- Review Flutter and backend logs for errors

## ✨ Enjoy Campus Hub!

Share resources, help fellow students, and build a stronger campus community! 🎓📚🤝

