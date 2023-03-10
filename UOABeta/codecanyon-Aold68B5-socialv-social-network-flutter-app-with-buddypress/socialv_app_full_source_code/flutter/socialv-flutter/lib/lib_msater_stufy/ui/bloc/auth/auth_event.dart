import 'package:meta/meta.dart';

@immutable
abstract class AuthEvent {


}

class LoginEvent extends AuthEvent {
  late final String login;
  late final String password;
  late final bool isSocialLogin;

  LoginEvent(this.login, this.password, this.isSocialLogin);
}

class RegisterEvent extends AuthEvent {
  final String login;
  final String email;
  final String password;

  RegisterEvent(this.login, this.email, this.password);
}

class CloseDialogEvent extends AuthEvent {}

class DemoAuthEvent extends AuthEvent {}
