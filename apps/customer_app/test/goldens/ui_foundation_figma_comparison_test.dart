import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<_ComparisonCase> cases = <_ComparisonCase>[
    const _ComparisonCase('08_home_light', '08-home-light.png'),
    const _ComparisonCase('08_home_dark', '08-home-dark.png'),
    const _ComparisonCase('09_catalog_light', '09-catalog-light.png'),
    const _ComparisonCase('09_catalog_dark', '09-catalog-dark.png'),
    const _ComparisonCase('15_orders_light', '15-orders-light.png'),
    const _ComparisonCase('15_orders_dark', '15-orders-dark.png'),
    const _ComparisonCase('19_account_light', '19-account-light.png'),
    const _ComparisonCase('19_account_dark', '19-account-dark.png'),
    const _ComparisonCase('20_states_light', '20-states-light.png'),
    const _ComparisonCase('20_states_dark', '20-states-dark.png'),
  ];

  for (final _ComparisonCase visualCase in cases) {
    test('${visualCase.name} keeps high visual agreement with Figma', () async {
      final _DecodedImage actual = await _decode(
        File('test/goldens/ui_foundation_${visualCase.name}.png'),
      );
      final _DecodedImage expected = await _decode(
        File(
          '../../docs/referencias-visuales/figma/10.01-10.03/'
          '${visualCase.referenceName}',
        ),
      );

      expect(actual.width, 390);
      expect(actual.height, 844);
      expect(expected.width, actual.width);
      expect(expected.height, actual.height);

      final _Similarity result = _compare(actual, expected);
      expect(
        result.meanChannelSimilarity,
        greaterThanOrEqualTo(0.97),
        reason:
            '${visualCase.name}: similitud media '
            '${result.meanChannelSimilarity.toStringAsFixed(4)}, '
            'píxeles dentro de tolerancia '
            '${result.tolerantPixelAgreement.toStringAsFixed(4)}',
      );
      expect(
        result.tolerantPixelAgreement,
        greaterThanOrEqualTo(0.94),
        reason:
            '${visualCase.name}: solo '
            '${result.tolerantPixelAgreement.toStringAsFixed(4)} '
            'de los píxeles difiere como máximo 32/255 por canal',
      );
    });
  }
}

class _ComparisonCase {
  const _ComparisonCase(this.name, this.referenceName);

  final String name;
  final String referenceName;
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
      if (!_insideRoundedViewport(x, y, actual.width, actual.height)) {
        continue;
      }
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
      if (maximumDifference <= 32) {
        tolerantPixels += 1;
      }
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
  if ((!left && !right) || (!top && !bottom)) {
    return true;
  }

  final int centerX = left ? radius : width - radius - 1;
  final int centerY = top ? radius : height - radius - 1;
  final int dx = x - centerX;
  final int dy = y - centerY;
  return dx * dx + dy * dy <= radius * radius;
}
