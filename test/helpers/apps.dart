import 'package:cupertino_ui/cupertino_ui.dart' as cui;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as legacy;
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as mui;

typedef AppBuilder = Widget Function(
  WidgetBuilder launcherBuilder, {
  Brightness? brightness,
});

const appsByLibrary = <String, AppBuilder>{
  'flutter/material': legacyApp,
  'material_ui': materialUiApp,
  'flutter/cupertino': cupertinoApp,
  'cupertino_ui': cupertinoUiApp,
};

Widget legacyApp(
  WidgetBuilder launcherBuilder, {
  Alignment alignment = Alignment.center,
  Brightness? brightness,
}) {
  return legacy.MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: brightness == null ? null : legacy.ThemeData(brightness: brightness),
    home: legacy.Scaffold(
      body: Align(
        alignment: alignment,
        child: Builder(builder: launcherBuilder),
      ),
    ),
  );
}

Widget materialUiApp(WidgetBuilder launcherBuilder, {Brightness? brightness}) {
  return mui.MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: brightness == null ? null : mui.ThemeData(brightness: brightness),
    home: mui.Scaffold(
      body: Center(child: Builder(builder: launcherBuilder)),
    ),
  );
}

Widget cupertinoApp(WidgetBuilder launcherBuilder, {Brightness? brightness}) {
  return cupertino.CupertinoApp(
    debugShowCheckedModeBanner: false,
    theme: brightness == null
        ? null
        : cupertino.CupertinoThemeData(brightness: brightness),
    home: cupertino.CupertinoPageScaffold(
      child: Center(child: Builder(builder: launcherBuilder)),
    ),
  );
}

Widget cupertinoUiApp(WidgetBuilder launcherBuilder, {Brightness? brightness}) {
  return cui.CupertinoApp(
    debugShowCheckedModeBanner: false,
    theme: brightness == null
        ? null
        : cui.CupertinoThemeData(brightness: brightness),
    home: cui.CupertinoPageScaffold(
      child: Center(child: Builder(builder: launcherBuilder)),
    ),
  );
}
