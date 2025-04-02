enum ForecastGranularity { daily, weekly, monthly, quarterly, yearly }

/// Get a display name for a forecast granularity
String getGranularityName(ForecastGranularity granularity) {
  switch (granularity) {
    case ForecastGranularity.daily:
      return 'Daily';
    case ForecastGranularity.weekly:
      return 'Weekly';
    case ForecastGranularity.monthly:
      return 'Monthly';
    case ForecastGranularity.quarterly:
      return 'Quarterly';
    case ForecastGranularity.yearly:
      return 'Yearly';
    default:
      return granularity.toString().split('.').last;
  }
}

/// Get the number of days in a period for the given granularity
int getDaysInPeriod(ForecastGranularity granularity) {
  switch (granularity) {
    case ForecastGranularity.daily:
      return 1;
    case ForecastGranularity.weekly:
      return 7;
    case ForecastGranularity.monthly:
      return 30; // approximation
    case ForecastGranularity.quarterly:
      return 90; // approximation
    case ForecastGranularity.yearly:
      return 365; // approximation
    default:
      return 1;
  }
}
