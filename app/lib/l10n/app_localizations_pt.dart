// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get languageEndonym => 'Português';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonRetry => 'Tentar de novo';

  @override
  String get offlineBar =>
      'Offline. Exibindo o que este dispositivo salvou; não é possível salvar alterações até você se reconectar.';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonClear => 'Limpar';

  @override
  String get iconChoose => 'Escolher um ícone';

  @override
  String get iconNone => 'Sem ícone';

  @override
  String get iconSearchHint => 'Buscar ou digitar um emoji';

  @override
  String get iconUseTyped => 'Usar este emoji';

  @override
  String get iconNoMatch => 'Nenhum ícone encontrado. Digite um emoji para usar.';

  @override
  String get iconSectionTravel => 'Viagens e lugares';

  @override
  String get iconSectionFood => 'Comida e bebida';

  @override
  String get iconSectionActivities => 'Atividades';

  @override
  String get iconSectionHome => 'Casa e contas';

  @override
  String get iconSectionPeople => 'Pessoas';

  @override
  String get iconSectionNature => 'Animais e natureza';

  @override
  String get iconSectionObjects => 'Dinheiro e objetos';

  @override
  String get iconSectionSymbols => 'Símbolos';

  @override
  String get commonRemove => 'Remover';

  @override
  String get commonUndo => 'Desfazer';

  @override
  String get someone => 'Alguém';

  @override
  String get errorTooLarge => 'O arquivo é grande demais para enviar ao servidor.';

  @override
  String get errorBusy => 'O servidor está ocupado. Tente de novo em instantes.';

  @override
  String get errorTimeout => 'O envio demorou demais. Verifique sua conexão e tente de novo.';

  @override
  String get errorBadOrigin =>
      'O servidor não aceita acessos deste endereço. Quem administra o servidor deve verificar a URL pública.';

  @override
  String get errorInvalidCategory => 'Essa categoria foi excluída. Escolha outra.';

  @override
  String get errorBuiltinCategory => 'Só é possível ocultar categorias predefinidas.';

  @override
  String get errorUnknownMember => 'Alguém deste grupo não faz mais parte dele. Recarregue e tente de novo.';

  @override
  String get errorNoPayers => 'Escolha quem pagou.';

  @override
  String get errorPayerTotal => 'A soma do que cada pessoa pagou precisa ser igual ao valor total.';

  @override
  String get errorPayerTooSmall =>
      'A parte paga por alguém fica abaixo de um centavo na moeda do grupo. Confira os valores.';

  @override
  String get errorInvalidNote => 'A observação é longa demais ou contém caracteres que não podem ser salvos.';

  @override
  String get errorInvalidDate => 'Essa data está fora do intervalo permitido.';

  @override
  String get errorGeneric => 'Algo deu errado. Tente de novo.';

  @override
  String get errorNetwork => 'Não foi possível acessar o servidor. Verifique sua conexão.';

  @override
  String get errorNotFound => 'Isso não existe mais.';

  @override
  String get errorRequired => 'Obrigatório';

  @override
  String get errorInvalidName => 'Digite um nome com até 100 caracteres.';

  @override
  String get errorDuplicateName => 'Alguém neste grupo já tem esse nome.';

  @override
  String get errorTooManyMembers => 'Este grupo já atingiu o limite de pessoas.';

  @override
  String get errorTooManyCategories => 'Este grupo já atingiu o limite de categorias.';

  @override
  String get errorDuplicateCategory => 'Este grupo já tem uma categoria com esse nome.';

  @override
  String get errorInvalidCurrency => 'Digite o código de três letras de uma moeda, como USD.';

  @override
  String get errorInvalidTitle => 'Digite um título com até 200 caracteres.';

  @override
  String get errorInvalidLocation => 'Digite o nome de um lugar em uma linha, com até 200 caracteres.';

  @override
  String get errorInvalidSymbol => 'Digite um símbolo com até 8 caracteres.';

  @override
  String get errorInvalidEmoji => 'Escolha um único emoji para o ícone.';

  @override
  String get errorMemberHasBalance => 'Acerte o saldo desta pessoa antes de removê-la.';

  @override
  String get errorVersionConflict =>
      'Outra pessoa alterou esta despesa enquanto você a editava. Recarregue para ver as alterações.';

  @override
  String get errorSignInRequired => 'Entre na sua conta para fazer isso.';

  @override
  String get errorRateLimited => 'Muitas solicitações. Aguarde um minuto e tente de novo.';

  @override
  String get errorNotAMember => 'Você ainda não faz parte deste grupo.';

  @override
  String get errorNotAllowed => 'Só essa pessoa ou o dono do grupo pode fazer isso.';

  @override
  String get errorLinkGroupsOff => 'Este servidor não permite abrir grupos apenas com o link.';

  @override
  String get errorMemberClaimed => 'Alguém já entrou como essa pessoa.';

  @override
  String get errorMemberLeft => 'Alguém deste grupo saiu.';

  @override
  String get errorInvalidEmail => 'Digite um endereço de e-mail.';

  @override
  String get errorInvalidPassword => 'Use de 8 a 200 caracteres.';

  @override
  String get errorEmailTaken => 'Já existe uma conta com esse e-mail. Entre na sua conta.';

  @override
  String get errorSignupClosed => 'Este servidor não está aceitando novas contas.';

  @override
  String get errorInvalidCredentials => 'O e-mail e a senha não correspondem.';

  @override
  String get errorWrongPassword => 'Sua senha atual está incorreta.';

  @override
  String get errorAccountsOff => 'Este servidor não usa contas.';

  @override
  String get errorInvalidAmount => 'Digite um valor maior que zero.';

  @override
  String get errorTooManyDecimals => 'Há casas decimais demais para esta moeda.';

  @override
  String get errorAmountTooLarge => 'Esse valor é grande demais.';

  @override
  String get errorNoShares => 'Escolha pelo menos uma pessoa para dividir o custo.';

  @override
  String get errorInvalidShare => 'Cada parte precisa ser um número.';

  @override
  String get errorExactTotal => 'A soma dos valores precisa ser igual ao total.';

  @override
  String get errorPayersTotal => 'A soma do que todos pagaram precisa ser igual ao total.';

  @override
  String get categoryFood => 'Comida e bebida';

  @override
  String get categoryGroceries => 'Mercado';

  @override
  String get categoryTransport => 'Transporte';

  @override
  String get categoryTravel => 'Viagem';

  @override
  String get categoryLodging => 'Hospedagem';

  @override
  String get categoryRent => 'Aluguel';

  @override
  String get categoryUtilities => 'Contas da casa';

  @override
  String get categoryEntertainment => 'Entretenimento';

  @override
  String get categoryShopping => 'Compras';

  @override
  String get categoryHealth => 'Saúde';

  @override
  String get categoryGifts => 'Presentes';

  @override
  String get categoryOther => 'Outros';

  @override
  String get groupNew => 'Novo grupo';

  @override
  String get groupSwitch => 'Trocar de grupo';

  @override
  String get groupReorder => 'Arraste para reordenar';

  @override
  String get groupCreate => 'Criar grupo';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
      zero: '$count pessoas',
    );
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return 'Você tem a receber $amount';
  }

  @override
  String pillOwe(String amount) {
    return 'Você deve $amount';
  }

  @override
  String get pillSettled => 'Tudo acertado';

  @override
  String get groupMissingTitle => 'Grupo não encontrado';

  @override
  String get groupMissingBody =>
      'Este grupo foi excluído ou o link foi redefinido. Peça o novo link a alguém do grupo.';

  @override
  String get groupLockedTitle => 'Entre para abrir este grupo';

  @override
  String get groupLockedBody =>
      'Este grupo só pode ser acessado pelas contas dos seus membros. Entre na conta que faz parte dele.';

  @override
  String get groupForget => 'Remover deste dispositivo';

  @override
  String get groupLinkOtherServer => 'Este link é de outro servidor. Conecte-se a ele para abrir o grupo.';

  @override
  String get openLinkTitle => 'Abrir link de grupo';

  @override
  String get openLinkBody => 'Cole um link que alguém compartilhou com você para entrar no grupo.';

  @override
  String get openLinkLabel => 'Link do grupo';

  @override
  String get openLinkAction => 'Abrir';

  @override
  String get openLinkInvalid => 'Esse não parece ser um link de grupo do Balnana.';

  @override
  String get groupName => 'Nome do grupo';

  @override
  String get groupNameHint => 'Viagem a Lisboa';

  @override
  String get groupCurrency => 'Moeda';

  @override
  String get groupCurrencyHelp =>
      'Todas as despesas deste grupo usam esta moeda. Não será possível alterá-la depois.';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name. Todas as despesas deste grupo usam esta moeda. Não será possível alterá-la depois.';
  }

  @override
  String get currencyChoose => 'Escolher moeda';

  @override
  String get currencySearchHint => 'Buscar por código ou nome';

  @override
  String get currencySuggested => 'Sugeridas';

  @override
  String get currencyAll => 'Todas as moedas';

  @override
  String currencyUseTyped(String code) {
    return 'Usar $code';
  }

  @override
  String get currencyNoMatch => 'Nenhuma moeda encontrada. Digite o código de três letras para usar.';

  @override
  String get groupSymbol => 'Símbolo';

  @override
  String get groupSymbolChoose => 'Escolher símbolo';

  @override
  String groupSymbolExample(String example) {
    return 'Os valores aparecem assim: $example';
  }

  @override
  String get groupColor => 'Cor';

  @override
  String colorSwatch(int number, int count) {
    return 'Cor $number de $count';
  }

  @override
  String get groupPeople => 'Pessoas';

  @override
  String get groupYourName => 'Seu nome';

  @override
  String groupPersonName(int number) {
    return 'Pessoa $number';
  }

  @override
  String get groupAddPerson => 'Adicionar pessoa';

  @override
  String get groupPeopleHelp => 'Você pode adicionar mais pessoas depois, ou elas podem entrar pelo link.';

  @override
  String get identityTitle => 'Quem é você?';

  @override
  String get identityBody =>
      'Escolha seu nome para o Balnana mostrar o que você deve. Só este dispositivo vai se lembrar dele.';

  @override
  String get identityNew => 'Sou uma pessoa nova';

  @override
  String get identityNewTitle => 'Entrar neste grupo';

  @override
  String get identityJoin => 'Entrar';

  @override
  String get identityChange => 'Quem é você';

  @override
  String get identityNone => 'Ainda não escolhido';

  @override
  String get memberName => 'Nome';

  @override
  String memberYou(String name) {
    return '$name (você)';
  }

  @override
  String get memberAdd => 'Adicionar pessoa';

  @override
  String get memberAddTitle => 'Adicionar alguém';

  @override
  String get memberRename => 'Renomear';

  @override
  String get memberRenameTitle => 'Renomear';

  @override
  String memberRemoveTitle(String name) {
    return 'Remover $name?';
  }

  @override
  String get memberRemoveBody =>
      'A pessoa continuará nas despesas antigas, mas não poderá ser incluída em novas.';

  @override
  String get groupLinkCopied => 'Link copiado. Qualquer pessoa com ele pode abrir este grupo.';

  @override
  String get groupShare => 'Compartilhar link';

  @override
  String get groupSettings => 'Configurações do grupo';

  @override
  String get groupEdit => 'Editar grupo';

  @override
  String get groupSharing => 'Compartilhamento';

  @override
  String get groupCopyLink => 'Copiar link';

  @override
  String get groupQrCode => 'Mostrar código QR';

  @override
  String get groupQrCodeHelp => 'As pessoas podem escanear o link com a câmera do celular.';

  @override
  String groupQrLabel(String group) {
    return 'Código QR do link para $group';
  }

  @override
  String get groupCopyLinkHelp => 'Qualquer pessoa com o link pode ver e editar este grupo.';

  @override
  String get groupCopyLinkHelpAccounts =>
      'Quem tiver o link pode pedir para entrar depois de acessar a conta.';

  @override
  String get linkAccessTitle => 'Aberto para qualquer pessoa com o link';

  @override
  String get linkAccessHelp => 'Permitir que as pessoas vejam e editem sem uma conta';

  @override
  String get resetLinkTitle => 'Redefinir link';

  @override
  String get resetLinkHelp => 'Criar um link novo; o antigo vai parar de funcionar';

  @override
  String get resetLinkBody =>
      'O link atual vai parar de funcionar para todo mundo. Compartilhe o novo link com quem deve continuar tendo acesso.';

  @override
  String get resetLinkAction => 'Redefinir';

  @override
  String get resetLinkDone => 'Link redefinido. Compartilhe o novo.';

  @override
  String get groupThisDevice => 'Este dispositivo';

  @override
  String get groupData => 'Dados';

  @override
  String get categoriesTitle => 'Categorias';

  @override
  String get categoriesHelp => 'Adicione suas próprias categorias ou oculte as que não usa';

  @override
  String get categoriesOwn => 'Deste grupo';

  @override
  String get categoriesOwnEmpty => 'Este grupo ainda não tem categorias próprias.';

  @override
  String get categoriesBuiltIn => 'Predefinidas';

  @override
  String get categoriesBuiltInHelp =>
      'Categorias ocultas não aparecem nas novas despesas. As despesas que já as usam continuam com elas.';

  @override
  String get categoryAdd => 'Adicionar categoria';

  @override
  String get categoryEdit => 'Editar categoria';

  @override
  String get categoryName => 'Nome';

  @override
  String get categoryDelete => 'Excluir categoria';

  @override
  String categoryDeleteTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String get categoryDeleteBody => 'As despesas desta categoria ficarão sem categoria.';

  @override
  String get categoryDeleteAction => 'Excluir';

  @override
  String get exportCsv => 'Exportar como CSV';

  @override
  String get exportCsvHelp => 'Todas as despesas e pagamentos, em uma planilha';

  @override
  String get exportCsvDone => 'Exportado';

  @override
  String get forgetTitle => 'Remover deste dispositivo';

  @override
  String get forgetHelp => 'O grupo continuará no servidor para as outras pessoas';

  @override
  String get forgetBody => 'Você pode abri-lo de novo pelo link.';

  @override
  String get groupYou => 'Você';

  @override
  String get leaveTitle => 'Sair do grupo';

  @override
  String get leaveHelp => 'Suas despesas continuam no grupo; você pode voltar pelo link';

  @override
  String get leaveBody =>
      'O grupo vai desaparecer da sua lista. Suas despesas e seu saldo continuarão no grupo.';

  @override
  String get leaveAction => 'Sair';

  @override
  String get tabExpenses => 'Despesas';

  @override
  String get heroWhoTitle => 'Quem é você neste grupo?';

  @override
  String get heroWhoBody => 'Escolha seu nome para ver o que você deve e o que devem a você.';

  @override
  String get heroWhoAction => 'Escolher';

  @override
  String get heroJoinTitle => 'Você está vendo este grupo';

  @override
  String get heroJoinBody => 'Entre no grupo para adicionar despesas e ver o que você deve.';

  @override
  String get joinAction => 'Entrar';

  @override
  String get heroOwed => 'Você tem a receber';

  @override
  String get heroOwe => 'Você deve';

  @override
  String get heroSettled => 'Está tudo acertado';

  @override
  String heroYouAre(String name) {
    return 'Você é $name';
  }

  @override
  String get expenseAdd => 'Adicionar despesa';

  @override
  String get expensesEmptyTitle => 'Ainda não há despesas';

  @override
  String get expensesEmptyBody => 'Adicione a primeira e o Balnana calcula quem deve a quem.';

  @override
  String get expensesSearchHint => 'Buscar títulos, observações e lugares';

  @override
  String get searchClear => 'Limpar busca';

  @override
  String get expensesNoMatchTitle => 'Nada encontrado';

  @override
  String get expensesNoMatchBody => 'Tente outras palavras ou use menos filtros.';

  @override
  String get filterAnyone => 'Qualquer pessoa';

  @override
  String get filterAnyCategory => 'Qualquer categoria';

  @override
  String get filterPayments => 'Pagamentos';

  @override
  String get filterClear => 'Limpar filtros';

  @override
  String get periodAll => 'Todo o período';

  @override
  String get periodThisMonth => 'Este mês';

  @override
  String get periodLastMonth => 'Mês passado';

  @override
  String get periodThisYear => 'Este ano';

  @override
  String get periodPickDays => 'Escolher datas…';

  @override
  String get statsTitle => 'Gastos';

  @override
  String get statsTotal => 'Total gasto';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count despesas',
      one: '1 despesa',
      zero: '$count despesas',
    );
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'Por categoria';

  @override
  String get statsByMember => 'Valor pago e dividido por pessoa';

  @override
  String get statsPaid => 'Pago';

  @override
  String get statsShare => 'Parte';

  @override
  String get statsByMonth => 'Por mês';

  @override
  String get statsNoCategory => 'Sem categoria';

  @override
  String get statsEmptyTitle => 'Nenhum gasto';

  @override
  String get statsEmptyBody => 'Não há despesas neste período.';

  @override
  String get statsShowExpenses => 'Mostrar estas despesas';

  @override
  String get dateToday => 'Hoje';

  @override
  String get dateYesterday => 'Ontem';

  @override
  String paymentTitle(String from, String to) {
    return '$from pagou para $to';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name pagou $amount';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return '$count pessoas pagaram $amount';
  }

  @override
  String expensePaidByName(String name) {
    return '$name pagou';
  }

  @override
  String expensePaidByManyNames(int count) {
    return '$count pessoas pagaram';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name recebeu $amount';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$name recebeu';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return '$count pessoas receberam';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return '$count pessoas receberam $amount';
  }

  @override
  String get transactionRefund => 'Reembolso';

  @override
  String get transactionIncome => 'Receita';

  @override
  String get paymentDelete => 'Excluir pagamento';

  @override
  String get paymentDeleted => 'Pagamento excluído';

  @override
  String expenseDeleted(String title) {
    return 'Despesa “$title” excluída';
  }

  @override
  String get expenseNew => 'Nova despesa';

  @override
  String get expenseEdit => 'Editar despesa';

  @override
  String get expenseDelete => 'Excluir';

  @override
  String get expenseAmount => 'Valor';

  @override
  String get expenseTitle => 'O que foi?';

  @override
  String get expenseTitleHint => 'Jantar, ingressos, táxi…';

  @override
  String get expenseAmountFromPayers => 'Soma do que todos pagaram';

  @override
  String expensePaidIn(String currency) {
    return 'Pago em $currency';
  }

  @override
  String expenseRate(String from, String to) {
    return '1 $from em $to';
  }

  @override
  String expenseInGroupCurrency(String currency) {
    return 'Total em $currency';
  }

  @override
  String expenseForeignHelp(String currency) {
    return 'Os saldos continuam em $currency. Digite a taxa de câmbio ou o valor convertido, por exemplo, o da fatura do cartão.';
  }

  @override
  String get expenseNote => 'Observação';

  @override
  String get expenseNoteHint => 'Opcional';

  @override
  String get expenseLocation => 'Local';

  @override
  String get expenseLocationHint => 'Onde foi? (opcional)';

  @override
  String get locationPickOnMap => 'Escolher no mapa';

  @override
  String get locationUseCurrent => 'Usar localização atual';

  @override
  String get locationFinding => 'Procurando sua localização…';

  @override
  String get locationChange => 'Alterar no mapa';

  @override
  String get locationRemovePin => 'Remover marcador';

  @override
  String get locationOpenInMaps => 'Abrir no Maps';

  @override
  String get locationPickTitle => 'Escolher um local';

  @override
  String get locationPickHint => 'Toque no mapa para colocar um marcador';

  @override
  String get locationPickDone => 'Concluído';

  @override
  String get locationDenied =>
      'O Balnana não tem permissão para acessar sua localização. Você pode permitir isso nas configurações do dispositivo ou navegador.';

  @override
  String get locationOff => 'A localização está desativada neste dispositivo.';

  @override
  String get locationUnavailable =>
      'Não foi possível encontrar sua localização. Tente de novo ou coloque um marcador no mapa.';

  @override
  String get expenseReceipt => 'Comprovante';

  @override
  String get expenseHasReceipt => 'Tem foto do comprovante';

  @override
  String get expenseHasLocation => 'Tem localização';

  @override
  String get receiptTakePhoto => 'Tirar foto';

  @override
  String get receiptChoose => 'Escolher uma imagem';

  @override
  String get receiptRemove => 'Remover';

  @override
  String get receiptView => 'Foto do comprovante';

  @override
  String receiptNotSaved(String reason) {
    return 'A despesa foi salva, mas a foto do comprovante não. $reason';
  }

  @override
  String get expensePaidByLabel => 'Pago por';

  @override
  String get expenseReceivedForLabel => 'Em benefício de';

  @override
  String get expenseReceivedByLabel => 'Recebido por';

  @override
  String get expenseMultiplePayers => 'Várias pessoas';

  @override
  String get expenseSplit => 'Divisão';

  @override
  String get splitEqual => 'Igualmente';

  @override
  String get splitExact => 'Valores';

  @override
  String get splitShares => 'Cotas';

  @override
  String splitLeft(String amount) {
    return 'Faltam $amount para dividir';
  }

  @override
  String splitOver(String amount) {
    return '$amount a mais';
  }

  @override
  String get conflictTitle => 'Alterada em outro lugar';

  @override
  String get conflictReload => 'Recarregar';

  @override
  String get expenseChangedElsewhere =>
      'Outra pessoa alterou esta despesa. Ao recarregar, você verá a versão dela e perderá suas alterações.';

  @override
  String get suggestedPayments => 'Pagamentos sugeridos';

  @override
  String get allSettled => 'Todo mundo acertou as contas.';

  @override
  String transferYouPay(String name) {
    return 'Você paga $name';
  }

  @override
  String transferPaysYou(String name) {
    return '$name paga a você';
  }

  @override
  String transferPays(String from, String to) {
    return '$from paga $to';
  }

  @override
  String get recordPayment => 'Registrar';

  @override
  String get recordPaymentTitle => 'Registrar pagamento';

  @override
  String get recordPaymentHelp => 'Registre apenas valores que foram realmente pagos fora do Balnana.';

  @override
  String get paymentRecorded => 'Pagamento registrado';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who criou $group';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who alterou os detalhes do grupo';
  }

  @override
  String activityLinkReset(String who) {
    return '$who redefiniu o link do grupo';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who adicionou $name';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who mudou o nome de $oldName para $name';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who removeu $name';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who adicionou a categoria $name';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who alterou as categorias';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who excluiu a categoria $name';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name entrou no grupo';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who adicionou “$title” ($amount)';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who editou “$title” ($amount)';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who excluiu “$title”';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who restaurou “$title”';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who registrou que $from pagou $to $amount';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who excluiu um pagamento de $amount';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who restaurou um pagamento de $amount';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lançamentos',
      one: '1 lançamento',
      zero: '$count lançamentos',
    );
    return '$who importou $_temp0 de $source';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who adicionou uma foto de comprovante a “$title”';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who removeu a foto de comprovante de “$title”';
  }

  @override
  String activityOther(String who) {
    return '$who fez uma alteração';
  }

  @override
  String get navGroups => 'Grupos';

  @override
  String get navActivity => 'Atividade';

  @override
  String get navSettings => 'Configurações';

  @override
  String get groupsEmptyTitle => 'Ainda não há grupos';

  @override
  String get groupsEmptyBody => 'Os grupos que você criar ou abrir por um link vão aparecer aqui.';

  @override
  String get groupsNoServerTitle => 'Conecte-se a um servidor';

  @override
  String get groupsNoServerBody =>
      'O Balnana mantém seus grupos em um servidor que você escolher, como um servidor próprio.';

  @override
  String get groupsNoServerAction => 'Escolher servidor';

  @override
  String get groupsUnreachableTitle => 'Não foi possível acessar o servidor';

  @override
  String get groupsUnreachableBody => 'Verifique sua conexão ou o endereço do servidor em Configurações.';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível carregar $count grupos, então algumas alterações não aparecem.',
      one: 'Não foi possível carregar um grupo, então algumas alterações não aparecem.',
      zero: 'Não foi possível carregar $count grupos, então algumas alterações não aparecem.',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => 'Ainda não há nada aqui';

  @override
  String get activityEmptyBody => 'Novas despesas e pagamentos dos seus grupos vão aparecer aqui.';

  @override
  String get notFoundTitle => 'Página não encontrada';

  @override
  String get notFoundBody => 'Este endereço não leva a nenhuma página do Balnana.';

  @override
  String get notFoundAction => 'Ir para grupos';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsAccount => 'Conta';

  @override
  String get accountRename => 'Alterar nome';

  @override
  String get passwordChange => 'Alterar senha';

  @override
  String get passwordChanged => 'Senha alterada. Você saiu da sua conta nos outros dispositivos.';

  @override
  String get passwordSet => 'Criar senha';

  @override
  String get passwordSetHelp => 'Entre também com seu e-mail ou nome de usuário e uma senha';

  @override
  String get passwordSetDone => 'Senha criada. Você saiu da sua conta nos outros dispositivos.';

  @override
  String get passwordCurrent => 'Senha atual';

  @override
  String get passwordNew => 'Nova senha';

  @override
  String get signOut => 'Sair da conta';

  @override
  String get accountOAuthLinked => 'Usado para entrar nesta conta. Toque para remover.';

  @override
  String get accountOAuthAdd => 'Adicionar forma de acesso';

  @override
  String accountOAuthAddTitle(String name) {
    return 'Adicionar $name';
  }

  @override
  String accountOAuthAdded(String name) {
    return 'Agora você pode entrar com $name.';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return 'Remover $name?';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return 'Você não poderá entrar com $name até adicioná-lo de novo.';
  }

  @override
  String get accountOAuthRemove => 'Remover';

  @override
  String accountOAuthRemoved(String name) {
    return '$name removido.';
  }

  @override
  String get confirmEmailTitle => 'Confirme seu e-mail';

  @override
  String confirmEmailBody(String email) {
    return 'Este servidor exige um e-mail confirmado. Abra o link que enviamos para $email.';
  }

  @override
  String get confirmEmailDone => 'Já confirmei';

  @override
  String get confirmEmailResend => 'Enviar o link novamente';

  @override
  String get confirmEmailNotYet => 'Ainda não foi confirmado. Abra o link no e-mail.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Padrão do sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get settingsDynamicColor => 'Cores do papel de parede';

  @override
  String get settingsDynamicColorSubtitle => 'Usar as cores do dispositivo no lugar do amarelo do Balnana';

  @override
  String get settingsWallpaperGroups => 'Cores do papel de parede nos grupos';

  @override
  String get settingsWallpaperGroupsSubtitle =>
      'Os grupos também usam as cores do dispositivo no lugar das próprias';

  @override
  String get settingsPureBlack => 'Preto puro';

  @override
  String get settingsPureBlackSubtitle => 'Um tema escuro ainda mais escuro para telas OLED';

  @override
  String get settingsMyShare => 'Mostrar minha parte';

  @override
  String get settingsMyShareSubtitle =>
      'As despesas mostram o que você emprestou ou tomou emprestado, em vez do total';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsNotificationsSubtitle =>
      'Quando alguém adiciona, altera ou exclui uma despesa da qual você participa';

  @override
  String get settingsNotificationsBlocked =>
      'Bloqueadas nas configurações do celular: permita as notificações do Balnana lá para vê-las';

  @override
  String get pushChannel => 'Despesas';

  @override
  String get pushChannelDescription =>
      'Quando alguém adiciona, altera ou exclui uma despesa da qual você participa';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who adicionou $title · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who alterou $title · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who excluiu $title · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return '$title foi adicionada · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return '$title foi alterada · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return '$title foi excluída · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payer pagou $payee $amount';
  }

  @override
  String get settingsConnection => 'Conexão';

  @override
  String get settingsServer => 'Servidor';

  @override
  String get serverNotSet => 'Não definido';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get aboutVersion => 'Versão';

  @override
  String get aboutLicenses => 'Licenças de código aberto';

  @override
  String get aboutSource => 'Código-fonte';

  @override
  String get aboutSourceCopied => 'Não foi possível abrir o navegador, então o link foi copiado';

  @override
  String get serverTitle => 'Servidor';

  @override
  String get serverIntro =>
      'Digite o endereço de um servidor Balnana. Qualquer pessoa pode hospedar um; geralmente, o endereço é onde o app web é aberto.';

  @override
  String get serverUrlLabel => 'Endereço do servidor';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => 'Testar conexão';

  @override
  String get serverSaveAnyway => 'Salvar mesmo assim';

  @override
  String get serverReset => 'Usar padrão';

  @override
  String serverDefault(String url) {
    return 'Padrão: $url';
  }

  @override
  String serverConnected(String version) {
    return 'Conectado ao Balnana $version';
  }

  @override
  String get serverModeLink =>
      'Os grupos são compartilhados por um link privado. Não é preciso ter uma conta.';

  @override
  String get serverModeAccounts => 'As pessoas entram com uma conta.';

  @override
  String get serverInsecure =>
      'Este endereço não é criptografado (http). Qualquer pessoa na rede pode ler seus dados. Use https em servidores fora da sua rede doméstica.';

  @override
  String get serverErrorInvalid => 'Digite um endereço da web, como balnana.example.com';

  @override
  String get serverErrorUnreachable =>
      'Não foi possível conectar. Verifique o endereço e se o servidor está funcionando.';

  @override
  String get serverErrorNotBalnana => 'O endereço respondeu, mas não é um servidor Balnana.';

  @override
  String get serverSaved => 'Servidor salvo';

  @override
  String get signIn => 'Entrar';

  @override
  String get groupSignInTitle => 'Entre para abrir este grupo';

  @override
  String get groupSignInBody =>
      'Este grupo é exclusivo para seus membros. Entre para ver o grupo ou participar dele.';

  @override
  String get signInTitle => 'Boas-vindas de volta';

  @override
  String get signInBody => 'Entre para ver seus grupos.';

  @override
  String get signInNoPassword => 'Este servidor usa outra forma de acesso. Pergunte a quem o administra.';

  @override
  String get registerTitle => 'Criar sua conta';

  @override
  String get registerBody => 'Tenha seus grupos em todos os dispositivos.';

  @override
  String get registerAction => 'Criar conta';

  @override
  String get registerHaveAccount => 'Já tenho uma conta';

  @override
  String get signInNoAccount => 'Criar uma conta';

  @override
  String get accountName => 'Seu nome';

  @override
  String get accountNameHelp => 'Como as pessoas dos seus grupos vão ver você';

  @override
  String get accountEmail => 'E-mail';

  @override
  String get accountPassword => 'Senha';

  @override
  String get accountPasswordHelp => 'Pelo menos 8 caracteres';

  @override
  String get passwordShow => 'Mostrar senha';

  @override
  String get passwordHide => 'Ocultar senha';

  @override
  String get joinPickName => 'Escolher outro nome';

  @override
  String joinTitle(String name) {
    return 'Entrar em $name';
  }

  @override
  String get joinBody => 'Você é uma destas pessoas? Escolha seu nome para assumir as despesas dela.';

  @override
  String get joinBodyNew => 'Entre no grupo para adicionar despesas e ver seu saldo.';

  @override
  String get joinAsNew => 'Sou uma pessoa nova';

  @override
  String joinAsName(String name) {
    return 'Entrar como $name';
  }

  @override
  String joinTaken(String names) {
    return 'Já entraram: $names';
  }

  @override
  String joinTakenCount(int count) {
    return '$count pessoas já entraram.';
  }

  @override
  String get commonContinue => 'Continuar';

  @override
  String get errorEmailOff => 'Este servidor não envia e-mails.';

  @override
  String get errorInvalidToken => 'Este link expirou ou já foi usado.';

  @override
  String get forgotPasswordTitle => 'Esqueceu a senha?';

  @override
  String get forgotPasswordBody => 'Vamos enviar um link por e-mail para você escolher uma nova senha.';

  @override
  String get forgotPasswordAction => 'Enviar link';

  @override
  String get forgotPasswordSent => 'Se houver uma conta com esse endereço, o link já está a caminho.';

  @override
  String get resetPasswordTitle => 'Escolha uma nova senha';

  @override
  String get resetPasswordBody =>
      'Você vai sair da sua conta em todos os dispositivos e poderá entrar com a nova senha.';

  @override
  String get resetPasswordAction => 'Salvar senha';

  @override
  String get resetPasswordDone => 'Senha alterada. Entre com sua nova senha.';

  @override
  String get verifyEmailTitle => 'Confirme seu e-mail';

  @override
  String get verifyEmailHelp => 'Assim você pode redefinir sua senha se esquecê-la';

  @override
  String verifyEmailSent(String email) {
    return 'Confira se há um link em $email.';
  }

  @override
  String get verifyEmailDone => 'E-mail confirmado';

  @override
  String get verifyEmailDoneBody => 'Obrigado! Seu endereço foi confirmado.';

  @override
  String get verifyEmailFailed => 'Não foi possível confirmar seu e-mail';

  @override
  String get inviteByEmail => 'Convidar por e-mail';

  @override
  String get inviteByEmailHelp => 'Envie um link para alguém entrar no grupo';

  @override
  String get inviteAs => 'Entrar como';

  @override
  String get inviteAsHelp => 'A pessoa poderá assumir as despesas deste membro';

  @override
  String get inviteAsAnyone => 'Alguém novo';

  @override
  String get inviteSend => 'Enviar convite';

  @override
  String inviteSent(String email) {
    return 'Convite enviado para $email.';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name convidou você para $group';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return 'Você foi convidado para $group';
  }

  @override
  String inviteBody(String email) {
    return 'Crie uma conta com $email para entrar ou acesse sua conta, se já tiver uma.';
  }

  @override
  String get inviteBodySignedIn => 'Entre no grupo para adicionar despesas e ver seu saldo.';

  @override
  String get inviteAction => 'Abrir convite';

  @override
  String get inviteMissingTitle => 'Este convite não funciona';

  @override
  String get inviteMissingBody => 'Talvez tenha expirado ou já tenha sido usado. Peça um novo convite.';

  @override
  String get joinInvitedAs => 'Você foi convidado como esta pessoa';

  @override
  String signInWith(String provider) {
    return 'Continuar com $provider';
  }

  @override
  String get signInOr => 'ou';

  @override
  String get oauthFailedTitle => 'Não foi possível acessar sua conta';

  @override
  String get oauthPendingTitle => 'Este e-mail já tem uma conta';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider informa que $email pertence a você, mas a conta com esse e-mail ainda não foi confirmada. O que você quer fazer?';
  }

  @override
  String get oauthPendingLink => 'Adicionar à conta existente';

  @override
  String get oauthPendingLinkHelp => 'Digite a senha dessa conta. Ela continuará funcionando.';

  @override
  String get oauthPendingTakeOver => 'Assumir essa conta';

  @override
  String get oauthPendingTakeOverHelp =>
      'A senha e as outras formas de acesso serão removidas, e a conta será desconectada em todos os dispositivos.';

  @override
  String get oauthPendingNew => 'Criar uma nova conta';

  @override
  String oauthPendingNewHelp(String email) {
    return 'A outra conta continuará com os grupos, mas ficará sem $email.';
  }

  @override
  String get oauthPendingPassword => 'Senha dessa conta';

  @override
  String get oauthPendingWrongPassword => 'Essa senha está incorreta.';

  @override
  String get oauthOtherServer =>
      'Este acesso foi iniciado em outro servidor. Entre de novo no servidor selecionado.';

  @override
  String get oauthBackToSignIn => 'Voltar para entrar';

  @override
  String get errorOAuthFailed => 'Não foi possível entrar. Tente de novo.';

  @override
  String get errorEmailHasAccount =>
      'Já existe uma conta com este e-mail. Entre nela e adicione esta forma de acesso em Configurações.';

  @override
  String get errorIdentityTaken => 'Esta forma de acesso já está vinculada a outra conta.';

  @override
  String get errorLastSignInMethod =>
      'Esta é sua única forma de acesso. Crie uma senha ou adicione outra forma primeiro.';

  @override
  String get errorEmailUnverified => 'Confirme seu e-mail primeiro.';

  @override
  String get errorOAuthCancelled => 'O acesso foi cancelado.';

  @override
  String get importTitle => 'Importar do Settle Up';

  @override
  String get importAction => 'Importar';

  @override
  String get importIntro =>
      'No Settle Up, exporte o grupo como arquivo CSV e escolha o arquivo aqui. As despesas, os pagamentos e todas as pessoas do grupo serão importados, mantendo os saldos.';

  @override
  String get importChooseFile => 'Escolher arquivo CSV';

  @override
  String get importChooseOther => 'Escolher outro arquivo';

  @override
  String get importReading => 'Lendo o arquivo…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(
      expenses,
      locale: localeName,
      other: '$expenses despesas',
      one: '1 despesa',
      zero: '$expenses despesas',
    );
    String _temp1 = intl.Intl.pluralLogic(
      payments,
      locale: localeName,
      other: '$payments pagamentos',
      one: '1 pagamento',
      zero: '$payments pagamentos',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return '$from a $to';
  }

  @override
  String importCurrency(String currency) {
    return 'Moeda: $currency. Os lançamentos em outras moedas usam os valores convertidos pelo Settle Up.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lançamentos de valor zero foram ignorados.',
      one: '1 lançamento de valor zero foi ignorado.',
      zero: '$count lançamentos de valor zero foram ignorados.',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => 'Qual pessoa é você?';

  @override
  String get importUntitled => 'Sem título';

  @override
  String get errorImportFile => 'Este arquivo não parece ser uma exportação CSV do Settle Up.';

  @override
  String get errorImportCurrency =>
      'O arquivo não tem lançamentos sem taxa de câmbio, então não foi possível identificar a moeda do grupo.';

  @override
  String get errorImportTooBig => 'Este arquivo é grande demais para importar.';

  @override
  String get errorBadImage => 'Não é possível usar esta imagem. Escolha uma imagem JPEG, PNG ou WebP.';

  @override
  String get errorReceiptTooBig => 'Esta imagem é grande demais. Escolha uma com menos de 10 MB.';

  @override
  String get errorImportMe => 'Escolha qual pessoa é você.';

  @override
  String errorImportRow(int line, String reason) {
    return 'Não foi possível importar a linha $line do arquivo: $reason';
  }

  @override
  String get errorImportAmount => 'não foi possível ler um valor.';

  @override
  String get errorImportCounts => 'os nomes e os valores não correspondem.';

  @override
  String get errorImportDate => 'não foi possível ler a data.';

  @override
  String get errorImportType => 'o tipo não é despesa, transferência nem receita.';

  @override
  String get errorImportTransfer => 'uma transferência precisa ter uma pessoa pagando outra.';

  @override
  String get errorImportRowCurrency => 'está em outra moeda sem taxa de câmbio.';

  @override
  String get adminSetupTitle => 'Configurar este servidor';

  @override
  String get adminSetupBody =>
      'Escolha uma senha para a administração. Ela protege esta página de configurações do servidor. Não há nome de usuário: quem souber a senha poderá alterar as configurações.';

  @override
  String get adminSetupCode => 'Código de configuração';

  @override
  String get adminSetupCodeHelp =>
      'Este servidor já tem dados, então o código de configuração foi exibido no registro ao iniciar. Com Docker: docker compose logs balnana';

  @override
  String get adminSetupAction => 'Definir senha';

  @override
  String get adminPassword => 'Senha de administrador';

  @override
  String get adminPasswordRepeat => 'Digite a senha novamente';

  @override
  String get adminPasswordMismatch => 'As senhas não correspondem.';

  @override
  String get adminLoginTitle => 'Administração';

  @override
  String get adminLoginBody =>
      'Digite a senha de administrador para alterar as configurações deste servidor.';

  @override
  String get adminLoginAction => 'Entrar';

  @override
  String get adminSettingsTitle => 'Configurações do servidor';

  @override
  String get adminSaved => 'Configurações salvas. Já estão valendo.';

  @override
  String get adminSaveFailed => 'Nada foi salvo. Confira as configurações destacadas.';

  @override
  String get adminChangePassword => 'Alterar senha de administrador';

  @override
  String get adminPasswordCurrent => 'Senha atual';

  @override
  String get adminPasswordNew => 'Nova senha';

  @override
  String get adminPasswordChanged =>
      'Senha alterada. As outras sessões de administração foram desconectadas.';

  @override
  String get adminSignOut => 'Sair da administração';

  @override
  String get adminBackHome => 'Voltar ao Balnana';

  @override
  String get adminRequireEmail => 'Exigir endereço de e-mail';

  @override
  String get adminRequireEmailHelp =>
      'Quando desativado, as pessoas se cadastram com um nome de usuário e podem deixar o e-mail em branco. É possível entrar com qualquer um dos dois.';

  @override
  String get adminRequireEmailUnused => 'Só se aplica ao acesso com e-mail e senha, que está desativado.';

  @override
  String get accountUsername => 'Nome de usuário';

  @override
  String get accountUsernameHelp =>
      'De 3 a 32 letras, números, pontos, hífens ou sublinhados. Você usa esse nome para entrar.';

  @override
  String get accountEmailOptional => 'E-mail (opcional)';

  @override
  String get accountEmailOptionalHelp =>
      'Permite receber convites para grupos e redefinir uma senha esquecida.';

  @override
  String get accountLogin => 'E-mail ou nome de usuário';

  @override
  String get errorInvalidUsername =>
      'Use de 3 a 32 letras, números, pontos, hífens ou sublinhados. Comece com uma letra ou número.';

  @override
  String get errorUsernameTaken => 'Alguém já está usando esse nome de usuário.';

  @override
  String get adminDiscardTitle => 'Descartar alterações?';

  @override
  String get adminDiscardBody => 'Suas alterações nas configurações não foram salvas.';

  @override
  String get adminDiscard => 'Descartar';

  @override
  String adminLocked(String key) {
    return 'Definido no servidor por $key';
  }

  @override
  String adminDefault(String value) {
    return 'Padrão: $value';
  }

  @override
  String get adminSecretSaved => 'Salvo. Digite um novo valor para substituí-lo.';

  @override
  String get adminSecretRemoved => 'Será removido ao salvar.';

  @override
  String get adminSecretRemove => 'Remover valor salvo';

  @override
  String get adminSectionGeneral => 'Geral';

  @override
  String get adminSectionAccess => 'Acesso';

  @override
  String get adminSectionMaps => 'Mapas';

  @override
  String get adminSectionAccounts => 'Contas';

  @override
  String get adminSectionAccountsBody => 'Estas opções se aplicam quando o acesso é feito por contas.';

  @override
  String get adminSectionEmail => 'E-mail (SMTP)';

  @override
  String get adminSectionEmailBody => 'Confirmação de endereço, redefinição de senha e convites.';

  @override
  String get adminSmtpOn => 'Enviar e-mail';

  @override
  String get adminSectionGoogle => 'Entrar com o Google';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Cadastre $url como URI de redirecionamento no console do Google Cloud.';
  }

  @override
  String get adminGoogleOn => 'Oferecer acesso com Google';

  @override
  String get adminGoogleOnHelp => 'As pessoas entram com a conta do Google.';

  @override
  String get adminSectionOidc => 'Entrar com OpenID Connect';

  @override
  String adminSectionOidcBody(String url) {
    return 'Cadastre $url como URI de redirecionamento no provedor.';
  }

  @override
  String get adminOidcHelp =>
      'Qualquer provedor OpenID Connect, como Authentik, Keycloak ou Dex. Adicione quantos quiser.';

  @override
  String get adminOidcAdd => 'Adicionar provedor';

  @override
  String get adminOidcRemove => 'Remover provedor';

  @override
  String get adminOidcNew => 'Novo provedor';

  @override
  String get adminOidcId => 'ID';

  @override
  String get adminOidcIdHelp =>
      'Letras minúsculas, números e hífens. Faz parte da URI de redirecionamento e não pode ser alterado depois.';

  @override
  String get adminOidcIdInvalid =>
      'Use até 32 letras minúsculas, números e hífens, começando com uma letra ou número.';

  @override
  String get adminOidcIdTaken => 'Outro provedor já usa este ID.';

  @override
  String get adminTrustEmail => 'Confiar no e-mail';

  @override
  String get adminGoogleTrustEmailHelp =>
      'Se o e-mail usado para entrar com o Google já tiver uma conta, a pessoa entrará nela. Desativado: ela entrará com a senha e adicionará o Google em Configurações.';

  @override
  String get adminOidcTrustEmailHelp =>
      'Use apenas com um provedor que você administra ou confia para verificar e-mails. Desativado: quem tem uma conta entra com a senha e adiciona o provedor em Configurações.';

  @override
  String get adminRequireVerified => 'Exigir e-mail confirmado';

  @override
  String get adminRequireVerifiedHelp =>
      'As contas só podem usar o app depois de confirmar o e-mail. Um acesso confiável com o mesmo e-mail assume uma conta não confirmada. Desativado: a pessoa escolhe o que fazer.';

  @override
  String get adminRequireVerifiedUnused => 'Requer envio de e-mails.';

  @override
  String get adminSectionAndroid => 'Links do app Android';

  @override
  String get adminSectionAndroidBody =>
      'As versões do Android feitas para este servidor abrem os links dele no app. Para não perguntar, informe as impressões digitais SHA-256 dos certificados usados para assinar essas versões.';

  @override
  String get adminSectionAdmin => 'Administração';

  @override
  String get adminPublicUrl => 'Endereço público';

  @override
  String get adminPublicUrlHelp =>
      'O endereço usado pelas pessoas para acessar este servidor. Os links de grupo e de e-mail são criados a partir dele.';

  @override
  String get adminSourceUrl => 'Link do código-fonte';

  @override
  String get adminSourceUrlHelp =>
      'Onde obter o código-fonte deste servidor, conforme exige a licença (AGPL-3.0) ao executar uma versão modificada.';

  @override
  String get adminAuthMode => 'Acesso';

  @override
  String get adminAuthModeLink => 'Links de grupo';

  @override
  String get adminAuthModeLinkHelp => 'Sem acesso à conta: basta ter o link privado do grupo.';

  @override
  String get adminAuthModeAccounts => 'Contas';

  @override
  String get adminAuthModeAccountsHelp =>
      'As pessoas entram com uma conta, e o link só permite que quem está conectado participe de um grupo.';

  @override
  String get adminPasswordLogin => 'Acesso com e-mail e senha';

  @override
  String get adminPasswordForced =>
      'Fica ativado até habilitar o acesso com Google ou OpenID Connect, para sempre haver uma forma de entrar.';

  @override
  String get adminSignup => 'Quem pode criar uma conta';

  @override
  String get adminSignupOpen => 'Qualquer pessoa';

  @override
  String get adminSignupOpenHelp => 'Qualquer pessoa que consiga acessar este servidor pode se cadastrar.';

  @override
  String get adminSignupInvite => 'Pessoas convidadas';

  @override
  String get adminSignupInviteHelp =>
      'Só pessoas convidadas por e-mail para um grupo podem se cadastrar, e apenas com o endereço que recebeu o convite. O link do grupo não basta para entrar. É preciso ativar o envio de e-mails para usar convites.';

  @override
  String get adminSignupClosed => 'Ninguém';

  @override
  String get adminSignupClosedHelp =>
      'Ninguém pode se cadastrar. As contas existentes continuam funcionando.';

  @override
  String get adminSignupHelp => 'Sempre é possível criar a primeira conta.';

  @override
  String get adminLinkGroups => 'Permitir abrir grupos pelo link';

  @override
  String get adminLinkGroupsHelp =>
      'Quem é dono do grupo pode permitir que qualquer pessoa com o link entre sem acessar uma conta.';

  @override
  String get adminSmtpHost => 'Servidor de e-mail';

  @override
  String get adminSmtpPort => 'Porta';

  @override
  String get adminSmtpUser => 'Nome de usuário';

  @override
  String get adminSmtpPassword => 'Senha';

  @override
  String get adminSmtpFrom => 'Remetente';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'ID do cliente';

  @override
  String get adminClientSecret => 'Chave secreta do cliente';

  @override
  String get adminOidcIssuer => 'URL do emissor';

  @override
  String get adminOidcName => 'Nome do botão';

  @override
  String get adminOidcNameHelp => 'Exibido como \"Continuar com…\" na página de acesso.';

  @override
  String get adminFingerprints => 'Impressões digitais do certificado';

  @override
  String get adminFingerprintsHelp =>
      'SHA-256, separados por vírgulas. keytool -list -v e apksigner verify --print-certs mostram esses valores.';

  @override
  String get adminInvalidValue => 'Este valor é inválido.';

  @override
  String get adminInvalidUrl => 'Digite um endereço completo que comece com https:// ou http://.';

  @override
  String get adminInvalidFrom =>
      'Digite um remetente, como Balnana <balnana@example.com>; é preciso informar um e-mail.';

  @override
  String get adminInvalidPort => 'Digite um número de porta entre 1 e 65535.';

  @override
  String get adminInvalidRequired => 'Este provedor de acesso exige este valor.';

  @override
  String get adminInvalidFingerprint =>
      'Digite as impressões digitais SHA-256: 64 dígitos hexadecimais cada, com ou sem dois-pontos.';

  @override
  String get adminNeedsSignIn =>
      'As contas precisam de uma forma de acesso: ative o acesso por e-mail e senha ou configure um provedor.';

  @override
  String get adminLockedChange => 'Esta opção é definida no servidor e não pode ser alterada aqui.';

  @override
  String get errorAdminRequired => 'Sua sessão de administração terminou. Entre novamente.';

  @override
  String get errorAdminWrongPassword => 'Essa senha está incorreta.';

  @override
  String get errorInvalidSetupCode =>
      'Esse código de configuração está incorreto. Procure-o no registro do servidor.';

  @override
  String get errorAlreadySetUp => 'Este servidor já foi configurado. Entre com a senha de administrador.';

  @override
  String get linkOpening => 'Abrindo link…';

  @override
  String get linkForeignTitle => 'Este link é de outro servidor';

  @override
  String linkForeignBody(String server) {
    return 'Este app está conectado a $server, mas o link pertence a outro servidor. Altere o servidor em Configurações para abri-lo.';
  }

  @override
  String get linkInvalidTitle => 'Não foi possível abrir este link';

  @override
  String get linkInvalidBody => 'Este não é um link do Balnana reconhecido pelo app.';

  @override
  String get linkGoHome => 'Ir para grupos';

  @override
  String get linkOpenInBrowser => 'Abrir no navegador';

  @override
  String get privacyTitle => 'Política de privacidade';

  @override
  String get privacyIntro =>
      'O Balnana é um software de código aberto. Quem administra o servidor ao qual este app está conectado decide onde seus dados ficam armazenados e é responsável por eles. Esta página descreve o que o próprio software armazena e faz.';

  @override
  String get privacyStoredTitle => 'O que é armazenado';

  @override
  String get privacyStoredBody =>
      'Os grupos que você cria ou dos quais participa: nomes dos grupos e dos membros, despesas, pagamentos, observações, fotos de comprovantes e os lugares adicionados às despesas. Se você tiver uma conta, também são armazenados seu nome, endereço de e-mail ou nome de usuário, um resumo criptográfico da senha (nunca a senha em si) e o provedor usado para entrar, como o Google. Se as notificações estiverem ativadas, também é armazenado um identificador do dispositivo e o endereço fornecido pelo serviço de notificações push.';

  @override
  String get privacyUseTitle => 'Como os dados são usados';

  @override
  String get privacyUseBody =>
      'Somente para executar o app: mostrar cada grupo aos seus membros, calcular saldos e enviar os e-mails e as notificações necessários, como confirmação de endereço, redefinição de senha e convites. O app não tem anúncios nem ferramentas de análise, e nada é vendido.';

  @override
  String get privacySharedTitle => 'Quem pode ver os dados';

  @override
  String get privacySharedBody =>
      'Todas as pessoas de um grupo veem seus membros, despesas e histórico. Se um grupo estiver aberto por link, qualquer pessoa com o link poderá acessá-lo. O acesso com Google passa pelo Google. Quando a pessoa que administra o servidor ativa as notificações, elas passam pelo serviço push usado pelo celular: o Firebase Cloud Messaging do Google ou outro serviço UnifiedPush instalado, como ntfy. O conteúdo das notificações é criptografado durante o envio. Os mapas carregam imagens do provedor escolhido pela pessoa que administra o servidor — OpenFreeMap, a menos que ela tenha escolhido outro — que vê seu endereço de rede e a região que você consulta. Sua localização só é acessada quando você toca em \"Usar localização atual\", e apenas o ponto que você decidir manter será salvo.';

  @override
  String get privacyDeviceTitle => 'Neste dispositivo';

  @override
  String get privacyDeviceBody =>
      'O app mantém o endereço do servidor, suas configurações e uma cópia dos seus grupos para quando você estiver offline. Ao desinstalar o app, esses dados são removidos.';

  @override
  String get privacyDeleteTitle => 'Como excluir seus dados';

  @override
  String get privacyDeleteBody =>
      'Você pode excluir sua conta em Configurações. Seu nome continuará nos grupos como um membro sem responsável, para que os saldos continuem fechando. Os grupos que ninguém mais consegue acessar também serão excluídos. Quem é dono de um grupo pode excluí-lo por completo nas configurações. Para qualquer outra coisa, entre em contato com quem administra o servidor.';

  @override
  String get privacyOperatorPolicy => 'Política de privacidade do servidor';

  @override
  String get privacyLink => 'Privacidade';

  @override
  String get accountEmailAdd => 'Adicionar endereço de e-mail';

  @override
  String get accountEmailChange => 'Alterar endereço de e-mail';

  @override
  String get accountEmailNew => 'Endereço de e-mail';

  @override
  String get accountEmailVerifyNote =>
      'Você receberá um link para confirmar o novo endereço. Seu endereço atual continuará valendo até lá.';

  @override
  String get accountEmailPendingTitle => 'Confirme seu novo e-mail';

  @override
  String accountEmailPendingHelp(String email) {
    return '$email substituirá seu endereço atual quando você abrir o link enviado para ele. Toque para enviar o link novamente.';
  }

  @override
  String get accountEmailRemoveNote =>
      'Deixe em branco para remover seu endereço. Você continuará entrando com seu nome de usuário.';

  @override
  String get accountEmailSaved => 'Endereço de e-mail salvo';

  @override
  String get accountEmailRemoved => 'Endereço de e-mail removido';

  @override
  String get accountConfirmPassword => 'Sua senha';

  @override
  String get accountConfirmPasswordHelp => 'Para confirmar que é você.';

  @override
  String get errorEmailNeeded => 'Você entra com seu endereço de e-mail, então não pode removê-lo.';

  @override
  String get accountDelete => 'Excluir conta';

  @override
  String get accountDeleteHelp => 'Remover sua conta deste servidor';

  @override
  String get accountDeleteTitle => 'Excluir sua conta?';

  @override
  String get accountDeleteBody =>
      'Sua conta será excluída permanentemente e você sairá dela. Seu nome continuará nos grupos como um membro sem responsável, para que os saldos continuem fechando. Os grupos sem outras pessoas serão excluídos.';

  @override
  String get accountDeleteAction => 'Excluir permanentemente';

  @override
  String get accountDeleted => 'Sua conta foi excluída.';

  @override
  String get accountDeletePageSignedOut => 'Entre para excluir sua conta neste servidor.';

  @override
  String get accountDeletePageLinkMode =>
      'Este servidor não usa contas: basta ter o link do grupo. Para excluir um grupo e tudo o que há nele, abra as configurações do grupo e escolha Excluir grupo.';

  @override
  String get groupDelete => 'Excluir grupo';

  @override
  String get groupDeleteHelp => 'Excluir o grupo e todas as despesas para todo mundo';

  @override
  String groupDeleteTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String get groupDeleteBody =>
      'O grupo, todas as despesas, os pagamentos e o histórico serão excluídos para todo mundo. Não é possível desfazer. Digite o nome do grupo para confirmar.';

  @override
  String get groupDeleteName => 'Nome do grupo';

  @override
  String get groupDeleteAction => 'Excluir permanentemente';

  @override
  String get groupDeleted => 'Grupo excluído';

  @override
  String get groupDeleteOwnerOnly => 'Só quem é dono do grupo pode excluí-lo.';

  @override
  String get expenseDiscardTitle => 'Descartar alterações?';

  @override
  String get expenseDiscardBody => 'Suas alterações nesta despesa não foram salvas.';

  @override
  String get expenseDiscard => 'Descartar';

  @override
  String get adminPrivacyUrl => 'Link da política de privacidade';

  @override
  String get adminPrivacyUrlHelp =>
      'Link da sua política de privacidade, exigido pelas lojas de apps. Se ficar em branco, o app mostra uma política geral sobre o que o Balnana armazena.';

  @override
  String get adminMapTiles => 'Blocos do mapa';

  @override
  String get adminMapSource => 'Fonte do mapa';

  @override
  String get adminMapSourceStyle => 'Estilo vetorial';

  @override
  String get adminMapSourceStyleHelp =>
      'Mapas desenhados a partir de um estilo MapLibre, como o do OpenFreeMap, que é gratuito e não precisa de chave.';

  @override
  String get adminMapSourceTiles => 'Blocos raster';

  @override
  String get adminMapSourceTilesHelp => 'Mapas exibidos com imagens de blocos, como as do OpenStreetMap.';

  @override
  String get adminMapSourceOff => 'Desativado';

  @override
  String get adminMapSourceOffHelp =>
      'Sem mapas. As despesas ainda salvam os nomes dos lugares e os pontos no mapa.';

  @override
  String get adminMapStyle => 'URL do estilo';

  @override
  String get adminMapStyleHelp =>
      'Endereço de um arquivo style.json do MapLibre, como Liberty (padrão), Bright ou Positron, do OpenFreeMap.';

  @override
  String get adminMapTilesHelp =>
      'Modelo de URL para blocos raster com z, x e y entre chaves, como o padrão. Os servidores próprios do OpenStreetMap são apenas para uso leve; servidores movimentados devem usar um provedor de blocos.';

  @override
  String get adminMapAttribution => 'Créditos do mapa';

  @override
  String get adminMapAttributionHelp =>
      'Exibidos em todos os mapas, conforme solicitado pelo provedor. Se ficar em branco, o estilo mostra os créditos informados e os blocos dão crédito ao OpenStreetMap.';

  @override
  String get adminInvalidMapTiles => 'Digite um modelo de URL http(s) com z, x e y entre chaves.';

  @override
  String get adminUsers => 'Contas';

  @override
  String get adminUsersSearch => 'Buscar por nome, e-mail ou nome de usuário';

  @override
  String adminUsersShown(int shown, int total) {
    return '$shown de $total contas';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contas',
      one: '1 conta',
      zero: '$count contas',
    );
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => 'Nenhuma conta encontrada.';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos',
      one: '1 grupo',
      zero: 'Nenhum grupo',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => 'não confirmado';

  @override
  String adminUserDeleteTitle(String name) {
    return 'Excluir a conta de $name?';
  }

  @override
  String get adminUserDeleteBody =>
      'A conta será excluída permanentemente e desconectada em todos os dispositivos. O nome continuará nos grupos como um membro sem responsável; os grupos sem outras pessoas serão excluídos.';

  @override
  String get adminUserDeleted => 'Conta excluída';

  @override
  String get commonDone => 'Concluído';

  @override
  String get crowdSearch => 'Buscar pessoas';

  @override
  String get crowdNoMatch => 'Ninguém encontrado.';

  @override
  String get crowdAll => 'Todas';

  @override
  String get crowdNone => 'Nenhuma';

  @override
  String crowdChosen(int count, int total) {
    return '$count de $total selecionadas';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mais $count',
      one: 'mais 1',
      zero: 'mais $count',
    );
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => 'Mostrar menos';

  @override
  String get crowdSort => 'Ordenar';

  @override
  String crowdShowAll(int count) {
    return 'Mostrar todas as $count';
  }

  @override
  String get crowdBalances => 'Saldo de todo mundo';

  @override
  String get crowdSomeoneElse => 'Outra pessoa';

  @override
  String get crowdChoosePayers => 'Escolher quem pagou';

  @override
  String get crowdFilterTitle => 'De quem são as despesas?';

  @override
  String get myGroupsTitle => 'Meus links de grupo';

  @override
  String get myGroupsExport => 'Exportar meus grupos';

  @override
  String get myGroupsExportHelp =>
      'Copie os links dos seus grupos para fazer um backup ou transferi-los para outro dispositivo.';

  @override
  String get myGroupsPrivate =>
      'Mantenha estes links privados. Qualquer pessoa com um link pode abrir o grupo correspondente.';

  @override
  String get myGroupsCopy => 'Copiar links';

  @override
  String get myGroupsImport => 'Importar grupos';

  @override
  String get myGroupsImportHelp =>
      'Cole os links dos grupos deste servidor, um por linha. Os grupos existentes mantêm seu lugar e sua identidade.';

  @override
  String get myGroupsLinks => 'Links dos grupos';

  @override
  String get myGroupsImportAction => 'Importar links';

  @override
  String get myGroupsInvalid => 'Digite links válidos de grupos, um por linha. Nada foi importado.';

  @override
  String get myGroupsServerChanged =>
      'O servidor selecionado mudou. Feche esta janela e importe os links no servidor correspondente.';

  @override
  String myGroupsLimit(int count) {
    return 'Mantenha no máximo $count links de grupo por servidor. Nada foi importado.';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novos links de grupo importados.',
      one: '1 novo link de grupo importado.',
      zero: 'Estes grupos já estão salvos.',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => 'Repetição';

  @override
  String get repeatNever => 'Não se repete';

  @override
  String get repeatDaily => 'Diariamente';

  @override
  String get repeatWeekly => 'Semanalmente';

  @override
  String get repeatMonthly => 'Mensalmente';

  @override
  String get repeatYearly => 'Anualmente';

  @override
  String get repeatEvery => 'A cada';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'dias', one: 'dia', zero: 'dias');
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'semanas',
      one: 'semana',
      zero: 'semanas',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'meses',
      one: 'mês',
      zero: 'meses',
    );
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'anos', one: 'ano', zero: 'anos');
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count dias',
      one: 'Todo dia',
      zero: 'A cada $count dias',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count semanas',
      one: 'Toda semana',
      zero: 'A cada $count semanas',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count meses',
      one: 'Todo mês',
      zero: 'A cada $count meses',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count anos',
      one: 'Todo ano',
      zero: 'A cada $count anos',
    );
    return '$_temp0';
  }

  @override
  String get repeatEndNone => 'Sem data final';

  @override
  String repeatEndOn(String date) {
    return 'Até $date';
  }

  @override
  String get repeatEndClear => 'Remover data final';

  @override
  String get repeatHelp =>
      'Adicionada automaticamente ao grupo em cada data, a partir da data acima. Ao salvar, as datas que já passaram também serão adicionadas.';

  @override
  String get repeatDropReceiptTitle => 'Remover o comprovante?';

  @override
  String get repeatDropReceiptBody =>
      'Uma despesa recorrente não pode ter comprovante. Você pode adicionar um comprovante a cada despesa criada por ela.';

  @override
  String get repeatDropReceiptAction => 'Repetir';

  @override
  String get recurringTitle => 'Despesas recorrentes';

  @override
  String get recurringHelp => 'Despesas adicionadas automaticamente em um intervalo definido';

  @override
  String get recurringEmptyTitle => 'Ainda não há despesas recorrentes';

  @override
  String get recurringEmptyBody =>
      'Aluguel, assinaturas e outros custos recorrentes podem ser adicionados automaticamente em cada data.';

  @override
  String get recurringAdd => 'Adicionar despesa recorrente';

  @override
  String get recurringEdit => 'Editar despesa recorrente';

  @override
  String recurringNext(String date) {
    return 'Próxima em $date';
  }

  @override
  String get recurringPaused => 'Pausada';

  @override
  String get recurringEnded => 'Encerrada';

  @override
  String get recurringPause => 'Pausar';

  @override
  String get recurringResume => 'Retomar';

  @override
  String get recurringActive => 'Repetindo';

  @override
  String get recurringDelete => 'Excluir';

  @override
  String get recurringDeleteTitle => 'Parar repetição?';

  @override
  String recurringDeleteBody(String title) {
    return '“$title” não será adicionada de novo. As despesas já adicionadas continuam no grupo.';
  }

  @override
  String get recurringDeleted => 'Despesa recorrente excluída';

  @override
  String get recurringFromSchedule => 'Adicionada por uma despesa recorrente';

  @override
  String get recurringOpen => 'Alterar a programação';

  @override
  String get recurringMissing => 'A despesa recorrente foi excluída ou não está mais disponível.';

  @override
  String get errorTooManyDue =>
      'A data inicial é antiga demais: mais de 100 despesas seriam adicionadas de uma só vez.';

  @override
  String get errorInvalidEnd => 'A data final não pode ser anterior à data inicial.';

  @override
  String get errorInvalidRepeat => 'Escolha um intervalo de 1 a 999 dias, semanas, meses ou anos.';

  @override
  String get errorRecurringConflict =>
      'Outra pessoa alterou esta despesa recorrente enquanto você a editava. Recarregue para ver as alterações.';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$who configurou a repetição de “$title”';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$who alterou a despesa recorrente “$title”';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$who pausou a despesa recorrente “$title”';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return 'A despesa recorrente “$title” foi pausada porque alguém incluído nela saiu do grupo';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return 'A despesa recorrente “$title” foi pausada porque não foi possível adicioná-la';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$who retomou a despesa recorrente “$title”';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$who parou a repetição de “$title”';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return '“$title” ($amount) foi adicionada automaticamente';
  }

  @override
  String get expenseRecurring => 'Adicionada por uma despesa recorrente';
}
