import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

class CustomPieceSet {
  static const List<String> defaultSymbols = ['P', 'N', 'B', 'R', 'Q', 'K'];
  final Map<String, WidgetBuilder> pieces;
  const CustomPieceSet({required this.pieces});

  Widget piece(BuildContext context, String symbol) => pieces[symbol]!(context);

  factory CustomPieceSet.fromSvgAssets({
    required String folder,
    String? package,
    required List<String> symbols,
    String format = 'svg',
    required String whitePrefix, // Prefix for white pieces
    required String blackPrefix,
  }) {
    Map<String, WidgetBuilder> pieces = {};
    for (String symbol in symbols) {
      pieces[symbol.toUpperCase()] = (BuildContext context) =>
          SvgPicture.asset('$folder${whitePrefix.toLowerCase()}$symbol.svg');
      pieces[symbol.toLowerCase()] = (BuildContext context) =>
          SvgPicture.asset('$folder${blackPrefix.toLowerCase()}$symbol.svg');
    }
    return CustomPieceSet(pieces: pieces);
  }
  factory CustomPieceSet.text({
    required Map<String, String> strings,
    TextStyle? style,
  }) {
    Map<String, WidgetBuilder> pieces = {};
    strings.forEach((k, v) {
      pieces[k] = (BuildContext context) => Text(v, style: style);
    });
    return CustomPieceSet(pieces: pieces);
  }
  // factory CustomPieceSet.custom() => CustomPieceSet.fromSvgAssets(
  //   folder: 'assets/images/',
  //   symbols: CustomPieceSet.defaultSymbols,
  // );
}





