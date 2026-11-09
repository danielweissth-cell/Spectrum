import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../settings/app_settings.dart';
import 'spectrum_background.dart';

/// Language, look and sound preferences. Every change applies at once and is saved.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SpectrumBackground()),
          ListenableBuilder(
            listenable: settings,
            builder: (context, _) => ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.paddingOf(context).top + kToolbarHeight + 8,
                16,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                _Section(
                  title: l10n.settingsLanguage,
                  child: _LanguagePicker(settings: settings),
                ),
                _Section(
                  title: l10n.settingsAppearance,
                  child: SwitchListTile(
                    title: Text(l10n.settingsGlass),
                    subtitle: Text(l10n.settingsGlassHint),
                    value: settings.glassEnabled,
                    onChanged: settings.setGlassEnabled,
                  ),
                ),
                _Section(
                  title: l10n.settingsSound,
                  child: Column(
                    children: [
                      _FactorSlider(
                        label: l10n.settingsVolume,
                        hint: l10n.settingsVolumeHint,
                        icon: Icons.volume_up,
                        value: settings.volume,
                        min: AppSettings.minVolume,
                        max: AppSettings.maxVolume,
                        step: 0.1,
                        defaultValue: AppSettings.defaultVolume,
                        onChanged: settings.setVolume,
                      ),
                      _FactorSlider(
                        label: l10n.settingsSpeed,
                        icon: Icons.speed,
                        value: settings.speed,
                        min: AppSettings.minSpeed,
                        max: AppSettings.maxSpeed,
                        step: 0.25,
                        defaultValue: AppSettings.defaultSpeed,
                        onChanged: settings.setSpeed,
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
}

/// A titled group of settings on a translucent card.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.surface.withValues(alpha: 0.55),
            clipBehavior: Clip.antiAlias,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String nameOf(AppLanguage language) => switch (language) {
      AppLanguage.system => l10n.settingsLanguageSystem,
      AppLanguage.english => l10n.settingsLanguageEnglish,
      AppLanguage.russian => l10n.settingsLanguageRussian,
    };
    return RadioGroup<AppLanguage>(
      groupValue: settings.language,
      onChanged: (language) {
        if (language != null) settings.setLanguage(language);
      },
      child: Column(
        children: [
          for (final language in AppLanguage.values)
            RadioListTile<AppLanguage>(
              value: language,
              title: Text(nameOf(language)),
            ),
        ],
      ),
    );
  }
}

/// A slider for a factor such as 1.5×, with a button that returns it to normal.
class _FactorSlider extends StatelessWidget {
  const _FactorSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.defaultValue,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final String? hint;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final double step;
  final double defaultValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final valueText = l10n.settingsMultiplier(value);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
              Text(valueText, style: theme.textTheme.titleMedium),
              IconButton(
                tooltip: l10n.settingsReset,
                icon: const Icon(Icons.restart_alt),
                onPressed: value == defaultValue
                    ? null
                    : () => onChanged(defaultValue),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / step).round(),
            label: valueText,
            // Rounding keeps values like 1.2000000000000002 out of storage.
            onChanged: (newValue) =>
                onChanged(double.parse(newValue.toStringAsFixed(2))),
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 8),
              child: Text(
                hint!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
