// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get languageEndonym => 'Русский';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get offlineBar =>
      'Нет подключения. Показаны сохранённые на устройстве данные; изменения сохранятся после восстановления связи.';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonClear => 'Очистить';

  @override
  String get iconChoose => 'Выберите значок';

  @override
  String get iconNone => 'Без значка';

  @override
  String get iconSearchHint => 'Найдите или введите эмодзи';

  @override
  String get iconUseTyped => 'Использовать это эмодзи';

  @override
  String get iconNoMatch => 'Значки не найдены. Введите эмодзи, чтобы использовать его.';

  @override
  String get iconSectionTravel => 'Путешествия и места';

  @override
  String get iconSectionFood => 'Еда и напитки';

  @override
  String get iconSectionActivities => 'Занятия';

  @override
  String get iconSectionHome => 'Дом и счета';

  @override
  String get iconSectionPeople => 'Люди';

  @override
  String get iconSectionNature => 'Животные и природа';

  @override
  String get iconSectionObjects => 'Деньги и вещи';

  @override
  String get iconSectionSymbols => 'Символы';

  @override
  String get commonRemove => 'Удалить';

  @override
  String get commonUndo => 'Отменить';

  @override
  String get someone => 'Кто-то';

  @override
  String get errorTooLarge => 'Не удалось отправить на сервер: слишком большой файл.';

  @override
  String get errorBusy => 'Сервер занят. Попробуйте ещё раз чуть позже.';

  @override
  String get errorTimeout =>
      'Не удалось отправить данные вовремя. Проверьте подключение и попробуйте ещё раз.';

  @override
  String get errorBadOrigin =>
      'Сервер не принимает вход с этого адреса. Администратору сервера нужно проверить его публичный адрес.';

  @override
  String get errorInvalidCategory => 'Эта категория уже удалена. Выберите другую.';

  @override
  String get errorBuiltinCategory => 'Встроенные категории можно только скрыть.';

  @override
  String get errorUnknownMember =>
      'Кого-то из участников больше нет в группе. Обновите страницу и попробуйте ещё раз.';

  @override
  String get errorNoPayers => 'Выберите, кто заплатил.';

  @override
  String get errorPayerTotal => 'Сумма платежей всех участников должна совпадать с суммой расхода.';

  @override
  String get errorPayerTooSmall =>
      'Доля одного из плательщиков округляется до нуля в валюте группы. Проверьте суммы.';

  @override
  String get errorInvalidNote => 'Примечание слишком длинное или содержит символы, которые нельзя сохранить.';

  @override
  String get errorInvalidDate => 'Дата вне допустимого диапазона.';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get errorNetwork => 'Не удаётся подключиться к серверу. Проверьте подключение.';

  @override
  String get errorNotFound => 'Этого больше нет.';

  @override
  String get errorRequired => 'Обязательное поле';

  @override
  String get errorInvalidName => 'Введите имя длиной не более 100 символов.';

  @override
  String get errorDuplicateName => 'В этой группе уже есть участник с таким именем.';

  @override
  String get errorTooManyMembers => 'В группе уже максимально допустимое число участников.';

  @override
  String get errorTooManyCategories => 'В группе уже максимально допустимое число категорий.';

  @override
  String get errorDuplicateCategory => 'В этой группе уже есть категория с таким названием.';

  @override
  String get errorInvalidCurrency => 'Введите трёхбуквенный код валюты, например USD.';

  @override
  String get errorInvalidTitle => 'Введите название длиной не более 200 символов.';

  @override
  String get errorInvalidLocation => 'Введите название места в одну строку, не более 200 символов.';

  @override
  String get errorInvalidSymbol => 'Введите символ длиной не более 8 символов.';

  @override
  String get errorInvalidEmoji => 'Выберите один эмодзи для значка.';

  @override
  String get errorMemberHasBalance => 'Сначала рассчитайтесь с этим участником, а потом удаляйте его.';

  @override
  String get errorVersionConflict =>
      'Пока вы редактировали расход, его изменил кто-то другой. Обновите страницу, чтобы увидеть изменения.';

  @override
  String get errorSignInRequired => 'Войдите, чтобы выполнить это действие.';

  @override
  String get errorRateLimited => 'Слишком много запросов. Подождите минуту и попробуйте ещё раз.';

  @override
  String get errorNotAMember => 'вы ещё не вступили в эту группу.';

  @override
  String get errorNotAllowed => 'Это может сделать только этот участник или владелец группы.';

  @override
  String get errorLinkGroupsOff => 'На этом сервере нельзя открывать группы только по ссылке.';

  @override
  String get errorMemberClaimed => 'Кто-то уже вступил в группу от имени этого участника.';

  @override
  String get errorMemberLeft => 'Кто-то из участников покинул группу.';

  @override
  String get errorInvalidEmail => 'Введите адрес электронной почты.';

  @override
  String get errorInvalidPassword => 'Пароль должен содержать от 8 до 200 символов.';

  @override
  String get errorEmailTaken => 'Аккаунт с таким адресом уже есть. Войдите в него.';

  @override
  String get errorSignupClosed => 'На этом сервере нельзя создавать новые аккаунты.';

  @override
  String get errorInvalidCredentials => 'Неверный адрес электронной почты или пароль.';

  @override
  String get errorWrongPassword => 'Неверный текущий пароль.';

  @override
  String get errorAccountsOff => 'На этом сервере не используются аккаунты.';

  @override
  String get errorInvalidAmount => 'Введите сумму больше нуля.';

  @override
  String get errorTooManyDecimals => 'Слишком много знаков после запятой для этой валюты.';

  @override
  String get errorAmountTooLarge => 'Сумма слишком большая.';

  @override
  String get errorNoShares => 'Выберите хотя бы одного участника, чтобы разделить расход.';

  @override
  String get errorInvalidShare => 'Доля должна быть числом.';

  @override
  String get errorExactTotal => 'Сумма долей должна совпадать с итоговой суммой.';

  @override
  String get errorPayersTotal => 'Сумма платежей всех участников должна совпадать с итоговой суммой.';

  @override
  String get categoryFood => 'Еда и напитки';

  @override
  String get categoryGroceries => 'Продукты';

  @override
  String get categoryTransport => 'Транспорт';

  @override
  String get categoryTravel => 'Путешествия';

  @override
  String get categoryLodging => 'Жильё';

  @override
  String get categoryRent => 'Аренда';

  @override
  String get categoryUtilities => 'Коммунальные услуги';

  @override
  String get categoryEntertainment => 'Развлечения';

  @override
  String get categoryShopping => 'Покупки';

  @override
  String get categoryHealth => 'Здоровье';

  @override
  String get categoryGifts => 'Подарки';

  @override
  String get categoryOther => 'Другое';

  @override
  String get groupNew => 'Новая группа';

  @override
  String get groupSwitch => 'Сменить группу';

  @override
  String get groupReorder => 'Перетащите, чтобы изменить порядок';

  @override
  String get groupCreate => 'Создать группу';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участника',
      many: '$count участников',
      few: '$count участника',
      two: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return 'вам должны $amount';
  }

  @override
  String pillOwe(String amount) {
    return 'вы должны $amount';
  }

  @override
  String get pillSettled => 'вы рассчитались';

  @override
  String get groupMissingTitle => 'Группа не найдена';

  @override
  String get groupMissingBody =>
      'Эта группа удалена или её ссылка сброшена. Попросите новую ссылку у кого-нибудь из участников.';

  @override
  String get groupLockedTitle => 'Войдите, чтобы открыть эту группу';

  @override
  String get groupLockedBody =>
      'Группа доступна только участникам, у которых есть аккаунт. Войдите в аккаунт, связанный с группой.';

  @override
  String get groupForget => 'Убрать с этого устройства';

  @override
  String get groupLinkOtherServer =>
      'Эта ссылка ведёт на другой сервер. Подключитесь к нему, чтобы открыть группу.';

  @override
  String get openLinkTitle => 'Открыть ссылку на группу';

  @override
  String get openLinkBody => 'Вставьте ссылку, которой с вами поделились, чтобы вступить в группу.';

  @override
  String get openLinkLabel => 'Ссылка на группу';

  @override
  String get openLinkAction => 'Открыть';

  @override
  String get openLinkInvalid => 'Похоже, это не ссылка на группу Balnana.';

  @override
  String get groupName => 'Название группы';

  @override
  String get groupNameHint => 'Поездка в Лиссабон';

  @override
  String get groupCurrency => 'Валюта';

  @override
  String get groupCurrencyHelp => 'Все расходы в группе будут в этой валюте. Позже её нельзя будет изменить.';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name. Все расходы в группе будут в этой валюте. Позже её нельзя будет изменить.';
  }

  @override
  String get currencyChoose => 'Выберите валюту';

  @override
  String get currencySearchHint => 'Поиск по коду или названию';

  @override
  String get currencySuggested => 'Предложенные';

  @override
  String get currencyAll => 'Все валюты';

  @override
  String currencyUseTyped(String code) {
    return 'Использовать $code';
  }

  @override
  String get currencyNoMatch => 'Валюта не найдена. Введите её трёхбуквенный код, чтобы использовать.';

  @override
  String get groupSymbol => 'Символ';

  @override
  String get groupSymbolChoose => 'Выберите символ';

  @override
  String groupSymbolExample(String example) {
    return 'Суммы будут выглядеть так: $example';
  }

  @override
  String get groupColor => 'Цвет';

  @override
  String colorSwatch(int number, int count) {
    return 'Цвет $number из $count';
  }

  @override
  String get groupPeople => 'Участники';

  @override
  String get groupYourName => 'ваше имя';

  @override
  String groupPersonName(int number) {
    return 'Участник $number';
  }

  @override
  String get groupAddPerson => 'Добавить участника';

  @override
  String get groupPeopleHelp => 'Участников можно добавить позже, или они смогут вступить по ссылке.';

  @override
  String get identityTitle => 'Кто вы?';

  @override
  String get identityBody =>
      'Выберите своё имя, чтобы Balnana показывала, сколько вы должны и сколько должны вам. Оно сохранится только на этом устройстве.';

  @override
  String get identityNew => 'Я новый участник';

  @override
  String get identityNewTitle => 'Вступить в группу';

  @override
  String get identityJoin => 'Вступить';

  @override
  String get identityChange => 'Кто вы';

  @override
  String get identityNone => 'Пока не выбрано';

  @override
  String get memberName => 'Имя';

  @override
  String memberYou(String name) {
    return '$name (вы)';
  }

  @override
  String get memberAdd => 'Добавить участника';

  @override
  String get memberAddTitle => 'Добавить участника';

  @override
  String get memberRename => 'Переименовать';

  @override
  String get memberRenameTitle => 'Переименовать';

  @override
  String memberRemoveTitle(String name) {
    return 'Удалить $name?';
  }

  @override
  String get memberRemoveBody =>
      'Участник останется в прошлых расходах, но его нельзя будет добавлять в новые.';

  @override
  String get groupLinkCopied => 'Ссылка скопирована. Открыть эту группу сможет любой, у кого она есть.';

  @override
  String get groupShare => 'Поделиться ссылкой';

  @override
  String get groupSettings => 'Настройки группы';

  @override
  String get groupEdit => 'Изменить группу';

  @override
  String get groupSharing => 'Доступ';

  @override
  String get groupCopyLink => 'Скопировать ссылку';

  @override
  String get groupQrCode => 'Показать QR-код';

  @override
  String get groupQrCodeHelp => 'Участники смогут отсканировать ссылку камерой телефона.';

  @override
  String groupQrLabel(String group) {
    return 'QR-код ссылки на группу «$group»';
  }

  @override
  String get groupCopyLinkHelp =>
      'Любой, у кого есть ссылка, может просматривать и редактировать эту группу.';

  @override
  String get groupCopyLinkHelpAccounts =>
      'Участники со ссылкой могут попросить доступ после входа в аккаунт.';

  @override
  String get linkAccessTitle => 'Доступна всем по ссылке';

  @override
  String get linkAccessHelp => 'Разрешить просматривать и редактировать без аккаунта';

  @override
  String get resetLinkTitle => 'Сбросить ссылку';

  @override
  String get resetLinkHelp => 'Создать новую ссылку, а старую отключить';

  @override
  String get resetLinkBody =>
      'Текущая ссылка перестанет работать для всех. Отправьте новую ссылку тем, кому нужен доступ.';

  @override
  String get resetLinkAction => 'Сбросить';

  @override
  String get resetLinkDone => 'Ссылка сброшена. Поделитесь новой.';

  @override
  String get groupThisDevice => 'Это устройство';

  @override
  String get groupData => 'Данные';

  @override
  String get categoriesTitle => 'Категории';

  @override
  String get categoriesHelp => 'Добавьте свои или скройте те, которыми не пользуетесь';

  @override
  String get categoriesOwn => 'Категории группы';

  @override
  String get categoriesOwnEmpty => 'Пока нет пользовательских категорий.';

  @override
  String get categoriesBuiltIn => 'Встроенные';

  @override
  String get categoriesBuiltInHelp =>
      'Скрытые категории не предлагаются для новых расходов. В существующих расходах они сохраняются.';

  @override
  String get categoryAdd => 'Добавить категорию';

  @override
  String get categoryEdit => 'Изменить категорию';

  @override
  String get categoryName => 'Название';

  @override
  String get categoryDelete => 'Удалить категорию';

  @override
  String categoryDeleteTitle(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get categoryDeleteBody => 'У этих расходов категория будет удалена.';

  @override
  String get categoryDeleteAction => 'Удалить';

  @override
  String get exportCsv => 'Экспортировать в CSV';

  @override
  String get exportCsvHelp => 'Все расходы и платежи для таблицы';

  @override
  String get exportCsvDone => 'Экспортировано';

  @override
  String get forgetTitle => 'Убрать с этого устройства';

  @override
  String get forgetHelp => 'Для остальных участников группа останется на сервере';

  @override
  String get forgetBody => 'вы сможете снова открыть её по ссылке.';

  @override
  String get groupYou => 'вы';

  @override
  String get leaveTitle => 'Покинуть группу';

  @override
  String get leaveHelp => 'Расходы сохранятся; вы сможете вступить снова по ссылке';

  @override
  String get leaveBody => 'Группа исчезнет из вашего списка, но расходы и баланс останутся в ней.';

  @override
  String get leaveAction => 'Покинуть';

  @override
  String get tabExpenses => 'Расходы';

  @override
  String get heroWhoTitle => 'Кто вы в этой группе?';

  @override
  String get heroWhoBody => 'Выберите своё имя, чтобы узнать, кому вы должны и кто должен вам.';

  @override
  String get heroWhoAction => 'Выбрать';

  @override
  String get heroJoinTitle => 'вы просматриваете группу';

  @override
  String get heroJoinBody => 'Вступите в группу, чтобы добавлять расходы и видеть свои долги.';

  @override
  String get joinAction => 'Вступить';

  @override
  String get heroOwed => 'вам должны';

  @override
  String get heroOwe => 'вы должны';

  @override
  String get heroSettled => 'вы рассчитались';

  @override
  String heroYouAre(String name) {
    return 'вы — $name';
  }

  @override
  String get expenseAdd => 'Добавить расход';

  @override
  String get expensesEmptyTitle => 'Расходов пока нет';

  @override
  String get expensesEmptyBody => 'Добавьте первый расход, и Balnana рассчитает, кто кому должен.';

  @override
  String get expensesSearchHint => 'Поиск по названиям, примечаниям и местам';

  @override
  String get searchClear => 'Очистить поиск';

  @override
  String get expensesNoMatchTitle => 'Ничего не найдено';

  @override
  String get expensesNoMatchBody => 'Попробуйте изменить запрос или убрать часть фильтров.';

  @override
  String get filterAnyone => 'Любой участник';

  @override
  String get filterAnyCategory => 'Любая категория';

  @override
  String get filterPayments => 'Платежи';

  @override
  String get filterClear => 'Сбросить фильтры';

  @override
  String get periodAll => 'За всё время';

  @override
  String get periodThisMonth => 'В этом месяце';

  @override
  String get periodLastMonth => 'В прошлом месяце';

  @override
  String get periodThisYear => 'В этом году';

  @override
  String get periodPickDays => 'Выбрать даты…';

  @override
  String get statsTitle => 'Расходы';

  @override
  String get statsTotal => 'Всего потрачено';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count расхода',
      many: '$count расходов',
      few: '$count расхода',
      two: '$count расхода',
      one: '$count расход',
    );
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'По категориям';

  @override
  String get statsByMember => 'Оплачено и доля каждого';

  @override
  String get statsPaid => 'Оплачено';

  @override
  String get statsShare => 'Доля';

  @override
  String get statsByMonth => 'По месяцам';

  @override
  String get statsNoCategory => 'Без категории';

  @override
  String get statsEmptyTitle => 'Пока ничего не потрачено';

  @override
  String get statsEmptyBody => 'За этот период расходов нет.';

  @override
  String get statsShowExpenses => 'Показать эти расходы';

  @override
  String get dateToday => 'Сегодня';

  @override
  String get dateYesterday => 'Вчера';

  @override
  String paymentTitle(String from, String to) {
    return '$from отправил(а) платёж участнику $to';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name заплатил(а) $amount';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return 'Оплачено участниками ($count): $amount';
  }

  @override
  String expensePaidByName(String name) {
    return '$name заплатил(а)';
  }

  @override
  String expensePaidByManyNames(int count) {
    return 'Плательщики ($count)';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name получил(а) $amount';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$name получил(а)';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return 'Получатели ($count)';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return 'Получено участниками ($count): $amount';
  }

  @override
  String get transactionRefund => 'Возврат';

  @override
  String get transactionIncome => 'Доход';

  @override
  String get paymentDelete => 'Удалить платёж';

  @override
  String get paymentDeleted => 'Платёж удалён';

  @override
  String expenseDeleted(String title) {
    return 'Удалено: «$title»';
  }

  @override
  String get expenseNew => 'Новый расход';

  @override
  String get expenseEdit => 'Изменить расход';

  @override
  String get expenseDelete => 'Удалить';

  @override
  String get expenseAmount => 'Сумма';

  @override
  String get expenseTitle => 'На что потратили?';

  @override
  String get expenseTitleHint => 'Ужин, билеты, такси…';

  @override
  String get expenseAmountFromPayers => 'Общая сумма платежей участников';

  @override
  String expensePaidIn(String currency) {
    return 'Оплачено в валюте $currency';
  }

  @override
  String expenseRate(String from, String to) {
    return '1 $from в $to';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return 'Итого в валюте $currency';
  }

  @override
  String expenseForeignHelp(String currency) {
    return 'Баланс считается в валюте $currency. Введите курс или сумму после конвертации, например из выписки по карте.';
  }

  @override
  String get expenseNote => 'Примечание';

  @override
  String get expenseNoteHint => 'Необязательно';

  @override
  String get expenseLocation => 'Место';

  @override
  String get expenseLocationHint => 'Где это было? (необязательно)';

  @override
  String get locationPickOnMap => 'Выбрать на карте';

  @override
  String get locationUseCurrent => 'Определить моё местоположение';

  @override
  String get locationFinding => 'Определяем местоположение…';

  @override
  String get locationChange => 'Изменить на карте';

  @override
  String get locationRemovePin => 'Убрать метку';

  @override
  String get locationOpenInMaps => 'Открыть на карте';

  @override
  String get locationPickTitle => 'Выберите место';

  @override
  String get locationPickHint => 'Нажмите на карту, чтобы поставить метку';

  @override
  String get locationPickDone => 'Готово';

  @override
  String get locationDenied =>
      'Разрешите Balnana доступ к местоположению в настройках устройства или браузера.';

  @override
  String get locationOff => 'На этом устройстве отключена геолокация.';

  @override
  String get locationUnavailable =>
      'Не удалось определить ваше местоположение. Попробуйте ещё раз или поставьте метку на карте.';

  @override
  String get expenseReceipt => 'Чек';

  @override
  String get expenseHasReceipt => 'Есть фото чека';

  @override
  String get expenseHasLocation => 'Есть место';

  @override
  String get receiptTakePhoto => 'Сфотографировать';

  @override
  String get receiptChoose => 'Выбрать изображение';

  @override
  String get receiptRemove => 'Удалить';

  @override
  String get receiptView => 'Фото чека';

  @override
  String receiptNotSaved(String reason) {
    return 'Расход сохранён, но фото чека сохранить не удалось. $reason';
  }

  @override
  String get expensePaidByLabel => 'Оплатил(а)';

  @override
  String get expenseReceivedForLabel => 'Получено за';

  @override
  String get expenseReceivedByLabel => 'Получил(а)';

  @override
  String get expenseMultiplePayers => 'Несколько участников';

  @override
  String get expenseSplit => 'Разделить';

  @override
  String get splitEqual => 'Поровну';

  @override
  String get splitExact => 'По суммам';

  @override
  String get splitShares => 'По долям';

  @override
  String splitLeft(String amount) {
    return 'Осталось распределить: $amount';
  }

  @override
  String splitOver(String amount) {
    return 'Превышение: $amount';
  }

  @override
  String get conflictTitle => 'Изменено кем-то ещё';

  @override
  String get conflictReload => 'Обновить';

  @override
  String get expenseChangedElsewhere =>
      'Кто-то другой изменил этот расход. Обновите страницу, чтобы увидеть его версию и отменить свои изменения.';

  @override
  String get suggestedPayments => 'Рекомендуемые платежи';

  @override
  String get allSettled => 'Все рассчитались.';

  @override
  String transferYouPay(String name) {
    return 'вы платите участнику $name';
  }

  @override
  String transferPaysYou(String name) {
    return 'Участник $name платит вам';
  }

  @override
  String transferPays(String from, String to) {
    return '$from платит $to';
  }

  @override
  String get recordPayment => 'Записать';

  @override
  String get recordPaymentTitle => 'Записать платёж';

  @override
  String get recordPaymentHelp => 'Записывайте только деньги, которые уже передали вне Balnana.';

  @override
  String get paymentRecorded => 'Платёж записан';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who создал(а) группу «$group»';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who изменил(а) данные группы';
  }

  @override
  String activityLinkReset(String who) {
    return '$who сбросил(а) ссылку на группу';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who добавил(а) участника $name';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who переименовал(а) участника: $oldName → $name';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who удалил(а) участника $name';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who добавил(а) категорию «$name»';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who изменил(а) категории';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who удалил(а) категорию «$name»';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name вступил(а) в группу';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who добавил(а) расход «$title» ($amount)';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who изменил(а) расход «$title» ($amount)';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who удалил(а) расход «$title»';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who восстановил(а) расход «$title»';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who записал(а) платёж от $from участнику $to на сумму $amount';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who удалил(а) платёж на сумму $amount';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who восстановил(а) платёж на сумму $amount';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      two: '$count записи',
      one: '$count запись',
    );
    return '$who импортировал(а) из $source: $_temp0';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who добавил(а) фото чека к расходу «$title»';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who удалил(а) фото чека из расхода «$title»';
  }

  @override
  String activityOther(String who) {
    return '$who изменил(а) данные';
  }

  @override
  String get navGroups => 'Группы';

  @override
  String get navActivity => 'Активность';

  @override
  String get navSettings => 'Настройки';

  @override
  String get groupsEmptyTitle => 'Пока нет групп';

  @override
  String get groupsEmptyBody => 'Здесь появятся созданные вами группы и группы, открытые по ссылке.';

  @override
  String get groupsNoServerTitle => 'Подключитесь к серверу';

  @override
  String get groupsNoServerBody =>
      'Balnana хранит ваши группы на выбранном вами сервере, например на собственном.';

  @override
  String get groupsNoServerAction => 'Выбрать сервер';

  @override
  String get groupsUnreachableTitle => 'Не удаётся подключиться к серверу';

  @override
  String get groupsUnreachableBody => 'Проверьте подключение или адрес сервера в настройках.';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count группы не загрузились, поэтому их изменения не показаны.',
      many: '$count групп не загрузились, поэтому их изменения не показаны.',
      few: '$count группы не загрузились, поэтому их изменения не показаны.',
      two: '$count группы не загрузились, поэтому их изменения не показаны.',
      one: '$count группа не загрузилась, поэтому её изменения не показаны.',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => 'Пока здесь ничего нет';

  @override
  String get activityEmptyBody => 'Здесь будут появляться новые расходы и платежи в ваших группах.';

  @override
  String get notFoundTitle => 'Страница не найдена';

  @override
  String get notFoundBody => 'Этот адрес никуда не ведёт в Balnana.';

  @override
  String get notFoundAction => 'К списку групп';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get accountRename => 'Изменить имя';

  @override
  String get passwordChange => 'Изменить пароль';

  @override
  String get passwordChanged => 'Пароль изменён. На других устройствах выполнен выход из аккаунта.';

  @override
  String get passwordSet => 'Задать пароль';

  @override
  String get passwordSetHelp => 'Входите по электронной почте или имени пользователя и паролю';

  @override
  String get passwordSetDone => 'Пароль задан. На других устройствах выполнен выход из аккаунта.';

  @override
  String get passwordCurrent => 'Текущий пароль';

  @override
  String get passwordNew => 'Новый пароль';

  @override
  String get signOut => 'Выйти';

  @override
  String get accountOAuthLinked => 'Используется для входа в этот аккаунт. Нажмите, чтобы удалить.';

  @override
  String get accountOAuthAdd => 'Добавить способ входа';

  @override
  String accountOAuthAddTitle(String name) {
    return 'Добавить $name';
  }

  @override
  String accountOAuthAdded(String name) {
    return 'Теперь можно входить через $name.';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return 'Удалить $name?';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return 'вы не сможете входить через $name, пока не добавите этот способ снова.';
  }

  @override
  String get accountOAuthRemove => 'Удалить';

  @override
  String accountOAuthRemoved(String name) {
    return 'Способ входа $name удалён.';
  }

  @override
  String get confirmEmailTitle => 'Подтвердите адрес электронной почты';

  @override
  String confirmEmailBody(String email) {
    return 'На этом сервере нужно подтвердить адрес. Откройте ссылку, отправленную на $email.';
  }

  @override
  String get confirmEmailDone => 'Я подтвердил(а)';

  @override
  String get confirmEmailResend => 'Отправить ссылку ещё раз';

  @override
  String get confirmEmailNotYet => 'Адрес пока не подтверждён. Откройте ссылку из письма.';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get settingsDynamicColor => 'Цвета обоев';

  @override
  String get settingsDynamicColorSubtitle => 'Использовать цвета устройства вместо жёлтого цвета Balnana';

  @override
  String get settingsWallpaperGroups => 'Цвета обоев в группах';

  @override
  String get settingsWallpaperGroupsSubtitle => 'Использовать в группах цвета устройства вместо собственных';

  @override
  String get settingsPureBlack => 'Чёрная тема';

  @override
  String get settingsPureBlackSubtitle => 'Более тёмная тема для OLED-экранов';

  @override
  String get settingsMyShare => 'Показывать мою долю';

  @override
  String get settingsMyShareSubtitle =>
      'В расходах показывается ваша доля долга или переплаты, а не общая сумма';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsNotificationsSubtitle =>
      'Когда кто-то добавляет, изменяет или удаляет расход, в котором вы участвуете';

  @override
  String get settingsNotificationsBlocked =>
      'Уведомления заблокированы в настройках телефона. Разрешите уведомления Balnana, чтобы получать их.';

  @override
  String get pushChannel => 'Расходы';

  @override
  String get pushChannelDescription =>
      'Когда кто-то добавляет, изменяет или удаляет расход, в котором вы участвуете';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who добавил(а) расход $title · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who изменил(а) расход $title · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who удалил(а) расход $title · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return 'Добавлен расход $title · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return 'Изменён расход $title · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return 'Удалён расход $title · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return 'Платёж от $payer участнику $payee: $amount';
  }

  @override
  String get settingsConnection => 'Подключение';

  @override
  String get settingsServer => 'Сервер';

  @override
  String get serverNotSet => 'Не задан';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get aboutVersion => 'Версия';

  @override
  String get aboutLicenses => 'Лицензии открытого ПО';

  @override
  String get aboutSource => 'Исходный код';

  @override
  String get aboutSourceCopied => 'Не удалось открыть браузер, поэтому ссылка скопирована';

  @override
  String get serverTitle => 'Сервер';

  @override
  String get serverIntro =>
      'Введите адрес сервера Balnana. Его может запустить любой; обычно по этому адресу открывается веб-приложение.';

  @override
  String get serverUrlLabel => 'Адрес сервера';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => 'Проверить подключение';

  @override
  String get serverSaveAnyway => 'Всё равно сохранить';

  @override
  String get serverReset => 'Использовать сервер по умолчанию';

  @override
  String serverDefault(String url) {
    return 'По умолчанию: $url';
  }

  @override
  String serverConnected(String version) {
    return 'Подключено к Balnana $version';
  }

  @override
  String get serverModeLink => 'Группы доступны по закрытой ссылке. Аккаунт не нужен.';

  @override
  String get serverModeAccounts => 'Участники входят в аккаунт.';

  @override
  String get serverInsecure =>
      'Соединение не зашифровано (http). Все в сети могут прочитать ваши данные. Используйте https для серверов вне домашней сети.';

  @override
  String get serverErrorInvalid => 'Введите веб-адрес, например balnana.example.com';

  @override
  String get serverErrorUnreachable =>
      'Не удалось подключиться. Проверьте адрес и убедитесь, что сервер работает.';

  @override
  String get serverErrorNotBalnana => 'Сервер ответил, но это не сервер Balnana.';

  @override
  String get serverSaved => 'Сервер сохранён';

  @override
  String get signIn => 'Войти';

  @override
  String get groupSignInTitle => 'Войдите, чтобы открыть эту группу';

  @override
  String get groupSignInBody =>
      'Эта группа доступна только её участникам. Войдите, чтобы просмотреть её или вступить.';

  @override
  String get signInTitle => 'С возвращением';

  @override
  String get signInBody => 'Войдите, чтобы увидеть свои группы.';

  @override
  String get signInNoPassword =>
      'На этом сервере используется другой способ входа. Обратитесь к администратору.';

  @override
  String get registerTitle => 'Создать аккаунт';

  @override
  String get registerBody => 'ваши группы будут доступны на всех устройствах.';

  @override
  String get registerAction => 'Создать аккаунт';

  @override
  String get registerHaveAccount => 'У меня уже есть аккаунт';

  @override
  String get signInNoAccount => 'Создать аккаунт';

  @override
  String get accountName => 'ваше имя';

  @override
  String get accountNameHelp => 'Так вас будут видеть участники групп';

  @override
  String get accountEmail => 'Электронная почта';

  @override
  String get accountPassword => 'Пароль';

  @override
  String get accountPasswordHelp => 'Не менее 8 символов';

  @override
  String get passwordShow => 'Показать пароль';

  @override
  String get passwordHide => 'Скрыть пароль';

  @override
  String get joinPickName => 'Выбрать другое имя';

  @override
  String joinTitle(String name) {
    return 'Вступить как $name';
  }

  @override
  String get joinBody => 'вы среди этих участников? Выберите себя, чтобы взять на себя их расходы.';

  @override
  String get joinBodyNew => 'Вступите, чтобы добавлять расходы и видеть свой баланс.';

  @override
  String get joinAsNew => 'Я новый участник';

  @override
  String joinAsName(String name) {
    return 'Вступить как $name';
  }

  @override
  String joinTaken(String names) {
    return 'Уже вступили: $names';
  }

  @override
  String joinTakenCount(int count) {
    return '$count участников уже вступили.';
  }

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get errorEmailOff => 'Этот сервер не отправляет электронную почту.';

  @override
  String get errorInvalidToken => 'Срок действия ссылки истёк или её уже использовали.';

  @override
  String get forgotPasswordTitle => 'Забыли пароль?';

  @override
  String get forgotPasswordBody => 'Мы отправим вам ссылку для создания нового пароля.';

  @override
  String get forgotPasswordAction => 'Отправить ссылку';

  @override
  String get forgotPasswordSent => 'Если аккаунт с таким адресом существует, ссылка уже отправлена.';

  @override
  String get resetPasswordTitle => 'Создайте новый пароль';

  @override
  String get resetPasswordBody =>
      'вы выйдете из аккаунта на всех устройствах, а затем сможете войти с новым паролем.';

  @override
  String get resetPasswordAction => 'Сохранить пароль';

  @override
  String get resetPasswordDone => 'Пароль изменён. Войдите с новым паролем.';

  @override
  String get verifyEmailTitle => 'Подтвердите адрес электронной почты';

  @override
  String get verifyEmailHelp => 'Это поможет восстановить пароль, если вы его забудете';

  @override
  String verifyEmailSent(String email) {
    return 'Откройте ссылку, отправленную на $email.';
  }

  @override
  String get verifyEmailDone => 'Адрес подтверждён';

  @override
  String get verifyEmailDoneBody => 'Спасибо! Адрес подтверждён.';

  @override
  String get verifyEmailFailed => 'Не удалось подтвердить адрес электронной почты';

  @override
  String get inviteByEmail => 'Пригласить по электронной почте';

  @override
  String get inviteByEmailHelp => 'Отправить кому-нибудь ссылку для вступления';

  @override
  String get inviteAs => 'Вступить как';

  @override
  String get inviteAsHelp => 'Приглашённый сможет взять на себя расходы этого участника.';

  @override
  String get inviteAsAnyone => 'Новый участник';

  @override
  String get inviteSend => 'Отправить приглашение';

  @override
  String inviteSent(String email) {
    return 'Приглашение отправлено на $email.';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name приглашает вас в группу «$group»';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return 'вас приглашают в группу «$group»';
  }

  @override
  String inviteBody(String email) {
    return 'Создайте аккаунт с адресом $email, чтобы вступить, или войдите в существующий.';
  }

  @override
  String get inviteBodySignedIn => 'Вступите, чтобы добавлять расходы и видеть свой баланс.';

  @override
  String get inviteAction => 'Открыть приглашение';

  @override
  String get inviteMissingTitle => 'Приглашение недействительно';

  @override
  String get inviteMissingBody =>
      'Возможно, срок действия приглашения истёк или его уже использовали. Попросите прислать новое.';

  @override
  String get joinInvitedAs => 'вы приглашены как этот участник';

  @override
  String signInWith(String provider) {
    return 'Продолжить через $provider';
  }

  @override
  String get signInOr => 'или';

  @override
  String get oauthFailedTitle => 'Не удалось войти';

  @override
  String get oauthPendingTitle => 'Для этого адреса уже есть аккаунт';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider сообщает, что адрес $email принадлежит вам, но аккаунт с ним ещё не подтверждён. Что сделать?';
  }

  @override
  String get oauthPendingLink => 'Добавить к этому аккаунту';

  @override
  String get oauthPendingLinkHelp => 'Введите пароль от аккаунта. Он продолжит работать.';

  @override
  String get oauthPendingTakeOver => 'Заменить способ входа';

  @override
  String get oauthPendingTakeOverHelp =>
      'Пароль и другие способы входа будут удалены, а все, кто вошёл в аккаунт, выйдут.';

  @override
  String get oauthPendingNew => 'Создать новый аккаунт';

  @override
  String oauthPendingNewHelp(String email) {
    return 'В другом аккаунте останутся его группы, но адрес $email будет удалён.';
  }

  @override
  String get oauthPendingPassword => 'Пароль от этого аккаунта';

  @override
  String get oauthPendingWrongPassword => 'Неверный пароль.';

  @override
  String get oauthOtherServer => 'Вход начат на другом сервере. Выберите нужный сервер и войдите ещё раз.';

  @override
  String get oauthBackToSignIn => 'Вернуться ко входу';

  @override
  String get errorOAuthFailed => 'Не удалось войти. Попробуйте ещё раз.';

  @override
  String get errorEmailHasAccount =>
      'Аккаунт с таким адресом уже есть. Войдите в него, а затем добавьте этот способ входа в настройках.';

  @override
  String get errorIdentityTaken => 'Этот способ входа уже привязан к другому аккаунту.';

  @override
  String get errorLastSignInMethod =>
      'Это ваш единственный способ входа. Сначала задайте пароль или добавьте другой способ.';

  @override
  String get errorEmailUnverified => 'Сначала подтвердите адрес электронной почты.';

  @override
  String get errorOAuthCancelled => 'Вход отменён.';

  @override
  String get importTitle => 'Импорт из Settle Up';

  @override
  String get importAction => 'Импортировать';

  @override
  String get importIntro =>
      'В Settle Up экспортируйте группу в CSV-файл, а затем выберите его здесь. Импортируются расходы, платежи и все участники группы, а баланс останется прежним.';

  @override
  String get importChooseFile => 'Выбрать CSV-файл';

  @override
  String get importChooseOther => 'Выбрать другой файл';

  @override
  String get importReading => 'Читаем файл…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(
      expenses,
      locale: localeName,
      other: '$expenses расхода',
      many: '$expenses расходов',
      few: '$expenses расхода',
      two: '$expenses расхода',
      one: '$expenses расход',
    );
    String _temp1 = intl.Intl.pluralLogic(
      payments,
      locale: localeName,
      other: '$payments платежа',
      many: '$payments платежей',
      few: '$payments платежа',
      two: '$payments платежа',
      one: '$payments платёж',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return 'С $from по $to';
  }

  @override
  String importCurrency(String currency) {
    return 'Валюта: $currency. Для записей в других валютах используются суммы, пересчитанные в Settle Up.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи с нулевой суммой не импортированы.',
      many: '$count записей с нулевой суммой не импортированы.',
      few: '$count записи с нулевой суммой не импортированы.',
      two: '$count записи с нулевой суммой не импортированы.',
      one: '$count запись с нулевой суммой не импортирована.',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => 'Кто из них вы?';

  @override
  String get importUntitled => 'Без названия';

  @override
  String get errorImportFile => 'Похоже, это не CSV-файл экспорта Settle Up.';

  @override
  String get errorImportCurrency =>
      'В файле нет записей без курса обмена, поэтому определить валюту группы не удалось.';

  @override
  String get errorImportTooBig => 'Файл слишком большой для импорта.';

  @override
  String get errorBadImage =>
      'Это изображение нельзя использовать. Выберите изображение в формате JPEG, PNG или WebP.';

  @override
  String get errorReceiptTooBig => 'Изображение слишком большое. Выберите файл размером до 10 МБ.';

  @override
  String get errorImportMe => 'Выберите, кто из участников — это вы.';

  @override
  String errorImportRow(int line, String reason) {
    return 'Не удалось импортировать строку $line файла: $reason';
  }

  @override
  String get errorImportAmount => 'не удалось прочитать сумму.';

  @override
  String get errorImportCounts => 'имена и суммы не совпадают.';

  @override
  String get errorImportDate => 'не удалось прочитать дату.';

  @override
  String get errorImportType => 'тип должен быть расходом, переводом или доходом.';

  @override
  String get errorImportTransfer => 'для перевода нужен один отправитель и один получатель.';

  @override
  String get errorImportRowCurrency => 'используется другая валюта без курса обмена.';

  @override
  String get adminSetupTitle => 'Настроить сервер';

  @override
  String get adminSetupBody =>
      'Задайте пароль администратора. Он защищает эту страницу с настройками сервера. Имени пользователя нет: настройки может изменить любой, кто знает пароль.';

  @override
  String get adminSetupCode => 'Код настройки';

  @override
  String get adminSetupCodeHelp =>
      'На сервере уже есть данные, поэтому при запуске код настройки был записан в журнал. Для Docker: docker compose logs balnana';

  @override
  String get adminSetupAction => 'Задать пароль';

  @override
  String get adminPassword => 'Пароль администратора';

  @override
  String get adminPasswordRepeat => 'Повторите пароль';

  @override
  String get adminPasswordMismatch => 'Пароли не совпадают.';

  @override
  String get adminLoginTitle => 'Администрирование';

  @override
  String get adminLoginBody => 'Введите пароль администратора, чтобы изменить настройки сервера.';

  @override
  String get adminLoginAction => 'Войти';

  @override
  String get adminSettingsTitle => 'Настройки сервера';

  @override
  String get adminSaved => 'Настройки сохранены и применены.';

  @override
  String get adminSaveFailed => 'Ничего не сохранено. Проверьте настройки, отмеченные цветом.';

  @override
  String get adminChangePassword => 'Изменить пароль администратора';

  @override
  String get adminPasswordCurrent => 'Текущий пароль';

  @override
  String get adminPasswordNew => 'Новый пароль';

  @override
  String get adminPasswordChanged => 'Пароль изменён. В других сеансах администратора выполнен выход.';

  @override
  String get adminSignOut => 'Выйти из панели администратора';

  @override
  String get adminBackHome => 'Вернуться в Balnana';

  @override
  String get adminRequireEmail => 'Требовать адрес электронной почты';

  @override
  String get adminRequireEmailHelp =>
      'Если выключено, при регистрации можно указать имя пользователя без адреса электронной почты. Для входа подойдёт то или другое.';

  @override
  String get adminRequireEmailUnused =>
      'Работает только для входа по электронной почте и паролю, который сейчас выключен.';

  @override
  String get accountUsername => 'Имя пользователя';

  @override
  String get accountUsernameHelp =>
      'От 3 до 32 букв, цифр, точек, дефисов или подчёркиваний. Используйте его для входа.';

  @override
  String get accountEmailOptional => 'Электронная почта (необязательно)';

  @override
  String get accountEmailOptionalHelp =>
      'На этот адрес можно получать приглашения в группы и ссылки для сброса забытого пароля.';

  @override
  String get accountLogin => 'Электронная почта или имя пользователя';

  @override
  String get errorInvalidUsername =>
      'Используйте от 3 до 32 букв, цифр, точек, дефисов или подчёркиваний. Начните с буквы или цифры.';

  @override
  String get errorUsernameTaken => 'Это имя пользователя уже занято.';

  @override
  String get adminDiscardTitle => 'Отменить изменения?';

  @override
  String get adminDiscardBody => 'Изменения настроек ещё не сохранены.';

  @override
  String get adminDiscard => 'Отменить';

  @override
  String adminLocked(String key) {
    return 'Задано на сервере параметром $key';
  }

  @override
  String adminDefault(String value) {
    return 'По умолчанию: $value';
  }

  @override
  String get adminSecretSaved => 'Сохранено. Введите новое значение, чтобы заменить его.';

  @override
  String get adminSecretRemoved => 'Будет удалено после сохранения.';

  @override
  String get adminSecretRemove => 'Удалить сохранённое значение';

  @override
  String get adminSectionGeneral => 'Основные';

  @override
  String get adminSectionAccess => 'Доступ';

  @override
  String get adminSectionMaps => 'Карты';

  @override
  String get adminSectionAccounts => 'Аккаунты';

  @override
  String get adminSectionAccountsBody => 'Эти настройки действуют, если для доступа нужны аккаунты.';

  @override
  String get adminSectionEmail => 'Электронная почта (SMTP)';

  @override
  String get adminSectionEmailBody => 'Подтверждение адресов, сброс паролей и приглашения.';

  @override
  String get adminSmtpOn => 'Отправлять письма';

  @override
  String get adminSectionGoogle => 'Вход через Google';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Добавьте $url как URI перенаправления в консоли Google Cloud.';
  }

  @override
  String get adminGoogleOn => 'Разрешить вход через Google';

  @override
  String get adminGoogleOnHelp => 'Участники смогут входить через аккаунт Google.';

  @override
  String get adminSectionOidc => 'Вход через OpenID Connect';

  @override
  String adminSectionOidcBody(String url) {
    return 'Добавьте $url как URI перенаправления у провайдера.';
  }

  @override
  String get adminOidcHelp =>
      'Можно использовать любого провайдера OpenID Connect, например Authentik, Keycloak или Dex. Добавьте сколько угодно провайдеров.';

  @override
  String get adminOidcAdd => 'Добавить провайдера';

  @override
  String get adminOidcRemove => 'Удалить провайдера';

  @override
  String get adminOidcNew => 'Новый провайдер';

  @override
  String get adminOidcId => 'ID';

  @override
  String get adminOidcIdHelp =>
      'Строчные буквы, цифры и дефисы. Это часть URI перенаправления; позже её нельзя будет изменить.';

  @override
  String get adminOidcIdInvalid =>
      'Используйте до 32 строчных букв, цифр и дефисов. Начните с буквы или цифры.';

  @override
  String get adminOidcIdTaken => 'У другого провайдера уже есть такой ID.';

  @override
  String get adminTrustEmail => 'Доверять адресу электронной почты';

  @override
  String get adminGoogleTrustEmailHelp =>
      'Если для адреса входа через Google уже есть аккаунт, пользователь войдёт в него. Если выключено, он войдёт с паролем и добавит Google в настройках.';

  @override
  String get adminOidcTrustEmailHelp =>
      'Используйте только провайдера, которым вы управляете или которому доверяете проверку адресов. Если выключено, пользователь войдёт с паролем и добавит провайдера в настройках.';

  @override
  String get adminRequireVerified => 'Требовать подтверждение адреса электронной почты';

  @override
  String get adminRequireVerifiedHelp =>
      'Аккаунтом нельзя пользоваться, пока адрес не подтверждён. Если доверенный способ входа использует тот же адрес, он заменит неподтверждённый аккаунт. Если выключено, пользователь сам решает, что делать.';

  @override
  String get adminRequireVerifiedUnused => 'Требуется отправка электронных писем.';

  @override
  String get adminSectionAndroid => 'Ссылки Android-приложения';

  @override
  String get adminSectionAndroidBody =>
      'Сборки Android для этого сервера открывают его ссылки в приложении. Чтобы не спрашивать каждый раз, укажите SHA-256-отпечатки сертификатов, которыми подписаны эти сборки.';

  @override
  String get adminSectionAdmin => 'Администратор';

  @override
  String get adminPublicUrl => 'Публичный адрес';

  @override
  String get adminPublicUrlHelp =>
      'По этому адресу пользователи открывают сервер. На его основе создаются ссылки на группы и в письмах.';

  @override
  String get adminSourceUrl => 'Ссылка на исходный код';

  @override
  String get adminSourceUrlHelp =>
      'Укажите, где получить исходный код сервера. Лицензия AGPL-3.0 требует этого, если вы запускаете изменённую версию.';

  @override
  String get adminAuthMode => 'Доступ';

  @override
  String get adminAuthModeLink => 'Ссылки на группы';

  @override
  String get adminAuthModeLinkHelp => 'Вход не нужен: для доступа достаточно закрытой ссылки на группу.';

  @override
  String get adminAuthModeAccounts => 'Аккаунты';

  @override
  String get adminAuthModeAccountsHelp =>
      'Участники входят в аккаунт, а по ссылке в группу могут вступить только те, кто уже вошёл.';

  @override
  String get adminPasswordLogin => 'Вход по электронной почте и паролю';

  @override
  String get adminPasswordForced =>
      'Останется включённым, пока не будет настроен вход через Google или OpenID Connect, чтобы всегда был доступен способ входа.';

  @override
  String get adminSignup => 'Кто может создать аккаунт';

  @override
  String get adminSignupOpen => 'Все';

  @override
  String get adminSignupOpenHelp => 'Зарегистрироваться может любой, у кого есть доступ к серверу.';

  @override
  String get adminSignupInvite => 'Приглашённые';

  @override
  String get adminSignupInviteHelp =>
      'Зарегистрироваться могут только те, кого пригласили в группу по электронной почте, и только на адрес, куда пришло приглашение. Одной ссылки на группу недостаточно. Для приглашений нужно включить электронную почту.';

  @override
  String get adminSignupClosed => 'Никто';

  @override
  String get adminSignupClosedHelp => 'Новые аккаунты создавать нельзя. Существующие продолжат работать.';

  @override
  String get adminSignupHelp => 'Первый аккаунт всегда можно создать.';

  @override
  String get adminLinkGroups => 'Открывать группы по ссылке';

  @override
  String get adminLinkGroupsHelp => 'Владельцы групп могут разрешить доступ по ссылке без входа в аккаунт.';

  @override
  String get adminSmtpHost => 'Почтовый сервер';

  @override
  String get adminSmtpPort => 'Порт';

  @override
  String get adminSmtpUser => 'Имя пользователя';

  @override
  String get adminSmtpPassword => 'Пароль';

  @override
  String get adminSmtpFrom => 'Отправитель';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'ID клиента';

  @override
  String get adminClientSecret => 'Секрет клиента';

  @override
  String get adminOidcIssuer => 'URL издателя';

  @override
  String get adminOidcName => 'Название кнопки';

  @override
  String get adminOidcNameHelp => 'Показывается на странице входа в виде «Продолжить через …».';

  @override
  String get adminFingerprints => 'Отпечатки сертификатов';

  @override
  String get adminFingerprintsHelp =>
      'SHA-256 через запятую. Их можно узнать командами keytool -list -v и apksigner verify --print-certs.';

  @override
  String get adminInvalidValue => 'Недопустимое значение.';

  @override
  String get adminInvalidUrl => 'Введите полный адрес, начинающийся с https:// или http://.';

  @override
  String get adminInvalidFrom =>
      'Введите отправителя, например Balnana <balnana@example.com>; нужен адрес электронной почты.';

  @override
  String get adminInvalidPort => 'Введите номер порта от 1 до 65535.';

  @override
  String get adminInvalidRequired => 'Это поле нужно для выбранного способа входа.';

  @override
  String get adminInvalidFingerprint =>
      'Введите SHA-256-отпечатки: по 64 шестнадцатеричных цифры, можно с двоеточиями.';

  @override
  String get adminNeedsSignIn =>
      'Для аккаунтов нужен способ входа: включите электронную почту и пароль или настройте провайдера.';

  @override
  String get adminLockedChange => 'Это задано на сервере, здесь изменить нельзя.';

  @override
  String get errorAdminRequired => 'Сеанс администратора завершился. Войдите снова.';

  @override
  String get errorAdminWrongPassword => 'Неверный пароль.';

  @override
  String get errorInvalidSetupCode => 'Неверный код настройки. Найдите его в журнале сервера.';

  @override
  String get errorAlreadySetUp => 'Этот сервер уже настроен. Войдите с паролем администратора.';

  @override
  String get linkOpening => 'Открываем ссылку…';

  @override
  String get linkForeignTitle => 'Эта ссылка ведёт на другой сервер';

  @override
  String linkForeignBody(String server) {
    return 'Приложение подключено к серверу $server, а ссылка ведёт на другой сервер. Смените сервер в настройках, чтобы открыть её.';
  }

  @override
  String get linkInvalidTitle => 'Не удаётся открыть ссылку';

  @override
  String get linkInvalidBody => 'Это неизвестная приложению ссылка Balnana.';

  @override
  String get linkGoHome => 'К списку групп';

  @override
  String get linkOpenInBrowser => 'Открыть в браузере';

  @override
  String get privacyTitle => 'Политика конфиденциальности';

  @override
  String get privacyIntro =>
      'Balnana — это программа с открытым исходным кодом. Администратор подключённого сервера решает, где хранить ваши данные, и отвечает за них. Здесь описано, какие данные хранит сама программа и как она их использует.';

  @override
  String get privacyStoredTitle => 'Какие данные хранятся';

  @override
  String get privacyStoredBody =>
      'В созданных вами группах и группах, в которые вы вступили, хранятся их названия, имена участников, расходы, платежи, примечания, фото чеков и указанные в расходах места. Если у вас есть аккаунт, также хранятся ваше имя, адрес электронной почты или имя пользователя, хеш пароля (сам пароль не хранится) и способ входа, например Google. Если включены уведомления, хранится идентификатор устройства и адрес, который присвоила ему служба push-уведомлений.';

  @override
  String get privacyUseTitle => 'Как используются данные';

  @override
  String get privacyUseBody =>
      'Данные нужны только для работы приложения: показа групп их участникам, расчёта баланса и отправки необходимых писем и уведомлений, например для подтверждения адреса, сброса пароля и приглашений. В приложении нет рекламы и аналитики, данные не продаются.';

  @override
  String get privacySharedTitle => 'Кто видит данные';

  @override
  String get privacySharedBody =>
      'Все участники группы видят её участников, расходы и историю. Если группа открыта по ссылке, открыть её может любой, у кого есть ссылка. Вход через Google выполняется через Google. Если администратор включил уведомления, они отправляются через службу push-уведомлений вашего телефона: Firebase Cloud Messaging от Google или другую установленную вами службу UnifiedPush, например ntfy. Содержимое уведомлений шифруется при отправке. Карты загружают изображения у выбранного администратором поставщика карт (по умолчанию OpenFreeMap), который видит ваш сетевой адрес и просматриваемый вами район. ваше местоположение считывается только после нажатия «Определить моё местоположение», и сохраняется только выбранная вами точка.';

  @override
  String get privacyDeviceTitle => 'На этом устройстве';

  @override
  String get privacyDeviceBody =>
      'Приложение хранит адрес сервера, ваши настройки и копию групп на случай отсутствия подключения. После удаления приложения эти данные удаляются.';

  @override
  String get privacyDeleteTitle => 'Удаление данных';

  @override
  String get privacyDeleteBody =>
      'Аккаунт можно удалить в настройках. ваше имя останется в группах как имя участника, за которым никто не закреплён, чтобы баланс продолжал сходиться. Группы, к которым больше никто не имеет доступа, будут удалены. Владелец группы может удалить её целиком в настройках группы. По другим вопросам обратитесь к администратору сервера.';

  @override
  String get privacyOperatorPolicy => 'Политика конфиденциальности администратора сервера';

  @override
  String get privacyLink => 'Конфиденциальность';

  @override
  String get accountEmailAdd => 'Добавить адрес электронной почты';

  @override
  String get accountEmailChange => 'Изменить адрес электронной почты';

  @override
  String get accountEmailNew => 'Адрес электронной почты';

  @override
  String get accountEmailVerifyNote =>
      'Мы отправим ссылку для подтверждения нового адреса. До этого текущий адрес останется в аккаунте.';

  @override
  String get accountEmailPendingTitle => 'Подтвердите новый адрес электронной почты';

  @override
  String accountEmailPendingHelp(String email) {
    return 'После перехода по ссылке, отправленной на $email, этот адрес заменит текущий. Нажмите, чтобы отправить ссылку ещё раз.';
  }

  @override
  String get accountEmailRemoveNote =>
      'Оставьте поле пустым, чтобы удалить адрес. вы по-прежнему сможете входить по имени пользователя.';

  @override
  String get accountEmailSaved => 'Адрес электронной почты сохранён';

  @override
  String get accountEmailRemoved => 'Адрес электронной почты удалён';

  @override
  String get accountConfirmPassword => 'ваш пароль';

  @override
  String get accountConfirmPasswordHelp => 'Чтобы подтвердить, что это вы.';

  @override
  String get errorEmailNeeded => 'вы входите по адресу электронной почты, поэтому его нельзя удалить.';

  @override
  String get accountDelete => 'Удалить аккаунт';

  @override
  String get accountDeleteHelp => 'Удалить аккаунт с этого сервера';

  @override
  String get accountDeleteTitle => 'Удалить аккаунт?';

  @override
  String get accountDeleteBody =>
      'Аккаунт будет удалён без возможности восстановления, и вы выйдете из него. В группах ваше имя останется как имя участника, за которым никто не закреплён, чтобы баланс продолжал сходиться. Группы, в которых больше никого нет, будут удалены.';

  @override
  String get accountDeleteAction => 'Удалить навсегда';

  @override
  String get accountDeleted => 'ваш аккаунт удалён.';

  @override
  String get accountDeletePageSignedOut => 'Войдите, чтобы удалить аккаунт на этом сервере.';

  @override
  String get accountDeletePageLinkMode =>
      'На этом сервере нет аккаунтов: для доступа достаточно ссылки на группу. Чтобы удалить группу со всеми данными, откройте её настройки и выберите «Удалить группу».';

  @override
  String get groupDelete => 'Удалить группу';

  @override
  String get groupDeleteHelp => 'Удалить группу со всеми расходами для всех участников';

  @override
  String groupDeleteTitle(String name) {
    return 'Удалить группу «$name»?';
  }

  @override
  String get groupDeleteBody =>
      'Группа, все её расходы, платежи и история будут удалены для всех. Это действие нельзя отменить. Для подтверждения введите название группы.';

  @override
  String get groupDeleteName => 'Название группы';

  @override
  String get groupDeleteAction => 'Удалить навсегда';

  @override
  String get groupDeleted => 'Группа удалена';

  @override
  String get groupDeleteOwnerOnly => 'Удалить группу может только её владелец.';

  @override
  String get expenseDiscardTitle => 'Отменить изменения?';

  @override
  String get expenseDiscardBody => 'Изменения этого расхода ещё не сохранены.';

  @override
  String get expenseDiscard => 'Отменить';

  @override
  String get adminPrivacyUrl => 'Ссылка на политику конфиденциальности';

  @override
  String get adminPrivacyUrlHelp =>
      'Ссылка на вашу политику конфиденциальности, которую требуют магазины приложений. Если поле пустое, приложение показывает общую политику о данных, которые хранит Balnana.';

  @override
  String get adminMapTiles => 'Тайлы карты';

  @override
  String get adminMapSource => 'Источник карты';

  @override
  String get adminMapSourceStyle => 'Векторный стиль';

  @override
  String get adminMapSourceStyleHelp =>
      'Карты на основе стиля MapLibre, например бесплатного OpenFreeMap, для которого не нужен ключ.';

  @override
  String get adminMapSourceTiles => 'Растровые тайлы';

  @override
  String get adminMapSourceTilesHelp => 'Карты из изображений тайлов, например OpenStreetMap.';

  @override
  String get adminMapSourceOff => 'Выключено';

  @override
  String get adminMapSourceOffHelp => 'Без карт. Названия мест и координаты в расходах сохраняются.';

  @override
  String get adminMapStyle => 'URL стиля';

  @override
  String get adminMapStyleHelp =>
      'Адрес style.json для MapLibre, например Liberty от OpenFreeMap (по умолчанию), Bright или Positron.';

  @override
  String get adminMapTilesHelp =>
      'Шаблон URL растровых тайлов с z, x и y в фигурных скобках, как в значении по умолчанию. Собственные серверы OpenStreetMap предназначены только для небольшой нагрузки; для загруженного сервера используйте поставщика тайлов.';

  @override
  String get adminMapAttribution => 'Указание источника карты';

  @override
  String get adminMapAttributionHelp =>
      'Показывается на каждой карте по требованию поставщика. Если поле пустое, векторный стиль показывает указанные в нём источники, а тайлы указывают OpenStreetMap.';

  @override
  String get adminInvalidMapTiles => 'Введите шаблон URL http(s) с z, x и y в фигурных скобках.';

  @override
  String get adminUsers => 'Аккаунты';

  @override
  String get adminUsersSearch => 'Поиск по имени, электронной почте или имени пользователя';

  @override
  String adminUsersShown(int shown, int total) {
    return 'Аккаунты: $shown из $total';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count аккаунта',
      many: '$count аккаунтов',
      few: '$count аккаунта',
      two: '$count аккаунта',
      one: '$count аккаунт',
    );
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => 'Совпадений нет.';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count группы',
      many: '$count групп',
      few: '$count группы',
      two: '$count группы',
      one: '$count группа',
      zero: 'Нет групп',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => 'не подтверждён';

  @override
  String adminUserDeleteTitle(String name) {
    return 'Удалить аккаунт $name?';
  }

  @override
  String get adminUserDeleteBody =>
      'Аккаунт будет удалён без возможности восстановления, и сеансы будут завершены на всех устройствах. Имя останется в группах как имя участника, за которым никто не закреплён; группы, в которых больше никого нет, будут удалены.';

  @override
  String get adminUserDeleted => 'Аккаунт удалён';

  @override
  String get commonDone => 'Готово';

  @override
  String get crowdSearch => 'Поиск участников';

  @override
  String get crowdNoMatch => 'Совпадений нет.';

  @override
  String get crowdAll => 'Все';

  @override
  String get crowdNone => 'Никто';

  @override
  String crowdChosen(int count, int total) {
    return 'Выбрано: $count из $total';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ещё $count',
      many: 'ещё $count',
      few: 'ещё $count',
      two: 'ещё $count',
      one: 'ещё $count',
    );
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => 'Показать меньше';

  @override
  String get crowdSort => 'Сортировка';

  @override
  String crowdShowAll(int count) {
    return 'Показать всех: $count';
  }

  @override
  String get crowdBalances => 'Баланс всех участников';

  @override
  String get crowdSomeoneElse => 'Кто-то другой';

  @override
  String get crowdChoosePayers => 'Выбрать плательщиков';

  @override
  String get crowdFilterTitle => 'Чьи расходы?';

  @override
  String get myGroupsTitle => 'Мои ссылки на группы';

  @override
  String get myGroupsExport => 'Экспортировать мои группы';

  @override
  String get myGroupsExportHelp =>
      'Скопируйте ссылки на группы для резервной копии или переноса на другое устройство.';

  @override
  String get myGroupsPrivate => 'Не передавайте эти ссылки: любой, у кого есть ссылка, может открыть группу.';

  @override
  String get myGroupsCopy => 'Скопировать ссылки';

  @override
  String get myGroupsImport => 'Импортировать группы';

  @override
  String get myGroupsImportHelp =>
      'Вставьте ссылки на группы с этого сервера, по одной в строке. Существующие группы сохранят своё место в списке и останутся без изменений.';

  @override
  String get myGroupsLinks => 'Ссылки на группы';

  @override
  String get myGroupsImportAction => 'Импортировать ссылки';

  @override
  String get myGroupsInvalid =>
      'Введите действительные ссылки на группы, по одной в строке. Импорт не выполнен.';

  @override
  String get myGroupsServerChanged =>
      'Выбран другой сервер. Закройте это окно и импортируйте ссылки на соответствующем сервере.';

  @override
  String myGroupsLimit(int count) {
    return 'На каждом сервере можно хранить не более $count ссылок на группы. Импорт не выполнен.';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count новых ссылок на группы.',
      many: 'Импортировано $count новых ссылок на группы.',
      few: 'Импортированы $count новые ссылки на группы.',
      two: 'Импортированы $count новые ссылки на группы.',
      one: 'Импортирована $count новая ссылка на группу.',
      zero: 'Эти группы уже сохранены.',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => 'Повтор';

  @override
  String get repeatNever => 'Не повторять';

  @override
  String get repeatDaily => 'Каждый день';

  @override
  String get repeatWeekly => 'Каждую неделю';

  @override
  String get repeatMonthly => 'Каждый месяц';

  @override
  String get repeatYearly => 'Каждый год';

  @override
  String get repeatEvery => 'Раз в';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'дня',
      many: 'дней',
      few: 'дня',
      two: 'дня',
      one: 'день',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'недели',
      many: 'недель',
      few: 'недели',
      two: 'недели',
      one: 'неделю',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'месяца',
      many: 'месяцев',
      few: 'месяца',
      two: 'месяца',
      one: 'месяц',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'года',
      many: 'лет',
      few: 'года',
      two: 'года',
      one: 'год',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Раз в $count дня',
      many: 'Раз в $count дней',
      few: 'Раз в $count дня',
      two: 'Раз в $count дня',
      one: 'Раз в $count день',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Раз в $count недели',
      many: 'Раз в $count недель',
      few: 'Раз в $count недели',
      two: 'Раз в $count недели',
      one: 'Раз в $count неделю',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Раз в $count месяца',
      many: 'Раз в $count месяцев',
      few: 'Раз в $count месяца',
      two: 'Раз в $count месяца',
      one: 'Раз в $count месяц',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Раз в $count года',
      many: 'Раз в $count лет',
      few: 'Раз в $count года',
      two: 'Раз в $count года',
      one: 'Раз в $count год',
    );
    return '$_temp0';
  }

  @override
  String get repeatEndNone => 'Без даты окончания';

  @override
  String repeatEndOn(String date) {
    return 'До $date';
  }

  @override
  String get repeatEndClear => 'Убрать дату окончания';

  @override
  String get repeatHelp =>
      'Расход будет автоматически добавляться в группу в каждую указанную дату, начиная с даты выше. Пропущенные даты будут добавлены при сохранении.';

  @override
  String get repeatDropReceiptTitle => 'Удалить чек?';

  @override
  String get repeatDropReceiptBody =>
      'У регулярного расхода не может быть чека. Вместо этого можно добавить чек к каждому созданному расходу.';

  @override
  String get repeatDropReceiptAction => 'Повторять';

  @override
  String get recurringTitle => 'Регулярные расходы';

  @override
  String get recurringHelp => 'Расходы, которые автоматически добавляются по расписанию';

  @override
  String get recurringEmptyTitle => 'Нет регулярных расходов';

  @override
  String get recurringEmptyBody =>
      'Аренда, подписки и другие повторяющиеся расходы могут автоматически добавляться в нужные даты.';

  @override
  String get recurringAdd => 'Добавить регулярный расход';

  @override
  String get recurringEdit => 'Изменить регулярный расход';

  @override
  String recurringNext(String date) {
    return 'Следующий: $date';
  }

  @override
  String get recurringPaused => 'Приостановлен';

  @override
  String get recurringEnded => 'Завершён';

  @override
  String get recurringPause => 'Приостановить';

  @override
  String get recurringResume => 'Возобновить';

  @override
  String get recurringActive => 'Повторяется';

  @override
  String get recurringDelete => 'Удалить';

  @override
  String get recurringDeleteTitle => 'Прекратить повторение?';

  @override
  String recurringDeleteBody(String title) {
    return '«$title» больше не будет добавляться. Уже добавленные расходы останутся.';
  }

  @override
  String get recurringDeleted => 'Регулярный расход удалён';

  @override
  String get recurringFromSchedule => 'Добавлено по расписанию регулярного расхода';

  @override
  String get recurringOpen => 'Изменить расписание';

  @override
  String get recurringMissing => 'Регулярный расход удалён или больше недоступен.';

  @override
  String get errorTooManyDue => 'Дата начала слишком давняя: за один раз добавится больше 100 расходов.';

  @override
  String get errorInvalidEnd => 'Дата окончания не может быть раньше даты начала.';

  @override
  String get errorInvalidRepeat => 'Повторяйте от 1 до 999 дней, недель, месяцев или лет.';

  @override
  String get errorRecurringConflict =>
      'Пока вы редактировали регулярный расход, его изменил кто-то другой. Обновите страницу, чтобы увидеть изменения.';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$who настроил(а) повторение расхода «$title»';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$who изменил(а) регулярный расход «$title»';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$who приостановил(а) регулярный расход «$title»';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return 'Повторение расхода «$title» приостановлено, потому что кто-то из участников покинул группу';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return 'Повторение расхода «$title» приостановлено, потому что его не удалось добавить';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$who возобновил(а) регулярный расход «$title»';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$who прекратил(а) повторение расхода «$title»';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return 'Расход «$title» ($amount) добавлен автоматически';
  }

  @override
  String get expenseRecurring => 'Добавлено по расписанию регулярного расхода';

  @override
  String get adminPlans => 'Тарифы';

  @override
  String get adminPayments => 'Платежи';

  @override
  String get adminSectionBilling => 'Тарифы и платежи';

  @override
  String get adminSectionBillingBody =>
      'Тарифы повышают лимиты на то, что хранит этот сервер. Деление расходов и расчёты остаются бесплатными.';

  @override
  String get adminBillingOn => 'Тарифы и лимиты';

  @override
  String get adminBillingOnHelp => 'Если выключено, сервер ничего не ограничивает и не показывает тарифы.';

  @override
  String get adminBillingNeedsAccounts =>
      'Для тарифов нужны аккаунты: сначала включите режим доступа с аккаунтами.';

  @override
  String get adminKofiUrl => 'Страница Ko-fi';

  @override
  String get adminKofiUrlHelp =>
      'Здесь выполняется оплата. Ссылка есть только в сборках, где разрешены внешние платежи.';

  @override
  String adminKofiWebhook(String url) {
    return 'URL вебхука для Ko-fi: $url';
  }

  @override
  String get adminKofiToken => 'Токен проверки Ko-fi';

  @override
  String get adminKofiTokenHelp => 'Указан на странице вебхука Ko-fi. Без него сервер игнорирует Ko-fi.';

  @override
  String adminUserPlanUntil(String plan, String date) {
    return '$plan до $date';
  }

  @override
  String get adminPlansHelp =>
      'Новый лимит действует на то, что добавят дальше. Уже добавленное остаётся. Оставьте пустым, чтобы не ограничивать.';

  @override
  String get adminPlanAdd => 'Добавить тариф';

  @override
  String adminPlanDefaultName(String name) {
    return '$name (по умолчанию)';
  }

  @override
  String adminPlanLimit(String label, String value) {
    return '$label: $value';
  }

  @override
  String adminPlanDays(int count) {
    return 'Дней: $count';
  }

  @override
  String get adminProductsSection => 'Продукты';

  @override
  String get adminProductsHelp =>
      'Платёж относится к продукту с названием его уровня, а если такого нет — к продукту без названия уровня, сумма которого достигнута.';

  @override
  String get adminProductAdd => 'Добавить продукт';

  @override
  String get adminProductEdit => 'Изменить продукт';

  @override
  String adminProductAnyPayment(String amount) {
    return 'Любой платёж от $amount';
  }

  @override
  String get adminProductName => 'Название уровня';

  @override
  String get adminProductNameHelp =>
      'Как на Ko-fi. Оставьте пустым, чтобы сопоставлять разовые и ежемесячные платежи по сумме.';

  @override
  String get adminProductPlan => 'Тариф';

  @override
  String get adminProductDays => 'Дней';

  @override
  String get adminProductDaysHelp =>
      'На сколько хватает одного платежа. Новый платёж добавляется к оставшемуся сроку.';

  @override
  String get adminProductMinAmount => 'Минимальная сумма';

  @override
  String get adminProductCurrency => 'Код валюты';

  @override
  String get adminPlanId => 'ID';

  @override
  String get adminPlanIdHelp => 'Строчные латинские буквы, цифры и дефисы. Изменить потом нельзя.';

  @override
  String get adminPlanName => 'Название';

  @override
  String get adminPlanRank => 'Ранг';

  @override
  String get adminPlanRankHelp => 'Аккаунт с несколькими тарифами получает тариф с наивысшим рангом.';

  @override
  String get adminPlanDefault => 'Тариф по умолчанию';

  @override
  String get adminPlanDefaultHelp => 'Для всех аккаунтов без другого тарифа.';

  @override
  String get adminEntitlementGranted => 'Выдан администратором';

  @override
  String get adminEntitlementRevoked => 'Отозван';

  @override
  String get adminEntitlementForever => 'Без даты окончания';

  @override
  String adminEntitlementUntil(String date) {
    return 'До $date';
  }

  @override
  String adminEntitlementEnded(String date) {
    return 'Закончился $date';
  }

  @override
  String get adminEntitlementsEmpty => 'У этого аккаунта пока нет тарифов.';

  @override
  String get adminEntitlementRevoke => 'Отозвать';

  @override
  String get adminEntitlementNote => 'Заметка';

  @override
  String get adminEntitlementGrant => 'Выдать тариф';

  @override
  String get adminPaymentApplied => 'Применён';

  @override
  String get adminPaymentUnclaimed => 'Не востребован';

  @override
  String get adminPaymentUnmatched => 'Не сопоставлен';

  @override
  String get adminPaymentsAll => 'Все';

  @override
  String adminPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count платежа',
      many: '$count платежей',
      few: '$count платежа',
      two: '$count платежа',
      one: '$count платёж',
    );
    return '$_temp0';
  }

  @override
  String get adminPaymentsEmpty => 'Платежей нет.';

  @override
  String get adminPaymentAssigned => 'Тариф выдан аккаунту.';

  @override
  String get adminPaymentAssign => 'Выдать аккаунту';

  @override
  String get adminPaymentPickUser => 'Выберите аккаунт.';

  @override
  String get errorBillingOff => 'На этом сервере нет тарифов.';

  @override
  String get errorAlreadySponsored => 'Эта группа уже покрыта тарифом другого участника.';

  @override
  String get errorPlanInUse => 'Этот тариф ещё используют аккаунты или продукты.';

  @override
  String get errorPaymentApplied => 'Этот платёж уже применён.';

  @override
  String get errorInvalidPlan => 'Проверьте настройки тарифа: что-то указано неверно.';

  @override
  String errorLimitReceipts(int max) {
    return 'Группа достигла лимита фото чеков: $max.';
  }

  @override
  String errorLimitRecurring(int max) {
    return 'Группа достигла лимита регулярных расходов: $max.';
  }

  @override
  String errorLimitOwnGroups(int max) {
    return 'Вы достигли лимита групп: $max.';
  }

  @override
  String errorLimitSponsored(int max) {
    return 'Тариф можно разделить максимум с таким числом групп: $max.';
  }

  @override
  String get errorLimitOther => 'Вы достигли лимита этого сервера.';

  @override
  String get planTitle => 'Тариф';

  @override
  String get planUnlimited => 'Без лимита';

  @override
  String planUntil(String date) {
    return 'До $date';
  }

  @override
  String get planSettingsHelp => 'Что этот сервер хранит для вас';

  @override
  String get planIntro =>
      'Деление и расчёты всегда бесплатны. Тариф меняет только то, сколько этот сервер хранит для вас.';

  @override
  String planUsage(int used, int limit) {
    return '$used из $limit';
  }

  @override
  String planUsed(int used) {
    return 'Использовано: $used';
  }

  @override
  String get planLimits => 'Лимиты';

  @override
  String get planLimitReceipts => 'Фото чеков на группу';

  @override
  String get planLimitRecurring => 'Регулярные расходы на группу';

  @override
  String get planLimitOwnGroups => 'Созданные вами группы';

  @override
  String get planLimitSponsored => 'Группы с вашим тарифом';

  @override
  String get planGet => 'Получить тариф';

  @override
  String get planKofi => 'Ko-fi';

  @override
  String get planKofiHelp =>
      'Платите с подтверждённой почты аккаунта или добавьте ниже адрес, с которого платите.';

  @override
  String get planPaymentEmailConfirmed => 'Платежи с этого адреса засчитываются вашему аккаунту';

  @override
  String get planPaymentEmailAdd => 'Добавить почту для оплаты';

  @override
  String get planPaymentEmailHelp => 'Мы отправим ссылку, чтобы подтвердить, что адрес ваш.';

  @override
  String get paymentEmailDone => 'Адрес подтверждён';

  @override
  String get paymentEmailDoneBody => 'Платежи с этого адреса теперь засчитываются вашему аккаунту.';

  @override
  String groupPlanUsage(String receipts, String recurring) {
    return 'Фото чеков: $receipts · Регулярные: $recurring';
  }

  @override
  String get groupSponsor => 'Поделиться тарифом с этой группой';

  @override
  String get groupUnsponsor => 'Больше не делиться тарифом';

  @override
  String groupSponsoredBy(String name) {
    return 'Использует тариф участника $name';
  }
}
