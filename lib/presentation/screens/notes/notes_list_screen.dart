import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/notes_provider.dart';
import '../../../core/models/note.dart';
import '../../../core/models/calendar_date.dart';
import 'note_edit_screen.dart';

/// Notes List Screen - Shows all notes or filtered notes
class NotesListScreen extends StatefulWidget {
  final SolarDate? filterDate;
  final String? filterTag;

  const NotesListScreen({
    super.key,
    this.filterDate,
    this.filterTag,
  });

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final notesProvider = context.read<NotesProvider>();
    if (widget.filterDate != null) {
      // Filter by date if provided
    } else if (widget.filterTag != null) {
      notesProvider.filterByTag(widget.filterTag);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi Chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<NotesProvider>().searchNotes('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                context.read<NotesProvider>().searchNotes(value);
              },
            ),
          ),
          // Notes list
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                final notes = widget.filterDate != null
                    ? notesProvider.getNotesForDate(widget.filterDate!)
                    : notesProvider.filteredNotes;

                if (notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.filterDate != null
                              ? 'Chưa có ghi chú cho ngày này'
                              : 'Chưa có ghi chú nào',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return _NoteCard(note: note);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final date = widget.filterDate ?? SolarDate.fromDateTime(DateTime.now());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditScreen(
                solarDate: date,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final notesProvider = context.read<NotesProvider>();
    final tags = notesProvider.getAllTags();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lọc ghi chú'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tất cả'),
              leading: Radio<String?>(
                value: null,
                groupValue: notesProvider.selectedTag,
                onChanged: (value) {
                  notesProvider.filterByTag(null);
                  Navigator.pop(context);
                },
              ),
            ),
            ...tags.map((tag) => ListTile(
              title: Text(tag),
              leading: Radio<String?>(
                value: tag,
                groupValue: notesProvider.selectedTag,
                onChanged: (value) {
                  notesProvider.filterByTag(value);
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}

/// Note Card Widget
class _NoteCard extends StatelessWidget {
  final Note note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditScreen(note: note),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(note.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: note.tags.map((tag) => Chip(
                    label: Text(tag),
                    labelStyle: const TextStyle(fontSize: 10),
                    padding: EdgeInsets.zero,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

