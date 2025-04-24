/// Configuration class for API endpoints and authentication
class ApiConfig {
  /// Base URL for the CRM API
  final String crmApiUrl;

  /// API key for authenticating with the CRM API
  final String crmApiKey;

  /// Base URL for the inventory API
  final String inventoryApiUrl;

  /// API key for authenticating with the inventory API
  final String inventoryApiKey;

  /// Default constructor with environment-specific configuration
  ApiConfig({
    this.crmApiUrl = 'https://api.crm.example.com/v1',
    this.crmApiKey = 'crm-api-key-placeholder',
    this.inventoryApiUrl = 'https://api.inventory.example.com/v1',
    this.inventoryApiKey = 'inventory-api-key-placeholder',
  });

  /// Creates an ApiConfig instance for development environment
  factory ApiConfig.development() {
    return ApiConfig(
      crmApiUrl: 'https://dev-api.crm.example.com/v1',
      crmApiKey: 'dev-crm-api-key',
      inventoryApiUrl: 'https://dev-api.inventory.example.com/v1',
      inventoryApiKey: 'dev-inventory-api-key',
    );
  }

  /// Creates an ApiConfig instance for production environment
  factory ApiConfig.production() {
    return ApiConfig(
      crmApiUrl: 'https://api.crm.example.com/v1',
      crmApiKey: 'prod-crm-api-key',
      inventoryApiUrl: 'https://api.inventory.example.com/v1',
      inventoryApiKey: 'prod-inventory-api-key',
    );
  }

  /// Creates an ApiConfig instance for testing environment
  factory ApiConfig.test() {
    return ApiConfig(
      crmApiUrl: 'https://test-api.crm.example.com/v1',
      crmApiKey: 'test-crm-api-key',
      inventoryApiUrl: 'https://test-api.inventory.example.com/v1',
      inventoryApiKey: 'test-inventory-api-key',
    );
  }
}
