import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Beautiful Door Phone Alert Dialog
/// Shows when door phone rings, similar to intercom call UI
class IPhoneAlertDialog extends StatefulWidget {
  final String deviceName;
  final String? imageUrl;
  final VoidCallback? onOpen;
  final VoidCallback? onDismiss;

  const IPhoneAlertDialog({
    super.key,
    required this.deviceName,
    this.imageUrl,
    this.onOpen,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required String deviceName,
    String? imageUrl,
    VoidCallback? onOpen,
    VoidCallback? onDismiss,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (dialogContext) => IPhoneAlertDialog(
        deviceName: deviceName,
        imageUrl: imageUrl,
        onOpen: onOpen,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<IPhoneAlertDialog> createState() => _IPhoneAlertDialogState();
}

class _IPhoneAlertDialogState extends State<IPhoneAlertDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for entrance
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    // Pulse animation for the image
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Slide animation for buttons
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleOpen() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    widget.onOpen?.call();
  }

  void _handleDismiss() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: size.width * 0.85,
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0xFF1C1C1E),
                              const Color(0xFF000000),
                            ]
                          : [
                              const Color(0xFFFFFFFF),
                              const Color(0xFFF5F5F7),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // iPhone Image Section
                        Container(
                          padding: const EdgeInsets.only(
                            top: 50,
                            bottom: 30,
                            left: 30,
                            right: 30,
                          ),
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.2),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 180,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark
                                            ? const Color(0xFF2C2C2E)
                                            : const Color(0xFFF2F2F7),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: widget.imageUrl != null
                                          ? ClipOval(
                                              child: Image.network(
                                                widget.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    _buildDefaultIcon(),
                                              ),
                                            )
                                          : _buildDefaultIcon(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Action Buttons
                        SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Dismiss Button
                                _buildActionButton(
                                  context: context,
                                  icon: Icons.close_rounded,
                                  label: 'نادیده گرفتن',
                                  color: isDark
                                      ? Colors.white.withOpacity(0.15)
                                      : Colors.black.withOpacity(0.08),
                                  iconColor: isDark
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.black.withOpacity(0.7),
                                  onTap: _handleDismiss,
                                ),

                                const SizedBox(width: 20),

                                // Open Button
                                _buildActionButton(
                                  context: context,
                                  icon: Icons.lock_open_rounded,
                                  label: 'باز کردن درب',
                                  color: const Color(0xFF34C759),
                                  iconColor: Colors.white,
                                  onTap: _handleOpen,
                                  isPrimary: true,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Center(
      child: Icon(
        Icons.doorbell_rounded,
        size: 80,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
