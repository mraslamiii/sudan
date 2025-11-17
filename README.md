# Sudan - Smart Home Flutter App

یک پروژه Flutter با معماری MVVM برای کنترل خانه هوشمند.

> 📋 **نکته مهم:** برای مشاهده لیست کامل امکانات سیستم، به فایل [FEATURES.md](docs/FEATURES.md) مراجعه کنید.

## معماری پروژه

این پروژه از معماری **MVVM (Model-View-ViewModel)** استفاده می‌کند:

### ساختار پوشه‌ها

```
lib/
├── core/                    # کدهای پایه و مشترک
│   ├── base/               # کلاس‌های پایه (BaseViewModel)
│   ├── constants/          # ثوابت (API, App, Socket)
│   ├── di/                 # Dependency Injection (GetIt)
│   ├── error/              # Exception ها
│   ├── theme/              # تم‌های برنامه
│   └── utils/              # ابزارهای کمکی
│
├── data/                    # لایه داده
│   ├── data_sources/       # منابع داده (API, Local, Socket)
│   ├── models/             # مدل‌های داده
│   └── repositories/       # پیاده‌سازی Repository ها
│
├── domain/                  # لایه دامنه (Business Logic)
│   ├── entities/           # موجودیت‌ها
│   ├── repositories/       # اینترفیس Repository ها
│   └── use_cases/          # Use Case ها
│
└── presentation/            # لایه نمایش
    ├── viewmodels/         # ViewModel ها
    ├── views/              # صفحات (View)
    └── widgets/            # ویجت‌های قابل استفاده مجدد
```

## ویژگی‌ها

- ✅ معماری MVVM با ChangeNotifier
- ✅ Dependency Injection با GetIt
- ✅ Network Layer با Dio
- ✅ Local Storage با SharedPreferences
- ✅ Error Handling
- ✅ Theme Support (Light/Dark)
- ✅ Clean Architecture

## نصب و راه‌اندازی

1. نصب وابستگی‌ها:
```bash
flutter pub get
```

2. اجرای برنامه:
```bash
flutter run
```

## استفاده

### ایجاد یک Feature جدید

1. **Entity** در `domain/entities/`
2. **Repository Interface** در `domain/repositories/`
3. **Use Case** در `domain/use_cases/`
4. **Model** در `data/models/`
5. **Repository Implementation** در `data/repositories/implementations/`
6. **ViewModel** در `presentation/viewmodels/`
7. **View** در `presentation/views/`
8. ثبت در `core/di/injection_container.dart`

### مثال: Home Feature

```dart
// ViewModel
class HomeViewModel extends BaseViewModel {
  final GetHomeDataUseCase _getHomeDataUseCase;
  // ...
}

// View
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<HomeViewModel>()..init(),
      child: const _HomeViewContent(),
    );
  }
}
```

## وابستگی‌ها

- `flutter_bloc` - State Management (برای آینده)
- `provider` - برای MVVM با ChangeNotifier
- `get_it` - Dependency Injection
- `dio` - HTTP Client
- `shared_preferences` - Local Storage

## مجوز

این پروژه برای استفاده شخصی است.
