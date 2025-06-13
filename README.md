# Rotterdam Navigation - 3D Route Planner

[![Flutter Version](https://img.shields.io/badge/flutter-%3E%3D3.0.0-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Flutter-based navigation application for Rotterdam, featuring advanced 3D route visualization using CesiumJS. This app enables users to create, manage, and visualize custom routes throughout Rotterdam with an immersive 3D experience.

## Overview

This application is part of a collaborative project between Hogeschool Rotterdam students and VONK/Gemeente Rotterdam. It addresses the need for intuitive route planning and visualization in Rotterdam's urban environment.

### Key Capabilities

- 3D visualization of Rotterdam's urban landscape
- Custom route creation and management
- Location-based services integration
- Offline route storage
- User authentication and data persistence

## Motivation

This project is being developed by students from Hogeschool Rotterdam as part of the intern minor as inter disciplinaire project. This is in collaboration with VONK and Gemeente Rotterdam. Users need a simple way to plan, save, and view custom routes for city trips, specifically within Rotterdam. This project aims to provide a user-friendly mobile solution leveraging 3D map visualization and open data.

## Features

- **Bottom Navigation:** Easy access to core sections (Home, Saved Routes, Create Route, Map, Settings).
- **Route Creation:** Functionality to define custom routes (implementation ongoing).
- **Route Saving:** Ability to persist created routes (implementation ongoing).
- **Route Visualization:** Display routes on a map (currently using CesiumJS 3D view, but 2.5D is also posibilities in the future).
- **Settings:** Basic application settings interface.

## Technical Architecture

### Core Framework & Libraries

- **Flutter SDK**: Cross-platform UI development
- **Dart**: Primary programming language
- **Provider**: State management using MVVM pattern
- **Dio**: HTTP client with interceptors for API communication
- **WebView**: Bridge for Cesium.js integration
- **Secure Storage**: Credentials and token management

### Architecture & State Management

#### MVVM Implementation

The application implements MVVM (Model-View-ViewModel) architecture with Provider for state management:

- **Models**: Data structures and business logic

  ```dart
  class RouteDto {
    final String routeId;
    final String name;
    final List<LocationDto> locations;
  }
  ```

- **ViewModels**: State management and business logic

  ```dart
  class RouteViewModel extends ChangeNotifier {
    final IRouteRepository _repository;
    List<RouteDto> _routes = [];

    Future<void> loadRoutes() async {
      // Update state and notify listeners
    }
  }
  ```

- **Views**: UI components using Provider for state
  ```dart
  class RouteScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Consumer<RouteViewModel>(
        builder: (context, viewModel, _) => ...
      );
    }
  }
  ```

#### Directory Structure

```
lib/
├── core/           # Core functionality & shared code
│   ├── config/     # Environment configuration
│   ├── models/     # Data models & DTOs
│   ├── services/   # API services & external integrations
│   └── utils/      # Shared utilities
└── features/       # Feature modules (MVVM pattern)
    ├── auth/       # Authentication
    ├── map/        # 3D visualization
    └── routes/     # Route management
```

- **Authentication & Security:**

  - Token-based authentication
  - Secure storage for sensitive data
  - Dynamic token resolution for API services

- **Mapping & Navigation:**

  - CesiumJS for 3D visualization
  - Rotterdam-specific 3D terrain and building data
  - OpenStreetMap integration
  - Valhalla routing engine
  - Two-way Flutter-Cesium communication
  - Animated route visualization

- **Backend Integration:**
  - ASP.NET Core backend
  - Primary and fallback API support
  - RESTful API communication

## Development Setup

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- Git for version control
- A physical device or emulator for testing

### Environment Configuration

1. Create a `.env` file in the project root:

   ```env
   API_URL=your_api_url
   CESIUM_TOKEN=your_cesium_token
   ```

2. Configure development environment:

   ```bash
   # Install dependencies
   flutter pub get

   # Run code generation (if needed)
   flutter pub run build_runner build
   ```

**Installation & Running:**

1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd FlutterNavigation # Or your project directory name
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the application:**
    ```bash
    flutter run
    ```

## Project Structure

The project follows MVVM (Model-View-ViewModel) architecture for clean separation of concerns:

- **`lib/core/`**: Core functionality and shared code

  - `config/`: Environment and app configuration
  - `models/`: Data transfer objects (DTOs)
  - `navigation/`: Route management
  - `providers/`: Global state management
  - `repositories/`: Data access abstraction
  - `services/`: API and external service integrations
  - `utils/`: Shared utilities

- **`lib/features/`**: Feature modules following MVVM pattern

  - `auth/`: Authentication screens and viewmodels
  - `create_location/`: Location creation and management
  - `create_route/`: Route creation functionality
  - `home/`: Main application screens
  - `map/`: Map visualization (2D and 3D)
  - `saved_routes/`: Route management and persistence
  - `setting/`: Application settings

- **`lib/main.dart`**: Application entry point with dependency injection setup
- **`assets/`**: Static assets including Cesium.html for 3D visualization
- **`test/`**: Unit and widget tests

## Development Guidelines

### Code Style & Standards

- Follow [Flutter style guide](https://dart.dev/guides/language/effective-dart/style)
- Use clear, descriptive variable and function names
- Document public APIs using Dart documentation comments
- Follow MVVM architecture patterns consistently

### Testing Standards

- Write unit tests for all business logic
- Include widget tests for complex UI components
- Use integration tests for critical user flows
- Maintain test coverage above 80%

### Documentation

- Document complex algorithms and business logic
- Keep API documentation up-to-date
- Include examples in documentation comments
- Document configuration requirements

### Performance & Best Practices

#### State Management

- Use `Provider` for dependency injection and state management
- Implement `ChangeNotifier` for ViewModels
- Use `Consumer` widgets strategically to minimize rebuilds
- Leverage `ProxyProvider` for dependent services

#### Performance Optimization

- Use const constructors where possible
- Implement proper state management
- Optimize asset loading and caching
- Profile and optimize render performance

## Branching Strategy

This project uses Gitflow for version control:

```
main ────────●───────────●─── (Production releases)
              \         /
develop ────●──●─●─●───●───── (Integration branch)
            \   \ \   /
feature/1    ●───●   /        (Feature branches)
               \    /
feature/2       ●──●          (Feature branches)
```

### Branch Types

- **`main`**: Production code only
- **`develop`**: Integration branch
- **`feature/*`**: New features
- **`release/*`**: Release preparation
- **`hotfix/*`**: Production fixes
- **`fix/*`**: Development fixes

## Contributing

1. Fork the repository
2. Create a feature branch from `develop`
3. Follow coding standards and guidelines
4. Write tests for new features
5. Submit a pull request
6. Update documentation as needed

## Acknowledgments

- VONK Rotterdam
- Gemeente Rotterdam
- Hogeschool Rotterdam
