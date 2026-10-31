// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get languageEndonym => 'हिन्दी';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonRetry => 'फिर कोशिश करें';

  @override
  String get offlineBar =>
      'ऑफ़लाइन। इस डिवाइस में सेव की गई जानकारी दिख रही है; दोबारा कनेक्ट होने तक बदलाव सेव नहीं होंगे।';

  @override
  String get commonSave => 'सेव करें';

  @override
  String get commonClear => 'साफ़ करें';

  @override
  String get iconChoose => 'आइकन चुनें';

  @override
  String get iconNone => 'कोई आइकन नहीं';

  @override
  String get iconSearchHint => 'खोजें या कोई इमोजी टाइप करें';

  @override
  String get iconUseTyped => 'यह इमोजी इस्तेमाल करें';

  @override
  String get iconNoMatch => 'कोई आइकन नहीं मिला। इस्तेमाल करने के लिए इमोजी टाइप करें।';

  @override
  String get iconSectionTravel => 'सफ़र और जगहें';

  @override
  String get iconSectionFood => 'खाना-पीना';

  @override
  String get iconSectionActivities => 'गतिविधियाँ';

  @override
  String get iconSectionHome => 'घर और बिल';

  @override
  String get iconSectionPeople => 'लोग';

  @override
  String get iconSectionNature => 'जानवर और प्रकृति';

  @override
  String get iconSectionObjects => 'पैसे और चीज़ें';

  @override
  String get iconSectionSymbols => 'प्रतीक';

  @override
  String get commonRemove => 'हटाएँ';

  @override
  String get commonUndo => 'पहले जैसा करें';

  @override
  String get someone => 'कोई व्यक्ति';

  @override
  String get errorTooLarge => 'यह सर्वर पर भेजने के लिए बहुत बड़ा है।';

  @override
  String get errorBusy => 'सर्वर व्यस्त है। थोड़ी देर बाद फिर कोशिश करें।';

  @override
  String get errorTimeout => 'इसे भेजने में बहुत समय लगा। कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get errorBadOrigin =>
      'सर्वर इस पते से साइन इन स्वीकार नहीं करता। इसे चलाने वाले व्यक्ति को इसका सार्वजनिक URL जाँचना चाहिए।';

  @override
  String get errorInvalidCategory => 'यह श्रेणी इस बीच मिटा दी गई। कोई दूसरी चुनें।';

  @override
  String get errorBuiltinCategory => 'पहले से मौजूद श्रेणियाँ सिर्फ़ छिपाई जा सकती हैं।';

  @override
  String get errorUnknownMember =>
      'इस खर्च में शामिल कोई व्यक्ति अब समूह में नहीं है। फिर से लोड करके कोशिश करें।';

  @override
  String get errorNoPayers => 'किसने पैसे दिए, चुनें।';

  @override
  String get errorPayerTotal => 'सबने जितना दिया है, उसका कुल खर्च की रकम के बराबर होना चाहिए।';

  @override
  String get errorPayerTooSmall =>
      'समूह की मुद्रा में किसी के दिए हुए हिस्से की रकम शून्य हो रही है। रकम जाँचें।';

  @override
  String get errorInvalidNote => 'नोट बहुत लंबा है या इसमें ऐसे अक्षर हैं जिन्हें सेव नहीं किया जा सकता।';

  @override
  String get errorInvalidDate => 'यह तारीख तय सीमा से बाहर है।';

  @override
  String get errorGeneric => 'कुछ गड़बड़ हुई। फिर कोशिश करें।';

  @override
  String get errorNetwork => 'सर्वर से संपर्क नहीं हो पा रहा। अपना कनेक्शन जाँचें।';

  @override
  String get errorNotFound => 'यह अब मौजूद नहीं है।';

  @override
  String get errorRequired => 'ज़रूरी है';

  @override
  String get errorInvalidName => '100 अक्षरों तक का नाम डालें।';

  @override
  String get errorDuplicateName => 'इस समूह में पहले से किसी का यह नाम है।';

  @override
  String get errorTooManyMembers => 'इस समूह में और लोगों को नहीं जोड़ा जा सकता।';

  @override
  String get errorTooManyCategories => 'इस समूह में और श्रेणियाँ नहीं जोड़ी जा सकतीं।';

  @override
  String get errorDuplicateCategory => 'इस समूह में इसी नाम की श्रेणी पहले से है।';

  @override
  String get errorInvalidCurrency => 'तीन अक्षरों वाला मुद्रा कोड डालें, जैसे USD।';

  @override
  String get errorInvalidTitle => '200 अक्षरों तक का शीर्षक डालें।';

  @override
  String get errorInvalidLocation => 'एक पंक्ति में, 200 अक्षरों तक की जगह का नाम डालें।';

  @override
  String get errorInvalidSymbol => '8 अक्षरों तक का चिह्न डालें।';

  @override
  String get errorInvalidEmoji => 'आइकन के लिए एक ही इमोजी चुनें।';

  @override
  String get errorMemberHasBalance => 'इस सदस्य को हटाने से पहले उसका बैलेंस चुकता करें।';

  @override
  String get errorVersionConflict =>
      'आपके बदलाव करते समय किसी और ने यह खर्च बदल दिया। उनके बदलाव देखने के लिए फिर से लोड करें।';

  @override
  String get errorSignInRequired => 'यह करने के लिए साइन इन करें।';

  @override
  String get errorRateLimited => 'बहुत ज़्यादा अनुरोध हुए। एक मिनट रुककर फिर कोशिश करें।';

  @override
  String get errorNotAMember => 'आप अभी इस समूह में नहीं हैं।';

  @override
  String get errorNotAllowed => 'यह काम सिर्फ़ वही व्यक्ति या समूह का मालिक कर सकता है।';

  @override
  String get errorLinkGroupsOff => 'यह सर्वर सिर्फ़ लिंक से समूह खोलने की अनुमति नहीं देता।';

  @override
  String get errorMemberClaimed => 'कोई पहले ही उस व्यक्ति के रूप में समूह में शामिल हो चुका है।';

  @override
  String get errorMemberLeft => 'इस खर्च में शामिल कोई व्यक्ति समूह छोड़ चुका है।';

  @override
  String get errorInvalidEmail => 'ईमेल पता डालें।';

  @override
  String get errorInvalidPassword => '8 से 200 अक्षरों का पासवर्ड इस्तेमाल करें।';

  @override
  String get errorEmailTaken => 'इस ईमेल से पहले से एक खाता है। इसके बजाय साइन इन करें।';

  @override
  String get errorSignupClosed => 'यह सर्वर नए खाते नहीं बना रहा।';

  @override
  String get errorInvalidCredentials => 'यह ईमेल और पासवर्ड मेल नहीं खाते।';

  @override
  String get errorWrongPassword => 'आपका मौजूदा पासवर्ड सही नहीं है।';

  @override
  String get errorAccountsOff => 'यह सर्वर खातों का इस्तेमाल नहीं करता।';

  @override
  String get errorInvalidAmount => 'शून्य से ज़्यादा रकम डालें।';

  @override
  String get errorTooManyDecimals => 'इस मुद्रा के लिए दशमलव के बाद बहुत ज़्यादा अंक हैं।';

  @override
  String get errorAmountTooLarge => 'यह रकम बहुत बड़ी है।';

  @override
  String get errorNoShares => 'खर्च बाँटने के लिए कम से कम एक व्यक्ति चुनें।';

  @override
  String get errorInvalidShare => 'हर हिस्सा एक संख्या होना चाहिए।';

  @override
  String get errorExactTotal => 'रकमों का कुल जोड़ पूरी रकम के बराबर होना चाहिए।';

  @override
  String get errorPayersTotal => 'सबने जितना दिया है, उसका कुल पूरी रकम के बराबर होना चाहिए।';

  @override
  String get categoryFood => 'खाना-पीना';

  @override
  String get categoryGroceries => 'किराने का सामान';

  @override
  String get categoryTransport => 'आना-जाना';

  @override
  String get categoryTravel => 'सफ़र';

  @override
  String get categoryLodging => 'रहने की जगह';

  @override
  String get categoryRent => 'किराया';

  @override
  String get categoryUtilities => 'बिजली-पानी के बिल';

  @override
  String get categoryEntertainment => 'मनोरंजन';

  @override
  String get categoryShopping => 'खरीदारी';

  @override
  String get categoryHealth => 'सेहत';

  @override
  String get categoryGifts => 'तोहफ़े';

  @override
  String get categoryOther => 'अन्य';

  @override
  String get groupNew => 'नया समूह';

  @override
  String get groupSwitch => 'समूह बदलें';

  @override
  String get groupReorder => 'क्रम बदलने के लिए खींचें';

  @override
  String get groupCreate => 'समूह बनाएँ';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लोग',
      one: '1 व्यक्ति',
      zero: '$count व्यक्ति',
    );
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return 'आपको $amount मिलने हैं';
  }

  @override
  String pillOwe(String amount) {
    return 'आपको $amount देने हैं';
  }

  @override
  String get pillSettled => 'हिसाब चुकता';

  @override
  String get groupMissingTitle => 'समूह नहीं मिला';

  @override
  String get groupMissingBody =>
      'यह समूह मिटा दिया गया है या इसका लिंक रीसेट हुआ है। समूह में किसी से नया लिंक माँगें।';

  @override
  String get groupLockedTitle => 'यह समूह खोलने के लिए साइन इन करें';

  @override
  String get groupLockedBody =>
      'यह समूह सिर्फ़ इसके सदस्यों के खातों से खुलता है। उस खाते में साइन इन करें जो इस समूह का सदस्य है।';

  @override
  String get groupForget => 'इस डिवाइस से हटाएँ';

  @override
  String get groupLinkOtherServer =>
      'यह लिंक किसी दूसरे सर्वर का है। इसे खोलने के लिए उस सर्वर से कनेक्ट करें।';

  @override
  String get openLinkTitle => 'समूह का लिंक खोलें';

  @override
  String get openLinkBody => 'किसी ने अपने समूह में शामिल होने के लिए जो लिंक भेजा है, उसे यहाँ चिपकाएँ।';

  @override
  String get openLinkLabel => 'समूह का लिंक';

  @override
  String get openLinkAction => 'खोलें';

  @override
  String get openLinkInvalid => 'यह Balnana समूह का लिंक नहीं लगता।';

  @override
  String get groupName => 'समूह का नाम';

  @override
  String get groupNameHint => 'लिस्बन की यात्रा';

  @override
  String get groupCurrency => 'मुद्रा';

  @override
  String get groupCurrencyHelp => 'इस समूह के सभी खर्च इसी मुद्रा में होंगे। बाद में इसे बदला नहीं जा सकता।';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name। इस समूह के सभी खर्च इसी मुद्रा में होंगे। बाद में इसे बदला नहीं जा सकता।';
  }

  @override
  String get currencyChoose => 'मुद्रा चुनें';

  @override
  String get currencySearchHint => 'कोड या नाम से खोजें';

  @override
  String get currencySuggested => 'सुझाई गई';

  @override
  String get currencyAll => 'सभी मुद्राएँ';

  @override
  String currencyUseTyped(String code) {
    return '$code इस्तेमाल करें';
  }

  @override
  String get currencyNoMatch =>
      'कोई मुद्रा नहीं मिली। इस्तेमाल करने के लिए उसका तीन अक्षरों वाला कोड टाइप करें।';

  @override
  String get groupSymbol => 'चिह्न';

  @override
  String get groupSymbolChoose => 'चिह्न चुनें';

  @override
  String groupSymbolExample(String example) {
    return 'रकम इस तरह दिखेगी: $example';
  }

  @override
  String get groupColor => 'रंग';

  @override
  String colorSwatch(int number, int count) {
    return '$count में से रंग $number';
  }

  @override
  String get groupPeople => 'लोग';

  @override
  String get groupYourName => 'आपका नाम';

  @override
  String groupPersonName(int number) {
    return 'व्यक्ति $number';
  }

  @override
  String get groupAddPerson => 'व्यक्ति जोड़ें';

  @override
  String get groupPeopleHelp => 'आप बाद में और लोगों को जोड़ सकते हैं या वे लिंक से शामिल हो सकते हैं।';

  @override
  String get identityTitle => 'आप कौन हैं?';

  @override
  String get identityBody =>
      'अपना नाम चुनें, ताकि Balnana दिखा सके कि आपको कितना देना है। इसे सिर्फ़ यह डिवाइस याद रखेगा।';

  @override
  String get identityNew => 'मैं नया व्यक्ति हूँ';

  @override
  String get identityNewTitle => 'इस समूह में शामिल हों';

  @override
  String get identityJoin => 'शामिल हों';

  @override
  String get identityChange => 'आप कौन हैं';

  @override
  String get identityNone => 'अभी तक नहीं चुना';

  @override
  String get memberName => 'नाम';

  @override
  String memberYou(String name) {
    return '$name (आप)';
  }

  @override
  String get memberAdd => 'व्यक्ति जोड़ें';

  @override
  String get memberAddTitle => 'किसी को जोड़ें';

  @override
  String get memberRename => 'नाम बदलें';

  @override
  String get memberRenameTitle => 'नाम बदलें';

  @override
  String memberRemoveTitle(String name) {
    return '$name को हटाएँ?';
  }

  @override
  String get memberRemoveBody => 'वे पुराने खर्चों में बने रहेंगे, लेकिन नए खर्चों में नहीं जोड़े जा सकेंगे।';

  @override
  String get groupLinkCopied => 'लिंक कॉपी हो गया। इसे पाने वाला कोई भी व्यक्ति यह समूह खोल सकता है।';

  @override
  String get groupShare => 'लिंक शेयर करें';

  @override
  String get groupSettings => 'समूह की सेटिंग';

  @override
  String get groupEdit => 'समूह में बदलाव करें';

  @override
  String get groupSharing => 'शेयर करना';

  @override
  String get groupCopyLink => 'लिंक कॉपी करें';

  @override
  String get groupQrCode => 'QR कोड दिखाएँ';

  @override
  String get groupQrCodeHelp => 'लोग अपने फ़ोन के कैमरे से लिंक स्कैन कर सकते हैं।';

  @override
  String groupQrLabel(String group) {
    return '$group के लिंक का QR कोड';
  }

  @override
  String get groupCopyLinkHelp =>
      'लिंक वाला कोई भी व्यक्ति इस समूह को देख सकता है और इसमें बदलाव कर सकता है।';

  @override
  String get groupCopyLinkHelpAccounts =>
      'लिंक पाने वाले लोग साइन इन करने के बाद शामिल होने का अनुरोध कर सकते हैं।';

  @override
  String get linkAccessTitle => 'लिंक पाने वाला कोई भी व्यक्ति खोल सकता है';

  @override
  String get linkAccessHelp => 'लोग बिना खाते के देख सकते हैं और बदलाव कर सकते हैं';

  @override
  String get resetLinkTitle => 'लिंक रीसेट करें';

  @override
  String get resetLinkHelp => 'नया लिंक बनाएँ; पुराना काम करना बंद कर देगा';

  @override
  String get resetLinkBody =>
      'मौजूदा लिंक सबके लिए काम करना बंद कर देगा। जिन लोगों को पहुँच देनी है, उन्हें नया लिंक भेजें।';

  @override
  String get resetLinkAction => 'रीसेट करें';

  @override
  String get resetLinkDone => 'लिंक रीसेट हो गया। नया लिंक शेयर करें।';

  @override
  String get groupThisDevice => 'यह डिवाइस';

  @override
  String get groupData => 'डेटा';

  @override
  String get categoriesTitle => 'श्रेणियाँ';

  @override
  String get categoriesHelp => 'अपनी श्रेणियाँ जोड़ें या जिनका इस्तेमाल नहीं करते उन्हें छिपाएँ';

  @override
  String get categoriesOwn => 'इस समूह की';

  @override
  String get categoriesOwnEmpty => 'इस समूह की अभी कोई अपनी श्रेणी नहीं है।';

  @override
  String get categoriesBuiltIn => 'पहले से मौजूद';

  @override
  String get categoriesBuiltInHelp =>
      'छिपी हुई श्रेणियाँ नए खर्चों के लिए नहीं दिखेंगी। जिन खर्चों में वे पहले से हैं, उनमें बनी रहेंगी।';

  @override
  String get categoryAdd => 'श्रेणी जोड़ें';

  @override
  String get categoryEdit => 'श्रेणी में बदलाव करें';

  @override
  String get categoryName => 'नाम';

  @override
  String get categoryDelete => 'श्रेणी मिटाएँ';

  @override
  String categoryDeleteTitle(String name) {
    return '$name मिटाएँ?';
  }

  @override
  String get categoryDeleteBody => 'इस श्रेणी के खर्चों में कोई श्रेणी नहीं रहेगी।';

  @override
  String get categoryDeleteAction => 'मिटाएँ';

  @override
  String get exportCsv => 'CSV के रूप में एक्सपोर्ट करें';

  @override
  String get exportCsvHelp => 'स्प्रेडशीट के लिए सभी खर्च और भुगतान';

  @override
  String get exportCsvDone => 'एक्सपोर्ट हो गया';

  @override
  String get forgetTitle => 'इस डिवाइस से हटाएँ';

  @override
  String get forgetHelp => 'समूह बाकी सभी लोगों के लिए सर्वर पर रहेगा';

  @override
  String get forgetBody => 'आप लिंक से इसे फिर खोल सकते हैं।';

  @override
  String get groupYou => 'आप';

  @override
  String get leaveTitle => 'समूह छोड़ें';

  @override
  String get leaveHelp => 'आपके खर्च बने रहेंगे; लिंक से फिर शामिल हो सकते हैं';

  @override
  String get leaveBody => 'समूह आपकी सूची से हट जाएगा। आपके खर्च और बैलेंस समूह में बने रहेंगे।';

  @override
  String get leaveAction => 'छोड़ें';

  @override
  String get tabExpenses => 'खर्च';

  @override
  String get heroWhoTitle => 'इस समूह में आप कौन हैं?';

  @override
  String get heroWhoBody => 'यह देखने के लिए अपना नाम चुनें कि आपको कितना देना और कितना मिलना है।';

  @override
  String get heroWhoAction => 'चुनें';

  @override
  String get heroJoinTitle => 'आप यह समूह देख रहे हैं';

  @override
  String get heroJoinBody => 'खर्च जोड़ने और अपना बैलेंस देखने के लिए शामिल हों।';

  @override
  String get joinAction => 'शामिल हों';

  @override
  String get heroOwed => 'आपको मिलने हैं';

  @override
  String get heroOwe => 'आपको देने हैं';

  @override
  String get heroSettled => 'आपका हिसाब चुकता है';

  @override
  String heroYouAre(String name) {
    return 'आप $name हैं';
  }

  @override
  String get expenseAdd => 'खर्च जोड़ें';

  @override
  String get expensesEmptyTitle => 'अभी कोई खर्च नहीं';

  @override
  String get expensesEmptyBody => 'पहला खर्च जोड़ें; Balnana हिसाब लगा देगा कि किसे किसको कितना देना है।';

  @override
  String get expensesSearchHint => 'शीर्षक, नोट और जगह खोजें';

  @override
  String get searchClear => 'खोज साफ़ करें';

  @override
  String get expensesNoMatchTitle => 'कुछ नहीं मिला';

  @override
  String get expensesNoMatchBody => 'दूसरे शब्द आज़माएँ या फ़िल्टर कम करें।';

  @override
  String get filterAnyone => 'कोई भी';

  @override
  String get filterAnyCategory => 'कोई भी श्रेणी';

  @override
  String get filterPayments => 'भुगतान';

  @override
  String get filterClear => 'फ़िल्टर साफ़ करें';

  @override
  String get periodAll => 'हर समय';

  @override
  String get periodThisMonth => 'इस महीने';

  @override
  String get periodLastMonth => 'पिछले महीने';

  @override
  String get periodThisYear => 'इस साल';

  @override
  String get periodPickDays => 'तारीखें चुनें…';

  @override
  String get statsTitle => 'खर्च का ब्यौरा';

  @override
  String get statsTotal => 'कुल खर्च';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खर्च',
      one: '1 खर्च',
      zero: '$count खर्च',
    );
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'श्रेणी के अनुसार';

  @override
  String get statsByMember => 'हर व्यक्ति का दिया और हिस्सा';

  @override
  String get statsPaid => 'दिया';

  @override
  String get statsShare => 'हिस्सा';

  @override
  String get statsByMonth => 'महीने के अनुसार';

  @override
  String get statsNoCategory => 'कोई श्रेणी नहीं';

  @override
  String get statsEmptyTitle => 'कोई खर्च नहीं';

  @override
  String get statsEmptyBody => 'इस अवधि में कोई खर्च नहीं है।';

  @override
  String get statsShowExpenses => 'ये खर्च दिखाएँ';

  @override
  String get dateToday => 'आज';

  @override
  String get dateYesterday => 'कल';

  @override
  String paymentTitle(String from, String to) {
    return '$from ने $to को पैसे दिए';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name ने $amount दिए';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return '$count लोगों ने $amount दिए';
  }

  @override
  String expensePaidByName(String name) {
    return '$name ने पैसे दिए';
  }

  @override
  String expensePaidByManyNames(int count) {
    return '$count लोगों ने पैसे दिए';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name को $amount मिले';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$name को मिले';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return '$count लोगों को मिले';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return '$count लोगों को $amount मिले';
  }

  @override
  String get transactionRefund => 'वापसी';

  @override
  String get transactionIncome => 'आमदनी';

  @override
  String get paymentDelete => 'भुगतान मिटाएँ';

  @override
  String get paymentDeleted => 'भुगतान मिटा दिया';

  @override
  String expenseDeleted(String title) {
    return '“$title” मिटा दिया';
  }

  @override
  String get expenseNew => 'नया खर्च';

  @override
  String get expenseEdit => 'खर्च में बदलाव करें';

  @override
  String get expenseDelete => 'मिटाएँ';

  @override
  String get expenseAmount => 'रकम';

  @override
  String get expenseTitle => 'किस चीज़ के लिए?';

  @override
  String get expenseTitleHint => 'खाना, टिकट, टैक्सी…';

  @override
  String get expenseAmountFromPayers => 'सबने कुल कितनी रकम दी';

  @override
  String expensePaidIn(String currency) {
    return '$currency में भुगतान';
  }

  @override
  String expenseRate(String from, String to) {
    return '$to में 1 $from';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return '$currency में कुल रकम';
  }

  @override
  String expenseForeignHelp(String currency) {
    return 'बैलेंस $currency में रहेगा। विनिमय दर या बदली हुई कुल रकम डालें, जैसे कार्ड स्टेटमेंट में दिखती है।';
  }

  @override
  String get expenseNote => 'नोट';

  @override
  String get expenseNoteHint => 'वैकल्पिक';

  @override
  String get expenseLocation => 'जगह';

  @override
  String get expenseLocationHint => 'यह कहाँ हुआ? (वैकल्पिक)';

  @override
  String get locationPickOnMap => 'मैप पर चुनें';

  @override
  String get locationUseCurrent => 'मौजूदा जगह इस्तेमाल करें';

  @override
  String get locationFinding => 'आपकी जगह ढूँढ़ रहे हैं…';

  @override
  String get locationChange => 'मैप पर बदलें';

  @override
  String get locationRemovePin => 'पिन हटाएँ';

  @override
  String get locationOpenInMaps => 'मैप में खोलें';

  @override
  String get locationPickTitle => 'जगह चुनें';

  @override
  String get locationPickHint => 'पिन लगाने के लिए मैप पर टैप करें';

  @override
  String get locationPickDone => 'हो गया';

  @override
  String get locationDenied =>
      'Balnana आपकी जगह इस्तेमाल नहीं कर पा रहा। डिवाइस या ब्राउज़र की सेटिंग में इसकी अनुमति दें।';

  @override
  String get locationOff => 'इस डिवाइस पर लोकेशन बंद है।';

  @override
  String get locationUnavailable => 'आपकी जगह नहीं मिल सकी। फिर कोशिश करें या मैप पर पिन लगाएँ।';

  @override
  String get expenseReceipt => 'रसीद';

  @override
  String get expenseHasReceipt => 'रसीद की फ़ोटो है';

  @override
  String get expenseHasLocation => 'जगह जोड़ी गई है';

  @override
  String get receiptTakePhoto => 'फ़ोटो लें';

  @override
  String get receiptChoose => 'तस्वीर चुनें';

  @override
  String get receiptRemove => 'हटाएँ';

  @override
  String get receiptView => 'रसीद की फ़ोटो';

  @override
  String receiptNotSaved(String reason) {
    return 'खर्च सेव हो गया, लेकिन रसीद की फ़ोटो नहीं। $reason';
  }

  @override
  String get expensePaidByLabel => 'किसने पैसे दिए';

  @override
  String get expenseReceivedForLabel => 'किसके लिए मिले';

  @override
  String get expenseReceivedByLabel => 'किसे पैसे मिले';

  @override
  String get expenseMultiplePayers => 'कई लोगों ने';

  @override
  String get expenseSplit => 'बाँटें';

  @override
  String get splitEqual => 'बराबर';

  @override
  String get splitExact => 'रकम के अनुसार';

  @override
  String get splitShares => 'हिस्सों के अनुसार';

  @override
  String splitLeft(String amount) {
    return 'बाँटने के लिए $amount बाकी';
  }

  @override
  String splitOver(String amount) {
    return '$amount ज़्यादा बाँटे गए';
  }

  @override
  String get conflictTitle => 'कहीं और बदलाव हुआ';

  @override
  String get conflictReload => 'फिर से लोड करें';

  @override
  String get expenseChangedElsewhere =>
      'किसी और ने यह खर्च बदल दिया। फिर से लोड करने पर उनके बदलाव दिखेंगे और आपके बदलाव हट जाएँगे।';

  @override
  String get expenseNewerTitle => 'नए संस्करण से बनाया गया';

  @override
  String get expenseNewerBody => 'इस प्रविष्टि को बदलने के लिए Balnana अपडेट करें।';

  @override
  String get suggestedPayments => 'सुझाए गए भुगतान';

  @override
  String get allSettled => 'सबका हिसाब चुकता है।';

  @override
  String transferYouPay(String name) {
    return 'आप $name को पैसे देंगे';
  }

  @override
  String transferPaysYou(String name) {
    return '$name आपको पैसे देंगे';
  }

  @override
  String transferPays(String from, String to) {
    return '$from, $to को पैसे देंगे';
  }

  @override
  String get recordPayment => 'दर्ज करें';

  @override
  String get recordPaymentTitle => 'भुगतान दर्ज करें';

  @override
  String get recordPaymentHelp => 'यहाँ सिर्फ़ वही पैसे दर्ज करें जिनका भुगतान Balnana के बाहर सचमुच हुआ है।';

  @override
  String get paymentRecorded => 'भुगतान दर्ज हो गया';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who ने $group बनाया';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who ने समूह की जानकारी बदली';
  }

  @override
  String activityLinkReset(String who) {
    return '$who ने समूह का लिंक रीसेट किया';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who ने $name को जोड़ा';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who ने $oldName का नाम बदलकर $name किया';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who ने $name को हटाया';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who ने $name श्रेणी जोड़ी';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who ने श्रेणियाँ बदलीं';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who ने $name श्रेणी मिटाई';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name शामिल हुए';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who ने “$title” ($amount) जोड़ा';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who ने “$title” ($amount) में बदलाव किया';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who ने “$title” मिटाया';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who ने “$title” वापस लाया';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who ने दर्ज किया कि $from ने $to को $amount दिए';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who ने $amount का भुगतान मिटाया';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who ने $amount का भुगतान वापस लाया';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count एंट्री',
      one: '1 एंट्री',
      zero: '$count एंट्री',
    );
    return '$who ने $source से $_temp0 इम्पोर्ट की';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who ने “$title” में रसीद की फ़ोटो जोड़ी';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who ने “$title” से रसीद की फ़ोटो हटाई';
  }

  @override
  String activityOther(String who) {
    return '$who ने बदलाव किया';
  }

  @override
  String get navGroups => 'समूह';

  @override
  String get navActivity => 'गतिविधि';

  @override
  String get navSettings => 'सेटिंग';

  @override
  String get groupsEmptyTitle => 'अभी कोई समूह नहीं';

  @override
  String get groupsEmptyBody => 'आपके बनाए या लिंक से खोले गए समूह यहाँ दिखेंगे।';

  @override
  String get groupsNoServerTitle => 'सर्वर से कनेक्ट करें';

  @override
  String get groupsNoServerBody => 'Balnana आपके समूह आपके चुने हुए सर्वर पर रखता है, जैसे आपका अपना सर्वर।';

  @override
  String get groupsNoServerAction => 'सर्वर चुनें';

  @override
  String get groupsUnreachableTitle => 'सर्वर से संपर्क नहीं हो पा रहा';

  @override
  String get groupsUnreachableBody => 'अपना कनेक्शन या सेटिंग में सर्वर का पता जाँचें।';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count समूह लोड नहीं हो सके, इसलिए उनके बदलाव नहीं दिख रहे।',
      one: 'एक समूह लोड नहीं हो सका, इसलिए उसके बदलाव नहीं दिख रहे।',
      zero: '$count समूह लोड नहीं हो सके, इसलिए उनके बदलाव नहीं दिख रहे।',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => 'अभी यहाँ कुछ नहीं';

  @override
  String get activityEmptyBody => 'आपके समूहों में नए खर्च और भुगतान यहाँ दिखेंगे।';

  @override
  String get notFoundTitle => 'पेज नहीं मिला';

  @override
  String get notFoundBody => 'Balnana में इस पते का कोई पेज नहीं है।';

  @override
  String get notFoundAction => 'समूहों पर जाएँ';

  @override
  String get settingsAppearance => 'दिखावट';

  @override
  String get settingsAccount => 'खाता';

  @override
  String get accountRename => 'नाम बदलें';

  @override
  String get passwordChange => 'पासवर्ड बदलें';

  @override
  String get passwordChanged => 'पासवर्ड बदल गया। दूसरे डिवाइस से साइन आउट हो गया है।';

  @override
  String get passwordSet => 'पासवर्ड बनाएँ';

  @override
  String get passwordSetHelp => 'ईमेल या यूज़रनेम और पासवर्ड से भी साइन इन करें';

  @override
  String get passwordSetDone => 'पासवर्ड बन गया। दूसरे डिवाइस से साइन आउट हो गया है।';

  @override
  String get passwordCurrent => 'मौजूदा पासवर्ड';

  @override
  String get passwordNew => 'नया पासवर्ड';

  @override
  String get signOut => 'साइन आउट करें';

  @override
  String get accountOAuthLinked => 'इस खाते में साइन इन करने का तरीका। हटाने के लिए टैप करें।';

  @override
  String get accountOAuthAdd => 'साइन इन का तरीका जोड़ें';

  @override
  String accountOAuthAddTitle(String name) {
    return '$name जोड़ें';
  }

  @override
  String accountOAuthAdded(String name) {
    return 'अब आप $name से साइन इन कर सकते हैं।';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return '$name हटाएँ?';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return 'जब तक आप इसे फिर से नहीं जोड़ेंगे, $name से साइन इन नहीं कर पाएँगे।';
  }

  @override
  String get accountOAuthRemove => 'हटाएँ';

  @override
  String accountOAuthRemoved(String name) {
    return '$name हटा दिया';
  }

  @override
  String get confirmEmailTitle => 'अपने ईमेल की पुष्टि करें';

  @override
  String confirmEmailBody(String email) {
    return 'इस सर्वर पर पुष्टि किया हुआ ईमेल ज़रूरी है। $email पर भेजा गया लिंक खोलें।';
  }

  @override
  String get confirmEmailDone => 'मैंने पुष्टि कर दी';

  @override
  String get confirmEmailResend => 'लिंक फिर भेजें';

  @override
  String get confirmEmailNotYet => 'अभी पुष्टि नहीं हुई। ईमेल में आया लिंक खोलें।';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get themeSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get themeLight => 'हल्की';

  @override
  String get themeDark => 'गहरी';

  @override
  String get settingsDynamicColor => 'वॉलपेपर के रंग';

  @override
  String get settingsDynamicColorSubtitle => 'Balnana के पीले रंग के बजाय अपने डिवाइस के रंग इस्तेमाल करें';

  @override
  String get settingsWallpaperGroups => 'समूहों में वॉलपेपर के रंग';

  @override
  String get settingsWallpaperGroupsSubtitle => 'समूह भी अपने रंगों के बजाय डिवाइस के रंग इस्तेमाल करेंगे';

  @override
  String get settingsPureBlack => 'एकदम काला';

  @override
  String get settingsPureBlackSubtitle => 'OLED स्क्रीन के लिए और गहरी थीम';

  @override
  String get settingsMyShare => 'मेरा हिस्सा दिखाएँ';

  @override
  String get settingsMyShareSubtitle => 'खर्चों में कुल रकम के बजाय दिखाएँ कि आपने कितना उधार दिया या लिया';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get settingsNotifications => 'सूचनाएँ';

  @override
  String get settingsNotificationsSubtitle => 'जब कोई आपके शामिल खर्च को जोड़े, बदले या मिटाए';

  @override
  String get settingsNotificationsBlocked =>
      'फ़ोन की सेटिंग में बंद है: सूचनाएँ देखने के लिए वहाँ Balnana को अनुमति दें';

  @override
  String get pushChannel => 'खर्च';

  @override
  String get pushChannelDescription => 'जब कोई आपके शामिल खर्च को जोड़े, बदले या मिटाए';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who ने $title जोड़ा · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who ने $title बदला · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who ने $title मिटाया · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return '$title जोड़ा गया · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return '$title बदला गया · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return '$title मिटाया गया · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payer ने $payee को $amount दिए';
  }

  @override
  String get settingsConnection => 'कनेक्शन';

  @override
  String get settingsServer => 'सर्वर';

  @override
  String get serverNotSet => 'सेट नहीं है';

  @override
  String get settingsAbout => 'जानकारी';

  @override
  String get aboutVersion => 'वर्शन';

  @override
  String get aboutLicenses => 'ओपन सोर्स लाइसेंस';

  @override
  String get aboutSource => 'सोर्स कोड';

  @override
  String get aboutSourceCopied => 'ब्राउज़र नहीं खुला, इसलिए लिंक कॉपी कर दिया';

  @override
  String get serverTitle => 'सर्वर';

  @override
  String get serverIntro =>
      'Balnana सर्वर का पता डालें। कोई भी सर्वर चला सकता है; आमतौर पर इसका web app इसी पते पर खुलता है।';

  @override
  String get serverUrlLabel => 'सर्वर का पता';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => 'कनेक्शन जाँचें';

  @override
  String get serverSaveAnyway => 'फिर भी सेव करें';

  @override
  String get serverReset => 'डिफ़ॉल्ट इस्तेमाल करें';

  @override
  String serverDefault(String url) {
    return 'डिफ़ॉल्ट: $url';
  }

  @override
  String serverConnected(String version) {
    return 'Balnana $version से कनेक्ट है';
  }

  @override
  String get serverModeLink => 'समूह निजी लिंक से शेयर होते हैं। खाते की ज़रूरत नहीं।';

  @override
  String get serverModeAccounts => 'लोग खाते से साइन इन करते हैं।';

  @override
  String get serverInsecure =>
      'यह पता एन्क्रिप्टेड नहीं है (http)। नेटवर्क पर कोई भी आपका डेटा पढ़ सकता है। अपने घर के नेटवर्क के बाहर के सर्वर के लिए https इस्तेमाल करें।';

  @override
  String get serverErrorInvalid => 'वेब पता डालें, जैसे balnana.example.com';

  @override
  String get serverErrorUnreachable => 'कनेक्ट नहीं हो सका। पता सही है और सर्वर चल रहा है या नहीं, जाँचें।';

  @override
  String get serverErrorNotBalnana => 'जवाब तो मिला, लेकिन यह Balnana सर्वर नहीं है।';

  @override
  String get serverSaved => 'सर्वर सेव हो गया';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get groupSignInTitle => 'यह समूह खोलने के लिए साइन इन करें';

  @override
  String get groupSignInBody =>
      'यह समूह सिर्फ़ इसके सदस्यों के लिए है। इसे देखने या शामिल होने के लिए साइन इन करें।';

  @override
  String get signInTitle => 'वापसी पर आपका स्वागत है';

  @override
  String get signInBody => 'अपने समूह देखने के लिए साइन इन करें।';

  @override
  String get signInNoPassword =>
      'यह सर्वर लोगों को किसी और तरीके से साइन इन करता है। इसे चलाने वाले व्यक्ति से पूछें।';

  @override
  String get registerTitle => 'अपना खाता बनाएँ';

  @override
  String get registerBody => 'अपने समूह हर डिवाइस पर पाएँ।';

  @override
  String get registerAction => 'खाता बनाएँ';

  @override
  String get registerHaveAccount => 'मेरा खाता पहले से है';

  @override
  String get signInNoAccount => 'खाता बनाएँ';

  @override
  String get accountName => 'आपका नाम';

  @override
  String get accountNameHelp => 'आपके समूहों के लोग यह नाम देखेंगे';

  @override
  String get accountEmail => 'ईमेल';

  @override
  String get accountPassword => 'पासवर्ड';

  @override
  String get accountPasswordHelp => 'कम से कम 8 अक्षर';

  @override
  String get passwordShow => 'पासवर्ड दिखाएँ';

  @override
  String get passwordHide => 'पासवर्ड छिपाएँ';

  @override
  String get joinPickName => 'दूसरा नाम चुनें';

  @override
  String joinTitle(String name) {
    return '$name से जुड़ें';
  }

  @override
  String get joinBody => 'क्या आप इनमें से कोई हैं? उनके खर्च संभालने के लिए अपना नाम चुनें।';

  @override
  String get joinBodyNew => 'खर्च जोड़ने और अपना बैलेंस देखने के लिए शामिल हों।';

  @override
  String get joinAsNew => 'मैं नया व्यक्ति हूँ';

  @override
  String joinAsName(String name) {
    return '$name के रूप में शामिल हों';
  }

  @override
  String joinTaken(String names) {
    return 'पहले से शामिल हैं: $names';
  }

  @override
  String joinTakenCount(int count) {
    return '$count लोग पहले ही शामिल हो चुके हैं।';
  }

  @override
  String get commonContinue => 'जारी रखें';

  @override
  String get errorEmailOff => 'यह सर्वर ईमेल नहीं भेजता।';

  @override
  String get errorInvalidToken => 'यह लिंक की समय-सीमा खत्म हो गई है या इसका इस्तेमाल हो चुका है।';

  @override
  String get forgotPasswordTitle => 'पासवर्ड भूल गए?';

  @override
  String get forgotPasswordBody => 'नया पासवर्ड चुनने का लिंक हम आपको ईमेल करेंगे।';

  @override
  String get forgotPasswordAction => 'लिंक भेजें';

  @override
  String get forgotPasswordSent => 'अगर इस पते से कोई खाता है, तो उसका लिंक भेजा जा रहा है।';

  @override
  String get resetPasswordTitle => 'नया पासवर्ड चुनें';

  @override
  String get resetPasswordBody => 'आप हर जगह से साइन आउट हो जाएँगे, फिर नए पासवर्ड से साइन इन कर सकेंगे।';

  @override
  String get resetPasswordAction => 'पासवर्ड सेव करें';

  @override
  String get resetPasswordDone => 'पासवर्ड बदल गया। नए पासवर्ड से साइन इन करें।';

  @override
  String get verifyEmailTitle => 'अपने ईमेल की पुष्टि करें';

  @override
  String get verifyEmailHelp => 'ताकि पासवर्ड भूलने पर आप उसे रीसेट कर सकें';

  @override
  String verifyEmailSent(String email) {
    return 'लिंक के लिए $email देखें।';
  }

  @override
  String get verifyEmailDone => 'ईमेल की पुष्टि हो गई';

  @override
  String get verifyEmailDoneBody => 'शुक्रिया! आपके पते की पुष्टि हो गई।';

  @override
  String get verifyEmailFailed => 'आपके ईमेल की पुष्टि नहीं हो सकी';

  @override
  String get inviteByEmail => 'ईमेल से आमंत्रित करें';

  @override
  String get inviteByEmailHelp => 'किसी को शामिल होने का लिंक भेजें';

  @override
  String get inviteAs => 'किसके रूप में शामिल हों';

  @override
  String get inviteAsHelp => 'वे इस व्यक्ति के खर्च संभाल सकते हैं';

  @override
  String get inviteAsAnyone => 'कोई नया व्यक्ति';

  @override
  String get inviteSend => 'आमंत्रण भेजें';

  @override
  String inviteSent(String email) {
    return '$email को आमंत्रण भेज दिया।';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name ने आपको $group में आमंत्रित किया';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return 'आपको $group में आमंत्रित किया गया है';
  }

  @override
  String inviteBody(String email) {
    return 'शामिल होने के लिए $email का इस्तेमाल करके खाता बनाएँ, या खाता है तो साइन इन करें।';
  }

  @override
  String get inviteBodySignedIn => 'खर्च जोड़ने और अपना बैलेंस देखने के लिए शामिल हों।';

  @override
  String get inviteAction => 'आमंत्रण खोलें';

  @override
  String get inviteMissingTitle => 'यह आमंत्रण काम नहीं करता';

  @override
  String get inviteMissingBody =>
      'इसकी समय-सीमा खत्म हो गई होगी या इसका इस्तेमाल हो चुका होगा। नया आमंत्रण माँगें।';

  @override
  String get joinInvitedAs => 'आपको इस व्यक्ति के रूप में आमंत्रित किया गया था';

  @override
  String signInWith(String provider) {
    return '$provider से जारी रखें';
  }

  @override
  String get signInOr => 'या';

  @override
  String get oauthFailedTitle => 'आप साइन इन नहीं कर सके';

  @override
  String get oauthPendingTitle => 'इस ईमेल से पहले से एक खाता है';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider का कहना है कि $email आपका ईमेल है, लेकिन इस ईमेल वाले खाते की पुष्टि नहीं हुई है। क्या करना है?';
  }

  @override
  String get oauthPendingLink => 'उस खाते में जोड़ें';

  @override
  String get oauthPendingLinkHelp => 'उस खाते का पासवर्ड डालें। उसका पासवर्ड काम करता रहेगा।';

  @override
  String get oauthPendingTakeOver => 'उस खाते का नियंत्रण लें';

  @override
  String get oauthPendingTakeOverHelp =>
      'उस खाते का पासवर्ड और साइन इन के दूसरे तरीके हट जाएँगे, और उससे सभी डिवाइस साइन आउट हो जाएँगे।';

  @override
  String get oauthPendingNew => 'नया खाता बनाएँ';

  @override
  String oauthPendingNewHelp(String email) {
    return 'दूसरे खाते के समूह बने रहेंगे, लेकिन उसमें $email नहीं रहेगा।';
  }

  @override
  String get oauthPendingPassword => 'उस खाते का पासवर्ड';

  @override
  String get oauthPendingWrongPassword => 'यह पासवर्ड सही नहीं है।';

  @override
  String get oauthOtherServer =>
      'यह साइन इन मौजूदा चुने गए सर्वर के बजाय किसी दूसरे सर्वर पर शुरू हुआ था। फिर से साइन इन करें।';

  @override
  String get oauthBackToSignIn => 'साइन इन पर वापस जाएँ';

  @override
  String get errorOAuthFailed => 'साइन इन नहीं हो सका। फिर कोशिश करें।';

  @override
  String get errorEmailHasAccount =>
      'इस ईमेल से पहले से एक खाता है। उसमें साइन इन करें, फिर सेटिंग में साइन इन का यह तरीका जोड़ें।';

  @override
  String get errorIdentityTaken => 'साइन इन का यह तरीका पहले से किसी दूसरे खाते से जुड़ा है।';

  @override
  String get errorLastSignInMethod =>
      'साइन इन का यह आपका एकमात्र तरीका है। पहले पासवर्ड बनाएँ या कोई दूसरा तरीका जोड़ें।';

  @override
  String get errorEmailUnverified => 'पहले अपने ईमेल की पुष्टि करें।';

  @override
  String get errorOAuthCancelled => 'साइन इन रद्द कर दिया गया।';

  @override
  String get importTitle => 'Settle Up से इम्पोर्ट करें';

  @override
  String get importAction => 'इम्पोर्ट करें';

  @override
  String get importIntro =>
      'Settle Up में समूह को CSV फ़ाइल के रूप में एक्सपोर्ट करें, फिर यहाँ फ़ाइल चुनें। खर्च, भुगतान और समूह के सभी लोग साथ आएँगे और बैलेंस वही रहेंगे।';

  @override
  String get importChooseFile => 'CSV फ़ाइल चुनें';

  @override
  String get importChooseOther => 'दूसरी फ़ाइल चुनें';

  @override
  String get importReading => 'फ़ाइल पढ़ी जा रही है…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(
      expenses,
      locale: localeName,
      other: '$expenses खर्च',
      one: '1 खर्च',
      zero: '$expenses खर्च',
    );
    String _temp1 = intl.Intl.pluralLogic(
      payments,
      locale: localeName,
      other: '$payments भुगतान',
      one: '1 भुगतान',
      zero: '$payments भुगतान',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return '$from से $to तक';
  }

  @override
  String importCurrency(String currency) {
    return 'मुद्रा: $currency। दूसरी मुद्राओं की एंट्री में Settle Up की बदली हुई रकम इस्तेमाल होंगी।';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'शून्य रकम वाली $count एंट्री शामिल नहीं की गईं।',
      one: 'शून्य रकम वाली 1 एंट्री शामिल नहीं की गई।',
      zero: 'शून्य रकम वाली $count एंट्री शामिल नहीं की गई।',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => 'इनमें से आप कौन हैं?';

  @override
  String get importUntitled => 'बिना शीर्षक';

  @override
  String get errorImportFile => 'यह Settle Up की CSV एक्सपोर्ट फ़ाइल नहीं लगती।';

  @override
  String get errorImportCurrency =>
      'फ़ाइल में विनिमय दर के बिना कोई एंट्री नहीं है, इसलिए समूह की मुद्रा पता नहीं चल सकती।';

  @override
  String get errorImportTooBig => 'यह फ़ाइल इम्पोर्ट करने के लिए बहुत बड़ी है।';

  @override
  String get errorBadImage => 'यह तस्वीर इस्तेमाल नहीं की जा सकती। JPEG, PNG या WebP तस्वीर चुनें।';

  @override
  String get errorReceiptTooBig => 'यह तस्वीर बहुत बड़ी है। 10 MB से छोटी तस्वीर चुनें।';

  @override
  String get errorImportMe => 'चुनें कि आप कौन हैं।';

  @override
  String errorImportRow(int line, String reason) {
    return 'फ़ाइल की $lineवीं पंक्ति इम्पोर्ट नहीं हो सकती: $reason';
  }

  @override
  String get errorImportAmount => 'रकम पढ़ी नहीं जा सकती।';

  @override
  String get errorImportCounts => 'नाम और रकम आपस में मेल नहीं खाते।';

  @override
  String get errorImportDate => 'तारीख पढ़ी नहीं जा सकती।';

  @override
  String get errorImportType => 'यह खर्च, भुगतान या आमदनी नहीं है।';

  @override
  String get errorImportTransfer => 'भुगतान में एक व्यक्ति किसी दूसरे को पैसे देता है।';

  @override
  String get errorImportRowCurrency => 'यह किसी दूसरी मुद्रा में है और इसकी विनिमय दर नहीं है।';

  @override
  String get adminSetupTitle => 'इस सर्वर को सेट अप करें';

  @override
  String get adminSetupBody =>
      'एडमिन के लिए पासवर्ड चुनें। इससे यह पेज सुरक्षित रहता है, जहाँ सर्वर की सेटिंग हैं। यूज़रनेम नहीं है: पासवर्ड जानने वाला कोई भी व्यक्ति सेटिंग बदल सकता है।';

  @override
  String get adminSetupCode => 'सेटअप कोड';

  @override
  String get adminSetupCodeHelp =>
      'इस सर्वर पर पहले से डेटा है, इसलिए शुरू होने पर इसके लॉग में सेटअप कोड दिखा था। Docker में: docker compose logs balnana';

  @override
  String get adminSetupAction => 'पासवर्ड सेट करें';

  @override
  String get adminPassword => 'एडमिन पासवर्ड';

  @override
  String get adminPasswordRepeat => 'पासवर्ड फिर से डालें';

  @override
  String get adminPasswordMismatch => 'पासवर्ड मेल नहीं खाते।';

  @override
  String get adminLoginTitle => 'एडमिन पैनल';

  @override
  String get adminLoginBody => 'इस सर्वर की सेटिंग बदलने के लिए एडमिन पासवर्ड डालें।';

  @override
  String get adminLoginAction => 'साइन इन करें';

  @override
  String get adminSettingsTitle => 'सर्वर की सेटिंग';

  @override
  String get adminSaved => 'सेटिंग सेव हो गईं। वे तुरंत लागू होंगी।';

  @override
  String get adminSaveFailed => 'कुछ भी सेव नहीं हुआ। हाइलाइट की गई सेटिंग जाँचें।';

  @override
  String get adminChangePassword => 'एडमिन पासवर्ड बदलें';

  @override
  String get adminPasswordCurrent => 'मौजूदा पासवर्ड';

  @override
  String get adminPasswordNew => 'नया पासवर्ड';

  @override
  String get adminPasswordChanged => 'पासवर्ड बदल गया। एडमिन के दूसरे सेशन से साइन आउट हो गया है।';

  @override
  String get adminSignOut => 'एडमिन पैनल से साइन आउट करें';

  @override
  String get adminBackHome => 'Balnana पर वापस जाएँ';

  @override
  String get adminRequireEmail => 'ईमेल पता ज़रूरी करें';

  @override
  String get adminRequireEmailHelp =>
      'बंद होने पर लोग यूज़रनेम से खाता बना सकते हैं और ईमेल पता छोड़ सकते हैं। वे इनमें से किसी से भी साइन इन कर सकते हैं।';

  @override
  String get adminRequireEmailUnused =>
      'यह सिर्फ़ ईमेल और पासवर्ड से साइन इन करने पर लागू है, जो अभी बंद है।';

  @override
  String get accountUsername => 'यूज़रनेम';

  @override
  String get accountUsernameHelp => '3 से 32 अक्षर, अंक, बिंदु, डैश या अंडरस्कोर। इसी से साइन इन करें।';

  @override
  String get accountEmailOptional => 'ईमेल (वैकल्पिक)';

  @override
  String get accountEmailOptionalHelp =>
      'इससे आप समूह के आमंत्रण पा सकते हैं और भूला हुआ पासवर्ड रीसेट कर सकते हैं।';

  @override
  String get accountLogin => 'ईमेल या यूज़रनेम';

  @override
  String get errorInvalidUsername =>
      '3 से 32 अक्षर, अंक, बिंदु, डैश या अंडरस्कोर इस्तेमाल करें। शुरुआत अक्षर या अंक से होनी चाहिए।';

  @override
  String get errorUsernameTaken => 'यह यूज़रनेम पहले से किसी ने लिया है।';

  @override
  String get adminDiscardTitle => 'बदलाव छोड़ दें?';

  @override
  String get adminDiscardBody => 'सेटिंग में आपके बदलाव सेव नहीं हुए हैं।';

  @override
  String get adminDiscard => 'छोड़ दें';

  @override
  String adminLocked(String key) {
    return 'सर्वर पर $key के ज़रिए सेट है';
  }

  @override
  String adminDefault(String value) {
    return 'डिफ़ॉल्ट: $value';
  }

  @override
  String get adminSecretSaved => 'सेव हो गया। बदलने के लिए नया मान डालें।';

  @override
  String get adminSecretRemoved => 'सेव करने पर हटा दिया जाएगा।';

  @override
  String get adminSecretRemove => 'सेव किया हुआ मान हटाएँ';

  @override
  String get adminSectionGeneral => 'सामान्य';

  @override
  String get adminSectionAccess => 'पहुँच';

  @override
  String get adminSectionMaps => 'मैप';

  @override
  String get adminSectionAccounts => 'खाते';

  @override
  String get adminSectionAccountsBody => 'ये तब लागू होते हैं जब पहुँच खातों के ज़रिए हो।';

  @override
  String get adminSectionEmail => 'ईमेल (SMTP)';

  @override
  String get adminSectionEmailBody => 'पते की पुष्टि, पासवर्ड रीसेट और आमंत्रण।';

  @override
  String get adminSmtpOn => 'ईमेल भेजें';

  @override
  String get adminSectionGoogle => 'Google से साइन इन';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Google Cloud कंसोल में $url को रीडायरेक्ट URI के रूप में रजिस्टर करें।';
  }

  @override
  String get adminGoogleOn => 'Google से साइन इन का विकल्प दें';

  @override
  String get adminGoogleOnHelp => 'लोग अपने Google खाते से साइन इन करेंगे।';

  @override
  String get adminSectionOidc => 'OpenID Connect से साइन इन';

  @override
  String adminSectionOidcBody(String url) {
    return 'प्रदाता के साथ $url को रीडायरेक्ट URI के रूप में रजिस्टर करें।';
  }

  @override
  String get adminOidcHelp =>
      'कोई भी OpenID Connect प्रदाता, जैसे Authentik, Keycloak या Dex। जितने चाहें जोड़ें।';

  @override
  String get adminOidcAdd => 'प्रदाता जोड़ें';

  @override
  String get adminOidcRemove => 'प्रदाता हटाएँ';

  @override
  String get adminOidcNew => 'नया प्रदाता';

  @override
  String get adminOidcId => 'ID';

  @override
  String get adminOidcIdHelp =>
      'छोटे अक्षर, अंक और डैश। यह रीडायरेक्ट URI का हिस्सा है और बाद में बदला नहीं जा सकता।';

  @override
  String get adminOidcIdInvalid =>
      '32 अक्षरों तक छोटे अक्षर, अंक और डैश इस्तेमाल करें। शुरुआत अक्षर या अंक से होनी चाहिए।';

  @override
  String get adminOidcIdTaken => 'इस ID वाला दूसरा प्रदाता पहले से है।';

  @override
  String get adminTrustEmail => 'इसके ईमेल पर भरोसा करें';

  @override
  String get adminGoogleTrustEmailHelp =>
      'जिस ईमेल से पहले से खाता है, उससे Google साइन इन करने पर उसी खाते में साइन इन होगा। बंद होने पर: लोग पासवर्ड से साइन इन करके सेटिंग में Google जोड़ेंगे।';

  @override
  String get adminOidcTrustEmailHelp =>
      'सिर्फ़ उस प्रदाता के लिए जिसका ईमेल जाँचने पर आपको भरोसा हो। बंद होने पर: खाते वाले लोग पासवर्ड से साइन इन करके उसे सेटिंग में जोड़ेंगे।';

  @override
  String get adminRequireVerified => 'पुष्टि किया हुआ ईमेल ज़रूरी करें';

  @override
  String get adminRequireVerifiedHelp =>
      'ईमेल की पुष्टि होने तक खाते app इस्तेमाल नहीं कर सकते। उसी ईमेल से भरोसेमंद साइन इन, बिना पुष्टि वाले खाते का नियंत्रण ले लेता है। बंद होने पर: लोग तय करेंगे कि क्या करना है।';

  @override
  String get adminRequireVerifiedUnused => 'ईमेल भेजना चालू होना ज़रूरी है।';

  @override
  String get adminSectionAndroid => 'Android app लिंक';

  @override
  String get adminSectionAndroidBody =>
      'इस सर्वर के लिए बनाए गए Android app इसके लिंक खोलते हैं। बिना पूछे लिंक खोलने के लिए उन प्रमाणपत्रों के SHA-256 फ़िंगरप्रिंट की सूची दें जिनसे ये app साइन किए गए हैं।';

  @override
  String get adminSectionAdmin => 'एडमिन';

  @override
  String get adminPublicUrl => 'सार्वजनिक पता';

  @override
  String get adminPublicUrlHelp =>
      'इस सर्वर तक पहुँचने के लिए लोग जिस पते का इस्तेमाल करते हैं। समूह और ईमेल लिंक इसी से बनते हैं।';

  @override
  String get adminSourceUrl => 'सोर्स कोड का लिंक';

  @override
  String get adminSourceUrlHelp =>
      'बदला हुआ वर्शन चलाने पर लाइसेंस (AGPL-3.0) के अनुसार लोगों को इस सर्वर का सोर्स कोड यहाँ मिलना चाहिए।';

  @override
  String get adminAuthMode => 'पहुँच';

  @override
  String get adminAuthModeLink => 'समूह के लिंक';

  @override
  String get adminAuthModeLinkHelp => 'साइन इन की ज़रूरत नहीं: समूह का निजी लिंक ही काफ़ी है।';

  @override
  String get adminAuthModeAccounts => 'खाते';

  @override
  String get adminAuthModeAccountsHelp =>
      'लोग साइन इन करते हैं और लिंक से सिर्फ़ साइन इन किए हुए लोग समूह में शामिल हो सकते हैं।';

  @override
  String get adminPasswordLogin => 'ईमेल और पासवर्ड से साइन इन';

  @override
  String get adminPasswordForced =>
      'Google या OpenID Connect से साइन इन चालू होने तक यह चालू रहेगा, ताकि साइन इन का एक तरीका हमेशा रहे।';

  @override
  String get adminSignup => 'कौन खाता बना सकता है';

  @override
  String get adminSignupOpen => 'कोई भी';

  @override
  String get adminSignupOpenHelp => 'जो भी इस सर्वर तक पहुँच सकता है, खाता बना सकता है।';

  @override
  String get adminSignupInvite => 'आमंत्रित लोग';

  @override
  String get adminSignupInviteHelp =>
      'सिर्फ़ ईमेल से समूह में आमंत्रित लोग खाता बना सकते हैं, और सिर्फ़ उसी पते से जिस पर आमंत्रण गया। सिर्फ़ समूह के लिंक से कोई शामिल नहीं हो सकता। आमंत्रण के लिए ईमेल चालू होना चाहिए।';

  @override
  String get adminSignupClosed => 'कोई नहीं';

  @override
  String get adminSignupClosedHelp => 'कोई नया खाता नहीं बना सकता। मौजूदा खाते काम करते रहेंगे।';

  @override
  String get adminSignupHelp => 'पहला खाता हमेशा बनाया जा सकता है।';

  @override
  String get adminLinkGroups => 'लिंक से समूह खोलने की अनुमति दें';

  @override
  String get adminLinkGroupsHelp =>
      'समूह के मालिक बिना साइन इन किए, लिंक पाने वाले किसी भी व्यक्ति को शामिल होने दे सकते हैं।';

  @override
  String get adminSmtpHost => 'मेल सर्वर';

  @override
  String get adminSmtpPort => 'पोर्ट';

  @override
  String get adminSmtpUser => 'यूज़रनेम';

  @override
  String get adminSmtpPassword => 'पासवर्ड';

  @override
  String get adminSmtpFrom => 'भेजने वाला';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'क्लाइंट ID';

  @override
  String get adminClientSecret => 'क्लाइंट सीक्रेट';

  @override
  String get adminOidcIssuer => 'जारीकर्ता URL';

  @override
  String get adminOidcName => 'बटन का नाम';

  @override
  String get adminOidcNameHelp => 'साइन इन पेज पर “... के साथ जारी रखें” के रूप में दिखता है।';

  @override
  String get adminFingerprints => 'प्रमाणपत्र फ़िंगरप्रिंट';

  @override
  String get adminFingerprintsHelp =>
      'अल्पविराम से अलग किए हुए SHA-256। इन्हें देखने के लिए keytool -list -v और apksigner verify --print-certs चलाएँ।';

  @override
  String get adminInvalidValue => 'यह मान सही नहीं है।';

  @override
  String get adminInvalidUrl => 'https:// या http:// से शुरू होने वाला पूरा पता डालें।';

  @override
  String get adminInvalidFrom =>
      'Balnana <balnana@example.com> जैसा भेजने वाला डालें; इसमें ईमेल होना चाहिए।';

  @override
  String get adminInvalidPort => '1 से 65535 के बीच पोर्ट नंबर डालें।';

  @override
  String get adminInvalidRequired => 'इस साइन इन प्रदाता के लिए यह ज़रूरी है।';

  @override
  String get adminInvalidFingerprint =>
      'SHA-256 फ़िंगरप्रिंट डालें: हर एक में 64 हेक्साडेसिमल अंक, कोलन इस्तेमाल कर सकते हैं।';

  @override
  String get adminNeedsSignIn =>
      'खातों के लिए साइन इन का तरीका ज़रूरी है: ईमेल और पासवर्ड चालू करें या प्रदाता सेट अप करें।';

  @override
  String get adminLockedChange => 'यह सर्वर पर सेट है और यहाँ बदला नहीं जा सकता।';

  @override
  String get errorAdminRequired => 'आपका एडमिन सेशन खत्म हो गया है। फिर से साइन इन करें।';

  @override
  String get errorAdminWrongPassword => 'यह पासवर्ड सही नहीं है।';

  @override
  String get errorInvalidSetupCode => 'यह सेटअप कोड सही नहीं है। इसे सर्वर के लॉग में देखें।';

  @override
  String get errorAlreadySetUp => 'यह सर्वर पहले से सेट अप है। इसके एडमिन पासवर्ड से साइन इन करें।';

  @override
  String get linkOpening => 'लिंक खुल रहा है…';

  @override
  String get linkForeignTitle => 'यह लिंक दूसरे सर्वर का है';

  @override
  String linkForeignBody(String server) {
    return 'यह app $server से कनेक्ट है और लिंक किसी दूसरे सर्वर का है। इसे खोलने के लिए सेटिंग में सर्वर बदलें।';
  }

  @override
  String get linkInvalidTitle => 'यह लिंक नहीं खुल सकता';

  @override
  String get linkInvalidBody => 'यह Balnana का ऐसा लिंक नहीं है जिसे यह app पहचानता हो।';

  @override
  String get linkGoHome => 'समूहों पर जाएँ';

  @override
  String get linkOpenInBrowser => 'ब्राउज़र में खोलें';

  @override
  String get privacyTitle => 'गोपनीयता नीति';

  @override
  String get privacyIntro =>
      'Balnana ओपन सोर्स सॉफ़्टवेयर है। यह app जिस सर्वर से कनेक्ट है, उसे चलाने वाला व्यक्ति (ऑपरेटर) तय करता है कि आपका डेटा कहाँ रखा जाए और उसकी ज़िम्मेदारी उसी की है। इस पेज पर बताया गया है कि सॉफ़्टवेयर खुद क्या सेव करता है और क्या करता है।';

  @override
  String get privacyStoredTitle => 'क्या सेव होता है';

  @override
  String get privacyStoredBody =>
      'आपके बनाए या जिन समूहों में आप शामिल हों, उनकी जानकारी: नाम, सदस्यों के नाम, खर्च, भुगतान, नोट, रसीद की फ़ोटो और खर्चों में जोड़ी गई जगहें। खाते के साथ आपका नाम, ईमेल पता या यूज़रनेम, पासवर्ड का हैश (पासवर्ड खुद कभी नहीं) और आप किस प्रदाता से साइन इन करते हैं, जैसे Google। सूचनाएँ चालू होने पर आपके डिवाइस की पहचान और इसकी पुश सेवा से मिला पता भी सेव होता है।';

  @override
  String get privacyUseTitle => 'इसका इस्तेमाल कैसे होता है';

  @override
  String get privacyUseBody =>
      'सिर्फ़ app चलाने के लिए: हर समूह को उसके सदस्यों को दिखाने, बैलेंस निकालने और app के लिए ज़रूरी ईमेल व सूचनाएँ भेजने में, जैसे पते की पुष्टि, पासवर्ड रीसेट और आमंत्रण। app में विज्ञापन या एनालिटिक्स नहीं हैं और कुछ बेचा नहीं जाता।';

  @override
  String get privacySharedTitle => 'इसे कौन देख सकता है';

  @override
  String get privacySharedBody =>
      'समूह में हर कोई उसके सदस्यों, खर्चों और इतिहास को देख सकता है। लिंक से खुलने वाले समूह को लिंक पाने वाला कोई भी व्यक्ति खोल सकता है। Google से साइन इन Google के ज़रिए होता है। ऑपरेटर सूचनाएँ चालू करे, तो वे आपके फ़ोन की पुश सेवा से जाती हैं: Google की Firebase Cloud Messaging या आपके इंस्टॉल किए हुए किसी दूसरी UnifiedPush सेवा, जैसे ntfy, से। सूचना की सामग्री रास्ते में एन्क्रिप्टेड रहती है। मैप की तस्वीरें ऑपरेटर के चुने मैप प्रदाता से आती हैं, आमतौर पर OpenFreeMap से; उसे आपका नेटवर्क पता और आप कौन-सा इलाका देख रहे हैं, पता चलता है। आपकी जगह सिर्फ़ तब पढ़ी जाती है जब आप “मौजूदा जगह इस्तेमाल करें” टैप करते हैं, और सेव सिर्फ़ वही बिंदु होता है जिसे आप बाद में रखते हैं।';

  @override
  String get privacyDeviceTitle => 'इस डिवाइस पर';

  @override
  String get privacyDeviceBody =>
      'app ऑफ़लाइन होने पर काम आए, इसलिए सर्वर का पता, आपकी सेटिंग और समूहों की एक कॉपी इस डिवाइस पर रखता है। app अनइंस्टॉल करने पर ये हट जाते हैं।';

  @override
  String get privacyDeleteTitle => 'अपना डेटा मिटाना';

  @override
  String get privacyDeleteBody =>
      'आप सेटिंग में अपना खाता मिटा सकते हैं। आपके समूहों में आपका नाम ऐसे सदस्य के रूप में बना रहेगा जिसका दावा किसी ने नहीं किया, ताकि बैलेंस का जोड़ सही रहे। जिन समूहों तक कोई और नहीं पहुँच सकता, वे भी मिट जाएँगे। समूह का मालिक उसकी सेटिंग में पूरा समूह मिटा सकता है। मिटाए गए समूह और मिटाए गए खर्चों की तस्वीरें 30 दिनों के बाद हमेशा के लिए हटा दी जाती हैं। बाकी किसी बात के लिए सर्वर ऑपरेटर से संपर्क करें।';

  @override
  String get privacyOperatorPolicy => 'ऑपरेटर की गोपनीयता नीति';

  @override
  String get privacyLink => 'गोपनीयता';

  @override
  String get accountEmailAdd => 'ईमेल पता जोड़ें';

  @override
  String get accountEmailChange => 'ईमेल पता बदलें';

  @override
  String get accountEmailNew => 'ईमेल पता';

  @override
  String get accountEmailVerifyNote =>
      'नए पते की पुष्टि के लिए आपको एक लिंक मिलेगा। तब तक आपका मौजूदा पता बना रहेगा।';

  @override
  String get accountEmailPendingTitle => 'अपने नए ईमेल की पुष्टि करें';

  @override
  String accountEmailPendingHelp(String email) {
    return '$email पर भेजा गया लिंक खोलने के बाद यह आपका मौजूदा पता बदल देगा। दोबारा भेजने के लिए टैप करें।';
  }

  @override
  String get accountEmailRemoveNote =>
      'पता हटाने के लिए इसे खाली छोड़ें। आप यूज़रनेम से साइन इन करते रहेंगे।';

  @override
  String get accountEmailSaved => 'ईमेल पता सेव हो गया';

  @override
  String get accountEmailRemoved => 'ईमेल पता हटा दिया गया';

  @override
  String get accountConfirmPassword => 'आपका पासवर्ड';

  @override
  String get accountConfirmPasswordHelp => 'पुष्टि करने के लिए कि यह आप ही हैं।';

  @override
  String get errorEmailNeeded => 'आप ईमेल पते से साइन इन करते हैं, इसलिए इसे हटाया नहीं जा सकता।';

  @override
  String get accountDelete => 'खाता मिटाएँ';

  @override
  String get accountDeleteHelp => 'इस सर्वर से अपना खाता हटाएँ';

  @override
  String get accountDeleteTitle => 'अपना खाता मिटाएँ?';

  @override
  String get accountDeleteBody =>
      'आपका खाता हमेशा के लिए मिट जाएगा और आप साइन आउट हो जाएँगे। आपके समूहों में आपका नाम ऐसे सदस्य के रूप में बना रहेगा जिसका दावा किसी ने नहीं किया, ताकि बैलेंस का जोड़ सही रहे। जिन समूहों में कोई और नहीं है, वे मिट जाएँगे।';

  @override
  String get accountDeleteAction => 'हमेशा के लिए मिटाएँ';

  @override
  String get accountDeleted => 'आपका खाता मिटा दिया गया है।';

  @override
  String get accountDeletePageSignedOut => 'इस सर्वर से अपना खाता मिटाने के लिए साइन इन करें।';

  @override
  String get accountDeletePageLinkMode =>
      'इस सर्वर पर खाते नहीं हैं: समूह का लिंक ही काफ़ी है। किसी समूह और उसकी सारी जानकारी को मिटाने के लिए उसकी सेटिंग खोलें और “समूह मिटाएँ” चुनें।';

  @override
  String get groupDelete => 'समूह मिटाएँ';

  @override
  String get groupDeleteHelp => 'सबके लिए समूह और उसके सभी खर्च मिटाएँ';

  @override
  String groupDeleteTitle(String name) {
    return '$name मिटाएँ?';
  }

  @override
  String get groupDeleteBody =>
      'समूह, उसके सभी खर्च, भुगतान और इतिहास सबके लिए मिट जाएँगे। इसे पहले जैसा नहीं किया जा सकता। पुष्टि के लिए समूह का नाम टाइप करें।';

  @override
  String get groupDeleteName => 'समूह का नाम';

  @override
  String get groupDeleteAction => 'हमेशा के लिए मिटाएँ';

  @override
  String get groupDeleted => 'समूह मिटा दिया गया';

  @override
  String get groupDeleteOwnerOnly => 'सिर्फ़ समूह का मालिक इसे मिटा सकता है।';

  @override
  String get expenseDiscardTitle => 'बदलाव छोड़ दें?';

  @override
  String get expenseDiscardBody => 'इस खर्च में आपके बदलाव सेव नहीं हुए हैं।';

  @override
  String get expenseDiscard => 'छोड़ दें';

  @override
  String get adminPrivacyUrl => 'गोपनीयता नीति का लिंक';

  @override
  String get adminPrivacyUrlHelp =>
      'आपकी गोपनीयता नीति, जो app store माँगते हैं। खाली छोड़ने पर app Balnana क्या सेव करता है, इसकी सामान्य नीति दिखाता है।';

  @override
  String get adminMapTiles => 'मैप टाइलें';

  @override
  String get adminMapSource => 'मैप का स्रोत';

  @override
  String get adminMapSourceStyle => 'वेक्टर स्टाइल';

  @override
  String get adminMapSourceStyleHelp =>
      'MapLibre स्टाइल से बने मैप, जैसे OpenFreeMap का। यह मुफ़्त है और इसके लिए key की ज़रूरत नहीं।';

  @override
  String get adminMapSourceTiles => 'रास्टर टाइलें';

  @override
  String get adminMapSourceTilesHelp => 'टाइल तस्वीरों से दिखाए गए मैप, जैसे OpenStreetMap के।';

  @override
  String get adminMapSourceOff => 'बंद';

  @override
  String get adminMapSourceOffHelp => 'मैप नहीं दिखेंगे। खर्चों में जगह के नाम और बिंदु फिर भी सेव रहेंगे।';

  @override
  String get adminMapStyle => 'स्टाइल URL';

  @override
  String get adminMapStyleHelp =>
      'MapLibre style.json का पता, जैसे OpenFreeMap का Liberty (डिफ़ॉल्ट), Bright या Positron।';

  @override
  String get adminMapTilesHelp =>
      'घुंघराले कोष्ठकों में z, x और y वाले रास्टर टाइल URL टेम्पलेट का पता, जैसे डिफ़ॉल्ट वाला। OpenStreetMap के अपने सर्वर सिर्फ़ कम इस्तेमाल के लिए हैं; व्यस्त सर्वर को टाइल प्रदाता इस्तेमाल करना चाहिए।';

  @override
  String get adminMapAttribution => 'मैप का श्रेय';

  @override
  String get adminMapAttributionHelp =>
      'मैप प्रदाता के अनुरोध के अनुसार हर मैप पर दिखता है। खाली छोड़ने पर स्टाइल में दिए गए श्रेय दिखते हैं और टाइलों के लिए OpenStreetMap को श्रेय दिया जाता है।';

  @override
  String get adminInvalidMapTiles => 'घुंघराले कोष्ठकों में z, x और y वाले http(s) URL टेम्पलेट डालें।';

  @override
  String get adminUsers => 'खाते';

  @override
  String get adminUsersSearch => 'नाम, ईमेल या यूज़रनेम से खोजें';

  @override
  String adminUsersShown(int shown, int total) {
    return 'कुल $total खातों में से $shown';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खाते',
      one: '1 खाता',
      zero: '$count खाता',
    );
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => 'कोई मेल खाता नहीं मिला।';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count समूह',
      one: '1 समूह',
      zero: 'कोई समूह नहीं',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => 'पुष्टि नहीं हुई';

  @override
  String adminUserDeleteTitle(String name) {
    return '$name का खाता मिटाएँ?';
  }

  @override
  String get adminUserDeleteBody =>
      'खाता हमेशा के लिए मिट जाएगा और हर जगह से साइन आउट हो जाएगा। उसका नाम समूहों में ऐसे सदस्य के रूप में बना रहेगा जिसका दावा किसी ने नहीं किया; जिन समूहों में कोई और नहीं है, वे मिट जाएँगे।';

  @override
  String get adminUserDeleted => 'खाता मिटा दिया गया';

  @override
  String get commonDone => 'हो गया';

  @override
  String get crowdSearch => 'लोग खोजें';

  @override
  String get crowdNoMatch => 'कोई मेल नहीं खाता।';

  @override
  String get crowdAll => 'सभी';

  @override
  String get crowdNone => 'कोई नहीं';

  @override
  String crowdChosen(int count, int total) {
    return '$total में से $count चुने गए';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count और',
      one: '1 और',
      zero: '$count और',
    );
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => 'कम दिखाएँ';

  @override
  String get crowdSort => 'क्रमबद्ध करें';

  @override
  String crowdShowAll(int count) {
    return 'सभी $count दिखाएँ';
  }

  @override
  String get crowdBalances => 'सबका बैलेंस';

  @override
  String get crowdSomeoneElse => 'कोई और';

  @override
  String get crowdChoosePayers => 'पैसे देने वाले चुनें';

  @override
  String get crowdFilterTitle => 'किसके खर्च?';

  @override
  String get myGroupsTitle => 'मेरे समूहों के लिंक';

  @override
  String get myGroupsExport => 'मेरे समूह एक्सपोर्ट करें';

  @override
  String get myGroupsExportHelp =>
      'बैकअप रखने या दूसरे डिवाइस पर ले जाने के लिए अपने समूहों के लिंक कॉपी करें।';

  @override
  String get myGroupsPrivate =>
      'इन लिंक को निजी रखें। इन्हें पाने वाला कोई भी व्यक्ति संबंधित समूह खोल सकता है।';

  @override
  String get myGroupsCopy => 'लिंक कॉपी करें';

  @override
  String get myGroupsImport => 'समूह इम्पोर्ट करें';

  @override
  String get myGroupsImportHelp =>
      'इस सर्वर के समूह लिंक एक-एक करके अलग पंक्ति में चिपकाएँ। मौजूदा समूहों की जगह और पहचान बनी रहेगी।';

  @override
  String get myGroupsLinks => 'समूहों के लिंक';

  @override
  String get myGroupsImportAction => 'लिंक इम्पोर्ट करें';

  @override
  String get myGroupsInvalid => 'हर पंक्ति में समूह का सही लिंक डालें। कुछ भी इम्पोर्ट नहीं हुआ।';

  @override
  String get myGroupsServerChanged =>
      'चुना हुआ सर्वर बदल गया। यह डायलॉग बंद करें और लिंक को उनके अपने सर्वर पर इम्पोर्ट करें।';

  @override
  String myGroupsLimit(int count) {
    return 'हर सर्वर पर ज़्यादा से ज़्यादा $count समूह लिंक रखें। कुछ भी इम्पोर्ट नहीं हुआ।';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'समूह के $count नए लिंक इम्पोर्ट हुए।',
      one: 'समूह का 1 नया लिंक इम्पोर्ट हुआ।',
      zero: 'ये समूह पहले से सेव हैं।',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => 'दोहराएँ';

  @override
  String get repeatNever => 'नहीं दोहराएँ';

  @override
  String get repeatDaily => 'हर दिन';

  @override
  String get repeatWeekly => 'हर हफ़्ते';

  @override
  String get repeatMonthly => 'हर महीने';

  @override
  String get repeatYearly => 'हर साल';

  @override
  String get repeatEvery => 'हर';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'दिन', one: 'दिन', zero: 'दिन');
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हफ़्ते',
      one: 'हफ़्ता',
      zero: 'हफ़्ता',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'महीने',
      one: 'महीना',
      zero: 'महीना',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'साल', one: 'साल', zero: 'साल');
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count दिन',
      one: 'हर दिन',
      zero: 'हर $count दिन',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count हफ़्ते',
      one: 'हर हफ़्ते',
      zero: 'हर $count हफ़्ते',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count महीने',
      one: 'हर महीने',
      zero: 'हर $count महीने',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हर $count साल',
      one: 'हर साल',
      zero: 'हर $count साल',
    );
    return '$_temp0';
  }

  @override
  String get repeatEndNone => 'समाप्ति की तारीख नहीं';

  @override
  String repeatEndOn(String date) {
    return '$date तक';
  }

  @override
  String get repeatEndClear => 'समाप्ति की तारीख हटाएँ';

  @override
  String get repeatHelp =>
      'ऊपर दी गई तारीख से शुरू करके, हर तारीख पर खर्च अपने आप समूह में जुड़ जाएगा। पिछली तारीखों के खर्च सेव करते समय जुड़ेंगे।';

  @override
  String get repeatCustom => 'कस्टम शेड्यूल';

  @override
  String get repeatDropReceiptTitle => 'रसीद हटाएँ?';

  @override
  String get repeatDropReceiptBody =>
      'बार-बार होने वाले खर्च के साथ रसीद नहीं रखी जा सकती। इसके बजाय उससे जुड़ने वाले हर खर्च में रसीद जोड़ सकते हैं।';

  @override
  String get repeatDropReceiptAction => 'दोहराएँ';

  @override
  String get recurringTitle => 'नियमित खर्च';

  @override
  String get recurringHelp => 'ऐसे खर्च जो तय समय पर अपने आप जुड़ते हैं';

  @override
  String get recurringEmptyTitle => 'अभी कोई नियमित खर्च नहीं';

  @override
  String get recurringEmptyBody =>
      'किराया, सब्सक्रिप्शन और बार-बार होने वाले दूसरे खर्च हर तारीख पर अपने आप जोड़े जा सकते हैं।';

  @override
  String get recurringAdd => 'नियमित खर्च जोड़ें';

  @override
  String get recurringEdit => 'नियमित खर्च में बदलाव करें';

  @override
  String recurringNext(String date) {
    return 'अगली बार $date को';
  }

  @override
  String get recurringPaused => 'रुका हुआ';

  @override
  String get recurringEnded => 'समाप्त';

  @override
  String get recurringPause => 'रोकें';

  @override
  String get recurringResume => 'फिर शुरू करें';

  @override
  String get recurringActive => 'दोहराया जा रहा है';

  @override
  String get recurringDelete => 'मिटाएँ';

  @override
  String get recurringDeleteTitle => 'दोहराना बंद करें?';

  @override
  String recurringDeleteBody(String title) {
    return '“$title” अब दोबारा नहीं जुड़ेगा। इससे पहले जोड़े गए खर्च बने रहेंगे।';
  }

  @override
  String get recurringDeleted => 'नियमित खर्च मिटा दिया';

  @override
  String get recurringFromSchedule => 'नियमित खर्च से जोड़ा गया';

  @override
  String get recurringOpen => 'समय-सारणी बदलें';

  @override
  String get recurringMissing => 'नियमित खर्च मिटा दिया गया है या अब उपलब्ध नहीं है।';

  @override
  String get errorTooManyDue => 'शुरू होने की तारीख बहुत पुरानी है: एक साथ 100 से ज़्यादा खर्च जुड़ जाएँगे।';

  @override
  String get errorInvalidEnd => 'समाप्ति की तारीख, शुरू होने की तारीख से पहले नहीं हो सकती।';

  @override
  String get errorInvalidRepeat => 'हर 1 से 999 दिन, हफ़्ते, महीने या साल में दोहराएँ।';

  @override
  String get errorRecurringConflict =>
      'आपके बदलाव करते समय किसी और ने यह नियमित खर्च बदल दिया। उनके बदलाव देखने के लिए फिर से लोड करें।';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$who ने “$title” को दोहराने के लिए सेट किया';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$who ने नियमित खर्च “$title” बदला';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$who ने नियमित खर्च “$title” रोका';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return 'नियमित खर्च “$title” रोक दिया गया, क्योंकि इसमें शामिल एक सदस्य ने समूह छोड़ दिया।';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return 'नियमित खर्च “$title” रोक दिया गया, क्योंकि इसे जोड़ा नहीं जा सका';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$who ने नियमित खर्च “$title” फिर शुरू किया';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$who ने नियमित खर्च “$title” दोहराना बंद किया';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return '“$title” ($amount) अपने आप जोड़ा गया';
  }

  @override
  String get expenseRecurring => 'नियमित खर्च से जोड़ा गया';

  @override
  String get adminPlans => 'प्लान';

  @override
  String get adminPayments => 'भुगतान';

  @override
  String get adminSectionBilling => 'प्लान और भुगतान';

  @override
  String get adminSectionBillingBody =>
      'प्लान इस सर्वर पर रखी जाने वाली चीज़ों की सीमा बढ़ाते हैं। खर्च बाँटना और हिसाब चुकाना मुफ़्त रहता है।';

  @override
  String get adminBillingOn => 'प्लान और सीमाएँ';

  @override
  String get adminBillingOnHelp => 'बंद होने पर यह सर्वर कुछ भी सीमित नहीं करता और कोई प्लान नहीं दिखाता।';

  @override
  String get adminBillingNeedsAccounts => 'प्लान के लिए खाते ज़रूरी हैं: पहले ऐक्सेस मोड को खातों पर बदलें।';

  @override
  String get adminKofiUrl => 'Ko-fi पेज';

  @override
  String get adminKofiUrlHelp =>
      'जहाँ लोग भुगतान करते हैं। बाहरी भुगतान की अनुमति वाले बिल्ड ही यहाँ लिंक करते हैं।';

  @override
  String adminKofiWebhook(String url) {
    return 'Ko-fi पर डालने के लिए webhook URL: $url';
  }

  @override
  String get adminKofiToken => 'Ko-fi सत्यापन टोकन';

  @override
  String get adminKofiTokenHelp =>
      'Ko-fi के webhook पेज पर दिखता है। इसके बिना यह सर्वर Ko-fi को अनदेखा करता है।';

  @override
  String adminUserPlanUntil(String plan, String date) {
    return '$plan, $date तक';
  }

  @override
  String get adminPlansHelp =>
      'नई सीमा आगे जोड़ी जाने वाली चीज़ों पर लागू होती है। जो पहले से है वह बना रहता है। कोई सीमा न रखने के लिए खाली छोड़ें।';

  @override
  String get adminPlanAdd => 'प्लान जोड़ें';

  @override
  String adminPlanDefaultName(String name) {
    return '$name (डिफ़ॉल्ट)';
  }

  @override
  String adminPlanLimit(String label, String value) {
    return '$label: $value';
  }

  @override
  String adminPlanDays(int count) {
    return 'दिन: $count';
  }

  @override
  String get adminProductsSection => 'प्रॉडक्ट';

  @override
  String get adminProductsHelp =>
      'भुगतान उसके टियर नाम वाले प्रॉडक्ट को जाता है, नहीं तो बिना टियर नाम वाले उस प्रॉडक्ट को जिसकी राशि तक वह पहुँचता है।';

  @override
  String get adminProductAdd => 'प्रॉडक्ट जोड़ें';

  @override
  String get adminProductEdit => 'प्रॉडक्ट बदलें';

  @override
  String adminProductAnyPayment(String amount) {
    return 'कम से कम $amount का कोई भी भुगतान';
  }

  @override
  String get adminProductName => 'टियर का नाम';

  @override
  String get adminProductNameHelp =>
      'जैसा Ko-fi पर लिखा है। एक बार या मासिक भुगतान को राशि से मिलाने के लिए खाली छोड़ें।';

  @override
  String get adminProductPlan => 'प्लान';

  @override
  String get adminProductDays => 'दिन';

  @override
  String get adminProductDaysHelp => 'एक भुगतान कितने समय चलता है। दोबारा भुगतान बचे समय में जुड़ता है।';

  @override
  String get adminProductMinAmount => 'न्यूनतम राशि';

  @override
  String get adminProductCurrency => 'मुद्रा कोड';

  @override
  String get adminPlanId => 'ID';

  @override
  String get adminPlanIdHelp => 'छोटे अंग्रेज़ी अक्षर, अंक और हाइफ़न। इसे बाद में बदला नहीं जा सकता।';

  @override
  String get adminPlanName => 'नाम';

  @override
  String get adminPlanRank => 'रैंक';

  @override
  String get adminPlanRankHelp => 'कई प्लान वाले खाते को सबसे ऊँची रैंक वाला प्लान मिलता है।';

  @override
  String get adminPlanDefault => 'डिफ़ॉल्ट प्लान';

  @override
  String get adminPlanDefaultHelp => 'बिना किसी और प्लान वाले हर खाते के लिए।';

  @override
  String adminPlanRemoveTitle(String name) {
    return '$name हटाएँ?';
  }

  @override
  String adminPlanRemoveBody(String products) {
    return 'इसके उत्पाद भी साथ में हट जाएँगे और फिर खरीदे नहीं जा सकेंगे: $products';
  }

  @override
  String get adminEntitlementGranted => 'व्यवस्थापक ने दिया';

  @override
  String get adminEntitlementRevoked => 'वापस लिया गया';

  @override
  String get adminEntitlementForever => 'कोई समाप्ति तिथि नहीं';

  @override
  String adminEntitlementUntil(String date) {
    return '$date तक';
  }

  @override
  String adminEntitlementEnded(String date) {
    return '$date को समाप्त';
  }

  @override
  String get adminEntitlementsEmpty => 'इस खाते में अभी कोई प्लान नहीं है।';

  @override
  String get adminEntitlementRevoke => 'वापस लें';

  @override
  String adminEntitlementRevokeTitle(String plan) {
    return '$plan वापस लें?';
  }

  @override
  String adminEntitlementRevokeBody(String user) {
    return '$user यह प्लान तुरंत खो देंगे। इसे पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String get adminEntitlementNote => 'नोट';

  @override
  String get adminEntitlementGrant => 'प्लान दें';

  @override
  String get adminPaymentApplied => 'लागू';

  @override
  String get adminPaymentUnclaimed => 'दावा नहीं किया गया';

  @override
  String get adminPaymentUnmatched => 'मेल नहीं खाया';

  @override
  String get adminPaymentsAll => 'सभी';

  @override
  String adminPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count भुगतान',
      one: '$count भुगतान',
    );
    return '$_temp0';
  }

  @override
  String get adminPaymentsEmpty => 'कोई भुगतान नहीं।';

  @override
  String get adminPaymentAssigned => 'खाते को प्लान दे दिया गया।';

  @override
  String get adminPaymentAssign => 'खाते को दें';

  @override
  String get adminPaymentPickUser => 'कोई खाता चुनें।';

  @override
  String get errorBillingOff => 'इस सर्वर पर कोई प्लान नहीं है।';

  @override
  String get errorAlreadySponsored => 'किसी दूसरे सदस्य का प्लान इस समूह को पहले से कवर करता है।';

  @override
  String get errorPlanInUse => 'कुछ खाते या प्रॉडक्ट अब भी यह प्लान इस्तेमाल कर रहे हैं।';

  @override
  String get errorPaymentApplied => 'यह भुगतान पहले ही लागू हो चुका है।';

  @override
  String get errorPaymentNotFound =>
      'इस आईडी का कोई भुगतान अभी नहीं है। अगर आपने अभी भुगतान किया है, तो एक मिनट बाद फिर कोशिश करें।';

  @override
  String get errorPaymentNoPlan =>
      'यह भुगतान किसी प्लान से मेल नहीं खाता। सर्वर व्यवस्थापक से इसे लागू करने को कहें।';

  @override
  String get errorInvalidPlan => 'प्लान की सेटिंग जाँचें: कुछ मान्य नहीं है।';

  @override
  String errorLimitReceipts(int max) {
    return 'यह समूह $max रसीद फ़ोटो की सीमा तक पहुँच गया है।';
  }

  @override
  String errorLimitRecurring(int max) {
    return 'यह समूह $max नियमित खर्चों की सीमा तक पहुँच गया है।';
  }

  @override
  String errorLimitOwnGroups(int max) {
    return 'आप $max समूहों की सीमा तक पहुँच गए हैं।';
  }

  @override
  String errorLimitSponsored(int max) {
    return 'आपका प्लान $max से ज़्यादा समूहों के साथ साझा नहीं किया जा सकता।';
  }

  @override
  String get errorLimitOther => 'आप इस सर्वर की एक सीमा तक पहुँच गए हैं।';

  @override
  String get planTitle => 'प्लान';

  @override
  String get planUnlimited => 'कोई सीमा नहीं';

  @override
  String planUntil(String date) {
    return '$date तक';
  }

  @override
  String get planSettingsHelp => 'यह सर्वर आपके लिए क्या रखता है';

  @override
  String get planIntro =>
      'बाँटना और चुकाना हमेशा मुफ़्त है। प्लान सिर्फ़ यह बदलता है कि यह सर्वर आपके लिए कितना रखता है।';

  @override
  String planUsage(int used, int limit) {
    return '$limit में से $used';
  }

  @override
  String planUsed(int used) {
    return '$used इस्तेमाल हुए';
  }

  @override
  String get planLimits => 'सीमाएँ';

  @override
  String get planLimitReceipts => 'प्रति समूह रसीद फ़ोटो';

  @override
  String get planLimitRecurring => 'प्रति समूह नियमित खर्च';

  @override
  String get planLimitOwnGroups => 'आपके बनाए समूह';

  @override
  String get planLimitSponsored => 'आपका प्लान साझा करने वाले समूह';

  @override
  String get planGet => 'प्लान पाएँ';

  @override
  String get planKofi => 'Ko-fi';

  @override
  String get planKofiHelp => 'अपना भुगतान कोड Ko-fi संदेश में चिपकाएँ, ताकि भुगतान आपके खाते में पहुँचे।';

  @override
  String get planPaymentCodeHelp => 'आपका भुगतान कोड। कॉपी करने के लिए टैप करें।';

  @override
  String get planPaymentCodeCopied => 'भुगतान कोड कॉपी किया गया';

  @override
  String get planPaymentClaim => 'कोड भूल गए?';

  @override
  String get planPaymentClaimHelp => 'Ko-fi लेन-देन आईडी से भुगतान जोड़ें।';

  @override
  String get planPaymentClaimField => 'लेन-देन आईडी या भुगतान लिंक';

  @override
  String get planPaymentClaimAction => 'भुगतान जोड़ें';

  @override
  String get planPaymentClaimed => 'भुगतान जोड़ा गया';

  @override
  String groupPlanUsage(String receipts, String recurring) {
    return 'रसीद फ़ोटो: $receipts · नियमित: $recurring';
  }

  @override
  String get groupSponsor => 'इस समूह के साथ मेरा प्लान साझा करें';

  @override
  String get groupUnsponsor => 'मेरा प्लान साझा करना बंद करें';

  @override
  String groupSponsoredBy(String name) {
    return '$name का प्लान इस्तेमाल करता है';
  }

  @override
  String get accountDeletePlayNote =>
      'Google Play सदस्यता आपके खाते के साथ खत्म नहीं होती। पहले उसे Google Play पर रद्द करें।';

  @override
  String get planPlayManage => 'सदस्यता प्रबंधित करें';

  @override
  String get planPlayManageHelp => 'Google Play पर बदलें या रद्द करें';

  @override
  String planPlayPrice(int months, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'हर $months महीने',
      one: 'प्रति माह',
    );
    return '$price $_temp0';
  }

  @override
  String get planPlayFailed => 'Google Play खरीदारी पूरी नहीं कर सका।';

  @override
  String get planPlayPending => 'आपका भुगतान अभी प्रोसेस हो रहा है। पूरा होने पर प्लान शुरू होगा।';

  @override
  String get planPlayOnHold =>
      'आपका पिछला भुगतान विफल रहा। यह प्लान बनाए रखने के लिए Google Play पर अपना भुगतान तरीका अपडेट करें।';

  @override
  String get planPlayHeldElsewhere =>
      'इस Google Play खाते में पहले से एक सदस्यता है, जो शायद किसी दूसरे Balnana खाते की हो।';

  @override
  String get planPlayUnavailable => 'Google Play से कनेक्ट नहीं हो सका। बाद में फिर कोशिश करें।';

  @override
  String get errorInvalidPurchase => 'Google Play इस खरीदारी को नहीं पहचानता।';

  @override
  String get errorPlayOtherAccount =>
      'यह सदस्यता किसी दूसरे खाते की है। उस खाते में साइन इन करें या इसे Google Play पर रद्द करें।';

  @override
  String get errorPlayUnavailable => 'Google Play से संपर्क नहीं हो सका। थोड़ी देर में फिर कोशिश करें।';

  @override
  String get adminPlayPackage => 'Google Play पैकेज नाम';

  @override
  String get adminPlayPackageHelp =>
      'Google Play पर ऐप की ID। नीचे दिए सर्विस खाते के साथ यह Google Play सदस्यताएँ चालू करता है।';

  @override
  String get adminPlayServiceAccount => 'Google Play सर्विस खाता';

  @override
  String get adminPlayServiceAccountHelp =>
      'ऐसे सर्विस खाते की JSON कुंजी जो Play Console में ऑर्डर और सदस्यताएँ देख और प्रबंधित कर सके।';

  @override
  String get adminPlayPushAccount => 'Pub/Sub पुश खाता';

  @override
  String get adminPlayPushAccountHelp =>
      'उस सर्विस खाते का ईमेल जिससे Pub/Sub अपनी डिलीवरी पर हस्ताक्षर करता है। इसके बिना नवीनीकरण तभी पहुँचते हैं जब कोई प्लान पेज खोले।';

  @override
  String adminPlayWebhook(String url) {
    return 'Pub/Sub पुश एंडपॉइंट, और यही ऑडियंस भी: $url';
  }

  @override
  String get adminProductProvider => 'भुगतान का माध्यम';

  @override
  String get adminProductPlayId => 'प्रोडक्ट ID';

  @override
  String get adminProductPlayIdHelp =>
      'जैसा Play Console में लिखा है। हर भुगतान कब खत्म होगा यह Google Play बताता है, इसलिए दिन सेट नहीं करने होते।';

  @override
  String get adminProductRemoveBody =>
      'इसके भुगतान अब खातों पर लागू नहीं होंगे। पहले से चल रहे प्लान खत्म होने तक बने रहेंगे।';
}
