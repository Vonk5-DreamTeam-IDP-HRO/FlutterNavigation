# Flutter Navigation & Route Planner

/We still have to add a license to it/

A Flutter application focused on creating, saving, and visualizing custom routes, featuring an intuitive navigation system. Using 3DTiles for navigation mapping.

## Motivation

This project is being developed by students from Hogeschool Rotterdam as part of the intern minor as inter disciplinaire project. This is in collaboration with VONK and Gemeente Rotterdam. Users need a simple way to plan, save, and view custom routes for city trips, specifically within Rotterdam. This project aims to provide a user-friendly mobile solution leveraging 3D map visualization and open data.

## Features

*   **Bottom Navigation:** Easy access to core sections (Home, Saved Routes, Create Route, Map, Settings).
*   **Route Creation:** Functionality to define custom routes (implementation ongoing).
*   **Route Saving:** Ability to persist created routes (implementation ongoing).
*   **Route Visualization:** Display routes on a map (currently using CesiumJS 3D view, but 2.5D is also posibilities in the future).
*   **Settings:** Basic application settings interface.

## Tech Stack

*   **Framework:** Flutter
*   **Language:** Dart
*   **State Management:** Provider
*   **Mapping (2D):** `flutter_map` (Current)
*   **Mapping (3D):** CesiumJS (via `webview_flutter`, planned/experimental)
*   **Routing Service:** Valhalla
*   **backend:** ASP.NET Core


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

*   `lib/core/`: Contains core functionalities like navigation (`navigation.dart`), providers (`app_state.dart`), and configuration.
*   `lib/features/`: Holds the UI (Screens/Views) and logic (ViewModels) for each major feature area (e.g., `home`, `map`, `create_route`).
*   `lib/main.dart`: Application entry point.
*   `assets/`: Static assets like the `Cesium.html` file.

## Branching Strategy (Gitflow)

This project uses the Gitflow branching model:

*   **`main`**: Production-ready code. Represents released versions.
*   **`develop`**: Main integration branch for ongoing development. Merges into `release` branches.
*   **`feature/name`**: Branched from `develop` for new features. Merged back into `develop`.
*   **`release/version`**: Branched from `develop` for release preparation (bug fixes, docs). Merged into `main` and `develop`.
*   **`hotfix/issue`**: Branched from `main` for urgent production fixes. Merged into `main` and `develop`.
*   **`fix/issue`**: Branched from `develop` for non-critical bug fixes. Merged back into `develop`.
