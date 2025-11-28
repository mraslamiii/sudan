import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../../core/di/injection_container.dart' as di;
import '../../data/models/dashboard_card_model.dart';
import '../../data/data_sources/local/dashboard/dashboard_settings_service.dart';
import '../widgets/dashboard/dashboard_card_factory.dart';
import '../widgets/dashboard/scenarios_section.dart';
import '../widgets/dashboard/led_control_panel.dart';
import '../widgets/dashboard/thermostat_control_panel.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/theme/app_theme.dart';

class AdvancedDashboardView extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  
  const AdvancedDashboardView({
    super.key,
    this.onThemeChanged,
  });

  @override
  State<AdvancedDashboardView> createState() => _AdvancedDashboardViewState();
}

class _AdvancedDashboardViewState extends State<AdvancedDashboardView>
    with TickerProviderStateMixin {
  late DashboardSettingsService _settingsService;
  List<DashboardCardModel> _cards = [];
  bool _isEditMode = false;
  bool _isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _headerController;
  String _selectedRoom = 'Living Room';

  @override
  void initState() {
    super.initState();
    _settingsService = di.getIt<DashboardSettingsService>();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadDashboard();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final cards = await _settingsService.loadDashboardCards();
    setState(() {
      _cards = cards;
      _isLoading = false;
    });
    _headerController.forward();
    _fadeController.forward();
  }

  Future<void> _saveDashboard() async {
    await _settingsService.saveDashboardCards(_cards);
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
    if (_isEditMode) {
      _slideController.forward();
    } else {
      _slideController.reverse();
      _saveDashboard();
    }
  }


  void _reorderCards(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final card = _cards.removeAt(oldIndex);
      _cards.insert(newIndex, card);
      // Update positions
      for (int i = 0; i < _cards.length; i++) {
        _cards[i] = _cards[i].copyWith(position: i);
      }
    });
    _saveDashboard();
  }

  void _deleteCard(String cardId) {
    setState(() {
      _cards.removeWhere((card) => card.id == cardId);
      // Update positions
      for (int i = 0; i < _cards.length; i++) {
        _cards[i] = _cards[i].copyWith(position: i);
      }
    });
    _saveDashboard();
  }

  void _resizeCard(String cardId, CardSize newSize) {
    setState(() {
      final index = _cards.indexWhere((card) => card.id == cardId);
      if (index != -1) {
        _cards[index] = _cards[index].copyWith(size: newSize);
      }
    });
    _saveDashboard();
  }

  void _updateCardData(String cardId, Map<String, dynamic> newData) {
    setState(() {
      final index = _cards.indexWhere((card) => card.id == cardId);
      if (index != -1) {
        final currentData = Map<String, dynamic>.from(_cards[index].data);
        currentData.addAll(newData);
        _cards[index] = _cards[index].copyWith(data: currentData);
      }
    });
    _saveDashboard();
  }

  void _handleCardTap(DashboardCardModel card) {
    if (_isEditMode) return;
    
    switch (card.type) {
      case CardType.light:
        final isOn = card.data['isOn'] as bool? ?? false;
        _updateCardData(card.id, {'isOn': !isOn});
        break;
      case CardType.curtain:
        final isOpen = card.data['isOpen'] as bool? ?? false;
        _updateCardData(card.id, {
          'isOpen': !isOpen,
          'position': !isOpen ? 100 : 0,
        });
        break;
      case CardType.tv:
        final isOn = card.data['isOn'] as bool? ?? false;
        _updateCardData(card.id, {'isOn': !isOn});
        break;
      case CardType.fan:
        final isOn = card.data['isOn'] as bool? ?? false;
        _updateCardData(card.id, {'isOn': !isOn});
        break;
      case CardType.security:
        final isActive = card.data['isActive'] as bool? ?? false;
        _updateCardData(card.id, {
          'isActive': !isActive,
          'status': !isActive ? 'Armed' : 'Disarmed',
        });
        break;
      case CardType.music:
        final isPlaying = card.data['isPlaying'] as bool? ?? false;
        _updateCardData(card.id, {'isPlaying': !isPlaying});
        break;
      case CardType.camera:
        final isOn = card.data['isOn'] as bool? ?? true;
        final isRecording = card.data['isRecording'] as bool? ?? false;
        _updateCardData(card.id, {
          'isOn': !isOn,
          'isRecording': !isOn ? false : isRecording, // Turn off recording if camera is off
        });
        break;
      default:
        break;
    }
  }

  void _addCard(CardType type) {
    setState(() {
      final newCard = DashboardCardModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        size: CardSize.medium,
        position: _cards.length,
        data: _getDefaultDataForType(type),
      );
      _cards.add(newCard);
    });
    _saveDashboard();
  }

  Map<String, dynamic> _getDefaultDataForType(CardType type) {
    switch (type) {
      case CardType.light:
        return {
          'name': 'New Light',
          'isOn': false,
          'brightness': 50,
          'color': '#FF6B6B',
        };
      case CardType.curtain:
        return {
          'name': 'New Curtains',
          'isOpen': false,
          'position': 0,
        };
      case CardType.thermostat:
        return {
          'temperature': 22,
          'targetTemperature': 22,
          'mode': 'cool',
        };
      case CardType.security:
        return {
          'status': 'Disarmed',
          'isActive': false,
        };
      case CardType.music:
        return {
          'title': 'No Track',
          'artist': 'Unknown Artist',
          'isPlaying': false,
          'volume': 50,
        };
      case CardType.tv:
        return {
          'name': 'TV',
          'isOn': false,
          'channel': 1,
        };
      case CardType.fan:
        return {
          'name': 'Fan',
          'isOn': false,
          'speed': 0,
        };
      case CardType.camera:
        return {
          'name': 'Camera',
          'isOn': true,
          'location': 'Living Room',
          'availableRooms': ['Living Room', 'Bed Room', 'Kitchen', 'Bathroom'],
          'isRecording': false,
          'resolution': '4K',
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTabletLandscape = size.width > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          child: _buildMainContent(isTabletLandscape),
        ),
      ),
    );
  }


  Widget _buildMainContent(bool isTabletLandscape) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: ThemeColors.primaryBlueLight,
        ),
      );
    }

    // Get camera cards and other device cards
    final cameraCards = _cards.where((c) => c.type == CardType.camera).toList();
    final deviceCards = _cards.where((c) => 
      c.type != CardType.camera && c.type != CardType.thermostat
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Navigation Bar with Room Tabs
        _buildRoomNavigationBar(),
        const SizedBox(height: 12),

        // Main Content Area
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Devices Section and Scenarios Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Devices Section
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 400,
                        child: _buildSectionBox(
                        child: _buildDevicesSection(deviceCards, isCompact: true),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Scenarios and Camera Section
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Scenarios Section
                            SizedBox(
                              height: 170,
                              child: _buildSectionBox(
                                child: ScenariosSection(
                                  onScenarioTap: (scenario) {
                                    // Handle scenario tap
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Camera Section
                            Expanded(
                              child: _buildSectionBox(
                                child: cameraCards.isNotEmpty
                                    ? _AnimatedCardWrapper(
                                        key: ValueKey(cameraCards.first.id),
                                        index: 0,
                                        animation: _fadeController,
                                        child: DashboardCardFactory.createCard(
                                          card: cameraCards.first,
                                          isEditMode: _isEditMode,
                                          onTap: () => _handleCardTap(cameraCards.first),
                                          onLongPress: _isEditMode ? null : _toggleEditMode,
                                          onDelete: () => _deleteCard(cameraCards.first.id),
                                          onResize: (newSize) => _resizeCard(cameraCards.first.id, newSize),
                                          onDataUpdate: (newData) => _updateCardData(cameraCards.first.id, newData),
                                        ),
                                      )
                                    : _buildDefaultCameraCard(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // LED Control and Thermostat Control Section
                SizedBox(
                  height: 410,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LED Control Panel
                      Expanded(
                        child: _buildSectionBox(
                          child: LEDControlPanel(
                            selectedColor: const Color(0xFF9C27B0),
                            brightness: 56,
                            onColorChanged: (color) {
                              // Handle color change
                            },
                            onBrightnessChanged: (brightness) {
                              // Handle brightness change
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Thermostat Control Panel
                      Expanded(
                        child: _buildSectionBox(
                          child: ThermostatControlPanel(
                            temperature: 25,
                            mode: 'Auto',
                            isOn: true,
                            onTemperatureChanged: (temp) {
                              // Handle temperature change
                            },
                            onModeChanged: (mode) {
                              // Handle mode change
                            },
                            onToggle: (isOn) {
                              // Handle toggle
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomNavigationBar() {
    final rooms = ['Living Room', 'Bed Room', 'Kitchen', 'Bathroom'];
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _headerController,
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.getSectionBackground(isDark),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getShadowColor(isDark),
                    blurRadius: 20,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                      // Room Tabs
                      Expanded(
                        child: Row(
                          children: rooms.map((room) {
                            final isSelected = room == _selectedRoom;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: _buildRoomTab(room, isSelected),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Action Buttons
                      Row(
                    children: [
                      if (_isEditMode)
                      Builder(
                        builder: (context) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return PopupMenuButton<CardType>(
                        icon: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                                color: AppTheme.getPrimaryBlue(isDark),
                            borderRadius: BorderRadius.circular(10),
                          ),
                              child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 18,
                                    color: AppTheme.getSectionBackground(isDark),
                              ),
                                  const SizedBox(width: 6),
                              Text(
                                'Add Device',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                      color: AppTheme.getSectionBackground(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                            color: AppTheme.getCardBackground(isDark),
                        elevation: 8,
                        onSelected: _addCard,
                        itemBuilder: (context) => [
                              _buildMenuItem(CardType.light, Icons.lightbulb_rounded, 'Light', isDark),
                              _buildMenuItem(CardType.curtain, Icons.curtains_rounded, 'Curtain', isDark),
                              _buildMenuItem(CardType.thermostat, Icons.thermostat_rounded, 'Thermostat', isDark),
                              _buildMenuItem(CardType.security, Icons.shield_rounded, 'Security', isDark),
                              _buildMenuItem(CardType.music, Icons.music_note_rounded, 'Music', isDark),
                              _buildMenuItem(CardType.tv, Icons.tv_rounded, 'TV', isDark),
                              _buildMenuItem(CardType.fan, Icons.toys_rounded, 'Fan', isDark),
                              _buildMenuItem(CardType.camera, Icons.videocam_rounded, 'Camera', isDark),
                        ],
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Builder(
                        builder: (context) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _toggleEditMode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _isEditMode
                                      ? AppTheme.getPrimaryBlue(isDark)
                                      : AppTheme.getLightGray(isDark),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isEditMode
                                      ? Icons.check_rounded
                                      : Icons.edit_rounded,
                                  size: 18,
                                  color: _isEditMode
                                          ? AppTheme.getSectionBackground(isDark)
                                          : AppTheme.getPrimaryBlue(isDark),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isEditMode ? 'Done' : 'Edit',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: _isEditMode
                                            ? AppTheme.getSectionBackground(isDark)
                                            : AppTheme.getPrimaryBlue(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.notifications_outlined,
                        label: '',
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.grid_view_outlined,
                        label: '',
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _buildMainMenu(),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoomTab(String room, bool isSelected) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRoom = room;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppTheme.getPrimaryBlue(isDark) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                room,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? AppTheme.getSectionBackground(isDark) 
                      : AppTheme.getSecondaryGray(isDark),
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: label.isEmpty ? 12 : 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
                color: AppTheme.getLightGray(isDark),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                    color: AppTheme.getPrimaryBlue(isDark),
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                      style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                        color: AppTheme.getPrimaryBlue(isDark),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
        );
      },
    );
  }

  Widget _buildSectionBox({required Widget child}) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.getSectionBackground(isDark),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getShadowColor(isDark),
                blurRadius: 20,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultCameraCard() {
    // Create a default camera card if none exists
    // Use a state variable to track the current room for default camera
    final defaultCameraCard = DashboardCardModel(
      id: 'default_camera',
      type: CardType.camera,
      size: CardSize.medium,
      position: 0,
      data: {
        'name': 'Security Camera',
        'isOn': true,
        'location': _selectedRoom,
        'availableRooms': ['Living Room', 'Bed Room', 'Kitchen', 'Bathroom'],
        'isRecording': false,
        'resolution': '4K',
      },
    );

    return _AnimatedCardWrapper(
      key: ValueKey('default_camera_$_selectedRoom'),
      index: 0,
      animation: _fadeController,
      child: DashboardCardFactory.createCard(
        card: defaultCameraCard,
        isEditMode: false,
        onTap: () {
          // Camera tap - user can interact with the CCTV widget
          // Note: Changes won't persist for default card
          // User should add a real camera card to save settings
        },
        onLongPress: _toggleEditMode,
        onDataUpdate: (newData) {
          // Update selected room if camera room changed
          if (newData.containsKey('location')) {
            setState(() {
              _selectedRoom = newData['location'] as String? ?? _selectedRoom;
            });
          }
        },
      ),
    );
  }

  Widget _buildDevicesSection(List<DashboardCardModel> deviceCards, {bool isCompact = false}) {
    if (deviceCards.isEmpty) {
      return const SizedBox.shrink();
    }

    final gridWidget = FadeTransition(
      opacity: _fadeController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (isCompact) {
            // Compact view - use regular grid (2 rows x 4 columns = 8 cards)
            const crossAxisCount = 4;
            final displayCards = deviceCards.take(8).toList();
            
            // Calculate responsive spacing and aspect ratio based on available space
            // Account for padding (16px on each side = 32px total)
            final availableWidth = (constraints.maxWidth.isFinite 
                ? constraints.maxWidth 
                : 400.0).clamp(0.0, double.infinity);
            final availableHeight = (constraints.maxHeight.isFinite 
                ? constraints.maxHeight 
                : 400.0).clamp(0.0, double.infinity);
            
            // Header height (icon + padding + bottom margin)
            const headerHeight = 50.0;
            final gridAvailableHeight = (availableHeight - headerHeight).clamp(100.0, double.infinity);
            
            // Calculate spacing (responsive, but ensure it fits)
            const spacing = 16.0; // Horizontal spacing between cards
            const mainAxisSpacing = 24.0; // Vertical spacing between cards
            
            // Calculate item width - ensure it fits exactly
            final totalSpacing = spacing * (crossAxisCount - 1);
            final itemWidth = (availableWidth - totalSpacing) / crossAxisCount;
            
            // Calculate item height based on available height (2 rows)
            final rowCount = 2;
            final totalVerticalSpacing = mainAxisSpacing * (rowCount - 1);
            final itemHeight = (gridAvailableHeight - totalVerticalSpacing) / rowCount;
            
            // Calculate aspect ratio - ensure exact fit
            final childAspectRatio = itemWidth / itemHeight;

            return SizedBox(
              width: availableWidth,
              height: gridAvailableHeight,
              child: ReorderableGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
                padding: EdgeInsets.zero,
                onReorder: _reorderCards,
                children: displayCards.asMap().entries.map((entry) {
                  final index = entry.key;
                  final card = entry.value;
                  return _AnimatedCardWrapper(
                    key: ValueKey(card.id),
                    index: index,
                    animation: _fadeController,
                    child: SizedBox(
                      width: itemWidth,
                      height: itemHeight,
                      child: DashboardCardFactory.createCard(
                        card: card,
                        isEditMode: _isEditMode,
                        onTap: () => _handleCardTap(card),
                        onLongPress: _isEditMode ? null : _toggleEditMode,
                        onDelete: () => _deleteCard(card.id),
                        onResize: (newSize) => _resizeCard(card.id, newSize),
                        onDataUpdate: (newData) => _updateCardData(card.id, newData),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          } else {
            // Full view - use regular grid with equal widths for all cards
            const crossAxisCount = 6;
            const spacing = 16.0; // Horizontal spacing between cards
            const mainAxisSpacing = 24.0; // Vertical spacing between cards
            
            // Calculate responsive spacing and aspect ratio based on available space
            final availableWidth = (constraints.maxWidth.isFinite 
                ? constraints.maxWidth 
                : 400.0).clamp(0.0, double.infinity);
            
            // Calculate item width - ensure it fits exactly
            final totalSpacing = spacing * (crossAxisCount - 1);
            final itemWidth = (availableWidth - totalSpacing) / crossAxisCount;
            
            // Use a standard height for all cards (medium size)
            const itemHeight = 180.0;
            
            // Calculate aspect ratio - ensure exact fit
            final childAspectRatio = itemWidth / itemHeight;

            return ReorderableGridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
              padding: EdgeInsets.zero,
              onReorder: _reorderCards,
              children: deviceCards.asMap().entries.map((entry) {
                final index = entry.key;
                final card = entry.value;
                return _AnimatedCardWrapper(
                  key: ValueKey(card.id),
                  index: index,
                  animation: _fadeController,
                  child: ClipRect(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: itemWidth,
                        maxHeight: itemHeight,
                        minWidth: itemWidth,
                        minHeight: itemHeight,
                      ),
                      child: SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: DashboardCardFactory.createCard(
                          card: card,
                          isEditMode: _isEditMode,
                          onTap: () => _handleCardTap(card),
                          onLongPress: _isEditMode ? null : _toggleEditMode,
                          onDelete: () => _deleteCard(card.id),
                          onResize: (newSize) => _resizeCard(card.id, newSize),
                          onDataUpdate: (newData) => _updateCardData(card.id, newData),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.getIconBackground(isDark),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.devices_rounded,
                      size: 18,
                      color: AppTheme.getPrimaryBlue(isDark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Smart Devices',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor1(isDark),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (isCompact)
          Expanded(child: gridWidget)
        else
          gridWidget,
      ],
    );
  }

  PopupMenuItem<CardType> _buildMenuItem(CardType type, IconData icon, String label, bool isDark) {
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.getLightGray(isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppTheme.getPrimaryBlue(isDark)),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenu() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
          color: AppTheme.getCardBackground(isDark),
      elevation: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
                color: AppTheme.getAvatarBackground(isDark),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.network(
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=200',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                    color: AppTheme.getAvatarBackground(isDark),
                    child: Icon(
                  Icons.person_rounded,
                      color: AppTheme.getSecondaryGray(isDark),
                  size: 20,
                ),
              );
            },
          ),
        ),
      ),
      onSelected: (value) {
        _handleMenuSelection(value);
      },
      itemBuilder: (context) => [
            _buildMenuHeader(isDark),
            PopupMenuDivider(color: AppTheme.getDividerColor(isDark)),
        _buildMenuOption(
          'profile',
          Icons.person_outline_rounded,
          'Profile',
          'View and edit your profile',
              isDark,
        ),
        _buildMenuOption(
          'settings',
          Icons.settings_outlined,
          'Settings',
          'App settings and preferences',
              isDark,
        ),
        _buildMenuOption(
          'theme',
          Icons.dark_mode_outlined,
          'Theme',
          'Switch between light and dark mode',
              isDark,
        ),
            PopupMenuDivider(color: AppTheme.getDividerColor(isDark)),
        _buildMenuOption(
          'about',
          Icons.info_outline_rounded,
          'About',
          'App information and version',
              isDark,
        ),
        _buildMenuOption(
          'help',
          Icons.help_outline_rounded,
          'Help & Support',
          'Get help and contact support',
              isDark,
        ),
            PopupMenuDivider(color: AppTheme.getDividerColor(isDark)),
        _buildMenuOption(
          'logout',
          Icons.logout_rounded,
          'Logout',
          'Sign out from your account',
              isDark,
          isDestructive: true,
        ),
      ],
        );
      },
    );
  }

  PopupMenuItem<String> _buildMenuHeader(bool isDark) {
    return PopupMenuItem<String>(
      enabled: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.getAvatarBackground(isDark),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.network(
                  'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=200',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.getAvatarBackground(isDark),
                      child: Icon(
                        Icons.person_rounded,
                        color: AppTheme.getSecondaryGray(isDark),
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor1(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'john.doe@example.com',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.getSecondaryGray(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuOption(
    String value,
    IconData icon,
    String title,
    String subtitle,
    bool isDark, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDestructive
                  ? ThemeColors.errorRed.withOpacity(0.1)
                  : AppTheme.getLightGray(isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDestructive
                  ? ThemeColors.errorRed
                  : AppTheme.getPrimaryBlue(isDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDestructive
                        ? ThemeColors.errorRed
                        : AppTheme.getTextColor1(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.getSecondaryGray(isDark),
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

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        // Navigate to profile page
        break;
      case 'settings':
        // Navigate to settings page
        break;
      case 'theme':
        _toggleTheme();
        break;
      case 'about':
        // Show about dialog
        _showAboutDialog();
        break;
      case 'help':
        // Navigate to help page
        break;
      case 'logout':
        // Handle logout
        _showLogoutDialog();
        break;
    }
  }

  void _toggleTheme() {
    final currentBrightness = Theme.of(context).brightness;
    final isDark = currentBrightness == Brightness.dark;
    
    // Toggle between light and dark, skip system mode
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    widget.onThemeChanged?.call(newMode);
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'About',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Home Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.secondaryGrayLight,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'A modern smart home control dashboard for managing your connected devices.',
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.secondaryGrayLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(
                color: ThemeColors.primaryBlueLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: ThemeColors.secondaryGrayLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle logout logic here
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFFF3B30),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Animated Card Wrapper for stagger effect
class _AnimatedCardWrapper extends StatelessWidget {
  final int index;
  final Animation<double> animation;
  final Widget child;

  const _AnimatedCardWrapper({
    super.key,
    required this.index,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delay = index * 0.05;
    final adjustedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          delay.clamp(0.0, 0.8),
          (delay + 0.3).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: adjustedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - adjustedAnimation.value)),
          child: Opacity(
            opacity: adjustedAnimation.value,
            child: Transform.scale(
              scale: 0.9 + (0.1 * adjustedAnimation.value),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}


