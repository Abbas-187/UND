// filepath: c:\FlutterProjects\und\lib\features\ai\presentation\widgets\responsive_ai_components.dart

import 'package:flutter/material.dart';
import '../../../../core/widgets/responsive_builder.dart';

/// Responsive AI component that adapts to different screen sizes
class ResponsiveAIComponent extends StatelessWidget {
  final Widget mobileWidget;
  final Widget? tabletWidget;
  final Widget? desktopWidget;
  final EdgeInsets? padding;
  final bool showHeader;
  final String? title;
  final List<Widget>? actions;

  const ResponsiveAIComponent({
    super.key,
    required this.mobileWidget,
    this.tabletWidget,
    this.desktopWidget,
    this.padding,
    this.showHeader = false,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildWithWrapper(mobileWidget, isMobile: true),
      tablet: _buildWithWrapper(tabletWidget ?? mobileWidget, isMobile: false),
      desktop: _buildWithWrapper(desktopWidget ?? tabletWidget ?? mobileWidget,
          isMobile: false),
    );
  }

  Widget _buildWithWrapper(Widget child, {required bool isMobile}) {
    if (!showHeader || title == null) {
      return Padding(
        padding: padding ?? EdgeInsets.all(isMobile ? 8.0 : 16.0),
        child: child,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
          child: _buildHeader(isMobile),
        ),
        Expanded(
          child: Padding(
            padding: padding ?? EdgeInsets.all(isMobile ? 8.0 : 16.0),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title!,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }
}

/// Responsive card component for AI features
class ResponsiveAICard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final IconData? icon;
  final Color? iconColor;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final bool isLoading;
  final String? errorMessage;

  const ResponsiveAICard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.icon,
    this.iconColor,
    this.actions,
    this.onTap,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildCard(context, isMobile: true),
      tablet: _buildCard(context, isMobile: false),
      desktop: _buildCard(context, isMobile: false),
    );
  }

  Widget _buildCard(BuildContext context, {required bool isMobile}) {
    Widget cardContent = Padding(
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(isMobile),
          if (subtitle != null) ...[
            SizedBox(height: isMobile ? 4 : 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          SizedBox(height: isMobile ? 12 : 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            _buildErrorState(isMobile)
          else
            child,
        ],
      ),
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: cardContent,
      );
    }

    return Card(
      elevation: isMobile ? 2 : 4,
      child: cardContent,
    );
  }

  Widget _buildCardHeader(bool isMobile) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: iconColor ?? Colors.blue,
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 6 : 8),
        ],
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 14 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }

  Widget _buildErrorState(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: isMobile ? 16 : 20,
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive metrics grid for AI dashboards
class ResponsiveMetricsGrid extends StatelessWidget {
  final List<MetricItem> metrics;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;

  const ResponsiveMetricsGrid({
    super.key,
    required this.metrics,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildGrid(mobileColumns!),
      tablet: _buildGrid(tabletColumns!),
      desktop: _buildGrid(desktopColumns!),
    );
  }

  Widget _buildGrid(int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        return MetricCard(metric: metrics[index]);
      },
    );
  }
}

/// Individual metric card
class MetricCard extends StatelessWidget {
  final MetricItem metric;

  const MetricCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildCard(context, isMobile: true),
      tablet: _buildCard(context, isMobile: false),
      desktop: _buildCard(context, isMobile: false),
    );
  }

  Widget _buildCard(BuildContext context, {required bool isMobile}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  metric.icon,
                  color: metric.color,
                  size: isMobile ? 16 : 20,
                ),
                const Spacer(),
                if (metric.trend != null)
                  Icon(
                    metric.trend! > 0 ? Icons.trending_up : Icons.trending_down,
                    color: metric.trend! > 0 ? Colors.green : Colors.red,
                    size: isMobile ? 12 : 16,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              metric.value,
              style: TextStyle(
                fontSize: isMobile ? 18 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              metric.label,
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (metric.trend != null)
              Text(
                '${metric.trend! > 0 ? '+' : ''}${metric.trend!.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: isMobile ? 8 : 10,
                  color: metric.trend! > 0 ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Data model for metrics
class MetricItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? trend;

  MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });
}

/// Responsive chart container
class ResponsiveChartContainer extends StatelessWidget {
  final Widget chart;
  final String title;
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;

  const ResponsiveChartContainer({
    super.key,
    required this.chart,
    required this.title,
    this.mobileHeight = 200,
    this.tabletHeight = 300,
    this.desktopHeight = 400,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildContainer(mobileHeight!, isMobile: true),
      tablet: _buildContainer(tabletHeight!, isMobile: false),
      desktop: _buildContainer(desktopHeight!, isMobile: false),
    );
  }

  Widget _buildContainer(double height, {required bool isMobile}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 14 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            SizedBox(
              height: height,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}

/// Responsive AI feature list
class ResponsiveAIFeatureList extends StatelessWidget {
  final List<AIFeatureItem> features;
  final bool isHorizontal;

  const ResponsiveAIFeatureList({
    super.key,
    required this.features,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return AIFeatureTile(feature: features[index], isCompact: true);
      },
    );
  }

  Widget _buildTabletLayout() {
    if (isHorizontal) {
      return SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: features.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 200,
              child: AIFeatureTile(feature: features[index], isCompact: false),
            );
          },
        ),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return AIFeatureTile(feature: features[index], isCompact: false);
        },
      );
    }
  }

  Widget _buildDesktopLayout() {
    if (isHorizontal) {
      return SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: features.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 250,
              child: AIFeatureTile(feature: features[index], isCompact: false),
            );
          },
        ),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return AIFeatureTile(feature: features[index], isCompact: false);
        },
      );
    }
  }
}

/// Individual AI feature tile
class AIFeatureTile extends StatelessWidget {
  final AIFeatureItem feature;
  final bool isCompact;

  const AIFeatureTile({
    super.key,
    required this.feature,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: feature.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 8.0 : 12.0),
          child: isCompact ? _buildCompactLayout() : _buildNormalLayout(),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Row(
      children: [
        Icon(
          feature.icon,
          color: feature.color,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (feature.subtitle != null)
                Text(
                  feature.subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 12),
      ],
    );
  }

  Widget _buildNormalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              feature.icon,
              color: feature.color,
              size: 24,
            ),
            const Spacer(),
            if (feature.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: feature.badgeColor ?? Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  feature.badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          feature.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (feature.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            feature.subtitle!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ],
    );
  }
}

/// Data model for AI features
class AIFeatureItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? badge;
  final Color? badgeColor;

  AIFeatureItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.badge,
    this.badgeColor,
  });
}
