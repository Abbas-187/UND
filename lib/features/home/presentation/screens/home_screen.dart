import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/app_reset_utility.dart';
import '../../../../features/shared/models/app_modules.dart';
import '../../../../features/shared/models/user_role.dart';
import '../../../../features/shared/providers/user_role_provider.dart';
import '../../../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final bool isLargeScreen = size.width > 600;
    final theme = Theme.of(context);

    // Get current user role
    final userRole = ref.watch(userRoleProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 140,
            elevation: 2,
            shadowColor: theme.colorScheme.shadow.withOpacity(0.15),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 18),
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeToUndManager,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          userRole.icon,
                          size: 14,
                          color: theme.colorScheme.onPrimary.withOpacity(0.85),
                          semanticLabel: userRole.name,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          userRole.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onPrimary.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary
                          .withBlue(theme.colorScheme.primary.blue + 10),
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Opacity(
                  opacity: 0.08,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 20),
                      child: Icon(
                        userRole.icon,
                        size: 80,
                        color: theme.colorScheme.onPrimary,
                        semanticLabel: userRole.name,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              if (userRole.canAccessNotifications)
                Tooltip(
                  message: l10n.notifications,
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    },
                  ),
                ),
              if (userRole.canAccessSettings)
                Tooltip(
                  message: l10n.settings,
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                  ),
                ),
              Tooltip(
                message: 'Profile',
                child: IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.userProfile);
                  },
                ),
              ),
            ],
          ),

          // Welcome section with user role info
          SliverToBoxAdapter(
            child: _buildWelcomeSection(context, l10n, ref, userRole),
          ),

          // Quick action buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              child: _buildQuickActionButtons(context, l10n, userRole),
            ),
          ),

          // Module header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.modules,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (!isLargeScreen)
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.view_module,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      label: Text(
                        'View All',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Modules grid or list - filtered by role
          isLargeScreen
              ? _buildModulesGrid(context, l10n, userRole)
              : _buildModulesList(context, l10n, userRole),

          // Footer space
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleIndicator(BuildContext context, UserRole userRole) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            userRole.icon,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            'Current role: ${userRole.name}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            child: Text(
              'Change',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, AppLocalizations l10n,
      WidgetRef ref, UserRole userRole) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
      child: Column(
        children: [
          // Role section
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withOpacity(0.6),
                  theme.colorScheme.primaryContainer.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    userRole.icon,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${userRole.name}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userRole.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daily stats overview
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insights,
                        color: theme.colorScheme.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Overview',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatItem(
                        context,
                        '12',
                        'Tasks',
                        Icons.task_alt,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        context,
                        '3',
                        'Alerts',
                        Icons.warning_amber,
                        Colors.orange,
                      ),
                      _buildStatItem(
                        context,
                        '5',
                        'Orders',
                        Icons.shopping_cart,
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Reset app button
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 8),
              child: TextButton.icon(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: theme.colorScheme.error.withOpacity(0.8),
                  size: 16,
                ),
                label: Text(
                  'Reset App',
                  style: TextStyle(
                    color: theme.colorScheme.error.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                onPressed: () => AppResetUtility.resetAppData(context, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesList(
      BuildContext context, AppLocalizations l10n, UserRole userRole) {
    // Filter the modules based on user role
    final allowedModules = appModules.entries
        .where((entry) => userRole.allowedModules.contains(entry.key))
        .toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = allowedModules[index];
          final moduleKey = entry.key;
          final module = entry.value;
          final moduleName =
              l10n.getModuleName(module.nameKey) ?? module.nameKey;

          return _buildModuleSection(context, moduleName, module);
        },
        childCount: allowedModules.length,
      ),
    );
  }

  Widget _buildModulesGrid(
      BuildContext context, AppLocalizations l10n, UserRole userRole) {
    // Filter the modules based on user role
    final allowedModules = appModules.entries
        .where((entry) => userRole.allowedModules.contains(entry.key))
        .toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final entry = allowedModules[index];
            final moduleKey = entry.key;
            final module = entry.value;
            final moduleName =
                l10n.getModuleName(module.nameKey) ?? module.nameKey;

            return _buildModuleCard(context, moduleName, module);
          },
          childCount: allowedModules.length,
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    AppModule module,
  ) {
    final theme = Theme.of(context);
    final isLightColor = module.color.computeLuminance() > 0.5;
    final textColor = isLightColor ? Colors.black87 : Colors.white;

    return Card(
      elevation: 1,
      shadowColor: module.color.withOpacity(0.2),
      margin: EdgeInsets.zero,
      color: module.color.withOpacity(0.85), // Fill with module color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // Show screen selection if module has multiple screens
          if (module.screens.length > 1) {
            _showModuleScreenSelection(context, title, module);
          } else if (module.screens.isNotEmpty) {
            // If module has only one screen, navigate directly
            Navigator.pushNamed(context, module.screens.first.route);
          }
        },
        borderRadius: BorderRadius.circular(8),
        splashColor: module.color.withOpacity(0.3),
        highlightColor: module.color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  module.icon,
                  size: 32,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  '${module.screens.length} ${module.screens.length == 1 ? 'screen' : 'screens'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show modal with all screens in the module
  void _showModuleScreenSelection(
    BuildContext context,
    String moduleTitle,
    AppModule module,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        module.color.withOpacity(0.7),
                        module.color.withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          module.icon,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              moduleTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Select a screen to navigate',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Screens list
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: module.screens.length,
                    itemBuilder: (context, index) {
                      final screen = module.screens[index];
                      final screenName =
                          l10n.getScreenName(screen.nameKey) ?? screen.nameKey;
                      final description =
                          l10n.getScreenDescription(screen.descriptionKey) ??
                              '';

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: module.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            screen.icon,
                            color: module.color,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          screenName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: description.isNotEmpty
                            ? Text(
                                description,
                                style: theme.textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(context); // Close the modal
                          Navigator.pushNamed(context, screen.route);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModuleSection(
    BuildContext context,
    String title,
    AppModule module,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shadowColor: module.color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Module header
          InkWell(
            onTap: () {
              // Show all screens in a bottom sheet if the module has screens
              if (module.screens.isNotEmpty) {
                _showModuleScreenSelection(context, title, module);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    module.color.withOpacity(0.7),
                    module.color.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      module.icon,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.apps, size: 18),
                      color: Colors.white,
                      onPressed: () {
                        // Show all screens in a bottom sheet
                        if (module.screens.isNotEmpty) {
                          _showModuleScreenSelection(context, title, module);
                        }
                      },
                      iconSize: 18,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Module screens
          if (module.screens.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(l10n.noScreensAvailable),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 450 ? 4 : 3;
                  final childAspectRatio = 0.85;

                  // Calculate the height needed for the grid
                  final itemCount =
                      module.screens.length > 6 ? 6 : module.screens.length;
                  final rowCount = (itemCount / crossAxisCount).ceil();
                  final totalHeight = rowCount *
                      (constraints.maxWidth /
                          crossAxisCount /
                          childAspectRatio);

                  return SizedBox(
                    height: totalHeight + 10, // Add a small buffer
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        final screen = module.screens[index];
                        final screenName = l10n.getScreenName(screen.nameKey) ??
                            screen.nameKey;
                        final description =
                            l10n.getScreenDescription(screen.descriptionKey) ??
                                '';

                        // If this is the last item and there are more than 6 screens,
                        // show a "More" button instead
                        if (index == 5 && module.screens.length > 6) {
                          return InkWell(
                            onTap: () {
                              _showModuleScreenSelection(
                                  context, title, module);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: module.color.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: module.color.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: module.color.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '+${module.screens.length - 5}',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: module.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'View more',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: module.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return _buildScreenCard(
                          context: context,
                          title: screenName,
                          icon: screen.icon,
                          color: module.color,
                          onTap: () {
                            Navigator.pushNamed(context, screen.route);
                          },
                          tooltip: description,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScreenCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String tooltip = '',
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: color.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Tooltip(
        message: tooltip.isNotEmpty ? tooltip : title,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons(
      BuildContext context, AppLocalizations l10n, UserRole userRole) {
    final theme = Theme.of(context);

    // Filter quick actions based on user role
    final List<Map<String, dynamic>> quickActions = [
      {
        'title': 'Purchase Orders',
        'icon': Icons.shopping_cart,
        'color': Colors.purple,
        'route': AppRoutes.purchaseOrders,
        'moduleId': 'procurement',
      },
      {
        'title': 'Inventory',
        'icon': Icons.inventory_2,
        'color': Colors.blue,
        'route': AppRoutes.inventoryDashboard,
        'moduleId': 'inventory',
      },
      {
        'title': 'Production',
        'icon': Icons.factory,
        'color': Colors.green,
        'route': AppRoutes.productionExecutions,
        'moduleId': 'factory',
      },
      {
        'title': 'Analytics',
        'icon': Icons.analytics,
        'color': Colors.amber,
        'route': AppRoutes.analyticsDashboard,
        'moduleId': 'analytics',
      },
    ];

    // Filter actions based on user role allowed modules
    final allowedActions = quickActions
        .where((action) => userRole.allowedModules.contains(action['moduleId']))
        .toList();

    // If no allowed actions, don't show the section
    if (allowedActions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bolt,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < allowedActions.length; i++)
                    Row(
                      children: [
                        _buildQuickActionButton(
                          context,
                          allowedActions[i]['title'],
                          allowedActions[i]['icon'],
                          allowedActions[i]['color'],
                          () => Navigator.pushNamed(
                              context, allowedActions[i]['route']),
                        ),
                        if (i < allowedActions.length - 1)
                          const SizedBox(width: 12),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }
}
