enum ForecastMethod {
  movingAverage,
  exponentialSmoothing,
  linearRegression,
  seasonalDecomposition,
  arima,
  machineLearningSales
}

/// Get a display name for a forecast method
String getForecastMethodName(ForecastMethod method) {
  switch (method) {
    case ForecastMethod.movingAverage:
      return 'Moving Average';
    case ForecastMethod.exponentialSmoothing:
      return 'Exponential Smoothing';
    case ForecastMethod.linearRegression:
      return 'Linear Regression';
    case ForecastMethod.seasonalDecomposition:
      return 'Seasonal Decomposition';
    case ForecastMethod.arima:
      return 'ARIMA';
    case ForecastMethod.machineLearningSales:
      return 'Machine Learning';
    default:
      return method.toString().split('.').last;
  }
}
