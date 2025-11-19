import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../core/di/injection_container.dart';
import '../../core/theme/theme_colors.dart';

class HomeViewGlass extends StatelessWidget {
  final VoidCallback onThemeToggle;

  const HomeViewGlass({super.key, required this.onThemeToggle});

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
    with TickerProviderStateMixin {
  // State for interactive elements
  final Map<String, bool> _deviceStates = {
    'living_light': true,
    'kitchen_light': false,
    'ac': true,
    'tv': false,
    'fan': true,
    'lock': true,
  };

  double _brightness = 0.7;
  double _temp = 24.0;
  int _selectedRoomIndex = 0;

  final List<String> _rooms = [
    'پذیرایی',
    'خواب',
    'آشپزخانه',
    'اتاق کار',
    'حمام',
    'حیاط',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Awesome Background
          _buildBackground(isDark),

          // 2. Glass Content
          SafeArea(
            child: Row(
              children: [
                // Navigation Rail (Glass)
                _buildGlassSidebar(context, isDark),

                // Main Content
                Expanded(
                  child: Column(
                    children: [
                      // Top Bar
                      _buildGlassTopBar(context, isDark),

                      // Scrollable Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero Section (Weather & Welcome)
                              _buildHeroSection(isDark),

                              const SizedBox(height: 24),

                              // Bento Grid Layout
                              _buildBentoGrid(isDark),

                              const SizedBox(height: 24),

                              // Room Selector
                              _buildRoomSelector(isDark),

                              const SizedBox(height: 24),

                              // Other Controls
                              _buildQuickControls(isDark),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F2027),
                  const Color(0xFF203A43),
                  const Color(0xFF2C5364),
                ]
              : [
                  const Color(0xFFE0EAFC),
                  const Color(0xFFCFDEF3),
                  const Color(0xFFE2E2E2),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Abstract blobs
          Positioned(
            top: -100,
            right: -100,
            child: _buildBlob(
              300,
              isDark
                  ? Colors.purple.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: _buildBlob(
              250,
              isDark
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.purple.withOpacity(0.2),
            ),
          ),
          Positioned(
            top: 200,
            left: 300,
            child: _buildBlob(
              150,
              isDark
                  ? Colors.teal.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 20)],
      ),
    );
  }

  Widget _buildGlassSidebar(BuildContext context, bool isDark) {
    return GlassCard(
      width: 80,
      margin: const EdgeInsets.fromLTRB(24, 24, 0, 24),
      isDark: isDark,
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Icon(Icons.home_rounded, size: 32, color: ThemeColors.blue),
          const SizedBox(height: 40),
          _buildNavItem(Icons.grid_view_rounded, true, isDark),
          const SizedBox(height: 24),
          _buildNavItem(Icons.bolt_rounded, false, isDark),
          const SizedBox(height: 24),
          _buildNavItem(Icons.videocam_rounded, false, isDark),
          const SizedBox(height: 24),
          _buildNavItem(Icons.settings_rounded, false, isDark),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              image: const DecorationImage(
                image: AssetImage(
                  'assets/images/photo-1600585154340-be6161a56a0c.jpeg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
            ), // Placeholder if image fails
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isActive
            ? (isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: isActive
            ? (isDark ? Colors.white : Colors.black)
            : (isDark ? Colors.white54 : Colors.black45),
        size: 24,
      ),
    );
  }

  Widget _buildGlassTopBar(BuildContext context, bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سلام، حمید 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'به خانه خوش اومدی',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Search Bar
          GlassCard(
            width: 300,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            isDark: isDark,
            borderRadius: 50,
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 10),
                Text(
                  'جستجو دستگاه...',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Theme Toggle
          GestureDetector(
            onTap: widget.onThemeToggle,
            child: GlassCard(
              width: 110,
              height: 50,
              isDark: isDark,
              borderRadius: 50,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: isDark
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      width: 44,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.dark_mode_rounded,
                        size: 20,
                        color: isDark ? Colors.amber : Colors.grey,
                      ),
                      Icon(
                        Icons.light_mode_rounded,
                        size: 20,
                        color: !isDark ? Colors.orange : Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          GlassCard(
            width: 50,
            height: 50,
            isDark: isDark,
            borderRadius: 50,
            child: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Row(
      children: [
        // Weather Widget (Big)
        Expanded(
          flex: 2,
          child: GlassCard(
            height: 180,
            isDark: isDark,
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    size: 160,
                    color: Colors.orange.withOpacity(isDark ? 0.1 : 0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '28°C',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'تهران',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'آفتابی • رطوبت 45%',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '29 آبان 1403',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Energy Consumption
        Expanded(
          flex: 1,
          child: GlassCard(
            height: 180,
            isDark: isDark,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.electric_bolt,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'مصرف انرژی',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '452',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6, right: 4),
                      child: Text(
                        'kWh',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    color: Colors.green,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '٪12 کمتر از ماه قبل',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(bool isDark) {
    // Simulating a bento grid using Rows and Columns
    return Column(
      children: [
        // Row 1
        SizedBox(
          height: 260,
          child: Row(
            children: [
              // Col 1: Climate Control (Big Square)
              Expanded(
                flex: 2,
                child: GlassCard(
                  isDark: isDark,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تهویه مطبوع',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'سامسونگ WindFree',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: _deviceStates['ac']!,
                            activeColor: ThemeColors.blue,
                            onChanged: (v) =>
                                setState(() => _deviceStates['ac'] = v),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: 0.75,
                                  strokeWidth: 8,
                                  backgroundColor: isDark
                                      ? Colors.white10
                                      : Colors.black12,
                                  valueColor: const AlwaysStoppedAnimation(
                                    ThemeColors.blue,
                                  ),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${_temp.toInt()}°',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Cooling',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ThemeColors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => setState(() => _temp--),
                            icon: const Icon(Icons.remove_circle_outline),
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          Text(
                            'دمای هدف',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _temp++),
                            icon: const Icon(Icons.add_circle_outline),
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Col 2: Two stacked cards
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildDeviceToggleCard(
                        'چراغ پذیرایی',
                        '4 لامپ',
                        Icons.lightbulb,
                        Colors.amber,
                        _deviceStates['living_light']!,
                        (v) =>
                            setState(() => _deviceStates['living_light'] = v),
                        isDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _buildDeviceToggleCard(
                        'تلویزیون',
                        'Netflix',
                        Icons.tv,
                        Colors.purple,
                        _deviceStates['tv']!,
                        (v) => setState(() => _deviceStates['tv'] = v),
                        isDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Col 3: Smart Light Control (Tall)
              Expanded(
                flex: 1,
                child: GlassCard(
                  isDark: isDark,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'روشنایی',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 40,
                              activeTrackColor: Colors.amber.withOpacity(0.8),
                              inactiveTrackColor: isDark
                                  ? Colors.white10
                                  : Colors.black12,
                              thumbColor: Colors.white,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 20,
                              ),
                              overlayShape: SliderComponentShape.noOverlay,
                              trackShape: const RoundedRectSliderTrackShape(),
                            ),
                            child: Slider(
                              value: _brightness,
                              onChanged: (v) => setState(() => _brightness = v),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Icon(
                        Icons.wb_incandescent,
                        color: Colors.amber.withOpacity(_brightness),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_brightness * 100).toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Row 2
        SizedBox(
          height: 140,
          child: Row(
            children: [
              Expanded(
                child: _buildSmallStatusCard(
                  'امنیت',
                  'فعال',
                  Icons.security,
                  Colors.green,
                  isDark,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildSmallStatusCard(
                  'اینترنت',
                  '120 Mbps',
                  Icons.wifi,
                  Colors.blue,
                  isDark,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildSmallStatusCard(
                  'رطوبت',
                  '45%',
                  Icons.water_drop,
                  Colors.cyan,
                  isDark,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: GlassCard(
                  isDark: isDark,
                  child: const Center(
                    child: Icon(Icons.add, size: 32, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceToggleCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isActive,
    ValueChanged<bool> onChanged,
    bool isDark,
  ) {
    return GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      color: isActive ? color.withOpacity(0.2) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : (isDark ? Colors.white10 : Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isActive
                      ? color
                      : (isDark ? Colors.white : Colors.black54),
                  size: 20,
                ),
              ),
              Transform.scale(
                scale: 0.7,
                child: Switch.adaptive(
                  value: isActive,
                  activeColor: color,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatusCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomSelector(bool isDark) {
    return GlassCard(
      height: 70,
      isDark: isDark,
      borderRadius: 50,
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedRoomIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedRoomIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Text(
                  _rooms[index],
                  style: TextStyle(
                    color: isSelected
                        ? (isDark ? Colors.black87 : Colors.white)
                        : (isDark ? Colors.white60 : Colors.black54),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickControls(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            isDark: isDark,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.music_note, color: Colors.pink),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'در حال پخش',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    Text(
                      'Blinding Lights',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_previous),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Reusable Components ---

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isDark;
  final double borderRadius;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    required this.isDark,
    this.borderRadius = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color:
                color ??
                (isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.white.withOpacity(0.4)),
            child: child,
          ),
        ),
      ),
    );
  }
}
