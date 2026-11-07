import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repo.dart';
import '../models.dart';
import '../seed.dart';

// Состояние приложения: вход, список салатов, поиск, экспорт и импорт
class AppState extends ChangeNotifier {
  final SaladRepo _repo = SaladRepo();

  bool booting = true;
  bool loggedIn = false;
  bool loading = false;
  String role = 'cook';
  List<Salad> salads = const [];
  String search = '';
  String? error;

  bool get isAdmin => role == 'admin';

  List<Salad> get visible {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return salads;
    return salads.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  Salad? byId(String id) {
    for (final s in salads) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> init() async {
    try {
      loggedIn = Supabase.instance.client.auth.currentSession != null;
      if (loggedIn) await _load();
    } finally {
      booting = false;
      notifyListeners();
    }
  }

  // возвращает текст ошибки или null, если вход выполнен
  Future<String?> signIn(String email, String password) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      loggedIn = true;
      await _load();
      return null;
    } on AuthException catch (e) {
      final m = e.message.toLowerCase();
      if (m.contains('invalid login')) return 'Неверный email или пароль';
      if (m.contains('not confirmed')) return 'Email не подтверждён в Supabase';
      return 'Ошибка входа: ${e.message}';
    } catch (_) {
      return 'Нет связи с сервером. Проверьте интернет.';
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    loggedIn = false;
    role = 'cook';
    salads = const [];
    notifyListeners();
  }

  Future<void> _load() async {
    loading = true;
    notifyListeners();
    try {
      role = await _repo.currentRole();
      var list = await _repo.fetchAll();
      if (list.isEmpty) {
        await _repo.insertNames(seedNames);
        list = await _repo.fetchAll();
      }
      salads = list;
      error = null;
    } catch (e) {
      error = 'Не удалось загрузить данные: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => _load();

  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  Future<void> saveSalad({
    String? id,
    required String name,
    double? finalWeight,
    required List<Ingredient> items,
  }) async {
    await _repo.save(id: id, name: name, finalWeight: finalWeight, items: items);
    await _load();
  }

  Future<void> deleteSalad(String id) async {
    await _repo.delete(id);
    await _load();
  }

  String exportJson() {
    final data = {
      'app': 'salad-book',
      'version': 2,
      'recipes': [
        for (final s in salads)
          {
            'name': s.name,
            'finalWeight': s.finalWeight,
            'items': [for (final i in s.items) {'name': i.name, 'grams': i.grams}],
          },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // возвращает количество импортированных салатов
  Future<int> importJson(String text) async {
    final decoded = jsonDecode(text);
    final list = decoded is List ? decoded : (decoded as Map)['recipes'] as List;
    final byName = {for (final s in salads) s.name.toLowerCase(): s};
    var count = 0;
    for (final item in list) {
      final m = item as Map;
      final name = (m['name'] as String).trim();
      if (name.isEmpty) continue;
      final rawItems = (m['items'] as List?) ?? const [];
      final items = <Ingredient>[];
      for (final raw in rawItems) {
        final ing = raw as Map;
        items.add(Ingredient(
          name: ing['name'] as String,
          grams: (ing['grams'] as num).toDouble(),
        ));
      }
      final existing = byName[name.toLowerCase()];
      await _repo.save(
        id: existing?.id,
        name: name,
        finalWeight: (m['finalWeight'] as num?)?.toDouble(),
        items: items,
      );
      count++;
    }
    await _load();
    return count;
  }
}
