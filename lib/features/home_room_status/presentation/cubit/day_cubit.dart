import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../room_status_posts/presentation/cubit/post_cubit.dart';

part 'day_state.dart';

// Cubit to manage the state of the selected day
class DayCubit extends Cubit<DayState> {
  DayCubit() : super(DayState(DateTime.now().weekday - 1, false));

  void selectDay(int index, PostCubit postCubit) {
    emit(state.copyWith(selectedIndex: index));
    // postCubit.fetchPostsForDay(
    //     DateTime.now().add(Duration(days: index - DateTime.now().weekday + 1)));
  }

  void toggleDrawer(bool isOpen) => emit(state.copyWith(isDrawerOpen: isOpen));
}
