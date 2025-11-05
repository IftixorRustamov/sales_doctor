import 'dart:async';

import 'package:sales_doctor/utils/app_logger.dart';

abstract class BackgroundSyncExecutor {
  Future<void> handle10SecondSave();

  Future<void> handle20SecondSync();
}

class BackgroundServiceHandler {
  Timer? _timer10s;
  Timer? _timer20s;
  final BackgroundSyncExecutor executor;

  BackgroundServiceHandler({required this.executor});

  void start() {
    appLogger.i(
      'Background Handler: Starting 10s (Save) and 20s (Sync) timers.',
    );

    _timer10s = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await executor.handle10SecondSave();
    });

    _timer20s = Timer.periodic(const Duration(seconds: 20), (timer) async {
      await executor.handle20SecondSync();
    });
  }

  void stop() {
    appLogger.i('Background Handler: Cancelling timers.');
    _timer10s?.cancel();
    _timer20s?.cancel();
    _timer10s = null;
    _timer20s = null;
  }
}
