import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/data/data_cubit.dart';
import 'package:mobius_app/models/data_model.dart';

import 'content_widgets.dart';
class HomeContent extends StatelessWidget {
  final String authToken;

  const HomeContent({Key? key, required this.authToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataCubit, DataState>(
      builder: (context, state) {
        if (state is DataInitial) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<DataCubit>().GetRepositoryParent('username', 'password');
              },
              child: Text('Fetch Data'),
            ),
          );
        } else if (state is DataSuccess) {
          final mobiusObjects = state.data as List<MobiusObject>;

          return GridView.builder(
            padding: EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Number of folders per row
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 1, // Adjust this for desired folder aspect ratio
            ),
            itemCount: mobiusObjects.length,
            itemBuilder: (context, index) {
              final mobiusObject = mobiusObjects[index];
              return GestureDetector(
                onTap: () {
                  context.read<DataCubit>().OpenFolder(mobiusObject.objectId);
                },
                child: Column(
                  children: [
                    Icon(Icons.folder, size: 64, color: Colors.amber),
                    SizedBox(height: 8.0),
                    Text(
                      mobiusObject.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis, // Handle long names
                    ),
                  ],
                ),
              );
            },
          );
        } else if (state is DataFailure) {
          return Center(child: Text('Failed to fetch data'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}


class SettingsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text('Settings Page', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('Change Theme'),
          ),
        ],
      ),
    );
  }
}

class AboutContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info, size: 100, color: Colors.green),
          SizedBox(height: 20),
          Text('About Our App', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('Version 1.0.0', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text('Created with Flutter and ❤️', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}