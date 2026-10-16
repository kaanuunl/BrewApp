import 'package:flutter/material.dart';

import '../models/brew_method.dart';

class BrewMethodsData {
  BrewMethodsData._();

  static const List<BrewMethod> all = [
    BrewMethod(
      id: 'espresso',
      name: 'Espresso',
      subtitle: 'Pressure-brewed, rich, and silky',
      description: 'A concentrated drink brewed by forcing water through a fine coffee bed. Adjust the dose-to-yield ratio to suit the coffee, basket, and machine.',
      icon: Icons.local_cafe,
      ratio: 2.0,
      ratioOutputLabel: 'Espresso yield',
      ratioOutputUnit: 'g',
      defaultCoffeeGrams: 18,
      grindSize: 'Fine; adjust to the flow and basket',
      waterTempC: 93,
      bloomSeconds: 0,
      totalTimeSeconds: 53,
      difficulty: Difficulty.zor,
      steps: [
        BrewStep(
          title: 'Dose',
          description: 'Weigh 18 g of coffee and add it to the portafilter.',
          durationSeconds: 10,
        ),
        BrewStep(
          title: 'Distribute and tamp',
          description:
              'Distribute the coffee evenly in the basket and tamp the bed level.',
          durationSeconds: 15,
        ),
        BrewStep(
          title: 'Extraction',
          description: 'Watch the flow; use about 36 g of espresso yield as a starting target for an 18 g dose.',
          durationSeconds: 28,
        ),
      ],
      tips: [
        'A 1:2 dose-to-yield ratio and a 25–30 second shot time are starting points, not universal rules.',
        'If the flow is too fast, try a finer grind; if it is too slow, try a coarser grind.',
        'Track yield in grams on a scale, not by cup volume. Espresso yield is not the amount of water entering the basket.',
        'Adjust water temperature and pressure profile to the machine, coffee, and roast.',
      ],
    ),
    BrewMethod(
      id: 'v60',
      name: 'V60 (Pour Over)',
      subtitle: 'Clean, bright pour-over coffee',
      description: 'A manual pour-over method using a cone-shaped dripper and paper filter. Grind, pouring technique, and filter choice affect flow rate and clarity.',
      icon: Icons.filter_alt,
      ratio: 16.0,
      defaultCoffeeGrams: 20,
      grindSize: 'Medium-fine (like granulated sugar)',
      waterTempC: 94,
      bloomSeconds: 45,
      totalTimeSeconds: 180,
      difficulty: Difficulty.orta,
      steps: [
        BrewStep(
          title: 'Rinse the filter',
          description: 'Rinse the paper filter with hot water and discard the rinse water.',
          durationSeconds: 20,
        ),
        BrewStep(
          title: 'Bloom',
          description: 'Pour 2–3 times the coffee dose in water and wait 45 seconds.',
          durationSeconds: 45,
        ),
        BrewStep(
          title: 'Main pour',
          description: 'Slowly add the water in circular motions.',
          durationSeconds: 60,
        ),
        BrewStep(
          title: 'Drawdown',
          description: 'Wait for all the water to drain through.',
          durationSeconds: 55,
        ),
      ],
      tips: [
        'A 1:15–1:17 ratio, 92–96 °C water, and 2:30–3:00 total brew time are starting ranges for this dose; adjust to flow and taste.',
        'Use about 2–3 times the coffee dose in water for the bloom, wetting the bed evenly.',
        'Keep pour height and agitation consistent; excessive agitation can disturb the bed and extend drawdown.',
        'If the flow is outside your target, make small adjustments to grind and pouring technique first.',
      ],
    ),
    BrewMethod(
      id: 'chemex',
      name: 'Chemex',
      subtitle: 'Larger batches with a silky body',
      description: 'A glass brewer using thick paper filters. It produces a very clean, tea-like cup and works well for brewing several servings.',
      icon: Icons.local_drink,
      ratio: 15.0,
      defaultCoffeeGrams: 30,
      grindSize: 'Medium-coarse (like sea salt)',
      waterTempC: 94,
      bloomSeconds: 45,
      totalTimeSeconds: 240,
      difficulty: Difficulty.orta,
      steps: [
        BrewStep(
          title: 'Rinse the filter',
          description: 'Rinse the filter with hot water and discard the water.',
          durationSeconds: 20,
        ),
        BrewStep(
          title: 'Bloom',
          description: 'Add 2–3 times the coffee dose in water and wait 45 seconds.',
          durationSeconds: 45,
        ),
        BrewStep(
          title: 'Pours',
          description: 'Add the water in 3–4 circular pours.',
          durationSeconds: 120,
        ),
        BrewStep(
          title: 'Drawdown',
          description: 'Wait for the water to drain completely, then serve.',
          durationSeconds: 55,
        ),
      ],
      tips: [
        'Thick filters reduce fines and oils in the cup. Rinse the filter thoroughly and position it so it does not block the spout.',
        'A 1:15 ratio and about 4 minutes are starting points for this dose; larger Chemex batches may take longer.',
        'Wet the bed evenly without allowing the water level to rise too high between pours.',
      ],
    ),
    BrewMethod(
      id: 'aeropress',
      name: 'AeroPress',
      subtitle: 'Fast, flexible, and portable',
      description: 'A manual immersion brewer with a paper or metal filter. Recipes vary widely in water volume, steep time, grind, and pressing technique.',
      icon: Icons.coffee,
      ratio: 13.0,
      defaultCoffeeGrams: 15,
      grindSize: 'Fine (like table salt)',
      waterTempC: 88,
      bloomSeconds: 0,
      totalTimeSeconds: 120,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(
          title: 'Coffee and water',
          description:
              'Add 195 ml of water to 15 g of coffee and stir to wet it evenly.',
          durationSeconds: 30,
        ),
        BrewStep(
          title: 'Steep',
          description: 'Steep for 60 seconds in this starter recipe; other recipes may use longer steep times.',
          durationSeconds: 60,
        ),
        BrewStep(
          title: 'Press',
          description: 'Press slowly for 30 seconds.',
          durationSeconds: 30,
        ),
      ],
      tips: [
        'A 1:13 ratio and 88 °C are starting values for this short recipe; there is no single AeroPress standard.',
        'Press with control. If there is excessive resistance or a blockage, stop and release pressure safely.',
        'Turning over a filled brewer in the inverted method risks spills and burns; follow the manufacturer instructions.',
        'Paper filters produce a cleaner cup; metal filters may let more oils and particles through.',
      ],
    ),
    BrewMethod(
      id: 'frenchpress',
      name: 'French Press',
      subtitle: 'Full-bodied with a rich texture',
      description: 'An immersion method. The metal filter allows oils through, creating a fuller, richer body.',
      icon: Icons.soup_kitchen,
      ratio: 16.0,
      defaultCoffeeGrams: 30,
      grindSize: 'Coarse (between sea salt and hazelnut-sized)',
      waterTempC: 94,
      bloomSeconds: 0,
      totalTimeSeconds: 260,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(
          title: 'Coffee and water',
          description: 'Add 480 ml of water to 30 g of coffee.',
          durationSeconds: 20,
        ),
        BrewStep(
          title: 'Steep',
          description: 'Steep for 4 minutes without unnecessarily disturbing the coffee bed.',
          durationSeconds: 220,
        ),
        BrewStep(
          title: 'Press and serve',
          description: 'Lower the plunger slowly and transfer the coffee to a serving vessel.',
          durationSeconds: 20,
        ),
      ],
      tips: [
        'A 1:16 ratio, about 94 °C water, and a 4-minute steep are starting points for this recipe.',
        'A coarse grind and slowly lowering the plunger can help reduce fines in the cup.',
        'For a cleaner cup, transfer the coffee to a serving vessel instead of leaving it in the press.',
      ],
    ),
    BrewMethod(
      id: 'moka',
      name: 'Moka Pot',
      subtitle: 'Stovetop coffee with espresso-like intensity',
      description: 'A stovetop brewer in which pressure from heated water carries coffee into the upper chamber. It does not produce the same pressure or beverage profile as an espresso machine.',
      icon: Icons.kitchen,
      ratio: 8.0,
      defaultCoffeeGrams: 18,
      grindSize: 'Fine (between espresso and medium)',
      waterTempC: 95,
      bloomSeconds: 0,
      totalTimeSeconds: 300,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(
          title: 'Add water',
          description: 'Fill the lower chamber with water up to the valve.',
          durationSeconds: 20,
        ),
        BrewStep(
          title: 'Add coffee',
          description: 'Fill the basket with coffee and level it without tamping.',
          durationSeconds: 20,
        ),
        BrewStep(
          title: 'Brew on the stovetop',
          description: 'Heat over medium-low and wait for the coffee to flow.',
          durationSeconds: 240,
        ),
        BrewStep(
          title: 'Serve',
          description: 'Remove from the heat when the flow first begins to sputter.',
          durationSeconds: 20,
        ),
      ],
      tips: [
        'Fill the basket to its capacity and level the surface; do not tamp. The water ratio depends on the chamber and basket size.',
        'If using hot water, hold the lower chamber with a cloth and keep water off the threads. Follow the manufacturer instructions.',
        'Brew over medium-low heat and remove from the heat when the flow turns pale and begins to sputter.',
        'Never block or cover the safety valve with water.',
      ],
    ),
    BrewMethod(
      id: 'turkish',
      name: 'Turkish Coffee',
      subtitle: 'Traditional, unfiltered, and foamy',
      description: 'A traditional method brewed in a cezve with very finely ground coffee. The result is rich and topped with foam.',
      icon: Icons.emoji_food_beverage,
      ratio: 10.0,
      defaultCoffeeGrams: 7,
      grindSize: 'Powder-fine (the finest grind)',
      waterTempC: 93,
      bloomSeconds: 0,
      totalTimeSeconds: 240,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(
          title: 'Measure and stir',
          description: 'For a small cup, combine 7 g of very finely ground coffee with 70 ml of cold water in a cezve; sugar is optional.',
          durationSeconds: 30,
        ),
        BrewStep(
          title: 'Heat gently',
          description: 'Heat over low to medium until foam forms. Remove the cezve before it boils vigorously or overflows.',
          durationSeconds: 180,
        ),
        BrewStep(
          title: 'Divide the foam',
          description: 'Spoon the foam into the cup, pour in the remaining coffee slowly, and briefly wait for the grounds to settle.',
          durationSeconds: 30,
        ),
      ],
      tips: [
        '7 g per 70 ml is an example for a small cup; adjust to cup size and taste.',
        'Remove the cezve from the heat as the foam rises. Repeated boiling is unnecessary and may affect the flavor.',
        'If using sugar, add it at the beginning and dissolve it to taste.',
      ],
    ),
    BrewMethod(
      id: 'kalita',
      name: 'Kalita Wave',
      subtitle: 'Flat-bottom filter brewing',
      description:
          'A manual pour-over brewed with a flat-bottom basket and ridged filter. The number of holes, filter bed, and pouring technique affect flow.',
      icon: Icons.filter_alt_outlined,
      ratio: 16.0,
      defaultCoffeeGrams: 20,
      grindSize: 'Medium (adjust to flow)',
      waterTempC: 93,
      bloomSeconds: 40,
      totalTimeSeconds: 210,
      difficulty: Difficulty.orta,
      steps: [
        BrewStep(
          title: 'Set the filter',
          description: 'Place the Wave filter in the dripper and rinse it with hot water.',
          durationSeconds: 20,
        ),
        BrewStep(
          title: 'Bloom',
          description: 'Evenly wet the bed with about 2–3 times the coffee dose in water.',
          durationSeconds: 40,
        ),
        BrewStep(
          title: 'Pours',
          description: 'Add the water in two or three controlled pours.',
          durationSeconds: 90,
        ),
        BrewStep(
          title: 'Drawdown',
          description: 'When the flow finishes, remove the dripper and serve.',
          durationSeconds: 60,
        ),
      ],
      tips: [
        'A 1:16 ratio, 93 °C, and about 3:30 are starting parameters for this dose; adjust to the filter, grind, and taste.',
        'Do not crush the filter or block its ridges; avoid channeling water around the coffee bed.',
        'If the flow is slow, grind slightly coarser; if it is very fast, grind slightly finer.',
      ],
    ),
    BrewMethod(
      id: 'clever',
      name: 'Clever Dripper',
      subtitle: 'Immersion with filtered drawdown',
      description:
          'An immersion method that steeps coffee in a valve-equipped dripper, then drains when placed over a cup or carafe.',
      icon: Icons.coffee_maker_outlined,
      ratio: 16.0,
      defaultCoffeeGrams: 18,
      grindSize: 'Medium (similar to drip coffee)',
      waterTempC: 93,
      bloomSeconds: 0,
      totalTimeSeconds: 240,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(
          title: 'Filter and coffee',
          description: 'Rinse the filter and add 18 g of coffee to the Clever Dripper.',
          durationSeconds: 20,
        ),
        BrewStep(
          title: 'Add water',
          description: 'Add 288 ml of water and wet the entire bed.',
          durationSeconds: 20,
        ),
        BrewStep(
          title: 'Steep',
          description: 'Cover and steep for 2 minutes, then stir gently.',
          durationSeconds: 150,
        ),
        BrewStep(
          title: 'Drawdown',
          description: 'Place the dripper over a cup and wait for it to drain completely.',
          durationSeconds: 50,
        ),
      ],
      tips: [
        'A 1:16 ratio and 4 minutes are for this example recipe; adjust steep time and grind to taste.',
        'Keep the valve closed during steeping and handle hot liquid carefully.',
        'Rinsing the paper filter first can help reduce papery flavors.',
      ],
    ),
    BrewMethod(
      id: 'siphon',
      name: 'Siphon',
      subtitle: 'A theatrical vacuum brewer',
      description:
          'A vacuum brewer in which heated water rises to the upper chamber and returns through a filter to the lower chamber after brewing.',
      icon: Icons.science_outlined,
      ratio: 15.0,
      defaultCoffeeGrams: 20,
      grindSize: 'Medium (adjust to flow)',
      waterTempC: 92,
      bloomSeconds: 0,
      totalTimeSeconds: 240,
      difficulty: Difficulty.zor,
      steps: [
        BrewStep(
          title: 'Set up',
          description: 'Secure the filter, add water to the lower chamber, and set the brewer on a level surface.',
          durationSeconds: 30,
        ),
        BrewStep(
          title: 'Raise the water',
          description: 'Heat the water; when it rises to the upper chamber, safely reduce the heat.',
          durationSeconds: 30,
        ),
        BrewStep(
          title: 'Brew',
          description: 'Add 20 g of coffee, stir gently, and steep for about 90 seconds.',
          durationSeconds: 90,
        ),
        BrewStep(
          title: 'Draw down',
          description: 'Turn off the heat and wait for the coffee to return through the filter to the lower chamber.',
          durationSeconds: 60,
        ),
        BrewStep(
          title: 'Serve',
          description: 'Once the glass cools, carefully separate the parts and serve.',
          durationSeconds: 30,
        ),
      ],
      tips: [
        'Protect the glass from thermal shock. Do not use cracked glass or place hot glass on a cold surface.',
        'A 1:15 ratio and about 4 minutes are starting values for this example recipe.',
        'Follow the manufacturer instructions and fire or electrical safety guidance when using the heater.',
      ],
    ),
    BrewMethod(
      id: 'phin',
      name: 'Vietnam Phin',
      subtitle: 'Slow drip through a metal filter',
      description:
          'A Vietnamese method that slowly brews coffee with hot water in a small metal filter. Serve black or with condensed milk.',
      icon: Icons.local_cafe_outlined,
      ratio: 10.0,
      defaultCoffeeGrams: 18,
      grindSize: 'Medium-fine (adjust to the filter)',
      waterTempC: 92,
      bloomSeconds: 30,
      totalTimeSeconds: 300,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(
          title: 'Warm the Phin and cup',
          description: 'Rinse the filter components and cup with hot water.',
          durationSeconds: 20,
        ),
        BrewStep(
          title: 'Add the coffee',
          description: 'Add 18 g of coffee, level it, and gently place the press plate.',
          durationSeconds: 20,
        ),
        BrewStep(
          title: 'Pre-wet',
          description: 'Pour in about 30 ml of hot water and let the coffee swell.',
          durationSeconds: 30,
        ),
        BrewStep(
          title: 'Brew',
          description: 'Slowly add the remaining water and wait for the dripping to finish.',
          durationSeconds: 210,
        ),
        BrewStep(
          title: 'Serve',
          description: 'Serve black or with milk, if desired.',
          durationSeconds: 20,
        ),
      ],
      tips: [
        'A 1:10 ratio and about 5 minutes apply to this example recipe using 180 ml of water.',
        'If the flow stops, loosen the press plate or grind coarser; if it is too fast, grind finer.',
        'Milk and sugar are optional; traditional serving preferences vary by region and person.',
      ],
    ),
    BrewMethod(
      id: 'batchbrew',
      name: 'Batch Brew',
      subtitle: 'Automatic drip coffee maker',
      description:
          'The machine showerhead distributes water over a coffee bed in a paper filter. Basket shape, dose, and batch size affect even wetting and flow time.',
      icon: Icons.coffee_maker_outlined,
      ratio: 16.0,
      defaultCoffeeGrams: 30,
      grindSize: 'Medium (adjust to the machine filter)',
      waterTempC: 93,
      bloomSeconds: 0,
      totalTimeSeconds: 300,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(
          title: 'Filter and carafe',
          description: 'Insert the paper filter and check that the carafe and basket are clean.',
          durationSeconds: 30,
        ),
        BrewStep(
          title: 'Measure the coffee',
          description: 'Weigh 30 g of coffee and 480 ml of water as a starting recipe.',
          durationSeconds: 30,
        ),
        BrewStep(
          title: 'Brew',
          description: 'Start the machine and check that the bed is wetted evenly and the flow is consistent.',
          durationSeconds: 210,
        ),
        BrewStep(
          title: 'Serve',
          description: 'When brewing is complete, stir the coffee and serve.',
          durationSeconds: 30,
        ),
      ],
      tips: [
        'A 1:16 ratio and medium grind are starting points for a 30 g dose; adjust to the machine and batch size.',
        'Clean and descale the coffee maker according to the manufacturer instructions.',
        'Leaving brewed coffee on the hot plate for a long time may affect its flavor.',
      ],
    ),
    BrewMethod(
      id: 'switch',
      name: 'Hario Switch',
      subtitle: 'Immersion with controlled drawdown',
      description:
          'Steep coffee and water together with the valve closed, then open the valve to drain through the paper filter. Steep time and pour can be adjusted separately.',
      icon: Icons.water_drop_outlined,
      ratio: 16.0,
      defaultCoffeeGrams: 18,
      grindSize: 'Medium (for immersion)',
      waterTempC: 93,
      bloomSeconds: 30,
      totalTimeSeconds: 180,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(
          title: 'Rinse the filter',
          description: 'Insert and rinse the paper filter with hot water; keep the valve closed.',
          durationSeconds: 20,
        ),
        BrewStep(
          title: 'Add coffee and water',
          description: 'Add 288 ml of water to 18 g of coffee and wet the entire bed.',
          durationSeconds: 30,
        ),
        BrewStep(
          title: 'Steep',
          description: 'Steep the coffee for about 2 minutes with the valve closed.',
          durationSeconds: 90,
        ),
        BrewStep(
          title: 'Draw down and serve',
          description: 'Open the valve and remove the dripper when the flow finishes.',
          durationSeconds: 40,
        ),
      ],
      tips: [
        'A 1:16 ratio and medium grind are repeatable starting points; grind slightly coarser for a cleaner cup.',
        'When you open the valve affects total contact time; keep this step consistent between trials.',
        'Use a stable, heat-resistant surface when handling hot equipment.',
      ],
    ),
    BrewMethod(
      id: 'origami',
      name: 'Origami Dripper',
      subtitle: 'A cone-shaped dripper for varied pouring styles',
      description:
          'A ridged ceramic dripper that can be used with cone or flat-bottom filters. Filter shape and pouring technique change bed drainage.',
      icon: Icons.filter_alt_outlined,
      ratio: 16.0,
      defaultCoffeeGrams: 20,
      grindSize: 'Medium-fine (adjust to filter and flow)',
      waterTempC: 93,
      bloomSeconds: 40,
      totalTimeSeconds: 180,
      difficulty: Difficulty.orta,
      steps: [
        BrewStep(
          title: 'Set the filter',
          description: 'Place the filter in the dripper according to its shape and rinse it.',
          durationSeconds: 20,
        ),
        BrewStep(
          title: 'Bloom',
          description: 'Wet the bed evenly with 2–3 times the coffee dose in water.',
          durationSeconds: 40,
        ),
        BrewStep(
          title: 'Controlled pours',
          description: 'Add the remaining water in steady, gentle pours without overflowing the bed.',
          durationSeconds: 80,
        ),
        BrewStep(
          title: 'Drawdown',
          description: 'Wait for the flow to finish, then serve.',
          durationSeconds: 40,
        ),
      ],
      tips: [
        'A 1:16 ratio, 93 °C, and a medium-fine grind are starting points for this dose; adjust the grind to filter shape and flow.',
        'A faster-flowing filter may need a slightly finer grind; one recipe will not produce the same results with every filter.',
        'Keep pour height and speed consistent to compare trials.',
      ],
    ),
    BrewMethod(
      id: 'colddrip',
      name: 'Cold Drip',
      subtitle: 'Cold water slowly dripping through a coffee bed',
      description:
          'Cold water drips from a reservoir through the coffee bed into a carafe. Drip rate, grind, bed preparation, and brewer design determine the total time.',
      icon: Icons.ac_unit,
      ratio: 10.0,
      defaultCoffeeGrams: 50,
      grindSize: 'Medium-coarse (adjust to drip rate)',
      waterTempC: 8,
      bloomSeconds: 0,
      totalTimeSeconds: 14400,
      difficulty: Difficulty.orta,
      steps: [
        BrewStep(
          title: 'Prepare the equipment',
          description: 'Set up clean cold-drip equipment and distribute the coffee bed evenly.',
          durationSeconds: 60,
        ),
        BrewStep(
          title: 'Set the drip rate',
          description: 'Use 500 ml of cold drinking water and check that the drips wet the bed without channeling.',
          durationSeconds: 120,
        ),
        BrewStep(
          title: 'Brew slowly',
          description: 'Monitor the flow for an initial brew time of about 4 hours; adjust for your equipment.',
          durationSeconds: 14100,
        ),
        BrewStep(
          title: 'Serve and store',
          description: 'Store chilled in a clean container. If concentrated, dilute with water to taste before serving.',
          durationSeconds: 120,
        ),
      ],
      tips: [
        'A 1:10 ratio and 4 hours are starting points for this example dose; some brewers take considerably longer.',
        'Very fast dripping can reduce contact time, while very slow dripping can stop the flow. Adjust grind and valve separately.',
        'Keep equipment clean and maintain cold, covered conditions during brewing and storage.',
      ],
    ),
    BrewMethod(
      id: 'coldbrew',
      name: 'Cold Brew',
      subtitle: 'Smooth, cold-steeped coffee',
      description: 'Coarse coffee steeped in cold water for an extended period. Results vary with the coffee, ratio, time, temperature, and filtration; it can be made as a concentrate or ready to drink.',
      icon: Icons.ac_unit,
      ratio: 6.0,
      defaultCoffeeGrams: 80,
      grindSize: 'Very coarse (hazelnut-sized)',
      waterTempC: 20,
      bloomSeconds: 0,
      totalTimeSeconds: 43350,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(
          title: 'Coffee and cold water',
          description: 'Combine 80 g of coarse coffee with 480 ml of drinking water and make sure all the grounds are wet.',
          durationSeconds: 30,
        ),
        BrewStep(
          title: 'Steep cold',
          description: 'Steep in a covered container in the refrigerator for 12 hours; a longer steep may produce a stronger brew.',
          durationSeconds: 43200,
        ),
        BrewStep(
          title: 'Filter and store',
          description: 'Filter through a clean filter and store in a clean, covered container in the refrigerator.',
          durationSeconds: 120,
        ),
      ],
      tips: [
        'A 1:6 ratio is a starting point for concentrate; use more water for ready-to-drink coffee.',
        'Dilute to taste with water or milk when serving; there is no fixed dilution ratio.',
        'Brew in a clean, covered container in the refrigerator and follow food-safety guidance for storage.',
        'Cold brew cannot be assumed to be less acidic or gentler on the stomach in every case.',
      ],
    ),
  ];

  static BrewMethod byId(String id) =>
      all.firstWhere((m) => m.id == id, orElse: () => all.first);

  static const Map<String, String> _legacyNames = {
    'Türk Kahvesi': 'Turkish Coffee',
    'Sifon (Syphon)': 'Siphon',
  };

  static BrewMethod byName(String name) {
    final canonicalName = _legacyNames[name] ?? name;
    return all.firstWhere(
      (method) => method.name == canonicalName,
      orElse: () => all.first,
    );
  }

  static BrewMethod? maybeByName(String name) {
    final canonicalName = _legacyNames[name] ?? name;
    for (final method in all) {
      if (method.name == canonicalName) return method;
    }
    return null;
  }

  static List<BrewMethod> get popular => [
    byId('v60'),
    byId('batchbrew'),
    byId('frenchpress'),
    byId('moka'),
    byId('aeropress'),
    byId('chemex'),
    byId('coldbrew'),
  ];

  static List<BrewMethod> get calibrationPriority => [
    byId('espresso'),
    ...popular,
    ...all.where(
      (method) =>
          method.id != 'espresso' &&
          !popular.any((popularMethod) => popularMethod.id == method.id),
    ),
  ];

  static List<BrewMethod> get featured => all.take(4).toList();
}
