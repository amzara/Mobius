part of 'login_cubit.dart';

@immutable
sealed class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginFailure extends LoginState {}

class LoginSuccess extends LoginState {
  final String? authToken;

  LoginSuccess({required this.authToken});
}
 