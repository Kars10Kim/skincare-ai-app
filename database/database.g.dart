// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ScannedProductsTable extends ScannedProducts
    with TableInfo<$ScannedProductsTable, ScannedProductsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScannedProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _skinTypeMeta =
      const VerificationMeta('skinType');
  @override
  late final GeneratedColumn<String> skinType = GeneratedColumn<String>(
      'skin_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ingredientJsonMeta =
      const VerificationMeta('ingredientJson');
  @override
  late final GeneratedColumn<String> ingredientJson = GeneratedColumn<String>(
      'ingredient_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localModifiedMeta =
      const VerificationMeta('localModified');
  @override
  late final GeneratedColumn<DateTime> localModified =
      GeneratedColumn<DateTime>('local_modified', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _serverModifiedMeta =
      const VerificationMeta('serverModified');
  @override
  late final GeneratedColumn<DateTime> serverModified =
      GeneratedColumn<DateTime>('server_modified', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _conflictFlagMeta =
      const VerificationMeta('conflictFlag');
  @override
  late final GeneratedColumn<String> conflictFlag = GeneratedColumn<String>(
      'conflict_flag', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        barcode,
        name,
        brand,
        description,
        imageUrl,
        category,
        skinType,
        ingredientJson,
        localModified,
        serverModified,
        conflictFlag
      ];
  @override
  Set<GeneratedColumn> get $primaryKey => {id, barcode};
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scanned_products';
  @override
  VerificationContext validateIntegrity(Insertable<ScannedProductsData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('skin_type')) {
      context.handle(_skinTypeMeta,
          skinType.isAcceptableOrUnknown(data['skin_type']!, _skinTypeMeta));
    }
    if (data.containsKey('ingredient_json')) {
      context.handle(
          _ingredientJsonMeta,
          ingredientJson.isAcceptableOrUnknown(
              data['ingredient_json']!, _ingredientJsonMeta));
    } else if (isInserting) {
      context.missing(_ingredientJsonMeta);
    }
    if (data.containsKey('local_modified')) {
      context.handle(
          _localModifiedMeta,
          localModified.isAcceptableOrUnknown(
              data['local_modified']!, _localModifiedMeta));
    }
    if (data.containsKey('server_modified')) {
      context.handle(
          _serverModifiedMeta,
          serverModified.isAcceptableOrUnknown(
              data['server_modified']!, _serverModifiedMeta));
    }
    if (data.containsKey('conflict_flag')) {
      context.handle(
          _conflictFlagMeta,
          conflictFlag.isAcceptableOrUnknown(
              data['conflict_flag']!, _conflictFlagMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScannedProductsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScannedProductsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      skinType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}skin_type']),
      ingredientJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ingredient_json'])!,
      localModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_modified'])!,
      serverModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_modified']),
      conflictFlag: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conflict_flag'])!,
    );
  }

  @override
  $ScannedProductsTable createAlias(String alias) {
    return $ScannedProductsTable(attachedDatabase, alias);
  }
}

class ScannedProductsData extends DataClass
    implements Insertable<ScannedProductsData> {
  final int id;
  final String barcode;
  final String name;
  final String? brand;
  final String? description;
  final String? imageUrl;
  final String? category;
  final String? skinType;
  final String ingredientJson;
  final DateTime localModified;
  final DateTime? serverModified;
  final String conflictFlag;
  const ScannedProductsData(
      {required this.id,
      required this.barcode,
      required this.name,
      this.brand,
      this.description,
      this.imageUrl,
      this.category,
      this.skinType,
      required this.ingredientJson,
      required this.localModified,
      this.serverModified,
      required this.conflictFlag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['barcode'] = Variable<String>(barcode);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || skinType != null) {
      map['skin_type'] = Variable<String>(skinType);
    }
    map['ingredient_json'] = Variable<String>(ingredientJson);
    map['local_modified'] = Variable<DateTime>(localModified);
    if (!nullToAbsent || serverModified != null) {
      map['server_modified'] = Variable<DateTime>(serverModified);
    }
    map['conflict_flag'] = Variable<String>(conflictFlag);
    return map;
  }

  ScannedProductsCompanion toCompanion(bool nullToAbsent) {
    return ScannedProductsCompanion(
      id: Value(id),
      barcode: Value(barcode),
      name: Value(name),
      brand:
          brand == null && nullToAbsent ? const Value.absent() : Value(brand),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      skinType: skinType == null && nullToAbsent
          ? const Value.absent()
          : Value(skinType),
      ingredientJson: Value(ingredientJson),
      localModified: Value(localModified),
      serverModified: serverModified == null && nullToAbsent
          ? const Value.absent()
          : Value(serverModified),
      conflictFlag: Value(conflictFlag),
    );
  }

  factory ScannedProductsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScannedProductsData(
      id: serializer.fromJson<int>(json['id']),
      barcode: serializer.fromJson<String>(json['barcode']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      description: serializer.fromJson<String?>(json['description']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      category: serializer.fromJson<String?>(json['category']),
      skinType: serializer.fromJson<String?>(json['skinType']),
      ingredientJson: serializer.fromJson<String>(json['ingredientJson']),
      localModified: serializer.fromJson<DateTime>(json['localModified']),
      serverModified: serializer.fromJson<DateTime?>(json['serverModified']),
      conflictFlag: serializer.fromJson<String>(json['conflictFlag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barcode': serializer.toJson<String>(barcode),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'description': serializer.toJson<String?>(description),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'category': serializer.toJson<String?>(category),
      'skinType': serializer.toJson<String?>(skinType),
      'ingredientJson': serializer.toJson<String>(ingredientJson),
      'localModified': serializer.toJson<DateTime>(localModified),
      'serverModified': serializer.toJson<DateTime?>(serverModified),
      'conflictFlag': serializer.toJson<String>(conflictFlag),
    };
  }

  ScannedProductsData copyWith(
          {int? id,
          String? barcode,
          String? name,
          Value<String?> brand = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<String?> skinType = const Value.absent(),
          String? ingredientJson,
          DateTime? localModified,
          Value<DateTime?> serverModified = const Value.absent(),
          String? conflictFlag}) =>
      ScannedProductsData(
        id: id ?? this.id,
        barcode: barcode ?? this.barcode,
        name: name ?? this.name,
        brand: brand.present ? brand.value : this.brand,
        description: description.present ? description.value : this.description,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        category: category.present ? category.value : this.category,
        skinType: skinType.present ? skinType.value : this.skinType,
        ingredientJson: ingredientJson ?? this.ingredientJson,
        localModified: localModified ?? this.localModified,
        serverModified:
            serverModified.present ? serverModified.value : this.serverModified,
        conflictFlag: conflictFlag ?? this.conflictFlag,
      );
  @override
  String toString() {
    return (StringBuffer('ScannedProductsData(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('category: $category, ')
          ..write('skinType: $skinType, ')
          ..write('ingredientJson: $ingredientJson, ')
          ..write('localModified: $localModified, ')
          ..write('serverModified: $serverModified, ')
          ..write('conflictFlag: $conflictFlag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      barcode,
      name,
      brand,
      description,
      imageUrl,
      category,
      skinType,
      ingredientJson,
      localModified,
      serverModified,
      conflictFlag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannedProductsData &&
          other.id == this.id &&
          other.barcode == this.barcode &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.category == this.category &&
          other.skinType == this.skinType &&
          other.ingredientJson == this.ingredientJson &&
          other.localModified == this.localModified &&
          other.serverModified == this.serverModified &&
          other.conflictFlag == this.conflictFlag);
}

class ScannedProductsCompanion extends UpdateCompanion<ScannedProductsData> {
  final Value<int> id;
  final Value<String> barcode;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> description;
  final Value<String?> imageUrl;
  final Value<String?> category;
  final Value<String?> skinType;
  final Value<String> ingredientJson;
  final Value<DateTime> localModified;
  final Value<DateTime?> serverModified;
  final Value<String> conflictFlag;
  const ScannedProductsCompanion({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.category = const Value.absent(),
    this.skinType = const Value.absent(),
    this.ingredientJson = const Value.absent(),
    this.localModified = const Value.absent(),
    this.serverModified = const Value.absent(),
    this.conflictFlag = const Value.absent(),
  });
  ScannedProductsCompanion.insert({
    this.id = const Value.absent(),
    required String barcode,
    required String name,
    this.brand = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.category = const Value.absent(),
    this.skinType = const Value.absent(),
    required String ingredientJson,
    this.localModified = const Value.absent(),
    this.serverModified = const Value.absent(),
    this.conflictFlag = const Value.absent(),
  })  : barcode = Value(barcode),
        name = Value(name),
        ingredientJson = Value(ingredientJson);
  static Insertable<ScannedProductsData> custom({
    Expression<int>? id,
    Expression<String>? barcode,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<String>? category,
    Expression<String>? skinType,
    Expression<String>? ingredientJson,
    Expression<DateTime>? localModified,
    Expression<DateTime>? serverModified,
    Expression<String>? conflictFlag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barcode != null) 'barcode': barcode,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (category != null) 'category': category,
      if (skinType != null) 'skin_type': skinType,
      if (ingredientJson != null) 'ingredient_json': ingredientJson,
      if (localModified != null) 'local_modified': localModified,
      if (serverModified != null) 'server_modified': serverModified,
      if (conflictFlag != null) 'conflict_flag': conflictFlag,
    });
  }

  ScannedProductsCompanion copyWith(
      {Value<int>? id,
      Value<String>? barcode,
      Value<String>? name,
      Value<String?>? brand,
      Value<String?>? description,
      Value<String?>? imageUrl,
      Value<String?>? category,
      Value<String?>? skinType,
      Value<String>? ingredientJson,
      Value<DateTime>? localModified,
      Value<DateTime?>? serverModified,
      Value<String>? conflictFlag}) {
    return ScannedProductsCompanion(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      skinType: skinType ?? this.skinType,
      ingredientJson: ingredientJson ?? this.ingredientJson,
      localModified: localModified ?? this.localModified,
      serverModified: serverModified ?? this.serverModified,
      conflictFlag: conflictFlag ?? this.conflictFlag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (skinType.present) {
      map['skin_type'] = Variable<String>(skinType.value);
    }
    if (ingredientJson.present) {
      map['ingredient_json'] = Variable<String>(ingredientJson.value);
    }
    if (localModified.present) {
      map['local_modified'] = Variable<DateTime>(localModified.value);
    }
    if (serverModified.present) {
      map['server_modified'] = Variable<DateTime>(serverModified.value);
    }
    if (conflictFlag.present) {
      map['conflict_flag'] = Variable<String>(conflictFlag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScannedProductsCompanion(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('category: $category, ')
          ..write('skinType: $skinType, ')
          ..write('ingredientJson: $ingredientJson, ')
          ..write('localModified: $localModified, ')
          ..write('serverModified: $serverModified, ')
          ..write('conflictFlag: $conflictFlag')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, IngredientsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _propertiesJsonMeta =
      const VerificationMeta('propertiesJson');
  @override
  late final GeneratedColumn<String> propertiesJson = GeneratedColumn<String>(
      'properties_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localModifiedMeta =
      const VerificationMeta('localModified');
  @override
  late final GeneratedColumn<DateTime> localModified =
      GeneratedColumn<DateTime>('local_modified', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _serverModifiedMeta =
      const VerificationMeta('serverModified');
  @override
  late final GeneratedColumn<DateTime> serverModified =
      GeneratedColumn<DateTime>('server_modified', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _conflictFlagMeta =
      const VerificationMeta('conflictFlag');
  @override
  late final GeneratedColumn<String> conflictFlag = GeneratedColumn<String>(
      'conflict_flag', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        propertiesJson,
        localModified,
        serverModified,
        conflictFlag
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(Insertable<IngredientsData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('properties_json')) {
      context.handle(
          _propertiesJsonMeta,
          propertiesJson.isAcceptableOrUnknown(
              data['properties_json']!, _propertiesJsonMeta));
    }
    if (data.containsKey('local_modified')) {
      context.handle(
          _localModifiedMeta,
          localModified.isAcceptableOrUnknown(
              data['local_modified']!, _localModifiedMeta));
    }
    if (data.containsKey('server_modified')) {
      context.handle(
          _serverModifiedMeta,
          serverModified.isAcceptableOrUnknown(
              data['server_modified']!, _serverModifiedMeta));
    }
    if (data.containsKey('conflict_flag')) {
      context.handle(
          _conflictFlagMeta,
          conflictFlag.isAcceptableOrUnknown(
              data['conflict_flag']!, _conflictFlagMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      propertiesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}properties_json']),
      localModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_modified'])!,
      serverModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_modified']),
      conflictFlag: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conflict_flag'])!,
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class IngredientsData extends DataClass implements Insertable<IngredientsData> {
  final int id;
  final String name;
  final String category;
  final String? propertiesJson;
  final DateTime localModified;
  final DateTime? serverModified;
  final String conflictFlag;
  const IngredientsData(
      {required this.id,
      required this.name,
      required this.category,
      this.propertiesJson,
      required this.localModified,
      this.serverModified,
      required this.conflictFlag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || propertiesJson != null) {
      map['properties_json'] = Variable<String>(propertiesJson);
    }
    map['local_modified'] = Variable<DateTime>(localModified);
    if (!nullToAbsent || serverModified != null) {
      map['server_modified'] = Variable<DateTime>(serverModified);
    }
    map['conflict_flag'] = Variable<String>(conflictFlag);
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      propertiesJson: propertiesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(propertiesJson),
      localModified: Value(localModified),
      serverModified: serverModified == null && nullToAbsent
          ? const Value.absent()
          : Value(serverModified),
      conflictFlag: Value(conflictFlag),
    );
  }

  factory IngredientsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientsData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      propertiesJson: serializer.fromJson<String?>(json['propertiesJson']),
      localModified: serializer.fromJson<DateTime>(json['localModified']),
      serverModified: serializer.fromJson<DateTime?>(json['serverModified']),
      conflictFlag: serializer.fromJson<String>(json['conflictFlag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'propertiesJson': serializer.toJson<String?>(propertiesJson),
      'localModified': serializer.toJson<DateTime>(localModified),
      'serverModified': serializer.toJson<DateTime?>(serverModified),
      'conflictFlag': serializer.toJson<String>(conflictFlag),
    };
  }

  IngredientsData copyWith(
          {int? id,
          String? name,
          String? category,
          Value<String?> propertiesJson = const Value.absent(),
          DateTime? localModified,
          Value<DateTime?> serverModified = const Value.absent(),
          String? conflictFlag}) =>
      IngredientsData(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        propertiesJson: propertiesJson.present
            ? propertiesJson.value
            : this.propertiesJson,
        localModified: localModified ?? this.localModified,
        serverModified:
            serverModified.present ? serverModified.value : this.serverModified,
        conflictFlag: conflictFlag ?? this.conflictFlag,
      );
  @override
  String toString() {
    return (StringBuffer('IngredientsData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('propertiesJson: $propertiesJson, ')
          ..write('localModified: $localModified, ')
          ..write('serverModified: $serverModified, ')
          ..write('conflictFlag: $conflictFlag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, category, propertiesJson,
      localModified, serverModified, conflictFlag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientsData &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.propertiesJson == this.propertiesJson &&
          other.localModified == this.localModified &&
          other.serverModified == this.serverModified &&
          other.conflictFlag == this.conflictFlag);
}

// Abbreviated for brevity - additional table implementations would follow
// This file would continue with implementations for all other tables

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $ScannedProductsTable scannedProducts = $ScannedProductsTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  // Other tables would be initialized here
  
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        scannedProducts,
        ingredients,
        // Additional tables would be listed here
      ];
}