// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsuariosTable extends Usuarios
    with TableInfo<$UsuariosTable, UsuarioLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsuariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _correoMeta = const VerificationMeta('correo');
  @override
  late final GeneratedColumn<String> correo = GeneratedColumn<String>(
      'correo', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _contrasenaMeta =
      const VerificationMeta('contrasena');
  @override
  late final GeneratedColumn<String> contrasena = GeneratedColumn<String>(
      'contrasena', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rolMeta = const VerificationMeta('rol');
  @override
  late final GeneratedColumn<String> rol = GeneratedColumn<String>(
      'rol', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('REGISTRADOR'));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        correo,
        contrasena,
        nombre,
        rol,
        version,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usuarios';
  @override
  VerificationContext validateIntegrity(Insertable<UsuarioLocal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('correo')) {
      context.handle(_correoMeta,
          correo.isAcceptableOrUnknown(data['correo']!, _correoMeta));
    } else if (isInserting) {
      context.missing(_correoMeta);
    }
    if (data.containsKey('contrasena')) {
      context.handle(
          _contrasenaMeta,
          contrasena.isAcceptableOrUnknown(
              data['contrasena']!, _contrasenaMeta));
    } else if (isInserting) {
      context.missing(_contrasenaMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    }
    if (data.containsKey('rol')) {
      context.handle(
          _rolMeta, rol.isAcceptableOrUnknown(data['rol']!, _rolMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsuarioLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsuarioLocal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      correo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}correo'])!,
      contrasena: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contrasena'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre']),
      rol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rol'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $UsuariosTable createAlias(String alias) {
    return $UsuariosTable(attachedDatabase, alias);
  }
}

class UsuarioLocal extends DataClass implements Insertable<UsuarioLocal> {
  final String id;
  final String correo;
  final String contrasena;
  final String? nombre;
  final String rol;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const UsuarioLocal(
      {required this.id,
      required this.correo,
      required this.contrasena,
      this.nombre,
      required this.rol,
      required this.version,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['correo'] = Variable<String>(correo);
    map['contrasena'] = Variable<String>(contrasena);
    if (!nullToAbsent || nombre != null) {
      map['nombre'] = Variable<String>(nombre);
    }
    map['rol'] = Variable<String>(rol);
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  UsuariosCompanion toCompanion(bool nullToAbsent) {
    return UsuariosCompanion(
      id: Value(id),
      correo: Value(correo),
      contrasena: Value(contrasena),
      nombre:
          nombre == null && nullToAbsent ? const Value.absent() : Value(nombre),
      rol: Value(rol),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory UsuarioLocal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsuarioLocal(
      id: serializer.fromJson<String>(json['id']),
      correo: serializer.fromJson<String>(json['correo']),
      contrasena: serializer.fromJson<String>(json['contrasena']),
      nombre: serializer.fromJson<String?>(json['nombre']),
      rol: serializer.fromJson<String>(json['rol']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'correo': serializer.toJson<String>(correo),
      'contrasena': serializer.toJson<String>(contrasena),
      'nombre': serializer.toJson<String?>(nombre),
      'rol': serializer.toJson<String>(rol),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  UsuarioLocal copyWith(
          {String? id,
          String? correo,
          String? contrasena,
          Value<String?> nombre = const Value.absent(),
          String? rol,
          int? version,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      UsuarioLocal(
        id: id ?? this.id,
        correo: correo ?? this.correo,
        contrasena: contrasena ?? this.contrasena,
        nombre: nombre.present ? nombre.value : this.nombre,
        rol: rol ?? this.rol,
        version: version ?? this.version,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  UsuarioLocal copyWithCompanion(UsuariosCompanion data) {
    return UsuarioLocal(
      id: data.id.present ? data.id.value : this.id,
      correo: data.correo.present ? data.correo.value : this.correo,
      contrasena:
          data.contrasena.present ? data.contrasena.value : this.contrasena,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      rol: data.rol.present ? data.rol.value : this.rol,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsuarioLocal(')
          ..write('id: $id, ')
          ..write('correo: $correo, ')
          ..write('contrasena: $contrasena, ')
          ..write('nombre: $nombre, ')
          ..write('rol: $rol, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, correo, contrasena, nombre, rol, version,
      createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsuarioLocal &&
          other.id == this.id &&
          other.correo == this.correo &&
          other.contrasena == this.contrasena &&
          other.nombre == this.nombre &&
          other.rol == this.rol &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class UsuariosCompanion extends UpdateCompanion<UsuarioLocal> {
  final Value<String> id;
  final Value<String> correo;
  final Value<String> contrasena;
  final Value<String?> nombre;
  final Value<String> rol;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const UsuariosCompanion({
    this.id = const Value.absent(),
    this.correo = const Value.absent(),
    this.contrasena = const Value.absent(),
    this.nombre = const Value.absent(),
    this.rol = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsuariosCompanion.insert({
    required String id,
    required String correo,
    required String contrasena,
    this.nombre = const Value.absent(),
    this.rol = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        correo = Value(correo),
        contrasena = Value(contrasena);
  static Insertable<UsuarioLocal> custom({
    Expression<String>? id,
    Expression<String>? correo,
    Expression<String>? contrasena,
    Expression<String>? nombre,
    Expression<String>? rol,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (correo != null) 'correo': correo,
      if (contrasena != null) 'contrasena': contrasena,
      if (nombre != null) 'nombre': nombre,
      if (rol != null) 'rol': rol,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsuariosCompanion copyWith(
      {Value<String>? id,
      Value<String>? correo,
      Value<String>? contrasena,
      Value<String?>? nombre,
      Value<String>? rol,
      Value<int>? version,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return UsuariosCompanion(
      id: id ?? this.id,
      correo: correo ?? this.correo,
      contrasena: contrasena ?? this.contrasena,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (correo.present) {
      map['correo'] = Variable<String>(correo.value);
    }
    if (contrasena.present) {
      map['contrasena'] = Variable<String>(contrasena.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (rol.present) {
      map['rol'] = Variable<String>(rol.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsuariosCompanion(')
          ..write('id: $id, ')
          ..write('correo: $correo, ')
          ..write('contrasena: $contrasena, ')
          ..write('nombre: $nombre, ')
          ..write('rol: $rol, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CiudadanosTable extends Ciudadanos
    with TableInfo<$CiudadanosTable, CiudadanoLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CiudadanosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _documentoIdentidadMeta =
      const VerificationMeta('documentoIdentidad');
  @override
  late final GeneratedColumn<String> documentoIdentidad =
      GeneratedColumn<String>('documento_identidad', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nombresMeta =
      const VerificationMeta('nombres');
  @override
  late final GeneratedColumn<String> nombres = GeneratedColumn<String>(
      'nombres', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _apellidosMeta =
      const VerificationMeta('apellidos');
  @override
  late final GeneratedColumn<String> apellidos = GeneratedColumn<String>(
      'apellidos', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fechaNacimientoMeta =
      const VerificationMeta('fechaNacimiento');
  @override
  late final GeneratedColumn<DateTime> fechaNacimiento =
      GeneratedColumn<DateTime>('fecha_nacimiento', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _telefonoMeta =
      const VerificationMeta('telefono');
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
      'telefono', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _correoMeta = const VerificationMeta('correo');
  @override
  late final GeneratedColumn<String> correo = GeneratedColumn<String>(
      'correo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estadoSincronizacionMeta =
      const VerificationMeta('estadoSincronizacion');
  @override
  late final GeneratedColumn<String> estadoSincronizacion =
      GeneratedColumn<String>('estado_sincronizacion', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('PENDIENTE'));
  static const VerificationMeta _registradoPorUsuarioIdMeta =
      const VerificationMeta('registradoPorUsuarioId');
  @override
  late final GeneratedColumn<String> registradoPorUsuarioId =
      GeneratedColumn<String>('registrado_por_usuario_id', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints:
              GeneratedColumn.constraintIsAlways('REFERENCES usuarios (id)'));
  static const VerificationMeta _registradoEnDispositivoIdMeta =
      const VerificationMeta('registradoEnDispositivoId');
  @override
  late final GeneratedColumn<String> registradoEnDispositivoId =
      GeneratedColumn<String>(
          'registrado_en_dispositivo_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _metadatosCamposMeta =
      const VerificationMeta('metadatosCampos');
  @override
  late final GeneratedColumn<String> metadatosCampos = GeneratedColumn<String>(
      'metadatos_campos', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        documentoIdentidad,
        nombres,
        apellidos,
        fechaNacimiento,
        telefono,
        correo,
        estadoSincronizacion,
        registradoPorUsuarioId,
        registradoEnDispositivoId,
        version,
        metadatosCampos,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ciudadanos';
  @override
  VerificationContext validateIntegrity(Insertable<CiudadanoLocal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('documento_identidad')) {
      context.handle(
          _documentoIdentidadMeta,
          documentoIdentidad.isAcceptableOrUnknown(
              data['documento_identidad']!, _documentoIdentidadMeta));
    } else if (isInserting) {
      context.missing(_documentoIdentidadMeta);
    }
    if (data.containsKey('nombres')) {
      context.handle(_nombresMeta,
          nombres.isAcceptableOrUnknown(data['nombres']!, _nombresMeta));
    } else if (isInserting) {
      context.missing(_nombresMeta);
    }
    if (data.containsKey('apellidos')) {
      context.handle(_apellidosMeta,
          apellidos.isAcceptableOrUnknown(data['apellidos']!, _apellidosMeta));
    } else if (isInserting) {
      context.missing(_apellidosMeta);
    }
    if (data.containsKey('fecha_nacimiento')) {
      context.handle(
          _fechaNacimientoMeta,
          fechaNacimiento.isAcceptableOrUnknown(
              data['fecha_nacimiento']!, _fechaNacimientoMeta));
    } else if (isInserting) {
      context.missing(_fechaNacimientoMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(_telefonoMeta,
          telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta));
    }
    if (data.containsKey('correo')) {
      context.handle(_correoMeta,
          correo.isAcceptableOrUnknown(data['correo']!, _correoMeta));
    }
    if (data.containsKey('estado_sincronizacion')) {
      context.handle(
          _estadoSincronizacionMeta,
          estadoSincronizacion.isAcceptableOrUnknown(
              data['estado_sincronizacion']!, _estadoSincronizacionMeta));
    }
    if (data.containsKey('registrado_por_usuario_id')) {
      context.handle(
          _registradoPorUsuarioIdMeta,
          registradoPorUsuarioId.isAcceptableOrUnknown(
              data['registrado_por_usuario_id']!, _registradoPorUsuarioIdMeta));
    } else if (isInserting) {
      context.missing(_registradoPorUsuarioIdMeta);
    }
    if (data.containsKey('registrado_en_dispositivo_id')) {
      context.handle(
          _registradoEnDispositivoIdMeta,
          registradoEnDispositivoId.isAcceptableOrUnknown(
              data['registrado_en_dispositivo_id']!,
              _registradoEnDispositivoIdMeta));
    } else if (isInserting) {
      context.missing(_registradoEnDispositivoIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('metadatos_campos')) {
      context.handle(
          _metadatosCamposMeta,
          metadatosCampos.isAcceptableOrUnknown(
              data['metadatos_campos']!, _metadatosCamposMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CiudadanoLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CiudadanoLocal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      documentoIdentidad: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}documento_identidad'])!,
      nombres: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombres'])!,
      apellidos: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}apellidos'])!,
      fechaNacimiento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_nacimiento'])!,
      telefono: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telefono']),
      correo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}correo']),
      estadoSincronizacion: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}estado_sincronizacion'])!,
      registradoPorUsuarioId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}registrado_por_usuario_id'])!,
      registradoEnDispositivoId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}registrado_en_dispositivo_id'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      metadatosCampos: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}metadatos_campos']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $CiudadanosTable createAlias(String alias) {
    return $CiudadanosTable(attachedDatabase, alias);
  }
}

class CiudadanoLocal extends DataClass implements Insertable<CiudadanoLocal> {
  final String id;
  final String documentoIdentidad;
  final String nombres;
  final String apellidos;
  final DateTime fechaNacimiento;
  final String? telefono;
  final String? correo;
  final String estadoSincronizacion;
  final String registradoPorUsuarioId;
  final String registradoEnDispositivoId;
  final int version;
  final String? metadatosCampos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CiudadanoLocal(
      {required this.id,
      required this.documentoIdentidad,
      required this.nombres,
      required this.apellidos,
      required this.fechaNacimiento,
      this.telefono,
      this.correo,
      required this.estadoSincronizacion,
      required this.registradoPorUsuarioId,
      required this.registradoEnDispositivoId,
      required this.version,
      this.metadatosCampos,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['documento_identidad'] = Variable<String>(documentoIdentidad);
    map['nombres'] = Variable<String>(nombres);
    map['apellidos'] = Variable<String>(apellidos);
    map['fecha_nacimiento'] = Variable<DateTime>(fechaNacimiento);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || correo != null) {
      map['correo'] = Variable<String>(correo);
    }
    map['estado_sincronizacion'] = Variable<String>(estadoSincronizacion);
    map['registrado_por_usuario_id'] = Variable<String>(registradoPorUsuarioId);
    map['registrado_en_dispositivo_id'] =
        Variable<String>(registradoEnDispositivoId);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || metadatosCampos != null) {
      map['metadatos_campos'] = Variable<String>(metadatosCampos);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CiudadanosCompanion toCompanion(bool nullToAbsent) {
    return CiudadanosCompanion(
      id: Value(id),
      documentoIdentidad: Value(documentoIdentidad),
      nombres: Value(nombres),
      apellidos: Value(apellidos),
      fechaNacimiento: Value(fechaNacimiento),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      correo:
          correo == null && nullToAbsent ? const Value.absent() : Value(correo),
      estadoSincronizacion: Value(estadoSincronizacion),
      registradoPorUsuarioId: Value(registradoPorUsuarioId),
      registradoEnDispositivoId: Value(registradoEnDispositivoId),
      version: Value(version),
      metadatosCampos: metadatosCampos == null && nullToAbsent
          ? const Value.absent()
          : Value(metadatosCampos),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CiudadanoLocal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CiudadanoLocal(
      id: serializer.fromJson<String>(json['id']),
      documentoIdentidad:
          serializer.fromJson<String>(json['documentoIdentidad']),
      nombres: serializer.fromJson<String>(json['nombres']),
      apellidos: serializer.fromJson<String>(json['apellidos']),
      fechaNacimiento: serializer.fromJson<DateTime>(json['fechaNacimiento']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      correo: serializer.fromJson<String?>(json['correo']),
      estadoSincronizacion:
          serializer.fromJson<String>(json['estadoSincronizacion']),
      registradoPorUsuarioId:
          serializer.fromJson<String>(json['registradoPorUsuarioId']),
      registradoEnDispositivoId:
          serializer.fromJson<String>(json['registradoEnDispositivoId']),
      version: serializer.fromJson<int>(json['version']),
      metadatosCampos: serializer.fromJson<String?>(json['metadatosCampos']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentoIdentidad': serializer.toJson<String>(documentoIdentidad),
      'nombres': serializer.toJson<String>(nombres),
      'apellidos': serializer.toJson<String>(apellidos),
      'fechaNacimiento': serializer.toJson<DateTime>(fechaNacimiento),
      'telefono': serializer.toJson<String?>(telefono),
      'correo': serializer.toJson<String?>(correo),
      'estadoSincronizacion': serializer.toJson<String>(estadoSincronizacion),
      'registradoPorUsuarioId':
          serializer.toJson<String>(registradoPorUsuarioId),
      'registradoEnDispositivoId':
          serializer.toJson<String>(registradoEnDispositivoId),
      'version': serializer.toJson<int>(version),
      'metadatosCampos': serializer.toJson<String?>(metadatosCampos),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CiudadanoLocal copyWith(
          {String? id,
          String? documentoIdentidad,
          String? nombres,
          String? apellidos,
          DateTime? fechaNacimiento,
          Value<String?> telefono = const Value.absent(),
          Value<String?> correo = const Value.absent(),
          String? estadoSincronizacion,
          String? registradoPorUsuarioId,
          String? registradoEnDispositivoId,
          int? version,
          Value<String?> metadatosCampos = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      CiudadanoLocal(
        id: id ?? this.id,
        documentoIdentidad: documentoIdentidad ?? this.documentoIdentidad,
        nombres: nombres ?? this.nombres,
        apellidos: apellidos ?? this.apellidos,
        fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
        telefono: telefono.present ? telefono.value : this.telefono,
        correo: correo.present ? correo.value : this.correo,
        estadoSincronizacion: estadoSincronizacion ?? this.estadoSincronizacion,
        registradoPorUsuarioId:
            registradoPorUsuarioId ?? this.registradoPorUsuarioId,
        registradoEnDispositivoId:
            registradoEnDispositivoId ?? this.registradoEnDispositivoId,
        version: version ?? this.version,
        metadatosCampos: metadatosCampos.present
            ? metadatosCampos.value
            : this.metadatosCampos,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  CiudadanoLocal copyWithCompanion(CiudadanosCompanion data) {
    return CiudadanoLocal(
      id: data.id.present ? data.id.value : this.id,
      documentoIdentidad: data.documentoIdentidad.present
          ? data.documentoIdentidad.value
          : this.documentoIdentidad,
      nombres: data.nombres.present ? data.nombres.value : this.nombres,
      apellidos: data.apellidos.present ? data.apellidos.value : this.apellidos,
      fechaNacimiento: data.fechaNacimiento.present
          ? data.fechaNacimiento.value
          : this.fechaNacimiento,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      correo: data.correo.present ? data.correo.value : this.correo,
      estadoSincronizacion: data.estadoSincronizacion.present
          ? data.estadoSincronizacion.value
          : this.estadoSincronizacion,
      registradoPorUsuarioId: data.registradoPorUsuarioId.present
          ? data.registradoPorUsuarioId.value
          : this.registradoPorUsuarioId,
      registradoEnDispositivoId: data.registradoEnDispositivoId.present
          ? data.registradoEnDispositivoId.value
          : this.registradoEnDispositivoId,
      version: data.version.present ? data.version.value : this.version,
      metadatosCampos: data.metadatosCampos.present
          ? data.metadatosCampos.value
          : this.metadatosCampos,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CiudadanoLocal(')
          ..write('id: $id, ')
          ..write('documentoIdentidad: $documentoIdentidad, ')
          ..write('nombres: $nombres, ')
          ..write('apellidos: $apellidos, ')
          ..write('fechaNacimiento: $fechaNacimiento, ')
          ..write('telefono: $telefono, ')
          ..write('correo: $correo, ')
          ..write('estadoSincronizacion: $estadoSincronizacion, ')
          ..write('registradoPorUsuarioId: $registradoPorUsuarioId, ')
          ..write('registradoEnDispositivoId: $registradoEnDispositivoId, ')
          ..write('version: $version, ')
          ..write('metadatosCampos: $metadatosCampos, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      documentoIdentidad,
      nombres,
      apellidos,
      fechaNacimiento,
      telefono,
      correo,
      estadoSincronizacion,
      registradoPorUsuarioId,
      registradoEnDispositivoId,
      version,
      metadatosCampos,
      createdAt,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CiudadanoLocal &&
          other.id == this.id &&
          other.documentoIdentidad == this.documentoIdentidad &&
          other.nombres == this.nombres &&
          other.apellidos == this.apellidos &&
          other.fechaNacimiento == this.fechaNacimiento &&
          other.telefono == this.telefono &&
          other.correo == this.correo &&
          other.estadoSincronizacion == this.estadoSincronizacion &&
          other.registradoPorUsuarioId == this.registradoPorUsuarioId &&
          other.registradoEnDispositivoId == this.registradoEnDispositivoId &&
          other.version == this.version &&
          other.metadatosCampos == this.metadatosCampos &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CiudadanosCompanion extends UpdateCompanion<CiudadanoLocal> {
  final Value<String> id;
  final Value<String> documentoIdentidad;
  final Value<String> nombres;
  final Value<String> apellidos;
  final Value<DateTime> fechaNacimiento;
  final Value<String?> telefono;
  final Value<String?> correo;
  final Value<String> estadoSincronizacion;
  final Value<String> registradoPorUsuarioId;
  final Value<String> registradoEnDispositivoId;
  final Value<int> version;
  final Value<String?> metadatosCampos;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CiudadanosCompanion({
    this.id = const Value.absent(),
    this.documentoIdentidad = const Value.absent(),
    this.nombres = const Value.absent(),
    this.apellidos = const Value.absent(),
    this.fechaNacimiento = const Value.absent(),
    this.telefono = const Value.absent(),
    this.correo = const Value.absent(),
    this.estadoSincronizacion = const Value.absent(),
    this.registradoPorUsuarioId = const Value.absent(),
    this.registradoEnDispositivoId = const Value.absent(),
    this.version = const Value.absent(),
    this.metadatosCampos = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CiudadanosCompanion.insert({
    required String id,
    required String documentoIdentidad,
    required String nombres,
    required String apellidos,
    required DateTime fechaNacimiento,
    this.telefono = const Value.absent(),
    this.correo = const Value.absent(),
    this.estadoSincronizacion = const Value.absent(),
    required String registradoPorUsuarioId,
    required String registradoEnDispositivoId,
    this.version = const Value.absent(),
    this.metadatosCampos = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        documentoIdentidad = Value(documentoIdentidad),
        nombres = Value(nombres),
        apellidos = Value(apellidos),
        fechaNacimiento = Value(fechaNacimiento),
        registradoPorUsuarioId = Value(registradoPorUsuarioId),
        registradoEnDispositivoId = Value(registradoEnDispositivoId);
  static Insertable<CiudadanoLocal> custom({
    Expression<String>? id,
    Expression<String>? documentoIdentidad,
    Expression<String>? nombres,
    Expression<String>? apellidos,
    Expression<DateTime>? fechaNacimiento,
    Expression<String>? telefono,
    Expression<String>? correo,
    Expression<String>? estadoSincronizacion,
    Expression<String>? registradoPorUsuarioId,
    Expression<String>? registradoEnDispositivoId,
    Expression<int>? version,
    Expression<String>? metadatosCampos,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentoIdentidad != null) 'documento_identidad': documentoIdentidad,
      if (nombres != null) 'nombres': nombres,
      if (apellidos != null) 'apellidos': apellidos,
      if (fechaNacimiento != null) 'fecha_nacimiento': fechaNacimiento,
      if (telefono != null) 'telefono': telefono,
      if (correo != null) 'correo': correo,
      if (estadoSincronizacion != null)
        'estado_sincronizacion': estadoSincronizacion,
      if (registradoPorUsuarioId != null)
        'registrado_por_usuario_id': registradoPorUsuarioId,
      if (registradoEnDispositivoId != null)
        'registrado_en_dispositivo_id': registradoEnDispositivoId,
      if (version != null) 'version': version,
      if (metadatosCampos != null) 'metadatos_campos': metadatosCampos,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CiudadanosCompanion copyWith(
      {Value<String>? id,
      Value<String>? documentoIdentidad,
      Value<String>? nombres,
      Value<String>? apellidos,
      Value<DateTime>? fechaNacimiento,
      Value<String?>? telefono,
      Value<String?>? correo,
      Value<String>? estadoSincronizacion,
      Value<String>? registradoPorUsuarioId,
      Value<String>? registradoEnDispositivoId,
      Value<int>? version,
      Value<String?>? metadatosCampos,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return CiudadanosCompanion(
      id: id ?? this.id,
      documentoIdentidad: documentoIdentidad ?? this.documentoIdentidad,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      estadoSincronizacion: estadoSincronizacion ?? this.estadoSincronizacion,
      registradoPorUsuarioId:
          registradoPorUsuarioId ?? this.registradoPorUsuarioId,
      registradoEnDispositivoId:
          registradoEnDispositivoId ?? this.registradoEnDispositivoId,
      version: version ?? this.version,
      metadatosCampos: metadatosCampos ?? this.metadatosCampos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentoIdentidad.present) {
      map['documento_identidad'] = Variable<String>(documentoIdentidad.value);
    }
    if (nombres.present) {
      map['nombres'] = Variable<String>(nombres.value);
    }
    if (apellidos.present) {
      map['apellidos'] = Variable<String>(apellidos.value);
    }
    if (fechaNacimiento.present) {
      map['fecha_nacimiento'] = Variable<DateTime>(fechaNacimiento.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (correo.present) {
      map['correo'] = Variable<String>(correo.value);
    }
    if (estadoSincronizacion.present) {
      map['estado_sincronizacion'] =
          Variable<String>(estadoSincronizacion.value);
    }
    if (registradoPorUsuarioId.present) {
      map['registrado_por_usuario_id'] =
          Variable<String>(registradoPorUsuarioId.value);
    }
    if (registradoEnDispositivoId.present) {
      map['registrado_en_dispositivo_id'] =
          Variable<String>(registradoEnDispositivoId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (metadatosCampos.present) {
      map['metadatos_campos'] = Variable<String>(metadatosCampos.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CiudadanosCompanion(')
          ..write('id: $id, ')
          ..write('documentoIdentidad: $documentoIdentidad, ')
          ..write('nombres: $nombres, ')
          ..write('apellidos: $apellidos, ')
          ..write('fechaNacimiento: $fechaNacimiento, ')
          ..write('telefono: $telefono, ')
          ..write('correo: $correo, ')
          ..write('estadoSincronizacion: $estadoSincronizacion, ')
          ..write('registradoPorUsuarioId: $registradoPorUsuarioId, ')
          ..write('registradoEnDispositivoId: $registradoEnDispositivoId, ')
          ..write('version: $version, ')
          ..write('metadatosCampos: $metadatosCampos, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tablaAfectadaMeta =
      const VerificationMeta('tablaAfectada');
  @override
  late final GeneratedColumn<String> tablaAfectada = GeneratedColumn<String>(
      'tabla_afectada', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _registroIdMeta =
      const VerificationMeta('registroId');
  @override
  late final GeneratedColumn<String> registroId = GeneratedColumn<String>(
      'registro_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operacionMeta =
      const VerificationMeta('operacion');
  @override
  late final GeneratedColumn<String> operacion = GeneratedColumn<String>(
      'operacion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDIENTE'));
  static const VerificationMeta _intentosMeta =
      const VerificationMeta('intentos');
  @override
  late final GeneratedColumn<int> intentos = GeneratedColumn<int>(
      'intentos', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _ultimoErrorMeta =
      const VerificationMeta('ultimoError');
  @override
  late final GeneratedColumn<String> ultimoError = GeneratedColumn<String>(
      'ultimo_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tablaAfectada,
        registroId,
        operacion,
        payload,
        estado,
        intentos,
        ultimoError,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueLocal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tabla_afectada')) {
      context.handle(
          _tablaAfectadaMeta,
          tablaAfectada.isAcceptableOrUnknown(
              data['tabla_afectada']!, _tablaAfectadaMeta));
    } else if (isInserting) {
      context.missing(_tablaAfectadaMeta);
    }
    if (data.containsKey('registro_id')) {
      context.handle(
          _registroIdMeta,
          registroId.isAcceptableOrUnknown(
              data['registro_id']!, _registroIdMeta));
    } else if (isInserting) {
      context.missing(_registroIdMeta);
    }
    if (data.containsKey('operacion')) {
      context.handle(_operacionMeta,
          operacion.isAcceptableOrUnknown(data['operacion']!, _operacionMeta));
    } else if (isInserting) {
      context.missing(_operacionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    if (data.containsKey('intentos')) {
      context.handle(_intentosMeta,
          intentos.isAcceptableOrUnknown(data['intentos']!, _intentosMeta));
    }
    if (data.containsKey('ultimo_error')) {
      context.handle(
          _ultimoErrorMeta,
          ultimoError.isAcceptableOrUnknown(
              data['ultimo_error']!, _ultimoErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueLocal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tablaAfectada: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tabla_afectada'])!,
      registroId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}registro_id'])!,
      operacion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operacion'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      intentos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}intentos'])!,
      ultimoError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ultimo_error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueLocal extends DataClass implements Insertable<SyncQueueLocal> {
  final String id;
  final String tablaAfectada;
  final String registroId;
  final String operacion;
  final String payload;
  final String estado;
  final int intentos;
  final String? ultimoError;
  final DateTime createdAt;
  const SyncQueueLocal(
      {required this.id,
      required this.tablaAfectada,
      required this.registroId,
      required this.operacion,
      required this.payload,
      required this.estado,
      required this.intentos,
      this.ultimoError,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tabla_afectada'] = Variable<String>(tablaAfectada);
    map['registro_id'] = Variable<String>(registroId);
    map['operacion'] = Variable<String>(operacion);
    map['payload'] = Variable<String>(payload);
    map['estado'] = Variable<String>(estado);
    map['intentos'] = Variable<int>(intentos);
    if (!nullToAbsent || ultimoError != null) {
      map['ultimo_error'] = Variable<String>(ultimoError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      tablaAfectada: Value(tablaAfectada),
      registroId: Value(registroId),
      operacion: Value(operacion),
      payload: Value(payload),
      estado: Value(estado),
      intentos: Value(intentos),
      ultimoError: ultimoError == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimoError),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueLocal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueLocal(
      id: serializer.fromJson<String>(json['id']),
      tablaAfectada: serializer.fromJson<String>(json['tablaAfectada']),
      registroId: serializer.fromJson<String>(json['registroId']),
      operacion: serializer.fromJson<String>(json['operacion']),
      payload: serializer.fromJson<String>(json['payload']),
      estado: serializer.fromJson<String>(json['estado']),
      intentos: serializer.fromJson<int>(json['intentos']),
      ultimoError: serializer.fromJson<String?>(json['ultimoError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tablaAfectada': serializer.toJson<String>(tablaAfectada),
      'registroId': serializer.toJson<String>(registroId),
      'operacion': serializer.toJson<String>(operacion),
      'payload': serializer.toJson<String>(payload),
      'estado': serializer.toJson<String>(estado),
      'intentos': serializer.toJson<int>(intentos),
      'ultimoError': serializer.toJson<String?>(ultimoError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueLocal copyWith(
          {String? id,
          String? tablaAfectada,
          String? registroId,
          String? operacion,
          String? payload,
          String? estado,
          int? intentos,
          Value<String?> ultimoError = const Value.absent(),
          DateTime? createdAt}) =>
      SyncQueueLocal(
        id: id ?? this.id,
        tablaAfectada: tablaAfectada ?? this.tablaAfectada,
        registroId: registroId ?? this.registroId,
        operacion: operacion ?? this.operacion,
        payload: payload ?? this.payload,
        estado: estado ?? this.estado,
        intentos: intentos ?? this.intentos,
        ultimoError: ultimoError.present ? ultimoError.value : this.ultimoError,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncQueueLocal copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueLocal(
      id: data.id.present ? data.id.value : this.id,
      tablaAfectada: data.tablaAfectada.present
          ? data.tablaAfectada.value
          : this.tablaAfectada,
      registroId:
          data.registroId.present ? data.registroId.value : this.registroId,
      operacion: data.operacion.present ? data.operacion.value : this.operacion,
      payload: data.payload.present ? data.payload.value : this.payload,
      estado: data.estado.present ? data.estado.value : this.estado,
      intentos: data.intentos.present ? data.intentos.value : this.intentos,
      ultimoError:
          data.ultimoError.present ? data.ultimoError.value : this.ultimoError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueLocal(')
          ..write('id: $id, ')
          ..write('tablaAfectada: $tablaAfectada, ')
          ..write('registroId: $registroId, ')
          ..write('operacion: $operacion, ')
          ..write('payload: $payload, ')
          ..write('estado: $estado, ')
          ..write('intentos: $intentos, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tablaAfectada, registroId, operacion,
      payload, estado, intentos, ultimoError, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueLocal &&
          other.id == this.id &&
          other.tablaAfectada == this.tablaAfectada &&
          other.registroId == this.registroId &&
          other.operacion == this.operacion &&
          other.payload == this.payload &&
          other.estado == this.estado &&
          other.intentos == this.intentos &&
          other.ultimoError == this.ultimoError &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueLocal> {
  final Value<String> id;
  final Value<String> tablaAfectada;
  final Value<String> registroId;
  final Value<String> operacion;
  final Value<String> payload;
  final Value<String> estado;
  final Value<int> intentos;
  final Value<String?> ultimoError;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.tablaAfectada = const Value.absent(),
    this.registroId = const Value.absent(),
    this.operacion = const Value.absent(),
    this.payload = const Value.absent(),
    this.estado = const Value.absent(),
    this.intentos = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required String tablaAfectada,
    required String registroId,
    required String operacion,
    required String payload,
    this.estado = const Value.absent(),
    this.intentos = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tablaAfectada = Value(tablaAfectada),
        registroId = Value(registroId),
        operacion = Value(operacion),
        payload = Value(payload);
  static Insertable<SyncQueueLocal> custom({
    Expression<String>? id,
    Expression<String>? tablaAfectada,
    Expression<String>? registroId,
    Expression<String>? operacion,
    Expression<String>? payload,
    Expression<String>? estado,
    Expression<int>? intentos,
    Expression<String>? ultimoError,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tablaAfectada != null) 'tabla_afectada': tablaAfectada,
      if (registroId != null) 'registro_id': registroId,
      if (operacion != null) 'operacion': operacion,
      if (payload != null) 'payload': payload,
      if (estado != null) 'estado': estado,
      if (intentos != null) 'intentos': intentos,
      if (ultimoError != null) 'ultimo_error': ultimoError,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<String>? id,
      Value<String>? tablaAfectada,
      Value<String>? registroId,
      Value<String>? operacion,
      Value<String>? payload,
      Value<String>? estado,
      Value<int>? intentos,
      Value<String?>? ultimoError,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      tablaAfectada: tablaAfectada ?? this.tablaAfectada,
      registroId: registroId ?? this.registroId,
      operacion: operacion ?? this.operacion,
      payload: payload ?? this.payload,
      estado: estado ?? this.estado,
      intentos: intentos ?? this.intentos,
      ultimoError: ultimoError ?? this.ultimoError,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tablaAfectada.present) {
      map['tabla_afectada'] = Variable<String>(tablaAfectada.value);
    }
    if (registroId.present) {
      map['registro_id'] = Variable<String>(registroId.value);
    }
    if (operacion.present) {
      map['operacion'] = Variable<String>(operacion.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (intentos.present) {
      map['intentos'] = Variable<int>(intentos.value);
    }
    if (ultimoError.present) {
      map['ultimo_error'] = Variable<String>(ultimoError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('tablaAfectada: $tablaAfectada, ')
          ..write('registroId: $registroId, ')
          ..write('operacion: $operacion, ')
          ..write('payload: $payload, ')
          ..write('estado: $estado, ')
          ..write('intentos: $intentos, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsuariosTable usuarios = $UsuariosTable(this);
  late final $CiudadanosTable ciudadanos = $CiudadanosTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final UsuarioDao usuarioDao = UsuarioDao(this as AppDatabase);
  late final CiudadanoDao ciudadanoDao = CiudadanoDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [usuarios, ciudadanos, syncQueue];
}

typedef $$UsuariosTableCreateCompanionBuilder = UsuariosCompanion Function({
  required String id,
  required String correo,
  required String contrasena,
  Value<String?> nombre,
  Value<String> rol,
  Value<int> version,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$UsuariosTableUpdateCompanionBuilder = UsuariosCompanion Function({
  Value<String> id,
  Value<String> correo,
  Value<String> contrasena,
  Value<String?> nombre,
  Value<String> rol,
  Value<int> version,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$UsuariosTableReferences
    extends BaseReferences<_$AppDatabase, $UsuariosTable, UsuarioLocal> {
  $$UsuariosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CiudadanosTable, List<CiudadanoLocal>>
      _ciudadanosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.ciudadanos,
              aliasName: 'usuarios__id__ciudadanos__registrado_por_usuario_id');

  $$CiudadanosTableProcessedTableManager get ciudadanosRefs {
    final manager = $$CiudadanosTableTableManager($_db, $_db.ciudadanos).filter(
        (f) =>
            f.registradoPorUsuarioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ciudadanosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsuariosTableFilterComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correo => $composableBuilder(
      column: $table.correo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contrasena => $composableBuilder(
      column: $table.contrasena, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rol => $composableBuilder(
      column: $table.rol, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> ciudadanosRefs(
      Expression<bool> Function($$CiudadanosTableFilterComposer f) f) {
    final $$CiudadanosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ciudadanos,
        getReferencedColumn: (t) => t.registradoPorUsuarioId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CiudadanosTableFilterComposer(
              $db: $db,
              $table: $db.ciudadanos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsuariosTableOrderingComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correo => $composableBuilder(
      column: $table.correo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contrasena => $composableBuilder(
      column: $table.contrasena, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rol => $composableBuilder(
      column: $table.rol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$UsuariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get correo =>
      $composableBuilder(column: $table.correo, builder: (column) => column);

  GeneratedColumn<String> get contrasena => $composableBuilder(
      column: $table.contrasena, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get rol =>
      $composableBuilder(column: $table.rol, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> ciudadanosRefs<T extends Object>(
      Expression<T> Function($$CiudadanosTableAnnotationComposer a) f) {
    final $$CiudadanosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ciudadanos,
        getReferencedColumn: (t) => t.registradoPorUsuarioId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CiudadanosTableAnnotationComposer(
              $db: $db,
              $table: $db.ciudadanos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsuariosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsuariosTable,
    UsuarioLocal,
    $$UsuariosTableFilterComposer,
    $$UsuariosTableOrderingComposer,
    $$UsuariosTableAnnotationComposer,
    $$UsuariosTableCreateCompanionBuilder,
    $$UsuariosTableUpdateCompanionBuilder,
    (UsuarioLocal, $$UsuariosTableReferences),
    UsuarioLocal,
    PrefetchHooks Function({bool ciudadanosRefs})> {
  $$UsuariosTableTableManager(_$AppDatabase db, $UsuariosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsuariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsuariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsuariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> correo = const Value.absent(),
            Value<String> contrasena = const Value.absent(),
            Value<String?> nombre = const Value.absent(),
            Value<String> rol = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsuariosCompanion(
            id: id,
            correo: correo,
            contrasena: contrasena,
            nombre: nombre,
            rol: rol,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String correo,
            required String contrasena,
            Value<String?> nombre = const Value.absent(),
            Value<String> rol = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsuariosCompanion.insert(
            id: id,
            correo: correo,
            contrasena: contrasena,
            nombre: nombre,
            rol: rol,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsuariosTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({ciudadanosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ciudadanosRefs) db.ciudadanos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ciudadanosRefs)
                    await $_getPrefetchedData<UsuarioLocal, $UsuariosTable,
                            CiudadanoLocal>(
                        currentTable: table,
                        referencedTable:
                            $$UsuariosTableReferences._ciudadanosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsuariosTableReferences(db, table, p0)
                                .ciudadanosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.registradoPorUsuarioId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsuariosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsuariosTable,
    UsuarioLocal,
    $$UsuariosTableFilterComposer,
    $$UsuariosTableOrderingComposer,
    $$UsuariosTableAnnotationComposer,
    $$UsuariosTableCreateCompanionBuilder,
    $$UsuariosTableUpdateCompanionBuilder,
    (UsuarioLocal, $$UsuariosTableReferences),
    UsuarioLocal,
    PrefetchHooks Function({bool ciudadanosRefs})>;
typedef $$CiudadanosTableCreateCompanionBuilder = CiudadanosCompanion Function({
  required String id,
  required String documentoIdentidad,
  required String nombres,
  required String apellidos,
  required DateTime fechaNacimiento,
  Value<String?> telefono,
  Value<String?> correo,
  Value<String> estadoSincronizacion,
  required String registradoPorUsuarioId,
  required String registradoEnDispositivoId,
  Value<int> version,
  Value<String?> metadatosCampos,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$CiudadanosTableUpdateCompanionBuilder = CiudadanosCompanion Function({
  Value<String> id,
  Value<String> documentoIdentidad,
  Value<String> nombres,
  Value<String> apellidos,
  Value<DateTime> fechaNacimiento,
  Value<String?> telefono,
  Value<String?> correo,
  Value<String> estadoSincronizacion,
  Value<String> registradoPorUsuarioId,
  Value<String> registradoEnDispositivoId,
  Value<int> version,
  Value<String?> metadatosCampos,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$CiudadanosTableReferences
    extends BaseReferences<_$AppDatabase, $CiudadanosTable, CiudadanoLocal> {
  $$CiudadanosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsuariosTable _registradoPorUsuarioIdTable(_$AppDatabase db) =>
      db.usuarios
          .createAlias('ciudadanos__registrado_por_usuario_id__usuarios__id');

  $$UsuariosTableProcessedTableManager get registradoPorUsuarioId {
    final $_column = $_itemColumn<String>('registrado_por_usuario_id')!;

    final manager = $$UsuariosTableTableManager($_db, $_db.usuarios)
        .filter((f) => f.id.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_registradoPorUsuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CiudadanosTableFilterComposer
    extends Composer<_$AppDatabase, $CiudadanosTable> {
  $$CiudadanosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentoIdentidad => $composableBuilder(
      column: $table.documentoIdentidad,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombres => $composableBuilder(
      column: $table.nombres, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get apellidos => $composableBuilder(
      column: $table.apellidos, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaNacimiento => $composableBuilder(
      column: $table.fechaNacimiento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correo => $composableBuilder(
      column: $table.correo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estadoSincronizacion => $composableBuilder(
      column: $table.estadoSincronizacion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registradoEnDispositivoId => $composableBuilder(
      column: $table.registradoEnDispositivoId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadatosCampos => $composableBuilder(
      column: $table.metadatosCampos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$UsuariosTableFilterComposer get registradoPorUsuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.registradoPorUsuarioId,
        referencedTable: $db.usuarios,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsuariosTableFilterComposer(
              $db: $db,
              $table: $db.usuarios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CiudadanosTableOrderingComposer
    extends Composer<_$AppDatabase, $CiudadanosTable> {
  $$CiudadanosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentoIdentidad => $composableBuilder(
      column: $table.documentoIdentidad,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombres => $composableBuilder(
      column: $table.nombres, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get apellidos => $composableBuilder(
      column: $table.apellidos, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaNacimiento => $composableBuilder(
      column: $table.fechaNacimiento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correo => $composableBuilder(
      column: $table.correo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estadoSincronizacion => $composableBuilder(
      column: $table.estadoSincronizacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registradoEnDispositivoId => $composableBuilder(
      column: $table.registradoEnDispositivoId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadatosCampos => $composableBuilder(
      column: $table.metadatosCampos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$UsuariosTableOrderingComposer get registradoPorUsuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.registradoPorUsuarioId,
        referencedTable: $db.usuarios,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsuariosTableOrderingComposer(
              $db: $db,
              $table: $db.usuarios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CiudadanosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CiudadanosTable> {
  $$CiudadanosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get documentoIdentidad => $composableBuilder(
      column: $table.documentoIdentidad, builder: (column) => column);

  GeneratedColumn<String> get nombres =>
      $composableBuilder(column: $table.nombres, builder: (column) => column);

  GeneratedColumn<String> get apellidos =>
      $composableBuilder(column: $table.apellidos, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaNacimiento => $composableBuilder(
      column: $table.fechaNacimiento, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get correo =>
      $composableBuilder(column: $table.correo, builder: (column) => column);

  GeneratedColumn<String> get estadoSincronizacion => $composableBuilder(
      column: $table.estadoSincronizacion, builder: (column) => column);

  GeneratedColumn<String> get registradoEnDispositivoId => $composableBuilder(
      column: $table.registradoEnDispositivoId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get metadatosCampos => $composableBuilder(
      column: $table.metadatosCampos, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsuariosTableAnnotationComposer get registradoPorUsuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.registradoPorUsuarioId,
        referencedTable: $db.usuarios,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsuariosTableAnnotationComposer(
              $db: $db,
              $table: $db.usuarios,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CiudadanosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CiudadanosTable,
    CiudadanoLocal,
    $$CiudadanosTableFilterComposer,
    $$CiudadanosTableOrderingComposer,
    $$CiudadanosTableAnnotationComposer,
    $$CiudadanosTableCreateCompanionBuilder,
    $$CiudadanosTableUpdateCompanionBuilder,
    (CiudadanoLocal, $$CiudadanosTableReferences),
    CiudadanoLocal,
    PrefetchHooks Function({bool registradoPorUsuarioId})> {
  $$CiudadanosTableTableManager(_$AppDatabase db, $CiudadanosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CiudadanosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CiudadanosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CiudadanosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> documentoIdentidad = const Value.absent(),
            Value<String> nombres = const Value.absent(),
            Value<String> apellidos = const Value.absent(),
            Value<DateTime> fechaNacimiento = const Value.absent(),
            Value<String?> telefono = const Value.absent(),
            Value<String?> correo = const Value.absent(),
            Value<String> estadoSincronizacion = const Value.absent(),
            Value<String> registradoPorUsuarioId = const Value.absent(),
            Value<String> registradoEnDispositivoId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> metadatosCampos = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CiudadanosCompanion(
            id: id,
            documentoIdentidad: documentoIdentidad,
            nombres: nombres,
            apellidos: apellidos,
            fechaNacimiento: fechaNacimiento,
            telefono: telefono,
            correo: correo,
            estadoSincronizacion: estadoSincronizacion,
            registradoPorUsuarioId: registradoPorUsuarioId,
            registradoEnDispositivoId: registradoEnDispositivoId,
            version: version,
            metadatosCampos: metadatosCampos,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String documentoIdentidad,
            required String nombres,
            required String apellidos,
            required DateTime fechaNacimiento,
            Value<String?> telefono = const Value.absent(),
            Value<String?> correo = const Value.absent(),
            Value<String> estadoSincronizacion = const Value.absent(),
            required String registradoPorUsuarioId,
            required String registradoEnDispositivoId,
            Value<int> version = const Value.absent(),
            Value<String?> metadatosCampos = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CiudadanosCompanion.insert(
            id: id,
            documentoIdentidad: documentoIdentidad,
            nombres: nombres,
            apellidos: apellidos,
            fechaNacimiento: fechaNacimiento,
            telefono: telefono,
            correo: correo,
            estadoSincronizacion: estadoSincronizacion,
            registradoPorUsuarioId: registradoPorUsuarioId,
            registradoEnDispositivoId: registradoEnDispositivoId,
            version: version,
            metadatosCampos: metadatosCampos,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CiudadanosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({registradoPorUsuarioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (registradoPorUsuarioId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.registradoPorUsuarioId,
                    referencedTable: $$CiudadanosTableReferences
                        ._registradoPorUsuarioIdTable(db),
                    referencedColumn: $$CiudadanosTableReferences
                        ._registradoPorUsuarioIdTable(db)
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
        ));
}

typedef $$CiudadanosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CiudadanosTable,
    CiudadanoLocal,
    $$CiudadanosTableFilterComposer,
    $$CiudadanosTableOrderingComposer,
    $$CiudadanosTableAnnotationComposer,
    $$CiudadanosTableCreateCompanionBuilder,
    $$CiudadanosTableUpdateCompanionBuilder,
    (CiudadanoLocal, $$CiudadanosTableReferences),
    CiudadanoLocal,
    PrefetchHooks Function({bool registradoPorUsuarioId})>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  required String id,
  required String tablaAfectada,
  required String registroId,
  required String operacion,
  required String payload,
  Value<String> estado,
  Value<int> intentos,
  Value<String?> ultimoError,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<String> id,
  Value<String> tablaAfectada,
  Value<String> registroId,
  Value<String> operacion,
  Value<String> payload,
  Value<String> estado,
  Value<int> intentos,
  Value<String?> ultimoError,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tablaAfectada => $composableBuilder(
      column: $table.tablaAfectada, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registroId => $composableBuilder(
      column: $table.registroId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operacion => $composableBuilder(
      column: $table.operacion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get intentos => $composableBuilder(
      column: $table.intentos, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ultimoError => $composableBuilder(
      column: $table.ultimoError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tablaAfectada => $composableBuilder(
      column: $table.tablaAfectada,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registroId => $composableBuilder(
      column: $table.registroId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operacion => $composableBuilder(
      column: $table.operacion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get intentos => $composableBuilder(
      column: $table.intentos, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ultimoError => $composableBuilder(
      column: $table.ultimoError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tablaAfectada => $composableBuilder(
      column: $table.tablaAfectada, builder: (column) => column);

  GeneratedColumn<String> get registroId => $composableBuilder(
      column: $table.registroId, builder: (column) => column);

  GeneratedColumn<String> get operacion =>
      $composableBuilder(column: $table.operacion, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get intentos =>
      $composableBuilder(column: $table.intentos, builder: (column) => column);

  GeneratedColumn<String> get ultimoError => $composableBuilder(
      column: $table.ultimoError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueLocal,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueLocal,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueLocal>
    ),
    SyncQueueLocal,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tablaAfectada = const Value.absent(),
            Value<String> registroId = const Value.absent(),
            Value<String> operacion = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<int> intentos = const Value.absent(),
            Value<String?> ultimoError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            tablaAfectada: tablaAfectada,
            registroId: registroId,
            operacion: operacion,
            payload: payload,
            estado: estado,
            intentos: intentos,
            ultimoError: ultimoError,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tablaAfectada,
            required String registroId,
            required String operacion,
            required String payload,
            Value<String> estado = const Value.absent(),
            Value<int> intentos = const Value.absent(),
            Value<String?> ultimoError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            tablaAfectada: tablaAfectada,
            registroId: registroId,
            operacion: operacion,
            payload: payload,
            estado: estado,
            intentos: intentos,
            ultimoError: ultimoError,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueLocal,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueLocal,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueLocal>
    ),
    SyncQueueLocal,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db, _db.usuarios);
  $$CiudadanosTableTableManager get ciudadanos =>
      $$CiudadanosTableTableManager(_db, _db.ciudadanos);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
