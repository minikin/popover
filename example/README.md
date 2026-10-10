# Popover example

Two tabs. Roadmap is an issue list with a Share menu, a filter menu and a
status picker on every issue. It is the screen in the README demo image.
Playground has nine buttons across the screen and a direction switcher, to see
how the popover flips, slides and shrinks near the edges. Run it from this
directory:

```bash
flutter run
```

`integration_test/popover_test.dart` opens every Playground button, taps an
item, rotates phones and tablets and takes the demo screenshot. CONTRIBUTING.md
in the repository root shows how to run it, and `tool/demo/render.sh` turns the
screenshots into the demo image.
