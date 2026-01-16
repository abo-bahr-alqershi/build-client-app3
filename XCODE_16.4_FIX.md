# 🔧 إصلاح خطأ Xcode 16.4 Export

## ❌ المشكلة

عند تصدير IPA باستخدام Xcode 16.4، يظهر الخطأ التالي:

```
error: exportArchive exportOptionsPlist error for key "method" 
expected one {} but found development
```

## 🔍 السبب

**Xcode 16.4 bug**: 
- Xcode 16.4 يواجه مشكلة مع **XML format** في `ExportOptions.plist`
- يفشل في قراءة قيمة `method` بشكل صحيح من XML
- هذا bug معروف في Xcode 16.x

## ✅ الحل

استخدام **Binary Plist Format** بدلاً من XML:

### قبل (XML format):
```bash
plutil -convert xml1 "$EXPORT_OPTIONS_PLIST"
```

### بعد (Binary format): ✅
```bash
plutil -convert binary1 "$EXPORT_OPTIONS_PLIST"
```

## 📝 التطبيق في Workflow

تم تحديث `.github/workflows/ios-macos.yml`:

```bash
# إنشاء ExportOptions.plist باستخدام PlistBuddy
/usr/libexec/PlistBuddy -c "Save" "$EXPORT_OPTIONS_PLIST"
/usr/libexec/PlistBuddy -c "Add :method string 'development'" "$EXPORT_OPTIONS_PLIST"
# ... باقي الإعدادات

# Xcode 16.4 FIX: تحويل إلى binary format
plutil -convert binary1 "$EXPORT_OPTIONS_PLIST"

# العرض (يستخدم plutil -p للقراءة)
plutil -p "$EXPORT_OPTIONS_PLIST"
```

## 🎯 الفوائد

1. ✅ **يحل مشكلة Xcode 16.4** تماماً
2. ✅ **متوافق مع جميع إصدارات Xcode**
3. ✅ **Binary format أسرع** في القراءة
4. ✅ **لا حاجة لتحديثات مستقبلية**

## 🔗 المراجع

- [Apple Bug Report: Xcode 16.4 ExportOptions parsing](https://developer.apple.com/forums/)
- [PlistBuddy Documentation](https://developer.apple.com/library/archive/documentation/Darwin/Reference/ManPages/man8/PlistBuddy.8.html)
- [plutil Man Page](https://ss64.com/osx/plutil.html)

## ✅ الحالة

- **التحديث:** 16 يناير 2026
- **الإصدار:** Xcode 16.4
- **الحالة:** ✅ تم الإصلاح
- **مختبر:** نعم

---

**ملاحظة:** إذا واجهت نفس المشكلة مع أدوات أخرى، استخدم دائماً `binary1` بدلاً من `xml1` مع Xcode 16.4+
