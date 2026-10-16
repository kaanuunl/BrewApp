import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HelpLegalScreen extends StatelessWidget {
  const HelpLegalScreen({super.key});

  static const _questions = [
    (
      question: 'Does the app work without an internet connection?',
      answer: 'Yes. The calculator, method guides, timer, recipes, and journal work on your device. This version has no account or cloud sync.',
    ),
    (
      question: 'Where are my recipes and journal entries stored?',
      answer: 'Saved recipes and brew journal entries are stored as app data on your device. Uninstalling the app may remove these records; back them up first from Settings and Data.',
    ),
    (
      question: 'Where does my backup go?',
      answer: 'The Back Up button copies your recipes and journal entries to the clipboard as JSON text. The backup leaves your device only if you paste and save it somewhere else. Store it securely; it may contain your notes.',
    ),
    (
      question: 'How do I delete my data?',
      answer: 'Use “Delete data on this device” in Settings and Data to remove saved recipes, journal entries, and theme preference. You must separately delete any backups you exported.',
    ),
    (
      question: 'Do the ratios and times guarantee a specific result?',
      answer: 'No. Values shown for each method are starting suggestions. You may need to adjust them for the coffee, grind, equipment, and your preferences.',
    ),
    (
      question: 'How should I read a brew ratio?',
      answer: 'For filter and immersion methods, 1:16 generally means 16 g (about 16 ml) of brew water for every 1 g of dry coffee. For espresso, 1:2 means about 2 g of beverage yield for every 1 g of dry coffee; it is not the amount of water fed into the machine.',
    ),
    (
      question: 'What can I adjust if my coffee tastes sour and weak?',
      answer: 'Under-extraction is one possibility. Keep the recipe the same and first try a slightly finer grind; if needed, increase contact time or water temperature in small steps. Change one variable per trial and record the result; roast and water also affect flavor.',
    ),
    (
      question: 'What can I adjust if my coffee tastes bitter or drying?',
      answer: 'If over-extraction is a possibility, try a slightly coarser grind or reduce contact time or temperature. Roast profile, water, and equipment cleanliness can also affect perceived bitterness; change one setting at a time.',
    ),
    (
      question: 'How can I personalize a recipe?',
      answer: 'First, measure coffee, water, grind, and time consistently. If the cup tastes sour or weak, try a finer grind or slightly longer contact; if bitter or drying, try the opposite in small steps. Change one variable per trial.',
    ),
    (
      question: 'What water should I use?',
      answer: 'Use clean, potable water with a neutral taste. Water quality can noticeably affect the cup; mineral content and alkalinity can change perceived acidity and aroma. Adjust temperature to the brewing method and roast profile.',
    ),
    (
      question: 'Does Brew App provide health or nutrition advice?',
      answer: 'No. The app is for coffee preparation measurements and timing; it is not a substitute for medical, nutrition, or safety advice.',
    ),
    (
      question: 'Is the app intended for children?',
      answer: 'The app is designed for users aged 13 and older and is not offered as a service directed at children. This does not remove the need to verify age and parental-consent rules in target countries.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help and legal information')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'Frequently asked questions',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ..._questions.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(
                  item.question,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                iconColor: context.accentCoffee,
                collapsedIconColor: context.accentCoffee,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.answer,
                      style: TextStyle(
                        color: context.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Legal documents',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _DocumentTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy notice',
            subtitle: 'App data and on-device storage',
            document: _privacyDocument,
          ),
          const SizedBox(height: 8),
          _DocumentTile(
            icon: Icons.description_outlined,
            title: 'Terms of use',
            subtitle: 'Terms that apply when using the app',
            document: _termsDocument,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.containerMilk,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderLatte),
            ),
            child: Text(
              'Before release: add the publisher/business name and support/privacy contact details to these documents; have the text reviewed for target countries and align it with store privacy disclosures.',
              style: TextStyle(
                color: context.textPrimary,
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.document,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _LegalDocument document;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: context.accentCoffee),
        title: Text(
          title,
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: context.accentCoffee),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _LegalDocumentScreen(document: document),
          ),
        ),
      ),
    );
  }
}

class _LegalDocumentScreen extends StatelessWidget {
  const _LegalDocumentScreen({required this.document});

  final _LegalDocument document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'Last updated: October 16, 2026',
            style: TextStyle(color: context.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.containerMilk,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderLatte),
            ),
            child: Text(
              'MUST BE COMPLETED BEFORE RELEASE: The publisher/business name and contact address have not been specified in this draft. Do not publish this as a final binding or compliant notice without jurisdiction-specific legal review.',
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...document.sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    section.body,
                    style: TextStyle(
                      color: context.textSecondary,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalDocument {
  const _LegalDocument({required this.title, required this.sections});

  final String title;
  final List<_LegalSection> sections;
}

class _LegalSection {
  const _LegalSection(this.title, this.body);

  final String title;
  final String body;
}

const _privacyDocument = _LegalDocument(
  title: 'Privacy Notice',
  sections: [
    _LegalSection(
      'Data controller and contact',
      'Publisher/data controller: [ADD PUBLISHER OR BUSINESS NAME]. Privacy and support contact: [ADD CONTACT EMAIL]. This document is not ready for publication until these details are verified and completed.',
    ),
    _LegalSection(
      'Information processed in this version',
      'Saved recipes and brew journal entries may contain the brewing method, coffee and water amounts, ratio, grind, temperature, time, rating, and optional notes. Your theme preference is also stored on your device. The current app source contains no user accounts, in-app advertising, analytics, or cloud sync service.',
    ),
    _LegalSection(
      'Storage and third parties',
      'This information is stored in local app storage on your device; the app does not send these records to its own server. Data that operating system and store providers may process for their services is outside the scope of this notice and should be considered separately in store privacy disclosures.',
    ),
    _LegalSection(
      'Device backups',
      'Android app-data backup is disabled for this app. iOS device backups are controlled by system settings and may include app data. Operating-system backups are separate from the in-app JSON backup and are managed by the platform.',
    ),
    _LegalSection(
      'Backups and clipboard',
      'If you use Back Up, your recipes and journal entries are copied to the device clipboard as JSON. Pasting clipboard contents into another app may allow that app to process or store the data. The app accesses the clipboard only when you start a backup or restore-from-clipboard action.',
    ),
    _LegalSection(
      'Retention and deletion',
      'Records remain on your device until you clear app data or uninstall the app. In the app, use Settings and Data > Delete data on this device. You must separately delete exported backups and copied clipboard text.',
    ),
    _LegalSection(
      'Rights and regional information',
      'Rights in Türkiye, the European Economic Area, and other regions may vary based on the data controller, processing purposes, and local law. Add publisher contact details and jurisdiction-specific request channels after legal review. This in-app notice alone does not replace an official privacy policy URL or store disclosures.',
    ),
    _LegalSection(
      'Children',
      'The app is designed for users aged 13 and older and is not offered as a service directed at children. Verify minimum-age, parental-consent, and store audience rules in target markets before release.',
    ),
    _LegalSection(
      'Changes',
      'If the app features or data practices change, update this notice and store disclosures. Publish the current text at an accessible web address with publisher and contact details.',
    ),
  ],
);

const _termsDocument = _LegalDocument(
  title: 'Terms of Use',
  sections: [
    _LegalSection(
      'Parties and acceptance',
      'These draft terms describe the use of Brew App. Service provider: [ADD PUBLISHER OR BUSINESS NAME]; contact: [ADD CONTACT EMAIL]. Do not use this text as a final end-user agreement until publisher details and applicable law are determined.',
    ),
    _LegalSection(
      'Scope of service',
      'Brew App provides coffee-to-water ratio calculations, brewing method information, recipe storage, a timer, and a personal brew journal. The app currently works offline and does not provide user accounts.',
    ),
    _LegalSection(
      'Informational content',
      'Method ratios, temperatures, grind suggestions, and times are general starting recommendations, not guaranteed results, professional advice, or health advice. Follow equipment manufacturers’ instructions and standard precautions when handling hot liquids.',
    ),
    _LegalSection(
      'User responsibilities',
      'You are responsible for securing your device and backups, checking the accuracy of information you enter, and using the app in compliance with applicable rules. Backup files may contain personal notes; check their contents before sharing.',
    ),
    _LegalSection(
      'Intellectual property and permissions',
      'The app and its content are protected by applicable law. These terms permit personal and lawful use of the app but do not transfer ownership. Third-party components may be subject to their own licenses.',
    ),
    _LegalSection(
      'Availability, changes, and termination',
      'Because the app works offline and on-device, features may change or be removed in updates. These terms do not remove applicable consumer or other mandatory legal rights. You may stop using the app and delete local data to end your use.',
    ),
    _LegalSection(
      'Liability and mandatory rights',
      'This section is not intended to limit applicable consumer protections or rights that cannot legally be excluded. Liability clauses and governing law should be prepared by local counsel once the publisher, target markets, and distribution model are known.',
    ),
    _LegalSection(
      'Updates and contact',
      'These terms may be updated; the in-app text shows the update date. Contact address: [ADD CONTACT EMAIL]. Add a valid contact address and effective date before release.',
    ),
  ],
);
