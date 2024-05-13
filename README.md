<h1 align="center">Popover</h1>

<p align="center">
  <a href="https://github.com/minikin/popover/">
    <img src="https://i.ibb.co/0DW1XQ0/popover-demo.png" alt="Popover screenshots" />
  </a>
<h2 align="center">Popover for Flutter</h2>
</p>

<p align="center">

  <a href="https://github.com/minikin/popover">
    <img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20Android%20%7C%20Linux%20%7C%20Windows%20%7C%20Web-green.svg" alt="Supported platforms" />
  </a>

   <a href="https://github.com/minikin/popover/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="Popover is released under the MIT license." />
  </a>

  <a href="https://github.com/tenhobi/effective_dart">
    <img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" alt="Effective Dart" />
  </a>

  <a href="https://github.com/minikin/popover/blob/main/CODE_OF_CONDUCT.md">
    <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs welcome!" />
  </a>

  </br>

   <a href="https://github.com/minikin/popover/actions">
    <img src="https://github.com/minikin/popover/workflows/On%20Pull%20Request/badge.svg" alt="Current Build Status." />
  </a>

  <a href="https://codecov.io/gh/minikin/popover">
    <img src="https://codecov.io/gh/minikin/popover/branch/main/graph/badge.svg?token=CHT3D24SOQ"/>
  </a>

</p>

# Content

- [Content](#content)
  - [Features](#features)
  - [Requirements](#requirements)
  - [Install](#install)
  - [Example](#example)
  - [Support](#support)
  - [License](#license)

## Features

> A popover is a transient view that appears above other content onscreen when you tap a control or in an area. Typically, a popover includes an arrow pointing to the location from which it emerged. Popovers can be nonmodal or modal. A nonmodal popover is dismissed by tapping another part of the screen or a button on the popover. A modal popover is dismissed by tapping a Cancel or other button on the popover.

Source: [Human Interface Guidelines.
](https://developer.apple.com/design/human-interface-guidelines/ios/views/popovers/)

## Requirements

- Dart: 3.2.0+
- Flutter: 3.16.0+

## Install

```yaml
dependencies:
  popover: ^0.3.0+1
```

## Example

See `example/lib/main.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class PopoverExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Popover Example')),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Button(),
          ),
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({Key? key}) : super(key: key);

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
          showPopover(
            context: context,
            bodyBuilder: (context) => const ListItems(),
            onPop: () => print('Popover was popped!'),
            direction: PopoverDirection.bottom,
            width: 200,
            height: 400,
            arrowHeight: 15,
            arrowWidth: 30,
          );
        },
      ),
    );
  }
}

class ListItems extends StatelessWidget {
  const ListItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context)
                  ..pop()
                  ..push(
                    MaterialPageRoute<SecondRoute>(
                      builder: (context) => SecondRoute(),
                    ),
                  );
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
          ],
        ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
```

To see examples of the following package on a device or simulator:

```sh
cd example && flutter run
```

## Support

Post issues and feature requests on the GitHub [issue tracker](https://github.com/minikin/popover/issues).

## License

The source code of Popover project is available under the MIT license.
See the [LICENSE](https://github.com/minikin/popover/blob/main/LICENSE) file for more info.
