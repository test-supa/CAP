#!/bin/bash

# FalconEye FUD Obfuscation Script
# Usage: ./obfuscate-build.sh <target_directory> <new_package_name> <app_name>

TARGET_DIR=$1
NEW_PKG=$2
APP_NAME=$3

if [ -z "$TARGET_DIR" ] || [ -z "$NEW_PKG" ] || [ -z "$APP_NAME" ]; then
    echo "Usage: ./obfuscate-build.sh <target_directory> <new_package_name> <app_name>"
    exit 1
fi

OLD_PKG="com.etechd.l3mon"
OLD_PKG_PATH="com/etechd/l3mon"
NEW_PKG_PATH=$(echo $NEW_PKG | sed 's/\./\//g')

echo "[*] Obfuscating $OLD_PKG to $NEW_PKG..."

# 1. Rename directories
mkdir -p "$TARGET_DIR/smali/$NEW_PKG_PATH"
mv "$TARGET_DIR/smali/$OLD_PKG_PATH"/* "$TARGET_DIR/smali/$NEW_PKG_PATH/"
rmdir -p "$TARGET_DIR/smali/$OLD_PKG_PATH" 2>/dev/null

# 2. Update package references in Smali files
find "$TARGET_DIR/smali" -type f -name "*.smali" -exec sed -i "s|L$OLD_PKG_PATH/|L$NEW_PKG_PATH/|g" {} +
find "$TARGET_DIR/smali" -type f -name "*.smali" -exec sed -i "s|$OLD_PKG|$NEW_PKG|g" {} +

# 3. Update AndroidManifest.xml
sed -i "s|package=\"$OLD_PKG\"|package=\"$NEW_PKG\"|g" "$TARGET_DIR/AndroidManifest.xml"
sed -i "s|android:name=\"$OLD_PKG|android:name=\"$NEW_PKG|g" "$TARGET_DIR/AndroidManifest.xml"

# 4. Update App Name in strings.xml
STRINGS_FILE="$TARGET_DIR/res/values/strings.xml"
if [ -f "$STRINGS_FILE" ]; then
    sed -i "s|<string name=\"app_name\">.*</string>|<string name=\"app_name\">$APP_NAME</string>|g" "$STRINGS_FILE"
fi

# 5. Add random junk classes to confuse signature scanners
for i in {1..10}; do
    RAND_NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 10 | head -n 1)
    cat <<EOF > "$TARGET_DIR/smali/$NEW_PKG_PATH/$RAND_NAME.smali"
.class public L$NEW_PKG_PATH/$RAND_NAME;
.super Ljava/lang/Object;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method
EOF
done

echo "[+] Obfuscation Complete. Ready for build."
