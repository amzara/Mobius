import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mobius_app/models/data_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:json_path/json_path.dart';
import 'dart:convert';
part 'data_state.dart';

class DataCubit extends Cubit<DataState> {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  DataCubit() : super(DataInitial());

Future<void> GetRepositoryParent(String username, String password) async {
  emit(DataLoading());

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
      emit(DataSuccess(data: mobiusObjects)); // Emit success state with parsed objects
    } else {
      emit(DataFailure());
    }
  } catch (error) {
    emit(DataFailure());
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

Future<void> OpenFolder(String ObjectId) async {
  emit(DataLoading());

  String? authToken = await storage.read(key: 'authToken');

  if (authToken == null) {
    emit(DataFailure());
    return;
  }

  try {
    final response = await http.get(
      Uri.parse("https://content.xmegtech.com:3443/mobius/rest/folders/$ObjectId/children"),
      headers: {
        "client-id": authToken,
        "Accept": "application/vnd.asg-mobius-navigation.v3+json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final mobiusObjects = await parseMobiusData(data);
      emit(DataSuccess(data: mobiusObjects)); // Emit success state with parsed objects
    } else {
      emit(DataFailure());
    }
  } catch (error) {
    emit(DataFailure());
  }
}


}
