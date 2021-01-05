import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class PopoverItems extends StatelessWidget {
  const PopoverItems({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Popover(
      child: Container(
        width: 80,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: const Center(child: Text('Click Me')),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Container(
              height: 50,
              color: Colors.amber[600],
              child: const Center(child: Text('Entry A')),
            ),
            Container(
              height: 50,
              color: Colors.amber[500],
              child: const Center(child: Text('Entry B')),
            ),
            Container(
              height: 50,
              color: Colors.amber[100],
              child: const Center(child: Text('Entry C')),
            ),
          ],
        );
      },
    );
  }
}
