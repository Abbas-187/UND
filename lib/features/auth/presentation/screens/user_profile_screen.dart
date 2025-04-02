import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/services/auth_service.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/primary_button.dart';

/// Screen for displaying and editing the current user's profile
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            // Not authenticated, redirect to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            });

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar and name
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.2),
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.displayName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(user.role.displayName),
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Account information
                const Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildInfoCard(
                  title: 'Email Status',
                  content: user.emailVerified ? 'Verified' : 'Not Verified',
                  icon: Icons.email,
                  iconColor: user.emailVerified ? Colors.green : Colors.orange,
                  trailing: user.emailVerified
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : TextButton(
                          onPressed: () {
                            // TODO: Implement verification email sending
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Verification email sent'),
                              ),
                            );
                          },
                          child: const Text('Verify Now'),
                        ),
                ),

                _buildInfoCard(
                  title: 'Account Created',
                  content: _formatDate(user.createdAt),
                  icon: Icons.calendar_today,
                ),

                if (user.lastLoginAt != null)
                  _buildInfoCard(
                    title: 'Last Login',
                    content: _formatDate(user.lastLoginAt!),
                    icon: Icons.login,
                  ),

                const SizedBox(height: 32),

                // Permissions section
                const Text(
                  'Your Permissions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildPermissionsList(user.permissions.toList()),

                const SizedBox(height: 32),

                // Sign out button
                PrimaryButton(
                  text: 'Sign Out',
                  onPressed: () => _signOut(context, ref),
                  icon: Icons.logout,
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    Color? iconColor,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Colors.blue,
        ),
        title: Text(title),
        subtitle: Text(content),
        trailing: trailing,
      ),
    );
  }

  Widget _buildPermissionsList(List<dynamic> permissions) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: permissions.length,
        itemBuilder: (context, index) {
          final permission = permissions[index];
          return ListTile(
            leading: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
            title: Text(
              permission.toString().split('.').last,
              style: const TextStyle(fontSize: 14),
            ),
            dense: true,
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
