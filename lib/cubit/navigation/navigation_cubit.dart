import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

class NavCubit extends Cubit<NavState> {
  NavCubit() : super(NavState.home);

  void showHome() => emit(NavState.home);
  void showSettings() => emit(NavState.settings);
  void showAbout() => emit(NavState.about);
}