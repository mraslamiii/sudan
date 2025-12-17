import 'package:flutter/material.dart';

/// App Localizations
/// Simple localization class for multi-language support
/// 
/// Usage:
/// ```dart
/// final l10n = AppLocalizations.of(context);
/// Text(l10n.floors);
/// ```
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Helper method
  String _getString(String english, String persian) {
    if (locale.languageCode == 'fa') {
      return persian;
    }
    return english;
  }

  // App & General
  String get appName => _getString('Smart Home', 'خانه هوشمند');
  String get appTitle => _getString('Smart Home', 'خانه هوشمند');

  // Floor related strings
  String get floors => _getString('Floors', 'طبقات');
  String get addFloor => _getString('Add Floor', 'افزودن طبقه');
  String get noFloorsYet => _getString('No floors yet', 'هنوز طبقه‌ای وجود ندارد');
  String get selectFloor => _getString('Select a floor', 'انتخاب طبقه');
  String get floorName => _getString('Floor Name', 'نام طبقه');
  String get createFloor => _getString('Create', 'ایجاد');
  String get deleteFloor => _getString('Delete Floor?', 'حذف طبقه؟');
  String get deleteFloorConfirm =>
      _getString('Are you sure you want to delete', 'آیا مطمئن هستید که می‌خواهید حذف کنید');
  String get cancel => _getString('Cancel', 'لغو');
  String get delete => _getString('Delete', 'حذف');
  String get addYourFirstFloor =>
      _getString('Add Your First Floor', 'اولین طبقه را اضافه کنید');
  String get rooms => _getString('Rooms', 'اتاق‌ها');
  String get room => _getString('Room', 'اتاق');
  String get createNewFloor =>
      _getString('Create a new floor for your home', 'یک طبقه جدید برای خانه خود ایجاد کنید');
  String get organizeByFloor =>
      _getString('Organize by floor', 'سازماندهی بر اساس طبقه');
  String get multipleRoomsPerFloor =>
      _getString('Multiple rooms per floor', 'چندین اتاق در هر طبقه');
  String get easyNavigation =>
      _getString('Easy navigation', 'ناوبری آسان');
  String get addNewFloor => _getString('Add New Floor', 'افزودن طبقه جدید');
  String get pleaseEnterFloorName => _getString('Please enter a floor name', 'لطفاً نام طبقه را وارد کنید');
  String get floorNameHint => _getString('e.g., First Floor, Basement', 'مثال: طبقه اول، زیرزمین');
  String get icon => _getString('Icon', 'آیکون');
  String deleteFloorConfirmWithName(String name) => 
      _getString('Are you sure you want to delete "$name"? This action cannot be undone.', 
                 'آیا مطمئن هستید که می‌خواهید "$name" را حذف کنید؟ این عمل قابل بازگشت نیست.');

  // Room related strings
  String get roomName => _getString('Room Name', 'نام اتاق');
  String get roomNameHint => _getString('e.g., Living Room, Bedroom', 'مثال: اتاق نشیمن، اتاق خواب');
  String get roomInformation => _getString('Room Information', 'اطلاعات اتاق');
  String get enterRoomDetails => _getString('Enter basic details about your room', 'اطلاعات پایه اتاق خود را وارد کنید');
  String get descriptionOptional => _getString('Description (Optional)', 'توضیحات (اختیاری)');
  String get roomDescriptionHint => _getString('Add a description for this room', 'توضیحی برای این اتاق اضافه کنید');
  String get createNewRoom => _getString('Create New Room', 'ایجاد اتاق جدید');
  String get stepOf => _getString('Step', 'مرحله');
  String get ofText => _getString('of', 'از');
  String get createRoom => _getString('Create Room', 'ایجاد اتاق');
  String roomCreatedSuccessfully(String name) => 
      _getString('Room "$name" created successfully!', 'اتاق "$name" با موفقیت ایجاد شد!');
  String get savingRoom => _getString('Saving room...', 'در حال ذخیره اتاق...');
  String get close => _getString('Close', 'بستن');
  String get editDetails => _getString('Edit Details', 'ویرایش جزئیات');
  String get noDevicesAvailable => _getString('No devices available', 'دستگاهی در دسترس نیست');
  String get createFirstDevice => _getString('Create your first device to add it to this room.', 'اولین دستگاه خود را ایجاد کنید تا به این اتاق اضافه شود.');
  String get activeRooms => _getString('Active rooms', 'اتاق‌های فعال');
  String get dashboardCards => _getString('Dashboard cards', 'کارت‌های داشبورد');
  String get currentFocus => _getString('Current focus:', 'تمرکز فعلی:');

  // Device Types
  String get light => _getString('Light', 'چراغ');
  String get lightDescription => _getString('Control brightness and color.', 'کنترل روشنایی و رنگ.');
  String get curtains => _getString('Curtains', 'پرده‌ها');
  String get curtainsDescription => _getString('Open, close and set positions.', 'باز کردن، بستن و تنظیم موقعیت.');
  String get thermostat => _getString('Thermostat', 'ترموستات');
  String get thermostatDescription => _getString('Control temperature and modes.', 'کنترل دما و حالت‌ها.');
  String get tv => _getString('TV', 'تلویزیون');
  String get tvDescription => _getString('Toggle and switch channels.', 'روشن/خاموش کردن و تغییر کانال.');
  String get musicPlayer => _getString('Music Player', 'پخش‌کننده موسیقی');
  String get musicPlayerDescription => _getString('Play, pause and adjust volume.', 'پخش، توقف و تنظیم صدا.');
  String get fan => _getString('Fan', 'پنکه');
  String get fanDescription => _getString('Control speed and oscillation.', 'کنترل سرعت و نوسان.');
  String get security => _getString('Security', 'امنیت');
  String get securityDescription => _getString('Arm, disarm and monitor status.', 'فعال‌سازی، غیرفعال‌سازی و نظارت بر وضعیت.');
  String get camera => _getString('Camera', 'دوربین');
  String get cameraDescription => _getString('Live feed and recording controls.', 'کنترل تصویر زنده و ضبط.');
  String get socket => _getString('Socket', 'پریز');
  String get socketDescription => _getString('Turn on/off power outlet.', 'روشن/خاموش کردن پریز برق.');
  String get lock => _getString('Lock', 'قفل');
  String get lockDescription => _getString('Lock and unlock doors.', 'قفل و باز کردن درها.');

  // Device Setup
  String get addDevice => _getString('Add Device', 'افزودن دستگاه');
  String get chooseDeviceType => _getString('Choose a device type to add', 'نوع دستگاه را برای افزودن انتخاب کنید');
  String get configureDevice => _getString('Configure Device', 'پیکربندی دستگاه');
  String get enterDeviceName => _getString('Enter device name', 'نام دستگاه را وارد کنید');
  String get deviceName => _getString('Device Name', 'نام دستگاه');
  String get deviceNameHint => _getString('e.g., Living Room Light', 'مثال: چراغ اتاق نشیمن');
  String get pleaseEnterDeviceName => _getString('Please enter a device name', 'لطفاً نام دستگاه را وارد کنید');
  String get pleaseAddDeviceAction => _getString('Please add at least one device action', 'لطفاً حداقل یک عمل دستگاه اضافه کنید');

  // Device Status
  String get on => _getString('On', 'روشن');
  String get off => _getString('Off', 'خاموش');

  // Dashboard
  String get lighting => _getString('Lighting', 'روشنایی');
  String get lightingNotPaired => _getString('Lighting not paired', 'روشنایی متصل نشده');
  String get connectSmartLighting => _getString('Connect a smart strip or bulb to unlock immersive lighting scenes.', 'یک نوار یا لامپ هوشمند متصل کنید تا صحنه‌های روشنایی غوطه‌ور باز شود.');
  String get ambientGradients => _getString('Ambient gradients', 'گرادیان‌های محیطی');
  String get presetSceneCycles => _getString('Preset scene cycles', 'چرخه‌های صحنه از پیش تنظیم شده');
  String get realtimeDimming => _getString('Realtime dimming', 'کاهش روشنایی در زمان واقعی');
  String get openLightingSetup => _getString('Open lighting setup', 'باز کردن تنظیمات روشنایی');
  String get thermostatOffline => _getString('Thermostat offline', 'ترموستات آفلاین');
  String get linkClimateController => _getString('Link your climate controller to monitor temperatures and automate comfort.', 'کنترل‌کننده آب و هوا را متصل کنید تا دما را نظارت کرده و راحتی را خودکار کنید.');
  String get modesAndScheduling => _getString('Modes & scheduling', 'حالت‌ها و زمان‌بندی');
  String get adaptiveComfortInsights => _getString('Adaptive comfort insights', 'بینش‌های راحتی تطبیقی');
  String get energyFriendlyPresets => _getString('Energy friendly presets', 'پیش‌تنظیمات دوستدار انرژی');
  String get openThermostatSetup => _getString('Open thermostat setup', 'باز کردن تنظیمات ترموستات');
  String get cameraNotLinked => _getString('Camera not linked', 'دوربین متصل نشده');
  String get secureRoomsWithCamera => _getString('Secure your rooms by pairing a camera feed to this dashboard tile.', 'اتاق‌های خود را با جفت‌کردن تصویر دوربین به این کاشی داشبورد ایمن کنید.');
  String get liveFeedSnapshots => _getString('Live feed snapshots', 'عکس‌های تصویر زنده');
  String get roomSwitching => _getString('Room switching', 'تغییر اتاق');
  String get recordingIndicators => _getString('Recording indicators', 'نشانگرهای ضبط');
  String get openCameraSetup => _getString('Open camera setup', 'باز کردن تنظیمات دوربین');
  String get noDevicesYet => _getString('No devices yet', 'هنوز دستگاهی وجود ندارد');
  String get addDevicesToDashboard => _getString('Add devices to your dashboard to control them from here.', 'دستگاه‌ها را به داشبورد خود اضافه کنید تا از اینجا کنترل کنید.');
  String get addRoomBeforeCards => _getString('Add a room before placing dashboard cards.', 'قبل از قرار دادن کارت‌های داشبورد، یک اتاق اضافه کنید.');
  String get deviceSetup => _getString('Device setup', 'تنظیمات دستگاه');
  String get buildPersonalizedControlBoard => _getString('Build your personalised control board', 'ساخت صفحه کنترل شخصی‌سازی شده');
  String get lightingSetup => _getString('Lighting setup', 'تنظیمات روشنایی');
  String get paintEverySceneWithLight => _getString('Paint every scene with light', 'رنگ‌آمیزی هر صحنه با نور');
  String get thermostatSetup => _getString('Thermostat setup', 'تنظیمات ترموستات');
  String get stabilizeComfortWithPrecision => _getString('Stabilise comfort with precision', 'تثبیت راحتی با دقت');
  String get cameraSetup => _getString('Camera setup', 'تنظیمات دوربین');
  String get keepEyeOnEveryCorner => _getString('Keep an eye on every corner', 'نظارت بر هر گوشه');
  String get ambientLight => _getString('Ambient light', 'نور محیطی');
  String get mediaDisplay => _getString('Media display', 'نمایش رسانه');
  String get ceilingFan => _getString('Ceiling fan', 'پنکه سقفی');
  String get deleteCard => _getString('Delete Card', 'حذف کارت');
  String deleteCardConfirm(String name) => 
      _getString('Are you sure you want to delete "$name"?', 'آیا مطمئن هستید که می‌خواهید "$name" را حذف کنید؟');

  // LED Control Panel
  String get reading => _getString('Reading', 'مطالعه');
  String get working => _getString('Working', 'کار');
  String get romantic => _getString('Romantic', 'رمانتیک');

  // Thermostat Control Panel
  String get cool => _getString('Cool', 'خنک');
  String get heat => _getString('Heat', 'گرم');
  String get auto => _getString('Auto', 'خودکار');
  String get cold => _getString('Cold', 'سرد');
  String get comfort => _getString('Comfort', 'راحت');
  String get warm => _getString('Warm', 'گرم');
  String get hot => _getString('Hot', 'داغ');
  String get samsung02 => _getString("Samsung '02", "سامسونگ '02");

  // Tablet Charger Control Panel
  String get tabletCharging => _getString('Tablet Charging', 'شارژ تبلت');
  String get charging => _getString('Charging', 'در حال شارژ');
  String get discharging => _getString('Discharging', 'در حال دی‌شارژ');
  String get fullCharge => _getString('Full Charge', 'شارژ کامل');
  String get goodCharge => _getString('Good Charge', 'شارژ خوب');
  String get lowCharge => _getString('Low Charge', 'شارژ کم');
  String get criticalCharge => _getString('Critical Charge', 'شارژ بحرانی');
  String get charge => _getString('Charge', 'شارژ');
  String get activeCharging => _getString('Active Charging', 'شارژ فعال');
  String get activeDischarging => _getString('Active Discharging', 'دی‌شارژ فعال');

  // Scenarios
  String get scenarios => _getString('Scenarios', 'سناریوها');
  String get add => _getString('Add', 'افزودن');
  String get noScenariosYet => _getString('No scenarios yet', 'هنوز سناریویی وجود ندارد');
  String get automateRoutine => _getString('Automate the routine—blend lighting, climate and security into a single tap.', 'خودکارسازی روال—ترکیب روشنایی، آب و هوا و امنیت در یک ضربه.');
  String get multiDeviceOrchestration => _getString('Multi-device orchestration', 'هماهنگی چند دستگاه');
  String get schedulesAndQuickTriggers => _getString('Schedules & quick triggers', 'زمان‌بندی‌ها و محرک‌های سریع');
  String get reusableRoomPresets => _getString('Reusable room presets', 'پیش‌تنظیمات قابل استفاده مجدد اتاق');
  String get openScenarioSetup => _getString('Open scenario setup', 'باز کردن تنظیمات سناریو');
  String get scenarioSetup => _getString('Scenario setup', 'تنظیمات سناریو');
  String get automateMomentsThatMatter => _getString('Automate moments that matter', 'خودکارسازی لحظات مهم');
  String get scenariosDescription => _getString('Scenarios let you choreograph multiple devices, timers and sensors into one tap or schedule. Design morning routines, arrival scenes or security sweeps effortlessly.', 'سناریوها به شما امکان می‌دهند چندین دستگاه، تایمر و حسگر را در یک ضربه یا زمان‌بندی هماهنگ کنید. روال‌های صبحگاهی، صحنه‌های ورود یا جاروب‌های امنیتی را به راحتی طراحی کنید.');
  String get roomAwareConditions => _getString('Room-aware conditions', 'شرایط آگاه از اتاق');
  String get stackableTriggers => _getString('Stackable triggers', 'محرک‌های قابل انباشت');
  String get visualTimelineEditor => _getString('Visual timeline editor', 'ویرایشگر خط زمانی بصری');
  String get scenarioStep1 => _getString('Pick the destination room and give the scenario a descriptive name.', 'اتاق مقصد را انتخاب کنید و نامی توصیفی برای سناریو بدهید.');
  String get scenarioStep2 => _getString('Add the devices you want to orchestrate, tuning their target states.', 'دستگاه‌هایی که می‌خواهید هماهنگ کنید را اضافه کنید و حالت‌های هدف آن‌ها را تنظیم کنید.');
  String get scenarioStep3 => _getString('Choose how it runs: manual trigger, schedule or sensor driven. Preview before saving.', 'انتخاب کنید که چگونه اجرا شود: محرک دستی، زمان‌بندی یا محرک حسگر. قبل از ذخیره پیش‌نمایش کنید.');
  String get createScenario => _getString('Create a scenario', 'ایجاد یک سناریو');
  String get viewQuickTips => _getString('View quick tips', 'مشاهده نکات سریع');
  String get tipCombineDevices => _getString('Tip: combine lighting, thermostat and security for arrival/away routines.', 'نکته: روشنایی، ترموستات و امنیت را برای روال‌های ورود/خروج ترکیب کنید.');
  String scenarioCreated(String name) => 
      _getString('Scenario "$name" created', 'سناریو "$name" ایجاد شد');
  String get failedToCreateScenario => _getString('Failed to create scenario', 'ایجاد سناریو ناموفق بود');
  String scenarioUpdated(String name) => 
      _getString('Scenario "$name" updated', 'سناریو "$name" به‌روزرسانی شد');
  String get failedToUpdateScenario => _getString('Failed to update scenario', 'به‌روزرسانی سناریو ناموفق بود');
  String scenarioExecuted(String name) => 
      _getString('Scenario "$name" executed', 'سناریو "$name" اجرا شد');
  String get failedToExecuteScenario => _getString('Failed to execute scenario', 'اجرای سناریو ناموفق بود');
  String get deleteScenario => _getString('Delete Scenario', 'حذف سناریو');
  String deleteScenarioConfirm(String name) => 
      _getString('Are you sure you want to delete "$name"?', 'آیا مطمئن هستید که می‌خواهید "$name" را حذف کنید؟');
  String scenarioDeleted(String name) => 
      _getString('Scenario "$name" deleted', 'سناریو "$name" حذف شد');
  String get failedToDeleteScenario => _getString('Failed to delete scenario', 'حذف سناریو ناموفق بود');
  String get editScenario => _getString('Edit Scenario', 'ویرایش سناریو');
  String get createScenarioTitle => _getString('Create Scenario', 'ایجاد سناریو');
  String get controlMultipleDevices => _getString('Control multiple devices with one tap', 'کنترل چندین دستگاه با یک ضربه');
  String get scenarioName => _getString('Scenario Name', 'نام سناریو');
  String get scenarioNameHint => _getString('e.g. Movie Night', 'مثال: شب فیلم');
  String get pleaseEnterName => _getString('Please enter a name', 'لطفاً نام را وارد کنید');
  String get descriptionOptionalScenario => _getString('Description (Optional)', 'توضیحات (اختیاری)');
  String get describeScenario => _getString('Describe what this scenario does', 'توضیح دهید که این سناریو چه کاری انجام می‌دهد');
  String get scenarioInformation => _getString('Scenario Information', 'اطلاعات سناریو');
  String get enterScenarioDetails => _getString('Enter basic details about your scenario', 'اطلاعات پایه سناریو خود را وارد کنید');
  String get selectIcon => _getString('Select Icon', 'انتخاب آیکون');
  String get selectColor => _getString('Select Color', 'انتخاب رنگ');
  String get configureDevices => _getString('Configure Devices', 'پیکربندی دستگاه‌ها');
  String get selectAndConfigureDevices => _getString('Select and configure devices for this scenario', 'دستگاه‌ها را برای این سناریو انتخاب و پیکربندی کنید');
  String get configuredDevices => _getString('Configured Devices', 'دستگاه‌های پیکربندی شده');
  String get noDevicesConfigured => _getString('No devices configured', 'هیچ دستگاهی پیکربندی نشده');
  String get addDevicesToConfigure => _getString('Add devices from the list below to configure them', 'دستگاه‌ها را از لیست زیر اضافه کنید تا پیکربندی شوند');
  String get appSettings => _getString('App Settings', 'تنظیمات اپلیکیشن');
  String get configureAppSettings => _getString('Configure app-level settings', 'پیکربندی تنظیمات سطح اپلیکیشن');
  String get appSettingsInfo => _getString('These settings will be applied when the scenario is executed. Leave unchanged to keep current settings.', 'این تنظیمات هنگام اجرای سناریو اعمال می‌شوند. بدون تغییر بگذارید تا تنظیمات فعلی حفظ شود.');
  String get dontChange => _getString('Don\'t Change', 'تغییر نده');
  String get reviewAndConfirm => _getString('Review & Confirm', 'بررسی و تأیید');
  String get reviewScenarioDetails => _getString('Review your scenario details before saving', 'جزئیات سناریو خود را قبل از ذخیره بررسی کنید');
  String get savingScenario => _getString('Saving scenario...', 'در حال ذخیره سناریو...');
  String get createNewScenario => _getString('Create New Scenario', 'ایجاد سناریو جدید');
  String get state => _getString('State', 'وضعیت');
  String get brightness => _getString('Brightness', 'روشنایی');
  String get targetTemperature => _getString('Target Temperature', 'دمای هدف');
  String get position => _getString('Position', 'موقعیت');
  String get volume => _getString('Volume', 'صدا');
  String get targetFloor => _getString('Target Floor', 'طبقه هدف');
  String get delay => _getString('Delay', 'تأخیر');
  String get turnOn => _getString('Turn On', 'روشن کردن');
  String get turnOff => _getString('Turn Off', 'خاموش کردن');
  String get setTo => _getString('Set to', 'تنظیم به');
  String get open => _getString('Open', 'باز کردن');
  String get play => _getString('Play', 'پخش');
  String get stop => _getString('Stop', 'توقف');
  String get arm => _getString('Arm', 'فعال‌سازی');
  String get disarm => _getString('Disarm', 'غیرفعال‌سازی');
  String get setState => _getString('Set State', 'تنظیم وضعیت');
  String get dark => _getString('Dark', 'تاریک');
  String get system => _getString('System', 'سیستم');
  String get themeMode => _getString('Theme Mode', 'حالت تم');
  String get addDevicesToRoomFirst => _getString('Add devices to room first', 'ابتدا دستگاه‌ها را به اتاق اضافه کنید');
  String get devices => _getString('Devices', 'دستگاه‌ها');
  String get availableDevices => _getString('Available Devices', 'دستگاه‌های موجود');

  // Socket Connection
  String get socketConnection => _getString('Socket Connection', 'اتصال سوکت');
  String get connected => _getString('Connected', 'متصل');
  String get disconnected => _getString('Disconnected', 'قطع شده');
  String get status => _getString('Status:', 'وضعیت:');
  String get ipAddress => _getString('IP Address', 'آدرس IP');
  String get port => _getString('Port', 'پورت');
  String get pleaseEnterValidIpPort => _getString('Please enter valid IP and Port', 'لطفاً IP و Port معتبر وارد کنید');
  String get connect => _getString('Connect', 'اتصال');
  String get disconnect => _getString('Disconnect', 'قطع اتصال');
  String get reconnect => _getString('Reconnect', 'اتصال مجدد');
  String get unknownError => _getString('Unknown error', 'خطای ناشناخته');
  String get commands => _getString('Commands', 'دستورات');
  String get requestIpConfig => _getString('Request IP Config', 'درخواست پیکربندی IP');
  String get requestFloorsCount => _getString('Request Floors Count', 'درخواست تعداد طبقات');
  String get turnOnLightDevice => _getString('Turn On Light (Device 1)', 'روشن کردن چراغ (دستگاه 1)');
  String get openCurtainDevice => _getString('Open Curtain (Device 1)', 'باز کردن پرده (دستگاه 1)');
  String get chargeTabletDevice => _getString('Charge Tablet (Device 1)', 'شارژ تبلت (دستگاه 1)');
  String get dischargeTabletDevice => _getString('Discharge Tablet (Device 1)', 'دی‌شارژ تبلت (دستگاه 1)');
  String get socketOnDevice => _getString('Socket On (Device 1)', 'پریز روشن (دستگاه 1)');
  String get lastReceivedData => _getString('Last Received Data', 'آخرین داده دریافت شده');
  String get anErrorOccurred => _getString('An error occurred', 'خطایی رخ داد');
  String get failedToCreateFloor => _getString('Failed to create floor', 'ایجاد طبقه ناموفق بود');

  // Settings
  String get settings => _getString('Settings', 'تنظیمات');
  String get customizeYourExperience => _getString('Customize your experience', 'تجربه خود را سفارشی کنید');
  String get appearance => _getString('Appearance', 'ظاهر');
  String get language => _getString('Language', 'زبان');
  String get about => _getString('About', 'درباره');
  String get version => _getString('Version', 'نسخه');
  String get appNameSettings => _getString('App Name', 'نام برنامه');
  String get sudanSmartHome => _getString('Sudan Smart Home', 'خانه هوشمند سودان');
  String get lightTheme => _getString('Light', 'روشن');
  String get darkTheme => _getString('Dark', 'تاریک');
  String get systemTheme => _getString('System', 'سیستم');
  String get english => _getString('English', 'انگلیسی');
  String get persian => _getString('فارسی', 'فارسی');

  // Navigation & Actions
  String get back => _getString('Back', 'بازگشت');
  String get next => _getString('Next', 'بعدی');
  String get save => _getString('Save', 'ذخیره');

  // Error Messages
  String get somethingWentWrong => _getString('Something went wrong:', 'مشکلی پیش آمد:');

  // Onboarding Guide
  String get onboardingTitle => _getString('Get Started', 'شروع کنید');
  String get onboardingSubtitle => _getString('Follow these steps to set up your smart home', 'این مراحل را دنبال کنید تا خانه هوشمند خود را راه‌اندازی کنید');
  String get stepCreateRoom => _getString('Create Your First Room', 'اولین اتاق خود را ایجاد کنید');
  String get stepCreateRoomDescription => _getString('Add a room to organize your devices', 'یک اتاق اضافه کنید تا دستگاه‌های خود را سازماندهی کنید');
  String get stepAddDevice => _getString('Add Devices', 'افزودن دستگاه‌ها');
  String get stepAddDeviceDescription => _getString('Add smart devices to control from dashboard', 'دستگاه‌های هوشمند را اضافه کنید تا از دشبورد کنترل کنید');
  String get stepCreateScenario => _getString('Create Scenarios', 'ایجاد سناریوها');
  String get stepCreateScenarioDescription => _getString('Automate your routine with scenarios', 'روال خود را با سناریوها خودکار کنید');
  String get stepCustomizeDashboard => _getString('Customize Dashboard', 'سفارشی‌سازی دشبورد');
  String get stepCustomizeDashboardDescription => _getString('Arrange and personalize your dashboard', 'دشبورد خود را مرتب و شخصی‌سازی کنید');
  String get startAction => _getString('Start', 'شروع');
  String get completed => _getString('Completed', 'انجام شده');

  // PIN related strings
  String get enterPin => _getString('Enter PIN', 'وارد کردن پین کد');
  String get pinRequired => _getString('PIN Required', 'پین کد مورد نیاز است');
  String get pinRequiredForAction => _getString('PIN is required to perform this action', 'برای انجام این عمل پین کد مورد نیاز است');
  String get incorrectPin => _getString('Incorrect PIN', 'پین کد اشتباه است');
  String get pinManagement => _getString('PIN Management', 'مدیریت پین کد');
  String get manageAllowedPins => _getString('Manage Allowed PINs', 'مدیریت پین کدهای مجاز');
  String get allowedPins => _getString('Allowed PINs', 'پین کدهای مجاز');
  String get addPin => _getString('Add PIN', 'افزودن پین کد');
  String get enterNewPin => _getString('Enter New PIN', 'وارد کردن پین کد جدید');
  String get pinMustBe4Digits => _getString('PIN must be 4 digits', 'پین کد باید ۴ رقم باشد');
  String get pinTooWeak => _getString('PIN is too weak. Avoid common patterns like 1234, 1111, etc.', 'پین کد خیلی ضعیف است. از الگوهای رایج مانند 1234، 1111 و غیره خودداری کنید.');
  String get pinAdded => _getString('PIN added successfully', 'پین کد با موفقیت اضافه شد');
  String get pinRemoved => _getString('PIN removed successfully', 'پین کد با موفقیت حذف شد');
  String get failedToAddPin => _getString('Failed to add PIN', 'افزودن پین کد ناموفق بود');
  String get failedToRemovePin => _getString('Failed to remove PIN', 'حذف پین کد ناموفق بود');
  String get removePin => _getString('Remove PIN', 'حذف پین کد');
  String get removePinConfirm => _getString('Are you sure you want to remove this PIN?', 'آیا مطمئن هستید که می‌خواهید این پین کد را حذف کنید؟');
  String get noPinsConfigured => _getString('No PINs configured', 'هیچ پین کدی پیکربندی نشده است');
  String get configurePinsFirst => _getString('Configure at least one PIN first', 'ابتدا حداقل یک پین کد پیکربندی کنید');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fa'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
