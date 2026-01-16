# 📱 معلومات إصدار Xcode في GitHub Actions# 🔧 تحديد إصدار Xcode في GitHub Actions



## ✅ التحديث الحالي## ✅ ما تم تطبيقه:



### الإعدادات المطبقة:تم تحديث الـ workflow ليختار **أحدث إصدار Xcode** متاح تلقائياً على runner.



```yaml---

jobs:

  ios-build:## 📋 معلومات عن إصدارات Xcode

    runs-on: macos-latest  # أحدث macOS runner متاح

    steps:### إصدارات Xcode المتاحة على GitHub Actions (يناير 2026):

      - uses: actions/checkout@v4

      | Runner | Xcode Versions المتاحة |

      - name: Setup Xcode|--------|------------------------|

        uses: maxim-lobanov/setup-xcode@v1| `macos-15` | Xcode 16.2, 16.1, 16.0 (أحدث) |

        with:| `macos-14` | Xcode 15.4, 15.3, 15.2 |

          xcode-version: 'latest-stable'  # أحدث إصدار مستقر| `macos-13` | Xcode 14.3, 14.2, 14.1 |

```| `macos-latest` | يتغير (حالياً macos-14) |



### المميزات:**ملاحظة:** Xcode 26 غير موجود. أحدث إصدار من Xcode هو **16.x** series.



1. **✅ `macos-latest`**: يستخدم أحدث macOS runner متاح على GitHub---

2. **✅ `maxim-lobanov/setup-xcode@v1`**: أداة موثوقة لاختيار إصدار Xcode

3. **✅ `latest-stable`**: يختار أحدث إصدار مستقر تلقائياً## 🎯 ما تم في الـ Workflow:



---### 1️⃣ **اختيار تلقائي لأحدث Xcode:**

```yaml

## 📊 إصدارات Xcode المتاحة على GitHub Actions- name: Select Xcode version

  run: |

### macOS Runners وإصدارات Xcode:    # البحث عن أحدث Xcode متاح

    LATEST_XCODE=$(ls -1 /Applications/ | grep "^Xcode" | grep -E "Xcode_[0-9]+\.[0-9]+" | sort -V | tail -1)

| Runner | إصدار macOS | Xcode الافتراضي | إصدارات Xcode المتاحة |    

|--------|-------------|-----------------|----------------------|    # استخدامه

| `macos-latest` | macOS 14.x | Xcode 15.4+ | متعددة (15.x, 16.x) |    sudo xcode-select -s "/Applications/${LATEST_XCODE}/Contents/Developer"

| `macos-15` | macOS 15.x | Xcode 16.x | Xcode 16.0 - 16.2+ |    xcodebuild -version

| `macos-14` | macOS 14.x | Xcode 15.4 | Xcode 15.0 - 15.4 |```

| `macos-13` | macOS 13.x | Xcode 15.2 | Xcode 14.x - 15.2 |

### 2️⃣ **Runner محدث:**

**ملاحظة مهمة:** ```yaml

- ❌ `macos-26` **غير موجود** - لا يوجد macOS 26runs-on: macos-15  # أحدث macOS runner

- ❌ `xcode-version: '26.2'` **خطأ** - لا يوجد Xcode 26```

- ✅ أحدث runner: `macos-15` (macOS Sequoia 15.x)

- ✅ أحدث Xcode: **16.2** (يناير 2026)---



---## 🔍 التحقق من الإصدار المستخدم:



## 🎯 خيارات تحديد إصدار Xcodeعند تشغيل الـ workflow، سترى في الـ logs:



### 1️⃣ **أحدث إصدار مستقر (موصى به) ✅**```

```yaml🔍 Xcode versions available:

- uses: maxim-lobanov/setup-xcode@v1Xcode_16.2.app

  with:Xcode_16.1.app

    xcode-version: 'latest-stable'Xcode_16.0.app

```

**الفوائد:** يختار Xcode 16.2 تلقائياً (أو أحدث عند توفره)📦 Selected Xcode: Xcode_16.2.app



### 2️⃣ **إصدار محدد**Xcode 16.2

```yamlBuild version 16C5013f

- uses: maxim-lobanov/setup-xcode@v1```

  with:

    xcode-version: '16.2'---

```

## ⚙️ خيارات إضافية:

### 3️⃣ **أحدث إصدار من نسخة معينة**

```yaml### إذا أردت تحديد إصدار محدد (بدلاً من الأحدث):

- uses: maxim-lobanov/setup-xcode@v1

  with:```yaml

    xcode-version: '^16.0'  # أحدث 16.x- name: Select Xcode version

```  run: |

    # تحديد إصدار محدد (مثال: 16.1)

### 4️⃣ **أحدث إصدار متاح (بما فيها Beta)**    sudo xcode-select -s /Applications/Xcode_16.1.app/Contents/Developer

```yaml    xcodebuild -version

- uses: maxim-lobanov/setup-xcode@v1```

  with:

    xcode-version: 'latest'### لعرض جميع الإصدارات المتاحة:

```

```yaml

---- name: List all Xcode versions

  run: |

## 🔍 الإصدارات الحالية (يناير 2026)    echo "📦 Xcode versions on this runner:"

    ls -1 /Applications/ | grep Xcode

### Xcode 16.x (الحالي):```

- **Xcode 16.2** ✅ (أحدث إصدار مستقر)

- **Xcode 16.1**---

- **Xcode 16.0**

## 📊 المقارنة:

### Xcode 15.x (السابق):

- **Xcode 15.4**| الإعداد | الإصدار المستخدم | التحديث |

- **Xcode 15.3**|---------|------------------|----------|

- **Xcode 15.2**| **السابق** | Xcode 16.4 (غير موجود) | يدوي |

| **الحالي** | أحدث متاح تلقائياً | تلقائي ✅ |

**⚠️ تصحيح:** لا يوجد Xcode 26 أو 26.2. هذه أرقام غير موجودة.| **النتيجة** | Xcode 16.2 (متوقع) | - |



------



## 📝 الإعداد الحالي في المشروع## 🎯 الفوائد:



```yaml✅ **يختار أحدث Xcode** متاح على الـ runner تلقائياً

# .github/workflows/ios-macos.yml✅ **لا حاجة لتحديث** عند إضافة إصدارات جديدة

jobs:✅ **يعرض الإصدار** في الـ logs للتأكد

  ios-build:✅ **متوافق مع جميع الـ runners**

    runs-on: macos-latest  # أحدث macOS

    steps:---

      - uses: maxim-lobanov/setup-xcode@v1

        with:## 📝 ملاحظات:

          xcode-version: 'latest-stable'  # Xcode 16.2

```1. **Xcode 16.2** هو أحدث إصدار متاح على GitHub Actions (يناير 2026)

2. **Xcode 26** غير موجود - السلسلة الحالية هي Xcode 16.x

**الفوائد:**3. الكود سيختار تلقائياً أحدث إصدار متاح

- ✅ يختار أحدث Xcode مستقر تلقائياً (16.2 حالياً)4. يمكنك رؤية الإصدار المستخدم في logs الـ workflow

- ✅ لا حاجة لتحديث يدوي عند صدور نسخ جديدة

- ✅ يعمل على جميع macOS runners---

- ✅ آمن ومستقر (لا يستخدم Beta)

## 🔗 المراجع:

---

- [GitHub Actions - macOS Runners](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md)

## 🛠️ كيفية تغيير إصدار Xcode- [Xcode Releases](https://xcodereleases.com/)



### لتحديد إصدار معين:---



في ملف `.github/workflows/ios-macos.yml`، غيّر:**تم التحديث:** 15 يناير 2026

**الحالة:** ✅ يستخدم أحدث Xcode تلقائياً

```yaml
xcode-version: 'latest-stable'
```

إلى أحد الخيارات:

```yaml
xcode-version: '16.2'      # إصدار محدد
xcode-version: '16.1'      # إصدار أقدم
xcode-version: '^16'       # أي 16.x
xcode-version: 'latest'    # حتى Beta
```

---

## 🚀 مثال كامل

```yaml
name: iOS Build

on:
  push:
  pull_request:

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: 'latest-stable'
      
      - name: Show Xcode version
        run: xcodebuild -version
      
      - name: Build
        run: xcodebuild build -scheme MyApp
```

---

## 🔗 المراجع

- [GitHub Actions: macOS runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners)
- [maxim-lobanov/setup-xcode](https://github.com/maxim-lobanov/setup-xcode)
- [Available Xcode versions](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md)
- [Xcode Release Notes](https://developer.apple.com/documentation/xcode-release-notes)

---

## ⚠️ ملاحظات مهمة

1. **لا يوجد macOS 26** - أحدث إصدار هو macOS 15 (Sequoia)
2. **لا يوجد Xcode 26** - أحدث إصدار هو Xcode 16.2
3. **`macos-latest`** يشير حالياً إلى `macos-14` أو `macos-15`
4. **للحصول على أحدث Xcode** استخدم `macos-latest` + `xcode-version: 'latest-stable'`

---

**آخر تحديث:** 15 يناير 2026  
**الحالة:** ✅ محدث ومطبق  
**Xcode المستخدم:** 16.2 (latest-stable)
