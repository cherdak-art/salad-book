import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../routes.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/salad_tile.dart';
import '../widgets/stagger.dart';
import 'detail_screen.dart';
import 'edit_screen.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final items = s.visible;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(fadeRoute(const EditScreen())),
        backgroundColor: Brand.amber,
        foregroundColor: Brand.bg,
        icon: const Icon(Icons.add),
        label: const Text('Новый салат', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Brand.bg,
            title: const Text('Ладушки салаты', style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              PopupMenuButton<String>(
                color: Brand.surface2,
                onSelected: (v) => _menu(context, v),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'export', child: Text('Экспорт')),
                  PopupMenuItem(value: 'import', child: Text('Импорт')),
                  PopupMenuItem(value: 'logout', child: Text('Выйти')),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                onChanged: s.setSearch,
                decoration: const InputDecoration(
                  hintText: 'Поиск салата',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          if (s.loading && s.salads.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Brand.amber)),
            )
          else if (items.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('Ничего не найдено', style: TextStyle(color: Brand.muted))),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  mainAxisExtent: 104,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final salad = items[i];
                  return StaggerIn(
                    index: i,
                    child: SaladTile(
                      salad: salad,
                      onTap: () => Navigator.of(context).push(fadeRoute(DetailScreen(id: salad.id))),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _menu(BuildContext context, String value) async {
    final s = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    switch (value) {
      case 'export':
        await Share.share(s.exportJson(), subject: 'Резервная копия салатов');
      case 'import':
        const jsonType = XTypeGroup(label: 'JSON', extensions: ['json']);
        final file = await openFile(acceptedTypeGroups: const [jsonType]);
        if (file == null) return;
        try {
          final text = await file.readAsString();
          final n = await s.importJson(text);
          messenger.showSnackBar(SnackBar(content: Text('Импортировано салатов: $n')));
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text('Не удалось прочитать файл: $e')));
        }
      case 'logout':
        await s.signOut();
    }
  }
}
