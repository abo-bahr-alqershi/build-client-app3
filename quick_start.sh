#!/bin/bash

# 🚀 Quick Start - تشغيل سريع للتوقيع التلقائي

echo "🚀 Quick Start: iOS Automatic Signing Setup"
echo "=============================================="
echo ""

# التحقق من الموقع
if [ ! -f ".github/workflows/ios-macos.yml" ]; then
    echo "❌ يجب تشغيل هذا السكريبت من مجلد المشروع الرئيسي"
    exit 1
fi

echo "📋 الملفات الموجودة:"
echo "   ✅ Workflow: .github/workflows/ios-macos.yml"
echo "   ✅ API Key: cer_ios/AuthKey_49B2H4YJHU (1).p8"
echo "   ✅ Profile: cer_ios/Provision_Profile_2.mobileprovision"
echo ""

echo "🔍 معلومات الجهاز المتصل:"
DEVICE_UUID=$(idevice_id -l 2>/dev/null || echo "لا يوجد")
echo "   UUID: $DEVICE_UUID"
echo ""

echo "📊 الإعدادات:"
echo "   • Xcode: 16.4 (على macos-15)"
echo "   • Signing: Automatic (مع API Key fallback إلى Manual)"
echo "   • Method: ad-hoc (يعمل على جميع الأجهزة المسجلة)"
echo "   • UUID: لا حاجة لتحديده ✅"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 خياران للبدء:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🔵 الخيار 1: التوقيع التلقائي (موصى به)"
echo "   - أضف 3 Secrets إلى GitHub"
echo "   - شغّل: ./add_github_secrets.sh"
echo "   - أو أضفها يدوياً (راجع SETUP_AUTOMATIC_SIGNING.md)"
echo ""

echo "🟢 الخيار 2: استخدام الإعدادات الحالية (يعمل الآن)"
echo "   - لا حاجة لإضافة Secrets"
echo "   - يستخدم التوقيع اليدوي"
echo "   - ادفع التغييرات مباشرة:"
echo ""
echo "     git add ."
echo "     git commit -m \"feat: iOS build with latest Xcode\""
echo "     git push origin main"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "هل تريد إضافة Secrets الآن؟ (y/n): " answer
case ${answer:0:1} in
    y|Y )
        echo ""
        echo "🔄 تشغيل add_github_secrets.sh..."
        ./add_github_secrets.sh
    ;;
    * )
        echo ""
        echo "✅ حسناً! يمكنك إضافة Secrets لاحقاً"
        echo "📖 راجع: COMPREHENSIVE_SUMMARY_AR.md لكل التفاصيل"
        echo ""
        echo "💡 نصيحة: البناء سيعمل الآن بالتوقيع اليدوي حتى تضيف Secrets"
    ;;
esac

echo ""
echo "📚 ملفات التوثيق:"
echo "   • COMPREHENSIVE_SUMMARY_AR.md - ملخص شامل بالعربية"
echo "   • SETUP_AUTOMATIC_SIGNING.md - دليل إعداد التوقيع التلقائي"
echo "   • add_github_secrets.sh - سكريبت إضافة Secrets تلقائياً"
echo ""
echo "🎉 انتهى الإعداد! حظاً موفقاً في البناء!"
