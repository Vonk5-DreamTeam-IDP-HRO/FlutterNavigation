# Flutter Navigation & Route Planner

[//]: # "TODO: Add appropriate license"

A Flutter application focused on creating, saving, and visualizing custom routes in Rotterdam, featuring an intuitive navigation system with advanced 3D visualization capabilities using CesiumJS.

## Motivation

This project is being developed by students from Hogeschool Rotterdam as part of the intern minor as inter disciplinaire project. This is in collaboration with VONK and Gemeente Rotterdam. Users need a simple way to plan, save, and view custom routes for city trips, specifically within Rotterdam. This project aims to provide a user-friendly mobile solution leveraging 3D map visualization and open data.

## Features

*   **Bottom Navigation:** Easy access to core sections (Home, Saved Routes, Create Route, Map, Settings).
*   **Route Creation:** Functionality to define custom routes (implementation ongoing).
*   **Route Saving:** Ability to persist created routes (implementation ongoing).
*   **Route Visualization:** Display routes on a map (currently using CesiumJS 3D view, but 2.5D is also posibilities in the future).
*   **Settings:** Basic application settings interface.

## Tech Stack

*   **Core Framework:**
    * Flutter (cross-platform development)
    * Dart programming language
    * Provider pattern for state management with `ChangeNotifier`
    * Dio for HTTP client communications

*   **Authentication & Security:**
    * Token-based authentication
    * Secure storage for sensitive data
    * Dynamic token resolution for API services

*   **Mapping & Navigation:**
    * CesiumJS for 3D visualization
    * Rotterdam-specific 3D terrain and building data
    * OpenStreetMap integration
    * Valhalla routing engine
    * Two-way Flutter-Cesium communication
    * Animated route visualization

*   **Backend Integration:**
    * ASP.NET Core backend
    * Primary and fallback API support
    * RESTful API communication


## Getting Started

**Prerequisites:**

*   Flutter SDK installed (check Flutter documentation for setup).
*   An IDE like VS Code or Android Studio.
*   Emulator or physical device for running the app.

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

*   **`lib/core/`**: Core functionality and shared code
    * `config/`: Environment and app configuration
    * `models/`: Data transfer objects (DTOs)
    * `navigation/`: Route management
    * `providers/`: Global state management
    * `repositories/`: Data access abstraction
    * `services/`: API and external service integrations
    * `utils/`: Shared utilities

*   **`lib/features/`**: Feature modules following MVVM pattern
    * `auth/`: Authentication screens and viewmodels
    * `create_location/`: Location creation and management
    * `create_route/`: Route creation functionality
    * `home/`: Main application screens
    * `map/`: Map visualization (2D and 3D)
    * `saved_routes/`: Route management and persistence
    * `setting/`: Application settings

*   **`lib/main.dart`**: Application entry point with dependency injection setup
*   **`assets/`**: Static assets including Cesium.html for 3D visualization
*   **`test/`**: Unit and widget tests

## Branching Strategy (Gitflow)

This project uses the Gitflow branching model:

*   **`main`**: Production-ready code. Represents released versions.
*   **`develop`**: Main integration branch for ongoing development. Merges into `release` branches.
*   **`feature/name`**: Branched from `develop` for new features. Merged back into `develop`.
*   **`release/version`**: Branched from `develop` for release preparation (bug fixes, docs). Merged into `main` and `develop`.
*   **`hotfix/issue`**: Branched from `main` for urgent production fixes. Merged into `main` and `develop`.
*   **`fix/issue`**: Branched from `develop` for non-critical bug fixes. Merged back into `develop`.
