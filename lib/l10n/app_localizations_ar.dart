// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Lkout';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get error => 'خطأ';

  @override
  String get welcome => 'مرحباً';

  @override
  String get timetable => 'الجدول';

  @override
  String get timetableCreate => 'إنشاء جدول';

  @override
  String get timetableResult => 'نتيجة الجدول';

  @override
  String get fieldRequired => 'مطلوب';

  @override
  String get mustBePositive => 'يجب أن يكون ≥ 1';

  @override
  String get idAlreadyUsed => 'المعرّف مستخدم بالفعل';

  @override
  String get minTwoChars => '2 أحرف على الأقل';

  @override
  String get invalidHoursFormat => 'الصيغة: معرّفالمستوى:ساعات — مثال: 1:6,2:4';

  @override
  String get levelsRequired => 'أدخل مستوى واحداً على الأقل — مثال: 1,2';

  @override
  String get invalidFormat => 'صيغة غير صالحة — مثال: 1,2';

  @override
  String get slotRange => 'يجب أن تكون الفترة بين 1 و 24';

  @override
  String get slotAlreadyUsed => 'هذه الفترة مُعرَّفة بالفعل كاستراحة';

  @override
  String get dayRange => 'يجب أن يكون اليوم بين 1 و 7';

  @override
  String get minTwo => 'يجب أن يكون ≥ 2';

  @override
  String get selectASubject => 'اختر مادة';

  @override
  String get searchTeacherHint => 'بحث عن أستاذ...';

  @override
  String get noTeachersForSubject => 'لا يوجد أستاذ لهذه المادة';

  @override
  String get addRooms => 'إضافة قاعات';

  @override
  String get addSubject => 'إضافة مادة';

  @override
  String get editTeacher => 'تعديل الأستاذ';

  @override
  String teacherUpdatedSuccessfully(String name) {
    return 'تم تحديث $name بنجاح';
  }

  @override
  String get noTeacherScheduleAvailable => 'لا يوجد جدول أساتذة متاح للعرض';

  @override
  String teacherNumberFallback(String id) {
    return 'أستاذ $id';
  }

  @override
  String dayNumberFallback(String id) {
    return 'اليوم $id';
  }

  @override
  String subjectNumberFallback(String id) {
    return 'مادة $id';
  }

  @override
  String classNumberFallback(String id) {
    return 'فصل $id';
  }

  @override
  String roomNumberFallback(String id) {
    return 'قاعة $id';
  }

  @override
  String get editSubject => 'تعديل المادة';

  @override
  String get editRoom => 'تعديل القاعة';

  @override
  String get save => 'حفظ';

  @override
  String get addTeacher => 'إضافة أستاذ';

  @override
  String get addABreakHour => 'إضافة ساعة استراحة';

  @override
  String get addEdit => 'إضافة/تعديل';

  @override
  String get allDataCleared => 'تم مسح جميع البيانات!';

  @override
  String get awesome => 'رائع';

  @override
  String get cancel => 'إلغاء';

  @override
  String get chooseLevel => 'اختر المستوى...';

  @override
  String get clearOverrides => 'مسح التعديلات';

  @override
  String get confirmPay => 'تأكيد والدفع';

  @override
  String get confirmPayment => 'تأكيد الدفع';

  @override
  String get continueBtn => 'متابعة';

  @override
  String get createSchedule => 'إنشاء جدول';

  @override
  String get createSubject => 'إنشاء مادة';

  @override
  String get enterPhoneNumber => 'أدخل رقم الهاتف';

  @override
  String get errorMsg => 'خطأ';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get generate => 'توليد';

  @override
  String get info => 'معلومات';

  @override
  String get insufficientTeachers => 'عدد الأساتذة غير كافٍ';

  @override
  String get language => 'اللغة';

  @override
  String get manualOverridesPlanner => 'مخطط التعديلات اليدوية';

  @override
  String get minutesMustBeBetween1And59 => 'يجب أن تكون الدقائق بين 1 و 59!';

  @override
  String get noRoomsConfiguredYet => 'لم يتم تهيئة أي قاعة حتى الآن.';

  @override
  String get noSubjectsAddedYet => 'لم تُضف أي مادة حتى الآن.';

  @override
  String get noTeachersAssignedYet =>
      'لم يُعيَّن أي أستاذ حتى الآن. استخدم القائمة أعلاه لتعطيل تضمين الأساتذة';

  @override
  String get ok => 'موافق';

  @override
  String get confirmQuestion => 'هل أنت متأكد؟';

  @override
  String get paymentSuccessful => 'تم الدفع بنجاح!';

  @override
  String get pinSlot => 'تثبيت الفترة';

  @override
  String get pleaseAddRooms => 'يرجى إضافة قاعات';

  @override
  String get pleaseAddSubjects => 'يرجى إضافة مواد';

  @override
  String get pleaseAddTeachers =>
      'يرجى إضافة أساتذة أو تعطيل تضمين الأساتذة في الجدول';

  @override
  String get includeTeachersInPayload => 'تضمين الأساتذة في الجدول';

  @override
  String get includeTeachersInPayloadHint =>
      'When disabled, the generator sends placeholder teachers to the backend while still allowing schedule creation.';

  @override
  String get pleaseSelectAClassFirst => 'يرجى اختيار فصل أولاً!';

  @override
  String get pleaseSelectAtLeastOneWorkingD =>
      'يرجى اختيار يوم عمل واحد على الأقل';

  @override
  String get scheduleResult => 'نتيجة الجدول الدراسي';

  @override
  String get scheduleSkeleton => 'هيكل الجدول الدراسي';

  @override
  String get scheduleDataNotFound => 'بيانات الجدول غير موجودة.';

  @override
  String get send => 'إرسال';

  @override
  String get timingConstraints => 'القيود الزمنية';

  @override
  String get tryAnyway => 'المحاولة على أي حال';

  @override
  String get upgradeToPremium => 'الترقية إلى النسخة المميزة';

  @override
  String get yourPremiumFeaturesHaveBeenUnl => 'تم إلغاء قفل ميزاتك المميزة.';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get confirmLogoutTitle => 'تأكيد تسجيل الخروج';

  @override
  String get confirmLogoutMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get alreadyHave => 'هل لديك حساب بالفعل؟';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get institution => 'المؤسسة';

  @override
  String get lastName => 'اللقب';

  @override
  String get phone => 'الهاتف';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordDescription =>
      'أدخل بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور.';

  @override
  String get emailNotConfirmedError => 'البريد الإلكتروني غير مؤكد.';

  @override
  String get pleaseConfirmEmail => 'يرجى تأكيد بريدك الإلكتروني';

  @override
  String get emailWillBeSentTo => '  سوف يتم ارسال البريد الإلكتروني إلى';

  @override
  String get errorPrefix => 'خطأ:';

  @override
  String get signInWelcome => 'مرحباً بتسجيل الدخول';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال بريد إلكتروني';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة مرور';

  @override
  String get shortPassword => 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get pleaseSelectRole => 'يرجى اختيار دور';

  @override
  String get welcomesegtotimetable => 'مرحبًا بك في مدارس';

  @override
  String get noMorePlaceAnimation => 'لا مكان لمزيد من الرسوم المتحركة';

  @override
  String get emptyFirstName => 'الاسم الأول فارغ';

  @override
  String get emptyLastName => 'اللقب فارغ';

  @override
  String get fillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get passwordNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get roleDirector => 'مدير';

  @override
  String get roleSupervisor => 'مشرف';

  @override
  String get roleTeacher => 'أستاذ';

  @override
  String get roleStudent => 'طالب';

  @override
  String get roleLabel => 'الدور';

  @override
  String get signInLabel => 'تسجيل_الدخول';

  @override
  String get optional => 'اختياري';

  @override
  String get guide => 'دليل';

  @override
  String get subject => 'المادة';

  @override
  String get teacher => 'الأستاذ';

  @override
  String get teachers => 'الأساتذة';

  @override
  String get room => 'القاعة';

  @override
  String get rooms => 'القاعات';

  @override
  String get restricted => 'مقيّد';

  @override
  String get consecutive => 'متتالي';

  @override
  String get levels => 'المستويات';

  @override
  String get subjects => 'المواد';

  @override
  String get weeklyHours => 'الساعات الأسبوعية';

  @override
  String get classes => 'الفصول';

  @override
  String get hours => 'الساعات';

  @override
  String get filterTeachersBySubject => 'تصفية الأساتذة حسب المادة';

  @override
  String get allSubjects => 'جميع المواد';

  @override
  String get searchForATeacher => 'البحث عن أستاذ';

  @override
  String get selectATeacherToViewSchedule => 'اختر أستاذًا لعرض جدوله.';

  @override
  String roomAddedSuccessfully(String name) {
    return 'تمت إضافة \"$name\" بنجاح';
  }

  @override
  String roomRemoved(String name) {
    return 'تم حذف \"$name\"';
  }

  @override
  String roomUpdatedSuccessfully(String name) {
    return 'تم تحديث \"$name\" بنجاح';
  }

  @override
  String teacherAddedSuccessfully(String name) {
    return 'تمت إضافة $name بنجاح';
  }

  @override
  String teacherRemoved(String name) {
    return 'تم حذف $name';
  }

  @override
  String nLevelsSelected(int count) {
    return 'تم اختيار $count مستوى(ات)';
  }

  @override
  String nSubjectsSelected(int count) {
    return 'تم اختيار $count مادة(مواد)';
  }

  @override
  String capacityValue(int value) {
    return 'السعة: $value';
  }

  @override
  String maxHoursPerWeekValue(int value) {
    return 'أقصى $valueس/أسبوع';
  }

  @override
  String classesInLevel(String level) {
    return 'فصول المستوى $level';
  }

  @override
  String templatePlannerTitle(String className) {
    return 'مخطط النموذج: $className';
  }

  @override
  String pinLessonForClass(String className) {
    return 'تثبيت درس للفصل $className';
  }

  @override
  String dayAndSlot(String day, int slot) {
    return '$day، الفترة $slot';
  }

  @override
  String slotNumber(int number) {
    return 'الفترة $number';
  }

  @override
  String nPinned(int count) {
    return '$count مثبت(ة)';
  }

  @override
  String get sectionBasicInformation => 'المعلومات الأساسية';

  @override
  String get sectionRestrictionsOptional => 'القيود  (اختياري)';

  @override
  String get sectionConstraints => 'القيود';

  @override
  String get cardRoomName => 'اسم القاعة';

  @override
  String get cardCapacityOptional => 'السعة  (اختياري)';

  @override
  String get cardAllowedLevels => 'المستويات المسموح بها';

  @override
  String get cardAllowedSubjects => 'المواد المسموح بها';

  @override
  String get cardUsedOnlyFor => 'تُستخدم فقط لـ';

  @override
  String get cardTeacherName => 'اسم الأستاذ';

  @override
  String get cardSubject => 'المادة';

  @override
  String get cardQualifiedLevels => 'المستويات المؤهَّلة';

  @override
  String get cardMaxHoursWeekOptional =>
      'الحد الأقصى للساعات / الأسبوع  (اختياري)';

  @override
  String get cardConsecutiveHours => 'ساعات متتالية';

  @override
  String get tooltipRoomName =>
      'اسم فريد يُعرِّف هذه القاعة. يمكن أن يكون رقماً أو تسمية أو وصفاً.';

  @override
  String get tooltipCapacity =>
      'الحد الأقصى لعدد الطلاب في هذه القاعة. يتجنب المخطط الاكتظاظ. القيمة الافتراضية هي 40.';

  @override
  String get tooltipAllowedLevels =>
      'اتركه فارغاً للسماح بأي مستوى. اختر مستويات محددة لحجز هذه القاعة لها.';

  @override
  String get tooltipAllowedSubjects =>
      'اتركه فارغاً للسماح بأي مادة. اختر مواد لتقييد هذه القاعة (مثل مختبر للكيمياء فقط).';

  @override
  String get tooltipUsedOnlyFor =>
      'اختر مادة لجعلها إلزامية في هذه القاعة (مثل مختبر للكيمياء فقط).';

  @override
  String get tooltipTeacherName =>
      'يجب أن يكون فريداً. يُستخدم لتمييز هذا الأستاذ في الجدول.';

  @override
  String get tooltipTeacherSubject =>
      'كل أستاذ مرتبط بمادة واحدة. يستخدم المخطط هذا لمطابقة الأساتذة بالفصول.';

  @override
  String get tooltipQualifiedLevels =>
      'المراحل الدراسية أو المجموعات التي يُجاز لهذا الأستاذ تدريسها. اختر كل ما ينطبق.';

  @override
  String get tooltipMaxHoursWeek =>
      'يمنع تخصيص أكثر من هذا العدد من الساعات لهذا الأستاذ في أسبوع واحد.';

  @override
  String get tooltipConsecutiveHours =>
      'عند التفعيل، يحاول المخطط تجميع حصص هذا الأستاذ في كتلة متواصلة.';

  @override
  String get hintEnterRoomName => 'أدخل اسم القاعة';

  @override
  String get hintCapacity => 'مثال: 30';

  @override
  String get hintEnterTeacherName => 'أدخل اسم الأستاذ';

  @override
  String get hintSelectSubject => 'اختر مادة';

  @override
  String get hintMaxHours => 'مثال: 20';

  @override
  String get capacityDescription =>
      'الحد الأقصى لعدد الطلاب. اتركه فارغاً لاستخدام القيمة الافتراضية (40).';

  @override
  String get allowedLevelsDescription =>
      'المستويات المختارة فقط مسموح بها. اتركه فارغاً للسماح بأي مستوى.';

  @override
  String get allowedSubjectsDescription =>
      'اتركه فارغاً للسماح بجميع المواد. اختر مواد لتقييد هذه القاعة.';

  @override
  String get usedOnlyForDescription =>
      'إجبار المادة على استخدام هذه الغرفة فقط (مثال مختبر للكيمياء فقط).';

  @override
  String get qualifiedLevelsDescription =>
      'اختر جميع المستويات التي يمكن لهذا الأستاذ تدريسها.';

  @override
  String get maxHoursWeekDescription =>
      'اتركه فارغاً لعدم وجود حد أسبوعي. مفيد للأساتذة بدوام جزئي.';

  @override
  String get requireConsecutiveHours => 'اشتراط ساعات متتالية';

  @override
  String get consecutiveHoursDescription => 'ستُجدوَل حصص الأستاذ بشكل متتالٍ.';

  @override
  String get validationRoomNameRequired => 'اسم القاعة مطلوب';

  @override
  String get validationNameMinTwoChars =>
      'يجب أن يحتوي الاسم على حرفين على الأقل';

  @override
  String get validationRoomNameAlreadyExists => 'توجد قاعة بهذا الاسم بالفعل';

  @override
  String get validationMustBeNumberGteOne => 'يجب أن يكون رقماً ≥ 1';

  @override
  String get validationTeacherNameRequired => 'اسم الأستاذ مطلوب';

  @override
  String get validationTeacherNameAlreadyExists =>
      'يوجد أستاذ بهذا الاسم بالفعل';

  @override
  String get validationSelectSubjectOrCreate =>
      'يرجى اختيار مادة أو إنشاء واحدة';

  @override
  String get validationSelectAtLeastOneLevel => 'اختر مستوى واحداً على الأقل';

  @override
  String get validationSelectSubject => 'يرجى اختيار مادة';

  @override
  String get validationSelectTeacher => 'يرجى اختيار أستاذ';

  @override
  String get validationSelectRoom => 'يرجى اختيار قاعة';

  @override
  String get noLevelsDefinedYet => 'لم يُحدَّد أي مستوى حتى الآن.';

  @override
  String get noSubjectsDefinedYet => 'لم تُحدَّد أي مادة حتى الآن.';

  @override
  String get noRoomsAddedYet => 'لم تُضف أي قاعة حتى الآن';

  @override
  String get noRoomsAddedYetSubtitle =>
      'املأ النموذج أو استخدم توليد لإضافة قاعات';

  @override
  String get noTeachersAddedYet => 'لم يُضف أي أستاذ حتى الآن';

  @override
  String get noTeachersAddedYetSubtitle => 'املأ النموذج واضغط إضافة أستاذ';

  @override
  String get unknownSubject => 'مادة غير معروفة';

  @override
  String get unknownTeacher => 'أستاذ غير معروف';

  @override
  String get unknownRoom => 'قاعة غير معروفة';

  @override
  String get roomsAdded => 'القاعات المضافة';

  @override
  String get teachersAdded => 'الأساتذة المضافون';

  @override
  String get removeRoom => 'حذف القاعة';

  @override
  String get removeTeacher => 'حذف الأستاذ';

  @override
  String get swipeLeftToDeleteRoom => 'اسحب يساراً لحذف قاعة';

  @override
  String get addRoom => 'إضافة قاعة';

  @override
  String get createNewSubject => 'إنشاء مادة جديدة';

  @override
  String get generateRooms => 'توليد قاعات';

  @override
  String get generateRoomsDescription =>
      'أضف قاعات متعددة بسرعة باستخدام نمط ترقيم.';

  @override
  String get numberOfRooms => 'عدد القاعات';

  @override
  String get numberOfRoomsHint => 'مثال: 10';

  @override
  String get namePatternLabel => 'نمط الاسم  (# → الرقم)';

  @override
  String get namePatternHint => 'مثال: قاعة # → قاعة 1، قاعة 2…';

  @override
  String get helpSheetRoomsTitle => 'إضافة قاعات — دليل';

  @override
  String get helpSheetTeachersTitle => 'إضافة أستاذ — دليل';

  @override
  String get helpSheetSubtitle => 'ما يجب إدخاله في كل حقل';

  @override
  String get helpEntryRoomNameTitle => 'اسم القاعة';

  @override
  String get helpEntryRoomNameBody =>
      'اسم فريد لتعريف هذه القاعة في الجدول.\n\n• حرفان على الأقل، يجب أن يكون فريداً\n• أمثلة: «قاعة 101»، «مختبر العلوم»، «قاعة الحاسوب»، «قاعة المكتبة»';

  @override
  String get helpEntryCapacityTitle => 'السعة';

  @override
  String get helpEntryCapacityBody =>
      'الحد الأقصى لعدد الطلاب الذين يمكن إيواؤهم في هذه القاعة في آنٍ واحد.\n\n• اتركه فارغاً لاستخدام السعة الافتراضية (40 طالباً)\n• يستخدم المخطط هذا لتفادي الاكتظاظ\n• مثال: أدخل «25» إذا كان المختبر لا يتسع إلا لـ 25 مقعداً';

  @override
  String get helpEntryAllowedLevelsTitle => 'المستويات المسموح بها';

  @override
  String get helpEntryAllowedLevelsBody =>
      'قيِّد هذه القاعة لمستويات دراسية محددة فقط.\n\n• اتركها جميعاً غير محددة للسماح بأي مستوى\n• اختر مستوى أو أكثر لحجز هذه القاعة لفئات معينة\n• مثال: «قاعة السنة الخامسة» محجوزة لطلاب السنة الخامسة فقط';

  @override
  String get helpEntryAllowedSubjectsTitle => 'المواد المسموح بها';

  @override
  String get helpEntryAllowedSubjectsBody =>
      'قيِّد هذه القاعة لمواد محددة فقط.\n\n• اتركها جميعاً غير محددة للسماح بأي مادة\n• اختر مواد إذا كانت القاعة تحتوي على معدات خاصة\n• مثال: «مختبر الكيمياء» يجب أن يُستخدم للكيمياء فقط';

  @override
  String get helpEntryGenerateRoomsTitle => 'توليد القاعات (إجراء سريع)';

  @override
  String get helpEntryGenerateRoomsBody =>
      'استخدم زر «توليد» في شريط الأدوات لإنشاء قاعات متعددة دفعةً واحدة.\n\n• أدخل عدد القاعات التي تحتاجها\n• استخدم # كعنصر نائب لرقم القاعة في الاسم\n• مثال: «قاعة #» مع العدد 5 → ينشئ «قاعة 1» إلى «قاعة 5»\n• القاعات المُولَّدة تستخدم السعة الافتراضية (40) بلا قيود';

  @override
  String get helpEntryDeletingRoomTitle => 'حذف قاعة';

  @override
  String get helpEntryDeletingRoomBody =>
      'يمكنك إزالة قاعة من القائمة بعد إضافتها.\n\n• اسحب يساراً على أي قاعة لحذفها\n• أو مرِّر المؤشر فوق البطاقة واضغط أيقونة 🗑 على اليمين';

  @override
  String get helpEntryTeacherNameTitle => 'اسم الأستاذ';

  @override
  String get helpEntryTeacherNameBody =>
      'الاسم الكامل للأستاذ المراد إضافته إلى الجدول.\n\n• حرفان على الأقل، يجب أن يكون فريداً\n• أمثلة «الأستاذ أحمد »، «الدكتورة ليلى»';

  @override
  String get helpEntryTeacherSubjectTitle => 'المادة';

  @override
  String get helpEntryTeacherSubjectBody =>
      'المادة التي يؤهَّل هذا الأستاذ لتدريسها.\n\n• كل أستاذ مرتبط بمادة واحدة بالضبط\n• يستخدم المخطط هذا لتعيين الأستاذ المناسب لكل فصل\n• إذا كانت المادة غير موجودة، اضغط «إنشاء مادة جديدة» لإضافتها أولاً';

  @override
  String get helpEntryQualifiedLevelsTitle => 'المستويات المؤهَّلة';

  @override
  String get helpEntryQualifiedLevelsBody =>
      'المستويات الدراسية التي يمكن لهذا الأستاذ تدريسها.\n\n• اختر مستوى واحداً على الأقل\n• اختر كل المستويات المنطبقة — يمكن للأستاذ تغطية مستويات متعددة\n• مثال: اختر «الصف الرابع» و«الصف الخامس» إذا كان الأستاذ يستطيع تدريس كليهما';

  @override
  String get helpEntryMaxHoursTitle => 'الحد الأقصى للساعات / الأسبوع';

  @override
  String get helpEntryMaxHoursBody =>
      'الحد الأقصى لساعات التدريس لهذا الأستاذ في الأسبوع.\n\n• اتركه فارغاً لعدم وجود حد\n• مفيد للأساتذة بدوام جزئي أو لتجنب إثقال كاهل الكادر\n• مثال: أدخل «18» لتحديد الأستاذ بـ 18 ساعة/أسبوع';

  @override
  String get helpEntryConsecutiveHoursTitle => 'الساعات المتتالية';

  @override
  String get helpEntryConsecutiveHoursBody =>
      'يتحكم في ما إذا كانت حصص هذا الأستاذ ستُجدوَل بشكل متتالٍ.\n\n• ✅ مفعَّل — يجمع المخطط حصص الأستاذ في كتلة متواصلة\n• ☐ غير مفعَّل — يمكن توزيع الحصص بحرية على مدار اليوم\n• مفيد للأساتذة الذين يفضلون تدريس جميع حصصهم في جلسة واحدة';

  @override
  String get createSubjectEmptyHint =>
      'اختر مستوى واضغط زر + (Ctrl+A/Cmd+A) لإضافة مواد\nإذا كانت المادة تُدرَّس لهذا المستوى، زِد الساعات الأسبوعية، وإلا اتركها عند 0\naقرأ الوثائق للمزيد من المعلومات';

  @override
  String get addSubjectTooltip => 'إضافة مادة (Ctrl+A/Cmd+A)';

  @override
  String get levelSelected => 'محدد ✓';

  @override
  String get levelTapToSelect => 'اضغط للاختيار';

  @override
  String get daySlotHeader => 'اليوم / الفترة';

  @override
  String get breakTime => 'وقت الاستراحة';

  @override
  String get selectLevel => 'اختر المستوى';

  @override
  String get selectLevelToViewClasses => 'اختر مستوى لعرض الفصول.';

  @override
  String get selectClassToStartPinning =>
      'اختر فصلاً من الشريط الجانبي للبدء في تثبيت الفترات.';

  @override
  String get pleaseAddLevelsFirst =>
      'يرجى إضافة المستويات أولاً في الصفحة الرئيسية.';

  @override
  String get pleaseCompleteWorkingDaysConfig =>
      'يرجى إكمال تهيئة أيام العمل والفترات الزمنية في الصفحة الأولى أولاً.';

  @override
  String get templatePlannerSubtitle =>
      'فرض مواد وأساتذة وقاعات محددة. الفصول المثبتة يلتزم بها المولِّد بشكل صارم.';

  @override
  String get clearedOverridesForClass => 'تم مسح التعديلات لهذا الفصل.';

  @override
  String get selectSubjectFirst => 'اختر مادة أولاً';

  @override
  String get noQualifiedTeachersForLevelSubject =>
      'لا يوجد أساتذة مؤهَّلون لهذا المستوى وهذه المادة';

  @override
  String get dayMonday => 'الاثنين';

  @override
  String get dayTuesday => 'الثلاثاء';

  @override
  String get dayWednesday => 'الأربعاء';

  @override
  String get dayThursday => 'الخميس';

  @override
  String get dayFriday => 'الجمعة';

  @override
  String get daySaturday => 'السبت';

  @override
  String get daySunday => 'الأحد';

  @override
  String get whileGeneratingTitle => 'يرجى الانتظار ...';

  @override
  String get whileGeneratingDescription =>
      'بمجرد توليد الجدول، ستُحال إلى صفحة تفاصيل الجدول.\nسيعمل المحلل (الخوارزمية) على الخادم ليجرب جميع التوليفات الممكنة للعثور على الحل الأمثل.\nسيؤدي نقص الموارد إلى حلول ممكنة ولكنها ليست مثالية أو غير ممكنة على الإطلاق.';

  @override
  String get whileGeneratingWarning =>
      'إذا استغرق الأمر وقتاً طويلاً، فهذا يعني أن المحلل سيفشل';

  @override
  String get generatingStatusInitializing => 'جارٍ بدء توليد الجدول...';

  @override
  String get generatingStatusEvaluating => 'جارٍ تقييم القيود...';

  @override
  String get generatingStatusSearching => 'جارٍ البحث عن الجدول الأمثل...';

  @override
  String get generatingStatusOptimizing => 'جارٍ تحسين الجدول الزمني...';

  @override
  String get generatingStatusFinalizing => 'جارٍ إنهاء الجدول...';

  @override
  String estimatedTime(String duration) {
    return 'الوقت المقدر: $duration';
  }

  @override
  String estimatedTimeMinSec(int minutes, int seconds) {
    return '$minutes دقيقة $seconds ثانية';
  }

  @override
  String estimatedTimeSec(int seconds) {
    return '$seconds ثانية';
  }

  @override
  String get homeHeroTitle => 'أنشئ جداول دراسية\nمثالية\nفي دقائق';

  @override
  String get homeHeroSubtitle =>
      'توقف عن الصراع مع جداول الحصص. تُخصّص مدارس تلقائياً الأساتذة والقاعات والفترات الزمنية حتى يحصل كل فصل على الجدول الذي يستحقه — خالٍ من التعارضات.';

  @override
  String get homeInstitutionNotice =>
      'صُمِّم أساساً للمدارس، لكن يمكن استخدامه من قِبَل أي مؤسسة تحتاج إلى جداول زمنية.';

  @override
  String get homeCtaButton => 'إنشاء جدولك الدراسي';

  @override
  String get homeSocialProof => 'مجاني للبدء · لا يلزم حساب';

  @override
  String get homeWeeklySchedulePreview => 'معاينة الجدول الأسبوعي';

  @override
  String get homeFeaturesTitle => 'كل ما تحتاجه لجدولة أذكى';

  @override
  String get homeFeaturesSubtitle =>
      'ميزات قوية في واجهة نظيفة وسهلة الاستخدام.';

  @override
  String get homeFeatureInstantGenerationTitle => 'توليد فوري';

  @override
  String get homeFeatureInstantGenerationDesc =>
      'تعالج خوارزميتنا قيودك وتُنتج جدولاً زمنياً كاملاً وخالياً من التعارضات في ثوانٍ.';

  @override
  String get homeFeatureTeacherRoomTitle => 'إدارة الأساتذة والقاعات';

  @override
  String get homeFeatureTeacherRoomDesc =>
      'أضف الأساتذة وحدّد المواد وخصّص القاعات. يحترم المخطط التوفر والسعة.';

  @override
  String get homeFeatureManualOverridesTitle => 'التعديلات اليدوية';

  @override
  String get homeFeatureManualOverridesDesc =>
      'تحتاج إلى تثبيت فترة معينة؟ استخدم مخطط التعديلات اليدوية لقفل التعيينات مع الحفاظ على تحسين الباقي.';

  @override
  String get homeFeatureExportPdfTitle => 'التصدير إلى PDF';

  @override
  String get homeFeatureExportPdfDesc =>
      'اطبع جدولك أو شاركه بصيغة PDF احترافية بنقرة واحدة — جاهز للوحات الإعلانات أو البريد الإلكتروني للكادر.';

  @override
  String get homeHowItWorksChip => 'كيف يعمل';

  @override
  String get homeHowItWorksTitle =>
      'من الصفحة الفارغة إلى الجدول المنشور\nفي أربع خطوات بسيطة';

  @override
  String get homeStep1Title => 'تحديد القيود الزمنية';

  @override
  String get homeStep1Desc =>
      'اختر أيام العمل وحدد ساعات البداية والنهاية وأشِر إلى فترات الاستراحة.';

  @override
  String get homeStep2Title => 'إضافة الأساتذة والمواد والقاعات';

  @override
  String get homeStep2Desc =>
      'أدخل جميع الأشخاص والموارد التي يحتاجها المخطط للعمل.';

  @override
  String get homeStep3Title => 'التوليد';

  @override
  String get homeStep3Desc =>
      'اضغط توليد وشاهد الخوارزمية تبني جدولاً متوازناً تماماً لكل فصل.';

  @override
  String get homeStep4Title => 'المراجعة والتصدير';

  @override
  String get homeStep4Desc =>
      'افحص النتيجة وطبِّق أي تعديلات يدوية، ثم صدِّر ملف PDF أنيقاً.';

  @override
  String get homeStartForFree => 'ابدأ مجاناً';

  @override
  String get homeBottomCtaTitle => 'هل أنت مستعد لبناء جدولك الأول؟';

  @override
  String get homeBottomCtaSubtitle =>
      'لا يستغرق الأمر سوى بضع دقائق لتهيئة مدرستك ودع الخوارزمية تتولى المهمة الشاقة.';

  @override
  String get homeBottomCtaButton => 'إنشاء جدولك الدراسي الآن';

  @override
  String get homeCopyright => 'Lkout © 2026';

  @override
  String get startFreshTitle => 'بدء من جديد؟';

  @override
  String get startFreshContent =>
      'سيؤدي هذا إلى حذف جميع البيانات المحفوظة بما فيها الأساتذة والمواد والقاعات وإعدادات الجدول. هل أنت متأكد؟';

  @override
  String get deleteAll => 'حذف الكل';

  @override
  String get startFresh => 'بدء من جديد';

  @override
  String get lastGenerated => 'آخر جدول مُولَّد';

  @override
  String get selectWorkingDays => 'اختر أيام الدراسة';

  @override
  String get pleaseSelectOneDayOrderMatters =>
      'يرجى اختيار يوم واحد على الأقل — الترتيب مهم:';

  @override
  String get workingHoursTitle => 'ساعات العمل  (مثال: 8 = 08:00)';

  @override
  String get workingHoursHint =>
      'أدخل الساعة الأولى والأخيرة من اليوم الدراسي.';

  @override
  String get startHourRequired => 'ساعة البداية مطلوبة';

  @override
  String get enterWholeNumber => 'أدخل رقماً صحيحاً';

  @override
  String get mustBeBetween1And22 => 'يجب أن يكون بين 1 و 22';

  @override
  String get startHourLabel => 'من';

  @override
  String get endHourRequired => 'الساعة الدراسية الأخيرة مطلوبة';

  @override
  String get cannotExceed23 => 'لا يمكن تجاوز 23';

  @override
  String get mustBeAfterStartHour => 'يجب أن تكون بعد ساعة البداية';

  @override
  String get endHourLabel => 'إلى';

  @override
  String get timeslotsFormula => 'الفترات = ساعة النهاية − ساعة البداية';

  @override
  String get maxHoursPerStudentPerDay =>
      'الحد الأقصى للساعات لكل طالب في اليوم';

  @override
  String get maxHoursPerDayHint =>
      'لا يمكن جدولة حصص دراسية أكثر من هذا العدد في يوم واحد.';

  @override
  String get pleaseSelectValidValue => 'يرجى اختيار قيمة صالحة (1 أو أكثر)';

  @override
  String get breakHoursTitle => 'ساعات الاستراحة';

  @override
  String get breakHoursHint => 'مثال: الغداء 12:00–14:00 → اختر 12 و 13.';

  @override
  String get pleaseSelectStartAndEndHoursFirst =>
      'يرجى تحديد ساعات البداية والنهاية أولاً';

  @override
  String get breakHourMustBeAfterStartHour =>
      'يجب أن تكون ساعة الاستراحة بعد ساعة البداية';

  @override
  String get breakHourMustBeBeforeEndHour =>
      'يجب أن تكون ساعة الاستراحة قبل ساعة النهاية';

  @override
  String get breakSlots => 'فترات الاستراحة:';

  @override
  String get noBreakHoursSelected => 'لم تُحدَّد ساعات استراحة';

  @override
  String get editSpecificDaySlots => 'تعديل ساعات الدراسة ليوم محدد.';

  @override
  String get clickDayToManageSlots => 'انقر على يوم لإدارة فتراته النشطة.';

  @override
  String get noDaysSelected => 'لم تُحدَّد أيام';

  @override
  String get scheduleSummary => 'ملخص الجدول';

  @override
  String get summaryDaysPerWeek => 'أيام في الأسبوع';

  @override
  String get summaryTimeslotsPerDay => 'فترات / اليوم';

  @override
  String get summaryMaxHoursPerDay => 'أقصى ساعات / اليوم';

  @override
  String get summaryBreakHours => 'ساعات الاستراحة';

  @override
  String get summarySelectedDays => 'الأيام المختارة';

  @override
  String get nextLabel => 'التالي';

  @override
  String get nextStageTooltip => 'المرحلة التالية';

  @override
  String get startByAddingLevels => 'ابدأ بإضافة المستويات';

  @override
  String get addLevelsInstructions =>
      'أضف المستويات أولاً، ثم المواد، ثم القاعات، ثم التعديلات اليدوية';

  @override
  String get addLevels => 'إضافة مستويات';

  @override
  String get levelsColumnHeader => 'المستويات';

  @override
  String get addLevel => 'إضافة مستوى';

  @override
  String get removeLevelTooltip => 'حذف المستوى';

  @override
  String get selectLevelToViewDetailsHeader => 'اختر مستوى لعرض التفاصيل';

  @override
  String detailsForLevel(String level) {
    return 'تفاصيل $level';
  }

  @override
  String get subjectsTaught => 'المواد المدرَّسة';

  @override
  String get assignedTeachers => 'الأساتذة المعيَّنون';

  @override
  String get availableRooms => 'القاعات المتاحة';

  @override
  String get manualOverridesSection => 'التعديلات اليدوية';

  @override
  String get noManualOverridesForLevel =>
      'لا توجد تعديلات يدوية مُهيَّأة لهذا المستوى.';

  @override
  String activeOverrideConstraints(int count) {
    return '$count قيد تعديل نشط مثبَّت لفصول هذا المستوى.';
  }

  @override
  String get pleaseSelectLevelFromLeft =>
      'يرجى اختيار مستوى من اليمين لعرض وإدارة\nمواده وأساتذته وقاعاته.';

  @override
  String get allRoomsForcedNoFreeRooms =>
      'جميع القاعات مخصصة لمواد محددة، مما يتركها بلا قاعات حرة للمواد الأخرى.';

  @override
  String get hasNoTeacher => 'لا يوجد له أستاذ';

  @override
  String needHoursNoQualifiedTeacher(int hours, String subject, String level) {
    return ' $level يحتاج $hours ساعات من \"$subject\" ولا يوجد أستاذ مؤهَّل، أضف أستاذاً للمستوى $level';
  }

  @override
  String notEnoughTeachersContent(
    String subject,
    int required,
    int available,
    int needed,
  ) {
    return 'عدد الأساتذة غير كافٍ لـ $subject!\n\n• المطلوب: $required ساعة\n• الطاقة المتاحة: $available ساعة\n\nفكّر في إضافة ~$needed أستاذ(أساتذة) إضافيين.';
  }

  @override
  String get insufficientRoomsTitle => 'قاعات غير كافية';

  @override
  String get roomCapacityMayBeInsufficient => 'قد تكون طاقة القاعات غير كافية';

  @override
  String get currentRooms => 'القاعات الحالية:';

  @override
  String get predictedNeeded => 'المتوقع الحاجة إليها:';

  @override
  String get totalClassHoursWeek => 'إجمالي ساعات الفصول/الأسبوع:';

  @override
  String get ratioPerRoom => 'النسبة لكل قاعة:';

  @override
  String get schedulerMayFail =>
      'قد يفشل المخطط في إيجاد حل. فكّر في إضافة المزيد من القاعات.';

  @override
  String classesCount(int count) {
    return 'الفصول: $count';
  }

  @override
  String get pdfLockedSlot => 'مغلق';

  @override
  String get pdfDocumentName => 'My_Document';

  @override
  String get settings => 'الإعدادات';

  @override
  String get print => 'طباعة';

  @override
  String get tryAgain => 'حاول مجدداً';

  @override
  String get noScheduleDataGoHome =>
      'لم يتم العثور على بيانات الجدول. جارٍ العودة إلى الرئيسية...';

  @override
  String get selectAClass => 'اختر فصلاً';

  @override
  String get selectClassToViewSchedule =>
      'اختر فصلاً من القائمة لعرض جدوله الزمني.';

  @override
  String get scheduleGenerationFailed => 'فشل إنشاء الجدول الزمني.';

  @override
  String get generalCategory => 'عام';

  @override
  String get noDetailsProvided => 'لا توجد تفاصيل.';

  @override
  String get noFurtherDiagnostics => 'لا توجد تشخيصات إضافية.';

  @override
  String solutionHint(String hint) {
    return 'تلميح: $hint';
  }

  @override
  String clsCount(int count) {
    return '$count فصل/فصول';
  }

  @override
  String get saveExit => 'حفظ والخروج';

  @override
  String get clickToAddHeaderImage => 'انقر لإضافة صورة الرأس';

  @override
  String get name => 'الاسم';

  @override
  String get close => 'إغلاق';

  @override
  String get dearUser => 'عزيزي المستخدم';

  @override
  String get paymentWorkInProgress =>
      'منصة الدفع قيد التطوير حاليًا. يرجى التواصل معنا مباشرةً لإتمام عملية الشراء.';

  @override
  String get paymentIntegrationMessage =>
      'لا نزال نعمل على دمج نظام الدفع.\nنعتذر عن الإزعاج. سنعود قريباً بحل أفضل. شكراً لصبرك.';

  @override
  String get contactEmail => 'البريد الإلكتروني: abdoullouahd@gmail.com';

  @override
  String get contactPhone => 'الهاتف: 212628503463+';

  @override
  String get thankYouForUnderstanding => 'شكراً لتفهمك!';

  @override
  String get amountDisplay => 'المبلغ: 299 درهم';

  @override
  String feesDisplay(String fees) {
    return 'الرسوم: $fees درهم';
  }

  @override
  String totalDisplay(String total) {
    return 'المجموع: $total درهم';
  }

  @override
  String paymentFailed(String error) {
    return 'فشل الدفع: $error';
  }

  @override
  String get unlockFullPotential => 'أطلق الإمكانات الكاملة';

  @override
  String get fullAccessDescription =>
      'احصل على وصول كامل لجميع الميزات وأنشئ جداول غير محدودة.';

  @override
  String get getFullAccess => 'احصل على وصول كامل لجدولك بدون قيود.';

  @override
  String get premiumAccess => 'الوصول المميز';

  @override
  String get perEightMonths => '/ 8 أشهر';

  @override
  String get featureRemoveLockedSlots => 'إزالة الخانات المقفلة';

  @override
  String get featureExportPdf => 'تصدير إلى PDF';

  @override
  String get featureAnyDevice => 'الوصول من أي جهاز';

  @override
  String get featureManualOverrides => 'التجاوزات اليدوية';

  @override
  String get featurePrioritySupport => 'دعم الأولوية';

  @override
  String get removeLockedSlots => 'إزالة جميع الخانات المقفلة';

  @override
  String get exportPdf => 'تصدير الجدول إلى PDF عالي الجودة';

  @override
  String get anyDevice => 'احصل على جدولك على أي جهاز';

  @override
  String get advancedOverrides => 'تجاوزات يدوية متقدمة';

  @override
  String get prioritySupport => 'دعم العملاء ذو الأولوية';

  @override
  String get upgradeNow => 'ترقية الآن';

  @override
  String get maybeLater => 'ربما لاحقاً';

  @override
  String get demoLimitTitle => 'تم بلوغ حد النسخة التجريبية';

  @override
  String get demoLimitContent =>
      'النسخة التجريبية تدعم فقط الجداول التي تحتوي على أقل من 30 قسمًا. سجّل دخولك أو قم بالترقية إلى النسخة المميزة لإنشاء جداول بـ 30 قسمًا أو أكثر.';

  @override
  String get signInOrUpgrade => 'تسجيل الدخول / الترقية';

  @override
  String get segtimetableDescription =>
      'منصة حديثة لإدارة الجداول الدراسية بسهولة وكفاءة.';

  @override
  String get featureTimetablesTitle => 'الجداول الدراسية';

  @override
  String get featureTimetablesDesc => 'أنشئ الجداول الدراسية وأدرها بسهولة.';

  @override
  String get featureSecureTitle => 'آمن وموثوق';

  @override
  String get featureSecureDesc => 'معلوماتك محمية ومخزنة بأمان.';

  @override
  String get featureSaveTimeTitle => 'توفير الوقت';

  @override
  String get featureSaveTimeDesc =>
      'نظّم الجداول بشكل أسرع من خلال سير عمل مبسّط.';

  @override
  String get featureSimpleTitle => 'تجربة بسيطة';

  @override
  String get featureSimpleDesc => 'واجهة بديهية مصممة للجميع.';

  @override
  String get segtimetableQuote => 'ننظم الجداول... لتتفرغوا للتعليم.';

  @override
  String get signInSubtitle => 'مرحبًا بعودتك! يرجى تسجيل الدخول إلى حسابك.';

  @override
  String get signUpSubtitle => 'أنشئ حسابك بملء المعلومات أدناه.';

  @override
  String get requestTimedOut =>
      'استغرق الطلب وقتًا طويلاً. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';

  @override
  String get unexpectedError => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get resetPasswordSuccess =>
      'إذا كان هناك حساب مرتبط بهذا البريد الإلكتروني، فقد تم إرسال رابط إعادة التعيين.';

  @override
  String get warning => 'تحذير';

  @override
  String get eraseSavedScheduleWarning =>
      'سيؤدي إنشاء جدول جديد إلى مسح الجدول المحفوظ.';

  @override
  String get impossibleToRecreate =>
      'من المستحيل تقريبًا إنشاء نفس الجدول مرتين.';

  @override
  String get sureToContinue => 'هل أنت متأكد أنك تريد الاستمرار؟';

  @override
  String get loadLastCreatedSchedule => 'تحميل آخر جدول تم إنشاؤه';

  @override
  String get pricing => 'الأسعار';

  @override
  String get aboutUs => 'من نحن';

  @override
  String get exitCreator => 'الخروج من صانع الجداول';

  @override
  String get exitConfirmMessage =>
      'هل أنت متأكد أنك تريد الخروج؟ ستفقد التغييرات غير المحفوظة.';

  @override
  String get exitBtn => 'خروج';

  @override
  String get hintStartHour => 'مثال: 8';

  @override
  String get hintEndHour => 'مثال: 17';

  @override
  String get validationLevelNameRequired => 'اسم المستوى مطلوب';

  @override
  String get validationLevelAlreadyExists => 'هذا المستوى موجود بالفعل';

  @override
  String get validationClassesRequired => 'عدد الأقسام مطلوب';

  @override
  String get labelLevelName => 'اسم المستوى';

  @override
  String get hintLevelName => 'مثال: ابتدائي 1';

  @override
  String get labelNumberOfClasses => 'عدد الأقسام';

  @override
  String get hintNumberOfClasses => 'مثال: 3';

  @override
  String get validationSubjectNameRequired => 'اسم المادة مطلوب';

  @override
  String get validationSubjectAlreadyExists => 'المادة موجودة بالفعل';

  @override
  String get hintSubjectName => 'مثال: الرياضيات';

  @override
  String get validationNonNegativeNumber => 'أدخل رقماً غير سالب';

  @override
  String get validationCommaSeparatedNumbers => 'أدخل أرقاماً مفصولة بفواصل';

  @override
  String get subjectColor => 'لون المادة';

  @override
  String get advancedParameters => 'إعدادات متقدمة';

  @override
  String get minimumRestHours => 'الحد الأدنى لساعات الراحة';

  @override
  String get avoidHours => 'الساعات التي يجب تجنبها';

  @override
  String get avoidHoursHint => 'اختياري، مثال: 1، 3، 5';

  @override
  String get validationRoomAlreadyExists => 'القاعة موجودة بالفعل';

  @override
  String get hintRoomName => 'مثال: قاعة 101';

  @override
  String get validationNumberOfRoomsRequired => 'عدد القاعات مطلوب';

  @override
  String get titleUpdateMinutes => 'تحديث الدقائق';

  @override
  String get labelMinutes => 'الدقائق';

  @override
  String get btnUpdate => 'تحديث';

  @override
  String get isNotScheduled => 'غير مجدول';

  @override
  String lessThanNClasses(int count) {
    return 'أقل من $count قسم';
  }

  @override
  String approxNStudents(int count) {
    return 'حوالي $count طالب';
  }

  @override
  String get contactUsForAgreement => 'اتصل بنا لتحديد اتفاقية';

  @override
  String get titleSchoolBasic => 'المستوى الأساسي';

  @override
  String get titleSchoolStandard => 'المستوى القياسي';

  @override
  String get titleSchoolPremium => 'المستوى المميز';

  @override
  String get titleCustomAgreement => 'اتفاقية خاصة';

  @override
  String get badgePopular => 'شائع';

  @override
  String get priceAgreement => 'اتفاقية';

  @override
  String get featureFlexibleClassCounts => 'عدد مرن من الأقسام';

  @override
  String get featureFlexibleStudentCounts => 'عدد مرن من الطلاب';

  @override
  String get featureExamCorrection => 'تصحيح الامتحانات';

  @override
  String get featureAbsenceManagement => 'إدارة الغيابات';

  @override
  String get featureLessonsPlanner => 'مخطط الدروس';

  @override
  String get btnContactUs => 'اتصل بنا';

  @override
  String get licenseError => 'خطأ في الترخيص';

  @override
  String get getALicense => 'الحصول على ترخيص';

  @override
  String get goHome => 'الذهاب للرئيسية';

  @override
  String routeNotFound(String uri) {
    return 'المسار غير موجود: $uri';
  }

  @override
  String get aboutHomeTooltip => 'الرئيسية';

  @override
  String get aboutAppBarTitle => 'حول Seg-Dude';

  @override
  String get aboutHeroChip => 'قصتنا';

  @override
  String get aboutHeroTitle => 'حول Seg-Dude';

  @override
  String get aboutHeroSubtitle => 'تبسيط إدارة المدارس عبر تقنية حديثة وذكية.';

  @override
  String get aboutScrollToExplore => 'مرّر للاستكشاف';

  @override
  String get aboutWhoWeAreChip => 'من نحن';

  @override
  String get aboutWhoWeAreTitle => 'من نحن';

  @override
  String get aboutWhoWeAreDescription =>
      'Seg-Dude منصة حديثة لإدارة المدارس مصممة لتبسيط العمليات اليومية للمؤسسات التعليمية. هدفنا تقديم حل فعّال وآمن وسهل الاستخدام يربط إداريي المدارس والمعلمين والطلاب وأولياء الأمور من خلال تجربة رقمية بديهية.';

  @override
  String get aboutOurMissionTitle => 'مهمتنا';

  @override
  String get aboutOurMissionDescription =>
      'مهمتنا تسهيل إدارة المدارس من خلال أدوات رقمية عملية تعزز التنظيم وتبسّط الجدولة وتدعم بيئة تعليمية أفضل للمدارس.';

  @override
  String get aboutWhatWeOfferChip => 'ما نقدمه';

  @override
  String get aboutWhatWeOfferTitle => 'ما نقدمه';

  @override
  String get aboutFeatureTeacherManagementTitle => 'إدارة المعلمين';

  @override
  String get aboutFeatureTeacherManagementDesc =>
      'تنظيم ملفات المعلمين وتوفرهم وأعباء عملهم.';

  @override
  String get aboutFeatureClassSchedulingTitle => 'جدولة الحصص';

  @override
  String get aboutFeatureClassSchedulingDesc =>
      'إنشاء جداول خالية من التعارض ببضع نقرات.';

  @override
  String get aboutFeatureSimpleInterfaceTitle => 'واجهة بسيطة وحديثة';

  @override
  String get aboutFeatureSimpleInterfaceDesc =>
      'تجربة واضحة مصممة لموظفي المدارس في حياتهم اليومية.';

  @override
  String get aboutFeatureFastWorkflowTitle => 'سير عمل سريع ومنظم';

  @override
  String get aboutFeatureFastWorkflowDesc =>
      'تقليل العمل اليدوي وإبقاء كل شيء في مكان واحد.';

  @override
  String get aboutComingSoonChip => 'قريباً';

  @override
  String get aboutWhatsNextTitle => 'ما التالي';

  @override
  String get aboutComingSoonIntro =>
      'Seg-Dude في تطور مستمر. إليكم لمحة عما نعمل عليه بعد.';

  @override
  String get aboutComingSoonFooter =>
      'Seg-Dude في تطور مستمر. نعمل على ميزات جديدة ستجعل إدارة المدارس أكثر ذكاءً وكفاءة.';

  @override
  String get aboutSoonBadge => 'قريباً';

  @override
  String get aboutComingSoonStudentManagementTitle => 'إدارة الطلاب';

  @override
  String get aboutComingSoonStudentManagementDesc =>
      'ملفات وسجلات كاملة للطلاب في مكان واحد.';

  @override
  String get aboutComingSoonAttendanceTitle => 'نظام الحضور';

  @override
  String get aboutComingSoonAttendanceDesc => 'تتبع الحضور والغياب بسهولة.';

  @override
  String get aboutComingSoonGradeManagementTitle => 'إدارة الدرجات';

  @override
  String get aboutComingSoonGradeManagementDesc => 'تسجيل وتحليل أداء الطلاب.';

  @override
  String get aboutComingSoonParentPortalTitle => 'بوابة أولياء الأمور';

  @override
  String get aboutComingSoonParentPortalDesc =>
      'إبقاء أولياء الأمور على اطلاع ومشاركة فعّالة.';

  @override
  String get aboutComingSoonNotificationsTitle => 'الإشعارات';

  @override
  String get aboutComingSoonNotificationsDesc =>
      'تنبيهات في الوقت المناسب للطاقم والطلاب وأولياء الأمور.';

  @override
  String get aboutComingSoonAiToolsTitle =>
      'أدوات تعليمية مدعومة بالذكاء الاصطناعي';

  @override
  String get aboutComingSoonAiToolsDesc =>
      'مساعدة ذكية للمهام المدرسية اليومية.';

  @override
  String get aboutOurVisionTitle => 'رؤيتنا';

  @override
  String get aboutOurVisionDescription =>
      'نتطلع إلى مستقبل تستطيع فيه كل مؤسسة تعليمية إدارة أنشطتها اليومية بكفاءة عبر تقنية مبتكرة توفر الوقت وتقلل التعقيد وتدعم النجاح الأكاديمي.';

  @override
  String get aboutOurValuesChip => 'قيمنا';

  @override
  String get aboutOurValuesTitle => 'قيمنا';

  @override
  String get aboutValueInnovationTitle => 'الابتكار';

  @override
  String get aboutValueInnovationDesc =>
      'جلب التقنية الحديثة لتلبية احتياجات المدارس اليومية.';

  @override
  String get aboutValueSimplicityTitle => 'البساطة';

  @override
  String get aboutValueSimplicityDesc => 'أدوات بديهية وسهلة الاستخدام.';

  @override
  String get aboutValueReliabilityTitle => 'الموثوقية';

  @override
  String get aboutValueReliabilityDesc =>
      'بناء حلول يمكن للمدارس الاعتماد عليها.';

  @override
  String get aboutValueSecurityTitle => 'الأمان';

  @override
  String get aboutValueSecurityDesc =>
      'حماية بيانات المدرسة والطلاب في كل خطوة.';

  @override
  String get aboutStayConnectedChip => 'ابقَ على تواصل';

  @override
  String get aboutConnectWithUsTitle => 'تابعنا';

  @override
  String get connectWithUsTitle => 'تواصل معنا';

  @override
  String get supportTitle => 'الدعم';

  @override
  String get supportSubtitle =>
      'لديكم أسئلة أو تحتاجون مساعدة؟ تواصلوا معنا مباشرةً.';

  @override
  String get emailUs => 'راسلنا عبر البريد الإلكتروني';

  @override
  String get sendUsEmailMessage =>
      'راسلنا عبر البريد الإلكتروني وسنقوم بالرد عليك في أقرب وقت ممكن';

  @override
  String get aboutConnectWithUsSubtitle =>
      'تابع Seg-Dude للحصول على شروحات وتحديثات المنتج وإعلانات ومحتوى تعليمي جديد.';

  @override
  String get aboutYouTubePlatform => 'YouTube';

  @override
  String get aboutYouTubeActionLabel => 'زيارة القناة';

  @override
  String get aboutYouTubeDescription =>
      'شاهد الشروحات وعروض الميزات والتحديثات ومقاطع الفيديو القادمة.';

  @override
  String get aboutInstagramPlatform => 'Instagram';

  @override
  String get aboutInstagramActionLabel => 'تابعنا';

  @override
  String get aboutInstagramDescription =>
      'تابعنا للأخبار والإعلانات وما خلف الكواليس ومحتوى المجتمع.';

  @override
  String get aboutCopyright => '© 2026 Seg-Dude. جميع الحقوق محفوظة.';

  @override
  String get aboutBackToHome => 'العودة إلى الرئيسية';

  @override
  String get groups => 'المجموعات';

  @override
  String get groupsAreAssignedToAClass => 'المجموعات مرتبطة بفصل دراسي';

  @override
  String get groupsSplitClsIntoGroups => 'قسم الفصل الى مجموعات';

  @override
  String get groupsSelectClassToSplit =>
      'الرجاء اختيار فصل للقسمة، انقر على زر الإضافة.';

  @override
  String get groupsAddSubjectFirst => 'الرجاء إنشاء المواد اولا';

  @override
  String get groupsAdd => 'أضف مجموعة';

  @override
  String get groupsApplyToOthers => 'تطبيق على الفصول الاخرى';

  @override
  String get groupsApplyToOthersDesc =>
      'هل تريد تطبيق نفس القيد على جميع الفصول في نفس المستوى؟';

  @override
  String get groupsNotConf => 'لم يتم تكوين المجموعات بعد';

  @override
  String get groupsMerge => 'دمج الفصول';

  @override
  String get groupsMergeClasses => 'دمج الفصول في مجموعة واحدة';

  @override
  String get groupsSelectClassesToMerge =>
      'اختر فصلين على الأقل من هذا المستوى.';

  @override
  String get groupsMergeWarningTitle => 'تم العثور على مجموعات مقسمة';

  @override
  String get groupsMergeWarning =>
      'بعض الفصول المحددة لديها مجموعات مقسمة لهذه المادة. سيؤدي الدمج إلى إزالة قيود تقسيم المجموعات. هل تريد المتابعة؟';

  @override
  String get groupsSelectTeacherFirstToMerge => 'اختر معلمًا أولاً';

  @override
  String get groupsNoClassesForTeacherSubject =>
      'لا توجد فصول مؤهلة لهذا المعلم وهذه المادة';

  @override
  String groupsClassesSelectedCount(int count) {
    return 'تم تحديد $count فصول';
  }

  @override
  String get groupsMergeSummary => 'الملخص';

  @override
  String get groupsMergeSuccessMessage => 'تم دمج الفصول بنجاح';

  @override
  String get groupsSelectSubjectToMerge => 'اختر المادة المعنية بهذا الدمج';

  @override
  String get groupsSelectTeacherToMerge => 'اختر المعلم المسؤول عن هذه المادة';

  @override
  String get groupsNoTeacherAssignedForSubject =>
      'لا يوجد معلم مخصص لهذه المادة — يمكنك مع ذلك دمج فصولها';

  @override
  String get groupsNoTeacherAssignedShort => 'لا يوجد معلم مخصص';

  @override
  String get groupsNoQualifiedTeacherMergeBlocked =>
      'لا يوجد معلم مؤهل لهذه المادة في هذا المستوى — الدمج غير متاح';

  @override
  String get deleteSubjectWarning =>
      'سيتم أيضاً حذف المعلمين والمجموعات المرتبطة بهذا الموضوع.';

  @override
  String get number => 'عدد';

  @override
  String get id => '(id)الهوية';

  @override
  String get grouping => 'التفويج';

  @override
  String get notes => 'ملاحظات';

  @override
  String get noMatchingRecordsFound => 'لا توجد نتائج تطابق خيارات البحث';

  @override
  String get supervisor => 'المشرف';

  @override
  String get loadFromFile => 'تحميل من ملف';

  @override
  String get noSavedScheduleFound => 'لم يتم العثور على جدول محفوظ';

  @override
  String get clickToCreateNewSchedule => 'انقر هنا لإنشاء جدول جديد';

  @override
  String get creationOptions => 'خيارات لإنشاء جدول زمني جديد';

  @override
  String get chooseHowCreate => 'اختر كيفية إنشاء جدولك الجديد.';

  @override
  String get collapse => 'اخفاء الشريط الجانبي';

  @override
  String get noGaps => 'أنشئ جدولًا زمنيًا بدون فجوات (منحاز للطالب)';

  @override
  String get teacherBias =>
      'أنشئ جدولًا زمنيًا بمجموعات من المعلمين (منحاز للمعلم)';

  @override
  String get studFirst => 'الطالب اولا';

  @override
  String get teacherFirst => 'المعلم اولا';

  @override
  String get ifNoneSelected => '( إذا لم يتم تحديد أي قسم، إذن الكل)';

  @override
  String get ifSubjetMultiTeachers =>
      'إذا كان للمادة أكثر من معلم، يتم تطبيق نظام الفترات والمجموعات.';

  @override
  String get teachersCoexist =>
      'قد يتواجد معلمو مادة معينة في المدرسة خلال نفس الفترة.';

  @override
  String get licenseWarning => 'البيانات قد تكون غير صحيحة بدون رخصة .';

  @override
  String get licenseWarningDesc =>
      'يرجى الحصول على ترخيص للحصول على بيانات صحيحة.';

  @override
  String get schoolSeason => 'الموسم الدراسي';

  @override
  String get subjRequireRooms => 'المادة تتطلب قاعة';

  @override
  String get freeResourcesTabTitle => 'الموارد المتاحة';

  @override
  String freeResourcesForLevel(String level) {
    return 'الموارد المتاحة - المستوى $level';
  }

  @override
  String get freeClassesLabel => 'الفصول المتاحة';

  @override
  String get freeQualifiedTeachersLabel => 'الأساتذة المتاحون';

  @override
  String get freeRoomsLabel => 'القاعات المتاحة';

  @override
  String get noneLabel => 'لا يوجد';

  @override
  String get noFreeSlotsThisDay => 'لا توجد حصص متاحة في هذا اليوم';

  @override
  String get noFreeSlotsAvailable => 'لا توجد حصص متاحة';

  @override
  String get freeForAllClasses => 'جميع المستويات متاحة';

  @override
  String get freeForLevelClasses => 'المستوى بأكمله متاح';

  @override
  String get freeForSomeClasses => 'بعض الفصول متاحة';

  @override
  String levelNumberFallback(String id) {
    return 'المستوى $id';
  }

  @override
  String get tapLevelForDetailsHint =>
      'اضغط على مستوى لعرض الأساتذة والقاعات المتاحة';

  @override
  String forcedSubjectInAllowedRooms(String subjectName, String roomName) {
    return 'المادة $subjectName مخصصة لقاعة محددة، ولكنها تظهر في المواد المسموح بها في $roomName. المتابعة ستؤدي إلى إزالة $subjectName من المواد المسموح بها في $roomName.';
  }
}
