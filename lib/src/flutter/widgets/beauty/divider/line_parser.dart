import 'package:flutter/material.dart';
import 'package:unlimited_things_dart/unlimited_things_dart.dart';

class LineParser {
  final double _length;
  final double _startFrom;
  final double _strokeWidth;
  final double _gapWidth;
  final bool _fixTrimmedGap;
  final bool _fixTrimmedDash;
  final List<_LinePart> _parts = [];

  LineParser({
    required double length,
    required double startFrom,
    required double strokeWidth,
    required double gapWidth,
    bool fixTrimmedGap = true,
    bool fixTrimmedDash = true,
  })  : _length = length,
        _startFrom = startFrom,
        _strokeWidth = strokeWidth,
        _gapWidth = gapWidth,
        _fixTrimmedGap = fixTrimmedGap,
        _fixTrimmedDash = fixTrimmedDash,
        assert(length > 0 && length.isFinite),
        assert(startFrom >= 0),
        assert(strokeWidth > 0),
        assert(gapWidth > 0) {
    _parse();
  }

  double get length => _length;

  double get gapWidth => _gapWidth;

  double get strokeWidth => _strokeWidth;

  void _parse() {
    var startFrom = _startFrom;
    while (startFrom > length) {
      startFrom -= length;
    }
    while (startFrom < 0) {
      startFrom += length;
    }
    final fill = _fill(length - startFrom);
    if (startFrom > 0) {
      final trimResult = _trim(fill, length - startFrom);
      final trimmedLength = _getLength(trimResult);
      final fill2 = [
        ...trimResult,
        ..._fill(
          startFrom - trimmedLength,
          startFromStroke: trimResult.isEmpty || trimResult.last.isGap,
        ),
      ];
      _trim(fill2, startFrom);
      _parts.addAll([
        ...fill2,
        ...fill,
      ]);
    } else {
      _parts.addAll(fill);
    }
    return;
  }

  double _getLength(List<_LinePart> parts) => parts.fold<double>(
        0,
        (previousValue, element) => previousValue + element.length,
      );

  List<_LinePart> _fill(
    double length, {
    bool startFromStroke = true,
  }) {
    final result = <_LinePart>[];
    for (var parsed = 0.0;
        parsed < length;
        parsed += _strokeWidth + _gapWidth,) {
      result
        ..add(_LinePart(
          length: _strokeWidth,
          isGap: !startFromStroke,
        ))
        ..add(_LinePart(
          length: _gapWidth,
          isGap: startFromStroke,
        ));
    }
    return result;
  }

  List<_LinePart> _trim(
    List<_LinePart> source,
    final double length,
  ) {
    if (source.isEmpty) {
      return [];
    }
    final result = <_LinePart>[];
    var parsed = _getLength(source);
    while (parsed > length) {
      final over = parsed - length;
      final part = source.last;
      if (part.length > over) {
        result.add(_LinePart(length: over, isGap: part.isGap));
        break;
      } else {
        parsed -= part.length;
        source.removeLast();
        result.insert(0, part);
      }
    }
    if (result.isNotEmpty && source.isNotEmpty) {
      source.last = source.last + (length - parsed);
    }
    return result.reversed.toList();
  }

  void draw({
    DoubleConsumer2? forDash,
    DoubleConsumer2? forGap,
  }) {
    if (forDash == null && forGap == null) {
      return;
    }
    var currentLength = 0.0;
    for (final part in _parts) {
      if (part.isGap) {
        if (_fixTrimmedGap) {
          if (part == _parts.first && _parts.first.length < _gapWidth) {
            forGap?.call(
              currentLength - (_gapWidth - part.length),
              _gapWidth,
            );
          } else if (part == _parts.last && _parts.last.length < _gapWidth) {
            forGap?.call(
              currentLength,
              _gapWidth,
            );
          } else {
            forGap?.call(currentLength, part.length);
          }
        } else {
          forGap?.call(currentLength, part.length);
        }
      } else {
        if (_fixTrimmedDash) {
          if (part == _parts.first && _parts.first.length < _strokeWidth) {
            forDash?.call(
              currentLength - (_strokeWidth - part.length),
              _strokeWidth,
            );
          } else if (part == _parts.last && _parts.last.length < _strokeWidth) {
            forDash?.call(
              currentLength,
              _strokeWidth,
            );
          } else {
            forDash?.call(currentLength, part.length);
          }
        } else {
          forDash?.call(currentLength, part.length);
        }
      }
      currentLength += part.length;
    }
  }
}

@immutable
class _LinePart {
  final double length;
  final bool isGap;

  const _LinePart({
    required this.length,
    required this.isGap,
  });

  _LinePart operator +(double length) => _LinePart(
        length: this.length + length,
        isGap: isGap,
      );

  _LinePart operator -(double length) => _LinePart(
        length: this.length - length,
        isGap: isGap,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _LinePart && other.length == length && other.isGap == isGap;
  }

  @override
  int get hashCode => length.hashCode ^ isGap.hashCode;
}
