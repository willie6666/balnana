// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_cache.dart';

// ignore_for_file: type=lint
class $CachedResponsesTable extends CachedResponses
    with TableInfo<$CachedResponsesTable, CachedResponse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedResponsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverMeta = const VerificationMeta('server');
  @override
  late final GeneratedColumn<String> server = GeneratedColumn<String>(
    'server',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountMeta = const VerificationMeta(
    'account',
  );
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
    'account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestMeta = const VerificationMeta(
    'request',
  );
  @override
  late final GeneratedColumn<String> request = GeneratedColumn<String>(
    'request',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    server,
    account,
    request,
    body,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_responses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedResponse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server')) {
      context.handle(
        _serverMeta,
        server.isAcceptableOrUnknown(data['server']!, _serverMeta),
      );
    } else if (isInserting) {
      context.missing(_serverMeta);
    }
    if (data.containsKey('account')) {
      context.handle(
        _accountMeta,
        account.isAcceptableOrUnknown(data['account']!, _accountMeta),
      );
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('request')) {
      context.handle(
        _requestMeta,
        request.isAcceptableOrUnknown(data['request']!, _requestMeta),
      );
    } else if (isInserting) {
      context.missing(_requestMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {server, account, request};
  @override
  CachedResponse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedResponse(
      server: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server'],
      )!,
      account: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account'],
      )!,
      request: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $CachedResponsesTable createAlias(String alias) {
    return $CachedResponsesTable(attachedDatabase, alias);
  }
}

class CachedResponse extends DataClass implements Insertable<CachedResponse> {
  final String server;

  /// Whose answer it is: see [cacheAccount] and [CacheDb.public].
  final String account;

  /// The method, path and query, plus the body for the few cached POSTs.
  final String request;
  final String body;
  final DateTime savedAt;
  const CachedResponse({
    required this.server,
    required this.account,
    required this.request,
    required this.body,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server'] = Variable<String>(server);
    map['account'] = Variable<String>(account);
    map['request'] = Variable<String>(request);
    map['body'] = Variable<String>(body);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  CachedResponsesCompanion toCompanion(bool nullToAbsent) {
    return CachedResponsesCompanion(
      server: Value(server),
      account: Value(account),
      request: Value(request),
      body: Value(body),
      savedAt: Value(savedAt),
    );
  }

  factory CachedResponse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedResponse(
      server: serializer.fromJson<String>(json['server']),
      account: serializer.fromJson<String>(json['account']),
      request: serializer.fromJson<String>(json['request']),
      body: serializer.fromJson<String>(json['body']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'server': serializer.toJson<String>(server),
      'account': serializer.toJson<String>(account),
      'request': serializer.toJson<String>(request),
      'body': serializer.toJson<String>(body),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  CachedResponse copyWith({
    String? server,
    String? account,
    String? request,
    String? body,
    DateTime? savedAt,
  }) => CachedResponse(
    server: server ?? this.server,
    account: account ?? this.account,
    request: request ?? this.request,
    body: body ?? this.body,
    savedAt: savedAt ?? this.savedAt,
  );
  CachedResponse copyWithCompanion(CachedResponsesCompanion data) {
    return CachedResponse(
      server: data.server.present ? data.server.value : this.server,
      account: data.account.present ? data.account.value : this.account,
      request: data.request.present ? data.request.value : this.request,
      body: data.body.present ? data.body.value : this.body,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedResponse(')
          ..write('server: $server, ')
          ..write('account: $account, ')
          ..write('request: $request, ')
          ..write('body: $body, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(server, account, request, body, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedResponse &&
          other.server == this.server &&
          other.account == this.account &&
          other.request == this.request &&
          other.body == this.body &&
          other.savedAt == this.savedAt);
}

class CachedResponsesCompanion extends UpdateCompanion<CachedResponse> {
  final Value<String> server;
  final Value<String> account;
  final Value<String> request;
  final Value<String> body;
  final Value<DateTime> savedAt;
  final Value<int> rowid;
  const CachedResponsesCompanion({
    this.server = const Value.absent(),
    this.account = const Value.absent(),
    this.request = const Value.absent(),
    this.body = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedResponsesCompanion.insert({
    required String server,
    required String account,
    required String request,
    required String body,
    required DateTime savedAt,
    this.rowid = const Value.absent(),
  }) : server = Value(server),
       account = Value(account),
       request = Value(request),
       body = Value(body),
       savedAt = Value(savedAt);
  static Insertable<CachedResponse> custom({
    Expression<String>? server,
    Expression<String>? account,
    Expression<String>? request,
    Expression<String>? body,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (server != null) 'server': server,
      if (account != null) 'account': account,
      if (request != null) 'request': request,
      if (body != null) 'body': body,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedResponsesCompanion copyWith({
    Value<String>? server,
    Value<String>? account,
    Value<String>? request,
    Value<String>? body,
    Value<DateTime>? savedAt,
    Value<int>? rowid,
  }) {
    return CachedResponsesCompanion(
      server: server ?? this.server,
      account: account ?? this.account,
      request: request ?? this.request,
      body: body ?? this.body,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (server.present) {
      map['server'] = Variable<String>(server.value);
    }
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (request.present) {
      map['request'] = Variable<String>(request.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedResponsesCompanion(')
          ..write('server: $server, ')
          ..write('account: $account, ')
          ..write('request: $request, ')
          ..write('body: $body, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingWritesTable extends PendingWrites
    with TableInfo<$PendingWritesTable, PendingWrite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingWritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverMeta = const VerificationMeta('server');
  @override
  late final GeneratedColumn<String> server = GeneratedColumn<String>(
    'server',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountMeta = const VerificationMeta(
    'account',
  );
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
    'account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupTokenMeta = const VerificationMeta(
    'groupToken',
  );
  @override
  late final GeneratedColumn<String> groupToken = GeneratedColumn<String>(
    'group_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberMeta = const VerificationMeta('member');
  @override
  late final GeneratedColumn<String> member = GeneratedColumn<String>(
    'member',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    server,
    account,
    groupToken,
    member,
    path,
    body,
    key,
    createdAt,
    error,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_writes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingWrite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server')) {
      context.handle(
        _serverMeta,
        server.isAcceptableOrUnknown(data['server']!, _serverMeta),
      );
    } else if (isInserting) {
      context.missing(_serverMeta);
    }
    if (data.containsKey('account')) {
      context.handle(
        _accountMeta,
        account.isAcceptableOrUnknown(data['account']!, _accountMeta),
      );
    } else if (isInserting) {
      context.missing(_accountMeta);
    }
    if (data.containsKey('group_token')) {
      context.handle(
        _groupTokenMeta,
        groupToken.isAcceptableOrUnknown(data['group_token']!, _groupTokenMeta),
      );
    } else if (isInserting) {
      context.missing(_groupTokenMeta);
    }
    if (data.containsKey('member')) {
      context.handle(
        _memberMeta,
        member.isAcceptableOrUnknown(data['member']!, _memberMeta),
      );
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingWrite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingWrite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      server: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server'],
      )!,
      account: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account'],
      )!,
      groupToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_token'],
      )!,
      member: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member'],
      ),
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
    );
  }

  @override
  $PendingWritesTable createAlias(String alias) {
    return $PendingWritesTable(attachedDatabase, alias);
  }
}

class PendingWrite extends DataClass implements Insertable<PendingWrite> {
  final int id;
  final String server;

  /// Whose it is, as in [CachedResponses.account].
  final String account;
  final String groupToken;

  /// The member it is sent as.
  final String? member;

  /// Where in the group it goes: [PendingPath].
  final String path;

  /// The JSON sent.
  final String body;

  /// The Idempotency-Key it is sent with, so sending it twice adds it once.
  final String key;
  final DateTime createdAt;

  /// The error code the server refused it with. It waits for the person
  /// to try again or let it go.
  final String? error;
  const PendingWrite({
    required this.id,
    required this.server,
    required this.account,
    required this.groupToken,
    this.member,
    required this.path,
    required this.body,
    required this.key,
    required this.createdAt,
    this.error,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server'] = Variable<String>(server);
    map['account'] = Variable<String>(account);
    map['group_token'] = Variable<String>(groupToken);
    if (!nullToAbsent || member != null) {
      map['member'] = Variable<String>(member);
    }
    map['path'] = Variable<String>(path);
    map['body'] = Variable<String>(body);
    map['key'] = Variable<String>(key);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  PendingWritesCompanion toCompanion(bool nullToAbsent) {
    return PendingWritesCompanion(
      id: Value(id),
      server: Value(server),
      account: Value(account),
      groupToken: Value(groupToken),
      member: member == null && nullToAbsent
          ? const Value.absent()
          : Value(member),
      path: Value(path),
      body: Value(body),
      key: Value(key),
      createdAt: Value(createdAt),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
    );
  }

  factory PendingWrite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingWrite(
      id: serializer.fromJson<int>(json['id']),
      server: serializer.fromJson<String>(json['server']),
      account: serializer.fromJson<String>(json['account']),
      groupToken: serializer.fromJson<String>(json['groupToken']),
      member: serializer.fromJson<String?>(json['member']),
      path: serializer.fromJson<String>(json['path']),
      body: serializer.fromJson<String>(json['body']),
      key: serializer.fromJson<String>(json['key']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'server': serializer.toJson<String>(server),
      'account': serializer.toJson<String>(account),
      'groupToken': serializer.toJson<String>(groupToken),
      'member': serializer.toJson<String?>(member),
      'path': serializer.toJson<String>(path),
      'body': serializer.toJson<String>(body),
      'key': serializer.toJson<String>(key),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'error': serializer.toJson<String?>(error),
    };
  }

  PendingWrite copyWith({
    int? id,
    String? server,
    String? account,
    String? groupToken,
    Value<String?> member = const Value.absent(),
    String? path,
    String? body,
    String? key,
    DateTime? createdAt,
    Value<String?> error = const Value.absent(),
  }) => PendingWrite(
    id: id ?? this.id,
    server: server ?? this.server,
    account: account ?? this.account,
    groupToken: groupToken ?? this.groupToken,
    member: member.present ? member.value : this.member,
    path: path ?? this.path,
    body: body ?? this.body,
    key: key ?? this.key,
    createdAt: createdAt ?? this.createdAt,
    error: error.present ? error.value : this.error,
  );
  PendingWrite copyWithCompanion(PendingWritesCompanion data) {
    return PendingWrite(
      id: data.id.present ? data.id.value : this.id,
      server: data.server.present ? data.server.value : this.server,
      account: data.account.present ? data.account.value : this.account,
      groupToken: data.groupToken.present
          ? data.groupToken.value
          : this.groupToken,
      member: data.member.present ? data.member.value : this.member,
      path: data.path.present ? data.path.value : this.path,
      body: data.body.present ? data.body.value : this.body,
      key: data.key.present ? data.key.value : this.key,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingWrite(')
          ..write('id: $id, ')
          ..write('server: $server, ')
          ..write('account: $account, ')
          ..write('groupToken: $groupToken, ')
          ..write('member: $member, ')
          ..write('path: $path, ')
          ..write('body: $body, ')
          ..write('key: $key, ')
          ..write('createdAt: $createdAt, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    server,
    account,
    groupToken,
    member,
    path,
    body,
    key,
    createdAt,
    error,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingWrite &&
          other.id == this.id &&
          other.server == this.server &&
          other.account == this.account &&
          other.groupToken == this.groupToken &&
          other.member == this.member &&
          other.path == this.path &&
          other.body == this.body &&
          other.key == this.key &&
          other.createdAt == this.createdAt &&
          other.error == this.error);
}

class PendingWritesCompanion extends UpdateCompanion<PendingWrite> {
  final Value<int> id;
  final Value<String> server;
  final Value<String> account;
  final Value<String> groupToken;
  final Value<String?> member;
  final Value<String> path;
  final Value<String> body;
  final Value<String> key;
  final Value<DateTime> createdAt;
  final Value<String?> error;
  const PendingWritesCompanion({
    this.id = const Value.absent(),
    this.server = const Value.absent(),
    this.account = const Value.absent(),
    this.groupToken = const Value.absent(),
    this.member = const Value.absent(),
    this.path = const Value.absent(),
    this.body = const Value.absent(),
    this.key = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.error = const Value.absent(),
  });
  PendingWritesCompanion.insert({
    this.id = const Value.absent(),
    required String server,
    required String account,
    required String groupToken,
    this.member = const Value.absent(),
    required String path,
    required String body,
    required String key,
    required DateTime createdAt,
    this.error = const Value.absent(),
  }) : server = Value(server),
       account = Value(account),
       groupToken = Value(groupToken),
       path = Value(path),
       body = Value(body),
       key = Value(key),
       createdAt = Value(createdAt);
  static Insertable<PendingWrite> custom({
    Expression<int>? id,
    Expression<String>? server,
    Expression<String>? account,
    Expression<String>? groupToken,
    Expression<String>? member,
    Expression<String>? path,
    Expression<String>? body,
    Expression<String>? key,
    Expression<DateTime>? createdAt,
    Expression<String>? error,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (server != null) 'server': server,
      if (account != null) 'account': account,
      if (groupToken != null) 'group_token': groupToken,
      if (member != null) 'member': member,
      if (path != null) 'path': path,
      if (body != null) 'body': body,
      if (key != null) 'key': key,
      if (createdAt != null) 'created_at': createdAt,
      if (error != null) 'error': error,
    });
  }

  PendingWritesCompanion copyWith({
    Value<int>? id,
    Value<String>? server,
    Value<String>? account,
    Value<String>? groupToken,
    Value<String?>? member,
    Value<String>? path,
    Value<String>? body,
    Value<String>? key,
    Value<DateTime>? createdAt,
    Value<String?>? error,
  }) {
    return PendingWritesCompanion(
      id: id ?? this.id,
      server: server ?? this.server,
      account: account ?? this.account,
      groupToken: groupToken ?? this.groupToken,
      member: member ?? this.member,
      path: path ?? this.path,
      body: body ?? this.body,
      key: key ?? this.key,
      createdAt: createdAt ?? this.createdAt,
      error: error ?? this.error,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (server.present) {
      map['server'] = Variable<String>(server.value);
    }
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (groupToken.present) {
      map['group_token'] = Variable<String>(groupToken.value);
    }
    if (member.present) {
      map['member'] = Variable<String>(member.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingWritesCompanion(')
          ..write('id: $id, ')
          ..write('server: $server, ')
          ..write('account: $account, ')
          ..write('groupToken: $groupToken, ')
          ..write('member: $member, ')
          ..write('path: $path, ')
          ..write('body: $body, ')
          ..write('key: $key, ')
          ..write('createdAt: $createdAt, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }
}

abstract class _$CacheDb extends GeneratedDatabase {
  _$CacheDb(QueryExecutor e) : super(e);
  $CacheDbManager get managers => $CacheDbManager(this);
  late final $CachedResponsesTable cachedResponses = $CachedResponsesTable(
    this,
  );
  late final $PendingWritesTable pendingWrites = $PendingWritesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedResponses,
    pendingWrites,
  ];
}

typedef $$CachedResponsesTableCreateCompanionBuilder =
    CachedResponsesCompanion Function({
      required String server,
      required String account,
      required String request,
      required String body,
      required DateTime savedAt,
      Value<int> rowid,
    });
typedef $$CachedResponsesTableUpdateCompanionBuilder =
    CachedResponsesCompanion Function({
      Value<String> server,
      Value<String> account,
      Value<String> request,
      Value<String> body,
      Value<DateTime> savedAt,
      Value<int> rowid,
    });

class $$CachedResponsesTableFilterComposer
    extends Composer<_$CacheDb, $CachedResponsesTable> {
  $$CachedResponsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get server => $composableBuilder(
    column: $table.server,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get request => $composableBuilder(
    column: $table.request,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedResponsesTableOrderingComposer
    extends Composer<_$CacheDb, $CachedResponsesTable> {
  $$CachedResponsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get server => $composableBuilder(
    column: $table.server,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get request => $composableBuilder(
    column: $table.request,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedResponsesTableAnnotationComposer
    extends Composer<_$CacheDb, $CachedResponsesTable> {
  $$CachedResponsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get server =>
      $composableBuilder(column: $table.server, builder: (column) => column);

  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<String> get request =>
      $composableBuilder(column: $table.request, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$CachedResponsesTableTableManager
    extends
        RootTableManager<
          _$CacheDb,
          $CachedResponsesTable,
          CachedResponse,
          $$CachedResponsesTableFilterComposer,
          $$CachedResponsesTableOrderingComposer,
          $$CachedResponsesTableAnnotationComposer,
          $$CachedResponsesTableCreateCompanionBuilder,
          $$CachedResponsesTableUpdateCompanionBuilder,
          (
            CachedResponse,
            BaseReferences<_$CacheDb, $CachedResponsesTable, CachedResponse>,
          ),
          CachedResponse,
          PrefetchHooks Function()
        > {
  $$CachedResponsesTableTableManager(_$CacheDb db, $CachedResponsesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedResponsesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedResponsesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedResponsesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> server = const Value.absent(),
                Value<String> account = const Value.absent(),
                Value<String> request = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedResponsesCompanion(
                server: server,
                account: account,
                request: request,
                body: body,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String server,
                required String account,
                required String request,
                required String body,
                required DateTime savedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedResponsesCompanion.insert(
                server: server,
                account: account,
                request: request,
                body: body,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedResponsesTable, CachedResponse>(table),
                  BaseReferences<
                    _$CacheDb,
                    $CachedResponsesTable,
                    CachedResponse
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedResponsesTableProcessedTableManager =
    ProcessedTableManager<
      _$CacheDb,
      $CachedResponsesTable,
      CachedResponse,
      $$CachedResponsesTableFilterComposer,
      $$CachedResponsesTableOrderingComposer,
      $$CachedResponsesTableAnnotationComposer,
      $$CachedResponsesTableCreateCompanionBuilder,
      $$CachedResponsesTableUpdateCompanionBuilder,
      (
        CachedResponse,
        BaseReferences<_$CacheDb, $CachedResponsesTable, CachedResponse>,
      ),
      CachedResponse,
      PrefetchHooks Function()
    >;
typedef $$PendingWritesTableCreateCompanionBuilder =
    PendingWritesCompanion Function({
      Value<int> id,
      required String server,
      required String account,
      required String groupToken,
      Value<String?> member,
      required String path,
      required String body,
      required String key,
      required DateTime createdAt,
      Value<String?> error,
    });
typedef $$PendingWritesTableUpdateCompanionBuilder =
    PendingWritesCompanion Function({
      Value<int> id,
      Value<String> server,
      Value<String> account,
      Value<String> groupToken,
      Value<String?> member,
      Value<String> path,
      Value<String> body,
      Value<String> key,
      Value<DateTime> createdAt,
      Value<String?> error,
    });

class $$PendingWritesTableFilterComposer
    extends Composer<_$CacheDb, $PendingWritesTable> {
  $$PendingWritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get server => $composableBuilder(
    column: $table.server,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupToken => $composableBuilder(
    column: $table.groupToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get member => $composableBuilder(
    column: $table.member,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingWritesTableOrderingComposer
    extends Composer<_$CacheDb, $PendingWritesTable> {
  $$PendingWritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get server => $composableBuilder(
    column: $table.server,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupToken => $composableBuilder(
    column: $table.groupToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get member => $composableBuilder(
    column: $table.member,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingWritesTableAnnotationComposer
    extends Composer<_$CacheDb, $PendingWritesTable> {
  $$PendingWritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get server =>
      $composableBuilder(column: $table.server, builder: (column) => column);

  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<String> get groupToken => $composableBuilder(
    column: $table.groupToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get member =>
      $composableBuilder(column: $table.member, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$PendingWritesTableTableManager
    extends
        RootTableManager<
          _$CacheDb,
          $PendingWritesTable,
          PendingWrite,
          $$PendingWritesTableFilterComposer,
          $$PendingWritesTableOrderingComposer,
          $$PendingWritesTableAnnotationComposer,
          $$PendingWritesTableCreateCompanionBuilder,
          $$PendingWritesTableUpdateCompanionBuilder,
          (
            PendingWrite,
            BaseReferences<_$CacheDb, $PendingWritesTable, PendingWrite>,
          ),
          PendingWrite,
          PrefetchHooks Function()
        > {
  $$PendingWritesTableTableManager(_$CacheDb db, $PendingWritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingWritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingWritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingWritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> server = const Value.absent(),
                Value<String> account = const Value.absent(),
                Value<String> groupToken = const Value.absent(),
                Value<String?> member = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => PendingWritesCompanion(
                id: id,
                server: server,
                account: account,
                groupToken: groupToken,
                member: member,
                path: path,
                body: body,
                key: key,
                createdAt: createdAt,
                error: error,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String server,
                required String account,
                required String groupToken,
                Value<String?> member = const Value.absent(),
                required String path,
                required String body,
                required String key,
                required DateTime createdAt,
                Value<String?> error = const Value.absent(),
              }) => PendingWritesCompanion.insert(
                id: id,
                server: server,
                account: account,
                groupToken: groupToken,
                member: member,
                path: path,
                body: body,
                key: key,
                createdAt: createdAt,
                error: error,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PendingWritesTable, PendingWrite>(table),
                  BaseReferences<_$CacheDb, $PendingWritesTable, PendingWrite>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingWritesTableProcessedTableManager =
    ProcessedTableManager<
      _$CacheDb,
      $PendingWritesTable,
      PendingWrite,
      $$PendingWritesTableFilterComposer,
      $$PendingWritesTableOrderingComposer,
      $$PendingWritesTableAnnotationComposer,
      $$PendingWritesTableCreateCompanionBuilder,
      $$PendingWritesTableUpdateCompanionBuilder,
      (
        PendingWrite,
        BaseReferences<_$CacheDb, $PendingWritesTable, PendingWrite>,
      ),
      PendingWrite,
      PrefetchHooks Function()
    >;

class $CacheDbManager {
  final _$CacheDb _db;
  $CacheDbManager(this._db);
  $$CachedResponsesTableTableManager get cachedResponses =>
      $$CachedResponsesTableTableManager(_db, _db.cachedResponses);
  $$PendingWritesTableTableManager get pendingWrites =>
      $$PendingWritesTableTableManager(_db, _db.pendingWrites);
}
