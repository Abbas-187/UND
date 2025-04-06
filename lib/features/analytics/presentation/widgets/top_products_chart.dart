import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TopProductsChart extends StatelessWidget {
  const TopProductsChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - in a real app, this would come from a provider
    final List<ProductSalesData> chartData = [
      ProductSalesData('Laptop X1', 35800),
      ProductSalesData('Smart TV 42"', 29500),
      ProductSalesData('Smartphone Z10', 27300),
      ProductSalesData('Bluetooth Speaker', 18600),
      ProductSalesData('Wireless Earbuds', 15200),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Products by Sales',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              labelStyle: const TextStyle(fontSize: 12),
            ),
            primaryYAxis: NumericAxis(
              numberFormat: NumberFormat.compact(),
              majorGridLines:
                  const MajorGridLines(width: 0.5, color: Colors.grey),
              labelStyle: const TextStyle(fontSize: 12),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              BarSeries<ProductSalesData, String>(
                dataSource: chartData,
                xValueMapper: (ProductSalesData data, _) => data.product,
                yValueMapper: (ProductSalesData data, _) => data.sales,
                name: 'Sales',
                color: Colors.blue,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.outer,
                  textStyle: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProductSalesData {

  ProductSalesData(this.product, this.sales);
  final String product;
  final double sales;
}
