# TACH Customer App — Starter Project

এই ZIP-এ Flutter Android app-এর প্রাথমিক source code দেওয়া হয়েছে।

## কী আছে
- Customer username/password দিয়ে API login
- Sanctum Bearer token local app storage-এ রাখা
- Customer dashboard: নাম, Customer ID, due, advance, package, monthly fee, expiry ইত্যাদি
- Logout এবং refresh
- Light Soft UI

## API
বর্তমান API base URL:
`https://tachnet.xyz/api/v1/customer`

প্রয়োজনীয় endpoint:
- POST `/login`
- GET `/dashboard` (Bearer token)
- POST `/logout` (Bearer token)

## Windows-এ চালানোর ধাপ
1. ZIP extract করুন, যেমন `C:\tach_customer_app`
2. CMD খুলে ওই folder-এ যান:
   `cd /d C:\tach_customer_app`
3. Dependency install:
   `flutter pub get`
4. Code check:
   `flutter analyze`
5. Android device USB debugging চালু করে সংযুক্ত করুন, তারপর:
   `flutter devices`
6. App চালু:
   `flutter run`

## APK build
Android SDK/Build tools ইনস্টল ও configure হওয়ার পর:
`flutter build apk --release`

APK তৈরি হলে:
`build\app\outputs\flutter-apk\app-release.apk`

## গুরুত্বপূর্ণ
- এই ZIP source project; এটি compile করা APK নয়।
- API response structure আপনার Laravel controller-এর বর্তমান response অনুযায়ী প্রয়োজনে সামান্য adjust করতে হতে পারে।
- Production customer password বা API token source code-এ রাখা হয়নি।
- Android SDK ছাড়া এই কম্পিউটারে APK compile হবে না।
