import '../constants/usb_serial_constants.dart';

/// USB Serial Protocol Handler
/// Handles framing, ACK/NACK, and message encoding/decoding
class UsbSerialProtocol {
  /// Encode a message with frame markers
  /// Format: [STX][Type][Length][Data][Checksum][ETX]
  static List<int> encodeMessage({
    required int messageType,
    required String data,
  }) {
    final dataBytes = data.codeUnits;
    final length = dataBytes.length;

    // Calculate simple checksum (sum of all bytes)
    int checksum = messageType + length;
    for (final byte in dataBytes) {
      checksum += byte;
    }
    checksum = checksum & 0xFF; // Keep only lower 8 bits

    // Build frame: [STX][Type][Length][Data...][Checksum][ETX]
    final frame = <int>[
      UsbSerialConstants.frameStart, // STX
      messageType,
      length,
      ...dataBytes,
      checksum,
      UsbSerialConstants.frameEnd, // ETX
    ];

    return frame;
  }

  /// Decode a message from received bytes
  /// Returns null if frame is invalid
  static UsbSerialMessage? decodeMessage(List<int> bytes) {
    if (bytes.isEmpty) return null;

    // Find STX
    int startIdx = -1;
    for (int i = 0; i < bytes.length; i++) {
      if (bytes[i] == UsbSerialConstants.frameStart) {
        startIdx = i;
        break;
      }
    }

    if (startIdx == -1) return null;

    // Find ETX
    int endIdx = -1;
    for (int i = startIdx + 1; i < bytes.length; i++) {
      if (bytes[i] == UsbSerialConstants.frameEnd) {
        endIdx = i;
        break;
      }
    }

    if (endIdx == -1 || endIdx < startIdx + 3) return null;

    // Extract frame data
    final frameData = bytes.sublist(startIdx + 1, endIdx);
    if (frameData.length < 3)
      return null; // Need at least [Type][Length][Checksum]

    final messageType = frameData[0];
    final length = frameData[1];
    final checksum = frameData[frameData.length - 1];

    // Extract data
    if (frameData.length < 3 + length) return null;
    final dataBytes = frameData.sublist(2, 2 + length);

    // Verify checksum
    int calculatedChecksum = messageType + length;
    for (final byte in dataBytes) {
      calculatedChecksum += byte;
    }
    calculatedChecksum = calculatedChecksum & 0xFF;

    if (calculatedChecksum != checksum) {
      return null; // Invalid checksum
    }

    final data = String.fromCharCodes(dataBytes);

    return UsbSerialMessage(type: messageType, data: data);
  }

  /// Create ACK frame
  static List<int> createAck() {
    return [
      UsbSerialConstants.frameStart,
      UsbSerialConstants.frameAck,
      UsbSerialConstants.frameEnd,
    ];
  }

  /// Create NACK frame
  static List<int> createNack() {
    return [
      UsbSerialConstants.frameStart,
      UsbSerialConstants.frameNack,
      UsbSerialConstants.frameEnd,
    ];
  }

  /// Create Heartbeat frame
  static List<int> createHeartbeat() {
    return encodeMessage(
      messageType: UsbSerialConstants.msgTypeHeartbeat,
      data: 'PING',
    );
  }

  /// Check if bytes contain a complete frame
  static bool hasCompleteFrame(List<int> bytes) {
    if (bytes.isEmpty) return false;

    int startIdx = -1;
    for (int i = 0; i < bytes.length; i++) {
      if (bytes[i] == UsbSerialConstants.frameStart) {
        startIdx = i;
        break;
      }
    }

    if (startIdx == -1) return false;

    for (int i = startIdx + 1; i < bytes.length; i++) {
      if (bytes[i] == UsbSerialConstants.frameEnd) {
        return true;
      }
    }

    return false;
  }
}

/// Represents a decoded USB Serial message
class UsbSerialMessage {
  final int type;
  final String data;

  UsbSerialMessage({required this.type, required this.data});

  bool get isCommand => type == UsbSerialConstants.msgTypeCommand;
  bool get isRequest => type == UsbSerialConstants.msgTypeRequest;
  bool get isResponse => type == UsbSerialConstants.msgTypeResponse;
  bool get isHeartbeat => type == UsbSerialConstants.msgTypeHeartbeat;
  bool get isPushState => type == UsbSerialConstants.msgTypePushState;
  bool get isAck =>
      data.codeUnits.isNotEmpty &&
      data.codeUnits[0] == UsbSerialConstants.frameAck;
  bool get isNack =>
      data.codeUnits.isNotEmpty &&
      data.codeUnits[0] == UsbSerialConstants.frameNack;
}
