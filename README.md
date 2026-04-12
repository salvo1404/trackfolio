# Trackfolio 📊

A comprehensive portfolio tracking application for managing stocks, crypto, real estate, watches, cash, and retirement funds.

## 🌐 Live Demo

Visit the live application: **[https://salvo1404.github.io/trackfolio/](https://salvo1404.github.io/trackfolio/)**

## ✨ Features

- **Multi-Asset Support**: Track 6 different asset types (Shares, Crypto, Real Estate, Watches, Cash, Retirement Funds)
- **Multi-Currency**: Support for 13 major currencies (USD, EUR, GBP, JPY, CNY, INR, AUD, CAD, CHF, BRL, ZAR, MXN, AED)
- **Real-Time Stock Prices**: Integration with Alpha Vantage API for live stock data
- **Beautiful UI**: Modern, responsive design with gradient backgrounds
- **Cross-Platform**: Works on Web, iOS, and Android

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (^3.11.4)
- Dart SDK

### Installation

```bash
# Clone the repository
git clone https://github.com/salvo1404/trackfolio.git
cd trackfolio

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome
```

## 📦 Deployment

This app is automatically deployed to GitHub Pages via GitHub Actions.

### How it works:

1. Push to the `main` branch
2. GitHub Actions automatically builds the Flutter web app
3. Deploys to GitHub Pages at https://salvo1404.github.io/trackfolio/

### Manual Deployment

To deploy manually:

```bash
# Build for web
flutter build web --release --base-href /trackfolio/

# The built files will be in build/web/
```

## 🛠️ Technology Stack

- **Flutter**: Cross-platform UI framework
- **Provider**: State management
- **FL Chart**: Data visualization
- **SharedPreferences**: Local storage
- **Alpha Vantage API**: Stock price data

## 📝 License

MIT License

## 🙏 Acknowledgments

- Alpha Vantage for stock market data API
- Flutter team for the amazing framework
