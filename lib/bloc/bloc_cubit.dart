import 'package:flutter_bloc/flutter_bloc.dart';

enum SplashState { loading, done }

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashState.loading);

  void finishLoading() {
    Future.delayed(const Duration(seconds: 5), () {
      emit(SplashState.done);
    });
  }
}