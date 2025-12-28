import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:martfury/src/utils/functions.dart';
import 'package:new_version_plus/new_version_plus.dart';

class AppInternetConnectionWrapper extends StatefulWidget {
  final Widget child;

  const AppInternetConnectionWrapper({Key? key, required this.child})
    : super(key: key);

  @override
  State<AppInternetConnectionWrapper> createState() =>
      _AppInternetConnectionWrapperState();
}

class _AppInternetConnectionWrapperState
    extends State<AppInternetConnectionWrapper> {
  bool _isLoading = false;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateConnectionStatus(results);
    });

    Future.delayed(const Duration(seconds: 2), () => checkVersion());
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> results;
    try {
      results = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      return;
    }

    if (!mounted) return;
    return _updateConnectionStatus(results);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.none) && !_isLoading) {
      noInternet(context: context);
      _isLoading = true;
    } else if (!results.contains(ConnectivityResult.none)) {
      if (_isLoading) {
        hideLoader(context);
        _isLoading = false;
      }
    }
  }

  void hideLoader(context) {
    Navigator.pop(context);
  }

  Future<void> checkVersion() async {
    final newVersion = NewVersionPlus(
      iOSId: 'com.app.soujanya',
      androidId: 'com.app.soujanya',
      androidPlayStoreCountry: "es_ES",
      androidHtmlReleaseNotes: true,
    );

    final status = await newVersion.getVersionStatus();
    if (status != null && status.canUpdate) {
      if (Platform.isAndroid) {
        print("Google Play Store URL: ${status.appStoreLink}");
      } else if (Platform.isIOS) {
        print("App Store URL: ${status.appStoreLink}");
      }

      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: 'Update available',
        dialogText: 'A new version is available. Update it now.',
        launchModeVersion: LaunchModeVersion.external,
        allowDismissal: false,
        updateButtonText: 'Update now',
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
