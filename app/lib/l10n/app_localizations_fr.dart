// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get languageEndonym => 'Français';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get offlineBar =>
      'Hors ligne. Voici les données enregistrées sur cet appareil ; les modifications ne seront pas enregistrées avant votre reconnexion.';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonClear => 'Effacer';

  @override
  String get iconChoose => 'Choisir une icône';

  @override
  String get iconNone => 'Aucune icône';

  @override
  String get iconSearchHint => 'Rechercher ou saisir un emoji';

  @override
  String get iconUseTyped => 'Utiliser cet emoji';

  @override
  String get iconNoMatch => 'Aucune icône ne correspond. Saisissez un emoji pour l’utiliser.';

  @override
  String get iconSectionTravel => 'Voyages et lieux';

  @override
  String get iconSectionFood => 'Repas et boissons';

  @override
  String get iconSectionActivities => 'Activités';

  @override
  String get iconSectionHome => 'Logement et factures';

  @override
  String get iconSectionPeople => 'Personnes';

  @override
  String get iconSectionNature => 'Animaux et nature';

  @override
  String get iconSectionObjects => 'Argent et objets';

  @override
  String get iconSectionSymbols => 'Symboles';

  @override
  String get commonRemove => 'Supprimer';

  @override
  String get commonUndo => 'Annuler';

  @override
  String get someone => 'Quelqu’un';

  @override
  String get errorTooLarge => 'Le fichier est trop volumineux pour être envoyé au serveur.';

  @override
  String get errorBusy => 'Le serveur est occupé. Réessayez dans un instant.';

  @override
  String get errorTimeout => 'L’envoi a pris trop de temps. Vérifiez votre connexion et réessayez.';

  @override
  String get errorBadOrigin =>
      'Le serveur n’accepte pas les connexions depuis cette adresse. La personne qui le gère doit vérifier son URL publique.';

  @override
  String get errorInvalidCategory => 'Cette catégorie a été supprimée entre-temps. Choisissez-en une autre.';

  @override
  String get errorBuiltinCategory => 'Les catégories intégrées peuvent uniquement être masquées.';

  @override
  String get errorUnknownMember =>
      'Une personne concernée ne fait plus partie du groupe. Rechargez la page et réessayez.';

  @override
  String get errorNoPayers => 'Choisissez qui a payé.';

  @override
  String get errorPayerTotal => 'La somme payée par chaque personne doit correspondre au montant total.';

  @override
  String get errorPayerTooSmall =>
      'La part payée par une personne est nulle dans la devise du groupe. Vérifiez les montants.';

  @override
  String get errorInvalidNote =>
      'La note est trop longue ou contient des caractères qui ne peuvent pas être enregistrés.';

  @override
  String get errorInvalidDate => 'Cette date n’est pas autorisée.';

  @override
  String get errorGeneric => 'Une erreur s’est produite. Réessayez.';

  @override
  String get errorNetwork => 'Impossible de joindre le serveur. Vérifiez votre connexion.';

  @override
  String get errorNotFound => 'Cet élément n’existe plus.';

  @override
  String get errorRequired => 'Obligatoire';

  @override
  String get errorInvalidName => 'Saisissez un nom de 100 caractères maximum.';

  @override
  String get errorDuplicateName => 'Une personne de ce groupe porte déjà ce nom.';

  @override
  String get errorTooManyMembers => 'Ce groupe a atteint le nombre maximal de personnes.';

  @override
  String get errorTooManyCategories => 'Ce groupe a atteint le nombre maximal de catégories.';

  @override
  String get errorDuplicateCategory => 'Ce groupe comporte déjà une catégorie portant ce nom.';

  @override
  String get errorInvalidCurrency => 'Saisissez un code de devise à trois lettres, comme USD.';

  @override
  String get errorInvalidTitle => 'Saisissez un titre de 200 caractères maximum.';

  @override
  String get errorInvalidLocation => 'Saisissez un lieu sur une seule ligne, de 200 caractères maximum.';

  @override
  String get errorInvalidSymbol => 'Saisissez un symbole de 8 caractères maximum.';

  @override
  String get errorInvalidEmoji => 'Choisissez un seul emoji comme icône.';

  @override
  String get errorMemberHasBalance => 'Réglez le solde de cette personne avant de la supprimer.';

  @override
  String get errorVersionConflict =>
      'Une autre personne a modifié cette dépense pendant que vous la modifiiez. Rechargez la page pour voir ses changements.';

  @override
  String get errorSignInRequired => 'Connectez-vous pour effectuer cette action.';

  @override
  String get errorRateLimited => 'Trop de requêtes. Attendez une minute, puis réessayez.';

  @override
  String get errorNotAMember => 'Vous ne faites pas encore partie de ce groupe.';

  @override
  String get errorNotAllowed =>
      'Seule cette personne ou le propriétaire du groupe peut effectuer cette action.';

  @override
  String get errorLinkGroupsOff => 'Ce serveur ne permet pas d’ouvrir un groupe avec son seul lien.';

  @override
  String get errorMemberClaimed => 'Une personne a déjà rejoint le groupe sous cette identité.';

  @override
  String get errorMemberLeft => 'Une personne concernée a quitté le groupe.';

  @override
  String get errorInvalidEmail => 'Saisissez une adresse e-mail.';

  @override
  String get errorInvalidPassword => 'Utilisez entre 8 et 200 caractères.';

  @override
  String get errorEmailTaken => 'Un compte utilise déjà cette adresse e-mail. Connectez-vous plutôt.';

  @override
  String get errorSignupClosed => 'Ce serveur n’accepte pas de nouveaux comptes.';

  @override
  String get errorInvalidCredentials => 'Cette adresse e-mail et ce mot de passe ne correspondent pas.';

  @override
  String get errorWrongPassword => 'Votre mot de passe actuel est incorrect.';

  @override
  String get errorAccountsOff => 'Ce serveur n’utilise pas de comptes.';

  @override
  String get errorInvalidAmount => 'Saisissez un montant supérieur à zéro.';

  @override
  String get errorTooManyDecimals => 'Cette devise n’autorise pas autant de décimales.';

  @override
  String get errorAmountTooLarge => 'Ce montant est trop élevé.';

  @override
  String get errorNoShares => 'Choisissez au moins une personne avec qui partager le coût.';

  @override
  String get errorInvalidShare => 'Chaque part doit être un nombre.';

  @override
  String get errorExactTotal => 'La somme des montants doit correspondre au total.';

  @override
  String get errorPayersTotal => 'La somme payée par tout le monde doit correspondre au total.';

  @override
  String get categoryFood => 'Repas et boissons';

  @override
  String get categoryGroceries => 'Courses';

  @override
  String get categoryTransport => 'Transports';

  @override
  String get categoryTravel => 'Voyages';

  @override
  String get categoryLodging => 'Hébergement';

  @override
  String get categoryRent => 'Loyer';

  @override
  String get categoryUtilities => 'Charges';

  @override
  String get categoryEntertainment => 'Loisirs';

  @override
  String get categoryShopping => 'Achats';

  @override
  String get categoryHealth => 'Santé';

  @override
  String get categoryGifts => 'Cadeaux';

  @override
  String get categoryOther => 'Autre';

  @override
  String get groupNew => 'Nouveau groupe';

  @override
  String get groupSwitch => 'Changer de groupe';

  @override
  String get groupReorder => 'Faire glisser pour réorganiser';

  @override
  String get groupCreate => 'Créer un groupe';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
      zero: 'Aucune personne',
    );
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return 'On vous doit $amount';
  }

  @override
  String pillOwe(String amount) {
    return 'Vous devez $amount';
  }

  @override
  String get pillSettled => 'Soldé';

  @override
  String get groupMissingTitle => 'Groupe introuvable';

  @override
  String get groupMissingBody =>
      'Ce groupe a été supprimé ou son lien a été réinitialisé. Demandez le nouveau lien à une personne du groupe.';

  @override
  String get groupLockedTitle => 'Connectez-vous pour ouvrir ce groupe';

  @override
  String get groupLockedBody =>
      'Ce groupe est réservé aux comptes de ses membres. Connectez-vous au compte qui en fait partie.';

  @override
  String get groupForget => 'Retirer de cet appareil';

  @override
  String get groupLinkOtherServer =>
      'Ce lien appartient à un autre serveur. Connectez-vous à ce serveur pour l’ouvrir.';

  @override
  String get openLinkTitle => 'Ouvrir un lien de groupe';

  @override
  String get openLinkBody => 'Collez un lien qu’on vous a envoyé pour rejoindre un groupe.';

  @override
  String get openLinkLabel => 'Lien du groupe';

  @override
  String get openLinkAction => 'Ouvrir';

  @override
  String get openLinkInvalid => 'Ce lien ne semble pas être un lien de groupe Balnana.';

  @override
  String get groupName => 'Nom du groupe';

  @override
  String get groupNameHint => 'Voyage à Lisbonne';

  @override
  String get groupCurrency => 'Devise';

  @override
  String get groupCurrencyHelp =>
      'Toutes les dépenses de ce groupe utilisent cette devise. Vous ne pourrez plus la changer.';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name. Toutes les dépenses de ce groupe utilisent cette devise. Vous ne pourrez plus la changer.';
  }

  @override
  String get currencyChoose => 'Choisir une devise';

  @override
  String get currencySearchHint => 'Rechercher par code ou nom';

  @override
  String get currencySuggested => 'Suggestions';

  @override
  String get currencyAll => 'Toutes les devises';

  @override
  String currencyUseTyped(String code) {
    return 'Utiliser $code';
  }

  @override
  String get currencyNoMatch =>
      'Aucune devise ne correspond. Saisissez son code à trois lettres pour l’utiliser.';

  @override
  String get groupSymbol => 'Symbole';

  @override
  String get groupSymbolChoose => 'Choisir un symbole';

  @override
  String groupSymbolExample(String example) {
    return 'Les montants s’affichent comme $example';
  }

  @override
  String get groupColor => 'Couleur';

  @override
  String colorSwatch(int number, int count) {
    return 'Couleur $number sur $count';
  }

  @override
  String get groupPeople => 'Personnes';

  @override
  String get groupYourName => 'Votre nom';

  @override
  String groupPersonName(int number) {
    return 'Personne $number';
  }

  @override
  String get groupAddPerson => 'Ajouter une personne';

  @override
  String get groupPeopleHelp =>
      'Vous pourrez ajouter d’autres personnes plus tard, ou elles pourront rejoindre le groupe avec le lien.';

  @override
  String get identityTitle => 'Qui êtes-vous ?';

  @override
  String get identityBody =>
      'Choisissez votre nom pour que Balnana affiche ce que vous devez. Seul cet appareil s’en souviendra.';

  @override
  String get identityNew => 'Je suis une nouvelle personne';

  @override
  String get identityNewTitle => 'Rejoindre ce groupe';

  @override
  String get identityJoin => 'Rejoindre';

  @override
  String get identityChange => 'Votre identité';

  @override
  String get identityNone => 'Pas encore de choix';

  @override
  String get memberName => 'Nom';

  @override
  String memberYou(String name) {
    return '$name (vous)';
  }

  @override
  String get memberAdd => 'Ajouter une personne';

  @override
  String get memberAddTitle => 'Ajouter une personne';

  @override
  String get memberRename => 'Renommer';

  @override
  String get memberRenameTitle => 'Renommer';

  @override
  String memberRemoveTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get memberRemoveBody =>
      'Cette personne restera dans les anciennes dépenses, mais ne pourra plus être ajoutée aux nouvelles.';

  @override
  String get groupLinkCopied => 'Lien copié. Toute personne disposant de ce lien peut ouvrir le groupe.';

  @override
  String get groupShare => 'Partager le lien';

  @override
  String get groupSettings => 'Paramètres du groupe';

  @override
  String get groupEdit => 'Modifier le groupe';

  @override
  String get groupSharing => 'Partage';

  @override
  String get groupCopyLink => 'Copier le lien';

  @override
  String get groupQrCode => 'Afficher le QR code';

  @override
  String get groupQrCodeHelp =>
      'Les personnes peuvent scanner le lien avec l’appareil photo de leur téléphone.';

  @override
  String groupQrLabel(String group) {
    return 'QR code du lien vers $group';
  }

  @override
  String get groupCopyLinkHelp => 'Toute personne qui a le lien peut voir et modifier ce groupe.';

  @override
  String get groupCopyLinkHelpAccounts =>
      'Les personnes qui ont le lien peuvent demander à rejoindre le groupe après s’être connectées.';

  @override
  String get linkAccessTitle => 'Accessible à toute personne ayant le lien';

  @override
  String get linkAccessHelp => 'Permettre de voir et modifier le groupe sans compte';

  @override
  String get resetLinkTitle => 'Réinitialiser le lien';

  @override
  String get resetLinkHelp => 'Créer un nouveau lien ; l’ancien ne fonctionnera plus';

  @override
  String get resetLinkBody =>
      'Le lien actuel ne fonctionnera plus pour personne. Partagez le nouveau lien avec les personnes qui doivent garder l’accès.';

  @override
  String get resetLinkAction => 'Réinitialiser';

  @override
  String get resetLinkDone => 'Lien réinitialisé. Partagez le nouveau.';

  @override
  String get groupThisDevice => 'Cet appareil';

  @override
  String get groupData => 'Données';

  @override
  String get categoriesTitle => 'Catégories';

  @override
  String get categoriesHelp => 'Ajoutez vos catégories ou masquez celles que vous n’utilisez pas.';

  @override
  String get categoriesOwn => 'Personnalisées';

  @override
  String get categoriesOwnEmpty => 'Aucune catégorie personnalisée pour le moment.';

  @override
  String get categoriesBuiltIn => 'Intégrées';

  @override
  String get categoriesBuiltInHelp =>
      'Les catégories masquées ne sont pas proposées pour les nouvelles dépenses. Les dépenses qui en ont une la conservent.';

  @override
  String get categoryAdd => 'Ajouter une catégorie';

  @override
  String get categoryEdit => 'Modifier la catégorie';

  @override
  String get categoryName => 'Nom';

  @override
  String get categoryDelete => 'Supprimer la catégorie';

  @override
  String categoryDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get categoryDeleteBody => 'Les dépenses de cette catégorie n’auront plus de catégorie.';

  @override
  String get categoryDeleteAction => 'Supprimer';

  @override
  String get exportCsv => 'Exporter en CSV';

  @override
  String get exportCsvHelp => 'Toutes les dépenses et tous les règlements, pour un tableur';

  @override
  String get exportCsvDone => 'Exporté';

  @override
  String get forgetTitle => 'Retirer de cet appareil';

  @override
  String get forgetHelp => 'Le groupe reste sur le serveur pour les autres personnes.';

  @override
  String get forgetBody => 'Vous pourrez l’ouvrir à nouveau avec le lien.';

  @override
  String get groupYou => 'Vous';

  @override
  String get leaveTitle => 'Quitter le groupe';

  @override
  String get leaveHelp => 'Vos dépenses restent ; vous pourrez rejoindre le groupe avec le lien';

  @override
  String get leaveBody =>
      'Le groupe disparaîtra de votre liste. Vos dépenses et votre solde resteront dans le groupe.';

  @override
  String get leaveAction => 'Quitter';

  @override
  String get tabExpenses => 'Dépenses';

  @override
  String get heroWhoTitle => 'Qui êtes-vous dans ce groupe ?';

  @override
  String get heroWhoBody => 'Choisissez votre nom pour voir ce que vous devez et ce qu’on vous doit.';

  @override
  String get heroWhoAction => 'Choisir';

  @override
  String get heroJoinTitle => 'Vous consultez ce groupe';

  @override
  String get heroJoinBody => 'Rejoignez le groupe pour ajouter des dépenses et voir ce que vous devez.';

  @override
  String get joinAction => 'Rejoindre';

  @override
  String get heroOwed => 'On vous doit';

  @override
  String get heroOwe => 'Vous devez';

  @override
  String get heroSettled => 'Vous êtes à l’équilibre';

  @override
  String heroYouAre(String name) {
    return 'Vous êtes $name';
  }

  @override
  String get expenseAdd => 'Ajouter une dépense';

  @override
  String get expensesEmptyTitle => 'Aucune dépense pour le moment';

  @override
  String get expensesEmptyBody => 'Ajoutez la première dépense et Balnana calculera qui doit quoi à qui.';

  @override
  String get expensesSearchHint => 'Rechercher dans les titres, notes et lieux';

  @override
  String get searchClear => 'Effacer la recherche';

  @override
  String get expensesNoMatchTitle => 'Aucun résultat';

  @override
  String get expensesNoMatchBody => 'Essayez d’autres mots ou réduisez le nombre de filtres.';

  @override
  String get filterAnyone => 'Tout le monde';

  @override
  String get filterAnyCategory => 'Toutes les catégories';

  @override
  String get filterPayments => 'Règlements';

  @override
  String get filterClear => 'Effacer les filtres';

  @override
  String get periodAll => 'Depuis le début';

  @override
  String get periodThisMonth => 'Ce mois-ci';

  @override
  String get periodLastMonth => 'Le mois dernier';

  @override
  String get periodThisYear => 'Cette année';

  @override
  String get periodPickDays => 'Choisir des dates…';

  @override
  String get statsTitle => 'Dépenses';

  @override
  String get statsTotal => 'Total dépensé';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dépenses',
      one: '1 dépense',
      zero: 'Aucune dépense',
    );
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'Par catégorie';

  @override
  String get statsByMember => 'Payé et part par personne';

  @override
  String get statsPaid => 'Payé';

  @override
  String get statsShare => 'Part';

  @override
  String get statsByMonth => 'Par mois';

  @override
  String get statsNoCategory => 'Sans catégorie';

  @override
  String get statsEmptyTitle => 'Aucune dépense';

  @override
  String get statsEmptyBody => 'Il n’y a aucune dépense sur cette période.';

  @override
  String get statsShowExpenses => 'Afficher ces dépenses';

  @override
  String get dateToday => 'Aujourd’hui';

  @override
  String get dateYesterday => 'Hier';

  @override
  String paymentTitle(String from, String to) {
    return '$from a payé $to';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name a payé $amount';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return '$count personnes ont payé $amount';
  }

  @override
  String expensePaidByName(String name) {
    return '$name a payé';
  }

  @override
  String expensePaidByManyNames(int count) {
    return '$count personnes ont payé';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name a reçu $amount';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$name a reçu';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return '$count personnes ont reçu';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return '$count personnes ont reçu $amount';
  }

  @override
  String get transactionRefund => 'Remboursement';

  @override
  String get transactionIncome => 'Revenu';

  @override
  String get paymentDelete => 'Supprimer le règlement';

  @override
  String get paymentDeleted => 'Règlement supprimé';

  @override
  String expenseDeleted(String title) {
    return '« $title » supprimé';
  }

  @override
  String get expenseNew => 'Nouvelle dépense';

  @override
  String get expenseEdit => 'Modifier la dépense';

  @override
  String get expenseDelete => 'Supprimer';

  @override
  String get expenseAmount => 'Montant';

  @override
  String get expenseTitle => 'À quoi correspond cette dépense ?';

  @override
  String get expenseTitleHint => 'Dîner, billets, taxi…';

  @override
  String get expenseAmountFromPayers => 'Total payé par tout le monde';

  @override
  String expensePaidIn(String currency) {
    return 'Payé en $currency';
  }

  @override
  String expenseRate(String from, String to) {
    return '1 $from en $to';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return 'Total en $currency';
  }

  @override
  String expenseForeignHelp(String currency) {
    return 'Les soldes restent en $currency. Saisissez le taux ou le montant final, indiqué par exemple sur votre relevé de carte.';
  }

  @override
  String get expenseNote => 'Note';

  @override
  String get expenseNoteHint => 'Facultatif';

  @override
  String get expenseLocation => 'Lieu';

  @override
  String get expenseLocationHint => 'Où était-ce ? (facultatif)';

  @override
  String get locationPickOnMap => 'Choisir sur la carte';

  @override
  String get locationUseCurrent => 'Utiliser ma position actuelle';

  @override
  String get locationFinding => 'Recherche de votre position…';

  @override
  String get locationChange => 'Modifier sur la carte';

  @override
  String get locationRemovePin => 'Retirer le repère';

  @override
  String get locationOpenInMaps => 'Ouvrir dans Maps';

  @override
  String get locationPickTitle => 'Choisir un lieu';

  @override
  String get locationPickHint => 'Touchez la carte pour placer un repère';

  @override
  String get locationPickDone => 'Terminé';

  @override
  String get locationDenied =>
      'Balnana n’a pas accès à votre position. Vous pouvez l’autoriser dans les paramètres de votre appareil ou de votre navigateur.';

  @override
  String get locationOff => 'La géolocalisation est désactivée sur cet appareil.';

  @override
  String get locationUnavailable =>
      'Impossible de trouver votre position. Réessayez ou placez un repère sur la carte.';

  @override
  String get expenseReceipt => 'Justificatif';

  @override
  String get expenseHasReceipt => 'Photo du justificatif disponible';

  @override
  String get expenseHasLocation => 'Lieu indiqué';

  @override
  String get receiptTakePhoto => 'Prendre une photo';

  @override
  String get receiptChoose => 'Choisir une image';

  @override
  String get receiptRemove => 'Supprimer';

  @override
  String get receiptView => 'Photo du justificatif';

  @override
  String receiptNotSaved(String reason) {
    return 'La dépense a été enregistrée, mais pas la photo du justificatif. $reason';
  }

  @override
  String get expensePaidByLabel => 'Payé par';

  @override
  String get expenseReceivedForLabel => 'Reçu pour';

  @override
  String get expenseReceivedByLabel => 'Reçu par';

  @override
  String get expenseMultiplePayers => 'Plusieurs personnes';

  @override
  String get expenseSplit => 'Répartition';

  @override
  String get splitEqual => 'À parts égales';

  @override
  String get splitExact => 'Montants';

  @override
  String get splitShares => 'Parts';

  @override
  String splitLeft(String amount) {
    return 'Il reste $amount à répartir';
  }

  @override
  String splitOver(String amount) {
    return '$amount en trop';
  }

  @override
  String get conflictTitle => 'Modifié ailleurs';

  @override
  String get conflictReload => 'Recharger';

  @override
  String get expenseChangedElsewhere =>
      'Une autre personne a modifié cette dépense. Rechargez la page pour voir sa version et abandonner vos modifications.';

  @override
  String get suggestedPayments => 'Règlements suggérés';

  @override
  String get allSettled => 'Tout le monde est quitte.';

  @override
  String transferYouPay(String name) {
    return 'Vous payez $name';
  }

  @override
  String transferPaysYou(String name) {
    return '$name vous paie';
  }

  @override
  String transferPays(String from, String to) {
    return '$from paie $to';
  }

  @override
  String get recordPayment => 'Enregistrer';

  @override
  String get recordPaymentTitle => 'Enregistrer un règlement';

  @override
  String get recordPaymentHelp => 'Enregistrez uniquement les sommes réellement payées en dehors de Balnana.';

  @override
  String get paymentRecorded => 'Règlement enregistré';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who a créé $group';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who a modifié les informations du groupe';
  }

  @override
  String activityLinkReset(String who) {
    return '$who a réinitialisé le lien du groupe';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who a ajouté $name';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who a renommé $oldName en $name';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who a supprimé $name';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who a ajouté la catégorie $name';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who a modifié les catégories';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who a supprimé la catégorie $name';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name a rejoint le groupe';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who a ajouté « $title » ($amount)';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who a modifié « $title » ($amount)';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who a supprimé « $title »';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who a restauré « $title »';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who a enregistré le règlement de $amount de $from à $to';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who a supprimé un règlement de $amount';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who a restauré un règlement de $amount';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées',
      one: '1 entrée',
      zero: 'Aucune entrée',
    );
    return '$who a importé $_temp0 depuis $source';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who a ajouté une photo du justificatif à « $title »';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who a supprimé la photo du justificatif de « $title »';
  }

  @override
  String activityOther(String who) {
    return '$who a effectué une modification';
  }

  @override
  String get navGroups => 'Groupes';

  @override
  String get navActivity => 'Activité';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get groupsEmptyTitle => 'Aucun groupe pour le moment';

  @override
  String get groupsEmptyBody => 'Les groupes que vous créez ou ouvrez avec un lien s’afficheront ici.';

  @override
  String get groupsNoServerTitle => 'Connectez-vous à un serveur';

  @override
  String get groupsNoServerBody =>
      'Balnana conserve vos groupes sur le serveur de votre choix, par exemple un serveur que vous hébergez.';

  @override
  String get groupsNoServerAction => 'Choisir un serveur';

  @override
  String get groupsUnreachableTitle => 'Impossible de joindre le serveur';

  @override
  String get groupsUnreachableBody => 'Vérifiez votre connexion ou l’adresse du serveur dans les paramètres.';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groupes n’ont pas pu être chargés ; leurs modifications sont donc absentes.',
      one: 'Un groupe n’a pas pu être chargé ; ses modifications sont donc absentes.',
      zero: 'Aucun groupe n’a pu être chargé ; ses modifications sont donc absentes.',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => 'Rien pour le moment';

  @override
  String get activityEmptyBody =>
      'Les nouvelles dépenses et les nouveaux règlements de vos groupes s’afficheront ici.';

  @override
  String get notFoundTitle => 'Page introuvable';

  @override
  String get notFoundBody => 'Cette adresse ne mène à aucune page de Balnana.';

  @override
  String get notFoundAction => 'Voir les groupes';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get accountRename => 'Changer de nom';

  @override
  String get passwordChange => 'Changer le mot de passe';

  @override
  String get passwordChanged => 'Mot de passe modifié. Les autres appareils sont déconnectés.';

  @override
  String get passwordSet => 'Créer un mot de passe';

  @override
  String get passwordSetHelp =>
      'Connectez-vous aussi avec votre e-mail ou nom d’utilisateur et un mot de passe.';

  @override
  String get passwordSetDone => 'Mot de passe créé. Les autres appareils sont déconnectés.';

  @override
  String get passwordCurrent => 'Mot de passe actuel';

  @override
  String get passwordNew => 'Nouveau mot de passe';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get accountOAuthLinked => 'Utilisé pour vous connecter. Touchez pour le supprimer.';

  @override
  String get accountOAuthAdd => 'Ajouter une méthode de connexion';

  @override
  String accountOAuthAddTitle(String name) {
    return 'Ajouter $name';
  }

  @override
  String accountOAuthAdded(String name) {
    return 'Vous pouvez maintenant vous connecter avec $name.';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return 'Vous ne pourrez plus vous connecter avec $name avant de l’ajouter à nouveau.';
  }

  @override
  String get accountOAuthRemove => 'Supprimer';

  @override
  String accountOAuthRemoved(String name) {
    return '$name supprimé.';
  }

  @override
  String get confirmEmailTitle => 'Confirmer votre adresse e-mail';

  @override
  String confirmEmailBody(String email) {
    return 'Ce serveur exige une adresse e-mail confirmée. Ouvrez le lien envoyé à $email.';
  }

  @override
  String get confirmEmailDone => 'J’ai confirmé';

  @override
  String get confirmEmailResend => 'Renvoyer le lien';

  @override
  String get confirmEmailNotYet => 'Adresse pas encore confirmée. Ouvrez le lien reçu par e-mail.';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSystem => 'Par défaut du système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsDynamicColor => 'Couleurs du fond d’écran';

  @override
  String get settingsDynamicColorSubtitle =>
      'Utiliser les couleurs de votre appareil plutôt que le jaune de Balnana';

  @override
  String get settingsWallpaperGroups => 'Couleurs du fond d’écran dans les groupes';

  @override
  String get settingsWallpaperGroupsSubtitle => 'Les groupes utilisent aussi les couleurs de votre appareil';

  @override
  String get settingsPureBlack => 'Noir profond';

  @override
  String get settingsPureBlackSubtitle => 'Un thème sombre encore plus foncé pour les écrans OLED';

  @override
  String get settingsMyShare => 'Afficher ma part';

  @override
  String get settingsMyShareSubtitle =>
      'Les dépenses affichent ce que vous avez avancé ou emprunté plutôt que le total';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Par défaut du système';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Quand quelqu’un ajoute, modifie ou supprime une dépense à laquelle vous participez';

  @override
  String get settingsNotificationsBlocked =>
      'Bloquées dans les paramètres du téléphone : autorisez les notifications de Balnana pour les recevoir.';

  @override
  String get pushChannel => 'Dépenses';

  @override
  String get pushChannelDescription =>
      'Quand quelqu’un ajoute, modifie ou supprime une dépense à laquelle vous participez';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who a ajouté $title · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who a modifié $title · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who a supprimé $title · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return '$title a été ajouté · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return '$title a été modifié · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return '$title a été supprimé · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payer a réglé $amount à $payee';
  }

  @override
  String get settingsConnection => 'Connexion';

  @override
  String get settingsServer => 'Serveur';

  @override
  String get serverNotSet => 'Non défini';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicenses => 'Licences open source';

  @override
  String get aboutSource => 'Code source';

  @override
  String get aboutSourceCopied => 'Impossible d’ouvrir un navigateur ; le lien a été copié';

  @override
  String get serverTitle => 'Serveur';

  @override
  String get serverIntro =>
      'Saisissez l’adresse d’un serveur Balnana. Tout le monde peut en héberger un ; son adresse correspond généralement à celle de son application web.';

  @override
  String get serverUrlLabel => 'Adresse du serveur';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => 'Tester la connexion';

  @override
  String get serverSaveAnyway => 'Enregistrer quand même';

  @override
  String get serverReset => 'Utiliser la valeur par défaut';

  @override
  String serverDefault(String url) {
    return 'Par défaut : $url';
  }

  @override
  String serverConnected(String version) {
    return 'Connexion réussie à Balnana $version';
  }

  @override
  String get serverModeLink => 'Les groupes sont partagés avec un lien privé. Aucun compte nécessaire.';

  @override
  String get serverModeAccounts => 'Les personnes se connectent avec un compte.';

  @override
  String get serverInsecure =>
      'Cette adresse n’est pas chiffrée (http). Les personnes sur le réseau pourraient lire vos données. Utilisez https pour les serveurs situés hors de votre réseau domestique.';

  @override
  String get serverErrorInvalid => 'Saisissez une adresse web, par exemple balnana.example.com';

  @override
  String get serverErrorUnreachable =>
      'Connexion impossible. Vérifiez l’adresse et que le serveur est en marche.';

  @override
  String get serverErrorNotBalnana => 'Le serveur a répondu, mais ce n’est pas un serveur Balnana.';

  @override
  String get serverSaved => 'Serveur enregistré';

  @override
  String get signIn => 'Se connecter';

  @override
  String get groupSignInTitle => 'Connectez-vous pour ouvrir ce groupe';

  @override
  String get groupSignInBody =>
      'Ce groupe est réservé à ses membres. Connectez-vous pour le consulter ou le rejoindre.';

  @override
  String get signInTitle => 'Bon retour';

  @override
  String get signInBody => 'Connectez-vous pour voir vos groupes.';

  @override
  String get signInNoPassword =>
      'Ce serveur utilise une autre méthode de connexion. Demandez à la personne qui le gère.';

  @override
  String get registerTitle => 'Créer votre compte';

  @override
  String get registerBody => 'Retrouvez vos groupes sur tous vos appareils.';

  @override
  String get registerAction => 'Créer un compte';

  @override
  String get registerHaveAccount => 'J’ai déjà un compte';

  @override
  String get signInNoAccount => 'Créer un compte';

  @override
  String get accountName => 'Votre nom';

  @override
  String get accountNameHelp => 'Le nom visible par les personnes de vos groupes';

  @override
  String get accountEmail => 'E-mail';

  @override
  String get accountPassword => 'Mot de passe';

  @override
  String get accountPasswordHelp => '8 caractères minimum';

  @override
  String get passwordShow => 'Afficher le mot de passe';

  @override
  String get passwordHide => 'Masquer le mot de passe';

  @override
  String get joinPickName => 'Choisir un autre nom';

  @override
  String joinTitle(String name) {
    return 'Rejoindre $name';
  }

  @override
  String get joinBody =>
      'Êtes-vous l’une de ces personnes ? Choisissez votre nom pour reprendre vos dépenses.';

  @override
  String get joinBodyNew => 'Rejoignez le groupe pour ajouter des dépenses et voir votre solde.';

  @override
  String get joinAsNew => 'Je suis une nouvelle personne';

  @override
  String joinAsName(String name) {
    return 'Rejoindre en tant que $name';
  }

  @override
  String joinTaken(String names) {
    return 'Déjà rejoint par : $names';
  }

  @override
  String joinTakenCount(int count) {
    return '$count personnes ont déjà rejoint le groupe.';
  }

  @override
  String get commonContinue => 'Continuer';

  @override
  String get errorEmailOff => 'Ce serveur n’envoie pas d’e-mails.';

  @override
  String get errorInvalidToken => 'Ce lien a expiré ou a déjà été utilisé.';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié ?';

  @override
  String get forgotPasswordBody =>
      'Nous vous enverrons un lien par e-mail pour choisir un nouveau mot de passe.';

  @override
  String get forgotPasswordAction => 'Envoyer le lien';

  @override
  String get forgotPasswordSent => 'Si un compte existe pour cette adresse, un lien est en route.';

  @override
  String get resetPasswordTitle => 'Choisir un nouveau mot de passe';

  @override
  String get resetPasswordBody =>
      'Vous serez déconnecté de tous vos appareils. Vous pourrez ensuite vous connecter avec le nouveau mot de passe.';

  @override
  String get resetPasswordAction => 'Enregistrer le mot de passe';

  @override
  String get resetPasswordDone => 'Mot de passe modifié. Connectez-vous avec votre nouveau mot de passe.';

  @override
  String get verifyEmailTitle => 'Confirmer votre adresse e-mail';

  @override
  String get verifyEmailHelp => 'Pour pouvoir réinitialiser votre mot de passe si vous l’oubliez';

  @override
  String verifyEmailSent(String email) {
    return 'Un lien a été envoyé à $email.';
  }

  @override
  String get verifyEmailDone => 'Adresse e-mail confirmée';

  @override
  String get verifyEmailDoneBody => 'Merci ! Votre adresse est confirmée.';

  @override
  String get verifyEmailFailed => 'Impossible de confirmer votre adresse e-mail';

  @override
  String get inviteByEmail => 'Inviter par e-mail';

  @override
  String get inviteByEmailHelp => 'Envoyer un lien pour rejoindre le groupe';

  @override
  String get inviteAs => 'Rejoindre en tant que';

  @override
  String get inviteAsHelp => 'Cette personne pourra reprendre les dépenses de ce membre.';

  @override
  String get inviteAsAnyone => 'Nouvelle personne';

  @override
  String get inviteSend => 'Envoyer l’invitation';

  @override
  String inviteSent(String email) {
    return 'Invitation envoyée à $email.';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name vous invite à rejoindre $group';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return 'Invitation pour $group';
  }

  @override
  String inviteBody(String email) {
    return 'Créez un compte avec l’adresse $email pour rejoindre le groupe, ou connectez-vous si vous en avez déjà un.';
  }

  @override
  String get inviteBodySignedIn => 'Rejoignez le groupe pour ajouter des dépenses et voir votre solde.';

  @override
  String get inviteAction => 'Ouvrir l’invitation';

  @override
  String get inviteMissingTitle => 'Cette invitation ne fonctionne pas';

  @override
  String get inviteMissingBody => 'Elle a peut-être expiré ou déjà été utilisée. Demandez-en une nouvelle.';

  @override
  String get joinInvitedAs => 'Vous avez été invité à rejoindre le groupe sous ce nom';

  @override
  String signInWith(String provider) {
    return 'Continuer avec $provider';
  }

  @override
  String get signInOr => 'ou';

  @override
  String get oauthFailedTitle => 'Impossible de vous connecter';

  @override
  String get oauthPendingTitle => 'Cette adresse e-mail a déjà un compte';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider indique que $email vous appartient, mais le compte associé à cette adresse n’a pas été confirmé. Que voulez-vous faire ?';
  }

  @override
  String get oauthPendingLink => 'Ajouter à ce compte';

  @override
  String get oauthPendingLinkHelp => 'Saisissez le mot de passe de ce compte. Il restera valide.';

  @override
  String get oauthPendingTakeOver => 'Récupérer ce compte';

  @override
  String get oauthPendingTakeOverHelp =>
      'Son mot de passe et ses autres méthodes de connexion seront supprimés, et toutes les sessions ouvertes seront fermées.';

  @override
  String get oauthPendingNew => 'Créer un nouveau compte';

  @override
  String oauthPendingNewHelp(String email) {
    return 'L’autre compte gardera ses groupes, mais n’aura plus l’adresse $email.';
  }

  @override
  String get oauthPendingPassword => 'Mot de passe de ce compte';

  @override
  String get oauthPendingWrongPassword => 'Ce mot de passe est incorrect.';

  @override
  String get oauthOtherServer =>
      'Cette connexion a été commencée sur un autre serveur que celui sélectionné. Recommencez la connexion.';

  @override
  String get oauthBackToSignIn => 'Retour à la connexion';

  @override
  String get errorOAuthFailed => 'La connexion a échoué. Réessayez.';

  @override
  String get errorEmailHasAccount =>
      'Un compte utilise déjà cette adresse e-mail. Connectez-vous, puis ajoutez cette méthode de connexion dans les paramètres.';

  @override
  String get errorIdentityTaken => 'Cette méthode de connexion est déjà associée à un autre compte.';

  @override
  String get errorLastSignInMethod =>
      'C’est votre seule méthode de connexion. Créez un mot de passe ou ajoutez-en une autre avant de la supprimer.';

  @override
  String get errorEmailUnverified => 'Confirmez d’abord votre adresse e-mail.';

  @override
  String get errorOAuthCancelled => 'La connexion a été annulée.';

  @override
  String get importTitle => 'Importer depuis Settle Up';

  @override
  String get importAction => 'Importer';

  @override
  String get importIntro =>
      'Dans Settle Up, exportez le groupe en fichier CSV, puis choisissez-le ici. Les dépenses, les règlements et tous les membres seront importés, et les soldes resteront identiques.';

  @override
  String get importChooseFile => 'Choisir un fichier CSV';

  @override
  String get importChooseOther => 'Choisir un autre fichier';

  @override
  String get importReading => 'Lecture du fichier…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(
      expenses,
      locale: localeName,
      other: '$expenses dépenses',
      one: '1 dépense',
      zero: 'Aucune dépense',
    );
    String _temp1 = intl.Intl.pluralLogic(
      payments,
      locale: localeName,
      other: '$payments règlements',
      one: '1 règlement',
      zero: 'Aucun règlement',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return 'Du $from au $to';
  }

  @override
  String importCurrency(String currency) {
    return 'Devise : $currency. Pour les entrées dans d’autres devises, les montants convertis par Settle Up seront utilisés.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées à zéro sont ignorées.',
      one: '1 entrée à zéro est ignorée.',
      zero: 'Aucune entrée à zéro n’est ignorée.',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => 'Laquelle de ces personnes êtes-vous ?';

  @override
  String get importUntitled => 'Sans titre';

  @override
  String get errorImportFile => 'Ce fichier ne semble pas être un export CSV de Settle Up.';

  @override
  String get errorImportCurrency =>
      'Le fichier ne contient aucune entrée sans taux de change ; impossible de déterminer la devise du groupe.';

  @override
  String get errorImportTooBig => 'Ce fichier est trop volumineux pour être importé.';

  @override
  String get errorBadImage =>
      'Cette image ne peut pas être utilisée. Choisissez une image JPEG, PNG ou WebP.';

  @override
  String get errorReceiptTooBig => 'Cette image est trop volumineuse. Choisissez-en une de moins de 10 Mo.';

  @override
  String get errorImportMe => 'Choisissez la personne que vous êtes.';

  @override
  String errorImportRow(int line, String reason) {
    return 'Impossible d’importer la ligne $line du fichier : $reason';
  }

  @override
  String get errorImportAmount => 'impossible de lire un montant.';

  @override
  String get errorImportCounts => 'les noms et les montants ne correspondent pas.';

  @override
  String get errorImportDate => 'impossible de lire la date.';

  @override
  String get errorImportType => 'le type n’est ni une dépense, ni un transfert, ni un revenu.';

  @override
  String get errorImportTransfer =>
      'un transfert doit correspondre à un paiement d’une personne à une autre.';

  @override
  String get errorImportRowCurrency => 'le montant est dans une autre devise sans taux de change.';

  @override
  String get adminSetupTitle => 'Configurer ce serveur';

  @override
  String get adminSetupBody =>
      'Choisissez un mot de passe administrateur. Il protège cette page, où se trouvent les paramètres du serveur. Il n’y a pas de nom d’utilisateur : toute personne qui connaît le mot de passe peut modifier les paramètres.';

  @override
  String get adminSetupCode => 'Code de configuration';

  @override
  String get adminSetupCodeHelp =>
      'Ce serveur contient déjà des données. Son code de configuration a été écrit dans le journal au démarrage. Avec Docker : docker compose logs balnana';

  @override
  String get adminSetupAction => 'Définir le mot de passe';

  @override
  String get adminPassword => 'Mot de passe administrateur';

  @override
  String get adminPasswordRepeat => 'Répéter le mot de passe';

  @override
  String get adminPasswordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get adminLoginTitle => 'Administration';

  @override
  String get adminLoginBody =>
      'Saisissez le mot de passe administrateur pour modifier les paramètres de ce serveur.';

  @override
  String get adminLoginAction => 'Se connecter';

  @override
  String get adminSettingsTitle => 'Paramètres du serveur';

  @override
  String get adminSaved => 'Paramètres enregistrés. Ils sont appliqués immédiatement.';

  @override
  String get adminSaveFailed => 'Aucun paramètre n’a été enregistré. Vérifiez les champs signalés.';

  @override
  String get adminChangePassword => 'Changer le mot de passe administrateur';

  @override
  String get adminPasswordCurrent => 'Mot de passe actuel';

  @override
  String get adminPasswordNew => 'Nouveau mot de passe';

  @override
  String get adminPasswordChanged =>
      'Mot de passe modifié. Les autres sessions administrateur sont déconnectées.';

  @override
  String get adminSignOut => 'Se déconnecter de l’administration';

  @override
  String get adminBackHome => 'Retour à Balnana';

  @override
  String get adminRequireEmail => 'Adresse e-mail obligatoire';

  @override
  String get adminRequireEmailHelp =>
      'Si cette option est désactivée, les personnes peuvent s’inscrire avec un nom d’utilisateur sans indiquer d’adresse e-mail. Elles peuvent se connecter avec l’un ou l’autre.';

  @override
  String get adminRequireEmailUnused =>
      'S’applique uniquement à la connexion par e-mail et mot de passe, actuellement désactivée.';

  @override
  String get accountUsername => 'Nom d’utilisateur';

  @override
  String get accountUsernameHelp =>
      '3 à 32 lettres, chiffres, points, tirets ou traits de soulignement. Vous pourrez l’utiliser pour vous connecter.';

  @override
  String get accountEmailOptional => 'E-mail (facultatif)';

  @override
  String get accountEmailOptionalHelp =>
      'Permet de recevoir des invitations de groupe et de réinitialiser un mot de passe oublié.';

  @override
  String get accountLogin => 'E-mail ou nom d’utilisateur';

  @override
  String get errorInvalidUsername =>
      'Utilisez 3 à 32 lettres, chiffres, points, tirets ou traits de soulignement. Commencez par une lettre ou un chiffre.';

  @override
  String get errorUsernameTaken => 'Ce nom d’utilisateur est déjà utilisé.';

  @override
  String get adminDiscardTitle => 'Abandonner les modifications ?';

  @override
  String get adminDiscardBody => 'Vos modifications des paramètres n’ont pas été enregistrées.';

  @override
  String get adminDiscard => 'Abandonner';

  @override
  String adminLocked(String key) {
    return 'Défini sur le serveur par $key';
  }

  @override
  String adminDefault(String value) {
    return 'Par défaut : $value';
  }

  @override
  String get adminSecretSaved => 'Enregistré. Saisissez une nouvelle valeur pour la remplacer.';

  @override
  String get adminSecretRemoved => 'La valeur sera supprimée à l’enregistrement.';

  @override
  String get adminSecretRemove => 'Supprimer la valeur enregistrée';

  @override
  String get adminSectionGeneral => 'Général';

  @override
  String get adminSectionAccess => 'Accès';

  @override
  String get adminSectionMaps => 'Cartes';

  @override
  String get adminSectionAccounts => 'Comptes';

  @override
  String get adminSectionAccountsBody =>
      'Ces paramètres s’appliquent lorsque l’accès aux groupes se fait par compte.';

  @override
  String get adminSectionEmail => 'E-mail (SMTP)';

  @override
  String get adminSectionEmailBody =>
      'Confirmation d’adresse, réinitialisation du mot de passe et invitations.';

  @override
  String get adminSmtpOn => 'Envoyer des e-mails';

  @override
  String get adminSectionGoogle => 'Connexion avec Google';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Enregistrez $url comme URI de redirection dans la console Google Cloud.';
  }

  @override
  String get adminGoogleOn => 'Proposer la connexion avec Google';

  @override
  String get adminGoogleOnHelp => 'Les personnes se connectent avec leur compte Google.';

  @override
  String get adminSectionOidc => 'Connexion avec OpenID Connect';

  @override
  String adminSectionOidcBody(String url) {
    return 'Enregistrez $url comme URI de redirection auprès du fournisseur.';
  }

  @override
  String get adminOidcHelp =>
      'Tout fournisseur OpenID Connect, comme Authentik, Keycloak ou Dex. Ajoutez-en autant que vous voulez.';

  @override
  String get adminOidcAdd => 'Ajouter un fournisseur';

  @override
  String get adminOidcRemove => 'Supprimer le fournisseur';

  @override
  String get adminOidcNew => 'Nouveau fournisseur';

  @override
  String get adminOidcId => 'ID';

  @override
  String get adminOidcIdHelp =>
      'Lettres minuscules, chiffres et tirets. Cet identifiant fait partie de l’URI de redirection et ne pourra plus être modifié.';

  @override
  String get adminOidcIdInvalid =>
      'Utilisez jusqu’à 32 lettres minuscules, chiffres et tirets, en commençant par une lettre ou un chiffre.';

  @override
  String get adminOidcIdTaken => 'Un autre fournisseur utilise déjà cet ID.';

  @override
  String get adminTrustEmail => 'Faire confiance à l’adresse e-mail';

  @override
  String get adminGoogleTrustEmailHelp =>
      'Si l’adresse du compte existe, la connexion Google ouvre ce compte. Désactivé : la personne se connecte avec son mot de passe et ajoute Google dans les paramètres.';

  @override
  String get adminOidcTrustEmailHelp =>
      'À utiliser uniquement avec un fournisseur que vous gérez ou qui vérifie les adresses e-mail de façon fiable. Désactivé : les personnes ayant un compte se connectent avec leur mot de passe et ajoutent ce fournisseur dans les paramètres.';

  @override
  String get adminRequireVerified => 'Exiger une adresse e-mail confirmée';

  @override
  String get adminRequireVerifiedHelp =>
      'Les comptes ne peuvent pas utiliser l’application avant d’avoir confirmé leur adresse. Une connexion approuvée avec la même adresse reprend un compte non confirmé. Désactivé : la personne choisit la marche à suivre.';

  @override
  String get adminRequireVerifiedUnused => 'Nécessite l’envoi d’e-mails.';

  @override
  String get adminSectionAndroid => 'Liens d’application Android';

  @override
  String get adminSectionAndroidBody =>
      'Les versions Android conçues pour ce serveur ouvrent ses liens dans l’application. Pour ne pas demander de confirmation, indiquez les empreintes SHA-256 des certificats utilisés pour signer ces versions.';

  @override
  String get adminSectionAdmin => 'Administrateur';

  @override
  String get adminPublicUrl => 'Adresse publique';

  @override
  String get adminPublicUrlHelp =>
      'Adresse utilisée pour accéder à ce serveur. Les liens de groupe et d’e-mail sont créés à partir de cette adresse.';

  @override
  String get adminSourceUrl => 'Lien vers le code source';

  @override
  String get adminSourceUrlHelp =>
      'Adresse où trouver le code source de ce serveur, comme l’exige sa licence (AGPL-3.0) si vous utilisez une version modifiée.';

  @override
  String get adminAuthMode => 'Accès';

  @override
  String get adminAuthModeLink => 'Liens de groupe';

  @override
  String get adminAuthModeLinkHelp => 'Sans connexion : le lien privé du groupe suffit pour y accéder.';

  @override
  String get adminAuthModeAccounts => 'Comptes';

  @override
  String get adminAuthModeAccountsHelp =>
      'Les personnes se connectent avec un compte ; le lien permet uniquement aux personnes connectées de rejoindre un groupe.';

  @override
  String get adminPasswordLogin => 'Connexion par e-mail et mot de passe';

  @override
  String get adminPasswordForced =>
      'Cette option reste activée jusqu’à ce que la connexion avec Google ou OpenID Connect soit activée, pour que vous puissiez toujours vous connecter.';

  @override
  String get adminSignup => 'Qui peut créer un compte ?';

  @override
  String get adminSignupOpen => 'Tout le monde';

  @override
  String get adminSignupOpenHelp => 'Toute personne qui peut accéder à ce serveur peut créer un compte.';

  @override
  String get adminSignupInvite => 'Personnes invitées';

  @override
  String get adminSignupInviteHelp =>
      'Seules les personnes invitées à un groupe par e-mail peuvent créer un compte, et uniquement avec l’adresse de l’invitation. Un lien de groupe ne suffit pas. L’envoi d’e-mails doit être activé pour utiliser les invitations.';

  @override
  String get adminSignupClosed => 'Personne';

  @override
  String get adminSignupClosedHelp =>
      'Personne ne peut créer de compte. Les comptes existants restent actifs.';

  @override
  String get adminSignupHelp => 'Le premier compte peut toujours être créé.';

  @override
  String get adminLinkGroups => 'Les groupes peuvent être ouverts avec un lien';

  @override
  String get adminLinkGroupsHelp =>
      'Les propriétaires de groupe peuvent autoriser toute personne ayant le lien à rejoindre le groupe sans se connecter.';

  @override
  String get adminSmtpHost => 'Serveur de messagerie';

  @override
  String get adminSmtpPort => 'Port';

  @override
  String get adminSmtpUser => 'Nom d’utilisateur';

  @override
  String get adminSmtpPassword => 'Mot de passe';

  @override
  String get adminSmtpFrom => 'Expéditeur';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'ID client';

  @override
  String get adminClientSecret => 'Clé secrète du client';

  @override
  String get adminOidcIssuer => 'URL de l’émetteur';

  @override
  String get adminOidcName => 'Nom du bouton';

  @override
  String get adminOidcNameHelp => 'S’affiche comme « Continuer avec… » sur la page de connexion.';

  @override
  String get adminFingerprints => 'Empreintes des certificats';

  @override
  String get adminFingerprintsHelp =>
      'SHA-256, séparées par des virgules. keytool -list -v et apksigner verify --print-certs permettent de les afficher.';

  @override
  String get adminInvalidValue => 'Cette valeur n’est pas valide.';

  @override
  String get adminInvalidUrl => 'Saisissez une adresse complète commençant par https:// ou http://.';

  @override
  String get adminInvalidFrom =>
      'Saisissez un expéditeur comme Balnana <balnana@example.com> ; une adresse e-mail est nécessaire.';

  @override
  String get adminInvalidPort => 'Saisissez un numéro de port entre 1 et 65535.';

  @override
  String get adminInvalidRequired => 'Ce fournisseur de connexion en a besoin.';

  @override
  String get adminInvalidFingerprint =>
      'Saisissez des empreintes SHA-256 de 64 caractères hexadécimaux chacune ; les deux-points sont autorisés.';

  @override
  String get adminNeedsSignIn =>
      'Les comptes nécessitent une méthode de connexion : activez l’e-mail et le mot de passe, ou configurez un fournisseur.';

  @override
  String get adminLockedChange => 'Cette valeur est définie sur le serveur et ne peut pas être modifiée ici.';

  @override
  String get errorAdminRequired => 'Votre session administrateur a expiré. Connectez-vous à nouveau.';

  @override
  String get errorAdminWrongPassword => 'Ce mot de passe est incorrect.';

  @override
  String get errorInvalidSetupCode =>
      'Ce code de configuration est incorrect. Recherchez-le dans le journal du serveur.';

  @override
  String get errorAlreadySetUp =>
      'Ce serveur est déjà configuré. Connectez-vous avec son mot de passe administrateur.';

  @override
  String get linkOpening => 'Ouverture du lien…';

  @override
  String get linkForeignTitle => 'Ce lien correspond à un autre serveur';

  @override
  String linkForeignBody(String server) {
    return 'Cette application est connectée à $server, mais le lien appartient à un autre serveur. Changez de serveur dans les paramètres pour l’ouvrir.';
  }

  @override
  String get linkInvalidTitle => 'Impossible d’ouvrir ce lien';

  @override
  String get linkInvalidBody => 'L’application ne reconnaît pas ce lien Balnana.';

  @override
  String get linkGoHome => 'Voir les groupes';

  @override
  String get linkOpenInBrowser => 'Ouvrir dans le navigateur';

  @override
  String get privacyTitle => 'Politique de confidentialité';

  @override
  String get privacyIntro =>
      'Balnana est un logiciel open source. La personne qui gère le serveur auquel cette application est connectée décide où vos données sont conservées et en est responsable. Cette page décrit les données enregistrées et les actions effectuées par le logiciel lui-même.';

  @override
  String get privacyStoredTitle => 'Données enregistrées';

  @override
  String get privacyStoredBody =>
      'Les groupes que vous créez ou rejoignez : leur nom, celui de leurs membres, les dépenses, les règlements, les notes, les photos de justificatifs et les lieux ajoutés aux dépenses. Avec un compte, sont aussi enregistrés votre nom, votre adresse e-mail ou nom d’utilisateur, une version hachée de votre mot de passe (jamais le mot de passe lui-même) et le fournisseur de connexion utilisé, comme Google. Si les notifications sont activées, un identifiant de votre appareil et l’adresse fournie par son service de notifications push sont également enregistrés.';

  @override
  String get privacyUseTitle => 'Utilisation des données';

  @override
  String get privacyUseBody =>
      'Les données servent uniquement au fonctionnement de l’application : afficher chaque groupe à ses membres, calculer les soldes et envoyer les e-mails et notifications nécessaires, comme la confirmation d’adresse, la réinitialisation des mots de passe et les invitations. L’application n’affiche pas de publicité, n’utilise pas d’outil d’analyse et ne vend rien.';

  @override
  String get privacySharedTitle => 'Qui peut voir vos données ?';

  @override
  String get privacySharedBody =>
      'Les membres d’un groupe voient ses membres, ses dépenses et son historique. Si un groupe est accessible par lien, toute personne qui a ce lien peut l’ouvrir. La connexion avec Google passe par Google. Si la personne qui gère le serveur active les notifications, elles passent par le service push de votre téléphone : Google Firebase Cloud Messaging ou un autre service UnifiedPush que vous avez installé, comme ntfy. Le contenu des notifications est chiffré pendant le transfert. Les cartes chargent leurs images auprès du fournisseur choisi par la personne qui gère le serveur : OpenFreeMap par défaut, sauf changement. Ce fournisseur voit votre adresse réseau et la zone consultée. Votre position n’est lue que si vous touchez « Utiliser ma position actuelle » ; seul le point que vous choisissez ensuite est enregistré.';

  @override
  String get privacyDeviceTitle => 'Sur cet appareil';

  @override
  String get privacyDeviceBody =>
      'L’application conserve l’adresse du serveur, vos paramètres et une copie de vos groupes pour les consulter hors ligne. La désinstallation de l’application les supprime.';

  @override
  String get privacyDeleteTitle => 'Supprimer vos données';

  @override
  String get privacyDeleteBody =>
      'Vous pouvez supprimer votre compte dans les paramètres. Votre nom restera alors dans vos groupes comme membre non revendiqué, afin que les soldes restent justes. Les groupes auxquels personne d’autre n’a accès seront supprimés. Le propriétaire d’un groupe peut supprimer tout le groupe dans ses paramètres. Pour toute autre demande, contactez la personne qui gère le serveur.';

  @override
  String get privacyOperatorPolicy => 'Politique de confidentialité du serveur';

  @override
  String get privacyLink => 'Confidentialité';

  @override
  String get accountEmailAdd => 'Ajouter une adresse e-mail';

  @override
  String get accountEmailChange => 'Changer d’adresse e-mail';

  @override
  String get accountEmailNew => 'Adresse e-mail';

  @override
  String get accountEmailVerifyNote =>
      'Vous recevrez un lien pour confirmer la nouvelle adresse. Votre adresse actuelle reste valide jusque-là.';

  @override
  String get accountEmailPendingTitle => 'Confirmer votre nouvelle adresse e-mail';

  @override
  String accountEmailPendingHelp(String email) {
    return 'L’adresse $email remplacera votre adresse actuelle lorsque vous ouvrirez le lien qui y a été envoyé. Touchez pour le renvoyer.';
  }

  @override
  String get accountEmailRemoveNote =>
      'Laissez ce champ vide pour supprimer votre adresse. Vous pourrez toujours vous connecter avec votre nom d’utilisateur.';

  @override
  String get accountEmailSaved => 'Adresse e-mail enregistrée';

  @override
  String get accountEmailRemoved => 'Adresse e-mail supprimée';

  @override
  String get accountConfirmPassword => 'Votre mot de passe';

  @override
  String get accountConfirmPasswordHelp => 'Pour confirmer votre identité.';

  @override
  String get errorEmailNeeded =>
      'Vous vous connectez avec votre adresse e-mail ; elle ne peut donc pas être supprimée.';

  @override
  String get accountDelete => 'Supprimer le compte';

  @override
  String get accountDeleteHelp => 'Supprimer votre compte de ce serveur';

  @override
  String get accountDeleteTitle => 'Supprimer votre compte ?';

  @override
  String get accountDeleteBody =>
      'Votre compte sera supprimé définitivement et vous serez déconnecté. Dans vos groupes, votre nom restera comme membre non revendiqué, afin que les soldes restent justes. Les groupes auxquels personne d’autre n’appartient seront supprimés.';

  @override
  String get accountDeleteAction => 'Supprimer définitivement';

  @override
  String get accountDeleted => 'Votre compte a été supprimé.';

  @override
  String get accountDeletePageSignedOut => 'Connectez-vous pour supprimer votre compte sur ce serveur.';

  @override
  String get accountDeletePageLinkMode =>
      'Ce serveur n’utilise pas de comptes : le lien du groupe suffit pour y accéder. Pour supprimer un groupe et tout son contenu, ouvrez ses paramètres et choisissez « Supprimer le groupe ».';

  @override
  String get groupDelete => 'Supprimer le groupe';

  @override
  String get groupDeleteHelp => 'Le supprimer pour tout le monde avec toutes ses dépenses';

  @override
  String groupDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get groupDeleteBody =>
      'Le groupe, toutes ses dépenses, tous ses règlements et son historique seront supprimés pour tout le monde. Cette action est irréversible. Saisissez le nom du groupe pour confirmer.';

  @override
  String get groupDeleteName => 'Nom du groupe';

  @override
  String get groupDeleteAction => 'Supprimer définitivement';

  @override
  String get groupDeleted => 'Groupe supprimé';

  @override
  String get groupDeleteOwnerOnly => 'Seul le propriétaire du groupe peut le supprimer.';

  @override
  String get expenseDiscardTitle => 'Abandonner les modifications ?';

  @override
  String get expenseDiscardBody => 'Vos modifications de cette dépense n’ont pas été enregistrées.';

  @override
  String get expenseDiscard => 'Abandonner';

  @override
  String get adminPrivacyUrl => 'Lien vers la politique de confidentialité';

  @override
  String get adminPrivacyUrlHelp =>
      'Politique de confidentialité requise par les boutiques d’applications. Si ce champ est vide, l’application affiche une politique générale sur les données enregistrées par Balnana.';

  @override
  String get adminMapTiles => 'Tuiles de carte';

  @override
  String get adminMapSource => 'Source cartographique';

  @override
  String get adminMapSourceStyle => 'Style vectoriel';

  @override
  String get adminMapSourceStyleHelp =>
      'Cartes dessinées à partir d’un style MapLibre, comme celui d’OpenFreeMap, gratuit et sans clé.';

  @override
  String get adminMapSourceTiles => 'Tuiles raster';

  @override
  String get adminMapSourceTilesHelp =>
      'Cartes affichées à partir d’images de tuiles, comme celles d’OpenStreetMap.';

  @override
  String get adminMapSourceOff => 'Désactivées';

  @override
  String get adminMapSourceOffHelp =>
      'Aucune carte. Les dépenses conservent le nom du lieu et ses coordonnées.';

  @override
  String get adminMapStyle => 'URL du style';

  @override
  String get adminMapStyleHelp =>
      'Adresse d’un fichier style.json MapLibre, comme Liberty (le style par défaut), Bright ou Positron d’OpenFreeMap.';

  @override
  String get adminMapTilesHelp =>
      'Modèle d’URL de tuiles raster avec z, x et y entre accolades, comme celui par défaut. Les serveurs d’OpenStreetMap sont réservés à un usage léger ; un serveur fréquenté doit utiliser un fournisseur de tuiles.';

  @override
  String get adminMapAttribution => 'Crédit cartographique';

  @override
  String get adminMapAttributionHelp =>
      'Affiché sur chaque carte, comme le demande le fournisseur. Si le champ est vide, le style affiche les crédits qu’il indique et les tuiles créditent OpenStreetMap.';

  @override
  String get adminInvalidMapTiles => 'Saisissez un modèle d’URL http(s) avec z, x et y entre accolades.';

  @override
  String get adminUsers => 'Comptes';

  @override
  String get adminUsersSearch => 'Rechercher par nom, e-mail ou nom d’utilisateur';

  @override
  String adminUsersShown(int shown, int total) {
    return '$shown comptes sur $total';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comptes',
      one: '1 compte',
      zero: '$count compte',
    );
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => 'Aucun compte ne correspond.';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groupes',
      one: '1 groupe',
      zero: 'Aucun groupe',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => 'non confirmé';

  @override
  String adminUserDeleteTitle(String name) {
    return 'Supprimer le compte de $name ?';
  }

  @override
  String get adminUserDeleteBody =>
      'Le compte sera supprimé définitivement et déconnecté de tous les appareils. Son nom restera dans ses groupes comme membre non revendiqué ; les groupes auxquels personne d’autre n’appartient seront supprimés.';

  @override
  String get adminUserDeleted => 'Compte supprimé';

  @override
  String get commonDone => 'Terminé';

  @override
  String get crowdSearch => 'Rechercher des personnes';

  @override
  String get crowdNoMatch => 'Aucune personne ne correspond.';

  @override
  String get crowdAll => 'Tout le monde';

  @override
  String get crowdNone => 'Personne';

  @override
  String crowdChosen(int count, int total) {
    return '$count sur $total sélectionnés';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de plus',
      one: '1 de plus',
      zero: 'Rien de plus',
    );
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => 'Afficher moins';

  @override
  String get crowdSort => 'Trier';

  @override
  String crowdShowAll(int count) {
    return 'Tout afficher ($count)';
  }

  @override
  String get crowdBalances => 'Solde de tout le monde';

  @override
  String get crowdSomeoneElse => 'Une autre personne';

  @override
  String get crowdChoosePayers => 'Choisir les personnes qui ont payé';

  @override
  String get crowdFilterTitle => 'Dépenses de qui ?';

  @override
  String get myGroupsTitle => 'Mes liens de groupe';

  @override
  String get myGroupsExport => 'Exporter mes groupes';

  @override
  String get myGroupsExportHelp =>
      'Copiez les liens de vos groupes pour en garder une sauvegarde ou les transférer vers un autre appareil.';

  @override
  String get myGroupsPrivate =>
      'Gardez ces liens privés. Toute personne qui en a un peut ouvrir le groupe correspondant.';

  @override
  String get myGroupsCopy => 'Copier les liens';

  @override
  String get myGroupsImport => 'Importer des groupes';

  @override
  String get myGroupsImportHelp =>
      'Collez les liens de groupe de ce serveur, un par ligne. Les groupes existants conservent leur place et leur identité.';

  @override
  String get myGroupsLinks => 'Liens de groupe';

  @override
  String get myGroupsImportAction => 'Importer les liens';

  @override
  String get myGroupsInvalid =>
      'Saisissez des liens de groupe valides, un par ligne. Aucun lien n’a été importé.';

  @override
  String get myGroupsServerChanged =>
      'Le serveur sélectionné a changé. Fermez cette fenêtre et importez les liens sur leur serveur d’origine.';

  @override
  String myGroupsLimit(int count) {
    return 'La limite est de $count liens de groupe par serveur. Aucun lien n’a été importé.';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux liens de groupe importés.',
      one: '1 nouveau lien de groupe importé.',
      zero: 'Ces groupes sont déjà enregistrés.',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => 'Répétition';

  @override
  String get repeatNever => 'Ne pas répéter';

  @override
  String get repeatDaily => 'Chaque jour';

  @override
  String get repeatWeekly => 'Chaque semaine';

  @override
  String get repeatMonthly => 'Chaque mois';

  @override
  String get repeatYearly => 'Chaque année';

  @override
  String get repeatEvery => 'Intervalle';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'jours',
      one: 'jour',
      zero: 'jours',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'semaines',
      one: 'semaine',
      zero: 'semaines',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mois',
      one: 'mois',
      zero: 'mois',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'ans', one: 'an', zero: 'ans');
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count jours',
      one: 'Tous les jours',
      zero: 'Tous les $count jours',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toutes les $count semaines',
      one: 'Toutes les semaines',
      zero: 'Toutes les $count semaines',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count mois',
      one: 'Tous les mois',
      zero: 'Tous les $count mois',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tous les $count ans',
      one: 'Tous les ans',
      zero: 'Tous les $count ans',
    );
    return '$_temp0';
  }

  @override
  String get repeatEndNone => 'Aucune date de fin';

  @override
  String repeatEndOn(String date) {
    return 'Jusqu’au $date';
  }

  @override
  String get repeatEndClear => 'Supprimer la date de fin';

  @override
  String get repeatHelp =>
      'La dépense est ajoutée automatiquement au groupe à chaque date, à partir de la date ci-dessus. Les dates déjà passées sont ajoutées à l’enregistrement.';

  @override
  String get repeatDropReceiptTitle => 'Supprimer le justificatif ?';

  @override
  String get repeatDropReceiptBody =>
      'Une dépense récurrente ne peut pas conserver de justificatif. Vous pourrez en ajouter un à chaque dépense créée.';

  @override
  String get repeatDropReceiptAction => 'Répéter';

  @override
  String get recurringTitle => 'Dépenses récurrentes';

  @override
  String get recurringHelp => 'Des dépenses ajoutées automatiquement selon un calendrier';

  @override
  String get recurringEmptyTitle => 'Aucune dépense récurrente';

  @override
  String get recurringEmptyBody =>
      'Le loyer, les abonnements et les autres frais réguliers peuvent être ajoutés automatiquement à chaque échéance.';

  @override
  String get recurringAdd => 'Ajouter une dépense récurrente';

  @override
  String get recurringEdit => 'Modifier la dépense récurrente';

  @override
  String recurringNext(String date) {
    return 'Prochaine échéance : $date';
  }

  @override
  String get recurringPaused => 'En pause';

  @override
  String get recurringEnded => 'Terminée';

  @override
  String get recurringPause => 'Mettre en pause';

  @override
  String get recurringResume => 'Reprendre';

  @override
  String get recurringActive => 'Répétition activée';

  @override
  String get recurringDelete => 'Supprimer';

  @override
  String get recurringDeleteTitle => 'Arrêter la répétition ?';

  @override
  String recurringDeleteBody(String title) {
    return '« $title » ne sera plus ajoutée. Les dépenses déjà créées restent dans le groupe.';
  }

  @override
  String get recurringDeleted => 'Dépense récurrente supprimée';

  @override
  String get recurringFromSchedule => 'Ajoutée par une dépense récurrente';

  @override
  String get recurringOpen => 'Modifier le calendrier';

  @override
  String get recurringMissing => 'La dépense récurrente a été supprimée ou n’est plus disponible.';

  @override
  String get errorTooManyDue =>
      'La date de début est trop ancienne : plus de 100 dépenses seraient ajoutées d’un coup.';

  @override
  String get errorInvalidEnd => 'La date de fin ne peut pas précéder la date de début.';

  @override
  String get errorInvalidRepeat =>
      'L’intervalle doit être compris entre 1 et 999 jours, semaines, mois ou ans.';

  @override
  String get errorRecurringConflict =>
      'Une autre personne a modifié cette dépense récurrente pendant que vous la modifiiez. Rechargez la page pour voir ses changements.';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$who a programmé la répétition de « $title »';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$who a modifié la dépense récurrente « $title »';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$who a mis en pause la dépense récurrente « $title »';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return 'La dépense récurrente « $title » a été mise en pause parce qu’une personne concernée a quitté le groupe';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return 'La dépense récurrente « $title » a été mise en pause car elle n’a pas pu être ajoutée';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$who a repris la dépense récurrente « $title »';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$who a arrêté la répétition de « $title »';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return '« $title » ($amount) a été ajoutée automatiquement';
  }

  @override
  String get expenseRecurring => 'Ajoutée par une dépense récurrente';

  @override
  String get adminPlans => 'Formules';

  @override
  String get adminPayments => 'Paiements';

  @override
  String get adminSectionBilling => 'Formules et paiements';

  @override
  String get adminSectionBillingBody =>
      'Les formules relèvent les limites de ce que ce serveur conserve. Partager les dépenses et régler restent gratuits.';

  @override
  String get adminBillingOn => 'Formules et limites';

  @override
  String get adminBillingOnHelp => 'Si désactivé, ce serveur ne limite rien et n’affiche aucune formule.';

  @override
  String get adminBillingNeedsAccounts =>
      'Les formules nécessitent des comptes : passez d’abord le mode d’accès aux comptes.';

  @override
  String get adminKofiUrl => 'Page Ko-fi';

  @override
  String get adminKofiUrlHelp =>
      'La page de paiement. Seules les versions qui autorisent les paiements externes y renvoient.';

  @override
  String adminKofiWebhook(String url) {
    return 'URL de webhook à saisir sur Ko-fi : $url';
  }

  @override
  String get adminKofiToken => 'Jeton de vérification Ko-fi';

  @override
  String get adminKofiTokenHelp => 'Affiché sur la page webhook de Ko-fi. Sans lui, ce serveur ignore Ko-fi.';

  @override
  String adminUserPlanUntil(String plan, String date) {
    return '$plan jusqu’au $date';
  }

  @override
  String get adminPlansHelp =>
      'Une nouvelle limite s’applique à ce qui sera ajouté ensuite. L’existant reste. Laissez vide pour ne fixer aucune limite.';

  @override
  String get adminPlanAdd => 'Ajouter une formule';

  @override
  String adminPlanDefaultName(String name) {
    return '$name (par défaut)';
  }

  @override
  String adminPlanLimit(String label, String value) {
    return '$label : $value';
  }

  @override
  String adminPlanDays(int count) {
    return 'Jours : $count';
  }

  @override
  String get adminProductsSection => 'Produits';

  @override
  String get adminProductsHelp =>
      'Un paiement va au produit portant son nom de palier, sinon à celui sans nom de palier dont il atteint le montant.';

  @override
  String get adminProductAdd => 'Ajouter un produit';

  @override
  String get adminProductEdit => 'Modifier le produit';

  @override
  String adminProductAnyPayment(String amount) {
    return 'Tout paiement d’au moins $amount';
  }

  @override
  String get adminProductName => 'Nom du palier';

  @override
  String get adminProductNameHelp =>
      'Tel qu’écrit sur Ko-fi. Laissez vide pour associer les paiements uniques ou mensuels par leur montant.';

  @override
  String get adminProductPlan => 'Formule';

  @override
  String get adminProductDays => 'Jours';

  @override
  String get adminProductDaysHelp => 'Durée d’un paiement. Un nouveau paiement s’ajoute au temps restant.';

  @override
  String get adminProductMinAmount => 'Montant minimum';

  @override
  String get adminProductCurrency => 'Code de devise';

  @override
  String get adminPlanId => 'ID';

  @override
  String get adminPlanIdHelp => 'Minuscules, chiffres et tirets. Non modifiable par la suite.';

  @override
  String get adminPlanName => 'Nom';

  @override
  String get adminPlanRank => 'Rang';

  @override
  String get adminPlanRankHelp => 'Un compte avec plusieurs formules obtient celle de rang le plus élevé.';

  @override
  String get adminPlanDefault => 'Formule par défaut';

  @override
  String get adminPlanDefaultHelp => 'Pour tous les comptes sans autre formule.';

  @override
  String get adminEntitlementGranted => 'Attribuée par un administrateur';

  @override
  String get adminEntitlementRevoked => 'Révoquée';

  @override
  String get adminEntitlementForever => 'Sans date de fin';

  @override
  String adminEntitlementUntil(String date) {
    return 'Jusqu’au $date';
  }

  @override
  String adminEntitlementEnded(String date) {
    return 'Terminée le $date';
  }

  @override
  String get adminEntitlementsEmpty => 'Ce compte n’a pas encore de formule.';

  @override
  String get adminEntitlementRevoke => 'Révoquer';

  @override
  String get adminEntitlementNote => 'Note';

  @override
  String get adminEntitlementGrant => 'Attribuer la formule';

  @override
  String get adminPaymentApplied => 'Appliqué';

  @override
  String get adminPaymentUnclaimed => 'Non réclamé';

  @override
  String get adminPaymentUnmatched => 'Non associé';

  @override
  String get adminPaymentsAll => 'Tous';

  @override
  String adminPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paiements',
      one: '1 paiement',
      zero: '$count paiement',
    );
    return '$_temp0';
  }

  @override
  String get adminPaymentsEmpty => 'Aucun paiement.';

  @override
  String get adminPaymentAssigned => 'Formule attribuée au compte.';

  @override
  String get adminPaymentAssign => 'Attribuer à un compte';

  @override
  String get adminPaymentPickUser => 'Choisissez un compte.';

  @override
  String get errorBillingOff => 'Ce serveur n’a pas de formules.';

  @override
  String get errorAlreadySponsored => 'La formule d’un autre membre couvre déjà ce groupe.';

  @override
  String get errorPlanInUse => 'Des comptes ou des produits utilisent encore cette formule.';

  @override
  String get errorPaymentApplied => 'Ce paiement a déjà été appliqué.';

  @override
  String get errorInvalidPlan => 'Vérifiez les réglages de la formule : un élément n’est pas valide.';

  @override
  String errorLimitReceipts(int max) {
    return 'Ce groupe a atteint sa limite de $max photos de justificatifs.';
  }

  @override
  String errorLimitRecurring(int max) {
    return 'Ce groupe a atteint sa limite de $max dépenses récurrentes.';
  }

  @override
  String errorLimitOwnGroups(int max) {
    return 'Vous avez atteint votre limite de $max groupes.';
  }

  @override
  String errorLimitSponsored(int max) {
    return 'Votre formule ne peut pas être partagée avec plus de $max groupes.';
  }

  @override
  String get errorLimitOther => 'Vous avez atteint une limite de ce serveur.';

  @override
  String get planTitle => 'Formule';

  @override
  String get planUnlimited => 'Aucune limite';

  @override
  String planUntil(String date) {
    return 'Jusqu’au $date';
  }

  @override
  String get planSettingsHelp => 'Ce que ce serveur conserve pour vous';

  @override
  String get planIntro =>
      'Partager et régler restent toujours gratuits. Une formule change seulement ce que ce serveur conserve pour vous.';

  @override
  String planUsage(int used, int limit) {
    return '$used sur $limit';
  }

  @override
  String planUsed(int used) {
    return '$used utilisés';
  }

  @override
  String get planLimits => 'Limites';

  @override
  String get planLimitReceipts => 'Photos de justificatifs par groupe';

  @override
  String get planLimitRecurring => 'Dépenses récurrentes par groupe';

  @override
  String get planLimitOwnGroups => 'Groupes que vous avez créés';

  @override
  String get planLimitSponsored => 'Groupes partageant votre formule';

  @override
  String get planGet => 'Obtenir une formule';

  @override
  String get planKofi => 'Ko-fi';

  @override
  String get planKofiHelp =>
      'Payez avec l’e-mail confirmé de votre compte, ou ajoutez ci-dessous l’adresse avec laquelle vous payez.';

  @override
  String get planPaymentEmailConfirmed => 'Les paiements depuis cette adresse comptent pour votre compte';

  @override
  String get planPaymentEmailAdd => 'Ajouter un e-mail de paiement';

  @override
  String get planPaymentEmailHelp => 'Nous enverrons un lien pour confirmer qu’il est à vous.';

  @override
  String get paymentEmailDone => 'Adresse confirmée';

  @override
  String get paymentEmailDoneBody =>
      'Les paiements depuis cette adresse comptent désormais pour votre compte.';

  @override
  String groupPlanUsage(String receipts, String recurring) {
    return 'Photos de justificatifs : $receipts · Récurrentes : $recurring';
  }

  @override
  String get groupSponsor => 'Partager ma formule avec ce groupe';

  @override
  String get groupUnsponsor => 'Ne plus partager ma formule';

  @override
  String groupSponsoredBy(String name) {
    return 'Utilise la formule de $name';
  }

  @override
  String get accountDeletePlayNote =>
      'Un abonnement Google Play ne s\'arrête pas avec votre compte. Résiliez-le d\'abord sur Google Play.';

  @override
  String get planPlayManage => 'Gérer l\'abonnement';

  @override
  String get planPlayManageHelp => 'Le modifier ou le résilier sur Google Play';

  @override
  String planPlayPrice(int months, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'tous les $months mois',
      one: 'par mois',
    );
    return '$price $_temp0';
  }

  @override
  String get planPlayFailed => 'Google Play n\'a pas pu finaliser l\'achat.';

  @override
  String get planPlayPending =>
      'Votre paiement est en cours de traitement. Le forfait commencera une fois celui-ci validé.';

  @override
  String get errorInvalidPurchase => 'Google Play ne reconnaît pas cet achat.';

  @override
  String get errorPlayOtherAccount =>
      'Cet abonnement appartient à un autre compte. Connectez-vous à celui-ci ou résiliez-le sur Google Play.';

  @override
  String get errorPlayUnavailable => 'Impossible de joindre Google Play. Réessayez dans un instant.';

  @override
  String get adminPlayPackage => 'Nom du package Google Play';

  @override
  String get adminPlayPackageHelp =>
      'L\'identifiant de l\'application sur Google Play. Avec le compte de service ci-dessous, il active les abonnements Google Play.';

  @override
  String get adminPlayServiceAccount => 'Compte de service Google Play';

  @override
  String get adminPlayServiceAccountHelp =>
      'La clé JSON d\'un compte de service pouvant voir et gérer les commandes et abonnements dans la Play Console.';

  @override
  String get adminPlayPushAccount => 'Compte push Pub/Sub';

  @override
  String get adminPlayPushAccountHelp =>
      'L\'adresse e-mail du compte de service avec lequel Pub/Sub signe ses envois. Sans elle, les renouvellements n\'arrivent que lorsque quelqu\'un ouvre la page du forfait.';

  @override
  String adminPlayWebhook(String url) {
    return 'Point de terminaison push Pub/Sub, et aussi son audience : $url';
  }

  @override
  String get adminProductProvider => 'Payé via';

  @override
  String get adminProductPlayId => 'ID du produit';

  @override
  String get adminProductPlayIdHelp =>
      'Tel qu\'écrit dans la Play Console. Google Play indique la fin de chaque paiement, il n\'y a donc pas de jours à définir.';
}
