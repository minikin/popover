import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

const demoAnchor = Key('demo-anchor');

/// An issue list with a Share menu. The README demo image is this screen.
class RoadmapPage extends StatelessWidget {
  const RoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Roadmap',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Builder(
              builder: (context) => FilledButton.icon(
                key: demoAnchor,
                onPressed: () => _showMenu(context),
                icon: const Icon(Icons.ios_share, size: 18),
                label: const Text('Share'),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        children: const [
          _Issue(
            'POP-118',
            'Native arrow shape on Apple platforms',
            0xFFF2994A,
          ),
          _Issue(
            'POP-116',
            'Place popovers like UIKit and NSPopover',
            0xFF5E6AD2,
          ),
          _Issue('POP-115', 'Follow the anchor while it scrolls', 0xFF27AE60),
          _Issue('POP-114', 'Support material_ui and cupertino_ui', 0xFF27AE60),
          _Issue('POP-112', 'Golden tests on Linux', 0xFF27AE60),
          _Issue('POP-109', 'Keyboard-aware placement', 0xFF27AE60),
          _Issue('POP-104', 'Right-to-left layouts', 0xFF9B9BA4),
          _Issue('POP-101', 'Clicks through the barrier', 0xFF9B9BA4),
        ],
      ),
    );
  }

  static void _showMenu(BuildContext context) {
    showPopover(
      context: context,
      width: 240,
      radius: 12,
      arrowWidth: 22,
      arrowHeight: 11,
      barrierColor: const Color(0x00000000),
      shadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
        BoxShadow(color: Color(0x0F000000), blurRadius: 2),
      ],
      bodyBuilder: (context) => const Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Column(
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
        ),
      ),
    );
  }
}

class _Issue extends StatelessWidget {
  final String id;
  final String title;
  final int status;

  const _Issue(this.id, this.title, this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6E6EA)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: Color(status)),
          const SizedBox(width: 12),
          Text(
            id,
            style: const TextStyle(color: Color(0xFF8A8A93), fontSize: 13),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
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
        : const Color(0xFF1C1C21);
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
