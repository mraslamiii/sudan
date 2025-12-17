import 'dart:convert';
import '../preferences/preferences_service.dart';
import '../../../models/scenario_model.dart';

/// Scenario Local Data Source
/// Handles local storage operations for scenarios
/// Uses PreferencesService for persistence
class ScenarioLocalDataSource {
  final PreferencesService _preferencesService;
  static const String _scenariosKey = 'scenarios_cache';

  ScenarioLocalDataSource(this._preferencesService);

  /// Get all cached scenarios
  Future<List<ScenarioModel>> getCachedScenarios() async {
    print('🟠 [SCENARIO_DS] getCachedScenarios called');
    try {
      final String? scenariosJson = _preferencesService.getString(_scenariosKey);
      if (scenariosJson == null || scenariosJson.isEmpty) {
        print('🟠 [SCENARIO_DS] No cached scenarios found, returning empty list');
        // Return empty list instead of default scenarios
        // Users should create their own scenarios
        return [];
      }

      print('🟠 [SCENARIO_DS] Found cached scenarios JSON (length: ${scenariosJson.length})');
      final List<dynamic> scenariosList = json.decode(scenariosJson);
      final scenarios = scenariosList
          .map((scenarioJson) => ScenarioModel.fromJson(scenarioJson))
          .toList();
      print('🟠 [SCENARIO_DS] Parsed ${scenarios.length} scenarios from cache');
      for (var scenario in scenarios) {
        print('   - ${scenario.name} (ID: ${scenario.id}, RoomId: ${scenario.roomId})');
      }
      return scenarios;
    } catch (e) {
      print('🔴 [SCENARIO_DS] Error parsing cached scenarios: $e');
      // If there's an error parsing, return empty list instead of defaults
      return [];
    }
  }

  /// Cache scenarios locally
  Future<void> cacheScenarios(List<ScenarioModel> scenarios) async {
    print('🟠 [SCENARIO_DS] cacheScenarios called with ${scenarios.length} scenarios');
    final scenariosJson = json.encode(
      scenarios.map((scenario) => scenario.toJson()).toList(),
    );
    print('🟠 [SCENARIO_DS] JSON encoded (length: ${scenariosJson.length})');
    await _preferencesService.setString(_scenariosKey, scenariosJson);
    print('🟠 [SCENARIO_DS] Scenarios saved to preferences');
  }

  /// Add a new scenario
  Future<void> addScenario(ScenarioModel scenario) async {
    print('🟠 [SCENARIO_DS] addScenario called');
    print('   - ID: ${scenario.id}');
    print('   - Name: ${scenario.name}');
    print('   - RoomId: ${scenario.roomId}');
    
    final scenarios = await getCachedScenarios();
    print('🟠 [SCENARIO_DS] Current scenarios count: ${scenarios.length}');
    
    // Check for duplicates
    if (scenarios.any((s) => s.id == scenario.id)) {
      print('🔴 [SCENARIO_DS] ERROR: Scenario with ID ${scenario.id} already exists!');
      throw Exception('Scenario with ID ${scenario.id} already exists');
    }
    
    scenarios.add(scenario);
    print('🟠 [SCENARIO_DS] Added scenario. New count: ${scenarios.length}');
    await cacheScenarios(scenarios);
    print('🟠 [SCENARIO_DS] Scenarios cached successfully');
  }

  /// Update a scenario
  Future<void> updateScenario(ScenarioModel scenario) async {
    final scenarios = await getCachedScenarios();
    final index = scenarios.indexWhere((s) => s.id == scenario.id);
    
    if (index != -1) {
      scenarios[index] = scenario;
      await cacheScenarios(scenarios);
    }
  }

  /// Delete a scenario
  Future<void> deleteScenario(String scenarioId) async {
    final scenarios = await getCachedScenarios();
    scenarios.removeWhere((s) => s.id == scenarioId);
    await cacheScenarios(scenarios);
  }

  /// Clear all cached scenarios
  Future<void> clearCache() async {
    await _preferencesService.remove(_scenariosKey);
  }

}

