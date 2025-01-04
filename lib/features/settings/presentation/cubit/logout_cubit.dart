import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutInitial());

  Timer? _timer;
  int _tapCount = 0;

  void _resetTapCount() {
    _tapCount = 0;
    emit(LogoutInitial());
  }

  void handleTap() {
    _tapCount++;
    emit(LogoutInProgress(_tapCount));

    if (_tapCount >= 3) {
      emit(LogoutComplete());
    } else {
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 2), _resetTapCount);
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
