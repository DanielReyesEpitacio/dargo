abstract class InstallationManager {
  /// Indica si es la primera vez que se ejecuta la app
  bool get isFirstLaunch;

  /// Marca la app como ya iniciada
  Future<void> markLaunched();

}
