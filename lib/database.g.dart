// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PostsTable extends Posts with TableInfo<$PostsTable, StoredPost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profilePicUrlMeta = const VerificationMeta(
    'profilePicUrl',
  );
  @override
  late final GeneratedColumn<String> profilePicUrl = GeneratedColumn<String>(
    'profile_pic_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarFileMeta = const VerificationMeta(
    'avatarFile',
  );
  @override
  late final GeneratedColumn<String> avatarFile = GeneratedColumn<String>(
    'avatar_file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta(
    'likeCount',
  );
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentCountMeta = const VerificationMeta(
    'commentCount',
  );
  @override
  late final GeneratedColumn<int> commentCount = GeneratedColumn<int>(
    'comment_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<int> mediaType = GeneratedColumn<int>(
    'media_type',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productTypeMeta = const VerificationMeta(
    'productType',
  );
  @override
  late final GeneratedColumn<String> productType = GeneratedColumn<String>(
    'product_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accessibilityCaptionMeta =
      const VerificationMeta('accessibilityCaption');
  @override
  late final GeneratedColumn<String> accessibilityCaption =
      GeneratedColumn<String>(
        'accessibility_caption',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _aspectRatioMeta = const VerificationMeta(
    'aspectRatio',
  );
  @override
  late final GeneratedColumn<double> aspectRatio = GeneratedColumn<double>(
    'aspect_ratio',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inFavoritesMeta = const VerificationMeta(
    'inFavorites',
  );
  @override
  late final GeneratedColumn<bool> inFavorites = GeneratedColumn<bool>(
    'in_favorites',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("in_favorites" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _inFollowingMeta = const VerificationMeta(
    'inFollowing',
  );
  @override
  late final GeneratedColumn<bool> inFollowing = GeneratedColumn<bool>(
    'in_following',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("in_following" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    username,
    profilePicUrl,
    avatarFile,
    caption,
    takenAt,
    likeCount,
    commentCount,
    mediaType,
    productType,
    accessibilityCaption,
    aspectRatio,
    inFavorites,
    inFollowing,
    isRead,
    rawJson,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredPost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('profile_pic_url')) {
      context.handle(
        _profilePicUrlMeta,
        profilePicUrl.isAcceptableOrUnknown(
          data['profile_pic_url']!,
          _profilePicUrlMeta,
        ),
      );
    }
    if (data.containsKey('avatar_file')) {
      context.handle(
        _avatarFileMeta,
        avatarFile.isAcceptableOrUnknown(data['avatar_file']!, _avatarFileMeta),
      );
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    }
    if (data.containsKey('like_count')) {
      context.handle(
        _likeCountMeta,
        likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta),
      );
    }
    if (data.containsKey('comment_count')) {
      context.handle(
        _commentCountMeta,
        commentCount.isAcceptableOrUnknown(
          data['comment_count']!,
          _commentCountMeta,
        ),
      );
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    }
    if (data.containsKey('product_type')) {
      context.handle(
        _productTypeMeta,
        productType.isAcceptableOrUnknown(
          data['product_type']!,
          _productTypeMeta,
        ),
      );
    }
    if (data.containsKey('accessibility_caption')) {
      context.handle(
        _accessibilityCaptionMeta,
        accessibilityCaption.isAcceptableOrUnknown(
          data['accessibility_caption']!,
          _accessibilityCaptionMeta,
        ),
      );
    }
    if (data.containsKey('aspect_ratio')) {
      context.handle(
        _aspectRatioMeta,
        aspectRatio.isAcceptableOrUnknown(
          data['aspect_ratio']!,
          _aspectRatioMeta,
        ),
      );
    }
    if (data.containsKey('in_favorites')) {
      context.handle(
        _inFavoritesMeta,
        inFavorites.isAcceptableOrUnknown(
          data['in_favorites']!,
          _inFavoritesMeta,
        ),
      );
    }
    if (data.containsKey('in_following')) {
      context.handle(
        _inFollowingMeta,
        inFollowing.isAcceptableOrUnknown(
          data['in_following']!,
          _inFollowingMeta,
        ),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredPost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredPost(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      profilePicUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_pic_url'],
      ),
      avatarFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_file'],
      ),
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      ),
      likeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like_count'],
      ),
      commentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}comment_count'],
      ),
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_type'],
      ),
      productType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_type'],
      ),
      accessibilityCaption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accessibility_caption'],
      ),
      aspectRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aspect_ratio'],
      ),
      inFavorites: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}in_favorites'],
      )!,
      inFollowing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}in_following'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
    );
  }

  @override
  $PostsTable createAlias(String alias) {
    return $PostsTable(attachedDatabase, alias);
  }
}

class StoredPost extends DataClass implements Insertable<StoredPost> {
  final String id;
  final String? code;
  final String? username;
  final String? profilePicUrl;
  final String? avatarFile;
  final String? caption;
  final DateTime? takenAt;
  final int? likeCount;
  final int? commentCount;
  final int? mediaType;
  final String? productType;
  final String? accessibilityCaption;
  final double? aspectRatio;
  final bool inFavorites;
  final bool inFollowing;
  final bool isRead;
  final String rawJson;
  final DateTime capturedAt;
  const StoredPost({
    required this.id,
    this.code,
    this.username,
    this.profilePicUrl,
    this.avatarFile,
    this.caption,
    this.takenAt,
    this.likeCount,
    this.commentCount,
    this.mediaType,
    this.productType,
    this.accessibilityCaption,
    this.aspectRatio,
    required this.inFavorites,
    required this.inFollowing,
    required this.isRead,
    required this.rawJson,
    required this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || profilePicUrl != null) {
      map['profile_pic_url'] = Variable<String>(profilePicUrl);
    }
    if (!nullToAbsent || avatarFile != null) {
      map['avatar_file'] = Variable<String>(avatarFile);
    }
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    if (!nullToAbsent || takenAt != null) {
      map['taken_at'] = Variable<DateTime>(takenAt);
    }
    if (!nullToAbsent || likeCount != null) {
      map['like_count'] = Variable<int>(likeCount);
    }
    if (!nullToAbsent || commentCount != null) {
      map['comment_count'] = Variable<int>(commentCount);
    }
    if (!nullToAbsent || mediaType != null) {
      map['media_type'] = Variable<int>(mediaType);
    }
    if (!nullToAbsent || productType != null) {
      map['product_type'] = Variable<String>(productType);
    }
    if (!nullToAbsent || accessibilityCaption != null) {
      map['accessibility_caption'] = Variable<String>(accessibilityCaption);
    }
    if (!nullToAbsent || aspectRatio != null) {
      map['aspect_ratio'] = Variable<double>(aspectRatio);
    }
    map['in_favorites'] = Variable<bool>(inFavorites);
    map['in_following'] = Variable<bool>(inFollowing);
    map['is_read'] = Variable<bool>(isRead);
    map['raw_json'] = Variable<String>(rawJson);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      id: Value(id),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      profilePicUrl: profilePicUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePicUrl),
      avatarFile: avatarFile == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarFile),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      takenAt: takenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(takenAt),
      likeCount: likeCount == null && nullToAbsent
          ? const Value.absent()
          : Value(likeCount),
      commentCount: commentCount == null && nullToAbsent
          ? const Value.absent()
          : Value(commentCount),
      mediaType: mediaType == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaType),
      productType: productType == null && nullToAbsent
          ? const Value.absent()
          : Value(productType),
      accessibilityCaption: accessibilityCaption == null && nullToAbsent
          ? const Value.absent()
          : Value(accessibilityCaption),
      aspectRatio: aspectRatio == null && nullToAbsent
          ? const Value.absent()
          : Value(aspectRatio),
      inFavorites: Value(inFavorites),
      inFollowing: Value(inFollowing),
      isRead: Value(isRead),
      rawJson: Value(rawJson),
      capturedAt: Value(capturedAt),
    );
  }

  factory StoredPost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredPost(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String?>(json['code']),
      username: serializer.fromJson<String?>(json['username']),
      profilePicUrl: serializer.fromJson<String?>(json['profilePicUrl']),
      avatarFile: serializer.fromJson<String?>(json['avatarFile']),
      caption: serializer.fromJson<String?>(json['caption']),
      takenAt: serializer.fromJson<DateTime?>(json['takenAt']),
      likeCount: serializer.fromJson<int?>(json['likeCount']),
      commentCount: serializer.fromJson<int?>(json['commentCount']),
      mediaType: serializer.fromJson<int?>(json['mediaType']),
      productType: serializer.fromJson<String?>(json['productType']),
      accessibilityCaption: serializer.fromJson<String?>(
        json['accessibilityCaption'],
      ),
      aspectRatio: serializer.fromJson<double?>(json['aspectRatio']),
      inFavorites: serializer.fromJson<bool>(json['inFavorites']),
      inFollowing: serializer.fromJson<bool>(json['inFollowing']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String?>(code),
      'username': serializer.toJson<String?>(username),
      'profilePicUrl': serializer.toJson<String?>(profilePicUrl),
      'avatarFile': serializer.toJson<String?>(avatarFile),
      'caption': serializer.toJson<String?>(caption),
      'takenAt': serializer.toJson<DateTime?>(takenAt),
      'likeCount': serializer.toJson<int?>(likeCount),
      'commentCount': serializer.toJson<int?>(commentCount),
      'mediaType': serializer.toJson<int?>(mediaType),
      'productType': serializer.toJson<String?>(productType),
      'accessibilityCaption': serializer.toJson<String?>(accessibilityCaption),
      'aspectRatio': serializer.toJson<double?>(aspectRatio),
      'inFavorites': serializer.toJson<bool>(inFavorites),
      'inFollowing': serializer.toJson<bool>(inFollowing),
      'isRead': serializer.toJson<bool>(isRead),
      'rawJson': serializer.toJson<String>(rawJson),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
    };
  }

  StoredPost copyWith({
    String? id,
    Value<String?> code = const Value.absent(),
    Value<String?> username = const Value.absent(),
    Value<String?> profilePicUrl = const Value.absent(),
    Value<String?> avatarFile = const Value.absent(),
    Value<String?> caption = const Value.absent(),
    Value<DateTime?> takenAt = const Value.absent(),
    Value<int?> likeCount = const Value.absent(),
    Value<int?> commentCount = const Value.absent(),
    Value<int?> mediaType = const Value.absent(),
    Value<String?> productType = const Value.absent(),
    Value<String?> accessibilityCaption = const Value.absent(),
    Value<double?> aspectRatio = const Value.absent(),
    bool? inFavorites,
    bool? inFollowing,
    bool? isRead,
    String? rawJson,
    DateTime? capturedAt,
  }) => StoredPost(
    id: id ?? this.id,
    code: code.present ? code.value : this.code,
    username: username.present ? username.value : this.username,
    profilePicUrl: profilePicUrl.present
        ? profilePicUrl.value
        : this.profilePicUrl,
    avatarFile: avatarFile.present ? avatarFile.value : this.avatarFile,
    caption: caption.present ? caption.value : this.caption,
    takenAt: takenAt.present ? takenAt.value : this.takenAt,
    likeCount: likeCount.present ? likeCount.value : this.likeCount,
    commentCount: commentCount.present ? commentCount.value : this.commentCount,
    mediaType: mediaType.present ? mediaType.value : this.mediaType,
    productType: productType.present ? productType.value : this.productType,
    accessibilityCaption: accessibilityCaption.present
        ? accessibilityCaption.value
        : this.accessibilityCaption,
    aspectRatio: aspectRatio.present ? aspectRatio.value : this.aspectRatio,
    inFavorites: inFavorites ?? this.inFavorites,
    inFollowing: inFollowing ?? this.inFollowing,
    isRead: isRead ?? this.isRead,
    rawJson: rawJson ?? this.rawJson,
    capturedAt: capturedAt ?? this.capturedAt,
  );
  StoredPost copyWithCompanion(PostsCompanion data) {
    return StoredPost(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      username: data.username.present ? data.username.value : this.username,
      profilePicUrl: data.profilePicUrl.present
          ? data.profilePicUrl.value
          : this.profilePicUrl,
      avatarFile: data.avatarFile.present
          ? data.avatarFile.value
          : this.avatarFile,
      caption: data.caption.present ? data.caption.value : this.caption,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
      commentCount: data.commentCount.present
          ? data.commentCount.value
          : this.commentCount,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      productType: data.productType.present
          ? data.productType.value
          : this.productType,
      accessibilityCaption: data.accessibilityCaption.present
          ? data.accessibilityCaption.value
          : this.accessibilityCaption,
      aspectRatio: data.aspectRatio.present
          ? data.aspectRatio.value
          : this.aspectRatio,
      inFavorites: data.inFavorites.present
          ? data.inFavorites.value
          : this.inFavorites,
      inFollowing: data.inFollowing.present
          ? data.inFollowing.value
          : this.inFollowing,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredPost(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('username: $username, ')
          ..write('profilePicUrl: $profilePicUrl, ')
          ..write('avatarFile: $avatarFile, ')
          ..write('caption: $caption, ')
          ..write('takenAt: $takenAt, ')
          ..write('likeCount: $likeCount, ')
          ..write('commentCount: $commentCount, ')
          ..write('mediaType: $mediaType, ')
          ..write('productType: $productType, ')
          ..write('accessibilityCaption: $accessibilityCaption, ')
          ..write('aspectRatio: $aspectRatio, ')
          ..write('inFavorites: $inFavorites, ')
          ..write('inFollowing: $inFollowing, ')
          ..write('isRead: $isRead, ')
          ..write('rawJson: $rawJson, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    username,
    profilePicUrl,
    avatarFile,
    caption,
    takenAt,
    likeCount,
    commentCount,
    mediaType,
    productType,
    accessibilityCaption,
    aspectRatio,
    inFavorites,
    inFollowing,
    isRead,
    rawJson,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredPost &&
          other.id == this.id &&
          other.code == this.code &&
          other.username == this.username &&
          other.profilePicUrl == this.profilePicUrl &&
          other.avatarFile == this.avatarFile &&
          other.caption == this.caption &&
          other.takenAt == this.takenAt &&
          other.likeCount == this.likeCount &&
          other.commentCount == this.commentCount &&
          other.mediaType == this.mediaType &&
          other.productType == this.productType &&
          other.accessibilityCaption == this.accessibilityCaption &&
          other.aspectRatio == this.aspectRatio &&
          other.inFavorites == this.inFavorites &&
          other.inFollowing == this.inFollowing &&
          other.isRead == this.isRead &&
          other.rawJson == this.rawJson &&
          other.capturedAt == this.capturedAt);
}

class PostsCompanion extends UpdateCompanion<StoredPost> {
  final Value<String> id;
  final Value<String?> code;
  final Value<String?> username;
  final Value<String?> profilePicUrl;
  final Value<String?> avatarFile;
  final Value<String?> caption;
  final Value<DateTime?> takenAt;
  final Value<int?> likeCount;
  final Value<int?> commentCount;
  final Value<int?> mediaType;
  final Value<String?> productType;
  final Value<String?> accessibilityCaption;
  final Value<double?> aspectRatio;
  final Value<bool> inFavorites;
  final Value<bool> inFollowing;
  final Value<bool> isRead;
  final Value<String> rawJson;
  final Value<DateTime> capturedAt;
  final Value<int> rowid;
  const PostsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.username = const Value.absent(),
    this.profilePicUrl = const Value.absent(),
    this.avatarFile = const Value.absent(),
    this.caption = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.commentCount = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.productType = const Value.absent(),
    this.accessibilityCaption = const Value.absent(),
    this.aspectRatio = const Value.absent(),
    this.inFavorites = const Value.absent(),
    this.inFollowing = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostsCompanion.insert({
    required String id,
    this.code = const Value.absent(),
    this.username = const Value.absent(),
    this.profilePicUrl = const Value.absent(),
    this.avatarFile = const Value.absent(),
    this.caption = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.commentCount = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.productType = const Value.absent(),
    this.accessibilityCaption = const Value.absent(),
    this.aspectRatio = const Value.absent(),
    this.inFavorites = const Value.absent(),
    this.inFollowing = const Value.absent(),
    this.isRead = const Value.absent(),
    required String rawJson,
    required DateTime capturedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       rawJson = Value(rawJson),
       capturedAt = Value(capturedAt);
  static Insertable<StoredPost> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? username,
    Expression<String>? profilePicUrl,
    Expression<String>? avatarFile,
    Expression<String>? caption,
    Expression<DateTime>? takenAt,
    Expression<int>? likeCount,
    Expression<int>? commentCount,
    Expression<int>? mediaType,
    Expression<String>? productType,
    Expression<String>? accessibilityCaption,
    Expression<double>? aspectRatio,
    Expression<bool>? inFavorites,
    Expression<bool>? inFollowing,
    Expression<bool>? isRead,
    Expression<String>? rawJson,
    Expression<DateTime>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (username != null) 'username': username,
      if (profilePicUrl != null) 'profile_pic_url': profilePicUrl,
      if (avatarFile != null) 'avatar_file': avatarFile,
      if (caption != null) 'caption': caption,
      if (takenAt != null) 'taken_at': takenAt,
      if (likeCount != null) 'like_count': likeCount,
      if (commentCount != null) 'comment_count': commentCount,
      if (mediaType != null) 'media_type': mediaType,
      if (productType != null) 'product_type': productType,
      if (accessibilityCaption != null)
        'accessibility_caption': accessibilityCaption,
      if (aspectRatio != null) 'aspect_ratio': aspectRatio,
      if (inFavorites != null) 'in_favorites': inFavorites,
      if (inFollowing != null) 'in_following': inFollowing,
      if (isRead != null) 'is_read': isRead,
      if (rawJson != null) 'raw_json': rawJson,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostsCompanion copyWith({
    Value<String>? id,
    Value<String?>? code,
    Value<String?>? username,
    Value<String?>? profilePicUrl,
    Value<String?>? avatarFile,
    Value<String?>? caption,
    Value<DateTime?>? takenAt,
    Value<int?>? likeCount,
    Value<int?>? commentCount,
    Value<int?>? mediaType,
    Value<String?>? productType,
    Value<String?>? accessibilityCaption,
    Value<double?>? aspectRatio,
    Value<bool>? inFavorites,
    Value<bool>? inFollowing,
    Value<bool>? isRead,
    Value<String>? rawJson,
    Value<DateTime>? capturedAt,
    Value<int>? rowid,
  }) {
    return PostsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      username: username ?? this.username,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      avatarFile: avatarFile ?? this.avatarFile,
      caption: caption ?? this.caption,
      takenAt: takenAt ?? this.takenAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      mediaType: mediaType ?? this.mediaType,
      productType: productType ?? this.productType,
      accessibilityCaption: accessibilityCaption ?? this.accessibilityCaption,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      inFavorites: inFavorites ?? this.inFavorites,
      inFollowing: inFollowing ?? this.inFollowing,
      isRead: isRead ?? this.isRead,
      rawJson: rawJson ?? this.rawJson,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (profilePicUrl.present) {
      map['profile_pic_url'] = Variable<String>(profilePicUrl.value);
    }
    if (avatarFile.present) {
      map['avatar_file'] = Variable<String>(avatarFile.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (likeCount.present) {
      map['like_count'] = Variable<int>(likeCount.value);
    }
    if (commentCount.present) {
      map['comment_count'] = Variable<int>(commentCount.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<int>(mediaType.value);
    }
    if (productType.present) {
      map['product_type'] = Variable<String>(productType.value);
    }
    if (accessibilityCaption.present) {
      map['accessibility_caption'] = Variable<String>(
        accessibilityCaption.value,
      );
    }
    if (aspectRatio.present) {
      map['aspect_ratio'] = Variable<double>(aspectRatio.value);
    }
    if (inFavorites.present) {
      map['in_favorites'] = Variable<bool>(inFavorites.value);
    }
    if (inFollowing.present) {
      map['in_following'] = Variable<bool>(inFollowing.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('username: $username, ')
          ..write('profilePicUrl: $profilePicUrl, ')
          ..write('avatarFile: $avatarFile, ')
          ..write('caption: $caption, ')
          ..write('takenAt: $takenAt, ')
          ..write('likeCount: $likeCount, ')
          ..write('commentCount: $commentCount, ')
          ..write('mediaType: $mediaType, ')
          ..write('productType: $productType, ')
          ..write('accessibilityCaption: $accessibilityCaption, ')
          ..write('aspectRatio: $aspectRatio, ')
          ..write('inFavorites: $inFavorites, ')
          ..write('inFollowing: $inFollowing, ')
          ..write('isRead: $isRead, ')
          ..write('rawJson: $rawJson, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostMediaTable extends PostMedia
    with TableInfo<$PostMediaTable, StoredMedia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostMediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
    'post_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES posts (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<int> mediaType = GeneratedColumn<int>(
    'media_type',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _videoUrlMeta = const VerificationMeta(
    'videoUrl',
  );
  @override
  late final GeneratedColumn<String> videoUrl = GeneratedColumn<String>(
    'video_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageFileMeta = const VerificationMeta(
    'imageFile',
  );
  @override
  late final GeneratedColumn<String> imageFile = GeneratedColumn<String>(
    'image_file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _videoFileMeta = const VerificationMeta(
    'videoFile',
  );
  @override
  late final GeneratedColumn<String> videoFile = GeneratedColumn<String>(
    'video_file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    postId,
    position,
    mediaType,
    imageUrl,
    videoUrl,
    imageFile,
    videoFile,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'post_media';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredMedia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('post_id')) {
      context.handle(
        _postIdMeta,
        postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta),
      );
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('video_url')) {
      context.handle(
        _videoUrlMeta,
        videoUrl.isAcceptableOrUnknown(data['video_url']!, _videoUrlMeta),
      );
    }
    if (data.containsKey('image_file')) {
      context.handle(
        _imageFileMeta,
        imageFile.isAcceptableOrUnknown(data['image_file']!, _imageFileMeta),
      );
    }
    if (data.containsKey('video_file')) {
      context.handle(
        _videoFileMeta,
        videoFile.isAcceptableOrUnknown(data['video_file']!, _videoFileMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {postId, position};
  @override
  StoredMedia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredMedia(
      postId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_type'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      videoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_url'],
      ),
      imageFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_file'],
      ),
      videoFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_file'],
      ),
    );
  }

  @override
  $PostMediaTable createAlias(String alias) {
    return $PostMediaTable(attachedDatabase, alias);
  }
}

class StoredMedia extends DataClass implements Insertable<StoredMedia> {
  final String postId;
  final int position;
  final int? mediaType;
  final String? imageUrl;
  final String? videoUrl;
  final String? imageFile;
  final String? videoFile;
  const StoredMedia({
    required this.postId,
    required this.position,
    this.mediaType,
    this.imageUrl,
    this.videoUrl,
    this.imageFile,
    this.videoFile,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['post_id'] = Variable<String>(postId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || mediaType != null) {
      map['media_type'] = Variable<int>(mediaType);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || videoUrl != null) {
      map['video_url'] = Variable<String>(videoUrl);
    }
    if (!nullToAbsent || imageFile != null) {
      map['image_file'] = Variable<String>(imageFile);
    }
    if (!nullToAbsent || videoFile != null) {
      map['video_file'] = Variable<String>(videoFile);
    }
    return map;
  }

  PostMediaCompanion toCompanion(bool nullToAbsent) {
    return PostMediaCompanion(
      postId: Value(postId),
      position: Value(position),
      mediaType: mediaType == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaType),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      videoUrl: videoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(videoUrl),
      imageFile: imageFile == null && nullToAbsent
          ? const Value.absent()
          : Value(imageFile),
      videoFile: videoFile == null && nullToAbsent
          ? const Value.absent()
          : Value(videoFile),
    );
  }

  factory StoredMedia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredMedia(
      postId: serializer.fromJson<String>(json['postId']),
      position: serializer.fromJson<int>(json['position']),
      mediaType: serializer.fromJson<int?>(json['mediaType']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      videoUrl: serializer.fromJson<String?>(json['videoUrl']),
      imageFile: serializer.fromJson<String?>(json['imageFile']),
      videoFile: serializer.fromJson<String?>(json['videoFile']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'postId': serializer.toJson<String>(postId),
      'position': serializer.toJson<int>(position),
      'mediaType': serializer.toJson<int?>(mediaType),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'videoUrl': serializer.toJson<String?>(videoUrl),
      'imageFile': serializer.toJson<String?>(imageFile),
      'videoFile': serializer.toJson<String?>(videoFile),
    };
  }

  StoredMedia copyWith({
    String? postId,
    int? position,
    Value<int?> mediaType = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> videoUrl = const Value.absent(),
    Value<String?> imageFile = const Value.absent(),
    Value<String?> videoFile = const Value.absent(),
  }) => StoredMedia(
    postId: postId ?? this.postId,
    position: position ?? this.position,
    mediaType: mediaType.present ? mediaType.value : this.mediaType,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
    imageFile: imageFile.present ? imageFile.value : this.imageFile,
    videoFile: videoFile.present ? videoFile.value : this.videoFile,
  );
  StoredMedia copyWithCompanion(PostMediaCompanion data) {
    return StoredMedia(
      postId: data.postId.present ? data.postId.value : this.postId,
      position: data.position.present ? data.position.value : this.position,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      imageFile: data.imageFile.present ? data.imageFile.value : this.imageFile,
      videoFile: data.videoFile.present ? data.videoFile.value : this.videoFile,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredMedia(')
          ..write('postId: $postId, ')
          ..write('position: $position, ')
          ..write('mediaType: $mediaType, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('imageFile: $imageFile, ')
          ..write('videoFile: $videoFile')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    postId,
    position,
    mediaType,
    imageUrl,
    videoUrl,
    imageFile,
    videoFile,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredMedia &&
          other.postId == this.postId &&
          other.position == this.position &&
          other.mediaType == this.mediaType &&
          other.imageUrl == this.imageUrl &&
          other.videoUrl == this.videoUrl &&
          other.imageFile == this.imageFile &&
          other.videoFile == this.videoFile);
}

class PostMediaCompanion extends UpdateCompanion<StoredMedia> {
  final Value<String> postId;
  final Value<int> position;
  final Value<int?> mediaType;
  final Value<String?> imageUrl;
  final Value<String?> videoUrl;
  final Value<String?> imageFile;
  final Value<String?> videoFile;
  final Value<int> rowid;
  const PostMediaCompanion({
    this.postId = const Value.absent(),
    this.position = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.imageFile = const Value.absent(),
    this.videoFile = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostMediaCompanion.insert({
    required String postId,
    required int position,
    this.mediaType = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.imageFile = const Value.absent(),
    this.videoFile = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : postId = Value(postId),
       position = Value(position);
  static Insertable<StoredMedia> custom({
    Expression<String>? postId,
    Expression<int>? position,
    Expression<int>? mediaType,
    Expression<String>? imageUrl,
    Expression<String>? videoUrl,
    Expression<String>? imageFile,
    Expression<String>? videoFile,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (postId != null) 'post_id': postId,
      if (position != null) 'position': position,
      if (mediaType != null) 'media_type': mediaType,
      if (imageUrl != null) 'image_url': imageUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (imageFile != null) 'image_file': imageFile,
      if (videoFile != null) 'video_file': videoFile,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostMediaCompanion copyWith({
    Value<String>? postId,
    Value<int>? position,
    Value<int?>? mediaType,
    Value<String?>? imageUrl,
    Value<String?>? videoUrl,
    Value<String?>? imageFile,
    Value<String?>? videoFile,
    Value<int>? rowid,
  }) {
    return PostMediaCompanion(
      postId: postId ?? this.postId,
      position: position ?? this.position,
      mediaType: mediaType ?? this.mediaType,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      imageFile: imageFile ?? this.imageFile,
      videoFile: videoFile ?? this.videoFile,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<int>(mediaType.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (videoUrl.present) {
      map['video_url'] = Variable<String>(videoUrl.value);
    }
    if (imageFile.present) {
      map['image_file'] = Variable<String>(imageFile.value);
    }
    if (videoFile.present) {
      map['video_file'] = Variable<String>(videoFile.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostMediaCompanion(')
          ..write('postId: $postId, ')
          ..write('position: $position, ')
          ..write('mediaType: $mediaType, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('imageFile: $imageFile, ')
          ..write('videoFile: $videoFile, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoriesTable extends Stories with TableInfo<$StoriesTable, StoredStory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarFileMeta = const VerificationMeta(
    'avatarFile',
  );
  @override
  late final GeneratedColumn<String> avatarFile = GeneratedColumn<String>(
    'avatar_file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasUnseenMeta = const VerificationMeta(
    'hasUnseen',
  );
  @override
  late final GeneratedColumn<bool> hasUnseen = GeneratedColumn<bool>(
    'has_unseen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_unseen" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    avatarUrl,
    avatarFile,
    hasUnseen,
    position,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stories';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredStory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('avatar_file')) {
      context.handle(
        _avatarFileMeta,
        avatarFile.isAcceptableOrUnknown(data['avatar_file']!, _avatarFileMeta),
      );
    }
    if (data.containsKey('has_unseen')) {
      context.handle(
        _hasUnseenMeta,
        hasUnseen.isAcceptableOrUnknown(data['has_unseen']!, _hasUnseenMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredStory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredStory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      avatarFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_file'],
      ),
      hasUnseen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_unseen'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StoriesTable createAlias(String alias) {
    return $StoriesTable(attachedDatabase, alias);
  }
}

class StoredStory extends DataClass implements Insertable<StoredStory> {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? avatarFile;
  final bool hasUnseen;
  final int position;
  final DateTime updatedAt;
  const StoredStory({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.avatarFile,
    required this.hasUnseen,
    required this.position,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || avatarFile != null) {
      map['avatar_file'] = Variable<String>(avatarFile);
    }
    map['has_unseen'] = Variable<bool>(hasUnseen);
    map['position'] = Variable<int>(position);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StoriesCompanion toCompanion(bool nullToAbsent) {
    return StoriesCompanion(
      id: Value(id),
      username: Value(username),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      avatarFile: avatarFile == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarFile),
      hasUnseen: Value(hasUnseen),
      position: Value(position),
      updatedAt: Value(updatedAt),
    );
  }

  factory StoredStory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredStory(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      avatarFile: serializer.fromJson<String?>(json['avatarFile']),
      hasUnseen: serializer.fromJson<bool>(json['hasUnseen']),
      position: serializer.fromJson<int>(json['position']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'avatarFile': serializer.toJson<String?>(avatarFile),
      'hasUnseen': serializer.toJson<bool>(hasUnseen),
      'position': serializer.toJson<int>(position),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StoredStory copyWith({
    String? id,
    String? username,
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> avatarFile = const Value.absent(),
    bool? hasUnseen,
    int? position,
    DateTime? updatedAt,
  }) => StoredStory(
    id: id ?? this.id,
    username: username ?? this.username,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    avatarFile: avatarFile.present ? avatarFile.value : this.avatarFile,
    hasUnseen: hasUnseen ?? this.hasUnseen,
    position: position ?? this.position,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StoredStory copyWithCompanion(StoriesCompanion data) {
    return StoredStory(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      avatarFile: data.avatarFile.present
          ? data.avatarFile.value
          : this.avatarFile,
      hasUnseen: data.hasUnseen.present ? data.hasUnseen.value : this.hasUnseen,
      position: data.position.present ? data.position.value : this.position,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredStory(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('avatarFile: $avatarFile, ')
          ..write('hasUnseen: $hasUnseen, ')
          ..write('position: $position, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    avatarUrl,
    avatarFile,
    hasUnseen,
    position,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredStory &&
          other.id == this.id &&
          other.username == this.username &&
          other.avatarUrl == this.avatarUrl &&
          other.avatarFile == this.avatarFile &&
          other.hasUnseen == this.hasUnseen &&
          other.position == this.position &&
          other.updatedAt == this.updatedAt);
}

class StoriesCompanion extends UpdateCompanion<StoredStory> {
  final Value<String> id;
  final Value<String> username;
  final Value<String?> avatarUrl;
  final Value<String?> avatarFile;
  final Value<bool> hasUnseen;
  final Value<int> position;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StoriesCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.avatarFile = const Value.absent(),
    this.hasUnseen = const Value.absent(),
    this.position = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoriesCompanion.insert({
    required String id,
    required String username,
    this.avatarUrl = const Value.absent(),
    this.avatarFile = const Value.absent(),
    this.hasUnseen = const Value.absent(),
    required int position,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       username = Value(username),
       position = Value(position);
  static Insertable<StoredStory> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? avatarUrl,
    Expression<String>? avatarFile,
    Expression<bool>? hasUnseen,
    Expression<int>? position,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (avatarFile != null) 'avatar_file': avatarFile,
      if (hasUnseen != null) 'has_unseen': hasUnseen,
      if (position != null) 'position': position,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? username,
    Value<String?>? avatarUrl,
    Value<String?>? avatarFile,
    Value<bool>? hasUnseen,
    Value<int>? position,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StoriesCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarFile: avatarFile ?? this.avatarFile,
      hasUnseen: hasUnseen ?? this.hasUnseen,
      position: position ?? this.position,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (avatarFile.present) {
      map['avatar_file'] = Variable<String>(avatarFile.value);
    }
    if (hasUnseen.present) {
      map['has_unseen'] = Variable<bool>(hasUnseen.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoriesCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('avatarFile: $avatarFile, ')
          ..write('hasUnseen: $hasUnseen, ')
          ..write('position: $position, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PostsTable posts = $PostsTable(this);
  late final $PostMediaTable postMedia = $PostMediaTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $StoriesTable stories = $StoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    posts,
    postMedia,
    appSettings,
    stories,
  ];
}

typedef $$PostsTableCreateCompanionBuilder = PostsCompanion Function({
  required String id,
  Value<String?> code,
  Value<String?> username,
  Value<String?> profilePicUrl,
  Value<String?> avatarFile,
  Value<String?> caption,
  Value<DateTime?> takenAt,
  Value<int?> likeCount,
  Value<int?> commentCount,
  Value<int?> mediaType,
  Value<String?> productType,
  Value<String?> accessibilityCaption,
  Value<double?> aspectRatio,
  Value<bool> inFavorites,
  Value<bool> inFollowing,
  Value<bool> isRead,
  required String rawJson,
  required DateTime capturedAt,
  Value<int> rowid,
});
typedef $$PostsTableUpdateCompanionBuilder = PostsCompanion Function({
  Value<String> id,
  Value<String?> code,
  Value<String?> username,
  Value<String?> profilePicUrl,
  Value<String?> avatarFile,
  Value<String?> caption,
  Value<DateTime?> takenAt,
  Value<int?> likeCount,
  Value<int?> commentCount,
  Value<int?> mediaType,
  Value<String?> productType,
  Value<String?> accessibilityCaption,
  Value<double?> aspectRatio,
  Value<bool> inFavorites,
  Value<bool> inFollowing,
  Value<bool> isRead,
  Value<String> rawJson,
  Value<DateTime> capturedAt,
  Value<int> rowid,
});

final class $$PostsTableReferences
    extends BaseReferences<_$AppDatabase, $PostsTable, StoredPost> {
  $$PostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PostMediaTable, List<StoredMedia>>
  _postMediaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.postMedia,
    aliasName: 'posts__id__post_media__post_id',
  );

  $$PostMediaTableProcessedTableManager get postMediaRefs {
    final manager = $$PostMediaTableTableManager(
      $_db,
      $_db.postMedia,
    ).filter((f) => f.postId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_postMediaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PostsTableFilterComposer extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profilePicUrl => $composableBuilder(
    column: $table.profilePicUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarFile => $composableBuilder(
    column: $table.avatarFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessibilityCaption => $composableBuilder(
    column: $table.accessibilityCaption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aspectRatio => $composableBuilder(
    column: $table.aspectRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inFavorites => $composableBuilder(
    column: $table.inFavorites,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inFollowing => $composableBuilder(
    column: $table.inFollowing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> postMediaRefs(
    Expression<bool> Function($$PostMediaTableFilterComposer f) f,
  ) {
    final $$PostMediaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.postMedia,
      getReferencedColumn: (t) => t.postId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostMediaTableFilterComposer(
            $db: $db,
            $table: $db.postMedia,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PostsTableOrderingComposer
    extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profilePicUrl => $composableBuilder(
    column: $table.profilePicUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarFile => $composableBuilder(
    column: $table.avatarFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessibilityCaption => $composableBuilder(
    column: $table.accessibilityCaption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aspectRatio => $composableBuilder(
    column: $table.aspectRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inFavorites => $composableBuilder(
    column: $table.inFavorites,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inFollowing => $composableBuilder(
    column: $table.inFollowing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get profilePicUrl => $composableBuilder(
    column: $table.profilePicUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarFile => $composableBuilder(
    column: $table.avatarFile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

  GeneratedColumn<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accessibilityCaption => $composableBuilder(
    column: $table.accessibilityCaption,
    builder: (column) => column,
  );

  GeneratedColumn<double> get aspectRatio => $composableBuilder(
    column: $table.aspectRatio,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get inFavorites => $composableBuilder(
    column: $table.inFavorites,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get inFollowing => $composableBuilder(
    column: $table.inFollowing,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  Expression<T> postMediaRefs<T extends Object>(
    Expression<T> Function($$PostMediaTableAnnotationComposer a) f,
  ) {
    final $$PostMediaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.postMedia,
      getReferencedColumn: (t) => t.postId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostMediaTableAnnotationComposer(
            $db: $db,
            $table: $db.postMedia,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PostsTable,
          StoredPost,
          $$PostsTableFilterComposer,
          $$PostsTableOrderingComposer,
          $$PostsTableAnnotationComposer,
          $$PostsTableCreateCompanionBuilder,
          $$PostsTableUpdateCompanionBuilder,
          (StoredPost, $$PostsTableReferences),
          StoredPost,
          PrefetchHooks Function({bool postMediaRefs})
        > {
  $$PostsTableTableManager(_$AppDatabase db, $PostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> profilePicUrl = const Value.absent(),
                Value<String?> avatarFile = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<DateTime?> takenAt = const Value.absent(),
                Value<int?> likeCount = const Value.absent(),
                Value<int?> commentCount = const Value.absent(),
                Value<int?> mediaType = const Value.absent(),
                Value<String?> productType = const Value.absent(),
                Value<String?> accessibilityCaption = const Value.absent(),
                Value<double?> aspectRatio = const Value.absent(),
                Value<bool> inFavorites = const Value.absent(),
                Value<bool> inFollowing = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion(
                id: id,
                code: code,
                username: username,
                profilePicUrl: profilePicUrl,
                avatarFile: avatarFile,
                caption: caption,
                takenAt: takenAt,
                likeCount: likeCount,
                commentCount: commentCount,
                mediaType: mediaType,
                productType: productType,
                accessibilityCaption: accessibilityCaption,
                aspectRatio: aspectRatio,
                inFavorites: inFavorites,
                inFollowing: inFollowing,
                isRead: isRead,
                rawJson: rawJson,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> code = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> profilePicUrl = const Value.absent(),
                Value<String?> avatarFile = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<DateTime?> takenAt = const Value.absent(),
                Value<int?> likeCount = const Value.absent(),
                Value<int?> commentCount = const Value.absent(),
                Value<int?> mediaType = const Value.absent(),
                Value<String?> productType = const Value.absent(),
                Value<String?> accessibilityCaption = const Value.absent(),
                Value<double?> aspectRatio = const Value.absent(),
                Value<bool> inFavorites = const Value.absent(),
                Value<bool> inFollowing = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                required String rawJson,
                required DateTime capturedAt,
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion.insert(
                id: id,
                code: code,
                username: username,
                profilePicUrl: profilePicUrl,
                avatarFile: avatarFile,
                caption: caption,
                takenAt: takenAt,
                likeCount: likeCount,
                commentCount: commentCount,
                mediaType: mediaType,
                productType: productType,
                accessibilityCaption: accessibilityCaption,
                aspectRatio: aspectRatio,
                inFavorites: inFavorites,
                inFollowing: inFollowing,
                isRead: isRead,
                rawJson: rawJson,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PostsTable, StoredPost>(table),
                  $$PostsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({postMediaRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (postMediaRefs) db.postMedia],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (postMediaRefs)
                    await $_getPrefetchedDataByColumns<
                      StoredPost,
                      $PostsTable,
                      StoredMedia,
                      $PostMediaTable
                    >(
                      currentTable: table,
                      referencedTable: $$PostsTableReferences
                          ._postMediaRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PostsTableReferences(db, table, p0).postMediaRefs,
                      currentColumn: 'id',
                      referencedColumn: 'post_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PostsTable,
      StoredPost,
      $$PostsTableFilterComposer,
      $$PostsTableOrderingComposer,
      $$PostsTableAnnotationComposer,
      $$PostsTableCreateCompanionBuilder,
      $$PostsTableUpdateCompanionBuilder,
      (StoredPost, $$PostsTableReferences),
      StoredPost,
      PrefetchHooks Function({bool postMediaRefs})
    >;
typedef $$PostMediaTableCreateCompanionBuilder = PostMediaCompanion Function({
  required String postId,
  required int position,
  Value<int?> mediaType,
  Value<String?> imageUrl,
  Value<String?> videoUrl,
  Value<String?> imageFile,
  Value<String?> videoFile,
  Value<int> rowid,
});
typedef $$PostMediaTableUpdateCompanionBuilder = PostMediaCompanion Function({
  Value<String> postId,
  Value<int> position,
  Value<int?> mediaType,
  Value<String?> imageUrl,
  Value<String?> videoUrl,
  Value<String?> imageFile,
  Value<String?> videoFile,
  Value<int> rowid,
});

final class $$PostMediaTableReferences
    extends BaseReferences<_$AppDatabase, $PostMediaTable, StoredMedia> {
  $$PostMediaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PostsTable _postIdTable(_$AppDatabase db) =>
      db.posts.createAlias('post_media__post_id__posts__id');

  $$PostsTableProcessedTableManager get postId {
    final $_column = $_itemColumn<String>('post_id')!;

    final manager = $$PostsTableTableManager(
      $_db,
      $_db.posts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_postIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PostMediaTableFilterComposer
    extends Composer<_$AppDatabase, $PostMediaTable> {
  $$PostMediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageFile => $composableBuilder(
    column: $table.imageFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoFile => $composableBuilder(
    column: $table.videoFile,
    builder: (column) => ColumnFilters(column),
  );

  $$PostsTableFilterComposer get postId {
    final $$PostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postId,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableFilterComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostMediaTableOrderingComposer
    extends Composer<_$AppDatabase, $PostMediaTable> {
  $$PostMediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageFile => $composableBuilder(
    column: $table.imageFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoFile => $composableBuilder(
    column: $table.videoFile,
    builder: (column) => ColumnOrderings(column),
  );

  $$PostsTableOrderingComposer get postId {
    final $$PostsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postId,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableOrderingComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostMediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostMediaTable> {
  $$PostMediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get videoUrl =>
      $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<String> get imageFile =>
      $composableBuilder(column: $table.imageFile, builder: (column) => column);

  GeneratedColumn<String> get videoFile =>
      $composableBuilder(column: $table.videoFile, builder: (column) => column);

  $$PostsTableAnnotationComposer get postId {
    final $$PostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postId,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableAnnotationComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostMediaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PostMediaTable,
          StoredMedia,
          $$PostMediaTableFilterComposer,
          $$PostMediaTableOrderingComposer,
          $$PostMediaTableAnnotationComposer,
          $$PostMediaTableCreateCompanionBuilder,
          $$PostMediaTableUpdateCompanionBuilder,
          (StoredMedia, $$PostMediaTableReferences),
          StoredMedia,
          PrefetchHooks Function({bool postId})
        > {
  $$PostMediaTableTableManager(_$AppDatabase db, $PostMediaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostMediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostMediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostMediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> postId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> mediaType = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                Value<String?> imageFile = const Value.absent(),
                Value<String?> videoFile = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostMediaCompanion(
                postId: postId,
                position: position,
                mediaType: mediaType,
                imageUrl: imageUrl,
                videoUrl: videoUrl,
                imageFile: imageFile,
                videoFile: videoFile,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String postId,
                required int position,
                Value<int?> mediaType = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                Value<String?> imageFile = const Value.absent(),
                Value<String?> videoFile = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostMediaCompanion.insert(
                postId: postId,
                position: position,
                mediaType: mediaType,
                imageUrl: imageUrl,
                videoUrl: videoUrl,
                imageFile: imageFile,
                videoFile: videoFile,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PostMediaTable, StoredMedia>(table),
                  $$PostMediaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({postId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (postId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.postId,
                        referencedTable: $$PostMediaTableReferences
                            ._postIdTable(db),
                        referencedColumn: $$PostMediaTableReferences
                            ._postIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PostMediaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PostMediaTable,
      StoredMedia,
      $$PostMediaTableFilterComposer,
      $$PostMediaTableOrderingComposer,
      $$PostMediaTableAnnotationComposer,
      $$PostMediaTableCreateCompanionBuilder,
      $$PostMediaTableUpdateCompanionBuilder,
      (StoredMedia, $$PostMediaTableReferences),
      StoredMedia,
      PrefetchHooks Function({bool postId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
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

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$StoriesTableCreateCompanionBuilder = StoriesCompanion Function({
  required String id,
  required String username,
  Value<String?> avatarUrl,
  Value<String?> avatarFile,
  Value<bool> hasUnseen,
  required int position,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$StoriesTableUpdateCompanionBuilder = StoriesCompanion Function({
  Value<String> id,
  Value<String> username,
  Value<String?> avatarUrl,
  Value<String?> avatarFile,
  Value<bool> hasUnseen,
  Value<int> position,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$StoriesTableFilterComposer
    extends Composer<_$AppDatabase, $StoriesTable> {
  $$StoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarFile => $composableBuilder(
    column: $table.avatarFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasUnseen => $composableBuilder(
    column: $table.hasUnseen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $StoriesTable> {
  $$StoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarFile => $composableBuilder(
    column: $table.avatarFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasUnseen => $composableBuilder(
    column: $table.hasUnseen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoriesTable> {
  $$StoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get avatarFile => $composableBuilder(
    column: $table.avatarFile,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasUnseen =>
      $composableBuilder(column: $table.hasUnseen, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoriesTable,
          StoredStory,
          $$StoriesTableFilterComposer,
          $$StoriesTableOrderingComposer,
          $$StoriesTableAnnotationComposer,
          $$StoriesTableCreateCompanionBuilder,
          $$StoriesTableUpdateCompanionBuilder,
          (
            StoredStory,
            BaseReferences<_$AppDatabase, $StoriesTable, StoredStory>,
          ),
          StoredStory,
          PrefetchHooks Function()
        > {
  $$StoriesTableTableManager(_$AppDatabase db, $StoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> avatarFile = const Value.absent(),
                Value<bool> hasUnseen = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoriesCompanion(
                id: id,
                username: username,
                avatarUrl: avatarUrl,
                avatarFile: avatarFile,
                hasUnseen: hasUnseen,
                position: position,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String username,
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> avatarFile = const Value.absent(),
                Value<bool> hasUnseen = const Value.absent(),
                required int position,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoriesCompanion.insert(
                id: id,
                username: username,
                avatarUrl: avatarUrl,
                avatarFile: avatarFile,
                hasUnseen: hasUnseen,
                position: position,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StoriesTable, StoredStory>(table),
                  BaseReferences<_$AppDatabase, $StoriesTable, StoredStory>(
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

typedef $$StoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoriesTable,
      StoredStory,
      $$StoriesTableFilterComposer,
      $$StoriesTableOrderingComposer,
      $$StoriesTableAnnotationComposer,
      $$StoriesTableCreateCompanionBuilder,
      $$StoriesTableUpdateCompanionBuilder,
      (StoredStory, BaseReferences<_$AppDatabase, $StoriesTable, StoredStory>),
      StoredStory,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db, _db.posts);
  $$PostMediaTableTableManager get postMedia =>
      $$PostMediaTableTableManager(_db, _db.postMedia);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$StoriesTableTableManager get stories =>
      $$StoriesTableTableManager(_db, _db.stories);
}
