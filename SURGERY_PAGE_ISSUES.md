# Surgery Page Issues & Fixes

## Issues Found in Screenshot

1. ❌ **Heart Rate showing "1... bpm"** - Invalid/low vitals values
2. ❌ **Temperature showing "-... °C"** - No valid temperature data
3. ❌ **Signal Quality showing 0%** - Already fixed in BLE service, but may still show 0 if no data buffered
4. ❌ **WebSocket not connecting** - Surgery start doesn't initialize websocket connection

## Root Causes

### 1. WebSocket Never Connects During Surgery

**File**: [lib/presentation/controllers/session_controller.dart](lib/presentation/controllers/session_controller.dart)
**Problem**: The `startSurgery()` method doesn't call websocket connection

```dart
Future<bool> startSurgery({...}) async {
  // ... updates session in database
  // ❌ MISSING: No websocket connection!
  // Should call: await _wsService.connectToRelay(sessionId: currentSession.value!.id);
}
```

**Impact**:
- Laptop never receives vitals data in real-time
- Mobile shows "0%" for laptop connection status
- No data streaming to backend

### 2. Collar Data Not Being Streamed to WebSocket

**Problem**: BLE service receives data but doesn't send it via websocket

The BLE service has:
- ✅ `vitalsStream` - emits vitals locally
- ❌ NO integration with websocket service to send data

**What's Missing**:
```dart
// In BleService, after emitting vitals:
_vitalsController.add(vitals);
// Should also send via websocket:
// _wsService.sendCollarData(legacyPacket);
```

### 3. Invalid Vitals Displaying

**Problem**: Early in data collection, BCG algorithm returns invalid vitals:
- Heart Rate: 0-1 bpm (invalid, should be 40-220)
- Temperature: negative or zero values
- Signal Quality: 0% (not enough buffered data yet)

**Why**: BCG algorithm needs ~5 seconds of buffered data before it can calculate valid vitals. Until then, it returns placeholder values.

## Fixes Required

### Fix 1: Connect WebSocket When Surgery Starts

**File**: `lib/presentation/controllers/session_controller.dart`

Add websocket connection in `startSurgery`:

```dart
Future<bool> startSurgery({...}) async {
  try {
    // ... existing code ...

    // NEW: Connect to websocket for real-time streaming
    try {
      await _wsService.connectToRelay(
        sessionId: currentSession.value!.id,
      );
      print('[Session] 📡 WebSocket connected for surgery monitoring');
    } catch (e) {
      print('[Session] ⚠️ WebSocket connection failed: $e');
      // Continue anyway - websocket is optional
    }

    // ... rest of code ...
  }
}
```

### Fix 2: Stream Collar Data via WebSocket

**File**: `lib/data/services/ble_service.dart`

Need to inject WebSocketService and stream data:

```dart
class BleService extends GetxService {
  final WebSocketService _wsService = Get.find<WebSocketService>();

  // In _onDataReceived, after creating legacyPacket:
  void _onDataReceived(List<int> data) {
    // ... existing packet parsing ...

    // Emit raw packet to stream
    _dataController.add(legacyPacket);

    // NEW: Send to websocket if connected
    if (_wsService.isConnected) {
      _wsService.sendCollarData(legacyPacket);
    }
  }
}
```

### Fix 3: Handle Invalid Vitals in UI

**Option A**: Don't display vitals until they're valid

```dart
Widget _buildVitalsSection() {
  return Obx(() {
    final vitals = _sessionController.latestVitals.value;
    final isValid = vitals != null &&
                    vitals.heartRateBpm > 30 &&
                    vitals.temperatureC > 0;

    return Row(
      children: [
        _VitalDisplay(
          label: 'Heart Rate',
          value: isValid ? vitals.heartRateBpm : null,  // Show "--" if null
          unit: 'bpm',
          // ...
        ),
      ],
    );
  });
}
```

**Option B**: Show "Collecting..." message for first few seconds

```dart
if (_elapsedTime < 5) {
  return Center(child: Text('Collecting baseline data...'));
}
```

### Fix 4: Disconnect WebSocket When Surgery Ends

```dart
Future<bool> endSurgery() async {
  // ... existing code ...

  // Disconnect websocket
  await _wsService.disconnect();

  // ... rest ...
}
```

## Testing Checklist

After fixes:

- [ ] Start surgery → Check websocket connects (laptop icon shows green)
- [ ] Wait 5 seconds → Vitals should appear with valid values
- [ ] Check laptop receives real-time data
- [ ] End surgery → Websocket disconnects cleanly
- [ ] Check no errors in console

## Additional Notes

**Vitals Buffer Time**: The BCG algorithm needs:
- **Standard Mode (100Hz)**: ~5 seconds of data = 500 samples
- **High-Res Mode (128Hz)**: ~5 seconds of data = 640 samples

Before this buffer is full:
- Signal Quality = 0%
- Heart Rate = 0-1 bpm (invalid)
- Respiratory Rate = 0 brpm (invalid)
- Temperature = may show raw sensor value

This is **normal and expected** - the UI should handle this gracefully by:
1. Showing "Collecting data..." message
2. Or showing "--" instead of invalid numbers
3. Only displaying vitals once `result.isValid == true`
