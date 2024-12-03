import 'package:bloc/bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<StartSplash>(_onStartSplash);
  }

  Future<void> _onStartSplash(
      StartSplash event, Emitter<SplashState> emit) async {
    await Future.delayed(const Duration(seconds: 7));
    emit(SplashCompleted());
  }
}
