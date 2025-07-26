# Qricket - Event Management & Ticket Booking App

A comprehensive Flutter application for event discovery, ticket purchasing, and user engagement. Built with modern UI/UX principles and robust state management.

## 🚀 Key Features

### 🎫 **Event Management & Ticket Booking**
- **Dynamic Event Discovery**: Browse upcoming and past events with rich details
- **Event Thumbnails as Banners**: Event cards now display the event's thumbnail (local asset or network) as the top banner image
- **Splash Screen**: Animated Qricket "Q" logo splash screen on app startup
- **Ticket Purchase System**: Complete ticket buying flow with invoice generation
- **QR Code Tickets**: Digital tickets with unique QR codes for easy verification
- **Purchase History**: Track all your ticket purchases with detailed invoices
- **Event Participation Tracking**: Automatic tracking of events you've participated in
- **Smart Refresh System**: Automatic UI updates after ticket purchases
- **Event Status Management**: Only show feedback for past events, not upcoming ones

### 👤 **User Authentication & Profile**
- **Secure Login/Registration**: Email-based authentication with password validation
- **Registration Confirmation**: After registering, users see a notification and are returned to the login screen (not logged in automatically)
- **Profile Management**: Edit mode for profile updates with compact layout
- **Profile Pictures**: Network and local image support with temporary avatars
- **Activity Logging**: Facebook-style activity log with privacy controls
- **Dark Mode Toggle**: Global dark/light theme with persistence
- **Compact Form Design**: First/last name on one line with edit mode

### 🔔 **Notification System**
- **Smart Notifications**: Event reminders, new event announcements, updates
- **Real-time Updates**: News, event updates, and ticket purchase confirmations
- **Persistent Notifications**: Long-term storage with smart cleanup
- **User-specific Alerts**: Personalized notifications based on participation

### 💾 **Data Management**
- **Local Storage**: Robust data persistence using SharedPreferences
- **Event Bookmarking**: Save events for later viewing
- **Invoice Management**: Complete purchase history with detailed invoices
- **User Preferences**: Persistent settings and preferences
- **Activity Privacy**: Control visibility of activity log entries
- **Robust Asset Image Loading**: All asset image paths are auto-prefixed and work on mobile (for events, news, and event info)

### 🎨 **Enhanced UI/UX**
- **Modern Design**: Clean, intuitive interface with Material Design 3
- **Responsive Layout**: Adaptive design for different screen sizes
- **Visual Feedback**: Real-time validation and user feedback
- **Accessibility**: Proper contrast, readable fonts, and touch targets
- **Facebook-style Activity Log**: Grouped by date with privacy indicators
- **Pull-to-Refresh**: Manual refresh functionality across screens

## 📱 App Screens

### **Splash Screen**
- **Animated Qricket Logo**: App startup splash with animated "Q" logo and app name

### **Authentication**
- **Login Screen**: Email/password authentication with dark mode toggle
- **Registration**: Complete signup with first/last name and password confirmation
- **Privacy Policy**: Integrated terms and conditions agreement

### **Main Navigation**
- **Home Screen**: Event overview with quick actions and recent activity
- **Event Selection**: Browse all events with search, filtering, and sorting
- **Notifications**: Dedicated notification center with read/unread status
- **Tickets**: View purchased tickets and access QR codes
- **Account**: Profile management and settings

### **Event Management**
- **Event Details**: Comprehensive event information with dynamic layouts and thumbnail banners
- **Ticket Purchase**: Complete buying flow with payment simulation
- **Ticket View**: Digital ticket with QR code and download functionality
- **Purchase History**: Detailed invoice management and history
- **Event Feedback**: Rate and review participated events (past events only)

### **User Features**
- **Account Settings**: Profile editing with edit mode, password changes, data management
- **Activity Log**: Facebook-style activity tracking with privacy controls
- **Saved Events**: Bookmarked events with search and filtering
- **Settings**: App preferences and configuration
- **Registration**: Account creation now shows a notification and returns to login screen (no auto-login)

## 🛠️ Technical Architecture

### **State Management**
- **Service-based Architecture**: Clean separation of business logic
- **SharedPreferences**: Robust local data persistence
- **Real-time Updates**: Immediate UI updates after data changes
- **Error Handling**: Comprehensive error management and user feedback
- **Refresh Mechanisms**: Automatic and manual refresh capabilities

### **Data Models**
- **User Model**: Complete user profile with activity tracking and profile images
- **Event Model**: Rich event data with dynamic content and thumbnail support
- **Invoice Model**: Detailed purchase and billing information
- **Notification Model**: Smart notification system with metadata
- **Activity Log Model**: Privacy-controlled activity tracking

### **Services**
- **AuthService**: User authentication and session management
- **EventService**: Event data management and operations
- **InvoiceService**: Ticket purchase and invoice generation
- **NotificationService**: Smart notification generation and management
- **StorageService**: Local data persistence and management
- **FeedbackService**: Event rating and review system

## 🎯 User Workflow

### **1. Authentication**
- Register with email, first/last name, and password
- Agree to privacy policy and terms
- Login with secure credentials
- Toggle dark mode for preferred theme

### **2. Event Discovery**
- Browse events on the home screen
- Use search and filtering options
- View event details with rich information
- Save events for later viewing

### **3. Ticket Purchase**
- Select upcoming events
- Choose ticket type and quantity
- Complete payment simulation
- Receive digital ticket with QR code
- Download ticket to device gallery
- **Automatic UI refresh** removes "Buy Ticket" button after purchase

### **4. Event Participation**
- Attend events with purchased tickets
- View participation history
- Access event-specific features
- Track activity and engagement
- **Provide feedback** for past events only

### **5. Profile Management**
- **Edit mode required** to change profile information
- Compact form with first/last name on one line
- Network and local profile image support
- Activity log with privacy controls
- Facebook-style activity grouping

## 📊 Features Overview

### **Event Management**
- ✅ Dynamic event listing with search and filters
- ✅ Rich event details with multiple layout types
- ✅ Event bookmarking and saved events
- ✅ Event participation tracking
- ✅ Event status (upcoming, ongoing, past)
- ✅ **Feedback system** for past events only
- ✅ **Automatic refresh** after ticket purchases

### **Ticket System**
- ✅ Complete ticket purchase flow
- ✅ Invoice generation with unique IDs
- ✅ QR code ticket generation
- ✅ Purchase history tracking
- ✅ Ticket download functionality
- ✅ **Background image support** for tickets

### **User Experience**
- ✅ Dark/light theme toggle
- ✅ **Profile picture management** with network support
- ✅ **Edit mode** for profile changes
- ✅ Password change with validation
- ✅ **Facebook-style activity logging**
- ✅ **Privacy controls** for activity entries
- ✅ **Pull-to-refresh** functionality

### **Data Persistence**
- ✅ Local storage with SharedPreferences
- ✅ User data persistence
- ✅ Event and ticket data management
- ✅ Settings and preferences storage
- ✅ **Activity log privacy** settings

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### **Installation**

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd Flutter_aileen_qricket
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

### **Configuration**

The app is pre-configured with sample data:
- **Sample Events**: Tech Conference, Music Festival, Art Exhibition
- **Sample Users**: Pre-loaded user accounts with temporary profile images
- **Sample Invoices**: Example purchase history
- **Network Profile Images**: Temporary avatars from Unsplash

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point with theme provider
├── models/                      # Data models
│   ├── user_model.dart         # User profile and activity
│   ├── event_model.dart        # Event data and content
│   ├── invoice_model.dart      # Purchase and billing data
│   ├── feedback_model.dart     # User feedback system
│   └── notification_model.dart # Notification system
├── services/                    # Business logic
│   ├── auth_service.dart       # Authentication and user management
│   ├── event_service.dart      # Event operations
│   ├── invoice_service.dart    # Ticket and invoice management
│   ├── notification_service.dart # Notification system
│   ├── feedback_service.dart   # Feedback and rating system
│   └── storage_service.dart    # Data persistence
├── screens/                     # UI screens
│   ├── login_screen.dart       # Authentication
│   ├── home_screen.dart        # Main dashboard
│   ├── event_selection_screen.dart # Event browser
│   ├── selected_event_screen.dart # Event details
│   ├── ticket_purchase_screen.dart # Ticket buying
│   ├── ticket_view_screen.dart # Digital ticket display
│   ├── account_settings_screen.dart # Profile management
│   ├── notification_screen.dart # Notification center
│   ├── activity_log_screen.dart # Facebook-style activity log
│   ├── purchase_history_screen.dart # Purchase history
│   └── invoice_details_screen.dart # Invoice details
├── widgets/                     # Reusable components
│   ├── event_card.dart         # Event display cards
│   ├── feedback_form.dart      # Feedback creation
│   └── base_form.dart          # Form base classes
└── assets/                      # Static assets
    ├── data/                   # JSON data files with profile images
    └── images/                 # Event images
```

## 🎨 UI/UX Features

### **Modern Design**
- Clean, intuitive interface
- Consistent color scheme and typography
- Responsive layout for all screen sizes
- Smooth animations and transitions

### **User Feedback**
- Real-time validation
- Loading states and progress indicators
- Success/error messages
- Confirmation dialogs

### **Accessibility**
- High contrast text
- Readable font sizes
- Touch-friendly buttons
- Screen reader support

### **Recent UI Improvements**
- **Splash Screen**: Animated Qricket logo on startup
- **Compact Profile Form**: First/last name on one line
- **Edit Mode**: Required to change profile information
- **Network Image Support**: Profile pictures from online sources
- **Facebook-style Activity Log**: Grouped by date with privacy
- **Pull-to-Refresh**: Manual refresh across screens
- **Background Images**: Event thumbnails on tickets

## 🔧 Technical Details

### **Dependencies**
- `shared_preferences`: Local data persistence
- `image_picker`: Profile picture selection
- `qr_flutter`: QR code generation
- `intl`: Date formatting and localization
- `cupertino_icons`: iOS-style icons

### **State Management**
- Service-based architecture
- Local state with setState
- SharedPreferences for persistence
- Real-time UI updates
- **Refresh mechanisms** for data consistency

### **Data Flow**
1. User interactions trigger service calls
2. Services update local storage
3. UI components reflect changes immediately
4. Data persists across app sessions
5. **Automatic refresh** after critical actions

### **Recent Technical Improvements**
- **Activity Log Privacy**: Prevents recording "view activity log" actions
- **Network Image Handling**: Support for online profile images
- **Feedback System**: Only for past events
- **Refresh Mechanisms**: Automatic UI updates
- **Compact Forms**: Better space utilization
- **Asset Image Path Fix**: All asset images (events, news, event info) are auto-prefixed and load correctly on mobile
- **Registration Flow**: Registration no longer logs in automatically; user is notified and returned to login
- **Splash Screen**: Animated logo splash on app startup

## 🚀 Recent Updates

### **v1.2.0 - Splash, Asset Fixes, and Registration Flow**
- ✅ **Splash Screen**: Animated Qricket "Q" logo splash on app startup
- ✅ **Event Thumbnails as Banners**: Event cards use event thumbnails as top images
- ✅ **Registration Flow**: Registration shows notification and returns to login (no auto-login)
- ✅ **Asset Image Path Fix**: All asset images now load correctly on mobile (auto-prefixed)
- ✅ **News/Event Info Asset Fix**: News and event info images also support asset path auto-fixing

### **v1.1.0 - Activity & Profile Enhancements**
- ✅ **Facebook-style Activity Log**: Grouped by date with privacy controls
- ✅ **Profile Image Support**: Network and local image handling
- ✅ **Compact Profile Form**: First/last name on one line with edit mode
- ✅ **Smart Refresh System**: Automatic UI updates after purchases
- ✅ **Feedback System**: Only for past events, not upcoming ones
- ✅ **Activity Privacy**: Prevents recording activity log views
- ✅ **Pull-to-Refresh**: Manual refresh across screens
- ✅ **Background Images**: Event thumbnails on tickets

### **v1.0.0 - Core Features**
- ✅ Complete event management system
- ✅ Ticket purchase and QR code generation
- ✅ User authentication and profile management
- ✅ Notification system
- ✅ Dark mode support
- ✅ Local data persistence

## 🚀 Future Enhancements

### **Planned Features**
- Cloud synchronization
- Push notifications
- Social sharing
- Event recommendations
- Advanced search filters
- Payment gateway integration
- **Real-time chat** for events
- **Event calendar** integration

### **Performance Optimizations**
- Image caching and optimization
- Lazy loading for large lists
- Memory management improvements
- Background data sync
- **Offline mode** support

## 🤝 Contributing

This project demonstrates modern Flutter development practices. Feel free to contribute by:

1. Reporting bugs and issues
2. Suggesting new features
3. Improving documentation
4. Enhancing UI/UX
5. Optimizing performance

## 📄 License

This project is open source and available under the MIT License.

---

**Built with ❤️ using Flutter and Dart**
