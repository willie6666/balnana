// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get languageEndonym => 'Türkçe';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonRetry => 'Yeniden dene';

  @override
  String get offlineBar =>
      'Çevrimdışısınız. Bu cihazda kayıtlı olanlar gösteriliyor; yeniden bağlanana kadar değişiklikler kaydedilemez.';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonClear => 'Temizle';

  @override
  String get iconChoose => 'Simge seç';

  @override
  String get iconNone => 'Simge yok';

  @override
  String get iconSearchHint => 'Ara veya bir emoji yaz';

  @override
  String get iconUseTyped => 'Bu emojiyi kullan';

  @override
  String get iconNoMatch => 'Eşleşen simge yok. Kullanmak için bir emoji yaz.';

  @override
  String get iconSectionTravel => 'Seyahat ve yerler';

  @override
  String get iconSectionFood => 'Yiyecek ve içecek';

  @override
  String get iconSectionActivities => 'Etkinlikler';

  @override
  String get iconSectionHome => 'Ev ve faturalar';

  @override
  String get iconSectionPeople => 'Kişiler';

  @override
  String get iconSectionNature => 'Hayvanlar ve doğa';

  @override
  String get iconSectionObjects => 'Para ve eşyalar';

  @override
  String get iconSectionSymbols => 'Semboller';

  @override
  String get commonRemove => 'Kaldır';

  @override
  String get commonUndo => 'Geri al';

  @override
  String get someone => 'Biri';

  @override
  String get errorTooLarge => 'Sunucuya göndermek için bu dosya çok büyük.';

  @override
  String get errorBusy => 'Sunucu şu anda meşgul. Birazdan tekrar deneyin.';

  @override
  String get errorTimeout => 'Gönderim çok uzun sürdü. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get errorBadOrigin =>
      'Sunucu bu adresten oturum açılmasına izin vermiyor. Sunucuyu yöneten kişi herkese açık URL’sini kontrol etmeli.';

  @override
  String get errorInvalidCategory => 'Bu kategori bu sırada silinmiş. Başka bir kategori seçin.';

  @override
  String get errorBuiltinCategory => 'Yerleşik kategoriler yalnızca gizlenebilir.';

  @override
  String get errorUnknownMember =>
      'Bu harcamadaki kişilerden biri artık grupta değil. Yenileyip tekrar deneyin.';

  @override
  String get errorNoPayers => 'Ödemeyi yapan kişiyi seçin.';

  @override
  String get errorPayerTotal => 'Kişilerin ödediği tutarların toplamı harcama tutarına eşit olmalı.';

  @override
  String get errorPayerTooSmall =>
      'Ödenen tutarın bir kişinin payı grup para biriminde sıfıra yuvarlanıyor. Tutarları kontrol edin.';

  @override
  String get errorInvalidNote => 'Not çok uzun veya kaydedilemeyen karakterler içeriyor.';

  @override
  String get errorInvalidDate => 'Tarih izin verilen aralığın dışında.';

  @override
  String get errorGeneric => 'Bir sorun oluştu. Tekrar deneyin.';

  @override
  String get errorNetwork => 'Sunucuya ulaşılamıyor. Bağlantınızı kontrol edin.';

  @override
  String get errorNotFound => 'Bu artık mevcut değil.';

  @override
  String get errorRequired => 'Zorunlu';

  @override
  String get errorInvalidName => 'En fazla 100 karakterlik bir ad girin.';

  @override
  String get errorDuplicateName => 'Bu grupta bu ad zaten kullanılıyor.';

  @override
  String get errorTooManyMembers => 'Bu grup alabileceği en fazla kişi sayısına ulaştı.';

  @override
  String get errorTooManyCategories => 'Bu grup alabileceği en fazla kategori sayısına ulaştı.';

  @override
  String get errorDuplicateCategory => 'Bu grupta bu ada sahip bir kategori zaten var.';

  @override
  String get errorInvalidCurrency => 'USD gibi üç harfli bir para birimi kodu girin.';

  @override
  String get errorInvalidTitle => 'En fazla 200 karakterlik bir başlık girin.';

  @override
  String get errorInvalidLocation => 'Tek satırda, en fazla 200 karakterlik bir yer adı girin.';

  @override
  String get errorInvalidSymbol => 'En fazla 8 karakterlik bir simge girin.';

  @override
  String get errorInvalidEmoji => 'Simge olarak tek bir emoji seçin.';

  @override
  String get errorMemberHasBalance => 'Bu kişiyi kaldırmadan önce bakiyesini kapatın.';

  @override
  String get errorVersionConflict =>
      'Siz düzenlerken başka biri bu harcamayı değiştirdi. Değişikliklerini görmek için yenileyin.';

  @override
  String get errorSignInRequired => 'Bunu yapmak için oturum açın.';

  @override
  String get errorRateLimited => 'Çok fazla istek gönderildi. Bir dakika bekleyip tekrar deneyin.';

  @override
  String get errorNotAMember => 'Henüz bu grubun üyesi değilsiniz.';

  @override
  String get errorNotAllowed => 'Bunu yalnızca o kişi veya grubun sahibi yapabilir.';

  @override
  String get errorLinkGroupsOff => 'Bu sunucu, grupların yalnızca bağlantıyla açılmasına izin vermiyor.';

  @override
  String get errorMemberClaimed => 'Bir başkası zaten bu kişi olarak gruba katılmış.';

  @override
  String get errorMemberLeft => 'Bu gruptaki kişilerden biri gruptan ayrıldı.';

  @override
  String get errorInvalidEmail => 'Bir e-posta adresi girin.';

  @override
  String get errorInvalidPassword => '8 ile 200 karakter arasında bir parola kullanın.';

  @override
  String get errorEmailTaken => 'Bu e-posta adresiyle zaten bir hesap var. Bunun yerine oturum açın.';

  @override
  String get errorSignupClosed => 'Bu sunucuda yeni hesap oluşturulamıyor.';

  @override
  String get errorInvalidCredentials => 'E-posta adresi ve parola eşleşmiyor.';

  @override
  String get errorWrongPassword => 'Mevcut parolanız yanlış.';

  @override
  String get errorAccountsOff => 'Bu sunucuda hesap kullanılmıyor.';

  @override
  String get errorInvalidAmount => 'Sıfırdan büyük bir tutar girin.';

  @override
  String get errorTooManyDecimals => 'Bu para birimi için ondalık basamak sayısı fazla.';

  @override
  String get errorAmountTooLarge => 'Bu tutar çok büyük.';

  @override
  String get errorNoShares => 'Masrafı paylaşacak en az bir kişi seçin.';

  @override
  String get errorInvalidShare => 'Her pay bir sayı olmalı.';

  @override
  String get errorExactTotal => 'Tutarların toplamı genel toplama eşit olmalı.';

  @override
  String get errorPayersTotal => 'Herkesin ödediği tutarların toplamı genel toplama eşit olmalı.';

  @override
  String get categoryFood => 'Yiyecek ve içecek';

  @override
  String get categoryGroceries => 'Market alışverişi';

  @override
  String get categoryTransport => 'Ulaşım';

  @override
  String get categoryTravel => 'Seyahat';

  @override
  String get categoryLodging => 'Konaklama';

  @override
  String get categoryRent => 'Kira';

  @override
  String get categoryUtilities => 'Faturalar';

  @override
  String get categoryEntertainment => 'Eğlence';

  @override
  String get categoryShopping => 'Alışveriş';

  @override
  String get categoryHealth => 'Sağlık';

  @override
  String get categoryGifts => 'Hediyeler';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get groupNew => 'Yeni grup';

  @override
  String get groupSwitch => 'Grup değiştir';

  @override
  String get groupReorder => 'Sıralamak için sürükleyin';

  @override
  String get groupCreate => 'Grup oluştur';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count kişi', one: '1 kişi');
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return 'Sana $amount borç var';
  }

  @override
  String pillOwe(String amount) {
    return '$amount borcun var';
  }

  @override
  String get pillSettled => 'Hesap kapandı';

  @override
  String get groupMissingTitle => 'Grup bulunamadı';

  @override
  String get groupMissingBody =>
      'Bu grup silinmiş veya bağlantısı sıfırlanmış. Yeni bağlantıyı gruptan birinden isteyin.';

  @override
  String get groupLockedTitle => 'Bu grubu açmak için oturum açın';

  @override
  String get groupLockedBody =>
      'Bu grubu yalnızca üyelerinin hesapları açabilir. Gruba ait hesapla oturum açın.';

  @override
  String get groupForget => 'Bu cihazdan kaldır';

  @override
  String get groupLinkOtherServer => 'Bu bağlantı başka bir sunucuya ait. Açmak için o sunucuya bağlanın.';

  @override
  String get openLinkTitle => 'Grup bağlantısı aç';

  @override
  String get openLinkBody => 'Bir gruba katılmak için size gönderilen bağlantıyı yapıştırın.';

  @override
  String get openLinkLabel => 'Grup bağlantısı';

  @override
  String get openLinkAction => 'Aç';

  @override
  String get openLinkInvalid => 'Bu, geçerli bir Balnana grup bağlantısına benzemiyor.';

  @override
  String get groupName => 'Grup adı';

  @override
  String get groupNameHint => 'Lizbon gezisi';

  @override
  String get groupCurrency => 'Para birimi';

  @override
  String get groupCurrencyHelp =>
      'Bu gruptaki tüm harcamalar bu para birimini kullanır. Daha sonra değiştirilemez.';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name. Bu gruptaki tüm harcamalar bu para birimini kullanır. Daha sonra değiştirilemez.';
  }

  @override
  String get currencyChoose => 'Para birimi seç';

  @override
  String get currencySearchHint => 'Koda veya ada göre ara';

  @override
  String get currencySuggested => 'Önerilenler';

  @override
  String get currencyAll => 'Tüm para birimleri';

  @override
  String currencyUseTyped(String code) {
    return '$code kullan';
  }

  @override
  String get currencyNoMatch => 'Eşleşen para birimi yok. Kullanmak için üç harfli kodunu yazın.';

  @override
  String get groupSymbol => 'Simge';

  @override
  String get groupSymbolChoose => 'Simge seç';

  @override
  String groupSymbolExample(String example) {
    return 'Tutarlar $example şeklinde görünür';
  }

  @override
  String get groupColor => 'Renk';

  @override
  String colorSwatch(int number, int count) {
    return '$count renkten $number. renk';
  }

  @override
  String get groupPeople => 'Kişiler';

  @override
  String get groupYourName => 'Adınız';

  @override
  String groupPersonName(int number) {
    return '$number. kişi';
  }

  @override
  String get groupAddPerson => 'Kişi ekle';

  @override
  String get groupPeopleHelp =>
      'Daha sonra kişi ekleyebilir veya bağlantıyla gruba katılmalarını sağlayabilirsiniz.';

  @override
  String get identityTitle => 'Siz kimsiniz?';

  @override
  String get identityBody =>
      'Borcunuzu görebilmesi için Balnana’da adınızı seçin. Bu adı yalnızca bu cihaz hatırlar.';

  @override
  String get identityNew => 'Yeni biriyim';

  @override
  String get identityNewTitle => 'Bu gruba katıl';

  @override
  String get identityJoin => 'Katıl';

  @override
  String get identityChange => 'Kim olduğunuz';

  @override
  String get identityNone => 'Henüz seçilmedi';

  @override
  String get memberName => 'Ad';

  @override
  String memberYou(String name) {
    return '$name (siz)';
  }

  @override
  String get memberAdd => 'Kişi ekle';

  @override
  String get memberAddTitle => 'Birini ekle';

  @override
  String get memberRename => 'Yeniden adlandır';

  @override
  String get memberRenameTitle => 'Yeniden adlandır';

  @override
  String memberRemoveTitle(String name) {
    return '$name kaldırılsın mı?';
  }

  @override
  String get memberRemoveBody => 'Geçmiş harcamalarda kalır ama yeni harcamalara eklenemez.';

  @override
  String get groupLinkCopied => 'Bağlantı kopyalandı. Bu bağlantıya sahip herkes grubu açabilir.';

  @override
  String get groupShare => 'Bağlantıyı paylaş';

  @override
  String get groupSettings => 'Grup ayarları';

  @override
  String get groupEdit => 'Grubu düzenle';

  @override
  String get groupSharing => 'Paylaşım';

  @override
  String get groupCopyLink => 'Bağlantıyı kopyala';

  @override
  String get groupQrCode => 'QR kodunu göster';

  @override
  String get groupQrCodeHelp => 'Başkaları telefon kamerasıyla bağlantıyı tarayabilir.';

  @override
  String groupQrLabel(String group) {
    return '$group grubunun bağlantısı için QR kodu';
  }

  @override
  String get groupCopyLinkHelp => 'Bağlantıya sahip herkes bu grubu görebilir ve düzenleyebilir.';

  @override
  String get groupCopyLinkHelpAccounts =>
      'Bağlantıya sahip kişiler oturum açtıktan sonra katılma isteği gönderebilir.';

  @override
  String get linkAccessTitle => 'Bağlantıya sahip herkes erişebilir';

  @override
  String get linkAccessHelp => 'Hesap olmadan grubu görüp düzenleyebilsinler.';

  @override
  String get resetLinkTitle => 'Bağlantıyı sıfırla';

  @override
  String get resetLinkHelp => 'Yeni bir bağlantı oluşturun; eskisi çalışmayı durdurur';

  @override
  String get resetLinkBody =>
      'Mevcut bağlantı herkes için çalışmayı durduracak. Erişimi sürdürmesi gereken kişilerle yeni bağlantıyı paylaşın.';

  @override
  String get resetLinkAction => 'Sıfırla';

  @override
  String get resetLinkDone => 'Bağlantı sıfırlandı. Yeni olanı paylaşın.';

  @override
  String get groupThisDevice => 'Bu cihaz';

  @override
  String get groupData => 'Veriler';

  @override
  String get categoriesTitle => 'Kategoriler';

  @override
  String get categoriesHelp => 'Kendi kategorilerinizi ekleyin veya kullanmadıklarınızı gizleyin';

  @override
  String get categoriesOwn => 'Bu grubun kategorileri';

  @override
  String get categoriesOwnEmpty => 'Henüz bu gruba ait kategori yok.';

  @override
  String get categoriesBuiltIn => 'Yerleşik';

  @override
  String get categoriesBuiltInHelp =>
      'Gizlenen kategoriler yeni harcamalarda sunulmaz. Mevcut harcamalardaki kategoriler kalır.';

  @override
  String get categoryAdd => 'Kategori ekle';

  @override
  String get categoryEdit => 'Kategoriyi düzenle';

  @override
  String get categoryName => 'Ad';

  @override
  String get categoryDelete => 'Kategoriyi sil';

  @override
  String categoryDeleteTitle(String name) {
    return '$name silinsin mi?';
  }

  @override
  String get categoryDeleteBody => 'Bu kategorideki harcamalar kategorisiz kalacak.';

  @override
  String get categoryDeleteAction => 'Sil';

  @override
  String get exportCsv => 'CSV olarak dışa aktar';

  @override
  String get exportCsvHelp => 'E-tablo için tüm harcamalar ve ödemeler';

  @override
  String get exportCsvDone => 'Dışa aktarıldı';

  @override
  String get forgetTitle => 'Bu cihazdan kaldır';

  @override
  String get forgetHelp => 'Grup, diğer herkes için sunucuda kalır';

  @override
  String get forgetBody => 'Bağlantısıyla grubu yeniden açabilirsiniz.';

  @override
  String get groupYou => 'Siz';

  @override
  String get leaveTitle => 'Gruptan ayrıl';

  @override
  String get leaveHelp => 'Harcamalarınız kalır; bağlantıyla yeniden katılabilirsiniz';

  @override
  String get leaveBody => 'Grup listenizden kaldırılır. Harcamalarınız ve bakiyeniz grupta kalır.';

  @override
  String get leaveAction => 'Ayrıl';

  @override
  String get tabExpenses => 'Harcamalar';

  @override
  String get heroWhoTitle => 'Bu grupta kimsiniz?';

  @override
  String get heroWhoBody => 'Borcunuzu ve size olan borçları görmek için adınızı seçin.';

  @override
  String get heroWhoAction => 'Seç';

  @override
  String get heroJoinTitle => 'Bu grubu görüntülüyorsunuz';

  @override
  String get heroJoinBody => 'Harcama eklemek ve bakiyenizi görmek için katılın.';

  @override
  String get joinAction => 'Katıl';

  @override
  String get heroOwed => 'Size borç var';

  @override
  String get heroOwe => 'Borçlusunuz';

  @override
  String get heroSettled => 'Hesabınız kapandı';

  @override
  String heroYouAre(String name) {
    return 'Siz: $name';
  }

  @override
  String get expenseAdd => 'Harcama ekle';

  @override
  String get expensesEmptyTitle => 'Henüz harcama yok';

  @override
  String get expensesEmptyBody => 'İlk harcamayı ekleyin, kimin kime borçlu olduğunu Balnana hesaplasın.';

  @override
  String get expensesSearchHint => 'Başlık, not ve yerlerde ara';

  @override
  String get searchClear => 'Aramayı temizle';

  @override
  String get expensesNoMatchTitle => 'Eşleşme yok';

  @override
  String get expensesNoMatchBody => 'Başka kelimeler deneyin veya filtreleri azaltın.';

  @override
  String get filterAnyone => 'Herkes';

  @override
  String get filterAnyCategory => 'Herhangi bir kategori';

  @override
  String get filterPayments => 'Ödemeler';

  @override
  String get filterClear => 'Filtreleri temizle';

  @override
  String get periodAll => 'Tüm zamanlar';

  @override
  String get periodThisMonth => 'Bu ay';

  @override
  String get periodLastMonth => 'Geçen ay';

  @override
  String get periodThisYear => 'Bu yıl';

  @override
  String get periodPickDays => 'Tarih seç…';

  @override
  String get statsTitle => 'Harcamalar';

  @override
  String get statsTotal => 'Toplam harcama';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count harcama',
      one: '1 harcama',
    );
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'Kategoriye göre';

  @override
  String get statsByMember => 'Kişi başına ödenen ve pay';

  @override
  String get statsPaid => 'Ödenen';

  @override
  String get statsShare => 'Pay';

  @override
  String get statsByMonth => 'Aya göre';

  @override
  String get statsNoCategory => 'Kategori yok';

  @override
  String get statsEmptyTitle => 'Harcama yok';

  @override
  String get statsEmptyBody => 'Bu dönemde harcama yok.';

  @override
  String get statsShowExpenses => 'Bu harcamaları göster';

  @override
  String get dateToday => 'Bugün';

  @override
  String get dateYesterday => 'Dün';

  @override
  String paymentTitle(String from, String to) {
    return '$from, $to için ödeme yaptı';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name, $amount ödedi';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return '$count kişi $amount ödedi';
  }

  @override
  String expensePaidByName(String name) {
    return '$name ödedi';
  }

  @override
  String expensePaidByManyNames(int count) {
    return '$count kişi ödedi';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name, $amount aldı';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$name aldı';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return '$count kişi aldı';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return '$count kişi $amount aldı';
  }

  @override
  String get transactionRefund => 'İade';

  @override
  String get transactionIncome => 'Gelir';

  @override
  String get paymentDelete => 'Ödemeyi sil';

  @override
  String get paymentDeleted => 'Ödeme silindi';

  @override
  String expenseDeleted(String title) {
    return '“$title” silindi';
  }

  @override
  String get expenseNew => 'Yeni harcama';

  @override
  String get expenseEdit => 'Harcamayı düzenle';

  @override
  String get expenseDelete => 'Sil';

  @override
  String get expenseAmount => 'Tutar';

  @override
  String get expenseTitle => 'Ne içindi?';

  @override
  String get expenseTitleHint => 'Akşam yemeği, bilet, taksi…';

  @override
  String get expenseAmountFromPayers => 'Herkesin ödediği tutarların toplamı';

  @override
  String expensePaidIn(String currency) {
    return '$currency olarak ödendi';
  }

  @override
  String expenseRate(String from, String to) {
    return '1 $from kaç $to?';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return '$currency cinsinden toplam';
  }

  @override
  String expenseForeignHelp(String currency) {
    return 'Bakiyeler $currency üzerinden hesaplanır. Kuru veya kart ekstresindeki gibi çıkan tutarı yazın.';
  }

  @override
  String get expenseNote => 'Not';

  @override
  String get expenseNoteHint => 'İsteğe bağlı';

  @override
  String get expenseLocation => 'Konum';

  @override
  String get expenseLocationHint => 'Neredeydi? (isteğe bağlı)';

  @override
  String get locationPickOnMap => 'Haritadan seç';

  @override
  String get locationUseCurrent => 'Mevcut konumu kullan';

  @override
  String get locationFinding => 'Konumunuz bulunuyor…';

  @override
  String get locationChange => 'Haritada değiştir';

  @override
  String get locationRemovePin => 'İşareti kaldır';

  @override
  String get locationOpenInMaps => 'Haritalarda aç';

  @override
  String get locationPickTitle => 'Konum seç';

  @override
  String get locationPickHint => 'İşaret koymak için haritaya dokunun';

  @override
  String get locationPickDone => 'Tamam';

  @override
  String get locationDenied =>
      'Balnana konumunuzu kullanamıyor. Cihaz veya tarayıcı ayarlarından izin verebilirsiniz.';

  @override
  String get locationOff => 'Bu cihazda konum kapalı.';

  @override
  String get locationUnavailable => 'Konumunuz bulunamadı. Tekrar deneyin veya haritaya işaret koyun.';

  @override
  String get expenseReceipt => 'Fiş';

  @override
  String get expenseHasReceipt => 'Fiş fotoğrafı var';

  @override
  String get expenseHasLocation => 'Konum var';

  @override
  String get receiptTakePhoto => 'Fotoğraf çek';

  @override
  String get receiptChoose => 'Resim seç';

  @override
  String get receiptRemove => 'Kaldır';

  @override
  String get receiptView => 'Fiş fotoğrafı';

  @override
  String receiptNotSaved(String reason) {
    return 'Harcama kaydedildi ama fiş fotoğrafı kaydedilemedi. $reason';
  }

  @override
  String get expensePaidByLabel => 'Ödeyen';

  @override
  String get expenseReceivedForLabel => 'Şunun için alındı';

  @override
  String get expenseReceivedByLabel => 'Alan';

  @override
  String get expenseMultiplePayers => 'Birden fazla kişi';

  @override
  String get expenseSplit => 'Paylaştırma';

  @override
  String get splitEqual => 'Eşit';

  @override
  String get splitExact => 'Tutarlar';

  @override
  String get splitShares => 'Paylar';

  @override
  String splitLeft(String amount) {
    return 'Atanacak $amount kaldı';
  }

  @override
  String splitOver(String amount) {
    return '$amount fazla';
  }

  @override
  String get conflictTitle => 'Başka yerde değiştirildi';

  @override
  String get conflictReload => 'Yenile';

  @override
  String get expenseChangedElsewhere =>
      'Başka biri bu harcamayı değiştirdi. Yenileyince onun sürümü gösterilir ve buradaki değişiklikleriniz silinir.';

  @override
  String get suggestedPayments => 'Önerilen ödemeler';

  @override
  String get allSettled => 'Herkesin hesabı kapandı.';

  @override
  String transferYouPay(String name) {
    return '$name kişisine ödeme yaparsınız';
  }

  @override
  String transferPaysYou(String name) {
    return '$name size ödeme yapar';
  }

  @override
  String transferPays(String from, String to) {
    return '$from, $to kişisine ödeme yapar';
  }

  @override
  String get recordPayment => 'Kaydet';

  @override
  String get recordPaymentTitle => 'Ödeme kaydet';

  @override
  String get recordPaymentHelp => 'Yalnızca Balnana dışında gerçekten yapılmış ödemeleri kaydedin.';

  @override
  String get paymentRecorded => 'Ödeme kaydedildi';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who, $group grubunu oluşturdu';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who, grup bilgilerini değiştirdi';
  }

  @override
  String activityLinkReset(String who) {
    return '$who, grup bağlantısını sıfırladı';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who, $name kişisini ekledi';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who, $oldName adını $name olarak değiştirdi';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who, $name kişisini kaldırdı';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who, $name kategorisini ekledi';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who, kategorileri değiştirdi';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who, $name kategorisini sildi';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name katıldı';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who, “$title” harcamasını ekledi ($amount)';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who, “$title” harcamasını düzenledi ($amount)';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who, “$title” harcamasını sildi';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who, “$title” harcamasını geri yükledi';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who, $from kişisinin $to kişisine $amount ödediğini kaydetti';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who, $amount tutarındaki ödemeyi sildi';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who, $amount tutarındaki ödemeyi geri yükledi';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count kayıt', one: '1 kayıt');
    return '$who, $source kaynağından $_temp0 içe aktardı';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who, “$title” harcamasına fiş fotoğrafı ekledi';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who, “$title” harcamasından fiş fotoğrafını kaldırdı';
  }

  @override
  String activityOther(String who) {
    return '$who bir değişiklik yaptı';
  }

  @override
  String get navGroups => 'Gruplar';

  @override
  String get navActivity => 'Etkinlikler';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get groupsEmptyTitle => 'Henüz grup yok';

  @override
  String get groupsEmptyBody => 'Oluşturduğunuz veya bağlantıdan açtığınız gruplar burada görünür.';

  @override
  String get groupsNoServerTitle => 'Bir sunucuya bağlanın';

  @override
  String get groupsNoServerBody =>
      'Balnana gruplarınızı kendi seçtiğiniz bir sunucuda tutar; bu sunucuyu kendiniz de barındırabilirsiniz.';

  @override
  String get groupsNoServerAction => 'Sunucu seç';

  @override
  String get groupsUnreachableTitle => 'Sunucuya ulaşılamıyor';

  @override
  String get groupsUnreachableBody => 'Bağlantınızı veya Ayarlar’daki sunucu adresini kontrol edin.';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grup yüklenemedi; bu gruplardaki değişiklikler gösterilmiyor.',
      one: 'Bir grup yüklenemedi; bu gruptaki değişiklikler gösterilmiyor.',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => 'Henüz etkinlik yok';

  @override
  String get activityEmptyBody => 'Gruplarınızdaki yeni harcamalar ve ödemeler burada görünür.';

  @override
  String get notFoundTitle => 'Sayfa bulunamadı';

  @override
  String get notFoundBody => 'Bu adres Balnana’da bir yere gitmiyor.';

  @override
  String get notFoundAction => 'Gruplara git';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsAccount => 'Hesap';

  @override
  String get accountRename => 'Adı değiştir';

  @override
  String get passwordChange => 'Parolayı değiştir';

  @override
  String get passwordChanged => 'Parola değiştirildi. Diğer cihazlardaki oturumlar kapatıldı.';

  @override
  String get passwordSet => 'Parola belirle';

  @override
  String get passwordSetHelp => 'E-posta adresiniz veya kullanıcı adınız ve parolanızla oturum açın';

  @override
  String get passwordSetDone => 'Parola belirlendi. Diğer cihazlardaki oturumlar kapatıldı.';

  @override
  String get passwordCurrent => 'Mevcut parola';

  @override
  String get passwordNew => 'Yeni parola';

  @override
  String get signOut => 'Oturumu kapat';

  @override
  String get accountOAuthLinked => 'Bu hesapta oturum açmak için kullanılıyor. Kaldırmak için dokunun.';

  @override
  String get accountOAuthAdd => 'Oturum açma yöntemi ekle';

  @override
  String accountOAuthAddTitle(String name) {
    return '$name ekle';
  }

  @override
  String accountOAuthAdded(String name) {
    return 'Artık $name ile oturum açabilirsiniz.';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return '$name kaldırılsın mı?';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return 'Tekrar ekleyene kadar $name ile oturum açamazsınız.';
  }

  @override
  String get accountOAuthRemove => 'Kaldır';

  @override
  String accountOAuthRemoved(String name) {
    return '$name kaldırıldı.';
  }

  @override
  String get confirmEmailTitle => 'E-posta adresinizi doğrulayın';

  @override
  String confirmEmailBody(String email) {
    return 'Bu sunucuda e-posta adresi doğrulanmalı. $email adresine gönderdiğimiz bağlantıyı açın.';
  }

  @override
  String get confirmEmailDone => 'Doğruladım';

  @override
  String get confirmEmailResend => 'Bağlantıyı tekrar gönder';

  @override
  String get confirmEmailNotYet => 'Henüz doğrulanmadı. E-postadaki bağlantıyı açın.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistem varsayılanı';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get settingsDynamicColor => 'Duvar kâğıdı renkleri';

  @override
  String get settingsDynamicColorSubtitle => 'Balnana sarısı yerine cihazınızdaki renkleri kullanın';

  @override
  String get settingsWallpaperGroups => 'Gruplarda duvar kâğıdı renkleri';

  @override
  String get settingsWallpaperGroupsSubtitle =>
      'Gruplar da kendi renkleri yerine cihazınızdaki renkleri kullanır';

  @override
  String get settingsPureBlack => 'Tam siyah';

  @override
  String get settingsPureBlackSubtitle => 'OLED ekranlar için daha koyu bir tema';

  @override
  String get settingsMyShare => 'Payımı göster';

  @override
  String get settingsMyShareSubtitle =>
      'Harcamalarda toplam yerine ödünç verdiğiniz veya borç aldığınız tutar gösterilir.';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get languageSystem => 'Sistem varsayılanı';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsNotificationsSubtitle =>
      'Birisi içinde olduğunuz bir harcamayı eklediğinde, değiştirdiğinde veya sildiğinde';

  @override
  String get settingsNotificationsBlocked =>
      'Telefon ayarlarında kapalı: bildirimleri görmek için Balnana’ya izin verin';

  @override
  String get pushChannel => 'Harcamalar';

  @override
  String get pushChannelDescription =>
      'Birisi içinde olduğunuz bir harcamayı eklediğinde, değiştirdiğinde veya sildiğinde';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who, $title harcamasını ekledi · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who, $title harcamasını değiştirdi · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who, $title harcamasını sildi · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return '$title eklendi · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return '$title değiştirildi · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return '$title silindi · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payer, $payee kişisine $amount ödedi';
  }

  @override
  String get settingsConnection => 'Bağlantı';

  @override
  String get settingsServer => 'Sunucu';

  @override
  String get serverNotSet => 'Ayarlanmadı';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get aboutVersion => 'Sürüm';

  @override
  String get aboutLicenses => 'Açık kaynak lisansları';

  @override
  String get aboutSource => 'Kaynak kodu';

  @override
  String get aboutSourceCopied => 'Tarayıcı açılamadı, bağlantı kopyalandı';

  @override
  String get serverTitle => 'Sunucu';

  @override
  String get serverIntro =>
      'Bir Balnana sunucusunun adresini girin. Herkes sunucu barındırabilir; adres genellikle web uygulamasının açıldığı adrestir.';

  @override
  String get serverUrlLabel => 'Sunucu adresi';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => 'Bağlantıyı dene';

  @override
  String get serverSaveAnyway => 'Yine de kaydet';

  @override
  String get serverReset => 'Varsayılana dön';

  @override
  String serverDefault(String url) {
    return 'Varsayılan: $url';
  }

  @override
  String serverConnected(String version) {
    return 'Balnana $version sunucusuna bağlandı';
  }

  @override
  String get serverModeLink => 'Gruplar özel bağlantıyla paylaşılır. Hesap gerekmez.';

  @override
  String get serverModeAccounts => 'Kullanıcılar hesaplarıyla oturum açar.';

  @override
  String get serverInsecure =>
      'Bu adres şifrelenmiyor (http). Ağdaki herkes verilerinizi okuyabilir. Ev ağınız dışındaki sunucular için https kullanın.';

  @override
  String get serverErrorInvalid => 'balnana.example.com gibi bir web adresi girin';

  @override
  String get serverErrorUnreachable => 'Bağlanılamadı. Adresi ve sunucunun çalıştığını kontrol edin.';

  @override
  String get serverErrorNotBalnana => 'Bir sunucu yanıt verdi ama Balnana sunucusu değil.';

  @override
  String get serverSaved => 'Sunucu kaydedildi';

  @override
  String get signIn => 'Oturum aç';

  @override
  String get groupSignInTitle => 'Bu grubu açmak için oturum açın';

  @override
  String get groupSignInBody => 'Bu grup yalnızca üyelerine açıktır. Görmek veya katılmak için oturum açın.';

  @override
  String get signInTitle => 'Tekrar hoş geldiniz';

  @override
  String get signInBody => 'Gruplarınızı görmek için oturum açın.';

  @override
  String get signInNoPassword =>
      'Bu sunucu başka bir oturum açma yöntemi kullanıyor. Sunucuyu yöneten kişiye danışın.';

  @override
  String get registerTitle => 'Hesabınızı oluşturun';

  @override
  String get registerBody => 'Gruplarınızı her cihazda yanınızda taşıyın.';

  @override
  String get registerAction => 'Hesap oluştur';

  @override
  String get registerHaveAccount => 'Zaten hesabım var';

  @override
  String get signInNoAccount => 'Hesap oluştur';

  @override
  String get accountName => 'Adınız';

  @override
  String get accountNameHelp => 'Gruplarınızdaki kişilerin göreceği ad';

  @override
  String get accountEmail => 'E-posta';

  @override
  String get accountPassword => 'Parola';

  @override
  String get accountPasswordHelp => 'En az 8 karakter';

  @override
  String get passwordShow => 'Parolayı göster';

  @override
  String get passwordHide => 'Parolayı gizle';

  @override
  String get joinPickName => 'Başka bir ad seç';

  @override
  String joinTitle(String name) {
    return '$name grubuna katıl';
  }

  @override
  String get joinBody => 'Bu kişilerden biri misiniz? Harcamalarını devralmak için kendinizi seçin.';

  @override
  String get joinBodyNew => 'Harcama eklemek ve bakiyenizi görmek için katılın.';

  @override
  String get joinAsNew => 'Yeni biriyim';

  @override
  String joinAsName(String name) {
    return '$name olarak katıl';
  }

  @override
  String joinTaken(String names) {
    return 'Zaten katılanlar: $names';
  }

  @override
  String joinTakenCount(int count) {
    return '$count kişi zaten katıldı.';
  }

  @override
  String get commonContinue => 'Devam et';

  @override
  String get errorEmailOff => 'Bu sunucu e-posta göndermiyor.';

  @override
  String get errorInvalidToken => 'Bu bağlantının süresi dolmuş veya daha önce kullanılmış.';

  @override
  String get forgotPasswordTitle => 'Parolanızı mı unuttunuz?';

  @override
  String get forgotPasswordBody => 'Yeni parola belirlemeniz için size bir bağlantı göndereceğiz.';

  @override
  String get forgotPasswordAction => 'Bağlantı gönder';

  @override
  String get forgotPasswordSent => 'Bu adresle bir hesap varsa bağlantı yolda.';

  @override
  String get resetPasswordTitle => 'Yeni parola belirleyin';

  @override
  String get resetPasswordBody =>
      'Tüm cihazlardaki oturumunuz kapatılır. Ardından yeni parolanızla oturum açabilirsiniz.';

  @override
  String get resetPasswordAction => 'Parolayı kaydet';

  @override
  String get resetPasswordDone => 'Parola değiştirildi. Yeni parolanızla oturum açın.';

  @override
  String get verifyEmailTitle => 'E-posta adresinizi doğrulayın';

  @override
  String get verifyEmailHelp => 'Böylece parolanızı unutursanız sıfırlayabilirsiniz';

  @override
  String verifyEmailSent(String email) {
    return 'Bağlantı için $email adresini kontrol edin.';
  }

  @override
  String get verifyEmailDone => 'E-posta doğrulandı';

  @override
  String get verifyEmailDoneBody => 'Teşekkürler! E-posta adresiniz doğrulandı.';

  @override
  String get verifyEmailFailed => 'E-posta adresiniz doğrulanamadı';

  @override
  String get inviteByEmail => 'E-posta ile davet et';

  @override
  String get inviteByEmailHelp => 'Katılmaları için birine bağlantı gönderin';

  @override
  String get inviteAs => 'Şu kişi olarak katılsın';

  @override
  String get inviteAsHelp => 'Bu kişinin harcamalarını devralabilir';

  @override
  String get inviteAsAnyone => 'Yeni biri';

  @override
  String get inviteSend => 'Davet gönder';

  @override
  String inviteSent(String email) {
    return 'Davet $email adresine gönderildi.';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name sizi $group grubuna davet etti';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return '$group grubuna davet edildiniz';
  }

  @override
  String inviteBody(String email) {
    return 'Katılmak için $email adresiyle hesap oluşturun veya hesabınız varsa oturum açın.';
  }

  @override
  String get inviteBodySignedIn => 'Harcama eklemek ve bakiyenizi görmek için katılın.';

  @override
  String get inviteAction => 'Daveti aç';

  @override
  String get inviteMissingTitle => 'Bu davet çalışmıyor';

  @override
  String get inviteMissingBody => 'Süresi dolmuş veya kullanılmış olabilir. Yeni bir davet isteyin.';

  @override
  String get joinInvitedAs => 'Bu kişi olarak davet edildiniz';

  @override
  String signInWith(String provider) {
    return '$provider ile devam et';
  }

  @override
  String get signInOr => 'veya';

  @override
  String get oauthFailedTitle => 'Oturum açılamadı';

  @override
  String get oauthPendingTitle => 'Bu e-posta adresinde zaten hesap var';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider, $email adresinin size ait olduğunu söylüyor ama bu adresle açılmış bir hesap henüz doğrulanmamış. Ne yapmak istiyorsunuz?';
  }

  @override
  String get oauthPendingLink => 'Bu hesaba ekle';

  @override
  String get oauthPendingLinkHelp => 'Bu hesabın parolasını girin. Parolası çalışmaya devam eder.';

  @override
  String get oauthPendingTakeOver => 'Bu hesabı devral';

  @override
  String get oauthPendingTakeOverHelp =>
      'Hesabın parolası ve diğer oturum açma yöntemleri kaldırılır; açık oturumları kapatılır.';

  @override
  String get oauthPendingNew => 'Yeni hesap oluştur';

  @override
  String oauthPendingNewHelp(String email) {
    return 'Diğer hesabın grupları kalır ama $email adresi kaldırılır.';
  }

  @override
  String get oauthPendingPassword => 'Bu hesabın parolası';

  @override
  String get oauthPendingWrongPassword => 'Bu parola yanlış.';

  @override
  String get oauthOtherServer =>
      'Bu oturum açma işlemi seçili sunucudan farklı bir sunucuda başlatıldı. Tekrar oturum açın.';

  @override
  String get oauthBackToSignIn => 'Oturum açmaya dön';

  @override
  String get errorOAuthFailed => 'Oturum açılamadı. Tekrar deneyin.';

  @override
  String get errorEmailHasAccount =>
      'Bu e-posta adresiyle zaten bir hesap var. Bu hesapta oturum açın, ardından Ayarlar’dan bu oturum açma yöntemini ekleyin.';

  @override
  String get errorIdentityTaken => 'Bu oturum açma yöntemi zaten başka bir hesaba bağlı.';

  @override
  String get errorLastSignInMethod =>
      'Bu, tek oturum açma yönteminiz. Önce bir parola belirleyin veya başka bir yöntem ekleyin.';

  @override
  String get errorEmailUnverified => 'Önce e-posta adresinizi doğrulayın.';

  @override
  String get errorOAuthCancelled => 'Oturum açma işlemi iptal edildi.';

  @override
  String get importTitle => 'Settle Up uygulamasından içe aktar';

  @override
  String get importAction => 'İçe aktar';

  @override
  String get importIntro =>
      'Settle Up’ta grubu CSV dosyası olarak dışa aktarın, sonra dosyayı burada seçin. Harcamalar, ödemeler ve gruptaki herkes aktarılır; bakiyeler değişmez.';

  @override
  String get importChooseFile => 'CSV dosyası seç';

  @override
  String get importChooseOther => 'Başka bir dosya seç';

  @override
  String get importReading => 'Dosya okunuyor…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(
      expenses,
      locale: localeName,
      other: '$expenses harcama',
      one: '1 harcama',
    );
    String _temp1 = intl.Intl.pluralLogic(
      payments,
      locale: localeName,
      other: '$payments ödeme',
      one: '1 ödeme',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return '$from - $to';
  }

  @override
  String importCurrency(String currency) {
    return 'Para birimi: $currency. Diğer para birimlerindeki kayıtlar Settle Up’ın çevirdiği tutarları kullanır.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sıfır tutarlı $count kayıt atlandı.',
      one: 'Sıfır tutarlı 1 kayıt atlandı.',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => 'Hangisi sizsiniz?';

  @override
  String get importUntitled => 'Başlıksız';

  @override
  String get errorImportFile => 'Bu, geçerli bir Settle Up CSV dışa aktarım dosyasına benzemiyor.';

  @override
  String get errorImportCurrency =>
      'Dosyada döviz kuru içermeyen kayıt bulunmadığından grubun para birimi belirlenemiyor.';

  @override
  String get errorImportTooBig => 'Bu dosya içe aktarılamayacak kadar büyük.';

  @override
  String get errorBadImage => 'Bu resim kullanılamıyor. JPEG, PNG veya WebP resmi seçin.';

  @override
  String get errorReceiptTooBig => 'Bu resim çok büyük. 10 MB’tan küçük bir resim seçin.';

  @override
  String get errorImportMe => 'Hangi kişi olduğunuzu seçin.';

  @override
  String errorImportRow(int line, String reason) {
    return 'Dosyanın $line. satırı içe aktarılamıyor: $reason';
  }

  @override
  String get errorImportAmount => 'Tutar okunamıyor.';

  @override
  String get errorImportCounts => 'Adlar ve tutarlar eşleşmiyor.';

  @override
  String get errorImportDate => 'Tarih okunamıyor.';

  @override
  String get errorImportType => 'Tür harcama, transfer veya gelir değil.';

  @override
  String get errorImportTransfer => 'Transferde bir kişinin başka birine ödeme yapması gerekir.';

  @override
  String get errorImportRowCurrency => 'Kayıt, döviz kuru olmayan başka bir para biriminde.';

  @override
  String get adminSetupTitle => 'Bu sunucuyu kurun';

  @override
  String get adminSetupBody =>
      'Yönetici için bir parola belirleyin. Bu parola, sunucu ayarlarının bulunduğu sayfayı korur. Kullanıcı adı yoktur: parolayı bilen herkes ayarları değiştirebilir.';

  @override
  String get adminSetupCode => 'Kurulum kodu';

  @override
  String get adminSetupCodeHelp =>
      'Bu sunucuda zaten veriler var; başladığında kurulum kodunu günlüğüne yazdı. Docker kullanıyorsanız: docker compose logs balnana';

  @override
  String get adminSetupAction => 'Parola belirle';

  @override
  String get adminPassword => 'Yönetici parolası';

  @override
  String get adminPasswordRepeat => 'Parolayı tekrar girin';

  @override
  String get adminPasswordMismatch => 'Parolalar eşleşmiyor.';

  @override
  String get adminLoginTitle => 'Yönetim';

  @override
  String get adminLoginBody => 'Bu sunucunun ayarlarını değiştirmek için yönetici parolasını girin.';

  @override
  String get adminLoginAction => 'Oturum aç';

  @override
  String get adminSettingsTitle => 'Sunucu ayarları';

  @override
  String get adminSaved => 'Ayarlar kaydedildi ve hemen geçerli oldu.';

  @override
  String get adminSaveFailed => 'Hiçbir şey kaydedilmedi. Vurgulanan ayarları kontrol edin.';

  @override
  String get adminChangePassword => 'Yönetici parolasını değiştir';

  @override
  String get adminPasswordCurrent => 'Mevcut parola';

  @override
  String get adminPasswordNew => 'Yeni parola';

  @override
  String get adminPasswordChanged => 'Parola değiştirildi. Diğer yönetici oturumları kapatıldı.';

  @override
  String get adminSignOut => 'Yönetim oturumunu kapat';

  @override
  String get adminBackHome => 'Balnana’ya dön';

  @override
  String get adminRequireEmail => 'E-posta adresi zorunlu olsun';

  @override
  String get adminRequireEmailHelp =>
      'Kapalıyken kullanıcılar kullanıcı adıyla kaydolabilir ve e-posta adresi vermeyebilir. Her ikisiyle de oturum açabilirler.';

  @override
  String get adminRequireEmailUnused => 'Yalnızca kapalı olan e-posta ve parola ile oturum açmayı etkiler.';

  @override
  String get accountUsername => 'Kullanıcı adı';

  @override
  String get accountUsernameHelp => '3-32 harf, rakam, nokta, tire veya alt çizgi. Bu adla oturum açarsınız.';

  @override
  String get accountEmailOptional => 'E-posta (isteğe bağlı)';

  @override
  String get accountEmailOptionalHelp =>
      'Grup davetleri almanızı ve unuttuğunuz parolayı sıfırlamanızı sağlar.';

  @override
  String get accountLogin => 'E-posta veya kullanıcı adı';

  @override
  String get errorInvalidUsername =>
      '3-32 karakterden oluşan; harf veya rakamla başlayıp harf, rakam, nokta, tire ya da alt çizgi içeren bir kullanıcı adı kullanın.';

  @override
  String get errorUsernameTaken => 'Bu kullanıcı adı zaten kullanılıyor.';

  @override
  String get adminDiscardTitle => 'Değişiklikler silinsin mi?';

  @override
  String get adminDiscardBody => 'Ayarlardaki değişiklikleriniz kaydedilmedi.';

  @override
  String get adminDiscard => 'Vazgeç';

  @override
  String adminLocked(String key) {
    return 'Sunucuda $key tarafından ayarlandı';
  }

  @override
  String adminDefault(String value) {
    return 'Varsayılan: $value';
  }

  @override
  String get adminSecretSaved => 'Kaydedildi. Değiştirmek için yeni bir değer yazın.';

  @override
  String get adminSecretRemoved => 'Kaydettiğinizde kaldırılacak.';

  @override
  String get adminSecretRemove => 'Kaydedilmiş değeri kaldır';

  @override
  String get adminSectionGeneral => 'Genel';

  @override
  String get adminSectionAccess => 'Erişim';

  @override
  String get adminSectionMaps => 'Haritalar';

  @override
  String get adminSectionAccounts => 'Hesaplar';

  @override
  String get adminSectionAccountsBody => 'Erişim yöntemi hesaplar olarak seçildiğinde bu ayarlar geçerlidir.';

  @override
  String get adminSectionEmail => 'E-posta (SMTP)';

  @override
  String get adminSectionEmailBody => 'Adres doğrulama, parola sıfırlama ve davetler.';

  @override
  String get adminSmtpOn => 'E-posta gönder';

  @override
  String get adminSectionGoogle => 'Google ile oturum aç';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Google Cloud konsolunda $url adresini yönlendirme URI’si olarak kaydedin.';
  }

  @override
  String get adminGoogleOn => 'Google ile oturum açma sun';

  @override
  String get adminGoogleOnHelp => 'Kullanıcılar Google hesaplarıyla oturum açar.';

  @override
  String get adminSectionOidc => 'OpenID Connect ile oturum aç';

  @override
  String adminSectionOidcBody(String url) {
    return 'Sağlayıcıda $url adresini yönlendirme URI’si olarak kaydedin.';
  }

  @override
  String get adminOidcHelp =>
      'Authentik, Keycloak veya Dex gibi herhangi bir OpenID Connect sağlayıcısı. İstediğiniz kadar ekleyin.';

  @override
  String get adminOidcAdd => 'Sağlayıcı ekle';

  @override
  String get adminOidcRemove => 'Sağlayıcıyı kaldır';

  @override
  String get adminOidcNew => 'Yeni sağlayıcı';

  @override
  String get adminOidcId => 'Kimlik';

  @override
  String get adminOidcIdHelp =>
      'Küçük harf, rakam ve tire kullanın. Yönlendirme URI’sinin parçasıdır ve sonradan değiştirilemez.';

  @override
  String get adminOidcIdInvalid =>
      'Harf veya rakamla başlayıp küçük harf, rakam ve tirelerden oluşan, en fazla 32 karakterlik bir değer kullanın.';

  @override
  String get adminOidcIdTaken => 'Bu kimlikte başka bir sağlayıcı zaten var.';

  @override
  String get adminTrustEmail => 'E-posta adresine güven';

  @override
  String get adminGoogleTrustEmailHelp =>
      'Hesabı olan bir e-posta adresiyle Google üzerinden giriş yapılırsa o hesap açılır. Kapalıyken parolayla oturum açılır ve Google, Ayarlar’dan eklenir.';

  @override
  String get adminOidcTrustEmailHelp =>
      'Yalnızca e-postaları doğruladığına güvendiğiniz veya sizin yönettiğiniz bir sağlayıcı için kullanın. Kapalıyken hesap sahipleri parolayla oturum açıp sağlayıcıyı Ayarlar’dan ekler.';

  @override
  String get adminRequireVerified => 'Doğrulanmış e-posta adresi zorunlu olsun';

  @override
  String get adminRequireVerifiedHelp =>
      'Kullanıcılar e-posta adreslerini doğrulamadan uygulamayı kullanamaz. Aynı e-posta adresine sahip güvenilir bir oturum açma yöntemi doğrulanmamış hesabı devralır. Kapalıyken ne olacağına kullanıcılar karar verir.';

  @override
  String get adminRequireVerifiedUnused => 'E-posta gönderimi gerekir.';

  @override
  String get adminSectionAndroid => 'Android uygulama bağlantıları';

  @override
  String get adminSectionAndroidBody =>
      'Bu sunucu için oluşturulan Android uygulamaları sunucu bağlantılarını uygulamada açar. Soru sormadan açılması için uygulama sertifikalarının SHA-256 parmak izlerini listeleyin.';

  @override
  String get adminSectionAdmin => 'Yönetici';

  @override
  String get adminPublicUrl => 'Herkese açık adres';

  @override
  String get adminPublicUrlHelp =>
      'Kullanıcıların bu sunucuya ulaşmak için kullandığı adres. Grup ve e-posta bağlantıları bu adresten oluşturulur.';

  @override
  String get adminSourceUrl => 'Kaynak kodu bağlantısı';

  @override
  String get adminSourceUrlHelp =>
      'Değiştirilmiş bir sürümü çalıştırdığınızda lisansın (AGPL-3.0) gerektirdiği şekilde kullanıcıların sunucunun kaynak kodunu bulabileceği yer.';

  @override
  String get adminAuthMode => 'Erişim';

  @override
  String get adminAuthModeLink => 'Grup bağlantıları';

  @override
  String get adminAuthModeLinkHelp => 'Oturum açmak gerekmez; herkes için grubun özel bağlantısı yeterlidir.';

  @override
  String get adminAuthModeAccounts => 'Hesaplar';

  @override
  String get adminAuthModeAccountsHelp =>
      'Kullanıcılar oturum açar; bağlantı yalnızca oturum açmış kişilerin gruba katılmasını sağlar.';

  @override
  String get adminPasswordLogin => 'E-posta ve parolayla oturum açma';

  @override
  String get adminPasswordForced =>
      'Google veya OpenID Connect ile oturum açma açılana kadar açık kalır; böylece her zaman bir oturum açma yöntemi bulunur.';

  @override
  String get adminSignup => 'Kimler hesap oluşturabilir?';

  @override
  String get adminSignupOpen => 'Herkes';

  @override
  String get adminSignupOpenHelp => 'Bu sunucuya ulaşabilen herkes kaydolabilir.';

  @override
  String get adminSignupInvite => 'Davet edilenler';

  @override
  String get adminSignupInviteHelp =>
      'Yalnızca e-postayla grup daveti alan kişiler, davetin gönderildiği adresle kaydolabilir. Grup bağlantısı tek başına erişim sağlamaz. Davetler için e-posta gönderimi açık olmalı.';

  @override
  String get adminSignupClosed => 'Hiç kimse';

  @override
  String get adminSignupClosedHelp => 'Kimse kaydolamaz. Mevcut hesaplar çalışmaya devam eder.';

  @override
  String get adminSignupHelp => 'İlk hesap her zaman oluşturulabilir.';

  @override
  String get adminLinkGroups => 'Gruplar bağlantıyla açılabilsin';

  @override
  String get adminLinkGroupsHelp =>
      'Grup sahipleri, herkesin oturum açmadan bağlantıyla katılmasına izin verebilir.';

  @override
  String get adminSmtpHost => 'Posta sunucusu';

  @override
  String get adminSmtpPort => 'Bağlantı noktası';

  @override
  String get adminSmtpUser => 'Kullanıcı adı';

  @override
  String get adminSmtpPassword => 'Parola';

  @override
  String get adminSmtpFrom => 'Gönderen';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'İstemci kimliği';

  @override
  String get adminClientSecret => 'İstemci gizli anahtarı';

  @override
  String get adminOidcIssuer => 'Yayıncı URL’si';

  @override
  String get adminOidcName => 'Düğme adı';

  @override
  String get adminOidcNameHelp => 'Oturum açma sayfasında “... ile devam et” şeklinde gösterilir.';

  @override
  String get adminFingerprints => 'Sertifika parmak izleri';

  @override
  String get adminFingerprintsHelp =>
      'Virgülle ayrılmış SHA-256 değerleri. Bunları keytool -list -v ve apksigner verify --print-certs komutları gösterir.';

  @override
  String get adminInvalidValue => 'Bu değer geçerli değil.';

  @override
  String get adminInvalidUrl => 'https:// veya http:// ile başlayan tam bir adres girin.';

  @override
  String get adminInvalidFrom =>
      'Balnana <balnana@example.com> gibi bir gönderen girin; e-posta adresi gerekli.';

  @override
  String get adminInvalidPort => '1 ile 65535 arasında bir bağlantı noktası numarası girin.';

  @override
  String get adminInvalidRequired => 'Bu oturum açma sağlayıcısı için bu alan zorunlu.';

  @override
  String get adminInvalidFingerprint =>
      'Her biri 64 onaltılık basamaktan oluşan SHA-256 parmak izlerini girin; iki nokta üst üste kullanılabilir.';

  @override
  String get adminNeedsSignIn =>
      'Hesaplar için oturum açma yöntemi gerekir: e-posta ve parolayı açın veya bir sağlayıcı kurun.';

  @override
  String get adminLockedChange => 'Bu ayar sunucuda belirlenmiş ve buradan değiştirilemez.';

  @override
  String get errorAdminRequired => 'Yönetici oturumunuz sona erdi. Tekrar oturum açın.';

  @override
  String get errorAdminWrongPassword => 'Bu parola yanlış.';

  @override
  String get errorInvalidSetupCode => 'Kurulum kodu yanlış. Sunucu günlüğünde arayın.';

  @override
  String get errorAlreadySetUp => 'Bu sunucu zaten kuruldu. Yönetici parolasıyla oturum açın.';

  @override
  String get linkOpening => 'Bağlantı açılıyor…';

  @override
  String get linkForeignTitle => 'Bu bağlantı başka bir sunucuya ait';

  @override
  String linkForeignBody(String server) {
    return 'Uygulama $server sunucusuna bağlı, ancak bu bağlantı başka bir sunucuya ait. Açmak için Ayarlar’dan sunucuyu değiştirin.';
  }

  @override
  String get linkInvalidTitle => 'Bu bağlantı açılamıyor';

  @override
  String get linkInvalidBody => 'Bu, uygulamanın tanıdığı bir Balnana bağlantısı değil.';

  @override
  String get linkGoHome => 'Gruplara git';

  @override
  String get linkOpenInBrowser => 'Tarayıcıda aç';

  @override
  String get privacyTitle => 'Gizlilik politikası';

  @override
  String get privacyIntro =>
      'Balnana açık kaynaklı bir yazılımdır. Uygulamanın bağlı olduğu sunucuyu işleten kişi (işletmeci), verilerinizin nerede tutulacağına karar verir ve verilerden sorumludur. Bu sayfada yazılımın kendisinin neleri kaydettiği ve yaptığı açıklanır.';

  @override
  String get privacyStoredTitle => 'Neler saklanır?';

  @override
  String get privacyStoredBody =>
      'Oluşturduğunuz veya katıldığınız gruplar: adları, üyelerin adları, harcamalar, ödemeler, notlar, fiş fotoğrafları ve harcamalara eklediğiniz yerler. Hesabınız varsa ayrıca adınız, e-posta adresiniz veya kullanıcı adınız, parolanızın özeti (parolanın kendisi asla değil) ve Google gibi kullandığınız oturum açma sağlayıcısı saklanır. Bildirimler açıksa cihaz kimliğiniz ve bildirim hizmetinin verdiği adres saklanır.';

  @override
  String get privacyUseTitle => 'Nasıl kullanılır?';

  @override
  String get privacyUseBody =>
      'Yalnızca uygulamayı çalıştırmak için: her grubu üyelerine göstermek, bakiyeleri hesaplamak ve adres doğrulama, parola sıfırlama ve davetler gibi gerekli e-posta ve bildirimleri göndermek için. Uygulamada reklam veya analiz yoktur; hiçbir şey satılmaz.';

  @override
  String get privacySharedTitle => 'Kimler görebilir?';

  @override
  String get privacySharedBody =>
      'Bir gruptaki herkes grubun üyelerini, harcamalarını ve geçmişini görür. Grup bağlantıyla açıksa bağlantıya sahip herkes grubu açabilir. Google ile oturum açma Google üzerinden gerçekleşir. İşletmeci bildirimleri açtığında bildirimler telefonunuzun kullandığı hizmetten geçer: Google Firebase Cloud Messaging veya kurduğunuz ntfy gibi başka bir UnifiedPush hizmeti. Bildirim içeriği aktarım sırasında şifrelenir. Harita görselleri işletmecinin seçtiği harita sağlayıcısından yüklenir; değiştirilmediyse bu OpenFreeMap’tir. Sağlayıcı ağ adresinizi ve baktığınız bölgeyi görür. Konumunuz yalnızca “Mevcut konumu kullan” seçeneğine dokunduğunuzda okunur ve yalnızca sonrasında kaydettiğiniz nokta saklanır.';

  @override
  String get privacyDeviceTitle => 'Bu cihazda';

  @override
  String get privacyDeviceBody =>
      'Uygulama, sunucu adresini, ayarlarınızı ve çevrimdışıyken kullanmanız için gruplarınızın bir kopyasını saklar. Uygulamayı kaldırmak bunları siler.';

  @override
  String get privacyDeleteTitle => 'Verilerinizi silme';

  @override
  String get privacyDeleteBody =>
      'Hesabınızı Ayarlar’dan silebilirsiniz. Böylece adınız, bakiyelerin hesaplanabilmesi için gruplarınızda kimsenin sahiplenmediği bir üye olarak kalır; başka kimsenin erişemediği gruplar da silinir. Grup sahibi, grubun tamamını ayarlarından silebilir. Diğer konular için sunucu işletmecisiyle iletişime geçin.';

  @override
  String get privacyOperatorPolicy => 'İşletmecinin gizlilik politikası';

  @override
  String get privacyLink => 'Gizlilik';

  @override
  String get accountEmailAdd => 'E-posta adresi ekle';

  @override
  String get accountEmailChange => 'E-posta adresini değiştir';

  @override
  String get accountEmailNew => 'E-posta adresi';

  @override
  String get accountEmailVerifyNote =>
      'Yeni adresi doğrulamanız için bir bağlantı gönderilecek. O zamana kadar mevcut adresiniz kalır.';

  @override
  String get accountEmailPendingTitle => 'Yeni e-posta adresinizi doğrulayın';

  @override
  String accountEmailPendingHelp(String email) {
    return 'Bağlantıyı açınca $email mevcut adresinizin yerini alır. Tekrar göndermek için dokunun.';
  }

  @override
  String get accountEmailRemoveNote =>
      'Adresinizi kaldırmak için alanı boş bırakın. Kullanıcı adınızla oturum açmaya devam edersiniz.';

  @override
  String get accountEmailSaved => 'E-posta adresi kaydedildi';

  @override
  String get accountEmailRemoved => 'E-posta adresi kaldırıldı';

  @override
  String get accountConfirmPassword => 'Parolanız';

  @override
  String get accountConfirmPasswordHelp => 'Kimliğinizi doğrulamak için.';

  @override
  String get errorEmailNeeded =>
      'Oturum açmak için e-posta adresinizi kullanıyorsunuz; bu nedenle adres kaldırılamaz.';

  @override
  String get accountDelete => 'Hesabı sil';

  @override
  String get accountDeleteHelp => 'Hesabınızı bu sunucudan kaldırın';

  @override
  String get accountDeleteTitle => 'Hesabınız silinsin mi?';

  @override
  String get accountDeleteBody =>
      'Hesabınız kalıcı olarak silinir ve oturumunuz kapatılır. Adınız, bakiyelerin doğru hesaplanması için gruplarınızda kimsenin sahiplenmediği bir üye olarak kalır. Başka kimsenin bulunmadığı gruplar silinir.';

  @override
  String get accountDeleteAction => 'Kalıcı olarak sil';

  @override
  String get accountDeleted => 'Hesabınız silindi.';

  @override
  String get accountDeletePageSignedOut => 'Hesabınızı bu sunucudan silmek için oturum açın.';

  @override
  String get accountDeletePageLinkMode =>
      'Bu sunucuda hesap yok; gruba erişmek için grup bağlantısı yeterlidir. Bir grubu içindekilerle birlikte silmek için grup ayarlarını açıp Grubu sil’i seçin.';

  @override
  String get groupDelete => 'Grubu sil';

  @override
  String get groupDeleteHelp => 'Grubu tüm harcamalarıyla birlikte herkes için silin';

  @override
  String groupDeleteTitle(String name) {
    return '$name silinsin mi?';
  }

  @override
  String get groupDeleteBody =>
      'Grup; tüm harcamaları, ödemeleri ve geçmişiyle birlikte herkes için silinir. Bu işlem geri alınamaz. Onaylamak için grubun adını yazın.';

  @override
  String get groupDeleteName => 'Grup adı';

  @override
  String get groupDeleteAction => 'Kalıcı olarak sil';

  @override
  String get groupDeleted => 'Grup silindi';

  @override
  String get groupDeleteOwnerOnly => 'Grubu yalnızca sahibi silebilir.';

  @override
  String get expenseDiscardTitle => 'Değişiklikler silinsin mi?';

  @override
  String get expenseDiscardBody => 'Bu harcamadaki değişiklikleriniz kaydedilmedi.';

  @override
  String get expenseDiscard => 'Vazgeç';

  @override
  String get adminPrivacyUrl => 'Gizlilik politikası bağlantısı';

  @override
  String get adminPrivacyUrlHelp =>
      'Uygulama mağazalarının istediği gizlilik politikası. Boş bırakılırsa uygulama, Balnana’nın neleri sakladığını açıklayan genel bir politika gösterir.';

  @override
  String get adminMapTiles => 'Harita döşemeleri';

  @override
  String get adminMapSource => 'Harita kaynağı';

  @override
  String get adminMapSourceStyle => 'Vektör stili';

  @override
  String get adminMapSourceStyleHelp =>
      'Ücretsiz olan ve anahtar gerektirmeyen OpenFreeMap Liberty gibi bir MapLibre stilinden çizilen haritalar.';

  @override
  String get adminMapSourceTiles => 'Raster döşemeler';

  @override
  String get adminMapSourceTilesHelp => 'OpenStreetMap gibi döşeme görsellerinden oluşturulan haritalar.';

  @override
  String get adminMapSourceOff => 'Kapalı';

  @override
  String get adminMapSourceOffHelp =>
      'Harita gösterilmez. Harcamalarda yer adları ve koordinatlar tutulmaya devam eder.';

  @override
  String get adminMapStyle => 'Stil URL’si';

  @override
  String get adminMapStyleHelp =>
      'OpenFreeMap’in varsayılan Liberty stili, Bright veya Positron gibi bir MapLibre style.json adresi.';

  @override
  String get adminMapTilesHelp =>
      'Varsayılan örnekteki gibi z, x ve y değerleri süslü parantez içinde olan bir raster döşeme URL şablonu. OpenStreetMap’in kendi sunucuları yalnızca hafif kullanım içindir; yoğun bir sunucu döşeme sağlayıcısı kullanmalıdır.';

  @override
  String get adminMapAttribution => 'Harita kaynak bilgisi';

  @override
  String get adminMapAttributionHelp =>
      'Harita sağlayıcısının isteği üzerine her haritada gösterilir. Boş bırakılırsa stil dosyasında belirtilen kaynaklar, döşemelerde ise OpenStreetMap belirtilir.';

  @override
  String get adminInvalidMapTiles =>
      'z, x ve y değerleri süslü parantez içinde olan bir http(s) URL şablonu girin.';

  @override
  String get adminUsers => 'Hesaplar';

  @override
  String get adminUsersSearch => 'Ada, e-posta adresine veya kullanıcı adına göre ara';

  @override
  String adminUsersShown(int shown, int total) {
    return '$total hesaptan $shown tanesi';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count hesap', one: '1 hesap');
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => 'Eşleşen hesap yok.';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grup',
      one: '1 grup',
      zero: 'Grup yok',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => 'doğrulanmadı';

  @override
  String adminUserDeleteTitle(String name) {
    return '$name kullanıcısının hesabı silinsin mi?';
  }

  @override
  String get adminUserDeleteBody =>
      'Hesap kalıcı olarak silinir ve tüm cihazlardaki oturumlar kapatılır. Adı, gruplarında kimsenin sahiplenmediği bir üye olarak kalır; başka kimsenin bulunmadığı gruplar silinir.';

  @override
  String get adminUserDeleted => 'Hesap silindi';

  @override
  String get commonDone => 'Tamam';

  @override
  String get crowdSearch => 'Kişi ara';

  @override
  String get crowdNoMatch => 'Eşleşen kişi yok.';

  @override
  String get crowdAll => 'Tümü';

  @override
  String get crowdNone => 'Hiçbiri';

  @override
  String crowdChosen(int count, int total) {
    return '$total kişiden $count tanesi seçildi';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kişi daha',
      one: '1 kişi daha',
    );
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => 'Daha az göster';

  @override
  String get crowdSort => 'Sırala';

  @override
  String crowdShowAll(int count) {
    return 'Tümünü göster ($count)';
  }

  @override
  String get crowdBalances => 'Herkesin bakiyesi';

  @override
  String get crowdSomeoneElse => 'Başka biri';

  @override
  String get crowdChoosePayers => 'Ödeyenleri seç';

  @override
  String get crowdFilterTitle => 'Kimin harcamaları?';

  @override
  String get myGroupsTitle => 'Grup bağlantılarım';

  @override
  String get myGroupsExport => 'Gruplarımı dışa aktar';

  @override
  String get myGroupsExportHelp =>
      'Yedeklemek veya başka bir cihaza taşımak için grup bağlantılarınızı kopyalayın.';

  @override
  String get myGroupsPrivate => 'Bu bağlantıları gizli tutun. Bağlantıya sahip herkes ilgili grubu açabilir.';

  @override
  String get myGroupsCopy => 'Bağlantıları kopyala';

  @override
  String get myGroupsImport => 'Grupları içe aktar';

  @override
  String get myGroupsImportHelp =>
      'Bu sunucudaki grup bağlantılarını her satıra bir tane gelecek şekilde yapıştırın. Var olan grupların yeri ve kimliği korunur.';

  @override
  String get myGroupsLinks => 'Grup bağlantıları';

  @override
  String get myGroupsImportAction => 'Bağlantıları içe aktar';

  @override
  String get myGroupsInvalid =>
      'Her satıra bir tane gelecek şekilde geçerli grup bağlantıları girin. Hiçbir şey içe aktarılmadı.';

  @override
  String get myGroupsServerChanged =>
      'Seçili sunucu değişti. Bu iletişim kutusunu kapatıp bağlantıları ait oldukları sunucuda içe aktarın.';

  @override
  String myGroupsLimit(int count) {
    return 'Her sunucuda en fazla $count grup bağlantısı tutabilirsiniz. Hiçbir şey içe aktarılmadı.';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yeni grup bağlantısı içe aktarıldı.',
      one: '1 yeni grup bağlantısı içe aktarıldı.',
      zero: 'Bu gruplar zaten kayıtlı.',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => 'Tekrar';

  @override
  String get repeatNever => 'Tekrarlama';

  @override
  String get repeatDaily => 'Her gün';

  @override
  String get repeatWeekly => 'Her hafta';

  @override
  String get repeatMonthly => 'Her ay';

  @override
  String get repeatYearly => 'Her yıl';

  @override
  String get repeatEvery => 'Her';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'gün', one: 'gün');
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'hafta', one: 'hafta');
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'ay', one: 'ay');
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'yıl', one: 'yıl');
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Her $count günde bir',
      one: 'Her gün',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Her $count haftada bir',
      one: 'Her hafta',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Her $count ayda bir',
      one: 'Her ay',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Her $count yılda bir',
      one: 'Her yıl',
    );
    return '$_temp0';
  }

  @override
  String get repeatEndNone => 'Bitiş tarihi yok';

  @override
  String repeatEndOn(String date) {
    return '$date tarihine kadar';
  }

  @override
  String get repeatEndClear => 'Bitiş tarihini kaldır';

  @override
  String get repeatHelp =>
      'Harcamalar, yukarıdaki tarihten başlayarak belirlenen her tarihte gruba otomatik eklenir. Geçmiş tarihli harcamalar siz kaydedince eklenir.';

  @override
  String get repeatDropReceiptTitle => 'Fiş kaldırılsın mı?';

  @override
  String get repeatDropReceiptBody =>
      'Tekrarlayan harcamaya fiş eklenemez. Bunun yerine eklenen her harcamaya ayrı fiş ekleyebilirsiniz.';

  @override
  String get repeatDropReceiptAction => 'Tekrarla';

  @override
  String get recurringTitle => 'Tekrarlayan harcamalar';

  @override
  String get recurringHelp => 'Belirli aralıklarla otomatik eklenen harcamalar';

  @override
  String get recurringEmptyTitle => 'Tekrarlayan harcama yok';

  @override
  String get recurringEmptyBody =>
      'Kira, abonelik ve düzenli masraflar belirlediğiniz tarihlerde otomatik eklenebilir.';

  @override
  String get recurringAdd => 'Tekrarlayan harcama ekle';

  @override
  String get recurringEdit => 'Tekrarlayan harcamayı düzenle';

  @override
  String recurringNext(String date) {
    return 'Sonraki eklenme: $date';
  }

  @override
  String get recurringPaused => 'Duraklatıldı';

  @override
  String get recurringEnded => 'Sona erdi';

  @override
  String get recurringPause => 'Duraklat';

  @override
  String get recurringResume => 'Sürdür';

  @override
  String get recurringActive => 'Tekrarlanıyor';

  @override
  String get recurringDelete => 'Sil';

  @override
  String get recurringDeleteTitle => 'Tekrarlama durdurulsun mu?';

  @override
  String recurringDeleteBody(String title) {
    return '“$title” tekrar eklenmeyecek. Daha önce eklenen harcamalar kalır.';
  }

  @override
  String get recurringDeleted => 'Tekrarlayan harcama silindi';

  @override
  String get recurringFromSchedule => 'Tekrarlayan harcama tarafından eklendi';

  @override
  String get recurringOpen => 'Zamanlamayı değiştir';

  @override
  String get recurringMissing => 'Tekrarlayan harcama silinmiş veya artık kullanılamıyor.';

  @override
  String get errorTooManyDue => 'Başlangıç tarihi çok eski: tek seferde 100’den fazla harcama eklenecek.';

  @override
  String get errorInvalidEnd => 'Bitiş tarihi başlangıç tarihinden önce olamaz.';

  @override
  String get errorInvalidRepeat => '1 ile 999 gün, hafta, ay veya yılda bir tekrarlayın.';

  @override
  String get errorRecurringConflict =>
      'Siz düzenlerken başka biri bu tekrarlayan harcamayı değiştirdi. Değişikliklerini görmek için yenileyin.';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$who, “$title” harcamasının tekrarlanmasını ayarladı';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$who, “$title” tekrarlayan harcamasını değiştirdi';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$who, “$title” tekrarlayan harcamasını duraklattı';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return '“$title” tekrarlayan harcaması, harcamadaki biri gruptan ayrıldığı için duraklatıldı';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return '“$title” tekrarlayan harcaması, eklenemediği için duraklatıldı';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$who, “$title” tekrarlayan harcamasını sürdürdü';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$who, “$title” tekrarlayan harcamasını durdurdu';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return '“$title” ($amount) otomatik olarak eklendi';
  }

  @override
  String get expenseRecurring => 'Tekrarlayan harcama tarafından eklendi';

  @override
  String get adminPlans => 'Planlar';

  @override
  String get adminPayments => 'Ödemeler';

  @override
  String get adminSectionBilling => 'Planlar ve ödemeler';

  @override
  String get adminSectionBillingBody =>
      'Planlar bu sunucunun sakladıklarına ait sınırları yükseltir. Harcama bölüşme ve hesaplaşma ücretsiz kalır.';

  @override
  String get adminBillingOn => 'Planlar ve sınırlar';

  @override
  String get adminBillingOnHelp => 'Kapalıyken bu sunucu hiçbir şeyi sınırlamaz ve plan göstermez.';

  @override
  String get adminBillingNeedsAccounts => 'Planlar için hesap gerekir: önce erişim modunu hesaplara çevirin.';

  @override
  String get adminKofiUrl => 'Ko-fi sayfası';

  @override
  String get adminKofiUrlHelp =>
      'Ödemenin yapıldığı yer. Yalnızca harici ödemelere izin veren sürümler buraya bağlantı verir.';

  @override
  String adminKofiWebhook(String url) {
    return 'Ko-fi\'ye girilecek webhook URL\'si: $url';
  }

  @override
  String get adminKofiToken => 'Ko-fi doğrulama jetonu';

  @override
  String get adminKofiTokenHelp =>
      'Ko-fi\'nin webhook sayfasında gösterilir. Bu olmadan sunucu Ko-fi\'yi yok sayar.';

  @override
  String adminUserPlanUntil(String plan, String date) {
    return '$plan, bitiş: $date';
  }

  @override
  String get adminPlansHelp =>
      'Yeni sınır, bundan sonra eklenenler için geçerlidir. Mevcut içerik kalır. Sınır olmaması için boş bırakın.';

  @override
  String get adminPlanAdd => 'Plan ekle';

  @override
  String adminPlanDefaultName(String name) {
    return '$name (varsayılan)';
  }

  @override
  String adminPlanLimit(String label, String value) {
    return '$label: $value';
  }

  @override
  String adminPlanDays(int count) {
    return 'Gün: $count';
  }

  @override
  String get adminProductsSection => 'Ürünler';

  @override
  String get adminProductsHelp =>
      'Ödeme önce kendi kademe adına sahip ürüne, yoksa kademe adı olmayan ve tutarına ulaştığı ürüne gider.';

  @override
  String get adminProductAdd => 'Ürün ekle';

  @override
  String get adminProductEdit => 'Ürünü düzenle';

  @override
  String adminProductAnyPayment(String amount) {
    return 'En az $amount tutarında her ödeme';
  }

  @override
  String get adminProductName => 'Kademe adı';

  @override
  String get adminProductNameHelp =>
      'Ko-fi\'de yazdığı gibi. Tek seferlik veya aylık ödemeleri tutara göre eşleştirmek için boş bırakın.';

  @override
  String get adminProductPlan => 'Plan';

  @override
  String get adminProductDays => 'Gün';

  @override
  String get adminProductDaysHelp => 'Bir ödemenin ne kadar süreceği. Yeniden ödeme kalan süreye eklenir.';

  @override
  String get adminProductMinAmount => 'En düşük tutar';

  @override
  String get adminProductCurrency => 'Para birimi kodu';

  @override
  String get adminPlanId => 'Kimlik';

  @override
  String get adminPlanIdHelp => 'Küçük harfler, rakamlar ve tireler. Sonradan değiştirilemez.';

  @override
  String get adminPlanName => 'Ad';

  @override
  String get adminPlanRank => 'Sıra';

  @override
  String get adminPlanRankHelp => 'Birden çok planı olan hesap, sırası en yüksek planı alır.';

  @override
  String get adminPlanDefault => 'Varsayılan plan';

  @override
  String get adminPlanDefaultHelp => 'Başka planı olmayan her hesap için.';

  @override
  String get adminEntitlementGranted => 'Yönetici tarafından verildi';

  @override
  String get adminEntitlementRevoked => 'İptal edildi';

  @override
  String get adminEntitlementForever => 'Bitiş tarihi yok';

  @override
  String adminEntitlementUntil(String date) {
    return 'Bitiş: $date';
  }

  @override
  String adminEntitlementEnded(String date) {
    return '$date tarihinde bitti';
  }

  @override
  String get adminEntitlementsEmpty => 'Bu hesabın henüz planı yok.';

  @override
  String get adminEntitlementRevoke => 'İptal et';

  @override
  String get adminEntitlementNote => 'Not';

  @override
  String get adminEntitlementGrant => 'Plan ver';

  @override
  String get adminPaymentApplied => 'Uygulandı';

  @override
  String get adminPaymentUnclaimed => 'Sahiplenilmedi';

  @override
  String get adminPaymentUnmatched => 'Eşleşmedi';

  @override
  String get adminPaymentsAll => 'Tümü';

  @override
  String adminPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ödeme', one: '1 ödeme');
    return '$_temp0';
  }

  @override
  String get adminPaymentsEmpty => 'Ödeme yok.';

  @override
  String get adminPaymentAssigned => 'Plan hesaba verildi.';

  @override
  String get adminPaymentAssign => 'Bir hesaba ver';

  @override
  String get adminPaymentPickUser => 'Bir hesap seçin.';

  @override
  String get errorBillingOff => 'Bu sunucuda plan yok.';

  @override
  String get errorAlreadySponsored => 'Bu grup zaten başka bir üyenin planı kapsamında.';

  @override
  String get errorPlanInUse => 'Hesaplar veya ürünler bu planı hâlâ kullanıyor.';

  @override
  String get errorPaymentApplied => 'Bu ödeme zaten uygulandı.';

  @override
  String get errorInvalidPlan => 'Plan ayarlarını kontrol edin: geçersiz bir değer var.';

  @override
  String errorLimitReceipts(int max) {
    return 'Bu grup $max fiş fotoğrafı sınırına ulaştı.';
  }

  @override
  String errorLimitRecurring(int max) {
    return 'Bu grup $max tekrarlayan harcama sınırına ulaştı.';
  }

  @override
  String errorLimitOwnGroups(int max) {
    return '$max grup sınırınıza ulaştınız.';
  }

  @override
  String errorLimitSponsored(int max) {
    return 'Planınız en fazla $max grupla paylaşılabilir.';
  }

  @override
  String get errorLimitOther => 'Bu sunucunun bir sınırına ulaştınız.';

  @override
  String get planTitle => 'Plan';

  @override
  String get planUnlimited => 'Sınır yok';

  @override
  String planUntil(String date) {
    return 'Bitiş: $date';
  }

  @override
  String get planSettingsHelp => 'Bu sunucunun sizin için sakladıkları';

  @override
  String get planIntro =>
      'Bölüşme ve hesaplaşma her zaman ücretsizdir. Plan yalnızca bu sunucunun sizin için ne kadar sakladığını değiştirir.';

  @override
  String planUsage(int used, int limit) {
    return '$used / $limit';
  }

  @override
  String planUsed(int used) {
    return '$used kullanılıyor';
  }

  @override
  String get planLimits => 'Sınırlar';

  @override
  String get planLimitReceipts => 'Grup başına fiş fotoğrafı';

  @override
  String get planLimitRecurring => 'Grup başına tekrarlayan harcama';

  @override
  String get planLimitOwnGroups => 'Oluşturduğunuz gruplar';

  @override
  String get planLimitSponsored => 'Planınızı paylaşan gruplar';

  @override
  String get planGet => 'Plan edinin';

  @override
  String get planKofi => 'Ko-fi';

  @override
  String get planKofiHelp =>
      'Hesabınızın doğrulanmış e-postasıyla ödeyin veya ödeme yaptığınız adresi aşağıya ekleyin.';

  @override
  String get planPaymentEmailConfirmed => 'Bu adresten yapılan ödemeler hesabınıza sayılır';

  @override
  String get planPaymentEmailAdd => 'Ödeme e-postası ekle';

  @override
  String get planPaymentEmailHelp => 'Size ait olduğunu doğrulamak için bir bağlantı göndereceğiz.';

  @override
  String get paymentEmailDone => 'Adres doğrulandı';

  @override
  String get paymentEmailDoneBody => 'Bu adresten yapılan ödemeler artık hesabınıza sayılıyor.';

  @override
  String groupPlanUsage(String receipts, String recurring) {
    return 'Fiş fotoğrafları: $receipts · Tekrarlayan: $recurring';
  }

  @override
  String get groupSponsor => 'Planımı bu grupla paylaş';

  @override
  String get groupUnsponsor => 'Planımı paylaşmayı durdur';

  @override
  String groupSponsoredBy(String name) {
    return 'Planı kullanılan üye: $name';
  }
}
