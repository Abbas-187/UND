/// API endpoints used across the application
class ApiEndpoints {
  ApiEndpoints._(); // Private constructor to prevent instantiation

  // Base URL
  static const String baseUrl = 'https://api.example.com/v1';

  // Order endpoints
  static const String orders = '$baseUrl/orders';

  // Order discussion endpoints
  static const String orderDiscussions = '$baseUrl/orders/discussions';

  // Customer endpoints
  static const String customers = '$baseUrl/customers';

  // Inventory endpoints
  static const String inventory = '$baseUrl/inventory';

  // Procurement endpoints
  static const String procurement = '$baseUrl/procurement';

  // Production endpoints
  static const String production = '$baseUrl/production';

  // Authentication endpoints
  static const String auth = '$baseUrl/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String refreshToken = '$auth/refresh-token';
}
