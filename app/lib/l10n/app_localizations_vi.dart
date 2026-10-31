// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get languageEndonym => 'Tiếng Việt';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get offlineBar =>
      'Đang ngoại tuyến. Đang hiển thị dữ liệu đã lưu trên thiết bị này; bạn chưa thể lưu thay đổi cho đến khi kết nối lại.';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonClear => 'Xóa';

  @override
  String get iconChoose => 'Chọn biểu tượng';

  @override
  String get iconNone => 'Không có biểu tượng';

  @override
  String get iconSearchHint => 'Tìm kiếm hoặc nhập emoji bất kỳ';

  @override
  String get iconUseTyped => 'Dùng emoji này';

  @override
  String get iconNoMatch => 'Không tìm thấy biểu tượng phù hợp. Nhập emoji để dùng.';

  @override
  String get iconSectionTravel => 'Du lịch và địa điểm';

  @override
  String get iconSectionFood => 'Đồ ăn và thức uống';

  @override
  String get iconSectionActivities => 'Hoạt động';

  @override
  String get iconSectionHome => 'Nhà cửa và hóa đơn';

  @override
  String get iconSectionPeople => 'Mọi người';

  @override
  String get iconSectionNature => 'Động vật và thiên nhiên';

  @override
  String get iconSectionObjects => 'Tiền và đồ vật';

  @override
  String get iconSectionSymbols => 'Ký hiệu';

  @override
  String get commonRemove => 'Gỡ';

  @override
  String get commonUndo => 'Hoàn tác';

  @override
  String get someone => 'Ai đó';

  @override
  String get errorTooLarge => 'Mục này quá lớn để gửi lên máy chủ.';

  @override
  String get errorBusy => 'Máy chủ đang bận. Vui lòng thử lại sau ít phút.';

  @override
  String get errorTimeout => 'Gửi mất quá nhiều thời gian. Kiểm tra kết nối rồi thử lại.';

  @override
  String get errorBadOrigin =>
      'Máy chủ không chấp nhận đăng nhập từ địa chỉ này. Người quản lý máy chủ nên kiểm tra URL công khai.';

  @override
  String get errorInvalidCategory => 'Danh mục đó đã bị xóa. Hãy chọn danh mục khác.';

  @override
  String get errorBuiltinCategory => 'Chỉ có thể ẩn danh mục có sẵn.';

  @override
  String get errorUnknownMember =>
      'Một người trong khoản chi này không còn ở trong nhóm. Tải lại rồi thử lại.';

  @override
  String get errorNoPayers => 'Chọn người đã trả tiền.';

  @override
  String get errorPayerTotal => 'Tổng số tiền mỗi người đã trả phải bằng số tiền của khoản chi.';

  @override
  String get errorPayerTooSmall =>
      'Phần tiền một người đã trả được quy đổi thành 0 theo tiền tệ của nhóm. Hãy kiểm tra số tiền.';

  @override
  String get errorInvalidNote => 'Ghi chú quá dài hoặc có ký tự không thể lưu.';

  @override
  String get errorInvalidDate => 'Ngày này nằm ngoài phạm vi cho phép.';

  @override
  String get errorGeneric => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get errorNetwork => 'Không thể kết nối với máy chủ. Hãy kiểm tra kết nối.';

  @override
  String get errorNotFound => 'Nội dung này không còn tồn tại.';

  @override
  String get errorRequired => 'Bắt buộc';

  @override
  String get errorInvalidName => 'Nhập tên không quá 100 ký tự.';

  @override
  String get errorDuplicateName => 'Đã có người trong nhóm này dùng tên đó.';

  @override
  String get errorTooManyMembers => 'Nhóm đã đủ số người tối đa.';

  @override
  String get errorTooManyCategories => 'Nhóm đã đủ số danh mục tối đa.';

  @override
  String get errorDuplicateCategory => 'Nhóm đã có danh mục tên đó.';

  @override
  String get errorInvalidCurrency => 'Nhập mã tiền tệ gồm 3 chữ cái, ví dụ USD.';

  @override
  String get errorInvalidTitle => 'Nhập tiêu đề không quá 200 ký tự.';

  @override
  String get errorInvalidLocation => 'Nhập tên địa điểm trên một dòng, không quá 200 ký tự.';

  @override
  String get errorInvalidSymbol => 'Nhập ký hiệu không quá 8 ký tự.';

  @override
  String get errorInvalidEmoji => 'Chọn một emoji làm biểu tượng.';

  @override
  String get errorMemberHasBalance => 'Hãy thanh toán hết số dư của người này trước khi xóa họ.';

  @override
  String get errorVersionConflict =>
      'Có người khác đã sửa khoản chi này khi bạn đang chỉnh sửa. Tải lại để xem thay đổi của họ.';

  @override
  String get errorSignInRequired => 'Đăng nhập để thực hiện việc này.';

  @override
  String get errorRateLimited => 'Bạn đã gửi quá nhiều yêu cầu. Đợi một phút rồi thử lại.';

  @override
  String get errorNotAMember => 'Bạn chưa tham gia nhóm này.';

  @override
  String get errorNotAllowed => 'Chỉ người đó hoặc chủ nhóm mới có thể làm việc này.';

  @override
  String get errorLinkGroupsOff => 'Máy chủ này không cho phép mở nhóm chỉ bằng liên kết.';

  @override
  String get errorMemberClaimed => 'Đã có người tham gia với tư cách thành viên này.';

  @override
  String get errorMemberLeft => 'Một người trong nhóm này đã rời nhóm.';

  @override
  String get errorInvalidEmail => 'Nhập địa chỉ email.';

  @override
  String get errorInvalidPassword => 'Dùng từ 8 đến 200 ký tự.';

  @override
  String get errorEmailTaken => 'Đã có tài khoản dùng email này. Hãy đăng nhập.';

  @override
  String get errorSignupClosed => 'Máy chủ này không nhận đăng ký tài khoản mới.';

  @override
  String get errorInvalidCredentials => 'Email và mật khẩu không khớp.';

  @override
  String get errorWrongPassword => 'Mật khẩu hiện tại không đúng.';

  @override
  String get errorAccountsOff => 'Máy chủ này không dùng tài khoản.';

  @override
  String get errorInvalidAmount => 'Nhập số tiền lớn hơn 0.';

  @override
  String get errorTooManyDecimals => 'Số chữ số thập phân vượt mức cho phép của tiền tệ này.';

  @override
  String get errorAmountTooLarge => 'Số tiền này quá lớn.';

  @override
  String get errorNoShares => 'Chọn ít nhất một người để chia khoản chi.';

  @override
  String get errorInvalidShare => 'Mỗi phần chia phải là một con số.';

  @override
  String get errorExactTotal => 'Tổng các khoản tiền phải bằng tổng cộng.';

  @override
  String get errorPayersTotal => 'Tổng số tiền mọi người đã trả phải bằng tổng cộng.';

  @override
  String get categoryFood => 'Đồ ăn và thức uống';

  @override
  String get categoryGroceries => 'Thực phẩm';

  @override
  String get categoryTransport => 'Đi lại';

  @override
  String get categoryTravel => 'Du lịch';

  @override
  String get categoryLodging => 'Chỗ ở';

  @override
  String get categoryRent => 'Tiền thuê nhà';

  @override
  String get categoryUtilities => 'Điện nước';

  @override
  String get categoryEntertainment => 'Giải trí';

  @override
  String get categoryShopping => 'Mua sắm';

  @override
  String get categoryHealth => 'Sức khỏe';

  @override
  String get categoryGifts => 'Quà tặng';

  @override
  String get categoryOther => 'Khác';

  @override
  String get groupNew => 'Nhóm mới';

  @override
  String get groupSwitch => 'Chuyển nhóm';

  @override
  String get groupReorder => 'Kéo để sắp xếp lại';

  @override
  String get groupCreate => 'Tạo nhóm';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count người', one: '1 người');
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return 'Bạn được nhận $amount';
  }

  @override
  String pillOwe(String amount) {
    return 'Bạn nợ $amount';
  }

  @override
  String get pillSettled => 'Đã thanh toán xong';

  @override
  String get groupMissingTitle => 'Không tìm thấy nhóm';

  @override
  String get groupMissingBody =>
      'Nhóm này đã bị xóa hoặc liên kết đã được đặt lại. Hãy hỏi người trong nhóm để xin liên kết mới.';

  @override
  String get groupLockedTitle => 'Đăng nhập để mở nhóm này';

  @override
  String get groupLockedBody =>
      'Chỉ tài khoản thành viên mới mở được nhóm này. Hãy đăng nhập vào tài khoản thuộc nhóm.';

  @override
  String get groupForget => 'Gỡ khỏi thiết bị này';

  @override
  String get groupLinkOtherServer => 'Liên kết này thuộc máy chủ khác. Hãy kết nối với máy chủ đó để mở.';

  @override
  String get openLinkTitle => 'Mở liên kết nhóm';

  @override
  String get openLinkBody => 'Dán liên kết ai đó đã chia sẻ với bạn để tham gia nhóm của họ.';

  @override
  String get openLinkLabel => 'Liên kết nhóm';

  @override
  String get openLinkAction => 'Mở';

  @override
  String get openLinkInvalid => 'Liên kết này có vẻ không phải liên kết nhóm Balnana.';

  @override
  String get groupName => 'Tên nhóm';

  @override
  String get groupNameHint => 'Chuyến đi Lisbon';

  @override
  String get groupCurrency => 'Tiền tệ';

  @override
  String get groupCurrencyHelp => 'Tất cả khoản chi trong nhóm này dùng tiền tệ này. Sau này không thể đổi.';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name. Tất cả khoản chi trong nhóm này dùng tiền tệ này. Sau này không thể đổi.';
  }

  @override
  String get currencyChoose => 'Chọn tiền tệ';

  @override
  String get currencySearchHint => 'Tìm theo mã hoặc tên';

  @override
  String get currencySuggested => 'Đề xuất';

  @override
  String get currencyAll => 'Tất cả tiền tệ';

  @override
  String currencyUseTyped(String code) {
    return 'Dùng $code';
  }

  @override
  String get currencyNoMatch => 'Không tìm thấy tiền tệ phù hợp. Nhập mã gồm 3 chữ cái để dùng.';

  @override
  String get groupSymbol => 'Ký hiệu';

  @override
  String get groupSymbolChoose => 'Chọn ký hiệu';

  @override
  String groupSymbolExample(String example) {
    return 'Số tiền sẽ hiển thị như $example';
  }

  @override
  String get groupColor => 'Màu';

  @override
  String colorSwatch(int number, int count) {
    return 'Màu số $number trong $count';
  }

  @override
  String get groupPeople => 'Mọi người';

  @override
  String get groupYourName => 'Tên bạn';

  @override
  String groupPersonName(int number) {
    return 'Người $number';
  }

  @override
  String get groupAddPerson => 'Thêm người';

  @override
  String get groupPeopleHelp => 'Bạn có thể thêm người sau, hoặc họ có thể tham gia bằng liên kết.';

  @override
  String get identityTitle => 'Bạn là ai?';

  @override
  String get identityBody =>
      'Chọn tên của bạn để Balnana hiển thị khoản bạn nợ. Chỉ thiết bị này ghi nhớ tên bạn.';

  @override
  String get identityNew => 'Tôi là người mới';

  @override
  String get identityNewTitle => 'Tham gia nhóm này';

  @override
  String get identityJoin => 'Tham gia';

  @override
  String get identityChange => 'Bạn là ai';

  @override
  String get identityNone => 'Chưa chọn';

  @override
  String get memberName => 'Tên';

  @override
  String memberYou(String name) {
    return '$name (bạn)';
  }

  @override
  String get memberAdd => 'Thêm người';

  @override
  String get memberAddTitle => 'Thêm người';

  @override
  String get memberRename => 'Đổi tên';

  @override
  String get memberRenameTitle => 'Đổi tên';

  @override
  String memberRemoveTitle(String name) {
    return 'Xóa $name?';
  }

  @override
  String get memberRemoveBody => 'Khoản chi và số dư của người này vẫn còn trong nhóm.';

  @override
  String get groupLinkCopied => 'Đã sao chép liên kết. Ai có liên kết đều có thể mở nhóm này.';

  @override
  String get groupShare => 'Chia sẻ liên kết';

  @override
  String get groupSettings => 'Cài đặt nhóm';

  @override
  String get groupEdit => 'Chỉnh sửa nhóm';

  @override
  String get groupSharing => 'Chia sẻ';

  @override
  String get groupCopyLink => 'Sao chép liên kết';

  @override
  String get groupQrCode => 'Hiện mã QR';

  @override
  String get groupQrCodeHelp => 'Mọi người có thể dùng camera điện thoại quét liên kết.';

  @override
  String groupQrLabel(String group) {
    return 'Mã QR cho liên kết đến $group';
  }

  @override
  String get groupCopyLinkHelp => 'Ai có liên kết đều có thể xem và chỉnh sửa nhóm này.';

  @override
  String get groupCopyLinkHelpAccounts => 'Người có liên kết có thể xin tham gia sau khi đăng nhập.';

  @override
  String get linkAccessTitle => 'Ai có liên kết đều mở được';

  @override
  String get linkAccessHelp => 'Cho phép mọi người xem và chỉnh sửa mà không cần tài khoản';

  @override
  String get resetLinkTitle => 'Đặt lại liên kết';

  @override
  String get resetLinkHelp => 'Tạo liên kết mới; liên kết cũ sẽ ngừng hoạt động';

  @override
  String get resetLinkBody =>
      'Liên kết hiện tại sẽ ngừng hoạt động với tất cả mọi người. Chia sẻ liên kết mới với những người cần tiếp tục truy cập.';

  @override
  String get resetLinkAction => 'Đặt lại';

  @override
  String get resetLinkDone => 'Đã đặt lại liên kết. Hãy chia sẻ liên kết mới.';

  @override
  String get groupThisDevice => 'Thiết bị này';

  @override
  String get groupData => 'Dữ liệu';

  @override
  String get categoriesTitle => 'Danh mục';

  @override
  String get categoriesHelp => 'Thêm danh mục riêng hoặc ẩn những danh mục bạn không dùng';

  @override
  String get categoriesOwn => 'Của nhóm này';

  @override
  String get categoriesOwnEmpty => 'Nhóm chưa có danh mục riêng.';

  @override
  String get categoriesBuiltIn => 'Có sẵn';

  @override
  String get categoriesBuiltInHelp =>
      'Danh mục bị ẩn sẽ không được gợi ý cho khoản chi mới. Khoản chi đã dùng danh mục đó vẫn giữ nguyên.';

  @override
  String get categoryAdd => 'Thêm danh mục';

  @override
  String get categoryEdit => 'Chỉnh sửa danh mục';

  @override
  String get categoryName => 'Tên';

  @override
  String get categoryDelete => 'Xóa danh mục';

  @override
  String categoryDeleteTitle(String name) {
    return 'Xóa $name?';
  }

  @override
  String get categoryDeleteBody => 'Các khoản chi trong danh mục này sẽ không còn danh mục.';

  @override
  String get categoryDeleteAction => 'Xóa';

  @override
  String get exportCsv => 'Xuất dưới dạng CSV';

  @override
  String get exportCsvHelp => 'Mọi khoản chi và thanh toán, để dùng trong bảng tính';

  @override
  String get exportCsvDone => 'Đã xuất';

  @override
  String get forgetTitle => 'Gỡ khỏi thiết bị này';

  @override
  String get forgetHelp => 'Nhóm vẫn còn trên máy chủ cho những người khác';

  @override
  String get forgetBody => 'Bạn có thể mở lại nhóm bằng liên kết.';

  @override
  String get groupYou => 'Bạn';

  @override
  String get leaveTitle => 'Rời nhóm';

  @override
  String get leaveHelp => 'Khoản chi của bạn vẫn còn; bạn có thể tham gia lại bằng liên kết';

  @override
  String get leaveBody =>
      'Nhóm sẽ biến mất khỏi danh sách của bạn. Khoản chi và số dư của bạn vẫn còn trong nhóm.';

  @override
  String get leaveAction => 'Rời nhóm';

  @override
  String get tabExpenses => 'Khoản chi';

  @override
  String get heroWhoTitle => 'Bạn là ai trong nhóm này?';

  @override
  String get heroWhoBody => 'Chọn tên của bạn để xem mình nợ và được nhận bao nhiêu.';

  @override
  String get heroWhoAction => 'Chọn';

  @override
  String get heroJoinTitle => 'Bạn đang xem nhóm này';

  @override
  String get heroJoinBody => 'Tham gia để thêm khoản chi và xem mình nợ bao nhiêu.';

  @override
  String get joinAction => 'Tham gia';

  @override
  String get heroOwed => 'Bạn được nhận';

  @override
  String get heroOwe => 'Bạn nợ';

  @override
  String get heroSettled => 'Bạn đã thanh toán xong';

  @override
  String heroYouAre(String name) {
    return 'Bạn là $name';
  }

  @override
  String get expenseAdd => 'Thêm khoản chi';

  @override
  String get expensesEmptyTitle => 'Chưa có khoản chi nào';

  @override
  String get expensesEmptyBody => 'Thêm khoản đầu tiên, Balnana sẽ tính xem ai nợ ai.';

  @override
  String get expensesSearchHint => 'Tìm tiêu đề, ghi chú và địa điểm';

  @override
  String get searchClear => 'Xóa tìm kiếm';

  @override
  String get expensesNoMatchTitle => 'Không có kết quả phù hợp';

  @override
  String get expensesNoMatchBody => 'Thử từ khóa khác hoặc bớt bộ lọc.';

  @override
  String get filterAnyone => 'Bất kỳ ai';

  @override
  String get filterAnyCategory => 'Mọi danh mục';

  @override
  String get filterPayments => 'Thanh toán';

  @override
  String get filterClear => 'Xóa bộ lọc';

  @override
  String get periodAll => 'Toàn bộ thời gian';

  @override
  String get periodThisMonth => 'Tháng này';

  @override
  String get periodLastMonth => 'Tháng trước';

  @override
  String get periodThisYear => 'Năm nay';

  @override
  String get periodPickDays => 'Chọn ngày…';

  @override
  String get statsTitle => 'Chi tiêu';

  @override
  String get statsTotal => 'Tổng đã chi';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count khoản chi',
      one: '1 khoản chi',
    );
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'Theo danh mục';

  @override
  String get statsByMember => 'Số tiền đã trả và phần chia của mỗi người';

  @override
  String get statsPaid => 'Đã trả';

  @override
  String get statsShare => 'Phần chia';

  @override
  String get statsByMonth => 'Theo tháng';

  @override
  String get statsNoCategory => 'Không có danh mục';

  @override
  String get statsEmptyTitle => 'Chưa chi tiêu';

  @override
  String get statsEmptyBody => 'Không có khoản chi nào trong khoảng thời gian này.';

  @override
  String get statsShowExpenses => 'Xem các khoản chi này';

  @override
  String get dateToday => 'Hôm nay';

  @override
  String get dateYesterday => 'Hôm qua';

  @override
  String paymentTitle(String from, String to) {
    return '$from đã trả cho $to';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name đã trả $amount';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return '$count người đã trả $amount';
  }

  @override
  String expensePaidByName(String name) {
    return '$name đã trả';
  }

  @override
  String expensePaidByManyNames(int count) {
    return '$count người đã trả';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name đã nhận $amount';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$name đã nhận';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return '$count người đã nhận';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return '$count người đã nhận $amount';
  }

  @override
  String get transactionRefund => 'Hoàn tiền';

  @override
  String get transactionIncome => 'Thu nhập';

  @override
  String get paymentDelete => 'Xóa khoản thanh toán';

  @override
  String get paymentDeleted => 'Đã xóa khoản thanh toán';

  @override
  String expenseDeleted(String title) {
    return 'Đã xóa “$title”';
  }

  @override
  String get expenseNew => 'Khoản chi mới';

  @override
  String get expenseEdit => 'Chỉnh sửa khoản chi';

  @override
  String get expenseDelete => 'Xóa';

  @override
  String get expenseAmount => 'Số tiền';

  @override
  String get expenseTitle => 'Khoản này dùng để làm gì?';

  @override
  String get expenseTitleHint => 'Bữa tối, vé, taxi…';

  @override
  String get expenseAmountFromPayers => 'Tổng số tiền mọi người đã trả';

  @override
  String expensePaidIn(String currency) {
    return 'Đã trả bằng $currency';
  }

  @override
  String expenseRate(String from, String to) {
    return '1 $from bằng $to';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return 'Tổng bằng $currency';
  }

  @override
  String expenseForeignHelp(String currency) {
    return 'Số dư vẫn tính bằng $currency. Nhập tỷ giá hoặc tổng tiền sau quy đổi, chẳng hạn theo sao kê thẻ.';
  }

  @override
  String get expenseNote => 'Ghi chú';

  @override
  String get expenseNoteHint => 'Không bắt buộc';

  @override
  String get expenseLocation => 'Địa điểm';

  @override
  String get expenseLocationHint => 'Ở đâu? (không bắt buộc)';

  @override
  String get locationPickOnMap => 'Chọn trên bản đồ';

  @override
  String get locationUseCurrent => 'Dùng vị trí hiện tại';

  @override
  String get locationFinding => 'Đang tìm vị trí của bạn…';

  @override
  String get locationChange => 'Đổi trên bản đồ';

  @override
  String get locationRemovePin => 'Xóa ghim';

  @override
  String get locationOpenInMaps => 'Mở trong bản đồ';

  @override
  String get locationPickTitle => 'Chọn địa điểm';

  @override
  String get locationPickHint => 'Chạm vào bản đồ để đặt ghim';

  @override
  String get locationPickDone => 'Xong';

  @override
  String get locationDenied =>
      'Balnana không được phép dùng vị trí của bạn. Bạn có thể cấp quyền trong phần cài đặt thiết bị hoặc trình duyệt.';

  @override
  String get locationOff => 'Vị trí đã tắt trên thiết bị này.';

  @override
  String get locationUnavailable => 'Không tìm được vị trí của bạn. Thử lại hoặc đặt ghim trên bản đồ.';

  @override
  String get expenseReceipt => 'Hóa đơn';

  @override
  String get expenseHasReceipt => 'Có ảnh hóa đơn';

  @override
  String get expenseHasLocation => 'Có địa điểm';

  @override
  String get receiptTakePhoto => 'Chụp ảnh';

  @override
  String get receiptChoose => 'Chọn ảnh';

  @override
  String get receiptRemove => 'Gỡ';

  @override
  String get receiptView => 'Ảnh hóa đơn';

  @override
  String receiptNotSaved(String reason) {
    return 'Khoản chi đã lưu nhưng chưa lưu được ảnh hóa đơn. $reason';
  }

  @override
  String get expensePaidByLabel => 'Người đã trả';

  @override
  String get expenseReceivedForLabel => 'Nhận cho';

  @override
  String get expenseReceivedByLabel => 'Người nhận';

  @override
  String get expenseMultiplePayers => 'Nhiều người';

  @override
  String get expenseSplit => 'Chia';

  @override
  String get splitEqual => 'Chia đều';

  @override
  String get splitExact => 'Theo số tiền';

  @override
  String get splitShares => 'Theo phần';

  @override
  String splitLeft(String amount) {
    return 'Còn $amount chưa phân bổ';
  }

  @override
  String splitOver(String amount) {
    return 'Vượt $amount';
  }

  @override
  String get conflictTitle => 'Đã thay đổi ở nơi khác';

  @override
  String get conflictReload => 'Tải lại';

  @override
  String get expenseChangedElsewhere =>
      'Có người khác đã sửa khoản chi này. Tải lại để xem phiên bản của họ và bỏ thay đổi của bạn tại đây.';

  @override
  String get expenseNewerTitle => 'Được tạo bằng phiên bản mới hơn';

  @override
  String get expenseNewerBody => 'Hãy cập nhật Balnana để thay đổi mục này.';

  @override
  String get suggestedPayments => 'Khoản thanh toán đề xuất';

  @override
  String get allSettled => 'Mọi người đã thanh toán xong.';

  @override
  String transferYouPay(String name) {
    return 'Bạn trả $name';
  }

  @override
  String transferPaysYou(String name) {
    return '$name trả bạn';
  }

  @override
  String transferPays(String from, String to) {
    return '$from trả $to';
  }

  @override
  String get recordPayment => 'Ghi nhận';

  @override
  String get recordPaymentTitle => 'Ghi nhận khoản thanh toán';

  @override
  String get recordPaymentHelp => 'Chỉ ghi nhận tiền đã thực sự được trả bên ngoài Balnana.';

  @override
  String get paymentRecorded => 'Đã ghi nhận khoản thanh toán';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who đã tạo nhóm $group';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who đã thay đổi thông tin nhóm';
  }

  @override
  String activityLinkReset(String who) {
    return '$who đã đặt lại liên kết nhóm';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who đã thêm $name';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who đã đổi tên $oldName thành $name';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who đã xóa $name';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who đã thêm danh mục $name';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who đã thay đổi danh mục';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who đã xóa danh mục $name';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name đã tham gia';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who đã thêm “$title” ($amount)';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who đã sửa “$title” ($amount)';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who đã xóa “$title”';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who đã khôi phục “$title”';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who đã ghi nhận $from trả $to $amount';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who đã xóa khoản thanh toán $amount';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who đã khôi phục khoản thanh toán $amount';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count mục', one: '1 mục');
    return '$who đã nhập $_temp0 từ $source';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who đã thêm ảnh hóa đơn vào “$title”';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who đã gỡ ảnh hóa đơn khỏi “$title”';
  }

  @override
  String activityOther(String who) {
    return '$who đã thay đổi nội dung';
  }

  @override
  String get navGroups => 'Nhóm';

  @override
  String get navActivity => 'Hoạt động';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get groupsEmptyTitle => 'Chưa có nhóm nào';

  @override
  String get groupsEmptyBody => 'Nhóm bạn tạo hoặc mở bằng liên kết sẽ xuất hiện ở đây.';

  @override
  String get groupsNoServerTitle => 'Kết nối với máy chủ';

  @override
  String get groupsNoServerBody =>
      'Balnana lưu nhóm trên máy chủ do bạn chọn, chẳng hạn máy chủ bạn tự chạy.';

  @override
  String get groupsNoServerAction => 'Chọn máy chủ';

  @override
  String get groupsUnreachableTitle => 'Không thể kết nối với máy chủ';

  @override
  String get groupsUnreachableBody => 'Kiểm tra kết nối hoặc địa chỉ máy chủ trong Cài đặt.';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Không tải được $count nhóm nên thiếu hoạt động của các nhóm đó.',
      one: 'Không tải được một nhóm nên thiếu hoạt động của nhóm đó.',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => 'Chưa có hoạt động';

  @override
  String get activityEmptyBody => 'Khoản chi và thanh toán mới trong nhóm của bạn sẽ xuất hiện ở đây.';

  @override
  String get notFoundTitle => 'Không tìm thấy trang';

  @override
  String get notFoundBody => 'Địa chỉ này không dẫn đến đâu trong Balnana.';

  @override
  String get notFoundAction => 'Đến danh sách nhóm';

  @override
  String get settingsAppearance => 'Giao diện';

  @override
  String get settingsAccount => 'Tài khoản';

  @override
  String get accountRename => 'Đổi tên';

  @override
  String get passwordChange => 'Đổi mật khẩu';

  @override
  String get passwordChanged => 'Đã đổi mật khẩu. Các thiết bị khác đã đăng xuất.';

  @override
  String get passwordSet => 'Đặt mật khẩu';

  @override
  String get passwordSetHelp => 'Đăng nhập bằng email hoặc tên người dùng cùng mật khẩu';

  @override
  String get passwordSetDone => 'Đã đặt mật khẩu. Các thiết bị khác đã đăng xuất.';

  @override
  String get passwordCurrent => 'Mật khẩu hiện tại';

  @override
  String get passwordNew => 'Mật khẩu mới';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get accountOAuthLinked => 'Dùng để đăng nhập vào tài khoản này. Chạm để gỡ.';

  @override
  String get accountOAuthAdd => 'Thêm cách đăng nhập';

  @override
  String accountOAuthAddTitle(String name) {
    return 'Thêm $name';
  }

  @override
  String accountOAuthAdded(String name) {
    return 'Giờ bạn có thể đăng nhập bằng $name.';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return 'Gỡ $name?';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return 'Bạn sẽ không thể đăng nhập bằng $name cho đến khi thêm lại.';
  }

  @override
  String get accountOAuthRemove => 'Gỡ';

  @override
  String accountOAuthRemoved(String name) {
    return 'Đã gỡ $name.';
  }

  @override
  String get confirmEmailTitle => 'Xác nhận email';

  @override
  String confirmEmailBody(String email) {
    return 'Máy chủ này yêu cầu email đã xác nhận. Mở liên kết chúng tôi đã gửi đến $email.';
  }

  @override
  String get confirmEmailDone => 'Tôi đã xác nhận';

  @override
  String get confirmEmailResend => 'Gửi lại liên kết';

  @override
  String get confirmEmailNotYet => 'Email chưa được xác nhận. Hãy mở liên kết trong email.';

  @override
  String get settingsTheme => 'Chủ đề';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get settingsDynamicColor => 'Màu hình nền';

  @override
  String get settingsDynamicColorSubtitle => 'Dùng màu từ thiết bị thay cho màu vàng Balnana';

  @override
  String get settingsWallpaperGroups => 'Màu hình nền trong nhóm';

  @override
  String get settingsWallpaperGroupsSubtitle => 'Nhóm cũng dùng màu từ thiết bị thay cho màu riêng';

  @override
  String get settingsPureBlack => 'Đen tuyền';

  @override
  String get settingsPureBlackSubtitle => 'Chủ đề tối hơn cho màn hình OLED';

  @override
  String get settingsMyShare => 'Hiện phần của tôi';

  @override
  String get settingsMyShareSubtitle => 'Khoản chi hiển thị số bạn cho mượn hoặc đã mượn thay vì tổng tiền';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get settingsNotifications => 'Thông báo';

  @override
  String get settingsNotificationsSubtitle => 'Khi có người thêm, sửa hoặc xóa khoản chi có bạn tham gia';

  @override
  String get settingsNotificationsBlocked =>
      'Đã chặn trong cài đặt điện thoại: bật thông báo cho Balnana ở đó để xem thông báo';

  @override
  String get pushChannel => 'Khoản chi';

  @override
  String get pushChannelDescription => 'Khi có người thêm, sửa hoặc xóa khoản chi có bạn tham gia';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who đã thêm $title · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who đã sửa $title · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who đã xóa $title · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return 'Đã thêm $title · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return 'Đã sửa $title · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return 'Đã xóa $title · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payer đã trả $payee $amount';
  }

  @override
  String get settingsConnection => 'Kết nối';

  @override
  String get settingsServer => 'Máy chủ';

  @override
  String get serverNotSet => 'Chưa đặt';

  @override
  String get settingsAbout => 'Giới thiệu';

  @override
  String get aboutVersion => 'Phiên bản';

  @override
  String get aboutLicenses => 'Giấy phép phần mềm nguồn mở';

  @override
  String get aboutSource => 'Mã nguồn';

  @override
  String get aboutSourceCopied => 'Không mở được trình duyệt nên liên kết đã được sao chép';

  @override
  String get serverTitle => 'Máy chủ';

  @override
  String get serverIntro =>
      'Nhập địa chỉ máy chủ Balnana. Ai cũng có thể tự chạy máy chủ; địa chỉ thường là nơi mở ứng dụng web.';

  @override
  String get serverUrlLabel => 'Địa chỉ máy chủ';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => 'Kiểm tra kết nối';

  @override
  String get serverSaveAnyway => 'Vẫn lưu';

  @override
  String get serverReset => 'Dùng mặc định';

  @override
  String serverDefault(String url) {
    return 'Mặc định: $url';
  }

  @override
  String serverConnected(String version) {
    return 'Đã kết nối với Balnana $version';
  }

  @override
  String get serverModeLink => 'Chia sẻ nhóm bằng liên kết riêng tư. Không cần tài khoản.';

  @override
  String get serverModeAccounts => 'Mọi người đăng nhập bằng tài khoản.';

  @override
  String get serverInsecure =>
      'Địa chỉ này không được mã hóa (http). Người khác trên cùng mạng có thể đọc dữ liệu của bạn. Hãy dùng https cho máy chủ bên ngoài mạng gia đình.';

  @override
  String get serverErrorInvalid => 'Nhập địa chỉ web, ví dụ balnana.example.com';

  @override
  String get serverErrorUnreachable =>
      'Không thể kết nối. Kiểm tra địa chỉ và xem máy chủ có đang chạy không.';

  @override
  String get serverErrorNotBalnana => 'Có phản hồi nhưng đây không phải máy chủ Balnana.';

  @override
  String get serverSaved => 'Đã lưu máy chủ';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get groupSignInTitle => 'Đăng nhập để mở nhóm này';

  @override
  String get groupSignInBody => 'Nhóm này chỉ dành cho thành viên. Đăng nhập để xem hoặc tham gia.';

  @override
  String get signInTitle => 'Chào mừng bạn quay lại';

  @override
  String get signInBody => 'Đăng nhập để xem các nhóm của bạn.';

  @override
  String get signInNoPassword => 'Máy chủ này dùng cách khác để đăng nhập. Hãy hỏi người quản lý.';

  @override
  String get registerTitle => 'Tạo tài khoản';

  @override
  String get registerBody => 'Dùng các nhóm của bạn trên mọi thiết bị.';

  @override
  String get registerAction => 'Tạo tài khoản';

  @override
  String get registerHaveAccount => 'Tôi đã có tài khoản';

  @override
  String get signInNoAccount => 'Tạo tài khoản';

  @override
  String get accountName => 'Tên bạn';

  @override
  String get accountNameHelp => 'Tên mọi người trong nhóm sẽ thấy';

  @override
  String get accountEmail => 'Email';

  @override
  String get accountPassword => 'Mật khẩu';

  @override
  String get accountPasswordHelp => 'Ít nhất 8 ký tự';

  @override
  String get passwordShow => 'Hiện mật khẩu';

  @override
  String get passwordHide => 'Ẩn mật khẩu';

  @override
  String get joinPickName => 'Chọn tên khác';

  @override
  String joinTitle(String name) {
    return 'Tham gia $name';
  }

  @override
  String get joinBody =>
      'Bạn có phải là một trong những người này không? Chọn tên mình để tiếp nhận các khoản chi của họ.';

  @override
  String get joinBodyNew => 'Tham gia để thêm khoản chi và xem số dư của bạn.';

  @override
  String get joinAsNew => 'Tôi là người mới';

  @override
  String joinAsName(String name) {
    return 'Tham gia với tên $name';
  }

  @override
  String joinTaken(String names) {
    return 'Đã có người tham gia: $names';
  }

  @override
  String joinTakenCount(int count) {
    return '$count người đã tham gia.';
  }

  @override
  String get commonContinue => 'Tiếp tục';

  @override
  String get errorEmailOff => 'Máy chủ này không gửi email.';

  @override
  String get errorInvalidToken => 'Liên kết đã hết hạn hoặc đã được dùng.';

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu?';

  @override
  String get forgotPasswordBody => 'Chúng tôi sẽ gửi email cho bạn một liên kết để chọn mật khẩu mới.';

  @override
  String get forgotPasswordAction => 'Gửi liên kết';

  @override
  String get forgotPasswordSent => 'Nếu có tài khoản dùng địa chỉ đó, liên kết sẽ sớm được gửi đến.';

  @override
  String get resetPasswordTitle => 'Chọn mật khẩu mới';

  @override
  String get resetPasswordBody => 'Bạn sẽ đăng xuất khỏi mọi nơi rồi có thể đăng nhập bằng mật khẩu mới.';

  @override
  String get resetPasswordAction => 'Lưu mật khẩu';

  @override
  String get resetPasswordDone => 'Đã đổi mật khẩu. Hãy đăng nhập bằng mật khẩu mới.';

  @override
  String get verifyEmailTitle => 'Xác nhận email';

  @override
  String get verifyEmailHelp => 'Để bạn có thể đặt lại mật khẩu nếu quên';

  @override
  String verifyEmailSent(String email) {
    return 'Kiểm tra $email để tìm liên kết.';
  }

  @override
  String get verifyEmailDone => 'Đã xác nhận email';

  @override
  String get verifyEmailDoneBody => 'Cảm ơn bạn! Địa chỉ email đã được xác nhận.';

  @override
  String get verifyEmailFailed => 'Không thể xác nhận email';

  @override
  String get inviteByEmail => 'Mời qua email';

  @override
  String get inviteByEmailHelp => 'Gửi liên kết để mời ai đó tham gia';

  @override
  String get inviteAs => 'Tham gia với tư cách';

  @override
  String get inviteAsHelp => 'Họ có thể tiếp nhận các khoản chi của người này';

  @override
  String get inviteAsAnyone => 'Người mới';

  @override
  String get inviteSend => 'Gửi lời mời';

  @override
  String inviteSent(String email) {
    return 'Đã gửi lời mời đến $email.';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name đã mời bạn tham gia $group';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return 'Bạn được mời tham gia $group';
  }

  @override
  String inviteBody(String email) {
    return 'Tạo tài khoản bằng $email để tham gia hoặc đăng nhập nếu bạn đã có tài khoản.';
  }

  @override
  String get inviteBodySignedIn => 'Tham gia để thêm khoản chi và xem số dư của bạn.';

  @override
  String get inviteAction => 'Mở lời mời';

  @override
  String get inviteMissingTitle => 'Lời mời này không dùng được';

  @override
  String get inviteMissingBody => 'Lời mời có thể đã hết hạn hoặc đã được dùng. Hãy xin lời mời mới.';

  @override
  String get joinInvitedAs => 'Bạn được mời với tư cách người này';

  @override
  String signInWith(String provider) {
    return 'Tiếp tục với $provider';
  }

  @override
  String get signInOr => 'hoặc';

  @override
  String get oauthFailedTitle => 'Không thể đăng nhập';

  @override
  String get oauthPendingTitle => 'Email này đã có tài khoản';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider cho biết $email là email của bạn, nhưng tài khoản dùng email đó chưa được xác nhận. Bạn muốn làm gì?';
  }

  @override
  String get oauthPendingLink => 'Thêm vào tài khoản đó';

  @override
  String get oauthPendingLinkHelp => 'Nhập mật khẩu của tài khoản đó. Bạn vẫn dùng được mật khẩu này.';

  @override
  String get oauthPendingTakeOver => 'Tiếp nhận tài khoản đó';

  @override
  String get oauthPendingTakeOverHelp =>
      'Mật khẩu và các cách đăng nhập khác sẽ bị gỡ, đồng thời mọi phiên đăng nhập sẽ kết thúc.';

  @override
  String get oauthPendingNew => 'Tạo tài khoản mới';

  @override
  String oauthPendingNewHelp(String email) {
    return 'Tài khoản kia vẫn giữ các nhóm nhưng không còn $email.';
  }

  @override
  String get oauthPendingPassword => 'Mật khẩu của tài khoản đó';

  @override
  String get oauthPendingWrongPassword => 'Mật khẩu đó không đúng.';

  @override
  String get oauthOtherServer =>
      'Bạn đã bắt đầu đăng nhập trên máy chủ khác với máy chủ đang chọn. Hãy đăng nhập lại.';

  @override
  String get oauthBackToSignIn => 'Quay lại đăng nhập';

  @override
  String get errorOAuthFailed => 'Không thể đăng nhập. Hãy thử lại.';

  @override
  String get errorEmailHasAccount =>
      'Email này đã có tài khoản. Hãy đăng nhập vào tài khoản đó rồi thêm cách đăng nhập này trong Cài đặt.';

  @override
  String get errorIdentityTaken => 'Cách đăng nhập này đã thuộc về tài khoản khác.';

  @override
  String get errorLastSignInMethod =>
      'Đây là cách đăng nhập duy nhất của bạn. Trước tiên, hãy đặt mật khẩu hoặc thêm cách khác.';

  @override
  String get errorEmailUnverified => 'Trước tiên, hãy xác nhận email.';

  @override
  String get errorOAuthCancelled => 'Đã hủy đăng nhập.';

  @override
  String get importTitle => 'Nhập từ Settle Up';

  @override
  String get importAction => 'Nhập';

  @override
  String get importIntro =>
      'Trong Settle Up, hãy xuất nhóm thành tệp CSV rồi chọn tệp ở đây. Khoản chi, thanh toán và mọi người trong nhóm sẽ được nhập, số dư vẫn giữ nguyên.';

  @override
  String get importChooseFile => 'Chọn tệp CSV';

  @override
  String get importChooseOther => 'Chọn tệp khác';

  @override
  String get importReading => 'Đang đọc tệp…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(
      expenses,
      locale: localeName,
      other: '$expenses khoản chi',
      one: '1 khoản chi',
    );
    String _temp1 = intl.Intl.pluralLogic(
      payments,
      locale: localeName,
      other: '$payments khoản thanh toán',
      one: '1 khoản thanh toán',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return '$from đến $to';
  }

  @override
  String importCurrency(String currency) {
    return 'Tiền tệ: $currency. Các mục dùng tiền tệ khác sẽ lấy số tiền Settle Up đã quy đổi.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã bỏ qua $count mục có số tiền bằng 0.',
      one: 'Đã bỏ qua 1 mục có số tiền bằng 0.',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => 'Bạn là ai?';

  @override
  String get importUntitled => 'Chưa có tiêu đề';

  @override
  String get errorImportFile => 'Tệp này có vẻ không phải bản xuất CSV từ Settle Up.';

  @override
  String get errorImportCurrency =>
      'Tệp không có mục nào thiếu tỷ giá nên không xác định được tiền tệ của nhóm.';

  @override
  String get errorImportTooBig => 'Tệp này quá lớn để nhập.';

  @override
  String get errorBadImage => 'Không dùng được ảnh này. Hãy chọn ảnh JPEG, PNG hoặc WebP.';

  @override
  String get errorReceiptTooBig => 'Ảnh quá lớn. Hãy chọn ảnh dưới 10 MB.';

  @override
  String get errorImportMe => 'Chọn người là bạn.';

  @override
  String errorImportRow(int line, String reason) {
    return 'Không thể nhập dòng $line trong tệp: $reason';
  }

  @override
  String get errorImportAmount => 'không đọc được số tiền.';

  @override
  String get errorImportCounts => 'tên và số tiền không khớp.';

  @override
  String get errorImportDate => 'không đọc được ngày.';

  @override
  String get errorImportType => 'loại không phải khoản chi, thanh toán hoặc thu nhập.';

  @override
  String get errorImportTransfer => 'một khoản thanh toán cần có một người trả cho người khác.';

  @override
  String get errorImportRowCurrency => 'mục này dùng tiền tệ khác mà không có tỷ giá.';

  @override
  String get adminSetupTitle => 'Thiết lập máy chủ này';

  @override
  String get adminSetupBody =>
      'Chọn mật khẩu quản trị viên. Mật khẩu này bảo vệ trang cài đặt máy chủ. Không có tên người dùng: bất kỳ ai biết mật khẩu đều có thể thay đổi cài đặt.';

  @override
  String get adminSetupCode => 'Mã thiết lập';

  @override
  String get adminSetupCodeHelp =>
      'Máy chủ này đã có dữ liệu nên khi khởi động, mã thiết lập được in trong nhật ký. Với Docker: docker compose logs balnana';

  @override
  String get adminSetupAction => 'Đặt mật khẩu';

  @override
  String get adminPassword => 'Mật khẩu quản trị viên';

  @override
  String get adminPasswordRepeat => 'Nhập lại mật khẩu';

  @override
  String get adminPasswordMismatch => 'Mật khẩu không khớp.';

  @override
  String get adminLoginTitle => 'Quản trị';

  @override
  String get adminLoginBody => 'Nhập mật khẩu quản trị viên để thay đổi cài đặt máy chủ.';

  @override
  String get adminLoginAction => 'Đăng nhập';

  @override
  String get adminSettingsTitle => 'Cài đặt máy chủ';

  @override
  String get adminSaved => 'Đã lưu cài đặt. Cài đặt có hiệu lực ngay.';

  @override
  String get adminSaveFailed => 'Chưa lưu nội dung nào. Hãy kiểm tra các cài đặt được đánh dấu.';

  @override
  String get adminChangePassword => 'Đổi mật khẩu quản trị viên';

  @override
  String get adminPasswordCurrent => 'Mật khẩu hiện tại';

  @override
  String get adminPasswordNew => 'Mật khẩu mới';

  @override
  String get adminPasswordChanged => 'Đã đổi mật khẩu. Các phiên quản trị viên khác đã đăng xuất.';

  @override
  String get adminSignOut => 'Đăng xuất khỏi trang quản trị';

  @override
  String get adminBackHome => 'Quay lại Balnana';

  @override
  String get adminRequireEmail => 'Yêu cầu địa chỉ email';

  @override
  String get adminRequireEmailHelp =>
      'Khi tắt, mọi người đăng ký bằng tên người dùng và có thể bỏ trống email. Họ có thể đăng nhập bằng một trong hai.';

  @override
  String get adminRequireEmailUnused => 'Chỉ áp dụng cho đăng nhập bằng email và mật khẩu, hiện đang tắt.';

  @override
  String get accountUsername => 'Tên người dùng';

  @override
  String get accountUsernameHelp =>
      'Dùng từ 3 đến 32 chữ cái, chữ số, dấu chấm, gạch ngang hoặc gạch dưới. Bạn dùng tên này để đăng nhập.';

  @override
  String get accountEmailOptional => 'Email (không bắt buộc)';

  @override
  String get accountEmailOptionalHelp => 'Dùng để nhận lời mời vào nhóm và đặt lại mật khẩu nếu quên.';

  @override
  String get accountLogin => 'Email hoặc tên người dùng';

  @override
  String get errorInvalidUsername =>
      'Dùng từ 3 đến 32 chữ cái, chữ số, dấu chấm, gạch ngang hoặc gạch dưới; bắt đầu bằng chữ cái hoặc chữ số.';

  @override
  String get errorUsernameTaken => 'Đã có người dùng tên này.';

  @override
  String get adminDiscardTitle => 'Bỏ thay đổi?';

  @override
  String get adminDiscardBody => 'Các thay đổi cài đặt của bạn chưa được lưu.';

  @override
  String get adminDiscard => 'Bỏ';

  @override
  String adminLocked(String key) {
    return 'Được đặt trên máy chủ bởi $key';
  }

  @override
  String adminDefault(String value) {
    return 'Mặc định: $value';
  }

  @override
  String get adminSecretSaved => 'Đã lưu. Nhập giá trị mới để thay thế.';

  @override
  String get adminSecretRemoved => 'Sẽ bị xóa khi bạn lưu.';

  @override
  String get adminSecretRemove => 'Xóa giá trị đã lưu';

  @override
  String get adminSectionGeneral => 'Chung';

  @override
  String get adminSectionAccess => 'Truy cập';

  @override
  String get adminSectionMaps => 'Bản đồ';

  @override
  String get adminSectionAccounts => 'Tài khoản';

  @override
  String get adminSectionAccountsBody => 'Áp dụng khi chế độ truy cập dùng tài khoản.';

  @override
  String get adminSectionEmail => 'Email (SMTP)';

  @override
  String get adminSectionEmailBody => 'Xác minh địa chỉ, đặt lại mật khẩu và lời mời.';

  @override
  String get adminSmtpOn => 'Gửi email';

  @override
  String get adminSectionGoogle => 'Đăng nhập bằng Google';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Đăng ký $url làm URI chuyển hướng trong Google Cloud Console.';
  }

  @override
  String get adminGoogleOn => 'Cho phép đăng nhập bằng Google';

  @override
  String get adminGoogleOnHelp => 'Mọi người đăng nhập bằng tài khoản Google.';

  @override
  String get adminSectionOidc => 'Đăng nhập bằng OpenID Connect';

  @override
  String adminSectionOidcBody(String url) {
    return 'Đăng ký $url làm URI chuyển hướng với nhà cung cấp.';
  }

  @override
  String get adminOidcHelp =>
      'Dùng được mọi nhà cung cấp OpenID Connect, chẳng hạn Authentik, Keycloak hoặc Dex. Bạn có thể thêm bao nhiêu tùy ý.';

  @override
  String get adminOidcAdd => 'Thêm nhà cung cấp';

  @override
  String get adminOidcRemove => 'Gỡ nhà cung cấp';

  @override
  String get adminOidcNew => 'Nhà cung cấp mới';

  @override
  String get adminOidcId => 'ID';

  @override
  String get adminOidcIdHelp =>
      'Dùng chữ thường, chữ số và dấu gạch ngang. ID là một phần của URI chuyển hướng và sau này không thể đổi.';

  @override
  String get adminOidcIdInvalid =>
      'Dùng chữ thường, chữ số và dấu gạch ngang; bắt đầu bằng chữ cái hoặc chữ số, tối đa 32 ký tự.';

  @override
  String get adminOidcIdTaken => 'Đã có nhà cung cấp khác dùng ID này.';

  @override
  String get adminTrustEmail => 'Tin cậy email từ nhà cung cấp';

  @override
  String get adminGoogleTrustEmailHelp =>
      'Nếu email đăng nhập Google đã có tài khoản, người dùng sẽ đăng nhập vào tài khoản đó. Khi tắt, họ cần dùng mật khẩu rồi thêm Google trong Cài đặt.';

  @override
  String get adminOidcTrustEmailHelp =>
      'Chỉ dùng với nhà cung cấp do bạn vận hành hoặc tin cậy trong việc xác minh email. Khi tắt, người đã có tài khoản cần dùng mật khẩu rồi thêm nhà cung cấp trong Cài đặt.';

  @override
  String get adminRequireVerified => 'Yêu cầu email đã xác nhận';

  @override
  String get adminRequireVerifiedHelp =>
      'Tài khoản không thể dùng ứng dụng cho đến khi xác nhận email. Nếu đăng nhập đáng tin cậy dùng cùng email, tài khoản chưa xác nhận sẽ được tiếp nhận. Khi tắt, người dùng tự chọn cách xử lý.';

  @override
  String get adminRequireVerifiedUnused => 'Cần bật gửi email.';

  @override
  String get adminSectionAndroid => 'Liên kết ứng dụng Android';

  @override
  String get adminSectionAndroidBody =>
      'Bản Android dành cho máy chủ này sẽ mở liên kết trong ứng dụng. Để bỏ qua yêu cầu xác nhận, hãy liệt kê dấu vân tay SHA-256 của chứng chỉ dùng để ký các bản dựng đó.';

  @override
  String get adminSectionAdmin => 'Quản trị viên';

  @override
  String get adminPublicUrl => 'Địa chỉ công khai';

  @override
  String get adminPublicUrlHelp =>
      'Địa chỉ mọi người dùng để truy cập máy chủ này. Liên kết nhóm và email được tạo từ địa chỉ đó.';

  @override
  String get adminSourceUrl => 'Liên kết mã nguồn';

  @override
  String get adminSourceUrlHelp =>
      'Nơi mọi người có thể lấy mã nguồn máy chủ này, theo yêu cầu trong giấy phép (AGPL-3.0) khi bạn chạy phiên bản đã sửa đổi.';

  @override
  String get adminAuthMode => 'Quyền truy cập';

  @override
  String get adminAuthModeLink => 'Liên kết nhóm';

  @override
  String get adminAuthModeLinkHelp => 'Không cần đăng nhập: chỉ cần liên kết riêng tư của nhóm.';

  @override
  String get adminAuthModeAccounts => 'Tài khoản';

  @override
  String get adminAuthModeAccountsHelp =>
      'Mọi người đăng nhập; chỉ người đã đăng nhập mới có thể tham gia nhóm qua liên kết.';

  @override
  String get adminPasswordLogin => 'Đăng nhập bằng email và mật khẩu';

  @override
  String get adminPasswordForced =>
      'Cài đặt này bật cho đến khi bật đăng nhập bằng Google hoặc OpenID Connect, để luôn có cách đăng nhập.';

  @override
  String get adminSignup => 'Ai có thể tạo tài khoản';

  @override
  String get adminSignupOpen => 'Bất kỳ ai';

  @override
  String get adminSignupOpenHelp => 'Bất kỳ ai truy cập được máy chủ này đều có thể đăng ký.';

  @override
  String get adminSignupInvite => 'Người được mời';

  @override
  String get adminSignupInviteHelp =>
      'Chỉ người được mời vào nhóm qua email mới có thể đăng ký, và phải dùng đúng địa chỉ nhận lời mời. Chỉ có liên kết nhóm thì không thể tham gia. Cần bật email để gửi lời mời.';

  @override
  String get adminSignupClosed => 'Không ai';

  @override
  String get adminSignupClosedHelp => 'Không ai có thể đăng ký. Tài khoản hiện có vẫn dùng được.';

  @override
  String get adminSignupHelp => 'Luôn có thể tạo tài khoản đầu tiên.';

  @override
  String get adminLinkGroups => 'Có thể mở nhóm bằng liên kết';

  @override
  String get adminLinkGroupsHelp =>
      'Chủ nhóm có thể cho phép bất kỳ ai có liên kết tham gia mà không cần đăng nhập.';

  @override
  String get adminSmtpHost => 'Máy chủ email';

  @override
  String get adminSmtpPort => 'Cổng';

  @override
  String get adminSmtpUser => 'Tên người dùng';

  @override
  String get adminSmtpPassword => 'Mật khẩu';

  @override
  String get adminSmtpFrom => 'Người gửi';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'ID ứng dụng';

  @override
  String get adminClientSecret => 'Mã bí mật ứng dụng';

  @override
  String get adminOidcIssuer => 'URL nhà phát hành';

  @override
  String get adminOidcName => 'Tên nút';

  @override
  String get adminOidcNameHelp => 'Hiển thị dưới dạng “Tiếp tục với …” trên trang đăng nhập.';

  @override
  String get adminFingerprints => 'Dấu vân tay chứng chỉ';

  @override
  String get adminFingerprintsHelp =>
      'SHA-256, phân tách bằng dấu phẩy. Dùng keytool -list -v và apksigner verify --print-certs để xem.';

  @override
  String get adminInvalidValue => 'Giá trị này không hợp lệ.';

  @override
  String get adminInvalidUrl => 'Nhập địa chỉ đầy đủ bắt đầu bằng https:// hoặc http://.';

  @override
  String get adminInvalidFrom => 'Nhập người gửi như Balnana <balnana@example.com>; cần có email.';

  @override
  String get adminInvalidPort => 'Nhập số cổng từ 1 đến 65535.';

  @override
  String get adminInvalidRequired => 'Nhà cung cấp đăng nhập này yêu cầu mục đó.';

  @override
  String get adminInvalidFingerprint =>
      'Nhập dấu vân tay SHA-256: mỗi dấu gồm 64 chữ số hệ thập lục phân, có thể dùng dấu hai chấm.';

  @override
  String get adminNeedsSignIn =>
      'Tài khoản cần có cách đăng nhập: bật email và mật khẩu hoặc thiết lập nhà cung cấp.';

  @override
  String get adminLockedChange => 'Mục này được đặt trên máy chủ và không thể thay đổi ở đây.';

  @override
  String get errorAdminRequired => 'Phiên quản trị viên của bạn đã kết thúc. Hãy đăng nhập lại.';

  @override
  String get errorAdminWrongPassword => 'Mật khẩu không đúng.';

  @override
  String get errorInvalidSetupCode => 'Mã thiết lập không đúng. Hãy tìm mã trong nhật ký máy chủ.';

  @override
  String get errorAlreadySetUp => 'Máy chủ này đã được thiết lập. Hãy đăng nhập bằng mật khẩu quản trị viên.';

  @override
  String get linkOpening => 'Đang mở liên kết…';

  @override
  String get linkForeignTitle => 'Liên kết này thuộc máy chủ khác';

  @override
  String linkForeignBody(String server) {
    return 'Ứng dụng này đang kết nối với $server, còn liên kết thuộc máy chủ khác. Đổi máy chủ trong Cài đặt để mở liên kết.';
  }

  @override
  String get linkInvalidTitle => 'Không thể mở liên kết này';

  @override
  String get linkInvalidBody => 'Đây không phải liên kết Balnana mà ứng dụng nhận biết.';

  @override
  String get linkGoHome => 'Đến danh sách nhóm';

  @override
  String get linkOpenInBrowser => 'Mở trong trình duyệt';

  @override
  String get privacyTitle => 'Chính sách quyền riêng tư';

  @override
  String get privacyIntro =>
      'Balnana là phần mềm nguồn mở. Người quản lý máy chủ mà ứng dụng này kết nối đến quyết định nơi lưu dữ liệu và chịu trách nhiệm về dữ liệu đó. Trang này mô tả dữ liệu phần mềm lưu và cách phần mềm xử lý dữ liệu đó.';

  @override
  String get privacyStoredTitle => 'Dữ liệu được lưu';

  @override
  String get privacyStoredBody =>
      'Các nhóm bạn tạo hoặc tham gia: tên nhóm, tên thành viên, khoản chi, thanh toán, ghi chú, ảnh hóa đơn và địa điểm bạn thêm vào khoản chi. Nếu có tài khoản, dữ liệu còn gồm tên, địa chỉ email hoặc tên người dùng, mã băm mật khẩu (không bao giờ lưu mật khẩu) và nhà cung cấp đăng nhập bạn dùng, chẳng hạn Google. Nếu bật thông báo, ứng dụng lưu mã định danh thiết bị và địa chỉ do dịch vụ thông báo đẩy cung cấp.';

  @override
  String get privacyUseTitle => 'Cách dữ liệu được dùng';

  @override
  String get privacyUseBody =>
      'Chỉ để vận hành ứng dụng: hiển thị từng nhóm cho thành viên, tính số dư và gửi email cùng thông báo cần thiết như xác minh địa chỉ, đặt lại mật khẩu và lời mời. Ứng dụng không có quảng cáo hay công cụ phân tích và không bán dữ liệu.';

  @override
  String get privacySharedTitle => 'Ai có thể xem dữ liệu';

  @override
  String get privacySharedBody =>
      'Mọi người trong nhóm đều xem được thành viên, khoản chi và lịch sử của nhóm. Nếu mở nhóm bằng liên kết, ai có liên kết đều mở được. Đăng nhập bằng Google sẽ thông qua Google. Nếu người quản lý bật thông báo, thông báo sẽ qua dịch vụ đẩy mà điện thoại dùng: Google Firebase Cloud Messaging hoặc dịch vụ UnifiedPush khác bạn đã cài, chẳng hạn ntfy. Nội dung thông báo được mã hóa khi truyền. Bản đồ tải ảnh từ nhà cung cấp do người quản lý chọn, mặc định là OpenFreeMap trừ khi họ đổi; nhà cung cấp này thấy địa chỉ mạng của bạn và khu vực bạn xem. Vị trí của bạn chỉ được đọc khi bạn chạm “Dùng vị trí hiện tại”, và chỉ điểm bạn giữ lại mới được lưu.';

  @override
  String get privacyDeviceTitle => 'Trên thiết bị này';

  @override
  String get privacyDeviceBody =>
      'Ứng dụng lưu địa chỉ máy chủ, cài đặt và bản sao nhóm để dùng khi ngoại tuyến. Gỡ cài đặt ứng dụng sẽ xóa dữ liệu đó.';

  @override
  String get privacyDeleteTitle => 'Xóa dữ liệu của bạn';

  @override
  String get privacyDeleteBody =>
      'Bạn có thể xóa tài khoản trong Cài đặt. Tên bạn vẫn ở trong nhóm với tư cách thành viên chưa có ai nhận là mình, để số dư vẫn khớp; các nhóm không ai khác truy cập được sẽ bị xóa. Chủ nhóm có thể xóa toàn bộ nhóm trong phần cài đặt. Nhóm đã xóa và ảnh của các khoản chi đã xóa sẽ bị xóa vĩnh viễn sau 30 ngày. Với yêu cầu khác, hãy liên hệ người quản lý máy chủ.';

  @override
  String get privacyOperatorPolicy => 'Chính sách quyền riêng tư của người quản lý';

  @override
  String get privacyLink => 'Quyền riêng tư';

  @override
  String get accountEmailAdd => 'Thêm địa chỉ email';

  @override
  String get accountEmailChange => 'Đổi địa chỉ email';

  @override
  String get accountEmailNew => 'Địa chỉ email';

  @override
  String get accountEmailVerifyNote =>
      'Bạn sẽ nhận được liên kết để xác nhận địa chỉ mới. Địa chỉ hiện tại vẫn được giữ cho đến lúc đó.';

  @override
  String get accountEmailPendingTitle => 'Xác nhận email mới';

  @override
  String accountEmailPendingHelp(String email) {
    return '$email sẽ thay địa chỉ hiện tại sau khi bạn mở liên kết được gửi đến đó. Chạm để gửi lại.';
  }

  @override
  String get accountEmailRemoveNote =>
      'Để trống để xóa địa chỉ email. Bạn vẫn đăng nhập bằng tên người dùng.';

  @override
  String get accountEmailSaved => 'Đã lưu địa chỉ email';

  @override
  String get accountEmailRemoved => 'Đã xóa địa chỉ email';

  @override
  String get accountConfirmPassword => 'Mật khẩu của bạn';

  @override
  String get accountConfirmPasswordHelp => 'Để xác nhận đó là bạn.';

  @override
  String get errorEmailNeeded => 'Bạn đăng nhập bằng địa chỉ email nên không thể xóa địa chỉ này.';

  @override
  String get accountDelete => 'Xóa tài khoản';

  @override
  String get accountDeleteHelp => 'Xóa tài khoản của bạn khỏi máy chủ này';

  @override
  String get accountDeleteTitle => 'Xóa tài khoản của bạn?';

  @override
  String get accountDeleteBody =>
      'Tài khoản sẽ bị xóa vĩnh viễn và bạn sẽ đăng xuất. Trong các nhóm, tên bạn vẫn ở lại với tư cách thành viên chưa có ai nhận là mình để số dư vẫn khớp. Các nhóm không có ai khác sẽ bị xóa.';

  @override
  String get accountDeleteAction => 'Xóa vĩnh viễn';

  @override
  String get accountDeleted => 'Tài khoản của bạn đã bị xóa.';

  @override
  String get accountDeletePageSignedOut => 'Đăng nhập để xóa tài khoản trên máy chủ này.';

  @override
  String get accountDeletePageLinkMode =>
      'Máy chủ này không có tài khoản: chỉ cần liên kết nhóm để truy cập. Để xóa nhóm cùng toàn bộ nội dung, hãy mở cài đặt nhóm và chọn Xóa nhóm.';

  @override
  String get groupDelete => 'Xóa nhóm';

  @override
  String get groupDeleteHelp => 'Xóa nhóm cùng tất cả khoản chi của nhóm cho mọi người';

  @override
  String groupDeleteTitle(String name) {
    return 'Xóa $name?';
  }

  @override
  String get groupDeleteBody =>
      'Nhóm cùng toàn bộ khoản chi, thanh toán và lịch sử sẽ bị xóa với tất cả mọi người. Không thể hoàn tác. Nhập tên nhóm để xác nhận.';

  @override
  String get groupDeleteName => 'Tên nhóm';

  @override
  String get groupDeleteAction => 'Xóa vĩnh viễn';

  @override
  String get groupDeleted => 'Đã xóa nhóm';

  @override
  String get groupDeleteOwnerOnly => 'Chỉ chủ nhóm mới có thể xóa nhóm.';

  @override
  String get expenseDiscardTitle => 'Bỏ thay đổi?';

  @override
  String get expenseDiscardBody => 'Thay đổi khoản chi này chưa được lưu.';

  @override
  String get expenseDiscard => 'Bỏ';

  @override
  String get adminPrivacyUrl => 'Liên kết chính sách quyền riêng tư';

  @override
  String get adminPrivacyUrlHelp =>
      'Chính sách quyền riêng tư mà cửa hàng ứng dụng yêu cầu. Nếu để trống, ứng dụng sẽ hiển thị chính sách chung về dữ liệu Balnana lưu.';

  @override
  String get adminMapTiles => 'Ô bản đồ';

  @override
  String get adminMapSource => 'Nguồn bản đồ';

  @override
  String get adminMapSourceStyle => 'Kiểu bản đồ vector';

  @override
  String get adminMapSourceStyleHelp =>
      'Bản đồ được vẽ từ kiểu MapLibre, chẳng hạn OpenFreeMap; miễn phí và không cần API key.';

  @override
  String get adminMapSourceTiles => 'Ô bản đồ raster';

  @override
  String get adminMapSourceTilesHelp => 'Bản đồ hiển thị từ ảnh ô bản đồ, chẳng hạn OpenStreetMap.';

  @override
  String get adminMapSourceOff => 'Tắt';

  @override
  String get adminMapSourceOffHelp => 'Không dùng bản đồ. Khoản chi vẫn lưu tên địa điểm và tọa độ.';

  @override
  String get adminMapStyle => 'URL kiểu bản đồ';

  @override
  String get adminMapStyleHelp =>
      'Địa chỉ tệp style.json của MapLibre, như Liberty (mặc định), Bright hoặc Positron của OpenFreeMap.';

  @override
  String get adminMapTilesHelp =>
      'Mẫu URL ô raster có z, x và y trong dấu ngoặc nhọn, như mẫu mặc định. Máy chủ riêng của OpenStreetMap chỉ dành cho lưu lượng thấp; máy chủ đông người dùng nên dùng nhà cung cấp ô bản đồ.';

  @override
  String get adminMapAttribution => 'Ghi nguồn bản đồ';

  @override
  String get adminMapAttributionHelp =>
      'Hiển thị trên mọi bản đồ theo yêu cầu của nhà cung cấp. Nếu để trống, kiểu bản đồ sẽ hiện nội dung ghi nguồn được chỉ định, còn ô bản đồ sẽ ghi nguồn OpenStreetMap.';

  @override
  String get adminInvalidMapTiles => 'Nhập mẫu URL http(s) có z, x và y trong dấu ngoặc nhọn.';

  @override
  String get adminUsers => 'Tài khoản';

  @override
  String get adminUsersSearch => 'Tìm theo tên, email hoặc tên người dùng';

  @override
  String adminUsersShown(int shown, int total) {
    return 'Đang hiển thị $shown/$total tài khoản';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tài khoản',
      one: '1 tài khoản',
    );
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => 'Không tìm thấy tài khoản phù hợp.';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nhóm',
      one: '1 nhóm',
      zero: 'Không có nhóm',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => 'chưa xác minh';

  @override
  String adminUserDeleteTitle(String name) {
    return 'Xóa tài khoản của $name?';
  }

  @override
  String get adminUserDeleteBody =>
      'Tài khoản sẽ bị xóa vĩnh viễn và đăng xuất khỏi mọi nơi. Tên người này vẫn ở trong các nhóm với tư cách thành viên chưa có ai nhận là mình; các nhóm không có ai khác sẽ bị xóa.';

  @override
  String get adminUserDeleted => 'Đã xóa tài khoản';

  @override
  String get commonDone => 'Xong';

  @override
  String get crowdSearch => 'Tìm người';

  @override
  String get crowdNoMatch => 'Không tìm thấy ai phù hợp.';

  @override
  String get crowdAll => 'Tất cả';

  @override
  String get crowdNone => 'Không ai';

  @override
  String crowdChosen(int count, int total) {
    return 'Đã chọn $count/$total';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Thêm $count người',
      one: 'Thêm 1 người',
    );
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => 'Hiện ít hơn';

  @override
  String get crowdSort => 'Sắp xếp';

  @override
  String crowdShowAll(int count) {
    return 'Hiện tất cả $count';
  }

  @override
  String get crowdBalances => 'Số dư của mọi người';

  @override
  String get crowdSomeoneElse => 'Người khác';

  @override
  String get crowdChoosePayers => 'Chọn người trả tiền';

  @override
  String get crowdFilterTitle => 'Khoản chi của ai?';

  @override
  String get myGroupsTitle => 'Liên kết nhóm của tôi';

  @override
  String get myGroupsExport => 'Xuất nhóm của tôi';

  @override
  String get myGroupsExportHelp => 'Sao chép liên kết nhóm để sao lưu hoặc chuyển sang thiết bị khác.';

  @override
  String get myGroupsPrivate => 'Giữ riêng tư các liên kết này. Ai có liên kết đều có thể mở nhóm tương ứng.';

  @override
  String get myGroupsCopy => 'Sao chép liên kết';

  @override
  String get myGroupsImport => 'Nhập nhóm';

  @override
  String get myGroupsImportHelp =>
      'Dán liên kết nhóm từ máy chủ này, mỗi liên kết một dòng. Các nhóm đã có vẫn giữ nguyên vị trí và thông tin.';

  @override
  String get myGroupsLinks => 'Liên kết nhóm';

  @override
  String get myGroupsImportAction => 'Nhập liên kết';

  @override
  String get myGroupsInvalid => 'Nhập liên kết nhóm hợp lệ, mỗi liên kết một dòng. Chưa có gì được nhập.';

  @override
  String get myGroupsServerChanged =>
      'Máy chủ đang chọn đã thay đổi. Đóng hộp thoại này rồi nhập liên kết trên đúng máy chủ.';

  @override
  String myGroupsLimit(int count) {
    return 'Mỗi máy chủ chỉ lưu tối đa $count liên kết nhóm. Chưa có gì được nhập.';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã nhập $count liên kết nhóm mới.',
      one: 'Đã nhập 1 liên kết nhóm mới.',
      zero: 'Các nhóm này đã được lưu rồi.',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => 'Lặp lại';

  @override
  String get repeatNever => 'Không lặp lại';

  @override
  String get repeatDaily => 'Hằng ngày';

  @override
  String get repeatWeekly => 'Hằng tuần';

  @override
  String get repeatMonthly => 'Hằng tháng';

  @override
  String get repeatYearly => 'Hằng năm';

  @override
  String get repeatEvery => 'Mỗi';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'ngày', one: 'ngày');
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'tuần', one: 'tuần');
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'tháng', one: 'tháng');
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'năm', one: 'năm');
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mỗi $count ngày',
      one: 'Mỗi ngày',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mỗi $count tuần',
      one: 'Mỗi tuần',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mỗi $count tháng',
      one: 'Mỗi tháng',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Mỗi $count năm', one: 'Mỗi năm');
    return '$_temp0';
  }

  @override
  String get repeatEndNone => 'Không có ngày kết thúc';

  @override
  String repeatEndOn(String date) {
    return 'Đến $date';
  }

  @override
  String get repeatEndClear => 'Xóa ngày kết thúc';

  @override
  String get repeatHelp =>
      'Khoản chi sẽ tự động được thêm vào nhóm theo lịch, bắt đầu từ ngày ở trên. Khi bạn lưu, các ngày đã qua cũng sẽ được thêm.';

  @override
  String get repeatCustom => 'Lịch tùy chỉnh';

  @override
  String get repeatDropReceiptTitle => 'Gỡ hóa đơn?';

  @override
  String get repeatDropReceiptBody =>
      'Khoản chi định kỳ không thể kèm hóa đơn. Thay vào đó, bạn có thể thêm hóa đơn riêng cho từng khoản chi được tạo.';

  @override
  String get repeatDropReceiptAction => 'Lặp lại';

  @override
  String get recurringTitle => 'Khoản chi định kỳ';

  @override
  String get recurringHelp => 'Khoản chi tự động được thêm theo lịch';

  @override
  String get recurringEmptyTitle => 'Chưa có khoản chi định kỳ';

  @override
  String get recurringEmptyBody =>
      'Tiền thuê nhà, phí đăng ký và các khoản chi lặp lại khác có thể tự động được thêm theo lịch.';

  @override
  String get recurringAdd => 'Thêm khoản chi định kỳ';

  @override
  String get recurringEdit => 'Chỉnh sửa khoản chi định kỳ';

  @override
  String recurringNext(String date) {
    return 'Lần tới: $date';
  }

  @override
  String get recurringPaused => 'Đã tạm dừng';

  @override
  String get recurringEnded => 'Đã kết thúc';

  @override
  String get recurringPause => 'Tạm dừng';

  @override
  String get recurringResume => 'Tiếp tục';

  @override
  String get recurringActive => 'Lặp lại';

  @override
  String get recurringDelete => 'Xóa';

  @override
  String get recurringDeleteTitle => 'Dừng lặp lại?';

  @override
  String recurringDeleteBody(String title) {
    return '“$title” sẽ không được thêm nữa. Các khoản chi đã tạo vẫn được giữ lại.';
  }

  @override
  String get recurringDeleted => 'Đã xóa khoản chi định kỳ';

  @override
  String get recurringFromSchedule => 'Được thêm bởi khoản chi định kỳ';

  @override
  String get recurringOpen => 'Đổi lịch';

  @override
  String get recurringMissing => 'Khoản chi định kỳ đã bị xóa hoặc không còn khả dụng.';

  @override
  String get errorTooManyDue => 'Ngày bắt đầu đã quá lâu: sẽ có hơn 100 khoản chi được thêm cùng lúc.';

  @override
  String get errorInvalidEnd => 'Ngày kết thúc không thể trước ngày bắt đầu.';

  @override
  String get errorInvalidRepeat => 'Lặp lại mỗi 1 đến 999 ngày, tuần, tháng hoặc năm.';

  @override
  String get errorRecurringConflict =>
      'Có người khác đã sửa khoản chi định kỳ này khi bạn đang chỉnh sửa. Tải lại để xem thay đổi của họ.';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$who đã đặt “$title” lặp lại';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$who đã thay đổi khoản chi định kỳ “$title”';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$who đã tạm dừng khoản chi định kỳ “$title”';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return 'Khoản chi định kỳ “$title” đã được tạm dừng vì có người trong đó rời nhóm';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return 'Khoản chi định kỳ “$title” đã được tạm dừng vì không thể thêm khoản chi';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$who đã tiếp tục khoản chi định kỳ “$title”';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$who đã dừng khoản chi định kỳ “$title”';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return '“$title” ($amount) đã được tự động thêm';
  }

  @override
  String get expenseRecurring => 'Được thêm bởi khoản chi định kỳ';

  @override
  String get adminPlans => 'Gói';

  @override
  String get adminPayments => 'Thanh toán';

  @override
  String get adminSectionBilling => 'Gói và thanh toán';

  @override
  String get adminSectionBillingBody =>
      'Các gói nâng giới hạn những gì máy chủ này lưu giữ. Chia chi phí và thanh toán nợ vẫn miễn phí.';

  @override
  String get adminBillingOn => 'Gói và giới hạn';

  @override
  String get adminBillingOnHelp => 'Khi tắt, máy chủ này không giới hạn gì và không hiển thị gói.';

  @override
  String get adminBillingNeedsAccounts =>
      'Gói cần có tài khoản: hãy đổi chế độ truy cập sang tài khoản trước.';

  @override
  String get adminKofiUrl => 'Trang Ko-fi';

  @override
  String get adminKofiUrlHelp =>
      'Nơi mọi người thanh toán. Chỉ các bản cho phép thanh toán bên ngoài mới liên kết tới đây.';

  @override
  String adminKofiWebhook(String url) {
    return 'URL webhook để nhập trên Ko-fi: $url';
  }

  @override
  String get adminKofiToken => 'Mã xác minh Ko-fi';

  @override
  String get adminKofiTokenHelp =>
      'Hiển thị trên trang webhook của Ko-fi. Nếu thiếu, máy chủ này bỏ qua Ko-fi.';

  @override
  String adminUserPlanUntil(String plan, String date) {
    return '$plan đến $date';
  }

  @override
  String get adminPlansHelp =>
      'Giới hạn mới áp dụng cho những gì được thêm sau đó. Nội dung đã có vẫn được giữ. Để trống nếu không giới hạn.';

  @override
  String get adminPlanAdd => 'Thêm gói';

  @override
  String adminPlanDefaultName(String name) {
    return '$name (mặc định)';
  }

  @override
  String adminPlanLimit(String label, String value) {
    return '$label: $value';
  }

  @override
  String adminPlanDays(int count) {
    return 'Số ngày: $count';
  }

  @override
  String get adminProductsSection => 'Sản phẩm';

  @override
  String get adminProductsHelp =>
      'Khoản thanh toán thuộc về sản phẩm có tên cấp của nó, nếu không thì về sản phẩm không có tên cấp mà số tiền đạt tới.';

  @override
  String get adminProductAdd => 'Thêm sản phẩm';

  @override
  String get adminProductEdit => 'Sửa sản phẩm';

  @override
  String adminProductAnyPayment(String amount) {
    return 'Mọi khoản thanh toán từ $amount';
  }

  @override
  String get adminProductName => 'Tên cấp';

  @override
  String get adminProductNameHelp =>
      'Viết giống trên Ko-fi. Để trống để khớp khoản thanh toán một lần hoặc hằng tháng theo số tiền.';

  @override
  String get adminProductPlan => 'Gói';

  @override
  String get adminProductDays => 'Số ngày';

  @override
  String get adminProductDaysHelp =>
      'Thời hạn của một khoản thanh toán. Thanh toán lại sẽ cộng vào thời gian còn lại.';

  @override
  String get adminProductMinAmount => 'Số tiền tối thiểu';

  @override
  String get adminProductCurrency => 'Mã tiền tệ';

  @override
  String get adminPlanId => 'ID';

  @override
  String get adminPlanIdHelp => 'Chữ thường, chữ số và dấu gạch nối. Không thể đổi sau này.';

  @override
  String get adminPlanName => 'Tên';

  @override
  String get adminPlanRank => 'Thứ hạng';

  @override
  String get adminPlanRankHelp => 'Tài khoản có nhiều gói sẽ nhận gói có thứ hạng cao nhất.';

  @override
  String get adminPlanDefault => 'Gói mặc định';

  @override
  String get adminPlanDefaultHelp => 'Dành cho mọi tài khoản không có gói khác.';

  @override
  String adminPlanRemoveTitle(String name) {
    return 'Xóa $name?';
  }

  @override
  String adminPlanRemoveBody(String products) {
    return 'Các sản phẩm của gói cũng bị xóa theo và không thể mua nữa: $products';
  }

  @override
  String get adminEntitlementGranted => 'Do quản trị viên cấp';

  @override
  String get adminEntitlementRevoked => 'Đã thu hồi';

  @override
  String get adminEntitlementForever => 'Không có ngày kết thúc';

  @override
  String adminEntitlementUntil(String date) {
    return 'Đến $date';
  }

  @override
  String adminEntitlementEnded(String date) {
    return 'Đã kết thúc $date';
  }

  @override
  String get adminEntitlementsEmpty => 'Tài khoản này chưa có gói nào.';

  @override
  String get adminEntitlementRevoke => 'Thu hồi';

  @override
  String adminEntitlementRevokeTitle(String plan) {
    return 'Thu hồi $plan?';
  }

  @override
  String adminEntitlementRevokeBody(String user) {
    return '$user sẽ mất gói này ngay lập tức. Không thể hoàn tác.';
  }

  @override
  String get adminEntitlementNote => 'Ghi chú';

  @override
  String get adminEntitlementGrant => 'Cấp gói';

  @override
  String get adminPaymentApplied => 'Đã áp dụng';

  @override
  String get adminPaymentUnclaimed => 'Chưa nhận';

  @override
  String get adminPaymentUnmatched => 'Chưa khớp';

  @override
  String get adminPaymentsAll => 'Tất cả';

  @override
  String adminPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count khoản thanh toán');
    return '$_temp0';
  }

  @override
  String get adminPaymentsEmpty => 'Không có khoản thanh toán nào.';

  @override
  String get adminPaymentAssigned => 'Đã cấp gói cho tài khoản.';

  @override
  String get adminPaymentAssign => 'Cấp cho tài khoản';

  @override
  String get adminPaymentPickUser => 'Hãy chọn một tài khoản.';

  @override
  String get errorBillingOff => 'Máy chủ này không có gói nào.';

  @override
  String get errorAlreadySponsored => 'Gói của một thành viên khác đã bao gồm nhóm này.';

  @override
  String get errorPlanInUse => 'Vẫn có tài khoản hoặc sản phẩm dùng gói này.';

  @override
  String get errorPaymentApplied => 'Khoản thanh toán này đã được áp dụng.';

  @override
  String get errorPaymentNotFound =>
      'Chưa có khoản thanh toán với mã đó. Nếu bạn vừa thanh toán, hãy thử lại sau một phút.';

  @override
  String get errorPaymentNoPlan =>
      'Khoản thanh toán này không khớp với gói nào. Hãy nhờ quản trị viên máy chủ áp dụng.';

  @override
  String get errorInvalidPlan => 'Hãy kiểm tra cài đặt gói: có mục không hợp lệ.';

  @override
  String errorLimitReceipts(int max) {
    return 'Nhóm này đã đạt giới hạn $max ảnh hóa đơn.';
  }

  @override
  String errorLimitRecurring(int max) {
    return 'Nhóm này đã đạt giới hạn $max khoản chi định kỳ.';
  }

  @override
  String errorLimitJoinedGroups(int max) {
    return 'Bạn đã đạt giới hạn $max nhóm.';
  }

  @override
  String errorLimitMembers(int max) {
    return 'Nhóm này đã đạt giới hạn $max người.';
  }

  @override
  String errorLimitSponsored(int max) {
    return 'Gói của bạn chỉ có thể chia sẻ với tối đa $max nhóm.';
  }

  @override
  String get errorLimitOther => 'Bạn đã đạt giới hạn của máy chủ này.';

  @override
  String get planTitle => 'Gói';

  @override
  String get planUnlimited => 'Không giới hạn';

  @override
  String planUntil(String date) {
    return 'Đến $date';
  }

  @override
  String get planSettingsHelp => 'Những gì máy chủ này lưu cho bạn';

  @override
  String get planIntro =>
      'Chia và thanh toán nợ luôn miễn phí. Gói chỉ thay đổi lượng nội dung máy chủ này lưu cho bạn.';

  @override
  String planUsage(int used, int limit) {
    return '$used / $limit';
  }

  @override
  String planUsed(int used) {
    return 'Đã dùng $used';
  }

  @override
  String get planLimits => 'Giới hạn';

  @override
  String get planLimitReceipts => 'Ảnh hóa đơn mỗi nhóm';

  @override
  String get planLimitRecurring => 'Khoản chi định kỳ mỗi nhóm';

  @override
  String get planLimitJoinedGroups => 'Nhóm bạn tham gia';

  @override
  String get planLimitMembers => 'Số người mỗi nhóm';

  @override
  String get planLimitSponsored => 'Nhóm dùng chung gói của bạn';

  @override
  String get planGet => 'Nhận gói';

  @override
  String get planKofi => 'Ko-fi';

  @override
  String get planKofiHelp =>
      'Hãy dán mã thanh toán vào lời nhắn trên Ko-fi để khoản thanh toán về đúng tài khoản của bạn.';

  @override
  String get planPaymentCodeHelp => 'Mã thanh toán của bạn. Nhấn để sao chép.';

  @override
  String get planPaymentCodeCopied => 'Đã sao chép mã thanh toán';

  @override
  String get planPaymentClaim => 'Quên mã?';

  @override
  String get planPaymentClaimHelp => 'Thêm khoản thanh toán bằng mã giao dịch Ko-fi.';

  @override
  String get planPaymentClaimField => 'Mã giao dịch hoặc liên kết thanh toán';

  @override
  String get planPaymentClaimAction => 'Thêm khoản thanh toán';

  @override
  String get planPaymentClaimed => 'Đã thêm khoản thanh toán';

  @override
  String groupPlanUsage(String members, String receipts, String recurring) {
    return 'Số người: $members · Ảnh hóa đơn: $receipts · Định kỳ: $recurring';
  }

  @override
  String get groupSponsor => 'Chia sẻ gói của tôi với nhóm này';

  @override
  String get groupUnsponsor => 'Ngừng chia sẻ gói của tôi';

  @override
  String groupSponsoredBy(String name) {
    return 'Dùng gói của $name';
  }

  @override
  String get accountDeletePlayNote =>
      'Gói đăng ký Google Play không kết thúc cùng tài khoản. Hãy hủy trên Google Play trước.';

  @override
  String get planPlayManage => 'Quản lý gói đăng ký';

  @override
  String get planPlayManageHelp => 'Thay đổi hoặc hủy trên Google Play';

  @override
  String planPlayPrice(int months, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'mỗi $months tháng',
      one: 'mỗi tháng',
    );
    return '$price $_temp0';
  }

  @override
  String get planPlayFailed => 'Google Play không thể hoàn tất giao dịch.';

  @override
  String get planPlayPending => 'Thanh toán của bạn vẫn đang được xử lý. Gói sẽ bắt đầu khi hoàn tất.';

  @override
  String get planPlayOnHold =>
      'Lần thanh toán gần nhất của bạn không thành công. Hãy cập nhật phương thức thanh toán trên Google Play để giữ gói này.';

  @override
  String get planPlayHeldElsewhere =>
      'Tài khoản Google Play này đã có gói đăng ký, có thể thuộc về một tài khoản Balnana khác.';

  @override
  String get planPlayUnavailable => 'Không thể kết nối Google Play. Hãy thử lại sau.';

  @override
  String get errorInvalidPurchase => 'Google Play không nhận ra giao dịch này.';

  @override
  String get errorPlayOtherAccount =>
      'Gói đăng ký này thuộc tài khoản khác. Hãy đăng nhập tài khoản đó hoặc hủy trên Google Play.';

  @override
  String get errorPlayUnavailable => 'Không thể kết nối Google Play. Hãy thử lại sau giây lát.';

  @override
  String get adminPlayPackage => 'Tên gói Google Play';

  @override
  String get adminPlayPackageHelp =>
      'ID của ứng dụng trên Google Play. Cùng với tài khoản dịch vụ bên dưới, mục này bật gói đăng ký Google Play.';

  @override
  String get adminPlayServiceAccount => 'Tài khoản dịch vụ Google Play';

  @override
  String get adminPlayServiceAccountHelp =>
      'Khóa JSON của tài khoản dịch vụ có quyền xem và quản lý đơn hàng cùng gói đăng ký trong Play Console.';

  @override
  String get adminPlayPushAccount => 'Tài khoản đẩy Pub/Sub';

  @override
  String get adminPlayPushAccountHelp =>
      'Email của tài khoản dịch vụ mà Pub/Sub dùng để ký khi gửi. Nếu không có, các lần gia hạn chỉ đến khi có người mở trang gói.';

  @override
  String adminPlayWebhook(String url) {
    return 'Điểm cuối đẩy của Pub/Sub, đồng thời là đối tượng: $url';
  }

  @override
  String get adminProductProvider => 'Thanh toán qua';

  @override
  String get adminProductPlayId => 'ID sản phẩm';

  @override
  String get adminProductPlayIdHelp =>
      'Như ghi trong Play Console. Google Play cho biết khi nào mỗi khoản thanh toán kết thúc nên không cần đặt số ngày.';

  @override
  String get adminProductRemoveBody =>
      'Các khoản thanh toán cho sản phẩm này sẽ không còn được áp dụng vào tài khoản. Các gói đang có vẫn dùng được đến khi hết hạn.';
}
