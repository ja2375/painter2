# painter2

A simple flutter widget to paint with your fingers.

## Features

The widget supports:
- Changing fore- and background color
- Changing the thickness of lines you draw
- Exporting your painting as png
- Undo/Redo drawing a line
- Clear the whole drawing

## Installation

In your `pubspec.yaml` file within your Flutter Project:

```yaml
dependencies:
  painter2: ^0.0.1
```

Then import it:

```dart
import 'package:painter2/painter2.dart';
```

## Use it

In order to use this plugin, first create a controller:

```dart
PainterController controller = PainterController();
controller.thickness = 5.0;
controller.backgroundColor = Colors.green;
```

That controller will handle all properties of your drawing space.

Then, to display the painting area, create an inline `Painter` object and give it a reference to your previously created controller:

```dart
Painter(controller)
```

## Example

For a full example take a look at the [example project](https://github.com/ja2375/painter2/tree/master/example).
Here is a short recording showing it.
Note that the color picker is an external dependency which is only required for the example.

![demo!](https://raw.githubusercontent.com/epnw/painter/master/example/demo.gif)
