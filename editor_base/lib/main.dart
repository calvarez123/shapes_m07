import 'dart:convert';
import 'dart:io' show Platform;
import 'package:editor_base/app_data_actions.dart';
import 'package:editor_base/util_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'app_data.dart';
import 'layout.dart';

void main() async {
  // For Linux, macOS and Windows, initialize WindowManager
  try {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      WidgetsFlutterBinding.ensureInitialized();
      await WindowManager.instance.ensureInitialized();
      windowManager.waitUntilReadyToShow().then(showWindow);
    }
  } catch (e) {
    // ignore: avoid_print
    print(e);
  }

  AppData appData = AppData();

  runApp(Focus(
    onKey: (FocusNode node, RawKeyEvent event) {
      bool isControlPressed = (Platform.isMacOS && event.isMetaPressed) ||
          (Platform.isLinux && event.isControlPressed) ||
          (Platform.isWindows && event.isControlPressed);
      bool isShiftPressed = event.isShiftPressed;
      bool isZPressed = event.logicalKey == LogicalKeyboardKey.keyZ;
      bool isDeletePressed = event.logicalKey == LogicalKeyboardKey.delete;
      bool isBackspacePressed =
          event.logicalKey == LogicalKeyboardKey.backspace;
      bool isCPressed = event.logicalKey == LogicalKeyboardKey.keyC;
      bool isVPressed = event.logicalKey == LogicalKeyboardKey.keyV;

      if (event is RawKeyDownEvent) {
        if (isControlPressed && isDeletePressed) {
          if (appData.selectedShapeIndex != -1) {
            var action = ActionRemoveShape(
                appData, appData.shapesList[appData.selectedShapeIndex]);
            appData.actionManager.register(action);
            return KeyEventResult.handled;
          }
        } else if (isControlPressed && isBackspacePressed) {
          if (appData.selectedShapeIndex != -1) {
            var action = ActionRemoveShape(
                appData, appData.shapesList[appData.selectedShapeIndex]);
            appData.actionManager.register(action);
            return KeyEventResult.handled;
          }
        } else if (isControlPressed && isZPressed && !isShiftPressed) {
          appData.actionManager.undo();
          return KeyEventResult.handled;
        } else if (isControlPressed && isShiftPressed && isZPressed) {
          appData.actionManager.redo();
          return KeyEventResult.handled;
        } else if (isControlPressed && isCPressed) {
          _copyToClipboard(appData);
          // Handle Control+C (copy) logic here
          return KeyEventResult.handled;
        } else if (isControlPressed && isVPressed) {
          // Handle Control+V (paste) logic here
          _pasteFromClipboard(appData);
          return KeyEventResult.handled;
        }

        if (event.logicalKey == LogicalKeyboardKey.altLeft) {
          appData.isAltOptionKeyPressed = true;
        }
      } else if (event is RawKeyUpEvent) {
        if (event.logicalKey == LogicalKeyboardKey.altLeft) {
          appData.isAltOptionKeyPressed = false;
        }
      }
      return KeyEventResult.ignored;
    },
    child: ChangeNotifierProvider(
      create: (context) => appData,
      child: const CDKApp(
        defaultAppearance: "system", // system, light, dark
        defaultColor:
            "systemBlue", // systemBlue, systemPurple, systemPink, systemRed, systemOrange, systemYellow, systemGreen, systemGray
        child: Layout(),
      ),
    ),
  ));
}

// Show the window when it's ready
void showWindow(_) async {
  const size = Size(800.0, 600.0);
  windowManager.setSize(size);
  windowManager.setMinimumSize(size);
  await windowManager.setTitle('Vector Editor');
}

void _copyToClipboard(AppData appData) {
  if (appData.selectedShapeIndex != -1) {
    Shape selectedShape = appData.shapesList[appData.selectedShapeIndex];
    String jsonString = jsonEncode(selectedShape.toMap());
    Clipboard.setData(ClipboardData(text: jsonString));
  }
}

Future<void> _pasteFromClipboard(AppData appData) async {
  try {
    String? jsonString = await Clipboard.getData(Clipboard.kTextPlain)
        ?.then((value) => value?.text);
    if (jsonString != null) {
      Map<String, dynamic> map = jsonDecode(jsonString);
      if (map['type'] == 'shape_drawing') {
        var shape = Shape.fromMap(map);

        appData.actionManager.register(ActionAddNewShape(appData, shape));
      }
    }
  } catch (e) {
    print("Error pasting from clipboard: $e");
  }
}
