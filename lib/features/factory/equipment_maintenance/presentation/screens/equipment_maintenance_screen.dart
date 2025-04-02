import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/equipment_model.dart';
import '../../data/models/maintenance_record_model.dart';
import '../../data/repositories/equipment_maintenance_repository.dart';
import '../../domain/providers/equipment_maintenance_provider.dart';
import '../widgets/equipment_status_card.dart';
import '../widgets/maintenance_schedule_card.dart';
import 'create_maintenance_record_screen.dart';

class EquipmentMaintenanceScreen extends ConsumerWidget {
  const EquipmentMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the providers to get AsyncValue objects
    final allEquipment = ref.watch(allEquipmentProvider);
    final maintenanceRequired =
        ref.watch(equipmentRequiringMaintenanceProvider);
    final sanitizationRequired =
        ref.watch(equipmentRequiringSanitizationProvider);
    final upcomingMaintenance = ref.watch(upcomingMaintenanceRecordsProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Equipment Maintenance'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'All Equipment'),
              Tab(text: 'Maintenance'),
              Tab(text: 'Sanitization'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showAddOptionsDialog(context, ref);
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            _buildOverviewTab(context, ref, maintenanceRequired,
                sanitizationRequired, upcomingMaintenance),

            // All Equipment Tab
            allEquipment.when(
              data: (equipment) => _buildEquipmentList(
                context,
                equipment,
                'No equipment found',
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load equipment',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your connection and try again',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(allEquipmentProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

            // Maintenance Tab
            maintenanceRequired.when(
              data: (equipment) => _buildEquipmentList(
                context,
                equipment,
                'No equipment requires maintenance',
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load maintenance data',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your connection and try again',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.invalidate(equipmentRequiringMaintenanceProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

            // Sanitization Tab
            sanitizationRequired.when(
              data: (equipment) => _buildEquipmentList(
                context,
                equipment,
                'No equipment requires sanitization',
                isSanitization: true,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load sanitization data',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your connection and try again',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref
                          .invalidate(equipmentRequiringSanitizationProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            try {
              // Get repository directly from ref
              final repository =
                  ref.read(equipmentMaintenanceRepositoryProvider);
              final ids = await repository.createScheduledMaintenanceForAll();

              // Invalidate providers to refresh data
              ref.invalidate(upcomingMaintenanceRecordsProvider);
              ref.invalidate(allEquipmentProvider);
              ref.invalidate(equipmentRequiringMaintenanceProvider);

              if (ids.isNotEmpty && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Scheduled maintenance for ${ids.length} equipment'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No new maintenance was scheduled'),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error scheduling maintenance: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          tooltip: 'Schedule maintenance for all equipment',
          child: const Icon(Icons.calendar_today),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<EquipmentModel>> maintenanceRequired,
    AsyncValue<List<EquipmentModel>> sanitizationRequired,
    AsyncValue<List<MaintenanceRecordModel>> upcomingMaintenance,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Equipment Status',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Equipment Status Cards
          Row(
            children: [
              Expanded(
                child: Builder(
                    builder: (context) => EquipmentStatusCard(
                          title: 'Maintenance Required',
                          count: maintenanceRequired.when(
                            data: (data) => data.length,
                            loading: () => null,
                            error: (_, __) => 0,
                          ),
                          icon: Icons.build,
                          color: Colors.orange,
                          onTap: () {
                            DefaultTabController.of(context).animateTo(2);
                          },
                        )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Builder(
                    builder: (context) => EquipmentStatusCard(
                          title: 'Sanitization Required',
                          count: sanitizationRequired.when(
                            data: (data) => data.length,
                            loading: () => null,
                            error: (_, __) => 0,
                          ),
                          icon: Icons.sanitizer,
                          color: Colors.blue,
                          onTap: () {
                            DefaultTabController.of(context).animateTo(3);
                          },
                        )),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Text(
            'Upcoming Maintenance',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Upcoming Maintenance Schedule
          upcomingMaintenance.when(
            data: (records) {
              if (records.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No upcoming maintenance scheduled'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length > 5 ? 5 : records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return MaintenanceScheduleCard(
                    record: record,
                    onTap: () {},
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading maintenance schedule: $error'),
            ),
          ),
          const SizedBox(height: 16),
          if (upcomingMaintenance.maybeWhen(
            data: (records) => records.length > 5,
            orElse: () => false,
          ))
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to full maintenance schedule
                },
                child: const Text('View All Scheduled Maintenance'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEquipmentList(
    BuildContext context,
    List<EquipmentModel> equipment,
    String emptyMessage, {
    bool isSanitization = false,
  }) {
    if (equipment.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSanitization ? Icons.sanitizer : Icons.build_circle,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: equipment.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final equip = equipment[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: _buildEquipmentTypeIcon(equip.type),
            title: Text(equip.name),
            subtitle: Text(
              '${equip.manufacturer} ${equip.model}\n'
              'Status: ${_formatStatus(equip.status)}',
            ),
            trailing: _buildStatusIcon(equip.status),
            isThreeLine: true,
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildEquipmentTypeIcon(EquipmentType type) {
    IconData iconData;

    switch (type) {
      case EquipmentType.pasteurizer:
        iconData = Icons.local_drink;
        break;
      case EquipmentType.homogenizer:
        iconData = Icons.blender;
        break;
      case EquipmentType.separator:
        iconData = Icons.filter_alt;
        break;
      case EquipmentType.tank:
        iconData = Icons.water_damage;
        break;
      case EquipmentType.packagingMachine:
        iconData = Icons.inventory_2;
        break;
      case EquipmentType.coolingSystem:
        iconData = Icons.ac_unit;
        break;
      case EquipmentType.cIP:
        iconData = Icons.cleaning_services;
        break;
      default:
        iconData = Icons.precision_manufacturing;
    }

    return CircleAvatar(
      child: Icon(iconData),
    );
  }

  Widget _buildStatusIcon(EquipmentStatus status) {
    IconData iconData;
    Color color;

    switch (status) {
      case EquipmentStatus.operational:
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case EquipmentStatus.maintenance:
        iconData = Icons.build;
        color = Colors.orange;
        break;
      case EquipmentStatus.repair:
        iconData = Icons.home_repair_service;
        color = Colors.red;
        break;
      case EquipmentStatus.sanitization:
        iconData = Icons.sanitizer;
        color = Colors.blue;
        break;
      case EquipmentStatus.retired:
        iconData = Icons.cancel;
        color = Colors.red;
        break;
      case EquipmentStatus.standby:
        iconData = Icons.pause_circle_filled;
        color = Colors.amber;
        break;
      default:
        iconData = Icons.help;
        color = Colors.grey;
    }

    return Icon(iconData, color: color);
  }

  String _formatStatus(EquipmentStatus status) {
    switch (status) {
      case EquipmentStatus.operational:
        return 'Operational';
      case EquipmentStatus.maintenance:
        return 'Under Maintenance';
      case EquipmentStatus.repair:
        return 'Under Repair';
      case EquipmentStatus.sanitization:
        return 'Sanitization';
      case EquipmentStatus.retired:
        return 'Retired';
      case EquipmentStatus.standby:
        return 'Standby';
      default:
        return status.toString().split('.').last;
    }
  }

  void _showAddOptionsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add New'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to create equipment screen
            },
            child: const ListTile(
              leading: Icon(Icons.precision_manufacturing),
              title: Text('New Equipment'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              // Show dialog to select equipment
              _showSelectEquipmentDialog(context, ref);
            },
            child: const ListTile(
              leading: Icon(Icons.build),
              title: Text('New Maintenance Record'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectEquipmentDialog(BuildContext context, WidgetRef ref) {
    // Use the allEquipmentProvider's value
    final equipmentAsync = ref.watch(allEquipmentProvider);

    equipmentAsync.when(
      data: (equipment) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              title: const Text('Select Equipment'),
              children: [
                ...equipment.map(
                  (e) => SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Builder(
                              builder: (context) =>
                                  CreateMaintenanceRecordScreen(equipment: e)),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: _buildEquipmentTypeIcon(e.type),
                      title: Text(e.name),
                      subtitle: Text('${e.manufacturer} ${e.model}'),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
      loading: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loading equipment...'),
            ),
          );
        }
      },
      error: (error, stackTrace) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading equipment: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}
