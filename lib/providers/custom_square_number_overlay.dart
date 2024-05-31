import 'package:flutter/material.dart';
import 'package:squares/squares.dart';

class CustomSquareNumberOverlay extends StatefulWidget {
  final int orientation;
  final BoardSize size;
  final TextStyle? textStyle;
  final bool showCircle;
  final Color? circleColour;

  const CustomSquareNumberOverlay({
    Key? key,
    required this.orientation,
    this.size = BoardSize.standard,
    this.textStyle,
    this.showCircle = true,
    this.circleColour,
  }) : super(key: key);

  @override
  _CustomSquareNumberOverlayState createState() => _CustomSquareNumberOverlayState();
}

class _CustomSquareNumberOverlayState extends State<CustomSquareNumberOverlay> {
  bool numbersOutside = false; // Track whether numbers should be outside the board

  void toggleNumbersPosition() {
    setState(() {
      numbersOutside = !numbersOutside;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: toggleNumbersPosition,
          child: Text(numbersOutside ? 'Numbers Inside' : 'Numbers Outside'),
        ),
        SizedBox(height: 8),
        BoardBuilder.index(
          orientation: widget.orientation,
          size: widget.size,
          builder: (i, size) {
            return Padding(
              padding: EdgeInsets.all(size / 4),
              child: Stack(
                children: [
                  if (!numbersOutside) // Inside the board
                    Container(
                      decoration: widget.showCircle
                          ? BoxDecoration(
                        color: widget.circleColour ??
                            Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(size / 2),
                      )
                          : null,
                      child: FittedBox(
                        child: Center(
                          child: Text('$i', style: widget.textStyle),
                        ),
                      ),
                    ),
                  if (numbersOutside) // Outside the board
                    Positioned(
                      left: i % 8 == 0 ? -size : null,
                      right: i % 8 == 0 ? null : -size,
                      top: i ~/ 8 == 0 ? -size : null,
                      bottom: i ~/ 8 == 0 ? null : -size,
                      child: Container(
                        decoration: widget.showCircle
                            ? BoxDecoration(
                          color: widget.circleColour ??
                              Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(size / 2),
                        )
                            : null,
                        child: FittedBox(
                          child: Center(
                            child: Text('$i', style: widget.textStyle),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
