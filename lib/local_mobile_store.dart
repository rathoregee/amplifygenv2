import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper class for storing an ID and a generic Model item.
class StoreRow<T> {
  final String id;
  final T item;

  StoreRow({required this.id, required this.item});

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) itemToJson) {
    return {
      'id': id,
      'item': itemToJson(item),
    };
  }

  static StoreRow<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    return StoreRow(
      id: json['id'] as String,
      item: itemFromJson(json['item'] as Map<String, dynamic>),
    );
  }
}

/// A generic class for persistent local storage using SharedPreferences.
/// Stores data as StoreRow<T> wrapping the actual model T.
class LocalMobileStore<T extends Model> {
  final ModelType<T> modelType;
  late final T Function(Map<String, dynamic>) fromJsonFactory;
  SharedPreferences? _prefs;

  LocalMobileStore({required this.modelType}) {
    fromJsonFactory = modelType.fromJson;
  }

  String get _storageKey => 'LocalStore_${modelType.modelName()}';

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _save(List<StoreRow<T>> items) async {
    await _init();
    final stringList = items
        .map((row) => jsonEncode(row.toJson((item) => item.toJson())))
        .toList();
    await _prefs!.setStringList(_storageKey, stringList);
  }

  Future<void> create(StoreRow<T> row) async {
    final items = await readAll();
    items.add(row);
    await _save(items);
  }

  Future<List<StoreRow<T>>> readAll() async {
    await _init();
    final stringList = _prefs!.getStringList(_storageKey);
    if (stringList == null) {
      return [];
    }
    return stringList
        .map((item) => StoreRow.fromJson<T>(
            jsonDecode(item) as Map<String, dynamic>, fromJsonFactory))
        .toList();
  }

  Future<void> update(StoreRow<T> row) async {
    final items = await readAll();
    final index = items.indexWhere((element) => element.id == row.id);
    if (index != -1) {
      items[index] = row;
      await _save(items);
    }
  }

  Future<void> delete(String id) async {
    final items = await readAll();
    items.removeWhere((element) => element.id == id);
    await _save(items);
  }

  Future<void> clear() async {
    await _init();
    await _prefs!.remove(_storageKey);
  }

  Future<void> replaceAll(List<StoreRow<T>> items) async {
    await _save(items);
  }
}
