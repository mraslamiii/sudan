import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_colors.dart';
import '../viewmodels/usb_serial_viewmodel.dart';
import '../views/socket_connection_view.dart';

/// نوار وضعیت اتصال به میکرو — در همه صفحات نمایش داده می‌شود.
/// با لمس باز شدن صفحه اتصال سریال برای اتصال/قطع.
class MicroConnectionStatusBar extends StatelessWidget {
  /// ارتفاع نوار
  final double height;

  /// قرارگیری نوار: بالا یا پایین
  final bool atTop;

  const MicroConnectionStatusBar({
    super.key,
    this.height = 32,
    this.atTop = true,
  });

  void _openConnectionScreen(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SocketConnectionView()));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UsbSerialViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isConnected = vm.isUsbConnected;
    final color = isConnected ? ThemeColors.successGreen : ThemeColors.errorRed;
    final statusText = isConnected ? 'متصل به میکرو' : 'قطع شده';
    final icon = isConnected ? Icons.usb_rounded : Icons.usb_off_rounded;
    final bg = isDark
        ? Colors.black.withOpacity(0.6)
        : Colors.white.withOpacity(0.92);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openConnectionScreen(context),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              bottom: atTop
                  ? BorderSide(color: color.withOpacity(0.4), width: 2)
                  : BorderSide.none,
              top: !atTop
                  ? BorderSide(color: color.withOpacity(0.4), width: 2)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: textColor.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
