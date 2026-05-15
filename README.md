# 📱 Smart OCR Scanner

A high-performance, premium Flutter application designed to extract sensitive information from **Credit/Debit Cards** and **Bank Passbooks** with extreme accuracy. Built using **Clean Architecture** and **BLoC**, it leverages Google ML Kit for text recognition while maintaining strict privacy through manual parsing algorithms.

---

## ✨ Key Features

### 💳 Card Scanner
- **Automatic Extraction**: Captures Card Number, Expiry Date, and Card Holder Name.
- **Smart Validation**: Implements a manual **Luhn Algorithm** to ensure extracted card numbers are valid before displaying.
- **Robust Parsing**: Uses a sliding-window algorithm to find valid card numbers even in noisy text or across multiple lines.
- **Privacy First**: Automatically masks card numbers in the UI (e.g., `XXXX XXXX XXXX 1234`).

### 🏦 Passbook Scanner
- **Flexible Input**: Support for both real-time camera scanning and gallery uploads.
- **Detail Extraction**: Identifies Account Holder Name, Account Number, and IFSC Codes.
- **Pattern Matching**: Detects complex bank-specific patterns (like IFSC) and cleans noisy document text.

---

## 🛠️ Technical Stack

- **Framework**: Flutter (Dart)
- **State Management**: [BLoC](https://pub.dev/packages/flutter_bloc) (Business Logic Component)
- **OCR Engine**: [Google ML Kit Text Recognition](https://pub.dev/packages/google_mlkit_text_recognition)
- **UI Architecture**: Clean Architecture (Feature-driven)
- **Design System**: Premium Dark Theme with [Google Fonts (Outfit)](https://pub.dev/packages/google_fonts)

---

## 🧩 Core Algorithms (Mandatory)

This project strictly adheres to the requirement of **Manual Parsing Logic**. No third-party libraries are used for data parsing.

### 1. Robust Card Parser (`CardParser`)
- **Sliding Window Luhn**: Instead of simple regex, the parser extracts all digits and uses a sliding window (lengths 13-19) to find the first sequence that passes the Luhn check.
- **Keyword-Aware Expiry**: Searches for date patterns near keywords like `EXP`, `VAL`, `THRU` to increase accuracy.
- **Format Normalization**: Standardizes dates (e.g., `12-25` or `12 / 25` -> `12/25`).

### 2. Passbook Parser (`PassbookParser`)
- **Heuristic Name Detection**: Uses uppercase pattern matching and keyword proximity to identify account holders among bank noise.
- **IFSC Regex**: Implements strict 11-character alphanumeric validation for Indian bank branches.

### 3. Luhn Algorithm (`LuhnValidator`)
- **Manual Implementation**: A pure Dart implementation of the Luhn checksum algorithm used for real-time validation of card digits.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (`^3.0.0`)
- Android Studio / VS Code
- A physical device (recommended for camera features)

### Installation
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Run the application**
   ```bash
   flutter run
   ```

### Running Tests
We maintain high reliability for our core algorithms with dedicated unit tests.
```bash
flutter test test/algorithm_test.dart
```

---

## 🛡️ Assumptions & Constraints
- **Offline Only**: The app works entirely on-device. No backend services or cloud APIs are used for parsing.
- **IFSC Format**: Assumes the standard Indian IFSC format (`ABCD0123456`).
- **Card Formats**: Supports Visa, Mastercard, and Amex (13-19 digits).

## 🚧 Edge Cases Handled
- **OCR Misreads**: Automatically corrects `O` to `0` and `I/l` to `1` in numeric fields.
- **Tilted/Partial Scans**: Sliding window handles numbers even if they appear fragmented in the raw OCR output.
- **Multiple Numbers**: Prioritizes valid card numbers over other numeric data (like phone numbers) found on the card.

---

## 👨‍💻 Author
**Dalsukh Solanki**
- Flutter Developer specializing in high-performance agentic applications.
