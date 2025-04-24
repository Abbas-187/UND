import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/user_role.dart';
import '../services/role_permission_service.dart';

/// A widget that provides filtering capabilities for the order list screen
/// with role-based filter options
class OrderFilterBar extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  // Current user info - in a real app, this would come from authentication
  final String userId;
  final RoleType userRole;
  final String userLocation;

  const OrderFilterBar({
    Key? key,
    required this.onFilterChanged,
    required this.userId,
    required this.userRole,
    required this.userLocation,
  }) : super(key: key);

  @override
  ConsumerState<OrderFilterBar> createState() => _OrderFilterBarState();
}

class _OrderFilterBarState extends ConsumerState<OrderFilterBar> {
  // Filter state
  String? _selectedStatus;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _searchQuery;
  RoleType? _selectedRole;
  String? _selectedLocation;
  bool _showOnlyMine = false;

  // UI control
  bool _showAdvancedFilters = false;

  @override
  void initState() {
    super.initState();

    // Set initial filters based on role
    _initializeFiltersBasedOnRole();
  }

  void _initializeFiltersBasedOnRole() {
    // For sales representatives, default to showing only their orders
    if (widget.userRole == RoleType.salesRepresentative) {
      setState(() {
        _showOnlyMine = true;
      });
    }

    // For location-restricted roles, set the location filter to their location
    if (widget.userRole != RoleType.admin &&
        widget.userRole != RoleType.regionalManager) {
      setState(() {
        _selectedLocation = widget.userLocation;
      });
    }

    // Apply initial filters
    _applyFilters();
  }

  void _applyFilters() {
    // Build filter map
    final Map<String, dynamic> filters = {
      'userId': _showOnlyMine ? widget.userId : null,
      'status': _selectedStatus,
      'fromDate': _fromDate,
      'toDate': _toDate,
      'searchQuery': _searchQuery,
      'role': _selectedRole,
      'location': _selectedLocation,
    };

    // Notify parent
    widget.onFilterChanged(filters);
  }

  @override
  Widget build(BuildContext context) {
    final rolePermissionService = ref.watch(rolePermissionServiceProvider);

    // Get available locations based on role
    List<String> availableLocations = _getAvailableLocations();

    // Get roles visible to current user
    Set<RoleType> visibleRoles =
        rolePermissionService.getVisibleRolesForUser(widget.userRole);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic filters row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Status filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                      _applyFilters();
                    });
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...OrderStatus.values.map((status) {
                      return DropdownMenuItem<String>(
                        value: status.name,
                        child: Text(status.name),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Search field
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Orders',
                    border: const OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    suffixIcon: _searchQuery != null && _searchQuery!.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = null;
                                _applyFilters();
                              });
                            },
                          )
                        : const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.isEmpty ? null : value;
                      _applyFilters();
                    });
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Only My Orders checkbox - only visible for certain roles
              if (widget.userRole != RoleType.admin)
                Row(
                  children: [
                    Checkbox(
                      value: _showOnlyMine,
                      onChanged: (value) {
                        setState(() {
                          _showOnlyMine = value ?? false;
                          _applyFilters();
                        });
                      },
                    ),
                    const Text('Only My Orders'),
                  ],
                ),

              // Toggle advanced filters
              TextButton.icon(
                icon: Icon(_showAdvancedFilters
                    ? Icons.expand_less
                    : Icons.expand_more),
                label: Text(
                    _showAdvancedFilters ? 'Less Filters' : 'More Filters'),
                onPressed: () {
                  setState(() {
                    _showAdvancedFilters = !_showAdvancedFilters;
                  });
                },
              ),
            ],
          ),
        ),

        // Advanced filters - conditionally visible
        if (_showAdvancedFilters)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Date range from
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _fromDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );

                          if (date != null) {
                            setState(() {
                              _fromDate = date;
                              _applyFilters();
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'From Date',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              suffixIcon: _fromDate != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _fromDate = null;
                                          _applyFilters();
                                        });
                                      },
                                    )
                                  : const Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: _fromDate != null
                                  ? '${_fromDate!.month}/${_fromDate!.day}/${_fromDate!.year}'
                                  : '',
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Date range to
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _toDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );

                          if (date != null) {
                            setState(() {
                              _toDate = date;
                              _applyFilters();
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'To Date',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              suffixIcon: _toDate != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _toDate = null;
                                          _applyFilters();
                                        });
                                      },
                                    )
                                  : const Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: _toDate != null
                                  ? '${_toDate!.month}/${_toDate!.day}/${_toDate!.year}'
                                  : '',
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Location filter - only for managers who can see multiple locations
                    if (widget.userRole == RoleType.admin ||
                        widget.userRole == RoleType.regionalManager)
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          value: _selectedLocation,
                          onChanged: (value) {
                            setState(() {
                              _selectedLocation = value;
                              _applyFilters();
                            });
                          },
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('All Locations'),
                            ),
                            ...availableLocations.map((location) {
                              return DropdownMenuItem<String>(
                                value: location,
                                child: Text(location),
                              );
                            }),
                          ],
                        ),
                      ),

                    // Role filter - only for managers who can see subordinates
                    if (visibleRoles.length > 1)
                      Expanded(
                        child: DropdownButtonFormField<RoleType>(
                          decoration: const InputDecoration(
                            labelText: 'Created By Role',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          value: _selectedRole,
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                              _applyFilters();
                            });
                          },
                          items: [
                            const DropdownMenuItem<RoleType>(
                              value: null,
                              child: Text('All Roles'),
                            ),
                            ...visibleRoles.map((role) {
                              return DropdownMenuItem<RoleType>(
                                value: role,
                                child: Text(role.displayName),
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Filter buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedStatus = null;
                          _fromDate = null;
                          _toDate = null;
                          _searchQuery = null;
                          _selectedRole = null;

                          // Don't reset location and myOrders for restricted users
                          if (widget.userRole == RoleType.admin ||
                              widget.userRole == RoleType.regionalManager) {
                            _selectedLocation = null;
                          }

                          if (widget.userRole != RoleType.salesRepresentative) {
                            _showOnlyMine = false;
                          }

                          _applyFilters();
                        });
                      },
                      child: const Text('Clear Filters'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Apply Filters'),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Get available locations based on user role
  List<String> _getAvailableLocations() {
    // In a real app, this would come from your locations database
    // Filtered based on user permissions

    if (widget.userRole == RoleType.admin ||
        widget.userRole == RoleType.regionalManager) {
      // Regional/admin can see all locations
      return ['Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Eldoret'];
    } else {
      // Other roles only see their own location
      return [widget.userLocation];
    }
  }
}
