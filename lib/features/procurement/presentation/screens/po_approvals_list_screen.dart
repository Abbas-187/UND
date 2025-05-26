import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/in_memory_purchase_requests.dart';

class POApprovalsListScreen extends StatefulWidget {
  const POApprovalsListScreen({super.key});

  @override
  State<POApprovalsListScreen> createState() => _POApprovalsListScreenState();
}

class _POApprovalsListScreenState extends State<POApprovalsListScreen> {
  String _search = '';
  bool _loading = true;
  late List<Map<String, dynamic>> _orders;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));
    _orders = InMemoryPurchaseOrders.orders;
    setState(() => _loading = false);
  }

  List<Map<String, dynamic>> _filterPOs(String status) {
    final filtered = _orders.where((po) {
      final matchesStatus = () {
        switch (status) {
          case 'pending':
            return po['status'] == 'pending' ||
                po['status'] == 'Pending Approval';
          case 'approved':
            return po['status'] == 'approved' || po['status'] == 'Approved';
          case 'rejected':
            return po['status'] == 'rejected' ||
                po['status'] == 'declined' ||
                po['status'] == 'Rejected' ||
                po['status'] == 'Declined';
          default:
            return false;
        }
      }();
      final matchesSearch = _search.isEmpty ||
          (po['poNumber']
                  ?.toString()
                  .toLowerCase()
                  .contains(_search.toLowerCase()) ??
              false) ||
          (po['supplierName']
                  ?.toString()
                  .toLowerCase()
                  .contains(_search.toLowerCase()) ??
              false) ||
          (po['supplier']
                  ?.toString()
                  .toLowerCase()
                  .contains(_search.toLowerCase()) ??
              false);
      return matchesStatus && matchesSearch;
    }).toList();
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pending = _filterPOs('pending');
    final approved = _filterPOs('approved');
    final rejected = _filterPOs('rejected');
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('PO Approvals',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: colorScheme.onPrimary)),
          backgroundColor: colorScheme.primary,
          elevation: 4,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: Container(
              color: colorScheme.primary,
              child: TabBar(
                indicatorColor: colorScheme.secondary,
                labelColor: colorScheme.onPrimary,
                unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7),
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    text: 'Pending (${pending.length})',
                    icon:
                        Icon(Icons.hourglass_top, color: colorScheme.secondary),
                  ),
                  Tab(
                    text: 'Approved (${approved.length})',
                    icon:
                        Icon(Icons.check_circle, color: colorScheme.secondary),
                  ),
                  Tab(
                    text: 'Rejected (${rejected.length})',
                    icon: Icon(Icons.cancel, color: colorScheme.secondary),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              backgroundColor: colorScheme.surface,
              builder: (context) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PO Approvals Help',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                        '• Use the search bar to quickly find a PO by number or supplier.',
                        style: theme.textTheme.bodyMedium),
                    Text('• Tap on a PO to view and approve or reject it.',
                        style: theme.textTheme.bodyMedium),
                    Text('• Pull down to refresh the list.',
                        style: theme.textTheme.bodyMedium),
                    Text('• The tab labels show counts for each status.',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          },
          icon: const Icon(Icons.help_outline),
          label: const Text('Help'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              gradient: LinearGradient(
                colors: [
                  colorScheme.surface,
                  colorScheme.surfaceContainerHighest.withOpacity(0.5)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Semantics(
                    label: 'Search purchase orders',
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.search, color: colorScheme.primary),
                        hintText: 'Search by PO number or supplier',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6)),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _loading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: colorScheme.primary))
                      : RefreshIndicator(
                          color: colorScheme.primary,
                          onRefresh: _fetchData,
                          child: TabBarView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildPOList(context, pending,
                                  'No purchase orders pending approval.'),
                              _buildPOList(context, approved,
                                  'No approved purchase orders.'),
                              _buildPOList(context, rejected,
                                  'No rejected purchase orders.'),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPOList(
      BuildContext context, List<Map<String, dynamic>> pos, String emptyMsg) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (pos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          Icon(Icons.inbox, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            emptyMsg,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
      itemCount: pos.length,
      separatorBuilder: (context, __) =>
          Divider(color: Theme.of(context).dividerColor, height: 14),
      itemBuilder: (context, index) {
        final po = pos[index];
        return _POApprovalCard(po: po);
      },
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader(
      {required this.pending, required this.approved, required this.rejected});
  final int pending;
  final int approved;
  final int rejected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatusCount(
              icon: Icons.hourglass_top,
              label: 'Pending',
              count: pending,
              color: Colors.orange.shade700,
            ),
            _StatusCount(
              icon: Icons.check_circle,
              label: 'Approved',
              count: approved,
              color: Colors.green.shade700,
            ),
            _StatusCount(
              icon: Icons.cancel,
              label: 'Rejected',
              count: rejected,
              color: Colors.red.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  const _StatusCount(
      {required this.icon,
      required this.label,
      required this.count,
      required this.color});
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text('$count',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(label,
            style: TextStyle(fontSize: 13, color: color.withOpacity(0.8))),
      ],
    );
  }
}

class _POApprovalCard extends StatelessWidget {
  const _POApprovalCard({required this.po});
  final Map<String, dynamic> po;

  Color _statusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending approval':
        return colorScheme.tertiary;
      case 'approved':
        return colorScheme.primary;
      case 'rejected':
      case 'declined':
        return colorScheme.error;
      default:
        return colorScheme.outlineVariant;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending approval':
        return Icons.hourglass_top;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
      case 'declined':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = po['status']?.toString() ?? '';
    return Semantics(
      label: 'Purchase order ${po['poNumber'] ?? ''}, status $status',
      button: true,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: colorScheme.surface,
        shadowColor: _statusColor(context, status).withOpacity(0.18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.go('/procurement/po/${po['id']}/approval'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description,
                        color: colorScheme.primary, size: 32),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        po['poNumber'] ?? '',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _statusColor(context, status).withOpacity(0.13),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(_statusIcon(status),
                              color: _statusColor(context, status), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            status,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _statusColor(context, status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.business, color: colorScheme.outline, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        po['supplierName'] ?? po['supplier'] ?? '-',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money,
                        color: colorScheme.outline, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      po['totalAmount'] != null
                          ? '\$${po['totalAmount'].toStringAsFixed(2)}'
                          : (po['amount'] != null
                              ? '\$${po['amount'].toStringAsFixed(2)}'
                              : '-'),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurface),
                    ),
                    const SizedBox(width: 18),
                    Icon(Icons.calendar_today,
                        color: colorScheme.outline, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      po['requestDate'] != null
                          ? _formatDate(po['requestDate'])
                          : '-',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('View & Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 18),
                      elevation: 2,
                    ),
                    onPressed: () {
                      context.go('/procurement/po/${po['id']}/approval');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
