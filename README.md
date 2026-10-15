# Barista Brew ☕

Baristalar için kahve gramajı hesaplama, demleme yöntemleri, reçeteler, adım bazlı
zamanlayıcı ve demleme günlüğü içeren **ücretsiz** mobil uygulama.

- **Platform:** iOS + Android (tek kod tabanı — Flutter)
- **Durum:** ücretsiz, tamamen çevrimdışı (veriler cihazda saklanır)

## Özellikler

| Sekme | Açıklama |
|---|---|
| **Hesapla** | Kahve-su oranı (1:X) ile gramaj hesaplama; kahve→su ve su→kahve yönleri, önerilen oran kısayolları, fincan tahmini |
| **Yöntemler** | Espresso, V60, Chemex, AeroPress, French Press, Moka Pot, Türk Kahvesi ve Cold Brew için oran, öğütüm, sıcaklık, adımlar ve püf noktaları |
| **Reçeteler** | Kendi özel reçetelerini kaydet, düzenle, sil |
| **Zamanlayıcı** | Seçilen yönteme göre adım bazlı geri sayım + aktif adım vurgusu |
| **Günlük** | Her demlemeyi kaydet, puan ver, son 7 gün grafiği ve özet istatistikler |

## Kurulum & Çalıştırma

```bash
# Bağımlılıkları indir
flutter pub get

# Analiz ve test
flutter analyze
flutter test

# Cihazda / emülatörde çalıştır
flutter run
```

## Proje Yapısı

```
lib/
├── main.dart                  # Uygulama girişi
├── theme/
│   └── app_theme.dart        # Kahve temalı renkler + tema
├── models/
│   ├── brew_method.dart      # Demleme yöntemi + adımlar
│   ├── coffee_recipe.dart    # Kayıtlı reçete
│   └── brew_log.dart         # Günlük kaydı
├── data/
│   └── brew_methods_data.dart # Önceden tanımlı 8 yöntem
├── state/
│   └── app_state.dart        # Provider + SharedPreferences kalıcılık
├── utils/
│   └── format.dart           # Türkçe biçimlendirme yardımcıları
└── screens/
    ├── home_screen.dart      # Alt gezinme iskeleti
    ├── calculator_screen.dart
    ├── methods_screen.dart
    ├── method_detail_screen.dart
    ├── recipes_screen.dart
    ├── timer_screen.dart
    └── journal_screen.dart
```

## Teknoloji

- **Flutter 3.x** (Dart 3) — tek kod tabanı, iOS + Android
- **provider** — durum yönetimi
- **shared_preferences** — cihazda kalıcı veri saklama

## Yayınlama Notları

iOS ve Android'de yayına almak gereken temel adımlar (hesaplar size ait):

1. **Android:** `flutter build appbundle` → Google Play Console'a yükle
2. **iOS:** Xcode'da imzalama ekibini seç (`Runner.xcworkspace`) → `flutter build ipa`
   ile archive edip App Store Connect'e yükle
3. Uygulama ikonunu (launcher icon) ve varsa splash görselini markana göre değiştir
