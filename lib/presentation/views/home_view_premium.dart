import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../core/di/injection_container.dart';
import '../../core/theme/theme_colors.dart';
import 'dart:math' as math;

class HomeViewPremium extends StatelessWidget {
  final VoidCallback onThemeToggle;

  const HomeViewPremium({super.key, required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<HomeViewModel>()..init(),
      child: _HomeViewContent(onThemeToggle: onThemeToggle),
    );
  }
}

class _HomeViewContent extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const _HomeViewContent({required this.onThemeToggle});

  @override
  State<_HomeViewContent> createState() => _HomeViewContentState();
}

class _HomeViewContentState extends State<_HomeViewContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Map<String, bool> _deviceStates = {
    'light': true,
    'ac': true,
    'air': true,
    'camera': false,
    'lock': true,
    'speaker': true,
    'wifi': true,
    'vacuum': false,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDevice(String deviceKey) {
    setState(() {
      _deviceStates[deviceKey] = !(_deviceStates[deviceKey] ?? false);
    });
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? ThemeColors.backgroundDark : ThemeColors.backgroundLight,
      body: SafeArea(
        child: _buildBody(context, viewModel, isDark),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HomeViewModel viewModel,
    bool isDark,
  ) {
    if (viewModel.isLoading && viewModel.homeItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: ThemeColors.red),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? 'خطایی رخ داده است',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.refresh,
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    return _buildMainContent(context, isDark, widget.onThemeToggle);
  }

  Widget _buildMainContent(
    BuildContext context,
    bool isDark,
    VoidCallback onThemeToggle,
  ) {
    return Row(
      children: [
        _buildSidebar(context, isDark),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isDark, onThemeToggle),
                  const SizedBox(height: 28),
                  _buildQuickStats(context, isDark),
                  const SizedBox(height: 28),
                  _buildDevicesGrid(context, isDark),
                  const SizedBox(height: 28),
                  _buildRoomsSection(context, isDark),
                ],
              ),
            ),
          ),
        ),
        _buildRightPanel(context, isDark),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDark) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  ThemeColors.cardBackgroundDark,
                  ThemeColors.cardBackgroundDark.withOpacity(0.95),
                ]
              : [
                  Colors.white,
                  Colors.white.withOpacity(0.98),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildSidebarIcon(Icons.home_rounded, true, isDark),
          const SizedBox(height: 24),
          _buildSidebarIcon(Icons.lightbulb_outline, false, isDark),
          const SizedBox(height: 24),
          _buildSidebarIcon(Icons.settings_outlined, false, isDark),
          const SizedBox(height: 24),
          _buildSidebarIcon(Icons.notifications_outlined, false, isDark),
          const Spacer(),
          _buildSidebarIcon(Icons.person_outline, false, isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSidebarIcon(IconData icon, bool isActive, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeColors.blue.withOpacity(0.2),
                  ThemeColors.blue.withOpacity(0.1),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: ThemeColors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        color: isActive
            ? ThemeColors.blue
            : (isDark
                    ? ThemeColors.iconColorDark
                    : ThemeColors.iconColorLight)
                .withOpacity(0.5),
        size: 26,
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    VoidCallback onThemeToggle,
  ) {
    final hour = DateTime.now().hour;
    String greeting = 'سلام';
    if (hour < 12) {
      greeting = 'صبح بخیر';
    } else if (hour < 18) {
      greeting = 'عصر بخیر';
    } else {
      greeting = 'شب بخیر';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isDark
                      ? [Colors.white, Colors.white.withOpacity(0.9)]
                      : [
                          ThemeColors.textColor1Light,
                          ThemeColors.textColor1Light.withOpacity(0.8)
                        ],
                ).createShader(bounds),
                child: Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'خانه هوشمند شما آماده است',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? ThemeColors.textColor2Dark
                      : ThemeColors.textColor2Light,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeaderAction(Icons.search, isDark, null),
            const SizedBox(width: 12),
            _buildThemeToggle(context, isDark, onThemeToggle),
            const SizedBox(width: 12),
            _buildProfileAvatar(isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderAction(IconData icon, bool isDark, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    ThemeColors.cardBackgroundDark,
                    ThemeColors.cardBackgroundDark.withOpacity(0.8),
                  ]
                : [
                    Colors.white,
                    Colors.white.withOpacity(0.95),
                  ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark
              ? ThemeColors.iconColorDark
              : ThemeColors.iconColorLight,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildThemeToggle(
    BuildContext context,
    bool isDark,
    VoidCallback onThemeToggle,
  ) {
    return GestureDetector(
      onTap: onThemeToggle,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    ThemeColors.amber.withOpacity(0.2),
                    ThemeColors.amber.withOpacity(0.1),
                  ]
                : [
                    ThemeColors.blue.withOpacity(0.15),
                    ThemeColors.blue.withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? ThemeColors.amber.withOpacity(0.2)
                : ThemeColors.blue.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? ThemeColors.amber : ThemeColors.blue)
                  .withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          color: isDark ? ThemeColors.amber : ThemeColors.blue,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeColors.blue.withOpacity(0.2),
            ThemeColors.blue.withOpacity(0.1),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: ThemeColors.blue.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.person, color: ThemeColors.blue, size: 22),
    );
  }

  Widget _buildQuickStats(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'دما',
            '24°C',
            Icons.thermostat,
            ThemeColors.blue,
            isDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildStatCard(
            'رطوبت',
            '65%',
            Icons.water_drop,
            ThemeColors.amber,
            isDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildStatCard(
            'مصرف انرژی',
            '1.2 kWh',
            Icons.bolt,
            ThemeColors.green,
            isDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildStatCard(
            'دستگاه فعال',
            '8/12',
            Icons.devices,
            ThemeColors.red,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  ThemeColors.cardBackgroundDark,
                  ThemeColors.cardBackgroundDark.withOpacity(0.7),
                ]
              : [
                  Colors.white,
                  Colors.white.withOpacity(0.9),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : color.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.25),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? ThemeColors.textColor2Dark
                        : ThemeColors.textColor2Light,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? ThemeColors.textColor1Dark
                        : ThemeColors.textColor1Light,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesGrid(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'دستگاه‌های اصلی',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark
                ? ThemeColors.textColor1Dark
                : ThemeColors.textColor1Light,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.95,
          children: [
            _buildDeviceCard('چراغ اصلی', '4 دستگاه', Icons.lightbulb,
                ThemeColors.amber, 'light', isDark),
            _buildDeviceCard(
                'کولر', '19°C', Icons.ac_unit, ThemeColors.blue, 'ac', isDark),
            _buildDeviceCard('تصفیه هوا', 'خودکار', Icons.air,
                ThemeColors.green, 'air', isDark),
            _buildDeviceCard('دوربین', '2 دستگاه', Icons.videocam,
                ThemeColors.red, 'camera', isDark),
            _buildDeviceCard(
                'قفل در', 'بسته', Icons.lock, ThemeColors.blue, 'lock', isDark),
            _buildDeviceCard('اسپیکر', 'پخش', Icons.speaker, ThemeColors.amber,
                'speaker', isDark),
            _buildDeviceCard(
                'Wi-Fi', 'متصل', Icons.wifi, ThemeColors.green, 'wifi', isDark),
            _buildDeviceCard('جاروبرقی', 'خاموش', Icons.cleaning_services,
                ThemeColors.disableColor, 'vacuum', isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceCard(
    String title,
    String status,
    IconData icon,
    Color color,
    String deviceKey,
    bool isDark,
  ) {
    final bool isActive = _deviceStates[deviceKey] ?? false;

    return GestureDetector(
      onTap: () => _toggleDevice(deviceKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? isDark
                    ? [
                        color.withOpacity(0.2),
                        color.withOpacity(0.1),
                      ]
                    : [
                        color.withOpacity(0.15),
                        color.withOpacity(0.05),
                      ]
                : isDark
                    ? [
                        ThemeColors.cardBackgroundDark,
                        ThemeColors.cardBackgroundDark.withOpacity(0.8),
                      ]
                    : [
                        Colors.white,
                        Colors.white.withOpacity(0.95),
                      ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? color.withOpacity(0.4)
                : isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
            width: 1.5,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -3,
              ),
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(isActive ? 0.3 : 0.2),
                          color.withOpacity(isActive ? 0.15 : 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 22,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? [ThemeColors.green, ThemeColors.green.withOpacity(0.8)]
                          : [Colors.grey.shade400, Colors.grey.shade300],
                    ),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: ThemeColors.green.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment:
                        isActive ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? ThemeColors.textColor1Dark
                    : ThemeColors.textColor1Light,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? ThemeColors.textColor2Dark
                    : ThemeColors.textColor2Light,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اتاق‌ها',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark
                ? ThemeColors.textColor1Dark
                : ThemeColors.textColor1Light,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRoomChip('همه', true, isDark),
              const SizedBox(width: 12),
              _buildRoomChip('نشیمن', false, isDark),
              const SizedBox(width: 12),
              _buildRoomChip('خواب', false, isDark),
              const SizedBox(width: 12),
              _buildRoomChip('آشپزخانه', false, isDark),
              const SizedBox(width: 12),
              _buildRoomChip('حمام', false, isDark),
              const SizedBox(width: 12),
              _buildRoomChip('باغ', false, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomChip(String label, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeColors.blue,
                  Color(0xFF0077CC),
                ],
              )
            : LinearGradient(
                colors: isDark
                    ? [
                        ThemeColors.cardBackgroundDark,
                        ThemeColors.cardBackgroundDark.withOpacity(0.8),
                      ]
                    : [
                        Colors.white,
                        Colors.white.withOpacity(0.95),
                      ],
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? ThemeColors.blue.withOpacity(0.5)
              : isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: ThemeColors.blue.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected
              ? Colors.white
              : (isDark
                  ? ThemeColors.textColor1Dark
                  : ThemeColors.textColor1Light),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context, bool isDark) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  ThemeColors.cardBackgroundDark,
                  ThemeColors.cardBackgroundDark.withOpacity(0.95),
                ]
              : [
                  Colors.white,
                  Colors.white.withOpacity(0.98),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeatherCard(isDark),
            const SizedBox(height: 20),
            _buildEnergyCard(isDark),
            const SizedBox(height: 20),
            _buildQuickActionsCard(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeColors.blue,
            Color(0xFF0077CC),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.blue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text(
                'تهران، ایران',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.wb_sunny, color: Colors.white, size: 48),
              SizedBox(width: 12),
              Text(
                '28°',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'آفتابی',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherDetail(Icons.water_drop, '65%'),
              _buildWeatherDetail(Icons.air, '12'),
              _buildWeatherDetail(Icons.visibility, '10'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  ThemeColors.backgroundDark,
                  ThemeColors.backgroundDark.withOpacity(0.8),
                ]
              : [
                  const Color(0xFFF8F9FA),
                  const Color(0xFFFFFFFF),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.green.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مصرف انرژی',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? ThemeColors.textColor1Dark
                  : ThemeColors.textColor1Light,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(100, 100),
                    painter: _CircularProgressPainter(
                      progress: 0.73,
                      color: ThemeColors.green,
                      backgroundColor: isDark
                          ? ThemeColors.cardBackgroundDark
                          : const Color(0xFFF0F0F0),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '73%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? ThemeColors.textColor1Dark
                                : ThemeColors.textColor1Light,
                          ),
                        ),
                        Text(
                          'صرفه‌جویی',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? ThemeColors.textColor2Dark
                                : ThemeColors.textColor2Light,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.green.withOpacity(0.15),
                  ThemeColors.green.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ThemeColors.green.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_down,
                    color: ThemeColors.green, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '23% کمتر',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  ThemeColors.backgroundDark,
                  ThemeColors.backgroundDark.withOpacity(0.8),
                ]
              : [
                  const Color(0xFFF8F9FA),
                  const Color(0xFFFFFFFF),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اقدامات سریع',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? ThemeColors.textColor1Dark
                  : ThemeColors.textColor1Light,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickAction('چراغ‌ها', Icons.lightbulb, isDark),
          const SizedBox(height: 8),
          _buildQuickAction('خواب', Icons.bedtime, isDark),
          const SizedBox(height: 8),
          _buildQuickAction('مهمان', Icons.person_add, isDark),
          const SizedBox(height: 8),
          _buildQuickAction('خروج', Icons.exit_to_app, isDark),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? ThemeColors.cardBackgroundDark
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.blue.withOpacity(0.2),
                  ThemeColors.blue.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ThemeColors.blue, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? ThemeColors.textColor1Dark
                    : ThemeColors.textColor1Light,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDark
                ? ThemeColors.textColor2Dark
                : ThemeColors.textColor2Light,
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 4, backgroundPaint);

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.7)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

