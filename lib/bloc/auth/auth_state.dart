// lib/bloc/auth/auth_state.dart
part of './auth_cubit.dart'; // This line links it to auth_cubit.dart

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AuthSuccess &&
              runtimeType == other.runtimeType &&
              user == other.user;

  @override
  int get hashCode => user.hashCode;
}

// AuthFailure is now an AuthState
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AuthFailure &&
              runtimeType == other.runtimeType &&
              message == other.message;

  @override
  int get hashCode => message.hashCode;
}