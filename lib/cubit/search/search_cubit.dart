import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:json_path/json_path.dart';
import 'search_state.dart';
import 'package:mobius_app/models/data_model.dart';
import 'package:mobius_app/cubit/search/search_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

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

    Future<String> fetchPdf(String objectId) async {
    String? authToken = await storage.read(key: 'authToken');
    if (authToken == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse(
          "https://content.xmegtech.com:3443/mobius/rest/contentstreams?id=$objectId&range=1&outputformat=PDF&rowshading=true&redacted=true&includepresentations=true&associatedviewer=false"),
      headers: {"client-id": authToken},
    );

    if (response.statusCode == 200) {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/temp.pdf");
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      throw Exception(
          'The request failed with status code: ${response.statusCode}.');
    }
  }

 Future<void> viewPdf(String objectId) async {
    emit(SearchPdfView('')); // Emit empty path to show loading
    try {
      final pdfPath = await fetchPdf(objectId);
      emit(SearchPdfView(pdfPath));
    } catch (e) {
      emit(SearchError('Error loading PDF: $e'));
    }
  }

  void resetSearch() {
    emit(SearchInitial());
  }
  

 
}
