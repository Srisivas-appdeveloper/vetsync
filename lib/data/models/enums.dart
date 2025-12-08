/// Species types
enum Species {
  dog('dog', 'Dog'),
  cat('cat', 'Cat'),
  other('other', 'Other');

  final String value;
  final String displayName;

  const Species(this.value, this.displayName);

  static Species fromString(String value) {
    return Species.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => Species.other,
    );
  }
}

/// Sex types
enum Sex {
  male('male', 'Male'),
  female('female', 'Female'),
  neutered('neutered', 'Neutered'),
  neuteredMale('neutered_male', 'Neutered Male'),
  spayed('spayed', 'Spayed'),
  spayedFemale('spayed_female', 'Spayed Female');

  final String value;
  final String displayName;

  const Sex(this.value, this.displayName);

  static Sex fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return Sex.values.firstWhere(
      (e) => e.value == normalized,
      orElse: () {
        // Handle alternative values
        if (normalized == 'neutered_male' || normalized == 'neuteredmale') {
          return Sex.neuteredMale;
        }
        if (normalized == 'spayed_female' || normalized == 'spayedfemale') {
          return Sex.spayedFemale;
        }
        if (normalized == 'm') return Sex.male;
        if (normalized == 'f') return Sex.female;
        return Sex.male;
      },
    );
  }
}

/// Session phases
enum SessionPhase {
  preSurgery('pre_surgery', 'Pre-Surgery'),
  surgery('surgery', 'Surgery'),
  calibration('calibration', 'Calibration'),
  recovery('recovery', 'Recovery'),
  completed('completed', 'Completed');

  final String value;
  final String displayName;

  const SessionPhase(this.value, this.displayName);

  static SessionPhase fromString(String value) {
    return SessionPhase.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => SessionPhase.preSurgery,
    );
  }

  bool get isActive => this != SessionPhase.completed;
}

/// Pet position during session setup
enum PetPosition {
  standing('standing', 'Standing'),
  sitting('sitting', 'Sitting'),
  laying('laying', 'Laying'),
  verySick('very_sick', 'Very Sick');

  final String value;
  final String displayName;

  const PetPosition(this.value, this.displayName);

  static PetPosition fromString(String value) {
    return PetPosition.values.firstWhere(
      (e) => e.value == value.toLowerCase().replaceAll(' ', '_'),
      orElse: () => PetPosition.standing,
    );
  }
}

/// Anxiety level
enum AnxietyLevel {
  calm('calm', 'Calm'),
  mild('mild', 'Mild'),
  moderate('moderate', 'Moderate'),
  severe('severe', 'Severe');

  final String value;
  final String displayName;

  const AnxietyLevel(this.value, this.displayName);

  static AnxietyLevel fromString(String value) {
    return AnxietyLevel.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => AnxietyLevel.calm,
    );
  }
}

/// ASA (American Society of Anesthesiologists) status
enum ASAStatus {
  i('I', 'I - Healthy patient'),
  ii('II', 'II - Mild systemic disease'),
  iii('III', 'III - Severe systemic disease'),
  iv('IV', 'IV - Life-threatening disease'),
  v('V', 'V - Moribund patient');

  final String value;
  final String description;

  const ASAStatus(this.value, this.description);

  static ASAStatus fromString(String value) {
    return ASAStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => ASAStatus.i,
    );
  }
}

/// Calibration status
enum CalibrationStatus {
  pending('pending', 'Pending'),
  inProgress('in_progress', 'In Progress'),
  success('success', 'Success'),
  insufficientData('insufficient_data', 'Insufficient Data'),
  lowQuality('low_quality', 'Low Quality'),
  failed('failed', 'Failed');

  final String value;
  final String displayName;

  const CalibrationStatus(this.value, this.displayName);

  static CalibrationStatus fromString(String value) {
    return CalibrationStatus.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => CalibrationStatus.pending,
    );
  }

  bool get isSuccess => this == CalibrationStatus.success;
  bool get isFailed =>
      this == CalibrationStatus.failed ||
      this == CalibrationStatus.insufficientData ||
      this == CalibrationStatus.lowQuality;
}

/// Annotation categories
enum AnnotationCategory {
  anesthesia('anesthesia', 'Anesthesia', '💉'),
  medication('medication', 'Medication', '💊'),
  preparation('preparation', 'Preparation', '📋'),
  surgical('surgical', 'Surgical', '🩺'),
  event('event', 'Event', '⚡'),
  recovery('recovery', 'Recovery', '🏥'),
  behavior('behavior', 'Behavior', '🐕'),
  physiological('physiological', 'Physiological', '🚽'),
  emergency('emergency', 'Emergency', '🚨'),
  system('system', 'System', '⚙️');

  final String value;
  final String displayName;
  final String icon;

  const AnnotationCategory(this.value, this.displayName, this.icon);

  /// Alias for icon - returns emoji character
  String get emoji => icon;

  static AnnotationCategory fromString(String value) {
    return AnnotationCategory.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => AnnotationCategory.event,
    );
  }
}

/// Annotation severity
enum AnnotationSeverity {
  info('info', 'Info'),
  warning('warning', 'Warning'),
  critical('critical', 'Critical');

  final String value;
  final String displayName;

  const AnnotationSeverity(this.value, this.displayName);

  static AnnotationSeverity fromString(String value) {
    return AnnotationSeverity.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => AnnotationSeverity.info,
    );
  }
}

/// Physiological event types
enum PhysiologicalEventType {
  urination('urination', 'Urination', false),
  defecation('defecation', 'Defecation', false),
  vomiting('vomiting', 'Vomiting', true),
  retching('retching', 'Retching', false),
  regurgitation('regurgitation', 'Regurgitation', false),
  diarrhea('diarrhea', 'Diarrhea', false),
  drooling('drooling', 'Drooling', false),
  trembling('trembling', 'Trembling', false),
  panting('panting', 'Panting', false),
  coughing('coughing', 'Coughing', false),
  sneezing('sneezing', 'Sneezing', false),
  flatulence('flatulence', 'Flatulence', false);

  final String value;
  final String displayName;
  final bool isCritical;

  const PhysiologicalEventType(this.value, this.displayName, this.isCritical);

  static PhysiologicalEventType fromString(String value) {
    return PhysiologicalEventType.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => PhysiologicalEventType.urination,
    );
  }
}

/// Event severity level (for physiological events)
enum EventSeverityLevel {
  mild('mild', 'Mild'),
  moderate('moderate', 'Moderate'),
  severe('severe', 'Severe');

  final String value;
  final String displayName;

  const EventSeverityLevel(this.value, this.displayName);

  static EventSeverityLevel fromString(String value) {
    return EventSeverityLevel.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => EventSeverityLevel.mild,
    );
  }
}

/// BLE connection state
enum BleConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  reconnecting,
  error;

  bool get isConnected => this == BleConnectionState.connected;
  bool get isDisconnected => this == BleConnectionState.disconnected;
  bool get isConnecting =>
      this == BleConnectionState.connecting ||
      this == BleConnectionState.reconnecting;
}

/// WebSocket connection state
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error;

  bool get isConnected => this == WebSocketState.connected;
}

/// Firmware mode
enum FirmwareMode {
  filtered('filtered', 100),
  raw('raw', 128);

  final String value;
  final int sampleRate;

  const FirmwareMode(this.value, this.sampleRate);

  static FirmwareMode fromString(String value) {
    return FirmwareMode.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => FirmwareMode.filtered,
    );
  }
}

/// Collar status
enum CollarStatus {
  available('available', 'Available'),
  inUse('in_use', 'In Use'),
  charging('charging', 'Charging'),
  maintenance('maintenance', 'Maintenance'),
  offline('offline', 'Offline');

  final String value;
  final String displayName;

  const CollarStatus(this.value, this.displayName);

  static CollarStatus fromString(String value) {
    return CollarStatus.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => CollarStatus.offline,
    );
  }
}

/// Signal strength levels
enum SignalStrength {
  excellent('Excellent', -60),
  good('Good', -70),
  fair('Fair', -80),
  poor('Poor', -100);

  final String displayName;
  final int minRssi;

  const SignalStrength(this.displayName, this.minRssi);

  static SignalStrength fromRssi(int rssi) {
    if (rssi >= -60) return SignalStrength.excellent;
    if (rssi >= -70) return SignalStrength.good;
    if (rssi >= -80) return SignalStrength.fair;
    return SignalStrength.poor;
  }
}

/// Observer role in a session
enum ObserverRole {
  primary('primary', 'Primary Observer'),
  secondary('secondary', 'Secondary Observer');

  final String value;
  final String displayName;

  const ObserverRole(this.value, this.displayName);

  static ObserverRole fromString(String value) {
    return ObserverRole.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => ObserverRole.secondary,
    );
  }
}

/// Sync status for offline items
enum SyncStatus {
  pending('pending'),
  syncing('syncing'),
  synced('synced'),
  failed('failed');

  final String value;

  const SyncStatus(this.value);

  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => SyncStatus.pending,
    );
  }
}
