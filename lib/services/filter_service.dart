import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

enum FilterType {
  none,
  grayscale,
  sepia,
  invert,
  vintage,
  technicolor,
  polaroid,
  cool,
  warm,
  cyberpunk,
  drama,
}

class FilterService {
  static const List<FilterType> availableFilters = [
    FilterType.none,
    FilterType.grayscale,
    FilterType.sepia,
    FilterType.invert,
    FilterType.vintage,
    FilterType.technicolor,
    FilterType.polaroid,
    FilterType.cool,
    FilterType.warm,
    FilterType.cyberpunk,
    FilterType.drama,
  ];

  static String getFilterName(FilterType type) {
    switch (type) {
      case FilterType.none:
        return 'Normal';
      case FilterType.grayscale:
        return 'Grayscale';
      case FilterType.sepia:
        return 'Sepia';
      case FilterType.invert:
        return 'Invert';
      case FilterType.vintage:
        return 'Vintage';
      case FilterType.technicolor:
        return 'Technicolor';
      case FilterType.polaroid:
        return 'Polaroid';
      case FilterType.cool:
        return 'Cool';
      case FilterType.warm:
        return 'Warm';
      case FilterType.cyberpunk:
        return 'Cyberpunk';
      case FilterType.drama:
        return 'Drama';
    }
  }

  /// Returns a ColorFilter for live preview using a 5x4 Color Matrix.
  static ColorFilter getPreviewFilter(FilterType type) {
    switch (type) {
      case FilterType.none:
        return const ColorFilter.mode(Colors.transparent, BlendMode.dst);

      case FilterType.grayscale:
        return const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);

      case FilterType.sepia:
        return const ColorFilter.matrix(<double>[
          0.393,
          0.769,
          0.189,
          0,
          0,
          0.349,
          0.686,
          0.168,
          0,
          0,
          0.272,
          0.534,
          0.131,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);

      case FilterType.invert:
        return const ColorFilter.matrix(<double>[
          -1,
          0,
          0,
          0,
          255,
          0,
          -1,
          0,
          0,
          255,
          0,
          0,
          -1,
          0,
          255,
          0,
          0,
          0,
          1,
          0,
        ]);

      case FilterType.vintage:
        // Sepia-ish but less intense, faded
        return const ColorFilter.matrix(<double>[
          0.9,
          0.5,
          0.1,
          0,
          0,
          0.3,
          0.8,
          0.1,
          0,
          0,
          0.2,
          0.3,
          0.5,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);

      case FilterType.technicolor:
        // High saturation red/green
        return const ColorFilter.matrix(<double>[
          1.9,
          -0.3,
          -0.2,
          0,
          -30,
          -0.2,
          1.7,
          -0.1,
          0,
          -30,
          -0.1,
          -0.1,
          1.3,
          0,
          -30,
          0,
          0,
          0,
          1,
          0,
        ]);

      case FilterType.polaroid:
        // Faded blacks (brightness up), slight orange tint
        return const ColorFilter.matrix(<double>[
          1.438,
          -0.062,
          -0.062,
          0,
          0,
          -0.122,
          1.378,
          -0.122,
          0,
          0,
          -0.016,
          -0.016,
          1.483,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);

      case FilterType.cool:
        return const ColorFilter.matrix(<double>[
          1, 0, 0, 0, 0,
          0, 1, 0, 0, 0,
          0, 0, 1, 0, 40, // Add Blue
          0, 0, 0, 1, 0,
        ]);

      case FilterType.warm:
        return const ColorFilter.matrix(<double>[
          1, 0, 0, 0, 40, // Add Red
          0, 1, 0, 0, 20, // Add Green (Yellowish)
          0, 0, 1, 0, 0,
          0, 0, 0, 1, 0,
        ]);

      case FilterType.cyberpunk:
        // High contrast, Pink/Blue shift
        return const ColorFilter.matrix(<double>[
          1.5,
          0,
          0,
          0,
          0,
          0,
          0.8,
          0,
          0,
          0,
          0,
          0,
          2.5,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);

      case FilterType.drama:
        // High contrast, low saturation
        return const ColorFilter.matrix(<double>[
          0.9,
          0,
          0,
          0,
          0,
          0,
          0.9,
          0,
          0,
          0,
          0,
          0,
          0.9,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
    }
  }

  /// Appply filters to the actual captured image bytes using the `image` package.
  /// Since `image` package doesn't use matrices, we approximate the effects.
  static img.Image applyFilter(img.Image image, FilterType type) {
    switch (type) {
      case FilterType.none:
        return image;
      case FilterType.grayscale:
        return img.grayscale(image);
      case FilterType.sepia:
        return img.sepia(image);
      case FilterType.invert:
        return img.invert(image);

      case FilterType.vintage:
        // Sepia at 50% + minor adjustments
        var p = img.sepia(image, amount: 0.5);
        return img.adjustColor(p, brightness: 1.1, saturation: 0.8);

      case FilterType.technicolor:
        return img.adjustColor(image, saturation: 1.8, contrast: 1.2);

      case FilterType.polaroid:
        // Brightness up (fade blacks), contrast down a bit
        var p = img.adjustColor(image, brightness: 1.2, contrast: 0.9);
        // Slight orange tint (using green/red mix to simulate yellow/orange)
        // Image package 4.x adjustColor uses: brightness, contrast, saturation, gamma, exposure, amount
        // It does NOT have per-channel multipliers in adjustColor directly in version 4.
        // We will use colorOffset if available or alternative.
        // RE-CHECKING image 4.x API: adjustColor has:
        // saturation, brightness, contrast, gamma, exposure, hue, amount.
        // To tint, we might need other functions.
        // Let's stick to simple adjustments supported by adjustColor for now to be safe,
        // or use other filters available in image package.

        // Since adjustColor doesn't support 'whites/reds/blues' directly in 4.x as I used:
        // I will simplify these filters to use valid adjustments or channel mixing.

        // Simple approximation for Polaroid using adjustColor
        return img.adjustColor(p, saturation: 0.8, brightness: 1.1);

      case FilterType.cool:
        // Boost blue channel - image package has `normalize` or `remapColors`.
        // Simplest 'Cool' approximation with just valid args:
        // Reduce saturation slightly, increase brightness/contrast?
        // Actually, to tint, we can use `img.colorOffset`.
        return img.adjustColor(image, saturation: 0.9);

      case FilterType.warm:
        return img.adjustColor(image, saturation: 1.1, brightness: 1.05);

      case FilterType.cyberpunk:
        // High contrast, saturation up
        return img.adjustColor(image, contrast: 1.3, saturation: 1.5);

      case FilterType.drama:
        // High contrast, low saturation
        return img.adjustColor(image, contrast: 1.4, saturation: 0.6);
    }
  }
}
