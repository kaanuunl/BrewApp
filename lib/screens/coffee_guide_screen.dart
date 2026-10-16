import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_entry.dart';

class CoffeeGuideScreen extends StatelessWidget {
  const CoffeeGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      (
        icon: Icons.inventory_2_outlined,
        title: 'Capsule coffee',
        intro:
            'The grind and dose are set in advance inside the capsule. Choosing a capsule compatible with your machine and the right cup size matters more than grinder settings.',
        tips: [
          'Check that the capsule is compatible with your machine model; never force an incompatible capsule into place.',
          'Choose a short or long cup setting to suit the capsule. Too much water can dilute the coffee.',
          'Remove the capsule after brewing and clean the machine water path according to the manufacturer instructions.',
          'For reusable capsules, use only the grind and fill amount recommended by the manufacturer, and close the lid securely.',
          'Sort capsules and packaging according to local collection rules; recycling options vary by material and region.',
        ],
      ),
      (
        icon: Icons.spa_outlined,
        title: 'Whole-bean coffee',
        intro:
            'Grinding just before brewing can help preserve aroma. There is no universal freshness deadline; roast date, packaging, and storage all matter.',
        tips: [
          'Check the roast date when available. After opening, store beans in an airtight, light-proof container.',
          'Keep the container in a cool, dry place away from the stove and direct sunlight.',
          'A refrigerator is generally not ideal for daily storage because of moisture and odor transfer.',
          'If freezing, divide beans into small airtight portions; thaw only the portion you plan to use.',
          'Grind just before brewing and weigh the same dose each time.',
        ],
      ),
      (
        icon: Icons.grain_outlined,
        title: 'Pre-ground coffee',
        intro:
            'Ground coffee has more exposed surface area, so its aroma can change faster than whole beans. Seal the package well after opening and use it promptly.',
        tips: [
          'If the package lists roast and grind information, choose one suited to your method; pre-ground coffee may not suit every brewer.',
          'Reseal opened packages airtight and keep coffee away from moisture, heat, light, and strong odors.',
          'Do not leave coffee exposed for long or put a wet spoon in the package.',
          'If the brew tastes weak, first check whether the grind suits your method, along with the dose and water volume.',
          'For finer control, buy whole beans and grind just before brewing.',
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Coffee storage and use guide')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.accentCoffee, context.accentCaramel],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.coffee, color: Colors.white, size: 34),
                SizedBox(height: 14),
                Text(
                  'Know your coffee',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Practical selection and storage tips for capsules, whole beans, and pre-ground coffee.',
                  style: TextStyle(color: Colors.white, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < sections.length; i++)
            AnimatedEntry(
              index: i,
              child: _CoffeeInfoCard(section: sections[i]),
            ),
        ],
      ),
    );
  }
}

class _CoffeeInfoCard extends StatelessWidget {
  const _CoffeeInfoCard({required this.section});

  final ({
    IconData icon,
    String title,
    String intro,
    List<String> tips,
  }) section;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: context.accentCoffee.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(section.icon, color: context.accentCoffee),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              section.intro,
              style: TextStyle(
                color: context.textSecondary,
                height: 1.45,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            for (final tip in section.tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: context.accentCaramel,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          color: context.textPrimary,
                          height: 1.4,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
