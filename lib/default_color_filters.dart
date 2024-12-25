import 'dart:ui';

import 'package:drawing_app/home.dart';

List<NamedColorFilter> defaultColorFilters = [
  NamedColorFilter(
      filter: const ColorFilter.matrix([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0]),
      id: "none",
      name: "None"),
  NamedColorFilter(
      filter:
          const ColorFilter.matrix([0.8, 0.1, 0.1, 0, 20, 0.1, 0.8, 0.1, 0, 20, 0.1, 0.1, 0.8, 0, 20, 0, 0, 0, 1, 0]),
      name: "Vintage",
      id: "vintage"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.2, 0.1, 0.1, 0, 10, 0.1, 1, 0.1, 0, 10, 0.1, 0.1, 1, 0, 10, 0, 0, 0, 1, 0]),
      name: 'Mood',
      id: "mood"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.2, 0, 0, 0, 0, 0, 1.2, 0, 0, 0, 0, 0, 1.2, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Crisp',
      id: "crisp"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([0.9, 0, 0.2, 0, 0, 0, 1, 0.1, 0, 0, 0.1, 0, 1.2, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Cool',
      id: "cool"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.1, 0.1, 0.1, 0, 10, 0.1, 1, 0.1, 0, 10, 0.1, 0.1, 1, 0, 5, 0, 0, 0, 1, 0]),
      name: 'Blush',
      id: "blush"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.3, 0, 0.1, 0, 15, 0, 1.1, 0.1, 0, 10, 0, 0, 0.9, 0, 5, 0, 0, 0, 1, 0]),
      name: 'Sunkissed',
      id: "sunkissed"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.2, 0, 0, 0, 20, 0, 1.2, 0, 0, 20, 0, 0, 1.1, 0, 20, 0, 0, 0, 1, 0]),
      name: 'Fresh',
      id: "fresh"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.1, 0, -0.1, 0, 10, -0.1, 1.1, 0.1, 0, 5, 0, -0.1, 1.1, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Classic',
      id: "classic"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.5, 0, 0.1, 0, 0, 0, 1.45, 0, 0, 0, 0.1, 0, 1.3, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Lomo-ish',
      id: "lomoish"),
  NamedColorFilter(
      filter:
          const ColorFilter.matrix([1.2, 0.15, -0.15, 0, 15, 0.1, 1.1, 0.1, 0, 10, -0.05, 0.2, 1.25, 0, 5, 0, 0, 0, 1, 0]),
      name: 'Nashville',
      id: "nashville"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.15, 0.1, 0.1, 0, 20, 0.1, 1.1, 0, 0, 10, 0.1, 0.1, 1.2, 0, 5, 0, 0, 0, 1, 0]),
      name: 'Valencia',
      id: "valencia"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.2, 0, 0, 0, 10, 0, 1.25, 0, 0, 10, 0, 0, 1.3, 0, 10, 0, 0, 0, 1, 0]),
      name: 'Clarendon',
      id: "claredon"),
  NamedColorFilter(
      filter:
          const ColorFilter.matrix([0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Moon',
      id: "moon"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([0.5, 0.5, 0.5, 0, 20, 0.5, 0.5, 0.5, 0, 20, 0.5, 0.5, 0.5, 0, 20, 0, 0, 0, 1, 0]),
      name: 'Willow',
      id: "willow"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.3, 0.1, -0.1, 0, 10, 0, 1.25, 0.1, 0, 10, 0, -0.1, 1.1, 0, 5, 0, 0, 0, 1, 0]),
      name: 'Kodak',
      id: "kodak"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([0.8, 0.2, 0.1, 0, 0, 0.2, 1.1, 0.1, 0, 0, 0.1, 0.1, 1.2, 0, 10, 0, 0, 0, 1, 0]),
      name: 'Frost',
      id: "frost"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([0.1, 0.95, 0.2, 0, 0, 0.1, 1.5, 0.1, 0, 0, 0.2, 0.7, 0, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Night Vision',
      id: "nightvision"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.5, 0.2, 0, 0, 0, 0.1, 0.9, 0.1, 0, 0, -0.1, -0.2, 1.3, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Sunset',
      id: "sunset"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.3, -0.3, 0.1, 0, 0, -0.1, 1.2, -0.1, 0, 0, 0.1, -0.2, 1.3, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Noir',
      id: "noir"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.1, 0.1, 0.1, 0, 0, 0.1, 1.1, 0.1, 0, 0, 0.1, 0.1, 1.1, 0, 15, 0, 0, 0, 1, 0]),
      name: 'Dreamy',
      id: "dreamy"),
  NamedColorFilter(
      filter: const ColorFilter.matrix(
          [0.393, 0.769, 0.189, 0, 0, 0.349, 0.686, 0.168, 0, 0, 0.272, 0.534, 0.131, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Sepia',
      id: "sepia"),
  NamedColorFilter(
      filter: const ColorFilter.matrix(
          [1.438, -0.062, -0.062, 0, 0, -0.122, 1.378, -0.122, 0, 0, -0.016, -0.016, 1.483, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Radium',
      id: "radium"),
  NamedColorFilter(
      filter: const ColorFilter.matrix(
          [0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0.7873, 0.2848, 0.9278, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Aqua',
      id: "aqua"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.3, 0, 1.2, 0, 0, 0, 1.1, 0, 0, 0, 0.2, 0, 1.3, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Purple Haze',
      id: "purplehaze"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.2, 0.1, 0, 0, 0, 0, 1.1, 0.2, 0, 0, 0.1, 0, 0.7, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Lemonade',
      id: "lemonade"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.6, 0.2, 0, 0, 0, 0.1, 1.3, 0.1, 0, 0, 0, 0.1, 0.9, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Caramel',
      id: "caramel"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.3, 0.5, 0, 0, 0, 0.2, 1.1, 0.3, 0, 0, 0.1, 0.1, 1.2, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Peachy',
      id: "peachy"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([0.8, 0.2, 0.5, 0, 0, 0.1, 1.2, 0.1, 0, 0, 0.3, 0.1, 1.7, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Cool Blue',
      id: "coolblue"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([0.5, 0, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Contrast',
      id: "contrast"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Neon',
      id: "neon"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([0.9, 0.1, 0.2, 0, 0, 0, 1, 0.1, 0, 0, 0.1, 0, 1.2, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Cold Morning',
      id: "coldmorning"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([0.9, 0.2, 0, 0, 0, 0, 1.2, 0, 0, 0, 0, 0, 1.1, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Lush',
      id: "lush"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([1.1, 0, 0.3, 0, 0, 0, 0.9, 0.3, 0, 0, 0.3, 0.1, 1.2, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Urban Neon',
      id: "urbanneon"),
  NamedColorFilter(
      filter: const ColorFilter.matrix([0.6, 0.2, 0.2, 0, 0, 0.2, 0.6, 0.2, 0, 0, 0.2, 0.2, 0.7, 0, 0, 0, 0, 0, 1, 0]),
      name: 'Moody Monochrome',
      id: "moodymonochrome"),
];
