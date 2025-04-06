import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/models/app_user.dart';
import '../../../../core/auth/models/permission.dart';
import '../../../../core/auth/models/user_role.dart';
import '../../../../core/auth/services/auth_service.dart';
import '../../../../core/auth/widgets/permission_wrapper.dart';

/// Provider to get all users from the auth service
final usersProvider = FutureProvider<List<AppUser>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getAllUsers();
});

/// Screen for managing users
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filter users based on search query
  List<AppUser> _filterUsers(List<AppUser> users) {
    if (_searchQuery.isEmpty) {
      return users;
    }

    final query = _searchQuery.toLowerCase();
    return users.where((user) {
      return user.displayName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.name.toLowerCase().contains(query);
    }).toList();
  }

  /// Refresh the users list
  Future<void> _refreshUsers() async {
    ref.refresh(usersProvider);
  }

  /// Update a user's role
  Future<void> _updateUserRole(AppUser user, UserRole newRole) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateUserRole(user.id, newRole);

      // Refresh the users list
      _refreshUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User role updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user role: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Delete a user
  Future<void> _deleteUser(AppUser user) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user.displayName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.deleteUser(user.id);

      // Refresh the users list
      _refreshUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show role selection dialog
  void _showRoleSelectionDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current role: ${user.role.displayName}'),
            const SizedBox(height: 16),
            const Text('Select new role:'),
            const SizedBox(height: 8),
            ...UserRole.values.map((role) {
              return ListTile(
                title: Text(role.displayName),
                subtitle: Text('${role.permissions.length} permissions'),
                leading: Icon(
                  Icons.check_circle,
                  color: role == user.role ? Colors.green : Colors.transparent,
                ),
                onTap: role == user.role
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        _updateUserRole(user, role);
                      },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with permission check
    return PermissionWrapper(
      requiredPermission: Permission.userManage,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _refreshUsers,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // User list
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final usersAsyncValue = ref.watch(usersProvider);

                  return usersAsyncValue.when(
                    data: (users) {
                      final filteredUsers = _filterUsers(users);

                      if (filteredUsers.isEmpty) {
                        return const Center(
                          child: Text('No users found'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return _buildUserCard(user);
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Text('Error: ${error.toString()}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to create user screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Create user feature coming soon'),
              ),
            );
          },
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  /// Build a card for a user
  Widget _buildUserCard(AppUser user) {
    final currentUser = ref.read(currentUserProvider).value;
    final isCurrentUser = currentUser?.id == user.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(
                          user.displayName.isNotEmpty
                              ? user.displayName.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentUser)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'You',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text(user.role.displayName),
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                if (user.emailVerified)
                  Chip(
                    label: const Text('Verified'),
                    backgroundColor: Colors.green.withOpacity(0.1),
                    avatar: const Icon(
                      Icons.verified,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isCurrentUser) ...[
                  TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Change Role'),
                    onPressed: _isLoading
                        ? null
                        : () => _showRoleSelectionDialog(user),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                    onPressed: _isLoading ? null : () => _deleteUser(user),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
