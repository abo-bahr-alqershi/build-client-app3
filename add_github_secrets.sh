#!/bin/bash

# 🔐 سكريبت إضافة Secrets إلى GitHub Repository
# يتطلب GitHub CLI (gh) مثبتاً ومصادق عليه

set -e

echo "================================================"
echo "🔐 إضافة App Store Connect API Secrets"
echo "================================================"
echo ""

# التحقق من وجود gh CLI
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) غير مثبت"
    echo "📥 لتثبيته:"
    echo "   brew install gh     # على macOS"
    echo "   أو قم بزيارة: https://cli.github.com/"
    exit 1
fi

# التحقق من المصادقة
if ! gh auth status &> /dev/null; then
    echo "❌ لم تتم المصادقة على GitHub CLI"
    echo "🔑 قم بتنفيذ: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI مصادق عليه"
echo ""

# المسار الحالي
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# الملفات والقيم
API_KEY_FILE="cer_ios/AuthKey_49B2H4YJHU (1).p8"
API_KEY_ID="49B2H4YJHU"
API_ISSUER_ID="0a92da91-c697-4b47-ab81-4ff8185080fa"

# التحقق من وجود ملف API Key
if [ ! -f "$API_KEY_FILE" ]; then
    echo "❌ ملف API Key غير موجود: $API_KEY_FILE"
    exit 1
fi

echo "📁 الملفات:"
echo "   API Key: $API_KEY_FILE ✅"
echo "   Key ID: $API_KEY_ID"
echo "   Issuer ID: $API_ISSUER_ID"
echo ""

# تحويل API Key إلى base64
echo "🔄 تحويل API Key إلى base64..."
API_KEY_BASE64=$(base64 -w 0 "$API_KEY_FILE")
echo "✅ تم التحويل"
echo ""

# إضافة Secrets
echo "📤 إضافة Secrets إلى GitHub Repository..."
echo ""

echo "1️⃣ إضافة APPSTORE_API_KEY_BASE64..."
echo "$API_KEY_BASE64" | gh secret set APPSTORE_API_KEY_BASE64
echo "   ✅ تم"

echo "2️⃣ إضافة APPSTORE_API_KEY_ID..."
echo "$API_KEY_ID" | gh secret set APPSTORE_API_KEY_ID
echo "   ✅ تم"

echo "3️⃣ إضافة APPSTORE_API_ISSUER_ID..."
echo "$API_ISSUER_ID" | gh secret set APPSTORE_API_ISSUER_ID
echo "   ✅ تم"

echo ""
echo "================================================"
echo "✅ تم إضافة جميع Secrets بنجاح!"
echo "================================================"
echo ""
echo "📋 التالي:"
echo "   1. ادفع التغييرات إلى GitHub"
echo "   2. سيتم تشغيل البناء تلقائياً"
echo "   3. أو شغّل الـ workflow يدوياً من Actions tab"
echo ""
echo "🔍 للتحقق من الـ Secrets:"
echo "   gh secret list"
echo ""
