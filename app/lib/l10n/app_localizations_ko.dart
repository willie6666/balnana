// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get languageEndonym => '한국어';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => '취소';

  @override
  String get commonRetry => '다시 시도';

  @override
  String get offlineBar => '오프라인 상태예요. 이 기기에 저장된 내용을 표시하고 있어요. 다시 연결될 때까지 변경사항을 저장할 수 없어요.';

  @override
  String get commonSave => '저장';

  @override
  String get commonClear => '지우기';

  @override
  String get iconChoose => '아이콘 선택';

  @override
  String get iconNone => '아이콘 없음';

  @override
  String get iconSearchHint => '검색하거나 이모지를 입력하세요';

  @override
  String get iconUseTyped => '이 이모지 사용';

  @override
  String get iconNoMatch => '일치하는 아이콘이 없어요. 사용할 이모지를 입력하세요.';

  @override
  String get iconSectionTravel => '여행 및 장소';

  @override
  String get iconSectionFood => '음식 및 음료';

  @override
  String get iconSectionActivities => '활동';

  @override
  String get iconSectionHome => '집 및 공과금';

  @override
  String get iconSectionPeople => '사람';

  @override
  String get iconSectionNature => '동물 및 자연';

  @override
  String get iconSectionObjects => '돈 및 물건';

  @override
  String get iconSectionSymbols => '기호';

  @override
  String get commonRemove => '삭제';

  @override
  String get commonUndo => '실행 취소';

  @override
  String get someone => '누군가';

  @override
  String get errorTooLarge => '서버로 보내기에는 파일이 너무 커요.';

  @override
  String get errorBusy => '서버가 바빠요. 잠시 후 다시 시도해 주세요.';

  @override
  String get errorTimeout => '보내는 데 시간이 너무 오래 걸렸어요. 연결을 확인하고 다시 시도해 주세요.';

  @override
  String get errorBadOrigin => '이 주소에서는 로그인할 수 없어요. 서버 운영자가 공개 URL을 확인해야 해요.';

  @override
  String get errorInvalidCategory => '해당 카테고리가 이미 삭제됐어요. 다른 카테고리를 선택해 주세요.';

  @override
  String get errorBuiltinCategory => '기본 카테고리는 숨길 수만 있어요.';

  @override
  String get errorUnknownMember => '이 지출에 지정된 멤버는 이제 그룹에 없어요. 새로고침한 뒤 다시 시도해 주세요.';

  @override
  String get errorNoPayers => '결제한 사람을 선택해 주세요.';

  @override
  String get errorPayerTotal => '각 사람이 낸 금액의 합이 전체 금액과 같아야 해요.';

  @override
  String get errorPayerTooSmall => '그룹 통화로 환산한 결제 금액이 0인 사람이 있어요. 금액을 확인해 주세요.';

  @override
  String get errorInvalidNote => '메모가 너무 길거나 저장할 수 없는 문자가 포함되어 있어요.';

  @override
  String get errorInvalidDate => '날짜가 허용 범위를 벗어났어요.';

  @override
  String get errorGeneric => '문제가 생겼어요. 다시 시도해 주세요.';

  @override
  String get errorNetwork => '서버에 연결할 수 없어요. 연결 상태를 확인해 주세요.';

  @override
  String get errorNotFound => '더 이상 존재하지 않아요.';

  @override
  String get errorRequired => '필수 항목이에요.';

  @override
  String get errorInvalidName => '이름은 100자 이내로 입력해 주세요.';

  @override
  String get errorDuplicateName => '그룹에 이미 같은 이름의 멤버가 있어요.';

  @override
  String get errorTooManyMembers => '이 그룹은 멤버 수가 최대치에 도달했어요.';

  @override
  String get errorTooManyCategories => '이 그룹은 카테고리 수가 최대치에 도달했어요.';

  @override
  String get errorDuplicateCategory => '이 그룹에 이미 같은 이름의 카테고리가 있어요.';

  @override
  String get errorInvalidCurrency => 'USD와 같은 세 글자 통화 코드를 입력해 주세요.';

  @override
  String get errorInvalidTitle => '제목은 200자 이내로 입력해 주세요.';

  @override
  String get errorInvalidLocation => '장소 이름을 한 줄로 200자 이내로 입력해 주세요.';

  @override
  String get errorInvalidSymbol => '기호는 8자 이내로 입력해 주세요.';

  @override
  String get errorInvalidEmoji => '아이콘으로 이모지 하나를 선택해 주세요.';

  @override
  String get errorMemberHasBalance => '삭제하기 전에 이 멤버의 잔액을 정산해 주세요.';

  @override
  String get errorVersionConflict => '수정하는 동안 다른 사람이 이 지출을 변경했어요. 새로고침해 변경 내용을 확인해 주세요.';

  @override
  String get errorSignInRequired => '이 작업을 하려면 로그인해 주세요.';

  @override
  String get errorRateLimited => '요청이 너무 많아요. 1분 후 다시 시도해 주세요.';

  @override
  String get errorNotAMember => '아직 이 그룹의 멤버가 아니에요.';

  @override
  String get errorNotAllowed => '해당 멤버나 그룹 소유자만 이 작업을 할 수 있어요.';

  @override
  String get errorLinkGroupsOff => '이 서버에서는 링크만으로 그룹을 열 수 없어요.';

  @override
  String get errorMemberClaimed => '이미 누군가 이 멤버로 참여했어요.';

  @override
  String get errorMemberLeft => '이 그룹의 멤버가 그룹을 나갔어요.';

  @override
  String get errorInvalidEmail => '이메일 주소를 입력해 주세요.';

  @override
  String get errorInvalidPassword => '8~200자로 입력해 주세요.';

  @override
  String get errorEmailTaken => '해당 이메일로 만든 계정이 이미 있어요. 대신 로그인해 주세요.';

  @override
  String get errorSignupClosed => '이 서버에서는 새 계정을 만들 수 없어요.';

  @override
  String get errorInvalidCredentials => '이메일과 비밀번호가 일치하지 않아요.';

  @override
  String get errorWrongPassword => '현재 비밀번호가 올바르지 않아요.';

  @override
  String get errorAccountsOff => '이 서버에서는 계정을 사용하지 않아요.';

  @override
  String get errorInvalidAmount => '0보다 큰 금액을 입력해 주세요.';

  @override
  String get errorTooManyDecimals => '이 통화에 비해 소수점 이하 자릿수가 너무 많아요.';

  @override
  String get errorAmountTooLarge => '금액이 너무 커요.';

  @override
  String get errorNoShares => '비용을 나눌 멤버를 한 명 이상 선택해 주세요.';

  @override
  String get errorInvalidShare => '각 분담 비율은 숫자여야 해요.';

  @override
  String get errorExactTotal => '금액의 합이 전체 금액과 같아야 해요.';

  @override
  String get errorPayersTotal => '모두가 낸 금액의 합이 전체 금액과 같아야 해요.';

  @override
  String get categoryFood => '음식 및 음료';

  @override
  String get categoryGroceries => '식료품';

  @override
  String get categoryTransport => '교통';

  @override
  String get categoryTravel => '여행';

  @override
  String get categoryLodging => '숙박';

  @override
  String get categoryRent => '월세';

  @override
  String get categoryUtilities => '공과금';

  @override
  String get categoryEntertainment => '여가';

  @override
  String get categoryShopping => '쇼핑';

  @override
  String get categoryHealth => '건강';

  @override
  String get categoryGifts => '선물';

  @override
  String get categoryOther => '기타';

  @override
  String get groupNew => '새 그룹';

  @override
  String get groupSwitch => '그룹 전환';

  @override
  String get groupReorder => '드래그해서 순서 변경';

  @override
  String get groupCreate => '그룹 만들기';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '멤버 $count명', one: '멤버 1명');
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return '받을 돈 $amount';
  }

  @override
  String pillOwe(String amount) {
    return '갚을 돈 $amount';
  }

  @override
  String get pillSettled => '정산 완료';

  @override
  String get groupMissingTitle => '그룹을 찾을 수 없어요';

  @override
  String get groupMissingBody => '그룹이 삭제됐거나 링크가 재설정됐어요. 그룹 멤버에게 새 링크를 요청해 주세요.';

  @override
  String get groupLockedTitle => '로그인해서 그룹 열기';

  @override
  String get groupLockedBody => '이 그룹은 멤버 계정으로만 열 수 있어요. 그룹 멤버의 계정으로 로그인해 주세요.';

  @override
  String get groupForget => '이 기기에서 삭제';

  @override
  String get groupLinkOtherServer => '이 링크는 다른 서버의 링크예요. 해당 서버에 연결해야 열 수 있어요.';

  @override
  String get openLinkTitle => '그룹 링크 열기';

  @override
  String get openLinkBody => '공유받은 링크를 붙여 넣어 그룹에 참여해 보세요.';

  @override
  String get openLinkLabel => '그룹 링크';

  @override
  String get openLinkAction => '열기';

  @override
  String get openLinkInvalid => 'Balnana 그룹 링크가 아닌 것 같아요.';

  @override
  String get groupName => '그룹 이름';

  @override
  String get groupNameHint => '리스본 여행';

  @override
  String get groupCurrency => '통화';

  @override
  String get groupCurrencyHelp => '이 그룹의 모든 지출은 이 통화를 사용해요. 나중에 변경할 수 없어요.';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name. 이 그룹의 모든 지출은 이 통화를 사용해요. 나중에 변경할 수 없어요.';
  }

  @override
  String get currencyChoose => '통화 선택';

  @override
  String get currencySearchHint => '코드나 이름으로 검색';

  @override
  String get currencySuggested => '추천';

  @override
  String get currencyAll => '모든 통화';

  @override
  String currencyUseTyped(String code) {
    return '$code 사용';
  }

  @override
  String get currencyNoMatch => '일치하는 통화가 없어요. 사용하려면 세 글자 통화 코드를 입력해 주세요.';

  @override
  String get groupSymbol => '기호';

  @override
  String get groupSymbolChoose => '기호 선택';

  @override
  String groupSymbolExample(String example) {
    return '금액 표시 예: $example';
  }

  @override
  String get groupColor => '색상';

  @override
  String colorSwatch(int number, int count) {
    return '$count개 중 $number번째 색상';
  }

  @override
  String get groupPeople => '멤버';

  @override
  String get groupYourName => '내 이름';

  @override
  String groupPersonName(int number) {
    return '멤버 $number';
  }

  @override
  String get groupAddPerson => '멤버 추가';

  @override
  String get groupPeopleHelp => '나중에 멤버를 더 추가하거나 링크로 참여하게 할 수 있어요.';

  @override
  String get identityTitle => '누구세요?';

  @override
  String get identityBody => '이름을 선택하면 Balnana가 내가 내야 할 금액을 보여줘요. 이 기기에만 저장돼요.';

  @override
  String get identityNew => '새 멤버로 참여할게요';

  @override
  String get identityNewTitle => '그룹 참여하기';

  @override
  String get identityJoin => '참여';

  @override
  String get identityChange => '내 이름';

  @override
  String get identityNone => '아직 선택 안 함';

  @override
  String get memberName => '이름';

  @override
  String memberYou(String name) {
    return '$name (나)';
  }

  @override
  String get memberAdd => '멤버 추가';

  @override
  String get memberAddTitle => '멤버 추가';

  @override
  String get memberRename => '이름 변경';

  @override
  String get memberRenameTitle => '이름 변경';

  @override
  String memberRemoveTitle(String name) {
    return '$name님을 삭제할까요?';
  }

  @override
  String get memberRemoveBody => '이전 지출에는 남아 있지만 새 지출에는 추가할 수 없어요.';

  @override
  String get groupLinkCopied => '링크를 복사했어요. 링크가 있으면 누구나 이 그룹을 열 수 있어요.';

  @override
  String get groupShare => '링크 공유';

  @override
  String get groupSettings => '그룹 설정';

  @override
  String get groupEdit => '그룹 수정';

  @override
  String get groupSharing => '공유';

  @override
  String get groupCopyLink => '링크 복사';

  @override
  String get groupQrCode => 'QR 코드 보기';

  @override
  String get groupQrCodeHelp => '휴대폰 카메라로 링크를 스캔할 수 있어요.';

  @override
  String groupQrLabel(String group) {
    return '$group 링크의 QR 코드';
  }

  @override
  String get groupCopyLinkHelp => '링크가 있으면 누구나 이 그룹을 보고 수정할 수 있어요.';

  @override
  String get groupCopyLinkHelpAccounts => '링크가 있는 사람은 로그인한 뒤 참여를 요청할 수 있어요.';

  @override
  String get linkAccessTitle => '링크가 있으면 누구나 참여 가능';

  @override
  String get linkAccessHelp => '계정 없이도 그룹을 보고 수정할 수 있게 해요';

  @override
  String get resetLinkTitle => '링크 재설정';

  @override
  String get resetLinkHelp => '새 링크를 만들어요. 이전 링크는 더 이상 작동하지 않아요.';

  @override
  String get resetLinkBody => '모든 사람에게 현재 링크가 더 이상 작동하지 않아요. 계속 접근해야 하는 사람에게 새 링크를 공유해 주세요.';

  @override
  String get resetLinkAction => '재설정';

  @override
  String get resetLinkDone => '링크를 재설정했어요. 새 링크를 공유해 주세요.';

  @override
  String get groupThisDevice => '이 기기';

  @override
  String get groupData => '데이터';

  @override
  String get categoriesTitle => '카테고리';

  @override
  String get categoriesHelp => '직접 카테고리를 추가하거나 사용하지 않는 카테고리를 숨길 수 있어요.';

  @override
  String get categoriesOwn => '이 그룹의 카테고리';

  @override
  String get categoriesOwnEmpty => '아직 그룹 카테고리가 없어요.';

  @override
  String get categoriesBuiltIn => '기본 제공';

  @override
  String get categoriesBuiltInHelp => '숨긴 카테고리는 새 지출에 사용할 수 없어요. 기존 지출의 카테고리는 유지돼요.';

  @override
  String get categoryAdd => '카테고리 추가';

  @override
  String get categoryEdit => '카테고리 수정';

  @override
  String get categoryName => '이름';

  @override
  String get categoryDelete => '카테고리 삭제';

  @override
  String categoryDeleteTitle(String name) {
    return '$name 카테고리를 삭제할까요?';
  }

  @override
  String get categoryDeleteBody => '이 카테고리의 지출은 카테고리 없음으로 표시돼요.';

  @override
  String get categoryDeleteAction => '삭제';

  @override
  String get exportCsv => 'CSV로 내보내기';

  @override
  String get exportCsvHelp => '스프레드시트용으로 모든 지출과 송금을 내보내요';

  @override
  String get exportCsvDone => '내보냈어요';

  @override
  String get forgetTitle => '이 기기에서 삭제';

  @override
  String get forgetHelp => '다른 사람은 서버에서 계속 그룹을 사용할 수 있어요';

  @override
  String get forgetBody => '링크로 다시 열 수 있어요.';

  @override
  String get groupYou => '나';

  @override
  String get leaveTitle => '그룹 나가기';

  @override
  String get leaveHelp => '내 지출은 남아 있고 링크로 다시 참여할 수 있어요';

  @override
  String get leaveBody => '그룹이 내 목록에서 사라져요. 내 지출과 잔액은 그룹에 남아요.';

  @override
  String get leaveAction => '나가기';

  @override
  String get tabExpenses => '지출';

  @override
  String get heroWhoTitle => '이 그룹에서 나는 누구인가요?';

  @override
  String get heroWhoBody => '이름을 선택하면 내가 내야 하거나 받을 금액을 볼 수 있어요.';

  @override
  String get heroWhoAction => '선택';

  @override
  String get heroJoinTitle => '그룹을 보고 있어요';

  @override
  String get heroJoinBody => '지출을 추가하고 내 정산 금액을 보려면 참여해 주세요.';

  @override
  String get joinAction => '참여';

  @override
  String get heroOwed => '받을 돈';

  @override
  String get heroOwe => '내가 낼 돈';

  @override
  String get heroSettled => '정산이 끝났어요';

  @override
  String heroYouAre(String name) {
    return '내 이름: $name';
  }

  @override
  String get expenseAdd => '지출 추가';

  @override
  String get expensesEmptyTitle => '아직 지출이 없어요';

  @override
  String get expensesEmptyBody => '첫 지출을 추가하면 Balnana가 누가 누구에게 얼마를 내야 하는지 계산해요.';

  @override
  String get expensesSearchHint => '제목, 메모, 장소 검색';

  @override
  String get searchClear => '검색 지우기';

  @override
  String get expensesNoMatchTitle => '일치하는 항목이 없어요';

  @override
  String get expensesNoMatchBody => '다른 단어를 검색하거나 필터를 줄여 보세요.';

  @override
  String get filterAnyone => '모두';

  @override
  String get filterAnyCategory => '모든 카테고리';

  @override
  String get filterPayments => '송금';

  @override
  String get filterClear => '필터 지우기';

  @override
  String get periodAll => '전체 기간';

  @override
  String get periodThisMonth => '이번 달';

  @override
  String get periodLastMonth => '지난달';

  @override
  String get periodThisYear => '올해';

  @override
  String get periodPickDays => '날짜 선택…';

  @override
  String get statsTitle => '지출 통계';

  @override
  String get statsTotal => '총 지출';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '지출 $count건', one: '지출 1건');
    return '$_temp0';
  }

  @override
  String get statsByCategory => '카테고리별';

  @override
  String get statsByMember => '멤버별 결제 금액 및 분담액';

  @override
  String get statsPaid => '결제액';

  @override
  String get statsShare => '분담액';

  @override
  String get statsByMonth => '월별';

  @override
  String get statsNoCategory => '카테고리 없음';

  @override
  String get statsEmptyTitle => '지출이 없어요';

  @override
  String get statsEmptyBody => '이 기간에는 지출이 없어요.';

  @override
  String get statsShowExpenses => '이 지출 보기';

  @override
  String get dateToday => '오늘';

  @override
  String get dateYesterday => '어제';

  @override
  String paymentTitle(String from, String to) {
    return '$from님이 $to님에게 송금했어요';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name님이 결제한 금액: $amount';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return '멤버 $count명이 결제한 금액: $amount';
  }

  @override
  String expensePaidByName(String name) {
    return '$name님이 결제했어요';
  }

  @override
  String expensePaidByManyNames(int count) {
    return '멤버 $count명이 결제했어요';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name님이 받은 금액: $amount';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$name님이 받았어요';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return '멤버 $count명이 받았어요';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return '멤버 $count명이 받은 금액: $amount';
  }

  @override
  String get transactionRefund => '환불';

  @override
  String get transactionIncome => '수입';

  @override
  String get paymentDelete => '송금 삭제';

  @override
  String get paymentDeleted => '송금을 삭제했어요';

  @override
  String expenseDeleted(String title) {
    return '“$title” 삭제됨';
  }

  @override
  String get expenseNew => '새 지출';

  @override
  String get expenseEdit => '지출 수정';

  @override
  String get expenseDelete => '삭제';

  @override
  String get expenseAmount => '금액';

  @override
  String get expenseTitle => '무엇에 쓴 돈인가요?';

  @override
  String get expenseTitleHint => '저녁 식사, 티켓, 택시…';

  @override
  String get expenseAmountFromPayers => '모두가 낸 금액의 합계';

  @override
  String expensePaidIn(String currency) {
    return '결제 통화 ($currency)';
  }

  @override
  String expenseRate(String from, String to) {
    return '1 $from = $to';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return '그룹 통화 기준 총액 ($currency)';
  }

  @override
  String expenseForeignHelp(String currency) {
    return '잔액은 $currency로 계산해요. 환율이나 카드 명세서에 나온 환산 금액을 입력해 주세요.';
  }

  @override
  String get expenseNote => '메모';

  @override
  String get expenseNoteHint => '선택 사항';

  @override
  String get expenseLocation => '장소';

  @override
  String get expenseLocationHint => '어디였나요? (선택 사항)';

  @override
  String get locationPickOnMap => '지도에서 선택';

  @override
  String get locationUseCurrent => '현재 위치 사용';

  @override
  String get locationFinding => '위치를 찾는 중…';

  @override
  String get locationChange => '지도에서 변경';

  @override
  String get locationRemovePin => '핀 삭제';

  @override
  String get locationOpenInMaps => '지도 앱에서 열기';

  @override
  String get locationPickTitle => '장소 선택';

  @override
  String get locationPickHint => '지도를 탭해 핀을 놓으세요';

  @override
  String get locationPickDone => '완료';

  @override
  String get locationDenied => 'Balnana에서 위치를 사용할 수 없어요. 기기 또는 브라우저 설정에서 허용할 수 있어요.';

  @override
  String get locationOff => '이 기기에서 위치 기능이 꺼져 있어요.';

  @override
  String get locationUnavailable => '위치를 찾을 수 없어요. 다시 시도하거나 지도에 핀을 놓아 주세요.';

  @override
  String get expenseReceipt => '영수증';

  @override
  String get expenseHasReceipt => '영수증 사진 있음';

  @override
  String get expenseHasLocation => '장소 있음';

  @override
  String get receiptTakePhoto => '사진 찍기';

  @override
  String get receiptChoose => '사진 선택';

  @override
  String get receiptRemove => '삭제';

  @override
  String get receiptView => '영수증 사진';

  @override
  String receiptNotSaved(String reason) {
    return '지출은 저장했지만 영수증 사진은 저장하지 못했어요. $reason';
  }

  @override
  String get expensePaidByLabel => '결제한 사람';

  @override
  String get expenseReceivedForLabel => '수령 대상';

  @override
  String get expenseReceivedByLabel => '받은 사람';

  @override
  String get expenseMultiplePayers => '여러 명';

  @override
  String get expenseSplit => '나누기';

  @override
  String get splitEqual => '똑같이';

  @override
  String get splitExact => '금액별';

  @override
  String get splitShares => '분담 비율';

  @override
  String splitLeft(String amount) {
    return '할당할 금액 $amount';
  }

  @override
  String splitOver(String amount) {
    return '초과 금액 $amount';
  }

  @override
  String get conflictTitle => '다른 곳에서 변경됨';

  @override
  String get conflictReload => '새로고침';

  @override
  String get expenseChangedElsewhere => '다른 사람이 이 지출을 변경했어요. 새로고침하면 상대방의 변경 내용이 적용되고 여기서 수정한 내용은 사라져요.';

  @override
  String get suggestedPayments => '추천 송금';

  @override
  String get allSettled => '모두 정산을 마쳤어요.';

  @override
  String transferYouPay(String name) {
    return '내가 $name님에게 송금';
  }

  @override
  String transferPaysYou(String name) {
    return '$name님이 나에게 송금';
  }

  @override
  String transferPays(String from, String to) {
    return '$from님이 $to님에게 송금';
  }

  @override
  String get recordPayment => '기록';

  @override
  String get recordPaymentTitle => '송금 기록';

  @override
  String get recordPaymentHelp => 'Balnana 밖에서 실제로 송금한 금액만 기록해 주세요.';

  @override
  String get paymentRecorded => '송금을 기록했어요';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who님이 $group 그룹을 만들었어요';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who님이 그룹 정보를 변경했어요';
  }

  @override
  String activityLinkReset(String who) {
    return '$who님이 그룹 링크를 재설정했어요';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who님이 $name님을 추가했어요';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who님이 멤버 이름을 변경했어요: $oldName → $name';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who님이 $name님을 삭제했어요';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who님이 $name 카테고리를 추가했어요';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who님이 카테고리를 변경했어요';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who님이 $name 카테고리를 삭제했어요';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name님이 참여했어요';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who님이 “$title” 지출을 추가했어요 ($amount)';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who님이 “$title” 지출을 수정했어요 ($amount)';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who님이 “$title” 지출을 삭제했어요';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who님이 “$title” 지출을 복원했어요';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who님이 $from님이 $to님에게 보낸 송금을 기록했어요: $amount';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who님이 $amount 송금 기록을 삭제했어요';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who님이 $amount 송금 기록을 복원했어요';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count개', one: '1개');
    return '$who님이 $source에서 항목 $_temp0를 가져왔어요';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who님이 “$title”의 영수증 사진을 추가했어요';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who님이 “$title”의 영수증 사진을 삭제했어요';
  }

  @override
  String activityOther(String who) {
    return '$who님이 변경했어요';
  }

  @override
  String get navGroups => '그룹';

  @override
  String get navActivity => '활동';

  @override
  String get navSettings => '설정';

  @override
  String get groupsEmptyTitle => '아직 그룹이 없어요';

  @override
  String get groupsEmptyBody => '만들거나 링크로 연 그룹이 여기에 표시돼요.';

  @override
  String get groupsNoServerTitle => '서버에 연결하기';

  @override
  String get groupsNoServerBody => 'Balnana는 직접 운영하는 서버 등 원하는 서버에 그룹을 저장해요.';

  @override
  String get groupsNoServerAction => '서버 선택';

  @override
  String get groupsUnreachableTitle => '서버에 연결할 수 없어요';

  @override
  String get groupsUnreachableBody => '연결 상태나 설정의 서버 주소를 확인해 주세요.';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '그룹 $count개를 불러오지 못해 변경 내역이 빠졌어요.',
      one: '그룹 1개를 불러오지 못해 변경 내역이 빠졌어요.',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => '아직 활동이 없어요';

  @override
  String get activityEmptyBody => '그룹에 새 지출과 송금이 생기면 여기에 표시돼요.';

  @override
  String get notFoundTitle => '페이지를 찾을 수 없어요';

  @override
  String get notFoundBody => '이 주소는 Balnana의 페이지가 아니에요.';

  @override
  String get notFoundAction => '그룹으로 이동';

  @override
  String get settingsAppearance => '화면 설정';

  @override
  String get settingsAccount => '계정';

  @override
  String get accountRename => '이름 변경';

  @override
  String get passwordChange => '비밀번호 변경';

  @override
  String get passwordChanged => '비밀번호를 변경했어요. 다른 기기에서는 로그아웃됐어요.';

  @override
  String get passwordSet => '비밀번호 설정';

  @override
  String get passwordSetHelp => '이메일 또는 사용자 이름과 비밀번호로 로그인할 수 있어요.';

  @override
  String get passwordSetDone => '비밀번호를 설정했어요. 다른 기기에서는 로그아웃됐어요.';

  @override
  String get passwordCurrent => '현재 비밀번호';

  @override
  String get passwordNew => '새 비밀번호';

  @override
  String get signOut => '로그아웃';

  @override
  String get accountOAuthLinked => '이 계정으로 로그인할 수 있어요. 탭해서 삭제하세요.';

  @override
  String get accountOAuthAdd => '로그인 방법 추가';

  @override
  String accountOAuthAddTitle(String name) {
    return '$name 추가';
  }

  @override
  String accountOAuthAdded(String name) {
    return '이제 $name(으)로 로그인할 수 있어요.';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return '$name 삭제';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return '다시 추가할 때까지 $name(으)로 로그인할 수 없어요.';
  }

  @override
  String get accountOAuthRemove => '삭제';

  @override
  String accountOAuthRemoved(String name) {
    return '$name 삭제됨';
  }

  @override
  String get confirmEmailTitle => '이메일 확인';

  @override
  String confirmEmailBody(String email) {
    return '이 서버에서는 이메일 확인이 필요해요. $email 주소로 보낸 링크를 열어 주세요.';
  }

  @override
  String get confirmEmailDone => '확인했어요';

  @override
  String get confirmEmailResend => '링크 다시 보내기';

  @override
  String get confirmEmailNotYet => '아직 확인되지 않았어요. 이메일의 링크를 열어 주세요.';

  @override
  String get settingsTheme => '테마';

  @override
  String get themeSystem => '시스템 기본값';

  @override
  String get themeLight => '밝게';

  @override
  String get themeDark => '어둡게';

  @override
  String get settingsDynamicColor => '배경화면 색상';

  @override
  String get settingsDynamicColorSubtitle => 'Balnana 노란색 대신 기기 색상을 사용해요';

  @override
  String get settingsWallpaperGroups => '그룹에 배경화면 색상 적용';

  @override
  String get settingsWallpaperGroupsSubtitle => '각 그룹의 색상 대신 기기 색상을 사용해요';

  @override
  String get settingsPureBlack => '완전한 검정';

  @override
  String get settingsPureBlackSubtitle => 'OLED 화면에 적합한 더 어두운 테마예요';

  @override
  String get settingsMyShare => '내 분담액 표시';

  @override
  String get settingsMyShareSubtitle => '총액 대신 내가 빌려주거나 빌린 금액을 지출에 표시해요';

  @override
  String get settingsLanguage => '언어';

  @override
  String get languageSystem => '시스템 기본값';

  @override
  String get settingsNotifications => '알림';

  @override
  String get settingsNotificationsSubtitle => '내가 참여한 지출이 추가, 변경 또는 삭제될 때 알림을 받아요';

  @override
  String get settingsNotificationsBlocked => '휴대폰 설정에서 차단됐어요. Balnana 알림을 허용하면 알림을 받을 수 있어요.';

  @override
  String get pushChannel => '지출';

  @override
  String get pushChannelDescription => '내가 참여한 지출이 추가, 변경 또는 삭제될 때 알림을 받아요.';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who님이 $title 지출을 추가했어요 · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who님이 $title 지출을 변경했어요 · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who님이 $title 지출을 삭제했어요 · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return '$title 지출이 추가됐어요 · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return '$title 지출이 변경됐어요 · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return '$title 지출이 삭제됐어요 · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payer님이 $payee님에게 $amount 송금했어요';
  }

  @override
  String get settingsConnection => '연결';

  @override
  String get settingsServer => '서버';

  @override
  String get serverNotSet => '설정 안 됨';

  @override
  String get settingsAbout => '정보';

  @override
  String get aboutVersion => '버전';

  @override
  String get aboutLicenses => '오픈소스 라이선스';

  @override
  String get aboutSource => '소스 코드';

  @override
  String get aboutSourceCopied => '브라우저를 열 수 없어 링크를 복사했어요';

  @override
  String get serverTitle => '서버';

  @override
  String get serverIntro => 'Balnana 서버 주소를 입력해 주세요. 누구나 서버를 운영할 수 있으며, 보통 웹 앱을 여는 주소를 사용해요.';

  @override
  String get serverUrlLabel => '서버 주소';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => '연결 테스트';

  @override
  String get serverSaveAnyway => '그래도 저장';

  @override
  String get serverReset => '기본값 사용';

  @override
  String serverDefault(String url) {
    return '기본값: $url';
  }

  @override
  String serverConnected(String version) {
    return 'Balnana $version에 연결됐어요';
  }

  @override
  String get serverModeLink => '비공개 링크로 그룹을 공유해요. 계정은 필요하지 않아요.';

  @override
  String get serverModeAccounts => '계정으로 로그인해요.';

  @override
  String get serverInsecure => '이 주소는 암호화되지 않았어요(http). 네트워크의 다른 사람이 데이터를 볼 수 있어요. 집 밖의 서버에는 https를 사용해 주세요.';

  @override
  String get serverErrorInvalid => 'balnana.example.com처럼 웹 주소를 입력해 주세요.';

  @override
  String get serverErrorUnreachable => '연결할 수 없어요. 주소와 서버 실행 여부를 확인해 주세요.';

  @override
  String get serverErrorNotBalnana => '응답은 받았지만 Balnana 서버가 아니에요.';

  @override
  String get serverSaved => '서버를 저장했어요';

  @override
  String get signIn => '로그인';

  @override
  String get groupSignInTitle => '로그인해서 그룹 열기';

  @override
  String get groupSignInBody => '이 그룹은 멤버만 사용할 수 있어요. 보거나 참여하려면 로그인해 주세요.';

  @override
  String get signInTitle => '다시 오신 걸 환영해요';

  @override
  String get signInBody => '그룹을 보려면 로그인해 주세요.';

  @override
  String get signInNoPassword => '이 서버는 다른 방법으로 로그인해요. 서버 운영자에게 문의해 주세요.';

  @override
  String get registerTitle => '계정 만들기';

  @override
  String get registerBody => '모든 기기에서 그룹을 이용할 수 있어요.';

  @override
  String get registerAction => '계정 만들기';

  @override
  String get registerHaveAccount => '이미 계정이 있어요';

  @override
  String get signInNoAccount => '계정 만들기';

  @override
  String get accountName => '이름';

  @override
  String get accountNameHelp => '그룹 멤버에게 표시되는 이름이에요.';

  @override
  String get accountEmail => '이메일';

  @override
  String get accountPassword => '비밀번호';

  @override
  String get accountPasswordHelp => '8자 이상';

  @override
  String get passwordShow => '비밀번호 표시';

  @override
  String get passwordHide => '비밀번호 숨기기';

  @override
  String get joinPickName => '다른 이름 선택';

  @override
  String joinTitle(String name) {
    return '$name 참여하기';
  }

  @override
  String get joinBody => '여기 있는 멤버 중 한 명인가요? 나를 선택하면 해당 멤버의 지출을 이어받을 수 있어요.';

  @override
  String get joinBodyNew => '지출을 추가하고 잔액을 보려면 참여해 주세요.';

  @override
  String get joinAsNew => '새 멤버로 참여할게요';

  @override
  String joinAsName(String name) {
    return '$name님으로 참여';
  }

  @override
  String joinTaken(String names) {
    return '이미 참여한 멤버: $names';
  }

  @override
  String joinTakenCount(int count) {
    return '이미 멤버 $count명이 참여했어요.';
  }

  @override
  String get commonContinue => '계속';

  @override
  String get errorEmailOff => '이 서버는 이메일을 보내지 않아요.';

  @override
  String get errorInvalidToken => '이 링크는 만료됐거나 이미 사용됐어요.';

  @override
  String get forgotPasswordTitle => '비밀번호를 잊으셨나요?';

  @override
  String get forgotPasswordBody => '새 비밀번호를 설정할 수 있는 링크를 이메일로 보내드릴게요.';

  @override
  String get forgotPasswordAction => '링크 보내기';

  @override
  String get forgotPasswordSent => '해당 이메일의 계정이 있다면 링크를 보냈어요.';

  @override
  String get resetPasswordTitle => '새 비밀번호 설정';

  @override
  String get resetPasswordBody => '모든 기기에서 로그아웃돼요. 그다음 새 비밀번호로 로그인할 수 있어요.';

  @override
  String get resetPasswordAction => '비밀번호 저장';

  @override
  String get resetPasswordDone => '비밀번호를 변경했어요. 새 비밀번호로 로그인해 주세요.';

  @override
  String get verifyEmailTitle => '이메일 확인';

  @override
  String get verifyEmailHelp => '비밀번호를 잊었을 때 재설정할 수 있어요.';

  @override
  String verifyEmailSent(String email) {
    return '$email에서 링크를 확인해 주세요.';
  }

  @override
  String get verifyEmailDone => '이메일 확인 완료';

  @override
  String get verifyEmailDoneBody => '감사해요! 이메일 주소를 확인했어요.';

  @override
  String get verifyEmailFailed => '이메일을 확인할 수 없어요.';

  @override
  String get inviteByEmail => '이메일로 초대';

  @override
  String get inviteByEmailHelp => '참여 링크를 보내세요';

  @override
  String get inviteAs => '다음 멤버로 참여';

  @override
  String get inviteAsHelp => '이 멤버의 지출을 이어받을 수 있어요.';

  @override
  String get inviteAsAnyone => '새 멤버';

  @override
  String get inviteSend => '초대 보내기';

  @override
  String inviteSent(String email) {
    return '초대 이메일을 보냈어요: $email';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name님이 나를 $group 그룹에 초대했어요';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return '$group 그룹에 초대됐어요';
  }

  @override
  String inviteBody(String email) {
    return '$email(으)로 계정을 만들어 참여하거나, 계정이 있다면 로그인해 주세요.';
  }

  @override
  String get inviteBodySignedIn => '지출을 추가하고 잔액을 보려면 참여해 주세요.';

  @override
  String get inviteAction => '초대 열기';

  @override
  String get inviteMissingTitle => '초대 링크가 작동하지 않아요';

  @override
  String get inviteMissingBody => '만료됐거나 이미 사용됐을 수 있어요. 새 초대를 요청해 주세요.';

  @override
  String get joinInvitedAs => '이 멤버로 초대받았어요';

  @override
  String signInWith(String provider) {
    return '$provider(으)로 계속';
  }

  @override
  String get signInOr => '또는';

  @override
  String get oauthFailedTitle => '로그인할 수 없어요';

  @override
  String get oauthPendingTitle => '이 이메일로 이미 계정이 있어요';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider에서 $email이 본인 이메일이라고 확인했지만, 해당 이메일의 계정은 아직 확인되지 않았어요. 어떻게 할까요?';
  }

  @override
  String get oauthPendingLink => '기존 계정에 추가';

  @override
  String get oauthPendingLinkHelp => '해당 계정의 비밀번호를 입력해 주세요. 기존 비밀번호는 계속 사용할 수 있어요.';

  @override
  String get oauthPendingTakeOver => '계정 이어받기';

  @override
  String get oauthPendingTakeOverHelp => '해당 계정의 비밀번호와 다른 로그인 방법이 삭제되고, 로그인된 모든 기기에서 로그아웃돼요.';

  @override
  String get oauthPendingNew => '새 계정 만들기';

  @override
  String oauthPendingNewHelp(String email) {
    return '기존 계정의 그룹은 유지되지만 $email은 더 이상 연결되지 않아요.';
  }

  @override
  String get oauthPendingPassword => '해당 계정의 비밀번호';

  @override
  String get oauthPendingWrongPassword => '비밀번호가 올바르지 않아요.';

  @override
  String get oauthOtherServer => '이 로그인은 현재 선택한 서버가 아닌 다른 서버에서 시작됐어요. 다시 로그인해 주세요.';

  @override
  String get oauthBackToSignIn => '로그인으로 돌아가기';

  @override
  String get errorOAuthFailed => '로그인하지 못했어요. 다시 시도해 주세요.';

  @override
  String get errorEmailHasAccount => '이 이메일로 만든 계정이 이미 있어요. 해당 계정에 로그인한 뒤 설정에서 이 로그인 방법을 추가해 주세요.';

  @override
  String get errorIdentityTaken => '이 로그인 방법은 이미 다른 계정에 연결되어 있어요.';

  @override
  String get errorLastSignInMethod => '사용 가능한 로그인 방법이 이것뿐이에요. 먼저 비밀번호를 설정하거나 다른 로그인 방법을 추가해 주세요.';

  @override
  String get errorEmailUnverified => '먼저 이메일을 확인해 주세요.';

  @override
  String get errorOAuthCancelled => '로그인이 취소됐어요.';

  @override
  String get importTitle => 'Settle Up에서 가져오기';

  @override
  String get importAction => '가져오기';

  @override
  String get importIntro =>
      'Settle Up에서 그룹을 CSV 파일로 내보낸 뒤 여기서 파일을 선택해 주세요. 지출, 송금, 모든 멤버가 함께 가져와지고 잔액은 그대로 유지돼요.';

  @override
  String get importChooseFile => 'CSV 파일 선택';

  @override
  String get importChooseOther => '다른 파일 선택';

  @override
  String get importReading => '파일을 읽는 중…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(expenses, locale: localeName, other: '지출 $expenses건', one: '지출 1건');
    String _temp1 = intl.Intl.pluralLogic(payments, locale: localeName, other: '송금 $payments건', one: '송금 1건');
    return '$_temp0, $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return '$from~$to';
  }

  @override
  String importCurrency(String currency) {
    return '통화: $currency. 다른 통화로 된 항목은 Settle Up에서 환산한 금액을 사용해요.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '금액이 0인 항목 $count개를 제외했어요.',
      one: '금액이 0인 항목 1개를 제외했어요.',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => '어느 멤버인가요?';

  @override
  String get importUntitled => '제목 없음';

  @override
  String get errorImportFile => 'Settle Up CSV 내보내기 파일이 아닌 것 같아요.';

  @override
  String get errorImportCurrency => '환율 정보가 없는 항목이 없어 그룹 통화를 확인할 수 없어요.';

  @override
  String get errorImportTooBig => '가져오기에는 파일이 너무 커요.';

  @override
  String get errorBadImage => '이 사진은 사용할 수 없어요. JPEG, PNG 또는 WebP 이미지를 선택해 주세요.';

  @override
  String get errorReceiptTooBig => '사진이 너무 커요. 10MB 미만의 사진을 선택해 주세요.';

  @override
  String get errorImportMe => '내가 누구인지 선택해 주세요.';

  @override
  String errorImportRow(int line, String reason) {
    return '파일의 $line번째 줄을 가져올 수 없어요: $reason';
  }

  @override
  String get errorImportAmount => '금액을 읽을 수 없어요.';

  @override
  String get errorImportCounts => '이름과 금액이 일치하지 않아요.';

  @override
  String get errorImportDate => '날짜를 읽을 수 없어요.';

  @override
  String get errorImportType => '유형은 지출, 송금 또는 수입이어야 해요.';

  @override
  String get errorImportTransfer => '송금에는 보내는 사람과 받는 사람이 각각 한 명씩 있어야 해요.';

  @override
  String get errorImportRowCurrency => '환율 정보가 없는 다른 통화로 된 항목이에요.';

  @override
  String get adminSetupTitle => '이 서버 설정하기';

  @override
  String get adminSetupBody =>
      '관리자 비밀번호를 설정해 주세요. 이 페이지에는 서버 설정이 있으며 비밀번호로 보호돼요. 사용자 이름은 없어요. 비밀번호를 아는 사람은 누구나 설정을 변경할 수 있어요.';

  @override
  String get adminSetupCode => '설정 코드';

  @override
  String get adminSetupCodeHelp =>
      '이 서버에는 이미 데이터가 있어서 시작할 때 로그에 설정 코드를 출력했어요. Docker를 사용하는 경우: docker compose logs balnana';

  @override
  String get adminSetupAction => '비밀번호 설정';

  @override
  String get adminPassword => '관리자 비밀번호';

  @override
  String get adminPasswordRepeat => '비밀번호 다시 입력';

  @override
  String get adminPasswordMismatch => '비밀번호가 일치하지 않아요.';

  @override
  String get adminLoginTitle => '관리자 페이지';

  @override
  String get adminLoginBody => '서버 설정을 변경하려면 관리자 비밀번호를 입력해 주세요.';

  @override
  String get adminLoginAction => '로그인';

  @override
  String get adminSettingsTitle => '서버 설정';

  @override
  String get adminSaved => '설정을 저장했어요. 바로 적용돼요.';

  @override
  String get adminSaveFailed => '저장되지 않았어요. 강조 표시된 설정을 확인해 주세요.';

  @override
  String get adminChangePassword => '관리자 비밀번호 변경';

  @override
  String get adminPasswordCurrent => '현재 비밀번호';

  @override
  String get adminPasswordNew => '새 비밀번호';

  @override
  String get adminPasswordChanged => '비밀번호를 변경했어요. 다른 관리자 세션은 로그아웃됐어요.';

  @override
  String get adminSignOut => '관리자 로그아웃';

  @override
  String get adminBackHome => 'Balnana로 돌아가기';

  @override
  String get adminRequireEmail => '이메일 주소 필수';

  @override
  String get adminRequireEmailHelp => '끄면 사용자 이름으로 가입할 수 있고 이메일은 입력하지 않아도 돼요. 둘 중 하나로 로그인할 수 있어요.';

  @override
  String get adminRequireEmailUnused => '현재 꺼져 있는 이메일 및 비밀번호 로그인에만 적용돼요.';

  @override
  String get accountUsername => '사용자 이름';

  @override
  String get accountUsernameHelp => '영문자, 숫자, 마침표, 하이픈, 밑줄을 3~32자로 입력해 주세요. 이 이름으로 로그인해요.';

  @override
  String get accountEmailOptional => '이메일 (선택 사항)';

  @override
  String get accountEmailOptionalHelp => '그룹 초대를 받고 잊어버린 비밀번호를 재설정할 때 사용해요.';

  @override
  String get accountLogin => '이메일 또는 사용자 이름';

  @override
  String get errorInvalidUsername => '영문자, 숫자, 마침표, 하이픈, 밑줄을 3~32자로 입력해 주세요. 영문자나 숫자로 시작해야 해요.';

  @override
  String get errorUsernameTaken => '이미 사용 중인 사용자 이름이에요.';

  @override
  String get adminDiscardTitle => '변경사항을 취소할까요?';

  @override
  String get adminDiscardBody => '설정 변경사항이 저장되지 않았어요.';

  @override
  String get adminDiscard => '취소';

  @override
  String adminLocked(String key) {
    return '서버에서 $key(으)로 설정됨';
  }

  @override
  String adminDefault(String value) {
    return '기본값: $value';
  }

  @override
  String get adminSecretSaved => '저장했어요. 바꾸려면 새 값을 입력해 주세요.';

  @override
  String get adminSecretRemoved => '저장하면 삭제돼요.';

  @override
  String get adminSecretRemove => '저장된 값 삭제';

  @override
  String get adminSectionGeneral => '일반';

  @override
  String get adminSectionAccess => '접근';

  @override
  String get adminSectionMaps => '지도';

  @override
  String get adminSectionAccounts => '계정';

  @override
  String get adminSectionAccountsBody => '접근 방식이 계정으로 설정된 경우에 적용돼요.';

  @override
  String get adminSectionEmail => '이메일 (SMTP)';

  @override
  String get adminSectionEmailBody => '주소 확인, 비밀번호 재설정, 초대에 사용해요.';

  @override
  String get adminSmtpOn => '이메일 보내기';

  @override
  String get adminSectionGoogle => 'Google 로그인';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Google Cloud 콘솔에서 $url을(를) 리디렉션 URI로 등록해 주세요.';
  }

  @override
  String get adminGoogleOn => 'Google 로그인 제공';

  @override
  String get adminGoogleOnHelp => 'Google 계정으로 로그인할 수 있어요.';

  @override
  String get adminSectionOidc => 'OpenID Connect 로그인';

  @override
  String adminSectionOidcBody(String url) {
    return '제공자의 리디렉션 URI로 $url을(를) 등록해 주세요.';
  }

  @override
  String get adminOidcHelp => 'Authentik, Keycloak, Dex 같은 OpenID Connect 제공자를 사용할 수 있어요. 원하는 만큼 추가할 수 있어요.';

  @override
  String get adminOidcAdd => '제공자 추가';

  @override
  String get adminOidcRemove => '제공자 삭제';

  @override
  String get adminOidcNew => '새 제공자';

  @override
  String get adminOidcId => 'ID';

  @override
  String get adminOidcIdHelp => '소문자, 숫자, 하이픈을 사용해 주세요. 리디렉션 URI에 포함되며 나중에 변경할 수 없어요.';

  @override
  String get adminOidcIdInvalid => '소문자, 숫자, 하이픈을 최대 32자로 입력해 주세요. 소문자나 숫자로 시작해야 해요.';

  @override
  String get adminOidcIdTaken => '이 ID를 사용하는 제공자가 이미 있어요.';

  @override
  String get adminTrustEmail => '이메일 주소 신뢰';

  @override
  String get adminGoogleTrustEmailHelp =>
      '계정에 등록된 이메일로 Google 로그인을 하면 해당 계정에 로그인해요. 끄면 비밀번호로 로그인한 뒤 설정에서 Google을 추가해야 해요.';

  @override
  String get adminOidcTrustEmailHelp =>
      '이메일 확인을 신뢰할 수 있는 본인 운영 또는 신뢰하는 제공자에만 사용하세요. 끄면 계정 멤버는 비밀번호로 로그인한 뒤 설정에서 추가해야 해요.';

  @override
  String get adminRequireVerified => '확인된 이메일 필수';

  @override
  String get adminRequireVerifiedHelp =>
      '이메일을 확인해야 계정을 사용할 수 있어요. 같은 이메일을 사용하는 신뢰된 로그인은 미확인 계정을 이어받아요. 끄면 사용자가 직접 선택해요.';

  @override
  String get adminRequireVerifiedUnused => '이메일 발송을 설정해야 해요.';

  @override
  String get adminSectionAndroid => 'Android 앱 링크';

  @override
  String get adminSectionAndroidBody =>
      '이 서버용으로 만든 Android 앱은 서버 링크를 앱에서 열어요. 확인을 건너뛰려면 앱 서명에 사용한 인증서의 SHA-256 지문을 입력해 주세요.';

  @override
  String get adminSectionAdmin => '관리자';

  @override
  String get adminPublicUrl => '공개 주소';

  @override
  String get adminPublicUrlHelp => '사람들이 이 서버에 접속할 때 사용하는 주소예요. 그룹 및 이메일 링크를 만들 때 사용해요.';

  @override
  String get adminSourceUrl => '소스 코드 링크';

  @override
  String get adminSourceUrlHelp => '수정한 버전을 운영할 때 라이선스(AGPL-3.0)에서 요구하는 서버 소스 코드 링크예요.';

  @override
  String get adminAuthMode => '접근 방식';

  @override
  String get adminAuthModeLink => '그룹 링크';

  @override
  String get adminAuthModeLinkHelp => '로그인하지 않아도 그룹 비공개 링크만 있으면 돼요.';

  @override
  String get adminAuthModeAccounts => '계정';

  @override
  String get adminAuthModeAccountsHelp => '로그인해야 해요. 링크는 로그인한 사람만 그룹에 참여하게 해요.';

  @override
  String get adminPasswordLogin => '이메일 및 비밀번호 로그인';

  @override
  String get adminPasswordForced => 'Google 또는 OpenID Connect 로그인을 켜야 비활성화할 수 있어요. 로그인 방법이 항상 하나는 있어야 해요.';

  @override
  String get adminSignup => '계정을 만들 수 있는 사람';

  @override
  String get adminSignupOpen => '누구나';

  @override
  String get adminSignupOpenHelp => '이 서버에 접속할 수 있는 사람은 누구나 가입할 수 있어요.';

  @override
  String get adminSignupInvite => '초대받은 사람';

  @override
  String get adminSignupInviteHelp =>
      '그룹에 이메일로 초대된 사람만 초대받은 주소로 가입할 수 있어요. 그룹 링크만으로는 참여할 수 없어요. 초대를 사용하려면 이메일을 켜야 해요.';

  @override
  String get adminSignupClosed => '가입 불가';

  @override
  String get adminSignupClosedHelp => '아무도 가입할 수 없어요. 기존 계정은 계속 사용할 수 있어요.';

  @override
  String get adminSignupHelp => '첫 계정은 언제든 만들 수 있어요.';

  @override
  String get adminLinkGroups => '링크로 그룹 열기 허용';

  @override
  String get adminLinkGroupsHelp => '그룹 소유자가 로그인 없이도 링크가 있는 사람을 참여시킬 수 있어요.';

  @override
  String get adminSmtpHost => '메일 서버';

  @override
  String get adminSmtpPort => '포트';

  @override
  String get adminSmtpUser => '사용자 이름';

  @override
  String get adminSmtpPassword => '비밀번호';

  @override
  String get adminSmtpFrom => '보내는 사람';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => '클라이언트 ID';

  @override
  String get adminClientSecret => '클라이언트 비밀 키';

  @override
  String get adminOidcIssuer => '발급자 URL';

  @override
  String get adminOidcName => '버튼 이름';

  @override
  String get adminOidcNameHelp => '로그인 페이지에 “...으로 계속”으로 표시돼요.';

  @override
  String get adminFingerprints => '인증서 지문';

  @override
  String get adminFingerprintsHelp =>
      'SHA-256 지문을 쉼표로 구분해 입력해 주세요. keytool -list -v 및 apksigner verify --print-certs 명령으로 확인할 수 있어요.';

  @override
  String get adminInvalidValue => '올바른 값이 아니에요.';

  @override
  String get adminInvalidUrl => 'https:// 또는 http://로 시작하는 전체 주소를 입력해 주세요.';

  @override
  String get adminInvalidFrom => 'Balnana <balnana@example.com>처럼 이메일 주소가 포함된 보내는 사람을 입력해 주세요.';

  @override
  String get adminInvalidPort => '1~65535 사이의 포트 번호를 입력해 주세요.';

  @override
  String get adminInvalidRequired => '이 로그인 제공자에 필요한 값이에요.';

  @override
  String get adminInvalidFingerprint => 'SHA-256 지문을 입력해 주세요. 각각 16진수 64자리이며 콜론을 사용할 수 있어요.';

  @override
  String get adminNeedsSignIn => '계정에 로그인 방법이 필요해요. 이메일 및 비밀번호 로그인을 켜거나 제공자를 설정해 주세요.';

  @override
  String get adminLockedChange => '서버에서 설정한 값은 여기서 변경할 수 없어요.';

  @override
  String get errorAdminRequired => '관리자 세션이 종료됐어요. 다시 로그인해 주세요.';

  @override
  String get errorAdminWrongPassword => '비밀번호가 올바르지 않아요.';

  @override
  String get errorInvalidSetupCode => '설정 코드가 올바르지 않아요. 서버 로그에서 확인해 주세요.';

  @override
  String get errorAlreadySetUp => '이 서버는 이미 설정됐어요. 관리자 비밀번호로 로그인해 주세요.';

  @override
  String get linkOpening => '링크 여는 중…';

  @override
  String get linkForeignTitle => '다른 서버의 링크예요';

  @override
  String linkForeignBody(String server) {
    return '이 앱은 $server에 연결되어 있지만 링크는 다른 서버의 링크예요. 설정에서 서버를 변경한 뒤 열어 주세요.';
  }

  @override
  String get linkInvalidTitle => '이 링크를 열 수 없어요';

  @override
  String get linkInvalidBody => '이 앱에서 지원하는 Balnana 링크가 아니에요.';

  @override
  String get linkGoHome => '그룹으로 이동';

  @override
  String get linkOpenInBrowser => '브라우저에서 열기';

  @override
  String get privacyTitle => '개인정보 처리방침';

  @override
  String get privacyIntro =>
      'Balnana는 오픈소스 소프트웨어예요. 앱이 연결된 서버를 운영하는 사람(운영자)이 데이터 저장 위치를 정하고 관리해요. 이 페이지에서는 소프트웨어가 저장하고 처리하는 정보를 설명해요.';

  @override
  String get privacyStoredTitle => '저장되는 정보';

  @override
  String get privacyStoredBody =>
      '만들거나 참여한 그룹의 이름, 멤버 이름, 지출, 송금, 메모, 영수증 사진, 지출에 추가한 장소가 저장돼요. 계정을 사용하면 이름, 이메일 주소 또는 사용자 이름, 비밀번호 해시(비밀번호 자체는 저장하지 않음), Google 같은 로그인 제공자도 저장돼요. 알림을 켜면 기기 식별자와 푸시 서비스에서 제공한 주소도 저장돼요.';

  @override
  String get privacyUseTitle => '정보 사용 방법';

  @override
  String get privacyUseBody =>
      '앱을 운영하는 데만 사용해요. 각 그룹을 멤버에게 보여주고 잔액을 계산하며, 이메일 확인, 비밀번호 재설정, 초대 등 앱에 필요한 이메일과 알림을 보내요. 광고나 분석 기능은 없으며 데이터를 판매하지 않아요.';

  @override
  String get privacySharedTitle => '정보를 볼 수 있는 사람';

  @override
  String get privacySharedBody =>
      '그룹 멤버는 그룹의 멤버, 지출, 내역을 볼 수 있어요. 링크로 공개된 그룹은 링크가 있는 누구나 열 수 있어요. Google 로그인은 Google을 통해 처리돼요. 운영자가 알림을 켜면 휴대폰에서 사용하는 푸시 서비스인 Google Firebase Cloud Messaging 또는 설치한 ntfy 같은 UnifiedPush 서비스로 알림이 전송돼요. 알림 내용은 전송 중 암호화돼요. 지도는 운영자가 선택한 지도 제공업체에서 이미지를 불러와요. 기본값은 OpenFreeMap이며, 제공업체는 네트워크 주소와 조회한 지역을 알 수 있어요. 내 위치는 “현재 위치 사용”을 탭할 때만 읽고, 이후 저장하기로 한 위치만 저장해요.';

  @override
  String get privacyDeviceTitle => '이 기기에서';

  @override
  String get privacyDeviceBody => '앱은 오프라인에서 사용할 수 있도록 서버 주소, 설정, 그룹 사본을 보관해요. 앱을 삭제하면 이 정보도 삭제돼요.';

  @override
  String get privacyDeleteTitle => '데이터 삭제';

  @override
  String get privacyDeleteBody =>
      '설정에서 계정을 삭제할 수 있어요. 그룹의 잔액 계산이 맞도록 내 이름은 미확인 멤버로 남고, 다른 사람이 접근할 수 없는 그룹은 함께 삭제돼요. 그룹 소유자는 그룹 설정에서 그룹 전체를 삭제할 수 있어요. 그 외 문의는 서버 운영자에게 해 주세요.';

  @override
  String get privacyOperatorPolicy => '운영자의 개인정보 처리방침';

  @override
  String get privacyLink => '개인정보';

  @override
  String get accountEmailAdd => '이메일 주소 추가';

  @override
  String get accountEmailChange => '이메일 주소 변경';

  @override
  String get accountEmailNew => '이메일 주소';

  @override
  String get accountEmailVerifyNote => '새 이메일 주소를 확인할 링크를 보내드려요. 확인 전까지 현재 주소는 유지돼요.';

  @override
  String get accountEmailPendingTitle => '새 이메일 확인';

  @override
  String accountEmailPendingHelp(String email) {
    return '보낸 링크를 열면 현재 이메일 주소가 $email(으)로 변경돼요. 탭해서 링크를 다시 보내세요.';
  }

  @override
  String get accountEmailRemoveNote => '비워 두면 이메일 주소가 삭제돼요. 사용자 이름으로 계속 로그인할 수 있어요.';

  @override
  String get accountEmailSaved => '이메일 주소를 저장했어요';

  @override
  String get accountEmailRemoved => '이메일 주소를 삭제했어요';

  @override
  String get accountConfirmPassword => '비밀번호';

  @override
  String get accountConfirmPasswordHelp => '본인 확인에 필요해요.';

  @override
  String get errorEmailNeeded => '이메일 주소로 로그인하므로 삭제할 수 없어요.';

  @override
  String get accountDelete => '계정 삭제';

  @override
  String get accountDeleteHelp => '이 서버에서 계정을 삭제해요';

  @override
  String get accountDeleteTitle => '계정을 삭제할까요?';

  @override
  String get accountDeleteBody =>
      '계정이 영구 삭제되고 로그아웃돼요. 잔액 계산이 맞도록 그룹에서 내 이름은 미확인 멤버로 남아요. 다른 멤버가 없는 그룹은 삭제돼요.';

  @override
  String get accountDeleteAction => '영구 삭제';

  @override
  String get accountDeleted => '계정을 삭제했어요.';

  @override
  String get accountDeletePageSignedOut => '이 서버에서 계정을 삭제하려면 로그인해 주세요.';

  @override
  String get accountDeletePageLinkMode =>
      '이 서버에는 계정이 없어요. 그룹 링크만 있으면 누구나 이용할 수 있어요. 모든 내용과 함께 그룹을 삭제하려면 그룹 설정을 열고 그룹 삭제를 선택하세요.';

  @override
  String get groupDelete => '그룹 삭제';

  @override
  String get groupDeleteHelp => '모든 멤버의 그룹과 지출을 삭제해요';

  @override
  String groupDeleteTitle(String name) {
    return '$name 그룹을 삭제할까요?';
  }

  @override
  String get groupDeleteBody => '그룹과 모든 지출, 송금, 내역이 모두에게서 삭제돼요. 되돌릴 수 없어요. 확인하려면 그룹 이름을 입력해 주세요.';

  @override
  String get groupDeleteName => '그룹 이름';

  @override
  String get groupDeleteAction => '영구 삭제';

  @override
  String get groupDeleted => '그룹을 삭제했어요';

  @override
  String get groupDeleteOwnerOnly => '그룹 소유자만 삭제할 수 있어요.';

  @override
  String get expenseDiscardTitle => '변경사항을 취소할까요?';

  @override
  String get expenseDiscardBody => '이 지출의 변경사항이 저장되지 않았어요.';

  @override
  String get expenseDiscard => '취소';

  @override
  String get adminPrivacyUrl => '개인정보 처리방침 링크';

  @override
  String get adminPrivacyUrlHelp => '앱 스토어에서 요청하는 개인정보 처리방침 링크예요. 비워 두면 Balnana가 저장하는 정보를 설명하는 일반 방침을 표시해요.';

  @override
  String get adminMapTiles => '지도 타일';

  @override
  String get adminMapSource => '지도 제공 방식';

  @override
  String get adminMapSourceStyle => '벡터 스타일';

  @override
  String get adminMapSourceStyleHelp => '무료이며 키가 필요 없는 OpenFreeMap 같은 MapLibre 스타일로 지도를 표시해요.';

  @override
  String get adminMapSourceTiles => '래스터 타일';

  @override
  String get adminMapSourceTilesHelp => 'OpenStreetMap처럼 지도 이미지를 타일로 표시해요.';

  @override
  String get adminMapSourceOff => '사용 안 함';

  @override
  String get adminMapSourceOffHelp => '지도를 표시하지 않아요. 지출에는 장소 이름과 좌표가 계속 저장돼요.';

  @override
  String get adminMapStyle => '스타일 URL';

  @override
  String get adminMapStyleHelp =>
      '기본값인 OpenFreeMap의 Liberty, Bright 또는 Positron처럼 MapLibre style.json의 주소를 입력해 주세요.';

  @override
  String get adminMapTilesHelp =>
      'z, x, y를 중괄호 안에 넣은 래스터 타일 URL 템플릿을 입력해 주세요. 기본값을 예로 들 수 있어요. OpenStreetMap 자체 서버는 가벼운 사용만 허용하므로, 사용량이 많은 서버는 타일 제공업체를 이용해야 해요.';

  @override
  String get adminMapAttribution => '지도 출처 표시';

  @override
  String get adminMapAttributionHelp =>
      '지도 제공업체의 요청에 따라 모든 지도에 표시돼요. 비워 두면 스타일에 지정된 출처가 표시되고 타일에는 OpenStreetMap 출처가 표시돼요.';

  @override
  String get adminInvalidMapTiles => 'z, x, y가 중괄호로 표시된 http(s) URL 템플릿을 입력해 주세요.';

  @override
  String get adminUsers => '계정';

  @override
  String get adminUsersSearch => '이름, 이메일 또는 사용자 이름으로 검색';

  @override
  String adminUsersShown(int shown, int total) {
    return '계정 $total개 중 $shown개';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '계정 $count개', one: '계정 1개');
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => '일치하는 계정이 없어요.';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '그룹 $count개',
      one: '그룹 1개',
      zero: '그룹 없음',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => '미확인';

  @override
  String adminUserDeleteTitle(String name) {
    return '$name님의 계정을 삭제할까요?';
  }

  @override
  String get adminUserDeleteBody =>
      '계정이 영구 삭제되고 모든 기기에서 로그아웃돼요. 그룹 잔액 계산이 맞도록 이름은 미확인 멤버로 남고, 다른 멤버가 없는 그룹은 삭제돼요.';

  @override
  String get adminUserDeleted => '계정을 삭제했어요';

  @override
  String get commonDone => '완료';

  @override
  String get crowdSearch => '멤버 검색';

  @override
  String get crowdNoMatch => '일치하는 멤버가 없어요.';

  @override
  String get crowdAll => '모두';

  @override
  String get crowdNone => '없음';

  @override
  String crowdChosen(int count, int total) {
    return '전체 $total명 중 $count명 선택';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count명 더 보기', one: '1명 더 보기');
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => '접기';

  @override
  String get crowdSort => '정렬';

  @override
  String crowdShowAll(int count) {
    return '$count명 모두 보기';
  }

  @override
  String get crowdBalances => '모두의 잔액';

  @override
  String get crowdSomeoneElse => '다른 사람';

  @override
  String get crowdChoosePayers => '결제한 사람 선택';

  @override
  String get crowdFilterTitle => '누구의 지출인가요?';

  @override
  String get myGroupsTitle => '내 그룹 링크';

  @override
  String get myGroupsExport => '내 그룹 내보내기';

  @override
  String get myGroupsExportHelp => '백업하거나 다른 기기로 옮길 수 있도록 그룹 링크를 복사해요.';

  @override
  String get myGroupsPrivate => '이 링크는 비공개로 보관해 주세요. 링크가 있으면 누구나 그룹을 열 수 있어요.';

  @override
  String get myGroupsCopy => '링크 복사';

  @override
  String get myGroupsImport => '그룹 가져오기';

  @override
  String get myGroupsImportHelp => '이 서버의 그룹 링크를 한 줄에 하나씩 붙여 넣어 주세요. 기존 그룹은 목록 위치와 정보가 유지돼요.';

  @override
  String get myGroupsLinks => '그룹 링크';

  @override
  String get myGroupsImportAction => '링크 가져오기';

  @override
  String get myGroupsInvalid => '올바른 그룹 링크를 한 줄에 하나씩 입력해 주세요. 아무것도 가져오지 않았어요.';

  @override
  String get myGroupsServerChanged => '선택한 서버가 변경됐어요. 이 창을 닫고 링크가 속한 서버에서 가져와 주세요.';

  @override
  String myGroupsLimit(int count) {
    return '서버마다 그룹 링크를 최대 $count개까지 저장할 수 있어요. 아무것도 가져오지 않았어요.';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '새 그룹 링크 $count개를 가져왔어요.',
      one: '새 그룹 링크 1개를 가져왔어요.',
      zero: '이 그룹은 이미 저장되어 있어요.',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => '반복';

  @override
  String get repeatNever => '반복 안 함';

  @override
  String get repeatDaily => '매일';

  @override
  String get repeatWeekly => '매주';

  @override
  String get repeatMonthly => '매월';

  @override
  String get repeatYearly => '매년';

  @override
  String get repeatEvery => '반복 간격';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '일', one: '일');
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '주', one: '주');
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '개월', one: '개월');
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '년', one: '년');
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count일마다', one: '매일');
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count주마다', one: '매주');
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count개월마다', one: '매월');
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count년마다', one: '매년');
    return '$_temp0';
  }

  @override
  String get repeatEndNone => '종료일 없음';

  @override
  String repeatEndOn(String date) {
    return '$date까지';
  }

  @override
  String get repeatEndClear => '종료일 삭제';

  @override
  String get repeatHelp => '위 날짜부터 설정한 날짜마다 그룹에 자동으로 추가돼요. 지난 날짜의 지출도 저장하면 추가돼요.';

  @override
  String get repeatDropReceiptTitle => '영수증을 삭제할까요?';

  @override
  String get repeatDropReceiptBody => '반복 지출에는 영수증을 첨부할 수 없어요. 대신 생성된 각 지출에 영수증을 추가할 수 있어요.';

  @override
  String get repeatDropReceiptAction => '반복 설정';

  @override
  String get recurringTitle => '반복 지출';

  @override
  String get recurringHelp => '정해진 일정에 따라 자동으로 추가되는 지출';

  @override
  String get recurringEmptyTitle => '반복 지출이 없어요';

  @override
  String get recurringEmptyBody => '월세, 구독료 등 반복되는 비용을 정해진 날짜마다 자동으로 추가할 수 있어요.';

  @override
  String get recurringAdd => '반복 지출 추가';

  @override
  String get recurringEdit => '반복 지출 수정';

  @override
  String recurringNext(String date) {
    return '다음 추가일: $date';
  }

  @override
  String get recurringPaused => '일시중지됨';

  @override
  String get recurringEnded => '종료됨';

  @override
  String get recurringPause => '일시중지';

  @override
  String get recurringResume => '다시 시작';

  @override
  String get recurringActive => '반복 중';

  @override
  String get recurringDelete => '삭제';

  @override
  String get recurringDeleteTitle => '반복을 중단할까요?';

  @override
  String recurringDeleteBody(String title) {
    return '“$title” 지출을 더 이상 추가하지 않아요. 이미 추가된 지출은 유지돼요.';
  }

  @override
  String get recurringDeleted => '반복 지출을 삭제했어요';

  @override
  String get recurringFromSchedule => '반복 지출에서 추가됨';

  @override
  String get recurringOpen => '일정 변경';

  @override
  String get recurringMissing => '반복 지출이 삭제됐거나 더 이상 사용할 수 없어요.';

  @override
  String get errorTooManyDue => '시작일이 너무 오래전이에요. 한 번에 100건이 넘는 지출이 추가돼요.';

  @override
  String get errorInvalidEnd => '종료일은 시작일보다 빠를 수 없어요.';

  @override
  String get errorInvalidRepeat => '반복 간격은 1~999로 설정해 주세요(일, 주, 개월, 년).';

  @override
  String get errorRecurringConflict => '수정하는 동안 다른 사람이 이 반복 지출을 변경했어요. 새로고침해 변경 내용을 확인해 주세요.';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$who님이 “$title” 지출을 반복하도록 설정했어요';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$who님이 “$title” 반복 지출을 변경했어요';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$who님이 “$title” 반복 지출을 일시중지했어요';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return '멤버가 그룹을 나가 “$title” 반복 지출이 일시중지됐어요';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return '추가할 수 없어 “$title” 반복 지출이 일시중지됐어요';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$who님이 “$title” 반복 지출을 다시 시작했어요';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$who님이 “$title” 반복 지출을 중단했어요';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return '“$title” 지출이 자동으로 추가됐어요 ($amount)';
  }

  @override
  String get expenseRecurring => '반복 지출에서 자동 추가됨';

  @override
  String get adminPlans => '요금제';

  @override
  String get adminPayments => '결제';

  @override
  String get adminSectionBilling => '요금제와 결제';

  @override
  String get adminSectionBillingBody => '요금제는 이 서버에 저장할 수 있는 양의 한도를 높여요. 비용 나누기와 정산은 언제나 무료예요.';

  @override
  String get adminBillingOn => '요금제와 한도';

  @override
  String get adminBillingOnHelp => '끄면 이 서버는 아무것도 제한하지 않고 요금제도 표시하지 않아요.';

  @override
  String get adminBillingNeedsAccounts => '요금제에는 계정이 필요해요. 먼저 접근 방식을 계정으로 바꿔 주세요.';

  @override
  String get adminKofiUrl => 'Ko-fi 페이지';

  @override
  String get adminKofiUrlHelp => '결제하러 가는 페이지예요. 외부 결제를 허용하는 빌드에서만 연결돼요.';

  @override
  String adminKofiWebhook(String url) {
    return 'Ko-fi에 입력할 웹훅 URL: $url';
  }

  @override
  String get adminKofiToken => 'Ko-fi 인증 토큰';

  @override
  String get adminKofiTokenHelp => 'Ko-fi의 웹훅 페이지에 표시돼요. 없으면 이 서버는 Ko-fi를 무시해요.';

  @override
  String adminUserPlanUntil(String plan, String date) {
    return '$plan, $date까지';
  }

  @override
  String get adminPlansHelp => '새 한도는 앞으로 추가하는 항목에 적용되고 기존 항목은 그대로 남아요. 비워 두면 한도가 없어요.';

  @override
  String get adminPlanAdd => '요금제 추가';

  @override
  String adminPlanDefaultName(String name) {
    return '$name (기본)';
  }

  @override
  String adminPlanLimit(String label, String value) {
    return '$label: $value';
  }

  @override
  String adminPlanDays(int count) {
    return '일수: $count';
  }

  @override
  String get adminProductsSection => '상품';

  @override
  String get adminProductsHelp => '결제는 먼저 티어 이름이 같은 상품에, 없으면 티어 이름이 없고 금액을 충족하는 상품에 연결돼요.';

  @override
  String get adminProductAdd => '상품 추가';

  @override
  String get adminProductEdit => '상품 수정';

  @override
  String adminProductAnyPayment(String amount) {
    return '$amount 이상의 모든 결제';
  }

  @override
  String get adminProductName => '티어 이름';

  @override
  String get adminProductNameHelp => 'Ko-fi에 적힌 그대로 입력하세요. 비워 두면 일회성·월간 결제를 금액으로 판단해요.';

  @override
  String get adminProductPlan => '요금제';

  @override
  String get adminProductDays => '일수';

  @override
  String get adminProductDaysHelp => '결제 한 번의 유효 기간이에요. 다시 결제하면 남은 기간에 더해져요.';

  @override
  String get adminProductMinAmount => '최소 금액';

  @override
  String get adminProductCurrency => '통화 코드';

  @override
  String get adminPlanId => 'ID';

  @override
  String get adminPlanIdHelp => '영문 소문자, 숫자, 하이픈만 사용할 수 있어요. 나중에 바꿀 수 없어요.';

  @override
  String get adminPlanName => '이름';

  @override
  String get adminPlanRank => '순위';

  @override
  String get adminPlanRankHelp => '계정에 요금제가 여러 개 있으면 순위가 가장 높은 요금제가 적용돼요.';

  @override
  String get adminPlanDefault => '기본 요금제';

  @override
  String get adminPlanDefaultHelp => '다른 요금제가 없는 모든 계정에 적용돼요.';

  @override
  String get adminEntitlementGranted => '관리자가 제공';

  @override
  String get adminEntitlementRevoked => '취소됨';

  @override
  String get adminEntitlementForever => '종료일 없음';

  @override
  String adminEntitlementUntil(String date) {
    return '$date까지';
  }

  @override
  String adminEntitlementEnded(String date) {
    return '$date에 종료됨';
  }

  @override
  String get adminEntitlementsEmpty => '이 계정에는 아직 요금제가 없어요.';

  @override
  String get adminEntitlementRevoke => '취소';

  @override
  String get adminEntitlementNote => '메모';

  @override
  String get adminEntitlementGrant => '요금제 제공';

  @override
  String get adminPaymentApplied => '적용됨';

  @override
  String get adminPaymentUnclaimed => '미확인';

  @override
  String get adminPaymentUnmatched => '연결 안 됨';

  @override
  String get adminPaymentsAll => '전체';

  @override
  String adminPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '결제 $count건');
    return '$_temp0';
  }

  @override
  String get adminPaymentsEmpty => '결제가 없어요.';

  @override
  String get adminPaymentAssigned => '계정에 요금제를 제공했어요.';

  @override
  String get adminPaymentAssign => '계정에 제공';

  @override
  String get adminPaymentPickUser => '계정을 선택해 주세요.';

  @override
  String get errorBillingOff => '이 서버에는 요금제가 없어요.';

  @override
  String get errorAlreadySponsored => '이 그룹에는 이미 다른 멤버의 요금제가 적용되어 있어요.';

  @override
  String get errorPlanInUse => '이 요금제를 사용하는 계정이나 상품이 있어요.';

  @override
  String get errorPaymentApplied => '이 결제는 이미 적용되었어요.';

  @override
  String get errorInvalidPlan => '요금제 설정을 확인해 주세요. 올바르지 않은 내용이 있어요.';

  @override
  String errorLimitReceipts(int max) {
    return '이 그룹의 영수증 사진이 한도인 $max장에 도달했어요.';
  }

  @override
  String errorLimitRecurring(int max) {
    return '이 그룹의 반복 지출이 한도인 $max건에 도달했어요.';
  }

  @override
  String errorLimitOwnGroups(int max) {
    return '그룹이 한도인 $max개에 도달했어요.';
  }

  @override
  String errorLimitSponsored(int max) {
    return '요금제는 최대 $max개 그룹에만 공유할 수 있어요.';
  }

  @override
  String get errorLimitOther => '이 서버의 한도에 도달했어요.';

  @override
  String get planTitle => '요금제';

  @override
  String get planUnlimited => '한도 없음';

  @override
  String planUntil(String date) {
    return '$date까지';
  }

  @override
  String get planSettingsHelp => '이 서버가 보관하는 내용';

  @override
  String get planIntro => '비용 나누기와 정산은 언제나 무료예요. 요금제는 이 서버에 보관할 수 있는 양만 바꿔요.';

  @override
  String planUsage(int used, int limit) {
    return '$used / $limit';
  }

  @override
  String planUsed(int used) {
    return '$used개 사용 중';
  }

  @override
  String get planLimits => '한도';

  @override
  String get planLimitReceipts => '그룹당 영수증 사진';

  @override
  String get planLimitRecurring => '그룹당 반복 지출';

  @override
  String get planLimitOwnGroups => '내가 만든 그룹';

  @override
  String get planLimitSponsored => '내 요금제를 공유하는 그룹';

  @override
  String get planGet => '요금제 받기';

  @override
  String get planKofi => 'Ko-fi';

  @override
  String get planKofiHelp => '계정의 확인된 이메일로 결제하거나, 결제에 쓰는 주소를 아래에 추가하세요.';

  @override
  String get planPaymentEmailConfirmed => '이 주소의 결제가 내 계정에 반영돼요';

  @override
  String get planPaymentEmailAdd => '결제 이메일 추가';

  @override
  String get planPaymentEmailHelp => '본인 주소인지 확인하는 링크를 보내 드려요.';

  @override
  String get paymentEmailDone => '주소가 확인되었어요';

  @override
  String get paymentEmailDoneBody => '이제 이 주소의 결제가 내 계정에 반영돼요.';

  @override
  String groupPlanUsage(String receipts, String recurring) {
    return '영수증 사진: $receipts · 반복 지출: $recurring';
  }

  @override
  String get groupSponsor => '이 그룹에 내 요금제 공유';

  @override
  String get groupUnsponsor => '요금제 공유 중지';

  @override
  String groupSponsoredBy(String name) {
    return '$name의 요금제 사용 중';
  }

  @override
  String get accountDeletePlayNote => 'Google Play 구독은 계정을 삭제해도 끝나지 않습니다. 먼저 Google Play에서 해지하세요.';

  @override
  String get planPlayManage => '구독 관리';

  @override
  String get planPlayManageHelp => 'Google Play에서 변경 또는 해지';

  @override
  String planPlayPrice(int months, String price) {
    String _temp0 = intl.Intl.pluralLogic(months, locale: localeName, other: '$months개월마다', one: '매월');
    return '$_temp0 $price';
  }

  @override
  String get planPlayFailed => 'Google Play에서 구매를 완료하지 못했습니다.';

  @override
  String get planPlayPending => '결제를 처리 중입니다. 완료되면 요금제가 시작됩니다.';

  @override
  String get errorInvalidPurchase => 'Google Play에서 이 구매를 확인할 수 없습니다.';

  @override
  String get errorPlayOtherAccount => '이 구독은 다른 계정의 것입니다. 그 계정으로 로그인하거나 Google Play에서 해지하세요.';

  @override
  String get errorPlayUnavailable => 'Google Play에 연결할 수 없습니다. 잠시 후 다시 시도하세요.';

  @override
  String get adminPlayPackage => 'Google Play 패키지 이름';

  @override
  String get adminPlayPackageHelp => 'Google Play에서의 앱 ID입니다. 아래 서비스 계정과 함께 설정하면 Google Play 구독이 켜집니다.';

  @override
  String get adminPlayServiceAccount => 'Google Play 서비스 계정';

  @override
  String get adminPlayServiceAccountHelp => 'Play Console에서 주문과 구독을 보고 관리할 수 있는 서비스 계정의 JSON 키입니다.';

  @override
  String get adminPlayPushAccount => 'Pub/Sub 푸시 계정';

  @override
  String get adminPlayPushAccountHelp =>
      'Pub/Sub가 전송에 서명할 때 쓰는 서비스 계정 이메일입니다. 없으면 갱신은 누군가 요금제 페이지를 열 때만 도착합니다.';

  @override
  String adminPlayWebhook(String url) {
    return 'Pub/Sub 푸시 엔드포인트(대상도 동일): $url';
  }

  @override
  String get adminProductProvider => '결제 수단';

  @override
  String get adminProductPlayId => '상품 ID';

  @override
  String get adminProductPlayIdHelp =>
      'Play Console에 적힌 그대로 입력하세요. 각 결제의 종료일은 Google Play가 정하므로 일수는 설정하지 않습니다.';
}
