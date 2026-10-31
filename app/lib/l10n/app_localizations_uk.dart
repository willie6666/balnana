// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get languageEndonym => 'Українська';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'Скасувати';

  @override
  String get commonRetry => 'Повторити';

  @override
  String get offlineBar =>
      'Немає зв’язку. Показано збережені на цьому пристрої дані; зміни збережуться після відновлення зв’язку.';

  @override
  String get commonSave => 'Зберегти';

  @override
  String get commonClear => 'Очистити';

  @override
  String get iconChoose => 'Виберіть піктограму';

  @override
  String get iconNone => 'Без піктограми';

  @override
  String get iconSearchHint => 'Знайдіть або введіть будь-який емодзі';

  @override
  String get iconUseTyped => 'Використати цей емодзі';

  @override
  String get iconNoMatch => 'Піктограм не знайдено. Введіть емодзі, щоб використати його.';

  @override
  String get iconSectionTravel => 'Подорожі й місця';

  @override
  String get iconSectionFood => 'Їжа й напої';

  @override
  String get iconSectionActivities => 'Розваги';

  @override
  String get iconSectionHome => 'Дім і рахунки';

  @override
  String get iconSectionPeople => 'Люди';

  @override
  String get iconSectionNature => 'Тварини й природа';

  @override
  String get iconSectionObjects => 'Гроші й речі';

  @override
  String get iconSectionSymbols => 'Символи';

  @override
  String get commonRemove => 'Видалити';

  @override
  String get commonUndo => 'Скасувати дію';

  @override
  String get someone => 'Хтось';

  @override
  String get errorTooLarge => 'Це завелике, щоб надіслати на сервер.';

  @override
  String get errorBusy => 'Сервер зайнятий. Спробуйте ще раз за хвилину.';

  @override
  String get errorTimeout => 'Не вдалося надіслати вчасно. Перевірте з’єднання й повторіть спробу.';

  @override
  String get errorBadOrigin =>
      'Сервер не приймає вхід із цієї адреси. Власнику сервера слід перевірити його публічну URL-адресу.';

  @override
  String get errorInvalidCategory => 'Цю категорію вже видалено. Виберіть іншу.';

  @override
  String get errorBuiltinCategory => 'Вбудовані категорії можна лише приховати.';

  @override
  String get errorUnknownMember =>
      'Хтось із цієї групи більше не є її учасником. Перезавантажте сторінку й повторіть спробу.';

  @override
  String get errorNoPayers => 'Виберіть, хто заплатив.';

  @override
  String get errorPayerTotal => 'Суми, сплачені кожним, мають дорівнювати загальній сумі.';

  @override
  String get errorPayerTooSmall =>
      'Частка когось зі сплаченого округлюється до нуля у валюті групи. Перевірте суми.';

  @override
  String get errorInvalidNote => 'Примітка задовга або містить символи, які не можна зберегти.';

  @override
  String get errorInvalidDate => 'Ця дата поза допустимим діапазоном.';

  @override
  String get errorGeneric => 'Щось пішло не так. Спробуйте ще раз.';

  @override
  String get errorNetwork => 'Не вдається зв’язатися із сервером. Перевірте з’єднання.';

  @override
  String get errorNotFound => 'Цього більше не існує.';

  @override
  String get errorRequired => 'Обов’язкове поле';

  @override
  String get errorInvalidName => 'Введіть ім’я завдовжки до 100 символів.';

  @override
  String get errorDuplicateName => 'У цій групі вже є учасник із таким ім’ям.';

  @override
  String get errorTooManyMembers => 'У групі вже максимальна кількість учасників.';

  @override
  String get errorTooManyCategories => 'У групі вже максимальна кількість категорій.';

  @override
  String get errorDuplicateCategory => 'У цій групі вже є категорія з такою назвою.';

  @override
  String get errorInvalidCurrency => 'Введіть трилітерний код валюти, наприклад USD.';

  @override
  String get errorInvalidTitle => 'Введіть назву завдовжки до 200 символів.';

  @override
  String get errorInvalidLocation => 'Введіть назву місця одним рядком, до 200 символів.';

  @override
  String get errorInvalidSymbol => 'Введіть символ завдовжки до 8 символів.';

  @override
  String get errorInvalidEmoji => 'Виберіть один емодзі як піктограму.';

  @override
  String get errorMemberHasBalance => 'Спершу розрахуйтеся з цим учасником, а тоді видаляйте його.';

  @override
  String get errorVersionConflict =>
      'Поки ви редагували витрату, хтось інший її змінив. Перезавантажте сторінку, щоб побачити зміни.';

  @override
  String get errorSignInRequired => 'Увійдіть, щоб це зробити.';

  @override
  String get errorRateLimited => 'Забагато запитів. Зачекайте хвилину й повторіть спробу.';

  @override
  String get errorNotAMember => 'Ви ще не приєдналися до цієї групи.';

  @override
  String get errorNotAllowed => 'Це може зробити лише ця людина або власник групи.';

  @override
  String get errorLinkGroupsOff => 'На цьому сервері не можна відкривати групи лише за посиланням.';

  @override
  String get errorMemberClaimed => 'Хтось уже приєднався як цей учасник.';

  @override
  String get errorMemberLeft => 'Хтось із цієї групи вийшов із неї.';

  @override
  String get errorInvalidEmail => 'Введіть адресу електронної пошти.';

  @override
  String get errorInvalidPassword => 'Використайте від 8 до 200 символів.';

  @override
  String get errorEmailTaken => 'Обліковий запис із цією адресою вже є. Увійдіть у нього.';

  @override
  String get errorSignupClosed => 'На цьому сервері не можна створювати нові облікові записи.';

  @override
  String get errorInvalidCredentials => 'Адреса електронної пошти й пароль не збігаються.';

  @override
  String get errorWrongPassword => 'Поточний пароль неправильний.';

  @override
  String get errorAccountsOff => 'На цьому сервері не використовуються облікові записи.';

  @override
  String get errorInvalidAmount => 'Введіть суму більшу за нуль.';

  @override
  String get errorTooManyDecimals => 'Для цієї валюти забагато цифр після коми.';

  @override
  String get errorAmountTooLarge => 'Ця сума завелика.';

  @override
  String get errorNoShares => 'Виберіть хоча б одного учасника, щоб розподілити витрату.';

  @override
  String get errorInvalidShare => 'Частка має бути числом.';

  @override
  String get errorExactTotal => 'Суми мають дорівнювати загальній сумі.';

  @override
  String get errorPayersTotal => 'Сума сплаченого всіма має дорівнювати загальній сумі.';

  @override
  String get categoryFood => 'Їжа й напої';

  @override
  String get categoryGroceries => 'Продукти';

  @override
  String get categoryTransport => 'Транспорт';

  @override
  String get categoryTravel => 'Подорожі';

  @override
  String get categoryLodging => 'Проживання';

  @override
  String get categoryRent => 'Оренда';

  @override
  String get categoryUtilities => 'Комунальні послуги';

  @override
  String get categoryEntertainment => 'Розваги';

  @override
  String get categoryShopping => 'Покупки';

  @override
  String get categoryHealth => 'Здоров’я';

  @override
  String get categoryGifts => 'Подарунки';

  @override
  String get categoryOther => 'Інше';

  @override
  String get groupNew => 'Нова група';

  @override
  String get groupSwitch => 'Змінити групу';

  @override
  String get groupReorder => 'Перетягніть, щоб змінити порядок';

  @override
  String get groupCreate => 'Створити групу';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учасника',
      many: '$count учасників',
      few: '$count учасники',
      two: '$count учасники',
      one: '$count учасник',
    );
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return 'Вам винні $amount';
  }

  @override
  String pillOwe(String amount) {
    return 'Ви винні $amount';
  }

  @override
  String get pillSettled => 'Усі розрахувалися';

  @override
  String get groupMissingTitle => 'Групу не знайдено';

  @override
  String get groupMissingBody =>
      'Групу видалили або її посилання скинули. Попросіть когось із групи надіслати нове посилання.';

  @override
  String get groupLockedTitle => 'Увійдіть, щоб відкрити цю групу';

  @override
  String get groupLockedBody =>
      'Цю групу можуть відкрити лише облікові записи її учасників. Увійдіть в обліковий запис учасника групи.';

  @override
  String get groupForget => 'Прибрати з цього пристрою';

  @override
  String get groupLinkOtherServer =>
      'Це посилання веде на інший сервер. Під’єднайтеся до нього, щоб відкрити групу.';

  @override
  String get openLinkTitle => 'Відкрити посилання на групу';

  @override
  String get openLinkBody => 'Вставте посилання, яким із вами поділилися, щоб приєднатися до групи.';

  @override
  String get openLinkLabel => 'Посилання на групу';

  @override
  String get openLinkAction => 'Відкрити';

  @override
  String get openLinkInvalid => 'Схоже, це не посилання на групу Balnana.';

  @override
  String get groupName => 'Назва групи';

  @override
  String get groupNameHint => 'Подорож до Лісабона';

  @override
  String get groupCurrency => 'Валюта';

  @override
  String get groupCurrencyHelp => 'Усі витрати в цій групі будуть у цій валюті. Змінити її пізніше не можна.';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name. Усі витрати в цій групі будуть у цій валюті. Змінити її пізніше не можна.';
  }

  @override
  String get currencyChoose => 'Виберіть валюту';

  @override
  String get currencySearchHint => 'Пошук за кодом або назвою';

  @override
  String get currencySuggested => 'Рекомендовані';

  @override
  String get currencyAll => 'Усі валюти';

  @override
  String currencyUseTyped(String code) {
    return 'Використати $code';
  }

  @override
  String get currencyNoMatch => 'Валюту не знайдено. Введіть її трилітерний код, щоб використати.';

  @override
  String get groupSymbol => 'Символ';

  @override
  String get groupSymbolChoose => 'Виберіть символ';

  @override
  String groupSymbolExample(String example) {
    return 'Суми матимуть вигляд $example';
  }

  @override
  String get groupColor => 'Колір';

  @override
  String colorSwatch(int number, int count) {
    return 'Колір $number із $count';
  }

  @override
  String get groupPeople => 'Учасники';

  @override
  String get groupYourName => 'Ваше ім’я';

  @override
  String groupPersonName(int number) {
    return 'Учасник $number';
  }

  @override
  String get groupAddPerson => 'Додати учасника';

  @override
  String get groupPeopleHelp =>
      'Пізніше можна додати інших учасників або вони можуть приєднатися за посиланням.';

  @override
  String get identityTitle => 'Хто ви?';

  @override
  String get identityBody =>
      'Виберіть своє ім’я, щоб Balnana показувала, скільки ви винні. Його пам’ятатиме лише цей пристрій.';

  @override
  String get identityNew => 'Я новий учасник';

  @override
  String get identityNewTitle => 'Приєднатися до групи';

  @override
  String get identityJoin => 'Приєднатися';

  @override
  String get identityChange => 'Хто ви';

  @override
  String get identityNone => 'Ще не вибрано';

  @override
  String get memberName => 'Ім’я';

  @override
  String memberYou(String name) {
    return '$name (ви)';
  }

  @override
  String get memberAdd => 'Додати учасника';

  @override
  String get memberAddTitle => 'Додати учасника';

  @override
  String get memberRename => 'Змінити ім’я';

  @override
  String get memberRenameTitle => 'Змінити ім’я';

  @override
  String memberRemoveTitle(String name) {
    return 'Видалити $name?';
  }

  @override
  String get memberRemoveBody => 'Витрати й баланс цього учасника залишаться в групі.';

  @override
  String get groupLinkCopied => 'Посилання скопійовано. Кожен, хто має його, може відкрити цю групу.';

  @override
  String get groupShare => 'Поділитися посиланням';

  @override
  String get groupSettings => 'Налаштування групи';

  @override
  String get groupEdit => 'Редагувати групу';

  @override
  String get groupSharing => 'Спільний доступ';

  @override
  String get groupCopyLink => 'Скопіювати посилання';

  @override
  String get groupQrCode => 'Показати QR-код';

  @override
  String get groupQrCodeHelp => 'Учасники можуть відсканувати посилання камерою телефона.';

  @override
  String groupQrLabel(String group) {
    return 'QR-код посилання на групу $group';
  }

  @override
  String get groupCopyLinkHelp => 'Кожен, хто має посилання, може переглядати й редагувати цю групу.';

  @override
  String get groupCopyLinkHelpAccounts => 'Ті, хто має посилання, можуть попросити приєднатися після входу.';

  @override
  String get linkAccessTitle => 'Доступ для всіх за посиланням';

  @override
  String get linkAccessHelp => 'Дозволити переглядати й редагувати без облікового запису';

  @override
  String get resetLinkTitle => 'Скинути посилання';

  @override
  String get resetLinkHelp => 'Створити нове посилання; старе перестане працювати';

  @override
  String get resetLinkBody =>
      'Поточне посилання перестане працювати для всіх. Поділіться новим посиланням із тими, кому потрібен доступ.';

  @override
  String get resetLinkAction => 'Скинути';

  @override
  String get resetLinkDone => 'Посилання скинуто. Поділіться новим.';

  @override
  String get groupThisDevice => 'Цей пристрій';

  @override
  String get groupData => 'Дані';

  @override
  String get categoriesTitle => 'Категорії';

  @override
  String get categoriesHelp => 'Додавайте власні категорії або приховуйте ті, якими не користуєтеся';

  @override
  String get categoriesOwn => 'Категорії групи';

  @override
  String get categoriesOwnEmpty => 'У групі ще немає власних категорій.';

  @override
  String get categoriesBuiltIn => 'Вбудовані';

  @override
  String get categoriesBuiltInHelp =>
      'Приховані категорії не пропонуються для нових витрат. У наявних витратах вони залишаються.';

  @override
  String get categoryAdd => 'Додати категорію';

  @override
  String get categoryEdit => 'Редагувати категорію';

  @override
  String get categoryName => 'Назва';

  @override
  String get categoryDelete => 'Видалити категорію';

  @override
  String categoryDeleteTitle(String name) {
    return 'Видалити $name?';
  }

  @override
  String get categoryDeleteBody => 'Витрати в цій категорії залишаться без категорії.';

  @override
  String get categoryDeleteAction => 'Видалити';

  @override
  String get exportCsv => 'Експортувати в CSV';

  @override
  String get exportCsvHelp => 'Усі витрати й платежі у форматі для таблиці';

  @override
  String get exportCsvDone => 'Експортовано';

  @override
  String get forgetTitle => 'Прибрати з цього пристрою';

  @override
  String get forgetHelp => 'Для інших учасників група залишиться на сервері';

  @override
  String get forgetBody => 'Ви зможете знову відкрити її за посиланням.';

  @override
  String get groupYou => 'Ви';

  @override
  String get leaveTitle => 'Вийти з групи';

  @override
  String get leaveHelp => 'Ваші витрати залишаться; ви зможете приєднатися знову за посиланням';

  @override
  String get leaveBody => 'Група зникне з вашого списку. Ваші витрати й баланс у групі залишаться.';

  @override
  String get leaveAction => 'Вийти';

  @override
  String get tabExpenses => 'Витрати';

  @override
  String get heroWhoTitle => 'Хто ви в цій групі?';

  @override
  String get heroWhoBody => 'Виберіть своє ім’я, щоб побачити, скільки ви винні й скільки вам винні.';

  @override
  String get heroWhoAction => 'Вибрати';

  @override
  String get heroJoinTitle => 'Ви переглядаєте цю групу';

  @override
  String get heroJoinBody => 'Приєднайтеся, щоб додавати витрати й бачити свій баланс.';

  @override
  String get joinAction => 'Приєднатися';

  @override
  String get heroOwed => 'Вам винні';

  @override
  String get heroOwe => 'Ви винні';

  @override
  String get heroSettled => 'Ви розрахувалися';

  @override
  String heroYouAre(String name) {
    return 'Ви — $name';
  }

  @override
  String get expenseAdd => 'Додати витрату';

  @override
  String get expensesEmptyTitle => 'Витрат ще немає';

  @override
  String get expensesEmptyBody => 'Додайте першу витрату, і Balnana підрахує, хто кому винен.';

  @override
  String get expensesSearchHint => 'Пошук за назвами, примітками й місцями';

  @override
  String get searchClear => 'Очистити пошук';

  @override
  String get expensesNoMatchTitle => 'Нічого не знайдено';

  @override
  String get expensesNoMatchBody => 'Спробуйте інші слова або зменште кількість фільтрів.';

  @override
  String get filterAnyone => 'Усі';

  @override
  String get filterAnyCategory => 'Усі категорії';

  @override
  String get filterPayments => 'Платежі';

  @override
  String get filterClear => 'Очистити фільтри';

  @override
  String get periodAll => 'За весь час';

  @override
  String get periodThisMonth => 'Цього місяця';

  @override
  String get periodLastMonth => 'Минулого місяця';

  @override
  String get periodThisYear => 'Цього року';

  @override
  String get periodPickDays => 'Вибрати дати…';

  @override
  String get statsTitle => 'Витрати';

  @override
  String get statsTotal => 'Усього витрачено';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count витрати',
      many: '$count витрат',
      few: '$count витрати',
      two: '$count витрати',
      one: '$count витрата',
    );
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'За категоріями';

  @override
  String get statsByMember => 'Сума платежів і частка кожного учасника';

  @override
  String get statsPaid => 'Сплачено';

  @override
  String get statsShare => 'Частка';

  @override
  String get statsByMonth => 'За місяцями';

  @override
  String get statsNoCategory => 'Без категорії';

  @override
  String get statsEmptyTitle => 'Нічого не витрачено';

  @override
  String get statsEmptyBody => 'За цей період витрат немає.';

  @override
  String get statsShowExpenses => 'Показати ці витрати';

  @override
  String get dateToday => 'Сьогодні';

  @override
  String get dateYesterday => 'Учора';

  @override
  String paymentTitle(String from, String to) {
    return 'Переказ від $from до $to';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return 'Сплачено $amount · $name';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учасника сплатили $amount',
      many: '$count учасників сплатили $amount',
      few: '$count учасники сплатили $amount',
      two: '$count учасники сплатили $amount',
      one: '$count учасник сплатив $amount',
    );
    return '$_temp0';
  }

  @override
  String expensePaidByName(String name) {
    return 'Платник: $name';
  }

  @override
  String expensePaidByManyNames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учасника сплатили',
      many: '$count учасників сплатили',
      few: '$count учасники сплатили',
      two: '$count учасники сплатили',
      one: '$count учасник сплатив',
    );
    return '$_temp0';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return 'Отримано $amount · $name';
  }

  @override
  String expenseReceivedByName(String name) {
    return 'Отримувач: $name';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учасника отримали',
      many: '$count учасників отримали',
      few: '$count учасники отримали',
      two: '$count учасники отримали',
      one: '$count учасник отримав',
    );
    return '$_temp0';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учасника отримали $amount',
      many: '$count учасників отримали $amount',
      few: '$count учасники отримали $amount',
      two: '$count учасники отримали $amount',
      one: '$count учасник отримав $amount',
    );
    return '$_temp0';
  }

  @override
  String get transactionRefund => 'Повернення коштів';

  @override
  String get transactionIncome => 'Дохід';

  @override
  String get paymentDelete => 'Видалити платіж';

  @override
  String get paymentDeleted => 'Платіж видалено';

  @override
  String expenseDeleted(String title) {
    return 'Витрату «$title» видалено';
  }

  @override
  String get expenseNew => 'Нова витрата';

  @override
  String get expenseEdit => 'Редагувати витрату';

  @override
  String get expenseDelete => 'Видалити';

  @override
  String get expenseAmount => 'Сума';

  @override
  String get expenseTitle => 'За що сплатили?';

  @override
  String get expenseTitleHint => 'Вечеря, квитки, таксі…';

  @override
  String get expenseAmountFromPayers => 'Сума всіх платежів';

  @override
  String expensePaidIn(String currency) {
    return 'Сплачено у валюті $currency';
  }

  @override
  String expenseRate(String from, String to) {
    return '1 $from у $to';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return 'Усього у валюті $currency';
  }

  @override
  String expenseForeignHelp(String currency) {
    return 'Баланс буде у валюті $currency. Введіть курс або суму після конвертації, наприклад із виписки картки.';
  }

  @override
  String get expenseNote => 'Примітка';

  @override
  String get expenseNoteHint => 'Необов’язково';

  @override
  String get expenseLocation => 'Місце';

  @override
  String get expenseLocationHint => 'Де це було? (необов’язково)';

  @override
  String get locationPickOnMap => 'Вибрати на мапі';

  @override
  String get locationUseCurrent => 'Використати поточне місце';

  @override
  String get locationFinding => 'Визначаємо ваше місце…';

  @override
  String get locationChange => 'Змінити на мапі';

  @override
  String get locationRemovePin => 'Прибрати позначку';

  @override
  String get locationOpenInMaps => 'Відкрити в мапах';

  @override
  String get locationPickTitle => 'Вибрати місце';

  @override
  String get locationPickHint => 'Торкніться мапи, щоб поставити позначку';

  @override
  String get locationPickDone => 'Готово';

  @override
  String get locationDenied =>
      'Balnana не має доступу до вашого місця. Дозвольте доступ у налаштуваннях пристрою або браузера.';

  @override
  String get locationOff => 'На цьому пристрої вимкнено визначення місця.';

  @override
  String get locationUnavailable =>
      'Не вдалося визначити ваше місце. Спробуйте ще раз або поставте позначку на мапі.';

  @override
  String get expenseReceipt => 'Чек';

  @override
  String get expenseHasReceipt => 'Є фото чека';

  @override
  String get expenseHasLocation => 'Є місце';

  @override
  String get receiptTakePhoto => 'Зробити фото';

  @override
  String get receiptChoose => 'Вибрати зображення';

  @override
  String get receiptRemove => 'Видалити';

  @override
  String get receiptView => 'Фото чека';

  @override
  String receiptNotSaved(String reason) {
    return 'Витрату збережено, але фото чека — ні. $reason';
  }

  @override
  String get expensePaidByLabel => 'Хто сплатив';

  @override
  String get expenseReceivedForLabel => 'За кого отримано';

  @override
  String get expenseReceivedByLabel => 'Хто отримав';

  @override
  String get expenseMultiplePayers => 'Кілька учасників';

  @override
  String get expenseSplit => 'Розподіл';

  @override
  String get splitEqual => 'Порівну';

  @override
  String get splitExact => 'За сумами';

  @override
  String get splitShares => 'За частками';

  @override
  String splitLeft(String amount) {
    return 'Залишилося розподілити $amount';
  }

  @override
  String splitOver(String amount) {
    return 'Забагато на $amount';
  }

  @override
  String get conflictTitle => 'Змінено в іншому місці';

  @override
  String get conflictReload => 'Перезавантажити';

  @override
  String get expenseChangedElsewhere =>
      'Хтось інший змінив цю витрату. Після перезавантаження ви побачите його версію, а ваші зміни буде відкинуто.';

  @override
  String get expenseNewerTitle => 'Створено новішою версією';

  @override
  String get expenseNewerBody => 'Оновіть Balnana, щоб змінити цей запис.';

  @override
  String get suggestedPayments => 'Рекомендовані платежі';

  @override
  String get allSettled => 'Усі розрахувалися.';

  @override
  String transferYouPay(String name) {
    return 'Ви платите $name';
  }

  @override
  String transferPaysYou(String name) {
    return '$name платить вам';
  }

  @override
  String transferPays(String from, String to) {
    return '$from платить $to';
  }

  @override
  String get recordPayment => 'Записати';

  @override
  String get recordPaymentTitle => 'Записати платіж';

  @override
  String get recordPaymentHelp => 'Записуйте лише гроші, які справді сплатили поза Balnana.';

  @override
  String get paymentRecorded => 'Платіж записано';

  @override
  String activityGroupCreated(String who, String group) {
    return 'Групу $group створено · $who';
  }

  @override
  String activityGroupUpdated(String who) {
    return 'Дані групи змінено · $who';
  }

  @override
  String activityLinkReset(String who) {
    return 'Посилання на групу скинуто · $who';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return 'Додано учасника $name · $who';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return 'Ім’я $oldName змінено на $name · $who';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return 'Учасника $name видалено · $who';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return 'Додано категорію $name · $who';
  }

  @override
  String activityCategoryUpdated(String who) {
    return 'Категорії змінено · $who';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return 'Категорію $name видалено · $who';
  }

  @override
  String activityMemberJoined(String name) {
    return 'Новий учасник групи: $name';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return 'Додано витрату «$title» ($amount) · $who';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return 'Змінено витрату «$title» ($amount) · $who';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return 'Видалено витрату «$title» · $who';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return 'Відновлено витрату «$title» · $who';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return 'Платіж $from → $to на $amount записано · $who';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return 'Платіж на $amount видалено · $who';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return 'Платіж на $amount відновлено · $who';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запису',
      many: '$count записів',
      few: '$count записи',
      two: '$count записи',
      one: '$count запис',
    );
    return '$who: імпортовано $_temp0 з $source';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return 'До витрати «$title» додано фото чека · $who';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return 'З витрати «$title» видалено фото чека · $who';
  }

  @override
  String activityOther(String who) {
    return 'Зміна від $who';
  }

  @override
  String get navGroups => 'Групи';

  @override
  String get navActivity => 'Історія';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get groupsEmptyTitle => 'Груп ще немає';

  @override
  String get groupsEmptyBody => 'Тут з’являться групи, які ви створите або відкриєте за посиланням.';

  @override
  String get groupsNoServerTitle => 'Під’єднайтеся до сервера';

  @override
  String get groupsNoServerBody => 'Balnana зберігає ваші групи на вибраному сервері, наприклад на власному.';

  @override
  String get groupsNoServerAction => 'Вибрати сервер';

  @override
  String get groupsUnreachableTitle => 'Не вдається зв’язатися із сервером';

  @override
  String get groupsUnreachableBody => 'Перевірте з’єднання або адресу сервера в налаштуваннях.';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не вдалося завантажити $count групи, тому їхні зміни не показано.',
      many: 'Не вдалося завантажити $count груп, тому їхні зміни не показано.',
      few: 'Не вдалося завантажити $count групи, тому їхні зміни не показано.',
      two: 'Не вдалося завантажити $count групи, тому їхні зміни не показано.',
      one: 'Не вдалося завантажити $count групу, тому її зміни не показано.',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => 'Тут поки нічого немає';

  @override
  String get activityEmptyBody => 'Тут з’являтимуться нові витрати й платежі у ваших групах.';

  @override
  String get notFoundTitle => 'Сторінку не знайдено';

  @override
  String get notFoundBody => 'Ця адреса не веде на сторінку Balnana.';

  @override
  String get notFoundAction => 'До груп';

  @override
  String get settingsAppearance => 'Вигляд';

  @override
  String get settingsAccount => 'Обліковий запис';

  @override
  String get accountRename => 'Змінити ім’я';

  @override
  String get passwordChange => 'Змінити пароль';

  @override
  String get passwordChanged => 'Пароль змінено. На інших пристроях сеанс завершено.';

  @override
  String get passwordSet => 'Установити пароль';

  @override
  String get passwordSetHelp => 'Увійдіть за адресою електронної пошти або ім’ям користувача й паролем';

  @override
  String get passwordSetDone => 'Пароль установлено. На інших пристроях сеанс завершено.';

  @override
  String get passwordCurrent => 'Поточний пароль';

  @override
  String get passwordNew => 'Новий пароль';

  @override
  String get signOut => 'Вийти';

  @override
  String get accountOAuthLinked => 'Вхід до цього облікового запису. Натисніть, щоб від’єднати.';

  @override
  String get accountOAuthAdd => 'Додати спосіб входу';

  @override
  String accountOAuthAddTitle(String name) {
    return 'Додати $name';
  }

  @override
  String accountOAuthAdded(String name) {
    return 'Тепер можна входити через $name.';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return 'Видалити $name?';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return 'Ви не зможете входити через $name, доки не додасте його знову.';
  }

  @override
  String get accountOAuthRemove => 'Від’єднати';

  @override
  String accountOAuthRemoved(String name) {
    return '$name від’єднано.';
  }

  @override
  String get confirmEmailTitle => 'Підтвердьте електронну пошту';

  @override
  String confirmEmailBody(String email) {
    return 'Для цього сервера потрібна підтверджена адреса електронної пошти. Відкрийте посилання, надіслане на $email.';
  }

  @override
  String get confirmEmailDone => 'Перевірити';

  @override
  String get confirmEmailResend => 'Надіслати посилання ще раз';

  @override
  String get confirmEmailNotYet => 'Адресу ще не підтверджено. Відкрийте посилання з листа.';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get themeSystem => 'Як у системі';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeDark => 'Темна';

  @override
  String get settingsDynamicColor => 'Кольори шпалер';

  @override
  String get settingsDynamicColorSubtitle => 'Використовувати кольори пристрою замість жовтого Balnana';

  @override
  String get settingsWallpaperGroups => 'Кольори шпалер у групах';

  @override
  String get settingsWallpaperGroupsSubtitle =>
      'Групи також використовуватимуть кольори пристрою замість власних';

  @override
  String get settingsPureBlack => 'Чистий чорний';

  @override
  String get settingsPureBlackSubtitle => 'Темніша тема для OLED-екранів';

  @override
  String get settingsMyShare => 'Показувати мою частку';

  @override
  String get settingsMyShareSubtitle =>
      'У витратах показувати, скільки вам винні або скільки винні ви, замість загальної суми.';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get languageSystem => 'Як у системі';

  @override
  String get settingsNotifications => 'Сповіщення';

  @override
  String get settingsNotificationsSubtitle =>
      'Коли хтось додає, змінює або видаляє витрату, у якій ви берете участь';

  @override
  String get settingsNotificationsBlocked =>
      'Сповіщення заблоковано в налаштуваннях телефона. Дозвольте сповіщення для Balnana там.';

  @override
  String get pushChannel => 'Витрати';

  @override
  String get pushChannelDescription =>
      'Коли хтось додає, змінює або видаляє витрату, у якій ви берете участь';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return 'Додано $title · $amount · $who';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return 'Змінено $title · $amount · $who';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return 'Видалено $title · $amount · $who';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return 'Додано $title · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return 'Змінено $title · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return 'Видалено $title · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return 'Переказ $payer → $payee · $amount';
  }

  @override
  String get settingsConnection => 'З’єднання';

  @override
  String get settingsServer => 'Сервер';

  @override
  String get serverNotSet => 'Не вказано';

  @override
  String get settingsAbout => 'Про застосунок';

  @override
  String get aboutVersion => 'Версія';

  @override
  String get aboutLicenses => 'Ліцензії відкритого коду';

  @override
  String get aboutSource => 'Вихідний код';

  @override
  String get aboutSourceCopied => 'Не вдалося відкрити браузер, тож посилання скопійовано';

  @override
  String get serverTitle => 'Сервер';

  @override
  String get serverIntro =>
      'Введіть адресу сервера Balnana. Розмістити його може будь-хто; зазвичай адреса веде на його вебзастосунок.';

  @override
  String get serverUrlLabel => 'Адреса сервера';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => 'Перевірити з’єднання';

  @override
  String get serverSaveAnyway => 'Усе одно зберегти';

  @override
  String get serverReset => 'Використати типову';

  @override
  String serverDefault(String url) {
    return 'Типово: $url';
  }

  @override
  String serverConnected(String version) {
    return 'Під’єднано до Balnana $version';
  }

  @override
  String get serverModeLink => 'Групи доступні за приватним посиланням. Обліковий запис не потрібен.';

  @override
  String get serverModeAccounts => 'Учасники входять в обліковий запис.';

  @override
  String get serverInsecure =>
      'Це з’єднання не зашифровано (http). Усі в мережі можуть читати ваші дані. Для серверів поза домашньою мережею використовуйте https.';

  @override
  String get serverErrorInvalid => 'Введіть вебадресу, наприклад balnana.example.com';

  @override
  String get serverErrorUnreachable => 'Не вдалося під’єднатися. Перевірте адресу й чи працює сервер.';

  @override
  String get serverErrorNotBalnana => 'Сервер відповів, але це не сервер Balnana.';

  @override
  String get serverSaved => 'Сервер збережено';

  @override
  String get signIn => 'Увійти';

  @override
  String get groupSignInTitle => 'Увійдіть, щоб відкрити цю групу';

  @override
  String get groupSignInBody =>
      'Ця група доступна лише її учасникам. Увійдіть, щоб переглянути її або приєднатися.';

  @override
  String get signInTitle => 'З поверненням';

  @override
  String get signInBody => 'Увійдіть, щоб побачити свої групи.';

  @override
  String get signInNoPassword =>
      'На цьому сервері використовується інший спосіб входу. Запитайте адміністратора сервера.';

  @override
  String get registerTitle => 'Створіть обліковий запис';

  @override
  String get registerBody => 'Ваші групи будуть доступні на всіх пристроях.';

  @override
  String get registerAction => 'Створити обліковий запис';

  @override
  String get registerHaveAccount => 'У мене вже є обліковий запис';

  @override
  String get signInNoAccount => 'Створити обліковий запис';

  @override
  String get accountName => 'Ваше ім’я';

  @override
  String get accountNameHelp => 'Так вас бачитимуть учасники груп';

  @override
  String get accountEmail => 'Електронна пошта';

  @override
  String get accountPassword => 'Пароль';

  @override
  String get accountPasswordHelp => 'Щонайменше 8 символів';

  @override
  String get passwordShow => 'Показати пароль';

  @override
  String get passwordHide => 'Приховати пароль';

  @override
  String get joinPickName => 'Вибрати інше ім’я';

  @override
  String joinTitle(String name) {
    return 'Приєднатися: $name';
  }

  @override
  String get joinBody =>
      'Хтось із цих учасників — це ви? Виберіть себе, щоб отримати доступ до своїх витрат.';

  @override
  String get joinBodyNew => 'Приєднайтеся, щоб додавати витрати й переглядати баланс.';

  @override
  String get joinAsNew => 'Я новий учасник';

  @override
  String joinAsName(String name) {
    return 'Приєднатися як $name';
  }

  @override
  String joinTaken(String names) {
    return 'Уже приєдналися: $names';
  }

  @override
  String joinTakenCount(int count) {
    return '$count учасників уже приєдналися.';
  }

  @override
  String get commonContinue => 'Продовжити';

  @override
  String get errorEmailOff => 'Цей сервер не надсилає електронні листи.';

  @override
  String get errorInvalidToken => 'Термін дії цього посилання минув або його вже використали.';

  @override
  String get forgotPasswordTitle => 'Забули пароль?';

  @override
  String get forgotPasswordBody => 'Ми надішлемо вам посилання для створення нового пароля.';

  @override
  String get forgotPasswordAction => 'Надіслати посилання';

  @override
  String get forgotPasswordSent => 'Якщо для цієї адреси є обліковий запис, посилання вже в дорозі.';

  @override
  String get resetPasswordTitle => 'Створіть новий пароль';

  @override
  String get resetPasswordBody => 'Ви вийдете з усіх пристроїв, а потім зможете увійти з новим паролем.';

  @override
  String get resetPasswordAction => 'Зберегти пароль';

  @override
  String get resetPasswordDone => 'Пароль змінено. Увійдіть із новим паролем.';

  @override
  String get verifyEmailTitle => 'Підтвердьте електронну пошту';

  @override
  String get verifyEmailHelp => 'Так ви зможете скинути пароль, якщо забудете його';

  @override
  String verifyEmailSent(String email) {
    return 'Перевірте пошту $email: там має бути посилання.';
  }

  @override
  String get verifyEmailDone => 'Електронну пошту підтверджено';

  @override
  String get verifyEmailDoneBody => 'Дякуємо! Вашу адресу підтверджено.';

  @override
  String get verifyEmailFailed => 'Не вдалося підтвердити електронну пошту';

  @override
  String get inviteByEmail => 'Запросити електронною поштою';

  @override
  String get inviteByEmailHelp => 'Надішліть комусь посилання для приєднання';

  @override
  String get inviteAs => 'Приєднатися як';

  @override
  String get inviteAsHelp => 'Запрошена людина зможе отримати доступ до витрат цього учасника';

  @override
  String get inviteAsAnyone => 'Новий учасник';

  @override
  String get inviteSend => 'Надіслати запрошення';

  @override
  String inviteSent(String email) {
    return 'Запрошення надіслано на $email.';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name запрошує вас до групи $group';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return 'Вас запросили до групи $group';
  }

  @override
  String inviteBody(String email) {
    return 'Створіть обліковий запис із адресою $email, щоб приєднатися, або увійдіть у наявний.';
  }

  @override
  String get inviteBodySignedIn => 'Приєднайтеся, щоб додавати витрати й переглядати баланс.';

  @override
  String get inviteAction => 'Відкрити запрошення';

  @override
  String get inviteMissingTitle => 'Це запрошення не працює';

  @override
  String get inviteMissingBody =>
      'Можливо, термін його дії минув або його вже використали. Попросіть надіслати нове.';

  @override
  String get joinInvitedAs => 'Вас запросили як цього учасника';

  @override
  String signInWith(String provider) {
    return 'Продовжити через $provider';
  }

  @override
  String get signInOr => 'або';

  @override
  String get oauthFailedTitle => 'Не вдалося увійти';

  @override
  String get oauthPendingTitle => 'Для цієї адреси вже є обліковий запис';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider підтверджує, що адреса $email належить вам, але її обліковий запис не підтверджено. Що зробити?';
  }

  @override
  String get oauthPendingLink => 'Додати до цього облікового запису';

  @override
  String get oauthPendingLinkHelp => 'Введіть пароль цього облікового запису. Він і далі працюватиме.';

  @override
  String get oauthPendingTakeOver => 'Отримати доступ до цього облікового запису';

  @override
  String get oauthPendingTakeOverHelp =>
      'Його пароль та інші способи входу буде видалено, а сеанси завершено.';

  @override
  String get oauthPendingNew => 'Створити новий обліковий запис';

  @override
  String oauthPendingNewHelp(String email) {
    return 'Інший обліковий запис збереже групи, але втратить адресу $email.';
  }

  @override
  String get oauthPendingPassword => 'Пароль цього облікового запису';

  @override
  String get oauthPendingWrongPassword => 'Цей пароль неправильний.';

  @override
  String get oauthOtherServer => 'Цей вхід почато на іншому сервері. Увійдіть ще раз.';

  @override
  String get oauthBackToSignIn => 'Назад до входу';

  @override
  String get errorOAuthFailed => 'Не вдалося увійти. Спробуйте ще раз.';

  @override
  String get errorEmailHasAccount =>
      'Обліковий запис із цією адресою вже є. Увійдіть у нього, а потім додайте цей спосіб входу в налаштуваннях.';

  @override
  String get errorIdentityTaken => 'Цей спосіб входу вже належить іншому обліковому запису.';

  @override
  String get errorLastSignInMethod =>
      'Це ваш єдиний спосіб входу. Спершу встановіть пароль або додайте інший спосіб.';

  @override
  String get errorEmailUnverified => 'Спершу підтвердьте адресу електронної пошти.';

  @override
  String get errorOAuthCancelled => 'Вхід скасовано.';

  @override
  String get importTitle => 'Імпорт із Settle Up';

  @override
  String get importAction => 'Імпортувати';

  @override
  String get importIntro =>
      'У Settle Up експортуйте групу у файл CSV, а потім виберіть його тут. Імпортуються витрати, платежі й усі учасники групи, а баланси залишаться незмінними.';

  @override
  String get importChooseFile => 'Вибрати файл CSV';

  @override
  String get importChooseOther => 'Вибрати інший файл';

  @override
  String get importReading => 'Читаємо файл…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(
      expenses,
      locale: localeName,
      other: '$expenses витрати',
      many: '$expenses витрат',
      few: '$expenses витрати',
      two: '$expenses витрати',
      one: '$expenses витрата',
    );
    String _temp1 = intl.Intl.pluralLogic(
      payments,
      locale: localeName,
      other: '$payments платежу',
      many: '$payments платежів',
      few: '$payments платежі',
      two: '$payments платежі',
      one: '$payments платіж',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return 'З $from до $to';
  }

  @override
  String importCurrency(String currency) {
    return 'Валюта: $currency. Для записів в інших валютах використано суми, конвертовані Settle Up.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запису з нульовою сумою пропущено.',
      many: '$count записів із нульовою сумою пропущено.',
      few: '$count записи з нульовою сумою пропущено.',
      two: '$count записи з нульовою сумою пропущено.',
      one: '$count запис із нульовою сумою пропущено.',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => 'Хто з них ви?';

  @override
  String get importUntitled => 'Без назви';

  @override
  String get errorImportFile => 'Схоже, це не файл експорту Settle Up у форматі CSV.';

  @override
  String get errorImportCurrency =>
      'У файлі немає записів без курсу обміну, тому валюту групи визначити не вдалося.';

  @override
  String get errorImportTooBig => 'Цей файл завеликий для імпорту.';

  @override
  String get errorBadImage => 'Не вдалося використати це зображення. Виберіть зображення JPEG, PNG або WebP.';

  @override
  String get errorReceiptTooBig => 'Це зображення завелике. Виберіть файл розміром до 10 МБ.';

  @override
  String get errorImportMe => 'Виберіть, хто з учасників — це ви.';

  @override
  String errorImportRow(int line, String reason) {
    return 'Не вдалося імпортувати рядок $line файлу: $reason';
  }

  @override
  String get errorImportAmount => 'не вдалося прочитати суму.';

  @override
  String get errorImportCounts => 'імена й суми не збігаються.';

  @override
  String get errorImportDate => 'не вдалося прочитати дату.';

  @override
  String get errorImportType => 'тип має бути витратою, переказом або доходом.';

  @override
  String get errorImportTransfer => 'Для переказу потрібні платник і отримувач.';

  @override
  String get errorImportRowCurrency => 'це інша валюта без курсу обміну.';

  @override
  String get adminSetupTitle => 'Налаштування сервера';

  @override
  String get adminSetupBody =>
      'Виберіть пароль адміністратора. Він захищає цю сторінку з налаштуваннями сервера. Імені користувача немає: змінювати налаштування зможе кожен, хто знає пароль.';

  @override
  String get adminSetupCode => 'Код налаштування';

  @override
  String get adminSetupCodeHelp =>
      'На сервері вже є дані, тому під час запуску він вивів код налаштування у свій журнал. Для Docker виконайте: docker compose logs balnana';

  @override
  String get adminSetupAction => 'Установити пароль';

  @override
  String get adminPassword => 'Пароль адміністратора';

  @override
  String get adminPasswordRepeat => 'Повторіть пароль';

  @override
  String get adminPasswordMismatch => 'Паролі не збігаються.';

  @override
  String get adminLoginTitle => 'Адміністрування';

  @override
  String get adminLoginBody => 'Введіть пароль адміністратора, щоб змінити налаштування сервера.';

  @override
  String get adminLoginAction => 'Увійти';

  @override
  String get adminSettingsTitle => 'Налаштування сервера';

  @override
  String get adminSaved => 'Налаштування збережено. Зміни вже діють.';

  @override
  String get adminSaveFailed => 'Зміни не збережено. Перевірте виділені налаштування.';

  @override
  String get adminChangePassword => 'Змінити пароль адміністратора';

  @override
  String get adminPasswordCurrent => 'Поточний пароль';

  @override
  String get adminPasswordNew => 'Новий пароль';

  @override
  String get adminPasswordChanged => 'Пароль змінено. Сеанси інших адміністраторів завершено.';

  @override
  String get adminSignOut => 'Вийти з адміністрування';

  @override
  String get adminBackHome => 'Назад до Balnana';

  @override
  String get adminRequireEmail => 'Вимагати адресу електронної пошти';

  @override
  String get adminRequireEmailHelp =>
      'Якщо вимкнено, користувачі реєструються з іменем користувача й можуть не вказувати адресу електронної пошти. Для входу можна використовувати будь-яке з них.';

  @override
  String get adminRequireEmailUnused =>
      'Застосовується лише для входу за адресою електронної пошти й паролем, який вимкнено.';

  @override
  String get accountUsername => 'Ім’я користувача';

  @override
  String get accountUsernameHelp =>
      'Від 3 до 32 літер, цифр, крапок, дефісів або підкреслень. Використовується для входу.';

  @override
  String get accountEmailOptional => 'Електронна пошта (необов’язково)';

  @override
  String get accountEmailOptionalHelp =>
      'На неї можна надсилати запрошення до груп і посилання для скидання забутого пароля.';

  @override
  String get accountLogin => 'Електронна пошта або ім’я користувача';

  @override
  String get errorInvalidUsername =>
      'Використайте від 3 до 32 літер, цифр, крапок, дефісів або підкреслень. Починайте з літери або цифри.';

  @override
  String get errorUsernameTaken => 'Це ім’я користувача вже зайняте.';

  @override
  String get adminDiscardTitle => 'Відкинути зміни?';

  @override
  String get adminDiscardBody => 'Зміни налаштувань ще не збережено.';

  @override
  String get adminDiscard => 'Відкинути';

  @override
  String adminLocked(String key) {
    return 'На сервері задано значення $key';
  }

  @override
  String adminDefault(String value) {
    return 'Типово: $value';
  }

  @override
  String get adminSecretSaved => 'Збережено. Введіть нове значення, щоб замінити його.';

  @override
  String get adminSecretRemoved => 'Буде видалено після збереження.';

  @override
  String get adminSecretRemove => 'Видалити збережене значення';

  @override
  String get adminSectionGeneral => 'Загальні';

  @override
  String get adminSectionAccess => 'Доступ';

  @override
  String get adminSectionMaps => 'Мапи';

  @override
  String get adminSectionAccounts => 'Облікові записи';

  @override
  String get adminSectionAccountsBody => 'Застосовується, якщо для доступу потрібні облікові записи.';

  @override
  String get adminSectionEmail => 'Електронна пошта (SMTP)';

  @override
  String get adminSectionEmailBody => 'Підтвердження адрес, скидання паролів і запрошення.';

  @override
  String get adminSmtpOn => 'Надсилати електронні листи';

  @override
  String get adminSectionGoogle => 'Вхід через Google';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Додайте $url як URI перенаправлення в консолі Google Cloud.';
  }

  @override
  String get adminGoogleOn => 'Дозволити вхід через Google';

  @override
  String get adminGoogleOnHelp => 'Користувачі входять через свій обліковий запис Google.';

  @override
  String get adminSectionOidc => 'Вхід через OpenID Connect';

  @override
  String adminSectionOidcBody(String url) {
    return 'Зареєструйте $url як URI перенаправлення в постачальника.';
  }

  @override
  String get adminOidcHelp =>
      'Будь-який постачальник OpenID Connect, наприклад Authentik, Keycloak або Dex. Можна додати кілька.';

  @override
  String get adminOidcAdd => 'Додати постачальника';

  @override
  String get adminOidcRemove => 'Видалити постачальника';

  @override
  String get adminOidcNew => 'Новий постачальник';

  @override
  String get adminOidcId => 'ID';

  @override
  String get adminOidcIdHelp =>
      'Лише малі літери, цифри й дефіси. Це частина URI перенаправлення, тож змінити його пізніше не можна.';

  @override
  String get adminOidcIdInvalid =>
      'Використайте до 32 малих літер, цифр і дефісів. Починайте з літери або цифри.';

  @override
  String get adminOidcIdTaken => 'Постачальник із таким ID уже є.';

  @override
  String get adminTrustEmail => 'Довіряти його підтвердженню адреси';

  @override
  String get adminGoogleTrustEmailHelp =>
      'Якщо в Google є обліковий запис із цією адресою, вхід через Google відкриє його. Якщо вимкнено, потрібно буде ввійти з паролем і додати Google в налаштуваннях.';

  @override
  String get adminOidcTrustEmailHelp =>
      'Вмикайте лише для постачальника, якому довіряєте перевірку адрес електронної пошти. Якщо вимкнено, користувачі з обліковим записом входять із паролем і додають постачальника в налаштуваннях.';

  @override
  String get adminRequireVerified => 'Вимагати підтвердження електронної пошти';

  @override
  String get adminRequireVerifiedHelp =>
      'Обліковим записом не можна користуватися, доки адресу не підтверджено. Якщо довірений спосіб входу підтвердить ту саму адресу, він отримає доступ до непідтвердженого облікового запису. Якщо вимкнено, користувачі самі вибирають, що робити.';

  @override
  String get adminRequireVerifiedUnused => 'Потрібне надсилання електронних листів.';

  @override
  String get adminSectionAndroid => 'Посилання для Android';

  @override
  String get adminSectionAndroidBody =>
      'Версії Android для цього сервера відкривають його посилання в застосунку. Щоб не питати дозволу, укажіть SHA-256 відбитки сертифікатів, якими підписано ці версії.';

  @override
  String get adminSectionAdmin => 'Адміністратор';

  @override
  String get adminPublicUrl => 'Публічна адреса';

  @override
  String get adminPublicUrlHelp =>
      'Адреса, за якою користувачі відкривають сервер. На її основі створюються посилання на групи й електронні листи.';

  @override
  String get adminSourceUrl => 'Посилання на вихідний код';

  @override
  String get adminSourceUrlHelp =>
      'Де користувачі можуть отримати вихідний код сервера. Ліцензія AGPL-3.0 вимагає цього, якщо ви запускаєте змінену версію.';

  @override
  String get adminAuthMode => 'Доступ';

  @override
  String get adminAuthModeLink => 'Посилання на групи';

  @override
  String get adminAuthModeLinkHelp => 'Без входу: для доступу до групи достатньо приватного посилання.';

  @override
  String get adminAuthModeAccounts => 'Облікові записи';

  @override
  String get adminAuthModeAccountsHelp =>
      'Учасники входять у систему, а за посиланням до групи можуть приєднатися лише ті, хто ввійшов.';

  @override
  String get adminPasswordLogin => 'Вхід за електронною поштою й паролем';

  @override
  String get adminPasswordForced =>
      'Буде ввімкнено, доки не налаштовано вхід через Google або OpenID Connect, щоб завжди залишався спосіб увійти.';

  @override
  String get adminSignup => 'Хто може створювати обліковий запис';

  @override
  String get adminSignupOpen => 'Усі';

  @override
  String get adminSignupOpenHelp => 'Зареєструватися може кожен, хто має доступ до сервера.';

  @override
  String get adminSignupInvite => 'Запрошені';

  @override
  String get adminSignupInviteHelp =>
      'Зареєструватися можуть лише люди, запрошені до групи електронною поштою, і лише з адресою, на яку надійшло запрошення. Самого посилання на групу недостатньо. Для запрошень потрібно ввімкнути електронну пошту.';

  @override
  String get adminSignupClosed => 'Ніхто';

  @override
  String get adminSignupClosedHelp => 'Реєстрація закрита. Наявні облікові записи й далі працюють.';

  @override
  String get adminSignupHelp => 'Перший обліковий запис можна створити завжди.';

  @override
  String get adminLinkGroups => 'Дозволити відкривати групи за посиланням';

  @override
  String get adminLinkGroupsHelp =>
      'Власники груп можуть надати доступ кожному, хто має посилання, без входу.';

  @override
  String get adminSmtpHost => 'Поштовий сервер';

  @override
  String get adminSmtpPort => 'Порт';

  @override
  String get adminSmtpUser => 'Ім’я користувача';

  @override
  String get adminSmtpPassword => 'Пароль';

  @override
  String get adminSmtpFrom => 'Відправник';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'ID клієнта';

  @override
  String get adminClientSecret => 'Секрет клієнта';

  @override
  String get adminOidcIssuer => 'URL видавця';

  @override
  String get adminOidcName => 'Назва кнопки';

  @override
  String get adminOidcNameHelp => 'Показується на сторінці входу в написі «Продовжити через …».';

  @override
  String get adminFingerprints => 'Відбитки сертифікатів';

  @override
  String get adminFingerprintsHelp =>
      'SHA-256, через кому. Щоб переглянути їх, скористайтеся командами keytool -list -v і apksigner verify --print-certs.';

  @override
  String get adminInvalidValue => 'Неприпустиме значення.';

  @override
  String get adminInvalidUrl => 'Введіть повну адресу, що починається з https:// або http://.';

  @override
  String get adminInvalidFrom =>
      'Введіть відправника, наприклад Balnana <balnana@example.com>; потрібна адреса електронної пошти.';

  @override
  String get adminInvalidPort => 'Введіть номер порту від 1 до 65535.';

  @override
  String get adminInvalidRequired => 'Це потрібно для цього постачальника входу.';

  @override
  String get adminInvalidFingerprint =>
      'Введіть SHA-256 відбитки: по 64 шістнадцяткові цифри, розділені двокрапками або без них.';

  @override
  String get adminNeedsSignIn =>
      'Для облікових записів потрібен спосіб входу: увімкніть вхід за електронною поштою й паролем або налаштуйте постачальника.';

  @override
  String get adminLockedChange => 'Це значення задано на сервері, тож тут його не змінити.';

  @override
  String get errorAdminRequired => 'Сеанс адміністратора завершився. Увійдіть знову.';

  @override
  String get errorAdminWrongPassword => 'Цей пароль неправильний.';

  @override
  String get errorInvalidSetupCode => 'Код налаштування неправильний. Знайдіть його в журналі сервера.';

  @override
  String get errorAlreadySetUp => 'Цей сервер уже налаштовано. Увійдіть із паролем адміністратора.';

  @override
  String get linkOpening => 'Відкриваємо посилання…';

  @override
  String get linkForeignTitle => 'Це посилання веде на інший сервер';

  @override
  String linkForeignBody(String server) {
    return 'Застосунок під’єднано до $server, а посилання належить іншому серверу. Змініть сервер у налаштуваннях, щоб відкрити його.';
  }

  @override
  String get linkInvalidTitle => 'Не вдалося відкрити посилання';

  @override
  String get linkInvalidBody => 'Застосунок не розпізнає це посилання Balnana.';

  @override
  String get linkGoHome => 'До груп';

  @override
  String get linkOpenInBrowser => 'Відкрити в браузері';

  @override
  String get privacyTitle => 'Політика конфіденційності';

  @override
  String get privacyIntro =>
      'Balnana — програмне забезпечення з відкритим кодом. Оператор сервера, до якого під’єднано застосунок, вирішує, де зберігати ваші дані, і відповідає за них. На цій сторінці описано, що саме зберігає та робить програмне забезпечення.';

  @override
  String get privacyStoredTitle => 'Що зберігається';

  @override
  String get privacyStoredBody =>
      'Створені вами групи й ті, до яких ви приєдналися: їхні назви, імена учасників, витрати, платежі, примітки, фото чеків і місця, додані до витрат. Якщо у вас є обліковий запис, також зберігаються ваше ім’я, адреса електронної пошти або ім’я користувача, хеш пароля (сам пароль ніколи не зберігається) і спосіб входу, наприклад Google. Якщо ввімкнено сповіщення, зберігається ідентифікатор пристрою й адреса, надана службою push-сповіщень.';

  @override
  String get privacyUseTitle => 'Як це використовується';

  @override
  String get privacyUseBody =>
      'Лише для роботи застосунку: показувати групи їхнім учасникам, обчислювати баланси й надсилати потрібні листи та сповіщення, наприклад для підтвердження адреси, скидання пароля й запрошень. У застосунку немає реклами й аналітики, а дані не продаються.';

  @override
  String get privacySharedTitle => 'Хто має доступ';

  @override
  String get privacySharedBody =>
      'Усі учасники групи бачать її учасників, витрати й історію. Якщо група доступна за посиланням, відкрити її може кожен, хто має посилання. Для входу через Google використовується Google. Якщо оператор увімкнув сповіщення, вони надходять через службу push-сповіщень вашого телефона: Firebase Cloud Messaging від Google або іншу встановлену вами службу UnifiedPush, наприклад ntfy. Вміст сповіщень шифрується під час передавання. Мапи завантажуються від вибраного оператором постачальника — OpenFreeMap, якщо налаштування не змінювали. Він бачить вашу мережеву адресу й область, яку ви переглядаєте. Місце пристрою зчитується лише після натискання «Використати поточне місце», і зберігається лише вибрана вами точка.';

  @override
  String get privacyDeviceTitle => 'На цьому пристрої';

  @override
  String get privacyDeviceBody =>
      'Застосунок зберігає адресу сервера, ваші налаштування й копію груп на випадок відсутності зв’язку. Після видалення застосунку ці дані буде видалено.';

  @override
  String get privacyDeleteTitle => 'Видалення даних';

  @override
  String get privacyDeleteBody =>
      'Обліковий запис можна видалити в налаштуваннях. Ваше ім’я залишиться в групах як учасник без власника, щоб баланси й далі сходилися. Групи, до яких більше ніхто не має доступу, буде видалено. Власник групи може видалити всю групу в її налаштуваннях. Видалені групи та фото видалених витрат стираються остаточно через 30 днів. З інших питань зверніться до оператора сервера.';

  @override
  String get privacyOperatorPolicy => 'Політика конфіденційності оператора';

  @override
  String get privacyLink => 'Конфіденційність';

  @override
  String get accountEmailAdd => 'Додати адресу електронної пошти';

  @override
  String get accountEmailChange => 'Змінити адресу електронної пошти';

  @override
  String get accountEmailNew => 'Адреса електронної пошти';

  @override
  String get accountEmailVerifyNote =>
      'Ви отримаєте посилання для підтвердження нової адреси. До цього часу залишиться поточна адреса.';

  @override
  String get accountEmailPendingTitle => 'Підтвердьте нову адресу';

  @override
  String accountEmailPendingHelp(String email) {
    return 'Адреса $email замінить поточну, щойно ви відкриєте надіслане на неї посилання. Натисніть, щоб надіслати його ще раз.';
  }

  @override
  String get accountEmailRemoveNote =>
      'Залиште поле порожнім, щоб видалити адресу. Ви й далі зможете входити за ім’ям користувача.';

  @override
  String get accountEmailSaved => 'Адресу електронної пошти збережено';

  @override
  String get accountEmailRemoved => 'Адресу електронної пошти видалено';

  @override
  String get accountConfirmPassword => 'Ваш пароль';

  @override
  String get accountConfirmPasswordHelp => 'Щоб підтвердити, що це ви.';

  @override
  String get errorEmailNeeded => 'Ви входите за адресою електронної пошти, тому її не можна видалити.';

  @override
  String get accountDelete => 'Видалити обліковий запис';

  @override
  String get accountDeleteHelp => 'Видалити обліковий запис із цього сервера';

  @override
  String get accountDeleteTitle => 'Видалити обліковий запис?';

  @override
  String get accountDeleteBody =>
      'Ваш обліковий запис буде видалено назавжди, а сеанс завершено. У групах ваше ім’я залишиться як учасник без власника, щоб баланси й далі сходилися. Групи, у яких не залишиться інших учасників, буде видалено.';

  @override
  String get accountDeleteAction => 'Видалити назавжди';

  @override
  String get accountDeleted => 'Ваш обліковий запис видалено.';

  @override
  String get accountDeletePageSignedOut => 'Увійдіть, щоб видалити обліковий запис на цьому сервері.';

  @override
  String get accountDeletePageLinkMode =>
      'На цьому сервері немає облікових записів: для доступу достатньо посилання на групу. Щоб видалити групу з усіма даними, відкрийте її налаштування й виберіть «Видалити групу».';

  @override
  String get groupDelete => 'Видалити групу';

  @override
  String get groupDeleteHelp => 'Видалити групу й усі її витрати для всіх учасників';

  @override
  String groupDeleteTitle(String name) {
    return 'Видалити $name?';
  }

  @override
  String get groupDeleteBody =>
      'Групу, усі її витрати, платежі й історію буде видалено для всіх. Цю дію не можна скасувати. Введіть назву групи для підтвердження.';

  @override
  String get groupDeleteName => 'Назва групи';

  @override
  String get groupDeleteAction => 'Видалити назавжди';

  @override
  String get groupDeleted => 'Групу видалено';

  @override
  String get groupDeleteOwnerOnly => 'Видалити групу може лише її власник.';

  @override
  String get expenseDiscardTitle => 'Відкинути зміни?';

  @override
  String get expenseDiscardBody => 'Зміни цієї витрати ще не збережено.';

  @override
  String get expenseDiscard => 'Відкинути';

  @override
  String get adminPrivacyUrl => 'Посилання на політику конфіденційності';

  @override
  String get adminPrivacyUrlHelp =>
      'Політика конфіденційності, потрібна магазинам застосунків. Якщо поле порожнє, застосунок показує загальну політику про дані Balnana.';

  @override
  String get adminMapTiles => 'Тайли мапи';

  @override
  String get adminMapSource => 'Джерело мапи';

  @override
  String get adminMapSourceStyle => 'Векторний стиль';

  @override
  String get adminMapSourceStyleHelp =>
      'Мапи на основі стилю MapLibre, наприклад безплатного OpenFreeMap. Ключ не потрібен.';

  @override
  String get adminMapSourceTiles => 'Растрові тайли';

  @override
  String get adminMapSourceTilesHelp => 'Мапи зображеннями тайлів, наприклад від OpenStreetMap.';

  @override
  String get adminMapSourceOff => 'Вимкнено';

  @override
  String get adminMapSourceOffHelp => 'Мапи вимкнено. Назви місць і координати у витратах зберігаються.';

  @override
  String get adminMapStyle => 'URL стилю';

  @override
  String get adminMapStyleHelp =>
      'Адреса файлу style.json для MapLibre, наприклад Liberty (типовий варіант), Bright або Positron від OpenFreeMap.';

  @override
  String get adminMapTilesHelp =>
      'Шаблон URL для растрових тайлів із z, x і y у фігурних дужках, як у типовому варіанті. Сервери OpenStreetMap призначені лише для невеликого навантаження; для завантаженого сервера використовуйте постачальника тайлів.';

  @override
  String get adminMapAttribution => 'Зазначення джерела мапи';

  @override
  String get adminMapAttributionHelp =>
      'Показується на кожній мапі згідно з вимогами постачальника. Якщо поле порожнє, стиль показує зазначені в ньому джерела, а тайли вказують OpenStreetMap.';

  @override
  String get adminInvalidMapTiles => 'Введіть шаблон URL http(s) із z, x і y у фігурних дужках.';

  @override
  String get adminUsers => 'Облікові записи';

  @override
  String get adminUsersSearch => 'Пошук за ім’ям, електронною поштою або іменем користувача';

  @override
  String adminUsersShown(int shown, int total) {
    return 'Показано $shown із $total облікових записів';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count облікового запису',
      many: '$count облікових записів',
      few: '$count облікові записи',
      two: '$count облікові записи',
      one: '$count обліковий запис',
    );
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => 'Облікових записів не знайдено.';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count групи',
      many: '$count груп',
      few: '$count групи',
      two: '$count групи',
      one: '$count група',
      zero: 'Немає груп',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => 'не підтверджено';

  @override
  String adminUserDeleteTitle(String name) {
    return 'Видалити обліковий запис $name?';
  }

  @override
  String get adminUserDeleteBody =>
      'Обліковий запис буде видалено назавжди, а сеанс завершено на всіх пристроях. Його ім’я залишиться в групах як учасник без власника; групи без інших учасників буде видалено.';

  @override
  String get adminUserDeleted => 'Обліковий запис видалено';

  @override
  String get commonDone => 'Готово';

  @override
  String get crowdSearch => 'Пошук учасників';

  @override
  String get crowdNoMatch => 'Нікого не знайдено.';

  @override
  String get crowdAll => 'Усі';

  @override
  String get crowdNone => 'Ніхто';

  @override
  String crowdChosen(int count, int total) {
    return 'Вибрано $count із $total';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ще $count',
      many: 'Ще $count',
      few: 'Ще $count',
      two: 'Ще $count',
      one: 'Ще $count',
    );
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => 'Показати менше';

  @override
  String get crowdSort => 'Сортувати';

  @override
  String crowdShowAll(int count) {
    return 'Показати всіх: $count';
  }

  @override
  String get crowdBalances => 'Баланс усіх';

  @override
  String get crowdSomeoneElse => 'Хтось інший';

  @override
  String get crowdChoosePayers => 'Виберіть, хто платив';

  @override
  String get crowdFilterTitle => 'Чиї витрати?';

  @override
  String get myGroupsTitle => 'Посилання на мої групи';

  @override
  String get myGroupsExport => 'Експортувати мої групи';

  @override
  String get myGroupsExportHelp =>
      'Скопіюйте посилання на групи, щоб створити резервну копію або перенести їх на інший пристрій.';

  @override
  String get myGroupsPrivate =>
      'Зберігайте ці посилання в таємниці. Кожен, хто має посилання, може відкрити групу.';

  @override
  String get myGroupsCopy => 'Скопіювати посилання';

  @override
  String get myGroupsImport => 'Імпортувати групи';

  @override
  String get myGroupsImportHelp =>
      'Вставте посилання на групи з цього сервера, по одному в рядку. Наявні групи збережуть своє місце й ідентифікатор.';

  @override
  String get myGroupsLinks => 'Посилання на групи';

  @override
  String get myGroupsImportAction => 'Імпортувати посилання';

  @override
  String get myGroupsInvalid =>
      'Введіть правильні посилання на групи, по одному в рядку. Нічого не імпортовано.';

  @override
  String get myGroupsServerChanged =>
      'Вибраний сервер змінився. Закрийте це вікно й імпортуйте посилання на їхньому сервері.';

  @override
  String myGroupsLimit(int count) {
    return 'Для кожного сервера можна зберегти не більш ніж $count посилань на групи. Нічого не імпортовано.';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Імпортовано $count нового посилання на групу.',
      many: 'Імпортовано $count нових посилань на групи.',
      few: 'Імпортовано $count нові посилання на групи.',
      two: 'Імпортовано $count нові посилання на групи.',
      one: 'Імпортовано $count нове посилання на групу.',
      zero: 'Ці групи вже збережено.',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => 'Повторення';

  @override
  String get repeatNever => 'Не повторювати';

  @override
  String get repeatDaily => 'Щодня';

  @override
  String get repeatWeekly => 'Щотижня';

  @override
  String get repeatMonthly => 'Щомісяця';

  @override
  String get repeatYearly => 'Щороку';

  @override
  String get repeatEvery => 'Кожні';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'дня',
      many: 'днів',
      few: 'дні',
      two: 'дні',
      one: 'день',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'тижня',
      many: 'тижнів',
      few: 'тижні',
      two: 'тижні',
      one: 'тиждень',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'місяця',
      many: 'місяців',
      few: 'місяці',
      two: 'місяці',
      one: 'місяць',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'року',
      many: 'років',
      few: 'роки',
      two: 'роки',
      one: 'рік',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Раз на $count дня',
      many: 'Раз на $count днів',
      few: 'Раз на $count дні',
      two: 'Раз на $count дні',
      one: 'Раз на $count день',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Раз на $count тижня',
      many: 'Раз на $count тижнів',
      few: 'Раз на $count тижні',
      two: 'Раз на $count тижні',
      one: 'Раз на $count тиждень',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Раз на $count місяця',
      many: 'Раз на $count місяців',
      few: 'Раз на $count місяці',
      two: 'Раз на $count місяці',
      one: 'Раз на $count місяць',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Раз на $count року',
      many: 'Раз на $count років',
      few: 'Раз на $count роки',
      two: 'Раз на $count роки',
      one: 'Раз на $count рік',
    );
    return '$_temp0';
  }

  @override
  String get repeatEndNone => 'Без кінцевої дати';

  @override
  String repeatEndOn(String date) {
    return 'До $date';
  }

  @override
  String get repeatEndClear => 'Прибрати кінцеву дату';

  @override
  String get repeatHelp =>
      'Витрата автоматично додається до групи у вказані дати, починаючи з дати вище. Минулі витрати буде додано після збереження.';

  @override
  String get repeatCustom => 'Власний розклад';

  @override
  String get repeatDropReceiptTitle => 'Видалити чек?';

  @override
  String get repeatDropReceiptBody =>
      'До регулярної витрати не можна додати чек. Натомість можна додавати чек до кожної створеної нею витрати.';

  @override
  String get repeatDropReceiptAction => 'Повторювати';

  @override
  String get recurringTitle => 'Регулярні витрати';

  @override
  String get recurringHelp => 'Витрати, які автоматично додаються за розкладом';

  @override
  String get recurringEmptyTitle => 'Регулярних витрат немає';

  @override
  String get recurringEmptyBody =>
      'Оренду, підписки та інші регулярні витрати можна автоматично додавати у визначені дати.';

  @override
  String get recurringAdd => 'Додати регулярну витрату';

  @override
  String get recurringEdit => 'Редагувати регулярну витрату';

  @override
  String recurringNext(String date) {
    return 'Наступна: $date';
  }

  @override
  String get recurringPaused => 'Призупинено';

  @override
  String get recurringEnded => 'Завершено';

  @override
  String get recurringPause => 'Призупинити';

  @override
  String get recurringResume => 'Відновити';

  @override
  String get recurringActive => 'Повторювати';

  @override
  String get recurringDelete => 'Видалити';

  @override
  String get recurringDeleteTitle => 'Зупинити повторення?';

  @override
  String recurringDeleteBody(String title) {
    return 'Витрату «$title» більше не буде додано. Раніше додані витрати залишаться.';
  }

  @override
  String get recurringDeleted => 'Регулярну витрату видалено';

  @override
  String get recurringFromSchedule => 'Додано автоматично за розкладом';

  @override
  String get recurringOpen => 'Змінити розклад';

  @override
  String get recurringMissing => 'Регулярну витрату видалено або вона більше недоступна.';

  @override
  String get errorTooManyDue => 'Дата початку надто давня: за раз буде додано понад 100 витрат.';

  @override
  String get errorInvalidEnd => 'Кінцева дата не може бути раніше дати початку.';

  @override
  String get errorInvalidRepeat => 'Повторюйте від 1 до 999 днів, тижнів, місяців або років.';

  @override
  String get errorRecurringConflict =>
      'Поки ви редагували регулярну витрату, хтось інший її змінив. Перезавантажте сторінку, щоб побачити зміни.';

  @override
  String activityRecurringCreated(String who, String title) {
    return 'Для витрати «$title» налаштовано повторення · $who';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return 'Розклад витрати «$title» змінено · $who';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return 'Повторення витрати «$title» призупинено · $who';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return 'Регулярну витрату «$title» призупинено, бо хтось із її учасників вийшов із групи';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return 'Регулярну витрату «$title» призупинено, бо її не вдалося додати';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return 'Повторення витрати «$title» відновлено · $who';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return 'Повторення витрати «$title» зупинено · $who';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return 'Витрату «$title» ($amount) додано автоматично';
  }

  @override
  String get expenseRecurring => 'Додано автоматично за розкладом';

  @override
  String get adminPlans => 'Тарифи';

  @override
  String get adminPayments => 'Платежі';

  @override
  String get adminSectionBilling => 'Тарифи й платежі';

  @override
  String get adminSectionBillingBody =>
      'Тарифи підвищують ліміти на те, що зберігає цей сервер. Поділ витрат і розрахунки залишаються безкоштовними.';

  @override
  String get adminBillingOn => 'Тарифи й ліміти';

  @override
  String get adminBillingOnHelp => 'Якщо вимкнено, сервер нічого не обмежує й не показує тарифів.';

  @override
  String get adminBillingNeedsAccounts =>
      'Для тарифів потрібні облікові записи: спочатку ввімкніть режим доступу з обліковими записами.';

  @override
  String get adminKofiUrl => 'Сторінка Ko-fi';

  @override
  String get adminKofiUrlHelp =>
      'Тут виконується оплата. Посилання є лише у версіях, де дозволено зовнішні платежі.';

  @override
  String adminKofiWebhook(String url) {
    return 'URL вебхука для Ko-fi: $url';
  }

  @override
  String get adminKofiToken => 'Токен перевірки Ko-fi';

  @override
  String get adminKofiTokenHelp => 'Указано на сторінці вебхука Ko-fi. Без нього сервер ігнорує Ko-fi.';

  @override
  String adminUserPlanUntil(String plan, String date) {
    return '$plan до $date';
  }

  @override
  String get adminPlansHelp =>
      'Новий ліміт діє на те, що додадуть далі. Уже додане залишається. Залиште порожнім, щоб не обмежувати.';

  @override
  String get adminPlanAdd => 'Додати тариф';

  @override
  String adminPlanDefaultName(String name) {
    return '$name (типовий)';
  }

  @override
  String adminPlanLimit(String label, String value) {
    return '$label: $value';
  }

  @override
  String adminPlanDays(int count) {
    return 'Днів: $count';
  }

  @override
  String get adminProductsSection => 'Продукти';

  @override
  String get adminProductsHelp =>
      'Платіж належить до продукту з назвою його рівня, а якщо такого немає — до продукту без назви рівня, суму якого досягнуто.';

  @override
  String get adminProductAdd => 'Додати продукт';

  @override
  String get adminProductEdit => 'Змінити продукт';

  @override
  String adminProductAnyPayment(String amount) {
    return 'Будь-який платіж від $amount';
  }

  @override
  String get adminProductName => 'Назва рівня';

  @override
  String get adminProductNameHelp =>
      'Як на Ko-fi. Залиште порожнім, щоб зіставляти разові й щомісячні платежі за сумою.';

  @override
  String get adminProductPlan => 'Тариф';

  @override
  String get adminProductDays => 'Днів';

  @override
  String get adminProductDaysHelp => 'На скільки вистачає одного платежу. Новий платіж додається до залишку.';

  @override
  String get adminProductMinAmount => 'Мінімальна сума';

  @override
  String get adminProductCurrency => 'Код валюти';

  @override
  String get adminPlanId => 'ID';

  @override
  String get adminPlanIdHelp => 'Малі латинські літери, цифри й дефіси. Змінити потім не можна.';

  @override
  String get adminPlanName => 'Назва';

  @override
  String get adminPlanRank => 'Ранг';

  @override
  String get adminPlanRankHelp => 'Обліковий запис із кількома тарифами отримує тариф із найвищим рангом.';

  @override
  String get adminPlanDefault => 'Типовий тариф';

  @override
  String get adminPlanDefaultHelp => 'Для всіх облікових записів без іншого тарифу.';

  @override
  String adminPlanRemoveTitle(String name) {
    return 'Вилучити $name?';
  }

  @override
  String adminPlanRemoveBody(String products) {
    return 'Його продукти буде вилучено разом із ним, і їх більше не можна буде купити: $products';
  }

  @override
  String get adminEntitlementGranted => 'Надано адміністратором';

  @override
  String get adminEntitlementRevoked => 'Відкликано';

  @override
  String get adminEntitlementForever => 'Без дати завершення';

  @override
  String adminEntitlementUntil(String date) {
    return 'До $date';
  }

  @override
  String adminEntitlementEnded(String date) {
    return 'Завершено $date';
  }

  @override
  String get adminEntitlementsEmpty => 'Цей обліковий запис ще не має тарифів.';

  @override
  String get adminEntitlementRevoke => 'Відкликати';

  @override
  String adminEntitlementRevokeTitle(String plan) {
    return 'Відкликати $plan?';
  }

  @override
  String adminEntitlementRevokeBody(String user) {
    return '$user одразу втратить цей тариф. Цю дію не можна скасувати.';
  }

  @override
  String get adminEntitlementNote => 'Нотатка';

  @override
  String get adminEntitlementGrant => 'Надати тариф';

  @override
  String get adminPaymentApplied => 'Застосовано';

  @override
  String get adminPaymentUnclaimed => 'Не отримано';

  @override
  String get adminPaymentUnmatched => 'Не зіставлено';

  @override
  String get adminPaymentsAll => 'Усі';

  @override
  String adminPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count платежу',
      many: '$count платежів',
      few: '$count платежі',
      two: '$count платежі',
      one: '$count платіж',
    );
    return '$_temp0';
  }

  @override
  String get adminPaymentsEmpty => 'Платежів немає.';

  @override
  String get adminPaymentAssigned => 'Тариф надано обліковому запису.';

  @override
  String get adminPaymentAssign => 'Надати обліковому запису';

  @override
  String get adminPaymentPickUser => 'Виберіть обліковий запис.';

  @override
  String get errorBillingOff => 'На цьому сервері немає тарифів.';

  @override
  String get errorAlreadySponsored => 'Цю групу вже покриває тариф іншого учасника.';

  @override
  String get errorPlanInUse => 'Цей тариф ще використовують облікові записи або продукти.';

  @override
  String get errorPaymentApplied => 'Цей платіж уже застосовано.';

  @override
  String get errorPaymentNotFound =>
      'Платежу з таким ID поки немає. Якщо ви щойно оплатили, спробуйте знову за хвилину.';

  @override
  String get errorPaymentNoPlan =>
      'Цей платіж не відповідає жодному тарифу. Попросіть адміністратора сервера застосувати його.';

  @override
  String get errorInvalidPlan => 'Перевірте налаштування тарифу: щось указано неправильно.';

  @override
  String errorLimitReceipts(int max) {
    return 'Група досягла ліміту фото чеків: $max.';
  }

  @override
  String errorLimitRecurring(int max) {
    return 'Група досягла ліміту регулярних витрат: $max.';
  }

  @override
  String errorLimitJoinedGroups(int max) {
    return 'Ви досягли ліміту груп: $max.';
  }

  @override
  String errorLimitMembers(int max) {
    return 'У цій групі досягнуто ліміту людей: $max.';
  }

  @override
  String errorLimitSponsored(int max) {
    return 'Тарифом можна поділитися максимум із такою кількістю груп: $max.';
  }

  @override
  String get errorLimitOther => 'Ви досягли ліміту цього сервера.';

  @override
  String get planTitle => 'Тариф';

  @override
  String get planUnlimited => 'Без ліміту';

  @override
  String planUntil(String date) {
    return 'До $date';
  }

  @override
  String get planSettingsHelp => 'Що цей сервер зберігає для вас';

  @override
  String get planIntro =>
      'Поділ і розрахунки завжди безкоштовні. Тариф змінює лише те, скільки цей сервер зберігає для вас.';

  @override
  String planUsage(int used, int limit) {
    return '$used з $limit';
  }

  @override
  String planUsed(int used) {
    return 'Використано: $used';
  }

  @override
  String get planLimits => 'Ліміти';

  @override
  String get planLimitReceipts => 'Фото чеків на групу';

  @override
  String get planLimitRecurring => 'Регулярні витрати на групу';

  @override
  String get planLimitJoinedGroups => 'Групи, у яких ви є';

  @override
  String get planLimitMembers => 'Людей у групі';

  @override
  String get planLimitSponsored => 'Групи з вашим тарифом';

  @override
  String get planGet => 'Отримати тариф';

  @override
  String get planKofi => 'Ko-fi';

  @override
  String get planKofiHelp =>
      'Вставте платіжний код у повідомлення на Ko-fi, щоб платіж потрапив на ваш обліковий запис.';

  @override
  String get planPaymentCodeHelp => 'Ваш платіжний код. Торкніться, щоб скопіювати.';

  @override
  String get planPaymentCodeCopied => 'Платіжний код скопійовано';

  @override
  String get planPaymentClaim => 'Забули код?';

  @override
  String get planPaymentClaimHelp => 'Додайте платіж за ID транзакції Ko-fi.';

  @override
  String get planPaymentClaimField => 'ID транзакції або посилання на платіж';

  @override
  String get planPaymentClaimAction => 'Додати платіж';

  @override
  String get planPaymentClaimed => 'Платіж додано';

  @override
  String groupPlanUsage(String members, String receipts, String recurring) {
    return 'Люди: $members · Фото чеків: $receipts · Регулярні: $recurring';
  }

  @override
  String get groupSponsor => 'Поділитися тарифом із цією групою';

  @override
  String get groupUnsponsor => 'Більше не ділитися тарифом';

  @override
  String groupSponsoredBy(String name) {
    return 'Використовує тариф учасника $name';
  }

  @override
  String get accountDeletePlayNote =>
      'Підписка Google Play не закінчується разом з обліковим записом. Спершу скасуйте її в Google Play.';

  @override
  String get planPlayManage => 'Керувати підпискою';

  @override
  String get planPlayManageHelp => 'Змінити або скасувати в Google Play';

  @override
  String planPlayPrice(int months, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'кожні $months місяців',
      few: 'кожні $months місяці',
      one: 'на місяць',
    );
    return '$price $_temp0';
  }

  @override
  String get planPlayFailed => 'Google Play не вдалося завершити покупку.';

  @override
  String get planPlayPending => 'Платіж ще обробляється. Тариф почне діяти після його завершення.';

  @override
  String get planPlayOnHold =>
      'Останній платіж не вдався. Оновіть спосіб оплати в Google Play, щоб зберегти цей тариф.';

  @override
  String get planPlayHeldElsewhere =>
      'Цей обліковий запис Google Play уже має підписку, яка може належати іншому обліковому запису Balnana.';

  @override
  String get planPlayUnavailable => 'Не вдалося під\'єднатися до Google Play. Спробуйте пізніше.';

  @override
  String get errorInvalidPurchase => 'Google Play не розпізнає цю покупку.';

  @override
  String get errorPlayOtherAccount =>
      'Ця підписка належить іншому обліковому запису. Увійдіть у нього або скасуйте її в Google Play.';

  @override
  String get errorPlayUnavailable => 'Не вдалося зв\'язатися з Google Play. Спробуйте трохи згодом.';

  @override
  String get adminPlayPackage => 'Назва пакета Google Play';

  @override
  String get adminPlayPackageHelp =>
      'ID застосунку в Google Play. Разом зі службовим обліковим записом нижче вмикає підписки Google Play.';

  @override
  String get adminPlayServiceAccount => 'Службовий обліковий запис Google Play';

  @override
  String get adminPlayServiceAccountHelp =>
      'JSON-ключ службового облікового запису, який може переглядати замовлення й підписки та керувати ними в Play Console.';

  @override
  String get adminPlayPushAccount => 'Push-обліковий запис Pub/Sub';

  @override
  String get adminPlayPushAccountHelp =>
      'Адреса службового облікового запису, яким Pub/Sub підписує доставки. Без неї поновлення надходять, лише коли хтось відкриває сторінку тарифу.';

  @override
  String adminPlayWebhook(String url) {
    return 'Push-адреса Pub/Sub, вона ж аудиторія: $url';
  }

  @override
  String get adminProductProvider => 'Спосіб оплати';

  @override
  String get adminProductPlayId => 'ID продукту';

  @override
  String get adminProductPlayIdHelp =>
      'Як указано в Play Console. Google Play сам повідомляє, коли закінчується кожен платіж, тому дні задавати не потрібно.';

  @override
  String get adminProductRemoveBody =>
      'Платежі за цей продукт більше не зараховуватимуться на облікові записи. Наявні тарифи діятимуть до завершення.';
}
