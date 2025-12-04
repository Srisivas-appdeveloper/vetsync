import 'dart:math';
import 'dart:typed_data';
import 'package:fftea/fftea.dart';

/// BCG (Ballistocardiography) Signal Processing Algorithm
/// Extracts heart rate and respiratory rate from collar pressure sensor data
class BcgAlgorithm {
  // Sampling configuration
  final int sampleRate;

  // Processing buffers
  final List<double> _pressureBuffer = [];
  final List<double> _filteredBuffer = [];
  final List<double> _hrBuffer = [];
  final List<double> _rrBuffer = [];

  // Configuration
  static const int hrWindowSeconds = 10; // Window for HR estimation
  static const int rrWindowSeconds =
      30; // Window for RR estimation (longer for breathing)
  static const int minBufferSeconds = 5; // Minimum data needed

  // HR detection thresholds (dogs: 60-180 BPM)
  static const double hrMinFreq = 0.8; // 48 BPM
  static const double hrMaxFreq = 3.5; // 210 BPM

  // RR detection thresholds (dogs: 10-40 breaths/min)
  static const double rrMinFreq = 0.15; // 9 breaths/min
  static const double rrMaxFreq = 0.8; // 48 breaths/min

  // Filter coefficients (Butterworth bandpass 0.5-10 Hz for HR)
  late final List<double> _hrFilterB;
  late final List<double> _hrFilterA;

  // Filter coefficients (Butterworth bandpass 0.1-1 Hz for RR)
  late final List<double> _rrFilterB;
  late final List<double> _rrFilterA;

  // Filter state
  final List<double> _hrFilterState = List.filled(4, 0.0);
  final List<double> _rrFilterState = List.filled(4, 0.0);

  // Results
  double _lastHeartRate = 0;
  double _lastRespiratoryRate = 0;
  int _lastSignalQuality = 0;

  // Peak detection state
  final List<int> _rPeakIndices = [];
  final List<double> _rPeakAmplitudes = [];

  BcgAlgorithm({this.sampleRate = 100}) {
    _initializeFilters();
  }

  void _initializeFilters() {
    // 2nd order Butterworth bandpass filter coefficients
    // For HR: 0.5-10 Hz at 100 Hz sample rate
    // Pre-computed for efficiency
    _hrFilterB = [0.0675, 0.0, -0.1349, 0.0, 0.0675];
    _hrFilterA = [1.0, -2.7488, 2.9562, -1.4589, 0.2762];

    // For RR: 0.1-1 Hz at 100 Hz sample rate
    _rrFilterB = [0.0201, 0.0, -0.0402, 0.0, 0.0201];
    _rrFilterA = [1.0, -3.6717, 5.0680, -3.1160, 0.7199];
  }

  /// Process new pressure samples
  /// Returns BcgResult with HR, RR, and quality metrics
  BcgResult processSamples(List<int> pressureSamples) {
    // Add samples to buffer
    for (final sample in pressureSamples) {
      _pressureBuffer.add(sample.toDouble());
    }

    // Trim buffer to max size (keep last 60 seconds)
    final maxSamples = sampleRate * 60;
    while (_pressureBuffer.length > maxSamples) {
      _pressureBuffer.removeAt(0);
    }

    // Need minimum data to process
    if (_pressureBuffer.length < sampleRate * minBufferSeconds) {
      return BcgResult(
        heartRateBpm: 0,
        respiratoryRateBpm: 0,
        signalQuality: 0,
        confidence: 0,
        isValid: false,
      );
    }

    // Extract heart rate
    final hrResult = _extractHeartRate();

    // Extract respiratory rate
    final rrResult = _extractRespiratoryRate();

    // Calculate signal quality
    final quality = _calculateSignalQuality();

    // Update last values
    if (hrResult.isValid) _lastHeartRate = hrResult.value;
    if (rrResult.isValid) _lastRespiratoryRate = rrResult.value;
    _lastSignalQuality = quality;

    return BcgResult(
      heartRateBpm: _lastHeartRate.round(),
      respiratoryRateBpm: _lastRespiratoryRate.round(),
      signalQuality: quality,
      confidence: (hrResult.confidence + rrResult.confidence) / 2,
      isValid: hrResult.isValid && rrResult.isValid,
      hrConfidence: hrResult.confidence,
      rrConfidence: rrResult.confidence,
    );
  }

  /// Extract heart rate using FFT and peak detection
  _ExtractionResult _extractHeartRate() {
    // Get last N seconds for HR window
    final windowSamples = sampleRate * hrWindowSeconds;
    if (_pressureBuffer.length < windowSamples) {
      return _ExtractionResult(
        value: _lastHeartRate,
        confidence: 0,
        isValid: false,
      );
    }

    // Get window
    final window = _pressureBuffer.sublist(
      _pressureBuffer.length - windowSamples,
    );

    // Apply bandpass filter for HR band
    final filtered = _applyFilter(
      window,
      _hrFilterB,
      _hrFilterA,
      _hrFilterState,
    );

    // Method 1: FFT-based frequency estimation
    final fftResult = _fftPeakFrequency(filtered, hrMinFreq, hrMaxFreq);

    // Method 2: Time-domain peak detection
    final peakResult = _timeDomainPeakDetection(filtered, hrMinFreq, hrMaxFreq);

    // Combine results (weighted average based on confidence)
    double hrEstimate;
    double confidence;

    if (fftResult.confidence > 0.5 && peakResult.confidence > 0.5) {
      // Both methods confident - average
      hrEstimate = (fftResult.value + peakResult.value) / 2;
      confidence = (fftResult.confidence + peakResult.confidence) / 2;
    } else if (fftResult.confidence > peakResult.confidence) {
      hrEstimate = fftResult.value;
      confidence = fftResult.confidence;
    } else {
      hrEstimate = peakResult.value;
      confidence = peakResult.confidence;
    }

    // Convert frequency to BPM
    final hrBpm = hrEstimate * 60;

    // Validate range
    if (hrBpm < 40 || hrBpm > 220) {
      return _ExtractionResult(
        value: _lastHeartRate,
        confidence: 0,
        isValid: false,
      );
    }

    return _ExtractionResult(
      value: hrBpm,
      confidence: confidence,
      isValid: confidence > 0.3,
    );
  }

  /// Extract respiratory rate using FFT on low-frequency band
  _ExtractionResult _extractRespiratoryRate() {
    // Get last N seconds for RR window
    final windowSamples = sampleRate * rrWindowSeconds;
    if (_pressureBuffer.length < windowSamples) {
      return _ExtractionResult(
        value: _lastRespiratoryRate,
        confidence: 0,
        isValid: false,
      );
    }

    // Get window
    final window = _pressureBuffer.sublist(
      _pressureBuffer.length - windowSamples,
    );

    // Apply bandpass filter for RR band
    final filtered = _applyFilter(
      window,
      _rrFilterB,
      _rrFilterA,
      _rrFilterState,
    );

    // FFT-based frequency estimation for respiratory rate
    final fftResult = _fftPeakFrequency(filtered, rrMinFreq, rrMaxFreq);

    // Convert frequency to breaths per minute
    final rrBpm = fftResult.value * 60;

    // Validate range
    if (rrBpm < 5 || rrBpm > 60) {
      return _ExtractionResult(
        value: _lastRespiratoryRate,
        confidence: 0,
        isValid: false,
      );
    }

    return _ExtractionResult(
      value: rrBpm,
      confidence: fftResult.confidence,
      isValid: fftResult.confidence > 0.3,
    );
  }

  /// Apply IIR filter to signal
  List<double> _applyFilter(
    List<double> signal,
    List<double> b,
    List<double> a,
    List<double> state,
  ) {
    final result = List<double>.filled(signal.length, 0);
    final order = b.length - 1;

    for (int i = 0; i < signal.length; i++) {
      // Direct form II transposed implementation
      result[i] = b[0] * signal[i] + state[0];

      for (int j = 0; j < order - 1; j++) {
        state[j] = b[j + 1] * signal[i] - a[j + 1] * result[i] + state[j + 1];
      }
      state[order - 1] = b[order] * signal[i] - a[order] * result[i];
    }

    return result;
  }

  /// FFT-based peak frequency detection
  _ExtractionResult _fftPeakFrequency(
    List<double> signal,
    double minFreq,
    double maxFreq,
  ) {
    // Zero-pad to next power of 2
    final n = _nextPowerOf2(signal.length);
    final paddedSignal = List<double>.filled(n, 0);
    for (int i = 0; i < signal.length; i++) {
      paddedSignal[i] = signal[i];
    }

    // Apply Hanning window
    for (int i = 0; i < signal.length; i++) {
      paddedSignal[i] *= 0.5 * (1 - cos(2 * pi * i / (signal.length - 1)));
    }

    // Compute FFT
    final fft = FFT(n);
    final spectrum = fft.realFft(paddedSignal);

    // Compute magnitude spectrum
    final magnitudes = List<double>.filled(n ~/ 2, 0);
    for (int i = 0; i < n ~/ 2; i++) {
      magnitudes[i] = spectrum[i].x.abs();
    }

    // Find frequency bins for search range
    final freqResolution = sampleRate / n;
    final minBin = (minFreq / freqResolution).floor();
    final maxBin = (maxFreq / freqResolution).ceil();

    // Find peak in range
    int peakBin = minBin;
    double peakMag = 0;
    double totalMag = 0;

    for (int i = minBin; i < maxBin && i < magnitudes.length; i++) {
      if (magnitudes[i] > peakMag) {
        peakMag = magnitudes[i];
        peakBin = i;
      }
      totalMag += magnitudes[i];
    }

    // Calculate confidence based on peak prominence
    final confidence = totalMag > 0
        ? (peakMag / totalMag) * (maxBin - minBin)
        : 0;

    // Convert bin to frequency
    final peakFreq = peakBin * freqResolution;

    return _ExtractionResult(
      value: peakFreq,
      confidence: confidence.clamp(0, 1).toDouble(),
      isValid: peakMag > 0,
    );
  }

  /// Time-domain peak detection for heart rate
  _ExtractionResult _timeDomainPeakDetection(
    List<double> signal,
    double minFreq,
    double maxFreq,
  ) {
    // Minimum and maximum samples between peaks
    final minSamples = (sampleRate / maxFreq).floor();
    final maxSamples = (sampleRate / minFreq).ceil();

    // Find peaks
    final peaks = <int>[];
    final threshold = _calculateAdaptiveThreshold(signal);

    for (int i = minSamples; i < signal.length - minSamples; i++) {
      if (_isPeak(signal, i, threshold, minSamples)) {
        peaks.add(i);
      }
    }

    if (peaks.length < 2) {
      return _ExtractionResult(value: 0, confidence: 0, isValid: false);
    }

    // Calculate intervals between peaks
    final intervals = <double>[];
    for (int i = 1; i < peaks.length; i++) {
      final interval = (peaks[i] - peaks[i - 1]).toDouble();
      if (interval >= minSamples && interval <= maxSamples) {
        intervals.add(interval);
      }
    }

    if (intervals.isEmpty) {
      return _ExtractionResult(value: 0, confidence: 0, isValid: false);
    }

    // Calculate mean interval and frequency
    final meanInterval = intervals.reduce((a, b) => a + b) / intervals.length;
    final freq = sampleRate / meanInterval;

    // Calculate confidence based on interval consistency
    final variance =
        intervals.map((i) => pow(i - meanInterval, 2)).reduce((a, b) => a + b) /
        intervals.length;
    final stdDev = sqrt(variance);
    final cv = stdDev / meanInterval; // Coefficient of variation
    final confidence =
        (1 - cv.clamp(0, 1)) * (intervals.length / 10).clamp(0, 1);

    return _ExtractionResult(
      value: freq,
      confidence: confidence.toDouble(),
      isValid: confidence > 0.3,
    );
  }

  bool _isPeak(
    List<double> signal,
    int index,
    double threshold,
    int minDistance,
  ) {
    if (signal[index] < threshold) return false;

    // Check if local maximum
    for (int i = 1; i <= minDistance ~/ 2; i++) {
      if (index - i >= 0 && signal[index - i] >= signal[index]) return false;
      if (index + i < signal.length && signal[index + i] >= signal[index])
        return false;
    }

    return true;
  }

  double _calculateAdaptiveThreshold(List<double> signal) {
    // Use median + 0.5 * MAD as threshold
    final sorted = List<double>.from(signal)..sort();
    final median = sorted[sorted.length ~/ 2];

    final deviations = signal.map((x) => (x - median).abs()).toList()..sort();
    final mad = deviations[deviations.length ~/ 2];

    return median + 0.5 * mad;
  }

  /// Calculate signal quality (0-100)
  int _calculateSignalQuality() {
    if (_pressureBuffer.length < sampleRate * 5) return 0;

    final window = _pressureBuffer.sublist(
      _pressureBuffer.length - sampleRate * 5,
    );

    // Check signal variance (too low = no signal, too high = noise)
    final mean = window.reduce((a, b) => a + b) / window.length;
    final variance =
        window.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
        window.length;
    final stdDev = sqrt(variance);

    // Check for clipping (values at min/max)
    final minVal = window.reduce((a, b) => a < b ? a : b);
    final maxVal = window.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    // Score based on signal characteristics
    double score = 100;

    // Penalize low variance (weak signal)
    if (stdDev < 10) score -= (10 - stdDev) * 5;

    // Penalize very high variance (noise)
    if (stdDev > 500) score -= (stdDev - 500) * 0.1;

    // Penalize small dynamic range
    if (range < 100) score -= (100 - range) * 0.3;

    // Penalize clipping
    final clippedCount = window.where((x) => x == minVal || x == maxVal).length;
    score -= (clippedCount / window.length) * 50;

    return score.clamp(0, 100).round();
  }

  int _nextPowerOf2(int n) {
    int power = 1;
    while (power < n) {
      power *= 2;
    }
    return power;
  }

  /// Reset algorithm state
  void reset() {
    _pressureBuffer.clear();
    _filteredBuffer.clear();
    _hrBuffer.clear();
    _rrBuffer.clear();
    _rPeakIndices.clear();
    _rPeakAmplitudes.clear();
    _lastHeartRate = 0;
    _lastRespiratoryRate = 0;
    _lastSignalQuality = 0;
    _hrFilterState.fillRange(0, _hrFilterState.length, 0);
    _rrFilterState.fillRange(0, _rrFilterState.length, 0);
  }

  /// Get current buffer length in seconds
  double get bufferLengthSeconds => _pressureBuffer.length / sampleRate;

  /// Get last computed values
  double get lastHeartRate => _lastHeartRate;
  double get lastRespiratoryRate => _lastRespiratoryRate;
  int get lastSignalQuality => _lastSignalQuality;
}

/// Result of BCG processing
class BcgResult {
  final int heartRateBpm;
  final int respiratoryRateBpm;
  final int signalQuality;
  final double confidence;
  final bool isValid;
  final double hrConfidence;
  final double rrConfidence;

  BcgResult({
    required this.heartRateBpm,
    required this.respiratoryRateBpm,
    required this.signalQuality,
    required this.confidence,
    required this.isValid,
    this.hrConfidence = 0,
    this.rrConfidence = 0,
  });

  @override
  String toString() =>
      'BcgResult(HR: $heartRateBpm, RR: $respiratoryRateBpm, Q: $signalQuality%)';
}

/// Internal extraction result
class _ExtractionResult {
  final double value;
  final double confidence;
  final bool isValid;

  _ExtractionResult({
    required this.value,
    required this.confidence,
    required this.isValid,
  });
}

/// BCG Algorithm for raw mode (128 Hz) - used during surgery
class BcgAlgorithmRaw extends BcgAlgorithm {
  BcgAlgorithmRaw() : super(sampleRate: 128);

  /// Process raw ADC samples (unfiltered from collar)
  BcgResult processRawSamples(List<int> rawAdcSamples) {
    // Apply additional preprocessing for raw samples
    final preprocessed = _preprocessRaw(rawAdcSamples);
    return processSamples(preprocessed);
  }

  List<int> _preprocessRaw(List<int> samples) {
    // Remove DC offset
    final mean = samples.reduce((a, b) => a + b) / samples.length;
    return samples.map((s) => (s - mean.round())).toList();
  }
}
