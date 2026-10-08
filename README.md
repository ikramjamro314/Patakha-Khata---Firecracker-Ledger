# Patakha Khata 🎇

**Patakha Khata** is a Flutter based billing app built for a wholesale firecracker business. It replaces paper based billing with a simple digital workflow for creating bills, managing different prices, tracking customer balances, and finding previous orders.

The app is designed for real day to day use by shop employees, including situations where an internet connection is not available.

## Why It Was Built

The business was managing sales and customer balances manually using paper bills. This made it harder to calculate prices, keep track of balances, and find previous transactions.

Patakha Khata was built to make that process faster and more reliable without making the workflow complicated for employees.

## Features

* Create bills quickly by selecting products
* Support for wholesale, retail, and sale prices
* Automatic balance tracking
* Searchable order history
* Share bills through WhatsApp
* Offline first data storage
* Product data synchronization through Firebase
* Simple interface designed for daily shop use

## Business Impact

The app is actively used by **4 to 5 shop employees** and has replaced the previous paper based billing process.

It helps the business:

* Reduce manual calculations
* Keep sales records organized
* Find previous orders quickly
* Track customer balances more easily
* Continue working without a constant internet connection
* Share bills with customers digitally

## Tech Stack

* **Flutter** for the mobile application
* **Dart** for application development
* **SQLite** for offline local storage
* **Firebase** for initial product data synchronization
* **Provider** for state management
* **Clean Architecture** for project structure

## Architecture

The project follows a Clean Architecture approach to keep business logic separated from the UI and data layer.

```text
lib/
├── core/
├── data/
├── domain/
├── presentation/
└── main.dart
```

The application uses SQLite as its primary local data source so that core billing operations remain available even when the device is offline.

## Screens

*Add screenshots here to showcase the main billing, product selection, order history, and balance tracking screens.*

## Getting Started

### Prerequisites

Make sure you have:

* Flutter SDK installed
* Dart SDK
* Android Studio or another Flutter compatible IDE

### Installation

Clone the repository:

```bash
git clone <repository-url>
cd patakha-khata
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Project Status

Patakha Khata is currently being used in a real business environment and continues to be improved based on day to day usage and business requirements.

## Author

**Ikram Jamro**

Built with Flutter to solve a real business problem and turn a manual paper based workflow into a practical digital system.
