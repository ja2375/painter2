# painter2

A simple flutter widget to paint with your fingers.

## Features

The widget supports:
- Changing fore- and background color
- Setting an image as background
- Changing the thickness of lines you draw
- Exporting your painting as png
- Undo/Redo drawing a line
- Clear the whole drawing

## Installation

In your `pubspec.yaml` file within your Flutter Project:

```yaml
dependencies:
  painter2: any
```

Then import it:

```dart
import 'package:painter2/painter2.dart';
```

## Use it

In order to use this plugin, first create a controller:

```dart
PainterController controller = PainterController();
controller.thickness = 5.0; // Set thickness of your brush. Defaults to 1.0
controller.backgroundColor = Colors.green; // Background color is ignores if you set a background image
controller.backgroundImage = Image.network(...); // Sets a background image. You can load images as you would normally do: From an asset, from the network, from memory...
```

That controller will handle all properties of your drawing space.

Then, to display the painting area, create an inline `Painter` object and give it a reference to your previously created controller:

```dart
Painter(controller)
```

By exporting the painting as PNG, you will get an Uint8List object which represents the bytes of the png final file:

```dart
await controller.exportAsPNGBytes();
```

The library does not handle saving the final image anywhere.

## Example

For a full example take a look at the [example project](https://github.com/ja2375/painter2/tree/master/example).
Here is a short recording showing it.
Note that the color picker is an external dependency which is only required for the example.

![demo!](https://raw.githubusercontent.com/epnw/painter/master/example/demo.gif)
