# Stock API Setup Instructions

This application uses **Alpha Vantage** to fetch real-time stock prices for share assets.

## Getting Your Free API Key

1. Visit [Alpha Vantage](https://www.alphavantage.co/support/#api-key)
2. Fill out the form to get your free API key
3. Copy the API key provided

## Configuring the API Key

1. Open the file: `lib/services/stock_api_service.dart`
2. Find this line near the top of the file:
   ```dart
   static const String _apiKey = 'FXHX7WL780IL2WWG'; // Replace with your actual API key
   ```
3. Replace with your actual API key if needed

## Supported Symbols

Alpha Vantage supports:
- **US Stocks**: AAPL, MSFT, GOOGL, TSLA, etc.
- **ETFs**: SPY, QQQ, VTI, etc.
- **International Stocks**: Many symbols with proper formatting
- **Mutual Funds**: Various mutual fund symbols

## API Limitations

**Alpha Vantage (free tier)**:
- **25 requests per day**
- **5 API requests per minute**

If you exceed these limits, the stock lookup feature will temporarily stop working until the limit resets.

## Usage Tips

- The API is only called when you type **3 or more characters** in the stock symbol field
- This helps conserve your API quota
- Most stock symbols are 3-5 characters, so this works well in practice

## Alternative: Using Environment Variables (Recommended for Production)

For better security, you can store the API key as an environment variable:

1. Create a `.env` file in the project root (add it to `.gitignore`):
   ```
   ALPHA_VANTAGE_API_KEY=your_api_key_here
   ```

2. Install the `flutter_dotenv` package:
   ```bash
   flutter pub add flutter_dotenv
   ```

3. Update `stock_api_service.dart` to read from environment:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';

   static String get _apiKey => dotenv.env['ALPHA_VANTAGE_API_KEY'] ?? 'demo';
   ```

## Testing

The 'demo' API key will work for testing with limited functionality. Try entering stock symbols like:
- AAPL (Apple)
- MSFT (Microsoft)
- GOOGL (Google)
- TSLA (Tesla)

**Note:** The demo key has very limited functionality and is meant only for testing the integration.
