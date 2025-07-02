# 🔐 Open Prices Credential Setup Guide

## Overview
The `weebi_openfoodfacts_service` package uses **login/password authentication** to access the Open Prices API. This guide shows you exactly where to put your credentials and how to keep them secure.

## 🎯 Quick Setup

### Step 1: Create Credentials File
Copy the example file and rename it:
```bash
# In your project root directory
cp open_prices_credentials.json.example open_prices_credentials.json
```

### Step 2: Edit Your Credentials
Open `open_prices_credentials.json` and replace the placeholders:

```json
{
  "open_prices": {
    "username": "your_actual_username",      ← Put your OpenFoodFacts username here
    "password": "your_actual_password",      ← Put your OpenFoodFacts password here
    "api_url": "https://prices.openfoodfacts.org/api/v1",
    "app_name": "YourAppName/1.0"
  }
}
```

### Step 3: Secure the File
Add this line to your `.gitignore`:
```gitignore
# Keep credentials secure
open_prices_credentials.json
```

## 🔒 Security Best Practices

### For Development
```json
{
  "open_prices": {
    "username": "your_dev_username",
    "password": "your_dev_password",
    "api_url": "https://prices.openfoodfacts.org/api/v1",
    "app_name": "YourApp-Dev/1.0"
  }
}
```

### For Production
Instead of a file, use environment variables:
```dart
// In your production code
final username = Platform.environment['OPEN_PRICES_USERNAME'];
final password = Platform.environment['OPEN_PRICES_PASSWORD'];
```

## 📍 File Location Rules

The service automatically looks for `open_prices_credentials.json` in:

1. **Package Root** (recommended): Next to `pubspec.yaml`
```
your_project/
├── pubspec.yaml
├── open_prices_credentials.json  ← Put it here
└── lib/
```

2. **Test Directory** (for testing): Inside `test/` folder
```
your_project/
├── test/
│   └── open_prices_credentials.json  ← For tests
└── lib/
```

## 🆔 Getting Your Credentials

### Option 1: Existing OpenFoodFacts Account
If you already have an OpenFoodFacts account:
- ✅ Use the **same username and password**
- ✅ Works immediately with Open Prices API

### Option 2: Create New Account
1. Visit https://openfoodfacts.org
2. Click "Sign up" 
3. Create your account
4. Use those credentials in your JSON file

## ⚡ How It Works

### Automatic Login Process
```dart
// The service automatically:
1. Reads your credentials from open_prices_credentials.json
2. Authenticates with Open Prices API using login/password
3. Maintains session for API calls
4. Re-authenticates when session expires
```

### Using in Your Code
```dart
import 'package:weebi_openfoodfacts_service/weebi_openfoodfacts_service.dart';

// Initialize the service (reads credentials automatically)
final service = WeebiOpenFoodFactsClient();

// Pricing features automatically work if credentials are valid
final product = await service.getProduct('3017620422003');
print('Product price: ${product.currentPrice}');
```

## 🚨 Security Warnings

### ❌ NEVER Do This:
```dart
// DON'T hardcode credentials in your code
const username = 'myusername';     // ❌ Visible in source code
const password = 'mypassword';     // ❌ Committed to git
```

### ✅ ALWAYS Do This:
```dart
// ✅ Use credential file (ignored by git)
// ✅ Or environment variables in production
// ✅ Credentials stay out of source code
```

### File Security Checklist:
- ✅ Add `open_prices_credentials.json` to `.gitignore`
- ✅ Never commit the actual credentials file
- ✅ Use different credentials for dev/prod
- ✅ The `.example` file can be safely committed

## 🔍 Troubleshooting

### "No credentials found"
1. Check file exists: `open_prices_credentials.json` 
2. Check file location: same directory as `pubspec.yaml`
3. Check JSON format: valid JSON syntax
4. Check placeholder values: replace `your_openfoodfacts_username`

### "Authentication failed"
1. Verify username/password on https://openfoodfacts.org
2. Check for typos in credentials file
3. Ensure account is active and verified

### "File not found in package"
```dart
// Debug: Check where the service is looking
await CredentialManager.initialize();
print('Has auth: ${CredentialManager.hasOpenPricesAuth}');
```

## 📂 Multiple Projects Setup

### Private Package Approach
For multiple projects using the same credentials:

```
your_development_folder/
├── project_a/
│   ├── pubspec.yaml
│   └── open_prices_credentials.json  ← Same credentials
├── project_b/
│   ├── pubspec.yaml
│   └── open_prices_credentials.json  ← Same credentials
└── shared_credentials.json            ← Master copy
```

### Symlink Approach (Advanced)
```bash
# Create shared credential file
echo '{"open_prices": {...}}' > shared_credentials.json

# Link from each project
ln -s ../shared_credentials.json project_a/open_prices_credentials.json
ln -s ../shared_credentials.json project_b/open_prices_credentials.json
```

---

## 🎉 Ready to Go!

Once you have:
- ✅ Created `open_prices_credentials.json` with your actual username/password
- ✅ Added the file to `.gitignore` 
- ✅ Verified your OpenFoodFacts account works

Your `weebi_openfoodfacts_service` will automatically:
- 🔐 Authenticate with Open Prices API
- 💰 Provide real pricing data
- 📊 Enable price history and statistics
- 🏪 Support store location features

**The credentials stay completely private and never appear in your source code!** 🔒 