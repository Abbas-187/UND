import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum PermissionCheckType {
  any, // User needs at least one of the permissions
  all // User needs all of the permissions
}

class PermissionWidget extends StatefulWidget {
  final List<String> permissions;
  final PermissionCheckType checkType;
  final Widget child;
  final Widget? fallback;
  final bool hideIfNoPermission;

  const PermissionWidget({
    Key? key,
    required this.permissions,
    this.checkType = PermissionCheckType.any,
    required this.child,
    this.fallback,
    this.hideIfNoPermission = true,
  }) : super(key: key);

  @override
  _PermissionWidgetState createState() => _PermissionWidgetState();
}

class _PermissionWidgetState extends State<PermissionWidget> {
  final AuthService _authService = AuthService();
  bool? _hasPermission;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void didUpdateWidget(PermissionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.permissions != widget.permissions ||
        oldWidget.checkType != widget.checkType) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final currentRole = await _authService.getCurrentUserRole();
    if (currentRole == null) {
      setState(() => _hasPermission = false);
      return;
    }

    final userRole = currentRole;

    // In a real implementation, you would check if the user has specific permissions
    // For now, we'll just check if the user role string matches any of the permissions
    final bool hasPermission = widget.checkType == PermissionCheckType.all
        ? widget.permissions.every((perm) => userRole.toString().contains(perm))
        : widget.permissions.any((perm) => userRole.toString().contains(perm));

    setState(() => _hasPermission = hasPermission);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPermission == null) {
      return const SizedBox.shrink(); // Still checking permissions
    }

    if (_hasPermission!) {
      return widget.child;
    }

    if (widget.hideIfNoPermission) {
      return const SizedBox.shrink();
    }

    return widget.fallback ?? const SizedBox.shrink();
  }
}
