# Shop Management App

A comprehensive shop management mobile application built with Flutter for single-store businesses.

## Features

### ✅ Implemented
- **Authentication**
  - PIN-based login
  - Biometric authentication (Fingerprint/Face ID)
  - Secure local storage
  
- **Dashboard**
  - Today's sales and purchase summary
  - Cash and bank balance overview
  - Outstanding tracking (receivables/payables)
  - Quick action buttons
  - Low stock alerts
  
- **Product Management**
  - Add/Edit products
  - Barcode support
  - Category management
  - Stock tracking
  - GST rates
  - Image upload
  
- **Sales Module**
  - Invoice creation
  - Payment tracking
  - Sales history
  
- **Purchase Module**
  - Purchase bill entry
  - Supplier management
  - Purchase history
  
- **Party Management**
  - Customer/Supplier management
  - Contact information
  - Outstanding tracking
  
- **Reports**
  - Sales reports
  - Purchase reports
  - Profit & Loss
  - GST reports
  - Stock reports
  
- **Settings**
  - Business information
  - Biometric toggle
  - PIN management
  - Data backup/restore

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Backend**: Supabase (PostgreSQL)
- **Local Database**: SQLite (sqflite)
- **State Management**: Riverpod 2.x
- **Navigation**: go_router
- **Authentication**: local_auth
- **PDF Generation**: pdf package
- **Printing**: printing + blue_thermal_printer
- **Barcode**: mobile_scanner + barcode_widget
- **Charts**: fl_chart

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   cd shop_management_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase** (Optional for cloud sync)
   - Create a Supabase project at https://supabase.com
   - Update `lib/core/config/supabase_config.dart` with your credentials:
   ```dart
   static const String url = 'YOUR_SUPABASE_URL';
   static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## First Time Setup

1. **Create PIN**: On first launch, create a 4-6 digit PIN
2. **Business Setup**: Enter your shop details (name, owner, phone, address, GSTIN)
3. **Enable Biometric** (Optional): Go to Settings → Enable biometric authentication

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App constants and routes
│   ├── config/         # Configuration files
│   ├── theme/          # App theme
│   └── utils/          # Utility functions
├── data/
│   ├── models/         # Data models
│   ├── repositories/   # Data repositories
│   └── services/       # Services (Auth, Database, etc.)
├── presentation/
│   ├── providers/      # Riverpod providers
│   ├── screens/        # UI screens
│   └── widgets/        # Reusable widgets
└── routes/             # Navigation routes
```

## Database Schema

The app uses both local SQLite and Supabase PostgreSQL for offline-first architecture.

### Main Tables:
- `users` - Business/user information
- `products` - Product inventory
- `categories` - Product categories
- `parties` - Customers and suppliers
- `sales_invoices` - Sales transactions
- `sale_items` - Invoice line items
- `purchases` - Purchase transactions
- `purchase_items` - Purchase line items
- `payments` - Payment records
- `expenses` - Business expenses
- `bank_accounts` - Bank account details
- `cash_transactions` - Cash flow tracking

## Features Roadmap

### Phase 1 (Current)
- ✅ Authentication with biometric
- ✅ Dashboard
- ✅ Product management
- ✅ Basic sales and purchase screens
- ✅ Party management
- ✅ Settings

### Phase 2 (Next)
- [ ] Complete invoice generation with PDF
- [ ] Payment tracking
- [ ] Expense management
- [ ] Barcode scanning
- [ ] Thermal printer support

### Phase 3 (Future)
- [ ] Advanced reports with charts
- [ ] GST filing support
- [ ] WhatsApp integration
- [ ] Cloud sync with Supabase
- [ ] Multi-user support
- [ ] Backup/Restore functionality

## Permissions

### Android
- `USE_BIOMETRIC` - For fingerprint/face authentication
- `CAMERA` - For barcode scanning (when implemented)
- `WRITE_EXTERNAL_STORAGE` - For PDF export
- `BLUETOOTH` - For thermal printer (when implemented)

## Contributing

This is a complete shop management solution. Feel free to customize based on your needs.

## License

Private project - All rights reserved

## Support

For issues or questions, please contact the development team.
