// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get languageEndonym => '简体中文';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => '取消';

  @override
  String get commonRetry => '重试';

  @override
  String get offlineBar => '当前离线。正在显示此设备保存的内容；重新连接后才能保存更改。';

  @override
  String get commonSave => '保存';

  @override
  String get commonClear => '清除';

  @override
  String get iconChoose => '选择图标';

  @override
  String get iconNone => '无图标';

  @override
  String get iconSearchHint => '搜索，或输入任意表情';

  @override
  String get iconUseTyped => '使用此表情';

  @override
  String get iconNoMatch => '没有匹配的图标。输入一个表情即可使用。';

  @override
  String get iconSectionTravel => '旅行与地点';

  @override
  String get iconSectionFood => '餐饮';

  @override
  String get iconSectionActivities => '活动';

  @override
  String get iconSectionHome => '家居与账单';

  @override
  String get iconSectionPeople => '人物';

  @override
  String get iconSectionNature => '动物与自然';

  @override
  String get iconSectionObjects => '金钱与物品';

  @override
  String get iconSectionSymbols => '符号';

  @override
  String get commonRemove => '移除';

  @override
  String get commonUndo => '撤销';

  @override
  String get someone => '某人';

  @override
  String get errorTooLarge => '内容太大，无法发送到服务器。';

  @override
  String get errorBusy => '服务器正忙，请稍后重试。';

  @override
  String get errorTimeout => '发送时间过长。请检查网络连接后重试。';

  @override
  String get errorBadOrigin => '服务器不接受来自此地址的登录。请让服务器管理员检查其公开网址。';

  @override
  String get errorInvalidCategory => '该类别已被删除，请选择其他类别。';

  @override
  String get errorBuiltinCategory => '内置类别只能隐藏。';

  @override
  String get errorUnknownMember => '此支出中的某位成员已不在群组中。请重新加载后重试。';

  @override
  String get errorNoPayers => '请选择付款人。';

  @override
  String get errorPayerTotal => '每个人支付的金额总和必须等于支出金额。';

  @override
  String get errorPayerTooSmall => '某人的付款金额换算成群组货币后为零。请检查金额。';

  @override
  String get errorInvalidNote => '备注太长，或包含无法保存的字符。';

  @override
  String get errorInvalidDate => '日期超出范围。';

  @override
  String get errorGeneric => '出了点问题，请重试。';

  @override
  String get errorNetwork => '无法连接到服务器。请检查网络连接。';

  @override
  String get errorNotFound => '此内容已不存在。';

  @override
  String get errorRequired => '必填';

  @override
  String get errorInvalidName => '请输入一个不超过 100 个字符的名称。';

  @override
  String get errorDuplicateName => '群组中已有成员使用此名称。';

  @override
  String get errorTooManyMembers => '群组成员已达上限。';

  @override
  String get errorTooManyCategories => '群组类别已达上限。';

  @override
  String get errorDuplicateCategory => '群组中已有同名类别。';

  @override
  String get errorInvalidCurrency => '请输入三位字母的货币代码，例如 USD。';

  @override
  String get errorInvalidTitle => '请输入不超过 200 个字符的标题。';

  @override
  String get errorInvalidLocation => '请输入单行地点名称，最多 200 个字符。';

  @override
  String get errorInvalidSymbol => '请输入不超过 8 个字符的符号。';

  @override
  String get errorInvalidEmoji => '请选择一个表情作为图标。';

  @override
  String get errorMemberHasBalance => '请先结清此成员的余额，再将其移除。';

  @override
  String get errorVersionConflict => '你编辑支出期间，其他人修改了它。重新加载以查看更改。';

  @override
  String get errorSignInRequired => '请先登录再执行此操作。';

  @override
  String get errorRateLimited => '请求太频繁。请稍等一分钟后重试。';

  @override
  String get errorNotAMember => '你还不是此群组的成员。';

  @override
  String get errorNotAllowed => '只有此成员或群组所有者可以执行此操作。';

  @override
  String get errorLinkGroupsOff => '此服务器不允许仅凭链接打开群组。';

  @override
  String get errorMemberClaimed => '已有其他人以此成员身份加入。';

  @override
  String get errorMemberLeft => '此群组中的某位成员已离开。';

  @override
  String get errorInvalidEmail => '请输入电子邮箱地址。';

  @override
  String get errorInvalidPassword => '请输入 8 至 200 个字符。';

  @override
  String get errorEmailTaken => '此邮箱已注册账号。请改为登录。';

  @override
  String get errorSignupClosed => '此服务器目前不接受新账号注册。';

  @override
  String get errorInvalidCredentials => '邮箱和密码不匹配。';

  @override
  String get errorWrongPassword => '当前密码不正确。';

  @override
  String get errorAccountsOff => '此服务器未启用账号功能。';

  @override
  String get errorInvalidAmount => '请输入大于零的金额。';

  @override
  String get errorTooManyDecimals => '此货币的小数位数过多。';

  @override
  String get errorAmountTooLarge => '金额过大。';

  @override
  String get errorNoShares => '请至少选择一位分摊人。';

  @override
  String get errorInvalidShare => '每份分摊金额都必须是数字。';

  @override
  String get errorExactTotal => '各项金额总和必须等于总额。';

  @override
  String get errorPayersTotal => '所有付款金额总和必须等于总额。';

  @override
  String get categoryFood => '餐饮';

  @override
  String get categoryGroceries => '食品杂货';

  @override
  String get categoryTransport => '交通';

  @override
  String get categoryTravel => '旅行';

  @override
  String get categoryLodging => '住宿';

  @override
  String get categoryRent => '房租';

  @override
  String get categoryUtilities => '水电燃气';

  @override
  String get categoryEntertainment => '娱乐';

  @override
  String get categoryShopping => '购物';

  @override
  String get categoryHealth => '医疗';

  @override
  String get categoryGifts => '礼物';

  @override
  String get categoryOther => '其他';

  @override
  String get groupNew => '新建群组';

  @override
  String get groupSwitch => '切换群组';

  @override
  String get groupReorder => '拖动以调整顺序';

  @override
  String get groupCreate => '创建群组';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count 位成员', one: '1 位成员');
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return '别人欠你 $amount';
  }

  @override
  String pillOwe(String amount) {
    return '你欠 $amount';
  }

  @override
  String get pillSettled => '已结清';

  @override
  String get groupMissingTitle => '找不到群组';

  @override
  String get groupMissingBody => '此群组已被删除，或其链接已重置。请向群组中的成员索取新链接。';

  @override
  String get groupLockedTitle => '登录后打开此群组';

  @override
  String get groupLockedBody => '此群组仅对其成员账号开放。请登录关联此群组的账号。';

  @override
  String get groupForget => '从此设备移除';

  @override
  String get groupLinkOtherServer => '此链接属于另一台服务器。请连接到该服务器后再打开。';

  @override
  String get openLinkTitle => '打开群组链接';

  @override
  String get openLinkBody => '粘贴别人分享给你的链接，即可加入他们的群组。';

  @override
  String get openLinkLabel => '群组链接';

  @override
  String get openLinkAction => '打开';

  @override
  String get openLinkInvalid => '这看起来不像 Balnana 群组链接。';

  @override
  String get groupName => '群组名称';

  @override
  String get groupNameHint => '里斯本之旅';

  @override
  String get groupCurrency => '货币';

  @override
  String get groupCurrencyHelp => '此群组中的所有支出都使用此货币。之后无法更改。';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name。此群组中的所有支出都使用此货币。之后无法更改。';
  }

  @override
  String get currencyChoose => '选择货币';

  @override
  String get currencySearchHint => '按代码或名称搜索';

  @override
  String get currencySuggested => '推荐';

  @override
  String get currencyAll => '所有货币';

  @override
  String currencyUseTyped(String code) {
    return '使用 $code';
  }

  @override
  String get currencyNoMatch => '没有匹配的货币。输入三位货币代码即可使用。';

  @override
  String get groupSymbol => '符号';

  @override
  String get groupSymbolChoose => '选择符号';

  @override
  String groupSymbolExample(String example) {
    return '金额会显示为 $example';
  }

  @override
  String get groupColor => '颜色';

  @override
  String colorSwatch(int number, int count) {
    return '第 $number/$count 个颜色';
  }

  @override
  String get groupPeople => '成员';

  @override
  String get groupYourName => '你的姓名';

  @override
  String groupPersonName(int number) {
    return '成员 $number';
  }

  @override
  String get groupAddPerson => '添加成员';

  @override
  String get groupPeopleHelp => '你之后可以添加更多成员，他们也可以通过链接加入。';

  @override
  String get identityTitle => '你是谁？';

  @override
  String get identityBody => '选择你的姓名，Balnana 才能显示你欠了多少。只有此设备会记住你的选择。';

  @override
  String get identityNew => '我是新成员';

  @override
  String get identityNewTitle => '加入此群组';

  @override
  String get identityJoin => '加入';

  @override
  String get identityChange => '更改身份';

  @override
  String get identityNone => '尚未选择';

  @override
  String get memberName => '姓名';

  @override
  String memberYou(String name) {
    return '$name（你）';
  }

  @override
  String get memberAdd => '添加成员';

  @override
  String get memberAddTitle => '添加成员';

  @override
  String get memberRename => '重命名';

  @override
  String get memberRenameTitle => '重命名';

  @override
  String memberRemoveTitle(String name) {
    return '移除 $name？';
  }

  @override
  String get memberRemoveBody => '此成员的支出和余额仍会保留在群组中。';

  @override
  String get groupLinkCopied => '链接已复制。任何拥有链接的人都可以打开此群组。';

  @override
  String get groupShare => '分享链接';

  @override
  String get groupSettings => '群组设置';

  @override
  String get groupEdit => '编辑群组';

  @override
  String get groupSharing => '共享';

  @override
  String get groupCopyLink => '复制链接';

  @override
  String get groupQrCode => '显示二维码';

  @override
  String get groupQrCodeHelp => '让其他人用手机相机扫描链接。';

  @override
  String groupQrLabel(String group) {
    return '$group 的群组链接二维码';
  }

  @override
  String get groupCopyLinkHelp => '任何拥有链接的人都可以查看和编辑此群组。';

  @override
  String get groupCopyLinkHelpAccounts => '拥有链接的人登录后可以申请加入。';

  @override
  String get linkAccessTitle => '任何拥有链接的人都可以打开';

  @override
  String get linkAccessHelp => '允许他人无需账号即可查看和编辑';

  @override
  String get resetLinkTitle => '重置链接';

  @override
  String get resetLinkHelp => '生成新链接，旧链接将失效';

  @override
  String get resetLinkBody => '当前链接将对所有人失效。请把新链接分享给仍需访问权限的人。';

  @override
  String get resetLinkAction => '重置';

  @override
  String get resetLinkDone => '链接已重置。请分享新链接。';

  @override
  String get groupThisDevice => '此设备';

  @override
  String get groupData => '数据';

  @override
  String get categoriesTitle => '类别';

  @override
  String get categoriesHelp => '添加自定义类别，或隐藏不使用的类别';

  @override
  String get categoriesOwn => '自定义类别';

  @override
  String get categoriesOwnEmpty => '此群组还没有自定义类别。';

  @override
  String get categoriesBuiltIn => '内置';

  @override
  String get categoriesBuiltInHelp => '隐藏的类别不会用于新支出，已有支出仍会保留该类别。';

  @override
  String get categoryAdd => '添加类别';

  @override
  String get categoryEdit => '编辑类别';

  @override
  String get categoryName => '名称';

  @override
  String get categoryDelete => '删除类别';

  @override
  String categoryDeleteTitle(String name) {
    return '删除“$name”？';
  }

  @override
  String get categoryDeleteBody => '此类别下的支出将不再有类别。';

  @override
  String get categoryDeleteAction => '删除';

  @override
  String get exportCsv => '导出为 CSV';

  @override
  String get exportCsvHelp => '导出所有支出和转账，方便用于电子表格';

  @override
  String get exportCsvDone => '已导出';

  @override
  String get forgetTitle => '从此设备移除';

  @override
  String get forgetHelp => '群组仍会保留在服务器上，供其他人使用';

  @override
  String get forgetBody => '你可以之后通过链接重新打开。';

  @override
  String get groupYou => '你';

  @override
  String get leaveTitle => '离开群组';

  @override
  String get leaveHelp => '你的支出会保留；之后可以通过链接重新加入';

  @override
  String get leaveBody => '此群组将从你的列表中消失。你的支出和余额仍会保留在群组中。';

  @override
  String get leaveAction => '离开';

  @override
  String get tabExpenses => '支出';

  @override
  String get heroWhoTitle => '你是群组中的哪位成员？';

  @override
  String get heroWhoBody => '选择你的姓名，查看你欠了多少以及别人欠你多少。';

  @override
  String get heroWhoAction => '选择';

  @override
  String get heroJoinTitle => '你正在查看此群组';

  @override
  String get heroJoinBody => '加入群组即可添加支出并查看欠款。';

  @override
  String get joinAction => '加入';

  @override
  String get heroOwed => '别人欠你';

  @override
  String get heroOwe => '你欠';

  @override
  String get heroSettled => '你已结清';

  @override
  String heroYouAre(String name) {
    return '你是 $name';
  }

  @override
  String get expenseAdd => '添加支出';

  @override
  String get expensesEmptyTitle => '还没有支出';

  @override
  String get expensesEmptyBody => '添加第一笔支出，Balnana 会帮你算出谁欠谁。';

  @override
  String get expensesSearchHint => '搜索标题、备注和地点';

  @override
  String get searchClear => '清除搜索';

  @override
  String get expensesNoMatchTitle => '没有匹配结果';

  @override
  String get expensesNoMatchBody => '试试其他关键词，或减少筛选条件。';

  @override
  String get filterAnyone => '所有人';

  @override
  String get filterAnyCategory => '所有类别';

  @override
  String get filterPayments => '转账';

  @override
  String get filterClear => '清除筛选';

  @override
  String get periodAll => '全部时间';

  @override
  String get periodThisMonth => '本月';

  @override
  String get periodLastMonth => '上月';

  @override
  String get periodThisYear => '今年';

  @override
  String get periodPickDays => '选择日期…';

  @override
  String get statsTitle => '支出统计';

  @override
  String get statsTotal => '支出总额';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count 笔支出', one: '1 笔支出');
    return '$_temp0';
  }

  @override
  String get statsByCategory => '按类别';

  @override
  String get statsByMember => '每人已付金额与分摊金额';

  @override
  String get statsPaid => '已付款';

  @override
  String get statsShare => '分摊金额';

  @override
  String get statsByMonth => '按月';

  @override
  String get statsNoCategory => '无类别';

  @override
  String get statsEmptyTitle => '暂无支出';

  @override
  String get statsEmptyBody => '此时间段内没有支出。';

  @override
  String get statsShowExpenses => '查看这些支出';

  @override
  String get dateToday => '今天';

  @override
  String get dateYesterday => '昨天';

  @override
  String paymentTitle(String from, String to) {
    return '$from 付给 $to';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name 支付了 $amount';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return '$count 人支付了 $amount';
  }

  @override
  String expensePaidByName(String name) {
    return '$name 支付';
  }

  @override
  String expensePaidByManyNames(int count) {
    return '$count 人支付';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name 收到 $amount';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$name 收到';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return '$count 人收到';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return '$count 人收到 $amount';
  }

  @override
  String get transactionRefund => '退款';

  @override
  String get transactionIncome => '收入';

  @override
  String get paymentDelete => '删除转账';

  @override
  String get paymentDeleted => '转账已删除';

  @override
  String expenseDeleted(String title) {
    return '已删除“$title”';
  }

  @override
  String get expenseNew => '新建支出';

  @override
  String get expenseEdit => '编辑支出';

  @override
  String get expenseDelete => '删除';

  @override
  String get expenseAmount => '金额';

  @override
  String get expenseTitle => '这笔支出是什么？';

  @override
  String get expenseTitleHint => '晚餐、门票、出租车…';

  @override
  String get expenseAmountFromPayers => '所有人的付款总和';

  @override
  String expensePaidIn(String currency) {
    return '以 $currency 付款';
  }

  @override
  String expenseRate(String from, String to) {
    return '1 $from 兑换 $to';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return '以 $currency 计的总额';
  }

  @override
  String expenseForeignHelp(String currency) {
    return '余额仍以 $currency 计算。输入汇率，或输入实际金额，例如银行卡账单上的金额。';
  }

  @override
  String get expenseNote => '备注';

  @override
  String get expenseNoteHint => '选填';

  @override
  String get expenseLocation => '地点';

  @override
  String get expenseLocationHint => '在哪里？（选填）';

  @override
  String get locationPickOnMap => '在地图上选择';

  @override
  String get locationUseCurrent => '使用当前位置';

  @override
  String get locationFinding => '正在查找你的位置…';

  @override
  String get locationChange => '在地图上更改';

  @override
  String get locationRemovePin => '移除标记';

  @override
  String get locationOpenInMaps => '在地图中打开';

  @override
  String get locationPickTitle => '选择地点';

  @override
  String get locationPickHint => '轻点地图放置标记';

  @override
  String get locationPickDone => '完成';

  @override
  String get locationDenied => 'Balnana 无法使用你的位置。你可以在设备或浏览器设置中允许访问。';

  @override
  String get locationOff => '此设备已关闭定位。';

  @override
  String get locationUnavailable => '无法找到你的位置。请重试，或在地图上放置标记。';

  @override
  String get expenseReceipt => '收据';

  @override
  String get expenseHasReceipt => '有收据照片';

  @override
  String get expenseHasLocation => '有地点';

  @override
  String get receiptTakePhoto => '拍照';

  @override
  String get receiptChoose => '选择图片';

  @override
  String get receiptRemove => '移除';

  @override
  String get receiptView => '收据照片';

  @override
  String receiptNotSaved(String reason) {
    return '支出已保存，但收据照片未保存。$reason';
  }

  @override
  String get expensePaidByLabel => '付款人';

  @override
  String get expenseReceivedForLabel => '收款事由';

  @override
  String get expenseReceivedByLabel => '收款人';

  @override
  String get expenseMultiplePayers => '多人';

  @override
  String get expenseSplit => '分摊';

  @override
  String get splitEqual => '均分';

  @override
  String get splitExact => '按金额';

  @override
  String get splitShares => '按份额';

  @override
  String splitLeft(String amount) {
    return '还需分配 $amount';
  }

  @override
  String splitOver(String amount) {
    return '超出 $amount';
  }

  @override
  String get conflictTitle => '已在其他位置更改';

  @override
  String get conflictReload => '重新加载';

  @override
  String get expenseChangedElsewhere => '其他人修改了此支出。重新加载会显示对方的版本，并丢弃你在此处的更改。';

  @override
  String get expenseNewerTitle => '由较新版本创建';

  @override
  String get expenseNewerBody => '请更新 Balnana 后再修改此项。';

  @override
  String get suggestedPayments => '建议转账';

  @override
  String get allSettled => '所有人都已结清。';

  @override
  String transferYouPay(String name) {
    return '你付给 $name';
  }

  @override
  String transferPaysYou(String name) {
    return '$name 付给你';
  }

  @override
  String transferPays(String from, String to) {
    return '$from 付给 $to';
  }

  @override
  String get recordPayment => '记录';

  @override
  String get recordPaymentTitle => '记录转账';

  @override
  String get recordPaymentHelp => '仅记录在 Balnana 之外实际支付的款项。';

  @override
  String get paymentRecorded => '已记录转账';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who 创建了群组 $group';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who 修改了群组信息';
  }

  @override
  String activityLinkReset(String who) {
    return '$who 重置了群组链接';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who 添加了成员 $name';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who 将 $oldName 重命名为 $name';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who 移除了成员 $name';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who 添加了类别“$name”';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who 修改了类别';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who 删除了类别“$name”';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name 加入了群组';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who 添加了支出“$title”（$amount）';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who 修改了支出“$title”（$amount）';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who 删除了支出“$title”';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who 恢复了支出“$title”';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who 记录了 $from 付给 $to 的转账（$amount）';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who 删除了一笔 $amount 的转账';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who 恢复了一笔 $amount 的转账';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count 条记录', one: '1 条记录');
    return '$who 从 $source 导入了 $_temp0';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who 为“$title”添加了收据照片';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who 移除了“$title”的收据照片';
  }

  @override
  String activityOther(String who) {
    return '$who 做出了一项更改';
  }

  @override
  String get navGroups => '群组';

  @override
  String get navActivity => '动态';

  @override
  String get navSettings => '设置';

  @override
  String get groupsEmptyTitle => '还没有群组';

  @override
  String get groupsEmptyBody => '你创建或通过链接打开的群组会显示在这里。';

  @override
  String get groupsNoServerTitle => '连接到服务器';

  @override
  String get groupsNoServerBody => 'Balnana 会将群组保存在你选择的服务器上，例如你自己托管的服务器。';

  @override
  String get groupsNoServerAction => '选择服务器';

  @override
  String get groupsUnreachableTitle => '无法连接到服务器';

  @override
  String get groupsUnreachableBody => '请检查网络连接，或在设置中检查服务器地址。';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '无法加载 $count 个群组，因此缺少这些群组的动态。',
      one: '无法加载 1 个群组，因此缺少该群组的动态。',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => '这里还没有动态';

  @override
  String get activityEmptyBody => '群组中的新支出和转账会显示在这里。';

  @override
  String get notFoundTitle => '找不到页面';

  @override
  String get notFoundBody => '此地址在 Balnana 中没有对应页面。';

  @override
  String get notFoundAction => '前往群组';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsAccount => '账号';

  @override
  String get accountRename => '更改姓名';

  @override
  String get passwordChange => '更改密码';

  @override
  String get passwordChanged => '密码已更改。其他设备已退出登录。';

  @override
  String get passwordSet => '设置密码';

  @override
  String get passwordSetHelp => '你也可以使用邮箱或用户名和密码登录';

  @override
  String get passwordSetDone => '密码已设置。其他设备已退出登录。';

  @override
  String get passwordCurrent => '当前密码';

  @override
  String get passwordNew => '新密码';

  @override
  String get signOut => '退出登录';

  @override
  String get accountOAuthLinked => '用于登录此账号。轻点即可移除。';

  @override
  String get accountOAuthAdd => '添加为登录方式';

  @override
  String accountOAuthAddTitle(String name) {
    return '添加 $name';
  }

  @override
  String accountOAuthAdded(String name) {
    return '现在可以使用 $name 登录。';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return '移除 $name？';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return '移除后，你将无法使用 $name 登录，除非再次添加。';
  }

  @override
  String get accountOAuthRemove => '移除';

  @override
  String accountOAuthRemoved(String name) {
    return '已移除 $name。';
  }

  @override
  String get confirmEmailTitle => '确认邮箱';

  @override
  String confirmEmailBody(String email) {
    return '此服务器要求确认邮箱。请打开我们发送到 $email 的链接。';
  }

  @override
  String get confirmEmailDone => '我已确认';

  @override
  String get confirmEmailResend => '重新发送链接';

  @override
  String get confirmEmailNotYet => '尚未确认。请打开邮件中的链接。';

  @override
  String get settingsTheme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get settingsDynamicColor => '壁纸颜色';

  @override
  String get settingsDynamicColorSubtitle => '使用设备的颜色，而不是 Balnana 黄';

  @override
  String get settingsWallpaperGroups => '群组使用壁纸颜色';

  @override
  String get settingsWallpaperGroupsSubtitle => '群组也使用设备的颜色，而不是各自的颜色';

  @override
  String get settingsPureBlack => '纯黑色';

  @override
  String get settingsPureBlackSubtitle => '适用于 OLED 屏幕的更深色主题';

  @override
  String get settingsMyShare => '显示我的分摊金额';

  @override
  String get settingsMyShareSubtitle => '支出显示你借出或借入的金额，而不是总额';

  @override
  String get settingsLanguage => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotificationsSubtitle => '当有人添加、更改或删除你参与的支出时通知';

  @override
  String get settingsNotificationsBlocked => '已在手机设置中禁止：请在那里允许 Balnana 发送通知';

  @override
  String get pushChannel => '支出';

  @override
  String get pushChannelDescription => '当有人添加、更改或删除你参与的支出时通知';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who 添加了 $title · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who 更改了 $title · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who 删除了 $title · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return '已添加 $title · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return '已更改 $title · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return '已删除 $title · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payer 付给 $payee $amount';
  }

  @override
  String get settingsConnection => '连接';

  @override
  String get settingsServer => '服务器';

  @override
  String get serverNotSet => '未设置';

  @override
  String get settingsAbout => '关于';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutLicenses => '开源许可证';

  @override
  String get aboutSource => '源代码';

  @override
  String get aboutSourceCopied => '无法打开浏览器，链接已复制';

  @override
  String get serverTitle => '服务器';

  @override
  String get serverIntro => '输入 Balnana 服务器地址。任何人都可以托管服务器；通常可以通过该地址打开服务器上的网页应用。';

  @override
  String get serverUrlLabel => '服务器地址';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => '测试连接';

  @override
  String get serverSaveAnyway => '仍然保存';

  @override
  String get serverReset => '恢复默认';

  @override
  String serverDefault(String url) {
    return '默认：$url';
  }

  @override
  String serverConnected(String version) {
    return '已连接到 Balnana $version';
  }

  @override
  String get serverModeLink => '通过私密链接共享群组。无需账号。';

  @override
  String get serverModeAccounts => '成员使用账号登录。';

  @override
  String get serverInsecure => '此地址未加密（http）。网络中的任何人都可能读取你的数据。离开家庭网络访问服务器时，请使用 https。';

  @override
  String get serverErrorInvalid => '请输入网址，例如 balnana.example.com';

  @override
  String get serverErrorUnreachable => '无法连接。请检查地址和服务器是否正在运行。';

  @override
  String get serverErrorNotBalnana => '服务器有响应，但它不是 Balnana 服务器。';

  @override
  String get serverSaved => '服务器已保存';

  @override
  String get signIn => '登录';

  @override
  String get groupSignInTitle => '登录后打开此群组';

  @override
  String get groupSignInBody => '此群组仅对其成员开放。登录后即可查看或加入。';

  @override
  String get signInTitle => '欢迎回来';

  @override
  String get signInBody => '登录以查看你的群组。';

  @override
  String get signInNoPassword => '此服务器使用其他方式登录。请联系服务器管理员。';

  @override
  String get registerTitle => '创建账号';

  @override
  String get registerBody => '在所有设备上查看你的群组。';

  @override
  String get registerAction => '创建账号';

  @override
  String get registerHaveAccount => '我已有账号';

  @override
  String get signInNoAccount => '创建账号';

  @override
  String get accountName => '你的姓名';

  @override
  String get accountNameHelp => '群组中的其他人会看到此名称';

  @override
  String get accountEmail => '邮箱';

  @override
  String get accountPassword => '密码';

  @override
  String get accountPasswordHelp => '至少 8 个字符';

  @override
  String get passwordShow => '显示密码';

  @override
  String get passwordHide => '隐藏密码';

  @override
  String get joinPickName => '选择其他姓名';

  @override
  String joinTitle(String name) {
    return '加入 $name';
  }

  @override
  String get joinBody => '你是这些成员中的一位吗？选择你自己，即可接管其支出。';

  @override
  String get joinBodyNew => '加入群组即可添加支出并查看余额。';

  @override
  String get joinAsNew => '我是新成员';

  @override
  String joinAsName(String name) {
    return '以 $name 的身份加入';
  }

  @override
  String joinTaken(String names) {
    return '已加入：$names';
  }

  @override
  String joinTakenCount(int count) {
    return '已有 $count 位成员加入。';
  }

  @override
  String get commonContinue => '继续';

  @override
  String get errorEmailOff => '此服务器不会发送邮件。';

  @override
  String get errorInvalidToken => '此链接已过期或已使用。';

  @override
  String get forgotPasswordTitle => '忘记密码？';

  @override
  String get forgotPasswordBody => '我们会通过邮件发送重设密码的链接。';

  @override
  String get forgotPasswordAction => '发送链接';

  @override
  String get forgotPasswordSent => '如果该邮箱已注册账号，重设链接很快就会发送。';

  @override
  String get resetPasswordTitle => '设置新密码';

  @override
  String get resetPasswordBody => '你将在所有设备上退出登录，然后可以使用新密码登录。';

  @override
  String get resetPasswordAction => '保存密码';

  @override
  String get resetPasswordDone => '密码已更改。请使用新密码登录。';

  @override
  String get verifyEmailTitle => '确认邮箱';

  @override
  String get verifyEmailHelp => '这样忘记密码时就可以重设';

  @override
  String verifyEmailSent(String email) {
    return '请查看 $email，找到其中的链接。';
  }

  @override
  String get verifyEmailDone => '邮箱已确认';

  @override
  String get verifyEmailDoneBody => '谢谢！你的邮箱已确认。';

  @override
  String get verifyEmailFailed => '无法确认邮箱';

  @override
  String get inviteByEmail => '通过邮箱邀请';

  @override
  String get inviteByEmailHelp => '发送链接邀请他人加入';

  @override
  String get inviteAs => '以此身份加入';

  @override
  String get inviteAsHelp => '对方可以接管此成员的支出';

  @override
  String get inviteAsAnyone => '新成员';

  @override
  String get inviteSend => '发送邀请';

  @override
  String inviteSent(String email) {
    return '已向 $email 发送邀请。';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name 邀请你加入 $group';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return '你受邀加入 $group';
  }

  @override
  String inviteBody(String email) {
    return '使用 $email 创建账号以加入；如果已有账号，请登录。';
  }

  @override
  String get inviteBodySignedIn => '加入群组即可添加支出并查看余额。';

  @override
  String get inviteAction => '打开邀请';

  @override
  String get inviteMissingTitle => '此邀请无法使用';

  @override
  String get inviteMissingBody => '邀请可能已过期或已被使用。请对方重新发送。';

  @override
  String get joinInvitedAs => '你受邀加入此成员';

  @override
  String signInWith(String provider) {
    return '使用 $provider 继续';
  }

  @override
  String get signInOr => '或';

  @override
  String get oauthFailedTitle => '无法登录';

  @override
  String get oauthPendingTitle => '此邮箱已注册账号';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider 表示 $email 属于你，但使用该邮箱的账号尚未确认邮箱。你想怎么处理？';
  }

  @override
  String get oauthPendingLink => '添加到该账号';

  @override
  String get oauthPendingLinkHelp => '输入该账号的密码。原密码仍然有效。';

  @override
  String get oauthPendingTakeOver => '接管该账号';

  @override
  String get oauthPendingTakeOverHelp => '该账号的密码和其他登录方式会被移除，所有已登录该账号的设备也会退出登录。';

  @override
  String get oauthPendingNew => '创建新账号';

  @override
  String oauthPendingNewHelp(String email) {
    return '另一个账号会保留其群组，但不再使用 $email。';
  }

  @override
  String get oauthPendingPassword => '该账号的密码';

  @override
  String get oauthPendingWrongPassword => '密码不正确。';

  @override
  String get oauthOtherServer => '此登录是在另一台服务器上发起的，与当前选择的服务器不同。请重新登录。';

  @override
  String get oauthBackToSignIn => '返回登录';

  @override
  String get errorOAuthFailed => '登录失败。请重试。';

  @override
  String get errorEmailHasAccount => '此邮箱已注册账号。请先登录，然后在设置中添加此登录方式。';

  @override
  String get errorIdentityTaken => '此登录方式已关联到另一个账号。';

  @override
  String get errorLastSignInMethod => '这是你唯一的登录方式。请先设置密码或添加其他登录方式。';

  @override
  String get errorEmailUnverified => '请先确认邮箱。';

  @override
  String get errorOAuthCancelled => '登录已取消。';

  @override
  String get importTitle => '从 Settle Up 导入';

  @override
  String get importAction => '导入';

  @override
  String get importIntro => '在 Settle Up 中将群组导出为 CSV 文件，然后在此选择该文件。支出、转账和所有群组成员都会一并导入，余额也会保持不变。';

  @override
  String get importChooseFile => '选择 CSV 文件';

  @override
  String get importChooseOther => '选择其他文件';

  @override
  String get importReading => '正在读取文件…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(expenses, locale: localeName, other: '$expenses 笔支出', one: '1 笔支出');
    String _temp1 = intl.Intl.pluralLogic(payments, locale: localeName, other: '$payments 笔转账', one: '1 笔转账');
    return '$_temp0，$_temp1';
  }

  @override
  String importDates(String from, String to) {
    return '$from 至 $to';
  }

  @override
  String importCurrency(String currency) {
    return '货币：$currency。其他货币的记录使用 Settle Up 换算后的金额。';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已忽略 $count 条金额为零的记录。',
      one: '已忽略 1 条金额为零的记录。',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => '你是哪位成员？';

  @override
  String get importUntitled => '无标题';

  @override
  String get errorImportFile => '这看起来不像 Settle Up 导出的 CSV 文件。';

  @override
  String get errorImportCurrency => '文件中没有不带汇率的记录，因此无法确定群组货币。';

  @override
  String get errorImportTooBig => '此文件太大，无法导入。';

  @override
  String get errorBadImage => '无法使用此图片。请选择 JPEG、PNG 或 WebP 图片。';

  @override
  String get errorReceiptTooBig => '图片太大。请选择小于 10 MB 的图片。';

  @override
  String get errorImportMe => '请选择你对应的成员。';

  @override
  String errorImportRow(int line, String reason) {
    return '无法导入文件第 $line 行：$reason';
  }

  @override
  String get errorImportAmount => '无法读取金额。';

  @override
  String get errorImportCounts => '名称和金额数量不匹配。';

  @override
  String get errorImportDate => '无法读取日期。';

  @override
  String get errorImportType => '类型必须是支出、转账或收入。';

  @override
  String get errorImportTransfer => '转账必须指定一位付款人和一位收款人。';

  @override
  String get errorImportRowCurrency => '此记录使用了另一种货币，且没有汇率。';

  @override
  String get adminSetupTitle => '设置此服务器';

  @override
  String get adminSetupBody => '为管理员设置密码。此密码用于保护服务器设置页面。没有用户名：知道密码的人都可以更改设置。';

  @override
  String get adminSetupCode => '设置代码';

  @override
  String get adminSetupCodeHelp => '此服务器已有数据，因此启动时会将设置代码写入日志。使用 Docker：docker compose logs balnana';

  @override
  String get adminSetupAction => '设置密码';

  @override
  String get adminPassword => '管理员密码';

  @override
  String get adminPasswordRepeat => '再次输入密码';

  @override
  String get adminPasswordMismatch => '两次输入的密码不一致。';

  @override
  String get adminLoginTitle => '管理后台';

  @override
  String get adminLoginBody => '输入管理员密码以更改此服务器的设置。';

  @override
  String get adminLoginAction => '登录';

  @override
  String get adminSettingsTitle => '服务器设置';

  @override
  String get adminSaved => '设置已保存并立即生效。';

  @override
  String get adminSaveFailed => '未保存任何内容。请检查标出的设置。';

  @override
  String get adminChangePassword => '更改管理员密码';

  @override
  String get adminPasswordCurrent => '当前密码';

  @override
  String get adminPasswordNew => '新密码';

  @override
  String get adminPasswordChanged => '密码已更改。其他管理员会话已退出登录。';

  @override
  String get adminSignOut => '退出管理后台';

  @override
  String get adminBackHome => '返回 Balnana';

  @override
  String get adminRequireEmail => '必须填写邮箱地址';

  @override
  String get adminRequireEmailHelp => '关闭后，用户可以使用用户名注册，也可以不填写邮箱地址。登录时可使用邮箱或用户名。';

  @override
  String get adminRequireEmailUnused => '仅适用于当前已关闭的邮箱和密码登录方式。';

  @override
  String get accountUsername => '用户名';

  @override
  String get accountUsernameHelp => '3 至 32 个字母、数字、点、短横线或下划线。可用此用户名登录。';

  @override
  String get accountEmailOptional => '邮箱（选填）';

  @override
  String get accountEmailOptionalHelp => '用于接收群组邀请和重设遗忘的密码。';

  @override
  String get accountLogin => '邮箱或用户名';

  @override
  String get errorInvalidUsername => '请输入 3 至 32 个字母、数字、点、短横线或下划线，并以字母或数字开头。';

  @override
  String get errorUsernameTaken => '此用户名已被使用。';

  @override
  String get adminDiscardTitle => '放弃更改？';

  @override
  String get adminDiscardBody => '你对设置所做的更改尚未保存。';

  @override
  String get adminDiscard => '放弃';

  @override
  String adminLocked(String key) {
    return '由服务器通过 $key 设置';
  }

  @override
  String adminDefault(String value) {
    return '默认值：$value';
  }

  @override
  String get adminSecretSaved => '已保存。输入新值即可替换。';

  @override
  String get adminSecretRemoved => '保存时将移除。';

  @override
  String get adminSecretRemove => '移除已保存的值';

  @override
  String get adminSectionGeneral => '常规';

  @override
  String get adminSectionAccess => '访问权限';

  @override
  String get adminSectionMaps => '地图';

  @override
  String get adminSectionAccounts => '账号';

  @override
  String get adminSectionAccountsBody => '这些设置仅在访问方式设为账号时生效。';

  @override
  String get adminSectionEmail => '邮箱（SMTP）';

  @override
  String get adminSectionEmailBody => '用于验证邮箱、重设密码和发送邀请。';

  @override
  String get adminSmtpOn => '发送邮件';

  @override
  String get adminSectionGoogle => '使用 Google 登录';

  @override
  String adminSectionGoogleBody(String url) {
    return '在 Google Cloud 控制台中，将 $url 注册为重定向 URI。';
  }

  @override
  String get adminGoogleOn => '提供 Google 登录';

  @override
  String get adminGoogleOnHelp => '用户可以使用 Google 账号登录。';

  @override
  String get adminSectionOidc => '使用 OpenID Connect 登录';

  @override
  String adminSectionOidcBody(String url) {
    return '在身份提供方中，将 $url 注册为重定向 URI。';
  }

  @override
  String get adminOidcHelp => '支持任意 OpenID Connect 提供方，例如 Authentik、Keycloak 或 Dex。可按需添加多个。';

  @override
  String get adminOidcAdd => '添加提供方';

  @override
  String get adminOidcRemove => '移除提供方';

  @override
  String get adminOidcNew => '新提供方';

  @override
  String get adminOidcId => 'ID';

  @override
  String get adminOidcIdHelp => '使用小写字母、数字和短横线。此 ID 是重定向 URI 的一部分，之后无法更改。';

  @override
  String get adminOidcIdInvalid => '请输入最多 32 个小写字母、数字或短横线，并以字母或数字开头。';

  @override
  String get adminOidcIdTaken => '另一个提供方已使用此 ID。';

  @override
  String get adminTrustEmail => '信任提供方验证的邮箱';

  @override
  String get adminGoogleTrustEmailHelp => '如果 Google 登录使用的邮箱已关联账号，则直接登录该账号。关闭后，用户需用密码登录，再到设置中添加 Google。';

  @override
  String get adminOidcTrustEmailHelp => '仅对你运营或信任其邮箱验证能力的提供方启用。关闭后，已有账号的用户需用密码登录，再到设置中添加该提供方。';

  @override
  String get adminRequireVerified => '必须确认邮箱';

  @override
  String get adminRequireVerifiedHelp => '账号必须先确认邮箱才能使用应用。受信任的登录方式若使用相同邮箱，也会接管未确认的账号。关闭后，由用户自行选择处理方式。';

  @override
  String get adminRequireVerifiedUnused => '需要启用邮件发送。';

  @override
  String get adminSectionAndroid => 'Android 应用链接';

  @override
  String get adminSectionAndroidBody => '为此服务器构建的 Android 应用会在应用中打开服务器链接。如要跳过确认提示，请填写这些应用签名证书的 SHA-256 指纹。';

  @override
  String get adminSectionAdmin => '管理员';

  @override
  String get adminPublicUrl => '公开地址';

  @override
  String get adminPublicUrlHelp => '用户访问此服务器所用的地址。群组链接和邮件链接都基于此地址生成。';

  @override
  String get adminSourceUrl => '源代码链接';

  @override
  String get adminSourceUrlHelp => '用户获取此服务器源代码的地址。根据 AGPL-3.0，运行修改过的版本时需要提供此链接。';

  @override
  String get adminAuthMode => '访问方式';

  @override
  String get adminAuthModeLink => '群组链接';

  @override
  String get adminAuthModeLinkHelp => '无需登录：任何人只要有群组私密链接即可访问。';

  @override
  String get adminAuthModeAccounts => '账号';

  @override
  String get adminAuthModeAccountsHelp => '用户需登录；群组链接只允许已登录的用户加入群组。';

  @override
  String get adminPasswordLogin => '使用邮箱和密码登录';

  @override
  String get adminPasswordForced => '在启用 Google 或 OpenID Connect 登录前，此项会保持开启，以确保始终有登录方式可用。';

  @override
  String get adminSignup => '谁可以创建账号';

  @override
  String get adminSignupOpen => '任何人';

  @override
  String get adminSignupOpenHelp => '任何能访问此服务器的人都可以注册。';

  @override
  String get adminSignupInvite => '受邀用户';

  @override
  String get adminSignupInviteHelp => '只有通过邮件受邀加入群组的人才能注册，并且只能使用收到邀请的邮箱。仅凭群组链接无法注册。必须启用邮件发送才能使用邀请。';

  @override
  String get adminSignupClosed => '无人';

  @override
  String get adminSignupClosedHelp => '不允许注册新账号。现有账号仍可使用。';

  @override
  String get adminSignupHelp => '始终允许创建第一个账号。';

  @override
  String get adminLinkGroups => '允许通过链接打开群组';

  @override
  String get adminLinkGroupsHelp => '群组所有者可以允许任何拥有链接的人无需登录即可加入。';

  @override
  String get adminSmtpHost => '邮件服务器';

  @override
  String get adminSmtpPort => '端口';

  @override
  String get adminSmtpUser => '用户名';

  @override
  String get adminSmtpPassword => '密码';

  @override
  String get adminSmtpFrom => '发件人';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => '客户端 ID';

  @override
  String get adminClientSecret => '客户端密钥';

  @override
  String get adminOidcIssuer => '签发方 URL';

  @override
  String get adminOidcName => '按钮名称';

  @override
  String get adminOidcNameHelp => '登录页面会显示为“使用……继续”。';

  @override
  String get adminFingerprints => '证书指纹';

  @override
  String get adminFingerprintsHelp =>
      '多个 SHA-256 指纹请用逗号分隔。可通过 keytool -list -v 和 apksigner verify --print-certs 查看。';

  @override
  String get adminInvalidValue => '此值无效。';

  @override
  String get adminInvalidUrl => '请输入以 https:// 或 http:// 开头的完整地址。';

  @override
  String get adminInvalidFrom => '请输入发件人，例如 Balnana <balnana@example.com>；必须包含邮箱地址。';

  @override
  String get adminInvalidPort => '请输入 1 到 65535 之间的端口号。';

  @override
  String get adminInvalidRequired => '此登录提供方必须填写此项。';

  @override
  String get adminInvalidFingerprint => '请输入 SHA-256 指纹：每个由 64 位十六进制数字组成，可使用冒号分隔。';

  @override
  String get adminNeedsSignIn => '账号需要登录方式：请启用邮箱和密码登录，或设置一个登录提供方。';

  @override
  String get adminLockedChange => '此项由服务器设置，无法在此更改。';

  @override
  String get errorAdminRequired => '管理员会话已结束。请重新登录。';

  @override
  String get errorAdminWrongPassword => '密码不正确。';

  @override
  String get errorInvalidSetupCode => '设置代码不正确。请在服务器日志中查找。';

  @override
  String get errorAlreadySetUp => '此服务器已完成设置。请使用管理员密码登录。';

  @override
  String get linkOpening => '正在打开链接…';

  @override
  String get linkForeignTitle => '此链接属于另一台服务器';

  @override
  String linkForeignBody(String server) {
    return '此应用当前连接到 $server，而此链接属于另一台服务器。请在设置中切换服务器后再打开。';
  }

  @override
  String get linkInvalidTitle => '无法打开此链接';

  @override
  String get linkInvalidBody => '此应用无法识别此 Balnana 链接。';

  @override
  String get linkGoHome => '前往群组';

  @override
  String get linkOpenInBrowser => '在浏览器中打开';

  @override
  String get privacyTitle => '隐私政策';

  @override
  String get privacyIntro => 'Balnana 是开源软件。此应用连接的服务器由其运营者管理，运营者决定数据的存储位置并对数据负责。本页面介绍软件本身会存储和处理哪些数据。';

  @override
  String get privacyStoredTitle => '存储的数据';

  @override
  String get privacyStoredBody =>
      '你创建或加入的群组：群组名称、成员姓名、支出、转账、备注、收据照片，以及你添加到支出中的地点。使用账号时，还会存储你的姓名、邮箱地址或用户名、密码的哈希值（绝不会存储密码本身），以及你使用的登录提供方（例如 Google）。如果启用了通知，还会存储设备标识符和推送服务提供的地址。';

  @override
  String get privacyUseTitle => '数据用途';

  @override
  String get privacyUseBody =>
      '数据仅用于运行应用：向群组成员展示群组、计算余额，以及发送应用所需的邮件和通知，例如邮箱验证、密码重设和群组邀请。应用没有广告或分析功能，也不会出售任何数据。';

  @override
  String get privacySharedTitle => '谁可以查看数据';

  @override
  String get privacySharedBody =>
      '群组中的所有人都可以查看成员、支出和历史记录。通过链接开放的群组，任何拥有链接的人都可以打开。使用 Google 登录时会通过 Google 处理；运营者启用通知后，通知会通过手机使用的推送服务发送：Google Firebase Cloud Messaging，或你安装的其他 UnifiedPush 服务，例如 ntfy。通知内容在传输过程中会加密。地图会从运营者选择的地图服务加载图片；默认使用 OpenFreeMap，除非运营者更改设置。地图服务会看到你的网络地址和你查看的区域。只有当你轻点“使用当前位置”时，应用才会读取你的位置，并且只会保存你随后确认的位置。';

  @override
  String get privacyDeviceTitle => '此设备上的数据';

  @override
  String get privacyDeviceBody => '应用会在此设备上保存服务器地址、你的设置和群组副本，以便离线使用。卸载应用会删除这些数据。';

  @override
  String get privacyDeleteTitle => '删除你的数据';

  @override
  String get privacyDeleteBody =>
      '你可以在设置中删除账号。删除后，你的姓名仍会作为无人认领的成员保留在群组中，以确保余额仍能正确计算；没有其他成员可以访问的群组也会一并删除。群组所有者可以在群组设置中删除整个群组。已删除的群组和已删除费用的照片会在 30 天后彻底清除。其他数据相关问题，请联系服务器运营者。';

  @override
  String get privacyOperatorPolicy => '运营者的隐私政策';

  @override
  String get privacyLink => '隐私';

  @override
  String get accountEmailAdd => '添加邮箱地址';

  @override
  String get accountEmailChange => '更改邮箱地址';

  @override
  String get accountEmailNew => '邮箱地址';

  @override
  String get accountEmailVerifyNote => '你会收到确认新邮箱的链接。在确认前，当前邮箱仍会保留。';

  @override
  String get accountEmailPendingTitle => '确认新邮箱';

  @override
  String accountEmailPendingHelp(String email) {
    return '打开发送到 $email 的链接后，新邮箱会替换当前邮箱。轻点可重新发送链接。';
  }

  @override
  String get accountEmailRemoveNote => '留空即可移除邮箱地址。你仍可使用用户名登录。';

  @override
  String get accountEmailSaved => '邮箱地址已保存';

  @override
  String get accountEmailRemoved => '邮箱地址已移除';

  @override
  String get accountConfirmPassword => '你的密码';

  @override
  String get accountConfirmPasswordHelp => '用于确认是你本人操作。';

  @override
  String get errorEmailNeeded => '你使用邮箱地址登录，因此无法移除该邮箱。';

  @override
  String get accountDelete => '删除账号';

  @override
  String get accountDeleteHelp => '从此服务器删除你的账号';

  @override
  String get accountDeleteTitle => '删除你的账号？';

  @override
  String get accountDeleteBody => '你的账号将被永久删除，你也会退出登录。你的姓名仍会作为无人认领的成员保留在群组中，以确保余额仍能正确计算。没有其他成员加入的群组将被删除。';

  @override
  String get accountDeleteAction => '永久删除';

  @override
  String get accountDeleted => '你的账号已删除。';

  @override
  String get accountDeletePageSignedOut => '登录后才能删除此服务器上的账号。';

  @override
  String get accountDeletePageLinkMode => '此服务器未启用账号：任何人只需群组链接即可访问。要连同群组中的所有内容一起删除群组，请打开群组设置并选择“删除群组”。';

  @override
  String get groupDelete => '删除群组';

  @override
  String get groupDeleteHelp => '为所有人删除群组及其中的所有支出';

  @override
  String groupDeleteTitle(String name) {
    return '删除“$name”？';
  }

  @override
  String get groupDeleteBody => '此群组及其所有支出、转账和历史记录都将为所有人删除。此操作无法撤销。请输入群组名称以确认。';

  @override
  String get groupDeleteName => '群组名称';

  @override
  String get groupDeleteAction => '永久删除';

  @override
  String get groupDeleted => '群组已删除';

  @override
  String get groupDeleteOwnerOnly => '只有群组所有者可以删除群组。';

  @override
  String get expenseDiscardTitle => '放弃更改？';

  @override
  String get expenseDiscardBody => '你对这笔支出所做的更改尚未保存。';

  @override
  String get expenseDiscard => '放弃';

  @override
  String get adminPrivacyUrl => '隐私政策链接';

  @override
  String get adminPrivacyUrlHelp => '应用商店要求提供隐私政策。留空时，应用会显示一份介绍 Balnana 存储内容的通用隐私政策。';

  @override
  String get adminMapTiles => '地图瓦片';

  @override
  String get adminMapSource => '地图来源';

  @override
  String get adminMapSourceStyle => '矢量样式';

  @override
  String get adminMapSourceStyleHelp => '使用 MapLibre 样式绘制地图，例如 OpenFreeMap 的样式。该服务免费且无需密钥。';

  @override
  String get adminMapSourceTiles => '栅格图块';

  @override
  String get adminMapSourceTilesHelp => '使用栅格地图瓦片图片显示地图，例如 OpenStreetMap。';

  @override
  String get adminMapSourceOff => '关闭';

  @override
  String get adminMapSourceOffHelp => '不显示地图。支出仍会保留地点名称和坐标。';

  @override
  String get adminMapStyle => '样式 URL';

  @override
  String get adminMapStyleHelp =>
      'MapLibre style.json 样式文件的地址，如 OpenFreeMap 的 Liberty（默认）、Bright 或 Positron。';

  @override
  String get adminMapTilesHelp =>
      '栅格地图瓦片的 URL 模板，需在大括号中包含 z、x 和 y，例如默认模板。OpenStreetMap 自有服务器仅供轻量使用；繁忙的服务器应使用瓦片服务提供商。';

  @override
  String get adminMapAttribution => '地图版权信息';

  @override
  String get adminMapAttributionHelp => '按照地图服务的要求显示在每张地图上。留空时，样式会显示其标注的版权信息，瓦片会标注 OpenStreetMap。';

  @override
  String get adminInvalidMapTiles => '请输入包含 z、x 和 y 占位符（大括号括起）的 http(s) URL 模板。';

  @override
  String get adminUsers => '账号';

  @override
  String get adminUsersSearch => '按姓名、邮箱或用户名搜索';

  @override
  String adminUsersShown(int shown, int total) {
    return '显示 $shown/$total 个账号';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count 个账号', one: '1 个账号');
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => '没有匹配的账号。';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个群组',
      one: '1 个群组',
      zero: '没有群组',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => '未验证';

  @override
  String adminUserDeleteTitle(String name) {
    return '删除 $name 的账号？';
  }

  @override
  String get adminUserDeleteBody => '账号将被永久删除，并在所有设备上退出登录。该成员会以无人认领的身份保留在其群组中；没有其他成员加入的群组将被删除。';

  @override
  String get adminUserDeleted => '账号已删除';

  @override
  String get commonDone => '完成';

  @override
  String get crowdSearch => '搜索成员';

  @override
  String get crowdNoMatch => '没有匹配的成员。';

  @override
  String get crowdAll => '全部';

  @override
  String get crowdNone => '无';

  @override
  String crowdChosen(int count, int total) {
    return '已选择 $count/$total 人';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '再显示 $count 人', one: '再显示 1 人');
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => '收起';

  @override
  String get crowdSort => '排序';

  @override
  String crowdShowAll(int count) {
    return '显示全部 $count 人';
  }

  @override
  String get crowdBalances => '所有人的余额';

  @override
  String get crowdSomeoneElse => '其他人';

  @override
  String get crowdChoosePayers => '选择付款人';

  @override
  String get crowdFilterTitle => '查看谁的支出？';

  @override
  String get myGroupsTitle => '我的群组链接';

  @override
  String get myGroupsExport => '导出我的群组链接';

  @override
  String get myGroupsExportHelp => '复制群组链接以备份，或转移到其他设备。';

  @override
  String get myGroupsPrivate => '请妥善保管这些链接。任何拥有链接的人都可以打开对应的群组。';

  @override
  String get myGroupsCopy => '复制链接';

  @override
  String get myGroupsImport => '导入群组';

  @override
  String get myGroupsImportHelp => '粘贴此服务器上的群组链接，每行一个。已有群组会保留原有位置和身份。';

  @override
  String get myGroupsLinks => '群组链接';

  @override
  String get myGroupsImportAction => '导入链接';

  @override
  String get myGroupsInvalid => '请输入有效的群组链接，每行一个。未导入任何内容。';

  @override
  String get myGroupsServerChanged => '所选服务器已更改。请关闭此对话框，并在链接所属的服务器上导入。';

  @override
  String myGroupsLimit(int count) {
    return '每台服务器最多保留 $count 个群组链接。未导入任何内容。';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导入 $count 个新的群组链接。',
      one: '已导入 1 个新的群组链接。',
      zero: '这些群组已保存。',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => '重复';

  @override
  String get repeatNever => '不重复';

  @override
  String get repeatDaily => '每天';

  @override
  String get repeatWeekly => '每周';

  @override
  String get repeatMonthly => '每月';

  @override
  String get repeatYearly => '每年';

  @override
  String get repeatEvery => '每隔';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '天', one: '天');
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '周', one: '周');
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '个月', one: '个月');
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '年', one: '年');
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '每 $count 天', one: '每天');
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '每 $count 周', one: '每周');
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '每 $count 个月', one: '每月');
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '每 $count 年', one: '每年');
    return '$_temp0';
  }

  @override
  String get repeatEndNone => '无结束日期';

  @override
  String repeatEndOn(String date) {
    return '截至 $date';
  }

  @override
  String get repeatEndClear => '移除结束日期';

  @override
  String get repeatHelp => '从上方日期开始，按设定日期自动添加到群组。保存时也会添加已经过去的日期。';

  @override
  String get repeatCustom => '自定义周期';

  @override
  String get repeatDropReceiptTitle => '移除收据？';

  @override
  String get repeatDropReceiptBody => '周期性支出无法保留收据。你可以为之后自动添加的每笔支出分别添加收据。';

  @override
  String get repeatDropReceiptAction => '设为重复';

  @override
  String get recurringTitle => '周期性支出';

  @override
  String get recurringHelp => '按计划自动添加的支出';

  @override
  String get recurringEmptyTitle => '没有周期性支出';

  @override
  String get recurringEmptyBody => '房租、订阅和其他定期开销都可以按日期自动添加。';

  @override
  String get recurringAdd => '添加周期性支出';

  @override
  String get recurringEdit => '编辑周期性支出';

  @override
  String recurringNext(String date) {
    return '下次添加：$date';
  }

  @override
  String get recurringPaused => '已暂停';

  @override
  String get recurringEnded => '已结束';

  @override
  String get recurringPause => '暂停';

  @override
  String get recurringResume => '恢复';

  @override
  String get recurringActive => '重复中';

  @override
  String get recurringDelete => '删除';

  @override
  String get recurringDeleteTitle => '停止重复？';

  @override
  String recurringDeleteBody(String title) {
    return '“$title”不会再被添加。已经添加的支出会保留。';
  }

  @override
  String get recurringDeleted => '周期性支出已删除';

  @override
  String get recurringFromSchedule => '由周期性支出添加';

  @override
  String get recurringOpen => '更改计划';

  @override
  String get recurringMissing => '周期性支出已删除或不再可用。';

  @override
  String get errorTooManyDue => '开始日期太早：一次会添加超过 100 笔支出。';

  @override
  String get errorInvalidEnd => '结束日期不能早于开始日期。';

  @override
  String get errorInvalidRepeat => '请设置每隔 1 至 999 天、周、月或年重复。';

  @override
  String get errorRecurringConflict => '你编辑期间，其他人修改了此周期性支出。重新加载以查看更改。';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$who 将“$title”设为重复支出';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$who 修改了周期性支出“$title”';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$who 暂停了周期性支出“$title”';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return '由于有成员离开群组，周期性支出“$title”已暂停';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return '由于无法添加，周期性支出“$title”已暂停';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$who 恢复了周期性支出“$title”';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$who 停止了周期性支出“$title”';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return '“$title”（$amount）已自动添加';
  }

  @override
  String get expenseRecurring => '由周期性支出添加';

  @override
  String get adminPlans => '方案';

  @override
  String get adminPayments => '付款记录';

  @override
  String get adminSectionBilling => '方案与付款';

  @override
  String get adminSectionBillingBody => '方案会提高此服务器保存内容的上限。分账和结清始终免费。';

  @override
  String get adminBillingOn => '方案与限制';

  @override
  String get adminBillingOnHelp => '关闭时，此服务器不做任何限制，也不显示方案。';

  @override
  String get adminBillingNeedsAccounts => '方案需要账号：请先将访问方式改为账号。';

  @override
  String get adminKofiUrl => 'Ko-fi 页面';

  @override
  String get adminKofiUrlHelp => '用户前往付款的页面。只有允许外部付款的版本才会链接到这里。';

  @override
  String adminKofiWebhook(String url) {
    return '请在 Ko-fi 填写此 Webhook 地址：$url';
  }

  @override
  String get adminKofiToken => 'Ko-fi 验证令牌';

  @override
  String get adminKofiTokenHelp => '显示在 Ko-fi 的 Webhook 页面。未设置时，此服务器会忽略 Ko-fi。';

  @override
  String adminUserPlanUntil(String plan, String date) {
    return '$plan，至 $date';
  }

  @override
  String get adminPlansHelp => '新的上限只影响之后添加的内容，已有内容会保留。留空表示没有上限。';

  @override
  String get adminPlanAdd => '添加方案';

  @override
  String adminPlanDefaultName(String name) {
    return '$name（默认）';
  }

  @override
  String adminPlanLimit(String label, String value) {
    return '$label：$value';
  }

  @override
  String adminPlanDays(int count) {
    return '天数：$count';
  }

  @override
  String get adminProductsSection => '商品';

  @override
  String get adminProductsHelp => '付款会先匹配同名的赞助等级；没有时，再匹配未填等级名称且金额达标的商品。';

  @override
  String get adminProductAdd => '添加商品';

  @override
  String get adminProductEdit => '编辑商品';

  @override
  String adminProductAnyPayment(String amount) {
    return '任何不低于 $amount 的付款';
  }

  @override
  String get adminProductName => '等级名称';

  @override
  String get adminProductNameHelp => '与 Ko-fi 上的名称相同。留空时，单次或每月付款都按金额匹配。';

  @override
  String get adminProductPlan => '方案';

  @override
  String get adminProductDays => '天数';

  @override
  String get adminProductDaysHelp => '一笔付款的有效天数。再次付款会接在剩余天数之后。';

  @override
  String get adminProductMinAmount => '最低金额';

  @override
  String get adminProductCurrency => '货币代码';

  @override
  String get adminPlanId => 'ID';

  @override
  String get adminPlanIdHelp => '小写英文字母、数字和连字符。之后无法更改。';

  @override
  String get adminPlanName => '名称';

  @override
  String get adminPlanRank => '优先级';

  @override
  String get adminPlanRankHelp => '账号有多个方案时，使用优先级最高的方案。';

  @override
  String get adminPlanDefault => '默认方案';

  @override
  String get adminPlanDefaultHelp => '用于没有其他方案的所有账号。';

  @override
  String adminPlanRemoveTitle(String name) {
    return '要移除 $name 吗？';
  }

  @override
  String adminPlanRemoveBody(String products) {
    return '其商品也会一并移除，且无法再购买：$products';
  }

  @override
  String get adminEntitlementGranted => '由管理员提供';

  @override
  String get adminEntitlementRevoked => '已撤销';

  @override
  String get adminEntitlementForever => '没有结束日期';

  @override
  String adminEntitlementUntil(String date) {
    return '至 $date';
  }

  @override
  String adminEntitlementEnded(String date) {
    return '已于 $date 结束';
  }

  @override
  String get adminEntitlementsEmpty => '此账号还没有方案。';

  @override
  String get adminEntitlementRevoke => '撤销';

  @override
  String adminEntitlementRevokeTitle(String plan) {
    return '要撤销 $plan 吗？';
  }

  @override
  String adminEntitlementRevokeBody(String user) {
    return '$user 会立即失去此方案，且无法恢复。';
  }

  @override
  String get adminEntitlementNote => '备注';

  @override
  String get adminEntitlementGrant => '提供方案';

  @override
  String get adminPaymentApplied => '已应用';

  @override
  String get adminPaymentUnclaimed => '待认领';

  @override
  String get adminPaymentUnmatched => '未匹配';

  @override
  String get adminPaymentsAll => '全部';

  @override
  String adminPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count 笔付款');
    return '$_temp0';
  }

  @override
  String get adminPaymentsEmpty => '这里没有付款记录。';

  @override
  String get adminPaymentAssigned => '方案已提供给账号。';

  @override
  String get adminPaymentAssign => '提供给账号';

  @override
  String get adminPaymentPickUser => '请选择账号。';

  @override
  String get errorBillingOff => '此服务器没有方案。';

  @override
  String get errorAlreadySponsored => '此群组已由其他成员的方案覆盖。';

  @override
  String get errorPlanInUse => '仍有账号或商品在使用此方案。';

  @override
  String get errorPaymentApplied => '这笔付款已经应用。';

  @override
  String get errorPaymentNotFound => '还没有这笔交易。如果刚付款，请过一分钟再试。';

  @override
  String get errorPaymentNoPlan => '这笔付款对应不到方案，请联系服务器管理员处理。';

  @override
  String get errorInvalidPlan => '请检查方案设置，其中有无效内容。';

  @override
  String errorLimitReceipts(int max) {
    return '此群组已达 $max 张收据照片的上限。';
  }

  @override
  String errorLimitRecurring(int max) {
    return '此群组已达 $max 笔周期性支出的上限。';
  }

  @override
  String errorLimitJoinedGroups(int max) {
    return '你已达 $max 个群组的上限。';
  }

  @override
  String errorLimitMembers(int max) {
    return '此群组已达 $max 人的上限。';
  }

  @override
  String errorLimitSponsored(int max) {
    return '你的方案最多只能共享给 $max 个群组。';
  }

  @override
  String get errorLimitOther => '你已达此服务器的上限。';

  @override
  String get planTitle => '方案';

  @override
  String get planUnlimited => '没有上限';

  @override
  String planUntil(String date) {
    return '至 $date';
  }

  @override
  String get planSettingsHelp => '此服务器为你保存的内容';

  @override
  String get planIntro => '分账和结清始终免费。方案只会改变此服务器能为你保存多少内容。';

  @override
  String planUsage(int used, int limit) {
    return '$used / $limit';
  }

  @override
  String planUsed(int used) {
    return '已使用 $used';
  }

  @override
  String get planLimits => '上限';

  @override
  String get planLimitReceipts => '每个群组的收据照片';

  @override
  String get planLimitRecurring => '每个群组的周期性支出';

  @override
  String get planLimitJoinedGroups => '你加入的群组';

  @override
  String get planLimitMembers => '每个群组的人数';

  @override
  String get planLimitSponsored => '共享你方案的群组';

  @override
  String get planGet => '获取方案';

  @override
  String get planKofi => 'Ko-fi';

  @override
  String get planKofiHelp => '请把付款代码粘贴到 Ko-fi 留言中，款项才会进入你的账号。';

  @override
  String get planPaymentCodeHelp => '你的付款代码，点按即可复制。';

  @override
  String get planPaymentCodeCopied => '已复制付款代码';

  @override
  String get planPaymentClaim => '忘记留代码？';

  @override
  String get planPaymentClaimHelp => '用 Ko-fi 的交易编号添加付款。';

  @override
  String get planPaymentClaimField => '交易编号或付款链接';

  @override
  String get planPaymentClaimAction => '添加付款';

  @override
  String get planPaymentClaimed => '已添加付款';

  @override
  String groupPlanUsage(String members, String receipts, String recurring) {
    return '人数：$members · 收据照片：$receipts · 周期性支出：$recurring';
  }

  @override
  String get groupSponsor => '与此群组共享我的方案';

  @override
  String get groupUnsponsor => '停止共享我的方案';

  @override
  String groupSponsoredBy(String name) {
    return '使用 $name 的方案';
  }

  @override
  String get accountDeletePlayNote => 'Google Play 订阅不会随账号一起结束，请先到 Google Play 取消。';

  @override
  String get planPlayManage => '管理订阅';

  @override
  String get planPlayManageHelp => '到 Google Play 更改或取消';

  @override
  String planPlayPrice(int months, String price) {
    String _temp0 = intl.Intl.pluralLogic(months, locale: localeName, other: '$months 个月', one: '月');
    return '每 $_temp0 $price';
  }

  @override
  String get planPlayFailed => 'Google Play 无法完成这笔购买。';

  @override
  String get planPlayPending => '付款仍在处理中，完成后方案才会开始。';

  @override
  String get planPlayOnHold => '上次付款失败。请到 Google Play 更新付款方式，以保留此方案。';

  @override
  String get planPlayHeldElsewhere => '这个 Google Play 账号已有订阅，可能属于另一个 Balnana 账号。';

  @override
  String get planPlayUnavailable => '无法连接 Google Play，请稍后再试。';

  @override
  String get errorInvalidPurchase => 'Google Play 查不到这笔购买。';

  @override
  String get errorPlayOtherAccount => '此订阅属于另一个账号。请登录该账号，或到 Google Play 取消。';

  @override
  String get errorPlayUnavailable => '无法连接 Google Play，请稍后再试。';

  @override
  String get adminPlayPackage => 'Google Play 软件包名称';

  @override
  String get adminPlayPackageHelp => '应用在 Google Play 上的 ID。与下方的服务账号一起设置后，即开启 Google Play 订阅。';

  @override
  String get adminPlayServiceAccount => 'Google Play 服务账号';

  @override
  String get adminPlayServiceAccountHelp => '服务账号的 JSON 密钥，需在 Play Console 中有查看和管理订单与订阅的权限。';

  @override
  String get adminPlayPushAccount => 'Pub/Sub 推送账号';

  @override
  String get adminPlayPushAccountHelp => 'Pub/Sub 用来签署推送的服务账号邮箱。未设置时，续订要等有人打开方案页才会收到。';

  @override
  String adminPlayWebhook(String url) {
    return 'Pub/Sub 推送端点，受众也填此网址：$url';
  }

  @override
  String get adminProductProvider => '付款方式';

  @override
  String get adminProductPlayId => '产品 ID';

  @override
  String get adminProductPlayIdHelp => '与 Play Console 中填写的相同。每笔付款的到期时间由 Google Play 决定，因此无需设置天数。';

  @override
  String get adminProductRemoveBody => '此商品的付款将不再计入账号。已持有的方案会保留到结束。';

  @override
  String get errorRecentSignIn => '为了安全，请先退出登录再重新登录，然后再试一次。';

  @override
  String get errorTooManyGroups => '一次的群组太多了。';

  @override
  String get errorInvalidTimeZone => '无法识别此设备的时区。';

  @override
  String get errorInvalidColor => '无法使用这个颜色。';

  @override
  String get errorPushOff => '此服务器不发送通知。';

  @override
  String paymentRecordedEarlier(String amount) {
    return '之前的尝试已记录 $amount，这次没有新增。';
  }

  @override
  String get refreshFailed => '无法更新，显示的内容可能不是最新的。';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get languageEndonym => '繁體中文';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => '取消';

  @override
  String get commonRetry => '重試';

  @override
  String get offlineBar => '目前離線。顯示此裝置儲存的內容；重新連線前無法儲存變更。';

  @override
  String get commonSave => '儲存';

  @override
  String get commonClear => '清除';

  @override
  String get iconChoose => '選擇圖示';

  @override
  String get iconNone => '沒有圖示';

  @override
  String get iconSearchHint => '搜尋，或輸入任何表情符號';

  @override
  String get iconUseTyped => '使用這個表情符號';

  @override
  String get iconNoMatch => '找不到符合的圖示。輸入表情符號即可使用。';

  @override
  String get iconSectionTravel => '旅遊與地點';

  @override
  String get iconSectionFood => '飲食';

  @override
  String get iconSectionActivities => '活動';

  @override
  String get iconSectionHome => '居家與帳單';

  @override
  String get iconSectionPeople => '人物';

  @override
  String get iconSectionNature => '動植物';

  @override
  String get iconSectionObjects => '金錢與物品';

  @override
  String get iconSectionSymbols => '符號';

  @override
  String get commonRemove => '移除';

  @override
  String get commonUndo => '復原';

  @override
  String get someone => '某人';

  @override
  String get errorTooLarge => '檔案太大，無法傳送至伺服器。';

  @override
  String get errorBusy => '伺服器目前忙碌，請稍後再試。';

  @override
  String get errorTimeout => '傳送時間過長。請檢查網路連線後再試一次。';

  @override
  String get errorBadOrigin => '伺服器不接受來自這個網址的登入。請伺服器管理者檢查公開網址。';

  @override
  String get errorInvalidCategory => '這個類別已被刪除，請選擇其他類別。';

  @override
  String get errorBuiltinCategory => '內建類別只能隱藏。';

  @override
  String get errorUnknownMember => '其中有人已不在群組內。重新載入後再試一次。';

  @override
  String get errorNoPayers => '選擇付款的人。';

  @override
  String get errorPayerTotal => '每個人支付的金額加總必須等於總額。';

  @override
  String get errorPayerTooSmall => '有人支付的部分換算成群組幣別後會變成零。請檢查金額。';

  @override
  String get errorInvalidNote => '備註太長，或含有無法儲存的字元。';

  @override
  String get errorInvalidDate => '日期超出允許範圍。';

  @override
  String get errorGeneric => '發生錯誤，請再試一次。';

  @override
  String get errorNetwork => '無法連線至伺服器。請檢查網路連線。';

  @override
  String get errorNotFound => '這個項目已不存在。';

  @override
  String get errorRequired => '必填';

  @override
  String get errorInvalidName => '請輸入不超過 100 個字元的名稱。';

  @override
  String get errorDuplicateName => '群組中已有同名的人。';

  @override
  String get errorTooManyMembers => '群組人數已達上限。';

  @override
  String get errorTooManyCategories => '群組類別數已達上限。';

  @override
  String get errorDuplicateCategory => '群組中已有同名類別。';

  @override
  String get errorInvalidCurrency => '請輸入三個字母的幣別代碼，例如 USD。';

  @override
  String get errorInvalidTitle => '請輸入不超過 200 個字元的標題。';

  @override
  String get errorInvalidLocation => '請輸入單行地點名稱，不超過 200 個字元。';

  @override
  String get errorInvalidSymbol => '請輸入不超過 8 個字元的符號。';

  @override
  String get errorInvalidEmoji => '請選擇一個表情符號作為圖示。';

  @override
  String get errorMemberHasBalance => '移除這個人前，請先結清他的餘額。';

  @override
  String get errorVersionConflict => '你編輯期間，其他人修改了這筆支出。重新載入以查看對方的變更。';

  @override
  String get errorSignInRequired => '請先登入才能進行這項操作。';

  @override
  String get errorRateLimited => '要求次數太多，請等一分鐘後再試。';

  @override
  String get errorNotAMember => '你還不是這個群組的成員。';

  @override
  String get errorNotAllowed => '只有這個人或群組擁有者能進行這項操作。';

  @override
  String get errorLinkGroupsOff => '這台伺服器不允許只透過連結開啟群組。';

  @override
  String get errorMemberClaimed => '已有人以這個身分加入。';

  @override
  String get errorMemberLeft => '群組中有人已離開。';

  @override
  String get errorInvalidEmail => '請輸入電子郵件地址。';

  @override
  String get errorInvalidPassword => '請使用 8 到 200 個字元。';

  @override
  String get errorEmailTaken => '這個電子郵件地址已有帳戶，請改為登入。';

  @override
  String get errorSignupClosed => '這台伺服器目前不接受新帳戶。';

  @override
  String get errorInvalidCredentials => '電子郵件地址與密碼不符。';

  @override
  String get errorWrongPassword => '目前的密碼不正確。';

  @override
  String get errorAccountsOff => '這台伺服器未使用帳戶。';

  @override
  String get errorInvalidAmount => '請輸入大於零的金額。';

  @override
  String get errorTooManyDecimals => '這個幣別的小數位數太多。';

  @override
  String get errorAmountTooLarge => '金額太大。';

  @override
  String get errorNoShares => '請至少選一人分攤費用。';

  @override
  String get errorInvalidShare => '每個份數都必須是數字。';

  @override
  String get errorExactTotal => '金額加總必須等於總額。';

  @override
  String get errorPayersTotal => '所有人支付的金額加總必須等於總額。';

  @override
  String get categoryFood => '飲食';

  @override
  String get categoryGroceries => '食品雜貨';

  @override
  String get categoryTransport => '交通';

  @override
  String get categoryTravel => '旅遊';

  @override
  String get categoryLodging => '住宿';

  @override
  String get categoryRent => '房租';

  @override
  String get categoryUtilities => '水電瓦斯';

  @override
  String get categoryEntertainment => '娛樂';

  @override
  String get categoryShopping => '購物';

  @override
  String get categoryHealth => '醫療';

  @override
  String get categoryGifts => '禮物';

  @override
  String get categoryOther => '其他';

  @override
  String get groupNew => '新增群組';

  @override
  String get groupSwitch => '切換群組';

  @override
  String get groupReorder => '拖曳以重新排序';

  @override
  String get groupCreate => '建立群組';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count 人', one: '1 人');
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return '你應收 $amount';
  }

  @override
  String pillOwe(String amount) {
    return '你欠 $amount';
  }

  @override
  String get pillSettled => '已結清';

  @override
  String get groupMissingTitle => '找不到群組';

  @override
  String get groupMissingBody => '這個群組已刪除，或連結已重設。請向群組中的人索取新連結。';

  @override
  String get groupLockedTitle => '登入以開啟這個群組';

  @override
  String get groupLockedBody => '只有群組成員的帳戶能開啟這個群組。請登入加入此群組的帳戶。';

  @override
  String get groupForget => '從這部裝置移除';

  @override
  String get groupLinkOtherServer => '這個連結屬於另一台伺服器。請連線至該伺服器以開啟。';

  @override
  String get openLinkTitle => '開啟群組連結';

  @override
  String get openLinkBody => '貼上別人分享給你的連結，即可加入對方的群組。';

  @override
  String get openLinkLabel => '群組連結';

  @override
  String get openLinkAction => '開啟';

  @override
  String get openLinkInvalid => '這看起來不像 Balnana 群組連結。';

  @override
  String get groupName => '群組名稱';

  @override
  String get groupNameHint => '里斯本之旅';

  @override
  String get groupCurrency => '幣別';

  @override
  String get groupCurrencyHelp => '這個群組的所有支出都會使用此幣別，之後無法變更。';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name。這個群組的所有支出都會使用此幣別，之後無法變更。';
  }

  @override
  String get currencyChoose => '選擇幣別';

  @override
  String get currencySearchHint => '依代碼或名稱搜尋';

  @override
  String get currencySuggested => '建議項目';

  @override
  String get currencyAll => '所有幣別';

  @override
  String currencyUseTyped(String code) {
    return '使用 $code';
  }

  @override
  String get currencyNoMatch => '找不到符合的幣別。輸入三個字母的代碼即可使用。';

  @override
  String get groupSymbol => '符號';

  @override
  String get groupSymbolChoose => '選擇符號';

  @override
  String groupSymbolExample(String example) {
    return '金額會顯示為 $example';
  }

  @override
  String get groupColor => '顏色';

  @override
  String colorSwatch(int number, int count) {
    return '第 $number 個顏色，共 $count 個';
  }

  @override
  String get groupPeople => '成員';

  @override
  String get groupYourName => '你的名稱';

  @override
  String groupPersonName(int number) {
    return '成員 $number';
  }

  @override
  String get groupAddPerson => '新增成員';

  @override
  String get groupPeopleHelp => '之後可以再新增成員，也可以讓他們透過連結加入。';

  @override
  String get identityTitle => '你是誰？';

  @override
  String get identityBody => '選擇你的名稱，Balnana 才能顯示你欠多少。只有這部裝置會記住你的選擇。';

  @override
  String get identityNew => '我是新加入的人';

  @override
  String get identityNewTitle => '加入這個群組';

  @override
  String get identityJoin => '加入';

  @override
  String get identityChange => '你的身分';

  @override
  String get identityNone => '尚未選擇';

  @override
  String get memberName => '名稱';

  @override
  String memberYou(String name) {
    return '$name（你）';
  }

  @override
  String get memberAdd => '新增成員';

  @override
  String get memberAddTitle => '新增成員';

  @override
  String get memberRename => '重新命名';

  @override
  String get memberRenameTitle => '重新命名';

  @override
  String memberRemoveTitle(String name) {
    return '要移除 $name 嗎？';
  }

  @override
  String get memberRemoveBody => '這個人的支出和餘額仍會保留在群組中。';

  @override
  String get groupLinkCopied => '已複製連結。任何人都能透過連結開啟這個群組。';

  @override
  String get groupShare => '分享連結';

  @override
  String get groupSettings => '群組設定';

  @override
  String get groupEdit => '編輯群組';

  @override
  String get groupSharing => '分享';

  @override
  String get groupCopyLink => '複製連結';

  @override
  String get groupQrCode => '顯示 QR code';

  @override
  String get groupQrCodeHelp => '讓大家用手機相機掃描連結。';

  @override
  String groupQrLabel(String group) {
    return '$group 的連結 QR code';
  }

  @override
  String get groupCopyLinkHelp => '任何人都能透過連結查看及編輯這個群組。';

  @override
  String get groupCopyLinkHelpAccounts => '取得連結的人登入後可以申請加入。';

  @override
  String get linkAccessTitle => '任何有連結的人都能開啟';

  @override
  String get linkAccessHelp => '讓大家不必建立帳戶也能查看及編輯';

  @override
  String get resetLinkTitle => '重設連結';

  @override
  String get resetLinkHelp => '建立新連結，舊連結將失效';

  @override
  String get resetLinkBody => '目前的連結將對所有人失效。請將新連結分享給需要繼續使用的人。';

  @override
  String get resetLinkAction => '重設';

  @override
  String get resetLinkDone => '連結已重設，請分享新連結。';

  @override
  String get groupThisDevice => '這部裝置';

  @override
  String get groupData => '資料';

  @override
  String get categoriesTitle => '類別';

  @override
  String get categoriesHelp => '新增自訂類別，或隱藏不使用的類別';

  @override
  String get categoriesOwn => '此群組的類別';

  @override
  String get categoriesOwnEmpty => '此群組尚無自訂類別。';

  @override
  String get categoriesBuiltIn => '內建類別';

  @override
  String get categoriesBuiltInHelp => '隱藏的類別不會用於新增支出，但已有該類別的支出會保留。';

  @override
  String get categoryAdd => '新增類別';

  @override
  String get categoryEdit => '編輯類別';

  @override
  String get categoryName => '名稱';

  @override
  String get categoryDelete => '刪除類別';

  @override
  String categoryDeleteTitle(String name) {
    return '要刪除 $name 嗎？';
  }

  @override
  String get categoryDeleteBody => '這個類別中的支出將不再有類別。';

  @override
  String get categoryDeleteAction => '刪除';

  @override
  String get exportCsv => '匯出為 CSV';

  @override
  String get exportCsvHelp => '匯出所有支出和款項，方便用試算表查看';

  @override
  String get exportCsvDone => '已匯出';

  @override
  String get forgetTitle => '從這部裝置移除';

  @override
  String get forgetHelp => '群組仍會保留在伺服器上，其他人也能繼續使用';

  @override
  String get forgetBody => '你可以之後透過連結重新開啟。';

  @override
  String get groupYou => '你';

  @override
  String get leaveTitle => '離開群組';

  @override
  String get leaveHelp => '你的支出會保留；你可以透過連結再次加入';

  @override
  String get leaveBody => '群組會從你的清單中移除。你的支出和餘額仍會保留在群組中。';

  @override
  String get leaveAction => '離開';

  @override
  String get tabExpenses => '支出';

  @override
  String get heroWhoTitle => '你是群組中的哪一位？';

  @override
  String get heroWhoBody => '選擇你的名稱，即可查看你欠款及應收的金額。';

  @override
  String get heroWhoAction => '選擇';

  @override
  String get heroJoinTitle => '你目前正在查看這個群組';

  @override
  String get heroJoinBody => '加入群組即可新增支出並查看你的欠款。';

  @override
  String get joinAction => '加入';

  @override
  String get heroOwed => '你應收';

  @override
  String get heroOwe => '你欠';

  @override
  String get heroSettled => '你已結清';

  @override
  String heroYouAre(String name) {
    return '你的身分是 $name';
  }

  @override
  String get expenseAdd => '新增支出';

  @override
  String get expensesEmptyTitle => '還沒有支出';

  @override
  String get expensesEmptyBody => '新增第一筆支出，Balnana 會幫你算出誰欠誰多少。';

  @override
  String get expensesSearchHint => '搜尋標題、備註和地點';

  @override
  String get searchClear => '清除搜尋';

  @override
  String get expensesNoMatchTitle => '找不到符合的項目';

  @override
  String get expensesNoMatchBody => '試試其他關鍵字，或減少篩選條件。';

  @override
  String get filterAnyone => '所有人';

  @override
  String get filterAnyCategory => '所有類別';

  @override
  String get filterPayments => '轉帳';

  @override
  String get filterClear => '清除篩選條件';

  @override
  String get periodAll => '不限時間';

  @override
  String get periodThisMonth => '本月';

  @override
  String get periodLastMonth => '上個月';

  @override
  String get periodThisYear => '今年';

  @override
  String get periodPickDays => '選擇日期…';

  @override
  String get statsTitle => '支出統計';

  @override
  String get statsTotal => '支出總額';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count 筆支出', one: '1 筆支出');
    return '$_temp0';
  }

  @override
  String get statsByCategory => '依類別';

  @override
  String get statsByMember => '每人支付及分攤金額';

  @override
  String get statsPaid => '已支付';

  @override
  String get statsShare => '分攤金額';

  @override
  String get statsByMonth => '依月份';

  @override
  String get statsNoCategory => '未分類';

  @override
  String get statsEmptyTitle => '尚無支出';

  @override
  String get statsEmptyBody => '這段期間沒有支出。';

  @override
  String get statsShowExpenses => '顯示這些支出';

  @override
  String get dateToday => '今天';

  @override
  String get dateYesterday => '昨天';

  @override
  String paymentTitle(String from, String to) {
    return '$from 轉帳給 $to';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name 支付了 $amount';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return '$count 人支付了 $amount';
  }

  @override
  String expensePaidByName(String name) {
    return '$name 已支付';
  }

  @override
  String expensePaidByManyNames(int count) {
    return '$count 人已支付';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name 收到 $amount';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$name 已收到';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return '$count 人已收到';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return '$count 人收到 $amount';
  }

  @override
  String get transactionRefund => '退款';

  @override
  String get transactionIncome => '收入';

  @override
  String get paymentDelete => '刪除轉帳';

  @override
  String get paymentDeleted => '已刪除轉帳';

  @override
  String expenseDeleted(String title) {
    return '已刪除「$title」';
  }

  @override
  String get expenseNew => '新增支出';

  @override
  String get expenseEdit => '編輯支出';

  @override
  String get expenseDelete => '刪除';

  @override
  String get expenseAmount => '金額';

  @override
  String get expenseTitle => '這筆支出是什麼？';

  @override
  String get expenseTitleHint => '晚餐、門票、計程車…';

  @override
  String get expenseAmountFromPayers => '所有人的支付金額總和';

  @override
  String expensePaidIn(String currency) {
    return '以 $currency 支付';
  }

  @override
  String expenseRate(String from, String to) {
    return '1 $from 換算為 $to';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return '以 $currency 計算的總額';
  }

  @override
  String expenseForeignHelp(String currency) {
    return '餘額會以 $currency 計算。輸入匯率或換算後的金額，例如信用卡帳單上的金額。';
  }

  @override
  String get expenseNote => '備註';

  @override
  String get expenseNoteHint => '選填';

  @override
  String get expenseLocation => '地點';

  @override
  String get expenseLocationHint => '在哪裡？（選填）';

  @override
  String get locationPickOnMap => '在地圖上選擇';

  @override
  String get locationUseCurrent => '使用目前位置';

  @override
  String get locationFinding => '正在尋找你的位置…';

  @override
  String get locationChange => '在地圖上變更';

  @override
  String get locationRemovePin => '移除圖釘';

  @override
  String get locationOpenInMaps => '在地圖中開啟';

  @override
  String get locationPickTitle => '選擇地點';

  @override
  String get locationPickHint => '點一下地圖即可放置圖釘';

  @override
  String get locationPickDone => '完成';

  @override
  String get locationDenied => 'Balnana 無法使用你的位置。你可以在裝置或瀏覽器設定中允許存取。';

  @override
  String get locationOff => '這部裝置已關閉定位功能。';

  @override
  String get locationUnavailable => '找不到你的位置。請再試一次，或在地圖上放置圖釘。';

  @override
  String get expenseReceipt => '收據';

  @override
  String get expenseHasReceipt => '有收據照片';

  @override
  String get expenseHasLocation => '有地點';

  @override
  String get receiptTakePhoto => '拍照';

  @override
  String get receiptChoose => '選擇圖片';

  @override
  String get receiptRemove => '移除';

  @override
  String get receiptView => '收據照片';

  @override
  String receiptNotSaved(String reason) {
    return '支出已儲存，但收據照片未儲存。$reason';
  }

  @override
  String get expensePaidByLabel => '付款人';

  @override
  String get expenseReceivedForLabel => '收款用途';

  @override
  String get expenseReceivedByLabel => '收款人';

  @override
  String get expenseMultiplePayers => '多人';

  @override
  String get expenseSplit => '分攤';

  @override
  String get splitEqual => '均分';

  @override
  String get splitExact => '金額';

  @override
  String get splitShares => '份數';

  @override
  String splitLeft(String amount) {
    return '還有 $amount 尚未分配';
  }

  @override
  String splitOver(String amount) {
    return '超出 $amount';
  }

  @override
  String get conflictTitle => '已在其他地方變更';

  @override
  String get conflictReload => '重新載入';

  @override
  String get expenseChangedElsewhere => '其他人已修改這筆支出。重新載入會顯示對方的版本，並捨棄你在此處的變更。';

  @override
  String get expenseNewerTitle => '由較新的版本建立';

  @override
  String get expenseNewerBody => '請更新 Balnana 後再修改這筆資料。';

  @override
  String get suggestedPayments => '建議轉帳方式';

  @override
  String get allSettled => '所有人都已結清。';

  @override
  String transferYouPay(String name) {
    return '你轉帳給 $name';
  }

  @override
  String transferPaysYou(String name) {
    return '$name 轉帳給你';
  }

  @override
  String transferPays(String from, String to) {
    return '$from 轉帳給 $to';
  }

  @override
  String get recordPayment => '記錄';

  @override
  String get recordPaymentTitle => '記錄轉帳';

  @override
  String get recordPaymentHelp => '只記錄實際已支付、且在 Balnana 之外完成的款項。';

  @override
  String get paymentRecorded => '已記錄轉帳';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who 建立了 $group';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who 修改了群組資訊';
  }

  @override
  String activityLinkReset(String who) {
    return '$who 重設了群組連結';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who 新增了 $name';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who 將 $oldName 重新命名為 $name';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who 移除了 $name';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who 新增了類別「$name」';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who 修改了類別';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who 刪除了類別「$name」';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name 加入了群組';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who 新增了「$title」（$amount）';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who 編輯了「$title」（$amount）';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who 刪除了「$title」';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who 還原了「$title」';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who 記錄了 $from 轉帳 $amount 給 $to';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who 刪除了一筆 $amount 的轉帳';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who 還原了一筆 $amount 的轉帳';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count 筆項目', one: '1 筆項目');
    return '$who 從 $source 匯入了 $_temp0';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who 為「$title」新增了收據照片';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who 移除了「$title」的收據照片';
  }

  @override
  String activityOther(String who) {
    return '$who 做了變更';
  }

  @override
  String get navGroups => '群組';

  @override
  String get navActivity => '動態';

  @override
  String get navSettings => '設定';

  @override
  String get groupsEmptyTitle => '尚無群組';

  @override
  String get groupsEmptyBody => '你建立或透過連結開啟的群組都會顯示在這裡。';

  @override
  String get groupsNoServerTitle => '連線至伺服器';

  @override
  String get groupsNoServerBody => 'Balnana 會將你的群組儲存在你選擇的伺服器上，例如自己架設的伺服器。';

  @override
  String get groupsNoServerAction => '選擇伺服器';

  @override
  String get groupsUnreachableTitle => '無法連線至伺服器';

  @override
  String get groupsUnreachableBody => '請檢查網路連線，或前往「設定」檢查伺服器網址。';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '無法載入 $count 個群組，因此缺少這些群組的動態。',
      one: '無法載入 1 個群組，因此缺少該群組的動態。',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => '目前沒有動態';

  @override
  String get activityEmptyBody => '群組中的新支出和轉帳會顯示在這裡。';

  @override
  String get notFoundTitle => '找不到頁面';

  @override
  String get notFoundBody => '這個網址無法開啟 Balnana 中的任何頁面。';

  @override
  String get notFoundAction => '前往群組';

  @override
  String get settingsAppearance => '外觀';

  @override
  String get settingsAccount => '帳戶';

  @override
  String get accountRename => '變更名稱';

  @override
  String get passwordChange => '變更密碼';

  @override
  String get passwordChanged => '密碼已變更，其他裝置已登出。';

  @override
  String get passwordSet => '設定密碼';

  @override
  String get passwordSetHelp => '也可以使用電子郵件或使用者名稱搭配密碼登入';

  @override
  String get passwordSetDone => '已設定密碼，其他裝置已登出。';

  @override
  String get passwordCurrent => '目前密碼';

  @override
  String get passwordNew => '新密碼';

  @override
  String get signOut => '登出';

  @override
  String get accountOAuthLinked => '可用來登入此帳戶。點一下即可移除。';

  @override
  String get accountOAuthAdd => '新增登入方式';

  @override
  String accountOAuthAddTitle(String name) {
    return '新增 $name';
  }

  @override
  String accountOAuthAdded(String name) {
    return '現在可以使用 $name 登入。';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return '要移除 $name 嗎？';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return '重新新增 $name 前，你將無法使用它登入。';
  }

  @override
  String get accountOAuthRemove => '移除';

  @override
  String accountOAuthRemoved(String name) {
    return '已移除 $name。';
  }

  @override
  String get confirmEmailTitle => '確認電子郵件';

  @override
  String confirmEmailBody(String email) {
    return '這台伺服器需要已確認的電子郵件地址。請開啟寄到 $email 的連結。';
  }

  @override
  String get confirmEmailDone => '我已確認';

  @override
  String get confirmEmailResend => '重新寄送連結';

  @override
  String get confirmEmailNotYet => '尚未確認。請開啟電子郵件中的連結。';

  @override
  String get settingsTheme => '主題';

  @override
  String get themeSystem => '依照系統';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get settingsDynamicColor => '桌布色彩';

  @override
  String get settingsDynamicColorSubtitle => '使用裝置的色彩，不使用 Balnana 黃色';

  @override
  String get settingsWallpaperGroups => '群組使用桌布色彩';

  @override
  String get settingsWallpaperGroupsSubtitle => '群組也使用裝置色彩，不使用群組自訂色彩';

  @override
  String get settingsPureBlack => '純黑色';

  @override
  String get settingsPureBlackSubtitle => '適合 OLED 螢幕的深色主題';

  @override
  String get settingsMyShare => '顯示我的分攤金額';

  @override
  String get settingsMyShareSubtitle => '支出會顯示你借出或借入的金額，而非總額';

  @override
  String get settingsLanguage => '語言';

  @override
  String get languageSystem => '依照系統';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotificationsSubtitle => '有人新增、修改或刪除你參與的支出時通知';

  @override
  String get settingsNotificationsBlocked => '已在手機設定中封鎖通知。請在手機設定中允許 Balnana 傳送通知。';

  @override
  String get pushChannel => '支出';

  @override
  String get pushChannelDescription => '有人新增、修改或刪除你參與的支出時通知';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who 新增了 $title · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who 修改了 $title · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who 刪除了 $title · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return '新增了 $title · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return '修改了 $title · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return '刪除了 $title · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payer 轉帳 $amount 給 $payee';
  }

  @override
  String get settingsConnection => '連線';

  @override
  String get settingsServer => '伺服器';

  @override
  String get serverNotSet => '尚未設定';

  @override
  String get settingsAbout => '關於';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutLicenses => '開放原始碼授權';

  @override
  String get aboutSource => '原始碼';

  @override
  String get aboutSourceCopied => '無法開啟瀏覽器，已複製連結';

  @override
  String get serverTitle => '伺服器';

  @override
  String get serverIntro => '輸入 Balnana 伺服器網址。任何人都能架設伺服器，網址通常就是開啟其網頁版的網址。';

  @override
  String get serverUrlLabel => '伺服器網址';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => '測試連線';

  @override
  String get serverSaveAnyway => '仍要儲存';

  @override
  String get serverReset => '使用預設值';

  @override
  String serverDefault(String url) {
    return '預設值：$url';
  }

  @override
  String serverConnected(String version) {
    return '已連線至 Balnana $version';
  }

  @override
  String get serverModeLink => '透過私人連結分享群組，不需要帳戶。';

  @override
  String get serverModeAccounts => '使用者透過帳戶登入。';

  @override
  String get serverInsecure => '這個網址未加密（http）。同一個網路上的任何人都可能讀取你的資料。若伺服器不在家用網路內，請使用 https。';

  @override
  String get serverErrorInvalid => '請輸入網址，例如 balnana.example.com';

  @override
  String get serverErrorUnreachable => '無法連線。請檢查網址和伺服器是否正在執行。';

  @override
  String get serverErrorNotBalnana => '有伺服器回應，但不是 Balnana 伺服器。';

  @override
  String get serverSaved => '已儲存伺服器';

  @override
  String get signIn => '登入';

  @override
  String get groupSignInTitle => '登入以開啟這個群組';

  @override
  String get groupSignInBody => '這個群組只開放給成員。登入即可查看或加入。';

  @override
  String get signInTitle => '歡迎回來';

  @override
  String get signInBody => '登入以查看你的群組。';

  @override
  String get signInNoPassword => '這台伺服器使用其他方式登入，請詢問伺服器管理者。';

  @override
  String get registerTitle => '建立帳戶';

  @override
  String get registerBody => '在所有裝置上使用你的群組。';

  @override
  String get registerAction => '建立帳戶';

  @override
  String get registerHaveAccount => '我已經有帳戶';

  @override
  String get signInNoAccount => '建立帳戶';

  @override
  String get accountName => '你的名稱';

  @override
  String get accountNameHelp => '群組中的其他人會看到這個名稱';

  @override
  String get accountEmail => '電子郵件';

  @override
  String get accountPassword => '密碼';

  @override
  String get accountPasswordHelp => '至少 8 個字元';

  @override
  String get passwordShow => '顯示密碼';

  @override
  String get passwordHide => '隱藏密碼';

  @override
  String get joinPickName => '選擇其他名稱';

  @override
  String joinTitle(String name) {
    return '加入 $name';
  }

  @override
  String get joinBody => '你是其中一位嗎？選擇你的身分即可接手對方的支出。';

  @override
  String get joinBodyNew => '加入群組即可新增支出並查看你的餘額。';

  @override
  String get joinAsNew => '我是新加入的人';

  @override
  String joinAsName(String name) {
    return '以 $name 的身分加入';
  }

  @override
  String joinTaken(String names) {
    return '已有人加入：$names';
  }

  @override
  String joinTakenCount(int count) {
    return '已有 $count 人加入。';
  }

  @override
  String get commonContinue => '繼續';

  @override
  String get errorEmailOff => '這台伺服器未設定寄送電子郵件。';

  @override
  String get errorInvalidToken => '這個連結已過期或使用過。';

  @override
  String get forgotPasswordTitle => '忘記密碼？';

  @override
  String get forgotPasswordBody => '我們會寄送連結給你，讓你設定新密碼。';

  @override
  String get forgotPasswordAction => '寄送連結';

  @override
  String get forgotPasswordSent => '如果這個地址有對應的帳戶，重設連結很快就會寄到。';

  @override
  String get resetPasswordTitle => '設定新密碼';

  @override
  String get resetPasswordBody => '你將在所有裝置上登出，之後可以使用新密碼登入。';

  @override
  String get resetPasswordAction => '儲存密碼';

  @override
  String get resetPasswordDone => '密碼已變更，請使用新密碼登入。';

  @override
  String get verifyEmailTitle => '確認電子郵件';

  @override
  String get verifyEmailHelp => '忘記密碼時可用來重設';

  @override
  String verifyEmailSent(String email) {
    return '請查看 $email，並開啟其中的連結。';
  }

  @override
  String get verifyEmailDone => '電子郵件已確認';

  @override
  String get verifyEmailDoneBody => '感謝你！電子郵件地址已確認。';

  @override
  String get verifyEmailFailed => '無法確認電子郵件';

  @override
  String get inviteByEmail => '透過電子郵件邀請';

  @override
  String get inviteByEmailHelp => '傳送加入連結給對方';

  @override
  String get inviteAs => '以此身分加入';

  @override
  String get inviteAsHelp => '對方可以接手這個人的支出';

  @override
  String get inviteAsAnyone => '新成員';

  @override
  String get inviteSend => '傳送邀請';

  @override
  String inviteSent(String email) {
    return '已將邀請寄送至 $email。';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name 邀請你加入 $group';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return '有人邀請你加入 $group';
  }

  @override
  String inviteBody(String email) {
    return '使用 $email 建立帳戶即可加入；如果你已有帳戶，請直接登入。';
  }

  @override
  String get inviteBodySignedIn => '加入群組即可新增支出並查看你的餘額。';

  @override
  String get inviteAction => '開啟邀請';

  @override
  String get inviteMissingTitle => '這個邀請無法使用';

  @override
  String get inviteMissingBody => '邀請可能已過期或使用過，請索取新的邀請。';

  @override
  String get joinInvitedAs => '你受邀以這個身分加入';

  @override
  String signInWith(String provider) {
    return '使用 $provider 繼續';
  }

  @override
  String get signInOr => '或';

  @override
  String get oauthFailedTitle => '無法登入';

  @override
  String get oauthPendingTitle => '這個電子郵件地址已有帳戶';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider 表示 $email 是你的地址，但這個地址的帳戶尚未確認。你想怎麼做？';
  }

  @override
  String get oauthPendingLink => '新增至該帳戶';

  @override
  String get oauthPendingLinkHelp => '輸入該帳戶的密碼。原密碼仍可使用。';

  @override
  String get oauthPendingTakeOver => '接管該帳戶';

  @override
  String get oauthPendingTakeOverHelp => '該帳戶的密碼和其他登入方式都會移除，所有已登入的裝置也會登出。';

  @override
  String get oauthPendingNew => '建立新帳戶';

  @override
  String oauthPendingNewHelp(String email) {
    return '另一個帳戶會保留群組，但不再使用 $email。';
  }

  @override
  String get oauthPendingPassword => '該帳戶的密碼';

  @override
  String get oauthPendingWrongPassword => '密碼不正確。';

  @override
  String get oauthOtherServer => '這次登入是在另一台伺服器上開始的，與目前選擇的伺服器不同。請重新登入。';

  @override
  String get oauthBackToSignIn => '返回登入';

  @override
  String get errorOAuthFailed => '登入失敗，請再試一次。';

  @override
  String get errorEmailHasAccount => '這個電子郵件地址已有帳戶。請先登入，再前往「設定」新增此登入方式。';

  @override
  String get errorIdentityTaken => '這個登入方式已連結到其他帳戶。';

  @override
  String get errorLastSignInMethod => '這是你唯一的登入方式。請先設定密碼或新增其他登入方式。';

  @override
  String get errorEmailUnverified => '請先確認電子郵件。';

  @override
  String get errorOAuthCancelled => '登入已取消。';

  @override
  String get importTitle => '從 Settle Up 匯入';

  @override
  String get importAction => '匯入';

  @override
  String get importIntro => '在 Settle Up 將群組匯出為 CSV 檔，再於此選取檔案。所有支出、轉帳和群組成員都會匯入，餘額也會維持不變。';

  @override
  String get importChooseFile => '選擇 CSV 檔';

  @override
  String get importChooseOther => '選擇其他檔案';

  @override
  String get importReading => '正在讀取檔案…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(expenses, locale: localeName, other: '$expenses 筆支出', one: '1 筆支出');
    String _temp1 = intl.Intl.pluralLogic(payments, locale: localeName, other: '$payments 筆轉帳', one: '1 筆轉帳');
    return '$_temp0、$_temp1';
  }

  @override
  String importDates(String from, String to) {
    return '$from 至 $to';
  }

  @override
  String importCurrency(String currency) {
    return '幣別：$currency。其他幣別的項目會使用 Settle Up 換算後的金額。';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆金額為零的項目。',
      one: '1 筆金額為零的項目。',
    );
    return '已略過 $_temp0';
  }

  @override
  String get importWhoAreYou => '你是哪一位？';

  @override
  String get importUntitled => '未命名';

  @override
  String get errorImportFile => '這看起來不像 Settle Up 匯出的 CSV 檔。';

  @override
  String get errorImportCurrency => '檔案中沒有未使用匯率的項目，因此無法判斷群組幣別。';

  @override
  String get errorImportTooBig => '檔案太大，無法匯入。';

  @override
  String get errorBadImage => '無法使用這張圖片。請選擇 JPEG、PNG 或 WebP 圖片。';

  @override
  String get errorReceiptTooBig => '圖片太大。請選擇小於 10 MB 的圖片。';

  @override
  String get errorImportMe => '請選擇你是哪一位。';

  @override
  String errorImportRow(int line, String reason) {
    return '檔案第 $line 行無法匯入：$reason';
  }

  @override
  String get errorImportAmount => '無法讀取金額。';

  @override
  String get errorImportCounts => '名稱和金額數量不一致。';

  @override
  String get errorImportDate => '無法讀取日期。';

  @override
  String get errorImportType => '類型必須是支出、轉帳或收入。';

  @override
  String get errorImportTransfer => '轉帳必須由一人付給另一人。';

  @override
  String get errorImportRowCurrency => '此項目使用其他幣別，且沒有匯率。';

  @override
  String get adminSetupTitle => '設定這台伺服器';

  @override
  String get adminSetupBody => '為管理員設定密碼。密碼可保護這個管理頁面，伺服器設定都在這裡。沒有使用者名稱，知道密碼的人都能修改設定。';

  @override
  String get adminSetupCode => '設定代碼';

  @override
  String get adminSetupCodeHelp => '這台伺服器已有資料，因此啟動時會在記錄檔中輸出設定代碼。使用 Docker 時，請執行：docker compose logs balnana';

  @override
  String get adminSetupAction => '設定密碼';

  @override
  String get adminPassword => '管理員密碼';

  @override
  String get adminPasswordRepeat => '再次輸入密碼';

  @override
  String get adminPasswordMismatch => '兩次輸入的密碼不相符。';

  @override
  String get adminLoginTitle => '管理';

  @override
  String get adminLoginBody => '輸入管理員密碼以修改伺服器設定。';

  @override
  String get adminLoginAction => '登入';

  @override
  String get adminSettingsTitle => '伺服器設定';

  @override
  String get adminSaved => '設定已儲存並立即套用。';

  @override
  String get adminSaveFailed => '沒有儲存任何設定。請檢查標示的設定。';

  @override
  String get adminChangePassword => '變更管理員密碼';

  @override
  String get adminPasswordCurrent => '目前密碼';

  @override
  String get adminPasswordNew => '新密碼';

  @override
  String get adminPasswordChanged => '密碼已變更，其他管理員工作階段已登出。';

  @override
  String get adminSignOut => '登出管理頁面';

  @override
  String get adminBackHome => '返回 Balnana';

  @override
  String get adminRequireEmail => '必須提供電子郵件地址';

  @override
  String get adminRequireEmailHelp => '關閉時，使用者可以只用使用者名稱註冊，也可以不填電子郵件地址。登入時可使用其中一項。';

  @override
  String get adminRequireEmailUnused => '僅適用於已關閉的電子郵件與密碼登入。';

  @override
  String get accountUsername => '使用者名稱';

  @override
  String get accountUsernameHelp => '使用 3 到 32 個英文字母、數字、句點、連字號或底線。登入時使用此名稱。';

  @override
  String get accountEmailOptional => '電子郵件（選填）';

  @override
  String get accountEmailOptionalHelp => '用於接收群組邀請和重設忘記的密碼。';

  @override
  String get accountLogin => '電子郵件或使用者名稱';

  @override
  String get errorInvalidUsername => '請使用 3 到 32 個英文字母、數字、句點、連字號或底線，並以英文字母或數字開頭。';

  @override
  String get errorUsernameTaken => '這個使用者名稱已有人使用。';

  @override
  String get adminDiscardTitle => '要捨棄變更嗎？';

  @override
  String get adminDiscardBody => '你對設定所做的變更尚未儲存。';

  @override
  String get adminDiscard => '捨棄';

  @override
  String adminLocked(String key) {
    return '由伺服器上的 $key 設定';
  }

  @override
  String adminDefault(String value) {
    return '預設值：$value';
  }

  @override
  String get adminSecretSaved => '已儲存。輸入新值即可取代。';

  @override
  String get adminSecretRemoved => '儲存時將會移除。';

  @override
  String get adminSecretRemove => '移除已儲存的值';

  @override
  String get adminSectionGeneral => '一般';

  @override
  String get adminSectionAccess => '存取權限';

  @override
  String get adminSectionMaps => '地圖';

  @override
  String get adminSectionAccounts => '帳戶';

  @override
  String get adminSectionAccountsBody => '使用帳戶模式時會套用這些設定。';

  @override
  String get adminSectionEmail => '電子郵件（SMTP）';

  @override
  String get adminSectionEmailBody => '地址驗證、密碼重設和邀請。';

  @override
  String get adminSmtpOn => '寄送電子郵件';

  @override
  String get adminSectionGoogle => '使用 Google 登入';

  @override
  String adminSectionGoogleBody(String url) {
    return '請在 Google Cloud 控制台將 $url 設為重新導向 URI。';
  }

  @override
  String get adminGoogleOn => '提供 Google 登入';

  @override
  String get adminGoogleOnHelp => '使用者可以透過 Google 帳戶登入。';

  @override
  String get adminSectionOidc => '使用 OpenID Connect 登入';

  @override
  String adminSectionOidcBody(String url) {
    return '請在登入服務提供者中將 $url 設為重新導向 URI。';
  }

  @override
  String get adminOidcHelp => '支援任何 OpenID Connect 提供者，例如 Authentik、Keycloak 或 Dex。可新增多個提供者。';

  @override
  String get adminOidcAdd => '新增提供者';

  @override
  String get adminOidcRemove => '移除提供者';

  @override
  String get adminOidcNew => '新增提供者';

  @override
  String get adminOidcId => '識別碼';

  @override
  String get adminOidcIdHelp => '使用小寫英文字母、數字和連字號。這是重新導向 URI 的一部分，之後無法變更。';

  @override
  String get adminOidcIdInvalid => '請使用小寫英文字母、數字和連字號，最多 32 個字元，並以英文字母或數字開頭。';

  @override
  String get adminOidcIdTaken => '另一個提供者已使用這個 ID。';

  @override
  String get adminTrustEmail => '信任其電子郵件';

  @override
  String get adminGoogleTrustEmailHelp => '若 Google 登入的電子郵件已有帳戶，會直接登入該帳戶。關閉時，使用者需輸入密碼登入，並在「設定」中新增 Google。';

  @override
  String get adminOidcTrustEmailHelp => '只適用於你管理或信任其電子郵件驗證機制的提供者。關閉時，已有帳戶的使用者需輸入密碼登入，並在「設定」中新增該登入方式。';

  @override
  String get adminRequireVerified => '必須確認電子郵件';

  @override
  String get adminRequireVerifiedHelp => '帳戶必須先確認電子郵件才能使用應用程式；受信任的登入方式若使用相同地址，會接管未確認的帳戶。關閉時，使用者可自行選擇如何處理。';

  @override
  String get adminRequireVerifiedUnused => '需要啟用電子郵件寄送功能。';

  @override
  String get adminSectionAndroid => 'Android 應用程式連結';

  @override
  String get adminSectionAndroidBody => '為這台伺服器製作的 Android 版本會在應用程式中開啟其連結。若要略過詢問，請列出這些版本簽署憑證的 SHA-256 指紋。';

  @override
  String get adminSectionAdmin => '管理員';

  @override
  String get adminPublicUrl => '公開網址';

  @override
  String get adminPublicUrlHelp => '使用者連線至伺服器的網址。群組連結和電子郵件連結會使用此網址建立。';

  @override
  String get adminSourceUrl => '原始碼連結';

  @override
  String get adminSourceUrlHelp => '使用者取得此伺服器原始碼的網址。若你執行修改過的版本，授權條款（AGPL-3.0）要求提供此連結。';

  @override
  String get adminAuthMode => '存取方式';

  @override
  String get adminAuthModeLink => '群組連結';

  @override
  String get adminAuthModeLinkHelp => '不需登入，只要群組的私人連結即可使用。';

  @override
  String get adminAuthModeAccounts => '帳戶';

  @override
  String get adminAuthModeAccountsHelp => '使用者需登入，只有已登入的使用者才能透過連結加入群組。';

  @override
  String get adminPasswordLogin => '電子郵件和密碼登入';

  @override
  String get adminPasswordForced => '在啟用 Google 或 OpenID Connect 登入前會保持開啟，確保使用者一定能登入。';

  @override
  String get adminSignup => '誰可以建立帳戶';

  @override
  String get adminSignupOpen => '任何人';

  @override
  String get adminSignupOpenHelp => '任何能連線至此伺服器的人都能註冊。';

  @override
  String get adminSignupInvite => '受邀者';

  @override
  String get adminSignupInviteHelp => '只有透過電子郵件受邀加入群組的人能註冊，且只能使用邀請寄送的地址。單靠群組連結無法加入。必須啟用電子郵件寄送功能。';

  @override
  String get adminSignupClosed => '沒有人';

  @override
  String get adminSignupClosedHelp => '不允許任何人註冊，現有帳戶仍可使用。';

  @override
  String get adminSignupHelp => '一律允許建立第一個帳戶。';

  @override
  String get adminLinkGroups => '允許透過連結開啟群組';

  @override
  String get adminLinkGroupsHelp => '群組擁有者可以允許任何取得連結的人加入，無需登入。';

  @override
  String get adminSmtpHost => '郵件伺服器';

  @override
  String get adminSmtpPort => '連接埠';

  @override
  String get adminSmtpUser => '使用者名稱';

  @override
  String get adminSmtpPassword => '密碼';

  @override
  String get adminSmtpFrom => '寄件者';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => '用戶端 ID';

  @override
  String get adminClientSecret => '用戶端密鑰';

  @override
  String get adminOidcIssuer => '簽發者 URL';

  @override
  String get adminOidcName => '按鈕名稱';

  @override
  String get adminOidcNameHelp => '在登入頁面顯示為「使用……繼續」。';

  @override
  String get adminFingerprints => '憑證指紋';

  @override
  String get adminFingerprintsHelp =>
      'SHA-256 指紋以逗號分隔。可用 keytool -list -v 和 apksigner verify --print-certs 查看。';

  @override
  String get adminInvalidValue => '此值無效。';

  @override
  String get adminInvalidUrl => '請輸入完整網址，並以 https:// 或 http:// 開頭。';

  @override
  String get adminInvalidFrom => '請輸入寄件者，例如 Balnana <balnana@example.com>；內容必須包含電子郵件地址。';

  @override
  String get adminInvalidPort => '請輸入 1 到 65535 之間的連接埠號碼。';

  @override
  String get adminInvalidRequired => '此登入提供者需要這項設定。';

  @override
  String get adminInvalidFingerprint => '請輸入 SHA-256 指紋：每個指紋為 64 位十六進位數字，可使用冒號分隔。';

  @override
  String get adminNeedsSignIn => '帳戶必須有登入方式：請啟用電子郵件和密碼，或設定登入提供者。';

  @override
  String get adminLockedChange => '此設定由伺服器設定，無法在這裡變更。';

  @override
  String get errorAdminRequired => '管理員工作階段已結束，請重新登入。';

  @override
  String get errorAdminWrongPassword => '密碼不正確。';

  @override
  String get errorInvalidSetupCode => '設定代碼不正確，請查看伺服器記錄檔。';

  @override
  String get errorAlreadySetUp => '這台伺服器已完成設定，請使用管理員密碼登入。';

  @override
  String get linkOpening => '正在開啟連結…';

  @override
  String get linkForeignTitle => '這個連結屬於另一台伺服器';

  @override
  String linkForeignBody(String server) {
    return '此應用程式目前連線至 $server，但這個連結屬於另一台伺服器。請前往「設定」切換伺服器以開啟連結。';
  }

  @override
  String get linkInvalidTitle => '無法開啟這個連結';

  @override
  String get linkInvalidBody => '這不是此應用程式支援的 Balnana 連結。';

  @override
  String get linkGoHome => '前往群組';

  @override
  String get linkOpenInBrowser => '在瀏覽器中開啟';

  @override
  String get privacyTitle => '隱私權政策';

  @override
  String get privacyIntro => 'Balnana 是開放原始碼軟體。此應用程式連線伺服器的管理者（營運者）會決定資料的儲存位置，並負責管理資料。本頁說明軟體本身會儲存什麼資料，以及如何使用。';

  @override
  String get privacyStoredTitle => '儲存的資料';

  @override
  String get privacyStoredBody =>
      '你建立或加入的群組：群組名稱、成員名稱、支出、轉帳、備註、收據照片，以及你新增到支出中的地點。若使用帳戶，也會儲存你的名稱、電子郵件地址或使用者名稱、密碼雜湊（不會儲存密碼本身），以及你使用的登入提供者，例如 Google。若開啟通知，也會儲存裝置識別碼和推播服務提供的地址。';

  @override
  String get privacyUseTitle => '資料用途';

  @override
  String get privacyUseBody =>
      '資料只用於提供應用程式功能：向群組成員顯示群組、計算餘額，以及寄送應用程式所需的電子郵件和通知，例如地址驗證、密碼重設和邀請。應用程式沒有廣告或分析功能，也不會販售任何資料。';

  @override
  String get privacySharedTitle => '誰能查看資料';

  @override
  String get privacySharedBody =>
      '群組中的所有人都能查看成員、支出和動態。若群組開放透過連結存取，任何取得連結的人都能開啟群組。使用 Google 登入時會連線至 Google；管理者啟用通知後，通知會透過手機使用的推播服務傳送：Google Firebase Cloud Messaging，或你安裝的其他 UnifiedPush 服務，例如 ntfy。通知內容在傳送途中會加密。地圖會從管理者選擇的地圖服務載入圖片，預設為 OpenFreeMap，除非管理者另行設定。地圖服務會看到你的網路位址和你查看的區域。只有在你點選「使用目前位置」時，應用程式才會讀取你的位置，並且只會儲存你接著選定的地點。';

  @override
  String get privacyDeviceTitle => '這部裝置上的資料';

  @override
  String get privacyDeviceBody => '應用程式會在此裝置儲存伺服器網址、你的設定，以及一份群組資料副本，供離線時使用。解除安裝應用程式會移除這些資料。';

  @override
  String get privacyDeleteTitle => '刪除資料';

  @override
  String get privacyDeleteBody =>
      '你可以在「設定」中刪除帳戶。刪除後，你的名稱仍會保留在群組中，成為無人認領的成員，讓餘額繼續正確計算；其他人都無法存取的群組也會一併刪除。群組擁有者可以在群組設定中刪除整個群組。已刪除的群組和已刪除費用的照片會在 30 天後徹底清除。其他資料刪除需求請聯絡伺服器管理者。';

  @override
  String get privacyOperatorPolicy => '管理者的隱私權政策';

  @override
  String get privacyLink => '隱私權';

  @override
  String get accountEmailAdd => '新增電子郵件地址';

  @override
  String get accountEmailChange => '變更電子郵件地址';

  @override
  String get accountEmailNew => '電子郵件地址';

  @override
  String get accountEmailVerifyNote => '你會收到確認新地址的連結。在確認前，仍會使用目前的地址。';

  @override
  String get accountEmailPendingTitle => '確認新的電子郵件';

  @override
  String accountEmailPendingHelp(String email) {
    return '開啟寄至 $email 的連結後，這個地址就會取代目前的地址。點一下即可重新寄送。';
  }

  @override
  String get accountEmailRemoveNote => '留空即可移除地址。你仍可使用使用者名稱登入。';

  @override
  String get accountEmailSaved => '已儲存電子郵件地址';

  @override
  String get accountEmailRemoved => '已移除電子郵件地址';

  @override
  String get accountConfirmPassword => '你的密碼';

  @override
  String get accountConfirmPasswordHelp => '用來確認是你本人。';

  @override
  String get errorEmailNeeded => '你使用電子郵件地址登入，因此無法移除。';

  @override
  String get accountDelete => '刪除帳戶';

  @override
  String get accountDeleteHelp => '從這台伺服器移除你的帳戶';

  @override
  String get accountDeleteTitle => '要刪除帳戶嗎？';

  @override
  String get accountDeleteBody => '你的帳戶將永久刪除，並且會登出。在群組中，你的名稱仍會保留為無人認領的成員，讓餘額繼續正確計算。沒有其他人的群組會被刪除。';

  @override
  String get accountDeleteAction => '永久刪除';

  @override
  String get accountDeleted => '你的帳戶已刪除。';

  @override
  String get accountDeletePageSignedOut => '請登入以刪除你在這台伺服器上的帳戶。';

  @override
  String get accountDeletePageLinkMode => '這台伺服器沒有帳戶：任何人只要有群組連結就能加入。若要刪除包含所有資料的群組，請開啟群組設定並選擇「刪除群組」。';

  @override
  String get groupDelete => '刪除群組';

  @override
  String get groupDeleteHelp => '為所有人刪除群組及其中所有支出';

  @override
  String groupDeleteTitle(String name) {
    return '要刪除 $name 嗎？';
  }

  @override
  String get groupDeleteBody => '群組及其中所有支出、轉帳和動態都會為所有人刪除，且無法復原。請輸入群組名稱以確認。';

  @override
  String get groupDeleteName => '群組名稱';

  @override
  String get groupDeleteAction => '永久刪除';

  @override
  String get groupDeleted => '群組已刪除';

  @override
  String get groupDeleteOwnerOnly => '只有群組擁有者能刪除群組。';

  @override
  String get expenseDiscardTitle => '要捨棄變更嗎？';

  @override
  String get expenseDiscardBody => '你對這筆支出所做的變更尚未儲存。';

  @override
  String get expenseDiscard => '捨棄';

  @override
  String get adminPrivacyUrl => '隱私權政策連結';

  @override
  String get adminPrivacyUrlHelp => '這是應用程式商店要求提供的隱私權政策。留空時，應用程式會顯示 Balnana 資料儲存方式的一般說明。';

  @override
  String get adminMapTiles => '地圖圖磚';

  @override
  String get adminMapSource => '地圖來源';

  @override
  String get adminMapSourceStyle => '向量樣式';

  @override
  String get adminMapSourceStyleHelp => '使用 MapLibre 樣式繪製的地圖，例如免費且不需金鑰的 OpenFreeMap。';

  @override
  String get adminMapSourceTiles => '點陣圖磚';

  @override
  String get adminMapSourceTilesHelp => '使用地圖圖磚圖片顯示的地圖，例如 OpenStreetMap。';

  @override
  String get adminMapSourceOff => '關閉';

  @override
  String get adminMapSourceOffHelp => '不顯示地圖，但支出仍會保留地點名稱和座標。';

  @override
  String get adminMapStyle => '樣式 URL';

  @override
  String get adminMapStyleHelp => 'MapLibre style.json 的網址，例如 OpenFreeMap 的 Liberty（預設）、Bright 或 Positron。';

  @override
  String get adminMapTilesHelp =>
      '點陣圖磚 URL 範本，需在大括號中包含 z、x 和 y，例如預設範本。OpenStreetMap 自有伺服器僅供少量使用；流量大的伺服器應使用地圖圖磚服務提供者。';

  @override
  String get adminMapAttribution => '地圖來源標示';

  @override
  String get adminMapAttributionHelp => '依地圖服務提供者的要求顯示於每張地圖。留空時，樣式會顯示其指定的來源標示，圖磚則會標示 OpenStreetMap。';

  @override
  String get adminInvalidMapTiles => '請輸入包含 z、x 和 y 大括號欄位的 http(s) URL 範本。';

  @override
  String get adminUsers => '帳戶';

  @override
  String get adminUsersSearch => '依名稱、電子郵件或使用者名稱搜尋';

  @override
  String adminUsersShown(int shown, int total) {
    return '共 $total 個帳戶，顯示 $shown 個';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count 個帳戶', one: '1 個帳戶');
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => '找不到符合的帳戶。';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個群組',
      one: '1 個群組',
      zero: '沒有群組',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => '未驗證';

  @override
  String adminUserDeleteTitle(String name) {
    return '要刪除 $name 的帳戶嗎？';
  }

  @override
  String get adminUserDeleteBody => '帳戶將永久刪除，並在所有地方登出。此人的名稱仍會保留在群組中，成為無人認領的成員；沒有其他人的群組則會被刪除。';

  @override
  String get adminUserDeleted => '帳戶已刪除';

  @override
  String get commonDone => '完成';

  @override
  String get crowdSearch => '搜尋成員';

  @override
  String get crowdNoMatch => '找不到符合的人。';

  @override
  String get crowdAll => '全部';

  @override
  String get crowdNone => '無';

  @override
  String crowdChosen(int count, int total) {
    return '已選 $count 人，共 $total 人';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '再顯示 $count 人', one: '再顯示 1 人');
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => '顯示較少';

  @override
  String get crowdSort => '排序';

  @override
  String crowdShowAll(int count) {
    return '顯示全部 $count 人';
  }

  @override
  String get crowdBalances => '所有人的餘額';

  @override
  String get crowdSomeoneElse => '其他人';

  @override
  String get crowdChoosePayers => '選擇付款人';

  @override
  String get crowdFilterTitle => '要看誰的支出？';

  @override
  String get myGroupsTitle => '我的群組連結';

  @override
  String get myGroupsExport => '匯出我的群組';

  @override
  String get myGroupsExportHelp => '複製群組連結以備份，或移至其他裝置。';

  @override
  String get myGroupsPrivate => '請妥善保管這些連結。任何有連結的人都能開啟對應的群組。';

  @override
  String get myGroupsCopy => '複製連結';

  @override
  String get myGroupsImport => '匯入群組';

  @override
  String get myGroupsImportHelp => '貼上這台伺服器的群組連結，每行一個。現有群組的位置和身分會保留。';

  @override
  String get myGroupsLinks => '群組連結';

  @override
  String get myGroupsImportAction => '匯入連結';

  @override
  String get myGroupsInvalid => '請輸入有效的群組連結，每行一個。沒有匯入任何項目。';

  @override
  String get myGroupsServerChanged => '所選伺服器已變更。請關閉此對話框，並在連結所屬的伺服器匯入。';

  @override
  String myGroupsLimit(int count) {
    return '每台伺服器最多保留 $count 個群組連結。沒有匯入任何項目。';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已匯入 $count 個新的群組連結。',
      one: '已匯入 1 個新的群組連結。',
      zero: '這些群組已儲存。',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => '重複';

  @override
  String get repeatNever => '不重複';

  @override
  String get repeatDaily => '每天';

  @override
  String get repeatWeekly => '每週';

  @override
  String get repeatMonthly => '每月';

  @override
  String get repeatYearly => '每年';

  @override
  String get repeatEvery => '每隔';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '天', one: '天');
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '週', one: '週');
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '個月', one: '個月');
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '年', one: '年');
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '每 $count 天', one: '每天');
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '每 $count 週', one: '每週');
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '每 $count 個月', one: '每月');
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '每 $count 年', one: '每年');
    return '$_temp0';
  }

  @override
  String get repeatEndNone => '沒有結束日期';

  @override
  String repeatEndOn(String date) {
    return '直到 $date';
  }

  @override
  String get repeatEndClear => '移除結束日期';

  @override
  String get repeatHelp => '從上方日期開始，在每個指定日期自動新增至群組。儲存時也會新增已過去日期的支出。';

  @override
  String get repeatCustom => '自訂週期';

  @override
  String get repeatDropReceiptTitle => '要移除收據嗎？';

  @override
  String get repeatDropReceiptBody => '定期支出無法保留收據。之後可以為自動新增的每筆支出各自新增收據。';

  @override
  String get repeatDropReceiptAction => '設為重複';

  @override
  String get recurringTitle => '定期支出';

  @override
  String get recurringHelp => '依排程自動新增的支出';

  @override
  String get recurringEmptyTitle => '沒有定期支出';

  @override
  String get recurringEmptyBody => '房租、訂閱和其他固定費用都可以設定為在指定日期自動新增。';

  @override
  String get recurringAdd => '新增定期支出';

  @override
  String get recurringEdit => '編輯定期支出';

  @override
  String recurringNext(String date) {
    return '下次新增日期：$date';
  }

  @override
  String get recurringPaused => '已暫停';

  @override
  String get recurringEnded => '已結束';

  @override
  String get recurringPause => '暫停';

  @override
  String get recurringResume => '繼續';

  @override
  String get recurringActive => '重複';

  @override
  String get recurringDelete => '刪除';

  @override
  String get recurringDeleteTitle => '停止重複？';

  @override
  String recurringDeleteBody(String title) {
    return '「$title」不會再新增。已新增的支出會保留。';
  }

  @override
  String get recurringDeleted => '已刪除定期支出';

  @override
  String get recurringFromSchedule => '由定期支出新增';

  @override
  String get recurringOpen => '變更排程';

  @override
  String get recurringMissing => '定期支出已刪除或無法再使用。';

  @override
  String get errorTooManyDue => '開始日期太早，一次會新增超過 100 筆支出。';

  @override
  String get errorInvalidEnd => '結束日期不能早於開始日期。';

  @override
  String get errorInvalidRepeat => '請設定每 1 到 999 天、週、月或年重複一次。';

  @override
  String get errorRecurringConflict => '你編輯期間，其他人修改了這筆定期支出。重新載入以查看對方的變更。';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$who 將「$title」設為重複';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$who 修改了定期支出「$title」';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$who 暫停了定期支出「$title」';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return '因為群組中有人離開，定期支出「$title」已暫停';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return '因為無法新增支出，定期支出「$title」已暫停';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$who 恢復了定期支出「$title」';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$who 停止重複定期支出「$title」';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return '已自動新增「$title」（$amount）';
  }

  @override
  String get expenseRecurring => '由定期支出新增';

  @override
  String get adminPlans => '方案';

  @override
  String get adminPayments => '付款紀錄';

  @override
  String get adminSectionBilling => '方案與付款';

  @override
  String get adminSectionBillingBody => '方案會提高這台伺服器保存內容的上限。分帳和結清永遠免費。';

  @override
  String get adminBillingOn => '方案與限制';

  @override
  String get adminBillingOnHelp => '關閉時，這台伺服器不做任何限制，也不顯示方案。';

  @override
  String get adminBillingNeedsAccounts => '方案需要帳戶：請先把存取方式改為帳戶。';

  @override
  String get adminKofiUrl => 'Ko-fi 頁面';

  @override
  String get adminKofiUrlHelp => '使用者前往付款的頁面。只有允許外部付款的版本才會連到這裡。';

  @override
  String adminKofiWebhook(String url) {
    return '請在 Ko-fi 填入這個 Webhook 網址：$url';
  }

  @override
  String get adminKofiToken => 'Ko-fi 驗證權杖';

  @override
  String get adminKofiTokenHelp => '顯示在 Ko-fi 的 Webhook 頁面。沒有設定時，這台伺服器會忽略 Ko-fi。';

  @override
  String adminUserPlanUntil(String plan, String date) {
    return '$plan，到 $date';
  }

  @override
  String get adminPlansHelp => '新的上限只影響之後新增的內容，已有的內容會保留。留白代表沒有上限。';

  @override
  String get adminPlanAdd => '新增方案';

  @override
  String adminPlanDefaultName(String name) {
    return '$name（預設）';
  }

  @override
  String adminPlanLimit(String label, String value) {
    return '$label：$value';
  }

  @override
  String adminPlanDays(int count) {
    return '天數：$count';
  }

  @override
  String get adminProductsSection => '商品';

  @override
  String get adminProductsHelp => '付款會先對應同名的贊助等級；沒有時，再對應未填等級名稱且金額達標的商品。';

  @override
  String get adminProductAdd => '新增商品';

  @override
  String get adminProductEdit => '編輯商品';

  @override
  String adminProductAnyPayment(String amount) {
    return '任何至少 $amount 的付款';
  }

  @override
  String get adminProductName => '等級名稱';

  @override
  String get adminProductNameHelp => '與 Ko-fi 上的名稱相同。留白時，單次或每月付款都依金額對應。';

  @override
  String get adminProductPlan => '方案';

  @override
  String get adminProductDays => '天數';

  @override
  String get adminProductDaysHelp => '一筆付款的有效天數。再次付款會接在剩餘天數之後。';

  @override
  String get adminProductMinAmount => '最低金額';

  @override
  String get adminProductCurrency => '貨幣代碼';

  @override
  String get adminPlanId => 'ID';

  @override
  String get adminPlanIdHelp => '小寫英文字母、數字和連字號。之後無法變更。';

  @override
  String get adminPlanName => '名稱';

  @override
  String get adminPlanRank => '順位';

  @override
  String get adminPlanRankHelp => '帳戶有多個方案時，採用順位最高的方案。';

  @override
  String get adminPlanDefault => '預設方案';

  @override
  String get adminPlanDefaultHelp => '用於沒有其他方案的所有帳戶。';

  @override
  String adminPlanRemoveTitle(String name) {
    return '要移除 $name 嗎？';
  }

  @override
  String adminPlanRemoveBody(String products) {
    return '它的商品也會一併移除，且無法再購買：$products';
  }

  @override
  String get adminEntitlementGranted => '由管理員提供';

  @override
  String get adminEntitlementRevoked => '已撤銷';

  @override
  String get adminEntitlementForever => '沒有結束日期';

  @override
  String adminEntitlementUntil(String date) {
    return '到 $date';
  }

  @override
  String adminEntitlementEnded(String date) {
    return '已於 $date 結束';
  }

  @override
  String get adminEntitlementsEmpty => '這個帳戶還沒有方案。';

  @override
  String get adminEntitlementRevoke => '撤銷';

  @override
  String adminEntitlementRevokeTitle(String plan) {
    return '要撤銷 $plan 嗎？';
  }

  @override
  String adminEntitlementRevokeBody(String user) {
    return '$user 會立即失去這個方案，且無法復原。';
  }

  @override
  String get adminEntitlementNote => '備註';

  @override
  String get adminEntitlementGrant => '提供方案';

  @override
  String get adminPaymentApplied => '已套用';

  @override
  String get adminPaymentUnclaimed => '待認領';

  @override
  String get adminPaymentUnmatched => '未對應';

  @override
  String get adminPaymentsAll => '全部';

  @override
  String adminPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count 筆付款');
    return '$_temp0';
  }

  @override
  String get adminPaymentsEmpty => '這裡沒有付款紀錄。';

  @override
  String get adminPaymentAssigned => '方案已提供給帳戶。';

  @override
  String get adminPaymentAssign => '提供給帳戶';

  @override
  String get adminPaymentPickUser => '請選擇帳戶。';

  @override
  String get errorBillingOff => '這台伺服器沒有方案。';

  @override
  String get errorAlreadySponsored => '這個群組已由其他成員的方案涵蓋。';

  @override
  String get errorPlanInUse => '仍有帳戶或商品在使用這個方案。';

  @override
  String get errorPaymentApplied => '這筆付款已經套用。';

  @override
  String get errorPaymentNotFound => '還沒有這筆交易。如果剛付款，請過一分鐘再試。';

  @override
  String get errorPaymentNoPlan => '這筆付款對不到方案，請聯絡伺服器管理員處理。';

  @override
  String get errorInvalidPlan => '請檢查方案設定，其中有無效的內容。';

  @override
  String errorLimitReceipts(int max) {
    return '這個群組已達 $max 張收據照片的上限。';
  }

  @override
  String errorLimitRecurring(int max) {
    return '這個群組已達 $max 筆定期支出的上限。';
  }

  @override
  String errorLimitJoinedGroups(int max) {
    return '你已達 $max 個群組的上限。';
  }

  @override
  String errorLimitMembers(int max) {
    return '此群組已達 $max 人的上限。';
  }

  @override
  String errorLimitSponsored(int max) {
    return '你的方案最多只能分享給 $max 個群組。';
  }

  @override
  String get errorLimitOther => '你已達這台伺服器的上限。';

  @override
  String get planTitle => '方案';

  @override
  String get planUnlimited => '沒有上限';

  @override
  String planUntil(String date) {
    return '到 $date';
  }

  @override
  String get planSettingsHelp => '這台伺服器為你保存的內容';

  @override
  String get planIntro => '分帳和結清永遠免費。方案只會改變這台伺服器能為你保存多少內容。';

  @override
  String planUsage(int used, int limit) {
    return '$used / $limit';
  }

  @override
  String planUsed(int used) {
    return '已使用 $used';
  }

  @override
  String get planLimits => '上限';

  @override
  String get planLimitReceipts => '每個群組的收據照片';

  @override
  String get planLimitRecurring => '每個群組的定期支出';

  @override
  String get planLimitJoinedGroups => '你加入的群組';

  @override
  String get planLimitMembers => '每個群組的人數';

  @override
  String get planLimitSponsored => '分享你方案的群組';

  @override
  String get planGet => '取得方案';

  @override
  String get planKofi => 'Ko-fi';

  @override
  String get planKofiHelp => '請把付款代碼貼到 Ko-fi 留言，款項才會進到你的帳號。';

  @override
  String get planPaymentCodeHelp => '你的付款代碼，點一下複製。';

  @override
  String get planPaymentCodeCopied => '已複製付款代碼';

  @override
  String get planPaymentClaim => '忘記留代碼？';

  @override
  String get planPaymentClaimHelp => '用 Ko-fi 的交易編號加入付款。';

  @override
  String get planPaymentClaimField => '交易編號或付款連結';

  @override
  String get planPaymentClaimAction => '加入付款';

  @override
  String get planPaymentClaimed => '已加入付款';

  @override
  String groupPlanUsage(String members, String receipts, String recurring) {
    return '人數：$members · 收據照片：$receipts · 定期支出：$recurring';
  }

  @override
  String get groupSponsor => '與這個群組分享我的方案';

  @override
  String get groupUnsponsor => '停止分享我的方案';

  @override
  String groupSponsoredBy(String name) {
    return '使用 $name 的方案';
  }

  @override
  String get accountDeletePlayNote => 'Google Play 訂閱不會隨帳號一起結束，請先到 Google Play 取消。';

  @override
  String get planPlayManage => '管理訂閱';

  @override
  String get planPlayManageHelp => '到 Google Play 變更或取消';

  @override
  String planPlayPrice(int months, String price) {
    String _temp0 = intl.Intl.pluralLogic(months, locale: localeName, other: '$months 個月', one: '月');
    return '每 $_temp0 $price';
  }

  @override
  String get planPlayFailed => 'Google Play 無法完成這筆購買。';

  @override
  String get planPlayPending => '付款仍在處理中，完成後方案才會開始。';

  @override
  String get planPlayOnHold => '上次付款失敗。請到 Google Play 更新付款方式，以保留這個方案。';

  @override
  String get planPlayHeldElsewhere => '這個 Google Play 帳號已有訂閱，可能屬於另一個 Balnana 帳號。';

  @override
  String get planPlayUnavailable => '無法連到 Google Play，請稍後再試。';

  @override
  String get errorInvalidPurchase => 'Google Play 查無這筆購買。';

  @override
  String get errorPlayOtherAccount => '這份訂閱屬於另一個帳號。請登入該帳號，或到 Google Play 取消。';

  @override
  String get errorPlayUnavailable => '無法連上 Google Play，請稍後再試。';

  @override
  String get adminPlayPackage => 'Google Play 套件名稱';

  @override
  String get adminPlayPackageHelp => 'App 在 Google Play 上的 ID。與下方的服務帳號一起設定後，就會開啟 Google Play 訂閱。';

  @override
  String get adminPlayServiceAccount => 'Google Play 服務帳號';

  @override
  String get adminPlayServiceAccountHelp => '服務帳號的 JSON 金鑰，需在 Play Console 有檢視及管理訂單與訂閱的權限。';

  @override
  String get adminPlayPushAccount => 'Pub/Sub 推送帳號';

  @override
  String get adminPlayPushAccountHelp => 'Pub/Sub 用來簽署推送的服務帳號 email。沒有設定時，續訂要等有人開啟方案頁才會收到。';

  @override
  String adminPlayWebhook(String url) {
    return 'Pub/Sub 推送端點，目標對象也填這個網址：$url';
  }

  @override
  String get adminProductProvider => '付款方式';

  @override
  String get adminProductPlayId => '產品 ID';

  @override
  String get adminProductPlayIdHelp => '與 Play Console 上寫的相同。每筆付款到何時由 Google Play 決定，所以不用設定天數。';

  @override
  String get adminProductRemoveBody => '這個商品的付款將不再計入帳號。已持有的方案會保留到結束。';

  @override
  String get errorRecentSignIn => '為了安全，請先登出再重新登入，然後再試一次。';

  @override
  String get errorTooManyGroups => '一次的群組太多了。';

  @override
  String get errorInvalidTimeZone => '無法辨識此裝置的時區。';

  @override
  String get errorInvalidColor => '無法使用這個顏色。';

  @override
  String get errorPushOff => '此伺服器不傳送通知。';

  @override
  String paymentRecordedEarlier(String amount) {
    return '之前的嘗試已記錄 $amount，這次沒有新增。';
  }

  @override
  String get refreshFailed => '無法更新，顯示的內容可能不是最新的。';
}
