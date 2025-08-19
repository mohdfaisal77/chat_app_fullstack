# Real-Time Chat Application - Frontend (Flutter)

This is the Flutter frontend of the Real-Time Chat Application.  
It connects to a Node.js + Express + MongoDB backend with Socket.IO for real-time messaging.

---

## Features
- User Authentication (Signup + Login using JWT)
- Secure token storage
- Real-time 1-to-1 chat with Socket.IO
- Online/offline connection status
- Auto-scroll chat view
- MVVM architecture with BLoC state management

---

## Architecture Brief
This app follows MVVM + BLoC:

- Models → Represent data (User, Message)
- Repositories (ViewModels) → Handle API calls, token storage, and chat logic
- Services → Provide REST + Socket.IO communication
- BLoCs → Manage app state for Auth and Chat
- Views → Flutter UI screens that respond to BLoC states

---

## Setup Instructions

1. Clone the repository
```
git clone https://github.com/mohdfaisal77/chat_app_fullstack.git
cd chat_app_fullstack
```

2. Install dependencies
```
flutter pub get
```

3. Configure Backend URL  
   The app auto-detects backend URL (emulator vs real device).  
   You can also manually set it in:

```dart
// lib/viewmodels/auth_repository.dart
String baseUrl = "http://192.168.31.94:400"; // replace with your backend IP
```

- http://10.0.2.2:4000 → Android Emulator
- http://192.168.x.x:4000 → Real device (use your machine’s LAN IP)
- http://localhost:4000 → iOS Simulator

4. Run the app
```
flutter run
```

---

## Project Structure and File Descriptions

```
lib/
 ├── bloc/                      # State management using BLoC
 │    ├── auth_bloc.dart         # Authentication state (login, signup, logout)
 │    ├── chat_bloc.dart         # Chat state (loading users, messages, socket events)
 │
 ├── models/                    # Data models
 │    ├── user.dart              # User model (id, email)
 │    ├── message.dart           # Chat message model (from, to, text, timestamp)
 │
 ├── services/                  # Backend + Socket services
 │    ├── api_service.dart       # REST API wrapper (GET/POST with JWT)
 │    ├── socket_service.dart    # Manages Socket.IO connections
 │
 ├── viewmodels/                # Repositories (business logic layer)
 │    ├── auth_repository.dart   # Handles signup/login, JWT token storage
 │    ├── chat_repository.dart   # Manages user list, chat messages
 │    ├── secure_storage.dart    # Securely saves JWT tokens on device
 │
 ├── views/                     # UI Screens
 │    ├── login_view.dart        # Login form screen
 │    ├── signup_view.dart       # Signup form screen
 │    ├── chat_list_view.dart    # Shows all users available for chat
 │    ├── chat_view.dart         # 1-to-1 chat screen
 │    ├── message_bubble.dart    # UI widget for displaying chat bubbles
 │
 ├── app.dart                   # Main app widget, routes, theme
 ├── main.dart                  # Entry point
```

---

## API Documentation

These APIs are provided by the Node.js backend.

### Authentication
- POST `/api/auth/signup`  
  Body: `{ "email": "test@example.com", "password": "123456" }`  
  Response: `{ "message": "User created", "userId": "..." }`

- POST `/api/auth/login`  
  Body: `{ "email": "test@example.com", "password": "123456" }`  
  Response: `{ "token": "JWT_TOKEN", "user": {...} }`

### Users
- GET `/api/users`  
  Header: `Authorization: Bearer <token>`  
  Response: `[ { "_id": "...", "email": "user@example.com" } ]`

### Socket.IO Events
- `connection` → Client connects using JWT
- `chat-message` → `{ from, to, text }` (real-time delivery)
- `disconnect` → Fired when user leaves

---

## Example Users
You can test quickly with:
```
{
  "email": "alice@example.com",
  "password": "123456"
}
{
  "email": "bob@example.com",
  "password": "123456"
}
```

---

## Dependencies

Main dependencies from pubspec.yaml:
- flutter_bloc → State management
- http → REST API requests
- socket_io_client → Real-time communication
- flutter_secure_storage → Secure JWT storage
- device_info_plus → Detect emulator/real device
- shared_preferences → Local storage
- intl → Date formatting

---

## Submission Notes
1. Clone both repos:
    - Frontend: chat_app_fullstack
    - Backend: chat_app_backend
2. Run backend first (npm start on port 4000 with MongoDB running).
3. Run the frontend (flutter run).
4. Signup or login with test accounts, then start chatting.  
