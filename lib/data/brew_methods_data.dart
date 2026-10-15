import 'package:flutter/material.dart';

import '../models/brew_method.dart';

/// Önceden tanımlı demleme yöntemleri kütüphanesi.
class BrewMethodsData {
  BrewMethodsData._();

  static const List<BrewMethod> all = [
    BrewMethod(
      id: 'espresso',
      name: 'Espresso',
      subtitle: 'Basınçlı, yoğun ve kremalı',
      description:
          'Yüksek basınç altında, çok ince öğütülmüş kahveden kısa sürede çıkarılan yoğun bir shot. Tüm sütlü içeceklerin temelidir.',
      icon: Icons.local_cafe,
      ratio: 2.0,
      defaultCoffeeGrams: 18,
      grindSize: 'Çok ince (tuz gibi)',
      waterTempC: 93,
      bloomSeconds: 0,
      totalTimeSeconds: 28,
      difficulty: Difficulty.zor,
      steps: [
        BrewStep(title: 'Tartım', description: '18 g kahveyi tart, portafiltreye koy.', durationSeconds: 10),
        BrewStep(title: 'Tamping', description: 'Kahveyi düzgün ve sıkı şekilde tamp et.', durationSeconds: 15),
        BrewStep(title: 'Ekstraksiyon', description: '25–30 sn boyunca 36 g (1:2) çıkart.', durationSeconds: 28),
      ],
      tips: [
        'Hedef oran: 1:2 (18 g kahve → 36 g espresso).',
        'Ristretto için 1:1.5, lungo için 1:3 kullan.',
        'İdeal süre 25–30 saniye arasıdır.',
        'Su sıcaklığı 92–94 °C olmalı.',
      ],
    ),
    BrewMethod(
      id: 'v60',
      name: 'V60 (Pour Over)',
      subtitle: 'Temiz, parlak, filtre kahve',
      description:
          'Japon Hario V60 ile elle dökme. Konik form sayesinde net ve aromatik fincan verir; üçüncü dalga kahvenin klasiği.',
      icon: Icons.filter_alt,
      ratio: 16.0,
      defaultCoffeeGrams: 20,
      grindSize: 'Orta-ince (toz şeker gibi)',
      waterTempC: 94,
      bloomSeconds: 45,
      totalTimeSeconds: 180,
      difficulty: Difficulty.orta,
      steps: [
        BrewStep(title: 'Filtreyi ıslat', description: 'Kağıt filtreyi sıcak suyla yıka, dökme suyunu boşalt.', durationSeconds: 20),
        BrewStep(title: 'Bloom', description: 'Kahvenin 2–3 katı su dök, 45 sn bekle.', durationSeconds: 45),
        BrewStep(title: 'Ana döküş', description: 'Dairesel hareketlerle yavaşça suyu ekle.', durationSeconds: 60),
        BrewStep(title: 'Damlatma', description: 'Suyun tamamen süzülmesini bekle.', durationSeconds: 55),
      ],
      tips: [
        'Oran: 1:15–1:17 arası.',
        'Su sıcaklığı 92–96 °C.',
        'Dairesel döküş, merkeze sabit döküşten daha dengeli çıkar.',
        'Toplam süre 2:30–3:00 civarı olmalı.',
      ],
    ),
    BrewMethod(
      id: 'chemex',
      name: 'Chemex',
      subtitle: 'Büyük hacim, ipeksi gövde',
      description:
          'Kalın filtreli şık cam sürahi. Çok temiz, çay gibi bir fincan verir; birkaç kişiye birlikte demlerken idealdir.',
      icon: Icons.local_drink,
      ratio: 15.0,
      defaultCoffeeGrams: 30,
      grindSize: 'Orta-kaba (deniz tuzu gibi)',
      waterTempC: 94,
      bloomSeconds: 45,
      totalTimeSeconds: 240,
      difficulty: Difficulty.orta,
      steps: [
        BrewStep(title: 'Filtreyi ıslat', description: 'Filtreyi sıcak suyla yıka, suyu dök.', durationSeconds: 20),
        BrewStep(title: 'Bloom', description: 'Kahvenin 2–3 katı su ekle, 45 sn bekle.', durationSeconds: 45),
        BrewStep(title: 'Döküşler', description: 'Suyu 3–4 parti halinde dairesel ekle.', durationSeconds: 120),
        BrewStep(title: 'Süzülme', description: 'Tam süzülmeyi bekle, servis et.', durationSeconds: 55),
      ],
      tips: [
        'Kalın filtre, vücudu yumuşatır; öğütümü V60’tan daha kaba tut.',
        'Oran: 1:15.',
        'Total süre yaklaşık 4 dakika.',
      ],
    ),
    BrewMethod(
      id: 'aeropress',
      name: 'AeroPress',
      subtitle: 'Hızlı, esnek ve taşınabilir',
      description:
          'Basınçlı daldırma yöntemi. Kısa sürede, temiz ve güçlü bir fincan verir; seyahatte çok pratik.',
      icon: Icons.coffee,
      ratio: 13.0,
      defaultCoffeeGrams: 15,
      grindSize: 'İnce (sofra tuzu gibi)',
      waterTempC: 88,
      bloomSeconds: 0,
      totalTimeSeconds: 120,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(title: 'Kahve + su', description: '15 g kahveye yaklaşık 200 ml su ekle, karıştır.', durationSeconds: 30),
        BrewStep(title: 'Demleme', description: '60–90 sn beklet.', durationSeconds: 60),
        BrewStep(title: 'Piston', description: 'Yavaşça 30 sn boyunca bastır.', durationSeconds: 30),
      ],
      tips: [
        'AeroPress biraz daha düşük sıcaklıkta (85–92 °C) çalışır.',
        'Ters (inverted) yöntemle daha uzun demleyebilirsin.',
        'Americano için suyla seyreltebilirsin.',
      ],
    ),
    BrewMethod(
      id: 'frenchpress',
      name: 'French Press',
      subtitle: 'Dolgun gövdeli, yağlı doku',
      description:
          'Daldırma yöntemi. Metal filtre yağları tutmaz, bu yüzden daha dolgun ve yoğun bir gövde elde edersin.',
      icon: Icons.soup_kitchen,
      ratio: 16.0,
      defaultCoffeeGrams: 30,
      grindSize: 'Kaba (deniz tuzu ile fındık arası)',
      waterTempC: 94,
      bloomSeconds: 0,
      totalTimeSeconds: 260,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(title: 'Kahve + su', description: '30 g kahveye 480 ml su ekle.', durationSeconds: 20),
        BrewStep(title: 'Karıştır + bekle', description: '1 dk sonra üstteki kabuğu kır, karıştır.', durationSeconds: 60),
        BrewStep(title: 'Demleme', description: 'Toplam 4 dk demle, pistonu yavaşça indir.', durationSeconds: 180),
      ],
      tips: [
        'Metal filtre yağları bırakır → daha dolgun gövde.',
        'Çok ince öğütürsen kupada tortu kalır.',
        'Demleme sonrası kahveyi başka kaba al, fazla demlenmesin.',
      ],
    ),
    BrewMethod(
      id: 'moka',
      name: 'Moka Pot',
      subtitle: 'Ocak üstü espresso benzeri',
      description:
          'Ocakta buhar basıncıyla çalışan klasik makine. Espresso kadar değil ama güçlü, yoğun bir kahve verir.',
      icon: Icons.kitchen,
      ratio: 8.0,
      defaultCoffeeGrams: 18,
      grindSize: 'İnce (espresso ile orta arası)',
      waterTempC: 95,
      bloomSeconds: 0,
      totalTimeSeconds: 300,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(title: 'Su ekle', description: 'Alt hazneye vanaya kadar su doldur.', durationSeconds: 20),
        BrewStep(title: 'Kahve ekle', description: 'Sepete kahve doldur (bastırmadan düzle).', durationSeconds: 20),
        BrewStep(title: 'Ocakta demle', description: 'Orta-kısık ateşte kaynayıp çıkışı bekle.', durationSeconds: 240),
        BrewStep(title: 'Servis', description: 'İlk fışkırma sesinde ocaktan al.', durationSeconds: 20),
      ],
      tips: [
        'Kahveyi tamp etme, sadece düzle.',
        'Fışkırma başlayınca ocaktan al, yanık tat önlenir.',
        'Soğuk su yerine sıcak su kullanmak acılığı azaltır.',
      ],
    ),
    BrewMethod(
      id: 'turkish',
      name: 'Türk Kahvesi',
      subtitle: 'Geleneksel, telveli, köpüklü',
      description:
          'Cezvede, çok ince öğütülmüş kahveyle yapılan geleneksel yöntem. Köpüklü ve yoğun.',
      icon: Icons.emoji_food_beverage,
      ratio: 10.0,
      defaultCoffeeGrams: 7,
      grindSize: 'Toz (en ince öğütüm)',
      waterTempC: 93,
      bloomSeconds: 0,
      totalTimeSeconds: 240,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(title: 'Ölçü', description: 'Fincan başına 1 tatlı (7 g) kahve + 70 ml su.', durationSeconds: 10),
        BrewStep(title: 'Karıştır', description: 'Soğukken kısık ateşte karıştır.', durationSeconds: 30),
        BrewStep(title: 'Köpük + kaynat', description: 'Köpük yükselince fincana al, tekrar kaynat.', durationSeconds: 180),
        BrewStep(title: 'Servis', description: 'Köpüğü bozmadan servis et.', durationSeconds: 20),
      ],
      tips: [
        'Kahveyi soğuk suyla karıştırıp kısık ateşte yavaş pişir.',
        'Kaynatınca köpüğü fincana böl.',
        'Şeker istenirse demlemede eklenir, sonradan değil.',
      ],
    ),
    BrewMethod(
      id: 'coldbrew',
      name: 'Cold Brew',
      subtitle: 'Soğuk demleme, yumuşak', 
      description:
          'Soğuk suyla 12–24 saat demlenen az asitli, yumuşak ve tatlı yoğun öz. Buzlu kahve için mükemmel.',
      icon: Icons.ac_unit,
      ratio: 6.0,
      defaultCoffeeGrams: 80,
      grindSize: 'Çok kaba (fındık büyüklüğü)',
      waterTempC: 20,
      bloomSeconds: 0,
      totalTimeSeconds: 43200,
      difficulty: Difficulty.kolay,
      steps: [
        BrewStep(title: 'Kahve + soğuk su', description: 'Kaba öğütülmüş kahveyi soğuk suyla karıştır.', durationSeconds: 30),
        BrewStep(title: 'Demleme', description: 'Buzdolabında 12–24 saat beklet.', durationSeconds: 43200),
        BrewStep(title: 'Süz', description: 'Filtreden/bezden geçir.', durationSeconds: 120),
      ],
      tips: [
        'Sonuç konsantredir; serviste 1:1 su veya sütle seyrelt.',
        'Ne kadar uzun beklerse o kadar dolgun, ama 24 saati aşma.',
        'Asit oranı düşük, mide dostu bir fincan.',
      ],
    ),
  ];

  static BrewMethod byId(String id) =>
      all.firstWhere((m) => m.id == id, orElse: () => all.first);

  static List<BrewMethod> get featured => all.take(4).toList();
}
