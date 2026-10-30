// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get languageEndonym => 'العربية';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get offlineBar => 'غير متصل. نعرض ما حفظه هذا الجهاز؛ لن تُحفظ التغييرات حتى تعود إلى الاتصال.';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonClear => 'مسح';

  @override
  String get iconChoose => 'اختر رمزًا';

  @override
  String get iconNone => 'بلا رمز';

  @override
  String get iconSearchHint => 'ابحث أو اكتب أي إيموجي';

  @override
  String get iconUseTyped => 'استخدم هذا الإيموجي';

  @override
  String get iconNoMatch => 'لا توجد رموز مطابقة. اكتب إيموجي لاستخدامه.';

  @override
  String get iconSectionTravel => 'السفر والأماكن';

  @override
  String get iconSectionFood => 'الطعام والشراب';

  @override
  String get iconSectionActivities => 'الأنشطة';

  @override
  String get iconSectionHome => 'المنزل والفواتير';

  @override
  String get iconSectionPeople => 'الأشخاص';

  @override
  String get iconSectionNature => 'الحيوانات والطبيعة';

  @override
  String get iconSectionObjects => 'المال والأشياء';

  @override
  String get iconSectionSymbols => 'الرموز';

  @override
  String get commonRemove => 'إزالة';

  @override
  String get commonUndo => 'تراجع';

  @override
  String get someone => 'شخص ما';

  @override
  String get errorTooLarge => 'حجم الملف كبير جدًا لإرساله إلى الخادم.';

  @override
  String get errorBusy => 'الخادم مشغول. حاول مجددًا بعد قليل.';

  @override
  String get errorTimeout => 'استغرق الإرسال وقتًا طويلًا. تحقق من اتصالك وحاول مجددًا.';

  @override
  String get errorBadOrigin =>
      'لا يقبل الخادم تسجيل الدخول من هذا العنوان. على مشغّله التحقق من عنوانه العام.';

  @override
  String get errorInvalidCategory => 'حُذفت هذه الفئة للتو. اختر فئة أخرى.';

  @override
  String get errorBuiltinCategory => 'يمكن إخفاء الفئات المضمنة فقط.';

  @override
  String get errorUnknownMember => 'لم يعد أحد الأشخاص في هذه المجموعة عضوًا فيها. أعد التحميل وحاول مجددًا.';

  @override
  String get errorNoPayers => 'اختر من دفع.';

  @override
  String get errorPayerTotal => 'يجب أن يساوي مجموع ما دفعه كل شخص المبلغ الإجمالي.';

  @override
  String get errorPayerTooSmall =>
      'أصبح نصيب أحد الأشخاص من المبلغ المدفوع صفرًا بعملة المجموعة. تحقق من المبالغ.';

  @override
  String get errorInvalidNote => 'الملاحظة طويلة جدًا أو تحتوي على أحرف لا يمكن حفظها.';

  @override
  String get errorInvalidDate => 'هذا التاريخ خارج النطاق المسموح.';

  @override
  String get errorGeneric => 'حدث خطأ. حاول مجددًا.';

  @override
  String get errorNetwork => 'تعذر الاتصال بالخادم. تحقق من اتصالك.';

  @override
  String get errorNotFound => 'لم يعد هذا موجودًا.';

  @override
  String get errorRequired => 'مطلوب';

  @override
  String get errorInvalidName => 'أدخل اسمًا لا يتجاوز 100 حرف.';

  @override
  String get errorDuplicateName => 'هناك شخص بهذا الاسم في المجموعة بالفعل.';

  @override
  String get errorTooManyMembers => 'بلغت المجموعة الحد الأقصى لعدد الأشخاص.';

  @override
  String get errorTooManyCategories => 'بلغت المجموعة الحد الأقصى لعدد الفئات.';

  @override
  String get errorDuplicateCategory => 'توجد في المجموعة فئة بهذا الاسم بالفعل.';

  @override
  String get errorInvalidCurrency => 'أدخل رمز عملة من ثلاثة أحرف، مثل USD.';

  @override
  String get errorInvalidTitle => 'أدخل عنوانًا لا يتجاوز 200 حرف.';

  @override
  String get errorInvalidLocation => 'أدخل اسم مكان من سطر واحد، لا يتجاوز 200 حرف.';

  @override
  String get errorInvalidSymbol => 'أدخل رمزًا لا يتجاوز 8 أحرف.';

  @override
  String get errorInvalidEmoji => 'اختر إيموجي واحدًا ليكون الرمز.';

  @override
  String get errorMemberHasBalance => 'سوِّ رصيد هذا الشخص قبل إزالته.';

  @override
  String get errorVersionConflict =>
      'غيّر شخص آخر هذا المصروف أثناء تعديله. أعد التحميل للاطلاع على تغييراته.';

  @override
  String get errorSignInRequired => 'سجّل الدخول للقيام بذلك.';

  @override
  String get errorRateLimited => 'طلبات كثيرة جدًا. انتظر دقيقة ثم حاول مجددًا.';

  @override
  String get errorNotAMember => 'لست عضوًا في هذه المجموعة بعد.';

  @override
  String get errorNotAllowed => 'يمكن لهذا الشخص أو مالك المجموعة وحده القيام بذلك.';

  @override
  String get errorLinkGroupsOff => 'لا يسمح هذا الخادم بفتح المجموعات باستخدام الرابط وحده.';

  @override
  String get errorMemberClaimed => 'انضم شخص بالفعل بصفته هذا العضو.';

  @override
  String get errorMemberLeft => 'غادر شخص هذه المجموعة.';

  @override
  String get errorInvalidEmail => 'أدخل عنوان بريد إلكتروني.';

  @override
  String get errorInvalidPassword => 'استخدم من 8 إلى 200 حرف.';

  @override
  String get errorEmailTaken => 'يوجد حساب بهذا البريد الإلكتروني بالفعل. سجّل الدخول بدلًا من ذلك.';

  @override
  String get errorSignupClosed => 'لا يقبل هذا الخادم إنشاء حسابات جديدة.';

  @override
  String get errorInvalidCredentials => 'البريد الإلكتروني وكلمة المرور غير متطابقين.';

  @override
  String get errorWrongPassword => 'كلمة المرور الحالية غير صحيحة.';

  @override
  String get errorAccountsOff => 'لا يستخدم هذا الخادم الحسابات.';

  @override
  String get errorInvalidAmount => 'أدخل مبلغًا أكبر من صفر.';

  @override
  String get errorTooManyDecimals => 'عدد الخانات العشرية أكبر من المسموح لهذه العملة.';

  @override
  String get errorAmountTooLarge => 'هذا المبلغ كبير جدًا.';

  @override
  String get errorNoShares => 'اختر شخصًا واحدًا على الأقل لتقسيم التكلفة.';

  @override
  String get errorInvalidShare => 'يجب أن تكون كل حصة رقمًا.';

  @override
  String get errorExactTotal => 'يجب أن يساوي مجموع المبالغ الإجمالي.';

  @override
  String get errorPayersTotal => 'يجب أن يساوي مجموع ما دفعه الجميع الإجمالي.';

  @override
  String get categoryFood => 'الطعام والشراب';

  @override
  String get categoryGroceries => 'مشتريات البقالة';

  @override
  String get categoryTransport => 'المواصلات';

  @override
  String get categoryTravel => 'السفر';

  @override
  String get categoryLodging => 'الإقامة';

  @override
  String get categoryRent => 'الإيجار';

  @override
  String get categoryUtilities => 'الخدمات';

  @override
  String get categoryEntertainment => 'الترفيه';

  @override
  String get categoryShopping => 'التسوق';

  @override
  String get categoryHealth => 'الصحة';

  @override
  String get categoryGifts => 'الهدايا';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get groupNew => 'مجموعة جديدة';

  @override
  String get groupSwitch => 'تبديل المجموعة';

  @override
  String get groupReorder => 'اسحب لإعادة الترتيب';

  @override
  String get groupCreate => 'إنشاء مجموعة';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخص',
      many: '$count شخصًا',
      few: '$count أشخاص',
      two: '$count شخصان',
      one: 'شخص واحد',
      zero: '$count أشخاص',
    );
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return 'لك $amount';
  }

  @override
  String pillOwe(String amount) {
    return 'عليك $amount';
  }

  @override
  String get pillSettled => 'تمت التسوية';

  @override
  String get groupMissingTitle => 'المجموعة غير موجودة';

  @override
  String get groupMissingBody =>
      'حُذفت هذه المجموعة أو أُعيد تعيين رابطها. اطلب الرابط الجديد من أحد أفراد المجموعة.';

  @override
  String get groupLockedTitle => 'سجّل الدخول لفتح هذه المجموعة';

  @override
  String get groupLockedBody => 'هذه المجموعة متاحة فقط لحسابات أعضائها. سجّل الدخول إلى الحساب المرتبط بها.';

  @override
  String get groupForget => 'إزالة من هذا الجهاز';

  @override
  String get groupLinkOtherServer => 'هذا الرابط تابع لخادم آخر. اتصل بذلك الخادم لفتحه.';

  @override
  String get openLinkTitle => 'افتح رابط مجموعة';

  @override
  String get openLinkBody => 'الصق رابطًا أرسله إليك أحدهم للانضمام إلى مجموعته.';

  @override
  String get openLinkLabel => 'رابط المجموعة';

  @override
  String get openLinkAction => 'فتح';

  @override
  String get openLinkInvalid => 'لا يبدو هذا رابط مجموعة في Balnana.';

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String get groupNameHint => 'رحلة إلى لشبونة';

  @override
  String get groupCurrency => 'العملة';

  @override
  String get groupCurrencyHelp => 'تُستخدم هذه العملة لكل مصروفات المجموعة. لا يمكن تغييرها لاحقًا.';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name. تُستخدم هذه العملة لكل مصروفات المجموعة. لا يمكن تغييرها لاحقًا.';
  }

  @override
  String get currencyChoose => 'اختر عملة';

  @override
  String get currencySearchHint => 'ابحث بالرمز أو الاسم';

  @override
  String get currencySuggested => 'مقترحة';

  @override
  String get currencyAll => 'كل العملات';

  @override
  String currencyUseTyped(String code) {
    return 'استخدم $code';
  }

  @override
  String get currencyNoMatch => 'لا توجد عملة مطابقة. اكتب رمزها المكوّن من ثلاثة أحرف لاستخدامها.';

  @override
  String get groupSymbol => 'الرمز';

  @override
  String get groupSymbolChoose => 'اختر رمزًا';

  @override
  String groupSymbolExample(String example) {
    return 'تظهر المبالغ هكذا: $example';
  }

  @override
  String get groupColor => 'اللون';

  @override
  String colorSwatch(int number, int count) {
    return 'اللون $number من $count';
  }

  @override
  String get groupPeople => 'الأشخاص';

  @override
  String get groupYourName => 'اسمك';

  @override
  String groupPersonName(int number) {
    return 'الشخص $number';
  }

  @override
  String get groupAddPerson => 'إضافة شخص';

  @override
  String get groupPeopleHelp => 'يمكنك إضافة أشخاص لاحقًا، أو يمكنهم الانضمام عبر الرابط.';

  @override
  String get identityTitle => 'من أنت؟';

  @override
  String get identityBody => 'اختر اسمك ليعرض Balnana ما عليك. هذا الجهاز وحده سيتذكره.';

  @override
  String get identityNew => 'أنا شخص جديد';

  @override
  String get identityNewTitle => 'انضم إلى هذه المجموعة';

  @override
  String get identityJoin => 'انضمام';

  @override
  String get identityChange => 'تغيير هويتك';

  @override
  String get identityNone => 'لم تختر بعد';

  @override
  String get memberName => 'الاسم';

  @override
  String memberYou(String name) {
    return '$name (أنت)';
  }

  @override
  String get memberAdd => 'إضافة شخص';

  @override
  String get memberAddTitle => 'إضافة شخص';

  @override
  String get memberRename => 'إعادة تسمية';

  @override
  String get memberRenameTitle => 'إعادة تسمية';

  @override
  String memberRemoveTitle(String name) {
    return 'إزالة $name؟';
  }

  @override
  String get memberRemoveBody =>
      'سيبقى هذا الشخص في المصروفات السابقة، لكن لن يمكن إضافته إلى مصروفات جديدة.';

  @override
  String get groupLinkCopied => 'نُسخ الرابط. يمكن لأي شخص لديه الرابط فتح هذه المجموعة.';

  @override
  String get groupShare => 'مشاركة الرابط';

  @override
  String get groupSettings => 'إعدادات المجموعة';

  @override
  String get groupEdit => 'تعديل المجموعة';

  @override
  String get groupSharing => 'المشاركة';

  @override
  String get groupCopyLink => 'نسخ الرابط';

  @override
  String get groupQrCode => 'إظهار رمز QR';

  @override
  String get groupQrCodeHelp => 'دع الآخرين يمسحون الرابط بكاميرا هواتفهم.';

  @override
  String groupQrLabel(String group) {
    return 'رمز QR لرابط $group';
  }

  @override
  String get groupCopyLinkHelp => 'يمكن لأي شخص لديه الرابط رؤية هذه المجموعة وتعديلها.';

  @override
  String get groupCopyLinkHelpAccounts => 'يمكن لمن لديه الرابط طلب الانضمام بعد تسجيل الدخول.';

  @override
  String get linkAccessTitle => 'متاحة لكل من لديه الرابط';

  @override
  String get linkAccessHelp => 'السماح للآخرين بالعرض والتعديل دون حساب';

  @override
  String get resetLinkTitle => 'إعادة تعيين الرابط';

  @override
  String get resetLinkHelp => 'إنشاء رابط جديد؛ سيتوقف القديم عن العمل';

  @override
  String get resetLinkBody =>
      'سيتوقف الرابط الحالي عن العمل لدى الجميع. شارك الرابط الجديد مع من تريد إبقاء إمكانية الوصول لديهم.';

  @override
  String get resetLinkAction => 'إعادة تعيين';

  @override
  String get resetLinkDone => 'أُعيد تعيين الرابط. شارك الرابط الجديد.';

  @override
  String get groupThisDevice => 'هذا الجهاز';

  @override
  String get groupData => 'البيانات';

  @override
  String get categoriesTitle => 'الفئات';

  @override
  String get categoriesHelp => 'أضف فئاتك أو أخفِ ما لا تستخدمه';

  @override
  String get categoriesOwn => 'فئات هذه المجموعة';

  @override
  String get categoriesOwnEmpty => 'لا توجد فئات خاصة بهذه المجموعة بعد.';

  @override
  String get categoriesBuiltIn => 'مضمنة';

  @override
  String get categoriesBuiltInHelp =>
      'الفئات المخفية لا تظهر للمصروفات الجديدة. وتبقى المصروفات المرتبطة بها كما هي.';

  @override
  String get categoryAdd => 'إضافة فئة';

  @override
  String get categoryEdit => 'تعديل الفئة';

  @override
  String get categoryName => 'الاسم';

  @override
  String get categoryDelete => 'حذف الفئة';

  @override
  String categoryDeleteTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String get categoryDeleteBody => 'ستصبح المصروفات في هذه الفئة بلا فئة.';

  @override
  String get categoryDeleteAction => 'حذف';

  @override
  String get exportCsv => 'تصدير كملف CSV';

  @override
  String get exportCsvHelp => 'كل المصروفات والدفعات في ملف جدول بيانات';

  @override
  String get exportCsvDone => 'تم التصدير';

  @override
  String get forgetTitle => 'إزالة من هذا الجهاز';

  @override
  String get forgetHelp => 'ستبقى المجموعة على الخادم للآخرين';

  @override
  String get forgetBody => 'يمكنك فتحها مجددًا باستخدام الرابط.';

  @override
  String get groupYou => 'أنت';

  @override
  String get leaveTitle => 'مغادرة المجموعة';

  @override
  String get leaveHelp => 'ستبقى مصروفاتك؛ ويمكنك الانضمام مجددًا عبر الرابط';

  @override
  String get leaveBody => 'ستختفي المجموعة من قائمتك. وستبقى مصروفاتك ورصيدك فيها.';

  @override
  String get leaveAction => 'مغادرة';

  @override
  String get tabExpenses => 'المصروفات';

  @override
  String get heroWhoTitle => 'من أنت في هذه المجموعة؟';

  @override
  String get heroWhoBody => 'اختر اسمك لمعرفة ما عليك وما لك.';

  @override
  String get heroWhoAction => 'اختيار';

  @override
  String get heroJoinTitle => 'أنت تشاهد هذه المجموعة';

  @override
  String get heroJoinBody => 'انضم لإضافة مصروفات ومعرفة ما عليك.';

  @override
  String get joinAction => 'انضمام';

  @override
  String get heroOwed => 'لك';

  @override
  String get heroOwe => 'عليك';

  @override
  String get heroSettled => 'تمت تسوية حسابك.';

  @override
  String heroYouAre(String name) {
    return 'أنت $name';
  }

  @override
  String get expenseAdd => 'إضافة مصروف';

  @override
  String get expensesEmptyTitle => 'لا توجد مصروفات بعد';

  @override
  String get expensesEmptyBody => 'أضف أول مصروف، وسيحسب Balnana من عليه المال ولمن.';

  @override
  String get expensesSearchHint => 'ابحث في العناوين والملاحظات والأماكن';

  @override
  String get searchClear => 'مسح البحث';

  @override
  String get expensesNoMatchTitle => 'لا توجد نتائج مطابقة';

  @override
  String get expensesNoMatchBody => 'جرّب كلمات أخرى أو قلّل عوامل التصفية.';

  @override
  String get filterAnyone => 'أي شخص';

  @override
  String get filterAnyCategory => 'أي فئة';

  @override
  String get filterPayments => 'الدفعات';

  @override
  String get filterClear => 'مسح عوامل التصفية';

  @override
  String get periodAll => 'كل الوقت';

  @override
  String get periodThisMonth => 'هذا الشهر';

  @override
  String get periodLastMonth => 'الشهر الماضي';

  @override
  String get periodThisYear => 'هذه السنة';

  @override
  String get periodPickDays => 'اختر التواريخ…';

  @override
  String get statsTitle => 'الإنفاق';

  @override
  String get statsTotal => 'إجمالي الإنفاق';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصروف',
      many: '$count مصروفًا',
      few: '$count مصروفات',
      two: '$count مصروفان',
      one: 'مصروف واحد',
      zero: 'لا توجد مصروفات',
    );
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'حسب الفئة';

  @override
  String get statsByMember => 'ما دفعه ونصيبه لكل شخص';

  @override
  String get statsPaid => 'المدفوع';

  @override
  String get statsShare => 'النصيب';

  @override
  String get statsByMonth => 'حسب الشهر';

  @override
  String get statsNoCategory => 'بلا فئة';

  @override
  String get statsEmptyTitle => 'لا يوجد إنفاق';

  @override
  String get statsEmptyBody => 'لا توجد مصروفات خلال هذه الفترة.';

  @override
  String get statsShowExpenses => 'عرض هذه المصروفات';

  @override
  String get dateToday => 'اليوم';

  @override
  String get dateYesterday => 'أمس';

  @override
  String paymentTitle(String from, String to) {
    return 'حوّل $from مبلغًا إلى $to';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return 'دفع $name مبلغ $amount';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return 'شارك $count أشخاص في دفع $amount';
  }

  @override
  String expensePaidByName(String name) {
    return 'دفع $name';
  }

  @override
  String expensePaidByManyNames(int count) {
    return 'شارك في الدفع $count أشخاص';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return 'استلم $name مبلغ $amount';
  }

  @override
  String expenseReceivedByName(String name) {
    return 'استلم $name';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return 'استلم المبلغ $count أشخاص';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return 'تلقى $count أشخاص مبلغًا قدره $amount';
  }

  @override
  String get transactionRefund => 'استرداد';

  @override
  String get transactionIncome => 'دخل';

  @override
  String get paymentDelete => 'حذف الدفعة';

  @override
  String get paymentDeleted => 'حُذفت الدفعة';

  @override
  String expenseDeleted(String title) {
    return 'حُذف «$title»';
  }

  @override
  String get expenseNew => 'مصروف جديد';

  @override
  String get expenseEdit => 'تعديل المصروف';

  @override
  String get expenseDelete => 'حذف';

  @override
  String get expenseAmount => 'المبلغ';

  @override
  String get expenseTitle => 'ما سبب المصروف؟';

  @override
  String get expenseTitleHint => 'عشاء، تذاكر، سيارة أجرة…';

  @override
  String get expenseAmountFromPayers => 'مجموع ما دفعه الجميع';

  @override
  String expensePaidIn(String currency) {
    return 'دُفع بعملة $currency';
  }

  @override
  String expenseRate(String from, String to) {
    return '1 $from يساوي $to';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return 'الإجمالي بعملة $currency';
  }

  @override
  String expenseForeignHelp(String currency) {
    return 'تظل الأرصدة بعملة $currency. أدخل سعر الصرف أو المبلغ المحوّل، مثلما يظهر في كشف البطاقة.';
  }

  @override
  String get expenseNote => 'ملاحظة';

  @override
  String get expenseNoteHint => 'اختياري';

  @override
  String get expenseLocation => 'الموقع';

  @override
  String get expenseLocationHint => 'أين كان؟ (اختياري)';

  @override
  String get locationPickOnMap => 'اختر على الخريطة';

  @override
  String get locationUseCurrent => 'استخدم موقعي الحالي';

  @override
  String get locationFinding => 'جارٍ تحديد موقعك…';

  @override
  String get locationChange => 'تغيير على الخريطة';

  @override
  String get locationRemovePin => 'إزالة العلامة';

  @override
  String get locationOpenInMaps => 'فتح في الخرائط';

  @override
  String get locationPickTitle => 'اختر موقعًا';

  @override
  String get locationPickHint => 'انقر على الخريطة لوضع علامة';

  @override
  String get locationPickDone => 'تم';

  @override
  String get locationDenied =>
      'لا يمكن لـ Balnana استخدام موقعك. يمكنك السماح بذلك من إعدادات جهازك أو متصفحك.';

  @override
  String get locationOff => 'خدمات الموقع متوقفة على هذا الجهاز.';

  @override
  String get locationUnavailable => 'تعذر تحديد موقعك. حاول مجددًا أو ضع علامة على الخريطة.';

  @override
  String get expenseReceipt => 'الإيصال';

  @override
  String get expenseHasReceipt => 'توجد صورة للإيصال';

  @override
  String get expenseHasLocation => 'يوجد موقع';

  @override
  String get receiptTakePhoto => 'التقط صورة';

  @override
  String get receiptChoose => 'اختر صورة';

  @override
  String get receiptRemove => 'إزالة';

  @override
  String get receiptView => 'صورة الإيصال';

  @override
  String receiptNotSaved(String reason) {
    return 'حُفظ المصروف، لكن لم تُحفظ صورة الإيصال. $reason';
  }

  @override
  String get expensePaidByLabel => 'دفعه';

  @override
  String get expenseReceivedForLabel => 'استُلم مقابل';

  @override
  String get expenseReceivedByLabel => 'استلمه';

  @override
  String get expenseMultiplePayers => 'عدة أشخاص';

  @override
  String get expenseSplit => 'تقسيم';

  @override
  String get splitEqual => 'بالتساوي';

  @override
  String get splitExact => 'بالمبالغ';

  @override
  String get splitShares => 'بالحصص';

  @override
  String splitLeft(String amount) {
    return 'بقي $amount لتوزيعه';
  }

  @override
  String splitOver(String amount) {
    return 'زيادة قدرها $amount';
  }

  @override
  String get conflictTitle => 'تغيّر في مكان آخر';

  @override
  String get conflictReload => 'إعادة التحميل';

  @override
  String get expenseChangedElsewhere =>
      'غيّر شخص آخر هذا المصروف. ستعرض إعادة التحميل نسخته وتتجاهل تغييراتك هنا.';

  @override
  String get suggestedPayments => 'الدفعات المقترحة';

  @override
  String get allSettled => 'تمت تسوية حسابات الجميع.';

  @override
  String transferYouPay(String name) {
    return 'تدفع إلى $name';
  }

  @override
  String transferPaysYou(String name) {
    return 'يدفع $name لك';
  }

  @override
  String transferPays(String from, String to) {
    return 'يدفع $from إلى $to';
  }

  @override
  String get recordPayment => 'تسجيل';

  @override
  String get recordPaymentTitle => 'تسجيل دفعة';

  @override
  String get recordPaymentHelp => 'سجّل فقط الأموال التي دُفعت فعلًا خارج Balnana.';

  @override
  String get paymentRecorded => 'سُجلت الدفعة';

  @override
  String activityGroupCreated(String who, String group) {
    return 'أنشأ $who المجموعة $group';
  }

  @override
  String activityGroupUpdated(String who) {
    return 'غيّر $who تفاصيل المجموعة';
  }

  @override
  String activityLinkReset(String who) {
    return 'أعاد $who تعيين رابط المجموعة';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return 'أضاف $who العضو $name';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return 'غيّر $who اسم $oldName إلى $name';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return 'أزال $who العضو $name';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return 'أضاف $who الفئة $name';
  }

  @override
  String activityCategoryUpdated(String who) {
    return 'غيّر $who الفئات';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return 'حذف $who الفئة $name';
  }

  @override
  String activityMemberJoined(String name) {
    return 'انضم $name';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return 'أضاف $who «$title» ($amount)';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return 'عدّل $who «$title» ($amount)';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return 'حذف $who «$title»';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return 'استعاد $who «$title»';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return 'سجّل $who أن $from دفع إلى $to مبلغ $amount';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return 'حذف $who دفعة قدرها $amount';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return 'استعاد $who دفعة قدرها $amount';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مدخل',
      many: '$count مدخلًا',
      few: '$count مدخلات',
      two: '$count مدخلان',
      one: 'مدخلًا واحدًا',
      zero: '$count مدخلات',
    );
    return 'استورد $who $_temp0 من $source';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return 'أضاف $who صورة إيصال إلى «$title»';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return 'أزال $who صورة الإيصال من «$title»';
  }

  @override
  String activityOther(String who) {
    return 'أجرى $who تغييرًا';
  }

  @override
  String get navGroups => 'المجموعات';

  @override
  String get navActivity => 'النشاط';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get groupsEmptyTitle => 'لا توجد مجموعات بعد';

  @override
  String get groupsEmptyBody => 'ستظهر هنا المجموعات التي تنشئها أو تفتحها من رابط.';

  @override
  String get groupsNoServerTitle => 'اتصل بخادم';

  @override
  String get groupsNoServerBody => 'يحفظ Balnana مجموعاتك على خادم تختاره، مثل خادم تستضيفه بنفسك.';

  @override
  String get groupsNoServerAction => 'اختيار خادم';

  @override
  String get groupsUnreachableTitle => 'تعذر الاتصال بالخادم';

  @override
  String get groupsUnreachableBody => 'تحقق من اتصالك أو من عنوان الخادم في الإعدادات.';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تعذر تحميل $count مجموعة، لذا لا تظهر تغييراتها.',
      many: 'تعذر تحميل $count مجموعة، لذا لا تظهر تغييراتها.',
      few: 'تعذر تحميل $count مجموعات، لذا لا تظهر تغييراتها.',
      two: 'تعذر تحميل مجموعتين، لذا لا تظهر تغييراتهما.',
      one: 'تعذر تحميل مجموعة واحدة، لذا لا تظهر تغييراتها.',
      zero: 'تعذر تحميل أي مجموعة، لذا لا تظهر تغييراتها.',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => 'لا يوجد نشاط بعد';

  @override
  String get activityEmptyBody => 'ستظهر هنا المصروفات والدفعات الجديدة في مجموعاتك.';

  @override
  String get notFoundTitle => 'الصفحة غير موجودة';

  @override
  String get notFoundBody => 'هذا العنوان لا يؤدي إلى أي مكان في Balnana.';

  @override
  String get notFoundAction => 'الانتقال إلى المجموعات';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get accountRename => 'تغيير الاسم';

  @override
  String get passwordChange => 'تغيير كلمة المرور';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور. سُجل الخروج من الأجهزة الأخرى.';

  @override
  String get passwordSet => 'تعيين كلمة مرور';

  @override
  String get passwordSetHelp => 'سجّل الدخول باستخدام بريدك الإلكتروني أو اسم المستخدم وكلمة مرور';

  @override
  String get passwordSetDone => 'تم تعيين كلمة المرور. سُجل الخروج من الأجهزة الأخرى.';

  @override
  String get passwordCurrent => 'كلمة المرور الحالية';

  @override
  String get passwordNew => 'كلمة المرور الجديدة';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get accountOAuthLinked => 'يُستخدم لتسجيل الدخول إلى هذا الحساب. اضغط لإزالته.';

  @override
  String get accountOAuthAdd => 'إضافة طريقة لتسجيل الدخول';

  @override
  String accountOAuthAddTitle(String name) {
    return 'إضافة $name';
  }

  @override
  String accountOAuthAdded(String name) {
    return 'يمكنك الآن تسجيل الدخول باستخدام $name.';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return 'إزالة $name؟';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return 'لن تتمكن من تسجيل الدخول باستخدام $name حتى تضيفه مجددًا.';
  }

  @override
  String get accountOAuthRemove => 'إزالة';

  @override
  String accountOAuthRemoved(String name) {
    return 'تمت إزالة $name.';
  }

  @override
  String get confirmEmailTitle => 'تأكيد بريدك الإلكتروني';

  @override
  String confirmEmailBody(String email) {
    return 'يتطلب هذا الخادم بريدًا إلكترونيًا مؤكدًا. افتح الرابط الذي أرسلناه إلى $email.';
  }

  @override
  String get confirmEmailDone => 'أكدت بريدي الإلكتروني';

  @override
  String get confirmEmailResend => 'إعادة إرسال الرابط';

  @override
  String get confirmEmailNotYet => 'لم يتم التأكيد بعد. افتح الرابط في الرسالة الإلكترونية.';

  @override
  String get settingsTheme => 'السمة';

  @override
  String get themeSystem => 'إعداد النظام';

  @override
  String get themeLight => 'فاتحة';

  @override
  String get themeDark => 'داكنة';

  @override
  String get settingsDynamicColor => 'ألوان الخلفية';

  @override
  String get settingsDynamicColorSubtitle => 'استخدم ألوان جهازك بدلًا من الأصفر الخاص بـ Balnana';

  @override
  String get settingsWallpaperGroups => 'ألوان الخلفية في المجموعات';

  @override
  String get settingsWallpaperGroupsSubtitle => 'استخدم ألوان جهازك للمجموعات بدلًا من ألوانها الخاصة';

  @override
  String get settingsPureBlack => 'أسود خالص';

  @override
  String get settingsPureBlackSubtitle => 'سمة داكنة أكثر للشاشات ذات OLED';

  @override
  String get settingsMyShare => 'إظهار نصيبي';

  @override
  String get settingsMyShareSubtitle => 'تعرض المصروفات ما أقرضته أو استعرته بدلًا من الإجمالي';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageSystem => 'إعداد النظام';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsNotificationsSubtitle => 'عندما يضيف أحدهم مصروفًا أنت عضو فيه أو يغيّره أو يحذفه';

  @override
  String get settingsNotificationsBlocked => 'محظورة في إعدادات الهاتف: اسمح بإشعارات Balnana هناك لتراها';

  @override
  String get pushChannel => 'المصروفات';

  @override
  String get pushChannelDescription => 'عندما يضيف أحدهم مصروفًا أنت عضو فيه أو يغيّره أو يحذفه';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return 'أضاف $who $title · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return 'غيّر $who $title · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return 'حذف $who $title · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return 'أُضيف $title · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return 'تم تغيير $title · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return 'حُذف $title · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return 'دفع $payer إلى $payee مبلغ $amount';
  }

  @override
  String get settingsConnection => 'الاتصال';

  @override
  String get settingsServer => 'الخادم';

  @override
  String get serverNotSet => 'لم يُحدّد';

  @override
  String get settingsAbout => 'حول';

  @override
  String get aboutVersion => 'الإصدار';

  @override
  String get aboutLicenses => 'تراخيص مفتوحة المصدر';

  @override
  String get aboutSource => 'الشفرة المصدرية';

  @override
  String get aboutSourceCopied => 'تعذر فتح المتصفح، لذا نُسخ الرابط';

  @override
  String get serverTitle => 'الخادم';

  @override
  String get serverIntro =>
      'أدخل عنوان خادم Balnana. يمكن لأي شخص استضافته؛ وعادةً ما يكون العنوان هو المكان الذي يفتح فيه تطبيق الويب.';

  @override
  String get serverUrlLabel => 'عنوان الخادم';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => 'اختبار الاتصال';

  @override
  String get serverSaveAnyway => 'حفظ على أي حال';

  @override
  String get serverReset => 'استخدام الافتراضي';

  @override
  String serverDefault(String url) {
    return 'الافتراضي: $url';
  }

  @override
  String serverConnected(String version) {
    return 'متصل بـ Balnana $version';
  }

  @override
  String get serverModeLink => 'تُشارك المجموعات عبر رابط خاص. لا حاجة إلى حساب.';

  @override
  String get serverModeAccounts => 'يسجّل الأشخاص الدخول باستخدام حساب.';

  @override
  String get serverInsecure =>
      'هذا العنوان غير مشفّر (http). يمكن لأي شخص على الشبكة قراءة بياناتك. استخدم https للخوادم خارج شبكتك المنزلية.';

  @override
  String get serverErrorInvalid => 'أدخل عنوان ويب، مثل balnana.example.com';

  @override
  String get serverErrorUnreachable => 'تعذر الاتصال. تحقق من العنوان ومن أن الخادم يعمل.';

  @override
  String get serverErrorNotBalnana => 'استجاب الخادم، لكنه ليس خادم Balnana.';

  @override
  String get serverSaved => 'تم حفظ الخادم';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get groupSignInTitle => 'سجّل الدخول لفتح هذه المجموعة';

  @override
  String get groupSignInBody => 'هذه المجموعة مخصصة لأعضائها فقط. سجّل الدخول لرؤيتها أو للانضمام إليها.';

  @override
  String get signInTitle => 'مرحبًا بعودتك';

  @override
  String get signInBody => 'سجّل الدخول لرؤية مجموعاتك.';

  @override
  String get signInNoPassword => 'يستخدم هذا الخادم طريقة أخرى لتسجيل الدخول. اسأل مشغّله.';

  @override
  String get registerTitle => 'إنشاء حسابك';

  @override
  String get registerBody => 'احتفظ بمجموعاتك على كل أجهزتك.';

  @override
  String get registerAction => 'إنشاء حساب';

  @override
  String get registerHaveAccount => 'لدي حساب بالفعل';

  @override
  String get signInNoAccount => 'إنشاء حساب';

  @override
  String get accountName => 'اسمك';

  @override
  String get accountNameHelp => 'الاسم الذي سيراه الأشخاص في مجموعاتك';

  @override
  String get accountEmail => 'البريد الإلكتروني';

  @override
  String get accountPassword => 'كلمة المرور';

  @override
  String get accountPasswordHelp => '8 أحرف على الأقل';

  @override
  String get passwordShow => 'إظهار كلمة المرور';

  @override
  String get passwordHide => 'إخفاء كلمة المرور';

  @override
  String get joinPickName => 'اختر اسمًا آخر';

  @override
  String joinTitle(String name) {
    return 'الانضمام إلى $name';
  }

  @override
  String get joinBody => 'هل أنت أحد هؤلاء الأشخاص؟ اختر نفسك لتتولى مصروفاتهم.';

  @override
  String get joinBodyNew => 'انضم لإضافة مصروفات ومعرفة رصيدك.';

  @override
  String get joinAsNew => 'أنا شخص جديد';

  @override
  String joinAsName(String name) {
    return 'الانضمام باسم $name';
  }

  @override
  String joinTaken(String names) {
    return 'انضم بالفعل: $names';
  }

  @override
  String joinTakenCount(int count) {
    return 'سبق انضمام $count من الأشخاص.';
  }

  @override
  String get commonContinue => 'متابعة';

  @override
  String get errorEmailOff => 'لا يرسل هذا الخادم رسائل بريد إلكتروني.';

  @override
  String get errorInvalidToken => 'انتهت صلاحية هذا الرابط أو سبق استخدامه.';

  @override
  String get forgotPasswordTitle => 'هل نسيت كلمة المرور؟';

  @override
  String get forgotPasswordBody => 'سنرسل إليك رابطًا عبر البريد الإلكتروني لاختيار كلمة مرور جديدة.';

  @override
  String get forgotPasswordAction => 'إرسال الرابط';

  @override
  String get forgotPasswordSent => 'إذا كان هناك حساب لهذا العنوان، فسيصلك رابط قريبًا.';

  @override
  String get resetPasswordTitle => 'اختر كلمة مرور جديدة';

  @override
  String get resetPasswordBody =>
      'سيُسجل خروجك من كل الأجهزة، وبعدها يمكنك تسجيل الدخول بكلمة المرور الجديدة.';

  @override
  String get resetPasswordAction => 'حفظ كلمة المرور';

  @override
  String get resetPasswordDone => 'تم تغيير كلمة المرور. سجّل الدخول بكلمة المرور الجديدة.';

  @override
  String get verifyEmailTitle => 'تأكيد بريدك الإلكتروني';

  @override
  String get verifyEmailHelp => 'لتتمكن من إعادة تعيين كلمة مرورك إذا نسيتها';

  @override
  String verifyEmailSent(String email) {
    return 'تحقق من $email للعثور على الرابط.';
  }

  @override
  String get verifyEmailDone => 'تم تأكيد البريد الإلكتروني';

  @override
  String get verifyEmailDoneBody => 'شكرًا! تم تأكيد عنوانك.';

  @override
  String get verifyEmailFailed => 'تعذر تأكيد بريدك الإلكتروني';

  @override
  String get inviteByEmail => 'دعوة عبر البريد الإلكتروني';

  @override
  String get inviteByEmailHelp => 'أرسل إلى شخص رابطًا للانضمام';

  @override
  String get inviteAs => 'الانضمام بصفة';

  @override
  String get inviteAsHelp => 'يمكنه تولي مصروفات هذا الشخص';

  @override
  String get inviteAsAnyone => 'شخص جديد';

  @override
  String get inviteSend => 'إرسال الدعوة';

  @override
  String inviteSent(String email) {
    return 'أُرسلت الدعوة إلى $email.';
  }

  @override
  String inviteTitle(String name, String group) {
    return 'دعاك $name إلى $group';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return 'دُعيت إلى $group';
  }

  @override
  String inviteBody(String email) {
    return 'أنشئ حسابًا باستخدام $email للانضمام، أو سجّل الدخول إذا كان لديك حساب.';
  }

  @override
  String get inviteBodySignedIn => 'انضم لإضافة مصروفات ومعرفة رصيدك.';

  @override
  String get inviteAction => 'فتح الدعوة';

  @override
  String get inviteMissingTitle => 'هذه الدعوة لا تعمل';

  @override
  String get inviteMissingBody => 'ربما انتهت صلاحيتها أو استُخدمت. اطلب دعوة جديدة.';

  @override
  String get joinInvitedAs => 'دُعيت بصفتك هذا الشخص';

  @override
  String signInWith(String provider) {
    return 'المتابعة باستخدام $provider';
  }

  @override
  String get signInOr => 'أو';

  @override
  String get oauthFailedTitle => 'تعذر تسجيل دخولك';

  @override
  String get oauthPendingTitle => 'يوجد حساب بهذا البريد الإلكتروني بالفعل';

  @override
  String oauthPendingBody(String provider, String email) {
    return 'يقول $provider إن $email عنوانك، لكن الحساب المرتبط به لم يؤكَّد. ماذا تريد أن تفعل؟';
  }

  @override
  String get oauthPendingLink => 'إضافة إلى ذلك الحساب';

  @override
  String get oauthPendingLinkHelp => 'أدخل كلمة مرور ذلك الحساب. وستظل كلمة مروره صالحة.';

  @override
  String get oauthPendingTakeOver => 'تولي ذلك الحساب';

  @override
  String get oauthPendingTakeOverHelp =>
      'ستُحذف كلمة مرور ذلك الحساب وطرق تسجيل الدخول الأخرى، وسيُسجل الخروج منه على جميع الأجهزة.';

  @override
  String get oauthPendingNew => 'إنشاء حساب جديد';

  @override
  String oauthPendingNewHelp(String email) {
    return 'سيحتفظ الحساب الآخر بمجموعاته، لكن لن يعود مرتبطًا بـ $email.';
  }

  @override
  String get oauthPendingPassword => 'كلمة مرور ذلك الحساب';

  @override
  String get oauthPendingWrongPassword => 'كلمة المرور غير صحيحة.';

  @override
  String get oauthOtherServer => 'بدأ تسجيل الدخول هذا على خادم آخر غير المحدد حاليًا. سجّل الدخول مجددًا.';

  @override
  String get oauthBackToSignIn => 'العودة إلى تسجيل الدخول';

  @override
  String get errorOAuthFailed => 'تعذر تسجيل الدخول. حاول مجددًا.';

  @override
  String get errorEmailHasAccount =>
      'يوجد حساب بهذا البريد الإلكتروني بالفعل. سجّل الدخول إليه، ثم أضف طريقة تسجيل الدخول هذه من الإعدادات.';

  @override
  String get errorIdentityTaken => 'طريقة تسجيل الدخول هذه مرتبطة بحساب آخر بالفعل.';

  @override
  String get errorLastSignInMethod =>
      'هذه طريقتك الوحيدة لتسجيل الدخول. عيّن كلمة مرور أو أضف طريقة أخرى أولًا.';

  @override
  String get errorEmailUnverified => 'أكّد بريدك الإلكتروني أولًا.';

  @override
  String get errorOAuthCancelled => 'أُلغِي تسجيل الدخول.';

  @override
  String get importTitle => 'استيراد من Settle Up';

  @override
  String get importAction => 'استيراد';

  @override
  String get importIntro =>
      'في Settle Up، صدّر المجموعة كملف CSV، ثم اختر الملف هنا. ستُستورد المصروفات والدفعات وكل أفراد المجموعة، وستبقى الأرصدة كما هي.';

  @override
  String get importChooseFile => 'اختيار ملف CSV';

  @override
  String get importChooseOther => 'اختيار ملف آخر';

  @override
  String get importReading => 'جارٍ قراءة الملف…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(
      expenses,
      locale: localeName,
      other: '$expenses مصروف',
      many: '$expenses مصروفًا',
      few: '$expenses مصروفات',
      two: '$expenses مصروفان',
      one: 'مصروف واحد',
      zero: 'لا توجد مصروفات',
    );
    String _temp1 = intl.Intl.pluralLogic(
      payments,
      locale: localeName,
      other: '$payments دفعة',
      many: '$payments دفعة',
      few: '$payments دفعات',
      two: '$payments دفعتان',
      one: 'دفعة واحدة',
      zero: 'لا توجد دفعات',
    );
    return '$_temp0، $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return 'من $from إلى $to';
  }

  @override
  String importCurrency(String currency) {
    return 'العملة: $currency. تستخدم المدخلات بالعملات الأخرى المبالغ التي حوّلها Settle Up.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'استُبعد مدخل قيمته صفر.',
      many: 'استُبعد $count مدخلًا قيمته صفر.',
      few: 'استُبعدت $count مدخلات قيمتها صفر.',
      two: 'استُبعد مدخلان قيمتهما صفر.',
      one: 'استُبعد مدخل واحد قيمته صفر.',
      zero: 'لم تُستبعد أي مدخلات.',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => 'أي شخص أنت؟';

  @override
  String get importUntitled => 'بلا عنوان';

  @override
  String get errorImportFile => 'لا يبدو هذا الملف تصدير CSV من Settle Up.';

  @override
  String get errorImportCurrency => 'لا يحتوي الملف على مدخلات بلا سعر صرف، لذا يتعذر تحديد عملة المجموعة.';

  @override
  String get errorImportTooBig => 'حجم الملف كبير جدًا لاستيراده.';

  @override
  String get errorBadImage => 'لا يمكن استخدام هذه الصورة. اختر صورة JPEG أو PNG أو WebP.';

  @override
  String get errorReceiptTooBig => 'حجم الصورة كبير جدًا. اختر صورة أصغر من 10 MB.';

  @override
  String get errorImportMe => 'اختر الشخص الذي يمثلك.';

  @override
  String errorImportRow(int line, String reason) {
    return 'تعذر استيراد السطر $line من الملف: $reason';
  }

  @override
  String get errorImportAmount => 'تعذرت قراءة مبلغ.';

  @override
  String get errorImportCounts => 'الأسماء والمبالغ غير متطابقة.';

  @override
  String get errorImportDate => 'تعذرت قراءة التاريخ.';

  @override
  String get errorImportType => 'النوع ليس مصروفًا أو تحويلًا أو دخلًا.';

  @override
  String get errorImportTransfer => 'يحتاج التحويل إلى شخص يدفع لشخص آخر.';

  @override
  String get errorImportRowCurrency => 'المبلغ بعملة أخرى ولا يتوفر سعر صرف لها.';

  @override
  String get adminSetupTitle => 'إعداد هذا الخادم';

  @override
  String get adminSetupBody =>
      'اختر كلمة مرور للمشرف. فهي تحمي هذه الصفحة التي تحتوي على إعدادات الخادم. لا يوجد اسم مستخدم؛ كل من يعرف كلمة المرور يمكنه تغيير الإعدادات.';

  @override
  String get adminSetupCode => 'رمز الإعداد';

  @override
  String get adminSetupCodeHelp =>
      'يحتوي هذا الخادم على بيانات بالفعل، لذا طبع رمز الإعداد في سجله عند بدء التشغيل. مع Docker: docker compose logs balnana';

  @override
  String get adminSetupAction => 'تعيين كلمة المرور';

  @override
  String get adminPassword => 'كلمة مرور المشرف';

  @override
  String get adminPasswordRepeat => 'أعد إدخال كلمة المرور';

  @override
  String get adminPasswordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get adminLoginTitle => 'الإدارة';

  @override
  String get adminLoginBody => 'أدخل كلمة مرور المشرف لتغيير إعدادات هذا الخادم.';

  @override
  String get adminLoginAction => 'تسجيل الدخول';

  @override
  String get adminSettingsTitle => 'إعدادات الخادم';

  @override
  String get adminSaved => 'حُفظت الإعدادات. تسري التغييرات فورًا.';

  @override
  String get adminSaveFailed => 'لم يُحفظ شيء. تحقق من الإعدادات المميزة.';

  @override
  String get adminChangePassword => 'تغيير كلمة مرور المشرف';

  @override
  String get adminPasswordCurrent => 'كلمة المرور الحالية';

  @override
  String get adminPasswordNew => 'كلمة المرور الجديدة';

  @override
  String get adminPasswordChanged => 'تم تغيير كلمة المرور. سُجل الخروج من جلسات المشرف الأخرى.';

  @override
  String get adminSignOut => 'تسجيل الخروج من الإدارة';

  @override
  String get adminBackHome => 'العودة إلى Balnana';

  @override
  String get adminRequireEmail => 'اشتراط عنوان بريد إلكتروني';

  @override
  String get adminRequireEmailHelp =>
      'عند إيقاف هذا الخيار، يسجّل الأشخاص باستخدام اسم مستخدم ويمكنهم ترك البريد الإلكتروني فارغًا. ويمكنهم تسجيل الدخول بأي منهما.';

  @override
  String get adminRequireEmailUnused =>
      'ينطبق فقط على تسجيل الدخول بالبريد الإلكتروني وكلمة المرور، وهو متوقف.';

  @override
  String get accountUsername => 'اسم المستخدم';

  @override
  String get accountUsernameHelp =>
      'من 3 إلى 32 حرفًا أو رقمًا أو نقطة أو شرطة أو شرطة سفلية. تسجّل الدخول به.';

  @override
  String get accountEmailOptional => 'البريد الإلكتروني (اختياري)';

  @override
  String get accountEmailOptionalHelp => 'يتيح لك تلقي دعوات المجموعات وإعادة تعيين كلمة مرور منسية.';

  @override
  String get accountLogin => 'البريد الإلكتروني أو اسم المستخدم';

  @override
  String get errorInvalidUsername =>
      'استخدم من 3 إلى 32 حرفًا أو رقمًا أو نقطة أو شرطة أو شرطة سفلية، وابدأ بحرف أو رقم.';

  @override
  String get errorUsernameTaken => 'اسم المستخدم هذا مستخدم بالفعل.';

  @override
  String get adminDiscardTitle => 'تجاهل التغييرات؟';

  @override
  String get adminDiscardBody => 'لم تُحفظ تغييراتك على الإعدادات.';

  @override
  String get adminDiscard => 'تجاهل';

  @override
  String adminLocked(String key) {
    return 'محدد على الخادم بواسطة $key';
  }

  @override
  String adminDefault(String value) {
    return 'الافتراضي: $value';
  }

  @override
  String get adminSecretSaved => 'حُفظ. اكتب قيمة جديدة لاستبداله.';

  @override
  String get adminSecretRemoved => 'ستتم إزالته عند الحفظ.';

  @override
  String get adminSecretRemove => 'إزالة القيمة المحفوظة';

  @override
  String get adminSectionGeneral => 'عام';

  @override
  String get adminSectionAccess => 'الوصول';

  @override
  String get adminSectionMaps => 'الخرائط';

  @override
  String get adminSectionAccounts => 'الحسابات';

  @override
  String get adminSectionAccountsBody => 'تُطبق هذه الإعدادات عند اختيار الحسابات للوصول.';

  @override
  String get adminSectionEmail => 'البريد الإلكتروني (SMTP)';

  @override
  String get adminSectionEmailBody => 'تأكيد العناوين وإعادة تعيين كلمات المرور وإرسال الدعوات.';

  @override
  String get adminSmtpOn => 'إرسال البريد الإلكتروني';

  @override
  String get adminSectionGoogle => 'تسجيل الدخول باستخدام Google';

  @override
  String adminSectionGoogleBody(String url) {
    return 'سجّل $url بصفته URI لإعادة التوجيه في وحدة تحكم Google Cloud.';
  }

  @override
  String get adminGoogleOn => 'إتاحة تسجيل الدخول باستخدام Google';

  @override
  String get adminGoogleOnHelp => 'يسجّل الأشخاص الدخول باستخدام حساب Google.';

  @override
  String get adminSectionOidc => 'تسجيل الدخول باستخدام OpenID Connect';

  @override
  String adminSectionOidcBody(String url) {
    return 'سجّل $url بصفته URI لإعادة التوجيه لدى موفر الخدمة.';
  }

  @override
  String get adminOidcHelp =>
      'يمكن استخدام أي موفر OpenID Connect، مثل Authentik أو Keycloak أو Dex. أضف ما تشاء من الموفرين.';

  @override
  String get adminOidcAdd => 'إضافة موفر';

  @override
  String get adminOidcRemove => 'إزالة موفر';

  @override
  String get adminOidcNew => 'موفر جديد';

  @override
  String get adminOidcId => 'المعرّف';

  @override
  String get adminOidcIdHelp =>
      'أحرف لاتينية صغيرة وأرقام وشرطات. سيكون جزءًا من URI إعادة التوجيه ولا يمكن تغييره لاحقًا.';

  @override
  String get adminOidcIdInvalid =>
      'استخدم أحرفًا لاتينية صغيرة وأرقامًا وشرطات، وابدأ بحرف أو رقم، بحد أقصى 32 حرفًا.';

  @override
  String get adminOidcIdTaken => 'يوجد موفر آخر بهذا المعرّف.';

  @override
  String get adminTrustEmail => 'الوثوق بالبريد الإلكتروني';

  @override
  String get adminGoogleTrustEmailHelp =>
      'يؤدي تسجيل الدخول باستخدام Google ببريد مرتبط بحساب إلى الدخول إليه. عند إيقاف هذا الخيار، يسجّل المستخدمون الدخول بكلمة مرورهم ويضيفون Google من الإعدادات.';

  @override
  String get adminOidcTrustEmailHelp =>
      'استخدم هذا الخيار فقط لموفر تديره أو تثق بأنه يتحقق من البريد الإلكتروني. عند إيقافه، يسجّل أصحاب الحسابات الدخول بكلمة مرورهم ويضيفون طريقة الدخول من الإعدادات.';

  @override
  String get adminRequireVerified => 'اشتراط تأكيد البريد الإلكتروني';

  @override
  String get adminRequireVerifiedHelp =>
      'لا يمكن استخدام التطبيق قبل تأكيد البريد الإلكتروني، كما سيتيح تسجيل الدخول الموثوق بالبريد نفسه تولي الحساب غير المؤكد. عند إيقاف هذا الخيار، يختار الأشخاص ما يحدث.';

  @override
  String get adminRequireVerifiedUnused => 'يتطلب إرسال البريد الإلكتروني.';

  @override
  String get adminSectionAndroid => 'روابط تطبيق Android';

  @override
  String get adminSectionAndroidBody =>
      'تفتح إصدارات Android المصممة لهذا الخادم روابطه في التطبيق. لتجاوز رسالة التأكيد، أدرج بصمات SHA-256 للشهادات المستخدمة لتوقيع تلك الإصدارات.';

  @override
  String get adminSectionAdmin => 'المشرف';

  @override
  String get adminPublicUrl => 'العنوان العام';

  @override
  String get adminPublicUrlHelp =>
      'العنوان الذي يستخدمه الأشخاص للوصول إلى هذا الخادم. تُنشأ منه روابط المجموعات وروابط البريد الإلكتروني.';

  @override
  String get adminSourceUrl => 'رابط الشفرة المصدرية';

  @override
  String get adminSourceUrlHelp =>
      'المكان الذي يمكن للناس الحصول منه على شفرة هذا الخادم، كما يطلب ترخيصه (AGPL-3.0) عند تشغيل نسخة معدّلة.';

  @override
  String get adminAuthMode => 'الوصول';

  @override
  String get adminAuthModeLink => 'روابط المجموعات';

  @override
  String get adminAuthModeLinkHelp => 'لا حاجة إلى تسجيل الدخول؛ يكفي الرابط الخاص بالمجموعة.';

  @override
  String get adminAuthModeAccounts => 'الحسابات';

  @override
  String get adminAuthModeAccountsHelp =>
      'يسجّل الأشخاص الدخول، ولا يتيح الرابط الانضمام إلى مجموعة إلا للمسجلين.';

  @override
  String get adminPasswordLogin => 'تسجيل الدخول بالبريد الإلكتروني وكلمة المرور';

  @override
  String get adminPasswordForced =>
      'سيظل مفعّلًا حتى تفعيل تسجيل الدخول باستخدام Google أو OpenID Connect، لضمان وجود طريقة لتسجيل الدخول دائمًا.';

  @override
  String get adminSignup => 'من يمكنه إنشاء حساب';

  @override
  String get adminSignupOpen => 'أي شخص';

  @override
  String get adminSignupOpenHelp => 'يمكن لأي شخص يستطيع الوصول إلى هذا الخادم إنشاء حساب.';

  @override
  String get adminSignupInvite => 'المدعوون';

  @override
  String get adminSignupInviteHelp =>
      'يمكن فقط للمدعوين إلى مجموعة عبر البريد الإلكتروني إنشاء حساب، باستخدام العنوان الذي تلقوا الدعوة عليه. لا تكفي روابط المجموعات للانضمام. يجب تفعيل البريد الإلكتروني لاستخدام الدعوات.';

  @override
  String get adminSignupClosed => 'لا أحد';

  @override
  String get adminSignupClosedHelp => 'لا يمكن لأحد إنشاء حساب. تظل الحسابات الحالية صالحة.';

  @override
  String get adminSignupHelp => 'يمكن دائمًا إنشاء الحساب الأول.';

  @override
  String get adminLinkGroups => 'السماح بفتح المجموعات عبر الرابط';

  @override
  String get adminLinkGroupsHelp =>
      'يمكن لمالكي المجموعات السماح لأي شخص لديه الرابط بالانضمام دون تسجيل الدخول.';

  @override
  String get adminSmtpHost => 'خادم البريد';

  @override
  String get adminSmtpPort => 'المنفذ';

  @override
  String get adminSmtpUser => 'اسم المستخدم';

  @override
  String get adminSmtpPassword => 'كلمة المرور';

  @override
  String get adminSmtpFrom => 'المرسل';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'معرّف العميل';

  @override
  String get adminClientSecret => 'سر العميل';

  @override
  String get adminOidcIssuer => 'رابط الجهة المُصدرة';

  @override
  String get adminOidcName => 'اسم الزر';

  @override
  String get adminOidcNameHelp => 'يظهر بصيغة «المتابعة باستخدام …» في صفحة تسجيل الدخول.';

  @override
  String get adminFingerprints => 'بصمات الشهادات';

  @override
  String get adminFingerprintsHelp =>
      'بصيغة SHA-256، مفصولة بفواصل. تعرضها الأوامر keytool -list -v و apksigner verify --print-certs.';

  @override
  String get adminInvalidValue => 'هذه القيمة غير صالحة.';

  @override
  String get adminInvalidUrl => 'أدخل عنوانًا كاملًا يبدأ بـ https:// أو http://.';

  @override
  String get adminInvalidFrom =>
      'أدخل مرسلًا مثل Balnana <balnana@example.com>؛ ويجب أن يتضمن بريدًا إلكترونيًا.';

  @override
  String get adminInvalidPort => 'أدخل رقم منفذ من 1 إلى 65535.';

  @override
  String get adminInvalidRequired => 'يتطلب موفر تسجيل الدخول هذا هذه القيمة.';

  @override
  String get adminInvalidFingerprint =>
      'أدخل بصمات SHA-256: كل واحدة من 64 رقمًا سداسيًا عشريًا، ويمكن فصلها بنقطتين رأسيتين.';

  @override
  String get adminNeedsSignIn =>
      'تحتاج الحسابات إلى طريقة لتسجيل الدخول: فعّل البريد الإلكتروني وكلمة المرور أو أعد إعداد موفر.';

  @override
  String get adminLockedChange => 'هذا الإعداد محدد على الخادم ولا يمكن تغييره هنا.';

  @override
  String get errorAdminRequired => 'انتهت جلسة المشرف. سجّل الدخول مجددًا.';

  @override
  String get errorAdminWrongPassword => 'كلمة المرور غير صحيحة.';

  @override
  String get errorInvalidSetupCode => 'رمز الإعداد غير صحيح. ابحث عنه في سجل الخادم.';

  @override
  String get errorAlreadySetUp => 'تم إعداد هذا الخادم بالفعل. سجّل الدخول بكلمة مرور المشرف.';

  @override
  String get linkOpening => 'جارٍ فتح الرابط…';

  @override
  String get linkForeignTitle => 'هذا الرابط لخادم آخر';

  @override
  String linkForeignBody(String server) {
    return 'هذا التطبيق متصل بـ $server، والرابط تابع لخادم آخر. غيّر الخادم من الإعدادات لفتحه.';
  }

  @override
  String get linkInvalidTitle => 'تعذر فتح هذا الرابط';

  @override
  String get linkInvalidBody => 'هذا ليس رابط Balnana معروفًا لهذا التطبيق.';

  @override
  String get linkGoHome => 'الانتقال إلى المجموعات';

  @override
  String get linkOpenInBrowser => 'فتح في المتصفح';

  @override
  String get privacyTitle => 'سياسة الخصوصية';

  @override
  String get privacyIntro =>
      'Balnana برنامج مفتوح المصدر. يحدد مشغّل الخادم الذي يتصل به هذا التطبيق مكان حفظ بياناتك ويتحمل مسؤوليتها. توضّح هذه الصفحة البيانات التي يخزنها البرنامج نفسه وما يفعله بها.';

  @override
  String get privacyStoredTitle => 'البيانات المخزنة';

  @override
  String get privacyStoredBody =>
      'المجموعات التي تنشئها أو تنضم إليها: أسماؤها، وأسماء أعضائها، والمصروفات، والدفعات، والملاحظات، وصور الإيصالات إن وُجدت، والأماكن التي تضيفها إلى المصروفات. وعند استخدام حساب، يُخزن أيضًا اسمك وعنوان بريدك الإلكتروني أو اسم المستخدم وبصمة كلمة مرورك (لا كلمة المرور نفسها) وموفر تسجيل الدخول الذي تستخدمه، مثل Google. وعند تفعيل الإشعارات، يُخزن معرّف لجهازك والعنوان الذي تمنحه له خدمة الإشعارات.';

  @override
  String get privacyUseTitle => 'كيفية استخدامها';

  @override
  String get privacyUseBody =>
      'تُستخدم البيانات لتشغيل التطبيق فقط: لعرض كل مجموعة على أعضائها وحساب الأرصدة وإرسال الرسائل والإشعارات التي يحتاجها التطبيق، مثل تأكيد العناوين وإعادة تعيين كلمات المرور وإرسال الدعوات. لا يحتوي التطبيق على إعلانات أو تحليلات، ولا تُباع أي بيانات.';

  @override
  String get privacySharedTitle => 'من يمكنه رؤيتها';

  @override
  String get privacySharedBody =>
      'يرى كل فرد في المجموعة أعضاءها ومصروفاتها وسجلها. وعندما تكون المجموعة متاحة عبر رابط، يمكن لأي شخص لديه الرابط فتحها. يتم تسجيل الدخول إلى الحسابات عبر Google، وتمر الإشعارات، عند تفعيلها من المشغّل، عبر خدمة الإشعارات التي يستخدمها هاتفك: Google Firebase Cloud Messaging أو خدمة UnifiedPush أخرى ثبّتها، مثل ntfy. يُشفّر محتوى الإشعار أثناء إرساله. تُحمّل الخرائط صورها من موفر الخرائط الذي اختاره المشغّل، وهو OpenFreeMap ما لم يغيّره؛ ويرى هذا الموفر عنوان شبكتك والمنطقة التي تطالعها. لا يُقرأ موقعك إلا عند الضغط على «استخدم موقعي الحالي»، ولا يُحفظ إلا الموقع الذي تختار الاحتفاظ به.';

  @override
  String get privacyDeviceTitle => 'على هذا الجهاز';

  @override
  String get privacyDeviceBody =>
      'يحتفظ التطبيق بعنوان الخادم وإعداداتك ونسخة من مجموعاتك لاستخدامها عند انقطاع الاتصال. يؤدي إلغاء تثبيت التطبيق إلى حذف هذه البيانات.';

  @override
  String get privacyDeleteTitle => 'حذف بياناتك';

  @override
  String get privacyDeleteBody =>
      'يمكنك حذف حسابك من الإعدادات. سيبقى اسمك في مجموعاتك كعضو لم يتولّه أحد، لتظل الأرصدة صحيحة، وستُحذف معه المجموعات التي لا يستطيع أحد سواك الوصول إليها. ويمكن لمالك المجموعة حذفها بالكامل من إعداداتها. لأي أمر آخر، تواصل مع مشغّل الخادم.';

  @override
  String get privacyOperatorPolicy => 'سياسة الخصوصية الخاصة بالمشغّل';

  @override
  String get privacyLink => 'الخصوصية';

  @override
  String get accountEmailAdd => 'إضافة عنوان بريد إلكتروني';

  @override
  String get accountEmailChange => 'تغيير عنوان البريد الإلكتروني';

  @override
  String get accountEmailNew => 'عنوان البريد الإلكتروني';

  @override
  String get accountEmailVerifyNote =>
      'سيصلك رابط لتأكيد العنوان الجديد. سيظل عنوانك الحالي مستخدمًا حتى ذلك الحين.';

  @override
  String get accountEmailPendingTitle => 'أكّد بريدك الإلكتروني الجديد';

  @override
  String accountEmailPendingHelp(String email) {
    return 'سيحل $email محل عنوانك الحالي بعد فتح الرابط المرسل إليه. اضغط لإعادة إرسال الرابط.';
  }

  @override
  String get accountEmailRemoveNote => 'اترك الحقل فارغًا لإزالة عنوانك. ستظل تسجّل الدخول باسم المستخدم.';

  @override
  String get accountEmailSaved => 'حُفظ عنوان البريد الإلكتروني';

  @override
  String get accountEmailRemoved => 'أُزيل عنوان البريد الإلكتروني';

  @override
  String get accountConfirmPassword => 'كلمة مرورك';

  @override
  String get accountConfirmPasswordHelp => 'للتأكد من هويتك.';

  @override
  String get errorEmailNeeded => 'تسجّل الدخول باستخدام بريدك الإلكتروني، لذا لا يمكن إزالته.';

  @override
  String get accountDelete => 'حذف الحساب';

  @override
  String get accountDeleteHelp => 'إزالة حسابك من هذا الخادم';

  @override
  String get accountDeleteTitle => 'حذف حسابك؟';

  @override
  String get accountDeleteBody =>
      'سيُحذف حسابك نهائيًا وسيُسجل خروجك. سيبقى اسمك في مجموعاتك كعضو لم يتولّه أحد، لتظل الأرصدة صحيحة. وستُحذف المجموعات التي لا تضم أحدًا غيرك.';

  @override
  String get accountDeleteAction => 'حذف نهائيًا';

  @override
  String get accountDeleted => 'تم حذف حسابك.';

  @override
  String get accountDeletePageSignedOut => 'سجّل الدخول لحذف حسابك على هذا الخادم.';

  @override
  String get accountDeletePageLinkMode =>
      'لا توجد حسابات على هذا الخادم؛ يكفي رابط المجموعة للوصول إليها. لحذف مجموعة بكل ما فيها، افتح إعداداتها واختر «حذف المجموعة».';

  @override
  String get groupDelete => 'حذف المجموعة';

  @override
  String get groupDeleteHelp => 'حذفها مع كل مصروفاتها للجميع';

  @override
  String groupDeleteTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String get groupDeleteBody =>
      'ستُحذف المجموعة وكل مصروفاتها ودفعاتها وسجلها لدى الجميع. لا يمكن التراجع عن ذلك. اكتب اسم المجموعة للتأكيد.';

  @override
  String get groupDeleteName => 'اسم المجموعة';

  @override
  String get groupDeleteAction => 'حذف نهائيًا';

  @override
  String get groupDeleted => 'حُذفت المجموعة';

  @override
  String get groupDeleteOwnerOnly => 'يمكن لمالك المجموعة وحده حذفها.';

  @override
  String get expenseDiscardTitle => 'تجاهل التغييرات؟';

  @override
  String get expenseDiscardBody => 'لم تُحفظ تغييراتك على هذا المصروف.';

  @override
  String get expenseDiscard => 'تجاهل';

  @override
  String get adminPrivacyUrl => 'رابط سياسة الخصوصية';

  @override
  String get adminPrivacyUrlHelp =>
      'سياسة الخصوصية التي تطلبها متاجر التطبيقات. عند ترك الحقل فارغًا، يعرض التطبيق سياسة عامة تشرح ما يخزنه Balnana.';

  @override
  String get adminMapTiles => 'مربعات الخريطة';

  @override
  String get adminMapSource => 'مصدر الخريطة';

  @override
  String get adminMapSourceStyle => 'نمط متجهي';

  @override
  String get adminMapSourceStyleHelp =>
      'خرائط مرسومة بنمط MapLibre، مثل OpenFreeMap، وهو مجاني ولا يحتاج إلى مفتاح.';

  @override
  String get adminMapSourceTiles => 'مربعات نقطية';

  @override
  String get adminMapSourceTilesHelp => 'خرائط معروضة كصور مربعات، مثل OpenStreetMap.';

  @override
  String get adminMapSourceOff => 'إيقاف';

  @override
  String get adminMapSourceOffHelp =>
      'لن تُعرض خرائط، لكن ستظل أسماء الأماكن وإحداثياتها محفوظة في المصروفات.';

  @override
  String get adminMapStyle => 'رابط النمط';

  @override
  String get adminMapStyleHelp =>
      'عنوان ملف style.json لـ MapLibre، مثل Liberty أو Bright أو Positron من OpenFreeMap (النمط الافتراضي).';

  @override
  String get adminMapTilesHelp =>
      'قالب رابط لمربعات نقطية يتضمن z وx وy بين أقواس معقوفة، مثل القالب الافتراضي. خوادم OpenStreetMap مخصصة للاستخدام المحدود؛ على الخوادم المزدحمة استخدام موفر للمربعات.';

  @override
  String get adminMapAttribution => 'الإسناد إلى مصدر الخريطة';

  @override
  String get adminMapAttributionHelp =>
      'يظهر على كل خريطة وفق طلب موفرها. عند ترك الحقل فارغًا، يعرض النمط أسماء الجهات التي يذكرها، وتُنسب المربعات إلى OpenStreetMap.';

  @override
  String get adminInvalidMapTiles => 'أدخل قالب رابط http(s) يتضمن z وx وy بين أقواس معقوفة.';

  @override
  String get adminUsers => 'الحسابات';

  @override
  String get adminUsersSearch => 'البحث بالاسم أو البريد الإلكتروني أو اسم المستخدم';

  @override
  String adminUsersShown(int shown, int total) {
    return '$shown من أصل $total حساب';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حساب',
      many: '$count حسابًا',
      few: '$count حسابات',
      two: '$count حسابان',
      one: 'حساب واحد',
      zero: 'لا توجد حسابات',
    );
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => 'لا توجد حسابات مطابقة.';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مجموعة',
      many: '$count مجموعة',
      few: '$count مجموعات',
      two: 'مجموعتان',
      one: 'مجموعة واحدة',
      zero: 'لا توجد مجموعات',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => 'غير مؤكّد';

  @override
  String adminUserDeleteTitle(String name) {
    return 'حذف حساب $name؟';
  }

  @override
  String get adminUserDeleteBody =>
      'سيُحذف الحساب نهائيًا وسيُسجل الخروج منه في كل الأجهزة. سيبقى اسمه في مجموعاته كعضو لم يتولّه أحد؛ وستُحذف المجموعات التي لا تضم أحدًا غيره.';

  @override
  String get adminUserDeleted => 'حُذف الحساب';

  @override
  String get commonDone => 'تم';

  @override
  String get crowdSearch => 'البحث عن أشخاص';

  @override
  String get crowdNoMatch => 'لا يوجد أحد مطابق.';

  @override
  String get crowdAll => 'الكل';

  @override
  String get crowdNone => 'لا أحد';

  @override
  String crowdChosen(int count, int total) {
    return 'تم اختيار $count من $total';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخص إضافي',
      many: '$count شخصًا إضافيًا',
      few: '$count أشخاص إضافيين',
      two: 'شخصان إضافيان',
      one: 'شخص إضافي واحد',
      zero: 'لا مزيد',
    );
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => 'عرض أقل';

  @override
  String get crowdSort => 'ترتيب';

  @override
  String crowdShowAll(int count) {
    return 'عرض جميع الأشخاص ($count)';
  }

  @override
  String get crowdBalances => 'أرصدة الجميع';

  @override
  String get crowdSomeoneElse => 'شخص آخر';

  @override
  String get crowdChoosePayers => 'اختيار من دفع';

  @override
  String get crowdFilterTitle => 'مصروفات مَن؟';

  @override
  String get myGroupsTitle => 'روابط مجموعاتي';

  @override
  String get myGroupsExport => 'تصدير مجموعاتي';

  @override
  String get myGroupsExportHelp => 'انسخ روابط مجموعاتك للاحتفاظ بنسخة احتياطية أو نقلها إلى جهاز آخر.';

  @override
  String get myGroupsPrivate => 'احتفظ بهذه الروابط لنفسك. يمكن لأي شخص لديه رابط فتح المجموعة.';

  @override
  String get myGroupsCopy => 'نسخ الروابط';

  @override
  String get myGroupsImport => 'استيراد مجموعات';

  @override
  String get myGroupsImportHelp =>
      'الصق روابط المجموعات من هذا الخادم، رابطًا في كل سطر. ستحتفظ المجموعات الموجودة بمكانها وهويتها.';

  @override
  String get myGroupsLinks => 'روابط المجموعات';

  @override
  String get myGroupsImportAction => 'استيراد الروابط';

  @override
  String get myGroupsInvalid => 'أدخل روابط مجموعات صالحة، رابطًا في كل سطر. لم يُستورد شيء.';

  @override
  String get myGroupsServerChanged => 'تغير الخادم المحدد. أغلق مربع الحوار واستورد الروابط على خادمها.';

  @override
  String myGroupsLimit(int count) {
    return 'احتفظ بحد أقصى $count رابط مجموعة لكل خادم. لم يُستورد شيء.';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم استيراد $count رابط مجموعة جديد.',
      many: 'تم استيراد $count رابطًا جديدًا للمجموعات.',
      few: 'تم استيراد $count روابط جديدة للمجموعات.',
      two: 'تم استيراد رابطَي مجموعة جديدين.',
      one: 'تم استيراد رابط مجموعة جديد واحد.',
      zero: 'هذه المجموعات محفوظة بالفعل.',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => 'التكرار';

  @override
  String get repeatNever => 'لا يتكرر';

  @override
  String get repeatDaily => 'يوميًا';

  @override
  String get repeatWeekly => 'أسبوعيًا';

  @override
  String get repeatMonthly => 'شهريًا';

  @override
  String get repeatYearly => 'سنويًا';

  @override
  String get repeatEvery => 'كل';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يوم',
      many: 'يومًا',
      few: 'أيام',
      two: 'يومان',
      one: 'يوم',
      zero: 'يوم',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أسبوع',
      many: 'أسبوعًا',
      few: 'أسابيع',
      two: 'أسبوعان',
      one: 'أسبوع',
      zero: 'أسبوع',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'شهر',
      many: 'شهرًا',
      few: 'أشهر',
      two: 'شهران',
      one: 'شهر',
      zero: 'شهر',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سنة',
      many: 'سنة',
      few: 'سنوات',
      two: 'سنتان',
      one: 'سنة',
      zero: 'سنة',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count يوم',
      many: 'كل $count يومًا',
      few: 'كل $count أيام',
      two: 'كل يومين',
      one: 'كل يوم',
      zero: 'كل $count يوم',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count أسبوع',
      many: 'كل $count أسبوعًا',
      few: 'كل $count أسابيع',
      two: 'كل أسبوعين',
      one: 'كل أسبوع',
      zero: 'كل $count أسبوع',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count شهر',
      many: 'كل $count شهرًا',
      few: 'كل $count أشهر',
      two: 'كل شهرين',
      one: 'كل شهر',
      zero: 'كل $count شهر',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count سنة',
      many: 'كل $count سنة',
      few: 'كل $count سنوات',
      two: 'كل سنتين',
      one: 'كل سنة',
      zero: 'كل $count سنة',
    );
    return '$_temp0';
  }

  @override
  String get repeatEndNone => 'بلا تاريخ انتهاء';

  @override
  String repeatEndOn(String date) {
    return 'حتى $date';
  }

  @override
  String get repeatEndClear => 'إزالة تاريخ الانتهاء';

  @override
  String get repeatHelp =>
      'يُضاف المصروف تلقائيًا إلى المجموعة في كل تاريخ، بدءًا من التاريخ أعلاه. تُضاف التواريخ الماضية عند الحفظ.';

  @override
  String get repeatDropReceiptTitle => 'إزالة الإيصال؟';

  @override
  String get repeatDropReceiptBody =>
      'لا يمكن إرفاق إيصال بمصروف متكرر. يمكنك إضافة إيصال لكل مصروف يُنشأ بدلًا من ذلك.';

  @override
  String get repeatDropReceiptAction => 'تكرار';

  @override
  String get recurringTitle => 'المصروفات المتكررة';

  @override
  String get recurringHelp => 'مصروفات تُضاف تلقائيًا وفق جدول زمني';

  @override
  String get recurringEmptyTitle => 'لا توجد مصروفات متكررة';

  @override
  String get recurringEmptyBody =>
      'يمكن إضافة الإيجار والاشتراكات وغيرها من التكاليف المتكررة تلقائيًا في كل موعد.';

  @override
  String get recurringAdd => 'إضافة مصروف متكرر';

  @override
  String get recurringEdit => 'تعديل المصروف المتكرر';

  @override
  String recurringNext(String date) {
    return 'التالي في $date';
  }

  @override
  String get recurringPaused => 'متوقف مؤقتًا';

  @override
  String get recurringEnded => 'انتهى';

  @override
  String get recurringPause => 'إيقاف مؤقت';

  @override
  String get recurringResume => 'استئناف';

  @override
  String get recurringActive => 'متكرر';

  @override
  String get recurringDelete => 'حذف';

  @override
  String get recurringDeleteTitle => 'إيقاف التكرار؟';

  @override
  String recurringDeleteBody(String title) {
    return 'لن يُضاف «$title» مجددًا. وستبقى المصروفات التي أضافها.';
  }

  @override
  String get recurringDeleted => 'حُذف المصروف المتكرر';

  @override
  String get recurringFromSchedule => 'أُضيف بواسطة مصروف متكرر';

  @override
  String get recurringOpen => 'تغيير الجدول';

  @override
  String get recurringMissing => 'حُذف المصروف المتكرر أو لم يعد متاحًا.';

  @override
  String get errorTooManyDue => 'تاريخ البدء قديم جدًا؛ سيؤدي إلى إضافة أكثر من 100 مصروف دفعة واحدة.';

  @override
  String get errorInvalidEnd => 'لا يمكن أن يسبق تاريخ الانتهاء تاريخ البدء.';

  @override
  String get errorInvalidRepeat => 'كرّر بمعدل كل 1 إلى 999 يومًا أو أسبوعًا أو شهرًا أو سنة.';

  @override
  String get errorRecurringConflict =>
      'غيّر شخص آخر هذا المصروف المتكرر أثناء تعديله. أعد التحميل للاطلاع على تغييراته.';

  @override
  String activityRecurringCreated(String who, String title) {
    return 'ضبط $who «$title» ليتكرر';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return 'غيّر $who المصروف المتكرر «$title»';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return 'أوقف $who المصروف المتكرر «$title» مؤقتًا';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return 'أُوقف المصروف المتكرر «$title» مؤقتًا لأن أحد أفراده غادر المجموعة';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return 'أُوقف المصروف المتكرر «$title» مؤقتًا لتعذر إضافته';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return 'استأنف $who المصروف المتكرر «$title»';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return 'أوقف $who تكرار المصروف «$title»';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return 'أُضيف «$title» ($amount) تلقائيًا';
  }

  @override
  String get expenseRecurring => 'أُضيف بواسطة مصروف متكرر';

  @override
  String get adminPlans => 'الخطط';

  @override
  String get adminPayments => 'المدفوعات';

  @override
  String get adminSectionBilling => 'الخطط والمدفوعات';

  @override
  String get adminSectionBillingBody =>
      'ترفع الخطط حدود ما يحتفظ به هذا الخادم. يظل تقسيم المصروفات وتسويتها مجانيًا.';

  @override
  String get adminBillingOn => 'الخطط والحدود';

  @override
  String get adminBillingOnHelp => 'عند الإيقاف، لا يقيّد هذا الخادم شيئًا ولا يعرض أي خطط.';

  @override
  String get adminBillingNeedsAccounts => 'تحتاج الخطط إلى حسابات: غيّر وضع الوصول إلى الحسابات أولًا.';

  @override
  String get adminKofiUrl => 'صفحة Ko-fi';

  @override
  String get adminKofiUrlHelp => 'حيث يتم الدفع. لا ترتبط بها إلا الإصدارات التي تسمح بالدفع الخارجي.';

  @override
  String adminKofiWebhook(String url) {
    return 'عنوان Webhook لإدخاله في Ko-fi: $url';
  }

  @override
  String get adminKofiToken => 'رمز التحقق من Ko-fi';

  @override
  String get adminKofiTokenHelp => 'يظهر في صفحة Webhook على Ko-fi. بدونه يتجاهل هذا الخادم Ko-fi.';

  @override
  String adminUserPlanUntil(String plan, String date) {
    return '$plan حتى $date';
  }

  @override
  String get adminPlansHelp =>
      'ينطبق الحد الجديد على ما يُضاف لاحقًا، ويبقى الموجود كما هو. اتركه فارغًا لعدم وضع حد.';

  @override
  String get adminPlanAdd => 'إضافة خطة';

  @override
  String adminPlanDefaultName(String name) {
    return '$name (الافتراضية)';
  }

  @override
  String adminPlanLimit(String label, String value) {
    return '$label: $value';
  }

  @override
  String adminPlanDays(int count) {
    return 'الأيام: $count';
  }

  @override
  String get adminProductsSection => 'المنتجات';

  @override
  String get adminProductsHelp =>
      'تذهب الدفعة إلى المنتج الذي يحمل اسم مستواها، وإلا فإلى المنتج بلا اسم مستوى الذي تبلغ مبلغه.';

  @override
  String get adminProductAdd => 'إضافة منتج';

  @override
  String get adminProductEdit => 'تعديل المنتج';

  @override
  String adminProductAnyPayment(String amount) {
    return 'أي دفعة لا تقل عن $amount';
  }

  @override
  String get adminProductName => 'اسم المستوى';

  @override
  String get adminProductNameHelp =>
      'كما هو مكتوب في Ko-fi. اتركه فارغًا لمطابقة الدفعات الفردية أو الشهرية حسب المبلغ.';

  @override
  String get adminProductPlan => 'الخطة';

  @override
  String get adminProductDays => 'الأيام';

  @override
  String get adminProductDaysHelp => 'مدة الدفعة الواحدة. يُضاف الدفع مرة أخرى إلى المدة المتبقية.';

  @override
  String get adminProductMinAmount => 'الحد الأدنى للمبلغ';

  @override
  String get adminProductCurrency => 'رمز العملة';

  @override
  String get adminPlanId => 'المعرّف';

  @override
  String get adminPlanIdHelp => 'أحرف إنجليزية صغيرة وأرقام وشرطات. لا يمكن تغييره لاحقًا.';

  @override
  String get adminPlanName => 'الاسم';

  @override
  String get adminPlanRank => 'الرتبة';

  @override
  String get adminPlanRankHelp => 'يحصل الحساب الذي لديه عدة خطط على الخطة ذات أعلى رتبة.';

  @override
  String get adminPlanDefault => 'الخطة الافتراضية';

  @override
  String get adminPlanDefaultHelp => 'لكل حساب ليس لديه خطة أخرى.';

  @override
  String get adminEntitlementGranted => 'منحها مسؤول';

  @override
  String get adminEntitlementRevoked => 'أُلغيت';

  @override
  String get adminEntitlementForever => 'بلا تاريخ انتهاء';

  @override
  String adminEntitlementUntil(String date) {
    return 'حتى $date';
  }

  @override
  String adminEntitlementEnded(String date) {
    return 'انتهت في $date';
  }

  @override
  String get adminEntitlementsEmpty => 'لا توجد خطط لهذا الحساب بعد.';

  @override
  String get adminEntitlementRevoke => 'إلغاء';

  @override
  String get adminEntitlementNote => 'ملاحظة';

  @override
  String get adminEntitlementGrant => 'منح الخطة';

  @override
  String get adminPaymentApplied => 'مُطبَّقة';

  @override
  String get adminPaymentUnclaimed => 'غير مطالب بها';

  @override
  String get adminPaymentUnmatched => 'غير مطابقة';

  @override
  String get adminPaymentsAll => 'الكل';

  @override
  String adminPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دفعة',
      many: '$count دفعة',
      few: '$count دفعات',
      two: 'دفعتان',
      one: 'دفعة واحدة',
      zero: 'لا توجد دفعات',
    );
    return '$_temp0';
  }

  @override
  String get adminPaymentsEmpty => 'لا توجد دفعات.';

  @override
  String get adminPaymentAssigned => 'مُنحت الخطة للحساب.';

  @override
  String get adminPaymentAssign => 'منح لحساب';

  @override
  String get adminPaymentPickUser => 'اختر حسابًا.';

  @override
  String get errorBillingOff => 'لا توجد خطط على هذا الخادم.';

  @override
  String get errorAlreadySponsored => 'خطة عضو آخر تغطي هذه المجموعة بالفعل.';

  @override
  String get errorPlanInUse => 'ما زالت حسابات أو منتجات تستخدم هذه الخطة.';

  @override
  String get errorPaymentApplied => 'طُبّقت هذه الدفعة بالفعل.';

  @override
  String get errorInvalidPlan => 'تحقق من إعدادات الخطة: هناك قيمة غير صالحة.';

  @override
  String errorLimitReceipts(int max) {
    return 'بلغت هذه المجموعة حد صور الإيصالات: $max.';
  }

  @override
  String errorLimitRecurring(int max) {
    return 'بلغت هذه المجموعة حد المصروفات المتكررة: $max.';
  }

  @override
  String errorLimitOwnGroups(int max) {
    return 'بلغت حد المجموعات: $max.';
  }

  @override
  String errorLimitSponsored(int max) {
    return 'الحد الأقصى للمجموعات التي يمكن مشاركة خطتك معها: $max.';
  }

  @override
  String get errorLimitOther => 'بلغت أحد حدود هذا الخادم.';

  @override
  String get planTitle => 'الخطة';

  @override
  String get planUnlimited => 'بلا حد';

  @override
  String planUntil(String date) {
    return 'حتى $date';
  }

  @override
  String get planSettingsHelp => 'ما يحتفظ به هذا الخادم لك';

  @override
  String get planIntro =>
      'التقسيم والتسوية مجانيان دائمًا. لا تغيّر الخطة إلا مقدار ما يحتفظ به هذا الخادم لك.';

  @override
  String planUsage(int used, int limit) {
    return '$used من $limit';
  }

  @override
  String planUsed(int used) {
    return 'المستخدم: $used';
  }

  @override
  String get planLimits => 'الحدود';

  @override
  String get planLimitReceipts => 'صور الإيصالات لكل مجموعة';

  @override
  String get planLimitRecurring => 'المصروفات المتكررة لكل مجموعة';

  @override
  String get planLimitOwnGroups => 'المجموعات التي أنشأتها';

  @override
  String get planLimitSponsored => 'المجموعات التي تشارك خطتك';

  @override
  String get planGet => 'الحصول على خطة';

  @override
  String get planKofi => 'Ko-fi';

  @override
  String get planKofiHelp => 'ادفع بالبريد الإلكتروني المؤكد لحسابك، أو أضف أدناه العنوان الذي تدفع به.';

  @override
  String get planPaymentEmailConfirmed => 'تُحتسب الدفعات من هذا العنوان لحسابك';

  @override
  String get planPaymentEmailAdd => 'إضافة بريد إلكتروني للدفع';

  @override
  String get planPaymentEmailHelp => 'سنرسل رابطًا لتأكيد أنه عنوانك.';

  @override
  String get paymentEmailDone => 'تم تأكيد العنوان';

  @override
  String get paymentEmailDoneBody => 'تُحتسب الدفعات من هذا العنوان لحسابك الآن.';

  @override
  String groupPlanUsage(String receipts, String recurring) {
    return 'صور الإيصالات: $receipts · المتكررة: $recurring';
  }

  @override
  String get groupSponsor => 'مشاركة خطتي مع هذه المجموعة';

  @override
  String get groupUnsponsor => 'إيقاف مشاركة خطتي';

  @override
  String groupSponsoredBy(String name) {
    return 'تستخدم خطة $name';
  }
}
