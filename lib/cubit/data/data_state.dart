part of 'data_cubit.dart';

sealed class DataState {}

class DataInitial extends DataState {}

class DataLoading extends DataState {}

class DataFailure extends DataState {}

class DataSuccess extends DataState {
  final dynamic data;
  final dynamic mode;

  DataSuccess({required this.data, this.mode});
}
