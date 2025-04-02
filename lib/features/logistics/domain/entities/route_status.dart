enum RouteStatus { planned, inProgress, completed, cancelled, delayed }

extension RouteStatusExtension on RouteStatus {
  String get name {
    switch (this) {
      case RouteStatus.planned:
        return 'Planned';
      case RouteStatus.inProgress:
        return 'In Progress';
      case RouteStatus.completed:
        return 'Completed';
      case RouteStatus.cancelled:
        return 'Cancelled';
      case RouteStatus.delayed:
        return 'Delayed';
    }
  }
}
