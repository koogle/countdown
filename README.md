# Countdown App

A simple iOS app to help you keep track of important dates. The app includes both a main interface and a widget to display your countdowns.

## Features

- Create and manage countdowns for important dates
- Star your most important countdown to display in the widget
- View countdowns in different formats:
  - Days remaining
  - Detailed time breakdown (days, hours, minutes)
- Widget support:
  - Small widget showing days remaining
  - Lock Screen widget showing detailed countdown
- Automatic categorization of expired countdowns
- Edit and delete countdowns with swipe actions

## Requirements

- iOS 16.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Setup

1. Clone the repository
2. Open `countdown.xcodeproj` in Xcode
3. Ensure you have the following capabilities enabled:
   - App Groups for both main app and widget extension
   - Widget extension capability

## Architecture

The app is split into three main components:

- **Main App**: Handles the user interface and countdown management
- **CountdownShared**: Framework containing shared models and business logic
- **Widget Extension**: Provides widget functionality for Home Screen and Lock Screen

## Data Sharing

The app uses App Groups to share data between the main app and widget. All countdowns are stored in UserDefaults within the shared app group container.

## License

[Your chosen license] 