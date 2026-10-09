import 'package:connectivity_plus/connectivity_plus.dart';

/// Tells whether the phone is on Wi-Fi, so big uploads don't use mobile data
/// unless the person asks for them.
class ConnectivityService {
  ConnectivityService([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// True on Wi-Fi or a wired connection. False on mobile data, when offline,
  /// and when it can't be told, because the safe answer is not to upload.
  Future<bool> isOnWifi() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);
    } on Object {
      return false;
    }
  }
}
