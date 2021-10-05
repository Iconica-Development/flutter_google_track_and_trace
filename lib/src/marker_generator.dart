part of google_track_trace;

Future<BitmapDescriptor> convertBytesToCustomBitmapDescriptor(
  Uint8List image, {
  int size = 150,
  bool addBorder = false,
  Color borderColor = Colors.white,
  double borderSize = 10,
  String? title,
  Color titleColor = Colors.white,
  Color titleBackgroundColor = Colors.black,
}) async {
  var pictureRecorder = ui.PictureRecorder();
  var canvas = Canvas(pictureRecorder);
  var paint = Paint()..color;
  var textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );
  var radius = size / 2;

  //make canvas clip path to prevent image drawing over the circle
  var clipPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Radius.circular(100),
      ),
    )
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
        Radius.circular(100),
      ),
    );
  canvas.clipPath(clipPath);

  //paintImage
  var imageUint8List = image;
  var codec = await ui.instantiateImageCodec(imageUint8List);
  var imageFI = await codec.getNextFrame();
  paintImage(
    canvas: canvas,
    rect: Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    image: imageFI.image,
  );

  if (addBorder) {
    //draw Border
    paint
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderSize;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
  }

  if (title != null) {
    var displayedTitle = '';
    if (title.length > 9) {
      displayedTitle = title.substring(0, 9);
    } else {
      displayedTitle = title;
    }
    //draw Title background
    paint
      ..color = titleBackgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
        Radius.circular(100),
      ),
      paint,
    );

    //draw Title
    textPainter
      ..text = TextSpan(
        text: displayedTitle,
        style: TextStyle(
          fontSize: radius / 2.5,
          fontWeight: FontWeight.bold,
          color: titleColor,
        ),
      )
      ..layout()
      ..paint(
        canvas,
        Offset(
          radius - textPainter.width / 2,
          size * 9.5 / 10 - textPainter.height / 2,
        ),
      );
  }

  //convert canvas as PNG bytes
  var _image =
      await pictureRecorder.endRecording().toImage(size, (size * 1.1).toInt());
  var data = await _image.toByteData(format: ui.ImageByteFormat.png);

  //convert PNG bytes as BitmapDescriptor
  return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
}

/// https://medium.com/@JBXBergDev/how-to-use-googlemap-markers-with-flutter-material-icons-38c4c975e928
Future<BitmapDescriptor> createBitmapDescriptorFromIconData(
  IconData iconData,
  double markerSize,
  Color iconColor,
  Color circleColor,
  Color backgroundColor,
) async {
  var pictureRecorder = ui.PictureRecorder();
  //var canvas = Canvas(pictureRecorder);

  //_paintCircleFill(canvas, backgroundColor);
  //_paintCircleStroke(canvas, circleColor);
  //_paintIcon(canvas, iconColor, iconData);

  var picture = pictureRecorder.endRecording();
  var image = await picture.toImage(markerSize.round(), markerSize.round());
  var bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}

/// Paints the icon background
  // void _paintCircleFill(Canvas canvas, Color color) {
  //   final paint = Paint()
  //     ..style = PaintingStyle.fill
  //     ..color = color;
  //   canvas.drawCircle(Offset(_circleOffset, _circleOffset), 
  //_fillCircleWidth, paint);
  // }

  // /// Paints a circle around the icon
  // void _paintCircleStroke(Canvas canvas, Color color) {
  //   final paint = Paint()
  //     ..style = PaintingStyle.stroke
  //     ..color = color
  //     ..strokeWidth = _circleStrokeWidth;
  //   canvas.drawCircle(Offset(_circleOffset, _circleOffset), 
  //_outlineCircleWidth, paint);
  // }

  // /// Paints the icon
  // void _paintIcon(Canvas canvas, Color color, IconData iconData) {
  //   final textPainter = TextPainter(textDirection: TextDirection.ltr);
  //   textPainter.text = TextSpan(
  //       text: String.fromCharCode(iconData.codePoint),
  //       style: TextStyle(
  //         letterSpacing: 0.0,
  //         fontSize: _iconSize,
  //         fontFamily: iconData.fontFamily,
  //         color: color,
  //       )
  //   );
  //   textPainter.layout();
  //   textPainter.paint(canvas, Offset(_iconOffset, _iconOffset));
  // }
