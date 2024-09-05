import 'package:mobius_app/models/data_model.dart';


abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<MobiusSearchObject> searchResults;

  SearchLoaded(this.searchResults);
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}