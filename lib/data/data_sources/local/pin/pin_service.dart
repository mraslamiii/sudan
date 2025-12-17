import 'dart:convert';
import '../preferences/preferences_service.dart';

/// PIN Type enum
enum PinType {
  admin,
  user,
}

/// PIN Service
/// Manages allowed PIN codes for accessing definition screens
/// Supports two types: Admin PIN (for sensitive operations) and User PIN (for personal settings)
class PinService {
  final PreferencesService _preferencesService;
  static const String _adminPinsKey = 'admin_pins';
  static const String _userPinKey = 'user_pin';
  static const int _pinLength = 4;
  static const String _defaultUserPin = '1234';

  PinService(this._preferencesService);

  // ========== Admin PIN Methods ==========
  
  /// Get all allowed Admin PINs
  List<String> getAllowedAdminPins() {
    final pinsJson = _preferencesService.getString(_adminPinsKey);
    if (pinsJson == null || pinsJson.isEmpty) {
      // Return default PINs if none configured
      return _getDefaultAdminPins();
    }
    try {
      final List<dynamic> pinsList = json.decode(pinsJson);
      return pinsList.cast<String>();
    } catch (e) {
      return _getDefaultAdminPins();
    }
  }

  /// Set allowed Admin PINs
  Future<bool> setAllowedAdminPins(List<String> pins) async {
    // Validate all PINs
    for (final pin in pins) {
      if (!_isValidAdminPin(pin)) {
        return false;
      }
    }
    final pinsJson = json.encode(pins);
    return await _preferencesService.setString(_adminPinsKey, pinsJson);
  }

  /// Add an Admin PIN to allowed list
  Future<bool> addAdminPin(String pin) async {
    if (!_isValidAdminPin(pin)) {
      return false;
    }
    final currentPins = getAllowedAdminPins();
    if (currentPins.contains(pin)) {
      return true; // Already exists
    }
    currentPins.add(pin);
    return await setAllowedAdminPins(currentPins);
  }

  /// Remove an Admin PIN from allowed list
  Future<bool> removeAdminPin(String pin) async {
    final currentPins = getAllowedAdminPins();
    currentPins.remove(pin);
    return await setAllowedAdminPins(currentPins);
  }

  /// Verify if an Admin PIN is allowed
  bool verifyAdminPin(String pin) {
    if (!_isValidAdminPin(pin)) {
      return false;
    }
    final allowedPins = getAllowedAdminPins();
    return allowedPins.contains(pin);
  }

  // ========== User PIN Methods ==========
  
  /// Get User PIN
  String getUserPin() {
    final pin = _preferencesService.getString(_userPinKey);
    return pin ?? _defaultUserPin;
  }

  /// Set User PIN
  Future<bool> setUserPin(String pin) async {
    // User PIN can be simple (like 1234), so we only check length and digits
    if (pin.length != _pinLength || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      return false;
    }
    return await _preferencesService.setString(_userPinKey, pin);
  }

  /// Verify User PIN
  bool verifyUserPin(String pin) {
    if (pin.length != _pinLength || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      return false;
    }
    final userPin = getUserPin();
    return pin == userPin;
  }

  // ========== Legacy Methods (for backward compatibility) ==========
  
  /// Get all allowed PINs (Admin PINs - for backward compatibility)
  @Deprecated('Use getAllowedAdminPins() instead')
  List<String> getAllowedPins() {
    return getAllowedAdminPins();
  }

  /// Set allowed PINs (Admin PINs - for backward compatibility)
  @Deprecated('Use setAllowedAdminPins() instead')
  Future<bool> setAllowedPins(List<String> pins) async {
    return await setAllowedAdminPins(pins);
  }

  /// Add a PIN to allowed list (Admin PINs - for backward compatibility)
  @Deprecated('Use addAdminPin() instead')
  Future<bool> addPin(String pin) async {
    return await addAdminPin(pin);
  }

  /// Remove a PIN from allowed list (Admin PINs - for backward compatibility)
  @Deprecated('Use removeAdminPin() instead')
  Future<bool> removePin(String pin) async {
    return await removeAdminPin(pin);
  }

  /// Verify if a PIN is allowed (Admin PINs - for backward compatibility)
  @Deprecated('Use verifyAdminPin() or verifyUserPin() instead')
  bool verifyPin(String pin) {
    return verifyAdminPin(pin);
  }

  /// Verify PIN by type
  bool verifyPinByType(String pin, PinType type) {
    switch (type) {
      case PinType.admin:
        return verifyAdminPin(pin);
      case PinType.user:
        return verifyUserPin(pin);
    }
  }

  /// Check if Admin PIN is valid format (4 digits, hard to guess)
  /// Public method for external validation
  bool isValidAdminPin(String pin) {
    return _isValidAdminPin(pin);
  }

  /// Check if Admin PIN is valid format (4 digits, hard to guess)
  bool _isValidAdminPin(String pin) {
    if (pin.length != _pinLength) {
      return false;
    }
    // Must be 4 digits
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      return false;
    }
    // Check for common weak patterns
    if (_isWeakPin(pin)) {
      return false;
    }
    return true;
  }

  /// Check if PIN is valid format (for backward compatibility - Admin PIN)
  /// Public method for external validation
  @Deprecated('Use isValidAdminPin() instead')
  bool isValidPin(String pin) {
    return _isValidAdminPin(pin);
  }

  /// Check if PIN is weak (easy to guess)
  bool _isWeakPin(String pin) {
    // All same digits (e.g., 1111, 2222)
    if (pin[0] == pin[1] && pin[1] == pin[2] && pin[2] == pin[3]) {
      return true;
    }
    // Sequential ascending (e.g., 1234, 5678)
    if (_isSequentialAscending(pin)) {
      return true;
    }
    // Sequential descending (e.g., 4321, 8765)
    if (_isSequentialDescending(pin)) {
      return true;
    }
    // Common patterns (e.g., 0000, 1234, 1111)
    final commonPins = ['0000', '1234', '1111', '2222', '3333', '4444', 
                        '5555', '6666', '7777', '8888', '9999'];
    if (commonPins.contains(pin)) {
      return true;
    }
    return false;
  }

  bool _isSequentialAscending(String pin) {
    for (int i = 0; i < pin.length - 1; i++) {
      final current = int.tryParse(pin[i]);
      final next = int.tryParse(pin[i + 1]);
      if (current == null || next == null || next != current + 1) {
        return false;
      }
    }
    return true;
  }

  bool _isSequentialDescending(String pin) {
    for (int i = 0; i < pin.length - 1; i++) {
      final current = int.tryParse(pin[i]);
      final next = int.tryParse(pin[i + 1]);
      if (current == null || next == null || next != current - 1) {
        return false;
      }
    }
    return true;
  }

  /// Get default Admin PINs (hard to guess)
  List<String> _getDefaultAdminPins() {
    return [
      '2847', // Random, hard to guess
      '7391', // Random, hard to guess
      '5628', // Random, hard to guess
    ];
  }

  /// Check if Admin PIN management is initialized
  bool isAdminPinInitialized() {
    final pinsJson = _preferencesService.getString(_adminPinsKey);
    return pinsJson != null && pinsJson.isNotEmpty;
  }

  /// Check if User PIN is initialized
  bool isUserPinInitialized() {
    final pin = _preferencesService.getString(_userPinKey);
    return pin != null && pin.isNotEmpty;
  }

  /// Initialize Admin PINs with default PINs if not already initialized
  Future<bool> initializeAdminPinsIfNeeded() async {
    if (!isAdminPinInitialized()) {
      return await setAllowedAdminPins(_getDefaultAdminPins());
    }
    return true;
  }

  /// Initialize User PIN with default PIN if not already initialized
  Future<bool> initializeUserPinIfNeeded() async {
    if (!isUserPinInitialized()) {
      return await setUserPin(_defaultUserPin);
    }
    return true;
  }

  /// Initialize both PIN types if needed (for backward compatibility)
  @Deprecated('Use initializeAdminPinsIfNeeded() and initializeUserPinIfNeeded() instead')
  Future<bool> initializeIfNeeded() async {
    await initializeAdminPinsIfNeeded();
    await initializeUserPinIfNeeded();
    return true;
  }

  /// Check if PIN management is initialized (for backward compatibility)
  @Deprecated('Use isAdminPinInitialized() instead')
  bool isInitialized() {
    return isAdminPinInitialized();
  }
}

