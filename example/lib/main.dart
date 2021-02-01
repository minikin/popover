import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:popover/popover.dart';

void main() => runApp(PopoverExample());

final widgetKey = GlobalKey();

void _showPopooverAfterDelay(BuildContext context, Key key) {
  Future.delayed(const Duration(milliseconds: 2500), () {
    final Popover popover = widgetKey.currentWidget;
    print(popover.toString());
    popover.programOnTap(context);
  });
}

// void _programTap(BuildContext context, GlobalKey key) {
//   final renderObj = context.findRenderObject();
//   if (renderObj is RenderBox) {
//     final hitTestResult = BoxHitTestResult();
//     if (renderObj.hitTest(hitTestResult, position: _widgetOffset(key))) {
//       print(hitTestResult.path);
//     }
//   }
// }

// Offset _widgetOffset(GlobalKey key) {
//   final RenderBox box = key.currentContext.findRenderObject();
//   return box.localToGlobal(Offset.zero);
// }

class PopoverExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _showPopooverAfterDelay(context, widgetKey);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Popover Example')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    PopoverItems(),
                    PopoverItems(popoverKey: widgetKey),
                    PopoverItems(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    PopoverItems(),
                    PopoverItems(),
                    PopoverItems(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    PopoverItems(),
                    PopoverItems(),
                    PopoverItems(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PopoverItems extends StatelessWidget {
  final Key popoverKey;

  PopoverItems({
    this.popoverKey = const ValueKey('PopoverKey'),
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Popover(
      key: popoverKey,
      direction: PopoverDirection.top,
      width: 200,
      arrowHeight: 15,
      arrowWidth: 30,
      child: const Child(),
      onPop: () => print('Popover was popped!'),
      bodyBuilder: (context) => const ListItems(),
    );
  }
}

class Child extends StatefulWidget {
  const Child({Key key}) : super(key: key);

  @override
  _ChildState createState() => _ChildState();
}

class _ChildState extends State<Child> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: GestureDetector(
        child: const Center(child: Text('Click Me')),
        onTap: () {
          print('GestureDetector was called in Child!');
        },
      ),
    );
  }
}

class ListItems extends StatelessWidget {
  const ListItems({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            InkWell(
              onTap: () {
                print('GestureDetector was called on Entry A');
                Navigator.of(context).pop();
              },
              child: Container(
                height: 50,
                color: Colors.amber[100],
                child: const Center(child: Text('Entry A')),
              ),
            ),
            const Divider(),
            Container(
              height: 50,
              color: Colors.amber[200],
              child: const Center(child: Text('Entry B')),
            ),
            const Divider(),
            Container(
              height: 50,
              color: Colors.amber[300],
              child: const Center(child: Text('Entry C')),
            ),
            const Divider(),
            Container(
              height: 50,
              color: Colors.amber[400],
              child: const Center(child: Text('Entry D')),
            ),
            const Divider(),
            Container(
              height: 50,
              color: Colors.amber[500],
              child: const Center(child: Text('Entry E')),
            ),
            const Divider(),
            Container(
              height: 50,
              color: Colors.amber[600],
              child: const Center(child: Text('Entry F')),
            ),
          ],
        ),
      ),
    );
  }
}
