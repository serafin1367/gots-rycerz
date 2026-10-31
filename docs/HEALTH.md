# System życia (wersja 0.2)

Postać rozpoczyna z trzema HP. Kontakt ze slime'em odbiera 1 HP; po trafieniu działa 1,2 sekundy nietykalności i efekt wizualny. Przy 0 HP postać umiera, a poziom restartuje się po 0,7 s. Przepaść zachowuje dotychczasową logikę natychmiastowej śmierci.

Parametry `max_health` i `invulnerability_seconds` są eksportowane w skrypcie postaci; obrażenia przeciwnika reguluje `damage` w `scripts/damage_zone.gd`.

HUD używa trzech serc w lewym górnym rogu ekranu. Czerwone serce oznacza aktywny punkt życia, przygaszone serce oznacza utracony punkt. HUD jest wyświetlany w CanvasLayer, więc pozostaje na ekranie podczas przesuwania kamery. Przy każdym przyjętym trafieniu odtwarzany jest plik `assets/sounds/hurt.wav` przez magistralę `SFX`. Testy regresyjne sprawdzają obrażenia, nietykalność, śmierć i kolizje z przeciwnikiem.

Licznik monet (`Coins: N`) znajduje się po prawej stronie serc, w tym samym rzędzie HUD. GameManager aktualizuje licznik po zebraniu monety. Stary napis przy kamerze został usunięty.

HUD graficzny: dwa warianty pixel-art (`assets/ui/heart_full.png`, `assets/ui/heart_empty.png`) są używane w `TextureRect`. Ikona monety pochodzi z istniejącego atlasu `assets/sprites/coin.png` (pierwsza klatka 16×16), a liczba monet jest wyświetlana bez prefiksu `Coins:`. Tekstury są wyświetlane filtrowaniem nearest.
