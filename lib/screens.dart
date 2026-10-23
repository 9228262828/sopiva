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

    await Future.delayed(const Duration(milliseconds: 420));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkspaceShell(store: widget.store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF11151C) : sopivaPaper,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const SopivaMark(size: 92),
                const SizedBox(height: 28),
                const Text(
                  'SOPIVA',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PROCEDURE WORKSPACE',
                  style: TextStyle(
                    color: dark ? Colors.white60 : sopivaSlate,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  width: 72,
                  height: 6,
                  decoration: BoxDecoration(
                    color: sopivaCoral,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Spacer(),
                Text(
                  'Structure the process.\nRun it cleanly.',
                  style: TextStyle(
                    color: dark ? Colors.white70 : sopivaInk,
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WorkspaceShell extends StatefulWidget {
  final SopivaStore store;

  const WorkspaceShell({
    super.key,
    required this.store,
  });

  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      OverviewPage(
        store: widget.store,
        openProcedures: () => setState(() => index = 1),
        openHistory: () => setState(() => index = 2),
        openInsights: () => setState(() => index = 3),
      ),
      ProceduresPage(store: widget.store),
      RunHistoryPage(store: widget.store),
      InsightsPage(store: widget.store),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: index,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() => index = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree_outlined),
            selectedIcon: Icon(Icons.account_tree_rounded),
            label: 'Procedures',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
}

class OverviewPage extends StatelessWidget {
  final SopivaStore store;
  final VoidCallback openProcedures;
  final VoidCallback openHistory;
  final VoidCallback openInsights;

  const OverviewPage({
    super.key,
    required this.store,
    required this.openProcedures,
    required this.openHistory,
    required this.openInsights,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final recent = [...store.runs].take(3).toList();
        final top = [...store.procedures]
          ..sort(
            (a, b) => store
                .usageCount(b.id)
                .compareTo(store.usageCount(a.id)),
          );

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
          children: [
            _TopBar(store: store),
            const SizedBox(height: 22),
            _CommandPanel(
              store: store,
              openProcedures: openProcedures,
            ),
            const SizedBox(height: 22),
            const SectionTitle(
              kicker: 'Workspace pulse',
              title: 'At a glance',
            ),
            const SizedBox(height: 12),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.15,
              ),
              children: [
                MetricStrip(
                  value: '${store.procedures.length}',
                  label: 'Procedures',
                  icon: Icons.account_tree_outlined,
                  color: sopivaIndigo,
                ),
                MetricStrip(
                  value: '${store.totalRuns}',
                  label: 'Runs',
                  icon: Icons.play_circle_outline_rounded,
                  color: sopivaCoral,
                ),
                MetricStrip(
                  value:
                      '${(store.averageCompletionRate * 100).round()}%',
                  label: 'Completion',
                  icon: Icons.task_alt_rounded,
                  color: sopivaMint,
                ),
                MetricStrip(
                  value: formatDuration(
                    store.averageDurationSeconds,
                  ),
                  label: 'Avg. run',
                  icon: Icons.timer_outlined,
                  color: sopivaGold,
                ),
              ],
            ),
            const SizedBox(height: 28),
            SectionTitle(
              kicker: 'Quick launch',
              title: 'Run a procedure',
              action: 'ALL',
              onAction: openProcedures,
            ),
            const SizedBox(height: 12),
            if (top.isEmpty)
              _BlankSlate(
                icon: Icons.account_tree_outlined,
                title: 'No procedures yet',
                message:
                    'Create your first workflow and define the steps once.',
                action: 'CREATE PROCEDURE',
                onAction: () => _openProcedureEditor(context, store),
              )
            else
              SizedBox(
                height: 154,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: top.take(5).length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = top[index];
                    return _LaunchTile(
                      item: item,
                      store: store,
                    );
                  },
                ),
              ),
            const SizedBox(height: 28),
            SectionTitle(
              kicker: 'Execution log',
              title: 'Recent activity',
              action: 'HISTORY',
              onAction: openHistory,
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              const _BlankSlate(
                icon: Icons.history_toggle_off_rounded,
                title: 'No completed runs',
                message:
                    'Run a procedure and its result will appear here.',
              )
            else
              ...recent.map(
                (run) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RecentRunRow(run: run),
                ),
              ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: openInsights,
              icon: const Icon(Icons.insights_rounded),
              label: const Text('VIEW PERFORMANCE INSIGHTS'),
            ),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final SopivaStore store;

  const _TopBar({
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SopivaMark(size: 48, compact: true),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SOPIVA',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.8,
                ),
              ),
              Text(
                'PROCESS WORKSPACE',
                style: TextStyle(
                  fontSize: 9,
                  color: sopivaSlate,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SettingsScreen(store: store),
            ),
          ),
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }
}

class _CommandPanel extends StatelessWidget {
  final SopivaStore store;
  final VoidCallback openProcedures;

  const _CommandPanel({
    required this.store,
    required this.openProcedures,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: sopivaInk,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Pill(
            text: 'PROCESS CONTROL',
            color: sopivaCoral,
            icon: Icons.bolt_rounded,
          ),
          const SizedBox(height: 18),
          const Text(
            'One process.\nOne clean run.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Build reusable operating procedures and execute them step by step.',
            style: TextStyle(
              color: Colors.white60,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: sopivaCoral,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () =>
                      _openProcedureEditor(context, store),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('NEW PROCEDURE'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white12,
                  foregroundColor: Colors.white,
                ),
                onPressed: openProcedures,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LaunchTile extends StatelessWidget {
  final ProcedureItem item;
  final SopivaStore store;

  const _LaunchTile({
    required this.item,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(item.category);

    return SizedBox(
      width: 178,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openProcedureDetail(
          context,
          store,
          item.id,
        ),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withOpacity(.16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(categoryIcon(item.category), color: color),
              const Spacer(),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${item.steps.length} steps • ${store.usageCount(item.id)} runs',
                style: const TextStyle(
                  fontSize: 10,
                  color: sopivaSlate,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentRunRow extends StatelessWidget {
  final ProcedureRun run;

  const _RecentRunRow({
    required this.run,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(run.category);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  run.procedureTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${shortDate(run.finishedAt)} • ${formatDuration(run.durationSeconds)}',
                  style: const TextStyle(
                    color: sopivaSlate,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Pill(
            text: '${(run.completionRate * 100).round()}%',
            color: run.skippedCount == 0
                ? sopivaMint
                : sopivaGold,
          ),
        ],
      ),
    );
  }
}

class _BlankSlate extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  const _BlankSlate({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(.12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: sopivaSlate),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: sopivaSlate,
              height: 1.4,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: onAction,
              child: Text(action!),
            ),
          ],
        ],
      ),
    );
  }
}


class ProceduresPage extends StatefulWidget {
  final SopivaStore store;

  const ProceduresPage({
    super.key,
    required this.store,
  });

  @override
  State<ProceduresPage> createState() => _ProceduresPageState();
}

class _ProceduresPageState extends State<ProceduresPage> {
  String query = '';
  ProcedureCategory? category;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final items = widget.store.procedures.where((item) {
          final q = query.trim().toLowerCase();
          final queryOk = q.isEmpty ||
              item.title.toLowerCase().contains(q) ||
              item.description.toLowerCase().contains(q) ||
              procedureCategoryLabel(item.category)
                  .toLowerCase()
                  .contains(q);

          final categoryOk =
              category == null || item.category == category;

          return queryOk && categoryOk;
        }).toList()
          ..sort((a, b) {
            if (a.favorite != b.favorite) {
              return a.favorite ? -1 : 1;
            }

            return a.title
                .toLowerCase()
                .compareTo(b.title.toLowerCase());
          });

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: SectionTitle(
                      kicker: 'Process library',
                      title: 'Procedures',
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () =>
                        _openProcedureEditor(context, widget.store),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('NEW'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  hintText: 'Find a procedure',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 43,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterPill(
                    label: 'All',
                    selected: category == null,
                    onTap: () => setState(() => category = null),
                  ),
                  for (final value in ProcedureCategory.values)
                    _FilterPill(
                      label: procedureCategoryLabel(value),
                      selected: category == value,
                      onTap: () => setState(() => category = value),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(18),
                      child: _BlankSlate(
                        icon: Icons.search_off_rounded,
                        title: 'Nothing matches',
                        message:
                            'Try another search or create a new procedure.',
                        action: 'CREATE PROCEDURE',
                        onAction: () => _openProcedureEditor(
                          context,
                          widget.store,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _ProcedureRow(
                          item: items[index],
                          store: widget.store,
                          index: index,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? sopivaInk
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : sopivaSlate,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProcedureRow extends StatelessWidget {
  final ProcedureItem item;
  final SopivaStore store;
  final int index;

  const _ProcedureRow({
    required this.item,
    required this.store,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(item.category);
    final usage = store.usageCount(item.id);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _openProcedureDetail(
        context,
        store,
        item.id,
      ),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${index + 1}'.padLeft(2, '0'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
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
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (item.favorite)
                        const Icon(
                          Icons.bookmark_rounded,
                          size: 18,
                          color: sopivaCoral,
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description.trim().isEmpty
                        ? procedureCategoryLabel(item.category)
                        : item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: sopivaSlate,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      Pill(
                        text: procedureCategoryLabel(item.category),
                        color: color,
                      ),
                      Pill(
                        text: '${item.steps.length} STEPS',
                        color: sopivaIndigo,
                      ),
                      Pill(
                        text: '$usage RUNS',
                        color: sopivaSlate,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: sopivaSlate,
            ),
          ],
        ),
      ),
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

class _ProcedureEditorScreenState extends State<ProcedureEditorScreen> {
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
    category = item?.category ?? ProcedureCategory.operations;
    favorite = item?.favorite ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit procedure' : 'New procedure'),
        actions: [
          if (editing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          children: [
            const SectionTitle(
              kicker: 'Procedure profile',
              title: 'Define the workflow',
            ),
            const SizedBox(height: 18),
            TextFormField(
              initialValue: title,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Procedure name',
                hintText: 'e.g. Client onboarding',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a procedure name';
                }
                return null;
              },
              onChanged: (value) => title = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: description,
              minLines: 4,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: 'Purpose or instructions',
                alignLabelWithHint: true,
              ),
              onChanged: (value) => description = value,
            ),
            const SizedBox(height: 22),
            const Text(
              'CATEGORY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: sopivaSlate,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in ProcedureCategory.values)
                  ChoiceChip(
                    avatar: Icon(
                      categoryIcon(value),
                      size: 17,
                      color: category == value
                          ? Colors.white
                          : categoryColor(value),
                    ),
                    label: Text(procedureCategoryLabel(value)),
                    selected: category == value,
                    selectedColor: categoryColor(value),
                    labelStyle: TextStyle(
                      color: category == value
                          ? Colors.white
                          : null,
                      fontWeight: FontWeight.w800,
                    ),
                    onSelected: (_) =>
                        setState(() => category = value),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: favorite,
                onChanged: (value) =>
                    setState(() => favorite = value),
                title: const Text(
                  'Pin to favorites',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: const Text(
                  'Keep this procedure easy to find.',
                ),
                secondary: const Icon(
                  Icons.bookmark_outline_rounded,
                  color: sopivaCoral,
                ),
              ),
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(
                editing ? 'SAVE PROCEDURE' : 'CREATE PROCEDURE',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

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
          'Remove "${item.title}"? Existing run history will stay available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
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
            body: Center(child: Text('Procedure not found')),
          );
        }

        final color = categoryColor(item.category);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Procedure'),
            actions: [
              IconButton(
                onPressed: () => store.toggleFavorite(item.id),
                icon: Icon(
                  item.favorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: item.favorite ? sopivaCoral : null,
                ),
              ),
              IconButton(
                onPressed: () => _openProcedureEditor(
                  context,
                  store,
                  procedure: item,
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: sopivaInk,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      categoryIcon(item.category),
                      size: 34,
                      color: color,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (item.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: Colors.white60,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Pill(
                          text: procedureCategoryLabel(item.category),
                          color: color,
                        ),
                        Pill(
                          text: '${item.steps.length} STEPS',
                          color: sopivaIndigo,
                        ),
                        Pill(
                          text: '${store.usageCount(item.id)} RUNS',
                          color: sopivaGold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: sopivaCoral,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: item.steps.isEmpty
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RunProcedureScreen(
                                      store: store,
                                      procedureId: item.id,
                                    ),
                                  ),
                                ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          item.steps.isEmpty
                              ? 'ADD STEPS FIRST'
                              : 'START RUN',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SectionTitle(
                kicker: 'Procedure map',
                title: 'Steps',
                action: 'ADD STEP',
                onAction: () => _showStepEditor(
                  context,
                  store,
                  item.id,
                ),
              ),
              const SizedBox(height: 14),
              if (item.steps.isEmpty)
                _BlankSlate(
                  icon: Icons.route_outlined,
                  title: 'Build the route',
                  message:
                      'Add each instruction once. SOPIVA will guide the next run step by step.',
                  action: 'ADD FIRST STEP',
                  onAction: () => _showStepEditor(
                    context,
                    store,
                    item.id,
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                    final isLast = index == item.steps.length - 1;

                    return _StepTimelineRow(
                      key: ValueKey(step.id),
                      index: index,
                      step: step,
                      color: color,
                      isLast: isLast,
                      onEdit: () => _showStepEditor(
                        context,
                        store,
                        item.id,
                        step: step,
                      ),
                      onDelete: () => store.deleteStep(
                        procedureId: item.id,
                        stepId: step.id,
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

class _StepTimelineRow extends StatelessWidget {
  final int index;
  final ProcedureStep step;
  final Color color;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StepTimelineRow({
    super.key,
    required this.index,
    required this.step,
    required this.color,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              children: [
                NumberBadge(
                  number: index + 1,
                  color: color,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: color.withOpacity(.18),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (step.note.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            step.note,
                            style: const TextStyle(
                              color: sopivaSlate,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit step'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete step'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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

  final result = await showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final bottom = MediaQuery.of(sheetContext).viewInsets.bottom;

      return Padding(
        padding: EdgeInsets.fromLTRB(18, 4, 18, bottom + 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step == null ? 'Add a step' : 'Edit step',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: title,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Step title',
              ),
              onChanged: (value) => title = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: note,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Instruction or note',
                alignLabelWithHint: true,
              ),
              onChanged: (value) => note = value,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (title.trim().isEmpty) return;

                  Navigator.pop(
                    sheetContext,
                    {
                      'title': title.trim(),
                      'note': note.trim(),
                    },
                  );
                },
                child: Text(step == null ? 'ADD STEP' : 'SAVE STEP'),
              ),
            ),
          ],
        ),
      );
    },
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
  State<RunProcedureScreen> createState() => _RunProcedureScreenState();
}

class _RunProcedureScreenState extends State<RunProcedureScreen> {
  late final DateTime startedAt;
  final Map<String, RunStepStatus> statuses = {};

  Timer? timer;
  int elapsedSeconds = 0;
  int currentIndex = 0;
  bool paused = false;
  bool saving = false;

  ProcedureItem? get procedure =>
      widget.store.procedureById(widget.procedureId);

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
      .where((e) => e == RunStepStatus.completed)
      .length;

  int get skippedCount =>
      statuses.values.where((e) => e == RunStepStatus.skipped).length;

  int get handledCount => completedCount + skippedCount;

  double get progress {
    if (statuses.isEmpty) return 0;
    return handledCount / statuses.length;
  }

  @override
  Widget build(BuildContext context) {
    final item = procedure;

    if (item == null || item.steps.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Procedure unavailable')),
      );
    }

    currentIndex = currentIndex.clamp(0, item.steps.length - 1).toInt();
    final step = item.steps[currentIndex];
    final status = statuses[step.id] ?? RunStepStatus.pending;
    final color = categoryColor(item.category);
    final allHandled = handledCount == item.steps.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _exitRun();
      },
      child: Scaffold(
        backgroundColor: sopivaInk,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _exitRun,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${currentIndex + 1} / ${item.steps.length}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatDuration(elapsedSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: ProgressTrack(
                  value: progress,
                  color: color,
                  height: 5,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                  decoration: const BoxDecoration(
                    color: sopivaPaper,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(34),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          NumberBadge(
                            number: currentIndex + 1,
                            color: color,
                            done: status == RunStepStatus.completed,
                          ),
                          const Spacer(),
                          Pill(
                            text: runStepStatusLabel(status).toUpperCase(),
                            color: status == RunStepStatus.completed
                                ? sopivaMint
                                : status == RunStepStatus.skipped
                                    ? sopivaGold
                                    : sopivaSlate,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        step.title,
                        style: const TextStyle(
                          color: sopivaInk,
                          fontSize: 32,
                          height: 1.08,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (step.note.trim().isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          step.note,
                          style: const TextStyle(
                            color: sopivaSlate,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.track_changes_rounded,
                              color: sopivaIndigo,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$completedCount completed • $skippedCount skipped',
                                style: const TextStyle(
                                  color: sopivaInk,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => paused = !paused),
                              icon: Icon(
                                paused
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                                color: sopivaInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (paused) ...[
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'RUN PAUSED',
                            style: TextStyle(
                              color: sopivaCoral,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: paused
                                  ? null
                                  : () => _setCurrentStatus(
                                        RunStepStatus.skipped,
                                      ),
                              icon: const Icon(Icons.skip_next_rounded),
                              label: const Text('SKIP'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              onPressed: paused
                                  ? null
                                  : () => _setCurrentStatus(
                                        RunStepStatus.completed,
                                      ),
                              icon: const Icon(Icons.check_rounded),
                              label: Text(
                                currentIndex == item.steps.length - 1
                                    ? 'MARK DONE'
                                    : 'DONE & NEXT',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            onPressed: currentIndex > 0
                                ? () => setState(() => currentIndex -= 1)
                                : null,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const Spacer(),
                          if (allHandled)
                            FilledButton.tonalIcon(
                              onPressed: saving ? null : _finishRun,
                              icon: const Icon(Icons.flag_rounded),
                              label: const Text('FINISH RUN'),
                            )
                          else
                            TextButton(
                              onPressed:
                                  currentIndex < item.steps.length - 1
                                      ? () => setState(
                                            () => currentIndex += 1,
                                          )
                                      : null,
                              child: const Text('NEXT STEP'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setCurrentStatus(RunStepStatus value) {
    final item = procedure;
    if (item == null || item.steps.isEmpty) return;

    final step = item.steps[currentIndex];

    setState(() {
      statuses[step.id] = value;

      if (currentIndex < item.steps.length - 1) {
        currentIndex += 1;
      }
    });
  }

  Future<void> _finishRun() async {
    final item = procedure;
    if (item == null || saving) return;

    String note = '';

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final bottom = MediaQuery.of(sheetContext).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(18, 6, 18, bottom + 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Close the run',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add an optional note before saving this execution.',
                style: TextStyle(color: sopivaSlate),
              ),
              const SizedBox(height: 16),
              TextFormField(
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Run note',
                  alignLabelWithHint: true,
                ),
                onChanged: (value) => note = value,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.pop(sheetContext, note.trim()),
                  child: const Text('SAVE RUN'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result == null || !mounted) return;

    setState(() => saving = true);
    timer?.cancel();

    final run = ProcedureRun(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      procedureId: item.id,
      procedureTitle: item.title,
      category: item.category,
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      durationSeconds: elapsedSeconds,
      note: result,
      steps: item.steps
          .map(
            (step) => RunStepResult(
              stepId: step.id,
              title: step.title,
              status:
                  statuses[step.id] ?? RunStepStatus.pending,
            ),
          )
          .toList(),
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
        title: const Text('Exit current run?'),
        content: const Text(
          'Progress from this unfinished run will not be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('KEEP RUNNING'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
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


class RunResultScreen extends StatelessWidget {
  final ProcedureRun run;

  const RunResultScreen({
    super.key,
    required this.run,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(run.category);

    return Scaffold(
      backgroundColor: sopivaInk,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Run complete',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'DONE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: sopivaPaper,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: color.withOpacity(.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.done_all_rounded,
                        size: 48,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      run.procedureTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: sopivaInk,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(run.completionRate * 100).round()}% completion',
                      style: const TextStyle(
                        color: sopivaSlate,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ProgressTrack(
                      value: run.completionRate,
                      color: color,
                      height: 9,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _ResultMetric(
                            value: '${run.completedCount}',
                            label: 'Done',
                            color: sopivaMint,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ResultMetric(
                            value: '${run.skippedCount}',
                            label: 'Skipped',
                            color: sopivaGold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ResultMetric(
                            value: formatDuration(run.durationSeconds),
                            label: 'Time',
                            color: sopivaIndigo,
                          ),
                        ),
                      ],
                    ),
                    if (run.note.trim().isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          run.note,
                          style: const TextStyle(
                            color: sopivaInk,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    const Text(
                      'Execution saved to local history',
                      style: TextStyle(
                        color: sopivaSlate,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _ResultMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: sopivaSlate,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }
}

class RunHistoryPage extends StatefulWidget {
  final SopivaStore store;

  const RunHistoryPage({
    super.key,
    required this.store,
  });

  @override
  State<RunHistoryPage> createState() => _RunHistoryPageState();
}

class _RunHistoryPageState extends State<RunHistoryPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final q = query.trim().toLowerCase();

        final runs = widget.store.runs.where((run) {
          return q.isEmpty ||
              run.procedureTitle.toLowerCase().contains(q) ||
              run.note.toLowerCase().contains(q) ||
              procedureCategoryLabel(run.category)
                  .toLowerCase()
                  .contains(q);
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: const SectionTitle(
                kicker: 'Execution archive',
                title: 'Run history',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  hintText: 'Search saved runs',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: runs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: _BlankSlate(
                        icon: Icons.history_toggle_off_rounded,
                        title: 'No run history',
                        message:
                            'Finished procedure runs will build a timeline here.',
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(18, 8, 18, 110),
                      itemCount: runs.length,
                      itemBuilder: (context, index) {
                        return _HistoryTimelineItem(
                          run: runs[index],
                          store: widget.store,
                          isLast: index == runs.length - 1,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryTimelineItem extends StatelessWidget {
  final ProcedureRun run;
  final SopivaStore store;
  final bool isLast;

  const _HistoryTimelineItem({
    required this.run,
    required this.store,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(run.category);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 3,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: color.withOpacity(.18),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(),
                collapsedShape: const RoundedRectangleBorder(),
                title: Text(
                  run.procedureTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  '${shortDate(run.finishedAt)} • ${formatDuration(run.durationSeconds)}',
                  style: const TextStyle(
                    color: sopivaSlate,
                    fontSize: 11,
                  ),
                ),
                trailing: Pill(
                  text: '${(run.completionRate * 100).round()}%',
                  color: run.skippedCount == 0
                      ? sopivaMint
                      : sopivaGold,
                ),
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniHistoryStat(
                          label: 'Done',
                          value: '${run.completedCount}',
                          color: sopivaMint,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniHistoryStat(
                          label: 'Skipped',
                          value: '${run.skippedCount}',
                          color: sopivaGold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniHistoryStat(
                          label: 'Steps',
                          value: '${run.totalCount}',
                          color: sopivaIndigo,
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
                        style: const TextStyle(
                          color: sopivaSlate,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  for (final step in run.steps)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        step.status == RunStepStatus.completed
                            ? Icons.check_circle_rounded
                            : step.status == RunStepStatus.skipped
                                ? Icons.skip_next_rounded
                                : Icons.circle_outlined,
                        color: step.status == RunStepStatus.completed
                            ? sopivaMint
                            : step.status == RunStepStatus.skipped
                                ? sopivaGold
                                : sopivaSlate,
                      ),
                      title: Text(step.title),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _deleteRun(
                        context,
                        store,
                        run,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('DELETE RUN'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniHistoryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniHistoryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
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
            label.toUpperCase(),
            style: const TextStyle(
              color: sopivaSlate,
              fontSize: 9,
              fontWeight: FontWeight.w900,
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
        'Remove this "${run.procedureTitle}" execution from local history?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('DELETE'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await store.deleteRun(run.id);
  }
}

class InsightsPage extends StatelessWidget {
  final SopivaStore store;

  const InsightsPage({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final mostUsed = [...store.procedures]
          ..sort(
            (a, b) => store
                .usageCount(b.id)
                .compareTo(store.usageCount(a.id)),
          );

        final categoryCounts = <ProcedureCategory, int>{
          for (final category in ProcedureCategory.values)
            category: store.procedures
                .where((e) => e.category == category)
                .length,
        };

        final maxUsage = mostUsed.isEmpty
            ? 1
            : mostUsed
                .map((e) => store.usageCount(e.id))
                .fold<int>(1, (a, b) => a > b ? a : b);

        final maxCategory = categoryCounts.values.isEmpty
            ? 1
            : categoryCounts.values
                .fold<int>(1, (a, b) => a > b ? a : b);

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
          children: [
            const SectionTitle(
              kicker: 'Local analytics',
              title: 'Insights',
            ),
            const SizedBox(height: 8),
            const Text(
              'Calculated from your saved procedures and completed runs.',
              style: TextStyle(
                color: sopivaSlate,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: sopivaInk,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  _DarkInsightRow(
                    label: 'Average completion',
                    value:
                        '${(store.averageCompletionRate * 100).round()}%',
                    icon: Icons.task_alt_rounded,
                    color: sopivaMint,
                  ),
                  const Divider(color: Colors.white12, height: 26),
                  _DarkInsightRow(
                    label: 'Average run time',
                    value:
                        formatDuration(store.averageDurationSeconds),
                    icon: Icons.timer_outlined,
                    color: sopivaGold,
                  ),
                  const Divider(color: Colors.white12, height: 26),
                  _DarkInsightRow(
                    label: 'Handled steps',
                    value:
                        '${store.totalCompletedSteps + store.totalSkippedSteps}',
                    icon: Icons.checklist_rounded,
                    color: sopivaCoral,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const SectionTitle(
              kicker: 'Usage',
              title: 'Most used procedures',
            ),
            const SizedBox(height: 14),
            if (store.totalRuns == 0)
              const _BlankSlate(
                icon: Icons.insights_outlined,
                title: 'No usage data yet',
                message:
                    'Complete a few procedure runs to build performance insights.',
              )
            else
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    for (final item in mostUsed
                        .where((e) => store.usageCount(e.id) > 0)
                        .take(6))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _BarInsight(
                          label: item.title,
                          value: store.usageCount(item.id),
                          max: maxUsage,
                          color: categoryColor(item.category),
                          suffix: 'runs',
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 28),
            const SectionTitle(
              kicker: 'Library',
              title: 'Category mix',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  for (final entry in categoryCounts.entries)
                    if (entry.value > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _BarInsight(
                          label: procedureCategoryLabel(entry.key),
                          value: entry.value,
                          max: maxCategory,
                          color: categoryColor(entry.key),
                          suffix: entry.value == 1
                              ? 'procedure'
                              : 'procedures',
                        ),
                      ),
                  if (categoryCounts.values.every((e) => e == 0))
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Create procedures to see the category mix.',
                        style: TextStyle(color: sopivaSlate),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DarkInsightRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DarkInsightRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _BarInsight extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  final String suffix;

  const _BarInsight({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = max <= 0 ? 0.0 : value / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$value $suffix',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ProgressTrack(
          value: ratio,
          color: color,
          height: 8,
        ),
      ],
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
            title: const Text('Settings'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
            children: [
              const SectionTitle(
                kicker: 'Workspace',
                title: 'Preferences',
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: SwitchListTile(
                  value: store.darkMode,
                  onChanged: store.setDarkMode,
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text(
                    'Dark mode',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text(
                    'Use a darker workspace appearance.',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle(
                kicker: 'Information',
                title: 'Legal',
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.privacy_tip_outlined),
                      title: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'Privacy Policy',
                            body: privacyText,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading:
                          const Icon(Icons.description_outlined),
                      title: const Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'Terms & Conditions',
                            body: termsText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle(
                kicker: 'Data',
                title: 'Local storage',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sopivaCoral.withOpacity(.08),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reset everything',
                      style: TextStyle(
                        color: sopivaCoral,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Delete all procedures, steps, execution history, and calculated statistics from this device.',
                      style: TextStyle(
                        color: sopivaSlate,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _resetAll(context, store),
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('RESET LOCAL DATA'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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

Future<void> _resetAll(
  BuildContext context,
  SopivaStore store,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Reset SOPIVA?'),
      content: const Text(
        'All procedures, checklist steps, run history, and local statistics will be removed from this device.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('RESET'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await store.resetAll();
  }
}

void _openProcedureEditor(
  BuildContext context,
  SopivaStore store, {
  ProcedureItem? procedure,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProcedureEditorScreen(
        store: store,
        procedure: procedure,
      ),
    ),
  );
}

void _openProcedureDetail(
  BuildContext context,
  SopivaStore store,
  String id,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProcedureDetailScreen(
        store: store,
        procedureId: id,
      ),
    ),
  );
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
