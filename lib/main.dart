import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobius_app/Home.dart';
import 'package:mobius_app/cubit/search/search_cubit.dart';
import 'package:mobius_app/login-page.dart';
import 'package:mobius_app/cubit/login/login_cubit.dart';
import 'package:mobius_app/cubit/navigation/navigation_cubit.dart';
import 'package:mobius_app/cubit/data/data_cubit.dart';
import 'Viewer.dart';

import 'dart:io';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(create: (context) => LoginCubit()),
        BlocProvider<NavCubit>(create: (context) => NavCubit()),
        BlocProvider<DataCubit>(create: (context) => DataCubit()),
        BlocProvider<SearchCubit>(create: (context) => SearchCubit()),
      ],
      child: MaterialApp(
        title: 'Mobius App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const Login(),
          '/home': (context) => Home(authToken: context.read<LoginCubit>().getAuthToken() ?? ''), 

        },
        onGenerateRoute: (settings) {
       
          return MaterialPageRoute(
            builder: (context) => const Login(),
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}