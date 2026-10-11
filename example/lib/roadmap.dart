import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

const shareAnchor = Key('share-anchor');
const filterAnchor = Key('filter-anchor');

Key statusAnchor(String issue) => Key('status-$issue');

enum _Status {
  backlog('Backlog', Color(0xFF9B9BA4)),
  todo('Todo', Color(0xFF5E6AD2)),
  inProgress('In Progress', Color(0xFFF2994A)),
  done('Done', Color(0xFF27AE60)),
  canceled('Canceled', Color(0xFFE5484D));

  final String label;
  final Color color;

  const _Status(this.label, this.color);
}

/// An issue list with three popovers: a Share menu, a filter menu and a status
/// picker on every issue. The README demo image is this screen.
class RoadmapPage extends StatefulWidget {
  const RoadmapPage({super.key});

  @override
  State<RoadmapPage> createState() => _RoadmapPageState();
}

class _RoadmapPageState extends State<RoadmapPage> {
  final _issues = [
    ('POP-118', 'Native arrow shape on Apple platforms', _Status.todo),
    ('POP-116', 'Place popovers like UIKit and NSPopover', _Status.inProgress),
    ('POP-115', 'Follow the anchor while it scrolls', _Status.done),
    ('POP-114', 'Support material_ui and cupertino_ui', _Status.done),
    ('POP-112', 'Golden tests on Linux', _Status.done),
    ('POP-109', 'Keyboard-aware placement', _Status.done),
    ('POP-104', 'Right-to-left layouts', _Status.backlog),
    ('POP-101', 'Clicks through the barrier', _Status.backlog),
  ];
  final _filters = {
    'Assigned to me': true,
    'Has a label': false,
    'Updated this week': true,
    'Show canceled': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Roadmap',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Builder(
            builder: (context) => OutlinedButton.icon(
              key: filterAnchor,
              style: OutlinedButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerLowest,
              ),
              onPressed: () => _showFilters(context),
              icon: const Icon(Icons.filter_list, size: 18),
              label: const Text('Filter'),
            ),
          ),
          const SizedBox(width: 8),
          Builder(
            builder: (context) => FilledButton.icon(
              key: shareAnchor,
              onPressed: () => _showShareMenu(context),
              icon: const Icon(Icons.ios_share, size: 18),
              label: const Text('Share'),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        children: [
          for (final (index, (id, title, status)) in _issues.indexed)
            _Issue(
              id: id,
              title: title,
              status: status,
              onStatusTap: (context) => _showStatuses(context, index),
            ),
        ],
      ),
    );
  }

  void _showShareMenu(BuildContext context) {
    _show(
      context,
      width: 240,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuItem(Icons.link, 'Copy link', '⌘L'),
          _MenuItem(Icons.content_copy, 'Duplicate', '⌘D'),
          _MenuItem(Icons.drive_file_move_outline, 'Move to project', '⇧M'),
          _MenuItem(Icons.notifications_none, 'Subscribe', 'S'),
          Divider(height: 9, indent: 12, endIndent: 12),
          _MenuItem(Icons.delete_outline, 'Delete', '⌫', destructive: true),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    _show(
      context,
      width: 250,
      child: StatefulBuilder(
        builder: (context, setMenuState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Filter issues',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A8A93),
                  ),
                ),
              ),
            ),
            for (final MapEntry(key: label, value: on) in _filters.entries)
              CheckboxListTile(
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                value: on,
                title: Text(label, style: const TextStyle(fontSize: 14)),
                onChanged: (value) =>
                    setMenuState(() => _filters[label] = value ?? false),
              ),
          ],
        ),
      ),
    );
  }

  void _showStatuses(BuildContext context, int index) {
    final (id, title, current) = _issues[index];
    _show(
      context,
      width: 200,
      direction: PopoverDirection.right,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final status in _Status.values)
            InkWell(
              onTap: () {
                setState(() => _issues[index] = (id, title, status));
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: status.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        status.label,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (status == current)
                      const Icon(
                        Icons.check,
                        size: 16,
                        color: Color(0xFF5E6AD2),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static void _show(
    BuildContext context, {
    required double width,
    required Widget child,
    PopoverDirection direction = PopoverDirection.bottom,
  }) {
    final platform = defaultTargetPlatform;
    final native =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    showPopover(
      context: context,
      width: width,
      direction: direction,
      style: PopoverStyle(
        barrierColor: const Color(0x00000000),
        shadow: native
            ? null
            : const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
                BoxShadow(color: Color(0x2E000000), spreadRadius: 0.5),
              ],
      ),
      // The native shape brings its own shadow. The triangle gets a hairline
      // outline so its arrow shows on the white rows.
      bodyBuilder: (context) => Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: child,
        ),
      ),
    );
  }
}

class _Issue extends StatefulWidget {
  final String id;
  final String title;
  final _Status status;
  final void Function(BuildContext context) onStatusTap;

  const _Issue({
    required this.id,
    required this.title,
    required this.status,
    required this.onStatusTap,
  });

  @override
  State<_Issue> createState() => _IssueState();
}

class _IssueState extends State<_Issue> {
  final _dot = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFE6E6EA)
              : const Color(0xFF2A2A30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            key: statusAnchor(widget.id),
            tooltip: widget.status.label,
            onPressed: () => widget.onStatusTap(_dot.currentContext!),
            icon: Icon(
              Icons.circle,
              key: _dot,
              size: 12,
              color: widget.status.color,
            ),
          ),
          Text(
            widget.id,
            style: const TextStyle(color: Color(0xFF8A8A93), fontSize: 13),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String shortcut;
  final bool destructive;

  const _MenuItem(
    this.icon,
    this.label,
    this.shortcut, {
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? const Color(0xFFE5484D)
        : Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, color: color)),
            ),
            Text(
              shortcut,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9B9BA4)),
            ),
          ],
        ),
      ),
    );
  }
}
