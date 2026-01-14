# 📱 دليل شامل لإعداد Code Signing لتطبيق iOS

## 🎯 المشكلة الحالية

عند استخدام **Automatic Signing** في Codemagic، يتحول Bundle ID من:
```
com.hggzk.app  →  com.hggzk.app.UF3CJWM5AP
```

هذا يسبب مشكلة مع Firebase لأن Bundle ID لا يتطابق.

---

## ✅ الحل الموصى به (الأسهل - بدون Mac)

### فقط قم بالمرحلة 1، ودع Codemagic يتعامل مع الباقي

**المرحلة 1: إنشاء App ID يدويًا في Apple Developer**

1. اذهب إلى: https://developer.apple.com/account
2. قم بتسجيل الدخول بحساب Apple Developer
3. من القائمة الجانبية اختر **"Certificates, IDs & Profiles"**
4. اختر **"Identifiers"**
5. اضغط زر **(+)** الأزرق في الأعلى
6. اختر **"App IDs"** ← اضغط **Continue**
7. اختر **"App"** ← اضغط **Continue**
8. املأ البيانات:
   ```
   Description: hggzk Hotel Booking App
   Bundle ID: Explicit
   Bundle ID Value: com.hggzk.app
   ```
9. في **Capabilities** حدد:
   - ✓ Push Notifications
   - ✓ Sign in with Apple (إذا كنت تستخدمه)
   - ✓ Associated Domains (للـ Deep Links)
10. اضغط **Continue** ثم **Register**

**بعد ذلك:**
- ارجع إلى Codemagic
- ابدأ build جديد
- Codemagic سيستخدم App ID الجديد تلقائيًا
- Bundle ID سيكون `com.hggzk.app` (بدون suffix)

---

## 🔧 الحل المتقدم (Manual Signing - يتطلب Mac)

إذا أردت **تحكم كامل** في Code Signing:

### الملفات المطلوبة:

| الملف | الامتداد | الوصف |
|------|----------|--------|
| **Code Signing Certificate** | `.p12` | شهادة التوقيع من Apple |
| **Provisioning Profile** | `.mobileprovision` | ملف يربط Certificate + App ID + Devices |

---

### المرحلة 1: إنشاء App ID
(نفس الخطوات السابقة)

---

### المرحلة 2: إنشاء Certificate (.p12)

#### أ) إنشاء Certificate Signing Request (CSR) - على Mac

1. افتح تطبيق **Keychain Access** (في مجلد Applications/Utilities)
2. من القائمة العلوية:
   ```
   Keychain Access → Certificate Assistant → 
   Request a Certificate From a Certificate Authority
   ```
3. املأ:
   ```
   User Email Address: بريدك الإلكتروني
   Common Name: اسمك
   CA Email Address: اتركه فارغ
   Request is: Saved to disk
   ```
4. اضغط **Continue**
5. احفظ ملف `CertificateSigningRequest.certSigningRequest`

#### ب) إنشاء Certificate في Apple Developer

1. ارجع إلى https://developer.apple.com/account
2. اختر **"Certificates"**
3. اضغط زر **(+)**
4. اختر نوع:
   - **Apple Distribution** (للنشر على App Store)
   - **Apple Development** (للتطوير والاختبار)
5. اضغط **Continue**
6. ارفع ملف `.certSigningRequest`
7. اضغط **Continue**
8. حمّل ملف `.cer`

#### ج) تحويل .cer إلى .p12 - على Mac

1. افتح ملف `.cer` (سيُضاف تلقائيًا إلى Keychain Access)
2. افتح **Keychain Access**
3. اذهب إلى **My Certificates** من القائمة الجانبية
4. ابحث عن Certificate الجديد (اسمه يبدأ بـ "Apple Distribution" أو "Apple Development")
5. انقر بزر الماوس الأيمن عليه
6. اختر **"Export"**
7. اختر صيغة **"Personal Information Exchange (.p12)"**
8. أدخل اسم للملف مثل: `hggzk_distribution.p12`
9. اضغط **Save**
10. أدخل **password قوي** (احفظه - ستحتاجه في Codemagic)
11. أدخل password حساب Mac
12. احفظ الملف

---

### المرحلة 3: إنشاء Provisioning Profile (.mobileprovision)

1. ارجع إلى https://developer.apple.com/account
2. اختر **"Profiles"**
3. اضغط زر **(+)**
4. اختر نوع:
   ```
   للنشر على App Store: "App Store"
   للتطوير: "iOS App Development"
   للتوزيع المباشر: "Ad Hoc"
   ```
5. اضغط **Continue**
6. اختر **App ID**: `com.hggzk.app` (الذي أنشأته)
7. اضغط **Continue**
8. اختر **Certificate** (الذي أنشأته في المرحلة 2)
9. اضغط **Continue**
10. (للـ Development/Ad Hoc فقط) اختر الأجهزة
11. اضغط **Continue**
12. أدخل اسم: `hggzk App Store Profile`
13. اضغط **Generate**
14. حمّل ملف `.mobileprovision`

---

### المرحلة 4: رفع الملفات إلى Codemagic

1. اذهب إلى **Codemagic Dashboard**
2. اختر التطبيق
3. اذهب إلى **Settings** → **Code signing identities**
4. في قسم **iOS**:

   **A. رفع Certificate:**
   ```
   - اضغط "Add certificate"
   - ارفع ملف .p12
   - أدخل password (الذي أدخلته عند التصدير)
   - اضغط Save
   ```

   **B. رفع Provisioning Profile:**
   ```
   - اضغط "Add profile"
   - ارفع ملف .mobileprovision
   - اضغط Save
   ```

5. عدّل `codemagic.yaml`:
   ```yaml
   workflows:
     ios-release:
       environment:
         ios_signing:
           distribution_type: app_store
           bundle_identifier: com.hggzk.app
   ```

6. ابدأ **build جديد**

---

## ❓ أسئلة شائعة

### هل أحتاج Mac؟
- **للحل الأسهل**: لا (فقط أنشئ App ID يدويًا)
- **للحل المتقدم**: نعم (لتحويل .cer إلى .p12)

### ما هو الفرق بين Automatic و Manual Signing؟

| Automatic Signing | Manual Signing |
|-------------------|----------------|
| Codemagic يُنشئ Certificate تلقائيًا | أنت تنشئ Certificate |
| قد يضيف suffix للـ Bundle ID | Bundle ID ثابت |
| سهل وسريع | تحكم كامل |
| مناسب للتطوير | مناسب للإنتاج |

### هل ستحل المشكلة؟
**نعم**، لأن:
- ✅ Bundle ID سيكون `com.hggzk.app` (ثابت)
- ✅ Firebase سيعمل بشكل صحيح
- ✅ تحكم كامل في التوقيع

### ماذا لو لم يكن لدي Mac؟
استخدم **الحل الأسهل** (المرحلة 1 فقط) + Automatic Signing

### كيف أتحقق من نجاح الحل؟
بعد البناء، افحص:
```json
"bundleInfo": {
  "CFBundleIdentifier": "com.hggzk.app"  // ← يجب أن يكون بدون .UF3CJWM5AP
}
```

---

## 🎯 الخلاصة

### الحل المستحسن:
1. أنشئ **App ID يدويًا** في Apple Developer (المرحلة 1)
2. دع **Codemagic يتعامل** مع باقي Signing تلقائيًا
3. ابدأ **build جديد**

### إذا أردت تحكم كامل:
- اتبع جميع المراحل (1-4)
- يتطلب **Mac** لتحويل Certificate إلى .p12
- رفع الملفات يدويًا إلى Codemagic

---

## 📚 روابط مفيدة

- Apple Developer Portal: https://developer.apple.com/account
- Codemagic Docs: https://docs.codemagic.io/yaml-code-signing/signing-ios/
- Fastlane Match (بديل): https://docs.fastlane.tools/actions/match/
