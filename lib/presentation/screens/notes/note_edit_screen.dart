import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notes_provider.dart';
import '../../../core/models/note.dart';
import '../../../core/models/calendar_date.dart';

/// Note Edit Screen - Create or edit a note
class NoteEditScreen extends StatefulWidget {
  final Note? note;
  final SolarDate? solarDate;

  const NoteEditScreen({
    super.key,
    this.note,
    this.solarDate,
  });

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  List<String> _tags = [];
  String? _selectedColor;

  final List<String> _availableColors = [
    '#FF6B6B', // Red
    '#4ECDC4', // Teal
    '#45B7D1', // Blue
    '#FFA07A', // Orange
    '#98D8C8', // Green
    '#F7DC6F', // Yellow
    '#BB8FCE', // Purple
    '#85C1E2', // Light Blue
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController = TextEditingController(text: widget.note!.title);
      _contentController = TextEditingController(text: widget.note!.content);
      _tags = List.from(widget.note!.tags);
      _tagsController = TextEditingController(text: widget.note!.tags.join(', '));
      _selectedColor = widget.note!.color;
    } else {
      _titleController = TextEditingController();
      _contentController = TextEditingController();
      _tagsController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _parseTags() {
    final tagText = _tagsController.text.trim();
    if (tagText.isEmpty) {
      _tags = [];
      return;
    }
    _tags = tagText.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _parseTags();

    final notesProvider = context.read<NotesProvider>();
    final solarDate = widget.solarDate ?? 
        (widget.note != null ? widget.note!.toSolarDate() : SolarDate.fromDateTime(DateTime.now()));

    if (widget.note != null) {
      // Update existing note
      final updatedNote = widget.note!.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: _tags,
        color: _selectedColor,
      );
      await notesProvider.updateNote(updatedNote);
    } else {
      // Create new note
      await notesProvider.createNote(
        solarDate: solarDate,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: _tags,
        color: _selectedColor,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteNote() async {
    if (widget.note == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ghi chú'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<NotesProvider>().deleteNote(widget.note!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa ghi chú' : 'Ghi chú mới'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNote,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              
              // Content field
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              
              // Tags field
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (phân cách bằng dấu phẩy)',
                  border: OutlineInputBorder(),
                  hintText: 'Ví dụ: Công việc, Quan trọng',
                ),
                onChanged: (_) => _parseTags(),
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: _tags.map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                        _tagsController.text = _tags.join(', ');
                      });
                    },
                  )).toList(),
                ),
              ],
              const SizedBox(height: 16),
              
              // Color picker
              Text(
                'Màu sắc',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  // No color option
                  _ColorOption(
                    color: null,
                    isSelected: _selectedColor == null,
                    onTap: () => setState(() => _selectedColor = null),
                  ),
                  ..._availableColors.map((color) => _ColorOption(
                    color: color,
                    isSelected: _selectedColor == color,
                    onTap: () => setState(() => _selectedColor = color),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final String? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color != null ? _parseColor(color!) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: color == null
            ? Icon(
                Icons.circle_outlined,
                color: Colors.grey,
                size: 20,
              )
            : null,
      ),
    );
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }
}

