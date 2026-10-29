// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get languageEndonym => '日本語';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonRetry => '再試行';

  @override
  String get offlineBar => 'オフラインです。このデバイスに保存された内容を表示しています。再接続するまで変更は保存されません。';

  @override
  String get commonSave => '保存';

  @override
  String get commonClear => 'クリア';

  @override
  String get iconChoose => 'アイコンを選択';

  @override
  String get iconNone => 'アイコンなし';

  @override
  String get iconSearchHint => '検索するか、絵文字を入力';

  @override
  String get iconUseTyped => 'この絵文字を使う';

  @override
  String get iconNoMatch => '一致するアイコンがありません。使いたい絵文字を入力してください。';

  @override
  String get iconSectionTravel => '旅行・場所';

  @override
  String get iconSectionFood => '食べ物・飲み物';

  @override
  String get iconSectionActivities => 'アクティビティ';

  @override
  String get iconSectionHome => '住まい・光熱費';

  @override
  String get iconSectionPeople => '人物';

  @override
  String get iconSectionNature => '動物・自然';

  @override
  String get iconSectionObjects => 'お金・持ち物';

  @override
  String get iconSectionSymbols => '記号';

  @override
  String get commonRemove => '削除';

  @override
  String get commonUndo => '元に戻す';

  @override
  String get someone => '誰か';

  @override
  String get errorTooLarge => 'サーバーに送信するには大きすぎます。';

  @override
  String get errorBusy => 'サーバーが混み合っています。少し待ってからもう一度お試しください。';

  @override
  String get errorTimeout => '送信に時間がかかりすぎました。接続を確認して、もう一度お試しください。';

  @override
  String get errorBadOrigin => 'このアドレスからのサインインはサーバーで許可されていません。サーバーの管理者に公開URLを確認してもらってください。';

  @override
  String get errorInvalidCategory => 'このカテゴリはすでに削除されています。別のカテゴリを選んでください。';

  @override
  String get errorBuiltinCategory => '組み込みカテゴリは非表示にすることしかできません。';

  @override
  String get errorUnknownMember => 'このグループにいないメンバーが含まれています。再読み込みして、もう一度お試しください。';

  @override
  String get errorNoPayers => '支払った人を選んでください。';

  @override
  String get errorPayerTotal => '各メンバーの支払額の合計を、支出額と一致させてください。';

  @override
  String get errorPayerTooSmall => 'グループの通貨に換算すると、支払額が0になるメンバーがいます。金額を確認してください。';

  @override
  String get errorInvalidNote => 'メモが長すぎるか、保存できない文字が含まれています。';

  @override
  String get errorInvalidDate => '日付が範囲外です。';

  @override
  String get errorGeneric => '問題が発生しました。もう一度お試しください。';

  @override
  String get errorNetwork => 'サーバーに接続できません。接続を確認してください。';

  @override
  String get errorNotFound => 'すでに存在しません。';

  @override
  String get errorRequired => '必須項目です';

  @override
  String get errorInvalidName => '100文字以内で名前を入力してください。';

  @override
  String get errorDuplicateName => 'このグループには、すでに同じ名前のメンバーがいます。';

  @override
  String get errorTooManyMembers => 'このグループに追加できるメンバーは上限に達しています。';

  @override
  String get errorTooManyCategories => 'このグループに追加できるカテゴリは上限に達しています。';

  @override
  String get errorDuplicateCategory => 'このグループには、すでに同じ名前のカテゴリがあります。';

  @override
  String get errorInvalidCurrency => 'USDのような3文字の通貨コードを入力してください。';

  @override
  String get errorInvalidTitle => '200文字以内でタイトルを入力してください。';

  @override
  String get errorInvalidLocation => '1行で200文字以内の場所の名前を入力してください。';

  @override
  String get errorInvalidSymbol => '8文字以内の記号を入力してください。';

  @override
  String get errorInvalidEmoji => 'アイコンには絵文字を1つ選んでください。';

  @override
  String get errorMemberHasBalance => 'このメンバーを削除する前に、残高を精算してください。';

  @override
  String get errorVersionConflict => '編集中に別の人がこの支出を変更しました。再読み込みして変更内容を確認してください。';

  @override
  String get errorSignInRequired => 'この操作にはサインインが必要です。';

  @override
  String get errorRateLimited => 'リクエストが多すぎます。1分ほど待ってからもう一度お試しください。';

  @override
  String get errorNotAMember => 'まだこのグループに参加していません。';

  @override
  String get errorNotAllowed => 'この操作は本人かグループのオーナーのみ行えます。';

  @override
  String get errorLinkGroupsOff => 'このサーバーでは、リンクだけでグループを開くことはできません。';

  @override
  String get errorMemberClaimed => 'すでに別の人がそのメンバーとして参加しています。';

  @override
  String get errorMemberLeft => 'このグループのメンバーがグループを退出しました。';

  @override
  String get errorInvalidEmail => 'メールアドレスを入力してください。';

  @override
  String get errorInvalidPassword => '8〜200文字で入力してください。';

  @override
  String get errorEmailTaken => 'このメールアドレスのアカウントはすでにあります。代わりにサインインしてください。';

  @override
  String get errorSignupClosed => 'このサーバーでは新しいアカウントを作成できません。';

  @override
  String get errorInvalidCredentials => 'メールアドレスまたはパスワードが正しくありません。';

  @override
  String get errorWrongPassword => '現在のパスワードが正しくありません。';

  @override
  String get errorAccountsOff => 'このサーバーではアカウントを使用しません。';

  @override
  String get errorInvalidAmount => '0より大きい金額を入力してください。';

  @override
  String get errorTooManyDecimals => 'この通貨で使える小数点以下の桁数を超えています。';

  @override
  String get errorAmountTooLarge => '金額が大きすぎます。';

  @override
  String get errorNoShares => '費用を分けるメンバーを1人以上選んでください。';

  @override
  String get errorInvalidShare => '各分け前は数字で入力してください。';

  @override
  String get errorExactTotal => '金額の合計を全体の金額と一致させてください。';

  @override
  String get errorPayersTotal => '全員の支払額の合計を、全体の金額と一致させてください。';

  @override
  String get categoryFood => '食べ物・飲み物';

  @override
  String get categoryGroceries => '食料品';

  @override
  String get categoryTransport => '交通費';

  @override
  String get categoryTravel => '旅行';

  @override
  String get categoryLodging => '宿泊費';

  @override
  String get categoryRent => '家賃';

  @override
  String get categoryUtilities => '光熱費';

  @override
  String get categoryEntertainment => '娯楽';

  @override
  String get categoryShopping => '買い物';

  @override
  String get categoryHealth => '健康';

  @override
  String get categoryGifts => '贈り物';

  @override
  String get categoryOther => 'その他';

  @override
  String get groupNew => '新しいグループ';

  @override
  String get groupSwitch => 'グループを切り替え';

  @override
  String get groupReorder => 'ドラッグして並べ替え';

  @override
  String get groupCreate => 'グループを作成';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count人', one: '1人');
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return '受け取り予定 $amount';
  }

  @override
  String pillOwe(String amount) {
    return '支払い予定 $amount';
  }

  @override
  String get pillSettled => '精算済み';

  @override
  String get groupMissingTitle => 'グループが見つかりません';

  @override
  String get groupMissingBody => 'このグループは削除されたか、リンクがリセットされています。グループのメンバーに新しいリンクを聞いてください。';

  @override
  String get groupLockedTitle => 'サインインしてこのグループを開く';

  @override
  String get groupLockedBody => 'このグループはメンバーのアカウントでのみ開けます。グループに参加しているアカウントでサインインしてください。';

  @override
  String get groupForget => 'このデバイスから削除';

  @override
  String get groupLinkOtherServer => 'このリンクは別のサーバーのものです。開くには、そのサーバーに接続してください。';

  @override
  String get openLinkTitle => 'グループのリンクを開く';

  @override
  String get openLinkBody => '共有されたリンクを貼り付けて、グループに参加しましょう。';

  @override
  String get openLinkLabel => 'グループのリンク';

  @override
  String get openLinkAction => '開く';

  @override
  String get openLinkInvalid => 'Balnanaのグループリンクではないようです。';

  @override
  String get groupName => 'グループ名';

  @override
  String get groupNameHint => 'リスボン旅行';

  @override
  String get groupCurrency => '通貨';

  @override
  String get groupCurrencyHelp => 'このグループの支出にはすべてこの通貨を使います。あとから変更できません。';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name。このグループの支出にはすべてこの通貨を使います。あとから変更できません。';
  }

  @override
  String get currencyChoose => '通貨を選択';

  @override
  String get currencySearchHint => 'コードまたは名前で検索';

  @override
  String get currencySuggested => 'おすすめ';

  @override
  String get currencyAll => 'すべての通貨';

  @override
  String currencyUseTyped(String code) {
    return '$codeを使う';
  }

  @override
  String get currencyNoMatch => '一致する通貨がありません。使いたい通貨の3文字コードを入力してください。';

  @override
  String get groupSymbol => '記号';

  @override
  String get groupSymbolChoose => '記号を選択';

  @override
  String groupSymbolExample(String example) {
    return '金額は$exampleのように表示されます';
  }

  @override
  String get groupColor => '色';

  @override
  String colorSwatch(int number, int count) {
    return '全$count色のうち$number番目';
  }

  @override
  String get groupPeople => 'メンバー';

  @override
  String get groupYourName => 'あなたの名前';

  @override
  String groupPersonName(int number) {
    return 'メンバー$number';
  }

  @override
  String get groupAddPerson => 'メンバーを追加';

  @override
  String get groupPeopleHelp => 'あとからメンバーを追加することも、リンクから参加してもらうこともできます。';

  @override
  String get identityTitle => 'あなたは誰ですか？';

  @override
  String get identityBody => '名前を選ぶと、Balnanaがあなたの支払い予定を表示します。このデバイスだけに記憶されます。';

  @override
  String get identityNew => '新しいメンバーとして参加';

  @override
  String get identityNewTitle => 'このグループに参加';

  @override
  String get identityJoin => '参加';

  @override
  String get identityChange => '自分の名前';

  @override
  String get identityNone => '未選択';

  @override
  String get memberName => '名前';

  @override
  String memberYou(String name) {
    return '$name（あなた）';
  }

  @override
  String get memberAdd => 'メンバーを追加';

  @override
  String get memberAddTitle => 'メンバーを追加';

  @override
  String get memberRename => '名前を変更';

  @override
  String get memberRenameTitle => '名前を変更';

  @override
  String memberRemoveTitle(String name) {
    return '$nameを削除しますか？';
  }

  @override
  String get memberRemoveBody => '過去の支出には残りますが、新しい支出には追加できなくなります。';

  @override
  String get groupLinkCopied => 'リンクをコピーしました。このリンクを知っている人は誰でもグループを開けます。';

  @override
  String get groupShare => 'リンクを共有';

  @override
  String get groupSettings => 'グループ設定';

  @override
  String get groupEdit => 'グループを編集';

  @override
  String get groupSharing => '共有';

  @override
  String get groupCopyLink => 'リンクをコピー';

  @override
  String get groupQrCode => 'QRコードを表示';

  @override
  String get groupQrCodeHelp => 'スマートフォンのカメラでリンクを読み取ってもらえます。';

  @override
  String groupQrLabel(String group) {
    return '$groupへのリンクのQRコード';
  }

  @override
  String get groupCopyLinkHelp => 'リンクを知っている人は誰でも、このグループを表示・編集できます。';

  @override
  String get groupCopyLinkHelpAccounts => 'リンクを知っている人は、サインイン後に参加をリクエストできます。';

  @override
  String get linkAccessTitle => 'リンクを知っている人に公開';

  @override
  String get linkAccessHelp => 'アカウントなしで表示・編集できるようにする';

  @override
  String get resetLinkTitle => 'リンクをリセット';

  @override
  String get resetLinkHelp => '新しいリンクを作成します。古いリンクは使えなくなります';

  @override
  String get resetLinkBody => '現在のリンクは全員に対して使えなくなります。引き続きアクセスさせたい人に新しいリンクを共有してください。';

  @override
  String get resetLinkAction => 'リセット';

  @override
  String get resetLinkDone => 'リンクをリセットしました。新しいリンクを共有してください。';

  @override
  String get groupThisDevice => 'このデバイス';

  @override
  String get groupData => 'データ';

  @override
  String get categoriesTitle => 'カテゴリ';

  @override
  String get categoriesHelp => 'カテゴリを追加するか、使わないものを非表示にできます';

  @override
  String get categoriesOwn => 'このグループのカテゴリ';

  @override
  String get categoriesOwnEmpty => 'このグループ独自のカテゴリはまだありません。';

  @override
  String get categoriesBuiltIn => '組み込み';

  @override
  String get categoriesBuiltInHelp => '非表示のカテゴリは新しい支出には選べません。設定済みの支出ではそのまま使われます。';

  @override
  String get categoryAdd => 'カテゴリを追加';

  @override
  String get categoryEdit => 'カテゴリを編集';

  @override
  String get categoryName => '名前';

  @override
  String get categoryDelete => 'カテゴリを削除';

  @override
  String categoryDeleteTitle(String name) {
    return '$nameを削除しますか？';
  }

  @override
  String get categoryDeleteBody => 'このカテゴリの支出は「カテゴリなし」になります。';

  @override
  String get categoryDeleteAction => '削除';

  @override
  String get exportCsv => 'CSVでエクスポート';

  @override
  String get exportCsvHelp => 'すべての支出と支払いをスプレッドシート用に出力します';

  @override
  String get exportCsvDone => 'エクスポートしました';

  @override
  String get forgetTitle => 'このデバイスから削除';

  @override
  String get forgetHelp => 'グループは他のメンバーのためにサーバーに残ります';

  @override
  String get forgetBody => 'リンクを使えば、いつでもまた開けます。';

  @override
  String get groupYou => 'あなた';

  @override
  String get leaveTitle => 'グループを退出';

  @override
  String get leaveHelp => '支出は残ります。リンクから再参加できます';

  @override
  String get leaveBody => 'グループは一覧から消えます。あなたの支出と残高はグループに残ります。';

  @override
  String get leaveAction => '退出';

  @override
  String get tabExpenses => '支出';

  @override
  String get heroWhoTitle => 'このグループであなたは誰ですか？';

  @override
  String get heroWhoBody => '名前を選ぶと、支払い予定と受け取り予定を確認できます。';

  @override
  String get heroWhoAction => '選択';

  @override
  String get heroJoinTitle => 'このグループを表示中';

  @override
  String get heroJoinBody => '参加すると、支出を追加したり支払い予定を確認したりできます。';

  @override
  String get joinAction => '参加';

  @override
  String get heroOwed => '受け取り予定';

  @override
  String get heroOwe => '支払い予定';

  @override
  String get heroSettled => '精算済みです';

  @override
  String heroYouAre(String name) {
    return 'あなたは$nameです';
  }

  @override
  String get expenseAdd => '支出を追加';

  @override
  String get expensesEmptyTitle => '支出はまだありません';

  @override
  String get expensesEmptyBody => '最初の支出を追加すると、Balnanaが誰が誰にいくら支払うかを計算します。';

  @override
  String get expensesSearchHint => 'タイトル、メモ、場所を検索';

  @override
  String get searchClear => '検索をクリア';

  @override
  String get expensesNoMatchTitle => '一致するものがありません';

  @override
  String get expensesNoMatchBody => '別の言葉で検索するか、フィルターを減らしてみてください。';

  @override
  String get filterAnyone => '全員';

  @override
  String get filterAnyCategory => 'すべてのカテゴリ';

  @override
  String get filterPayments => '支払い';

  @override
  String get filterClear => 'フィルターをクリア';

  @override
  String get periodAll => '全期間';

  @override
  String get periodThisMonth => '今月';

  @override
  String get periodLastMonth => '先月';

  @override
  String get periodThisYear => '今年';

  @override
  String get periodPickDays => '日付を選択…';

  @override
  String get statsTitle => '支出の集計';

  @override
  String get statsTotal => '支出合計';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '支出$count件', one: '支出1件');
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'カテゴリ別';

  @override
  String get statsByMember => 'メンバーごとの支払額と負担額';

  @override
  String get statsPaid => '支払額';

  @override
  String get statsShare => '負担額';

  @override
  String get statsByMonth => '月別';

  @override
  String get statsNoCategory => 'カテゴリなし';

  @override
  String get statsEmptyTitle => '支出はありません';

  @override
  String get statsEmptyBody => 'この期間に支出はありません。';

  @override
  String get statsShowExpenses => '支出を表示';

  @override
  String get dateToday => '今日';

  @override
  String get dateYesterday => '昨日';

  @override
  String paymentTitle(String from, String to) {
    return '$fromから$toへの支払い';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$nameが$amountを支払いました';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return '$count人が$amountを支払いました';
  }

  @override
  String expensePaidByName(String name) {
    return '$nameが支払い';
  }

  @override
  String expensePaidByManyNames(int count) {
    return '$count人が支払い';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$nameが$amountを受け取りました';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$nameが受け取り';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return '$count人が受け取り';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return '$count人が$amountを受け取りました';
  }

  @override
  String get transactionRefund => '返金';

  @override
  String get transactionIncome => '収入';

  @override
  String get paymentDelete => '支払いを削除';

  @override
  String get paymentDeleted => '支払いを削除しました';

  @override
  String expenseDeleted(String title) {
    return '「$title」を削除しました';
  }

  @override
  String get expenseNew => '新しい支出';

  @override
  String get expenseEdit => '支出を編集';

  @override
  String get expenseDelete => '削除';

  @override
  String get expenseAmount => '金額';

  @override
  String get expenseTitle => '何に使いましたか？';

  @override
  String get expenseTitleHint => '夕食、チケット、タクシー…';

  @override
  String get expenseAmountFromPayers => '全員の支払額の合計';

  @override
  String expensePaidIn(String currency) {
    return '支払い通貨：$currency';
  }

  @override
  String expenseRate(String from, String to) {
    return '1$fromあたりの$to';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return '$currencyでの合計';
  }

  @override
  String expenseForeignHelp(String currency) {
    return '残高は$currencyで計算します。為替レート、またはカードの明細にある換算後の金額を入力してください。';
  }

  @override
  String get expenseNote => 'メモ';

  @override
  String get expenseNoteHint => '任意';

  @override
  String get expenseLocation => '場所';

  @override
  String get expenseLocationHint => 'どこでしたか？（任意）';

  @override
  String get locationPickOnMap => '地図から選択';

  @override
  String get locationUseCurrent => '現在地を使う';

  @override
  String get locationFinding => '現在地を確認中…';

  @override
  String get locationChange => '地図で変更';

  @override
  String get locationRemovePin => 'ピンを削除';

  @override
  String get locationOpenInMaps => '地図で開く';

  @override
  String get locationPickTitle => '場所を選択';

  @override
  String get locationPickHint => '地図をタップしてピンを置く';

  @override
  String get locationPickDone => '完了';

  @override
  String get locationDenied => 'Balnanaは現在地を使用できません。デバイスまたはブラウザーの設定で許可してください。';

  @override
  String get locationOff => 'このデバイスでは位置情報がオフです。';

  @override
  String get locationUnavailable => '現在地を確認できませんでした。もう一度試すか、地図にピンを置いてください。';

  @override
  String get expenseReceipt => 'レシート';

  @override
  String get expenseHasReceipt => 'レシート写真あり';

  @override
  String get expenseHasLocation => '場所を登録済み';

  @override
  String get receiptTakePhoto => '写真を撮る';

  @override
  String get receiptChoose => '写真を選択';

  @override
  String get receiptRemove => '削除';

  @override
  String get receiptView => 'レシート写真';

  @override
  String receiptNotSaved(String reason) {
    return '支出は保存されましたが、レシート写真は保存できませんでした。$reason';
  }

  @override
  String get expensePaidByLabel => '支払った人';

  @override
  String get expenseReceivedForLabel => '受け取りの理由';

  @override
  String get expenseReceivedByLabel => '受け取った人';

  @override
  String get expenseMultiplePayers => '複数人';

  @override
  String get expenseSplit => '分け方';

  @override
  String get splitEqual => '均等に分ける';

  @override
  String get splitExact => '金額で分ける';

  @override
  String get splitShares => '割合で分ける';

  @override
  String splitLeft(String amount) {
    return 'あと$amountを割り当て';
  }

  @override
  String splitOver(String amount) {
    return '$amount超過';
  }

  @override
  String get conflictTitle => '別の場所で変更されました';

  @override
  String get conflictReload => '再読み込み';

  @override
  String get expenseChangedElsewhere => '別の人がこの支出を変更しました。再読み込みすると、その人の変更が表示され、ここでの変更は破棄されます。';

  @override
  String get suggestedPayments => 'おすすめの支払い';

  @override
  String get allSettled => '全員の精算が完了しました。';

  @override
  String transferYouPay(String name) {
    return 'あなたが$nameに支払う';
  }

  @override
  String transferPaysYou(String name) {
    return '$nameがあなたに支払う';
  }

  @override
  String transferPays(String from, String to) {
    return '$fromが$toに支払う';
  }

  @override
  String get recordPayment => '記録';

  @override
  String get recordPaymentTitle => '支払いを記録';

  @override
  String get recordPaymentHelp => 'Balnanaの外で実際に支払ったお金だけを記録してください。';

  @override
  String get paymentRecorded => '支払いを記録しました';

  @override
  String activityGroupCreated(String who, String group) {
    return '$whoが$groupを作成しました';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$whoがグループ情報を変更しました';
  }

  @override
  String activityLinkReset(String who) {
    return '$whoがグループのリンクをリセットしました';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$whoが$nameを追加しました';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$whoが$oldNameを$nameに変更しました';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$whoが$nameを削除しました';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$whoがカテゴリ「$name」を追加しました';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$whoがカテゴリを変更しました';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$whoがカテゴリ「$name」を削除しました';
  }

  @override
  String activityMemberJoined(String name) {
    return '$nameが参加しました';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$whoが「$title」（$amount）を追加しました';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$whoが「$title」（$amount）を編集しました';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$whoが「$title」を削除しました';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$whoが「$title」を復元しました';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$whoが$fromから$toへの$amountの支払いを記録しました';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$whoが$amountの支払いを削除しました';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$whoが$amountの支払いを復元しました';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count件', one: '1件');
    return '$whoが$sourceから$_temp0をインポートしました';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$whoが「$title」にレシート写真を追加しました';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$whoが「$title」からレシート写真を削除しました';
  }

  @override
  String activityOther(String who) {
    return '$whoが変更しました';
  }

  @override
  String get navGroups => 'グループ';

  @override
  String get navActivity => 'アクティビティ';

  @override
  String get navSettings => '設定';

  @override
  String get groupsEmptyTitle => 'グループはまだありません';

  @override
  String get groupsEmptyBody => '作成したグループやリンクから開いたグループがここに表示されます。';

  @override
  String get groupsNoServerTitle => 'サーバーに接続';

  @override
  String get groupsNoServerBody => 'Balnanaでは、選択したサーバーにグループを保存します。自分でサーバーを用意することもできます。';

  @override
  String get groupsNoServerAction => 'サーバーを選択';

  @override
  String get groupsUnreachableTitle => 'サーバーに接続できません';

  @override
  String get groupsUnreachableBody => '接続または設定内のサーバーアドレスを確認してください。';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のグループを読み込めなかったため、それらの変更は表示されません。',
      one: 'グループを読み込めなかったため、その変更は表示されません。',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => 'まだ何もありません';

  @override
  String get activityEmptyBody => 'グループに新しい支出や支払いがあると、ここに表示されます。';

  @override
  String get notFoundTitle => 'ページが見つかりません';

  @override
  String get notFoundBody => 'このアドレスはBalnana内のページにつながっていません。';

  @override
  String get notFoundAction => 'グループへ';

  @override
  String get settingsAppearance => '外観';

  @override
  String get settingsAccount => 'アカウント';

  @override
  String get accountRename => '名前を変更';

  @override
  String get passwordChange => 'パスワードを変更';

  @override
  String get passwordChanged => 'パスワードを変更しました。他のデバイスからはサインアウトしました。';

  @override
  String get passwordSet => 'パスワードを設定';

  @override
  String get passwordSetHelp => 'メールアドレスまたはユーザー名とパスワードでサインインできるようになります';

  @override
  String get passwordSetDone => 'パスワードを設定しました。他のデバイスからはサインアウトしました。';

  @override
  String get passwordCurrent => '現在のパスワード';

  @override
  String get passwordNew => '新しいパスワード';

  @override
  String get signOut => 'サインアウト';

  @override
  String get accountOAuthLinked => 'このアカウントへのサインインに使えます。タップして削除。';

  @override
  String get accountOAuthAdd => 'サインイン方法として追加';

  @override
  String accountOAuthAddTitle(String name) {
    return '$nameを追加';
  }

  @override
  String accountOAuthAdded(String name) {
    return '$nameでサインインできるようになりました。';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return '$nameを削除しますか？';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return '再度追加するまで、$nameでサインインできなくなります。';
  }

  @override
  String get accountOAuthRemove => '削除';

  @override
  String accountOAuthRemoved(String name) {
    return '$nameを削除しました。';
  }

  @override
  String get confirmEmailTitle => 'メールアドレスを確認';

  @override
  String confirmEmailBody(String email) {
    return 'このサーバーではメールアドレスの確認が必要です。$emailに送ったリンクを開いてください。';
  }

  @override
  String get confirmEmailDone => '確認しました';

  @override
  String get confirmEmailResend => 'リンクを再送信';

  @override
  String get confirmEmailNotYet => 'まだ確認されていません。メールに届いたリンクを開いてください。';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get themeSystem => 'システム設定に合わせる';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get settingsDynamicColor => '壁紙の色';

  @override
  String get settingsDynamicColorSubtitle => 'Balnanaの黄色の代わりに、デバイスの色を使います';

  @override
  String get settingsWallpaperGroups => 'グループに壁紙の色を使う';

  @override
  String get settingsWallpaperGroupsSubtitle => 'グループ独自の色の代わりに、デバイスの色を使います';

  @override
  String get settingsPureBlack => '真っ黒';

  @override
  String get settingsPureBlackSubtitle => 'OLED画面向けの、より暗いダークテーマです';

  @override
  String get settingsMyShare => '自分の負担額を表示';

  @override
  String get settingsMyShareSubtitle => '支出の合計ではなく、自分が立て替えた額または借りた額を表示します';

  @override
  String get settingsLanguage => '言語';

  @override
  String get languageSystem => 'システム設定に合わせる';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotificationsSubtitle => '参加している支出が追加・変更・削除されたときに通知します';

  @override
  String get settingsNotificationsBlocked => 'スマートフォンの設定で通知がブロックされています。Balnanaの通知を許可してください';

  @override
  String get pushChannel => '支出';

  @override
  String get pushChannelDescription => '参加している支出が追加・変更・削除されたときに通知します';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$whoが$titleを追加 · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$whoが$titleを変更 · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$whoが$titleを削除 · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return '$titleを追加 · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return '$titleを変更 · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return '$titleを削除 · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payerから$payeeへ支払い $amount';
  }

  @override
  String get settingsConnection => '接続';

  @override
  String get settingsServer => 'サーバー';

  @override
  String get serverNotSet => '未設定';

  @override
  String get settingsAbout => 'アプリ情報';

  @override
  String get aboutVersion => 'バージョン';

  @override
  String get aboutLicenses => 'オープンソースライセンス';

  @override
  String get aboutSource => 'ソースコード';

  @override
  String get aboutSourceCopied => 'ブラウザーを開けなかったため、リンクをコピーしました';

  @override
  String get serverTitle => 'サーバー';

  @override
  String get serverIntro => 'Balnanaサーバーのアドレスを入力してください。誰でもサーバーを運営でき、通常はそのWebアプリを開くアドレスです。';

  @override
  String get serverUrlLabel => 'サーバーアドレス';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => '接続をテスト';

  @override
  String get serverSaveAnyway => 'このまま保存';

  @override
  String get serverReset => '初期設定に戻す';

  @override
  String serverDefault(String url) {
    return '初期設定：$url';
  }

  @override
  String serverConnected(String version) {
    return 'Balnana $versionに接続しました';
  }

  @override
  String get serverModeLink => 'グループは専用リンクで共有されます。アカウントは不要です。';

  @override
  String get serverModeAccounts => 'アカウントでサインインします。';

  @override
  String get serverInsecure =>
      'このアドレスは暗号化されていません（http）。ネットワーク上の人にデータを読まれる可能性があります。自宅のネットワーク外にあるサーバーにはhttpsを使ってください。';

  @override
  String get serverErrorInvalid => 'balnana.example.comのようなWebアドレスを入力してください。';

  @override
  String get serverErrorUnreachable => '接続できませんでした。アドレスとサーバーが起動していることを確認してください。';

  @override
  String get serverErrorNotBalnana => '応答がありましたが、Balnanaサーバーではありません。';

  @override
  String get serverSaved => 'サーバーを保存しました';

  @override
  String get signIn => 'サインイン';

  @override
  String get groupSignInTitle => 'サインインしてこのグループを開く';

  @override
  String get groupSignInBody => 'このグループはメンバー専用です。サインインすると、表示または参加できます。';

  @override
  String get signInTitle => 'おかえりなさい';

  @override
  String get signInBody => 'サインインしてグループを確認しましょう。';

  @override
  String get signInNoPassword => 'このサーバーでは別の方法でサインインします。サーバーの管理者にお問い合わせください。';

  @override
  String get registerTitle => 'アカウントを作成';

  @override
  String get registerBody => 'どのデバイスからもグループを使えるようにします。';

  @override
  String get registerAction => 'アカウントを作成';

  @override
  String get registerHaveAccount => 'すでにアカウントをお持ちです';

  @override
  String get signInNoAccount => 'アカウントを作成';

  @override
  String get accountName => 'あなたの名前';

  @override
  String get accountNameHelp => 'グループのメンバーに表示される名前です';

  @override
  String get accountEmail => 'メールアドレス';

  @override
  String get accountPassword => 'パスワード';

  @override
  String get accountPasswordHelp => '8文字以上';

  @override
  String get passwordShow => 'パスワードを表示';

  @override
  String get passwordHide => 'パスワードを隠す';

  @override
  String get joinPickName => '別の名前を選択';

  @override
  String joinTitle(String name) {
    return '$nameに参加';
  }

  @override
  String get joinBody => 'この中にあなたがいますか？自分を選ぶと、その人の支出を引き継げます。';

  @override
  String get joinBodyNew => '参加して支出を追加し、残高を確認しましょう。';

  @override
  String get joinAsNew => '新しいメンバーとして参加';

  @override
  String joinAsName(String name) {
    return '$nameとして参加';
  }

  @override
  String joinTaken(String names) {
    return '参加済み：$names';
  }

  @override
  String joinTakenCount(int count) {
    return '$count人がすでに参加しています。';
  }

  @override
  String get commonContinue => '続ける';

  @override
  String get errorEmailOff => 'このサーバーではメールを送信できません。';

  @override
  String get errorInvalidToken => 'このリンクの有効期限が切れているか、すでに使用されています。';

  @override
  String get forgotPasswordTitle => 'パスワードをお忘れですか？';

  @override
  String get forgotPasswordBody => '新しいパスワードを設定するリンクをメールでお送りします。';

  @override
  String get forgotPasswordAction => 'リンクを送信';

  @override
  String get forgotPasswordSent => 'このアドレスのアカウントがあれば、リンクを記載したメールをお送りします。';

  @override
  String get resetPasswordTitle => '新しいパスワードを設定';

  @override
  String get resetPasswordBody => 'すべてのデバイスからサインアウトします。その後、新しいパスワードでサインインできます。';

  @override
  String get resetPasswordAction => 'パスワードを保存';

  @override
  String get resetPasswordDone => 'パスワードを変更しました。新しいパスワードでサインインしてください。';

  @override
  String get verifyEmailTitle => 'メールアドレスを確認';

  @override
  String get verifyEmailHelp => 'パスワードを忘れたときにリセットできるようにします';

  @override
  String verifyEmailSent(String email) {
    return '$emailに届いたリンクを確認してください。';
  }

  @override
  String get verifyEmailDone => 'メールアドレスを確認しました';

  @override
  String get verifyEmailDoneBody => 'ありがとうございます。メールアドレスを確認できました。';

  @override
  String get verifyEmailFailed => 'メールアドレスを確認できませんでした';

  @override
  String get inviteByEmail => 'メールで招待';

  @override
  String get inviteByEmailHelp => '参加用リンクを相手に送ります';

  @override
  String get inviteAs => '参加するメンバー';

  @override
  String get inviteAsHelp => 'このメンバーの支出を引き継げます';

  @override
  String get inviteAsAnyone => '新しいメンバー';

  @override
  String get inviteSend => '招待を送信';

  @override
  String inviteSent(String email) {
    return '$emailに招待を送信しました。';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$nameさんから$groupへの招待が届きました';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return '$groupへの招待が届きました';
  }

  @override
  String inviteBody(String email) {
    return '$emailでアカウントを作成して参加するか、すでにお持ちの場合はサインインしてください。';
  }

  @override
  String get inviteBodySignedIn => '参加して支出を追加し、残高を確認しましょう。';

  @override
  String get inviteAction => '招待を開く';

  @override
  String get inviteMissingTitle => 'この招待は使えません';

  @override
  String get inviteMissingBody => '有効期限が切れているか、すでに使用された可能性があります。新しい招待を依頼してください。';

  @override
  String get joinInvitedAs => 'このメンバーとして招待されました';

  @override
  String signInWith(String provider) {
    return '$providerで続ける';
  }

  @override
  String get signInOr => 'または';

  @override
  String get oauthFailedTitle => 'サインインできませんでした';

  @override
  String get oauthPendingTitle => 'このメールアドレスのアカウントはすでにあります';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$providerでは$emailがあなたのアドレスと確認されましたが、このアドレスのアカウントは未確認です。どうしますか？';
  }

  @override
  String get oauthPendingLink => 'そのアカウントに追加';

  @override
  String get oauthPendingLinkHelp => 'そのアカウントのパスワードを入力してください。これまでのパスワードも引き続き使えます。';

  @override
  String get oauthPendingTakeOver => 'そのアカウントを引き継ぐ';

  @override
  String get oauthPendingTakeOverHelp => 'そのアカウントのパスワードと他のサインイン方法は削除され、サインイン中のすべてのデバイスからサインアウトします。';

  @override
  String get oauthPendingNew => '新しいアカウントを作成';

  @override
  String oauthPendingNewHelp(String email) {
    return '元のアカウントにはグループが残りますが、$emailは使えなくなります。';
  }

  @override
  String get oauthPendingPassword => 'そのアカウントのパスワード';

  @override
  String get oauthPendingWrongPassword => 'パスワードが正しくありません。';

  @override
  String get oauthOtherServer => 'このサインインは、現在選択されているサーバーとは別のサーバーで開始されました。もう一度サインインしてください。';

  @override
  String get oauthBackToSignIn => 'サインインに戻る';

  @override
  String get errorOAuthFailed => 'サインインできませんでした。もう一度お試しください。';

  @override
  String get errorEmailHasAccount => 'このメールアドレスのアカウントはすでにあります。サインインしてから、設定でこのサインイン方法を追加してください。';

  @override
  String get errorIdentityTaken => 'このサインイン方法はすでに別のアカウントに紐付いています。';

  @override
  String get errorLastSignInMethod => 'これが唯一のサインイン方法です。先にパスワードを設定するか、別の方法を追加してください。';

  @override
  String get errorEmailUnverified => '先にメールアドレスを確認してください。';

  @override
  String get errorOAuthCancelled => 'サインインがキャンセルされました。';

  @override
  String get importTitle => 'Settle Upからインポート';

  @override
  String get importAction => 'インポート';

  @override
  String get importIntro =>
      'Settle UpでグループをCSVファイルにエクスポートし、ここでファイルを選択してください。支出、支払い、グループのメンバーが引き継がれ、残高も変わりません。';

  @override
  String get importChooseFile => 'CSVファイルを選択';

  @override
  String get importChooseOther => '別のファイルを選択';

  @override
  String get importReading => 'ファイルを読み込み中…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(expenses, locale: localeName, other: '支出$expenses件', one: '支出1件');
    String _temp1 = intl.Intl.pluralLogic(payments, locale: localeName, other: '支払い$payments件', one: '支払い1件');
    return '$_temp0、$_temp1';
  }

  @override
  String importDates(String from, String to) {
    return '$from〜$to';
  }

  @override
  String importCurrency(String currency) {
    return '通貨：$currency。別の通貨の項目には、Settle Upが換算した金額を使います。';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '金額が0の項目を$count件除外しました。',
      one: '金額が0の項目を1件除外しました。',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => 'あなたはどのメンバーですか？';

  @override
  String get importUntitled => 'タイトルなし';

  @override
  String get errorImportFile => 'Settle UpのCSVエクスポートではないようです。';

  @override
  String get errorImportCurrency => '為替レートのない項目がファイルにないため、グループの通貨を特定できません。';

  @override
  String get errorImportTooBig => 'このファイルは大きすぎてインポートできません。';

  @override
  String get errorBadImage => 'この写真は使えません。JPEG、PNG、WebPの画像を選んでください。';

  @override
  String get errorReceiptTooBig => 'この写真は大きすぎます。10 MB未満の画像を選んでください。';

  @override
  String get errorImportMe => 'あなたがどのメンバーか選んでください。';

  @override
  String errorImportRow(int line, String reason) {
    return 'ファイルの$line行目をインポートできません：$reason';
  }

  @override
  String get errorImportAmount => '金額を読み取れません。';

  @override
  String get errorImportCounts => '名前と金額が一致しません。';

  @override
  String get errorImportDate => '日付を読み取れません。';

  @override
  String get errorImportType => '種類は支出、支払い、収入のいずれかである必要があります。';

  @override
  String get errorImportTransfer => '支払いには、支払う人と受け取る人を1人ずつ指定してください。';

  @override
  String get errorImportRowCurrency => '為替レートのない別通貨の項目です。';

  @override
  String get adminSetupTitle => 'このサーバーを設定';

  @override
  String get adminSetupBody =>
      '管理者用パスワードを設定してください。このパスワードで、サーバー設定があるこのページを保護します。ユーザー名はありません。パスワードを知っている人なら誰でも設定を変更できます。';

  @override
  String get adminSetupCode => 'セットアップコード';

  @override
  String get adminSetupCodeHelp =>
      'このサーバーにはすでにデータがあるため、起動時にログへセットアップコードが出力されています。Dockerの場合：docker compose logs balnana';

  @override
  String get adminSetupAction => 'パスワードを設定';

  @override
  String get adminPassword => '管理者パスワード';

  @override
  String get adminPasswordRepeat => 'パスワードを再入力';

  @override
  String get adminPasswordMismatch => 'パスワードが一致しません。';

  @override
  String get adminLoginTitle => '管理';

  @override
  String get adminLoginBody => 'サーバー設定を変更するには、管理者パスワードを入力してください。';

  @override
  String get adminLoginAction => 'サインイン';

  @override
  String get adminSettingsTitle => 'サーバー設定';

  @override
  String get adminSaved => '設定を保存しました。すぐに反映されます。';

  @override
  String get adminSaveFailed => '保存できませんでした。強調表示された設定を確認してください。';

  @override
  String get adminChangePassword => '管理者パスワードを変更';

  @override
  String get adminPasswordCurrent => '現在のパスワード';

  @override
  String get adminPasswordNew => '新しいパスワード';

  @override
  String get adminPasswordChanged => 'パスワードを変更しました。他の管理者セッションからはサインアウトしました。';

  @override
  String get adminSignOut => '管理画面からサインアウト';

  @override
  String get adminBackHome => 'Balnanaに戻る';

  @override
  String get adminRequireEmail => 'メールアドレスを必須にする';

  @override
  String get adminRequireEmailHelp => 'オフの場合、ユーザー名で登録し、メールアドレスは省略できます。サインインにはメールアドレスかユーザー名を使えます。';

  @override
  String get adminRequireEmailUnused => 'メールアドレスとパスワードでのサインインがオフのため、この設定は適用されません。';

  @override
  String get accountUsername => 'ユーザー名';

  @override
  String get accountUsernameHelp => '3〜32文字。英字、数字、ピリオド、ハイフン、アンダースコアが使えます。サインインに使います。';

  @override
  String get accountEmailOptional => 'メールアドレス（任意）';

  @override
  String get accountEmailOptionalHelp => 'グループへの招待や、忘れたパスワードのリセットに使います。';

  @override
  String get accountLogin => 'メールアドレスまたはユーザー名';

  @override
  String get errorInvalidUsername => '先頭は英字か数字にしてください。英字、数字、ピリオド、ハイフン、アンダースコアを3〜32文字で入力してください。';

  @override
  String get errorUsernameTaken => 'このユーザー名はすでに使われています。';

  @override
  String get adminDiscardTitle => '変更を破棄しますか？';

  @override
  String get adminDiscardBody => '設定の変更はまだ保存されていません。';

  @override
  String get adminDiscard => '破棄';

  @override
  String adminLocked(String key) {
    return 'サーバーで$keyにより設定されています';
  }

  @override
  String adminDefault(String value) {
    return '初期値：$value';
  }

  @override
  String get adminSecretSaved => '保存しました。置き換える場合は新しい値を入力してください。';

  @override
  String get adminSecretRemoved => '保存時に削除されます。';

  @override
  String get adminSecretRemove => '保存済みの値を削除';

  @override
  String get adminSectionGeneral => '一般';

  @override
  String get adminSectionAccess => 'アクセス';

  @override
  String get adminSectionMaps => '地図';

  @override
  String get adminSectionAccounts => 'アカウント';

  @override
  String get adminSectionAccountsBody => 'アクセス方法がアカウントに設定されている場合に適用されます。';

  @override
  String get adminSectionEmail => 'メール（SMTP）';

  @override
  String get adminSectionEmailBody => 'アドレス確認、パスワードのリセット、招待に使います。';

  @override
  String get adminSmtpOn => 'メールを送信';

  @override
  String get adminSectionGoogle => 'Googleでサインイン';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Google Cloudコンソールで、リダイレクトURIとして$urlを登録してください。';
  }

  @override
  String get adminGoogleOn => 'Googleでのサインインを提供';

  @override
  String get adminGoogleOnHelp => 'Googleアカウントでサインインできるようにします。';

  @override
  String get adminSectionOidc => 'OpenID Connectでサインイン';

  @override
  String adminSectionOidcBody(String url) {
    return 'プロバイダーにリダイレクトURIとして$urlを登録してください。';
  }

  @override
  String get adminOidcHelp => 'Authentik、Keycloak、Dexなど、任意のOpenID Connectプロバイダーを使えます。いくつでも追加できます。';

  @override
  String get adminOidcAdd => 'プロバイダーを追加';

  @override
  String get adminOidcRemove => 'プロバイダーを削除';

  @override
  String get adminOidcNew => '新しいプロバイダー';

  @override
  String get adminOidcId => 'ID';

  @override
  String get adminOidcIdHelp => '小文字の英字、数字、ハイフンを使います。リダイレクトURIの一部になり、あとから変更できません。';

  @override
  String get adminOidcIdInvalid => '小文字の英字または数字で始め、英字、数字、ハイフンを使って32文字以内で入力してください。';

  @override
  String get adminOidcIdTaken => 'このIDは別のプロバイダーがすでに使っています。';

  @override
  String get adminTrustEmail => 'メールアドレスを信頼する';

  @override
  String get adminGoogleTrustEmailHelp =>
      'アカウントと同じメールアドレスでGoogleサインインすると、そのアカウントにサインインします。オフの場合、パスワードでサインインしてから設定でGoogleを追加します。';

  @override
  String get adminOidcTrustEmailHelp =>
      'メールアドレスの確認を信頼できる、自分が運営するプロバイダーにのみ使ってください。オフの場合、アカウントを持つ人はパスワードでサインインしてから設定で追加します。';

  @override
  String get adminRequireVerified => '確認済みメールアドレスを必須にする';

  @override
  String get adminRequireVerifiedHelp =>
      'メールアドレスを確認するまでアカウントを使えません。同じメールアドレスの信頼済みサインイン方法では、未確認のアカウントを引き継げます。オフの場合、どうするかはユーザーが選びます。';

  @override
  String get adminRequireVerifiedUnused => 'メール送信の設定が必要です。';

  @override
  String get adminSectionAndroid => 'Androidアプリリンク';

  @override
  String get adminSectionAndroidBody =>
      'このサーバー向けのAndroidアプリは、サーバーのリンクをアプリで開きます。確認を省略するには、アプリの署名に使う証明書のSHA-256フィンガープリントを登録してください。';

  @override
  String get adminSectionAdmin => '管理者';

  @override
  String get adminPublicUrl => '公開アドレス';

  @override
  String get adminPublicUrlHelp => 'このサーバーへのアクセスに使うアドレスです。グループリンクやメール内のリンクはこのアドレスから作られます。';

  @override
  String get adminSourceUrl => 'ソースコードのリンク';

  @override
  String get adminSourceUrlHelp => '変更を加えたバージョンを運用する場合、ライセンス（AGPL-3.0）に従ってソースコードを公開する必要があります。そのリンクを入力してください。';

  @override
  String get adminAuthMode => 'アクセス方法';

  @override
  String get adminAuthModeLink => 'グループリンク';

  @override
  String get adminAuthModeLinkHelp => 'サインインは不要です。グループ専用リンクがあれば誰でもアクセスできます。';

  @override
  String get adminAuthModeAccounts => 'アカウント';

  @override
  String get adminAuthModeAccountsHelp => 'サインインが必要です。リンクから参加できるのはサインイン済みのユーザーだけです。';

  @override
  String get adminPasswordLogin => 'メールアドレスとパスワードでサインイン';

  @override
  String get adminPasswordForced => 'GoogleまたはOpenID Connectでのサインインを有効にするまでオンのままです。常にサインイン方法を確保できます。';

  @override
  String get adminSignup => 'アカウントを作成できる人';

  @override
  String get adminSignupOpen => '誰でも';

  @override
  String get adminSignupOpenHelp => 'このサーバーにアクセスできる人なら誰でも登録できます。';

  @override
  String get adminSignupInvite => '招待された人';

  @override
  String get adminSignupInviteHelp => 'メールでグループに招待された人だけが、招待先のアドレスで登録できます。グループリンクだけでは登録できません。招待にはメール設定が必要です。';

  @override
  String get adminSignupClosed => '誰も不可';

  @override
  String get adminSignupClosedHelp => '新規登録はできません。既存のアカウントは引き続き使えます。';

  @override
  String get adminSignupHelp => '最初のアカウントはいつでも作成できます。';

  @override
  String get adminLinkGroups => 'リンクからグループを開けるようにする';

  @override
  String get adminLinkGroupsHelp => 'グループのオーナーは、サインインなしでリンクを知っている人にアクセスを許可できます。';

  @override
  String get adminSmtpHost => 'メールサーバー';

  @override
  String get adminSmtpPort => 'ポート';

  @override
  String get adminSmtpUser => 'ユーザー名';

  @override
  String get adminSmtpPassword => 'パスワード';

  @override
  String get adminSmtpFrom => '差出人';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'クライアントID';

  @override
  String get adminClientSecret => 'クライアントシークレット';

  @override
  String get adminOidcIssuer => '発行者URL';

  @override
  String get adminOidcName => 'ボタン名';

  @override
  String get adminOidcNameHelp => 'サインイン画面に「…で続ける」と表示されます。';

  @override
  String get adminFingerprints => '証明書のフィンガープリント';

  @override
  String get adminFingerprintsHelp =>
      'SHA-256をカンマで区切って入力します。keytool -list -vとapksigner verify --print-certsで確認できます。';

  @override
  String get adminInvalidValue => 'この値は無効です。';

  @override
  String get adminInvalidUrl => 'https://またはhttp://で始まる完全なアドレスを入力してください。';

  @override
  String get adminInvalidFrom => 'Balnana <balnana@example.com>のような差出人を入力してください。メールアドレスが必要です。';

  @override
  String get adminInvalidPort => '1〜65535のポート番号を入力してください。';

  @override
  String get adminInvalidRequired => 'このサインインプロバイダーには必須です。';

  @override
  String get adminInvalidFingerprint => 'SHA-256フィンガープリントを入力してください。各64桁の16進数で、コロンを含めてもかまいません。';

  @override
  String get adminNeedsSignIn => 'アカウントにはサインイン方法が必要です。メールアドレスとパスワードでのサインインを有効にするか、プロバイダーを設定してください。';

  @override
  String get adminLockedChange => 'サーバーで設定されているため、ここでは変更できません。';

  @override
  String get errorAdminRequired => '管理者セッションの有効期限が切れました。もう一度サインインしてください。';

  @override
  String get errorAdminWrongPassword => 'パスワードが正しくありません。';

  @override
  String get errorInvalidSetupCode => 'セットアップコードが正しくありません。サーバーのログを確認してください。';

  @override
  String get errorAlreadySetUp => 'このサーバーはすでに設定済みです。管理者パスワードでサインインしてください。';

  @override
  String get linkOpening => 'リンクを開いています…';

  @override
  String get linkForeignTitle => 'このリンクは別のサーバーのものです';

  @override
  String linkForeignBody(String server) {
    return 'このアプリは$serverに接続していますが、このリンクは別のサーバーのものです。開くには設定でサーバーを変更してください。';
  }

  @override
  String get linkInvalidTitle => 'このリンクは開けません';

  @override
  String get linkInvalidBody => 'このアプリが認識できるBalnanaのリンクではありません。';

  @override
  String get linkGoHome => 'グループへ';

  @override
  String get linkOpenInBrowser => 'ブラウザーで開く';

  @override
  String get privacyTitle => 'プライバシーポリシー';

  @override
  String get privacyIntro =>
      'Balnanaはオープンソースソフトウェアです。このアプリが接続しているサーバーの運営者が、データの保存場所を決め、その管理に責任を負います。このページでは、ソフトウェア自体が保存する情報とその使い方を説明します。';

  @override
  String get privacyStoredTitle => '保存される情報';

  @override
  String get privacyStoredBody =>
      '作成または参加したグループの名前、メンバーの名前、支出、支払い、メモ、レシート写真、支出に追加した場所を保存します。アカウントを使う場合は、名前、メールアドレスまたはユーザー名、パスワードそのものではなくパスワードのハッシュ、Googleなどのサインインプロバイダーも保存します。通知がオンの場合は、デバイス識別子とプッシュ通知サービスから割り当てられたアドレスも保存します。';

  @override
  String get privacyUseTitle => '情報の使い方';

  @override
  String get privacyUseBody =>
      'アプリの運営にのみ使います。各グループをメンバーに表示し、残高を計算し、メールアドレスの確認、パスワードのリセット、招待などに必要なメールや通知を送ります。広告やアクセス解析はなく、情報を販売することもありません。';

  @override
  String get privacySharedTitle => '情報を見ることができる人';

  @override
  String get privacySharedBody =>
      'グループのメンバーは、そのグループのメンバー、支出、履歴を確認できます。リンクで公開されたグループは、リンクを知っている人なら誰でも開けます。GoogleでのサインインはGoogleを経由します。運営者が通知を有効にした場合、通知はスマートフォンで使っているプッシュ通知サービス（GoogleのFirebase Cloud Messaging、またはインストール済みのntfyなどのUnifiedPushサービス）を経由します。通知の内容は送信中に暗号化されます。地図は運営者が選んだ地図プロバイダー（変更されていなければOpenFreeMap）から画像を読み込みます。地図プロバイダーにはネットワークアドレスと閲覧した地域が伝わります。「現在地を使う」をタップしたときだけ現在地を読み取り、その後に保存した地点だけを記録します。';

  @override
  String get privacyDeviceTitle => 'このデバイス上の情報';

  @override
  String get privacyDeviceBody => 'オフラインで使えるように、サーバーアドレス、設定、グループのコピーを保存します。アプリをアンインストールすると削除されます。';

  @override
  String get privacyDeleteTitle => 'データの削除';

  @override
  String get privacyDeleteBody =>
      '設定からアカウントを削除できます。グループの残高を保てるよう、あなたの名前は引き継ぐ人のいないメンバーとしてグループに残ります。ほかにアクセスできる人がいないグループは一緒に削除されます。グループのオーナーは、設定からグループ全体を削除できます。それ以外については、サーバーの運営者にお問い合わせください。';

  @override
  String get privacyOperatorPolicy => '運営者のプライバシーポリシー';

  @override
  String get privacyLink => 'プライバシー';

  @override
  String get accountEmailAdd => 'メールアドレスを追加';

  @override
  String get accountEmailChange => 'メールアドレスを変更';

  @override
  String get accountEmailNew => 'メールアドレス';

  @override
  String get accountEmailVerifyNote => '新しいアドレスを確認するリンクを送信します。確認が終わるまでは現在のアドレスが使われます。';

  @override
  String get accountEmailPendingTitle => '新しいメールアドレスを確認';

  @override
  String accountEmailPendingHelp(String email) {
    return '$emailに送信したリンクを開くと、現在のアドレスが置き換わります。タップするとリンクを再送信します。';
  }

  @override
  String get accountEmailRemoveNote => 'アドレスを削除するには空欄にしてください。ユーザー名でのサインインは引き続き使えます。';

  @override
  String get accountEmailSaved => 'メールアドレスを保存しました';

  @override
  String get accountEmailRemoved => 'メールアドレスを削除しました';

  @override
  String get accountConfirmPassword => 'パスワード';

  @override
  String get accountConfirmPasswordHelp => '本人確認のために入力してください。';

  @override
  String get errorEmailNeeded => 'メールアドレスでサインインする設定のため、削除できません。';

  @override
  String get accountDelete => 'アカウントを削除';

  @override
  String get accountDeleteHelp => 'このサーバーからアカウントを削除します';

  @override
  String get accountDeleteTitle => 'アカウントを削除しますか？';

  @override
  String get accountDeleteBody =>
      'アカウントは完全に削除され、サインアウトします。残高を保てるよう、あなたの名前は引き継ぐ人のいないメンバーとしてグループに残ります。ほかにメンバーがいないグループは削除されます。';

  @override
  String get accountDeleteAction => '完全に削除';

  @override
  String get accountDeleted => 'アカウントを削除しました。';

  @override
  String get accountDeletePageSignedOut => 'このサーバーのアカウントを削除するには、サインインしてください。';

  @override
  String get accountDeletePageLinkMode =>
      'このサーバーにはアカウントがありません。グループのリンクがあれば誰でもアクセスできます。グループとそのすべてのデータを削除するには、グループ設定を開いて「グループを削除」を選んでください。';

  @override
  String get groupDelete => 'グループを削除';

  @override
  String get groupDeleteHelp => 'すべてのメンバーに対して、支出ごと削除します';

  @override
  String groupDeleteTitle(String name) {
    return '$nameを削除しますか？';
  }

  @override
  String get groupDeleteBody => 'グループとすべての支出、支払い、履歴が全員から削除されます。この操作は元に戻せません。確認のため、グループ名を入力してください。';

  @override
  String get groupDeleteName => 'グループ名';

  @override
  String get groupDeleteAction => '完全に削除';

  @override
  String get groupDeleted => 'グループを削除しました';

  @override
  String get groupDeleteOwnerOnly => 'グループを削除できるのはオーナーだけです。';

  @override
  String get expenseDiscardTitle => '変更を破棄しますか？';

  @override
  String get expenseDiscardBody => 'この支出への変更はまだ保存されていません。';

  @override
  String get expenseDiscard => '破棄';

  @override
  String get adminPrivacyUrl => 'プライバシーポリシーのリンク';

  @override
  String get adminPrivacyUrlHelp => 'アプリストアで求められるプライバシーポリシーを設定します。空欄の場合、Balnanaが保存する情報についての一般的な説明を表示します。';

  @override
  String get adminMapTiles => '地図タイル';

  @override
  String get adminMapSource => '地図ソース';

  @override
  String get adminMapSourceStyle => 'ベクタースタイル';

  @override
  String get adminMapSourceStyleHelp => '無料でAPIキーも不要なOpenFreeMapなどのMapLibreスタイルから地図を描画します。';

  @override
  String get adminMapSourceTiles => 'ラスタータイル';

  @override
  String get adminMapSourceTilesHelp => 'OpenStreetMapなどのタイル画像を使って地図を表示します。';

  @override
  String get adminMapSourceOff => 'オフ';

  @override
  String get adminMapSourceOffHelp => '地図を表示しません。支出の場所名と座標は引き続き保存されます。';

  @override
  String get adminMapStyle => 'スタイルURL';

  @override
  String get adminMapStyleHelp => 'OpenFreeMapのLiberty（初期設定）、Bright、Positronなど、MapLibreのstyle.jsonのアドレスです。';

  @override
  String get adminMapTilesHelp =>
      '初期設定のようにz、x、yを波括弧で示したラスタータイルのURLテンプレートを入力します。OpenStreetMapのサーバーは少量の利用向けです。利用者が多いサーバーではタイルプロバイダーを使ってください。';

  @override
  String get adminMapAttribution => '地図のクレジット表記';

  @override
  String get adminMapAttributionHelp =>
      '地図プロバイダーの指定に従い、各地図に表示します。空欄の場合、スタイルでは指定されたクレジットを表示し、タイルではOpenStreetMapを表示します。';

  @override
  String get adminInvalidMapTiles => 'z、x、yを波括弧で示したhttp(s) URLテンプレートを入力してください。';

  @override
  String get adminUsers => 'アカウント';

  @override
  String get adminUsersSearch => '名前、メールアドレス、ユーザー名で検索';

  @override
  String adminUsersShown(int shown, int total) {
    return '全$total件中$shown件のアカウント';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'アカウント$count件', one: 'アカウント1件');
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => '一致するアカウントがありません。';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'グループ$count件',
      one: 'グループ1件',
      zero: 'グループなし',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => '未確認';

  @override
  String adminUserDeleteTitle(String name) {
    return '$nameのアカウントを削除しますか？';
  }

  @override
  String get adminUserDeleteBody =>
      'アカウントは完全に削除され、すべてのデバイスからサインアウトします。名前は引き継ぐ人のいないメンバーとしてグループに残ります。ほかにメンバーがいないグループは削除されます。';

  @override
  String get adminUserDeleted => 'アカウントを削除しました';

  @override
  String get commonDone => '完了';

  @override
  String get crowdSearch => 'メンバーを検索';

  @override
  String get crowdNoMatch => '一致するメンバーがいません。';

  @override
  String get crowdAll => 'すべて';

  @override
  String get crowdNone => 'なし';

  @override
  String crowdChosen(int count, int total) {
    return '$total人中$count人を選択';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'さらに$count人', one: 'さらに1人');
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => '表示を減らす';

  @override
  String get crowdSort => '並べ替え';

  @override
  String crowdShowAll(int count) {
    return '全$count人を表示';
  }

  @override
  String get crowdBalances => '全員の残高';

  @override
  String get crowdSomeoneElse => '別のメンバー';

  @override
  String get crowdChoosePayers => '支払った人を選択';

  @override
  String get crowdFilterTitle => '誰の支出を表示しますか？';

  @override
  String get myGroupsTitle => '自分のグループリンク';

  @override
  String get myGroupsExport => 'グループリンクをエクスポート';

  @override
  String get myGroupsExportHelp => 'バックアップや別のデバイスへの移行用に、グループリンクをコピーします。';

  @override
  String get myGroupsPrivate => 'リンクを知っている人はグループを開けるため、リンクは他の人に見せないでください。';

  @override
  String get myGroupsCopy => 'リンクをコピー';

  @override
  String get myGroupsImport => 'グループをインポート';

  @override
  String get myGroupsImportHelp => 'このサーバーのグループリンクを1行に1つずつ貼り付けてください。既存のグループは並び順もそのままで、同じグループとして扱われます。';

  @override
  String get myGroupsLinks => 'グループリンク';

  @override
  String get myGroupsImportAction => 'リンクをインポート';

  @override
  String get myGroupsInvalid => '有効なグループリンクを1行に1つずつ入力してください。何もインポートされませんでした。';

  @override
  String get myGroupsServerChanged => '選択中のサーバーが変わりました。このダイアログを閉じて、リンク先のサーバーでインポートしてください。';

  @override
  String myGroupsLimit(int count) {
    return 'サーバーごとに保存できるグループリンクは最大$count件です。何もインポートされませんでした。';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '新しいグループリンクを$count件インポートしました。',
      one: '新しいグループリンクを1件インポートしました。',
      zero: 'これらのグループはすでに保存されています。',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => '繰り返し';

  @override
  String get repeatNever => '繰り返さない';

  @override
  String get repeatDaily => '毎日';

  @override
  String get repeatWeekly => '毎週';

  @override
  String get repeatMonthly => '毎月';

  @override
  String get repeatYearly => '毎年';

  @override
  String get repeatEvery => '間隔';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '日', one: '日');
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '週間', one: '週間');
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'か月', one: 'か月');
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '年', one: '年');
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count日ごと', one: '毎日');
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count週間ごと', one: '毎週');
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$countか月ごと', one: '毎月');
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count年ごと', one: '毎年');
    return '$_temp0';
  }

  @override
  String get repeatEndNone => '終了日なし';

  @override
  String repeatEndOn(String date) {
    return '$dateまで';
  }

  @override
  String get repeatEndClear => '終了日を削除';

  @override
  String get repeatHelp => '上の日付から、予定日にグループへ自動追加されます。過去の日付分も保存時に追加されます。';

  @override
  String get repeatDropReceiptTitle => 'レシートを削除しますか？';

  @override
  String get repeatDropReceiptBody => '定期支出にはレシートを保存できません。代わりに、追加される支出ごとにレシートを追加できます。';

  @override
  String get repeatDropReceiptAction => '繰り返す';

  @override
  String get recurringTitle => '定期支出';

  @override
  String get recurringHelp => 'スケジュールに沿って自動追加される支出';

  @override
  String get recurringEmptyTitle => '定期支出はありません';

  @override
  String get recurringEmptyBody => '家賃やサブスクリプションなど、定期的に発生する費用を日付ごとに自動追加できます。';

  @override
  String get recurringAdd => '定期支出を追加';

  @override
  String get recurringEdit => '定期支出を編集';

  @override
  String recurringNext(String date) {
    return '次回：$date';
  }

  @override
  String get recurringPaused => '一時停止中';

  @override
  String get recurringEnded => '終了';

  @override
  String get recurringPause => '一時停止';

  @override
  String get recurringResume => '再開';

  @override
  String get recurringActive => '繰り返し中';

  @override
  String get recurringDelete => '削除';

  @override
  String get recurringDeleteTitle => '繰り返しを停止しますか？';

  @override
  String recurringDeleteBody(String title) {
    return '「$title」は今後追加されなくなります。すでに追加された支出は残ります。';
  }

  @override
  String get recurringDeleted => '定期支出を削除しました';

  @override
  String get recurringFromSchedule => '定期支出から追加';

  @override
  String get recurringOpen => 'スケジュールを変更';

  @override
  String get recurringMissing => '定期支出は削除されたか、利用できなくなりました。';

  @override
  String get errorTooManyDue => '開始日が古すぎます。一度に100件を超える支出が追加されます。';

  @override
  String get errorInvalidEnd => '終了日は開始日より前に設定できません。';

  @override
  String get errorInvalidRepeat => '繰り返し間隔は1〜999で、単位は日・週・か月・年から選んでください。';

  @override
  String get errorRecurringConflict => '編集中に別の人がこの定期支出を変更しました。再読み込みして変更内容を確認してください。';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$whoが「$title」を繰り返す設定にしました';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$whoが定期支出「$title」を変更しました';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$whoが定期支出「$title」を一時停止しました';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return 'メンバーがグループを退出したため、定期支出「$title」は一時停止されました';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return '追加できなかったため、定期支出「$title」は一時停止されました';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$whoが定期支出「$title」を再開しました';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$whoが定期支出「$title」の繰り返しを停止しました';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return '「$title」（$amount）が自動で追加されました';
  }

  @override
  String get expenseRecurring => '定期支出から追加';
}
