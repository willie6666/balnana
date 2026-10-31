// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get languageEndonym => 'Deutsch';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get offlineBar =>
      'Offline. Angezeigt werden die auf diesem Gerät gespeicherten Daten. Änderungen werden erst gespeichert, wenn du wieder verbunden bist.';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonClear => 'Leeren';

  @override
  String get iconChoose => 'Symbol auswählen';

  @override
  String get iconNone => 'Kein Symbol';

  @override
  String get iconSearchHint => 'Suchen oder ein beliebiges Emoji eingeben';

  @override
  String get iconUseTyped => 'Dieses Emoji verwenden';

  @override
  String get iconNoMatch => 'Keine passenden Symbole. Gib ein Emoji ein, um es zu verwenden.';

  @override
  String get iconSectionTravel => 'Reisen und Orte';

  @override
  String get iconSectionFood => 'Essen und Trinken';

  @override
  String get iconSectionActivities => 'Aktivitäten';

  @override
  String get iconSectionHome => 'Wohnen und Rechnungen';

  @override
  String get iconSectionPeople => 'Personen';

  @override
  String get iconSectionNature => 'Tiere und Natur';

  @override
  String get iconSectionObjects => 'Geld und Dinge';

  @override
  String get iconSectionSymbols => 'Symbole';

  @override
  String get commonRemove => 'Entfernen';

  @override
  String get commonUndo => 'Rückgängig';

  @override
  String get someone => 'Jemand';

  @override
  String get errorTooLarge => 'Diese Datei ist zu groß, um sie an den Server zu senden.';

  @override
  String get errorBusy => 'Der Server ist gerade ausgelastet. Versuch es gleich noch einmal.';

  @override
  String get errorTimeout =>
      'Das Senden hat zu lange gedauert. Prüfe deine Verbindung und versuch es noch einmal.';

  @override
  String get errorBadOrigin =>
      'Der Server akzeptiert keine Anmeldungen von dieser Adresse. Die betreibende Person sollte die öffentliche URL prüfen.';

  @override
  String get errorInvalidCategory => 'Diese Kategorie wurde inzwischen gelöscht. Wähle eine andere.';

  @override
  String get errorBuiltinCategory => 'Vorgegebene Kategorien können nur ausgeblendet werden.';

  @override
  String get errorUnknownMember =>
      'Eine Person in dieser Ausgabe ist nicht mehr Teil der Gruppe. Lade die Seite neu und versuch es noch einmal.';

  @override
  String get errorNoPayers => 'Wähle aus, wer bezahlt hat.';

  @override
  String get errorPayerTotal =>
      'Die Beträge, die alle bezahlt haben, müssen zusammen dem Gesamtbetrag entsprechen.';

  @override
  String get errorPayerTooSmall =>
      'Der Anteil einer Person am bezahlten Betrag ergibt in der Gruppenwährung null. Prüfe die Beträge.';

  @override
  String get errorInvalidNote =>
      'Die Notiz ist zu lang oder enthält Zeichen, die nicht gespeichert werden können.';

  @override
  String get errorInvalidDate => 'Das Datum liegt außerhalb des zulässigen Bereichs.';

  @override
  String get errorGeneric => 'Etwas ist schiefgelaufen. Versuch es noch einmal.';

  @override
  String get errorNetwork => 'Der Server ist nicht erreichbar. Prüfe deine Verbindung.';

  @override
  String get errorNotFound => 'Das gibt es nicht mehr.';

  @override
  String get errorRequired => 'Erforderlich';

  @override
  String get errorInvalidName => 'Gib einen Namen mit höchstens 100 Zeichen ein.';

  @override
  String get errorDuplicateName => 'Jemand in dieser Gruppe hat bereits diesen Namen.';

  @override
  String get errorTooManyMembers => 'Diese Gruppe kann keine weiteren Mitglieder aufnehmen.';

  @override
  String get errorTooManyCategories => 'Diese Gruppe kann keine weiteren Kategorien aufnehmen.';

  @override
  String get errorDuplicateCategory => 'In dieser Gruppe gibt es bereits eine Kategorie mit diesem Namen.';

  @override
  String get errorInvalidCurrency => 'Gib einen dreistelligen Währungscode ein, zum Beispiel USD.';

  @override
  String get errorInvalidTitle => 'Gib einen Titel mit höchstens 200 Zeichen ein.';

  @override
  String get errorInvalidLocation => 'Gib einen einzeiligen Ortsnamen mit höchstens 200 Zeichen ein.';

  @override
  String get errorInvalidSymbol => 'Gib ein Symbol mit höchstens 8 Zeichen ein.';

  @override
  String get errorInvalidEmoji => 'Wähle ein einzelnes Emoji als Symbol.';

  @override
  String get errorMemberHasBalance => 'Gleiche den Saldo dieser Person aus, bevor du sie entfernst.';

  @override
  String get errorVersionConflict =>
      'Jemand anderes hat diese Ausgabe während deiner Bearbeitung geändert. Lade sie neu, um die Änderungen zu sehen.';

  @override
  String get errorSignInRequired => 'Melde dich an, um das zu tun.';

  @override
  String get errorRateLimited => 'Zu viele Anfragen. Warte eine Minute und versuch es noch einmal.';

  @override
  String get errorNotAMember => 'Du bist noch nicht in dieser Gruppe.';

  @override
  String get errorNotAllowed => 'Nur diese Person oder der Inhaber der Gruppe kann das tun.';

  @override
  String get errorLinkGroupsOff =>
      'Dieser Server erlaubt es nicht, Gruppen allein über einen Link zu öffnen.';

  @override
  String get errorMemberClaimed => 'Jemand ist der Gruppe bereits als diese Person beigetreten.';

  @override
  String get errorMemberLeft => 'Jemand in dieser Gruppe hat sie verlassen.';

  @override
  String get errorInvalidEmail => 'Gib eine E-Mail-Adresse ein.';

  @override
  String get errorInvalidPassword => 'Verwende 8 bis 200 Zeichen.';

  @override
  String get errorEmailTaken =>
      'Für diese E-Mail-Adresse gibt es bereits ein Konto. Melde dich stattdessen an.';

  @override
  String get errorSignupClosed => 'Auf diesem Server können keine neuen Konten erstellt werden.';

  @override
  String get errorInvalidCredentials => 'E-Mail-Adresse und Passwort passen nicht zusammen.';

  @override
  String get errorWrongPassword => 'Dein aktuelles Passwort ist falsch.';

  @override
  String get errorAccountsOff => 'Dieser Server verwendet keine Konten.';

  @override
  String get errorInvalidAmount => 'Gib einen Betrag größer als null ein.';

  @override
  String get errorTooManyDecimals => 'Diese Währung erlaubt nicht so viele Nachkommastellen.';

  @override
  String get errorAmountTooLarge => 'Dieser Betrag ist zu groß.';

  @override
  String get errorNoShares => 'Wähle mindestens eine Person aus, mit der die Kosten geteilt werden.';

  @override
  String get errorInvalidShare => 'Jeder Anteil muss eine Zahl sein.';

  @override
  String get errorExactTotal => 'Die Beträge müssen zusammen dem Gesamtbetrag entsprechen.';

  @override
  String get errorPayersTotal =>
      'Die Beträge, die alle bezahlt haben, müssen zusammen dem Gesamtbetrag entsprechen.';

  @override
  String get categoryFood => 'Essen und Trinken';

  @override
  String get categoryGroceries => 'Lebensmittel';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryTravel => 'Reisen';

  @override
  String get categoryLodging => 'Unterkunft';

  @override
  String get categoryRent => 'Miete';

  @override
  String get categoryUtilities => 'Nebenkosten';

  @override
  String get categoryEntertainment => 'Unterhaltung';

  @override
  String get categoryShopping => 'Einkäufe';

  @override
  String get categoryHealth => 'Gesundheit';

  @override
  String get categoryGifts => 'Geschenke';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get groupNew => 'Neue Gruppe';

  @override
  String get groupSwitch => 'Gruppe wechseln';

  @override
  String get groupReorder => 'Zum Sortieren ziehen';

  @override
  String get groupCreate => 'Gruppe erstellen';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
    );
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return 'Andere schulden dir $amount';
  }

  @override
  String pillOwe(String amount) {
    return 'Du schuldest $amount';
  }

  @override
  String get pillSettled => 'Ausgeglichen';

  @override
  String get groupMissingTitle => 'Gruppe nicht gefunden';

  @override
  String get groupMissingBody =>
      'Diese Gruppe wurde gelöscht oder ihr Link wurde zurückgesetzt. Bitte jemanden aus der Gruppe um den neuen Link.';

  @override
  String get groupLockedTitle => 'Melde dich an, um diese Gruppe zu öffnen';

  @override
  String get groupLockedBody =>
      'Diese Gruppe ist nur für die Konten ihrer Mitglieder zugänglich. Melde dich mit dem zugehörigen Konto an.';

  @override
  String get groupForget => 'Von diesem Gerät entfernen';

  @override
  String get groupLinkOtherServer =>
      'Dieser Link gehört zu einem anderen Server. Verbinde dich mit diesem Server, um ihn zu öffnen.';

  @override
  String get openLinkTitle => 'Gruppenlink öffnen';

  @override
  String get openLinkBody =>
      'Füge einen Link ein, den jemand mit dir geteilt hat, um der Gruppe beizutreten.';

  @override
  String get openLinkLabel => 'Gruppenlink';

  @override
  String get openLinkAction => 'Öffnen';

  @override
  String get openLinkInvalid => 'Das sieht nicht nach einem Balnana-Gruppenlink aus.';

  @override
  String get groupName => 'Gruppenname';

  @override
  String get groupNameHint => 'Reise nach Lissabon';

  @override
  String get groupCurrency => 'Währung';

  @override
  String get groupCurrencyHelp =>
      'Für alle Ausgaben in dieser Gruppe wird diese Währung verwendet. Sie kann später nicht geändert werden.';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name. Für alle Ausgaben in dieser Gruppe wird diese Währung verwendet. Sie kann später nicht geändert werden.';
  }

  @override
  String get currencyChoose => 'Währung auswählen';

  @override
  String get currencySearchHint => 'Nach Code oder Name suchen';

  @override
  String get currencySuggested => 'Vorgeschlagen';

  @override
  String get currencyAll => 'Alle Währungen';

  @override
  String currencyUseTyped(String code) {
    return '$code verwenden';
  }

  @override
  String get currencyNoMatch =>
      'Keine passende Währung. Gib den dreistelligen Code ein, um sie zu verwenden.';

  @override
  String get groupSymbol => 'Symbol';

  @override
  String get groupSymbolChoose => 'Symbol auswählen';

  @override
  String groupSymbolExample(String example) {
    return 'Beträge sehen so aus: $example';
  }

  @override
  String get groupColor => 'Farbe';

  @override
  String colorSwatch(int number, int count) {
    return 'Farbe $number von $count';
  }

  @override
  String get groupPeople => 'Personen';

  @override
  String get groupYourName => 'Dein Name';

  @override
  String groupPersonName(int number) {
    return 'Person $number';
  }

  @override
  String get groupAddPerson => 'Person hinzufügen';

  @override
  String get groupPeopleHelp =>
      'Du kannst später weitere Personen hinzufügen oder sie können über den Link beitreten.';

  @override
  String get identityTitle => 'Wer bist du?';

  @override
  String get identityBody =>
      'Wähle deinen Namen, damit Balnana anzeigen kann, was du schuldest. Nur dieses Gerät merkt sich deine Auswahl.';

  @override
  String get identityNew => 'Ich bin neu hier';

  @override
  String get identityNewTitle => 'Dieser Gruppe beitreten';

  @override
  String get identityJoin => 'Beitreten';

  @override
  String get identityChange => 'Wer du bist';

  @override
  String get identityNone => 'Noch nicht ausgewählt';

  @override
  String get memberName => 'Name';

  @override
  String memberYou(String name) {
    return '$name (du)';
  }

  @override
  String get memberAdd => 'Person hinzufügen';

  @override
  String get memberAddTitle => 'Person hinzufügen';

  @override
  String get memberRename => 'Umbenennen';

  @override
  String get memberRenameTitle => 'Umbenennen';

  @override
  String memberRemoveTitle(String name) {
    return '$name entfernen?';
  }

  @override
  String get memberRemoveBody => 'Die Ausgaben und der Saldo dieser Person bleiben in der Gruppe.';

  @override
  String get groupLinkCopied => 'Link kopiert. Alle mit diesem Link können die Gruppe öffnen.';

  @override
  String get groupShare => 'Link teilen';

  @override
  String get groupSettings => 'Gruppeneinstellungen';

  @override
  String get groupEdit => 'Gruppe bearbeiten';

  @override
  String get groupSharing => 'Freigabe';

  @override
  String get groupCopyLink => 'Link kopieren';

  @override
  String get groupQrCode => 'QR-Code anzeigen';

  @override
  String get groupQrCodeHelp => 'Andere können den Link mit ihrer Handykamera scannen.';

  @override
  String groupQrLabel(String group) {
    return 'QR-Code für den Link zu $group';
  }

  @override
  String get groupCopyLinkHelp => 'Alle mit diesem Link können diese Gruppe ansehen und bearbeiten.';

  @override
  String get groupCopyLinkHelpAccounts =>
      'Personen mit diesem Link können nach der Anmeldung den Beitritt beantragen.';

  @override
  String get linkAccessTitle => 'Für alle mit dem Link zugänglich';

  @override
  String get linkAccessHelp => 'Personen können die Gruppe ohne Konto ansehen und bearbeiten';

  @override
  String get resetLinkTitle => 'Link zurücksetzen';

  @override
  String get resetLinkHelp => 'Erstelle einen neuen Link. Der alte funktioniert dann nicht mehr.';

  @override
  String get resetLinkBody =>
      'Der aktuelle Link funktioniert für niemanden mehr. Teile den neuen Link mit allen, die weiterhin Zugriff haben sollen.';

  @override
  String get resetLinkAction => 'Zurücksetzen';

  @override
  String get resetLinkDone => 'Link zurückgesetzt. Teile den neuen Link.';

  @override
  String get groupThisDevice => 'Dieses Gerät';

  @override
  String get groupData => 'Daten';

  @override
  String get categoriesTitle => 'Kategorien';

  @override
  String get categoriesHelp => 'Füge eigene hinzu oder blende ungenutzte aus';

  @override
  String get categoriesOwn => 'Eigene Kategorien';

  @override
  String get categoriesOwnEmpty => 'Es gibt noch keine eigenen Kategorien für diese Gruppe.';

  @override
  String get categoriesBuiltIn => 'Vorgegeben';

  @override
  String get categoriesBuiltInHelp =>
      'Ausgeblendete Kategorien werden bei neuen Ausgaben nicht angeboten. In bestehenden Ausgaben bleiben sie erhalten.';

  @override
  String get categoryAdd => 'Kategorie hinzufügen';

  @override
  String get categoryEdit => 'Kategorie bearbeiten';

  @override
  String get categoryName => 'Name';

  @override
  String get categoryDelete => 'Kategorie löschen';

  @override
  String categoryDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get categoryDeleteBody => 'Ausgaben in dieser Kategorie haben anschließend keine Kategorie mehr.';

  @override
  String get categoryDeleteAction => 'Löschen';

  @override
  String get exportCsv => 'Als CSV exportieren';

  @override
  String get exportCsvHelp => 'Alle Ausgaben und Zahlungen für eine Tabellenkalkulation';

  @override
  String get exportCsvDone => 'Exportiert';

  @override
  String get forgetTitle => 'Von diesem Gerät entfernen';

  @override
  String get forgetHelp => 'Die Gruppe bleibt für alle anderen auf dem Server';

  @override
  String get forgetBody => 'Du kannst sie mit dem Link wieder öffnen.';

  @override
  String get groupYou => 'Du';

  @override
  String get leaveTitle => 'Gruppe verlassen';

  @override
  String get leaveHelp => 'Deine Ausgaben bleiben erhalten. Du kannst über den Link wieder beitreten.';

  @override
  String get leaveBody =>
      'Die Gruppe verschwindet aus deiner Liste. Deine Ausgaben und dein Saldo bleiben in der Gruppe.';

  @override
  String get leaveAction => 'Verlassen';

  @override
  String get tabExpenses => 'Ausgaben';

  @override
  String get heroWhoTitle => 'Wer bist du in dieser Gruppe?';

  @override
  String get heroWhoBody => 'Wähle deinen Namen, um zu sehen, was du schuldest und was dir geschuldet wird.';

  @override
  String get heroWhoAction => 'Auswählen';

  @override
  String get heroJoinTitle => 'Du siehst dir diese Gruppe an';

  @override
  String get heroJoinBody => 'Tritt bei, um Ausgaben hinzuzufügen und deinen Saldo zu sehen.';

  @override
  String get joinAction => 'Beitreten';

  @override
  String get heroOwed => 'Andere schulden dir etwas';

  @override
  String get heroOwe => 'Du schuldest etwas';

  @override
  String get heroSettled => 'Alles ist ausgeglichen';

  @override
  String heroYouAre(String name) {
    return 'Du bist $name';
  }

  @override
  String get expenseAdd => 'Ausgabe hinzufügen';

  @override
  String get expensesEmptyTitle => 'Noch keine Ausgaben';

  @override
  String get expensesEmptyBody =>
      'Füge die erste Ausgabe hinzu. Balnana berechnet dann, wer wem etwas schuldet.';

  @override
  String get expensesSearchHint => 'Titel, Notizen und Orte durchsuchen';

  @override
  String get searchClear => 'Suche leeren';

  @override
  String get expensesNoMatchTitle => 'Keine Treffer';

  @override
  String get expensesNoMatchBody => 'Versuch es mit anderen Wörtern oder weniger Filtern.';

  @override
  String get filterAnyone => 'Alle';

  @override
  String get filterAnyCategory => 'Alle Kategorien';

  @override
  String get filterPayments => 'Zahlungen';

  @override
  String get filterClear => 'Filter zurücksetzen';

  @override
  String get periodAll => 'Gesamter Zeitraum';

  @override
  String get periodThisMonth => 'Diesen Monat';

  @override
  String get periodLastMonth => 'Letzten Monat';

  @override
  String get periodThisYear => 'Dieses Jahr';

  @override
  String get periodPickDays => 'Zeitraum auswählen…';

  @override
  String get statsTitle => 'Ausgaben';

  @override
  String get statsTotal => 'Insgesamt ausgegeben';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ausgaben',
      one: '1 Ausgabe',
    );
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'Nach Kategorie';

  @override
  String get statsByMember => 'Bezahlt und Anteil pro Person';

  @override
  String get statsPaid => 'Bezahlt';

  @override
  String get statsShare => 'Anteil';

  @override
  String get statsByMonth => 'Nach Monat';

  @override
  String get statsNoCategory => 'Ohne Kategorie';

  @override
  String get statsEmptyTitle => 'Nichts ausgegeben';

  @override
  String get statsEmptyBody => 'In diesem Zeitraum gibt es keine Ausgaben.';

  @override
  String get statsShowExpenses => 'Diese Ausgaben anzeigen';

  @override
  String get dateToday => 'Heute';

  @override
  String get dateYesterday => 'Gestern';

  @override
  String paymentTitle(String from, String to) {
    return '$from hat an $to gezahlt';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name hat $amount bezahlt';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return '$count Personen haben $amount bezahlt';
  }

  @override
  String expensePaidByName(String name) {
    return '$name hat bezahlt';
  }

  @override
  String expensePaidByManyNames(int count) {
    return '$count Personen haben bezahlt';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name hat $amount erhalten';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$name hat erhalten';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return '$count Personen haben etwas erhalten';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return '$count Personen haben $amount erhalten';
  }

  @override
  String get transactionRefund => 'Rückerstattung';

  @override
  String get transactionIncome => 'Einnahme';

  @override
  String get paymentDelete => 'Zahlung löschen';

  @override
  String get paymentDeleted => 'Zahlung gelöscht';

  @override
  String expenseDeleted(String title) {
    return '„$title“ gelöscht';
  }

  @override
  String get expenseNew => 'Neue Ausgabe';

  @override
  String get expenseEdit => 'Ausgabe bearbeiten';

  @override
  String get expenseDelete => 'Löschen';

  @override
  String get expenseAmount => 'Betrag';

  @override
  String get expenseTitle => 'Wofür war das?';

  @override
  String get expenseTitleHint => 'Abendessen, Tickets, Taxi …';

  @override
  String get expenseAmountFromPayers => 'Summe der Zahlungen aller';

  @override
  String expensePaidIn(String currency) {
    return 'Bezahlt in $currency';
  }

  @override
  String expenseRate(String from, String to) {
    return '1 $from in $to';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return 'Gesamtbetrag in $currency';
  }

  @override
  String expenseForeignHelp(String currency) {
    return 'Die Salden bleiben in $currency. Gib den Wechselkurs oder den umgerechneten Betrag ein, zum Beispiel aus der Kartenabrechnung.';
  }

  @override
  String get expenseNote => 'Notiz';

  @override
  String get expenseNoteHint => 'Optional';

  @override
  String get expenseLocation => 'Ort';

  @override
  String get expenseLocationHint => 'Wo war das? (optional)';

  @override
  String get locationPickOnMap => 'Auf der Karte auswählen';

  @override
  String get locationUseCurrent => 'Aktuellen Standort verwenden';

  @override
  String get locationFinding => 'Standort wird gesucht …';

  @override
  String get locationChange => 'Auf der Karte ändern';

  @override
  String get locationRemovePin => 'Markierung entfernen';

  @override
  String get locationOpenInMaps => 'In Karten öffnen';

  @override
  String get locationPickTitle => 'Ort auswählen';

  @override
  String get locationPickHint => 'Tippe auf die Karte, um eine Markierung zu setzen';

  @override
  String get locationPickDone => 'Fertig';

  @override
  String get locationDenied =>
      'Balnana darf deinen Standort nicht verwenden. Du kannst das in den Geräte- oder Browsereinstellungen erlauben.';

  @override
  String get locationOff => 'Der Standort ist auf diesem Gerät ausgeschaltet.';

  @override
  String get locationUnavailable =>
      'Dein Standort konnte nicht gefunden werden. Versuch es noch einmal oder setze eine Markierung auf der Karte.';

  @override
  String get expenseReceipt => 'Beleg';

  @override
  String get expenseHasReceipt => 'Foto eines Belegs vorhanden';

  @override
  String get expenseHasLocation => 'Standort vorhanden';

  @override
  String get receiptTakePhoto => 'Foto aufnehmen';

  @override
  String get receiptChoose => 'Bild auswählen';

  @override
  String get receiptRemove => 'Entfernen';

  @override
  String get receiptView => 'Belegfoto';

  @override
  String receiptNotSaved(String reason) {
    return 'Die Ausgabe wurde gespeichert, aber nicht ihr Belegfoto. $reason';
  }

  @override
  String get expensePaidByLabel => 'Bezahlt von';

  @override
  String get expenseReceivedForLabel => 'Erhalten für';

  @override
  String get expenseReceivedByLabel => 'Erhalten von';

  @override
  String get expenseMultiplePayers => 'Mehrere Personen';

  @override
  String get expenseSplit => 'Aufteilen';

  @override
  String get splitEqual => 'Gleichmäßig';

  @override
  String get splitExact => 'Beträge';

  @override
  String get splitShares => 'Anteile';

  @override
  String splitLeft(String amount) {
    return 'Noch $amount zu verteilen';
  }

  @override
  String splitOver(String amount) {
    return '$amount zu viel';
  }

  @override
  String get conflictTitle => 'Anderswo geändert';

  @override
  String get conflictReload => 'Neu laden';

  @override
  String get expenseChangedElsewhere =>
      'Jemand anderes hat diese Ausgabe geändert. Beim Neuladen wird die andere Version angezeigt und deine Änderungen hier werden verworfen.';

  @override
  String get expenseNewerTitle => 'Mit einer neueren Version erstellt';

  @override
  String get expenseNewerBody => 'Aktualisiere Balnana, um diesen Eintrag zu ändern.';

  @override
  String get suggestedPayments => 'Vorgeschlagene Zahlungen';

  @override
  String get allSettled => 'Alle Salden sind ausgeglichen.';

  @override
  String transferYouPay(String name) {
    return 'Du zahlst $name';
  }

  @override
  String transferPaysYou(String name) {
    return '$name zahlt an dich';
  }

  @override
  String transferPays(String from, String to) {
    return '$from zahlt an $to';
  }

  @override
  String get recordPayment => 'Eintragen';

  @override
  String get recordPaymentTitle => 'Zahlung eintragen';

  @override
  String get recordPaymentHelp => 'Trage nur Geld ein, das tatsächlich außerhalb von Balnana gezahlt wurde.';

  @override
  String get paymentRecorded => 'Zahlung eingetragen';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who hat $group erstellt';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who hat die Gruppendetails geändert';
  }

  @override
  String activityLinkReset(String who) {
    return '$who hat den Gruppenlink zurückgesetzt';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who hat $name hinzugefügt';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who hat $oldName in $name umbenannt';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who hat $name entfernt';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who hat die Kategorie $name hinzugefügt';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who hat die Kategorien geändert';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who hat die Kategorie $name gelöscht';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name ist beigetreten';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who hat „$title“ ($amount) hinzugefügt';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who hat „$title“ ($amount) bearbeitet';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who hat „$title“ gelöscht';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who hat „$title“ wiederhergestellt';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who hat eingetragen, dass $from $amount an $to gezahlt hat';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who hat eine Zahlung über $amount gelöscht';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who hat eine Zahlung über $amount wiederhergestellt';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
    );
    return '$who hat $_temp0 aus $source importiert';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who hat „$title“ ein Belegfoto hinzugefügt';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who hat das Belegfoto von „$title“ entfernt';
  }

  @override
  String activityOther(String who) {
    return '$who hat etwas geändert';
  }

  @override
  String get navGroups => 'Gruppen';

  @override
  String get navActivity => 'Aktivität';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get groupsEmptyTitle => 'Noch keine Gruppen';

  @override
  String get groupsEmptyBody => 'Gruppen, die du erstellst oder über einen Link öffnest, erscheinen hier.';

  @override
  String get groupsNoServerTitle => 'Mit einem Server verbinden';

  @override
  String get groupsNoServerBody =>
      'Balnana speichert deine Gruppen auf einem Server, den du selbst auswählst, zum Beispiel auf deinem eigenen.';

  @override
  String get groupsNoServerAction => 'Server auswählen';

  @override
  String get groupsUnreachableTitle => 'Server nicht erreichbar';

  @override
  String get groupsUnreachableBody => 'Prüfe deine Verbindung oder die Serveradresse in den Einstellungen.';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gruppen konnten nicht geladen werden. Ihre Änderungen fehlen.',
      one: 'Eine Gruppe konnte nicht geladen werden. Ihre Änderungen fehlen.',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => 'Noch nichts hier';

  @override
  String get activityEmptyBody => 'Neue Ausgaben und Zahlungen in deinen Gruppen erscheinen hier.';

  @override
  String get notFoundTitle => 'Seite nicht gefunden';

  @override
  String get notFoundBody => 'Diese Adresse führt nirgendwo in Balnana hin.';

  @override
  String get notFoundAction => 'Zu den Gruppen';

  @override
  String get settingsAppearance => 'Darstellung';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get accountRename => 'Name ändern';

  @override
  String get passwordChange => 'Passwort ändern';

  @override
  String get passwordChanged => 'Passwort geändert. Auf anderen Geräten wurdest du abgemeldet.';

  @override
  String get passwordSet => 'Passwort festlegen';

  @override
  String get passwordSetHelp =>
      'Melde dich auch mit deiner E-Mail-Adresse oder deinem Benutzernamen und einem Passwort an';

  @override
  String get passwordSetDone => 'Passwort festgelegt. Auf anderen Geräten wurdest du abgemeldet.';

  @override
  String get passwordCurrent => 'Aktuelles Passwort';

  @override
  String get passwordNew => 'Neues Passwort';

  @override
  String get signOut => 'Abmelden';

  @override
  String get accountOAuthLinked => 'Meldet dich bei diesem Konto an. Tippe, um die Verknüpfung zu entfernen.';

  @override
  String get accountOAuthAdd => 'Als Anmeldemethode hinzufügen';

  @override
  String accountOAuthAddTitle(String name) {
    return '$name hinzufügen';
  }

  @override
  String accountOAuthAdded(String name) {
    return 'Du kannst dich jetzt mit $name anmelden.';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return '$name entfernen?';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return 'Du kannst dich erst wieder mit $name anmelden, wenn du es erneut hinzufügst.';
  }

  @override
  String get accountOAuthRemove => 'Entfernen';

  @override
  String accountOAuthRemoved(String name) {
    return '$name entfernt.';
  }

  @override
  String get confirmEmailTitle => 'E-Mail-Adresse bestätigen';

  @override
  String confirmEmailBody(String email) {
    return 'Dieser Server verlangt eine bestätigte E-Mail-Adresse. Öffne den Link, den wir an $email gesendet haben.';
  }

  @override
  String get confirmEmailDone => 'Ich habe sie bestätigt';

  @override
  String get confirmEmailResend => 'Link erneut senden';

  @override
  String get confirmEmailNotYet => 'Noch nicht bestätigt. Öffne den Link in der E-Mail.';

  @override
  String get settingsTheme => 'Design';

  @override
  String get themeSystem => 'Wie im System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get settingsDynamicColor => 'Hintergrundfarben';

  @override
  String get settingsDynamicColorSubtitle => 'Farben deines Geräts statt des Balnana-Gelbs verwenden';

  @override
  String get settingsWallpaperGroups => 'Hintergrundfarben in Gruppen';

  @override
  String get settingsWallpaperGroupsSubtitle =>
      'Auch Gruppen verwenden die Farben deines Geräts statt ihrer eigenen';

  @override
  String get settingsPureBlack => 'Tiefschwarz';

  @override
  String get settingsPureBlackSubtitle => 'Ein dunkleres Design für OLED-Bildschirme';

  @override
  String get settingsMyShare => 'Meinen Anteil anzeigen';

  @override
  String get settingsMyShareSubtitle =>
      'Ausgaben zeigen, was du vorgestreckt hast oder was du schuldest, statt des Gesamtbetrags';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageSystem => 'Wie im System';

  @override
  String get settingsNotifications => 'Mitteilungen';

  @override
  String get settingsNotificationsSubtitle =>
      'Wenn jemand eine Ausgabe ändert oder löscht, an der du beteiligt bist';

  @override
  String get settingsNotificationsBlocked =>
      'In den Geräteeinstellungen blockiert: Erlaube dort Mitteilungen von Balnana, um sie zu sehen';

  @override
  String get pushChannel => 'Ausgaben';

  @override
  String get pushChannelDescription =>
      'Wenn jemand eine Ausgabe ändert oder löscht, an der du beteiligt bist';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who hat $title hinzugefügt · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who hat $title geändert · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who hat $title gelöscht · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return '$title wurde hinzugefügt · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return '$title wurde geändert · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return '$title wurde gelöscht · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payer hat $payee $amount gezahlt';
  }

  @override
  String get settingsConnection => 'Verbindung';

  @override
  String get settingsServer => 'Server';

  @override
  String get serverNotSet => 'Nicht festgelegt';

  @override
  String get settingsAbout => 'Über';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicenses => 'Open-Source-Lizenzen';

  @override
  String get aboutSource => 'Quellcode';

  @override
  String get aboutSourceCopied => 'Browser konnte nicht geöffnet werden. Der Link wurde kopiert.';

  @override
  String get serverTitle => 'Server';

  @override
  String get serverIntro =>
      'Gib die Adresse eines Balnana-Servers ein. Jede Person kann einen Server betreiben. Die Adresse ist normalerweise die, unter der sich die Web-App öffnet.';

  @override
  String get serverUrlLabel => 'Serveradresse';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => 'Verbindung testen';

  @override
  String get serverSaveAnyway => 'Trotzdem speichern';

  @override
  String get serverReset => 'Standard verwenden';

  @override
  String serverDefault(String url) {
    return 'Standard: $url';
  }

  @override
  String serverConnected(String version) {
    return 'Mit Balnana $version verbunden';
  }

  @override
  String get serverModeLink => 'Gruppen werden über einen privaten Link geteilt. Kein Konto nötig.';

  @override
  String get serverModeAccounts => 'Personen melden sich mit einem Konto an.';

  @override
  String get serverInsecure =>
      'Diese Adresse ist nicht verschlüsselt (http). Andere im Netzwerk könnten deine Daten lesen. Verwende https für Server außerhalb deines Heimnetzwerks.';

  @override
  String get serverErrorInvalid => 'Gib eine Webadresse ein, zum Beispiel balnana.example.com';

  @override
  String get serverErrorUnreachable =>
      'Verbindung fehlgeschlagen. Prüfe die Adresse und ob der Server läuft.';

  @override
  String get serverErrorNotBalnana => 'Es hat jemand geantwortet, aber es ist kein Balnana-Server.';

  @override
  String get serverSaved => 'Server gespeichert';

  @override
  String get signIn => 'Anmelden';

  @override
  String get groupSignInTitle => 'Melde dich an, um diese Gruppe zu öffnen';

  @override
  String get groupSignInBody =>
      'Diese Gruppe ist nur für ihre Mitglieder. Melde dich an, um sie anzusehen oder beizutreten.';

  @override
  String get signInTitle => 'Willkommen zurück';

  @override
  String get signInBody => 'Melde dich an, um deine Gruppen zu sehen.';

  @override
  String get signInNoPassword =>
      'Dieser Server meldet Personen auf andere Weise an. Frag die betreibende Person.';

  @override
  String get registerTitle => 'Konto erstellen';

  @override
  String get registerBody => 'Nutze deine Gruppen auf allen Geräten.';

  @override
  String get registerAction => 'Konto erstellen';

  @override
  String get registerHaveAccount => 'Ich habe bereits ein Konto';

  @override
  String get signInNoAccount => 'Konto erstellen';

  @override
  String get accountName => 'Dein Name';

  @override
  String get accountNameHelp => 'So sehen dich andere in deinen Gruppen';

  @override
  String get accountEmail => 'E-Mail-Adresse';

  @override
  String get accountPassword => 'Passwort';

  @override
  String get accountPasswordHelp => 'Mindestens 8 Zeichen';

  @override
  String get passwordShow => 'Passwort anzeigen';

  @override
  String get passwordHide => 'Passwort ausblenden';

  @override
  String get joinPickName => 'Anderen Namen auswählen';

  @override
  String joinTitle(String name) {
    return '$name beitreten';
  }

  @override
  String get joinBody => 'Bist du eine dieser Personen? Wähle dich aus, um ihre Ausgaben zu übernehmen.';

  @override
  String get joinBodyNew => 'Tritt bei, um Ausgaben hinzuzufügen und deinen Saldo zu sehen.';

  @override
  String get joinAsNew => 'Ich bin neu hier';

  @override
  String joinAsName(String name) {
    return 'Als $name beitreten';
  }

  @override
  String joinTaken(String names) {
    return 'Bereits beigetreten: $names';
  }

  @override
  String joinTakenCount(int count) {
    return '$count Personen sind bereits beigetreten.';
  }

  @override
  String get commonContinue => 'Weiter';

  @override
  String get errorEmailOff => 'Dieser Server versendet keine E-Mails.';

  @override
  String get errorInvalidToken => 'Dieser Link ist abgelaufen oder wurde bereits verwendet.';

  @override
  String get forgotPasswordTitle => 'Passwort vergessen?';

  @override
  String get forgotPasswordBody =>
      'Wir senden dir einen Link, über den du ein neues Passwort festlegen kannst.';

  @override
  String get forgotPasswordAction => 'Link senden';

  @override
  String get forgotPasswordSent => 'Falls es ein Konto für diese Adresse gibt, ist ein Link unterwegs.';

  @override
  String get resetPasswordTitle => 'Neues Passwort festlegen';

  @override
  String get resetPasswordBody =>
      'Du wirst überall abgemeldet und kannst dich dann mit dem neuen Passwort anmelden.';

  @override
  String get resetPasswordAction => 'Passwort speichern';

  @override
  String get resetPasswordDone => 'Passwort geändert. Melde dich mit deinem neuen Passwort an.';

  @override
  String get verifyEmailTitle => 'E-Mail-Adresse bestätigen';

  @override
  String get verifyEmailHelp => 'So kannst du dein Passwort zurücksetzen, falls du es vergisst';

  @override
  String verifyEmailSent(String email) {
    return 'Prüfe $email. Dort findest du einen Link.';
  }

  @override
  String get verifyEmailDone => 'E-Mail-Adresse bestätigt';

  @override
  String get verifyEmailDoneBody => 'Danke! Deine E-Mail-Adresse ist bestätigt.';

  @override
  String get verifyEmailFailed => 'E-Mail-Adresse konnte nicht bestätigt werden';

  @override
  String get inviteByEmail => 'Per E-Mail einladen';

  @override
  String get inviteByEmailHelp => 'Sende jemandem einen Link zum Beitreten';

  @override
  String get inviteAs => 'Beitreten als';

  @override
  String get inviteAsHelp => 'Die Person kann die Ausgaben dieses Mitglieds übernehmen';

  @override
  String get inviteAsAnyone => 'Neue Person';

  @override
  String get inviteSend => 'Einladung senden';

  @override
  String inviteSent(String email) {
    return 'Einladung an $email gesendet.';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name hat dich zu $group eingeladen';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return 'Du bist zu $group eingeladen';
  }

  @override
  String inviteBody(String email) {
    return 'Erstelle mit $email ein Konto, um beizutreten, oder melde dich an, falls du schon eines hast.';
  }

  @override
  String get inviteBodySignedIn => 'Tritt bei, um Ausgaben hinzuzufügen und deinen Saldo zu sehen.';

  @override
  String get inviteAction => 'Einladung öffnen';

  @override
  String get inviteMissingTitle => 'Diese Einladung funktioniert nicht';

  @override
  String get inviteMissingBody =>
      'Vielleicht ist sie abgelaufen oder wurde bereits verwendet. Bitte um eine neue Einladung.';

  @override
  String get joinInvitedAs => 'Du wurdest als dieses Mitglied eingeladen';

  @override
  String signInWith(String provider) {
    return 'Weiter mit $provider';
  }

  @override
  String get signInOr => 'oder';

  @override
  String get oauthFailedTitle => 'Anmeldung fehlgeschlagen';

  @override
  String get oauthPendingTitle => 'Für diese E-Mail-Adresse gibt es bereits ein Konto';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider bestätigt, dass $email dir gehört. Ein Konto mit dieser E-Mail-Adresse wurde aber noch nicht bestätigt. Was soll geschehen?';
  }

  @override
  String get oauthPendingLink => 'Zu diesem Konto hinzufügen';

  @override
  String get oauthPendingLinkHelp => 'Gib das Passwort für dieses Konto ein. Es bleibt weiterhin gültig.';

  @override
  String get oauthPendingTakeOver => 'Dieses Konto übernehmen';

  @override
  String get oauthPendingTakeOverHelp =>
      'Das Passwort und andere Anmeldemethoden werden entfernt. Alle angemeldeten Personen werden abgemeldet.';

  @override
  String get oauthPendingNew => 'Neues Konto erstellen';

  @override
  String oauthPendingNewHelp(String email) {
    return 'Das andere Konto behält seine Gruppen, aber nicht mehr $email.';
  }

  @override
  String get oauthPendingPassword => 'Passwort dieses Kontos';

  @override
  String get oauthPendingWrongPassword => 'Dieses Passwort ist falsch.';

  @override
  String get oauthOtherServer =>
      'Diese Anmeldung wurde auf einem anderen Server begonnen als dem aktuell ausgewählten. Melde dich erneut an.';

  @override
  String get oauthBackToSignIn => 'Zurück zur Anmeldung';

  @override
  String get errorOAuthFailed => 'Anmeldung fehlgeschlagen. Versuch es noch einmal.';

  @override
  String get errorEmailHasAccount =>
      'Für diese E-Mail-Adresse gibt es bereits ein Konto. Melde dich dort an und füge diese Anmeldemethode in den Einstellungen hinzu.';

  @override
  String get errorIdentityTaken => 'Diese Anmeldemethode gehört bereits zu einem anderen Konto.';

  @override
  String get errorLastSignInMethod =>
      'Das ist deine einzige Anmeldemethode. Lege zuerst ein Passwort fest oder füge eine weitere Methode hinzu.';

  @override
  String get errorEmailUnverified => 'Bestätige zuerst deine E-Mail-Adresse.';

  @override
  String get errorOAuthCancelled => 'Anmeldung abgebrochen.';

  @override
  String get importTitle => 'Aus Settle Up importieren';

  @override
  String get importAction => 'Importieren';

  @override
  String get importIntro =>
      'Exportiere in Settle Up die Gruppe als CSV-Datei und wähle sie dann hier aus. Ausgaben, Zahlungen und alle Gruppenmitglieder werden übernommen. Die Salden bleiben gleich.';

  @override
  String get importChooseFile => 'CSV-Datei auswählen';

  @override
  String get importChooseOther => 'Andere Datei auswählen';

  @override
  String get importReading => 'Datei wird gelesen …';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(
      expenses,
      locale: localeName,
      other: '$expenses Ausgaben',
      one: '1 Ausgabe',
    );
    String _temp1 = intl.Intl.pluralLogic(
      payments,
      locale: localeName,
      other: '$payments Zahlungen',
      one: '1 Zahlung',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return '$from bis $to';
  }

  @override
  String importCurrency(String currency) {
    return 'Währung: $currency. Für Einträge in anderen Währungen werden die von Settle Up umgerechneten Beträge verwendet.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge mit Betrag null werden ausgelassen.',
      one: '1 Eintrag mit Betrag null wird ausgelassen.',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => 'Wer bist du?';

  @override
  String get importUntitled => 'Ohne Titel';

  @override
  String get errorImportFile => 'Das sieht nicht nach einem Settle Up CSV-Export aus.';

  @override
  String get errorImportCurrency =>
      'Die Datei enthält keine Einträge ohne Wechselkurs. Daher ist die Währung der Gruppe unklar.';

  @override
  String get errorImportTooBig => 'Diese Datei ist zu groß zum Importieren.';

  @override
  String get errorBadImage =>
      'Dieses Bild kann nicht verwendet werden. Wähle ein JPEG-, PNG- oder WebP-Bild.';

  @override
  String get errorReceiptTooBig => 'Dieses Bild ist zu groß. Wähle ein Bild unter 10 MB.';

  @override
  String get errorImportMe => 'Wähle aus, welche Person du bist.';

  @override
  String errorImportRow(int line, String reason) {
    return 'Zeile $line der Datei kann nicht importiert werden: $reason';
  }

  @override
  String get errorImportAmount => 'ein Betrag kann nicht gelesen werden.';

  @override
  String get errorImportCounts => 'Namen und Beträge stimmen nicht überein.';

  @override
  String get errorImportDate => 'das Datum kann nicht gelesen werden.';

  @override
  String get errorImportType => 'Der Typ ist weder Ausgabe noch Überweisung noch Einnahme.';

  @override
  String get errorImportTransfer => 'Bei einer Überweisung muss eine Person an eine andere zahlen.';

  @override
  String get errorImportRowCurrency => 'die Währung ist eine andere und es fehlt ein Wechselkurs.';

  @override
  String get adminSetupTitle => 'Diesen Server einrichten';

  @override
  String get adminSetupBody =>
      'Lege ein Passwort für den Administrator fest. Es schützt diese Seite mit den Servereinstellungen. Es gibt keinen Benutzernamen: Wer das Passwort kennt, kann die Einstellungen ändern.';

  @override
  String get adminSetupCode => 'Einrichtungscode';

  @override
  String get adminSetupCodeHelp =>
      'Auf diesem Server sind bereits Daten gespeichert. Beim Start wurde ein Einrichtungscode ins Protokoll geschrieben. Mit Docker: docker compose logs balnana';

  @override
  String get adminSetupAction => 'Passwort festlegen';

  @override
  String get adminPassword => 'Administratorpasswort';

  @override
  String get adminPasswordRepeat => 'Passwort wiederholen';

  @override
  String get adminPasswordMismatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get adminLoginTitle => 'Administration';

  @override
  String get adminLoginBody => 'Gib das Administratorpasswort ein, um die Servereinstellungen zu ändern.';

  @override
  String get adminLoginAction => 'Anmelden';

  @override
  String get adminSettingsTitle => 'Servereinstellungen';

  @override
  String get adminSaved => 'Einstellungen gespeichert. Sie gelten sofort.';

  @override
  String get adminSaveFailed => 'Es wurde nichts gespeichert. Prüfe die markierten Einstellungen.';

  @override
  String get adminChangePassword => 'Administratorpasswort ändern';

  @override
  String get adminPasswordCurrent => 'Aktuelles Passwort';

  @override
  String get adminPasswordNew => 'Neues Passwort';

  @override
  String get adminPasswordChanged => 'Passwort geändert. Andere Administratorsitzungen wurden abgemeldet.';

  @override
  String get adminSignOut => 'Von der Administration abmelden';

  @override
  String get adminBackHome => 'Zurück zu Balnana';

  @override
  String get adminRequireEmail => 'E-Mail-Adresse erforderlich';

  @override
  String get adminRequireEmailHelp =>
      'Wenn deaktiviert, melden sich Personen mit einem Benutzernamen an und können die E-Mail-Adresse weglassen. Die Anmeldung ist mit beidem möglich.';

  @override
  String get adminRequireEmailUnused =>
      'Gilt nur für die Anmeldung mit E-Mail-Adresse und Passwort, die deaktiviert ist.';

  @override
  String get accountUsername => 'Benutzername';

  @override
  String get accountUsernameHelp =>
      '3 bis 32 Buchstaben, Ziffern, Punkte, Bindestriche oder Unterstriche. Damit meldest du dich an.';

  @override
  String get accountEmailOptional => 'E-Mail-Adresse (optional)';

  @override
  String get accountEmailOptionalHelp =>
      'Damit kannst du Gruppeneinladungen erhalten und ein vergessenes Passwort zurücksetzen.';

  @override
  String get accountLogin => 'E-Mail-Adresse oder Benutzername';

  @override
  String get errorInvalidUsername =>
      'Verwende 3 bis 32 Buchstaben, Ziffern, Punkte, Bindestriche oder Unterstriche. Der erste Buchstabe muss ein Buchstabe oder eine Ziffer sein.';

  @override
  String get errorUsernameTaken => 'Jemand verwendet diesen Benutzernamen bereits.';

  @override
  String get adminDiscardTitle => 'Änderungen verwerfen?';

  @override
  String get adminDiscardBody => 'Deine Änderungen an den Einstellungen wurden noch nicht gespeichert.';

  @override
  String get adminDiscard => 'Verwerfen';

  @override
  String adminLocked(String key) {
    return 'Auf dem Server durch $key festgelegt';
  }

  @override
  String adminDefault(String value) {
    return 'Standard: $value';
  }

  @override
  String get adminSecretSaved => 'Gespeichert. Gib einen neuen Wert ein, um ihn zu ersetzen.';

  @override
  String get adminSecretRemoved => 'Wird beim Speichern entfernt.';

  @override
  String get adminSecretRemove => 'Gespeicherten Wert entfernen';

  @override
  String get adminSectionGeneral => 'Allgemein';

  @override
  String get adminSectionAccess => 'Zugriff';

  @override
  String get adminSectionMaps => 'Karten';

  @override
  String get adminSectionAccounts => 'Konten';

  @override
  String get adminSectionAccountsBody =>
      'Diese Einstellungen gelten, wenn der Zugriff auf Konten beschränkt ist.';

  @override
  String get adminSectionEmail => 'E-Mail (SMTP)';

  @override
  String get adminSectionEmailBody => 'E-Mail-Bestätigungen, Passwortzurücksetzungen und Einladungen.';

  @override
  String get adminSmtpOn => 'E-Mail versenden';

  @override
  String get adminSectionGoogle => 'Mit Google anmelden';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Registriere $url als Weiterleitungs-URI in der Google Cloud Console.';
  }

  @override
  String get adminGoogleOn => 'Google-Anmeldung anbieten';

  @override
  String get adminGoogleOnHelp => 'Personen melden sich mit ihrem Google-Konto an.';

  @override
  String get adminSectionOidc => 'Mit OpenID Connect anmelden';

  @override
  String adminSectionOidcBody(String url) {
    return 'Registriere $url als Weiterleitungs-URI beim Anbieter.';
  }

  @override
  String get adminOidcHelp =>
      'Beliebiger OpenID-Connect-Anbieter, zum Beispiel Authentik, Keycloak oder Dex. Du kannst beliebig viele hinzufügen.';

  @override
  String get adminOidcAdd => 'Anbieter hinzufügen';

  @override
  String get adminOidcRemove => 'Anbieter entfernen';

  @override
  String get adminOidcNew => 'Neuer Anbieter';

  @override
  String get adminOidcId => 'ID';

  @override
  String get adminOidcIdHelp =>
      'Kleinbuchstaben, Ziffern und Bindestriche. Die ID ist Teil der Weiterleitungs-URI und kann später nicht geändert werden.';

  @override
  String get adminOidcIdInvalid =>
      'Verwende bis zu 32 Kleinbuchstaben, Ziffern und Bindestriche. Der erste Buchstabe muss ein Buchstabe oder eine Ziffer sein.';

  @override
  String get adminOidcIdTaken => 'Ein anderer Anbieter hat diese ID bereits.';

  @override
  String get adminTrustEmail => 'E-Mail-Adresse des Anbieters vertrauen';

  @override
  String get adminGoogleTrustEmailHelp =>
      'Bei einer Google-Anmeldung mit einer E-Mail-Adresse, für die es ein Konto gibt, wird dieses Konto geöffnet. Deaktiviert: Die Person meldet sich mit ihrem Passwort an und fügt Google in den Einstellungen hinzu.';

  @override
  String get adminOidcTrustEmailHelp =>
      'Nur für Anbieter, die du betreibst oder denen du die Prüfung von E-Mail-Adressen anvertraust. Deaktiviert: Personen mit einem Konto melden sich mit ihrem Passwort an und fügen den Anbieter in den Einstellungen hinzu.';

  @override
  String get adminRequireVerified => 'Bestätigte E-Mail-Adresse erforderlich';

  @override
  String get adminRequireVerifiedHelp =>
      'Konten können die App erst nach Bestätigung ihrer E-Mail-Adresse nutzen. Eine vertrauenswürdige Anmeldung mit derselben E-Mail-Adresse übernimmt ein unbestätigtes Konto. Deaktiviert: Personen entscheiden selbst, was geschieht.';

  @override
  String get adminRequireVerifiedUnused => 'Benötigt den E-Mail-Versand.';

  @override
  String get adminSectionAndroid => 'Android-App-Links';

  @override
  String get adminSectionAndroidBody =>
      'Android-Versionen für diesen Server öffnen seine Links in der App. Damit keine Rückfrage erscheint, liste die SHA-256-Fingerabdrücke der Zertifikate auf, mit denen diese Versionen signiert sind.';

  @override
  String get adminSectionAdmin => 'Administrator';

  @override
  String get adminPublicUrl => 'Öffentliche Adresse';

  @override
  String get adminPublicUrlHelp =>
      'Unter dieser Adresse ist der Server erreichbar. Gruppenlinks und E-Mail-Links werden daraus erstellt.';

  @override
  String get adminSourceUrl => 'Link zum Quellcode';

  @override
  String get adminSourceUrlHelp =>
      'Hier finden Personen den Quellcode dieses Servers. Die Lizenz (AGPL-3.0) verlangt das, wenn du eine geänderte Version betreibst.';

  @override
  String get adminAuthMode => 'Zugriff';

  @override
  String get adminAuthModeLink => 'Gruppenlinks';

  @override
  String get adminAuthModeLinkHelp => 'Keine Anmeldung: Der private Link einer Gruppe reicht aus.';

  @override
  String get adminAuthModeAccounts => 'Konten';

  @override
  String get adminAuthModeAccountsHelp =>
      'Personen melden sich an. Über einen Link können nur angemeldete Personen einer Gruppe beitreten.';

  @override
  String get adminPasswordLogin => 'Anmeldung mit E-Mail-Adresse und Passwort';

  @override
  String get adminPasswordForced =>
      'Bleibt aktiviert, bis die Anmeldung mit Google oder OpenID Connect eingerichtet ist, damit immer eine Anmeldemethode verfügbar ist.';

  @override
  String get adminSignup => 'Wer kann ein Konto erstellen?';

  @override
  String get adminSignupOpen => 'Alle';

  @override
  String get adminSignupOpenHelp => 'Alle, die diesen Server erreichen, können sich registrieren.';

  @override
  String get adminSignupInvite => 'Eingeladene Personen';

  @override
  String get adminSignupInviteHelp =>
      'Nur Personen, die per E-Mail zu einer Gruppe eingeladen wurden, können sich registrieren – und nur mit der E-Mail-Adresse, an die die Einladung ging. Gruppenlinks allein gewähren keinen Zugang. Dafür muss der E-Mail-Versand aktiviert sein.';

  @override
  String get adminSignupClosed => 'Niemand';

  @override
  String get adminSignupClosedHelp =>
      'Niemand kann sich registrieren. Bestehende Konten funktionieren weiterhin.';

  @override
  String get adminSignupHelp => 'Das erste Konto kann immer erstellt werden.';

  @override
  String get adminLinkGroups => 'Gruppen können über einen Link geöffnet werden';

  @override
  String get adminLinkGroupsHelp =>
      'Gruppeninhaber können allen mit dem Link den Zugang erlauben, ohne Anmeldung.';

  @override
  String get adminSmtpHost => 'Mailserver';

  @override
  String get adminSmtpPort => 'Port';

  @override
  String get adminSmtpUser => 'Benutzername';

  @override
  String get adminSmtpPassword => 'Passwort';

  @override
  String get adminSmtpFrom => 'Absender';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'Client-ID';

  @override
  String get adminClientSecret => 'Client-Schlüssel';

  @override
  String get adminOidcIssuer => 'Aussteller-URL';

  @override
  String get adminOidcName => 'Name der Schaltfläche';

  @override
  String get adminOidcNameHelp => 'Wird auf der Anmeldeseite als „Weiter mit …“ angezeigt.';

  @override
  String get adminFingerprints => 'Zertifikat-Fingerabdrücke';

  @override
  String get adminFingerprintsHelp =>
      'SHA-256, durch Kommas getrennt. keytool -list -v und apksigner verify --print-certs zeigen sie an.';

  @override
  String get adminInvalidValue => 'Dieser Wert ist ungültig.';

  @override
  String get adminInvalidUrl => 'Gib eine vollständige Adresse ein, die mit https:// oder http:// beginnt.';

  @override
  String get adminInvalidFrom =>
      'Gib einen Absender wie Balnana <balnana@example.com> ein. Eine E-Mail-Adresse ist erforderlich.';

  @override
  String get adminInvalidPort => 'Gib eine Portnummer zwischen 1 und 65535 ein.';

  @override
  String get adminInvalidRequired => 'Dieser Anmeldeanbieter benötigt diesen Wert.';

  @override
  String get adminInvalidFingerprint =>
      'Gib SHA-256-Fingerabdrücke mit jeweils 64 hexadezimalen Ziffern ein. Doppelpunkte sind erlaubt.';

  @override
  String get adminNeedsSignIn =>
      'Konten benötigen eine Anmeldemethode: Aktiviere E-Mail-Adresse und Passwort oder richte einen Anbieter ein.';

  @override
  String get adminLockedChange =>
      'Diese Einstellung wird auf dem Server festgelegt und kann hier nicht geändert werden.';

  @override
  String get errorAdminRequired => 'Deine Administratorsitzung ist abgelaufen. Melde dich erneut an.';

  @override
  String get errorAdminWrongPassword => 'Dieses Passwort ist falsch.';

  @override
  String get errorInvalidSetupCode => 'Dieser Einrichtungscode ist falsch. Suche im Serverprotokoll danach.';

  @override
  String get errorAlreadySetUp =>
      'Dieser Server wurde bereits eingerichtet. Melde dich mit dem Administratorpasswort an.';

  @override
  String get linkOpening => 'Link wird geöffnet …';

  @override
  String get linkForeignTitle => 'Dieser Link gehört zu einem anderen Server';

  @override
  String linkForeignBody(String server) {
    return 'Diese App ist mit $server verbunden, aber der Link gehört zu einem anderen Server. Ändere den Server in den Einstellungen, um ihn zu öffnen.';
  }

  @override
  String get linkInvalidTitle => 'Dieser Link kann nicht geöffnet werden';

  @override
  String get linkInvalidBody => 'Die App kennt diesen Balnana-Link nicht.';

  @override
  String get linkGoHome => 'Zu den Gruppen';

  @override
  String get linkOpenInBrowser => 'Im Browser öffnen';

  @override
  String get privacyTitle => 'Datenschutzerklärung';

  @override
  String get privacyIntro =>
      'Balnana ist quelloffene Software. Die Person, die den Server betreibt, mit dem diese App verbunden ist, entscheidet, wo deine Daten gespeichert werden, und ist dafür verantwortlich. Auf dieser Seite steht, welche Daten die Software selbst speichert und was sie damit tut.';

  @override
  String get privacyStoredTitle => 'Was gespeichert wird';

  @override
  String get privacyStoredBody =>
      'Die Gruppen, denen du beitrittst oder die du erstellst: ihre Namen, die Namen der Mitglieder, Ausgaben, Zahlungen, Notizen, Belegfotos und Orte, die du zu Ausgaben hinzufügst. Bei einem Konto außerdem dein Name, deine E-Mail-Adresse oder dein Benutzername, ein Hash deines Passworts (niemals das Passwort selbst) und dein Anmeldeanbieter, zum Beispiel Google. Wenn Mitteilungen aktiviert sind, eine Kennung deines Geräts und die Adresse, die der Push-Dienst dafür bereitstellt.';

  @override
  String get privacyUseTitle => 'Wie die Daten verwendet werden';

  @override
  String get privacyUseBody =>
      'Nur für den Betrieb der App: um jeder Gruppe ihre Mitglieder anzuzeigen, Salden zu berechnen und nötige E-Mails und Mitteilungen zu versenden, etwa zur Bestätigung einer E-Mail-Adresse, zum Zurücksetzen von Passwörtern und für Einladungen. Die App hat keine Werbung und keine Analysefunktionen. Es werden keine Daten verkauft.';

  @override
  String get privacySharedTitle => 'Wer die Daten sehen kann';

  @override
  String get privacySharedBody =>
      'Alle in einer Gruppe sehen ihre Mitglieder, Ausgaben und den Verlauf. Wenn eine Gruppe über einen Link zugänglich ist, kann sie jeder mit diesem Link öffnen. Die Anmeldung mit Google läuft über Google. Mitteilungen laufen, wenn die betreibende Person sie aktiviert, über den Push-Dienst deines Smartphones: Googles Firebase Cloud Messaging oder einen installierten UnifiedPush-Dienst wie ntfy. Der Inhalt der Mitteilung wird auf dem Übertragungsweg verschlüsselt. Karten laden ihre Bilder vom gewählten Kartenanbieter, standardmäßig OpenFreeMap. Dieser sieht deine Netzwerkadresse und den Bereich, den du aufrufst. Dein Standort wird nur gelesen, wenn du auf „Aktuellen Standort verwenden“ tippst. Gespeichert wird nur der Punkt, den du anschließend übernimmst.';

  @override
  String get privacyDeviceTitle => 'Auf diesem Gerät';

  @override
  String get privacyDeviceBody =>
      'Die App speichert die Serveradresse, deine Einstellungen und eine Kopie deiner Gruppen für die Offline-Nutzung. Wenn du die App deinstallierst, werden diese Daten entfernt.';

  @override
  String get privacyDeleteTitle => 'Deine Daten löschen';

  @override
  String get privacyDeleteBody =>
      'Du kannst dein Konto in den Einstellungen löschen. Dein Name bleibt dann in deinen Gruppen als Mitglied ohne zugeordnetes Konto erhalten, damit die Salden weiterhin stimmen. Gruppen, auf die sonst niemand mehr zugreifen kann, werden ebenfalls gelöscht. Der Inhaber einer Gruppe kann sie in den Gruppeneinstellungen vollständig löschen. Gelöschte Gruppen und die Fotos gelöschter Ausgaben werden nach 30 Tagen endgültig entfernt. Bei allem anderen wende dich an die betreibende Person des Servers.';

  @override
  String get privacyOperatorPolicy => 'Datenschutzerklärung der betreibenden Person';

  @override
  String get privacyLink => 'Datenschutz';

  @override
  String get accountEmailAdd => 'E-Mail-Adresse hinzufügen';

  @override
  String get accountEmailChange => 'E-Mail-Adresse ändern';

  @override
  String get accountEmailNew => 'Neue E-Mail-Adresse';

  @override
  String get accountEmailVerifyNote =>
      'Du erhältst einen Link, um die neue Adresse zu bestätigen. Bis dahin bleibt deine aktuelle Adresse bestehen.';

  @override
  String get accountEmailPendingTitle => 'Neue E-Mail-Adresse bestätigen';

  @override
  String accountEmailPendingHelp(String email) {
    return '$email ersetzt deine aktuelle Adresse, sobald du den dorthin gesendeten Link öffnest. Tippe, um den Link erneut zu senden.';
  }

  @override
  String get accountEmailRemoveNote =>
      'Lass das Feld leer, um deine Adresse zu entfernen. Du kannst dich weiterhin mit deinem Benutzernamen anmelden.';

  @override
  String get accountEmailSaved => 'E-Mail-Adresse gespeichert';

  @override
  String get accountEmailRemoved => 'E-Mail-Adresse entfernt';

  @override
  String get accountConfirmPassword => 'Dein Passwort';

  @override
  String get accountConfirmPasswordHelp => 'Damit wir wissen, dass du es bist.';

  @override
  String get errorEmailNeeded =>
      'Du meldest dich mit deiner E-Mail-Adresse an. Sie kann daher nicht entfernt werden.';

  @override
  String get accountDelete => 'Konto löschen';

  @override
  String get accountDeleteHelp => 'Dein Konto von diesem Server entfernen';

  @override
  String get accountDeleteTitle => 'Konto löschen?';

  @override
  String get accountDeleteBody =>
      'Dein Konto wird endgültig gelöscht und du wirst abgemeldet. In deinen Gruppen bleibt dein Name als Mitglied ohne zugeordnetes Konto erhalten, damit die Salden weiterhin stimmen. Gruppen ohne weitere Mitglieder werden gelöscht.';

  @override
  String get accountDeleteAction => 'Endgültig löschen';

  @override
  String get accountDeleted => 'Dein Konto wurde gelöscht.';

  @override
  String get accountDeletePageSignedOut => 'Melde dich an, um dein Konto auf diesem Server zu löschen.';

  @override
  String get accountDeletePageLinkMode =>
      'Dieser Server verwendet keine Konten. Der Link einer Gruppe reicht aus. Um eine Gruppe mit allen Inhalten zu löschen, öffne ihre Einstellungen und wähle „Gruppe löschen“.';

  @override
  String get groupDelete => 'Gruppe löschen';

  @override
  String get groupDeleteHelp => 'Für alle samt ihren Ausgaben löschen';

  @override
  String groupDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get groupDeleteBody =>
      'Die Gruppe und alle ihre Ausgaben, Zahlungen und ihr Verlauf werden für alle gelöscht. Das lässt sich nicht rückgängig machen. Gib zur Bestätigung den Namen der Gruppe ein.';

  @override
  String get groupDeleteName => 'Gruppenname';

  @override
  String get groupDeleteAction => 'Endgültig löschen';

  @override
  String get groupDeleted => 'Gruppe gelöscht';

  @override
  String get groupDeleteOwnerOnly => 'Nur der Inhaber der Gruppe kann sie löschen.';

  @override
  String get expenseDiscardTitle => 'Änderungen verwerfen?';

  @override
  String get expenseDiscardBody => 'Deine Änderungen an dieser Ausgabe wurden noch nicht gespeichert.';

  @override
  String get expenseDiscard => 'Verwerfen';

  @override
  String get adminPrivacyUrl => 'Link zur Datenschutzerklärung';

  @override
  String get adminPrivacyUrlHelp =>
      'Der Link zu deiner Datenschutzerklärung, den App-Stores verlangen. Wenn das Feld leer ist, zeigt die App eine allgemeine Erklärung zu den von Balnana gespeicherten Daten.';

  @override
  String get adminMapTiles => 'Kartenkacheln';

  @override
  String get adminMapSource => 'Kartenquelle';

  @override
  String get adminMapSourceStyle => 'Vektorkartenstil';

  @override
  String get adminMapSourceStyleHelp =>
      'Karten auf Grundlage eines MapLibre-Stils, zum Beispiel von OpenFreeMap. Dieser ist kostenlos und benötigt keinen Schlüssel.';

  @override
  String get adminMapSourceTiles => 'Rasterkarten';

  @override
  String get adminMapSourceTilesHelp => 'Karten aus Kachelbildern, zum Beispiel von OpenStreetMap.';

  @override
  String get adminMapSourceOff => 'Aus';

  @override
  String get adminMapSourceOffHelp =>
      'Keine Karten. Ortsnamen und Koordinaten bleiben in den Ausgaben erhalten.';

  @override
  String get adminMapStyle => 'Stil-URL';

  @override
  String get adminMapStyleHelp =>
      'Die Adresse einer MapLibre-style.json, zum Beispiel von OpenFreeMap: Liberty (Standard), Bright oder Positron.';

  @override
  String get adminMapTilesHelp =>
      'Eine URL-Vorlage für Rasterkacheln mit z, x und y in geschweiften Klammern, wie die Standardvorlage. Die Server von OpenStreetMap sind nur für geringe Nutzung gedacht. Ein stark ausgelasteter Server sollte einen Kachelanbieter verwenden.';

  @override
  String get adminMapAttribution => 'Kartenangabe';

  @override
  String get adminMapAttributionHelp =>
      'Wird gemäß den Vorgaben des Kartenanbieters auf jeder Karte angezeigt. Wenn das Feld leer ist, zeigt ein Stil die darin angegebenen Quellen an und Kacheln nennen OpenStreetMap.';

  @override
  String get adminInvalidMapTiles =>
      'Gib eine http(s)-URL-Vorlage mit z, x und y in geschweiften Klammern ein.';

  @override
  String get adminUsers => 'Konten';

  @override
  String get adminUsersSearch => 'Nach Name, E-Mail-Adresse oder Benutzername suchen';

  @override
  String adminUsersShown(int shown, int total) {
    return '$shown von $total Konten';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count Konten', one: '1 Konto');
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => 'Keine passenden Konten.';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gruppen',
      one: '1 Gruppe',
      zero: 'Keine Gruppen',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => 'nicht bestätigt';

  @override
  String adminUserDeleteTitle(String name) {
    return 'Konto von $name löschen?';
  }

  @override
  String get adminUserDeleteBody =>
      'Das Konto wird endgültig gelöscht und überall abgemeldet. Der Name bleibt in den Gruppen als Mitglied ohne zugeordnetes Konto erhalten. Gruppen ohne weitere Mitglieder werden gelöscht.';

  @override
  String get adminUserDeleted => 'Konto gelöscht';

  @override
  String get commonDone => 'Fertig';

  @override
  String get crowdSearch => 'Personen suchen';

  @override
  String get crowdNoMatch => 'Niemand gefunden.';

  @override
  String get crowdAll => 'Alle';

  @override
  String get crowdNone => 'Niemand';

  @override
  String crowdChosen(int count, int total) {
    return '$count von $total ausgewählt';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count anzeigen',
      one: 'Noch 1 anzeigen',
    );
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => 'Weniger anzeigen';

  @override
  String get crowdSort => 'Sortieren';

  @override
  String crowdShowAll(int count) {
    return 'Alle $count anzeigen';
  }

  @override
  String get crowdBalances => 'Salden aller';

  @override
  String get crowdSomeoneElse => 'Jemand anderes';

  @override
  String get crowdChoosePayers => 'Zahlende auswählen';

  @override
  String get crowdFilterTitle => 'Wessen Ausgaben?';

  @override
  String get myGroupsTitle => 'Meine Gruppenlinks';

  @override
  String get myGroupsExport => 'Gruppenlinks exportieren';

  @override
  String get myGroupsExportHelp =>
      'Kopiere deine Gruppenlinks als Sicherung oder um sie auf ein anderes Gerät zu übertragen.';

  @override
  String get myGroupsPrivate =>
      'Halte diese Links geheim. Alle mit einem Link können die zugehörige Gruppe öffnen.';

  @override
  String get myGroupsCopy => 'Links kopieren';

  @override
  String get myGroupsImport => 'Gruppen importieren';

  @override
  String get myGroupsImportHelp =>
      'Füge Gruppenlinks von diesem Server ein, einen pro Zeile. Bestehende Gruppen behalten ihren Platz und ihre Identität.';

  @override
  String get myGroupsLinks => 'Gruppenlinks';

  @override
  String get myGroupsImportAction => 'Links importieren';

  @override
  String get myGroupsInvalid => 'Gib gültige Gruppenlinks ein, einen pro Zeile. Es wurde nichts importiert.';

  @override
  String get myGroupsServerChanged =>
      'Der ausgewählte Server hat sich geändert. Schließe diesen Dialog und importiere die Links auf dem zugehörigen Server.';

  @override
  String myGroupsLimit(int count) {
    return 'Importiere höchstens $count Gruppenlinks pro Server. Es wurde nichts importiert.';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Gruppenlinks importiert.',
      one: '1 neuer Gruppenlink importiert.',
      zero: 'Diese Gruppen sind bereits gespeichert.',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => 'Wiederholung';

  @override
  String get repeatNever => 'Keine Wiederholung';

  @override
  String get repeatDaily => 'Täglich';

  @override
  String get repeatWeekly => 'Wöchentlich';

  @override
  String get repeatMonthly => 'Monatlich';

  @override
  String get repeatYearly => 'Jährlich';

  @override
  String get repeatEvery => 'Alle';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Tage', one: 'Tag');
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Wochen', one: 'Woche');
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Monate', one: 'Monat');
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Jahre', one: 'Jahr');
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Tage',
      one: 'Jeden Tag',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Wochen',
      one: 'Jede Woche',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Monate',
      one: 'Jeden Monat',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Jahre',
      one: 'Jedes Jahr',
    );
    return '$_temp0';
  }

  @override
  String get repeatEndNone => 'Kein Enddatum';

  @override
  String repeatEndOn(String date) {
    return 'Bis zum $date';
  }

  @override
  String get repeatEndClear => 'Enddatum entfernen';

  @override
  String get repeatHelp =>
      'Wird an jedem Datum automatisch zur Gruppe hinzugefügt, beginnend mit dem Datum oben. Bereits vergangene Termine werden beim Speichern hinzugefügt.';

  @override
  String get repeatCustom => 'Eigener Zeitplan';

  @override
  String get repeatDropReceiptTitle => 'Beleg entfernen?';

  @override
  String get repeatDropReceiptBody =>
      'Eine wiederkehrende Ausgabe kann keinen Beleg behalten. Du kannst jeder dadurch hinzugefügten Ausgabe einzeln einen Beleg hinzufügen.';

  @override
  String get repeatDropReceiptAction => 'Wiederholen';

  @override
  String get recurringTitle => 'Wiederkehrende Ausgaben';

  @override
  String get recurringHelp => 'Ausgaben, die nach einem Zeitplan automatisch hinzugefügt werden';

  @override
  String get recurringEmptyTitle => 'Keine wiederkehrenden Ausgaben';

  @override
  String get recurringEmptyBody =>
      'Miete, Abos und andere regelmäßige Kosten können automatisch an den jeweiligen Terminen hinzugefügt werden.';

  @override
  String get recurringAdd => 'Wiederkehrende Ausgabe hinzufügen';

  @override
  String get recurringEdit => 'Wiederkehrende Ausgabe bearbeiten';

  @override
  String recurringNext(String date) {
    return 'Als Nächstes am $date';
  }

  @override
  String get recurringPaused => 'Pausiert';

  @override
  String get recurringEnded => 'Beendet';

  @override
  String get recurringPause => 'Pausieren';

  @override
  String get recurringResume => 'Fortsetzen';

  @override
  String get recurringActive => 'Wiederholt sich';

  @override
  String get recurringDelete => 'Löschen';

  @override
  String get recurringDeleteTitle => 'Wiederholung beenden?';

  @override
  String recurringDeleteBody(String title) {
    return '„$title“ wird nicht mehr hinzugefügt. Bereits hinzugefügte Ausgaben bleiben erhalten.';
  }

  @override
  String get recurringDeleted => 'Wiederkehrende Ausgabe gelöscht';

  @override
  String get recurringFromSchedule => 'Von einer wiederkehrenden Ausgabe hinzugefügt';

  @override
  String get recurringOpen => 'Zeitplan ändern';

  @override
  String get recurringMissing => 'Die wiederkehrende Ausgabe wurde gelöscht oder ist nicht mehr verfügbar.';

  @override
  String get errorTooManyDue =>
      'Das Startdatum liegt zu lange zurück. Es würden mehr als 100 Ausgaben auf einmal hinzugefügt.';

  @override
  String get errorInvalidEnd => 'Das Enddatum darf nicht vor dem Startdatum liegen.';

  @override
  String get errorInvalidRepeat => 'Wiederhole alle 1 bis 999 Tage, Wochen, Monate oder Jahre.';

  @override
  String get errorRecurringConflict =>
      'Jemand anderes hat diese wiederkehrende Ausgabe während deiner Bearbeitung geändert. Lade sie neu, um die Änderungen zu sehen.';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$who hat „$title“ auf Wiederholung gesetzt';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$who hat die wiederkehrende Ausgabe „$title“ geändert';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$who hat die wiederkehrende Ausgabe „$title“ pausiert';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return 'Die wiederkehrende Ausgabe „$title“ wurde pausiert, weil jemand daraus die Gruppe verlassen hat';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return 'Die wiederkehrende Ausgabe „$title“ wurde pausiert, weil sie nicht hinzugefügt werden konnte';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$who hat die wiederkehrende Ausgabe „$title“ fortgesetzt';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$who hat die Wiederholung von „$title“ beendet';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return '„$title“ ($amount) wurde automatisch hinzugefügt';
  }

  @override
  String get expenseRecurring => 'Von einer wiederkehrenden Ausgabe hinzugefügt';

  @override
  String get adminPlans => 'Tarife';

  @override
  String get adminPayments => 'Zahlungen';

  @override
  String get adminSectionBilling => 'Tarife und Zahlungen';

  @override
  String get adminSectionBillingBody =>
      'Tarife erhöhen die Grenzen dafür, was dieser Server speichert. Ausgaben teilen und ausgleichen bleibt kostenlos.';

  @override
  String get adminBillingOn => 'Tarife und Grenzen';

  @override
  String get adminBillingOnHelp => 'Wenn aus, begrenzt dieser Server nichts und zeigt keine Tarife.';

  @override
  String get adminBillingNeedsAccounts =>
      'Tarife brauchen Konten: Stelle die Anmeldung zuerst auf Konten um.';

  @override
  String get adminKofiUrl => 'Ko-fi-Seite';

  @override
  String get adminKofiUrlHelp =>
      'Hier wird bezahlt. Nur Versionen, die externe Zahlungen erlauben, verlinken dorthin.';

  @override
  String adminKofiWebhook(String url) {
    return 'Webhook-URL für Ko-fi: $url';
  }

  @override
  String get adminKofiToken => 'Ko-fi-Prüftoken';

  @override
  String get adminKofiTokenHelp =>
      'Steht auf der Webhook-Seite von Ko-fi. Ohne Token ignoriert dieser Server Ko-fi.';

  @override
  String adminUserPlanUntil(String plan, String date) {
    return '$plan bis $date';
  }

  @override
  String get adminPlansHelp =>
      'Eine neue Grenze gilt für das, was als Nächstes hinzukommt. Vorhandenes bleibt. Leer bedeutet keine Grenze.';

  @override
  String get adminPlanAdd => 'Tarif hinzufügen';

  @override
  String adminPlanDefaultName(String name) {
    return '$name (Standard)';
  }

  @override
  String adminPlanLimit(String label, String value) {
    return '$label: $value';
  }

  @override
  String adminPlanDays(int count) {
    return 'Tage: $count';
  }

  @override
  String get adminProductsSection => 'Produkte';

  @override
  String get adminProductsHelp =>
      'Eine Zahlung gehört zum Produkt mit ihrem Stufennamen, sonst zu dem ohne Stufennamen, dessen Betrag sie erreicht.';

  @override
  String get adminProductAdd => 'Produkt hinzufügen';

  @override
  String get adminProductEdit => 'Produkt bearbeiten';

  @override
  String adminProductAnyPayment(String amount) {
    return 'Jede Zahlung ab $amount';
  }

  @override
  String get adminProductName => 'Stufenname';

  @override
  String get adminProductNameHelp =>
      'Wie auf Ko-fi geschrieben. Leer lassen, um einmalige oder monatliche Zahlungen nach dem Betrag zuzuordnen.';

  @override
  String get adminProductPlan => 'Tarif';

  @override
  String get adminProductDays => 'Tage';

  @override
  String get adminProductDaysHelp =>
      'Wie lange eine Zahlung gilt. Eine weitere Zahlung kommt zur Restzeit hinzu.';

  @override
  String get adminProductMinAmount => 'Mindestbetrag';

  @override
  String get adminProductCurrency => 'Währungscode';

  @override
  String get adminPlanId => 'ID';

  @override
  String get adminPlanIdHelp => 'Kleinbuchstaben, Ziffern und Bindestriche. Lässt sich später nicht ändern.';

  @override
  String get adminPlanName => 'Name';

  @override
  String get adminPlanRank => 'Rang';

  @override
  String get adminPlanRankHelp => 'Ein Konto mit mehreren Tarifen erhält den mit dem höchsten Rang.';

  @override
  String get adminPlanDefault => 'Standardtarif';

  @override
  String get adminPlanDefaultHelp => 'Für jedes Konto ohne anderen Tarif.';

  @override
  String adminPlanRemoveTitle(String name) {
    return '$name entfernen?';
  }

  @override
  String adminPlanRemoveBody(String products) {
    return 'Die zugehörigen Produkte werden mit entfernt und können nicht mehr gekauft werden: $products';
  }

  @override
  String get adminEntitlementGranted => 'Von einem Administrator vergeben';

  @override
  String get adminEntitlementRevoked => 'Widerrufen';

  @override
  String get adminEntitlementForever => 'Kein Enddatum';

  @override
  String adminEntitlementUntil(String date) {
    return 'Bis $date';
  }

  @override
  String adminEntitlementEnded(String date) {
    return 'Beendet am $date';
  }

  @override
  String get adminEntitlementsEmpty => 'Dieses Konto hat noch keine Tarife.';

  @override
  String get adminEntitlementRevoke => 'Widerrufen';

  @override
  String adminEntitlementRevokeTitle(String plan) {
    return '$plan widerrufen?';
  }

  @override
  String adminEntitlementRevokeBody(String user) {
    return '$user verliert diesen Tarif sofort. Das lässt sich nicht rückgängig machen.';
  }

  @override
  String get adminEntitlementNote => 'Notiz';

  @override
  String get adminEntitlementGrant => 'Tarif vergeben';

  @override
  String get adminPaymentApplied => 'Angewendet';

  @override
  String get adminPaymentUnclaimed => 'Nicht beansprucht';

  @override
  String get adminPaymentUnmatched => 'Nicht zugeordnet';

  @override
  String get adminPaymentsAll => 'Alle';

  @override
  String adminPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zahlungen',
      one: '1 Zahlung',
    );
    return '$_temp0';
  }

  @override
  String get adminPaymentsEmpty => 'Keine Zahlungen.';

  @override
  String get adminPaymentAssigned => 'Tarif an das Konto vergeben.';

  @override
  String get adminPaymentAssign => 'Einem Konto zuweisen';

  @override
  String get adminPaymentPickUser => 'Wähle ein Konto aus.';

  @override
  String get errorBillingOff => 'Dieser Server hat keine Tarife.';

  @override
  String get errorAlreadySponsored => 'Der Tarif eines anderen Mitglieds gilt bereits für diese Gruppe.';

  @override
  String get errorPlanInUse => 'Konten oder Produkte nutzen diesen Tarif noch.';

  @override
  String get errorPaymentApplied => 'Diese Zahlung wurde bereits angewendet.';

  @override
  String get errorPaymentNotFound =>
      'Noch keine Zahlung mit dieser ID. Wenn du gerade bezahlt hast, versuche es in einer Minute erneut.';

  @override
  String get errorPaymentNoPlan =>
      'Diese Zahlung passt zu keinem Tarif. Bitte die Serveradministration, sie zuzuordnen.';

  @override
  String get errorInvalidPlan => 'Prüfe die Tarifeinstellungen: Etwas darin ist ungültig.';

  @override
  String errorLimitReceipts(int max) {
    return 'Diese Gruppe hat ihre Grenze von $max Belegfotos erreicht.';
  }

  @override
  String errorLimitRecurring(int max) {
    return 'Diese Gruppe hat ihre Grenze von $max wiederkehrenden Ausgaben erreicht.';
  }

  @override
  String errorLimitJoinedGroups(int max) {
    return 'Du hast deine Grenze von $max Gruppen erreicht.';
  }

  @override
  String errorLimitMembers(int max) {
    return 'Diese Gruppe hat ihre Grenze von $max Personen erreicht.';
  }

  @override
  String errorLimitSponsored(int max) {
    return 'Dein Tarif lässt sich mit höchstens $max Gruppen teilen.';
  }

  @override
  String get errorLimitOther => 'Du hast eine Grenze dieses Servers erreicht.';

  @override
  String get planTitle => 'Tarif';

  @override
  String get planUnlimited => 'Keine Grenze';

  @override
  String planUntil(String date) {
    return 'Bis $date';
  }

  @override
  String get planSettingsHelp => 'Was dieser Server für dich speichert';

  @override
  String get planIntro =>
      'Teilen und Ausgleichen sind immer kostenlos. Ein Tarif ändert nur, wie viel dieser Server für dich speichert.';

  @override
  String planUsage(int used, int limit) {
    return '$used von $limit';
  }

  @override
  String planUsed(int used) {
    return '$used genutzt';
  }

  @override
  String get planLimits => 'Grenzen';

  @override
  String get planLimitReceipts => 'Belegfotos pro Gruppe';

  @override
  String get planLimitRecurring => 'Wiederkehrende Ausgaben pro Gruppe';

  @override
  String get planLimitJoinedGroups => 'Gruppen, in denen du bist';

  @override
  String get planLimitMembers => 'Personen pro Gruppe';

  @override
  String get planLimitSponsored => 'Gruppen, die deinen Tarif teilen';

  @override
  String get planGet => 'Tarif holen';

  @override
  String get planKofi => 'Ko-fi';

  @override
  String get planKofiHelp =>
      'Füge deinen Zahlungscode in die Ko-fi-Nachricht ein, damit die Zahlung dein Konto erreicht.';

  @override
  String get planPaymentCodeHelp => 'Dein Zahlungscode. Zum Kopieren tippen.';

  @override
  String get planPaymentCodeCopied => 'Zahlungscode kopiert';

  @override
  String get planPaymentClaim => 'Code vergessen?';

  @override
  String get planPaymentClaimHelp => 'Füge eine Zahlung mit ihrer Ko-fi-Transaktions-ID hinzu.';

  @override
  String get planPaymentClaimField => 'Transaktions-ID oder Zahlungslink';

  @override
  String get planPaymentClaimAction => 'Zahlung hinzufügen';

  @override
  String get planPaymentClaimed => 'Zahlung hinzugefügt';

  @override
  String groupPlanUsage(String members, String receipts, String recurring) {
    return 'Personen: $members · Belegfotos: $receipts · Wiederkehrend: $recurring';
  }

  @override
  String get groupSponsor => 'Meinen Tarif mit dieser Gruppe teilen';

  @override
  String get groupUnsponsor => 'Tarif nicht mehr teilen';

  @override
  String groupSponsoredBy(String name) {
    return 'Nutzt den Tarif von $name';
  }

  @override
  String get accountDeletePlayNote =>
      'Ein Google-Play-Abo endet nicht mit deinem Konto. Kündige es zuerst bei Google Play.';

  @override
  String get planPlayManage => 'Abo verwalten';

  @override
  String get planPlayManageHelp => 'Bei Google Play ändern oder kündigen';

  @override
  String planPlayPrice(int months, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'alle $months Monate',
      one: 'pro Monat',
    );
    return '$price $_temp0';
  }

  @override
  String get planPlayFailed => 'Google Play konnte den Kauf nicht abschließen.';

  @override
  String get planPlayPending =>
      'Deine Zahlung wird noch verarbeitet. Der Tarif beginnt, sobald sie durch ist.';

  @override
  String get planPlayOnHold =>
      'Deine letzte Zahlung ist fehlgeschlagen. Aktualisiere deine Zahlungsmethode bei Google Play, um diesen Tarif zu behalten.';

  @override
  String get planPlayHeldElsewhere =>
      'Dieses Google-Play-Konto hat bereits ein Abo, das eventuell zu einem anderen Balnana-Konto gehört.';

  @override
  String get planPlayUnavailable => 'Google Play ist nicht erreichbar. Versuch es später noch einmal.';

  @override
  String get errorInvalidPurchase => 'Google Play kennt diesen Kauf nicht.';

  @override
  String get errorPlayOtherAccount =>
      'Dieses Abo gehört zu einem anderen Konto. Melde dich dort an oder kündige es bei Google Play.';

  @override
  String get errorPlayUnavailable => 'Google Play ist nicht erreichbar. Versuche es gleich noch einmal.';

  @override
  String get adminPlayPackage => 'Google-Play-Paketname';

  @override
  String get adminPlayPackageHelp =>
      'Die ID der App bei Google Play. Zusammen mit dem Dienstkonto unten schaltet sie Google-Play-Abos ein.';

  @override
  String get adminPlayServiceAccount => 'Google-Play-Dienstkonto';

  @override
  String get adminPlayServiceAccountHelp =>
      'Der JSON-Schlüssel eines Dienstkontos, das in der Play Console Bestellungen und Abos ansehen und verwalten darf.';

  @override
  String get adminPlayPushAccount => 'Pub/Sub-Push-Konto';

  @override
  String get adminPlayPushAccountHelp =>
      'Die E-Mail-Adresse des Dienstkontos, mit dem Pub/Sub seine Zustellungen signiert. Ohne sie kommen Verlängerungen erst an, wenn jemand die Tarifseite öffnet.';

  @override
  String adminPlayWebhook(String url) {
    return 'Pub/Sub-Push-Endpunkt, auch als Zielgruppe: $url';
  }

  @override
  String get adminProductProvider => 'Bezahlt über';

  @override
  String get adminProductPlayId => 'Produkt-ID';

  @override
  String get adminProductPlayIdHelp =>
      'Wie in der Play Console geschrieben. Google Play bestimmt, wann jede Zahlung endet, daher gibt es keine Tage einzustellen.';

  @override
  String get adminProductRemoveBody =>
      'Zahlungen dafür werden Konten nicht mehr gutgeschrieben. Bestehende Tarife bleiben bis zu ihrem Ende aktiv.';

  @override
  String get errorRecentSignIn =>
      'Melde dich zu deiner Sicherheit ab und wieder an und versuche es dann noch einmal.';

  @override
  String get errorTooManyGroups => 'Das sind zu viele Gruppen auf einmal.';

  @override
  String get errorInvalidTimeZone => 'Die Zeitzone dieses Geräts wird nicht erkannt.';

  @override
  String get errorInvalidColor => 'Diese Farbe kann nicht verwendet werden.';

  @override
  String get errorPushOff => 'Dieser Server sendet keine Benachrichtigungen.';

  @override
  String paymentRecordedEarlier(String amount) {
    return 'Ein früherer Versuch hat bereits $amount erfasst. Es wurde nichts Neues hinzugefügt.';
  }

  @override
  String get refreshFailed => 'Aktualisierung fehlgeschlagen. Die Angaben sind möglicherweise veraltet.';
}
