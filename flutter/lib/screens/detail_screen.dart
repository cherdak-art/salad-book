import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../format.dart';
import '../models.dart';
import '../routes.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/animated_grams.dart';
import 'edit_screen.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.id});

  final String id;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _portions = 10;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final salad = s.byId(widget.id);
    if (salad == null) {
      return const Scaffold(body: Center(child: Text('Салат не найден')));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Brand.bg,
        title: Text(
          salad.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Brand.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Brand.amber.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выход готового салата: ${fmtGrams(salad.outWeight)} г'
                  '${(salad.finalWeight ?? 0) > 0 ? ' (после готовки)' : ''}',
                  style: const TextStyle(color: Brand.muted),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text('Порций по 100 г:'),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: '$_portions',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (v) {
                          final n = int.tryParse(v) ?? 1;
                          setState(() => _portions = n < 1 ? 1 : n);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (salad.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Состав не заполнен. Нажмите «Изменить», чтобы добавить продукты.',
                  style: TextStyle(color: Brand.muted)),
            )
          else
            _IngredientsTable(salad: salad, portions: _portions),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(fadeRoute(EditScreen(salad: salad))),
                  child: const Text('Изменить'),
                ),
              ),
              if (s.isAdmin) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Brand.danger),
                    onPressed: () => _delete(context, salad),
                    child: const Text('Удалить'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, Salad salad) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Brand.surface2,
        title: Text('Удалить «${salad.name}»?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Brand.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      await context.read<AppState>().deleteSalad(salad.id);
      nav.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}

class _IngredientsTable extends StatelessWidget {
  const _IngredientsTable({required this.salad, required this.portions});

  final Salad salad;
  final int portions;

  @override
  Widget build(BuildContext context) {
    const header = TextStyle(color: Brand.muted, fontSize: 13);
    const amberBold = TextStyle(color: Brand.amber, fontWeight: FontWeight.w700);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Brand.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: Text('Продукт', style: header)),
              const SizedBox(width: 90, child: Text('на 100 г', style: header, textAlign: TextAlign.right)),
              SizedBox(
                width: 120,
                child: Text('для $portions порц., кг', style: header, textAlign: TextAlign.right),
              ),
            ],
          ),
          const Divider(color: Brand.surface2, height: 20),
          for (final i in salad.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text(i.name)),
                  SizedBox(
                    width: 90,
                    child: AnimatedGrams(
                      value: salad.per100(i.grams),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: AnimatedKg(
                      value: salad.per100(i.grams) * portions,
                      style: amberBold,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(color: Brand.surface2, height: 20),
          Row(
            children: [
              const Expanded(
                child: Text('Итого сырья', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                width: 90,
                child: AnimatedGrams(
                  value: salad.totalPer100,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                width: 120,
                child: AnimatedKg(value: salad.totalPer100 * portions, style: amberBold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
