import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

void main() => runApp(PopoverExample());

class PopoverExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    const PopoverItems(),
                    const PopoverItems(),
                    const PopoverItems(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const PopoverItems(),
                    const PopoverItems(),
                    const PopoverItems(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const PopoverItems(),
                    const PopoverItems(),
                    const PopoverItems(),
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
  const PopoverItems({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Popover(
      direction: PopoverDirection.top,
      width: 200,
      arrowHeight: 15,
      arrowWidth: 30,
      child: const Child(),
      onPop: () => print('Popover was popped!'),
      bodyBuilder: (context) {
        return Scrollbar(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
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
      },
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
