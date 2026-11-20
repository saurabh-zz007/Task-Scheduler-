import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Global network connectivity service monitoring internet status.
class NetworkService extends GetxService {
  final Connectivity _connectivity;

  final RxBool isOffline = false.obs;
  final RxBool showReconnectedNotice = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  void onInit() {
    super.onInit();
    checkConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  bool _hasActiveConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    for (final result in results) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn ||
          result == ConnectivityResult.other) {
        return true;
      }
    }
    return false;
  }

  /// Manually trigger a connectivity check (e.g. on Retry button tap).
  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      developer.log('Error checking network connectivity: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final connected = _hasActiveConnection(results);
    final wasOffline = isOffline.value;

    if (!connected) {
      isOffline.value = true;
      developer.log('Network status changed: OFFLINE');
    } else {
      isOffline.value = false;
      developer.log('Network status changed: ONLINE');
      if (wasOffline) {
        showReconnectedNotice.value = true;
        Future.delayed(const Duration(seconds: 4), () {
          showReconnectedNotice.value = false;
        });
      }
    }
  }
}

