import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan/core/theme/app_theme.dart';
import 'package:sudan/core/localization/app_localizations.dart';
import 'package:sudan/presentation/viewmodels/room_setup_viewmodel.dart';

/// Room Basic Info Step
/// First step of room setup - name and description
class RoomBasicInfoStep extends StatefulWidget {
  const RoomBasicInfoStep({super.key});

  @override
  State<RoomBasicInfoStep> createState() => _RoomBasicInfoStepState();
}

class _RoomBasicInfoStepState extends State<RoomBasicInfoStep> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<RoomSetupViewModel>();
    _nameController.text = viewModel.roomName ?? '';
    _descriptionController.text = viewModel.roomDescription ?? '';
    _nameController.addListener(_onNameChanged);
    _descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    context.read<RoomSetupViewModel>().setRoomName(_nameController.text);
  }

  void _onDescriptionChanged() {
    context.read<RoomSetupViewModel>().setRoomDescription(
          _descriptionController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppTheme.getPrimaryBlue(isDark);
    final size = MediaQuery.of(context).size;
    final isTabletLandscape = size.width > 900;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
        children: [
        // Header Section
        if (!isTabletLandscape) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.getPrimaryButtonGradient(isDark),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppTheme.getSectionShadows(
                    isDark,
                    elevated: true,
                  ),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.roomInformation,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor1(isDark),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.enterRoomDetails,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.getSecondaryGray(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],

        // Form Fields - Side by side on tablet, stacked on mobile
        isTabletLandscape
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildNameField(isDark, accentColor),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDescriptionField(isDark, accentColor),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameField(isDark, accentColor),
                  const SizedBox(height: 24),
                  _buildDescriptionField(isDark, accentColor),
                ],
              ),
      ],
    );
  }

  Widget _buildNameField(bool isDark, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            AppLocalizations.of(context)!.roomName,
            style: TextStyle(
            fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
        const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            autofocus: true,
          textInputAction: TextInputAction.next,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextColor1(isDark),
            ),
            decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.roomNameHint,
              hintStyle: TextStyle(
                color: AppTheme.getSecondaryGray(isDark),
              fontSize: 15,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: accentColor.withOpacity(0.6),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(bool isDark, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            AppLocalizations.of(context)!.descriptionOptional,
            style: TextStyle(
            fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
        const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
          maxLines: 4,
          textInputAction: TextInputAction.done,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextColor1(isDark),
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.roomDescriptionHint,
              hintStyle: TextStyle(
                color: AppTheme.getSecondaryGray(isDark),
              fontSize: 15,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: accentColor.withOpacity(0.6),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
              ),
            ),
          ),
        ],
    );
  }
}

