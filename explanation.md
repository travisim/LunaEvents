# Luna Events Application Documentation

This document provides a comprehensive explanation of the Luna Events application, detailing its architecture, backend functionality, frontend structure, and data management processes.

## 1. System Overview

Luna Events is a mobile application designed to help users discover events and connect with friends. It leverages a Supabase backend for data storage, authentication, and serverless functions, and a SwiftUI-based iOS application for the user interface. The core of the application is a recommendation engine that suggests events to users based on their preferences and the events' content.

## 2. Backend (Supabase)

The backend is built entirely on Supabase, utilizing its various features to create a robust and scalable platform.

### 2.1. Database

The Supabase Postgres database stores all the application's data. The key tables include:

-   **`profiles`**: Stores user profile information, including their username, preferred event types, and a vector embedding representing their interests.
-   **`luma_events`**: Stores event information, including the event's name, description, date, and a vector embedding of its content.
-   **`connections`**: Manages the relationships between users, storing friend requests and accepted connections.

### 2.2. Edge Functions

The application's core logic is implemented as a set of serverless Edge Functions written in TypeScript.

-   **`get-recommended-events`**: This is the heart of the recommendation engine. It takes a user's ID, retrieves their profile embedding, and then uses a vector similarity search (via the `match_events` database function) to find and return a list of recommended events. This allows for personalized event suggestions.

-   **`generate-event-embedding`**: This function is triggered whenever a new event is added to the `luma_events` table. It uses the Google Generative AI `embedding-001` model to create a vector embedding from the event's title and description. This embedding is then stored in the `luma_events` table, allowing it to be used in similarity searches.

-   **`generate-profile-embedding`**: This function is triggered when a user updates their `preferred_event_types` in their profile. It concatenates the user's preferred event types into a single string and uses the same `embedding-001` model to generate a vector embedding. This embedding represents the user's interests and is stored in their profile.

-   **`get-friends`**: This function retrieves a list of a user's friends. It queries the `connections` table for all "accepted" connections where the user is either the requester or the addressee.

-   **`get-connection-requests`**: This function fetches all pending friend requests for a given user, allowing them to accept or reject new connections.

-   **`get-midpoint`**: This function calculates the geographical midpoint between two users based on their last known latitude and longitude. This feature can be used to suggest convenient meeting locations for friends.

### 2.3. Authentication

User authentication is handled by Supabase Auth, which provides a secure and easy-to-use system for managing user sign-up, sign-in, and session management.

## 3. Frontend (iOS Application)

The frontend is a native iOS application built with SwiftUI, following the Model-View-ViewModel (MVVM) design pattern.

### 3.1. Views

-   **`ContentView`**: This is the root view of the application. It acts as a router, displaying either the `LoginView` or the `MainView` depending on the user's authentication state.

-   **`LoginView` / `SignupView`**: These views handle the user authentication process, allowing users to sign in or create a new account.

-   **`MainView`**: This is the main interface of the app, featuring a `TabView` with four tabs:
    -   **`HomeView`**: The application's dashboard. It displays a summary of the user's activity, including stats on their friends and connection requests, a list of incoming requests, a preview of their recent friends, and a list of upcoming events.
    -   **`FriendsView`**: This view displays a list of the user's friends and allows them to manage their connections.
    -   **`EventsView`**: This view shows a list of recommended events, powered by the `get-recommended-events` backend function.
    -   **`SettingsView`**: This view allows users to manage their account settings and preferences.

### 3.2. ViewModels

-   **`AuthViewModel`**: Manages the user's authentication state and handles all authentication-related logic.
-   **`FriendsViewModel`**: Manages the user's friends, connection requests, and all related interactions.
-   **`EventsViewModel`**: Fetches and manages the list of recommended events.
-   **`NavigationViewModel`**: Manages the navigation state and flow within the application.
-   **`ProfileViewModel`**: Manages the user's profile data.

### 3.3. Services

-   **`SupabaseManager`**: A singleton that provides a centralized and convenient way to access the Supabase client throughout the application.
-   **`SupabaseAuth`**: A dedicated service that handles all user authentication operations with Supabase.
-   **`PermissionsManager`**: A singleton that manages user permissions for features like location services and notifications.

## 4. Data Scraping

The `seleniumScrap` directory contains a set of Python scripts that are used to populate the `luma_events` table.

-   **`scraper.py`**: This script uses the Selenium library to scrape event data from the Luma website.
-   **`uploader.py`**: This script takes the scraped data and uploads it to the Supabase database.

This automated process ensures that the application always has a fresh and up-to-date list of events to recommend to users.


## 5. View Hierarchy and Data Flow

This section provides a more detailed look at the frontend architecture, including the view hierarchy, data flow, and an explanation of key SwiftUI syntax.

### 5.1. View Hierarchy Diagram

The following diagram illustrates the navigation flow and the relationship between the different views in the application:

```
ContentView
├── if authState == .Signin
│   └── MainView
│       └── TabView
│           ├── HomeView
│           ├── FriendsView
│           ├── EventsView
│           └── SettingsView
└── if authState == .Signout
    └── LoginView
        └── NavigationStack
            └── SignupView
```

### 5.2. Explanation of View Hierarchy and Data Flow

The application's UI is built using SwiftUI, which employs a declarative approach to building user interfaces. The view hierarchy is a tree-like structure that represents the relationships between different views.

**1. View Hierarchy**

The root of the application is the `ContentView`, which acts as a router based on the user's authentication state.

-   If the user is signed in (`authState == .Signin`), the `MainView` is displayed.
-   `MainView` contains a `TabView` that allows the user to switch between four main sections of the app: `HomeView`, `FriendsView`, `EventsView`, and `SettingsView`.
-   If the user is signed out (`authState == .Signout`), the `LoginView` is displayed.
-   `LoginView` is wrapped in a `NavigationStack`, which manages a navigation hierarchy. From the `LoginView`, the user can navigate to the `SignupView`.

**2. Data Flow and State Management**

SwiftUI uses a powerful state management system to keep the UI in sync with the application's data. In this application, the **MVVM (Model-View-ViewModel)** design pattern is used, and data is passed between views primarily through **Environment Objects**.

-   **`@main` App Struct (`LunaEvents_appApp`)**: This is the entry point of the application. It creates instances of the primary view models (`AuthViewModel`, `NavigationViewModel`, `FriendsViewModel`, `EventsViewModel`) and injects them into the view hierarchy as environment objects using the `.environmentObject()` modifier.

    ```swift
    // In LunaEvents_appApp.swift
    WindowGroup {
        ContentView()
            .environmentObject(authViewModel)
            .environmentObject(navigationViewModel)
            // ... and so on
    }
    ```

-   **`@EnvironmentObject`**: This property wrapper allows any view in the hierarchy to access the shared view model instances. For example, in `ContentView`, the `authViewModel` is accessed like this:

    ```swift
    // In ContentView.swift
    @EnvironmentObject private var authViewModel : AuthViewModel
    ```

    When a property in an `ObservableObject` (like our view models) marked with `@Published` changes, any view that depends on it will automatically be re-rendered to reflect the change. This is the core of SwiftUI's reactive nature.

-   **`@StateObject`**: This property wrapper is used to create and manage the lifecycle of an `ObservableObject` within a view. In `LunaEvents_appApp`, it ensures that the view models are created once and persist for the lifetime of the app.

-   **`@State`**: This is used for simple, view-specific state that doesn't need to be shared with other views (e.g., the text in a `TextField`).

### 5.3. Explanation of Syntax

Here are explanations for some of the more advanced or specific syntax used in the project:

-   **`@main`**: This attribute identifies the entry point of the application. It tells the system that the `LunaEvents_appApp` struct contains the top-level logic for the app.

-   **`some View`**: This is an opaque return type. It means the function or property will return *some* concrete type that conforms to the `View` protocol, but the specific type is hidden from the caller. This is a key feature of SwiftUI that allows for more flexible and efficient view composition.

-   **`NavigationStack(path: $navigationVM.authPath)`**: This creates a navigation stack that is programmatically controlled by the `authPath` property in the `NavigationViewModel`. The `$` prefix creates a `Binding`, which means that any changes to the `authPath` array will be reflected in the navigation stack, and vice-versa.

-   **`.task { ... }`**: This modifier attaches an asynchronous task to the lifetime of a view. The task is automatically started when the view appears and cancelled when the view disappears. This is the modern and recommended way to perform asynchronous operations (like network requests) in SwiftUI.

    ```swift
    // In ContentView.swift
    .task {
        await authViewModel.isUserSignIn()
    }
    ```

-   **`Button(action: { Task { ... } }, label: { ... })`**: This is a common pattern for performing an asynchronous action when a button is tapped. The `Task { ... }` creates a new asynchronous context where you can call `async` functions.

-   **`.environmentObject(_:)`**: As explained above, this modifier injects an `ObservableObject` into the SwiftUI environment, making it accessible to any child view. This is a form of dependency injection.
