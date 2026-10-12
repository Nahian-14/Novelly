/// Base URL of our own backend server (the Node/Express + MongoDB server
/// in the `backend/` folder at the root of this repo). All calls that
/// need the MongoDB-backed profile go through [ApiConfig.baseUrl].
///
/// IMPORTANT — this almost always needs editing for your current setup:
/// - Android emulator -> use `http://10.0.2.2:5000` (NOT `localhost`;
///   the emulator has its own loopback address, and `10.0.2.2` is the
///   special alias Android emulators use to reach your computer's
///   localhost).
/// - iOS simulator -> `http://localhost:5000` works fine.
/// - A real phone (Android or iOS) on the same Wi-Fi as your computer ->
///   use your computer's LAN IP, e.g. `http://192.168.1.23:5000`.
/// - Once the backend is deployed (Render, Railway, etc.) -> use that
///   public HTTPS URL instead, e.g. `https://novelly-api.onrender.com`.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://localhost:5000';
}
