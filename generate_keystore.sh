#!/bin/bash

# FixFlow Production Keystore Generator
# This script generates an Android keystore for production signing

echo \"================================================\"
echo \"  FixFlow - Production Keystore Generator      \"
echo \"================================================\"
echo \"\"

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo \"❌ Error: keytool not found. Install Java SDK first.\"
    exit 1
fi

# Create .keystore directory if it doesn't exist
KEYSTORE_DIR=\"$HOME/.fixflow_keys\"
mkdir -p \"$KEYSTORE_DIR\"

KEYSTORE_FILE=\"$KEYSTORE_DIR/fixflow_prod.jks\"
VALIDITY_DAYS=10950  # 30 years

echo \"Keystore will be created at: $KEYSTORE_FILE\"
echo \"\"
echo \"Enter the following information:\"
echo \"\"

# Generate keystore
keytool -genkey -v -keystore \"$KEYSTORE_FILE\" \\
  -keyalg RSA -keysize 2048 -validity $VALIDITY_DAYS \\
  -alias fixflow_app_release

if [ $? -eq 0 ]; then
    echo \"\"
    echo \"✅ Keystore created successfully!\"
    echo \"\"
    echo \"Next steps:\"
    echo \"1. Copy your password (you'll need it later)\"
    echo \"2. Set environment variables:\"
    echo \"\"
    echo \"   export KEYSTORE_PATH=\\\"$KEYSTORE_FILE\\\"\"
    echo \"   export KEYSTORE_PASSWORD=\\\"your_password_here\\\"\"
    echo \"   export KEY_ALIAS=\\\"fixflow_app_release\\\"\"
    echo \"   export KEY_PASSWORD=\\\"your_password_here\\\"\"
    echo \"\"
    echo \"3. Add to ~/.zshrc or ~/.bash_profile to persist\"
    echo \"\"
    echo \"4. Build release APK:\"
    echo \"   flutter build apk --release\"
    echo \"\"
    echo \"5. Build app bundle for Play Store:\"
    echo \"   flutter build appbundle --release\"
    echo \"\"
else
    echo \"❌ Failed to create keystore\"
    exit 1
fi
