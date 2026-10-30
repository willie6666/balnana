// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get languageEndonym => 'Español';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get offlineBar =>
      'Sin conexión. Se muestran los datos guardados en este dispositivo; no podrás guardar cambios hasta que vuelvas a conectarte.';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonClear => 'Borrar';

  @override
  String get iconChoose => 'Elegir un icono';

  @override
  String get iconNone => 'Sin icono';

  @override
  String get iconSearchHint => 'Busca o escribe un emoji';

  @override
  String get iconUseTyped => 'Usar este emoji';

  @override
  String get iconNoMatch => 'No hay iconos que coincidan. Escribe un emoji para usarlo.';

  @override
  String get iconSectionTravel => 'Viajes y lugares';

  @override
  String get iconSectionFood => 'Comida y bebida';

  @override
  String get iconSectionActivities => 'Actividades';

  @override
  String get iconSectionHome => 'Hogar y facturas';

  @override
  String get iconSectionPeople => 'Personas';

  @override
  String get iconSectionNature => 'Animales y naturaleza';

  @override
  String get iconSectionObjects => 'Dinero y objetos';

  @override
  String get iconSectionSymbols => 'Símbolos';

  @override
  String get commonRemove => 'Quitar';

  @override
  String get commonUndo => 'Deshacer';

  @override
  String get someone => 'Alguien';

  @override
  String get errorTooLarge => 'El archivo es demasiado grande para enviarlo al servidor.';

  @override
  String get errorBusy => 'El servidor está ocupado. Inténtalo de nuevo dentro de un momento.';

  @override
  String get errorTimeout => 'Se ha tardado demasiado en enviar. Comprueba la conexión e inténtalo de nuevo.';

  @override
  String get errorBadOrigin =>
      'El servidor no acepta inicios de sesión desde esta dirección. Quien lo administre debe comprobar su URL pública.';

  @override
  String get errorInvalidCategory => 'Esa categoría ya se ha eliminado. Elige otra.';

  @override
  String get errorBuiltinCategory => 'Las categorías predefinidas solo se pueden ocultar.';

  @override
  String get errorUnknownMember =>
      'Alguien ya no forma parte del grupo. Recarga la página e inténtalo de nuevo.';

  @override
  String get errorNoPayers => 'Elige quién pagó.';

  @override
  String get errorPayerTotal => 'Lo que pagó cada persona debe sumar el importe total.';

  @override
  String get errorPayerTooSmall =>
      'La parte pagada por alguien equivale a cero en la moneda del grupo. Comprueba los importes.';

  @override
  String get errorInvalidNote => 'La nota es demasiado larga o contiene caracteres que no se pueden guardar.';

  @override
  String get errorInvalidDate => 'Esa fecha está fuera del intervalo permitido.';

  @override
  String get errorGeneric => 'Algo ha fallado. Inténtalo de nuevo.';

  @override
  String get errorNetwork => 'No se puede conectar con el servidor. Comprueba la conexión.';

  @override
  String get errorNotFound => 'Esto ya no existe.';

  @override
  String get errorRequired => 'Obligatorio';

  @override
  String get errorInvalidName => 'Escribe un nombre de hasta 100 caracteres.';

  @override
  String get errorDuplicateName => 'Alguien del grupo ya tiene ese nombre.';

  @override
  String get errorTooManyMembers => 'El grupo ya tiene el máximo de personas.';

  @override
  String get errorTooManyCategories => 'El grupo ya tiene el máximo de categorías.';

  @override
  String get errorDuplicateCategory => 'El grupo ya tiene una categoría con ese nombre.';

  @override
  String get errorInvalidCurrency => 'Escribe un código de moneda de tres letras, como USD.';

  @override
  String get errorInvalidTitle => 'Escribe un título de hasta 200 caracteres.';

  @override
  String get errorInvalidLocation =>
      'Escribe el nombre de un lugar en una sola línea, con un máximo de 200 caracteres.';

  @override
  String get errorInvalidSymbol => 'Escribe un símbolo de hasta 8 caracteres.';

  @override
  String get errorInvalidEmoji => 'Elige un solo emoji como icono.';

  @override
  String get errorMemberHasBalance => 'Salda la deuda de esta persona antes de quitarla.';

  @override
  String get errorVersionConflict =>
      'Alguien ha cambiado este gasto mientras lo editabas. Recarga la página para ver los cambios.';

  @override
  String get errorSignInRequired => 'Inicia sesión para hacer esto.';

  @override
  String get errorRateLimited => 'Has hecho demasiadas solicitudes. Espera un minuto e inténtalo de nuevo.';

  @override
  String get errorNotAMember => 'Aún no formas parte de este grupo.';

  @override
  String get errorNotAllowed => 'Solo esa persona o el propietario del grupo puede hacer esto.';

  @override
  String get errorLinkGroupsOff => 'Este servidor no permite abrir grupos solo con un enlace.';

  @override
  String get errorMemberClaimed => 'Alguien ya se ha unido como esa persona.';

  @override
  String get errorMemberLeft => 'Alguien de este grupo se ha ido.';

  @override
  String get errorInvalidEmail => 'Escribe una dirección de correo electrónico.';

  @override
  String get errorInvalidPassword => 'Usa entre 8 y 200 caracteres.';

  @override
  String get errorEmailTaken => 'Ya hay una cuenta con ese correo. Inicia sesión.';

  @override
  String get errorSignupClosed => 'Este servidor no acepta cuentas nuevas.';

  @override
  String get errorInvalidCredentials => 'El correo y la contraseña no coinciden.';

  @override
  String get errorWrongPassword => 'La contraseña actual no es correcta.';

  @override
  String get errorAccountsOff => 'Este servidor no usa cuentas.';

  @override
  String get errorInvalidAmount => 'Escribe un importe mayor que cero.';

  @override
  String get errorTooManyDecimals => 'Esta moneda no admite tantos decimales.';

  @override
  String get errorAmountTooLarge => 'Ese importe es demasiado grande.';

  @override
  String get errorNoShares => 'Elige al menos a una persona para repartir el gasto.';

  @override
  String get errorInvalidShare => 'Cada parte debe ser un número.';

  @override
  String get errorExactTotal => 'Los importes deben sumar el total.';

  @override
  String get errorPayersTotal => 'Lo que pagaron entre todos debe sumar el total.';

  @override
  String get categoryFood => 'Comida y bebida';

  @override
  String get categoryGroceries => 'Supermercado';

  @override
  String get categoryTransport => 'Transporte';

  @override
  String get categoryTravel => 'Viajes';

  @override
  String get categoryLodging => 'Alojamiento';

  @override
  String get categoryRent => 'Alquiler';

  @override
  String get categoryUtilities => 'Suministros';

  @override
  String get categoryEntertainment => 'Ocio';

  @override
  String get categoryShopping => 'Compras';

  @override
  String get categoryHealth => 'Salud';

  @override
  String get categoryGifts => 'Regalos';

  @override
  String get categoryOther => 'Otros';

  @override
  String get groupNew => 'Nuevo grupo';

  @override
  String get groupSwitch => 'Cambiar de grupo';

  @override
  String get groupReorder => 'Arrastra para cambiar el orden';

  @override
  String get groupCreate => 'Crear grupo';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return 'Te deben $amount';
  }

  @override
  String pillOwe(String amount) {
    return 'Debes $amount';
  }

  @override
  String get pillSettled => 'Todo saldado';

  @override
  String get groupMissingTitle => 'No se encontró el grupo';

  @override
  String get groupMissingBody =>
      'Este grupo se ha eliminado o su enlace se ha restablecido. Pídele a alguien del grupo el enlace nuevo.';

  @override
  String get groupLockedTitle => 'Inicia sesión para abrir este grupo';

  @override
  String get groupLockedBody =>
      'Este grupo solo está disponible para las cuentas de sus integrantes. Inicia sesión con la cuenta que pertenece al grupo.';

  @override
  String get groupForget => 'Quitar de este dispositivo';

  @override
  String get groupLinkOtherServer =>
      'Este enlace pertenece a otro servidor. Conéctate a ese servidor para abrirlo.';

  @override
  String get openLinkTitle => 'Abrir un enlace de grupo';

  @override
  String get openLinkBody => 'Pega un enlace que alguien haya compartido contigo para unirte a su grupo.';

  @override
  String get openLinkLabel => 'Enlace del grupo';

  @override
  String get openLinkAction => 'Abrir';

  @override
  String get openLinkInvalid => 'Eso no parece un enlace de grupo de Balnana.';

  @override
  String get groupName => 'Nombre del grupo';

  @override
  String get groupNameHint => 'Viaje a Lisboa';

  @override
  String get groupCurrency => 'Moneda';

  @override
  String get groupCurrencyHelp =>
      'Todos los gastos del grupo usan esta moneda. No se puede cambiar más adelante.';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name. Todos los gastos del grupo usan esta moneda. No se puede cambiar más adelante.';
  }

  @override
  String get currencyChoose => 'Elegir una moneda';

  @override
  String get currencySearchHint => 'Busca por código o nombre';

  @override
  String get currencySuggested => 'Sugeridas';

  @override
  String get currencyAll => 'Todas las monedas';

  @override
  String currencyUseTyped(String code) {
    return 'Usar $code';
  }

  @override
  String get currencyNoMatch => 'No hay monedas que coincidan. Escribe su código de tres letras para usarla.';

  @override
  String get groupSymbol => 'Símbolo';

  @override
  String get groupSymbolChoose => 'Elegir un símbolo';

  @override
  String groupSymbolExample(String example) {
    return 'Los importes se muestran como $example';
  }

  @override
  String get groupColor => 'Color';

  @override
  String colorSwatch(int number, int count) {
    return 'Color $number de $count';
  }

  @override
  String get groupPeople => 'Personas';

  @override
  String get groupYourName => 'Tu nombre';

  @override
  String groupPersonName(int number) {
    return 'Persona $number';
  }

  @override
  String get groupAddPerson => 'Añadir persona';

  @override
  String get groupPeopleHelp => 'Puedes añadir más personas después, o pueden unirse con el enlace.';

  @override
  String get identityTitle => '¿Quién eres?';

  @override
  String get identityBody =>
      'Elige tu nombre para que Balnana te muestre lo que debes. Solo este dispositivo lo recordará.';

  @override
  String get identityNew => 'Soy una persona nueva';

  @override
  String get identityNewTitle => 'Unirte a este grupo';

  @override
  String get identityJoin => 'Unirse';

  @override
  String get identityChange => 'Quién eres';

  @override
  String get identityNone => 'Aún no has elegido';

  @override
  String get memberName => 'Nombre';

  @override
  String memberYou(String name) {
    return '$name (tú)';
  }

  @override
  String get memberAdd => 'Añadir persona';

  @override
  String get memberAddTitle => 'Añadir a alguien';

  @override
  String get memberRename => 'Cambiar nombre';

  @override
  String get memberRenameTitle => 'Cambiar nombre';

  @override
  String memberRemoveTitle(String name) {
    return '¿Quitar a $name?';
  }

  @override
  String get memberRemoveBody => 'Seguirá en los gastos anteriores, pero no se podrá añadir a los nuevos.';

  @override
  String get groupLinkCopied => 'Enlace copiado. Cualquiera que lo tenga puede abrir este grupo.';

  @override
  String get groupShare => 'Compartir enlace';

  @override
  String get groupSettings => 'Ajustes del grupo';

  @override
  String get groupEdit => 'Editar grupo';

  @override
  String get groupSharing => 'Compartir';

  @override
  String get groupCopyLink => 'Copiar enlace';

  @override
  String get groupQrCode => 'Mostrar código QR';

  @override
  String get groupQrCodeHelp => 'Para que otras personas escaneen el enlace con la cámara de su teléfono.';

  @override
  String groupQrLabel(String group) {
    return 'Código QR del enlace a $group';
  }

  @override
  String get groupCopyLinkHelp => 'Cualquiera que tenga el enlace puede ver y editar este grupo.';

  @override
  String get groupCopyLinkHelpAccounts =>
      'Quienes tengan el enlace pueden solicitar unirse después de iniciar sesión.';

  @override
  String get linkAccessTitle => 'Abierto a cualquiera que tenga el enlace';

  @override
  String get linkAccessHelp => 'Permite ver y editar sin una cuenta';

  @override
  String get resetLinkTitle => 'Restablecer enlace';

  @override
  String get resetLinkHelp => 'Crear un enlace nuevo; el anterior dejará de funcionar';

  @override
  String get resetLinkBody =>
      'El enlace actual dejará de funcionar para todos. Comparte el enlace nuevo con quienes deban seguir teniendo acceso.';

  @override
  String get resetLinkAction => 'Restablecer';

  @override
  String get resetLinkDone => 'Enlace restablecido. Comparte el nuevo.';

  @override
  String get groupThisDevice => 'Este dispositivo';

  @override
  String get groupData => 'Datos';

  @override
  String get categoriesTitle => 'Categorías';

  @override
  String get categoriesHelp => 'Añade categorías propias u oculta las que no uses';

  @override
  String get categoriesOwn => 'De este grupo';

  @override
  String get categoriesOwnEmpty => 'Aún no hay categorías propias del grupo.';

  @override
  String get categoriesBuiltIn => 'Predefinidas';

  @override
  String get categoriesBuiltInHelp =>
      'Las categorías ocultas no se ofrecen para los gastos nuevos. Los gastos que ya las usan las conservan.';

  @override
  String get categoryAdd => 'Añadir categoría';

  @override
  String get categoryEdit => 'Editar categoría';

  @override
  String get categoryName => 'Nombre';

  @override
  String get categoryDelete => 'Eliminar categoría';

  @override
  String categoryDeleteTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get categoryDeleteBody => 'Los gastos de esta categoría se quedarán sin categoría.';

  @override
  String get categoryDeleteAction => 'Eliminar';

  @override
  String get exportCsv => 'Exportar como CSV';

  @override
  String get exportCsvHelp => 'Todos los gastos y pagos, para una hoja de cálculo';

  @override
  String get exportCsvDone => 'Exportado';

  @override
  String get forgetTitle => 'Quitar de este dispositivo';

  @override
  String get forgetHelp => 'El grupo seguirá en el servidor para las demás personas';

  @override
  String get forgetBody => 'Puedes volver a abrirlo con el enlace.';

  @override
  String get groupYou => 'Tú';

  @override
  String get leaveTitle => 'Salir del grupo';

  @override
  String get leaveHelp => 'Tus gastos se conservan; puedes volver a unirte con el enlace';

  @override
  String get leaveBody => 'El grupo desaparecerá de tu lista. Tus gastos y tu saldo seguirán en el grupo.';

  @override
  String get leaveAction => 'Salir';

  @override
  String get tabExpenses => 'Gastos';

  @override
  String get heroWhoTitle => '¿Quién eres en este grupo?';

  @override
  String get heroWhoBody => 'Elige tu nombre para ver lo que debes y lo que te deben.';

  @override
  String get heroWhoAction => 'Elegir';

  @override
  String get heroJoinTitle => 'Estás viendo este grupo';

  @override
  String get heroJoinBody => 'Únete para añadir gastos y ver lo que debes.';

  @override
  String get joinAction => 'Unirse';

  @override
  String get heroOwed => 'Te deben';

  @override
  String get heroOwe => 'Debes';

  @override
  String get heroSettled => 'Tus cuentas están saldadas';

  @override
  String heroYouAre(String name) {
    return 'Eres $name';
  }

  @override
  String get expenseAdd => 'Añadir gasto';

  @override
  String get expensesEmptyTitle => 'Aún no hay gastos';

  @override
  String get expensesEmptyBody => 'Añade el primero y Balnana calculará quién debe a quién.';

  @override
  String get expensesSearchHint => 'Buscar títulos, notas y lugares';

  @override
  String get searchClear => 'Borrar búsqueda';

  @override
  String get expensesNoMatchTitle => 'No hay resultados';

  @override
  String get expensesNoMatchBody => 'Prueba con otras palabras o menos filtros.';

  @override
  String get filterAnyone => 'Cualquiera';

  @override
  String get filterAnyCategory => 'Cualquier categoría';

  @override
  String get filterPayments => 'Pagos';

  @override
  String get filterClear => 'Borrar filtros';

  @override
  String get periodAll => 'Todo el tiempo';

  @override
  String get periodThisMonth => 'Este mes';

  @override
  String get periodLastMonth => 'El mes pasado';

  @override
  String get periodThisYear => 'Este año';

  @override
  String get periodPickDays => 'Elegir fechas…';

  @override
  String get statsTitle => 'Gastos';

  @override
  String get statsTotal => 'Total gastado';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count gastos', one: '1 gasto');
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'Por categoría';

  @override
  String get statsByMember => 'Pagado y repartido por persona';

  @override
  String get statsPaid => 'Pagado';

  @override
  String get statsShare => 'Parte';

  @override
  String get statsByMonth => 'Por mes';

  @override
  String get statsNoCategory => 'Sin categoría';

  @override
  String get statsEmptyTitle => 'Aún no has gastado';

  @override
  String get statsEmptyBody => 'No hay gastos en este periodo.';

  @override
  String get statsShowExpenses => 'Mostrar estos gastos';

  @override
  String get dateToday => 'Hoy';

  @override
  String get dateYesterday => 'Ayer';

  @override
  String paymentTitle(String from, String to) {
    return '$from pagó a $to';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name pagó $amount';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return '$count personas pagaron $amount';
  }

  @override
  String expensePaidByName(String name) {
    return '$name pagó';
  }

  @override
  String expensePaidByManyNames(int count) {
    return '$count personas pagaron';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name recibió $amount';
  }

  @override
  String expenseReceivedByName(String name) {
    return '$name recibió';
  }

  @override
  String expenseReceivedByManyNames(int count) {
    return '$count personas recibieron';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return '$count personas recibieron $amount';
  }

  @override
  String get transactionRefund => 'Reembolso';

  @override
  String get transactionIncome => 'Ingreso';

  @override
  String get paymentDelete => 'Eliminar pago';

  @override
  String get paymentDeleted => 'Pago eliminado';

  @override
  String expenseDeleted(String title) {
    return 'Se eliminó «$title»';
  }

  @override
  String get expenseNew => 'Nuevo gasto';

  @override
  String get expenseEdit => 'Editar gasto';

  @override
  String get expenseDelete => 'Eliminar';

  @override
  String get expenseAmount => 'Importe';

  @override
  String get expenseTitle => '¿En qué fue?';

  @override
  String get expenseTitleHint => 'Cena, entradas, taxi…';

  @override
  String get expenseAmountFromPayers => 'Total de lo que pagó cada persona';

  @override
  String expensePaidIn(String currency) {
    return 'Pagado en $currency';
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
    return 'Los saldos se mantienen en $currency. Escribe el tipo de cambio o el importe convertido, por ejemplo, el de un extracto de tarjeta.';
  }

  @override
  String get expenseNote => 'Nota';

  @override
  String get expenseNoteHint => 'Opcional';

  @override
  String get expenseLocation => 'Ubicación';

  @override
  String get expenseLocationHint => '¿Dónde fue? (opcional)';

  @override
  String get locationPickOnMap => 'Elegir en el mapa';

  @override
  String get locationUseCurrent => 'Usar ubicación actual';

  @override
  String get locationFinding => 'Buscando dónde estás…';

  @override
  String get locationChange => 'Cambiar en el mapa';

  @override
  String get locationRemovePin => 'Quitar marcador';

  @override
  String get locationOpenInMaps => 'Abrir en mapas';

  @override
  String get locationPickTitle => 'Elegir una ubicación';

  @override
  String get locationPickHint => 'Toca el mapa para poner un marcador';

  @override
  String get locationPickDone => 'Listo';

  @override
  String get locationDenied =>
      'Balnana no tiene permiso para usar tu ubicación. Puedes permitirlo en los ajustes de tu dispositivo o navegador.';

  @override
  String get locationOff => 'La ubicación está desactivada en este dispositivo.';

  @override
  String get locationUnavailable =>
      'No se pudo encontrar tu ubicación. Inténtalo de nuevo o pon un marcador en el mapa.';

  @override
  String get expenseReceipt => 'Recibo';

  @override
  String get expenseHasReceipt => 'Tiene una foto del recibo';

  @override
  String get expenseHasLocation => 'Tiene una ubicación';

  @override
  String get receiptTakePhoto => 'Hacer una foto';

  @override
  String get receiptChoose => 'Elegir una imagen';

  @override
  String get receiptRemove => 'Quitar';

  @override
  String get receiptView => 'Foto del recibo';

  @override
  String receiptNotSaved(String reason) {
    return 'El gasto se guardó, pero no la foto del recibo. $reason';
  }

  @override
  String get expensePaidByLabel => 'Pagado por';

  @override
  String get expenseReceivedForLabel => 'Para';

  @override
  String get expenseReceivedByLabel => 'Recibido por';

  @override
  String get expenseMultiplePayers => 'Varias personas';

  @override
  String get expenseSplit => 'Reparto';

  @override
  String get splitEqual => 'Por igual';

  @override
  String get splitExact => 'Por importes';

  @override
  String get splitShares => 'Por partes';

  @override
  String splitLeft(String amount) {
    return 'Faltan $amount por asignar';
  }

  @override
  String splitOver(String amount) {
    return 'Sobran $amount';
  }

  @override
  String get conflictTitle => 'Cambios en otro dispositivo';

  @override
  String get conflictReload => 'Recargar';

  @override
  String get expenseChangedElsewhere =>
      'Alguien ha cambiado este gasto. Al recargar verás su versión y se descartarán tus cambios.';

  @override
  String get suggestedPayments => 'Pagos sugeridos';

  @override
  String get allSettled => 'Todo el mundo ha saldado sus cuentas.';

  @override
  String transferYouPay(String name) {
    return 'Tú le pagas a $name';
  }

  @override
  String transferPaysYou(String name) {
    return '$name te paga';
  }

  @override
  String transferPays(String from, String to) {
    return '$from le paga a $to';
  }

  @override
  String get recordPayment => 'Registrar';

  @override
  String get recordPaymentTitle => 'Registrar un pago';

  @override
  String get recordPaymentHelp => 'Registra solo dinero que se haya pagado de verdad, fuera de Balnana.';

  @override
  String get paymentRecorded => 'Pago registrado';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who creó $group';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who cambió los datos del grupo';
  }

  @override
  String activityLinkReset(String who) {
    return '$who restableció el enlace del grupo';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who añadió a $name';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who cambió el nombre de $oldName a $name';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who quitó a $name';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who añadió la categoría $name';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who cambió las categorías';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who eliminó la categoría $name';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name se unió';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who añadió «$title» ($amount)';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who editó «$title» ($amount)';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who eliminó «$title»';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who restauró «$title»';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who registró que $from pagó a $to $amount';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who eliminó un pago de $amount';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who restauró un pago de $amount';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas',
      one: '1 entrada',
    );
    return '$who importó $_temp0 de $source';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who añadió una foto del recibo a «$title»';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who quitó la foto del recibo de «$title»';
  }

  @override
  String activityOther(String who) {
    return '$who hizo un cambio';
  }

  @override
  String get navGroups => 'Grupos';

  @override
  String get navActivity => 'Actividad';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get groupsEmptyTitle => 'Aún no hay grupos';

  @override
  String get groupsEmptyBody => 'Los grupos que crees o abras con un enlace aparecerán aquí.';

  @override
  String get groupsNoServerTitle => 'Conéctate a un servidor';

  @override
  String get groupsNoServerBody =>
      'Balnana guarda tus grupos en el servidor que elijas, por ejemplo, uno que alojes tú.';

  @override
  String get groupsNoServerAction => 'Elegir servidor';

  @override
  String get groupsUnreachableTitle => 'No se puede conectar con el servidor';

  @override
  String get groupsUnreachableBody => 'Comprueba la conexión o la dirección del servidor en Ajustes.';

  @override
  String activityPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No se pudieron cargar $count grupos, así que faltan sus cambios.',
      one: 'No se pudo cargar un grupo, así que faltan sus cambios.',
    );
    return '$_temp0';
  }

  @override
  String get activityEmptyTitle => 'Aún no hay actividad';

  @override
  String get activityEmptyBody => 'Los nuevos gastos y pagos de tus grupos aparecerán aquí.';

  @override
  String get notFoundTitle => 'No se encontró la página';

  @override
  String get notFoundBody => 'Esta dirección no lleva a ninguna parte de Balnana.';

  @override
  String get notFoundAction => 'Ir a grupos';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get accountRename => 'Cambiar nombre';

  @override
  String get passwordChange => 'Cambiar contraseña';

  @override
  String get passwordChanged => 'Contraseña cambiada. Se cerró la sesión en los demás dispositivos.';

  @override
  String get passwordSet => 'Crear contraseña';

  @override
  String get passwordSetHelp =>
      'También podrás iniciar sesión con tu correo o nombre de usuario y una contraseña.';

  @override
  String get passwordSetDone => 'Contraseña creada. Se cerró la sesión en los demás dispositivos.';

  @override
  String get passwordCurrent => 'Contraseña actual';

  @override
  String get passwordNew => 'Nueva contraseña';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get accountOAuthLinked => 'Sirve para iniciar sesión en esta cuenta. Toca para quitarlo.';

  @override
  String get accountOAuthAdd => 'Añadir como método de inicio de sesión';

  @override
  String accountOAuthAddTitle(String name) {
    return 'Añadir $name';
  }

  @override
  String accountOAuthAdded(String name) {
    return 'Ya puedes iniciar sesión con $name.';
  }

  @override
  String accountOAuthRemoveTitle(String name) {
    return '¿Quitar $name?';
  }

  @override
  String accountOAuthRemoveBody(String name) {
    return 'No podrás iniciar sesión con $name hasta que lo vuelvas a añadir.';
  }

  @override
  String get accountOAuthRemove => 'Quitar';

  @override
  String accountOAuthRemoved(String name) {
    return 'Se quitó $name.';
  }

  @override
  String get confirmEmailTitle => 'Confirma tu correo';

  @override
  String confirmEmailBody(String email) {
    return 'Este servidor requiere un correo confirmado. Abre el enlace que enviamos a $email.';
  }

  @override
  String get confirmEmailDone => 'Ya lo confirmé';

  @override
  String get confirmEmailResend => 'Enviar el enlace de nuevo';

  @override
  String get confirmEmailNotYet => 'Aún no está confirmado. Abre el enlace del correo.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Usar el del sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsDynamicColor => 'Colores del fondo de pantalla';

  @override
  String get settingsDynamicColorSubtitle =>
      'Usar los colores de tu dispositivo en lugar del amarillo de Balnana';

  @override
  String get settingsWallpaperGroups => 'Colores del fondo en los grupos';

  @override
  String get settingsWallpaperGroupsSubtitle =>
      'Los grupos también usan los colores de tu dispositivo, en lugar de los suyos';

  @override
  String get settingsPureBlack => 'Negro puro';

  @override
  String get settingsPureBlackSubtitle => 'Una versión más oscura para pantallas OLED';

  @override
  String get settingsMyShare => 'Mostrar mi parte';

  @override
  String get settingsMyShareSubtitle =>
      'Los gastos muestran lo que te deben o lo que debes, en lugar del total';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Usar el del sistema';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotificationsSubtitle =>
      'Cuando alguien añade, cambia o elimina un gasto en el que participas';

  @override
  String get settingsNotificationsBlocked =>
      'Bloqueadas en los ajustes del teléfono: permite allí las notificaciones de Balnana para verlas';

  @override
  String get pushChannel => 'Gastos';

  @override
  String get pushChannelDescription => 'Cuando alguien añade, cambia o elimina un gasto en el que participas';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who añadió $title · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who cambió $title · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who eliminó $title · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return 'Se añadió $title · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return 'Se cambió $title · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return 'Se eliminó $title · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payer pagó a $payee $amount';
  }

  @override
  String get settingsConnection => 'Conexión';

  @override
  String get settingsServer => 'Servidor';

  @override
  String get serverNotSet => 'Sin configurar';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get aboutVersion => 'Versión';

  @override
  String get aboutLicenses => 'Licencias de código abierto';

  @override
  String get aboutSource => 'Código fuente';

  @override
  String get aboutSourceCopied => 'No se pudo abrir el navegador, así que se copió el enlace';

  @override
  String get serverTitle => 'Servidor';

  @override
  String get serverIntro =>
      'Escribe la dirección de un servidor de Balnana. Cualquiera puede alojar uno; normalmente, su dirección es donde se abre la aplicación web.';

  @override
  String get serverUrlLabel => 'Dirección del servidor';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => 'Probar conexión';

  @override
  String get serverSaveAnyway => 'Guardar de todos modos';

  @override
  String get serverReset => 'Usar predeterminado';

  @override
  String serverDefault(String url) {
    return 'Predeterminado: $url';
  }

  @override
  String serverConnected(String version) {
    return 'Conectado a Balnana $version';
  }

  @override
  String get serverModeLink =>
      'Los grupos se comparten mediante un enlace privado. No hace falta una cuenta.';

  @override
  String get serverModeAccounts => 'Las personas inician sesión con una cuenta.';

  @override
  String get serverInsecure =>
      'La conexión con esta dirección no está cifrada (http). Cualquiera en la red podría leer tus datos. Usa https para servidores fuera de tu red doméstica.';

  @override
  String get serverErrorInvalid => 'Escribe una dirección web, como balnana.example.com';

  @override
  String get serverErrorUnreachable =>
      'No se pudo conectar. Comprueba la dirección y que el servidor esté en marcha.';

  @override
  String get serverErrorNotBalnana => 'El servidor respondió, pero no es un servidor de Balnana.';

  @override
  String get serverSaved => 'Servidor guardado';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get groupSignInTitle => 'Inicia sesión para abrir este grupo';

  @override
  String get groupSignInBody => 'Este grupo es solo para sus integrantes. Inicia sesión para verlo o unirte.';

  @override
  String get signInTitle => 'Te damos la bienvenida';

  @override
  String get signInBody => 'Inicia sesión para ver tus grupos.';

  @override
  String get signInNoPassword =>
      'Este servidor permite iniciar sesión de otra forma. Pregúntale a quien lo administre.';

  @override
  String get registerTitle => 'Crea tu cuenta';

  @override
  String get registerBody => 'Ten tus grupos en todos tus dispositivos.';

  @override
  String get registerAction => 'Crear cuenta';

  @override
  String get registerHaveAccount => 'Ya tengo una cuenta';

  @override
  String get signInNoAccount => 'Crear una cuenta';

  @override
  String get accountName => 'Tu nombre';

  @override
  String get accountNameHelp => 'El nombre que verán las personas de tus grupos';

  @override
  String get accountEmail => 'Correo electrónico';

  @override
  String get accountPassword => 'Contraseña';

  @override
  String get accountPasswordHelp => 'Al menos 8 caracteres';

  @override
  String get passwordShow => 'Mostrar contraseña';

  @override
  String get passwordHide => 'Ocultar contraseña';

  @override
  String get joinPickName => 'Elegir otro nombre';

  @override
  String joinTitle(String name) {
    return 'Unirte a $name';
  }

  @override
  String get joinBody => '¿Eres una de estas personas? Elige cuál eres para hacerte cargo de sus gastos.';

  @override
  String get joinBodyNew => 'Únete para añadir gastos y ver tu saldo.';

  @override
  String get joinAsNew => 'Soy una persona nueva';

  @override
  String joinAsName(String name) {
    return 'Unirme como $name';
  }

  @override
  String joinTaken(String names) {
    return 'Ya se unieron: $names';
  }

  @override
  String joinTakenCount(int count) {
    return '$count personas ya se unieron.';
  }

  @override
  String get commonContinue => 'Continuar';

  @override
  String get errorEmailOff => 'Este servidor no envía correos.';

  @override
  String get errorInvalidToken => 'Este enlace ha caducado o ya se ha usado.';

  @override
  String get forgotPasswordTitle => '¿Olvidaste la contraseña?';

  @override
  String get forgotPasswordBody => 'Te enviaremos un enlace para elegir una contraseña nueva.';

  @override
  String get forgotPasswordAction => 'Enviar enlace';

  @override
  String get forgotPasswordSent => 'Si hay una cuenta con esa dirección, pronto recibirás un enlace.';

  @override
  String get resetPasswordTitle => 'Elige una contraseña nueva';

  @override
  String get resetPasswordBody =>
      'Se cerrará tu sesión en todos los dispositivos y podrás iniciar sesión con la contraseña nueva.';

  @override
  String get resetPasswordAction => 'Guardar contraseña';

  @override
  String get resetPasswordDone => 'Contraseña cambiada. Inicia sesión con la nueva contraseña.';

  @override
  String get verifyEmailTitle => 'Confirma tu correo';

  @override
  String get verifyEmailHelp => 'Así podrás restablecer la contraseña si la olvidas';

  @override
  String verifyEmailSent(String email) {
    return 'Busca el enlace en $email.';
  }

  @override
  String get verifyEmailDone => 'Correo confirmado';

  @override
  String get verifyEmailDoneBody => '¡Gracias! Tu dirección está confirmada.';

  @override
  String get verifyEmailFailed => 'No se pudo confirmar tu correo';

  @override
  String get inviteByEmail => 'Invitar por correo';

  @override
  String get inviteByEmailHelp => 'Enviar un enlace para que alguien se una';

  @override
  String get inviteAs => 'Unirse como';

  @override
  String get inviteAsHelp => 'La persona invitada podrá hacerse cargo de los gastos de esta persona';

  @override
  String get inviteAsAnyone => 'Alguien nuevo';

  @override
  String get inviteSend => 'Enviar invitación';

  @override
  String inviteSent(String email) {
    return 'Invitación enviada a $email.';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name te invitó a $group';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return 'Te invitaron a $group';
  }

  @override
  String inviteBody(String email) {
    return 'Crea una cuenta con $email para unirte o inicia sesión si ya tienes una.';
  }

  @override
  String get inviteBodySignedIn => 'Únete para añadir gastos y ver tu saldo.';

  @override
  String get inviteAction => 'Abrir invitación';

  @override
  String get inviteMissingTitle => 'Esta invitación no funciona';

  @override
  String get inviteMissingBody => 'Puede que haya caducado o ya se haya usado. Pide una nueva.';

  @override
  String get joinInvitedAs => 'Te invitaron como esta persona';

  @override
  String signInWith(String provider) {
    return 'Continuar con $provider';
  }

  @override
  String get signInOr => 'o';

  @override
  String get oauthFailedTitle => 'No se pudo iniciar sesión';

  @override
  String get oauthPendingTitle => 'Este correo ya tiene una cuenta';

  @override
  String oauthPendingBody(String provider, String email) {
    return '$provider dice que $email te pertenece, pero la cuenta con ese correo no está confirmada. ¿Qué quieres hacer?';
  }

  @override
  String get oauthPendingLink => 'Añadir a esa cuenta';

  @override
  String get oauthPendingLinkHelp => 'Escribe la contraseña de esa cuenta. Seguirás pudiendo usarla.';

  @override
  String get oauthPendingTakeOver => 'Hacerte cargo de esa cuenta';

  @override
  String get oauthPendingTakeOverHelp =>
      'Se quitarán la contraseña y los demás métodos de inicio de sesión de esa cuenta, y se cerrará su sesión en todos los dispositivos.';

  @override
  String get oauthPendingNew => 'Crear una cuenta nueva';

  @override
  String oauthPendingNewHelp(String email) {
    return 'La otra cuenta conservará sus grupos, pero dejará de tener $email.';
  }

  @override
  String get oauthPendingPassword => 'Contraseña de esa cuenta';

  @override
  String get oauthPendingWrongPassword => 'Esa contraseña no es correcta.';

  @override
  String get oauthOtherServer =>
      'Este inicio de sesión se inició en otro servidor distinto del elegido ahora. Inicia sesión de nuevo.';

  @override
  String get oauthBackToSignIn => 'Volver a iniciar sesión';

  @override
  String get errorOAuthFailed => 'No se pudo iniciar sesión. Inténtalo de nuevo.';

  @override
  String get errorEmailHasAccount =>
      'Ya hay una cuenta con este correo. Inicia sesión y añade este método desde Ajustes.';

  @override
  String get errorIdentityTaken => 'Este método de inicio de sesión ya pertenece a otra cuenta.';

  @override
  String get errorLastSignInMethod =>
      'Esta es tu única forma de iniciar sesión. Primero crea una contraseña o añade otro método.';

  @override
  String get errorEmailUnverified => 'Primero confirma tu correo.';

  @override
  String get errorOAuthCancelled => 'Se canceló el inicio de sesión.';

  @override
  String get importTitle => 'Importar desde Settle Up';

  @override
  String get importAction => 'Importar';

  @override
  String get importIntro =>
      'En Settle Up, exporta el grupo como archivo CSV y luego elige aquí el archivo. Se importarán los gastos, los pagos y todas las personas del grupo; los saldos se mantendrán igual.';

  @override
  String get importChooseFile => 'Elegir archivo CSV';

  @override
  String get importChooseOther => 'Elegir otro archivo';

  @override
  String get importReading => 'Leyendo el archivo…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(
      expenses,
      locale: localeName,
      other: '$expenses gastos',
      one: '1 gasto',
    );
    String _temp1 = intl.Intl.pluralLogic(
      payments,
      locale: localeName,
      other: '$payments pagos',
      one: '1 pago',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return '$from a $to';
  }

  @override
  String importCurrency(String currency) {
    return 'Moneda: $currency. Los importes de otras monedas son los que convirtió Settle Up.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se omiten $count entradas con importe cero.',
      one: 'Se omite 1 entrada con importe cero.',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => '¿Cuál eres tú?';

  @override
  String get importUntitled => 'Sin título';

  @override
  String get errorImportFile => 'Esto no parece un archivo CSV exportado desde Settle Up.';

  @override
  String get errorImportCurrency =>
      'El archivo no tiene entradas sin tipo de cambio, así que no se puede saber cuál es la moneda del grupo.';

  @override
  String get errorImportTooBig => 'Este archivo es demasiado grande para importarlo.';

  @override
  String get errorBadImage => 'No se puede usar esa imagen. Elige una imagen JPEG, PNG o WebP.';

  @override
  String get errorReceiptTooBig => 'Esa imagen es demasiado grande. Elige una de menos de 10 MB.';

  @override
  String get errorImportMe => 'Elige cuál de estas personas eres.';

  @override
  String errorImportRow(int line, String reason) {
    return 'No se puede importar la línea $line del archivo: $reason';
  }

  @override
  String get errorImportAmount => 'no se puede leer un importe.';

  @override
  String get errorImportCounts => 'los nombres y los importes no coinciden.';

  @override
  String get errorImportDate => 'no se puede leer la fecha.';

  @override
  String get errorImportType => 'el tipo no es gasto, transferencia ni ingreso.';

  @override
  String get errorImportTransfer => 'una transferencia necesita una persona que pague a otra.';

  @override
  String get errorImportRowCurrency => 'está en otra moneda y no tiene tipo de cambio.';

  @override
  String get adminSetupTitle => 'Configurar este servidor';

  @override
  String get adminSetupBody =>
      'Elige una contraseña para el administrador. Protege esta página, donde están los ajustes del servidor. No hay nombre de usuario: cualquiera que conozca la contraseña puede cambiar los ajustes.';

  @override
  String get adminSetupCode => 'Código de configuración';

  @override
  String get adminSetupCodeHelp =>
      'Este servidor ya tiene datos, así que al iniciarse imprimió un código de configuración en el registro. Con Docker: docker compose logs balnana';

  @override
  String get adminSetupAction => 'Crear contraseña';

  @override
  String get adminPassword => 'Contraseña del administrador';

  @override
  String get adminPasswordRepeat => 'Repetir contraseña';

  @override
  String get adminPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get adminLoginTitle => 'Administración';

  @override
  String get adminLoginBody =>
      'Escribe la contraseña del administrador para cambiar los ajustes del servidor.';

  @override
  String get adminLoginAction => 'Iniciar sesión';

  @override
  String get adminSettingsTitle => 'Ajustes del servidor';

  @override
  String get adminSaved => 'Ajustes guardados. Se aplican de inmediato.';

  @override
  String get adminSaveFailed => 'No se guardó nada. Comprueba los ajustes resaltados.';

  @override
  String get adminChangePassword => 'Cambiar contraseña del administrador';

  @override
  String get adminPasswordCurrent => 'Contraseña actual';

  @override
  String get adminPasswordNew => 'Nueva contraseña';

  @override
  String get adminPasswordChanged =>
      'Contraseña cambiada. Se cerró la sesión en las demás sesiones de administración.';

  @override
  String get adminSignOut => 'Cerrar sesión de administración';

  @override
  String get adminBackHome => 'Volver a Balnana';

  @override
  String get adminRequireEmail => 'Exigir una dirección de correo';

  @override
  String get adminRequireEmailHelp =>
      'Si está desactivado, las personas se registran con un nombre de usuario y pueden omitir el correo. Pueden iniciar sesión con cualquiera de los dos.';

  @override
  String get adminRequireEmailUnused =>
      'Solo se aplica al inicio de sesión con correo y contraseña, que está desactivado.';

  @override
  String get accountUsername => 'Nombre de usuario';

  @override
  String get accountUsernameHelp =>
      'De 3 a 32 letras, números, puntos, guiones o guiones bajos. Se usa para iniciar sesión.';

  @override
  String get accountEmailOptional => 'Correo electrónico (opcional)';

  @override
  String get accountEmailOptionalHelp =>
      'Te permite recibir invitaciones a grupos y restablecer una contraseña olvidada.';

  @override
  String get accountLogin => 'Correo o nombre de usuario';

  @override
  String get errorInvalidUsername =>
      'Usa entre 3 y 32 letras, números, puntos, guiones o guiones bajos, y empieza con una letra o un número.';

  @override
  String get errorUsernameTaken => 'Alguien ya tiene ese nombre de usuario.';

  @override
  String get adminDiscardTitle => '¿Descartar los cambios?';

  @override
  String get adminDiscardBody => 'No se han guardado los cambios en los ajustes.';

  @override
  String get adminDiscard => 'Descartar';

  @override
  String adminLocked(String key) {
    return 'Configurado en el servidor por $key';
  }

  @override
  String adminDefault(String value) {
    return 'Predeterminado: $value';
  }

  @override
  String get adminSecretSaved => 'Guardado. Escribe uno nuevo para reemplazarlo.';

  @override
  String get adminSecretRemoved => 'Se quitará al guardar.';

  @override
  String get adminSecretRemove => 'Quitar el valor guardado';

  @override
  String get adminSectionGeneral => 'General';

  @override
  String get adminSectionAccess => 'Acceso';

  @override
  String get adminSectionMaps => 'Mapas';

  @override
  String get adminSectionAccounts => 'Cuentas';

  @override
  String get adminSectionAccountsBody =>
      'Estos ajustes se aplican cuando el acceso está configurado para cuentas.';

  @override
  String get adminSectionEmail => 'Correo electrónico (SMTP)';

  @override
  String get adminSectionEmailBody =>
      'Verificación de direcciones, restablecimiento de contraseñas e invitaciones.';

  @override
  String get adminSmtpOn => 'Enviar correo';

  @override
  String get adminSectionGoogle => 'Iniciar sesión con Google';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Registra $url como URI de redirección en la consola de Google Cloud.';
  }

  @override
  String get adminGoogleOn => 'Ofrecer inicio de sesión con Google';

  @override
  String get adminGoogleOnHelp => 'Las personas inician sesión con su cuenta de Google.';

  @override
  String get adminSectionOidc => 'Iniciar sesión con OpenID Connect';

  @override
  String adminSectionOidcBody(String url) {
    return 'Registra $url como URI de redirección con el proveedor.';
  }

  @override
  String get adminOidcHelp =>
      'Cualquier proveedor de OpenID Connect, como Authentik, Keycloak o Dex. Añade tantos como quieras.';

  @override
  String get adminOidcAdd => 'Añadir proveedor';

  @override
  String get adminOidcRemove => 'Quitar proveedor';

  @override
  String get adminOidcNew => 'Nuevo proveedor';

  @override
  String get adminOidcId => 'ID';

  @override
  String get adminOidcIdHelp =>
      'Letras minúsculas, números y guiones. Forma parte de la URI de redirección y no se puede cambiar después.';

  @override
  String get adminOidcIdInvalid =>
      'Usa hasta 32 letras minúsculas, números y guiones; empieza con una letra o un número.';

  @override
  String get adminOidcIdTaken => 'Otro proveedor ya tiene este ID.';

  @override
  String get adminTrustEmail => 'Confiar en el correo verificado';

  @override
  String get adminGoogleTrustEmailHelp =>
      'Si alguien inicia sesión con Google usando un correo que ya tiene una cuenta, entrará en ella. Desactivado: iniciará sesión con su contraseña y añadirá Google en Ajustes.';

  @override
  String get adminOidcTrustEmailHelp =>
      'Úsalo solo con un proveedor que administres o que confíes para verificar correos. Desactivado: quienes tengan cuenta iniciarán sesión con su contraseña y lo añadirán en Ajustes.';

  @override
  String get adminRequireVerified => 'Exigir un correo confirmado';

  @override
  String get adminRequireVerifiedHelp =>
      'Las cuentas no pueden usar la aplicación hasta confirmar su correo. Además, si un proveedor de confianza confirma el mismo correo, se usará para acceder a la cuenta sin confirmar. Desactivado: cada persona elige qué ocurre.';

  @override
  String get adminRequireVerifiedUnused => 'Requiere el envío de correo.';

  @override
  String get adminSectionAndroid => 'Enlaces de la aplicación Android';

  @override
  String get adminSectionAndroidBody =>
      'Las versiones de Android creadas para este servidor abren sus enlaces en la aplicación. Para omitir la pregunta, indica las huellas SHA-256 de los certificados con los que están firmadas.';

  @override
  String get adminSectionAdmin => 'Administrador';

  @override
  String get adminPublicUrl => 'Dirección pública';

  @override
  String get adminPublicUrlHelp =>
      'Dirección que se usa para acceder a este servidor. Los enlaces de grupos y de correo se crean a partir de ella.';

  @override
  String get adminSourceUrl => 'Enlace al código fuente';

  @override
  String get adminSourceUrlHelp =>
      'Dónde se puede obtener el código fuente del servidor, como exige la licencia (AGPL-3.0) si ejecutas una versión modificada.';

  @override
  String get adminAuthMode => 'Acceso';

  @override
  String get adminAuthModeLink => 'Enlaces de grupo';

  @override
  String get adminAuthModeLinkHelp => 'Sin inicio de sesión: basta con el enlace privado de un grupo.';

  @override
  String get adminAuthModeAccounts => 'Cuentas';

  @override
  String get adminAuthModeAccountsHelp =>
      'Las personas inician sesión y solo quienes hayan iniciado sesión pueden unirse a un grupo mediante un enlace.';

  @override
  String get adminPasswordLogin => 'Iniciar sesión con correo y contraseña';

  @override
  String get adminPasswordForced =>
      'Se mantiene activado hasta que se habilite el inicio de sesión con Google u OpenID Connect, para que siempre haya una forma de iniciar sesión.';

  @override
  String get adminSignup => 'Quién puede crear una cuenta';

  @override
  String get adminSignupOpen => 'Cualquiera';

  @override
  String get adminSignupOpenHelp => 'Cualquiera que pueda acceder a este servidor puede crear una cuenta.';

  @override
  String get adminSignupInvite => 'Personas invitadas';

  @override
  String get adminSignupInviteHelp =>
      'Solo pueden crear una cuenta las personas invitadas a un grupo por correo, y únicamente con la dirección a la que se envió la invitación. Los enlaces de grupo no bastan para acceder. El envío de invitaciones requiere que el correo esté activado.';

  @override
  String get adminSignupClosed => 'Nadie';

  @override
  String get adminSignupClosedHelp =>
      'Nadie puede crear una cuenta. Las cuentas existentes seguirán funcionando.';

  @override
  String get adminSignupHelp => 'Siempre se puede crear la primera cuenta.';

  @override
  String get adminLinkGroups => 'Permitir abrir grupos con un enlace';

  @override
  String get adminLinkGroupsHelp =>
      'Los propietarios de grupos pueden permitir el acceso a cualquiera que tenga el enlace, sin iniciar sesión.';

  @override
  String get adminSmtpHost => 'Servidor de correo';

  @override
  String get adminSmtpPort => 'Puerto';

  @override
  String get adminSmtpUser => 'Nombre de usuario';

  @override
  String get adminSmtpPassword => 'Contraseña';

  @override
  String get adminSmtpFrom => 'Remitente';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'ID de cliente';

  @override
  String get adminClientSecret => 'Secreto de cliente';

  @override
  String get adminOidcIssuer => 'URL del emisor';

  @override
  String get adminOidcName => 'Nombre del botón';

  @override
  String get adminOidcNameHelp => 'Se muestra como «Continuar con…» en la página de inicio de sesión.';

  @override
  String get adminFingerprints => 'Huellas de certificados';

  @override
  String get adminFingerprintsHelp =>
      'SHA-256, separadas por comas. Puedes verlas con keytool -list -v y apksigner verify --print-certs.';

  @override
  String get adminInvalidValue => 'Este valor no es válido.';

  @override
  String get adminInvalidUrl => 'Escribe una dirección completa que empiece por https:// o http://.';

  @override
  String get adminInvalidFrom =>
      'Escribe un remitente con dirección de correo, por ejemplo, Balnana <balnana@example.com>.';

  @override
  String get adminInvalidPort => 'Escribe un número de puerto entre 1 y 65535.';

  @override
  String get adminInvalidRequired => 'Este proveedor de inicio de sesión necesita este dato.';

  @override
  String get adminInvalidFingerprint =>
      'Escribe huellas SHA-256: 64 dígitos hexadecimales cada una, se permiten dos puntos.';

  @override
  String get adminNeedsSignIn =>
      'Las cuentas necesitan una forma de iniciar sesión: activa el correo y la contraseña o configura un proveedor.';

  @override
  String get adminLockedChange => 'Este ajuste está definido en el servidor y no se puede cambiar aquí.';

  @override
  String get errorAdminRequired => 'Tu sesión de administrador ha terminado. Inicia sesión de nuevo.';

  @override
  String get errorAdminWrongPassword => 'Esa contraseña no es correcta.';

  @override
  String get errorInvalidSetupCode =>
      'Ese código de configuración no es correcto. Búscalo en el registro del servidor.';

  @override
  String get errorAlreadySetUp =>
      'Este servidor ya está configurado. Inicia sesión con la contraseña del administrador.';

  @override
  String get linkOpening => 'Abriendo enlace…';

  @override
  String get linkForeignTitle => 'Este enlace es de otro servidor';

  @override
  String linkForeignBody(String server) {
    return 'Esta aplicación está conectada a $server, pero el enlace pertenece a otro servidor. Cambia el servidor en Ajustes para abrirlo.';
  }

  @override
  String get linkInvalidTitle => 'No se puede abrir este enlace';

  @override
  String get linkInvalidBody => 'La aplicación no reconoce este enlace de Balnana.';

  @override
  String get linkGoHome => 'Ir a grupos';

  @override
  String get linkOpenInBrowser => 'Abrir en el navegador';

  @override
  String get privacyTitle => 'Política de privacidad';

  @override
  String get privacyIntro =>
      'Balnana es un programa de código abierto. Quien administra el servidor al que está conectada esta aplicación decide dónde se guardan tus datos y es responsable de ellos. Esta página describe qué guarda y hace el programa.';

  @override
  String get privacyStoredTitle => 'Qué datos se guardan';

  @override
  String get privacyStoredBody =>
      'Los grupos que creas o a los que te unes: sus nombres, los nombres de sus integrantes, los gastos, los pagos, las notas, las fotos de recibos y los lugares que añades a los gastos. Si tienes una cuenta, también se guardan tu nombre, tu correo electrónico o nombre de usuario, un hash de tu contraseña (nunca la contraseña en sí) y el proveedor con el que inicias sesión, como Google. Si activas las notificaciones, se guarda un identificador de tu dispositivo y la dirección que le asignó el servicio de notificaciones.';

  @override
  String get privacyUseTitle => 'Cómo se usan';

  @override
  String get privacyUseBody =>
      'Solo para que funcione la aplicación: mostrar cada grupo a sus integrantes, calcular los saldos y enviar los correos y las notificaciones que necesita, como la verificación de direcciones, el restablecimiento de contraseñas y las invitaciones. La aplicación no tiene anuncios ni análisis de uso, y no se vende ningún dato.';

  @override
  String get privacySharedTitle => 'Quién puede verlos';

  @override
  String get privacySharedBody =>
      'Todas las personas de un grupo ven a sus integrantes, los gastos y el historial. Si un grupo está abierto mediante un enlace, cualquiera que lo tenga puede abrirlo. El inicio de sesión con Google se realiza a través de Google. Si quien administra el servidor activa las notificaciones, estas se envían mediante el servicio que usa tu teléfono: Firebase Cloud Messaging de Google u otro servicio UnifiedPush que hayas instalado, como ntfy. El contenido de las notificaciones se cifra durante el envío. Los mapas cargan sus imágenes del proveedor elegido por quien administra el servidor: OpenFreeMap, salvo que lo haya cambiado. Ese proveedor ve tu dirección de red y la zona que consultas. Tu ubicación solo se lee cuando tocas «Usar ubicación actual», y solo se guarda el punto que decidas conservar.';

  @override
  String get privacyDeviceTitle => 'En este dispositivo';

  @override
  String get privacyDeviceBody =>
      'La aplicación guarda la dirección del servidor, tus ajustes y una copia de tus grupos para cuando no tengas conexión. Al desinstalarla, se eliminan.';

  @override
  String get privacyDeleteTitle => 'Eliminar tus datos';

  @override
  String get privacyDeleteBody =>
      'Puedes eliminar tu cuenta desde Ajustes. Tu nombre seguirá en tus grupos como integrante sin cuenta vinculada, para que los saldos sigan cuadrando. También se eliminarán los grupos a los que nadie más pueda acceder. El propietario de un grupo puede eliminarlo entero desde sus ajustes. Para cualquier otra cosa, contacta con quien administra el servidor.';

  @override
  String get privacyOperatorPolicy => 'Política de privacidad del servidor';

  @override
  String get privacyLink => 'Privacidad';

  @override
  String get accountEmailAdd => 'Añadir correo electrónico';

  @override
  String get accountEmailChange => 'Cambiar correo electrónico';

  @override
  String get accountEmailNew => 'Correo electrónico';

  @override
  String get accountEmailVerifyNote =>
      'Recibirás un enlace para confirmar la dirección nueva. La actual seguirá en uso hasta entonces.';

  @override
  String get accountEmailPendingTitle => 'Confirma tu correo nuevo';

  @override
  String accountEmailPendingHelp(String email) {
    return '$email sustituirá a tu dirección actual cuando abras el enlace que te enviamos. Toca para volver a enviarlo.';
  }

  @override
  String get accountEmailRemoveNote =>
      'Déjalo vacío para quitar tu dirección. Podrás seguir iniciando sesión con tu nombre de usuario.';

  @override
  String get accountEmailSaved => 'Correo electrónico guardado';

  @override
  String get accountEmailRemoved => 'Correo electrónico eliminado';

  @override
  String get accountConfirmPassword => 'Tu contraseña';

  @override
  String get accountConfirmPasswordHelp => 'Para confirmar que eres tú.';

  @override
  String get errorEmailNeeded => 'Inicias sesión con tu correo electrónico, así que no puedes quitarlo.';

  @override
  String get accountDelete => 'Eliminar cuenta';

  @override
  String get accountDeleteHelp => 'Quitar tu cuenta de este servidor';

  @override
  String get accountDeleteTitle => '¿Eliminar tu cuenta?';

  @override
  String get accountDeleteBody =>
      'Tu cuenta se eliminará definitivamente y se cerrará tu sesión. En tus grupos, tu nombre seguirá como integrante sin cuenta vinculada, para que los saldos sigan cuadrando. Se eliminarán los grupos en los que no haya nadie más.';

  @override
  String get accountDeleteAction => 'Eliminar definitivamente';

  @override
  String get accountDeleted => 'Se ha eliminado tu cuenta.';

  @override
  String get accountDeletePageSignedOut => 'Inicia sesión para eliminar tu cuenta de este servidor.';

  @override
  String get accountDeletePageLinkMode =>
      'Este servidor no tiene cuentas: basta con el enlace de un grupo. Para eliminar un grupo con todo lo que contiene, abre sus ajustes y elige «Eliminar grupo».';

  @override
  String get groupDelete => 'Eliminar grupo';

  @override
  String get groupDeleteHelp => 'Eliminarlo con todos sus gastos para todas las personas';

  @override
  String groupDeleteTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get groupDeleteBody =>
      'El grupo y todos sus gastos, pagos e historial se eliminarán para todos. Esta acción no se puede deshacer. Escribe el nombre del grupo para confirmarlo.';

  @override
  String get groupDeleteName => 'Nombre del grupo';

  @override
  String get groupDeleteAction => 'Eliminar definitivamente';

  @override
  String get groupDeleted => 'Grupo eliminado';

  @override
  String get groupDeleteOwnerOnly => 'Solo el propietario del grupo puede eliminarlo.';

  @override
  String get expenseDiscardTitle => '¿Descartar los cambios?';

  @override
  String get expenseDiscardBody => 'No se han guardado los cambios de este gasto.';

  @override
  String get expenseDiscard => 'Descartar';

  @override
  String get adminPrivacyUrl => 'Enlace a la política de privacidad';

  @override
  String get adminPrivacyUrlHelp =>
      'La política de privacidad que solicitan las tiendas de aplicaciones. Si lo dejas vacío, la aplicación muestra información general sobre los datos que guarda Balnana.';

  @override
  String get adminMapTiles => 'Teselas del mapa';

  @override
  String get adminMapSource => 'Fuente del mapa';

  @override
  String get adminMapSourceStyle => 'Estilo vectorial';

  @override
  String get adminMapSourceStyleHelp =>
      'Mapas basados en un estilo de MapLibre, como los de OpenFreeMap, gratis y sin necesidad de clave.';

  @override
  String get adminMapSourceTiles => 'Teselas ráster';

  @override
  String get adminMapSourceTilesHelp =>
      'Mapas que se muestran como imágenes de teselas, como las de OpenStreetMap.';

  @override
  String get adminMapSourceOff => 'Desactivado';

  @override
  String get adminMapSourceOffHelp => 'Sin mapas. Los gastos siguen guardando nombres de lugares y puntos.';

  @override
  String get adminMapStyle => 'URL del estilo';

  @override
  String get adminMapStyleHelp =>
      'Dirección de un archivo style.json de MapLibre, como Liberty (el predeterminado), Bright o Positron de OpenFreeMap.';

  @override
  String get adminMapTilesHelp =>
      'Plantilla de URL para teselas ráster con z, x e y entre llaves, como la predeterminada. Los servidores propios de OpenStreetMap son solo para uso ligero; si hay mucho tráfico, usa un proveedor de teselas.';

  @override
  String get adminMapAttribution => 'Atribución del mapa';

  @override
  String get adminMapAttributionHelp =>
      'Se muestra en cada mapa, como pide el proveedor. Si se deja vacío, el estilo muestra los créditos que indica y las teselas muestran los de OpenStreetMap.';

  @override
  String get adminInvalidMapTiles => 'Escribe una plantilla de URL http(s) con z, x e y entre llaves.';

  @override
  String get adminUsers => 'Cuentas';

  @override
  String get adminUsersSearch => 'Buscar por nombre, correo o nombre de usuario';

  @override
  String adminUsersShown(int shown, int total) {
    return '$shown de $total cuentas';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cuentas',
      one: '1 cuenta',
    );
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => 'No hay cuentas que coincidan.';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos',
      one: '1 grupo',
      zero: 'Ningún grupo',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => 'sin verificar';

  @override
  String adminUserDeleteTitle(String name) {
    return '¿Eliminar la cuenta de $name?';
  }

  @override
  String get adminUserDeleteBody =>
      'La cuenta se eliminará definitivamente y se cerrará la sesión en todos los dispositivos. Su nombre seguirá en sus grupos como integrante sin cuenta vinculada; se eliminarán los grupos en los que no haya nadie más.';

  @override
  String get adminUserDeleted => 'Cuenta eliminada';

  @override
  String get commonDone => 'Listo';

  @override
  String get crowdSearch => 'Buscar personas';

  @override
  String get crowdNoMatch => 'Nadie coincide.';

  @override
  String get crowdAll => 'Todas';

  @override
  String get crowdNone => 'Ninguna';

  @override
  String crowdChosen(int count, int total) {
    return '$count de $total personas seleccionadas';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count más', one: '1 más');
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => 'Mostrar menos';

  @override
  String get crowdSort => 'Ordenar';

  @override
  String crowdShowAll(int count) {
    return 'Mostrar los $count integrantes';
  }

  @override
  String get crowdBalances => 'Saldos de todos';

  @override
  String get crowdSomeoneElse => 'Otra persona';

  @override
  String get crowdChoosePayers => 'Elegir quiénes pagan';

  @override
  String get crowdFilterTitle => '¿De quién son los gastos?';

  @override
  String get myGroupsTitle => 'Mis enlaces de grupo';

  @override
  String get myGroupsExport => 'Exportar mis grupos';

  @override
  String get myGroupsExportHelp =>
      'Copia los enlaces de tus grupos para guardar una copia de seguridad o pasarlos a otro dispositivo.';

  @override
  String get myGroupsPrivate =>
      'Mantén estos enlaces en privado. Cualquiera que tenga uno puede abrir el grupo.';

  @override
  String get myGroupsCopy => 'Copiar enlaces';

  @override
  String get myGroupsImport => 'Importar grupos';

  @override
  String get myGroupsImportHelp =>
      'Pega enlaces de grupos de este servidor, uno por línea. Los grupos que ya tienes conservarán su posición y su identidad.';

  @override
  String get myGroupsLinks => 'Enlaces de grupo';

  @override
  String get myGroupsImportAction => 'Importar enlaces';

  @override
  String get myGroupsInvalid => 'Escribe enlaces de grupo válidos, uno por línea. No se importó nada.';

  @override
  String get myGroupsServerChanged =>
      'El servidor seleccionado ha cambiado. Cierra este cuadro e importa los enlaces en su servidor.';

  @override
  String myGroupsLimit(int count) {
    return 'Guarda como máximo $count enlaces de grupo por servidor. No se importó nada.';
  }

  @override
  String myGroupsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se importaron $count enlaces de grupo nuevos.',
      one: 'Se importó 1 enlace de grupo nuevo.',
      zero: 'Estos grupos ya están guardados.',
    );
    return '$_temp0';
  }

  @override
  String get repeatSection => 'Repetir';

  @override
  String get repeatNever => 'No repetir';

  @override
  String get repeatDaily => 'Cada día';

  @override
  String get repeatWeekly => 'Cada semana';

  @override
  String get repeatMonthly => 'Cada mes';

  @override
  String get repeatYearly => 'Cada año';

  @override
  String get repeatEvery => 'Cada';

  @override
  String repeatUnitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'días', one: 'día');
    return '$_temp0';
  }

  @override
  String repeatUnitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'semanas', one: 'semana');
    return '$_temp0';
  }

  @override
  String repeatUnitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'meses', one: 'mes');
    return '$_temp0';
  }

  @override
  String repeatUnitYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'años', one: 'año');
    return '$_temp0';
  }

  @override
  String repeatIntervalDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count días',
      one: 'Cada día',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count semanas',
      one: 'Cada semana',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count meses',
      one: 'Cada mes',
    );
    return '$_temp0';
  }

  @override
  String repeatIntervalYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cada $count años',
      one: 'Cada año',
    );
    return '$_temp0';
  }

  @override
  String get repeatEndNone => 'Sin fecha de finalización';

  @override
  String repeatEndOn(String date) {
    return 'Hasta $date';
  }

  @override
  String get repeatEndClear => 'Quitar la fecha de finalización';

  @override
  String get repeatHelp =>
      'Se añade automáticamente al grupo en cada fecha a partir de la indicada arriba. Las fechas pasadas se añadirán al guardar.';

  @override
  String get repeatDropReceiptTitle => '¿Quitar el recibo?';

  @override
  String get repeatDropReceiptBody =>
      'Un gasto periódico no puede conservar un recibo. Puedes añadir uno a cada gasto que genere.';

  @override
  String get repeatDropReceiptAction => 'Repetir';

  @override
  String get recurringTitle => 'Gastos periódicos';

  @override
  String get recurringHelp => 'Gastos que se añaden automáticamente según un calendario';

  @override
  String get recurringEmptyTitle => 'Aún no hay gastos periódicos';

  @override
  String get recurringEmptyBody =>
      'El alquiler, las suscripciones y otros gastos habituales se pueden añadir automáticamente en cada fecha.';

  @override
  String get recurringAdd => 'Añadir gasto periódico';

  @override
  String get recurringEdit => 'Editar gasto periódico';

  @override
  String recurringNext(String date) {
    return 'Próximo: $date';
  }

  @override
  String get recurringPaused => 'En pausa';

  @override
  String get recurringEnded => 'Finalizado';

  @override
  String get recurringPause => 'Pausar';

  @override
  String get recurringResume => 'Reanudar';

  @override
  String get recurringActive => 'Se repite';

  @override
  String get recurringDelete => 'Eliminar';

  @override
  String get recurringDeleteTitle => '¿Dejar de repetir?';

  @override
  String recurringDeleteBody(String title) {
    return '«$title» no se volverá a añadir. Se conservarán los gastos que ya haya generado.';
  }

  @override
  String get recurringDeleted => 'Gasto periódico eliminado';

  @override
  String get recurringFromSchedule => 'Añadido por un gasto periódico';

  @override
  String get recurringOpen => 'Cambiar el calendario';

  @override
  String get recurringMissing => 'El gasto periódico se eliminó o ya no está disponible.';

  @override
  String get errorTooManyDue =>
      'Esa fecha de inicio es demasiado antigua: se añadirían más de 100 gastos de una vez.';

  @override
  String get errorInvalidEnd => 'La fecha de finalización no puede ser anterior a la de inicio.';

  @override
  String get errorInvalidRepeat => 'El intervalo debe ser de 1 a 999 días, semanas, meses o años.';

  @override
  String get errorRecurringConflict =>
      'Alguien ha cambiado este gasto periódico mientras lo editabas. Recarga la página para ver los cambios.';

  @override
  String activityRecurringCreated(String who, String title) {
    return '$who configuró «$title» para que se repita';
  }

  @override
  String activityRecurringUpdated(String who, String title) {
    return '$who cambió el gasto periódico «$title»';
  }

  @override
  String activityRecurringPaused(String who, String title) {
    return '$who puso en pausa el gasto periódico «$title»';
  }

  @override
  String activityRecurringPausedMemberLeft(String title) {
    return 'El gasto periódico «$title» se puso en pausa porque alguien que participaba se fue del grupo';
  }

  @override
  String activityRecurringPausedFailed(String title) {
    return 'El gasto periódico «$title» se puso en pausa porque no se pudo añadir';
  }

  @override
  String activityRecurringResumed(String who, String title) {
    return '$who reanudó el gasto periódico «$title»';
  }

  @override
  String activityRecurringDeleted(String who, String title) {
    return '$who dejó de repetir el gasto «$title»';
  }

  @override
  String activityRecurringAdded(String title, String amount) {
    return '«$title» ($amount) se añadió automáticamente';
  }

  @override
  String get expenseRecurring => 'Añadido por un gasto periódico';

  @override
  String get adminPlans => 'Planes';

  @override
  String get adminPayments => 'Pagos';

  @override
  String get adminSectionBilling => 'Planes y pagos';

  @override
  String get adminSectionBillingBody =>
      'Los planes amplían los límites de lo que guarda este servidor. Repartir gastos y saldar cuentas sigue siendo gratis.';

  @override
  String get adminBillingOn => 'Planes y límites';

  @override
  String get adminBillingOnHelp => 'Si está desactivado, este servidor no limita nada ni muestra planes.';

  @override
  String get adminBillingNeedsAccounts =>
      'Los planes necesitan cuentas: primero cambia el modo de acceso a cuentas.';

  @override
  String get adminKofiUrl => 'Página de Ko-fi';

  @override
  String get adminKofiUrlHelp =>
      'Donde se realiza el pago. Solo enlazan a ella las versiones que permiten pagos externos.';

  @override
  String adminKofiWebhook(String url) {
    return 'URL de webhook para Ko-fi: $url';
  }

  @override
  String get adminKofiToken => 'Token de verificación de Ko-fi';

  @override
  String get adminKofiTokenHelp =>
      'Aparece en la página de webhook de Ko-fi. Sin él, este servidor ignora Ko-fi.';

  @override
  String adminUserPlanUntil(String plan, String date) {
    return '$plan hasta $date';
  }

  @override
  String get adminPlansHelp =>
      'Un límite nuevo se aplica a lo que se añada después. Lo que ya existe se queda. Déjalo vacío para no poner límite.';

  @override
  String get adminPlanAdd => 'Añadir plan';

  @override
  String adminPlanDefaultName(String name) {
    return '$name (predeterminado)';
  }

  @override
  String adminPlanLimit(String label, String value) {
    return '$label: $value';
  }

  @override
  String adminPlanDays(int count) {
    return 'Días: $count';
  }

  @override
  String get adminProductsSection => 'Productos';

  @override
  String get adminProductsHelp =>
      'Un pago va al producto con su nombre de nivel o, si no, al que no tiene nombre de nivel y cuyo importe alcanza.';

  @override
  String get adminProductAdd => 'Añadir producto';

  @override
  String get adminProductEdit => 'Editar producto';

  @override
  String adminProductAnyPayment(String amount) {
    return 'Cualquier pago de al menos $amount';
  }

  @override
  String get adminProductName => 'Nombre del nivel';

  @override
  String get adminProductNameHelp =>
      'Tal como aparece en Ko-fi. Déjalo vacío para asociar por importe los pagos únicos o mensuales.';

  @override
  String get adminProductPlan => 'Plan';

  @override
  String get adminProductDays => 'Días';

  @override
  String get adminProductDaysHelp => 'Cuánto dura un pago. Volver a pagar se suma al tiempo restante.';

  @override
  String get adminProductMinAmount => 'Importe mínimo';

  @override
  String get adminProductCurrency => 'Código de moneda';

  @override
  String get adminPlanId => 'ID';

  @override
  String get adminPlanIdHelp => 'Minúsculas, dígitos y guiones. No se puede cambiar después.';

  @override
  String get adminPlanName => 'Nombre';

  @override
  String get adminPlanRank => 'Rango';

  @override
  String get adminPlanRankHelp => 'Una cuenta con varios planes obtiene el de mayor rango.';

  @override
  String get adminPlanDefault => 'Plan predeterminado';

  @override
  String get adminPlanDefaultHelp => 'Para todas las cuentas sin otro plan.';

  @override
  String get adminEntitlementGranted => 'Otorgado por un administrador';

  @override
  String get adminEntitlementRevoked => 'Revocado';

  @override
  String get adminEntitlementForever => 'Sin fecha de fin';

  @override
  String adminEntitlementUntil(String date) {
    return 'Hasta $date';
  }

  @override
  String adminEntitlementEnded(String date) {
    return 'Finalizó el $date';
  }

  @override
  String get adminEntitlementsEmpty => 'Esta cuenta aún no tiene planes.';

  @override
  String get adminEntitlementRevoke => 'Revocar';

  @override
  String get adminEntitlementNote => 'Nota';

  @override
  String get adminEntitlementGrant => 'Otorgar plan';

  @override
  String get adminPaymentApplied => 'Aplicado';

  @override
  String get adminPaymentUnclaimed => 'Sin reclamar';

  @override
  String get adminPaymentUnmatched => 'Sin asociar';

  @override
  String get adminPaymentsAll => 'Todos';

  @override
  String adminPaymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count pagos', one: '1 pago');
    return '$_temp0';
  }

  @override
  String get adminPaymentsEmpty => 'No hay pagos.';

  @override
  String get adminPaymentAssigned => 'Plan otorgado a la cuenta.';

  @override
  String get adminPaymentAssign => 'Otorgar a una cuenta';

  @override
  String get adminPaymentPickUser => 'Elige una cuenta.';

  @override
  String get errorBillingOff => 'Este servidor no tiene planes.';

  @override
  String get errorAlreadySponsored => 'El plan de otro miembro ya cubre este grupo.';

  @override
  String get errorPlanInUse => 'Aún hay cuentas o productos que usan este plan.';

  @override
  String get errorPaymentApplied => 'Este pago ya se ha aplicado.';

  @override
  String get errorPaymentNotFound =>
      'Aún no hay ningún pago con ese ID. Si acabas de pagar, inténtalo de nuevo en un minuto.';

  @override
  String get errorPaymentNoPlan =>
      'Este pago no corresponde a ningún plan. Pide a la administración del servidor que lo aplique.';

  @override
  String get errorInvalidPlan => 'Revisa los ajustes del plan: algo no es válido.';

  @override
  String errorLimitReceipts(int max) {
    return 'Este grupo ha alcanzado su límite de $max fotos de recibos.';
  }

  @override
  String errorLimitRecurring(int max) {
    return 'Este grupo ha alcanzado su límite de $max gastos periódicos.';
  }

  @override
  String errorLimitOwnGroups(int max) {
    return 'Has alcanzado tu límite de $max grupos.';
  }

  @override
  String errorLimitSponsored(int max) {
    return 'Tu plan no se puede compartir con más de $max grupos.';
  }

  @override
  String get errorLimitOther => 'Has alcanzado un límite de este servidor.';

  @override
  String get planTitle => 'Plan';

  @override
  String get planUnlimited => 'Sin límite';

  @override
  String planUntil(String date) {
    return 'Hasta $date';
  }

  @override
  String get planSettingsHelp => 'Lo que este servidor guarda para ti';

  @override
  String get planIntro =>
      'Repartir y saldar siempre es gratis. Un plan solo cambia cuánto guarda este servidor para ti.';

  @override
  String planUsage(int used, int limit) {
    return '$used de $limit';
  }

  @override
  String planUsed(int used) {
    return '$used en uso';
  }

  @override
  String get planLimits => 'Límites';

  @override
  String get planLimitReceipts => 'Fotos de recibos por grupo';

  @override
  String get planLimitRecurring => 'Gastos periódicos por grupo';

  @override
  String get planLimitOwnGroups => 'Grupos que has creado';

  @override
  String get planLimitSponsored => 'Grupos que comparten tu plan';

  @override
  String get planGet => 'Obtener un plan';

  @override
  String get planKofi => 'Ko-fi';

  @override
  String get planKofiHelp =>
      'Pega tu código de pago en el mensaje de Ko-fi para que el pago llegue a tu cuenta.';

  @override
  String get planPaymentCodeHelp => 'Tu código de pago. Toca para copiarlo.';

  @override
  String get planPaymentCodeCopied => 'Código de pago copiado';

  @override
  String get planPaymentClaim => '¿Olvidaste el código?';

  @override
  String get planPaymentClaimHelp => 'Añade un pago con su ID de transacción de Ko-fi.';

  @override
  String get planPaymentClaimField => 'ID de transacción o enlace del pago';

  @override
  String get planPaymentClaimAction => 'Añadir pago';

  @override
  String get planPaymentClaimed => 'Pago añadido';

  @override
  String groupPlanUsage(String receipts, String recurring) {
    return 'Fotos de recibos: $receipts · Periódicos: $recurring';
  }

  @override
  String get groupSponsor => 'Compartir mi plan con este grupo';

  @override
  String get groupUnsponsor => 'Dejar de compartir mi plan';

  @override
  String groupSponsoredBy(String name) {
    return 'Usa el plan de $name';
  }

  @override
  String get accountDeletePlayNote =>
      'Una suscripción de Google Play no termina con tu cuenta. Cancélala antes en Google Play.';

  @override
  String get planPlayManage => 'Gestionar suscripción';

  @override
  String get planPlayManageHelp => 'Cámbiala o cancélala en Google Play';

  @override
  String planPlayPrice(int months, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'cada $months meses',
      one: 'al mes',
    );
    return '$price $_temp0';
  }

  @override
  String get planPlayFailed => 'Google Play no pudo completar la compra.';

  @override
  String get planPlayPending => 'Tu pago aún se está procesando. El plan empezará cuando se complete.';

  @override
  String get errorInvalidPurchase => 'Google Play no reconoce esta compra.';

  @override
  String get errorPlayOtherAccount =>
      'Esta suscripción pertenece a otra cuenta. Inicia sesión en ella o cancélala en Google Play.';

  @override
  String get errorPlayUnavailable => 'No se pudo conectar con Google Play. Inténtalo de nuevo en un momento.';

  @override
  String get adminPlayPackage => 'Nombre del paquete de Google Play';

  @override
  String get adminPlayPackageHelp =>
      'El ID de la app en Google Play. Junto con la cuenta de servicio de abajo, activa las suscripciones de Google Play.';

  @override
  String get adminPlayServiceAccount => 'Cuenta de servicio de Google Play';

  @override
  String get adminPlayServiceAccountHelp =>
      'La clave JSON de una cuenta de servicio que pueda ver y gestionar pedidos y suscripciones en Play Console.';

  @override
  String get adminPlayPushAccount => 'Cuenta de envío de Pub/Sub';

  @override
  String get adminPlayPushAccountHelp =>
      'El correo de la cuenta de servicio con la que Pub/Sub firma sus envíos. Sin ella, las renovaciones solo llegan cuando alguien abre la página del plan.';

  @override
  String adminPlayWebhook(String url) {
    return 'Punto de envío de Pub/Sub, y también su audiencia: $url';
  }

  @override
  String get adminProductProvider => 'Pagado con';

  @override
  String get adminProductPlayId => 'ID del producto';

  @override
  String get adminProductPlayIdHelp =>
      'Tal como aparece en Play Console. Google Play indica cuándo termina cada pago, así que no hay días que configurar.';
}
