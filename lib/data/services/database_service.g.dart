// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_service.dart';

// ignore_for_file: type=lint
class $LocalSessionsTable extends LocalSessions
    with TableInfo<$LocalSessionsTable, LocalSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionCodeMeta = const VerificationMeta(
    'sessionCode',
  );
  @override
  late final GeneratedColumn<String> sessionCode = GeneratedColumn<String>(
    'session_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _animalIdMeta = const VerificationMeta(
    'animalId',
  );
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
    'animal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collarIdMeta = const VerificationMeta(
    'collarId',
  );
  @override
  late final GeneratedColumn<String> collarId = GeneratedColumn<String>(
    'collar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observerIdMeta = const VerificationMeta(
    'observerId',
  );
  @override
  late final GeneratedColumn<String> observerId = GeneratedColumn<String>(
    'observer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentPhaseMeta = const VerificationMeta(
    'currentPhase',
  );
  @override
  late final GeneratedColumn<String> currentPhase = GeneratedColumn<String>(
    'current_phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surgeryTypeMeta = const VerificationMeta(
    'surgeryType',
  );
  @override
  late final GeneratedColumn<String> surgeryType = GeneratedColumn<String>(
    'surgery_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _surgeryReasonMeta = const VerificationMeta(
    'surgeryReason',
  );
  @override
  late final GeneratedColumn<String> surgeryReason = GeneratedColumn<String>(
    'surgery_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _asaStatusMeta = const VerificationMeta(
    'asaStatus',
  );
  @override
  late final GeneratedColumn<String> asaStatus = GeneratedColumn<String>(
    'asa_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baselineDataJsonMeta = const VerificationMeta(
    'baselineDataJson',
  );
  @override
  late final GeneratedColumn<String> baselineDataJson = GeneratedColumn<String>(
    'baseline_data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baselineQualityMeta = const VerificationMeta(
    'baselineQuality',
  );
  @override
  late final GeneratedColumn<int> baselineQuality = GeneratedColumn<int>(
    'baseline_quality',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCalibratedMeta = const VerificationMeta(
    'isCalibrated',
  );
  @override
  late final GeneratedColumn<bool> isCalibrated = GeneratedColumn<bool>(
    'is_calibrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_calibrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _calibrationStatusMeta = const VerificationMeta(
    'calibrationStatus',
  );
  @override
  late final GeneratedColumn<String> calibrationStatus =
      GeneratedColumn<String>(
        'calibration_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _calibrationErrorBpmMeta =
      const VerificationMeta('calibrationErrorBpm');
  @override
  late final GeneratedColumn<double> calibrationErrorBpm =
      GeneratedColumn<double>(
        'calibration_error_bpm',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _calibrationCorrelationMeta =
      const VerificationMeta('calibrationCorrelation');
  @override
  late final GeneratedColumn<double> calibrationCorrelation =
      GeneratedColumn<double>(
        'calibration_correlation',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surgeryStartedAtMeta = const VerificationMeta(
    'surgeryStartedAt',
  );
  @override
  late final GeneratedColumn<DateTime> surgeryStartedAt =
      GeneratedColumn<DateTime>(
        'surgery_started_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _surgeryEndedAtMeta = const VerificationMeta(
    'surgeryEndedAt',
  );
  @override
  late final GeneratedColumn<DateTime> surgeryEndedAt =
      GeneratedColumn<DateTime>(
        'surgery_ended_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collarPhotoPathMeta = const VerificationMeta(
    'collarPhotoPath',
  );
  @override
  late final GeneratedColumn<String> collarPhotoPath = GeneratedColumn<String>(
    'collar_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialPositionMeta = const VerificationMeta(
    'initialPosition',
  );
  @override
  late final GeneratedColumn<String> initialPosition = GeneratedColumn<String>(
    'initial_position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialAnxietyMeta = const VerificationMeta(
    'initialAnxiety',
  );
  @override
  late final GeneratedColumn<String> initialAnxiety = GeneratedColumn<String>(
    'initial_anxiety',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialNotesMeta = const VerificationMeta(
    'initialNotes',
  );
  @override
  late final GeneratedColumn<String> initialNotes = GeneratedColumn<String>(
    'initial_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    sessionCode,
    animalId,
    collarId,
    observerId,
    clinicId,
    currentPhase,
    surgeryType,
    surgeryReason,
    asaStatus,
    baselineDataJson,
    baselineQuality,
    isCalibrated,
    calibrationStatus,
    calibrationErrorBpm,
    calibrationCorrelation,
    startedAt,
    surgeryStartedAt,
    surgeryEndedAt,
    endedAt,
    collarPhotoPath,
    initialPosition,
    initialAnxiety,
    initialNotes,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_code')) {
      context.handle(
        _sessionCodeMeta,
        sessionCode.isAcceptableOrUnknown(
          data['session_code']!,
          _sessionCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionCodeMeta);
    }
    if (data.containsKey('animal_id')) {
      context.handle(
        _animalIdMeta,
        animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('collar_id')) {
      context.handle(
        _collarIdMeta,
        collarId.isAcceptableOrUnknown(data['collar_id']!, _collarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_collarIdMeta);
    }
    if (data.containsKey('observer_id')) {
      context.handle(
        _observerIdMeta,
        observerId.isAcceptableOrUnknown(data['observer_id']!, _observerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_observerIdMeta);
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clinicIdMeta);
    }
    if (data.containsKey('current_phase')) {
      context.handle(
        _currentPhaseMeta,
        currentPhase.isAcceptableOrUnknown(
          data['current_phase']!,
          _currentPhaseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentPhaseMeta);
    }
    if (data.containsKey('surgery_type')) {
      context.handle(
        _surgeryTypeMeta,
        surgeryType.isAcceptableOrUnknown(
          data['surgery_type']!,
          _surgeryTypeMeta,
        ),
      );
    }
    if (data.containsKey('surgery_reason')) {
      context.handle(
        _surgeryReasonMeta,
        surgeryReason.isAcceptableOrUnknown(
          data['surgery_reason']!,
          _surgeryReasonMeta,
        ),
      );
    }
    if (data.containsKey('asa_status')) {
      context.handle(
        _asaStatusMeta,
        asaStatus.isAcceptableOrUnknown(data['asa_status']!, _asaStatusMeta),
      );
    }
    if (data.containsKey('baseline_data_json')) {
      context.handle(
        _baselineDataJsonMeta,
        baselineDataJson.isAcceptableOrUnknown(
          data['baseline_data_json']!,
          _baselineDataJsonMeta,
        ),
      );
    }
    if (data.containsKey('baseline_quality')) {
      context.handle(
        _baselineQualityMeta,
        baselineQuality.isAcceptableOrUnknown(
          data['baseline_quality']!,
          _baselineQualityMeta,
        ),
      );
    }
    if (data.containsKey('is_calibrated')) {
      context.handle(
        _isCalibratedMeta,
        isCalibrated.isAcceptableOrUnknown(
          data['is_calibrated']!,
          _isCalibratedMeta,
        ),
      );
    }
    if (data.containsKey('calibration_status')) {
      context.handle(
        _calibrationStatusMeta,
        calibrationStatus.isAcceptableOrUnknown(
          data['calibration_status']!,
          _calibrationStatusMeta,
        ),
      );
    }
    if (data.containsKey('calibration_error_bpm')) {
      context.handle(
        _calibrationErrorBpmMeta,
        calibrationErrorBpm.isAcceptableOrUnknown(
          data['calibration_error_bpm']!,
          _calibrationErrorBpmMeta,
        ),
      );
    }
    if (data.containsKey('calibration_correlation')) {
      context.handle(
        _calibrationCorrelationMeta,
        calibrationCorrelation.isAcceptableOrUnknown(
          data['calibration_correlation']!,
          _calibrationCorrelationMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('surgery_started_at')) {
      context.handle(
        _surgeryStartedAtMeta,
        surgeryStartedAt.isAcceptableOrUnknown(
          data['surgery_started_at']!,
          _surgeryStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('surgery_ended_at')) {
      context.handle(
        _surgeryEndedAtMeta,
        surgeryEndedAt.isAcceptableOrUnknown(
          data['surgery_ended_at']!,
          _surgeryEndedAtMeta,
        ),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('collar_photo_path')) {
      context.handle(
        _collarPhotoPathMeta,
        collarPhotoPath.isAcceptableOrUnknown(
          data['collar_photo_path']!,
          _collarPhotoPathMeta,
        ),
      );
    }
    if (data.containsKey('initial_position')) {
      context.handle(
        _initialPositionMeta,
        initialPosition.isAcceptableOrUnknown(
          data['initial_position']!,
          _initialPositionMeta,
        ),
      );
    }
    if (data.containsKey('initial_anxiety')) {
      context.handle(
        _initialAnxietyMeta,
        initialAnxiety.isAcceptableOrUnknown(
          data['initial_anxiety']!,
          _initialAnxietyMeta,
        ),
      );
    }
    if (data.containsKey('initial_notes')) {
      context.handle(
        _initialNotesMeta,
        initialNotes.isAcceptableOrUnknown(
          data['initial_notes']!,
          _initialNotesMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
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
  LocalSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_code'],
      )!,
      animalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animal_id'],
      )!,
      collarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collar_id'],
      )!,
      observerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observer_id'],
      )!,
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
      )!,
      currentPhase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_phase'],
      )!,
      surgeryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surgery_type'],
      ),
      surgeryReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surgery_reason'],
      ),
      asaStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asa_status'],
      ),
      baselineDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}baseline_data_json'],
      ),
      baselineQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baseline_quality'],
      ),
      isCalibrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_calibrated'],
      )!,
      calibrationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calibration_status'],
      ),
      calibrationErrorBpm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calibration_error_bpm'],
      ),
      calibrationCorrelation: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calibration_correlation'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      surgeryStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}surgery_started_at'],
      ),
      surgeryEndedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}surgery_ended_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      collarPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collar_photo_path'],
      ),
      initialPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}initial_position'],
      ),
      initialAnxiety: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}initial_anxiety'],
      ),
      initialNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}initial_notes'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalSessionsTable createAlias(String alias) {
    return $LocalSessionsTable(attachedDatabase, alias);
  }
}

class LocalSession extends DataClass implements Insertable<LocalSession> {
  final String id;
  final String sessionCode;
  final String animalId;
  final String collarId;
  final String observerId;
  final String clinicId;
  final String currentPhase;
  final String? surgeryType;
  final String? surgeryReason;
  final String? asaStatus;
  final String? baselineDataJson;
  final int? baselineQuality;
  final bool isCalibrated;
  final String? calibrationStatus;
  final double? calibrationErrorBpm;
  final double? calibrationCorrelation;
  final DateTime startedAt;
  final DateTime? surgeryStartedAt;
  final DateTime? surgeryEndedAt;
  final DateTime? endedAt;
  final String? collarPhotoPath;
  final String? initialPosition;
  final String? initialAnxiety;
  final String? initialNotes;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalSession({
    required this.id,
    required this.sessionCode,
    required this.animalId,
    required this.collarId,
    required this.observerId,
    required this.clinicId,
    required this.currentPhase,
    this.surgeryType,
    this.surgeryReason,
    this.asaStatus,
    this.baselineDataJson,
    this.baselineQuality,
    required this.isCalibrated,
    this.calibrationStatus,
    this.calibrationErrorBpm,
    this.calibrationCorrelation,
    required this.startedAt,
    this.surgeryStartedAt,
    this.surgeryEndedAt,
    this.endedAt,
    this.collarPhotoPath,
    this.initialPosition,
    this.initialAnxiety,
    this.initialNotes,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_code'] = Variable<String>(sessionCode);
    map['animal_id'] = Variable<String>(animalId);
    map['collar_id'] = Variable<String>(collarId);
    map['observer_id'] = Variable<String>(observerId);
    map['clinic_id'] = Variable<String>(clinicId);
    map['current_phase'] = Variable<String>(currentPhase);
    if (!nullToAbsent || surgeryType != null) {
      map['surgery_type'] = Variable<String>(surgeryType);
    }
    if (!nullToAbsent || surgeryReason != null) {
      map['surgery_reason'] = Variable<String>(surgeryReason);
    }
    if (!nullToAbsent || asaStatus != null) {
      map['asa_status'] = Variable<String>(asaStatus);
    }
    if (!nullToAbsent || baselineDataJson != null) {
      map['baseline_data_json'] = Variable<String>(baselineDataJson);
    }
    if (!nullToAbsent || baselineQuality != null) {
      map['baseline_quality'] = Variable<int>(baselineQuality);
    }
    map['is_calibrated'] = Variable<bool>(isCalibrated);
    if (!nullToAbsent || calibrationStatus != null) {
      map['calibration_status'] = Variable<String>(calibrationStatus);
    }
    if (!nullToAbsent || calibrationErrorBpm != null) {
      map['calibration_error_bpm'] = Variable<double>(calibrationErrorBpm);
    }
    if (!nullToAbsent || calibrationCorrelation != null) {
      map['calibration_correlation'] = Variable<double>(calibrationCorrelation);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || surgeryStartedAt != null) {
      map['surgery_started_at'] = Variable<DateTime>(surgeryStartedAt);
    }
    if (!nullToAbsent || surgeryEndedAt != null) {
      map['surgery_ended_at'] = Variable<DateTime>(surgeryEndedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || collarPhotoPath != null) {
      map['collar_photo_path'] = Variable<String>(collarPhotoPath);
    }
    if (!nullToAbsent || initialPosition != null) {
      map['initial_position'] = Variable<String>(initialPosition);
    }
    if (!nullToAbsent || initialAnxiety != null) {
      map['initial_anxiety'] = Variable<String>(initialAnxiety);
    }
    if (!nullToAbsent || initialNotes != null) {
      map['initial_notes'] = Variable<String>(initialNotes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalSessionsCompanion toCompanion(bool nullToAbsent) {
    return LocalSessionsCompanion(
      id: Value(id),
      sessionCode: Value(sessionCode),
      animalId: Value(animalId),
      collarId: Value(collarId),
      observerId: Value(observerId),
      clinicId: Value(clinicId),
      currentPhase: Value(currentPhase),
      surgeryType: surgeryType == null && nullToAbsent
          ? const Value.absent()
          : Value(surgeryType),
      surgeryReason: surgeryReason == null && nullToAbsent
          ? const Value.absent()
          : Value(surgeryReason),
      asaStatus: asaStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(asaStatus),
      baselineDataJson: baselineDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(baselineDataJson),
      baselineQuality: baselineQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(baselineQuality),
      isCalibrated: Value(isCalibrated),
      calibrationStatus: calibrationStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(calibrationStatus),
      calibrationErrorBpm: calibrationErrorBpm == null && nullToAbsent
          ? const Value.absent()
          : Value(calibrationErrorBpm),
      calibrationCorrelation: calibrationCorrelation == null && nullToAbsent
          ? const Value.absent()
          : Value(calibrationCorrelation),
      startedAt: Value(startedAt),
      surgeryStartedAt: surgeryStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(surgeryStartedAt),
      surgeryEndedAt: surgeryEndedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(surgeryEndedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      collarPhotoPath: collarPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(collarPhotoPath),
      initialPosition: initialPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(initialPosition),
      initialAnxiety: initialAnxiety == null && nullToAbsent
          ? const Value.absent()
          : Value(initialAnxiety),
      initialNotes: initialNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(initialNotes),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSession(
      id: serializer.fromJson<String>(json['id']),
      sessionCode: serializer.fromJson<String>(json['sessionCode']),
      animalId: serializer.fromJson<String>(json['animalId']),
      collarId: serializer.fromJson<String>(json['collarId']),
      observerId: serializer.fromJson<String>(json['observerId']),
      clinicId: serializer.fromJson<String>(json['clinicId']),
      currentPhase: serializer.fromJson<String>(json['currentPhase']),
      surgeryType: serializer.fromJson<String?>(json['surgeryType']),
      surgeryReason: serializer.fromJson<String?>(json['surgeryReason']),
      asaStatus: serializer.fromJson<String?>(json['asaStatus']),
      baselineDataJson: serializer.fromJson<String?>(json['baselineDataJson']),
      baselineQuality: serializer.fromJson<int?>(json['baselineQuality']),
      isCalibrated: serializer.fromJson<bool>(json['isCalibrated']),
      calibrationStatus: serializer.fromJson<String?>(
        json['calibrationStatus'],
      ),
      calibrationErrorBpm: serializer.fromJson<double?>(
        json['calibrationErrorBpm'],
      ),
      calibrationCorrelation: serializer.fromJson<double?>(
        json['calibrationCorrelation'],
      ),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      surgeryStartedAt: serializer.fromJson<DateTime?>(
        json['surgeryStartedAt'],
      ),
      surgeryEndedAt: serializer.fromJson<DateTime?>(json['surgeryEndedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      collarPhotoPath: serializer.fromJson<String?>(json['collarPhotoPath']),
      initialPosition: serializer.fromJson<String?>(json['initialPosition']),
      initialAnxiety: serializer.fromJson<String?>(json['initialAnxiety']),
      initialNotes: serializer.fromJson<String?>(json['initialNotes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionCode': serializer.toJson<String>(sessionCode),
      'animalId': serializer.toJson<String>(animalId),
      'collarId': serializer.toJson<String>(collarId),
      'observerId': serializer.toJson<String>(observerId),
      'clinicId': serializer.toJson<String>(clinicId),
      'currentPhase': serializer.toJson<String>(currentPhase),
      'surgeryType': serializer.toJson<String?>(surgeryType),
      'surgeryReason': serializer.toJson<String?>(surgeryReason),
      'asaStatus': serializer.toJson<String?>(asaStatus),
      'baselineDataJson': serializer.toJson<String?>(baselineDataJson),
      'baselineQuality': serializer.toJson<int?>(baselineQuality),
      'isCalibrated': serializer.toJson<bool>(isCalibrated),
      'calibrationStatus': serializer.toJson<String?>(calibrationStatus),
      'calibrationErrorBpm': serializer.toJson<double?>(calibrationErrorBpm),
      'calibrationCorrelation': serializer.toJson<double?>(
        calibrationCorrelation,
      ),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'surgeryStartedAt': serializer.toJson<DateTime?>(surgeryStartedAt),
      'surgeryEndedAt': serializer.toJson<DateTime?>(surgeryEndedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'collarPhotoPath': serializer.toJson<String?>(collarPhotoPath),
      'initialPosition': serializer.toJson<String?>(initialPosition),
      'initialAnxiety': serializer.toJson<String?>(initialAnxiety),
      'initialNotes': serializer.toJson<String?>(initialNotes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalSession copyWith({
    String? id,
    String? sessionCode,
    String? animalId,
    String? collarId,
    String? observerId,
    String? clinicId,
    String? currentPhase,
    Value<String?> surgeryType = const Value.absent(),
    Value<String?> surgeryReason = const Value.absent(),
    Value<String?> asaStatus = const Value.absent(),
    Value<String?> baselineDataJson = const Value.absent(),
    Value<int?> baselineQuality = const Value.absent(),
    bool? isCalibrated,
    Value<String?> calibrationStatus = const Value.absent(),
    Value<double?> calibrationErrorBpm = const Value.absent(),
    Value<double?> calibrationCorrelation = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> surgeryStartedAt = const Value.absent(),
    Value<DateTime?> surgeryEndedAt = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
    Value<String?> collarPhotoPath = const Value.absent(),
    Value<String?> initialPosition = const Value.absent(),
    Value<String?> initialAnxiety = const Value.absent(),
    Value<String?> initialNotes = const Value.absent(),
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalSession(
    id: id ?? this.id,
    sessionCode: sessionCode ?? this.sessionCode,
    animalId: animalId ?? this.animalId,
    collarId: collarId ?? this.collarId,
    observerId: observerId ?? this.observerId,
    clinicId: clinicId ?? this.clinicId,
    currentPhase: currentPhase ?? this.currentPhase,
    surgeryType: surgeryType.present ? surgeryType.value : this.surgeryType,
    surgeryReason: surgeryReason.present
        ? surgeryReason.value
        : this.surgeryReason,
    asaStatus: asaStatus.present ? asaStatus.value : this.asaStatus,
    baselineDataJson: baselineDataJson.present
        ? baselineDataJson.value
        : this.baselineDataJson,
    baselineQuality: baselineQuality.present
        ? baselineQuality.value
        : this.baselineQuality,
    isCalibrated: isCalibrated ?? this.isCalibrated,
    calibrationStatus: calibrationStatus.present
        ? calibrationStatus.value
        : this.calibrationStatus,
    calibrationErrorBpm: calibrationErrorBpm.present
        ? calibrationErrorBpm.value
        : this.calibrationErrorBpm,
    calibrationCorrelation: calibrationCorrelation.present
        ? calibrationCorrelation.value
        : this.calibrationCorrelation,
    startedAt: startedAt ?? this.startedAt,
    surgeryStartedAt: surgeryStartedAt.present
        ? surgeryStartedAt.value
        : this.surgeryStartedAt,
    surgeryEndedAt: surgeryEndedAt.present
        ? surgeryEndedAt.value
        : this.surgeryEndedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    collarPhotoPath: collarPhotoPath.present
        ? collarPhotoPath.value
        : this.collarPhotoPath,
    initialPosition: initialPosition.present
        ? initialPosition.value
        : this.initialPosition,
    initialAnxiety: initialAnxiety.present
        ? initialAnxiety.value
        : this.initialAnxiety,
    initialNotes: initialNotes.present ? initialNotes.value : this.initialNotes,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalSession copyWithCompanion(LocalSessionsCompanion data) {
    return LocalSession(
      id: data.id.present ? data.id.value : this.id,
      sessionCode: data.sessionCode.present
          ? data.sessionCode.value
          : this.sessionCode,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      collarId: data.collarId.present ? data.collarId.value : this.collarId,
      observerId: data.observerId.present
          ? data.observerId.value
          : this.observerId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      currentPhase: data.currentPhase.present
          ? data.currentPhase.value
          : this.currentPhase,
      surgeryType: data.surgeryType.present
          ? data.surgeryType.value
          : this.surgeryType,
      surgeryReason: data.surgeryReason.present
          ? data.surgeryReason.value
          : this.surgeryReason,
      asaStatus: data.asaStatus.present ? data.asaStatus.value : this.asaStatus,
      baselineDataJson: data.baselineDataJson.present
          ? data.baselineDataJson.value
          : this.baselineDataJson,
      baselineQuality: data.baselineQuality.present
          ? data.baselineQuality.value
          : this.baselineQuality,
      isCalibrated: data.isCalibrated.present
          ? data.isCalibrated.value
          : this.isCalibrated,
      calibrationStatus: data.calibrationStatus.present
          ? data.calibrationStatus.value
          : this.calibrationStatus,
      calibrationErrorBpm: data.calibrationErrorBpm.present
          ? data.calibrationErrorBpm.value
          : this.calibrationErrorBpm,
      calibrationCorrelation: data.calibrationCorrelation.present
          ? data.calibrationCorrelation.value
          : this.calibrationCorrelation,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      surgeryStartedAt: data.surgeryStartedAt.present
          ? data.surgeryStartedAt.value
          : this.surgeryStartedAt,
      surgeryEndedAt: data.surgeryEndedAt.present
          ? data.surgeryEndedAt.value
          : this.surgeryEndedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      collarPhotoPath: data.collarPhotoPath.present
          ? data.collarPhotoPath.value
          : this.collarPhotoPath,
      initialPosition: data.initialPosition.present
          ? data.initialPosition.value
          : this.initialPosition,
      initialAnxiety: data.initialAnxiety.present
          ? data.initialAnxiety.value
          : this.initialAnxiety,
      initialNotes: data.initialNotes.present
          ? data.initialNotes.value
          : this.initialNotes,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSession(')
          ..write('id: $id, ')
          ..write('sessionCode: $sessionCode, ')
          ..write('animalId: $animalId, ')
          ..write('collarId: $collarId, ')
          ..write('observerId: $observerId, ')
          ..write('clinicId: $clinicId, ')
          ..write('currentPhase: $currentPhase, ')
          ..write('surgeryType: $surgeryType, ')
          ..write('surgeryReason: $surgeryReason, ')
          ..write('asaStatus: $asaStatus, ')
          ..write('baselineDataJson: $baselineDataJson, ')
          ..write('baselineQuality: $baselineQuality, ')
          ..write('isCalibrated: $isCalibrated, ')
          ..write('calibrationStatus: $calibrationStatus, ')
          ..write('calibrationErrorBpm: $calibrationErrorBpm, ')
          ..write('calibrationCorrelation: $calibrationCorrelation, ')
          ..write('startedAt: $startedAt, ')
          ..write('surgeryStartedAt: $surgeryStartedAt, ')
          ..write('surgeryEndedAt: $surgeryEndedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('collarPhotoPath: $collarPhotoPath, ')
          ..write('initialPosition: $initialPosition, ')
          ..write('initialAnxiety: $initialAnxiety, ')
          ..write('initialNotes: $initialNotes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sessionCode,
    animalId,
    collarId,
    observerId,
    clinicId,
    currentPhase,
    surgeryType,
    surgeryReason,
    asaStatus,
    baselineDataJson,
    baselineQuality,
    isCalibrated,
    calibrationStatus,
    calibrationErrorBpm,
    calibrationCorrelation,
    startedAt,
    surgeryStartedAt,
    surgeryEndedAt,
    endedAt,
    collarPhotoPath,
    initialPosition,
    initialAnxiety,
    initialNotes,
    syncStatus,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSession &&
          other.id == this.id &&
          other.sessionCode == this.sessionCode &&
          other.animalId == this.animalId &&
          other.collarId == this.collarId &&
          other.observerId == this.observerId &&
          other.clinicId == this.clinicId &&
          other.currentPhase == this.currentPhase &&
          other.surgeryType == this.surgeryType &&
          other.surgeryReason == this.surgeryReason &&
          other.asaStatus == this.asaStatus &&
          other.baselineDataJson == this.baselineDataJson &&
          other.baselineQuality == this.baselineQuality &&
          other.isCalibrated == this.isCalibrated &&
          other.calibrationStatus == this.calibrationStatus &&
          other.calibrationErrorBpm == this.calibrationErrorBpm &&
          other.calibrationCorrelation == this.calibrationCorrelation &&
          other.startedAt == this.startedAt &&
          other.surgeryStartedAt == this.surgeryStartedAt &&
          other.surgeryEndedAt == this.surgeryEndedAt &&
          other.endedAt == this.endedAt &&
          other.collarPhotoPath == this.collarPhotoPath &&
          other.initialPosition == this.initialPosition &&
          other.initialAnxiety == this.initialAnxiety &&
          other.initialNotes == this.initialNotes &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalSessionsCompanion extends UpdateCompanion<LocalSession> {
  final Value<String> id;
  final Value<String> sessionCode;
  final Value<String> animalId;
  final Value<String> collarId;
  final Value<String> observerId;
  final Value<String> clinicId;
  final Value<String> currentPhase;
  final Value<String?> surgeryType;
  final Value<String?> surgeryReason;
  final Value<String?> asaStatus;
  final Value<String?> baselineDataJson;
  final Value<int?> baselineQuality;
  final Value<bool> isCalibrated;
  final Value<String?> calibrationStatus;
  final Value<double?> calibrationErrorBpm;
  final Value<double?> calibrationCorrelation;
  final Value<DateTime> startedAt;
  final Value<DateTime?> surgeryStartedAt;
  final Value<DateTime?> surgeryEndedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> collarPhotoPath;
  final Value<String?> initialPosition;
  final Value<String?> initialAnxiety;
  final Value<String?> initialNotes;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalSessionsCompanion({
    this.id = const Value.absent(),
    this.sessionCode = const Value.absent(),
    this.animalId = const Value.absent(),
    this.collarId = const Value.absent(),
    this.observerId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.currentPhase = const Value.absent(),
    this.surgeryType = const Value.absent(),
    this.surgeryReason = const Value.absent(),
    this.asaStatus = const Value.absent(),
    this.baselineDataJson = const Value.absent(),
    this.baselineQuality = const Value.absent(),
    this.isCalibrated = const Value.absent(),
    this.calibrationStatus = const Value.absent(),
    this.calibrationErrorBpm = const Value.absent(),
    this.calibrationCorrelation = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.surgeryStartedAt = const Value.absent(),
    this.surgeryEndedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.collarPhotoPath = const Value.absent(),
    this.initialPosition = const Value.absent(),
    this.initialAnxiety = const Value.absent(),
    this.initialNotes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSessionsCompanion.insert({
    required String id,
    required String sessionCode,
    required String animalId,
    required String collarId,
    required String observerId,
    required String clinicId,
    required String currentPhase,
    this.surgeryType = const Value.absent(),
    this.surgeryReason = const Value.absent(),
    this.asaStatus = const Value.absent(),
    this.baselineDataJson = const Value.absent(),
    this.baselineQuality = const Value.absent(),
    this.isCalibrated = const Value.absent(),
    this.calibrationStatus = const Value.absent(),
    this.calibrationErrorBpm = const Value.absent(),
    this.calibrationCorrelation = const Value.absent(),
    required DateTime startedAt,
    this.surgeryStartedAt = const Value.absent(),
    this.surgeryEndedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.collarPhotoPath = const Value.absent(),
    this.initialPosition = const Value.absent(),
    this.initialAnxiety = const Value.absent(),
    this.initialNotes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionCode = Value(sessionCode),
       animalId = Value(animalId),
       collarId = Value(collarId),
       observerId = Value(observerId),
       clinicId = Value(clinicId),
       currentPhase = Value(currentPhase),
       startedAt = Value(startedAt);
  static Insertable<LocalSession> custom({
    Expression<String>? id,
    Expression<String>? sessionCode,
    Expression<String>? animalId,
    Expression<String>? collarId,
    Expression<String>? observerId,
    Expression<String>? clinicId,
    Expression<String>? currentPhase,
    Expression<String>? surgeryType,
    Expression<String>? surgeryReason,
    Expression<String>? asaStatus,
    Expression<String>? baselineDataJson,
    Expression<int>? baselineQuality,
    Expression<bool>? isCalibrated,
    Expression<String>? calibrationStatus,
    Expression<double>? calibrationErrorBpm,
    Expression<double>? calibrationCorrelation,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? surgeryStartedAt,
    Expression<DateTime>? surgeryEndedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? collarPhotoPath,
    Expression<String>? initialPosition,
    Expression<String>? initialAnxiety,
    Expression<String>? initialNotes,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionCode != null) 'session_code': sessionCode,
      if (animalId != null) 'animal_id': animalId,
      if (collarId != null) 'collar_id': collarId,
      if (observerId != null) 'observer_id': observerId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (currentPhase != null) 'current_phase': currentPhase,
      if (surgeryType != null) 'surgery_type': surgeryType,
      if (surgeryReason != null) 'surgery_reason': surgeryReason,
      if (asaStatus != null) 'asa_status': asaStatus,
      if (baselineDataJson != null) 'baseline_data_json': baselineDataJson,
      if (baselineQuality != null) 'baseline_quality': baselineQuality,
      if (isCalibrated != null) 'is_calibrated': isCalibrated,
      if (calibrationStatus != null) 'calibration_status': calibrationStatus,
      if (calibrationErrorBpm != null)
        'calibration_error_bpm': calibrationErrorBpm,
      if (calibrationCorrelation != null)
        'calibration_correlation': calibrationCorrelation,
      if (startedAt != null) 'started_at': startedAt,
      if (surgeryStartedAt != null) 'surgery_started_at': surgeryStartedAt,
      if (surgeryEndedAt != null) 'surgery_ended_at': surgeryEndedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (collarPhotoPath != null) 'collar_photo_path': collarPhotoPath,
      if (initialPosition != null) 'initial_position': initialPosition,
      if (initialAnxiety != null) 'initial_anxiety': initialAnxiety,
      if (initialNotes != null) 'initial_notes': initialNotes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionCode,
    Value<String>? animalId,
    Value<String>? collarId,
    Value<String>? observerId,
    Value<String>? clinicId,
    Value<String>? currentPhase,
    Value<String?>? surgeryType,
    Value<String?>? surgeryReason,
    Value<String?>? asaStatus,
    Value<String?>? baselineDataJson,
    Value<int?>? baselineQuality,
    Value<bool>? isCalibrated,
    Value<String?>? calibrationStatus,
    Value<double?>? calibrationErrorBpm,
    Value<double?>? calibrationCorrelation,
    Value<DateTime>? startedAt,
    Value<DateTime?>? surgeryStartedAt,
    Value<DateTime?>? surgeryEndedAt,
    Value<DateTime?>? endedAt,
    Value<String?>? collarPhotoPath,
    Value<String?>? initialPosition,
    Value<String?>? initialAnxiety,
    Value<String?>? initialNotes,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalSessionsCompanion(
      id: id ?? this.id,
      sessionCode: sessionCode ?? this.sessionCode,
      animalId: animalId ?? this.animalId,
      collarId: collarId ?? this.collarId,
      observerId: observerId ?? this.observerId,
      clinicId: clinicId ?? this.clinicId,
      currentPhase: currentPhase ?? this.currentPhase,
      surgeryType: surgeryType ?? this.surgeryType,
      surgeryReason: surgeryReason ?? this.surgeryReason,
      asaStatus: asaStatus ?? this.asaStatus,
      baselineDataJson: baselineDataJson ?? this.baselineDataJson,
      baselineQuality: baselineQuality ?? this.baselineQuality,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      calibrationStatus: calibrationStatus ?? this.calibrationStatus,
      calibrationErrorBpm: calibrationErrorBpm ?? this.calibrationErrorBpm,
      calibrationCorrelation:
          calibrationCorrelation ?? this.calibrationCorrelation,
      startedAt: startedAt ?? this.startedAt,
      surgeryStartedAt: surgeryStartedAt ?? this.surgeryStartedAt,
      surgeryEndedAt: surgeryEndedAt ?? this.surgeryEndedAt,
      endedAt: endedAt ?? this.endedAt,
      collarPhotoPath: collarPhotoPath ?? this.collarPhotoPath,
      initialPosition: initialPosition ?? this.initialPosition,
      initialAnxiety: initialAnxiety ?? this.initialAnxiety,
      initialNotes: initialNotes ?? this.initialNotes,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
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
    if (sessionCode.present) {
      map['session_code'] = Variable<String>(sessionCode.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (collarId.present) {
      map['collar_id'] = Variable<String>(collarId.value);
    }
    if (observerId.present) {
      map['observer_id'] = Variable<String>(observerId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (currentPhase.present) {
      map['current_phase'] = Variable<String>(currentPhase.value);
    }
    if (surgeryType.present) {
      map['surgery_type'] = Variable<String>(surgeryType.value);
    }
    if (surgeryReason.present) {
      map['surgery_reason'] = Variable<String>(surgeryReason.value);
    }
    if (asaStatus.present) {
      map['asa_status'] = Variable<String>(asaStatus.value);
    }
    if (baselineDataJson.present) {
      map['baseline_data_json'] = Variable<String>(baselineDataJson.value);
    }
    if (baselineQuality.present) {
      map['baseline_quality'] = Variable<int>(baselineQuality.value);
    }
    if (isCalibrated.present) {
      map['is_calibrated'] = Variable<bool>(isCalibrated.value);
    }
    if (calibrationStatus.present) {
      map['calibration_status'] = Variable<String>(calibrationStatus.value);
    }
    if (calibrationErrorBpm.present) {
      map['calibration_error_bpm'] = Variable<double>(
        calibrationErrorBpm.value,
      );
    }
    if (calibrationCorrelation.present) {
      map['calibration_correlation'] = Variable<double>(
        calibrationCorrelation.value,
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (surgeryStartedAt.present) {
      map['surgery_started_at'] = Variable<DateTime>(surgeryStartedAt.value);
    }
    if (surgeryEndedAt.present) {
      map['surgery_ended_at'] = Variable<DateTime>(surgeryEndedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (collarPhotoPath.present) {
      map['collar_photo_path'] = Variable<String>(collarPhotoPath.value);
    }
    if (initialPosition.present) {
      map['initial_position'] = Variable<String>(initialPosition.value);
    }
    if (initialAnxiety.present) {
      map['initial_anxiety'] = Variable<String>(initialAnxiety.value);
    }
    if (initialNotes.present) {
      map['initial_notes'] = Variable<String>(initialNotes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('LocalSessionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionCode: $sessionCode, ')
          ..write('animalId: $animalId, ')
          ..write('collarId: $collarId, ')
          ..write('observerId: $observerId, ')
          ..write('clinicId: $clinicId, ')
          ..write('currentPhase: $currentPhase, ')
          ..write('surgeryType: $surgeryType, ')
          ..write('surgeryReason: $surgeryReason, ')
          ..write('asaStatus: $asaStatus, ')
          ..write('baselineDataJson: $baselineDataJson, ')
          ..write('baselineQuality: $baselineQuality, ')
          ..write('isCalibrated: $isCalibrated, ')
          ..write('calibrationStatus: $calibrationStatus, ')
          ..write('calibrationErrorBpm: $calibrationErrorBpm, ')
          ..write('calibrationCorrelation: $calibrationCorrelation, ')
          ..write('startedAt: $startedAt, ')
          ..write('surgeryStartedAt: $surgeryStartedAt, ')
          ..write('surgeryEndedAt: $surgeryEndedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('collarPhotoPath: $collarPhotoPath, ')
          ..write('initialPosition: $initialPosition, ')
          ..write('initialAnxiety: $initialAnxiety, ')
          ..write('initialNotes: $initialNotes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAnnotationsTable extends LocalAnnotations
    with TableInfo<$LocalAnnotationsTable, LocalAnnotation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnnotationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampUtcMeta = const VerificationMeta(
    'timestampUtc',
  );
  @override
  late final GeneratedColumn<DateTime> timestampUtc = GeneratedColumn<DateTime>(
    'timestamp_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('info'),
  );
  static const VerificationMeta _structuredDataJsonMeta =
      const VerificationMeta('structuredDataJson');
  @override
  late final GeneratedColumn<String> structuredDataJson =
      GeneratedColumn<String>(
        'structured_data_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _voiceNotePathMeta = const VerificationMeta(
    'voiceNotePath',
  );
  @override
  late final GeneratedColumn<String> voiceNotePath = GeneratedColumn<String>(
    'voice_note_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voiceTranscriptionMeta =
      const VerificationMeta('voiceTranscription');
  @override
  late final GeneratedColumn<String> voiceTranscription =
      GeneratedColumn<String>(
        'voice_transcription',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _annotatorUserIdMeta = const VerificationMeta(
    'annotatorUserId',
  );
  @override
  late final GeneratedColumn<String> annotatorUserId = GeneratedColumn<String>(
    'annotator_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAutoGeneratedMeta = const VerificationMeta(
    'isAutoGenerated',
  );
  @override
  late final GeneratedColumn<bool> isAutoGenerated = GeneratedColumn<bool>(
    'is_auto_generated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_auto_generated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    timestampUtc,
    elapsedMs,
    phase,
    category,
    type,
    description,
    severity,
    structuredDataJson,
    voiceNotePath,
    voiceTranscription,
    annotatorUserId,
    isAutoGenerated,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_annotations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAnnotation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('timestamp_utc')) {
      context.handle(
        _timestampUtcMeta,
        timestampUtc.isAcceptableOrUnknown(
          data['timestamp_utc']!,
          _timestampUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampUtcMeta);
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_elapsedMsMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('structured_data_json')) {
      context.handle(
        _structuredDataJsonMeta,
        structuredDataJson.isAcceptableOrUnknown(
          data['structured_data_json']!,
          _structuredDataJsonMeta,
        ),
      );
    }
    if (data.containsKey('voice_note_path')) {
      context.handle(
        _voiceNotePathMeta,
        voiceNotePath.isAcceptableOrUnknown(
          data['voice_note_path']!,
          _voiceNotePathMeta,
        ),
      );
    }
    if (data.containsKey('voice_transcription')) {
      context.handle(
        _voiceTranscriptionMeta,
        voiceTranscription.isAcceptableOrUnknown(
          data['voice_transcription']!,
          _voiceTranscriptionMeta,
        ),
      );
    }
    if (data.containsKey('annotator_user_id')) {
      context.handle(
        _annotatorUserIdMeta,
        annotatorUserId.isAcceptableOrUnknown(
          data['annotator_user_id']!,
          _annotatorUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_annotatorUserIdMeta);
    }
    if (data.containsKey('is_auto_generated')) {
      context.handle(
        _isAutoGeneratedMeta,
        isAutoGenerated.isAcceptableOrUnknown(
          data['is_auto_generated']!,
          _isAutoGeneratedMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAnnotation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnnotation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      timestampUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp_utc'],
      )!,
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      structuredDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}structured_data_json'],
      ),
      voiceNotePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_note_path'],
      ),
      voiceTranscription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_transcription'],
      ),
      annotatorUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}annotator_user_id'],
      )!,
      isAutoGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_auto_generated'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalAnnotationsTable createAlias(String alias) {
    return $LocalAnnotationsTable(attachedDatabase, alias);
  }
}

class LocalAnnotation extends DataClass implements Insertable<LocalAnnotation> {
  final String id;
  final String sessionId;
  final DateTime timestampUtc;
  final int elapsedMs;
  final String phase;
  final String category;
  final String type;
  final String? description;
  final String severity;
  final String? structuredDataJson;
  final String? voiceNotePath;
  final String? voiceTranscription;
  final String annotatorUserId;
  final bool isAutoGenerated;
  final String syncStatus;
  final DateTime createdAt;
  const LocalAnnotation({
    required this.id,
    required this.sessionId,
    required this.timestampUtc,
    required this.elapsedMs,
    required this.phase,
    required this.category,
    required this.type,
    this.description,
    required this.severity,
    this.structuredDataJson,
    this.voiceNotePath,
    this.voiceTranscription,
    required this.annotatorUserId,
    required this.isAutoGenerated,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['timestamp_utc'] = Variable<DateTime>(timestampUtc);
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    map['phase'] = Variable<String>(phase);
    map['category'] = Variable<String>(category);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['severity'] = Variable<String>(severity);
    if (!nullToAbsent || structuredDataJson != null) {
      map['structured_data_json'] = Variable<String>(structuredDataJson);
    }
    if (!nullToAbsent || voiceNotePath != null) {
      map['voice_note_path'] = Variable<String>(voiceNotePath);
    }
    if (!nullToAbsent || voiceTranscription != null) {
      map['voice_transcription'] = Variable<String>(voiceTranscription);
    }
    map['annotator_user_id'] = Variable<String>(annotatorUserId);
    map['is_auto_generated'] = Variable<bool>(isAutoGenerated);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalAnnotationsCompanion toCompanion(bool nullToAbsent) {
    return LocalAnnotationsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      timestampUtc: Value(timestampUtc),
      elapsedMs: Value(elapsedMs),
      phase: Value(phase),
      category: Value(category),
      type: Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      severity: Value(severity),
      structuredDataJson: structuredDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(structuredDataJson),
      voiceNotePath: voiceNotePath == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceNotePath),
      voiceTranscription: voiceTranscription == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceTranscription),
      annotatorUserId: Value(annotatorUserId),
      isAutoGenerated: Value(isAutoGenerated),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory LocalAnnotation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnnotation(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      timestampUtc: serializer.fromJson<DateTime>(json['timestampUtc']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      phase: serializer.fromJson<String>(json['phase']),
      category: serializer.fromJson<String>(json['category']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String?>(json['description']),
      severity: serializer.fromJson<String>(json['severity']),
      structuredDataJson: serializer.fromJson<String?>(
        json['structuredDataJson'],
      ),
      voiceNotePath: serializer.fromJson<String?>(json['voiceNotePath']),
      voiceTranscription: serializer.fromJson<String?>(
        json['voiceTranscription'],
      ),
      annotatorUserId: serializer.fromJson<String>(json['annotatorUserId']),
      isAutoGenerated: serializer.fromJson<bool>(json['isAutoGenerated']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'timestampUtc': serializer.toJson<DateTime>(timestampUtc),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'phase': serializer.toJson<String>(phase),
      'category': serializer.toJson<String>(category),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String?>(description),
      'severity': serializer.toJson<String>(severity),
      'structuredDataJson': serializer.toJson<String?>(structuredDataJson),
      'voiceNotePath': serializer.toJson<String?>(voiceNotePath),
      'voiceTranscription': serializer.toJson<String?>(voiceTranscription),
      'annotatorUserId': serializer.toJson<String>(annotatorUserId),
      'isAutoGenerated': serializer.toJson<bool>(isAutoGenerated),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalAnnotation copyWith({
    String? id,
    String? sessionId,
    DateTime? timestampUtc,
    int? elapsedMs,
    String? phase,
    String? category,
    String? type,
    Value<String?> description = const Value.absent(),
    String? severity,
    Value<String?> structuredDataJson = const Value.absent(),
    Value<String?> voiceNotePath = const Value.absent(),
    Value<String?> voiceTranscription = const Value.absent(),
    String? annotatorUserId,
    bool? isAutoGenerated,
    String? syncStatus,
    DateTime? createdAt,
  }) => LocalAnnotation(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    timestampUtc: timestampUtc ?? this.timestampUtc,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    phase: phase ?? this.phase,
    category: category ?? this.category,
    type: type ?? this.type,
    description: description.present ? description.value : this.description,
    severity: severity ?? this.severity,
    structuredDataJson: structuredDataJson.present
        ? structuredDataJson.value
        : this.structuredDataJson,
    voiceNotePath: voiceNotePath.present
        ? voiceNotePath.value
        : this.voiceNotePath,
    voiceTranscription: voiceTranscription.present
        ? voiceTranscription.value
        : this.voiceTranscription,
    annotatorUserId: annotatorUserId ?? this.annotatorUserId,
    isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalAnnotation copyWithCompanion(LocalAnnotationsCompanion data) {
    return LocalAnnotation(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      timestampUtc: data.timestampUtc.present
          ? data.timestampUtc.value
          : this.timestampUtc,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      phase: data.phase.present ? data.phase.value : this.phase,
      category: data.category.present ? data.category.value : this.category,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      severity: data.severity.present ? data.severity.value : this.severity,
      structuredDataJson: data.structuredDataJson.present
          ? data.structuredDataJson.value
          : this.structuredDataJson,
      voiceNotePath: data.voiceNotePath.present
          ? data.voiceNotePath.value
          : this.voiceNotePath,
      voiceTranscription: data.voiceTranscription.present
          ? data.voiceTranscription.value
          : this.voiceTranscription,
      annotatorUserId: data.annotatorUserId.present
          ? data.annotatorUserId.value
          : this.annotatorUserId,
      isAutoGenerated: data.isAutoGenerated.present
          ? data.isAutoGenerated.value
          : this.isAutoGenerated,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnnotation(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('phase: $phase, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('severity: $severity, ')
          ..write('structuredDataJson: $structuredDataJson, ')
          ..write('voiceNotePath: $voiceNotePath, ')
          ..write('voiceTranscription: $voiceTranscription, ')
          ..write('annotatorUserId: $annotatorUserId, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    timestampUtc,
    elapsedMs,
    phase,
    category,
    type,
    description,
    severity,
    structuredDataJson,
    voiceNotePath,
    voiceTranscription,
    annotatorUserId,
    isAutoGenerated,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnnotation &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.timestampUtc == this.timestampUtc &&
          other.elapsedMs == this.elapsedMs &&
          other.phase == this.phase &&
          other.category == this.category &&
          other.type == this.type &&
          other.description == this.description &&
          other.severity == this.severity &&
          other.structuredDataJson == this.structuredDataJson &&
          other.voiceNotePath == this.voiceNotePath &&
          other.voiceTranscription == this.voiceTranscription &&
          other.annotatorUserId == this.annotatorUserId &&
          other.isAutoGenerated == this.isAutoGenerated &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class LocalAnnotationsCompanion extends UpdateCompanion<LocalAnnotation> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<DateTime> timestampUtc;
  final Value<int> elapsedMs;
  final Value<String> phase;
  final Value<String> category;
  final Value<String> type;
  final Value<String?> description;
  final Value<String> severity;
  final Value<String?> structuredDataJson;
  final Value<String?> voiceNotePath;
  final Value<String?> voiceTranscription;
  final Value<String> annotatorUserId;
  final Value<bool> isAutoGenerated;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalAnnotationsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.timestampUtc = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.phase = const Value.absent(),
    this.category = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.severity = const Value.absent(),
    this.structuredDataJson = const Value.absent(),
    this.voiceNotePath = const Value.absent(),
    this.voiceTranscription = const Value.absent(),
    this.annotatorUserId = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAnnotationsCompanion.insert({
    required String id,
    required String sessionId,
    required DateTime timestampUtc,
    required int elapsedMs,
    required String phase,
    required String category,
    required String type,
    this.description = const Value.absent(),
    this.severity = const Value.absent(),
    this.structuredDataJson = const Value.absent(),
    this.voiceNotePath = const Value.absent(),
    this.voiceTranscription = const Value.absent(),
    required String annotatorUserId,
    this.isAutoGenerated = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       timestampUtc = Value(timestampUtc),
       elapsedMs = Value(elapsedMs),
       phase = Value(phase),
       category = Value(category),
       type = Value(type),
       annotatorUserId = Value(annotatorUserId);
  static Insertable<LocalAnnotation> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<DateTime>? timestampUtc,
    Expression<int>? elapsedMs,
    Expression<String>? phase,
    Expression<String>? category,
    Expression<String>? type,
    Expression<String>? description,
    Expression<String>? severity,
    Expression<String>? structuredDataJson,
    Expression<String>? voiceNotePath,
    Expression<String>? voiceTranscription,
    Expression<String>? annotatorUserId,
    Expression<bool>? isAutoGenerated,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (timestampUtc != null) 'timestamp_utc': timestampUtc,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (phase != null) 'phase': phase,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (severity != null) 'severity': severity,
      if (structuredDataJson != null)
        'structured_data_json': structuredDataJson,
      if (voiceNotePath != null) 'voice_note_path': voiceNotePath,
      if (voiceTranscription != null) 'voice_transcription': voiceTranscription,
      if (annotatorUserId != null) 'annotator_user_id': annotatorUserId,
      if (isAutoGenerated != null) 'is_auto_generated': isAutoGenerated,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAnnotationsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<DateTime>? timestampUtc,
    Value<int>? elapsedMs,
    Value<String>? phase,
    Value<String>? category,
    Value<String>? type,
    Value<String?>? description,
    Value<String>? severity,
    Value<String?>? structuredDataJson,
    Value<String?>? voiceNotePath,
    Value<String?>? voiceTranscription,
    Value<String>? annotatorUserId,
    Value<bool>? isAutoGenerated,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalAnnotationsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestampUtc: timestampUtc ?? this.timestampUtc,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      phase: phase ?? this.phase,
      category: category ?? this.category,
      type: type ?? this.type,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      structuredDataJson: structuredDataJson ?? this.structuredDataJson,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      voiceTranscription: voiceTranscription ?? this.voiceTranscription,
      annotatorUserId: annotatorUserId ?? this.annotatorUserId,
      isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (timestampUtc.present) {
      map['timestamp_utc'] = Variable<DateTime>(timestampUtc.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (structuredDataJson.present) {
      map['structured_data_json'] = Variable<String>(structuredDataJson.value);
    }
    if (voiceNotePath.present) {
      map['voice_note_path'] = Variable<String>(voiceNotePath.value);
    }
    if (voiceTranscription.present) {
      map['voice_transcription'] = Variable<String>(voiceTranscription.value);
    }
    if (annotatorUserId.present) {
      map['annotator_user_id'] = Variable<String>(annotatorUserId.value);
    }
    if (isAutoGenerated.present) {
      map['is_auto_generated'] = Variable<bool>(isAutoGenerated.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('LocalAnnotationsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('phase: $phase, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('severity: $severity, ')
          ..write('structuredDataJson: $structuredDataJson, ')
          ..write('voiceNotePath: $voiceNotePath, ')
          ..write('voiceTranscription: $voiceTranscription, ')
          ..write('annotatorUserId: $annotatorUserId, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalVitalsTable extends LocalVitals
    with TableInfo<$LocalVitalsTable, LocalVital> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalVitalsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampUtcMeta = const VerificationMeta(
    'timestampUtc',
  );
  @override
  late final GeneratedColumn<DateTime> timestampUtc = GeneratedColumn<DateTime>(
    'timestamp_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heartRateBpmMeta = const VerificationMeta(
    'heartRateBpm',
  );
  @override
  late final GeneratedColumn<int> heartRateBpm = GeneratedColumn<int>(
    'heart_rate_bpm',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respiratoryRateBpmMeta =
      const VerificationMeta('respiratoryRateBpm');
  @override
  late final GeneratedColumn<int> respiratoryRateBpm = GeneratedColumn<int>(
    'respiratory_rate_bpm',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureCMeta = const VerificationMeta(
    'temperatureC',
  );
  @override
  late final GeneratedColumn<double> temperatureC = GeneratedColumn<double>(
    'temperature_c',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signalQualityMeta = const VerificationMeta(
    'signalQuality',
  );
  @override
  late final GeneratedColumn<int> signalQuality = GeneratedColumn<int>(
    'signal_quality',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    timestampUtc,
    heartRateBpm,
    respiratoryRateBpm,
    temperatureC,
    signalQuality,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_vitals';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalVital> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('timestamp_utc')) {
      context.handle(
        _timestampUtcMeta,
        timestampUtc.isAcceptableOrUnknown(
          data['timestamp_utc']!,
          _timestampUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampUtcMeta);
    }
    if (data.containsKey('heart_rate_bpm')) {
      context.handle(
        _heartRateBpmMeta,
        heartRateBpm.isAcceptableOrUnknown(
          data['heart_rate_bpm']!,
          _heartRateBpmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_heartRateBpmMeta);
    }
    if (data.containsKey('respiratory_rate_bpm')) {
      context.handle(
        _respiratoryRateBpmMeta,
        respiratoryRateBpm.isAcceptableOrUnknown(
          data['respiratory_rate_bpm']!,
          _respiratoryRateBpmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_respiratoryRateBpmMeta);
    }
    if (data.containsKey('temperature_c')) {
      context.handle(
        _temperatureCMeta,
        temperatureC.isAcceptableOrUnknown(
          data['temperature_c']!,
          _temperatureCMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureCMeta);
    }
    if (data.containsKey('signal_quality')) {
      context.handle(
        _signalQualityMeta,
        signalQuality.isAcceptableOrUnknown(
          data['signal_quality']!,
          _signalQualityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_signalQualityMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalVital map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalVital(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      timestampUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp_utc'],
      )!,
      heartRateBpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate_bpm'],
      )!,
      respiratoryRateBpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}respiratory_rate_bpm'],
      )!,
      temperatureC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_c'],
      )!,
      signalQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}signal_quality'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalVitalsTable createAlias(String alias) {
    return $LocalVitalsTable(attachedDatabase, alias);
  }
}

class LocalVital extends DataClass implements Insertable<LocalVital> {
  final int id;
  final String sessionId;
  final DateTime timestampUtc;
  final int heartRateBpm;
  final int respiratoryRateBpm;
  final double temperatureC;
  final int signalQuality;
  final String syncStatus;
  final DateTime createdAt;
  const LocalVital({
    required this.id,
    required this.sessionId,
    required this.timestampUtc,
    required this.heartRateBpm,
    required this.respiratoryRateBpm,
    required this.temperatureC,
    required this.signalQuality,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['timestamp_utc'] = Variable<DateTime>(timestampUtc);
    map['heart_rate_bpm'] = Variable<int>(heartRateBpm);
    map['respiratory_rate_bpm'] = Variable<int>(respiratoryRateBpm);
    map['temperature_c'] = Variable<double>(temperatureC);
    map['signal_quality'] = Variable<int>(signalQuality);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalVitalsCompanion toCompanion(bool nullToAbsent) {
    return LocalVitalsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      timestampUtc: Value(timestampUtc),
      heartRateBpm: Value(heartRateBpm),
      respiratoryRateBpm: Value(respiratoryRateBpm),
      temperatureC: Value(temperatureC),
      signalQuality: Value(signalQuality),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory LocalVital.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalVital(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      timestampUtc: serializer.fromJson<DateTime>(json['timestampUtc']),
      heartRateBpm: serializer.fromJson<int>(json['heartRateBpm']),
      respiratoryRateBpm: serializer.fromJson<int>(json['respiratoryRateBpm']),
      temperatureC: serializer.fromJson<double>(json['temperatureC']),
      signalQuality: serializer.fromJson<int>(json['signalQuality']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'timestampUtc': serializer.toJson<DateTime>(timestampUtc),
      'heartRateBpm': serializer.toJson<int>(heartRateBpm),
      'respiratoryRateBpm': serializer.toJson<int>(respiratoryRateBpm),
      'temperatureC': serializer.toJson<double>(temperatureC),
      'signalQuality': serializer.toJson<int>(signalQuality),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalVital copyWith({
    int? id,
    String? sessionId,
    DateTime? timestampUtc,
    int? heartRateBpm,
    int? respiratoryRateBpm,
    double? temperatureC,
    int? signalQuality,
    String? syncStatus,
    DateTime? createdAt,
  }) => LocalVital(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    timestampUtc: timestampUtc ?? this.timestampUtc,
    heartRateBpm: heartRateBpm ?? this.heartRateBpm,
    respiratoryRateBpm: respiratoryRateBpm ?? this.respiratoryRateBpm,
    temperatureC: temperatureC ?? this.temperatureC,
    signalQuality: signalQuality ?? this.signalQuality,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalVital copyWithCompanion(LocalVitalsCompanion data) {
    return LocalVital(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      timestampUtc: data.timestampUtc.present
          ? data.timestampUtc.value
          : this.timestampUtc,
      heartRateBpm: data.heartRateBpm.present
          ? data.heartRateBpm.value
          : this.heartRateBpm,
      respiratoryRateBpm: data.respiratoryRateBpm.present
          ? data.respiratoryRateBpm.value
          : this.respiratoryRateBpm,
      temperatureC: data.temperatureC.present
          ? data.temperatureC.value
          : this.temperatureC,
      signalQuality: data.signalQuality.present
          ? data.signalQuality.value
          : this.signalQuality,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalVital(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('heartRateBpm: $heartRateBpm, ')
          ..write('respiratoryRateBpm: $respiratoryRateBpm, ')
          ..write('temperatureC: $temperatureC, ')
          ..write('signalQuality: $signalQuality, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    timestampUtc,
    heartRateBpm,
    respiratoryRateBpm,
    temperatureC,
    signalQuality,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalVital &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.timestampUtc == this.timestampUtc &&
          other.heartRateBpm == this.heartRateBpm &&
          other.respiratoryRateBpm == this.respiratoryRateBpm &&
          other.temperatureC == this.temperatureC &&
          other.signalQuality == this.signalQuality &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class LocalVitalsCompanion extends UpdateCompanion<LocalVital> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<DateTime> timestampUtc;
  final Value<int> heartRateBpm;
  final Value<int> respiratoryRateBpm;
  final Value<double> temperatureC;
  final Value<int> signalQuality;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  const LocalVitalsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.timestampUtc = const Value.absent(),
    this.heartRateBpm = const Value.absent(),
    this.respiratoryRateBpm = const Value.absent(),
    this.temperatureC = const Value.absent(),
    this.signalQuality = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LocalVitalsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required DateTime timestampUtc,
    required int heartRateBpm,
    required int respiratoryRateBpm,
    required double temperatureC,
    required int signalQuality,
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : sessionId = Value(sessionId),
       timestampUtc = Value(timestampUtc),
       heartRateBpm = Value(heartRateBpm),
       respiratoryRateBpm = Value(respiratoryRateBpm),
       temperatureC = Value(temperatureC),
       signalQuality = Value(signalQuality);
  static Insertable<LocalVital> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<DateTime>? timestampUtc,
    Expression<int>? heartRateBpm,
    Expression<int>? respiratoryRateBpm,
    Expression<double>? temperatureC,
    Expression<int>? signalQuality,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (timestampUtc != null) 'timestamp_utc': timestampUtc,
      if (heartRateBpm != null) 'heart_rate_bpm': heartRateBpm,
      if (respiratoryRateBpm != null)
        'respiratory_rate_bpm': respiratoryRateBpm,
      if (temperatureC != null) 'temperature_c': temperatureC,
      if (signalQuality != null) 'signal_quality': signalQuality,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LocalVitalsCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<DateTime>? timestampUtc,
    Value<int>? heartRateBpm,
    Value<int>? respiratoryRateBpm,
    Value<double>? temperatureC,
    Value<int>? signalQuality,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
  }) {
    return LocalVitalsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestampUtc: timestampUtc ?? this.timestampUtc,
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      respiratoryRateBpm: respiratoryRateBpm ?? this.respiratoryRateBpm,
      temperatureC: temperatureC ?? this.temperatureC,
      signalQuality: signalQuality ?? this.signalQuality,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (timestampUtc.present) {
      map['timestamp_utc'] = Variable<DateTime>(timestampUtc.value);
    }
    if (heartRateBpm.present) {
      map['heart_rate_bpm'] = Variable<int>(heartRateBpm.value);
    }
    if (respiratoryRateBpm.present) {
      map['respiratory_rate_bpm'] = Variable<int>(respiratoryRateBpm.value);
    }
    if (temperatureC.present) {
      map['temperature_c'] = Variable<double>(temperatureC.value);
    }
    if (signalQuality.present) {
      map['signal_quality'] = Variable<int>(signalQuality.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalVitalsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('heartRateBpm: $heartRateBpm, ')
          ..write('respiratoryRateBpm: $respiratoryRateBpm, ')
          ..write('temperatureC: $temperatureC, ')
          ..write('signalQuality: $signalQuality, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    action,
    dataJson,
    priority,
    retryCount,
    lastError,
    createdAt,
    nextRetryAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_dataJsonMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entityType;
  final String entityId;
  final String action;
  final String dataJson;
  final int priority;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? nextRetryAt;
  const SyncQueueData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.dataJson,
    required this.priority,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
    this.nextRetryAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['data_json'] = Variable<String>(dataJson);
    map['priority'] = Variable<int>(priority);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      dataJson: Value(dataJson),
      priority: Value(priority),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      dataJson: serializer.fromJson<String>(json['dataJson']),
      priority: serializer.fromJson<int>(json['priority']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'dataJson': serializer.toJson<String>(dataJson),
      'priority': serializer.toJson<int>(priority),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? entityType,
    String? entityId,
    String? action,
    String? dataJson,
    int? priority,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> nextRetryAt = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    dataJson: dataJson ?? this.dataJson,
    priority: priority ?? this.priority,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      priority: data.priority.present ? data.priority.value : this.priority,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('dataJson: $dataJson, ')
          ..write('priority: $priority, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextRetryAt: $nextRetryAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    action,
    dataJson,
    priority,
    retryCount,
    lastError,
    createdAt,
    nextRetryAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.dataJson == this.dataJson &&
          other.priority == this.priority &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.nextRetryAt == this.nextRetryAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> dataJson;
  final Value<int> priority;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime?> nextRetryAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.priority = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String action,
    required String dataJson,
    this.priority = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       action = Value(action),
       dataJson = Value(dataJson);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? dataJson,
    Expression<int>? priority,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? nextRetryAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (dataJson != null) 'data_json': dataJson,
      if (priority != null) 'priority': priority,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? action,
    Value<String>? dataJson,
    Value<int>? priority,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime?>? nextRetryAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      dataJson: dataJson ?? this.dataJson,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('dataJson: $dataJson, ')
          ..write('priority: $priority, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextRetryAt: $nextRetryAt')
          ..write(')'))
        .toString();
  }
}

class $CachedAnimalsTable extends CachedAnimals
    with TableInfo<$CachedAnimalsTable, CachedAnimal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAnimalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
    'breed',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageYearsMeta = const VerificationMeta(
    'ageYears',
  );
  @override
  late final GeneratedColumn<double> ageYears = GeneratedColumn<double>(
    'age_years',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta(
    'ownerName',
  );
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerPhoneMeta = const VerificationMeta(
    'ownerPhone',
  );
  @override
  late final GeneratedColumn<String> ownerPhone = GeneratedColumn<String>(
    'owner_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    species,
    breed,
    ageYears,
    weightKg,
    sex,
    ownerName,
    ownerPhone,
    clinicId,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_animals';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedAnimal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
        _breedMeta,
        breed.isAcceptableOrUnknown(data['breed']!, _breedMeta),
      );
    } else if (isInserting) {
      context.missing(_breedMeta);
    }
    if (data.containsKey('age_years')) {
      context.handle(
        _ageYearsMeta,
        ageYears.isAcceptableOrUnknown(data['age_years']!, _ageYearsMeta),
      );
    } else if (isInserting) {
      context.missing(_ageYearsMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerNameMeta);
    }
    if (data.containsKey('owner_phone')) {
      context.handle(
        _ownerPhoneMeta,
        ownerPhone.isAcceptableOrUnknown(data['owner_phone']!, _ownerPhoneMeta),
      );
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clinicIdMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAnimal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAnimal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      breed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed'],
      )!,
      ageYears: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}age_years'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      )!,
      ownerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_phone'],
      ),
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedAnimalsTable createAlias(String alias) {
    return $CachedAnimalsTable(attachedDatabase, alias);
  }
}

class CachedAnimal extends DataClass implements Insertable<CachedAnimal> {
  final String id;
  final String name;
  final String species;
  final String breed;
  final double ageYears;
  final double weightKg;
  final String sex;
  final String ownerName;
  final String? ownerPhone;
  final String clinicId;
  final DateTime cachedAt;
  const CachedAnimal({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.ageYears,
    required this.weightKg,
    required this.sex,
    required this.ownerName,
    this.ownerPhone,
    required this.clinicId,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['species'] = Variable<String>(species);
    map['breed'] = Variable<String>(breed);
    map['age_years'] = Variable<double>(ageYears);
    map['weight_kg'] = Variable<double>(weightKg);
    map['sex'] = Variable<String>(sex);
    map['owner_name'] = Variable<String>(ownerName);
    if (!nullToAbsent || ownerPhone != null) {
      map['owner_phone'] = Variable<String>(ownerPhone);
    }
    map['clinic_id'] = Variable<String>(clinicId);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedAnimalsCompanion toCompanion(bool nullToAbsent) {
    return CachedAnimalsCompanion(
      id: Value(id),
      name: Value(name),
      species: Value(species),
      breed: Value(breed),
      ageYears: Value(ageYears),
      weightKg: Value(weightKg),
      sex: Value(sex),
      ownerName: Value(ownerName),
      ownerPhone: ownerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerPhone),
      clinicId: Value(clinicId),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedAnimal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAnimal(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      species: serializer.fromJson<String>(json['species']),
      breed: serializer.fromJson<String>(json['breed']),
      ageYears: serializer.fromJson<double>(json['ageYears']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      sex: serializer.fromJson<String>(json['sex']),
      ownerName: serializer.fromJson<String>(json['ownerName']),
      ownerPhone: serializer.fromJson<String?>(json['ownerPhone']),
      clinicId: serializer.fromJson<String>(json['clinicId']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'species': serializer.toJson<String>(species),
      'breed': serializer.toJson<String>(breed),
      'ageYears': serializer.toJson<double>(ageYears),
      'weightKg': serializer.toJson<double>(weightKg),
      'sex': serializer.toJson<String>(sex),
      'ownerName': serializer.toJson<String>(ownerName),
      'ownerPhone': serializer.toJson<String?>(ownerPhone),
      'clinicId': serializer.toJson<String>(clinicId),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedAnimal copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    double? ageYears,
    double? weightKg,
    String? sex,
    String? ownerName,
    Value<String?> ownerPhone = const Value.absent(),
    String? clinicId,
    DateTime? cachedAt,
  }) => CachedAnimal(
    id: id ?? this.id,
    name: name ?? this.name,
    species: species ?? this.species,
    breed: breed ?? this.breed,
    ageYears: ageYears ?? this.ageYears,
    weightKg: weightKg ?? this.weightKg,
    sex: sex ?? this.sex,
    ownerName: ownerName ?? this.ownerName,
    ownerPhone: ownerPhone.present ? ownerPhone.value : this.ownerPhone,
    clinicId: clinicId ?? this.clinicId,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedAnimal copyWithCompanion(CachedAnimalsCompanion data) {
    return CachedAnimal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      ageYears: data.ageYears.present ? data.ageYears.value : this.ageYears,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      sex: data.sex.present ? data.sex.value : this.sex,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      ownerPhone: data.ownerPhone.present
          ? data.ownerPhone.value
          : this.ownerPhone,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAnimal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('ageYears: $ageYears, ')
          ..write('weightKg: $weightKg, ')
          ..write('sex: $sex, ')
          ..write('ownerName: $ownerName, ')
          ..write('ownerPhone: $ownerPhone, ')
          ..write('clinicId: $clinicId, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    species,
    breed,
    ageYears,
    weightKg,
    sex,
    ownerName,
    ownerPhone,
    clinicId,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAnimal &&
          other.id == this.id &&
          other.name == this.name &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.ageYears == this.ageYears &&
          other.weightKg == this.weightKg &&
          other.sex == this.sex &&
          other.ownerName == this.ownerName &&
          other.ownerPhone == this.ownerPhone &&
          other.clinicId == this.clinicId &&
          other.cachedAt == this.cachedAt);
}

class CachedAnimalsCompanion extends UpdateCompanion<CachedAnimal> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> species;
  final Value<String> breed;
  final Value<double> ageYears;
  final Value<double> weightKg;
  final Value<String> sex;
  final Value<String> ownerName;
  final Value<String?> ownerPhone;
  final Value<String> clinicId;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedAnimalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.ageYears = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.sex = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.ownerPhone = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedAnimalsCompanion.insert({
    required String id,
    required String name,
    required String species,
    required String breed,
    required double ageYears,
    required double weightKg,
    required String sex,
    required String ownerName,
    this.ownerPhone = const Value.absent(),
    required String clinicId,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       species = Value(species),
       breed = Value(breed),
       ageYears = Value(ageYears),
       weightKg = Value(weightKg),
       sex = Value(sex),
       ownerName = Value(ownerName),
       clinicId = Value(clinicId);
  static Insertable<CachedAnimal> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<double>? ageYears,
    Expression<double>? weightKg,
    Expression<String>? sex,
    Expression<String>? ownerName,
    Expression<String>? ownerPhone,
    Expression<String>? clinicId,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (ageYears != null) 'age_years': ageYears,
      if (weightKg != null) 'weight_kg': weightKg,
      if (sex != null) 'sex': sex,
      if (ownerName != null) 'owner_name': ownerName,
      if (ownerPhone != null) 'owner_phone': ownerPhone,
      if (clinicId != null) 'clinic_id': clinicId,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedAnimalsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? species,
    Value<String>? breed,
    Value<double>? ageYears,
    Value<double>? weightKg,
    Value<String>? sex,
    Value<String>? ownerName,
    Value<String?>? ownerPhone,
    Value<String>? clinicId,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedAnimalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      ageYears: ageYears ?? this.ageYears,
      weightKg: weightKg ?? this.weightKg,
      sex: sex ?? this.sex,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      clinicId: clinicId ?? this.clinicId,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (ageYears.present) {
      map['age_years'] = Variable<double>(ageYears.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (ownerPhone.present) {
      map['owner_phone'] = Variable<String>(ownerPhone.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAnimalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('ageYears: $ageYears, ')
          ..write('weightKg: $weightKg, ')
          ..write('sex: $sex, ')
          ..write('ownerName: $ownerName, ')
          ..write('ownerPhone: $ownerPhone, ')
          ..write('clinicId: $clinicId, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalSessionsTable localSessions = $LocalSessionsTable(this);
  late final $LocalAnnotationsTable localAnnotations = $LocalAnnotationsTable(
    this,
  );
  late final $LocalVitalsTable localVitals = $LocalVitalsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $CachedAnimalsTable cachedAnimals = $CachedAnimalsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localSessions,
    localAnnotations,
    localVitals,
    syncQueue,
    cachedAnimals,
  ];
}

typedef $$LocalSessionsTableCreateCompanionBuilder =
    LocalSessionsCompanion Function({
      required String id,
      required String sessionCode,
      required String animalId,
      required String collarId,
      required String observerId,
      required String clinicId,
      required String currentPhase,
      Value<String?> surgeryType,
      Value<String?> surgeryReason,
      Value<String?> asaStatus,
      Value<String?> baselineDataJson,
      Value<int?> baselineQuality,
      Value<bool> isCalibrated,
      Value<String?> calibrationStatus,
      Value<double?> calibrationErrorBpm,
      Value<double?> calibrationCorrelation,
      required DateTime startedAt,
      Value<DateTime?> surgeryStartedAt,
      Value<DateTime?> surgeryEndedAt,
      Value<DateTime?> endedAt,
      Value<String?> collarPhotoPath,
      Value<String?> initialPosition,
      Value<String?> initialAnxiety,
      Value<String?> initialNotes,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalSessionsTableUpdateCompanionBuilder =
    LocalSessionsCompanion Function({
      Value<String> id,
      Value<String> sessionCode,
      Value<String> animalId,
      Value<String> collarId,
      Value<String> observerId,
      Value<String> clinicId,
      Value<String> currentPhase,
      Value<String?> surgeryType,
      Value<String?> surgeryReason,
      Value<String?> asaStatus,
      Value<String?> baselineDataJson,
      Value<int?> baselineQuality,
      Value<bool> isCalibrated,
      Value<String?> calibrationStatus,
      Value<double?> calibrationErrorBpm,
      Value<double?> calibrationCorrelation,
      Value<DateTime> startedAt,
      Value<DateTime?> surgeryStartedAt,
      Value<DateTime?> surgeryEndedAt,
      Value<DateTime?> endedAt,
      Value<String?> collarPhotoPath,
      Value<String?> initialPosition,
      Value<String?> initialAnxiety,
      Value<String?> initialNotes,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableFilterComposer({
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

  ColumnFilters<String> get sessionCode => $composableBuilder(
    column: $table.sessionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get animalId => $composableBuilder(
    column: $table.animalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collarId => $composableBuilder(
    column: $table.collarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observerId => $composableBuilder(
    column: $table.observerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentPhase => $composableBuilder(
    column: $table.currentPhase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surgeryType => $composableBuilder(
    column: $table.surgeryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surgeryReason => $composableBuilder(
    column: $table.surgeryReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get asaStatus => $composableBuilder(
    column: $table.asaStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baselineDataJson => $composableBuilder(
    column: $table.baselineDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baselineQuality => $composableBuilder(
    column: $table.baselineQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCalibrated => $composableBuilder(
    column: $table.isCalibrated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calibrationStatus => $composableBuilder(
    column: $table.calibrationStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calibrationErrorBpm => $composableBuilder(
    column: $table.calibrationErrorBpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calibrationCorrelation => $composableBuilder(
    column: $table.calibrationCorrelation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get surgeryStartedAt => $composableBuilder(
    column: $table.surgeryStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get surgeryEndedAt => $composableBuilder(
    column: $table.surgeryEndedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collarPhotoPath => $composableBuilder(
    column: $table.collarPhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get initialPosition => $composableBuilder(
    column: $table.initialPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get initialAnxiety => $composableBuilder(
    column: $table.initialAnxiety,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get initialNotes => $composableBuilder(
    column: $table.initialNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get sessionCode => $composableBuilder(
    column: $table.sessionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get animalId => $composableBuilder(
    column: $table.animalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collarId => $composableBuilder(
    column: $table.collarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observerId => $composableBuilder(
    column: $table.observerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentPhase => $composableBuilder(
    column: $table.currentPhase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surgeryType => $composableBuilder(
    column: $table.surgeryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surgeryReason => $composableBuilder(
    column: $table.surgeryReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asaStatus => $composableBuilder(
    column: $table.asaStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baselineDataJson => $composableBuilder(
    column: $table.baselineDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baselineQuality => $composableBuilder(
    column: $table.baselineQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCalibrated => $composableBuilder(
    column: $table.isCalibrated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calibrationStatus => $composableBuilder(
    column: $table.calibrationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calibrationErrorBpm => $composableBuilder(
    column: $table.calibrationErrorBpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calibrationCorrelation => $composableBuilder(
    column: $table.calibrationCorrelation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get surgeryStartedAt => $composableBuilder(
    column: $table.surgeryStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get surgeryEndedAt => $composableBuilder(
    column: $table.surgeryEndedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collarPhotoPath => $composableBuilder(
    column: $table.collarPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get initialPosition => $composableBuilder(
    column: $table.initialPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get initialAnxiety => $composableBuilder(
    column: $table.initialAnxiety,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get initialNotes => $composableBuilder(
    column: $table.initialNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionCode => $composableBuilder(
    column: $table.sessionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<String> get collarId =>
      $composableBuilder(column: $table.collarId, builder: (column) => column);

  GeneratedColumn<String> get observerId => $composableBuilder(
    column: $table.observerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicId =>
      $composableBuilder(column: $table.clinicId, builder: (column) => column);

  GeneratedColumn<String> get currentPhase => $composableBuilder(
    column: $table.currentPhase,
    builder: (column) => column,
  );

  GeneratedColumn<String> get surgeryType => $composableBuilder(
    column: $table.surgeryType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get surgeryReason => $composableBuilder(
    column: $table.surgeryReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get asaStatus =>
      $composableBuilder(column: $table.asaStatus, builder: (column) => column);

  GeneratedColumn<String> get baselineDataJson => $composableBuilder(
    column: $table.baselineDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baselineQuality => $composableBuilder(
    column: $table.baselineQuality,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCalibrated => $composableBuilder(
    column: $table.isCalibrated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calibrationStatus => $composableBuilder(
    column: $table.calibrationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calibrationErrorBpm => $composableBuilder(
    column: $table.calibrationErrorBpm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calibrationCorrelation => $composableBuilder(
    column: $table.calibrationCorrelation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get surgeryStartedAt => $composableBuilder(
    column: $table.surgeryStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get surgeryEndedAt => $composableBuilder(
    column: $table.surgeryEndedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get collarPhotoPath => $composableBuilder(
    column: $table.collarPhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get initialPosition => $composableBuilder(
    column: $table.initialPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get initialAnxiety => $composableBuilder(
    column: $table.initialAnxiety,
    builder: (column) => column,
  );

  GeneratedColumn<String> get initialNotes => $composableBuilder(
    column: $table.initialNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSessionsTable,
          LocalSession,
          $$LocalSessionsTableFilterComposer,
          $$LocalSessionsTableOrderingComposer,
          $$LocalSessionsTableAnnotationComposer,
          $$LocalSessionsTableCreateCompanionBuilder,
          $$LocalSessionsTableUpdateCompanionBuilder,
          (
            LocalSession,
            BaseReferences<_$AppDatabase, $LocalSessionsTable, LocalSession>,
          ),
          LocalSession,
          PrefetchHooks Function()
        > {
  $$LocalSessionsTableTableManager(_$AppDatabase db, $LocalSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionCode = const Value.absent(),
                Value<String> animalId = const Value.absent(),
                Value<String> collarId = const Value.absent(),
                Value<String> observerId = const Value.absent(),
                Value<String> clinicId = const Value.absent(),
                Value<String> currentPhase = const Value.absent(),
                Value<String?> surgeryType = const Value.absent(),
                Value<String?> surgeryReason = const Value.absent(),
                Value<String?> asaStatus = const Value.absent(),
                Value<String?> baselineDataJson = const Value.absent(),
                Value<int?> baselineQuality = const Value.absent(),
                Value<bool> isCalibrated = const Value.absent(),
                Value<String?> calibrationStatus = const Value.absent(),
                Value<double?> calibrationErrorBpm = const Value.absent(),
                Value<double?> calibrationCorrelation = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> surgeryStartedAt = const Value.absent(),
                Value<DateTime?> surgeryEndedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> collarPhotoPath = const Value.absent(),
                Value<String?> initialPosition = const Value.absent(),
                Value<String?> initialAnxiety = const Value.absent(),
                Value<String?> initialNotes = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSessionsCompanion(
                id: id,
                sessionCode: sessionCode,
                animalId: animalId,
                collarId: collarId,
                observerId: observerId,
                clinicId: clinicId,
                currentPhase: currentPhase,
                surgeryType: surgeryType,
                surgeryReason: surgeryReason,
                asaStatus: asaStatus,
                baselineDataJson: baselineDataJson,
                baselineQuality: baselineQuality,
                isCalibrated: isCalibrated,
                calibrationStatus: calibrationStatus,
                calibrationErrorBpm: calibrationErrorBpm,
                calibrationCorrelation: calibrationCorrelation,
                startedAt: startedAt,
                surgeryStartedAt: surgeryStartedAt,
                surgeryEndedAt: surgeryEndedAt,
                endedAt: endedAt,
                collarPhotoPath: collarPhotoPath,
                initialPosition: initialPosition,
                initialAnxiety: initialAnxiety,
                initialNotes: initialNotes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionCode,
                required String animalId,
                required String collarId,
                required String observerId,
                required String clinicId,
                required String currentPhase,
                Value<String?> surgeryType = const Value.absent(),
                Value<String?> surgeryReason = const Value.absent(),
                Value<String?> asaStatus = const Value.absent(),
                Value<String?> baselineDataJson = const Value.absent(),
                Value<int?> baselineQuality = const Value.absent(),
                Value<bool> isCalibrated = const Value.absent(),
                Value<String?> calibrationStatus = const Value.absent(),
                Value<double?> calibrationErrorBpm = const Value.absent(),
                Value<double?> calibrationCorrelation = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> surgeryStartedAt = const Value.absent(),
                Value<DateTime?> surgeryEndedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> collarPhotoPath = const Value.absent(),
                Value<String?> initialPosition = const Value.absent(),
                Value<String?> initialAnxiety = const Value.absent(),
                Value<String?> initialNotes = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSessionsCompanion.insert(
                id: id,
                sessionCode: sessionCode,
                animalId: animalId,
                collarId: collarId,
                observerId: observerId,
                clinicId: clinicId,
                currentPhase: currentPhase,
                surgeryType: surgeryType,
                surgeryReason: surgeryReason,
                asaStatus: asaStatus,
                baselineDataJson: baselineDataJson,
                baselineQuality: baselineQuality,
                isCalibrated: isCalibrated,
                calibrationStatus: calibrationStatus,
                calibrationErrorBpm: calibrationErrorBpm,
                calibrationCorrelation: calibrationCorrelation,
                startedAt: startedAt,
                surgeryStartedAt: surgeryStartedAt,
                surgeryEndedAt: surgeryEndedAt,
                endedAt: endedAt,
                collarPhotoPath: collarPhotoPath,
                initialPosition: initialPosition,
                initialAnxiety: initialAnxiety,
                initialNotes: initialNotes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSessionsTable,
      LocalSession,
      $$LocalSessionsTableFilterComposer,
      $$LocalSessionsTableOrderingComposer,
      $$LocalSessionsTableAnnotationComposer,
      $$LocalSessionsTableCreateCompanionBuilder,
      $$LocalSessionsTableUpdateCompanionBuilder,
      (
        LocalSession,
        BaseReferences<_$AppDatabase, $LocalSessionsTable, LocalSession>,
      ),
      LocalSession,
      PrefetchHooks Function()
    >;
typedef $$LocalAnnotationsTableCreateCompanionBuilder =
    LocalAnnotationsCompanion Function({
      required String id,
      required String sessionId,
      required DateTime timestampUtc,
      required int elapsedMs,
      required String phase,
      required String category,
      required String type,
      Value<String?> description,
      Value<String> severity,
      Value<String?> structuredDataJson,
      Value<String?> voiceNotePath,
      Value<String?> voiceTranscription,
      required String annotatorUserId,
      Value<bool> isAutoGenerated,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$LocalAnnotationsTableUpdateCompanionBuilder =
    LocalAnnotationsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<DateTime> timestampUtc,
      Value<int> elapsedMs,
      Value<String> phase,
      Value<String> category,
      Value<String> type,
      Value<String?> description,
      Value<String> severity,
      Value<String?> structuredDataJson,
      Value<String?> voiceNotePath,
      Value<String?> voiceTranscription,
      Value<String> annotatorUserId,
      Value<bool> isAutoGenerated,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalAnnotationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAnnotationsTable> {
  $$LocalAnnotationsTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get structuredDataJson => $composableBuilder(
    column: $table.structuredDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceNotePath => $composableBuilder(
    column: $table.voiceNotePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceTranscription => $composableBuilder(
    column: $table.voiceTranscription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get annotatorUserId => $composableBuilder(
    column: $table.annotatorUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAutoGenerated => $composableBuilder(
    column: $table.isAutoGenerated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAnnotationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAnnotationsTable> {
  $$LocalAnnotationsTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get structuredDataJson => $composableBuilder(
    column: $table.structuredDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceNotePath => $composableBuilder(
    column: $table.voiceNotePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceTranscription => $composableBuilder(
    column: $table.voiceTranscription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get annotatorUserId => $composableBuilder(
    column: $table.annotatorUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAutoGenerated => $composableBuilder(
    column: $table.isAutoGenerated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAnnotationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAnnotationsTable> {
  $$LocalAnnotationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get structuredDataJson => $composableBuilder(
    column: $table.structuredDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voiceNotePath => $composableBuilder(
    column: $table.voiceNotePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voiceTranscription => $composableBuilder(
    column: $table.voiceTranscription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get annotatorUserId => $composableBuilder(
    column: $table.annotatorUserId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAutoGenerated => $composableBuilder(
    column: $table.isAutoGenerated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalAnnotationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAnnotationsTable,
          LocalAnnotation,
          $$LocalAnnotationsTableFilterComposer,
          $$LocalAnnotationsTableOrderingComposer,
          $$LocalAnnotationsTableAnnotationComposer,
          $$LocalAnnotationsTableCreateCompanionBuilder,
          $$LocalAnnotationsTableUpdateCompanionBuilder,
          (
            LocalAnnotation,
            BaseReferences<
              _$AppDatabase,
              $LocalAnnotationsTable,
              LocalAnnotation
            >,
          ),
          LocalAnnotation,
          PrefetchHooks Function()
        > {
  $$LocalAnnotationsTableTableManager(
    _$AppDatabase db,
    $LocalAnnotationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAnnotationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAnnotationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAnnotationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<DateTime> timestampUtc = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String?> structuredDataJson = const Value.absent(),
                Value<String?> voiceNotePath = const Value.absent(),
                Value<String?> voiceTranscription = const Value.absent(),
                Value<String> annotatorUserId = const Value.absent(),
                Value<bool> isAutoGenerated = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAnnotationsCompanion(
                id: id,
                sessionId: sessionId,
                timestampUtc: timestampUtc,
                elapsedMs: elapsedMs,
                phase: phase,
                category: category,
                type: type,
                description: description,
                severity: severity,
                structuredDataJson: structuredDataJson,
                voiceNotePath: voiceNotePath,
                voiceTranscription: voiceTranscription,
                annotatorUserId: annotatorUserId,
                isAutoGenerated: isAutoGenerated,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required DateTime timestampUtc,
                required int elapsedMs,
                required String phase,
                required String category,
                required String type,
                Value<String?> description = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String?> structuredDataJson = const Value.absent(),
                Value<String?> voiceNotePath = const Value.absent(),
                Value<String?> voiceTranscription = const Value.absent(),
                required String annotatorUserId,
                Value<bool> isAutoGenerated = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAnnotationsCompanion.insert(
                id: id,
                sessionId: sessionId,
                timestampUtc: timestampUtc,
                elapsedMs: elapsedMs,
                phase: phase,
                category: category,
                type: type,
                description: description,
                severity: severity,
                structuredDataJson: structuredDataJson,
                voiceNotePath: voiceNotePath,
                voiceTranscription: voiceTranscription,
                annotatorUserId: annotatorUserId,
                isAutoGenerated: isAutoGenerated,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAnnotationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAnnotationsTable,
      LocalAnnotation,
      $$LocalAnnotationsTableFilterComposer,
      $$LocalAnnotationsTableOrderingComposer,
      $$LocalAnnotationsTableAnnotationComposer,
      $$LocalAnnotationsTableCreateCompanionBuilder,
      $$LocalAnnotationsTableUpdateCompanionBuilder,
      (
        LocalAnnotation,
        BaseReferences<_$AppDatabase, $LocalAnnotationsTable, LocalAnnotation>,
      ),
      LocalAnnotation,
      PrefetchHooks Function()
    >;
typedef $$LocalVitalsTableCreateCompanionBuilder =
    LocalVitalsCompanion Function({
      Value<int> id,
      required String sessionId,
      required DateTime timestampUtc,
      required int heartRateBpm,
      required int respiratoryRateBpm,
      required double temperatureC,
      required int signalQuality,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
    });
typedef $$LocalVitalsTableUpdateCompanionBuilder =
    LocalVitalsCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<DateTime> timestampUtc,
      Value<int> heartRateBpm,
      Value<int> respiratoryRateBpm,
      Value<double> temperatureC,
      Value<int> signalQuality,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
    });

class $$LocalVitalsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalVitalsTable> {
  $$LocalVitalsTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRateBpm => $composableBuilder(
    column: $table.heartRateBpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get respiratoryRateBpm => $composableBuilder(
    column: $table.respiratoryRateBpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureC => $composableBuilder(
    column: $table.temperatureC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get signalQuality => $composableBuilder(
    column: $table.signalQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalVitalsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalVitalsTable> {
  $$LocalVitalsTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRateBpm => $composableBuilder(
    column: $table.heartRateBpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get respiratoryRateBpm => $composableBuilder(
    column: $table.respiratoryRateBpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureC => $composableBuilder(
    column: $table.temperatureC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get signalQuality => $composableBuilder(
    column: $table.signalQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalVitalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalVitalsTable> {
  $$LocalVitalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heartRateBpm => $composableBuilder(
    column: $table.heartRateBpm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get respiratoryRateBpm => $composableBuilder(
    column: $table.respiratoryRateBpm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperatureC => $composableBuilder(
    column: $table.temperatureC,
    builder: (column) => column,
  );

  GeneratedColumn<int> get signalQuality => $composableBuilder(
    column: $table.signalQuality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalVitalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalVitalsTable,
          LocalVital,
          $$LocalVitalsTableFilterComposer,
          $$LocalVitalsTableOrderingComposer,
          $$LocalVitalsTableAnnotationComposer,
          $$LocalVitalsTableCreateCompanionBuilder,
          $$LocalVitalsTableUpdateCompanionBuilder,
          (
            LocalVital,
            BaseReferences<_$AppDatabase, $LocalVitalsTable, LocalVital>,
          ),
          LocalVital,
          PrefetchHooks Function()
        > {
  $$LocalVitalsTableTableManager(_$AppDatabase db, $LocalVitalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalVitalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalVitalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalVitalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<DateTime> timestampUtc = const Value.absent(),
                Value<int> heartRateBpm = const Value.absent(),
                Value<int> respiratoryRateBpm = const Value.absent(),
                Value<double> temperatureC = const Value.absent(),
                Value<int> signalQuality = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocalVitalsCompanion(
                id: id,
                sessionId: sessionId,
                timestampUtc: timestampUtc,
                heartRateBpm: heartRateBpm,
                respiratoryRateBpm: respiratoryRateBpm,
                temperatureC: temperatureC,
                signalQuality: signalQuality,
                syncStatus: syncStatus,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required DateTime timestampUtc,
                required int heartRateBpm,
                required int respiratoryRateBpm,
                required double temperatureC,
                required int signalQuality,
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocalVitalsCompanion.insert(
                id: id,
                sessionId: sessionId,
                timestampUtc: timestampUtc,
                heartRateBpm: heartRateBpm,
                respiratoryRateBpm: respiratoryRateBpm,
                temperatureC: temperatureC,
                signalQuality: signalQuality,
                syncStatus: syncStatus,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalVitalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalVitalsTable,
      LocalVital,
      $$LocalVitalsTableFilterComposer,
      $$LocalVitalsTableOrderingComposer,
      $$LocalVitalsTableAnnotationComposer,
      $$LocalVitalsTableCreateCompanionBuilder,
      $$LocalVitalsTableUpdateCompanionBuilder,
      (
        LocalVital,
        BaseReferences<_$AppDatabase, $LocalVitalsTable, LocalVital>,
      ),
      LocalVital,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entityType,
      required String entityId,
      required String action,
      required String dataJson,
      Value<int> priority,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime?> nextRetryAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> action,
      Value<String> dataJson,
      Value<int> priority,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime?> nextRetryAt,
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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> dataJson = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                action: action,
                dataJson: dataJson,
                priority: priority,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
                nextRetryAt: nextRetryAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityId,
                required String action,
                required String dataJson,
                Value<int> priority = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                action: action,
                dataJson: dataJson,
                priority: priority,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
                nextRetryAt: nextRetryAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$CachedAnimalsTableCreateCompanionBuilder =
    CachedAnimalsCompanion Function({
      required String id,
      required String name,
      required String species,
      required String breed,
      required double ageYears,
      required double weightKg,
      required String sex,
      required String ownerName,
      Value<String?> ownerPhone,
      required String clinicId,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$CachedAnimalsTableUpdateCompanionBuilder =
    CachedAnimalsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> species,
      Value<String> breed,
      Value<double> ageYears,
      Value<double> weightKg,
      Value<String> sex,
      Value<String> ownerName,
      Value<String?> ownerPhone,
      Value<String> clinicId,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedAnimalsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAnimalsTable> {
  $$CachedAnimalsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerPhone => $composableBuilder(
    column: $table.ownerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedAnimalsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAnimalsTable> {
  $$CachedAnimalsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerPhone => $composableBuilder(
    column: $table.ownerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedAnimalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAnimalsTable> {
  $$CachedAnimalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<double> get ageYears =>
      $composableBuilder(column: $table.ageYears, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get ownerPhone => $composableBuilder(
    column: $table.ownerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicId =>
      $composableBuilder(column: $table.clinicId, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedAnimalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedAnimalsTable,
          CachedAnimal,
          $$CachedAnimalsTableFilterComposer,
          $$CachedAnimalsTableOrderingComposer,
          $$CachedAnimalsTableAnnotationComposer,
          $$CachedAnimalsTableCreateCompanionBuilder,
          $$CachedAnimalsTableUpdateCompanionBuilder,
          (
            CachedAnimal,
            BaseReferences<_$AppDatabase, $CachedAnimalsTable, CachedAnimal>,
          ),
          CachedAnimal,
          PrefetchHooks Function()
        > {
  $$CachedAnimalsTableTableManager(_$AppDatabase db, $CachedAnimalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAnimalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAnimalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAnimalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<String> breed = const Value.absent(),
                Value<double> ageYears = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<String> ownerName = const Value.absent(),
                Value<String?> ownerPhone = const Value.absent(),
                Value<String> clinicId = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAnimalsCompanion(
                id: id,
                name: name,
                species: species,
                breed: breed,
                ageYears: ageYears,
                weightKg: weightKg,
                sex: sex,
                ownerName: ownerName,
                ownerPhone: ownerPhone,
                clinicId: clinicId,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String species,
                required String breed,
                required double ageYears,
                required double weightKg,
                required String sex,
                required String ownerName,
                Value<String?> ownerPhone = const Value.absent(),
                required String clinicId,
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAnimalsCompanion.insert(
                id: id,
                name: name,
                species: species,
                breed: breed,
                ageYears: ageYears,
                weightKg: weightKg,
                sex: sex,
                ownerName: ownerName,
                ownerPhone: ownerPhone,
                clinicId: clinicId,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedAnimalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedAnimalsTable,
      CachedAnimal,
      $$CachedAnimalsTableFilterComposer,
      $$CachedAnimalsTableOrderingComposer,
      $$CachedAnimalsTableAnnotationComposer,
      $$CachedAnimalsTableCreateCompanionBuilder,
      $$CachedAnimalsTableUpdateCompanionBuilder,
      (
        CachedAnimal,
        BaseReferences<_$AppDatabase, $CachedAnimalsTable, CachedAnimal>,
      ),
      CachedAnimal,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalSessionsTableTableManager get localSessions =>
      $$LocalSessionsTableTableManager(_db, _db.localSessions);
  $$LocalAnnotationsTableTableManager get localAnnotations =>
      $$LocalAnnotationsTableTableManager(_db, _db.localAnnotations);
  $$LocalVitalsTableTableManager get localVitals =>
      $$LocalVitalsTableTableManager(_db, _db.localVitals);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$CachedAnimalsTableTableManager get cachedAnimals =>
      $$CachedAnimalsTableTableManager(_db, _db.cachedAnimals);
}
