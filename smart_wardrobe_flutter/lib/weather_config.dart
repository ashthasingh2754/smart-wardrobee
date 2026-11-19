class WeatherConfig {
  static const String apiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
  );
}