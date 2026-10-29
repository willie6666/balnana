// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get languageEndonym => 'Polski';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonRetry => 'Ponów';

  @override
  String get offlineBar =>
      'Brak połączenia. Wyświetlam dane zapisane na tym urządzeniu; zmiany będzie można zapisać po ponownym połączeniu.';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get commonClear => 'Wyczyść';

  @override
  String get iconChoose => 'Wybierz ikonę';

  @override
  String get iconNone => 'Brak ikony';

  @override
  String get iconSearchHint => 'Szukaj lub wpisz dowolne emoji';

  @override
  String get iconUseTyped => 'Użyj tego emoji';

  @override
  String get iconNoMatch => 'Brak pasujących ikon. Wpisz emoji, aby go użyć.';

  @override
  String get iconSectionTravel => 'Podróże i miejsca';

  @override
  String get iconSectionFood => 'Jedzenie i napoje';

  @override
  String get iconSectionActivities => 'Aktywności';

  @override
  String get iconSectionHome => 'Dom i rachunki';

  @override
  String get iconSectionPeople => 'Osoby';

  @override
  String get iconSectionNature => 'Zwierzęta i przyroda';

  @override
  String get iconSectionObjects => 'Pieniądze i przedmioty';

  @override
  String get iconSectionSymbols => 'Symbole';

  @override
  String get commonRemove => 'Usuń';

  @override
  String get commonUndo => 'Cofnij';

  @override
  String get someone => 'Ktoś';

  @override
  String get errorTooLarge => 'Plik jest za duży, aby wysłać go na serwer.';

  @override
  String get errorBusy => 'Serwer jest zajęty. Spróbuj ponownie za chwilę.';

  @override
  String get errorTimeout => 'Wysyłanie trwało zbyt długo. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get errorBadOrigin =>
      'Serwer nie akceptuje logowania z tego adresu. Administrator powinien sprawdzić publiczny adres serwera.';

  @override
  String get errorInvalidCategory => 'Ta kategoria została już usunięta. Wybierz inną.';

  @override
  String get errorBuiltinCategory => 'Wbudowane kategorie można tylko ukryć.';

  @override
  String get errorUnknownMember => 'Kogoś z tej grupy już w niej nie ma. Odśwież stronę i spróbuj ponownie.';

  @override
  String get errorNoPayers => 'Wybierz, kto zapłacił.';

  @override
  String get errorPayerTotal => 'Suma kwot zapłaconych przez poszczególne osoby musi być równa całej kwocie.';

  @override
  String get errorPayerTooSmall =>
      'Część zapłacona przez jedną z osób wynosi zero w walucie grupy. Sprawdź kwoty.';

  @override
  String get errorInvalidNote => 'Notatka jest za długa lub zawiera znaki, których nie można zapisać.';

  @override
  String get errorInvalidDate => 'Ta data jest poza dozwolonym zakresem.';

  @override
  String get errorGeneric => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get errorNetwork => 'Nie można połączyć się z serwerem. Sprawdź połączenie.';

  @override
  String get errorNotFound => 'Ten element już nie istnieje.';

  @override
  String get errorRequired => 'To pole jest wymagane.';

  @override
  String get errorInvalidName => 'Wpisz nazwę o długości do 100 znaków.';

  @override
  String get errorDuplicateName => 'Ktoś w tej grupie ma już taką nazwę.';

  @override
  String get errorTooManyMembers => 'W tej grupie jest już maksymalna liczba osób.';

  @override
  String get errorTooManyCategories => 'W tej grupie jest już maksymalna liczba kategorii.';

  @override
  String get errorDuplicateCategory => 'Ta grupa ma już kategorię o tej nazwie.';

  @override
  String get errorInvalidCurrency => 'Wpisz trzyliterowy kod waluty, na przykład USD.';

  @override
  String get errorInvalidTitle => 'Wpisz tytuł o długości do 200 znaków.';

  @override
  String get errorInvalidLocation => 'Wpisz nazwę miejsca w jednym wierszu, do 200 znaków.';

  @override
  String get errorInvalidSymbol => 'Wpisz symbol o długości do 8 znaków.';

  @override
  String get errorInvalidEmoji => 'Wybierz jedno emoji jako ikonę.';

  @override
  String get errorMemberHasBalance => 'Rozlicz saldo tej osoby, zanim ją usuniesz.';

  @override
  String get errorVersionConflict =>
      'Ktoś inny zmienił ten wydatek podczas edycji. Odśwież stronę, aby zobaczyć zmiany.';

  @override
  String get errorSignInRequired => 'Zaloguj się, aby to zrobić.';

  @override
  String get errorRateLimited => 'Wysłano zbyt wiele próśb. Odczekaj minutę i spróbuj ponownie.';

  @override
  String get errorNotAMember => 'Nie należysz jeszcze do tej grupy.';

  @override
  String get errorNotAllowed => 'Może to zrobić tylko ta osoba albo właściciel grupy.';

  @override
  String get errorLinkGroupsOff => 'Ten serwer nie pozwala otwierać grup za pomocą samego linku.';

  @override
  String get errorMemberClaimed => 'Ktoś już dołączył jako ta osoba.';

  @override
  String get errorMemberLeft => 'Ktoś z tej grupy już ją opuścił.';

  @override
  String get errorInvalidEmail => 'Wpisz adres e-mail.';

  @override
  String get errorInvalidPassword => 'Użyj od 8 do 200 znaków.';

  @override
  String get errorEmailTaken => 'Konto z tym adresem e-mail już istnieje. Zamiast tego zaloguj się.';

  @override
  String get errorSignupClosed => 'Na tym serwerze nie można zakładać nowych kont.';

  @override
  String get errorInvalidCredentials => 'Ten adres e-mail i hasło do siebie nie pasują.';

  @override
  String get errorWrongPassword => 'Obecne hasło jest nieprawidłowe.';

  @override
  String get errorAccountsOff => 'Ten serwer nie obsługuje kont.';

  @override
  String get errorInvalidAmount => 'Wpisz kwotę większą od zera.';

  @override
  String get errorTooManyDecimals => 'Za dużo miejsc po przecinku dla tej waluty.';

  @override
  String get errorAmountTooLarge => 'Ta kwota jest za duża.';

  @override
  String get errorNoShares => 'Wybierz co najmniej jedną osobę, która poniesie koszt.';

  @override
  String get errorInvalidShare => 'Każdy udział musi być liczbą.';

  @override
  String get errorExactTotal => 'Suma kwot musi być równa całości.';

  @override
  String get errorPayersTotal => 'Suma kwot zapłaconych przez wszystkich musi być równa całości.';

  @override
  String get categoryFood => 'Jedzenie i napoje';

  @override
  String get categoryGroceries => 'Zakupy spożywcze';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryTravel => 'Podróże';

  @override
  String get categoryLodging => 'Noclegi';

  @override
  String get categoryRent => 'Czynsz';

  @override
  String get categoryUtilities => 'Rachunki';

  @override
  String get categoryEntertainment => 'Rozrywka';

  @override
  String get categoryShopping => 'Zakupy';

  @override
  String get categoryHealth => 'Zdrowie';

  @override
  String get categoryGifts => 'Prezenty';

  @override
  String get categoryOther => 'Inne';

  @override
  String get groupNew => 'Nowa grupa';

  @override
  String get groupSwitch => 'Zmień grupę';

  @override
  String get groupReorder => 'Przeciągnij, aby zmienić kolejność';

  @override
  String get groupCreate => 'Utwórz grupę';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osoby',
      many: '$count osób',
      few: '$count osoby',
      two: '$count osoby',
      one: '1 osoba',
    );
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return 'Masz do odebrania $amount';
  }

  @override
  String pillOwe(String amount) {
    return 'Masz do zapłaty $amount';
  }

  @override
  String get pillSettled => 'Rozliczone';

  @override
  String get groupMissingTitle => 'Nie znaleziono grupy';

  @override
  String get groupMissingBody =>
      'Ta grupa została usunięta albo jej link został zresetowany. Poproś kogoś z grupy o nowy link.';

  @override
  String get groupLockedTitle => 'Zaloguj się, aby otworzyć tę grupę';

  @override
  String get groupLockedBody =>
      'Ta grupa jest dostępna tylko dla kont jej członków. Zaloguj się na konto przypisane do tej grupy.';

  @override
  String get groupForget => 'Usuń z tego urządzenia';

  @override
  String get groupLinkOtherServer =>
      'Ten link prowadzi do innego serwera. Połącz się z nim, aby otworzyć grupę.';

  @override
  String get openLinkTitle => 'Otwórz link do grupy';

  @override
  String get openLinkBody => 'Wklej link udostępniony przez kogoś, aby dołączyć do grupy.';

  @override
  String get openLinkLabel => 'Link do grupy';

  @override
  String get openLinkAction => 'Otwórz';

  @override
  String get openLinkInvalid => 'To nie wygląda na link do grupy Balnana.';

  @override
  String get groupName => 'Nazwa grupy';

  @override
  String get groupNameHint => 'Wyjazd do Lizbony';

  @override
  String get groupCurrency => 'Waluta';

  @override
  String get groupCurrencyHelp =>
      'Wszystkie wydatki w tej grupie będą w tej walucie. Później nie można jej zmienić.';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name. Wszystkie wydatki w tej grupie będą w tej walucie. Później nie można jej zmienić.';
  }

  @override
  String get currencyChoose => 'Wybierz walutę';

  @override
  String get currencySearchHint => 'Szukaj po kodzie lub nazwie';

  @override
  String get currencySuggested => 'Polecane';

  @override
  String get currencyAll => 'Wszystkie waluty';

  @override
  String currencyUseTyped(String code) {
    return 'Użyj $code';
  }

  @override
  String get currencyNoMatch => 'Nie znaleziono waluty. Wpisz jej trzyliterowy kod, aby jej użyć.';

  @override
  String get groupSymbol => 'Symbol';

  @override
  String get groupSymbolChoose => 'Wybierz symbol';

  @override
  String groupSymbolExample(String example) {
    return 'Kwoty będą wyglądać tak: $example';
  }

  @override
  String get groupColor => 'Kolor';

  @override
  String colorSwatch(int number, int count) {
    return 'Kolor $number z $count';
  }

  @override
  String get groupPeople => 'Osoby';

  @override
  String get groupYourName => 'Twoje imię';

  @override
  String groupPersonName(int number) {
    return 'Osoba $number';
  }

  @override
  String get groupAddPerson => 'Dodaj osobę';

  @override
  String get groupPeopleHelp => 'Później możesz dodać kolejne osoby. Mogą też dołączyć za pomocą linku.';

  @override
  String get identityTitle => 'Kim jesteś?';

  @override
  String get identityBody =>
      'Wybierz swoje imię, aby Balnana pokazywała, ile masz do zapłaty. Zapamięta je tylko to urządzenie.';

  @override
  String get identityNew => 'Jestem nową osobą';

  @override
  String get identityNewTitle => 'Dołącz do tej grupy';

  @override
  String get identityJoin => 'Dołącz';

  @override
  String get identityChange => 'Twoja tożsamość';

  @override
  String get identityNone => 'Jeszcze nie wybrano';

  @override
  String get memberName => 'Imię';

  @override
  String memberYou(String name) {
    return '$name (Ty)';
  }

  @override
  String get memberAdd => 'Dodaj osobę';

  @override
  String get memberAddTitle => 'Dodaj osobę';

  @override
  String get memberRename => 'Zmień imię';

  @override
  String get memberRenameTitle => 'Zmień imię';

  @override
  String memberRemoveTitle(String name) {
    return 'Usunąć osobę $name?';
  }

  @override
  String get memberRemoveBody =>
      'Pozostanie przy wcześniejszych wydatkach, ale nie będzie można dodawać jej do nowych.';

  @override
  String get groupLinkCopied => 'Link skopiowany. Każda osoba, która go ma, może otworzyć tę grupę.';

  @override
  String get groupShare => 'Udostępnij link';

  @override
  String get groupSettings => 'Ustawienia grupy';

  @override
  String get groupEdit => 'Edytuj grupę';

  @override
  String get groupSharing => 'Udostępnianie';

  @override
  String get groupCopyLink => 'Kopiuj link';

  @override
  String get groupQrCode => 'Pokaż kod QR';

  @override
  String get groupQrCodeHelp => 'Pozwól innym zeskanować link aparatem w telefonie.';

  @override
  String groupQrLabel(String group) {
    return 'Kod QR linku do grupy $group';
  }

  @override
  String get groupCopyLinkHelp => 'Każda osoba mająca link może wyświetlać i edytować tę grupę.';

  @override
  String get groupCopyLinkHelpAccounts => 'Osoby z linkiem mogą poprosić o dołączenie po zalogowaniu.';

  @override
  String get linkAccessTitle => 'Dostęp dla każdej osoby z linkiem';

  @override
  String get linkAccessHelp => 'Pozwól wyświetlać i edytować bez konta';

  @override
  String get resetLinkTitle => 'Zresetuj link';

  @override
  String get resetLinkHelp => 'Utwórz nowy link. Stary przestanie działać.';

  @override
  String get resetLinkBody =>
      'Obecny link przestanie działać dla wszystkich. Udostępnij nowy link osobom, które mają zachować dostęp.';

  @override
  String get resetLinkAction => 'Resetuj';

  @override
  String get resetLinkDone => 'Link zresetowany. Udostępnij nowy.';

  @override
  String get groupThisDevice => 'To urządzenie';

  @override
  String get groupData => 'Dane';

  @override
  String get categoriesTitle => 'Kategorie';

  @override
  String get categoriesHelp => 'Dodaj własne kategorie lub ukryj te, których nie używasz.';

  @override
  String get categoriesOwn => 'Własne tej grupy';

  @override
  String get categoriesOwnEmpty => 'Ta grupa nie ma jeszcze własnych kategorii.';

  @override
  String get categoriesBuiltIn => 'Wbudowane';

  @override
  String get categoriesBuiltInHelp =>
      'Ukryte kategorie nie pojawiają się przy dodawaniu wydatków. Wcześniejsze wydatki nadal będą z nich korzystać.';

  @override
  String get categoryAdd => 'Dodaj kategorię';

  @override
  String get categoryEdit => 'Edytuj kategorię';

  @override
  String get categoryName => 'Nazwa';

  @override
  String get categoryDelete => 'Usuń kategorię';

  @override
  String categoryDeleteTitle(String name) {
    return 'Usunąć kategorię $name?';
  }

  @override
  String get categoryDeleteBody => 'Wydatki w tej kategorii nie będą miały kategorii.';

  @override
  String get categoryDeleteAction => 'Usuń';

  @override
  String get exportCsv => 'Eksportuj jako CSV';

  @override
  String get exportCsvHelp => 'Wszystkie wydatki i płatności do arkusza kalkulacyjnego';

  @override
  String get exportCsvDone => 'Wyeksportowano';

  @override
  String get forgetTitle => 'Usuń z tego urządzenia';

  @override
  String get forgetHelp => 'Grupa pozostanie na serwerze dla pozostałych osób.';

  @override
  String get forgetBody => 'Możesz ponownie ją otworzyć za pomocą linku.';

  @override
  String get groupYou => 'Ty';

  @override
  String get leaveTitle => 'Opuść grupę';

  @override
  String get leaveHelp => 'Twoje wydatki pozostaną. Możesz dołączyć ponownie za pomocą linku.';

  @override
  String get leaveBody => 'Grupa zniknie z Twojej listy. Twoje wydatki i saldo pozostaną w grupie.';

  @override
  String get leaveAction => 'Opuść';

  @override
  String get tabExpenses => 'Wydatki';

  @override
  String get heroWhoTitle => 'Kim jesteś w tej grupie?';

  @override
  String get heroWhoBody => 'Wybierz swoje imię, aby zobaczyć, ile masz do zapłaty i ile masz do odebrania.';

  @override
  String get heroWhoAction => 'Wybierz';

  @override
  String get heroJoinTitle => 'Przeglądasz tę grupę';

  @override
  String get heroJoinBody => 'Dołącz, aby dodawać wydatki i sprawdzać swoje saldo.';

  @override
  String get joinAction => 'Dołącz';

  @override
  String get heroOwed => 'Masz do odebrania';

  @override
  String get heroOwe => 'Masz do zapłaty';

  @override
  String get heroSettled => 'Wszystko rozliczone';

  @override
  String heroYouAre(String name) {
    return 'Jesteś: $name';
  }

  @override
  String get expenseAdd => 'Dodaj wydatek';

  @override
  String get expensesEmptyTitle => 'Nie ma jeszcze wydatków';

  @override
  String get expensesEmptyBody => 'Dodaj pierwszy wydatek, a Balnana obliczy, kto komu jest winien.';

  @override
  String get expensesSearchHint => 'Szukaj tytułów, notatek i miejsc';

  @override
  String get searchClear => 'Wyczyść wyszukiwanie';

  @override
  String get expensesNoMatchTitle => 'Brak wyników';

  @override
  String get expensesNoMatchBody => 'Spróbuj użyć innych słów lub zmniejszyć liczbę filtrów.';

  @override
  String get filterAnyone => 'Każdy';

  @override
  String get filterAnyCategory => 'Dowolna kategoria';

  @override
  String get filterPayments => 'Płatności';

  @override
  String get filterClear => 'Wyczyść filtry';

  @override
  String get periodAll => 'Cały okres';

  @override
  String get periodThisMonth => 'Ten miesiąc';

  @override
  String get periodLastMonth => 'Poprzedni miesiąc';

  @override
  String get periodThisYear => 'Ten rok';

  @override
  String get periodPickDays => 'Wybierz daty…';

  @override
  String get statsTitle => 'Wydatki';

  @override
  String get statsTotal => 'Łącznie wydano';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wydatku',
      many: '$count wydatków',
      few: '$count wydatki',
      two: '$count wydatki',
      one: '1 wydatek',
    );
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'Według kategorii';

  @override
  String get statsByMember => 'Zapłacono i udział na osobę';

  @override
  String get statsPaid => 'Zapłacono';

  @override
  String get statsShare => 'Udział';

  @override
  String get statsByMonth => 'Według miesiąca';

  @override
  String get statsNoCategory => 'Bez kategorii';

  @override
  String get statsEmptyTitle => 'Brak wydatków';

  @override
  String get statsEmptyBody => 'W tym okresie nie ma żadnych wydatków.';

  @override
  String get statsShowExpenses => 'Pokaż te wydatki';

  @override
  String get dateToday => 'Dzisiaj';

  @override
  String get dateYesterday => 'Wczoraj';

  @override
  String paymentTitle(String from, String to) {
    return '$from zapłacił(a) $to';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name zapłacił(a) $amount';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osoby zapłaciły $amount',
      many: '$count osób zapłaciło $amount',
      few: '$count osoby zapłaciły $amount',
      two: '$count osoby zapłaciły $amount',
      one: '$count osób zapłaciło $amount',
    );
    return '$_temp0';
  }

  @override
  String expensePaidByName(String name) {
    return '$name zapłacił(a)';
  }

  @override
  String expensePaidByManyNames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osoby zapłaciły',
      many: '$count osób zapłaciło',
      few: '$count osoby zapłaciły',
      two: '$count osoby zapłaciły',
      one: '$count osób zapłaciło',
    );
    return '$_temp0';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name otrzymał(a) $amount';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$name otrzymał(a)';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osoby otrzymały',
      many: '$count osób otrzymało',
      few: '$count osoby otrzymały',
      two: '$count osoby otrzymały',
      one: '$count osób otrzymało',
    );
    return '$_temp0';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osoby otrzymały $amount',
      many: '$count osób otrzymało $amount',
      few: '$count osoby otrzymały $amount',
      two: '$count osoby otrzymały $amount',
      one: '$count osób otrzymało $amount',
    );
    return '$_temp0';
  }

  @override
  String get transactionRefund => 'Zwrot';

  @override
  String get transactionIncome => 'Przychód';

  @override
  String get paymentDelete => 'Usuń płatność';

  @override
  String get paymentDeleted => 'Płatność usunięta';

  @override
  String expenseDeleted(String title) {
    return 'Usunięto „$title”';
  }

  @override
  String get expenseNew => 'Nowy wydatek';

  @override
  String get expenseEdit => 'Edytuj wydatek';

  @override
  String get expenseDelete => 'Usuń';

  @override
  String get expenseAmount => 'Kwota';

  @override
  String get expenseTitle => 'Na co to było?';

  @override
  String get expenseTitleHint => 'Kolacja, bilety, taksówka…';

  @override
  String get expenseAmountFromPayers => 'Suma kwot zapłaconych przez wszystkich';

  @override
  String expensePaidIn(String currency) {
    return 'Zapłacono w walucie $currency';
  }

  @override
  String expenseRate(String from, String to) {
    return '1 $from w $to';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return 'Suma w walucie $currency';
  }

  @override
  String expenseForeignHelp(String currency) {
    return 'Saldo pozostaje w walucie $currency. Wpisz kurs albo przeliczoną kwotę, na przykład z wyciągu z karty.';
  }

  @override
  String get expenseNote => 'Notatka';

  @override
  String get expenseNoteHint => 'Opcjonalnie';

  @override
  String get expenseLocation => 'Miejsce';

  @override
  String get expenseLocationHint => 'Gdzie to było? (opcjonalnie)';

  @override
  String get locationPickOnMap => 'Wybierz na mapie';

  @override
  String get locationUseCurrent => 'Użyj bieżącej lokalizacji';

  @override
  String get locationFinding => 'Ustalanie lokalizacji…';

  @override
  String get locationChange => 'Zmień na mapie';

  @override
  String get locationRemovePin => 'Usuń pinezkę';

  @override
  String get locationOpenInMaps => 'Otwórz w mapach';

  @override
  String get locationPickTitle => 'Wybierz lokalizację';

  @override
  String get locationPickHint => 'Dotknij mapy, aby dodać pinezkę';

  @override
  String get locationPickDone => 'Gotowe';

  @override
  String get locationDenied =>
      'Balnana nie ma dostępu do Twojej lokalizacji. Możesz go włączyć w ustawieniach urządzenia lub przeglądarki.';

  @override
  String get locationOff => 'Lokalizacja jest wyłączona na tym urządzeniu.';

  @override
  String get locationUnavailable =>
      'Nie udało się ustalić Twojej lokalizacji. Spróbuj ponownie lub dodaj pinezkę na mapie.';

  @override
  String get expenseReceipt => 'Paragon';

  @override
  String get expenseHasReceipt => 'Ma zdjęcie paragonu';

  @override
  String get expenseHasLocation => 'Ma lokalizację';

  @override
  String get receiptTakePhoto => 'Zrób zdjęcie';

  @override
  String get receiptChoose => 'Wybierz zdjęcie';

  @override
  String get receiptRemove => 'Usuń';

  @override
  String get receiptView => 'Zdjęcie paragonu';

  @override
  String receiptNotSaved(String reason) {
    return 'Wydatek został zapisany, ale zdjęcie paragonu nie. $reason';
  }

  @override
  String get expensePaidByLabel => 'Zapłacił(a)';

  @override
  String get expenseReceivedForLabel => 'Otrzymano za';

  @override
  String get expenseReceivedByLabel => 'Otrzymał(a)';

  @override
  String get expenseMultiplePayers => 'Kilka osób';

  @override
  String get expenseSplit => 'Podział';

  @override
  String get splitEqual => 'Po równo';

  @override
  String get splitExact => 'Kwoty';

  @override
  String get splitShares => 'Udziały';

  @override
  String splitLeft(String amount) {
    return 'Pozostało do przydzielenia: $amount';
  }

  @override
  String splitOver(String amount) {
    return 'Za dużo o $amount';
  }

  @override
  String get conflictTitle => 'Zmiana wprowadzona gdzie indziej';

  @override
  String get conflictReload => 'Odśwież';

  @override
  String get expenseChangedElsewhere =>
      'Ktoś inny zmienił ten wydatek. Po odświeżeniu zobaczysz jego wersję, a Twoje zmiany zostaną odrzucone.';

  @override
  String get suggestedPayments => 'Proponowane przelewy';

  @override
  String get allSettled => 'Wszyscy są rozliczeni.';

  @override
  String transferYouPay(String name) {
    return 'Ty płacisz $name';
  }

  @override
  String transferPaysYou(String name) {
    return '$name płaci Tobie';
  }

  @override
  String transferPays(String from, String to) {
    return '$from płaci $to';
  }

  @override
  String get recordPayment => 'Zapisz';

  @override
  String get recordPaymentTitle => 'Zapisz płatność';

  @override
  String get recordPaymentHelp => 'Zapisuj tylko płatności faktycznie wykonane poza Balnana.';

  @override
  String get paymentRecorded => 'Płatność zapisana';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who utworzył(a) grupę $group';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who zmienił(a) szczegóły grupy';
  }

  @override
  String activityLinkReset(String who) {
    return '$who zresetował(a) link do grupy';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who dodał(a) osobę $name';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who zmienił(a) imię $oldName na $name';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who usunął(a) osobę $name';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who dodał(a) kategorię $name';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who zmienił(a) kategorie';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who usunął(a) kategorię $name';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name dołączył(a)';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who dodał(a) wydatek „$title” ($amount)';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who edytował(a) wydatek „$title” ($amount)';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who usunął(a) wydatek „$title”';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who przywrócił(a) wydatek „$title”';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who zapisał(a), że $from zapłacił(a) $to $amount';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who usunął(a) płatność na kwotę $amount';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who przywrócił(a) płatność na kwotę $amount';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wpisu',
      many: '$count wpisów',
      few: '$count wpisy',
      two: '$count wpisy',
      one: '1 wpis',
    );
    return '$who zaimportował(a) $_temp0 z $source';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who dodał(a) zdjęcie paragonu do „$title”';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who usunął(a) zdjęcie paragonu z „$title”';
  }

  @override
  String activityOther(String who) {
    return '$who wprowadził(a) zmianę';
  }

  @override
  String get navGroups => 'Grupy';

  @override
  String get navActivity => 'Aktywność';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get groupsEmptyTitle => 'Nie ma jeszcze grup';

  @override
  String get groupsEmptyBody => 'Tutaj pojawią się utworzone grupy i grupy otwarte za pomocą linku.';

  @override
  String get groupsNoServerTitle => 'Połącz się z serwerem';

  @override
  String get groupsNoServerBody =>
      'Balnana przechowuje Twoje grupy na wybranym serwerze, na przykład własnym.';

  @override
  String get groupsNoServerAction => 'Wybierz serwer';

  @override
  String get groupsUnreachableTitle => 'Nie można połączyć się z serwerem';

  @override
  String get groupsUnreachableBody => 'Sprawdź połączenie lub adres serwera w Ustawieniach.';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nie udało się wczytać $count grupy, więc brakuje ich zmian.',
      many: 'Nie udało się wczytać $count grup, więc brakuje ich zmian.',
      few: 'Nie udało się wczytać $count grup, więc brakuje ich zmian.',
      two: 'Nie udało się wczytać $count grup, więc brakuje ich zmian.',
      one: 'Nie udało się wczytać 1 grupy, więc brakuje jej zmian.',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => 'Nic tu jeszcze nie ma';

  @override
  String get activityEmptyBody => 'Tutaj pojawią się nowe wydatki i płatności w Twoich grupach.';

  @override
  String get notFoundTitle => 'Nie znaleziono strony';

  @override
  String get notFoundBody => 'Ten adres nie prowadzi do żadnego miejsca w Balnana.';

  @override
  String get notFoundAction => 'Przejdź do grup';

  @override
  String get settingsAppearance => 'Wygląd';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get accountRename => 'Zmień imię';

  @override
  String get passwordChange => 'Zmień hasło';

  @override
  String get passwordChanged => 'Hasło zmienione. Wylogowano z innych urządzeń.';

  @override
  String get passwordSet => 'Ustaw hasło';

  @override
  String get passwordSetHelp => 'Loguj się adresem e-mail lub nazwą użytkownika oraz hasłem.';

  @override
  String get passwordSetDone => 'Hasło ustawione. Wylogowano z innych urządzeń.';

  @override
  String get passwordCurrent => 'Obecne hasło';

  @override
  String get passwordNew => 'Nowe hasło';

  @override
  String get signOut => 'Wyloguj się';

  @override
  String get accountOAuthLinked => 'Służy do logowania na to konto. Dotknij, aby usunąć.';

  @override
  String get accountOAuthAdd => 'Dodaj metodę logowania';

  @override
  String accountOAuthAddTitle(String name) {
    return 'Dodaj $name';
  }

  @override
  String accountOAuthAdded(String name) {
    return 'Możesz już logować się przez $name.';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return 'Usunąć $name?';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return 'Nie będzie można logować się przez $name, dopóki nie dodasz go ponownie.';
  }

  @override
  String get accountOAuthRemove => 'Usuń';

  @override
  String accountOAuthRemoved(String name) {
    return 'Usunięto $name.';
  }

  @override
  String get confirmEmailTitle => 'Potwierdź adres e-mail';

  @override
  String confirmEmailBody(String email) {
    return 'Ten serwer wymaga potwierdzenia adresu e-mail. Otwórz link wysłany na adres $email.';
  }

  @override
  String get confirmEmailDone => 'Potwierdzam';

  @override
  String get confirmEmailResend => 'Wyślij link ponownie';

  @override
  String get confirmEmailNotYet => 'Adres nie został jeszcze potwierdzony. Otwórz link z wiadomości e-mail.';

  @override
  String get settingsTheme => 'Motyw';

  @override
  String get themeSystem => 'Domyślny systemowy';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get settingsDynamicColor => 'Kolory tapety';

  @override
  String get settingsDynamicColorSubtitle => 'Używaj kolorów z urządzenia zamiast żółtego Balnana';

  @override
  String get settingsWallpaperGroups => 'Kolory tapety w grupach';

  @override
  String get settingsWallpaperGroupsSubtitle => 'Grupy też będą używać kolorów z urządzenia zamiast własnych';

  @override
  String get settingsPureBlack => 'Czysta czerń';

  @override
  String get settingsPureBlackSubtitle => 'Ciemniejszy motyw dla ekranów OLED';

  @override
  String get settingsMyShare => 'Pokaż mój udział';

  @override
  String get settingsMyShareSubtitle => 'Wydatki pokazują kwotę pożyczki lub długu zamiast całej sumy.';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get languageSystem => 'Domyślny systemowy';

  @override
  String get settingsNotifications => 'Powiadomienia';

  @override
  String get settingsNotificationsSubtitle =>
      'Gdy ktoś doda, zmieni lub usunie wydatek, w którym uczestniczysz';

  @override
  String get settingsNotificationsBlocked =>
      'Zablokowane w ustawieniach telefonu. Włącz tam powiadomienia Balnana, aby je otrzymywać.';

  @override
  String get pushChannel => 'Wydatki';

  @override
  String get pushChannelDescription => 'Gdy ktoś doda, zmieni lub usunie wydatek, w którym uczestniczysz';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who dodał(a) $title · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who zmienił(a) $title · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who usunął(a) $title · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return 'Dodano $title · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return 'Zmieniono $title · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return 'Usunięto $title · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payer zapłacił(a) $payee $amount';
  }

  @override
  String get settingsConnection => 'Połączenie';

  @override
  String get settingsServer => 'Serwer';

  @override
  String get serverNotSet => 'Nie ustawiono';

  @override
  String get settingsAbout => 'O aplikacji';

  @override
  String get aboutVersion => 'Wersja';

  @override
  String get aboutLicenses => 'Licencje open source';

  @override
  String get aboutSource => 'Kod źródłowy';

  @override
  String get aboutSourceCopied => 'Nie udało się otworzyć przeglądarki, więc link został skopiowany';

  @override
  String get serverTitle => 'Serwer';

  @override
  String get serverIntro =>
      'Wpisz adres serwera Balnana. Każdy może go uruchomić; zazwyczaj jest to adres strony internetowej serwera.';

  @override
  String get serverUrlLabel => 'Adres serwera';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => 'Testuj połączenie';

  @override
  String get serverSaveAnyway => 'Zapisz mimo to';

  @override
  String get serverReset => 'Przywróć domyślny';

  @override
  String serverDefault(String url) {
    return 'Domyślny: $url';
  }

  @override
  String serverConnected(String version) {
    return 'Połączono z Balnana $version';
  }

  @override
  String get serverModeLink => 'Grupy są udostępniane za pomocą prywatnych linków. Konto nie jest potrzebne.';

  @override
  String get serverModeAccounts => 'Użytkownicy logują się na swoje konta.';

  @override
  String get serverInsecure =>
      'To połączenie nie jest szyfrowane (http). Inne osoby w sieci mogą odczytać Twoje dane. Poza siecią domową używaj serwerów z https.';

  @override
  String get serverErrorInvalid => 'Wpisz adres strony internetowej, na przykład balnana.example.com';

  @override
  String get serverErrorUnreachable => 'Nie udało się połączyć. Sprawdź adres i czy serwer działa.';

  @override
  String get serverErrorNotBalnana => 'Serwer odpowiedział, ale nie jest to serwer Balnana.';

  @override
  String get serverSaved => 'Serwer zapisany';

  @override
  String get signIn => 'Zaloguj się';

  @override
  String get groupSignInTitle => 'Zaloguj się, aby otworzyć tę grupę';

  @override
  String get groupSignInBody =>
      'Ta grupa jest tylko dla jej członków. Zaloguj się, aby ją zobaczyć lub do niej dołączyć.';

  @override
  String get signInTitle => 'Witaj ponownie';

  @override
  String get signInBody => 'Zaloguj się, aby zobaczyć swoje grupy.';

  @override
  String get signInNoPassword => 'Ten serwer umożliwia logowanie w inny sposób. Zapytaj jego administratora.';

  @override
  String get registerTitle => 'Utwórz konto';

  @override
  String get registerBody => 'Miej swoje grupy na każdym urządzeniu.';

  @override
  String get registerAction => 'Utwórz konto';

  @override
  String get registerHaveAccount => 'Mam już konto';

  @override
  String get signInNoAccount => 'Utwórz konto';

  @override
  String get accountName => 'Twoje imię';

  @override
  String get accountNameHelp => 'Tak będą Cię widzieć osoby z Twoich grup';

  @override
  String get accountEmail => 'E-mail';

  @override
  String get accountPassword => 'Hasło';

  @override
  String get accountPasswordHelp => 'Co najmniej 8 znaków';

  @override
  String get passwordShow => 'Pokaż hasło';

  @override
  String get passwordHide => 'Ukryj hasło';

  @override
  String get joinPickName => 'Wybierz inne imię';

  @override
  String joinTitle(String name) {
    return 'Dołącz do grupy $name';
  }

  @override
  String get joinBody => 'Czy jesteś jedną z tych osób? Wybierz siebie, aby przejąć jej wydatki.';

  @override
  String get joinBodyNew => 'Dołącz, aby dodawać wydatki i sprawdzać swoje saldo.';

  @override
  String get joinAsNew => 'Jestem nową osobą';

  @override
  String joinAsName(String name) {
    return 'Dołącz jako $name';
  }

  @override
  String joinTaken(String names) {
    return 'Już dołączyły: $names';
  }

  @override
  String joinTakenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dołączyło już $count osób.',
      many: 'Dołączyło już $count osób.',
      few: 'Dołączyły już $count osoby.',
      two: 'Dołączyły już $count osoby.',
      one: 'Dołączyła już 1 osoba.',
    );
    return '$_temp0';
  }

  @override
  String get commonContinue => 'Dalej';

  @override
  String get errorEmailOff => 'Ten serwer nie wysyła e-maili.';

  @override
  String get errorInvalidToken => 'Ten link wygasł albo został już użyty.';

  @override
  String get forgotPasswordTitle => 'Nie pamiętasz hasła?';

  @override
  String get forgotPasswordBody => 'Wyślemy Ci link do ustawienia nowego hasła.';

  @override
  String get forgotPasswordAction => 'Wyślij link';

  @override
  String get forgotPasswordSent => 'Jeśli istnieje konto z tym adresem, link jest już w drodze.';

  @override
  String get resetPasswordTitle => 'Ustaw nowe hasło';

  @override
  String get resetPasswordBody =>
      'Nastąpi wylogowanie ze wszystkich urządzeń. Potem możesz zalogować się nowym hasłem.';

  @override
  String get resetPasswordAction => 'Zapisz hasło';

  @override
  String get resetPasswordDone => 'Hasło zmienione. Zaloguj się nowym hasłem.';

  @override
  String get verifyEmailTitle => 'Potwierdź adres e-mail';

  @override
  String get verifyEmailHelp => 'Dzięki temu zresetujesz hasło, jeśli go zapomnisz';

  @override
  String verifyEmailSent(String email) {
    return 'Sprawdź, czy na adres $email dotarł link.';
  }

  @override
  String get verifyEmailDone => 'Adres e-mail potwierdzony';

  @override
  String get verifyEmailDoneBody => 'Dziękujemy! Twój adres został potwierdzony.';

  @override
  String get verifyEmailFailed => 'Nie udało się potwierdzić adresu e-mail';

  @override
  String get inviteByEmail => 'Zaproś e-mailem';

  @override
  String get inviteByEmailHelp => 'Wyślij komuś link do grupy';

  @override
  String get inviteAs => 'Dołącz jako';

  @override
  String get inviteAsHelp => 'Zaproszona osoba może przejąć wydatki tego członka grupy.';

  @override
  String get inviteAsAnyone => 'Nowa osoba';

  @override
  String get inviteSend => 'Wyślij zaproszenie';

  @override
  String inviteSent(String email) {
    return 'Zaproszenie wysłano na adres $email.';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name zaprasza Cię do grupy $group';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return 'Zaproszono Cię do grupy $group';
  }

  @override
  String inviteBody(String email) {
    return 'Utwórz konto na adres $email, aby dołączyć, lub zaloguj się, jeśli już je masz.';
  }

  @override
  String get inviteBodySignedIn => 'Dołącz, aby dodawać wydatki i sprawdzać swoje saldo.';

  @override
  String get inviteAction => 'Otwórz zaproszenie';

  @override
  String get inviteMissingTitle => 'To zaproszenie nie działa';

  @override
  String get inviteMissingBody => 'Mogło wygasnąć albo zostać użyte. Poproś o nowe.';

  @override
  String get joinInvitedAs => 'Zaproszono Cię jako tę osobę';

  @override
  String signInWith(String provider) {
    return 'Kontynuuj przez $provider';
  }

  @override
  String get signInOr => 'lub';

  @override
  String get oauthFailedTitle => 'Nie udało się zalogować';

  @override
  String get oauthPendingTitle => 'To konto ma już ten adres e-mail';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider potwierdza, że adres $email należy do Ciebie, ale konto z tym adresem nie zostało potwierdzone. Co zrobić?';
  }

  @override
  String get oauthPendingLink => 'Dodaj do tego konta';

  @override
  String get oauthPendingLinkHelp => 'Wpisz hasło do tego konta. Nadal będzie można logować się tym hasłem.';

  @override
  String get oauthPendingTakeOver => 'Przejmij to konto';

  @override
  String get oauthPendingTakeOverHelp =>
      'Hasło i inne metody logowania zostaną usunięte, a wszyscy użytkownicy zostaną wylogowani.';

  @override
  String get oauthPendingNew => 'Utwórz nowe konto';

  @override
  String oauthPendingNewHelp(String email) {
    return 'Drugie konto zachowa swoje grupy, ale nie będzie już mieć adresu $email.';
  }

  @override
  String get oauthPendingPassword => 'Hasło do tego konta';

  @override
  String get oauthPendingWrongPassword => 'To hasło jest nieprawidłowe.';

  @override
  String get oauthOtherServer =>
      'Logowanie rozpoczęto na innym serwerze niż obecnie wybrany. Zaloguj się ponownie.';

  @override
  String get oauthBackToSignIn => 'Wróć do logowania';

  @override
  String get errorOAuthFailed => 'Nie udało się zalogować. Spróbuj ponownie.';

  @override
  String get errorEmailHasAccount =>
      'Konto z tym adresem e-mail już istnieje. Zaloguj się na nie, a potem dodaj tę metodę logowania w Ustawieniach.';

  @override
  String get errorIdentityTaken => 'Ta metoda logowania jest już przypisana do innego konta.';

  @override
  String get errorLastSignInMethod =>
      'To jedyna metoda logowania do Twojego konta. Najpierw ustaw hasło lub dodaj inną metodę.';

  @override
  String get errorEmailUnverified => 'Najpierw potwierdź swój adres e-mail.';

  @override
  String get errorOAuthCancelled => 'Logowanie zostało anulowane.';

  @override
  String get importTitle => 'Importuj z Settle Up';

  @override
  String get importAction => 'Importuj';

  @override
  String get importIntro =>
      'W Settle Up wyeksportuj grupę do pliku CSV, a następnie wybierz go tutaj. Zostaną przeniesione wydatki, płatności i wszystkie osoby z grupy, a salda pozostaną takie same.';

  @override
  String get importChooseFile => 'Wybierz plik CSV';

  @override
  String get importChooseOther => 'Wybierz inny plik';

  @override
  String get importReading => 'Odczytywanie pliku…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(
      expenses,
      locale: localeName,
      other: '$expenses wydatku',
      many: '$expenses wydatków',
      few: '$expenses wydatki',
      two: '$expenses wydatki',
      one: '1 wydatek',
    );
    String _temp1 = intl.Intl.pluralLogic(
      payments,
      locale: localeName,
      other: '$payments płatności',
      many: '$payments płatności',
      few: '$payments płatności',
      two: '$payments płatności',
      one: '1 płatność',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return '$from–$to';
  }

  @override
  String importCurrency(String currency) {
    return 'Waluta: $currency. Wpisy w innych walutach używają kwot przeliczonych przez Settle Up.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pominięto $count wpisu o wartości zero.',
      many: 'Pominięto $count wpisów o wartości zero.',
      few: 'Pominięto $count wpisy o wartości zero.',
      two: 'Pominięto $count wpisy o wartości zero.',
      one: 'Pominięto 1 wpis o wartości zero.',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => 'Którą osobą jesteś?';

  @override
  String get importUntitled => 'Bez tytułu';

  @override
  String get errorImportFile => 'To nie wygląda na plik CSV wyeksportowany z Settle Up.';

  @override
  String get errorImportCurrency =>
      'Plik nie zawiera wpisów bez kursu wymiany, więc nie można ustalić waluty grupy.';

  @override
  String get errorImportTooBig => 'Ten plik jest za duży, aby go zaimportować.';

  @override
  String get errorBadImage => 'Nie można użyć tego zdjęcia. Wybierz JPEG, PNG lub WebP.';

  @override
  String get errorReceiptTooBig => 'To zdjęcie jest za duże. Wybierz plik mniejszy niż 10 MB.';

  @override
  String get errorImportMe => 'Wybierz, którą osobą jesteś.';

  @override
  String errorImportRow(int line, String reason) {
    return 'Nie można zaimportować wiersza $line z pliku: $reason';
  }

  @override
  String get errorImportAmount => 'nie można odczytać kwoty.';

  @override
  String get errorImportCounts => 'nazwy i kwoty nie są zgodne.';

  @override
  String get errorImportDate => 'nie można odczytać daty.';

  @override
  String get errorImportType => 'typ nie jest wydatkiem, przelewem ani przychodem.';

  @override
  String get errorImportTransfer => 'przelew wymaga jednej osoby płacącej drugiej.';

  @override
  String get errorImportRowCurrency => 'wpis jest w innej walucie i nie ma kursu wymiany.';

  @override
  String get adminSetupTitle => 'Skonfiguruj ten serwer';

  @override
  String get adminSetupBody =>
      'Ustaw hasło administratora. Chroni ono stronę z ustawieniami serwera. Nie ma nazwy użytkownika: ustawienia może zmienić każda osoba znająca hasło.';

  @override
  String get adminSetupCode => 'Kod konfiguracji';

  @override
  String get adminSetupCodeHelp =>
      'Na tym serwerze są już dane, dlatego po uruchomieniu kod konfiguracji pojawił się w logu. W Dockerze: docker compose logs balnana';

  @override
  String get adminSetupAction => 'Ustaw hasło';

  @override
  String get adminPassword => 'Hasło administratora';

  @override
  String get adminPasswordRepeat => 'Powtórz hasło';

  @override
  String get adminPasswordMismatch => 'Hasła nie są takie same.';

  @override
  String get adminLoginTitle => 'Administracja';

  @override
  String get adminLoginBody => 'Wpisz hasło administratora, aby zmienić ustawienia serwera.';

  @override
  String get adminLoginAction => 'Zaloguj się';

  @override
  String get adminSettingsTitle => 'Ustawienia serwera';

  @override
  String get adminSaved => 'Ustawienia zapisane. Zmiany obowiązują od razu.';

  @override
  String get adminSaveFailed => 'Nie zapisano żadnych zmian. Sprawdź wyróżnione ustawienia.';

  @override
  String get adminChangePassword => 'Zmień hasło administratora';

  @override
  String get adminPasswordCurrent => 'Obecne hasło';

  @override
  String get adminPasswordNew => 'Nowe hasło';

  @override
  String get adminPasswordChanged => 'Hasło zmienione. Wylogowano z innych sesji administratora.';

  @override
  String get adminSignOut => 'Wyloguj się z administracji';

  @override
  String get adminBackHome => 'Wróć do Balnana';

  @override
  String get adminRequireEmail => 'Wymagaj adresu e-mail';

  @override
  String get adminRequireEmailHelp =>
      'Gdy ta opcja jest wyłączona, można założyć konto z nazwą użytkownika bez adresu e-mail. Logować się można za pomocą jednego z nich.';

  @override
  String get adminRequireEmailUnused =>
      'Dotyczy tylko logowania adresem e-mail i hasłem, które jest wyłączone.';

  @override
  String get accountUsername => 'Nazwa użytkownika';

  @override
  String get accountUsernameHelp =>
      'Od 3 do 32 liter, cyfr, kropek, myślników lub podkreśleń. Służy do logowania.';

  @override
  String get accountEmailOptional => 'E-mail (opcjonalnie)';

  @override
  String get accountEmailOptionalHelp =>
      'Umożliwia odbieranie zaproszeń do grup i resetowanie zapomnianego hasła.';

  @override
  String get accountLogin => 'E-mail lub nazwa użytkownika';

  @override
  String get errorInvalidUsername =>
      'Użyj od 3 do 32 liter, cyfr, kropek, myślników lub podkreśleń. Zacznij od litery lub cyfry.';

  @override
  String get errorUsernameTaken => 'Ktoś już używa tej nazwy użytkownika.';

  @override
  String get adminDiscardTitle => 'Odrzucić zmiany?';

  @override
  String get adminDiscardBody => 'Zmiany w ustawieniach nie zostały zapisane.';

  @override
  String get adminDiscard => 'Odrzuć';

  @override
  String adminLocked(String key) {
    return 'Ustawione na serwerze przez $key';
  }

  @override
  String adminDefault(String value) {
    return 'Domyślnie: $value';
  }

  @override
  String get adminSecretSaved => 'Zapisano. Wpisz nową wartość, aby ją zastąpić.';

  @override
  String get adminSecretRemoved => 'Zostanie usunięte po zapisaniu.';

  @override
  String get adminSecretRemove => 'Usuń zapisaną wartość';

  @override
  String get adminSectionGeneral => 'Ogólne';

  @override
  String get adminSectionAccess => 'Dostęp';

  @override
  String get adminSectionMaps => 'Mapy';

  @override
  String get adminSectionAccounts => 'Konta';

  @override
  String get adminSectionAccountsBody => 'Te ustawienia dotyczą trybu dostępu za pomocą kont.';

  @override
  String get adminSectionEmail => 'E-mail (SMTP)';

  @override
  String get adminSectionEmailBody => 'Potwierdzanie adresu, resetowanie haseł i zaproszenia.';

  @override
  String get adminSmtpOn => 'Wysyłaj e-maile';

  @override
  String get adminSectionGoogle => 'Logowanie przez Google';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Dodaj $url jako identyfikator URI przekierowania w konsoli Google Cloud.';
  }

  @override
  String get adminGoogleOn => 'Udostępnij logowanie przez Google';

  @override
  String get adminGoogleOnHelp => 'Użytkownicy logują się na swoje konto Google.';

  @override
  String get adminSectionOidc => 'Logowanie przez OpenID Connect';

  @override
  String adminSectionOidcBody(String url) {
    return 'Dodaj $url jako identyfikator URI przekierowania u dostawcy.';
  }

  @override
  String get adminOidcHelp =>
      'Dowolny dostawca OpenID Connect, na przykład Authentik, Keycloak lub Dex. Możesz dodać ich wielu.';

  @override
  String get adminOidcAdd => 'Dodaj dostawcę';

  @override
  String get adminOidcRemove => 'Usuń dostawcę';

  @override
  String get adminOidcNew => 'Nowy dostawca';

  @override
  String get adminOidcId => 'ID';

  @override
  String get adminOidcIdHelp =>
      'Małe litery, cyfry i myślniki. To część identyfikatora URI przekierowania, której nie można później zmienić.';

  @override
  String get adminOidcIdInvalid =>
      'Użyj małych liter, cyfr i myślników, zacznij od litery lub cyfry; maksymalnie 32 znaki.';

  @override
  String get adminOidcIdTaken => 'Inny dostawca ma już ten identyfikator.';

  @override
  String get adminTrustEmail => 'Ufaj jego adresom e-mail';

  @override
  String get adminGoogleTrustEmailHelp =>
      'Logowanie przez Google z adresem e-mail przypisanym do konta prowadzi do tego konta. Po wyłączeniu tej opcji trzeba zalogować się hasłem i dodać Google w Ustawieniach.';

  @override
  String get adminOidcTrustEmailHelp =>
      'Tylko dla dostawcy, któremu ufasz w kwestii weryfikacji adresów e-mail. Po wyłączeniu tej opcji użytkownicy z kontem logują się hasłem i dodają dostawcę w Ustawieniach.';

  @override
  String get adminRequireVerified => 'Wymagaj potwierdzonego adresu e-mail';

  @override
  String get adminRequireVerifiedHelp =>
      'Nie można korzystać z konta, dopóki adres e-mail nie zostanie potwierdzony. Zaufana metoda logowania z tym samym adresem przejmuje niepotwierdzone konto. Po wyłączeniu użytkownik decyduje, co zrobić.';

  @override
  String get adminRequireVerifiedUnused => 'Wymaga wysyłania e-maili.';

  @override
  String get adminSectionAndroid => 'Linki aplikacji na Androida';

  @override
  String get adminSectionAndroidBody =>
      'Linki serwera otwierają aplikację w wersjach Androida przygotowanych dla tego serwera. Aby pominąć pytanie, wpisz odciski SHA-256 certyfikatów użytych do podpisania tych wersji.';

  @override
  String get adminSectionAdmin => 'Administrator';

  @override
  String get adminPublicUrl => 'Adres publiczny';

  @override
  String get adminPublicUrlHelp =>
      'Adres używany do łączenia się z serwerem. Na jego podstawie tworzone są linki do grup i z wiadomości e-mail.';

  @override
  String get adminSourceUrl => 'Link do kodu źródłowego';

  @override
  String get adminSourceUrlHelp =>
      'Miejsce, z którego można pobrać kod źródłowy serwera, zgodnie z wymogami licencji AGPL-3.0 dla zmodyfikowanej wersji.';

  @override
  String get adminAuthMode => 'Dostęp';

  @override
  String get adminAuthModeLink => 'Linki do grup';

  @override
  String get adminAuthModeLinkHelp => 'Bez logowania: do otwarcia grupy wystarczy jej prywatny link.';

  @override
  String get adminAuthModeAccounts => 'Konta';

  @override
  String get adminAuthModeAccountsHelp =>
      'Użytkownicy logują się na konto, a link pozwala dołączyć do grupy tylko po zalogowaniu.';

  @override
  String get adminPasswordLogin => 'Logowanie e-mailem i hasłem';

  @override
  String get adminPasswordForced =>
      'Ta opcja pozostaje włączona, dopóki nie zostanie włączone logowanie przez Google lub OpenID Connect, aby zawsze była dostępna metoda logowania.';

  @override
  String get adminSignup => 'Kto może założyć konto';

  @override
  String get adminSignupOpen => 'Każdy';

  @override
  String get adminSignupOpenHelp => 'Każdy, kto ma dostęp do tego serwera, może założyć konto.';

  @override
  String get adminSignupInvite => 'Zaproszone osoby';

  @override
  String get adminSignupInviteHelp =>
      'Konto mogą założyć tylko osoby zaproszone do grupy e-mailem i tylko na adres, na który wysłano zaproszenie. Sam link do grupy nie wystarczy. Aby wysyłać zaproszenia, włącz e-maile.';

  @override
  String get adminSignupClosed => 'Nikt';

  @override
  String get adminSignupClosedHelp => 'Nikt nie może zakładać kont. Istniejące konta nadal działają.';

  @override
  String get adminSignupHelp => 'Pierwsze konto można zawsze utworzyć.';

  @override
  String get adminLinkGroups => 'Otwieranie grup za pomocą linku';

  @override
  String get adminLinkGroupsHelp =>
      'Właściciele grup mogą zezwolić każdej osobie z linkiem na dołączenie bez logowania.';

  @override
  String get adminSmtpHost => 'Serwer poczty';

  @override
  String get adminSmtpPort => 'Port';

  @override
  String get adminSmtpUser => 'Nazwa użytkownika';

  @override
  String get adminSmtpPassword => 'Hasło';

  @override
  String get adminSmtpFrom => 'Nadawca';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'ID klienta';

  @override
  String get adminClientSecret => 'Klucz klienta';

  @override
  String get adminOidcIssuer => 'Adres wystawcy';

  @override
  String get adminOidcName => 'Nazwa przycisku';

  @override
  String get adminOidcNameHelp => 'Wyświetlana na stronie logowania jako „Kontynuuj przez…”.';

  @override
  String get adminFingerprints => 'Odciski certyfikatów';

  @override
  String get adminFingerprintsHelp =>
      'SHA-256, oddzielone przecinkami. Wyświetlą je polecenia keytool -list -v i apksigner verify --print-certs.';

  @override
  String get adminInvalidValue => 'Ta wartość jest nieprawidłowa.';

  @override
  String get adminInvalidUrl => 'Wpisz pełny adres zaczynający się od https:// lub http://.';

  @override
  String get adminInvalidFrom =>
      'Wpisz nadawcę, na przykład Balnana <balnana@example.com>; wymagany jest adres e-mail.';

  @override
  String get adminInvalidPort => 'Wpisz numer portu od 1 do 65535.';

  @override
  String get adminInvalidRequired => 'Ten dostawca logowania wymaga tej wartości.';

  @override
  String get adminInvalidFingerprint =>
      'Wpisz odciski SHA-256: po 64 cyfry szesnastkowe, dwukropki są dozwolone.';

  @override
  String get adminNeedsSignIn =>
      'Konta wymagają metody logowania: włącz logowanie e-mailem i hasłem albo skonfiguruj dostawcę.';

  @override
  String get adminLockedChange => 'Ta wartość jest ustawiona na serwerze i nie można jej tutaj zmienić.';

  @override
  String get errorAdminRequired => 'Sesja administratora wygasła. Zaloguj się ponownie.';

  @override
  String get errorAdminWrongPassword => 'To hasło jest nieprawidłowe.';

  @override
  String get errorInvalidSetupCode => 'Ten kod konfiguracji jest nieprawidłowy. Poszukaj go w logu serwera.';

  @override
  String get errorAlreadySetUp => 'Ten serwer jest już skonfigurowany. Zaloguj się hasłem administratora.';

  @override
  String get linkOpening => 'Otwieranie linku…';

  @override
  String get linkForeignTitle => 'Ten link prowadzi do innego serwera';

  @override
  String linkForeignBody(String server) {
    return 'Aplikacja jest połączona z serwerem $server, a ten link prowadzi do innego serwera. Zmień serwer w Ustawieniach, aby go otworzyć.';
  }

  @override
  String get linkInvalidTitle => 'Nie można otworzyć tego linku';

  @override
  String get linkInvalidBody => 'To nie jest znany tej aplikacji link Balnana.';

  @override
  String get linkGoHome => 'Przejdź do grup';

  @override
  String get linkOpenInBrowser => 'Otwórz w przeglądarce';

  @override
  String get privacyTitle => 'Polityka prywatności';

  @override
  String get privacyIntro =>
      'Balnana to oprogramowanie open source. Administrator serwera, z którym łączy się aplikacja, decyduje, gdzie przechowywane są Twoje dane, i odpowiada za nie. Ta strona opisuje, jakie dane przechowuje i jak działa samo oprogramowanie.';

  @override
  String get privacyStoredTitle => 'Jakie dane są przechowywane';

  @override
  String get privacyStoredBody =>
      'Utworzone lub otwarte przez Ciebie grupy: ich nazwy, imiona członków, wydatki, płatności, notatki, zdjęcia paragonów i miejsca dodane do wydatków. W przypadku konta także Twoje imię, adres e-mail lub nazwa użytkownika, skrót hasła (nigdy samo hasło) oraz informacja o używanej metodzie logowania, na przykład Google. Po włączeniu powiadomień przechowywany jest identyfikator urządzenia i adres otrzymany od usługi powiadomień.';

  @override
  String get privacyUseTitle => 'Jak dane są wykorzystywane';

  @override
  String get privacyUseBody =>
      'Tylko do działania aplikacji: wyświetlania grup ich członkom, obliczania sald oraz wysyłania potrzebnych wiadomości e-mail i powiadomień, na przykład potwierdzeń adresu, resetowania haseł i zaproszeń. Aplikacja nie wyświetla reklam, nie zbiera danych analitycznych ani niczego nie sprzedaje.';

  @override
  String get privacySharedTitle => 'Kto może zobaczyć dane';

  @override
  String get privacySharedBody =>
      'Wszyscy członkowie grupy widzą jej osoby, wydatki i historię. Jeśli grupę można otworzyć za pomocą linku, zobaczyć ją może każdy, kto ma link. Logowanie przez Google odbywa się za pośrednictwem Google, a włączone przez administratora powiadomienia przechodzą przez usługę używaną przez telefon: Google Firebase Cloud Messaging lub inną zainstalowaną usługę UnifiedPush, na przykład ntfy. Treść powiadomień jest szyfrowana podczas przesyłania. Mapy pobierają obrazy od wybranego przez administratora dostawcy, domyślnie OpenFreeMap, który widzi Twój adres sieciowy i oglądany obszar. Lokalizacja jest odczytywana tylko po dotknięciu opcji „Użyj bieżącej lokalizacji”; zapisywany jest tylko wybrany punkt.';

  @override
  String get privacyDeviceTitle => 'Na tym urządzeniu';

  @override
  String get privacyDeviceBody =>
      'Aplikacja przechowuje adres serwera, Twoje ustawienia i kopię grup na wypadek braku połączenia. Odinstalowanie aplikacji usuwa te dane.';

  @override
  String get privacyDeleteTitle => 'Usuwanie danych';

  @override
  String get privacyDeleteBody =>
      'Możesz usunąć konto w Ustawieniach. Twoje imię pozostanie w grupach jako osoba bez przypisanego konta, dzięki czemu salda nadal będą się zgadzać. Usunięte zostaną też grupy, do których nikt inny nie ma dostępu. Właściciel grupy może usunąć całą grupę w jej ustawieniach. W innych sprawach skontaktuj się z administratorem serwera.';

  @override
  String get privacyOperatorPolicy => 'Polityka prywatności administratora';

  @override
  String get privacyLink => 'Prywatność';

  @override
  String get accountEmailAdd => 'Dodaj adres e-mail';

  @override
  String get accountEmailChange => 'Zmień adres e-mail';

  @override
  String get accountEmailNew => 'Adres e-mail';

  @override
  String get accountEmailVerifyNote =>
      'Otrzymasz link do potwierdzenia nowego adresu. Obecny adres pozostanie aktywny do tego czasu.';

  @override
  String get accountEmailPendingTitle => 'Potwierdź nowy adres e-mail';

  @override
  String accountEmailPendingHelp(String email) {
    return 'Po otwarciu linku wysłanego na adres $email zastąpi on obecny adres. Dotknij, aby wysłać link ponownie.';
  }

  @override
  String get accountEmailRemoveNote =>
      'Pozostaw puste, aby usunąć adres. Nadal możesz logować się nazwą użytkownika.';

  @override
  String get accountEmailSaved => 'Zapisano adres e-mail';

  @override
  String get accountEmailRemoved => 'Usunięto adres e-mail';

  @override
  String get accountConfirmPassword => 'Twoje hasło';

  @override
  String get accountConfirmPasswordHelp => 'Aby potwierdzić, że to Ty.';

  @override
  String get errorEmailNeeded => 'Logujesz się za pomocą adresu e-mail, więc nie można go usunąć.';

  @override
  String get accountDelete => 'Usuń konto';

  @override
  String get accountDeleteHelp => 'Usuń konto z tego serwera';

  @override
  String get accountDeleteTitle => 'Usunąć konto?';

  @override
  String get accountDeleteBody =>
      'Konto zostanie trwale usunięte i nastąpi wylogowanie. W grupach Twoje imię pozostanie jako osoba bez przypisanego konta, dzięki czemu salda nadal będą się zgadzać. Grupy, w których nikt inny nie uczestniczy, zostaną usunięte.';

  @override
  String get accountDeleteAction => 'Usuń na stałe';

  @override
  String get accountDeleted => 'Twoje konto zostało usunięte.';

  @override
  String get accountDeletePageSignedOut => 'Zaloguj się, aby usunąć konto na tym serwerze.';

  @override
  String get accountDeletePageLinkMode =>
      'Ten serwer nie obsługuje kont: do korzystania z grup wystarczy ich link. Aby usunąć grupę wraz z całą zawartością, otwórz jej ustawienia i wybierz „Usuń grupę”.';

  @override
  String get groupDelete => 'Usuń grupę';

  @override
  String get groupDeleteHelp => 'Usuń ją wraz ze wszystkimi wydatkami u wszystkich osób';

  @override
  String groupDeleteTitle(String name) {
    return 'Usunąć grupę $name?';
  }

  @override
  String get groupDeleteBody =>
      'Grupa oraz wszystkie jej wydatki, płatności i historia zostaną usunięte u wszystkich. Tej czynności nie można cofnąć. Wpisz nazwę grupy, aby potwierdzić.';

  @override
  String get groupDeleteName => 'Nazwa grupy';

  @override
  String get groupDeleteAction => 'Usuń na stałe';

  @override
  String get groupDeleted => 'Grupa usunięta';

  @override
  String get groupDeleteOwnerOnly => 'Grupę może usunąć tylko jej właściciel.';

  @override
  String get expenseDiscardTitle => 'Odrzucić zmiany?';

  @override
  String get expenseDiscardBody => 'Zmiany w tym wydatku nie zostały zapisane.';

  @override
  String get expenseDiscard => 'Odrzuć';

  @override
  String get adminPrivacyUrl => 'Link do polityki prywatności';

  @override
  String get adminPrivacyUrlHelp =>
      'Polityka prywatności wymagana przez sklepy z aplikacjami. Jeśli pole jest puste, aplikacja wyświetla ogólną informację o danych przechowywanych przez Balnana.';

  @override
  String get adminMapTiles => 'Kafelki mapy';

  @override
  String get adminMapSource => 'Źródło mapy';

  @override
  String get adminMapSourceStyle => 'Styl wektorowy';

  @override
  String get adminMapSourceStyleHelp =>
      'Mapy rysowane na podstawie stylu MapLibre, na przykład darmowego OpenFreeMap, który nie wymaga klucza.';

  @override
  String get adminMapSourceTiles => 'Kafelki rastrowe';

  @override
  String get adminMapSourceTilesHelp => 'Mapy wyświetlane jako obrazy kafelków, na przykład z OpenStreetMap.';

  @override
  String get adminMapSourceOff => 'Wyłączone';

  @override
  String get adminMapSourceOffHelp => 'Mapy są wyłączone. Wydatki nadal zapisują nazwy miejsc i punkty.';

  @override
  String get adminMapStyle => 'Adres URL stylu';

  @override
  String get adminMapStyleHelp =>
      'Adres pliku style.json MapLibre, na przykład Liberty w OpenFreeMap (domyślny), Bright lub Positron.';

  @override
  String get adminMapTilesHelp =>
      'Szablon adresu URL kafelków rastrowych z parametrami z, x i y w nawiasach klamrowych, tak jak w domyślnym adresie. Serwery OpenStreetMap są przeznaczone do niewielkiego ruchu; przy większym ruchu użyj dostawcy kafelków.';

  @override
  String get adminMapAttribution => 'Informacja o źródle mapy';

  @override
  String get adminMapAttributionHelp =>
      'Wyświetlana na każdej mapie zgodnie z wymaganiami dostawcy. Jeśli pole jest puste, styl wyświetla podane w nim źródła, a kafelki — OpenStreetMap.';

  @override
  String get adminInvalidMapTiles =>
      'Wpisz szablon adresu URL http(s) z parametrami z, x i y w nawiasach klamrowych.';

  @override
  String get adminUsers => 'Konta';

  @override
  String get adminUsersSearch => 'Szukaj po imieniu, e-mailu lub nazwie użytkownika';

  @override
  String adminUsersShown(int shown, int total) {
    return 'Konta: $shown/$total';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konta',
      many: '$count kont',
      few: '$count konta',
      two: '$count konta',
      one: '1 konto',
    );
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => 'Brak pasujących kont.';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupy',
      many: '$count grup',
      few: '$count grupy',
      two: '$count grupy',
      one: '1 grupa',
      zero: 'Brak grup',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => 'niepotwierdzone';

  @override
  String adminUserDeleteTitle(String name) {
    return 'Usunąć konto osoby $name?';
  }

  @override
  String get adminUserDeleteBody =>
      'Konto zostanie trwale usunięte, a użytkownik wylogowany ze wszystkich urządzeń. Jego imię pozostanie w grupach jako osoba bez przypisanego konta; grupy, w których nikt inny nie uczestniczy, zostaną usunięte.';

  @override
  String get adminUserDeleted => 'Konto usunięte';

  @override
  String get commonDone => 'Gotowe';

  @override
  String get crowdSearch => 'Szukaj osób';

  @override
  String get crowdNoMatch => 'Nie znaleziono osób.';

  @override
  String get crowdAll => 'Wszystkie';

  @override
  String get crowdNone => 'Brak';

  @override
  String crowdChosen(int count, int total) {
    return 'Wybrano $count z $total';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kolejnej osoby',
      many: '$count kolejnych osób',
      few: '$count kolejne osoby',
      two: '$count kolejne osoby',
      one: '1 kolejna osoba',
    );
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => 'Pokaż mniej';

  @override
  String get crowdSort => 'Sortuj';

  @override
  String crowdShowAll(int count) {
    return 'Pokaż wszystkie osoby ($count)';
  }

  @override
  String get crowdBalances => 'Saldo wszystkich';

  @override
  String get crowdSomeoneElse => 'Ktoś inny';

  @override
  String get crowdChoosePayers => 'Wybierz płacących';

  @override
  String get crowdFilterTitle => 'Czyje wydatki?';

  @override
  String get myGroupsTitle => 'Moje linki do grup';

  @override
  String get myGroupsExport => 'Eksportuj moje grupy';

  @override
  String get myGroupsExportHelp =>
      'Skopiuj linki do grup, aby zrobić kopię zapasową lub przenieść je na inne urządzenie.';

  @override
  String get myGroupsPrivate => 'Chroń te linki. Każda osoba, która ma link, może otworzyć grupę.';

  @override
  String get myGroupsCopy => 'Kopiuj linki';

  @override
  String get myGroupsImport => 'Importuj grupy';

  @override
  String get myGroupsImportHelp =>
      'Wklej linki do grup z tego serwera, po jednym w wierszu. Istniejące grupy zachowają dotychczasowe miejsce na liście i swoją tożsamość.';

  @override
  String get myGroupsLinks => 'Linki do grup';

  @override
  String get myGroupsImportAction => 'Importuj linki';

  @override
  String get myGroupsInvalid =>
      'Wpisz prawidłowe linki do grup, po jednym w wierszu. Niczego nie zaimportowano.';

  @override
  String get myGroupsServerChanged =>
      'Wybrany serwer uległ zmianie. Zamknij to okno i zaimportuj linki na ich serwerze.';

  @override
  String myGroupsLimit(int count) {
    return 'Limit linków do grup na serwerze: $count. Niczego nie zaimportowano.';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zaimportowano $count nowego linku do grupy.',
      many: 'Zaimportowano $count nowych linków do grup.',
      few: 'Zaimportowano $count nowe linki do grup.',
      two: 'Zaimportowano $count nowe linki do grup.',
      one: 'Zaimportowano 1 nowy link do grupy.',
      zero: 'Te grupy są już zapisane.',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => 'Powtarzanie';

  @override
  String get repeatNever => 'Nie powtarzaj';

  @override
  String get repeatDaily => 'Codziennie';

  @override
  String get repeatWeekly => 'Co tydzień';

  @override
  String get repeatMonthly => 'Co miesiąc';

  @override
  String get repeatYearly => 'Co rok';

  @override
  String get repeatEvery => 'Co';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dnia',
      many: '$count dni',
      few: '$count dni',
      two: '$count dni',
      one: 'dzień',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tygodnia',
      many: '$count tygodni',
      few: '$count tygodnie',
      two: '$count tygodnie',
      one: 'tydzień',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miesiąca',
      many: '$count miesięcy',
      few: '$count miesiące',
      two: '$count miesiące',
      one: 'miesiąc',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count roku',
      many: '$count lat',
      few: '$count lata',
      two: '$count lata',
      one: 'rok',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Co $count dnia',
      many: 'Co $count dni',
      few: 'Co $count dni',
      two: 'Co $count dni',
      one: 'Codziennie',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Co $count tygodnia',
      many: 'Co $count tygodni',
      few: 'Co $count tygodnie',
      two: 'Co $count tygodnie',
      one: 'Co tydzień',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Co $count miesiąca',
      many: 'Co $count miesięcy',
      few: 'Co $count miesiące',
      two: 'Co $count miesiące',
      one: 'Co miesiąc',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Co $count roku',
      many: 'Co $count lat',
      few: 'Co $count lata',
      two: 'Co $count lata',
      one: 'Co rok',
    );
    return '$_temp0';
  }

  @override
  String get repeatEndNone => 'Bez daty końcowej';

  @override
  String repeatEndOn(String date) {
    return 'Do $date';
  }

  @override
  String get repeatEndClear => 'Usuń datę końcową';

  @override
  String get repeatHelp =>
      'Wydatek będzie automatycznie dodawany do grupy w wyznaczonych terminach, począwszy od daty powyżej. Zaległe wydatki zostaną dodane po zapisaniu.';

  @override
  String get repeatDropReceiptTitle => 'Usunąć paragon?';

  @override
  String get repeatDropReceiptBody =>
      'Cykliczny wydatek nie może mieć paragonu. Możesz dodać go osobno do każdego utworzonego wydatku.';

  @override
  String get repeatDropReceiptAction => 'Powtarzaj';

  @override
  String get recurringTitle => 'Wydatki cykliczne';

  @override
  String get recurringHelp => 'Wydatki dodawane automatycznie według harmonogramu';

  @override
  String get recurringEmptyTitle => 'Brak wydatków cyklicznych';

  @override
  String get recurringEmptyBody =>
      'Czynsz, subskrypcje i inne powtarzające się koszty mogą być dodawane automatycznie w wyznaczonych terminach.';

  @override
  String get recurringAdd => 'Dodaj wydatek cykliczny';

  @override
  String get recurringEdit => 'Edytuj wydatek cykliczny';

  @override
  String recurringNext(String date) {
    return 'Następny: $date';
  }

  @override
  String get recurringPaused => 'Wstrzymany';

  @override
  String get recurringEnded => 'Zakończony';

  @override
  String get recurringPause => 'Wstrzymaj';

  @override
  String get recurringResume => 'Wznów';

  @override
  String get recurringActive => 'Powtarzaj';

  @override
  String get recurringDelete => 'Usuń';

  @override
  String get recurringDeleteTitle => 'Zatrzymać powtarzanie?';

  @override
  String recurringDeleteBody(String title) {
    return 'Wydatek „$title” nie będzie już dodawany. Utworzone wcześniej wydatki pozostaną.';
  }

  @override
  String get recurringDeleted => 'Usunięto wydatek cykliczny';

  @override
  String get recurringFromSchedule => 'Dodany przez wydatek cykliczny';

  @override
  String get recurringOpen => 'Zmień harmonogram';

  @override
  String get recurringMissing => 'Wydatek cykliczny został usunięty lub jest niedostępny.';

  @override
  String get errorTooManyDue =>
      'Data początkowa jest zbyt odległa w przeszłości: jednocześnie zostałoby dodanych ponad 100 wydatków.';

  @override
  String get errorInvalidEnd => 'Data końcowa nie może przypadać przed datą początkową.';

  @override
  String get errorInvalidRepeat => 'Powtarzaj co 1–999 dni, tygodni, miesięcy lub lat.';

  @override
  String get errorRecurringConflict =>
      'Ktoś inny zmienił ten wydatek cykliczny podczas edycji. Odśwież stronę, aby zobaczyć zmiany.';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$who ustawił(a) powtarzanie wydatku „$title”';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$who zmienił(a) wydatek cykliczny „$title”';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$who wstrzymał(a) wydatek cykliczny „$title”';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return 'Wstrzymano wydatek cykliczny „$title”, ponieważ jedna z osób opuściła grupę';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return 'Wstrzymano wydatek cykliczny „$title”, ponieważ nie udało się go dodać';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$who wznowił(a) wydatek cykliczny „$title”';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$who zatrzymał(a) wydatek cykliczny „$title”';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return 'Automatycznie dodano „$title” ($amount)';
  }

  @override
  String get expenseRecurring => 'Dodany przez wydatek cykliczny';
}
