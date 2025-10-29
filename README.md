# Campus Hub 🎓

A production-ready resource-sharing platform for Mehran University (MUET) students, built with Flutter and Spring Boot.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-green.svg)](https://spring.io/projects/spring-boot)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 📖 Overview

Campus Hub enables students to share resources like books, lab equipment, electronics, and more. The platform facilitates borrowing, lending, and donating items within the campus community.

### ✨ Key Features

- 🔐 **Secure Authentication** - Email verification and JWT tokens
- 📚 **Resource Management** - Upload, browse, and search resources
- 🤝 **Request System** - Request to borrow items with approval workflow
- 📊 **Transaction Tracking** - Monitor borrowed and lent items
- 🔍 **Advanced Search** - Filter by category, type, and keywords
- 📱 **Modern UI** - Material 3 design with smooth animations
- 🔄 **Real-time Updates** - Automatic synchronization across users

## 🎥 Screenshots

<table>
  <tr>
    <td><img src="docs/screenshots/login.png" alt="Login" width="200"/></td>
    <td><img src="docs/screenshots/browse.png" alt="Browse" width="200"/></td>
    <td><img src="docs/screenshots/detail.png" alt="Detail" width="200"/></td>
    <td><img src="docs/screenshots/requests.png" alt="Requests" width="200"/></td>
  </tr>
</table>

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** 3.0.0 or higher
- **Dart SDK** 3.0.0 or higher
- **Java** 17+ (for backend)
- **Maven** (for backend)
- Android Studio / VS Code with Flutter extension

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd campus_hub
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Start the backend** (in a separate terminal)
   ```bash
   cd Backend
   mvn spring-boot:run
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

For detailed setup instructions, see [QUICK_START.md](QUICK_START.md)

## 📁 Project Structure

```
campus_hub/
├── lib/
│   ├── main.dart                 # App entry point
│   └── src/
│       ├── api/                  # API service layer
│       │   └── api_service.dart
│       ├── models/               # Data models (DTOs)
│       │   └── models.dart
│       ├── providers/            # State management (Riverpod)
│       │   └── providers.dart
│       ├── repositories/         # Data repositories
│       │   ├── auth_repository.dart
│       │   ├── resource_repository.dart
│       │   ├── request_repository.dart
│       │   └── transaction_repository.dart
│       ├── screens/              # UI screens
│       │   ├── login_screen.dart
│       │   ├── signup_screen.dart
│       │   ├── verification_pending_screen.dart
│       │   ├── home_screen.dart
│       │   ├── browse_screen.dart
│       │   ├── item_detail_screen.dart
│       │   ├── my_items_screen.dart
│       │   ├── donate_screen.dart
│       │   ├── requests_screen.dart
│       │   ├── transactions_screen.dart
│       │   └── profile_screen.dart
│       ├── utils/                # Utilities
│       │   ├── error_util.dart
│       │   └── constants.dart
│       ├── widgets/              # Reusable widgets
│       │   └── common_widgets.dart
│       └── app_router.dart       # Navigation configuration
├── Backend/                      # Spring Boot backend
│   └── src/main/java/
├── test/                         # Unit tests
├── pubspec.yaml                  # Flutter dependencies
└── README.md                     # This file
```

## 🏗️ Architecture

### Frontend (Flutter)
- **State Management**: Riverpod for reactive state
- **Navigation**: GoRouter for declarative routing
- **HTTP Client**: http package with JWT authentication
- **Secure Storage**: flutter_secure_storage for tokens
- **Image Caching**: cached_network_image for performance
- **Design**: Material 3 with Google Fonts

### Backend (Spring Boot)
- **Authentication**: JWT with email verification
- **Database**: PostgreSQL with JPA/Hibernate
- **Image Storage**: Cloudinary
- **Email Service**: SMTP integration
- **API**: RESTful with proper status codes

## 📱 User Flows

### 1. Authentication Flow
```
Signup → Email Verification → Login → Home
```

### 2. Resource Sharing Flow
```
Upload Resource → Browse by Others → Request → Approve → Transaction
```

### 3. Borrow-Return Flow
```
Request Item → Lender Approves → Borrow → Mark Returned → Lender Confirms
```

## 🔑 Core Features Detail

### Authentication
- Email-based registration
- OTP verification via email
- JWT token authentication
- Secure token storage
- Auto-login support

### Resource Management
- Upload with images (required)
- Categories: Books, Electronics, Lab Equipment, Stationery, Misc
- Types: Share (lend) or Donate
- Search and filter functionality
- Edit and delete own resources

### Request System
- Request to borrow with custom return dates
- Approve/decline workflow
- Status tracking (Pending, Approved, Declined)
- Notifications for new requests

### Transaction Tracking
- Borrowed items dashboard
- Lent items dashboard
- Return workflow with confirmation
- Dispute handling for problematic returns

## 🎨 Design System

- **Primary Color**: Indigo (#6366F1)
- **Typography**: Inter (Google Fonts)
- **Design Language**: Material 3
- **Card Radius**: 12px
- **Button Radius**: 12px

## 🔧 Configuration

### API Endpoint Configuration

Create a `.env` file in the project root:
```env
API_BASE_URL=http://10.0.2.2:8080
```

Or use dart-define:
```bash
flutter run --dart-define=API_BASE_URL=http://your-backend-url
```

### Backend Configuration

Configure `application.properties`:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/campus_hub
spring.datasource.username=your_username
spring.datasource.password=your_password

# Email service
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your_email@gmail.com
spring.mail.password=your_app_password

# Cloudinary
cloudinary.cloud_name=your_cloud_name
cloudinary.api_key=your_api_key
cloudinary.api_secret=your_api_secret
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Check formatting
flutter format --set-exit-if-changed lib/
```

## 📚 Documentation

- [QUICK_START.md](QUICK_START.md) - Setup and user guide
- [REFACTOR_SUMMARY.md](REFACTOR_SUMMARY.md) - Architecture and refactor details
- [API_VERIFICATION.md](API_VERIFICATION.md) - Backend integration verification
- [REMOVED_LEGACY_FILES.md](REMOVED_LEGACY_FILES.md) - Cleanup history

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📋 Roadmap

- [ ] Push notifications for requests and returns
- [ ] In-app chat between users
- [ ] User ratings and reviews
- [ ] Dark mode support
- [ ] Advanced analytics dashboard
- [ ] QR code scanning for quick resource lookup
- [ ] Offline mode with sync
- [ ] Multi-language support

## 🐛 Known Issues

- Images are required for resource upload (future: make optional)
- No offline support yet
- Single image per resource (future: multiple images)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Development Team** - Mehran University of Engineering & Technology

## 🙏 Acknowledgments

- Mehran University (MUET) for supporting student initiatives
- Flutter and Spring Boot communities for excellent documentation
- All contributors and testers

## 📞 Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Check the documentation files
- Review backend and frontend logs

---

**Made with ❤️ for the MUET community**

🎓 Share knowledge, share resources, build community!

