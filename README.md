# budg - The Weekly Budget App

A smart and flexible Flutter app to help you manage your weekly "wants" expenses, encourage saving, and develop better financial habits.

## Features

- 💰 Set and manage a weekly budget for discretionary spending
- 📅 Track expenses for each day of the week
- 🏦 Accumulate unspent money as savings
- 💸 Allow spending from savings for larger purchases
- 🚫 Track and manage debts from overspending
- 📊 Visual representation of budget, savings, and debts
- 🎯 Set and track savings goals
- 📈 Insights and analytics on spending patterns
- 🌓 Light and dark mode support
- 💾 Local data persistence

## Key Concepts

- Weekly Budget: A set amount (e.g., 1.5k SEK) refreshed each week for "wants"
- Savings: Unspent money accumulates over time
- Flexible Spending: Use weekly budget or tap into savings
- Debt Tracking: Overspending creates debt against future weeks
- Long-term Financial Management: Learn to balance immediate wants with saving

## Getting Started

### Prerequisites

- Flutter (Channel stable, 2.x.x)
- Dart SDK version: 2.x.x

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/budg.git
   ```

2. Navigate to the project directory:
   ```
   cd budg
   ```

3. Get the dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Architecture

This app follows a clean architecture pattern and uses the following key packages:

- `flutter_riverpod` for state management
- `shared_preferences` for local data persistence
- `flex_color_scheme` for theming

## Acknowledgments

- [Flutter](https://flutter.dev/) for the amazing framework
- [Riverpod](https://riverpod.dev/) for the efficient state management solution
- [flex_color_scheme](https://pub.dev/packages/flex_color_scheme) for the beautiful theming options

---

Made with ❤️ by Rasmus Lindahl