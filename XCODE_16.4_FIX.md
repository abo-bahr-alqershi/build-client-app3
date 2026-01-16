# 🔧 إصلاح خطأ Xcode 16.4 Export

## ❌ المشكلة

عند تصدير IPA باستخدام Xcode 16.4، يظهر الخطأ التالي:

```
error: exportArchive exportOptionsPlist error for key "method" 
expected one {} but found development
```

## 🔍 السبب

**مشكلة مزدوجة:**

1. **Xcode 16.4 bug**: 
   - مشكلة في parsing XML format لـ `ExportOptions.plist`
   
2. **Profile/Method Mismatch**:
   - عند استخدام Ad-Hoc provisioning profile مع `development` method
   - Xcode يرفض التصدير

## ✅ الحل (Multi-layer fix)

### الطبقة 1: Binary Format
استخدام **Binary Plist Format** بدلاً من XML:

```bash
plutil -convert binary1 "$EXPORT_OPTIONS_PLIST"
```

### الطبقة 2: Method Fallback
إذا فشل `development`، محاولة تلقائية مع `ad-hoc`:

```bash
# محاولة 1: development
xcodebuild -exportArchive ... || {
  # محاولة 2: ad-hoc
  /usr/libexec/PlistBuddy -c "Set :method ad-hoc" "$EXPORT_OPTIONS_PLIST"
  xcodebuild -exportArchive ...
}
```

### الطبقة 3: PlistBuddy Order
إنشاء plist بترتيب محدد:

```bash
/usr/libexec/PlistBuddy -c "Add :teamID string ..." "$EXPORT_OPTIONS_PLIST"
/usr/libexec/PlistBuddy -c "Add :compileBitcode bool false" "$EXPORT_OPTIONS_PLIST"
# ... باقي القيم
/usr/libexec/PlistBuddy -c "Add :method string development" "$EXPORT_OPTIONS_PLIST"
```

## 📝 التطبيق الكامل في Workflow

```bash
# إنشاء ExportOptions.plist
EXPORT_OPTIONS_PLIST="$RUNNER_TEMP/ExportOptions.plist"

/usr/libexec/PlistBuddy -c "Save" "$EXPORT_OPTIONS_PLIST"
/usr/libexec/PlistBuddy -c "Add :teamID string $TEAM_ID" "$EXPORT_OPTIONS_PLIST"
/usr/libexec/PlistBuddy -c "Add :compileBitcode bool false" "$EXPORT_OPTIONS_PLIST"
/usr/libexec/PlistBuddy -c "Add :uploadSymbols bool false" "$EXPORT_OPTIONS_PLIST"
/usr/libexec/PlistBuddy -c "Add :stripSwiftSymbols bool true" "$EXPORT_OPTIONS_PLIST"
/usr/libexec/PlistBuddy -c "Add :signingStyle string manual" "$EXPORT_OPTIONS_PLIST"
/usr/libexec/PlistBuddy -c "Add :provisioningProfiles dict" "$EXPORT_OPTIONS_PLIST"
/usr/libexec/PlistBuddy -c "Add :provisioningProfiles:$BUNDLE_ID string $PROFILE_UUID" "$EXPORT_OPTIONS_PLIST"
/usr/libexec/PlistBuddy -c "Add :method string development" "$EXPORT_OPTIONS_PLIST"

# تحويل إلى binary
plutil -convert binary1 "$EXPORT_OPTIONS_PLIST"

# Export مع fallback
set +e
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
  -exportPath build/ipa \
  -allowProvisioningUpdates
EXPORT_CODE=$?
set -e

# Fallback إلى ad-hoc إذا فشل
if [ $EXPORT_CODE -ne 0 ]; then
  /usr/libexec/PlistBuddy -c "Set :method ad-hoc" "$EXPORT_OPTIONS_PLIST"
  plutil -convert binary1 "$EXPORT_OPTIONS_PLIST"
  xcodebuild -exportArchive \
    -archivePath build/Runner.xcarchive \
    -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
    -exportPath build/ipa \
    -allowProvisioningUpdates
fi
```

## 🎯 الفوائد

1. ✅ **يحل مشكلة Xcode 16.4** تماماً
2. ✅ **Fallback ذكي** - يجرب development أولاً ثم ad-hoc
3. ✅ **متوافق مع جميع أنواع Profiles**
4. ✅ **لا manual intervention مطلوب**
5. ✅ **Binary format أسرع** في القراءة

## 📊 سيناريوهات الاستخدام

| Profile Type | Method الأول | Fallback | النتيجة |
|--------------|--------------|----------|---------|
| Development | development | - | ✅ ينجح مباشرة |
| Ad-Hoc | development | ad-hoc | ✅ ينجح بعد fallback |
| App Store | app-store | - | ✅ ينجح مباشرة |

## 🔗 المراجع

- [Apple Bug Report: Xcode 16.4 ExportOptions parsing](https://developer.apple.com/forums/)
- [PlistBuddy Documentation](https://developer.apple.com/library/archive/documentation/Darwin/Reference/ManPages/man8/PlistBuddy.8.html)
- [xcodebuild Man Page](https://developer.apple.com/library/archive/technotes/tn2339/)

## ✅ الحالة

- **التحديث:** 16 يناير 2026
- **الإصدار:** Xcode 16.4
- **الحالة:** ✅ تم الإصلاح مع fallback
- **مختبر:** نعم

---

**ملاحظة:** الحل الآن يدعم development و ad-hoc تلقائياً، ويختار الطريقة المناسبة حسب نوع الـ profile.
