# Event-Based Feedback System

A Flutter application that provides an object-oriented, event-based feedback system with star ratings. Each event has its own dedicated feedback section with existing comments that always remain visible, and users can add, edit, and delete their own feedback. Feedback is always tied to a unique event by a 10-digit numeric event ID.

**Recent Improvements:**
- Existing comments now display a feedback title above the comment text for better clarity.
- The feedback form is fully scrollable and supports long feedback without overflow errors.
- The event list (home screen) updates immediately with new feedback and ratings after returning from the feedback screen—no manual refresh needed.

## 📦 Libraries Used

- **Flutter**: UI framework for building cross-platform apps
- **shared_preferences**: Local data persistence for feedback, events, and user ID
- **cupertino_icons**: iOS-style icons
- **Dart core libraries**: `dart:convert`, `dart:math` for JSON, random, and date handling

## 🏗️ Object-Oriented Programming (OOP) Implementation

- **Encapsulation**: All models use private fields with public getters (e.g., `_id`, `_title` in `FeedbackModel`). This hides internal data and exposes only what is necessary.
- **Inheritance**: Shared logic and UI structure are placed in base classes, which are inherited by concrete implementations. For example:
  - `BaseScreen` is an abstract class that provides loading, error, and success handling for all screens. `EventSelectionScreen` and `FeedbackScreen` inherit from `BaseScreen` to reuse this logic.
  - `BaseForm` is an abstract class for forms, inherited by `FeedbackForm` for validation and submission logic.
- **Why Inheritance?**: Inheritance allows code reuse and enforces a consistent structure across screens and forms, reducing duplication and making maintenance easier.
- **Abstraction**: Abstract classes and interfaces (like `StorageService`) define contracts for what a service or widget must do, without specifying how. This allows for multiple implementations (e.g., `SharedPreferencesStorageService` for local storage).
- **Why Abstraction?**: Abstraction enables flexibility and testability. You can swap out storage backends or UI components without changing the rest of the code, and you can mock services for testing.
- **Polymorphism**: Multiple implementations of storage (e.g., `SharedPreferencesStorageService` implements `StorageService`) can be used interchangeably wherever the abstract type is expected.
- **Factory Pattern**: Used for model creation (e.g., `FeedbackModel.create`, `EventModel.create`) to encapsulate object construction logic.
- **Dependency Injection**: Services accept storage implementations as constructor arguments, making the code more modular and testable.
- **Separation of Concerns**: Models, services, screens, and widgets are separated into their own files and directories, so each part of the app has a single responsibility.

## 🚦 Workflow

1. **Event Selection**: The app starts with a list of events. Each event has a unique 10-digit numeric ID, a name, description, and status (upcoming or ended).
2. **Feedback Management**: Selecting an event shows its feedback screen, which displays:
   - Existing (predefined) comments for the event
   - Your feedback for the event (if any)
   - Statistics (total feedback, average rating)
3. **Add/Edit/Delete Feedback**: You can add one feedback per event. You can edit or delete your feedback. Feedback is always tied to the event's unique ID and your unique user ID (stored locally).
4. **Persistence**: All data is stored locally using `shared_preferences`, so your feedback and user ID persist across app restarts.
5. **OOP Structure**: All business logic is handled by service classes, all data is modeled with encapsulated classes, and all UI is built with reusable widgets and base classes.

## 📝 How to Use

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```
2. **Run the app**:
   ```bash
   flutter run
   ```
3. **Select an event** from the main screen (see event ID and status)
4. **View feedback** for the event (existing comments and your feedback)
5. **Add, edit, or delete your feedback** (one per event)
6. **Switch between events** to see that feedback is always tied to the correct event by its unique ID

## 📚 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (EventModel, FeedbackModel)
├── services/                 # Business logic (EventService, FeedbackService, StorageService)
├── screens/                  # UI screens (EventSelectionScreen, FeedbackScreen, BaseScreen)
├── widgets/                  # Reusable UI components (EventCard, FeedbackCard, FeedbackForm, ExistingCommentCard, BaseForm)
```

## 🛠️ Technical Details

- **Feedback is always tied to a unique event by a 10-digit numeric event ID**
- **User ID is generated and stored locally for per-user feedback isolation**
- **All data is persisted using shared_preferences**
- **OOP principles are followed throughout the codebase**

## 📖 Example Event IDs

- Tech Conference 2024: `1000000001` (upcoming)
- Music Festival: `1000000002` (ended)
- Business Networking Workshop: `1000000003` (ended)

## 💡 Notes

- To reset events and feedback, clear app data or reinstall the app.
- You can only add one feedback per event per user.
- Feedback is never shared between events due to unique event IDs.

---

Feel free to extend the app with more events, authentication, or cloud storage while maintaining the OOP architecture!

## Features

### 🎯 Event Management
- **Predefined Events**: Three sample events are automatically created:
  - **Tech Conference 2024**: Technology conference with 5 existing comments (rated 4-5 stars)
  - **Music Festival**: Entertainment event with 5 existing comments (rated 4-5 stars)
  - **Business Networking Workshop**: Business event with 5 existing comments (rated 4-5 stars)

### ⭐ Event-Specific Feedback System
- **Star Ratings**: Rate events from 1 to 5 stars
- **Event-Only Feedback**: Each event has its own dedicated feedback section
- **One Feedback Per Event**: Users can submit only one feedback per event
- **Existing Comments with Titles**: Predefined comments now show a descriptive title above the comment text.
- **Existing Comments with Ratings**: Each event comes with predefined comments that have star ratings and are always visible
- **User Feedback CRUD**: Users can add, edit, and delete their own feedback per event (one per event)
- **Total Rating Calculation**: Calculates average rating including both existing comments and user feedback
- **Persistent Display**: Existing comments never disappear, even after adding user feedback
- **Event Association**: All feedback is linked to specific events
- **Fully Scrollable Feedback Form**: The add/edit feedback form is fully scrollable and supports long feedback without overflow errors, even when the keyboard is open.
- **Instant Home Screen Update**: The event list updates immediately with new feedback and ratings after returning from the feedback screen—no manual refresh required.

### 🏗️ Object-Oriented Architecture
- **Encapsulation**: Private fields with public getters
- **Inheritance**: Base classes for forms, cards, screens, and services
- **Abstraction**: Abstract base classes defining common interfaces
- **Polymorphism**: Different implementations of base classes
- **Design Patterns**: Factory pattern, Strategy pattern, Dependency Injection

### 📱 User Interface
- **Event-First Workflow**: Start by selecting an event, then manage its feedback
- **Event-Specific Views**: Each event has its own feedback screen
- **Always Visible Existing Comments**: Shows predefined comments with titles and ratings that never disappear
- **Separate User Feedback Section**: User feedback appears in a separate section with edit/delete options
- **Modern UI**: Clean, intuitive interface with Material Design
- **Event Cards**: Display event information with total feedback count and average rating
- **Feedback Cards**: Show star ratings and additional comments for the specific event
- **Statistics**: Total feedback count, average rating, and user feedback count per event

## Architecture

### Models
- **EventModel**: Represents events with existing comments and their ratings
- **FeedbackModel**: Represents user feedback with star ratings

### Services
- **EventService**: Manages event operations and predefined events with existing comments and ratings
- **FeedbackService**: Handles user feedback CRUD operations and rating calculations
- **StorageService**: Abstract storage interface with SharedPreferences implementation

### Screens
- **EventSelectionScreen**: Main screen for browsing events with total feedback counts
- **FeedbackScreen**: Manages feedback for a specific event only, shows existing comments and user feedback separately

### Widgets
- **EventCard**: Displays event information with total feedback count and rating statistics
- **FeedbackCard**: Shows user feedback with star ratings and edit/delete options
- **FeedbackForm**: Form for creating/editing user feedback with star rating selection
- **ExistingCommentCard**: Displays predefined comments with star ratings for events

## Getting Started

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the Application**:
   ```bash
   flutter run
   ```

3. **Usage**:
   - Browse events on the main screen (shows total feedback count per event)
   - Tap an event to view its specific feedback
   - See existing comments with titles and ratings (always visible, cannot be edited)
   - Add your own feedback by selecting star rating (1-5) for that event
   - The feedback form is fully scrollable and supports long feedback
   - Edit or delete your own feedback using the action buttons
   - View total statistics including existing comments and user feedback
   - **After adding or editing feedback, the event list updates instantly when you return to the home screen**

## User Feedback Features

### Adding Feedback
- Select star rating (1-5) for the event
- Add title and detailed comments
- Submit feedback specific to the event
- **One feedback per event**: You can only submit one feedback per event

### Editing Feedback
- Click edit button on your feedback card
- Modify rating, title, or comments
- Update your feedback

### Deleting Feedback
- Click delete button on your feedback card
- Confirm deletion
- Remove your feedback from the event
- After deletion, you can add new feedback for that event

## Rating Calculations

### Total Feedback Count
- **Existing Comments**: 5 predefined comments per event
- **User Feedback**: Number of feedback entries added by users
- **Total**: Existing + User feedback count

### Average Rating
- **Existing Comments**: Predefined ratings (4-5 stars)
- **User Feedback**: User-submitted ratings
- **Average**: (Sum of all ratings) / (Total number of ratings)

## Existing Comments with Ratings

Each event comes with 5 predefined comments that have star ratings and are always visible:

### Tech Conference 2024
- "Excellent speakers and content!" ⭐⭐⭐⭐⭐ (5 stars)
- "Great networking opportunities" ⭐⭐⭐⭐ (4 stars)
- "Well-organized event" ⭐⭐⭐⭐⭐ (5 stars)
- "Inspiring presentations" ⭐⭐⭐⭐ (4 stars)
- "Good venue and facilities" ⭐⭐⭐⭐ (4 stars)

### Music Festival
- "Amazing performances!" ⭐⭐⭐⭐⭐ (5 stars)
- "Great atmosphere and vibes" ⭐⭐⭐⭐⭐ (5 stars)
- "Well-coordinated logistics" ⭐⭐⭐⭐ (4 stars)
- "Fantastic food options" ⭐⭐⭐⭐ (4 stars)
- "Perfect weather and setting" ⭐⭐⭐⭐⭐ (5 stars)

### Business Networking Workshop
- "Very informative and practical" ⭐⭐⭐⭐⭐ (5 stars)
- "Great networking opportunities" ⭐⭐⭐⭐ (4 stars)
- "Professional and well-structured" ⭐⭐⭐⭐⭐ (5 stars)
- "Valuable insights shared" ⭐⭐⭐⭐ (4 stars)
- "Excellent facilitator" ⭐⭐⭐⭐⭐ (5 stars)

## Rating System

- **5 Stars**: Excellent experience
- **4 Stars**: Very good experience
- **3 Stars**: Good experience
- **2 Stars**: Fair experience
- **1 Star**: Poor experience

## Technical Details

### Dependencies
- `shared_preferences`: Local data persistence
- Flutter Material Design components

### Storage
- Uses SharedPreferences for local data storage
- Events and feedback are stored as JSON strings
- Automatic data persistence across app sessions

### State Management
- Service-based state management
- Proper initialization and error handling
- Loading states and user feedback

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── event_model.dart     # Event with existing comments and ratings
│   └── feedback_model.dart  # User feedback with ratings
├── services/                # Business logic
│   ├── event_service.dart   # Event management
│   ├── feedback_service.dart # User feedback management
│   └── storage_service.dart # Data persistence
├── screens/                 # UI screens
│   ├── base_screen.dart     # Base screen functionality
│   ├── event_selection_screen.dart # Main event browser
│   └── feedback_screen.dart # Event-specific feedback management
└── widgets/                 # Reusable UI components
    ├── base_card.dart       # Base card functionality
    ├── base_form.dart       # Base form functionality
    ├── event_card.dart      # Event display with total feedback counts
    ├── feedback_card.dart   # User feedback display with edit/delete
    ├── feedback_form.dart   # User feedback creation/editing
    └── existing_comment_card.dart # Existing comments with ratings display
```

## Contributing

This project demonstrates object-oriented programming principles in Flutter. Feel free to extend it with additional features while maintaining the OOP architecture.

## 🏷️ Participated Watermark

- On the home screen, events you have participated in are marked with a green "Participated" watermark on their event card.
- This makes it easy to see at a glance which events you can leave feedback for.
- Participation is tracked per user and stored locally using shared_preferences.
- By default, Tech Conference 2024 (ongoing) and Music Festival (ended) are marked as participated for your user.
- You can only add feedback to events where you see the "Participated" watermark.
