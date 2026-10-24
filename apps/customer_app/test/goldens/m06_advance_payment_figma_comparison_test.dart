import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final _VisualComparison visual in <_VisualComparison>[
    for (final String theme in <String>['light', 'dark']) ...<_VisualComparison>[
      _VisualComparison('14_advance_$theme', '14-$theme.png', 'm06_advance_14_advance_$theme.png'),
      _VisualComparison('17_status_$theme', '17-$theme.png', 'm06_payment_17_status_$theme.png'),
    ],
  ]) {
    test('${visual.name} keeps high agreement with Figma', () async {
      final File goldenFile = File('test/goldens/${visual.goldenFile}');
      if (!goldenFile.existsSync()) {
        fail('Golden file not found: ${visual.goldenFile}');
      }
      final _DecodedImage actual = await _decode(goldenFile);
      final _DecodedImage expected = await _decode(
        File('../../docs/referencias-visuales/figma/10.07/${visual.reference}'),
      );

      expect(actual.width, 390);
      expect(actual.height, 844);
      expect(expected.width, actual.width);
      expect(expected.height, actual.height);

      final _Similarity result = _compare(actual, expected);
      // ignore: avoid_print
      print(
        '${visual.name} similarity: mean=${result.meanChannelSimilarity.toStringAsFixed(6)}, tolerant=${result.tolerantPixelAgreement.toStringAsFixed(6)}',
      );
      expect(
        result.meanChannelSimilarity,
        greaterThanOrEqualTo(0.97),
        reason:
            '${visual.name}: similitud media '
            '${result.meanChannelSimilarity.toStringAsFixed(6)}, '
            'acuerdo tolerante '
            '${result.tolerantPixelAgreement.toStringAsFixed(6)}',
      );
      expect(
        result.tolerantPixelAgreement,
        greaterThanOrEqualTo(0.94),
        reason:
            '${visual.name}: solo '
            '${result.tolerantPixelAgreement.toStringAsFixed(6)} '
            'de los píxeles difiere como máximo 32/255 por canal',
      );
    });
  }
}

class _VisualComparison {
  const _VisualComparison(this.name, this.reference, this.goldenFile);

  final String name;
  final String reference;
  final String goldenFile;
}

class _DecodedImage {
  const _DecodedImage(this.width, this.height, this.rgba);

  final int width;
  final int height;
  final Uint8List rgba;
}

class _Similarity {
  const _Similarity(this.meanChannelSimilarity, this.tolerantPixelAgreement);

  final double meanChannelSimilarity;
  final double tolerantPixelAgreement;
}

Future<_DecodedImage> _decode(File file) async {
  final ui.Codec codec = await ui.instantiateImageCodec(
    await file.readAsBytes(),
  );
  final ui.FrameInfo frame = await codec.getNextFrame();
  final ui.Image image = frame.image;
  final ByteData data = (await image.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  ))!;
  final _DecodedImage decoded = _DecodedImage(
    image.width,
    image.height,
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
  image.dispose();
  codec.dispose();
  return decoded;
}

_Similarity _compare(_DecodedImage actual, _DecodedImage expected) {
  var absoluteDifference = 0;
  var comparedChannels = 0;
  var tolerantPixels = 0;
  var comparedPixels = 0;

  for (var y = 0; y < actual.height; y += 1) {
    for (var x = 0; x < actual.width; x += 1) {
      if (!_insideRoundedViewport(x, y, actual.width, actual.height)) continue;
      final int offset = (y * actual.width + x) * 4;
      var maximumDifference = 0;
      for (var channel = 0; channel < 3; channel += 1) {
        final int difference =
            (actual.rgba[offset + channel] - expected.rgba[offset + channel])
                .abs();
        absoluteDifference += difference;
        maximumDifference = difference > maximumDifference
            ? difference
            : maximumDifference;
        comparedChannels += 1;
      }
      if (maximumDifference <= 32) tolerantPixels += 1;
      comparedPixels += 1;
    }
  }

  return _Similarity(
    1 - absoluteDifference / (comparedChannels * 255),
    tolerantPixels / comparedPixels,
  );
}

bool _insideRoundedViewport(int x, int y, int width, int height) {
  const int radius = 25;
  final bool left = x < radius;
  final bool right = x >= width - radius;
  final bool top = y < radius;
  final bool bottom = y >= height - radius;
  if ((!left && !right) || (!top && !bottom)) return true;

  final int centerX = left ? radius : width - radius - 1;
  final int centerY = top ? radius : height - radius - 1;
  final int dx = x - centerX;
  final int dy = y - centerY;
  return dx * dx + dy * dy <= radius * radius;
}
