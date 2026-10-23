import 'dart:async';

import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';
import 'ui.dart';

class SplashScreen extends StatefulWidget {
  final SopivaStore store;

  const SplashScreen({
    super.key,
    required this.store,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    while (!widget.store.ready) {
      await Future.delayed(const Duration(milliseconds: 40));
    }

    await Future.delayed(const Duration(milliseconds: 450));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(store: widget.store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SopivaLogo(size: 102),
            SizedBox(height: 22),
            Text(
              'SOPIVA',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'PROCEDURE CHECKLIST MANAGER',
              style: TextStyle(
                color: sopivaTeal,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final SopivaStore store;

  const HomeScreen({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final favorites =
            store.procedures.where((e) => e.favorite).take(3).toList();

        final mostUsed = [...store.procedures]
          ..sort(
            (a, b) => store
                .usageCount(b.id)
                .compareTo(store.usageCount(a.id)),
          );

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProcedureEditorScreen(store: store),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('NEW PROCEDURE'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
              children: [
                Row(
                  children: [
                    const SopivaLogo(size: 54),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SOPIVA',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                          Text(
                            'WORKFLOW CONTROL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Run every process\nwith confidence.',
                  style: TextStyle(
                    fontSize: 31,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Build repeatable procedures, run checklists, and review execution history.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        value: '${store.procedures.length}',
                        label: 'PROCEDURES',
                        icon: Icons.rule_rounded,
                        color: sopivaTeal,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        value: '${store.totalRuns}',
                        label: 'TOTAL RUNS',
                        icon: Icons.play_circle_outline_rounded,
                        color: sopivaBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        value:
                            '${(store.averageCompletionRate * 100).round()}%',
                        label: 'AVG COMPLETE',
                        icon: Icons.task_alt_rounded,
                        color: sopivaGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        value: formatDuration(
                          store.averageDurationSeconds,
                        ),
                        label: 'AVG TIME',
                        icon: Icons.timer_outlined,
                        color: sopivaAmber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _QuickMenu(store: store),
                const SizedBox(height: 26),
                _SectionHeader(
                  title: 'Most used',
                  actionLabel: 'VIEW ALL',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProceduresScreen(store: store),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (mostUsed.isEmpty)
                  const _EmptyCard(
                    icon: Icons.rule_folder_outlined,
                    title: 'No procedures yet',
                    text:
                        'Create your first procedure and add checklist steps.',
                  )
                else
                  ...mostUsed.take(4).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ProcedureCard(
                            item: item,
                            store: store,
                          ),
                        ),
                      ),
                if (favorites.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const _SectionHeader(title: 'Favorites'),
                  const SizedBox(height: 10),
                  ...favorites.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ProcedureCard(
                        item: item,
                        store: store,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickMenu extends StatelessWidget {
  final SopivaStore store;

  const _QuickMenu({
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, dynamic>>[
      {
        'title': 'Procedures',
        'icon': Icons.rule_folder_outlined,
        'open': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProceduresScreen(store: store),
              ),
            ),
      },
      {
        'title': 'Run History',
        'icon': Icons.history_rounded,
        'open': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RunHistoryScreen(store: store),
              ),
            ),
      },
      {
        'title': 'Statistics',
        'icon': Icons.bar_chart_rounded,
        'open': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StatisticsScreen(store: store),
              ),
            ),
      },
      {
        'title': 'Favorites',
        'icon': Icons.star_outline_rounded,
        'open': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProceduresScreen(
                  store: store,
                  favoritesOnly: true,
                ),
              ),
            ),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.75,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: item['open'] as VoidCallback,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: sopivaTeal,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onTap,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(
              icon,
              color: sopivaTeal,
              size: 38,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProcedureCard extends StatelessWidget {
  final ProcedureItem item;
  final SopivaStore store;

  const ProcedureCard({
    super.key,
    required this.item,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(item.category);
    final used = store.usageCount(item.id);

    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProcedureDetailScreen(
              store: store,
              procedureId: item.id,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(.09),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  categoryIcon(item.category),
                  color: color,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (item.favorite)
                          const Icon(
                            Icons.star_rounded,
                            color: sopivaAmber,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${procedureCategoryLabel(item.category)} • ${item.steps.length} steps',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      used == 0
                          ? 'Not run yet'
                          : '$used completed ${used == 1 ? 'run' : 'runs'}',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProceduresScreen extends StatefulWidget {
  final SopivaStore store;
  final bool favoritesOnly;

  const ProceduresScreen({
    super.key,
    required this.store,
    this.favoritesOnly = false,
  });

  @override
  State<ProceduresScreen> createState() => _ProceduresScreenState();
}

class _ProceduresScreenState extends State<ProceduresScreen> {
  String query = '';
  ProcedureCategory? category;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final items = widget.store.procedures.where((item) {
          final q = query.trim().toLowerCase();

          final matchesQuery = q.isEmpty ||
              item.title.toLowerCase().contains(q) ||
              item.description.toLowerCase().contains(q) ||
              procedureCategoryLabel(item.category)
                  .toLowerCase()
                  .contains(q);

          final matchesCategory =
              category == null || item.category == category;

          final matchesFavorite =
              !widget.favoritesOnly || item.favorite;

          return matchesQuery &&
              matchesCategory &&
              matchesFavorite;
        }).toList()
          ..sort((a, b) {
            if (a.favorite != b.favorite) {
              return a.favorite ? -1 : 1;
            }
            return a.title
                .toLowerCase()
                .compareTo(b.title.toLowerCase());
          });

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.favoritesOnly
                  ? 'FAVORITE PROCEDURES'
                  : 'MY PROCEDURES',
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProcedureEditorScreen(
                  store: widget.store,
                ),
              ),
            ),
            child: const Icon(Icons.add_rounded),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            children: [
              TextField(
                onChanged: (value) {
                  setState(() => query = value);
                },
                decoration: const InputDecoration(
                  hintText: 'Search procedures',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: category == null,
                        onSelected: (_) {
                          setState(() => category = null);
                        },
                      ),
                    ),
                    for (final value
                        in ProcedureCategory.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            procedureCategoryLabel(value),
                          ),
                          selected: category == value,
                          onSelected: (_) {
                            setState(() => category = value);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${items.length} procedures',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (items.isEmpty)
                const _EmptyCard(
                  icon: Icons.search_off_rounded,
                  title: 'No procedures found',
                  text:
                      'Try another filter or create a new procedure.',
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ProcedureCard(
                      item: item,
                      store: widget.store,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class ProcedureEditorScreen extends StatefulWidget {
  final SopivaStore store;
  final ProcedureItem? procedure;

  const ProcedureEditorScreen({
    super.key,
    required this.store,
    this.procedure,
  });

  @override
  State<ProcedureEditorScreen> createState() =>
      _ProcedureEditorScreenState();
}

class _ProcedureEditorScreenState
    extends State<ProcedureEditorScreen> {
  final formKey = GlobalKey<FormState>();

  late String title;
  late String description;
  late ProcedureCategory category;
  late bool favorite;

  bool get editing => widget.procedure != null;

  @override
  void initState() {
    super.initState();

    final item = widget.procedure;

    title = item?.title ?? '';
    description = item?.description ?? '';
    category =
        item?.category ?? ProcedureCategory.operations;
    favorite = item?.favorite ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing ? 'EDIT PROCEDURE' : 'NEW PROCEDURE',
        ),
        actions: [
          if (editing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(
                Icons.delete_outline_rounded,
              ),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
          children: [
            TextFormField(
              initialValue: title,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Procedure name',
                prefixIcon: Icon(Icons.rule_rounded),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter a procedure name';
                }
                return null;
              },
              onChanged: (value) => title = value,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ProcedureCategory>(
              initialValue: category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                for (final value
                    in ProcedureCategory.values)
                  DropdownMenuItem(
                    value: value,
                    child: Text(
                      procedureCategoryLabel(value),
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: description,
              minLines: 4,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: 'Purpose or instructions',
                alignLabelWithHint: true,
                prefixIcon: Icon(
                  Icons.notes_rounded,
                ),
              ),
              onChanged: (value) => description = value,
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              child: SwitchListTile(
                value: favorite,
                onChanged: (value) {
                  setState(() => favorite = value);
                },
                secondary: const Icon(
                  Icons.star_outline_rounded,
                  color: sopivaAmber,
                ),
                title: const Text(
                  'Favorite procedure',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  editing
                      ? 'SAVE CHANGES'
                      : 'CREATE PROCEDURE',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final now = DateTime.now();

    final item = ProcedureItem(
      id: widget.procedure?.id ??
          now.microsecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      category: category,
      favorite: favorite,
      createdAt: widget.procedure?.createdAt ?? now,
      steps: widget.procedure?.steps ?? const [],
    );

    if (editing) {
      await widget.store.updateProcedure(item);
    } else {
      await widget.store.addProcedure(item);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final item = widget.procedure;
    if (item == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete procedure?'),
        content: Text(
          'Remove "${item.title}"? Existing completed run history will remain available.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.store.deleteProcedure(item.id);
      if (mounted) Navigator.pop(context);
    }
  }
}


class ProcedureDetailScreen extends StatelessWidget {
  final SopivaStore store;
  final String procedureId;

  const ProcedureDetailScreen({
    super.key,
    required this.store,
    required this.procedureId,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final item = store.procedureById(procedureId);

        if (item == null) {
          return const Scaffold(
            body: Center(
              child: Text('Procedure not found'),
            ),
          );
        }

        final color = categoryColor(item.category);
        final usage = store.usageCount(item.id);

        return Scaffold(
          appBar: AppBar(
            title: const Text('PROCEDURE DETAILS'),
            actions: [
              IconButton(
                onPressed: () =>
                    store.toggleFavorite(item.id),
                icon: Icon(
                  item.favorite
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color:
                      item.favorite ? sopivaAmber : null,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProcedureEditorScreen(
                      store: store,
                      procedure: item,
                    ),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
            children: [
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: color.withOpacity(.09),
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                            child: Icon(
                              categoryIcon(item.category),
                              color: color,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  procedureCategoryLabel(
                                    item.category,
                                  ),
                                  style: TextStyle(
                                    color: color,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (item.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text(
                          item.description,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            text:
                                '${item.steps.length} steps',
                            color: sopivaTeal,
                          ),
                          _InfoChip(
                            text:
                                '$usage ${usage == 1 ? 'run' : 'runs'}',
                            color: sopivaBlue,
                          ),
                          _InfoChip(
                            text: shortDate(item.createdAt),
                            color: sopivaAmber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: item.steps.isEmpty
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RunProcedureScreen(
                                store: store,
                                procedureId: item.id,
                              ),
                            ),
                          ),
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    item.steps.isEmpty
                        ? 'ADD STEPS TO START'
                        : 'START PROCEDURE',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Checklist steps',
                actionLabel: 'ADD STEP',
                onTap: () => _showStepEditor(
                  context,
                  store,
                  item.id,
                ),
              ),
              const SizedBox(height: 10),
              if (item.steps.isEmpty)
                const _EmptyCard(
                  icon: Icons.playlist_add_check_rounded,
                  title: 'No steps yet',
                  text:
                      'Add the steps that should be followed whenever this procedure is run.',
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: item.steps.length,
                  onReorder: (oldIndex, newIndex) {
                    store.reorderSteps(
                      procedureId: item.id,
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                    );
                  },
                  itemBuilder: (context, index) {
                    final step = item.steps[index];

                    return Padding(
                      key: ValueKey(step.id),
                      padding:
                          const EdgeInsets.only(bottom: 9),
                      child: Card(
                        elevation: 0,
                        child: ListTile(
                          leading: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  sopivaTeal.withOpacity(.09),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: sopivaTeal,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),
                          title: Text(
                            step.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: step.note.trim().isEmpty
                              ? null
                              : Text(
                                  step.note,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                          trailing:
                              PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await _showStepEditor(
                                  context,
                                  store,
                                  item.id,
                                  step: step,
                                );
                              } else if (value ==
                                  'delete') {
                                await store.deleteStep(
                                  procedureId: item.id,
                                  stepId: step.id,
                                );
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final Color color;

  const _InfoChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(.18),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

Future<void> _showStepEditor(
  BuildContext context,
  SopivaStore store,
  String procedureId, {
  ProcedureStep? step,
}) async {
  String title = step?.title ?? '';
  String note = step?.note ?? '';

  final result =
      await showDialog<Map<String, String>>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        step == null ? 'Add step' : 'Edit step',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: title,
            autofocus: true,
            textCapitalization:
                TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Step title',
            ),
            onChanged: (value) => title = value,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: note,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Instruction or note',
            ),
            onChanged: (value) => note = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(dialogContext),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: () {
            if (title.trim().isEmpty) return;

            Navigator.pop(
              dialogContext,
              {
                'title': title.trim(),
                'note': note.trim(),
              },
            );
          },
          child: Text(
            step == null ? 'ADD' : 'SAVE',
          ),
        ),
      ],
    ),
  );

  if (result == null) return;

  if (step == null) {
    await store.addStep(
      procedureId: procedureId,
      title: result['title'] ?? '',
      note: result['note'] ?? '',
    );
  } else {
    await store.updateStep(
      procedureId: procedureId,
      step: step.copyWith(
        title: result['title'] ?? step.title,
        note: result['note'] ?? step.note,
      ),
    );
  }
}

class RunProcedureScreen extends StatefulWidget {
  final SopivaStore store;
  final String procedureId;

  const RunProcedureScreen({
    super.key,
    required this.store,
    required this.procedureId,
  });

  @override
  State<RunProcedureScreen> createState() =>
      _RunProcedureScreenState();
}

class _RunProcedureScreenState
    extends State<RunProcedureScreen> {
  late final DateTime startedAt;
  final Map<String, RunStepStatus> statuses = {};
  Timer? timer;
  int elapsedSeconds = 0;
  bool paused = false;
  bool saving = false;

  ProcedureItem? get procedure =>
      widget.store.procedureById(
        widget.procedureId,
      );

  @override
  void initState() {
    super.initState();

    final item = procedure;
    startedAt = DateTime.now();

    if (item != null) {
      for (final step in item.steps) {
        statuses[step.id] = RunStepStatus.pending;
      }
    }

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted || paused || saving) return;

        setState(() {
          elapsedSeconds += 1;
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  int get completedCount => statuses.values
      .where(
        (e) => e == RunStepStatus.completed,
      )
      .length;

  int get skippedCount => statuses.values
      .where(
        (e) => e == RunStepStatus.skipped,
      )
      .length;

  int get pendingCount => statuses.values
      .where(
        (e) => e == RunStepStatus.pending,
      )
      .length;

  double get progress {
    if (statuses.isEmpty) return 0;
    return (completedCount + skippedCount) /
        statuses.length;
  }

  @override
  Widget build(BuildContext context) {
    final item = procedure;

    if (item == null) {
      return const Scaffold(
        body: Center(
          child: Text('Procedure not found'),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (
        didPop,
        result,
      ) async {
        if (didPop) return;
        await _exitRun();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: _exitRun,
            icon: const Icon(Icons.close_rounded),
          ),
          title: const Text('RUN PROCEDURE'),
          actions: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  paused = !paused;
                });
              },
              icon: Icon(
                paused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
              ),
              label: Text(
                paused ? 'RESUME' : 'PAUSE',
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              margin:
                  const EdgeInsets.fromLTRB(16, 4, 16, 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        formatDuration(elapsedSeconds),
                        style: const TextStyle(
                          color: sopivaTeal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  ProgressLine(
                    value: progress,
                    color: sopivaTeal,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completedCount completed • $skippedCount skipped • $pendingCount pending',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (paused) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color:
                            sopivaAmber.withOpacity(.10),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Run paused',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: sopivaAmber,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  110,
                ),
                itemCount: item.steps.length,
                itemBuilder: (context, index) {
                  final step = item.steps[index];
                  final status =
                      statuses[step.id] ??
                          RunStepStatus.pending;

                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 9),
                    child: _RunStepTile(
                      index: index,
                      step: step,
                      status: status,
                      disabled: paused,
                      onCompleted: () {
                        if (paused) return;
                        setState(() {
                          statuses[step.id] =
                              status ==
                                      RunStepStatus
                                          .completed
                                  ? RunStepStatus
                                      .pending
                                  : RunStepStatus
                                      .completed;
                        });
                      },
                      onSkipped: () {
                        if (paused) return;
                        setState(() {
                          statuses[step.id] =
                              status ==
                                      RunStepStatus
                                          .skipped
                                  ? RunStepStatus
                                      .pending
                                  : RunStepStatus
                                      .skipped;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum:
              const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed:
                pendingCount == 0 && !saving
                    ? _finishRun
                    : null,
            icon: const Icon(Icons.flag_rounded),
            label: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                pendingCount == 0
                    ? 'FINISH PROCEDURE'
                    : 'HANDLE ALL STEPS',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finishRun() async {
    final item = procedure;
    if (item == null || saving) return;

    String note = '';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Complete run'),
        content: TextFormField(
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Run notes (optional)',
            alignLabelWithHint: true,
          ),
          onChanged: (value) => note = value,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              note.trim(),
            ),
            child: const Text('SAVE RUN'),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      saving = true;
    });

    timer?.cancel();

    final run = ProcedureRun(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      procedureId: item.id,
      procedureTitle: item.title,
      category: item.category,
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      durationSeconds: elapsedSeconds,
      note: result,
      steps: item.steps.map((step) {
        return RunStepResult(
          stepId: step.id,
          title: step.title,
          status: statuses[step.id] ??
              RunStepStatus.pending,
        );
      }).toList(),
    );

    await widget.store.addRun(run);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RunResultScreen(run: run),
      ),
    );
  }

  Future<void> _exitRun() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit this run?'),
        content: const Text(
          'Current checklist progress will not be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('KEEP RUNNING'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('EXIT'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.pop(context);
    }
  }
}

class _RunStepTile extends StatelessWidget {
  final int index;
  final ProcedureStep step;
  final RunStepStatus status;
  final bool disabled;
  final VoidCallback onCompleted;
  final VoidCallback onSkipped;

  const _RunStepTile({
    required this.index,
    required this.step,
    required this.status,
    required this.disabled,
    required this.onCompleted,
    required this.onSkipped,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case RunStepStatus.pending:
        color = Theme.of(context)
            .colorScheme
            .onSurfaceVariant;
        icon = Icons.radio_button_unchecked_rounded;
        break;
      case RunStepStatus.completed:
        color = sopivaGreen;
        icon = Icons.check_circle_rounded;
        break;
      case RunStepStatus.skipped:
        color = sopivaAmber;
        icon = Icons.skip_next_rounded;
        break;
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          14,
          12,
          10,
          12,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 39,
              height: 39,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(.09),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      decoration: status ==
                              RunStepStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (step.note.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.note,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              disabled ? null : onSkipped,
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            size: 18,
                          ),
                          label: const Text('SKIP'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              disabled ? null : onCompleted,
                          icon: Icon(
                            status ==
                                    RunStepStatus.completed
                                ? Icons.undo_rounded
                                : Icons.check_rounded,
                            size: 18,
                          ),
                          label: Text(
                            status ==
                                    RunStepStatus.completed
                                ? 'UNDO'
                                : 'DONE',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              icon,
              color: color,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class RunResultScreen extends StatelessWidget {
  final ProcedureRun run;

  const RunResultScreen({
    super.key,
    required this.run,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('RUN COMPLETE'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DONE'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: sopivaGreen.withOpacity(.09),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  size: 64,
                  color: sopivaGreen,
                ),
                const SizedBox(height: 14),
                Text(
                  run.procedureTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${(run.completionRate * 100).round()}% completed',
                  style: const TextStyle(
                    color: sopivaGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  value: '${run.completedCount}',
                  label: 'COMPLETED',
                  icon: Icons.check_rounded,
                  color: sopivaGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  value: '${run.skippedCount}',
                  label: 'SKIPPED',
                  icon: Icons.skip_next_rounded,
                  color: sopivaAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MetricCard(
            value: formatDuration(run.durationSeconds),
            label: 'RUN TIME',
            icon: Icons.timer_outlined,
            color: sopivaBlue,
          ),
          if (run.note.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Run note',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(run.note),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class RunHistoryScreen extends StatefulWidget {
  final SopivaStore store;

  const RunHistoryScreen({
    super.key,
    required this.store,
  });

  @override
  State<RunHistoryScreen> createState() =>
      _RunHistoryScreenState();
}

class _RunHistoryScreenState
    extends State<RunHistoryScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final q = query.trim().toLowerCase();

        final runs = widget.store.runs.where((run) {
          return q.isEmpty ||
              run.procedureTitle
                  .toLowerCase()
                  .contains(q) ||
              procedureCategoryLabel(run.category)
                  .toLowerCase()
                  .contains(q) ||
              run.note.toLowerCase().contains(q);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('RUN HISTORY'),
          ),
          body: ListView(
            padding:
                const EdgeInsets.fromLTRB(16, 4, 16, 30),
            children: [
              TextField(
                onChanged: (value) {
                  setState(() => query = value);
                },
                decoration: const InputDecoration(
                  hintText: 'Search run history',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              if (runs.isEmpty)
                const _EmptyCard(
                  icon: Icons.history_rounded,
                  title: 'No run history',
                  text:
                      'Finished procedure runs will appear here.',
                )
              else
                ...runs.map(
                  (run) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 10),
                    child: _RunHistoryCard(
                      run: run,
                      store: widget.store,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RunHistoryCard extends StatelessWidget {
  final ProcedureRun run;
  final SopivaStore store;

  const _RunHistoryCard({
    required this.run,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(run.category);

    return Card(
      elevation: 0,
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(),
        collapsedShape:
            const RoundedRectangleBorder(),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(.09),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            categoryIcon(run.category),
            color: color,
          ),
        ),
        title: Text(
          run.procedureTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          '${shortDate(run.finishedAt)} • ${formatDuration(run.durationSeconds)}',
        ),
        trailing: Text(
          '${(run.completionRate * 100).round()}%',
          style: TextStyle(
            color: run.skippedCount == 0
                ? sopivaGreen
                : sopivaAmber,
            fontWeight: FontWeight.w900,
          ),
        ),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Completed',
                  value: '${run.completedCount}',
                  color: sopivaGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'Skipped',
                  value: '${run.skippedCount}',
                  color: sopivaAmber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'Total',
                  value: '${run.totalCount}',
                  color: sopivaBlue,
                ),
              ),
            ],
          ),
          if (run.note.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                run.note,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (final step in run.steps)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                step.status ==
                        RunStepStatus.completed
                    ? Icons.check_circle_rounded
                    : step.status ==
                            RunStepStatus.skipped
                        ? Icons.skip_next_rounded
                        : Icons
                            .radio_button_unchecked_rounded,
                color: step.status ==
                        RunStepStatus.completed
                    ? sopivaGreen
                    : step.status ==
                            RunStepStatus.skipped
                        ? sopivaAmber
                        : null,
              ),
              title: Text(step.title),
              trailing: Text(
                runStepStatusLabel(step.status),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: step.status ==
                          RunStepStatus.completed
                      ? sopivaGreen
                      : step.status ==
                              RunStepStatus.skipped
                          ? sopivaAmber
                          : null,
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _deleteRun(
                context,
                store,
                run,
              ),
              icon: const Icon(
                Icons.delete_outline_rounded,
              ),
              label: const Text('DELETE RUN'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _deleteRun(
  BuildContext context,
  SopivaStore store,
  ProcedureRun run,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete run?'),
      content: Text(
        'Remove this "${run.procedureTitle}" run from history?',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(dialogContext, false),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(dialogContext, true),
          child: const Text('DELETE'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await store.deleteRun(run.id);
  }
}

class StatisticsScreen extends StatelessWidget {
  final SopivaStore store;

  const StatisticsScreen({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final categoryCounts =
            <ProcedureCategory, int>{
          for (final category
              in ProcedureCategory.values)
            category: store.procedures
                .where(
                  (e) => e.category == category,
                )
                .length,
        };

        final mostUsed = [...store.procedures]
          ..sort(
            (a, b) => store
                .usageCount(b.id)
                .compareTo(store.usageCount(a.id)),
          );

        return Scaffold(
          appBar: AppBar(
            title: const Text('STATISTICS'),
          ),
          body: ListView(
            padding:
                const EdgeInsets.fromLTRB(16, 4, 16, 30),
            children: [
              const Text(
                'Process performance',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'A local overview calculated from your procedure runs.',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      value:
                          '${store.procedures.length}',
                      label: 'PROCEDURES',
                      icon: Icons.rule_rounded,
                      color: sopivaTeal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricCard(
                      value: '${store.totalRuns}',
                      label: 'TOTAL RUNS',
                      icon: Icons
                          .play_circle_outline_rounded,
                      color: sopivaBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      value:
                          '${(store.averageCompletionRate * 100).round()}%',
                      label: 'AVG COMPLETE',
                      icon: Icons.task_alt_rounded,
                      color: sopivaGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricCard(
                      value: formatDuration(
                        store.averageDurationSeconds,
                      ),
                      label: 'AVG RUN TIME',
                      icon: Icons.timer_outlined,
                      color: sopivaAmber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      value:
                          '${store.totalCompletedSteps}',
                      label: 'STEPS DONE',
                      icon: Icons.check_rounded,
                      color: sopivaGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricCard(
                      value:
                          '${store.totalSkippedSteps}',
                      label: 'STEPS SKIPPED',
                      icon: Icons.skip_next_rounded,
                      color: sopivaRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionHeader(
                title: 'Most used procedures',
              ),
              const SizedBox(height: 10),
              if (mostUsed.isEmpty ||
                  store.totalRuns == 0)
                const _EmptyCard(
                  icon: Icons.insights_outlined,
                  title: 'No usage data yet',
                  text:
                      'Run procedures to build useful performance statistics.',
                )
              else
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        for (final item
                            in mostUsed.where(
                          (e) =>
                              store.usageCount(e.id) > 0,
                        ).take(5))
                          ListTile(
                            leading: Icon(
                              categoryIcon(
                                item.category,
                              ),
                              color: categoryColor(
                                item.category,
                              ),
                            ),
                            title: Text(item.title),
                            trailing: Text(
                              '${store.usageCount(item.id)} runs',
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 22),
              const _SectionHeader(
                title: 'Procedures by category',
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      for (final entry
                          in categoryCounts.entries)
                        if (entry.value > 0)
                          ListTile(
                            leading: Icon(
                              categoryIcon(entry.key),
                              color:
                                  categoryColor(entry.key),
                            ),
                            title: Text(
                              procedureCategoryLabel(
                                entry.key,
                              ),
                            ),
                            trailing: Text(
                              '${entry.value}',
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),
                      if (categoryCounts.values
                          .every((e) => e == 0))
                        const Padding(
                          padding: EdgeInsets.all(18),
                          child: Text(
                            'Add procedures to see category statistics.',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final SopivaStore store;

  const SettingsScreen({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('SETTINGS'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                child: SwitchListTile(
                  value: store.darkMode,
                  onChanged: store.setDarkMode,
                  secondary: const Icon(
                    Icons.dark_mode_outlined,
                  ),
                  title: const Text(
                    'Dark mode',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.privacy_tip_outlined,
                      ),
                      title:
                          const Text('Privacy Policy'),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const LegalScreen(
                            title: 'Privacy Policy',
                            body: privacyText,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.description_outlined,
                      ),
                      title: const Text(
                        'Terms & Conditions',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const LegalScreen(
                            title:
                                'Terms & Conditions',
                            body: termsText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                child: ListTile(
                  textColor: sopivaRed,
                  iconColor: sopivaRed,
                  leading: const Icon(
                    Icons.delete_sweep_outlined,
                  ),
                  title:
                      const Text('Reset all data'),
                  subtitle: const Text(
                    'Delete procedures and run history stored by SOPIVA.',
                  ),
                  onTap: () =>
                      _resetAll(context, store),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _resetAll(
  BuildContext context,
  SopivaStore store,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Reset SOPIVA?'),
      content: const Text(
        'All procedures, checklist steps, run history, and statistics will be removed from local app storage.',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(dialogContext, false),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(dialogContext, true),
          child: const Text('RESET'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await store.resetAll();
  }
}

class LegalScreen extends StatelessWidget {
  final String title;
  final String body;

  const LegalScreen({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SelectableText(
            body,
            style: const TextStyle(height: 1.7),
          ),
        ],
      ),
    );
  }
}

const privacyText = '''SOPIVA PRIVACY POLICY

SOPIVA is an offline-first procedure checklist and workflow organization application.

The current core version does not require an account, login, Firebase, backend services, advertising, analytics, cloud synchronization, or a public profile.

Information you enter into SOPIVA, including procedure names, descriptions, categories, checklist steps, step notes, favorites, run results, skipped steps, completion data, run duration, and run notes, is stored locally on your device.

The current core version does not require access to your precise location, camera, microphone, contacts, phone, SMS, calendar, photos, media library, or payment information.

SOPIVA does not intentionally sell or rent your locally stored procedure information and does not use it for personalized advertising.

You can delete procedures, remove individual run records, or reset all locally stored app data from Settings. Clearing application storage or uninstalling the app may also remove local information, subject to operating-system backup and restore behavior.

SOPIVA is an organization and checklist tool. It does not replace workplace policies, professional judgment, legal requirements, regulatory requirements, safety procedures, financial controls, medical protocols, or emergency instructions.

If future versions add online accounts, cloud sync, analytics, crash reporting, advertising, purchases, collaboration, file uploads, external integrations, or additional permissions, this policy should be reviewed and updated before release.''';

const termsText = '''SOPIVA TERMS & CONDITIONS

SOPIVA is a personal procedure checklist and workflow organization tool.

You are responsible for the procedures, steps, notes, categories, and run information you enter into the app.

SOPIVA helps you organize repeatable processes and record checklist execution. It does not certify that a procedure is legally compliant, safe, complete, professionally approved, or suitable for a particular workplace.

The current core version stores procedure data and run history locally on your device. We do not guarantee recovery after uninstalling the app, clearing app data, device loss, storage failure, software defects, or operating-system changes.

Completion percentages, average run times, usage counts, skipped-step statistics, and related metrics are calculated from the information stored in the app.

You should independently verify any procedure used for safety-critical, regulated, medical, financial, legal, industrial, or emergency work.

SOPIVA is provided on an "as available" basis to the extent permitted by applicable law. Features may be changed, improved, added, or removed in future versions.''';
