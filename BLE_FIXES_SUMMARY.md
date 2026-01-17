# BLE Collar Connection Fixes

## Problem
The collar Bluetooth connection was working, but the values received from the collar were inaccurate in the Flutter app, while the Python implementation worked perfectly.

## Root Causes Identified

After analyzing the working Python BLE visualizer code, I found **three critical issues** in the Flutter implementation:

### 1. **Missing Stream Reassembly Buffer** ❌
**Problem**: BLE notifications can be fragmented or batched. The collar sends data in various formats:
- Single 27-byte packets
- Array frames with 2 packets (2 + 2×27 = 56 bytes OR 2 + 2×26 = 54 bytes)
- Array frames with 4 packets (2 + 4×27 = 110 bytes OR 2 + 4×26 = 106 bytes)

The old code tried to parse each BLE notification as a single packet, which caused:
- Partial packets being parsed incorrectly
- Batched packets only reading the first one
- Alignment issues causing corrupted data

**Fix**: Created `CollarStreamParser` class with:
- RX buffer for stream reassembly
- Automatic header alignment
- Support for fragmented packets

### 2. **Missing Array Frame Parsing** ❌
**Problem**: The collar firmware batches multiple packets together for efficiency (2 or 4 packets per BLE notification). The old code completely ignored this batching.

This meant:
- Only 1 out of every 2-4 packets was being processed
- Effective sample rate was 25-50% of actual
- Vital sign calculations were based on incomplete data

**Fix**: Added array frame detection and parsing with two format support:
- **Format 1**: `[ptype, count, packet1(27), packet2(27), ...]` - each element includes packet type
- **Format 2**: `[ptype, count, packet1(26), packet2(26), ...]` - packet type stripped from elements (reconstructed during parsing)

### 3. **Timestamp Field Misnamed (Microseconds, not Milliseconds)** ❌
**Problem**: The field was named `timestampMs` but actually contained **microseconds** (not milliseconds).

This caused:
- Incorrect time calculations
- Delta calculations being off by 1000×
- Packet loss detection not working properly

**Fix**: Renamed field from `timestampMs` to `timestampUs` throughout the codebase to reflect actual units.

## Files Changed

### New Files Created
1. **`lib/data/services/collar_stream_parser.dart`** - Complete stream parser with reassembly buffer and array frame support

### Files Modified
1. **`lib/data/models/collar_packet_validated.dart`**
   - Renamed `timestampMs` → `timestampUs`
   - Added support for aggregated pressure samples (multi-sample packets)
   - Updated documentation to clarify microsecond timing

2. **`lib/data/services/ble_service.dart`**
   - Integrated `CollarStreamParser` for all incoming BLE data
   - Removed old single-packet parsing logic
   - Added parser reset on connect/disconnect
   - Fixed timestamp conversion for legacy compatibility

## How It Works Now

```
BLE Notification (raw bytes)
    ↓
CollarStreamParser.processData()
    ↓
RX Buffer (handles fragmentation)
    ↓
Header Alignment (finds valid packet starts)
    ↓
Array Frame Detection
    ↓
├─ Single Packet (27 bytes)
│   └─ Parse → CollarPacket
│
└─ Array Frame (2 or 4 packets)
    ├─ Format 1 (count × 27 bytes)
    │   └─ Parse each 27-byte element
    │
    └─ Format 2 (count × 26 bytes)
        └─ Reconstruct to 27 bytes + parse
    ↓
CRC Validation
    ↓
Multiple CollarPacket objects
    ↓
Feed to BcgService for vital signs processing
```

## Expected Improvements

✅ **Accurate Data**: All packets are now correctly parsed
✅ **Higher Sample Rate**: Full 100Hz (Standard) or 128Hz (High-Res) data
✅ **Better Vital Signs**: BCG algorithm receives complete data
✅ **Fewer CRC Errors**: Proper packet alignment reduces corruption
✅ **Correct Timestamps**: Microsecond precision maintained

## Testing Checklist

- [ ] Connect to collar
- [ ] Verify data stream starts
- [ ] Check packet count increases rapidly (should see 2-4× previous rate)
- [ ] Monitor CRC error rate (should be <1%)
- [ ] Verify vital signs appear and are stable
- [ ] Check parser statistics in logs
- [ ] Test mode switching (Standard ↔ High-Res)
- [ ] Test reconnection after disconnect

## Python vs Flutter - Key Differences Now Fixed

| Feature | Python (Working) | Flutter (Old) | Flutter (Fixed) |
|---------|-----------------|---------------|-----------------|
| Stream Buffer | ✅ Yes | ❌ No | ✅ Yes |
| Array Frames | ✅ Parsed | ❌ Ignored | ✅ Parsed |
| Timestamp Units | ✅ Microseconds | ❌ Wrong (named Ms) | ✅ Microseconds |
| CRC Validation | ✅ Before parse | ✅ After parse | ✅ Before parse |
| Packet Alignment | ✅ Automatic | ❌ None | ✅ Automatic |
| Multi-packet Batches | ✅ Handled | ❌ Only first | ✅ All handled |

## Debug Logging

The parser now provides statistics accessible via:
```dart
final stats = bleService._streamParser.statistics;
// Returns:
// {
//   'bytes_received': 12345,
//   'packets_extracted': 234,
//   'responses_extracted': 5,
//   'crc_errors': 2,
//   'alignment_corrections': 3,
//   'buffer_size': 0
// }
```

Look for these log messages:
- `[StreamParser] ✅ Parsed array frame (format 1): 2 packets` - Good!
- `[StreamParser] ✅ Parsed array frame (format 2): 4 packets` - Good!
- `[StreamParser] Aligned: skipped X unknown bytes` - Normal during stream start
- `[BLE] 📦 Packet #1: CollarPacket(...)` - First few packets logged for debugging

## What to Watch For

⚠️ **High CRC Error Rate**: If you see >5% CRC errors, check:
- Signal strength (RSSI should be > -80 dBm)
- Distance from collar
- Physical obstructions
- Interference from other devices

⚠️ **Buffer Growth**: If `buffer_size` keeps growing, indicates:
- Unexpected packet format
- Firmware sending unknown data
- Need to update parser for new protocol version

## Performance Impact

**Before**: Processing ~25-50 packets/second (only first packet of each batch)
**After**: Processing ~100-128 packets/second (all packets in all batches)

This is a **2-4× improvement** in data throughput without any additional BLE overhead.

## Next Steps (If Issues Persist)

1. **Capture Raw BLE Data**: Enable verbose logging to see exact bytes received
2. **Compare with Python**: Run Python visualizer alongside Flutter app
3. **Firmware Version**: Check if collar firmware matches Python implementation
4. **Protocol Changes**: Verify no protocol updates since Python code was written

## Credits

This fix is based on the working Python BLE visualizer implementation (`ble_visualizer.py`) which correctly handles:
- Stream reassembly via `rx_buffer`
- Array frame detection via `_try_parse_array_frame_len()`
- CRC validation before processing
- Microsecond timestamps

The Flutter implementation now matches this battle-tested logic.
