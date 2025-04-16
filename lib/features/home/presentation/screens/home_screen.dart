import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../features/shared/models/app_modules.dart';
import '../../../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.welcomeToUndManager),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(
                  Icons.dashboard,
                  size: 60,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.welcomeToUndManager,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.dairyManagementSolution,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.modules,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: appModules.length,
              itemBuilder: (context, index) {
                final moduleKey = appModules.keys.elementAt(index);
                final module = appModules[moduleKey]!;
                final moduleName =
                    l10n.getModuleName(module.nameKey) ?? module.nameKey;

                return _buildModuleCard(
                  context,
                  moduleName,
                  module.icon,
                  module.color,
                  () {
                    showModuleScreensDialog(context, module);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showModuleScreensDialog(BuildContext context, AppModule module) {
    final l10n = AppLocalizations.of(context);
    final moduleName = l10n.getModuleName(module.nameKey) ?? module.nameKey;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '$moduleName ${l10n.screens}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: module.screens.isEmpty
                ? Center(
                    child: Text(l10n.noScreensAvailable),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: module.screens.length,
                    itemBuilder: (context, index) {
                      final screen = module.screens[index];
                      final screenName =
                          l10n.getScreenName(screen.nameKey) ?? screen.nameKey;
                      final screenDesc =
                          l10n.getScreenDescription(screen.descriptionKey) ??
                              screen.descriptionKey;

                      return ListTile(
                        leading: Icon(
                          screen.icon,
                          color: module.color,
                        ),
                        title: Text(screenName),
                        subtitle: Text(screenDesc),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, screen.route);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${appModules.entries.firstWhere((entry) => entry.value.nameKey == title.toLowerCase() || l10n.getModuleName(entry.value.nameKey) == title, orElse: () => MapEntry(title.toLowerCase(), appModules.values.first)).value.screens.length} ${l10n.screens}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
