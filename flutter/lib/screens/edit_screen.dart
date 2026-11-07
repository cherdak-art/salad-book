import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../format.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, this.salad});

  final Salad? salad;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _IngRow {
  _IngRow({String name = '', String grams = ''})
      : name = TextEditingController(text: name),
        grams = TextEditingController(text: grams);

  final TextEditingController name;
  final TextEditingController grams;

  void dispose() {
    name.dispose();
    grams.dispose();
  }
}

class _EditScreenState extends State<EditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _finalWeight;
  final List<_IngRow> _rows = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.salad;
    _name = TextEditingController(text: s?.name ?? '');
    _finalWeight = TextEditingController(text: s?.finalWeight?.toString() ?? '');
    final items = s?.items ?? const <Ingredient>[];
    if (items.isEmpty) {
      _rows.add(_IngRow());
    } else {
      for (final i in items) {
        _rows.add(_IngRow(name: i.name, grams: i.grams.toString()));
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _finalWeight.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  double _parse(String t) => double.tryParse(t.replaceAll(',', '.')) ?? 0;

  List<Ingredient> get _items => [
        for (final r in _rows)
          if (r.name.text.trim().isNotEmpty && _parse(r.grams.text) > 0)
            Ingredient(name: r.name.text.trim(), grams: _parse(r.grams.text)),
      ];

  double get _rawSum => _items.fold(0.0, (s, i) => s + i.grams);

  double get _outWeight {
    final f = _parse(_finalWeight.text);
    return f > 0 ? f : _rawSum;
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      _snack('Введите название салата');
      return;
    }
    if (_items.isEmpty) {
      _snack('Добавьте хотя бы один продукт с весом');
      return;
    }
    setState(() => _saving = true);
    final nav = Navigator.of(context);
    try {
      final f = _parse(_finalWeight.text);
      await context.read<AppState>().saveSalad(
            id: widget.salad?.id,
            name: name,
            finalWeight: f > 0 ? f : null,
            items: _items,
          );
      if (mounted) nav.pop();
    } catch (e) {
      if (mounted) _snack('Не удалось сохранить: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _items;
    final out = _outWeight;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Brand.bg,
        title: Text(widget.salad == null ? 'Новый салат' : 'Редактирование'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Название салата'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          const Text('Продукты: граммы на партию', style: TextStyle(color: Brand.muted)),
          const SizedBox(height: 8),
          for (var i = 0; i < _rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _rows[i].name,
                      decoration: const InputDecoration(hintText: 'Продукт'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _rows[i].grams,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'граммы'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Brand.muted),
                    onPressed: () {
                      setState(() {
                        _rows.removeAt(i).dispose();
                        if (_rows.isEmpty) _rows.add(_IngRow());
                      });
                    },
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: () => setState(() => _rows.add(_IngRow())),
            icon: const Icon(Icons.add),
            label: const Text('Добавить продукт'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _finalWeight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Вес готового салата, г (необязательно)',
              hintText: 'Пусто = сумма продуктов',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Text(
            'Сумма продуктов: ${fmtGrams(_rawSum)} г · выход: ${fmtGrams(out)} г',
            style: const TextStyle(color: Brand.muted),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Brand.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: preview.isEmpty
                ? const Text('Добавьте продукты с весом', style: TextStyle(color: Brand.muted))
                : Column(
                    children: [
                      for (final i in preview)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(i.name)),
                              Text(
                                '${fmtGrams(i.grams / out * 100)} г на 100 г',
                                style: const TextStyle(color: Brand.amber),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Brand.bg),
                  )
                : const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
