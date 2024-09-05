import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:json_path/json_path.dart';
import 'search_state.dart';
import 'package:mobius_app/models/data_model.dart';
import 'package:mobius_app/cubit/search/search_cubit.dart';

class SearchCubit extends Cubit<SearchState> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  SearchCubit() : super(SearchInitial());

  Future<void> fetchIndexes(String clientId) async {
    try {
      emit(SearchLoading());

      var repositoryApi =
          'https://content.xmegtech.com:3443/mobius/rest/repositories/D6DFEAB4-637C-4D99-AB9B-F70DE0FA9392/indexes';

      var headers = {
        "Accept": "application/vnd.asg-mobius-indexes.v2+json",
        "Client-Id": clientId,
      };

      var response = await http.get(Uri.parse(repositoryApi), headers: headers);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        final indexes = JsonPath(r'$..indexName').readValues(jsonData);
        List<String> indexList = indexes.toList().cast<String>();
        emit(
            SearchLoaded([])); // Emit empty list as we're just fetching indexes
      } else {
        emit(SearchError(
            'Failed to fetch indexes. Status code: ${response.statusCode}'));
      }
    } catch (e) {
      emit(SearchError('An error occurred: $e'));
    }
  }

  Future<void> searchData(String name, String operator, String value) async {
    try {
      emit(SearchLoading());
      String? authToken = await storage.read(key: 'authToken');

      if (authToken == null) {
        emit(SearchError('Authentication token not found'));
        return;
      }

      var url =
          'https://content.xmegtech.com:3443/mobius/rest/searches?returnresults=true';
      var headers = {
        "Accept": "application/vnd.asg-mobius-search-results.v3+json",
        "Client-Id": authToken,
        "Content-Type": "application/vnd.asg-mobius-search.v4+json"
      };
      var body = jsonEncode({
        "indexSearch": {
          "name": "Creating a new search",
          "distinct": false,
          "exitOnError": true,
          "conjunction": "AND",
          "constraints": [
            {
              "name": name,
              "operator": operator,
              "values": [
                {"value": value}
              ]
            }
          ],
          "returnedIndexes": [
            {"name": name}
          ],
          "repositories": [
            {"id": "660BE760-402F-4D7B-B6AE-829DB6EA8A28"}
          ],
          "description": "",
          "advancedDescription": null,
          "textFilter": null
        }
      });

      var response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print(jsonData);

        final fileName =
            JsonPath(r'$..metadata[1].keyValue').readValues(jsonData);
        final objectId = JsonPath(r'$..objectId').readValues(jsonData);
        final indexName = JsonPath(r'$..indexes..value').readValues(jsonData);

        List<MobiusSearchObject> searchResults = [];
        for (var i = 0; i < fileName.length; i++) {
          searchResults.add(MobiusSearchObject(
            name: fileName.elementAt(i).toString(),
            objectId: objectId.elementAt(i).toString(),
            indexNumber: indexName.elementAt(i).toString(),
          ));
        }

        emit(SearchLoaded(searchResults));
      } else {
        emit(SearchError(
            'The request failed with status code: ${response.statusCode}.'));
      }
    } catch (e) {
      emit(SearchError('An error occurred: $e'));
    }
  }
}
