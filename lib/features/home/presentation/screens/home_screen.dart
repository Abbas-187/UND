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
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.userProfile);
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                l10n.modules,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final moduleKey = appModules.keys.elementAt(index);
                final module = appModules[moduleKey]!;
                final moduleName =
                    l10n.getModuleName(module.nameKey) ?? module.nameKey;

                return _buildModuleSection(context, moduleName, module);
              },
              childCount: appModules.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleSection(
    BuildContext context,
    String title,
    AppModule module,
  ) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module header
          Container(
            padding: const EdgeInsets.all(16.0),
            color: module.color.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  module.icon,
                  size: 36,
                  color: module.color,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: module.color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
          // Module screens
          if (module.screens.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(l10n.noScreensAvailable),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: module.screens.length,
                itemBuilder: (context, index) {
                  final screen = module.screens[index];
                  final screenName =
                      l10n.getScreenName(screen.nameKey) ?? screen.nameKey;

                  return _buildScreenCard(
                    context,
                    screenName,
                    screen.icon,
                    module.color,
                    () {
                      Navigator.pushNamed(context, screen.route);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScreenCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
