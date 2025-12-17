import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan/core/theme/app_theme.dart';
import 'package:sudan/core/localization/app_localizations.dart';
import 'package:sudan/presentation/viewmodels/scenario_setup_viewmodel.dart';
import 'package:sudan/presentation/widgets/setup/scenario_icon_picker.dart';
import 'package:sudan/presentation/widgets/setup/scenario_color_picker.dart';

/// Scenario Basic Info Step
/// First step of scenario setup - name, description, icon and color selection
class ScenarioBasicInfoStep extends StatefulWidget {
  const ScenarioBasicInfoStep({super.key});

  @override
  State<ScenarioBasicInfoStep> createState() => _ScenarioBasicInfoStepState();
}

class _ScenarioBasicInfoStepState extends State<ScenarioBasicInfoStep> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ScenarioSetupViewModel>();
    _nameController.text = viewModel.scenarioName ?? '';
    _descriptionController.text = viewModel.scenarioDescription ?? '';
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
    context.read<ScenarioSetupViewModel>().setScenarioName(_nameController.text);
  }

  void _onDescriptionChanged() {
    context.read<ScenarioSetupViewModel>().setScenarioDescription(
          _descriptionController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppTheme.getPrimaryBlue(isDark);
    final size = MediaQuery.of(context).size;
    final isTabletLandscape = size.width > 900;
    final viewModel = context.watch<ScenarioSetupViewModel>();

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
                      AppLocalizations.of(context)!.scenarioInformation,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor1(isDark),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.enterScenarioDetails,
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

        // Form Fields
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

        const SizedBox(height: 32),

        // Icon Selection
        Text(
          AppLocalizations.of(context)!.selectIcon,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor1(isDark),
          ),
        ),
        const SizedBox(height: 16),
        ScenarioIconPicker(
          selectedIcon: viewModel.selectedIcon,
          selectedColor: viewModel.selectedColor,
          onIconSelected: (icon) => viewModel.setSelectedIcon(icon),
        ),

        const SizedBox(height: 32),

        // Color Selection
        Text(
          AppLocalizations.of(context)!.selectColor,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor1(isDark),
          ),
        ),
        const SizedBox(height: 16),
        ScenarioColorPicker(
          selectedColor: viewModel.selectedColor,
          onColorSelected: (color) => viewModel.setSelectedColor(color),
        ),
      ],
    );
  }

  Widget _buildNameField(bool isDark, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.scenarioName,
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
            hintText: AppLocalizations.of(context)!.scenarioNameHint,
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
          AppLocalizations.of(context)!.descriptionOptionalScenario,
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
            hintText: AppLocalizations.of(context)!.describeScenario,
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

