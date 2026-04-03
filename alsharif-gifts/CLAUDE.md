# Al Sharif Gifts — مشروع كامل

## فكرة المشروع
تطبيق موبايل + موقع ويب لمتجر هدايا اسمه "Al Sharif Gifts"
الهدف: تسويق المشروع كنموذج جاهز لبيعه كخدمة للعملاء
المطور: مقيم في الإمارات
الجمهور المستهدف: سوريا

## الغاية من التطبيق
- عرض المنتجات (تصفح فقط — بدون دفع)
- التحكم الكامل بالمحتوى من لوحة تحكم Sanity
- الزبون يدير منتجاته بنفسه بدون خبرة تقنية
- بدون backend — Flutter يتصل بـ Sanity API مباشرة

## اللغة
- العربية هي اللغة الافتراضية والوحيدة
- الاتجاه: RTL (يمين لليسار)
- يجب أن تكون جميع النصوص والواجهات بالعربية

## التقنيات
- Sanity Studio     → لوحة التحكم (CMS)
- Flutter           → تطبيق Android
- Next.js           → موقع ويب (مرحلة لاحقة)
- بدون TypeScript
- بدون Backend
- بدون قاعدة بيانات خارجية

## هيكل المشروع الكامل
alsharif-gifts/     → Sanity Studio (هذا المشروع)
alsharif-mobile/    → Flutter App (المرحلة القادمة)
alsharif-web/       → Next.js (مرحلة لاحقة)

## مميزات التطبيق
- عرض المنتجات مع صور متعددة
- تصنيف المنتجات
- المنتجات الأكثر مبيعاً (Best Sellers)
- الوصول الجديد (New Arrivals)
- عروض وخصومات مع تاريخ انتهاء
- الصفحة الرئيسية ديناميكية (Page Builder)
- حالة المخزون (متوفر / غير متوفر)

## الـ Schemas المطلوبة
schemas/
  ├── category.js        → التصنيفات
  ├── product.js         → المنتجات
  ├── heroBanner.js      → البانر الرئيسي
  ├── saleBanner.js      → بانر العروض
  ├── featuredProducts.js → المنتجات المميزة
  ├── homePage.js        → الصفحة الرئيسية
  └── index.js           → تجميع كل الـ schemas

## تفاصيل Product Schema
- name (اسم المنتج بالعربية)
- slug
- category (reference → category)
- images (array of images)
- description (وصف بالعربية)
- price (السعر)
- onSale (boolean)
- discountPercent (نسبة الخصم 0-100)
- saleEndDate (تاريخ انتهاء العرض)
- isBestSeller (boolean)
- isNew (boolean)
- inStock (boolean)
- tags (array of strings)

## تفاصيل Category Schema
- title (اسم التصنيف بالعربية)
- slug
- image
- description

## Home Page — Page Builder
الصفحة الرئيسية تتكون من sections:
- heroBanner  → صورة + عنوان + زر
- featuredProducts → منتجات مختارة
- saleBanner  → بانر العروض الموسمية
الزبون يرتب الأقسام بالسحب والإفلات

## GROQ Queries المستخدمة في Flutter
// كل المنتجات
*[_type == "product"]{...}

// العروض فقط
*[_type == "product" && onSale == true]

// الأكثر مبيعاً
*[_type == "product" && isBestSeller == true]

// حسب التصنيف
*[_type == "product" && category->slug.current == $slug]

// الصفحة الرئيسية
*[_type == "homePage"][0]{sections[]{...}}

## ألوان التطبيق
primary:    #B5838D  (وردي هادئ)
secondary:  #6D6875  (بنفسجي)
background: #FFF8F0  (كريمي فاتح)
saleRed:    #E63946  (أحمر العروض)

## ملاحظات للمطور
- جميع حقول الـ Schema يجب أن تكون بعناوين عربية (title بالعربي)
- الـ preview في Studio يظهر السعر النهائي بعد الخصم
- لا تستخدم TypeScript
- استخدم JavaScript فقط
```

---

## كيف تستخدمه في Claude Code
```
أنشئ ملف CLAUDE.md في:
C:\Users\manso\OneDrive\Documents\Flutter Sanity projects\alsharif-gifts\CLAUDE.md
```

ثم في Claude Code اكتب:
```
Read CLAUDE.md and start building the project

## Flutter App
المسار: C:\Users\manso\OneDrive\Documents\Flutter Sanity projects\alsharif_gifts_app
اسم المشروع: alsharif_gifts_app

## Sanity Project Details
Project ID: plo63gzr
Dataset: production
API Version: 2024-01-01

## Flutter Dependencies المطلوبة
dio: ^5.4.0
cached_network_image: ^3.3.1
carousel_slider: ^4.2.1
shimmer: ^3.0.0
go_router: ^13.0.0
provider: ^6.1.1

## ثم في Claude Code اكتب هذا بالضبط
```
I have a Flutter app at:
C:\Users\manso\OneDrive\Documents\Flutter Sanity projects\alsharif_gifts_app

And a Sanity CMS project with:
- Project ID: plo63gzr
- Dataset: production
- Schemas: product, category, homePage, heroBanner, saleBanner, featuredProducts

Please build the complete Flutter app structure:
1. lib/core/constants.dart → Sanity config
2. lib/core/theme.dart → app colors and theme (Arabic RTL)
3. lib/models/ → product and category models
4. lib/services/sanity_service.dart → all GROQ queries
5. lib/screens/ → home, category, product list, product detail, sale screens
6. lib/widgets/ → product card, hero banner, category card, sale banner
7. main.dart → with RTL Arabic support and bottom navigation
8. pubspec.yaml → add all required dependencies

The app is in Arabic (RTL), targeting Android only.
No payment — browsing only.
