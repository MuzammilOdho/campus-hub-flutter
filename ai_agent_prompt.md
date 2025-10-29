

## PROMPT START

You are an expert Flutter developer. Build a complete production-ready Flutter mobile application called "Campus Hub" for Mehran University (MUET). This is a resource-sharing platform where students can lend, borrow, and donate items.

### 📋 PROJECT REQUIREMENTS

**Backend:** Java Spring Boot (already exists at API endpoint)
**Authentication:** JWT-based with OTP verification via email
**University Email:** Only @admin.muet.edu.pk emails allowed

### 🎯 CORE FEATURES TO IMPLEMENT

#### 1. **Authentication Module**
- Splash screen with animated logo
- Login page (email + password)
- Registration page (name, MUET email, password, phone, department, enrollment)
- OTP verification page (6-digit code sent to email)
- Forgot password flow
- JWT token management with auto-refresh
- Session persistence using SharedPreferences

#### 2. **Home Dashboard**
- Welcome banner with user name
- Statistics cards: Total Items, Active Borrows, Lent Items, Pending Requests
- Category grid: Books, Electronics, Stationery, Tools, Sports, Furniture, Clothing, Others
- Recent items feed (infinite scroll)
- Quick action buttons: Add Item, My Requests, Transactions

#### 3. **Items Management**
- Browse all available items (filterable by category, condition, type)
- Item detail page with:
  - Image carousel
  - Title, description, condition, category
  - Owner information
  - "Request to Borrow" or "Claim Donation" button
  - Share button
- Create/Edit item form:
  - Image picker (multiple images)
  - Title, description, category, condition
  - Type: Lend (with return date) or Donate
  - Availability toggle
- My items list with edit/delete options
- Search with filters (category, condition, availability)

#### 4. **Request System**
- Send borrow request with message and requested return date
- My requests page (sent requests with status)
- Incoming requests page (received requests)
- Request detail with:
  - Requester/Lender info
  - Item details
  - Message
  - Accept/Decline buttons (for lender)
  - Cancel button (for requester)
- Push notifications for request updates

#### 5. **Transactions Management**
- Active transactions (borrowed/lent items)
- Transaction detail showing:
  - Item info
  - Borrower/Lender details
  - Borrow date, expected return date
  - Timeline view of transaction status
- "Mark as Returned" button (for borrower)
- "Confirm Return" button (for lender)
- "Raise Issue" button if problems occur
- Transaction history (completed)

#### 6. **Notifications**
- Notification list with unread count badge
- Notification types:
  - New request received
  - Request accepted/declined
  - Item borrowed
  - Return reminder (1 day before due)
  - Return marked by borrower
  - Return confirmed by lender
  - Issue raised
- Mark as read functionality
- Deep linking to relevant screens

#### 7. **Profile & Settings**
- User profile with stats (items shared, successful borrows, rating)
- Edit profile (name, phone, department, enrollment, profile picture)
- Change password
- Theme toggle (light/dark mode)
- Logout

#### 8. **Admin/Moderator Features** (if user role is admin/mod)
- View all users
- View all transactions
- Resolve disputes/issues
- Suspend users
- Analytics dashboard

### 🏗️ ARCHITECTURE REQUIREMENTS

**Use Clean Architecture with BLoC Pattern:**

```
lib/
├── main.dart
├── app.dart
├── injection_container.dart (GetIt for DI)
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart (all endpoints)
│   │   ├── app_constants.dart
│   │   ├── colors.dart (modern color scheme)
│   │   └── text_styles.dart (Google Fonts - Poppins)
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_client.dart (Dio wrapper)
│   │   ├── dio_interceptor.dart (JWT injection)
│   │   └── network_info.dart (connectivity check)
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── date_formatter.dart
│   │   ├── image_picker_helper.dart
│   │   └── shared_preferences_helper.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── loading_indicator.dart
│       ├── error_widget.dart
│       ├── cached_image.dart
│       └── empty_state.dart
│
├── config/
│   ├── routes/
│   │   ├── app_routes.dart
│   │   └── route_generator.dart
│   └── themes/
│       └── app_theme.dart (Material 3)
│
└── features/
    ├── authentication/
    │   ├── data/
    │   │   ├── datasources/auth_remote_datasource.dart
    │   │   ├── models/user_model.dart, auth_response.dart
    │   │   └── repositories/auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/user.dart
    │   │   ├── repositories/auth_repository.dart
    │   │   └── usecases/ (login, register, verify_otp, logout)
    │   └── presentation/
    │       ├── bloc/ (auth_bloc, auth_event, auth_state)
    │       └── pages/ (splash, login, register, otp_verification)
    │
    ├── home/
    ├── items/
    ├── requests/
    ├── transactions/
    ├── notifications/
    └── profile/
```

### 📦 REQUIRED PACKAGES

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  dartz: ^0.10.1
  get_it: ^7.6.4
  dio: ^5.3.3
  connectivity_plus: ^5.0.1
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_spinkit: ^5.2.0
  google_fonts: ^6.1.0
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0
  image_picker: ^1.0.4
  image_cropper: ^5.0.1
  intl: ^0.18.1
  timeago: ^3.6.0
  url_launcher: ^6.2.1
  permission_handler: ^11.0.1
  flutter_dotenv: ^5.1.0
```

### 🎨 UI/UX GUIDELINES

1. **Modern Design:**
   - Use Material Design 3
   - Gradient backgrounds for key areas
   - Card-based layouts with shadows
   - Smooth animations and transitions
   - Pull-to-refresh on lists
   - Shimmer loading effects

2. **Colors:**
   - Primary: Blue (#2563EB)
   - Secondary: Purple (#7C3AED)
   - Accent: Green (#10B981)
   - Error: Red (#EF4444)
   - Support dark mode

3. **Components:**
   - Bottom navigation bar (Home, Items, Requests, Transactions, Profile)
   - Floating action button for quick actions
   - Custom cards for items with image, title, category badge
   - Status badges (Available, Borrowed, Pending, etc.)
   - Empty states with illustrations
   - Error states with retry button

4. **Forms:**
   - Rounded text fields with icons
   - Clear error messages below fields
   - Loading state on buttons during API calls
   - Form validation before submission

### 🔧 TECHNICAL SPECIFICATIONS

1. **API Integration:**
   - Base URL from .env file
   - All endpoints follow REST conventions
   - JWT token in Authorization header (Bearer token)
   - Handle 401 (logout and redirect to login)
   - Handle network errors gracefully
   - Implement retry logic for failed requests

2. **State Management:**
   - Use BLoC for all features
   - Emit proper states (Initial, Loading, Success, Error)
   - Handle edge cases
   - Use Equatable for state comparison

3. **Local Storage:**
   - Store JWT token securely (flutter_secure_storage)
   - Store user preferences (SharedPreferences)
   - Cache user data
   - Clear on logout

4. **Image Handling:**
   - Compress images before upload
   - Show loading during upload
   - Support multiple image picker
   - Cache network images

5. **Error Handling:**
   - Network errors → Show retry option
   - Validation errors → Show under field
   - Server errors → Show error dialog
   - Session expired → Auto logout

6. **Performance:**
   - Lazy loading for lists
   - Image caching
   - Debounce search queries
   - Optimize API calls

### 🚀 API ENDPOINTS (Backend Already Exists)

**Auth:**
- POST /api/v1/auth/register
- POST /api/v1/auth/verify-otp
- POST /api/v1/auth/login
- POST /api/v1/auth/logout
- POST /api/v1/auth/forgot-password
- POST /api/v1/auth/reset-password

**Items:**
- GET /api/v1/items (with pagination, filters)
- GET /api/v1/items/{id}
- POST /api/v1/items
- PUT /api/v1/items/{id}
- DELETE /api/v1/items/{id}
- GET /api/v1/items/my-items
- GET /api/v1/items/search?q=

**Requests:**
- POST /api/v1/requests
- GET /api/v1/requests/my-requests
- GET /api/v1/requests/incoming
- GET /api/v1/requests/{id}
- PUT /api/v1/requests/{id}/accept
- PUT /api/v1/requests/{id}/decline
- PUT /api/v1/requests/{id}/cancel

**Transactions:**
- GET /api/v1/transactions/my-transactions
- GET /api/v1/transactions/{id}
- PUT /api/v1/transactions/{id}/mark-returned
- PUT /api/v1/transactions/{id}/confirm-return
- PUT /api/v1/transactions/{id}/raise-issue

**Notifications:**
- GET /api/v1/notifications
- GET /api/v1/notifications/unread-count
- PUT /api/v1/notifications/{id}/read
- PUT /api/v1/notifications/mark-all-read

**Profile:**
- GET /api/v1/users/profile
- PUT /api/v1/users/profile
- PUT /api/v1/users/change-password

**Upload:**
- POST /api/v1/upload/image (multipart/form-data)

### ✅ DELIVERABLES

Generate complete, production-ready code with:
1. All files organized in proper folder structure
2. Comprehensive comments and documentation
3. Error handling for all scenarios
4. Loading states for all async operations
5. Form validation with proper error messages
6. Responsive UI that works on all screen sizes
7. Dark mode support
8. README.md with setup instructions
9. .env.example file
10. Proper Git ignore file

### 🎯 VALIDATION RULES

- Email: Must be @admin.muet.edu.pk
- Password: Min 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char
- Name: 2-50 characters, letters only
- Phone: Pakistani format (03XXXXXXXXX)
- OTP: 6 digits
- Item title: 3-100 characters
- Description: 10-500 characters

### 📱 SCREEN FLOW

1. Splash → Check auth → Login/Home
2. Login → OTP if not verified → Home
3. Register → OTP Verification → Home
4. Home → Browse Items → Item Detail → Request/Claim
5. Lender receives request → Accept/Decline
6. If accepted → Transaction created → Track return
7. Borrower marks returned → Lender confirms → Transaction completed

### 🔔 IMPORTANT NOTES

- DO NOT include Firebase or any chat functionality
- Use only HTTP REST APIs
- Follow Flutter best practices
- Write clean, maintainable code
- Add proper null safety
- Test all edge cases
- Handle offline scenarios
- Implement proper loading states

Build this complete application now with all features, proper architecture, and excellent UI/UX.

## PROMPT END

