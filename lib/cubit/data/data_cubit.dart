import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mobius_app/models/data_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:json_path/json_path.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
part 'data_state.dart';

class DataCubit extends Cubit<DataState> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  List<MobiusObject> navigationHistory = [];

  DataCubit() : super(DataInitial());

  Future<void> GetRepositoryParent(String username, String password) async {
    emit(DataLoading());
    navigationHistory.clear(); // Clear history when fetching root

    String? authToken = await storage.read(key: 'authToken');

    if (authToken == null) {
      emit(DataFailure());
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("https://content.xmegtech.com:3443/mobius/rest/repositories/660BE760-402F-4D7B-B6AE-829DB6EA8A28/children?&showOnlyConfiguredIndexes=true"),
        headers: {
          "client-id": authToken,
          "Accept": "application/vnd.asg-mobius-navigation.v3+json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mobiusObjects = await parseMobiusData(data);
        emit(DataSuccess(data: mobiusObjects, mode: 1));
      } else {
        emit(DataFailure());
      }
    } catch (error) {
      emit(DataFailure());
    }
  }

  Future<void> OpenFolder(MobiusObject mobiusObject) async {
    String _pdfPath = '';
    String? authToken = await storage.read(key: 'authToken');

    if (authToken == null) {
      emit(DataFailure());
      return;
    }

    try {
      if (mobiusObject.baseType == "FOLDER") {
        final response = await http.get(
          Uri.parse("https://content.xmegtech.com:3443/mobius/rest/folders/${mobiusObject.objectId}/children"),
          headers: {
            "client-id": authToken,
            "Accept": "application/vnd.asg-mobius-navigation.v3+json",
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final mobiusObjects = await parseMobiusData(data);
          navigationHistory.add(mobiusObject); // Add to history when opening a folder
          emit(DataSuccess(data: mobiusObjects, mode: 1));
        } else {
          emit(DataFailure());
        }
      } else {
        final response = await http.get(
          Uri.parse("https://content.xmegtech.com:3443/mobius/rest/contentstreams?id=${mobiusObject.objectId}&range=1&outputformat=PDF&rowshading=true&redacted=true&includepresentations=true&associatedviewer=false"),
          headers: {
            "client-id": authToken,
          },
        );
        if (response.statusCode == 200) {
          var bytes = response.bodyBytes;
          var dir = await getApplicationDocumentsDirectory();
          File file = File("${dir.path}/temp.pdf");
          await file.writeAsBytes(bytes);
          _pdfPath = file.path;
          emit(DataSuccess(data: _pdfPath, mode: 2));
        } else {
          emit(DataFailure());
        }
      }
    } catch (error) {
      emit(DataFailure());
    }
  }

  Future<void> navigateBack() async {
    if (navigationHistory.isNotEmpty) {
      navigationHistory.removeLast(); // Remove the current folder from history
      if (navigationHistory.isNotEmpty) {
        await OpenFolder(navigationHistory.last); // Open the previous folder
        navigationHistory.removeLast(); // Remove it again as OpenFolder will add it back
      } else {
        await GetRepositoryParent('username', 'password'); // If history is empty, go to root
      }
    } else {
      emit(DataFailure());
    }
  }






}


Future<List<MobiusObject>> parseMobiusData(dynamic response) async {
  final List<MobiusObject> mobiusObjectList = [];


  final objectName = JsonPath(r'$..name').readValues(response);  
  final objectId = JsonPath(r'$..objectId').readValues(response);  
  final objectParentId = JsonPath(r'$..parentId').readValues(response);  
  final objectBaseTypeId = JsonPath(r'$..baseTypeId').readValues(response);  


  final objectNameList = objectName.toList();
  final objectIdList = objectId.toList();
  final objectParentIdList = objectParentId.toList();
  final objectTypeList = objectBaseTypeId.toList();


  for (var i = 0; i < objectNameList.length; i++) {
    mobiusObjectList.add(MobiusObject.fromJson({
      'name': objectNameList[i].toString(),
      'objectId': objectIdList[i].toString(),
      'parentId': objectParentIdList[i].toString(),
      'baseTypeId': objectTypeList[i].toString(),
    }));
  }


  return mobiusObjectList;
}

