import 'package:supabase_flutter/supabase_flutter.dart';

import '../models.dart';

// Все обращения к базе Supabase в одном месте
class SaladRepo {
  SupabaseClient get _db => Supabase.instance.client;

  Future<String> currentRole() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return 'cook';
    final row = await _db.from('profiles').select('role').eq('id', uid).maybeSingle();
    return (row?['role'] as String?) ?? 'cook';
  }

  Future<List<Salad>> fetchAll() async {
    final rows = await _db
        .from('salads')
        .select('id, name, final_weight, ingredients(name, grams, position)')
        .order('name');
    return rows.map((r) => Salad.fromRow(r)).toList();
  }

  // создать или обновить салат вместе с составом; возвращает id
  Future<String> save({
    String? id,
    required String name,
    double? finalWeight,
    required List<Ingredient> items,
  }) async {
    final row = {
      'name': name,
      'final_weight': (finalWeight ?? 0) > 0 ? finalWeight : null,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    String saladId;
    if (id != null) {
      await _db.from('salads').update(row).eq('id', id);
      await _db.from('ingredients').delete().eq('salad_id', id);
      saladId = id;
    } else {
      final created = await _db.from('salads').insert(row).select('id').single();
      saladId = created['id'] as String;
    }
    if (items.isNotEmpty) {
      await _db.from('ingredients').insert([
        for (var i = 0; i < items.length; i++)
          {
            'salad_id': saladId,
            'name': items[i].name,
            'grams': items[i].grams,
            'position': i,
          },
      ]);
    }
    return saladId;
  }

  // RLS разрешает удаление только администратору: проверяем, что строка реально удалена
  Future<void> delete(String id) async {
    final deleted = await _db.from('salads').delete().eq('id', id).select('id');
    if (deleted.isEmpty) {
      throw Exception('Удалять может только администратор');
    }
  }

  Future<void> insertNames(List<String> names) async {
    if (names.isEmpty) return;
    await _db.from('salads').insert([
      for (final n in names)
        {'name': n.isEmpty ? n : n[0].toUpperCase() + n.substring(1)},
    ]);
  }
}
