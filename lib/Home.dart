import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/navigation/navigation_cubit.dart';
import 'cubit/navigation/navigation_state.dart';
import 'cubit/login/login_cubit.dart';
import 'content_widgets.dart';

class Home extends StatelessWidget {
  final String authToken;

  const Home({Key? key, required this.authToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                context.read<NavCubit>().showHome();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                context.read<NavCubit>().showSettings();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                context.read<NavCubit>().showAbout();
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                context.read<LoginCubit>().logout();
                // Optionally, navigate to login page or show a confirmation
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          BlocBuilder<NavCubit, NavState>(
            builder: (context, state) {
              switch (state) {
                case NavState.home:
                  return HomeContent(authToken: authToken);
                case NavState.settings:
                  return SettingsContent();
                case NavState.about:
                  return AboutContent();
              }
            },
          ),
          Positioned(
            left: 10,
            bottom: 16,
            child: Tooltip(
              message: authToken,
              child: Icon(
                Icons.security,
                color: Colors.green,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
