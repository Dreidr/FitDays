import 'package:flutter/material.dart';
import 'package:mobile/features/workout/services/local_exercise_repo.dart';
import 'package:mobile/features/workout/exercise_detail_screen.dart';
import 'package:mobile/features/workout/widgets/exercise_thumb.dart';

class AllExercisesScreen extends StatefulWidget {
  final String? targetFilter;
  final bool selectionMode;
  final bool warmupOnly;
  final bool multiSelect;
  final List<String> preselectedIds;

  const AllExercisesScreen({
    super.key,
    this.targetFilter,
    this.selectionMode = false,
    this.warmupOnly = false,
    this.multiSelect = false,
    this.preselectedIds = const [],
  });

  @override
  State<AllExercisesScreen> createState() => _AllExercisesScreenState();
}

class _AllExercisesScreenState extends State<AllExercisesScreen> {
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  List<String> _bodyParts = [];

  bool _loading = false;
  int _totalAll = 0;

  String? _selectedBodyPart; // null = all
  String _search = "";
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();

    _selectedIds.addAll(widget.preselectedIds);

    _bootstrap();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _s(dynamic v) => (v ?? '').toString();

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      final all = widget.warmupOnly
          ? await LocalExerciseRepo.loadWarmups()
          : await LocalExerciseRepo.loadAll();
      final parts = await LocalExerciseRepo.bodyParts();
      final warmups = await LocalExerciseRepo.loadWarmups();

      var filtered = all;

      if (widget.targetFilter != null) {
        filtered = all.where((e) {
          return _s(e["target"]).toLowerCase() ==
              widget.targetFilter!.toLowerCase();
        }).toList();
      }

      for (final w in warmups.take(30)) {}

      if (!mounted) return;

      setState(() {
        _items = filtered;
        _totalAll = filtered.length;
        _bodyParts = parts;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _applyFilters() async {
    setState(() => _loading = true);
    try {
      List<Map<String, dynamic>> list;

      if (_search.trim().isNotEmpty) {
        list = await LocalExerciseRepo.searchByName(_search);
      } else if (_selectedBodyPart != null && _selectedBodyPart!.isNotEmpty) {
        list = await LocalExerciseRepo.byBodyPart(_selectedBodyPart!);
      } else {
        list = await LocalExerciseRepo.loadAll();
      }

      if (!mounted) return;
      setState(() => _items = list);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async => _applyFilters();

  void _applySearch(String v) {
    setState(() => _search = v);
    _applyFilters();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _search = "");
    _applyFilters();
  }

  void _selectBodyPart(String? part) {
    setState(() => _selectedBodyPart = part);
    _applyFilters();
  }

  void _confirmSelection() {
    final selected = _items
        .where((e) => _selectedIds.contains(e['id'].toString()))
        .toList();

    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    final title = _selectedBodyPart == null
        ? "All Exercises"
        : "Exercises • ${_selectedBodyPart!}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: _applySearch,
              decoration: InputDecoration(
                hintText: "Search exercise name (e.g. push up)",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // BodyPart filter chips
          if (_bodyParts.isNotEmpty) ...[
            SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: "All ($_totalAll)",
                    selected: _selectedBodyPart == null,
                    onTap: () => _selectBodyPart(null),
                  ),
                  ..._bodyParts.map(
                    (p) => _FilterChip(
                      label: p,
                      selected: _selectedBodyPart == p,
                      onTap: () => _selectBodyPart(p),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Showing ${_items.length} / $_totalAll",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],

          const Divider(height: 1),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final ex = _items[index];
                        final name = _s(ex['name']);
                        final bodyPart = _s(ex['bodyPart']);
                        final target = _s(ex['target']);
                        final equipment = _s(ex['equipment']);
                        final isSelected = _selectedIds.contains(
                          ex['id'].toString(),
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              if (widget.multiSelect) {
                                final id = ex['id'].toString();

                                setState(() {
                                  if (_selectedIds.contains(id)) {
                                    _selectedIds.remove(id);
                                  } else {
                                    _selectedIds.add(id);
                                  }
                                });

                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ExerciseDetailScreen(exercise: ex),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),

                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(
                                        0xFF4442D9,
                                      ).withValues(alpha: 0.05)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF4442D9)
                                      : Colors.black.withValues(alpha: 0.06),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: ExerciseThumb(
                                        exerciseId: ex['id'].toString(),
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
                                          name.isEmpty ? "Exercise" : name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          [
                                            if (bodyPart.isNotEmpty) bodyPart,
                                            if (target.isNotEmpty)
                                              "Target: $target",
                                            if (equipment.isNotEmpty)
                                              "Equip: $equipment",
                                          ].join(" • "),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  widget.multiSelect
                                      ? Icon(
                                          _selectedIds.contains(
                                                ex['id'].toString(),
                                              )
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,

                                          color:
                                              _selectedIds.contains(
                                                ex['id'].toString(),
                                              )
                                              ? const Color(0xFF4442D9)
                                              : Colors.black38,
                                        )
                                      : const Icon(
                                          Icons.chevron_right,
                                          color: Colors.black45,
                                        ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: widget.multiSelect
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _selectedIds.isEmpty ? null : _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4442D9),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _selectedIds.isEmpty
                        ? "Select Exercises"
                        : "Add ${_selectedIds.length} Exercise${_selectedIds.length == 1 ? '' : 's'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF4442D9).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? const Color(0xFF4442D9).withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: selected ? const Color(0xFF2F2ECF) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
