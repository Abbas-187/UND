import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../utils/report_aggregators.dart';
import '../utils/report_pdf_export.dart';
import '../widgets/report_widgets.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.aggregators});
  final ReportAggregators aggregators;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? selectedCategory;
  String? selectedExpiryStatus;
  String movementBreakdown = 'type';
  DateTimeRange? selectedDateRange;

  // GlobalKeys for chart RepaintBoundaries
  final GlobalKey stockChartKey = GlobalKey();
  final GlobalKey expiryChartKey = GlobalKey();
  final GlobalKey valuationChartKey = GlobalKey();
  final GlobalKey movementChartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> get expiryStatuses =>
      ['expired', 'expiring_soon', 'safe', 'no_expiry'];

  void _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDateRange: selectedDateRange ??
          DateTimeRange(
              start: now.subtract(const Duration(days: 30)), end: now),
    );
    if (picked != null) {
      setState(() => selectedDateRange = picked);
    }
  }

  Future<Uint8List?> _captureChartImage(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Widget _sectionHeader(String title, {List<Widget>? actions}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (actions != null) Row(children: actions),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stock'),
            Tab(text: 'Expiry'),
            Tab(text: 'Valuation'),
            Tab(text: 'Movements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- STOCK TAB ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _sectionHeader('Stock by Item'),
                const SizedBox(height: 8),
                StockTableWidget(
                  aggregators: widget.aggregators,
                ),
                const SizedBox(height: 24),
                _sectionHeader('Stock by Category'),
                const SizedBox(height: 8),
                RepaintBoundary(
                  key: stockChartKey,
                  child: StockBarChartWidget(aggregators: widget.aggregators),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export to PDF'),
                  onPressed: () async {
                    final chartImage = await _captureChartImage(stockChartKey);
                    debugPrint(
                        'Stock chart image bytes: \\${chartImage?.length ?? 0}');
                    if (chartImage == null || chartImage.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Chart image could not be captured. Make sure the chart is visible.')),
                        );
                      }
                    }
                    final stockData = await widget.aggregators.stockByItem();
                    ReportPdfExport.exportStockReportPdf(
                      context: context,
                      data: selectedCategory == null
                          ? stockData
                          : stockData
                              .where(
                                  (row) => row['category'] == selectedCategory)
                              .toList(),
                      categoryFilter: selectedCategory,
                      chartImage: chartImage,
                    );
                  },
                ),
              ],
            ),
          ),
          // --- EXPIRY TAB ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _sectionHeader('Expiry Status'),
                const SizedBox(height: 8),
                ExpiryTableWidget(
                  aggregators: widget.aggregators,
                ),
                const SizedBox(height: 24),
                _sectionHeader('Expiry Status Breakdown'),
                const SizedBox(height: 8),
                RepaintBoundary(
                  key: expiryChartKey,
                  child: ExpiryPieChartWidget(aggregators: widget.aggregators),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export to PDF'),
                  onPressed: () async {
                    final chartImage = await _captureChartImage(expiryChartKey);
                    debugPrint(
                        'Expiry chart image bytes: \\${chartImage?.length ?? 0}');
                    if (chartImage == null || chartImage.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Chart image could not be captured. Make sure the chart is visible.')),
                        );
                      }
                    }
                    final expiryData = await widget.aggregators.expiryStatus();
                    ReportPdfExport.exportExpiryReportPdf(
                      context: context,
                      data: selectedExpiryStatus == null
                          ? expiryData
                          : expiryData
                              .where((row) =>
                                  row['status'] == selectedExpiryStatus)
                              .toList(),
                      statusFilter: selectedExpiryStatus,
                      chartImage: chartImage,
                    );
                  },
                ),
              ],
            ),
          ),
          // --- VALUATION TAB ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _sectionHeader('Valuation by Item'),
                const SizedBox(height: 8),
                ValuationTableWidget(
                  aggregators: widget.aggregators,
                ),
                const SizedBox(height: 24),
                _sectionHeader('Valuation by Category'),
                const SizedBox(height: 8),
                RepaintBoundary(
                  key: valuationChartKey,
                  child:
                      ValuationBarChartWidget(aggregators: widget.aggregators),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export to PDF'),
                  onPressed: () async {
                    final chartImage =
                        await _captureChartImage(valuationChartKey);
                    debugPrint(
                        'Valuation chart image bytes: \\${chartImage?.length ?? 0}');
                    if (chartImage == null || chartImage.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Chart image could not be captured. Make sure the chart is visible.')),
                        );
                      }
                    }
                    final valuationData =
                        await widget.aggregators.valuationByItem();
                    ReportPdfExport.exportValuationReportPdf(
                      context: context,
                      data: selectedCategory == null
                          ? valuationData
                          : valuationData
                              .where(
                                  (row) => row['category'] == selectedCategory)
                              .toList(),
                      categoryFilter: selectedCategory,
                      chartImage: chartImage,
                    );
                  },
                ),
              ],
            ),
          ),
          // --- MOVEMENTS TAB ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _sectionHeader('Movements', actions: [
                  DropdownButton<String>(
                    value: movementBreakdown,
                    items: const [
                      DropdownMenuItem<String>(
                          value: 'type', child: Text('By Type')),
                      DropdownMenuItem<String>(
                          value: 'status', child: Text('By Status')),
                      DropdownMenuItem<String>(
                          value: 'date', child: Text('By Date')),
                    ],
                    onChanged: (val) =>
                        setState(() => movementBreakdown = val ?? 'type'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: const Text('Date Range'),
                    onPressed: _pickDateRange,
                  ),
                  if (selectedDateRange != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '${DateFormat.yMd().format(selectedDateRange!.start)} - ${DateFormat.yMd().format(selectedDateRange!.end)}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ]),
                const SizedBox(height: 8),
                MovementTableWidget(
                  aggregators: widget.aggregators,
                ),
                const SizedBox(height: 24),
                _sectionHeader('Movements Breakdown'),
                const SizedBox(height: 8),
                RepaintBoundary(
                  key: movementChartKey,
                  child: MovementBarChartWidget(
                    aggregators: widget.aggregators,
                    breakdown: movementBreakdown,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export to PDF'),
                  onPressed: () async {
                    final chartImage =
                        await _captureChartImage(movementChartKey);
                    debugPrint(
                        'Movements chart image bytes: \\${chartImage?.length ?? 0}');
                    if (chartImage == null || chartImage.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Chart image could not be captured. Make sure the chart is visible.')),
                        );
                      }
                    }
                    final allMovements =
                        await widget.aggregators.movementTable();
                    final movementData = selectedDateRange == null
                        ? allMovements
                        : allMovements.where((row) {
                            final date =
                                DateTime.tryParse(row['timestamp'].toString());
                            if (date == null) return false;
                            return date.isAfter(selectedDateRange!.start
                                    .subtract(const Duration(days: 1))) &&
                                date.isBefore(selectedDateRange!.end
                                    .add(const Duration(days: 1)));
                          }).toList();
                    ReportPdfExport.exportMovementsReportPdf(
                      context: context,
                      data: movementData,
                      breakdown: movementBreakdown,
                      dateRange: selectedDateRange,
                      chartImage: chartImage,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
