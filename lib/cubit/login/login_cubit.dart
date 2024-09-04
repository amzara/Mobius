import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final storage = FlutterSecureStorage();
  String? authToken;

  LoginCubit() : super(LoginInitial()) {
    loadAuthToken(); // Load auth token when cubit is created
  }

  Future<void> login(String username, String password) async {
    emit(LoginLoading()); // Emit loading state while logging in

    String btoaFormat = "mobius:" + username + ":" + password;
    final Base64Encoder = base64.encoder;
    final encoded = Base64Encoder.convert(btoaFormat.codeUnits);
    print(encoded);
    String btoaKey = "Basic " + encoded;

    final dio = Dio();
    final response =
        await dio.get("https://content.xmegtech.com:3443/mobius/rest",
            options: Options(headers: {
              "Authorization-Repo": btoaKey,
            }));

    authToken = response.headers['client-id']?.first;
    print("Token : $authToken");
    await storage.write(key: 'authToken', value: authToken);

    emit(LoginSuccess(authToken: authToken!)); // Emit success state with token
  }

  void loadAuthToken() async {
    authToken = await storage.read(key: 'authToken');
    emit(LoginSuccess(authToken: authToken)); // Emit success state with loaded token
  }

  void logout() async {
    await storage.delete(key: 'authToken');
    authToken = null;
    emit(LoginInitial()); // Reset state after logout
  }

  String? getAuthToken() {
    return authToken!;
  }
}
