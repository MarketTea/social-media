import 'dart:async';
import 'dart:ui';

class DebounceTime {
  final int milliseconds;
  Timer _timer;

  DebounceTime({this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
