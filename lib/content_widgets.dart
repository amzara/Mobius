import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/data/data_cubit.dart';
import 'package:mobius_app/models/data_model.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
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
          return Scaffold(
            appBar: AppBar(
              title: Text('Mobius Content'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  context.read<DataCubit>().navigateBack();
                },
              ),
            ),
            body: _buildBody(context, state),
          );
        } else if (state is DataFailure) {
          return Center(child: Text('Failed to fetch data'));
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildBody(BuildContext context, DataSuccess state) {
    if (state.mode == 1) {
      final mobiusObjects = state.data as List<MobiusObject>;
      return GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 1,
        ),
        itemCount: mobiusObjects.length,
        itemBuilder: (context, index) {
          final mobiusObject = mobiusObjects[index];
          return GestureDetector(
            onTap: () {
              
              context.read<DataCubit>().OpenFolder(mobiusObject);
            },
            child: Column(
              children: [
                Icon(Icons.folder, size: 64, color: Colors.amber),
                SizedBox(height: 8.0),
                Text(
                  mobiusObject.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      );
    } else if (state.mode == 2) {
      final String pdfPath = state.data as String;
      return pdfPath.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: pdfPath,
              pageSnap: true,
              defaultPage: 0,
            );
    }

    return Center(child: Text('Unknown state'));
  }
}


class SettingsContent extends StatefulWidget {
  @override
  _SettingsContentState createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();
  String _selectedOption = 'Option 1';
  final List<String> _options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _firstController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedOption,
              decoration: InputDecoration(
                labelText: 'Select an option',
                border: OutlineInputBorder(),
              ),
              items: _options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedOption = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _thirdController,
              decoration: InputDecoration(
                labelText: 'Additional Info',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Implement search functionality here
                print('Search pressed');
                print('First input: ${_firstController.text}');
                print('Selected option: $_selectedOption');
                print('Third input: ${_thirdController.text}');
              },
              child: Text('Search'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
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