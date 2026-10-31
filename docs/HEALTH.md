# System życia (wersja 0.2)

Postać rozpoczyna z trzema HP. Kontakt ze slime'em odbiera 1 HP; po trafieniu działa 1,2 sekundy nietykalności i efekt wizualny. Przy 0 HP postać umiera, a poziom restartuje się po 0,7 s. Przepaść zachowuje dotychczasową logikę natychmiastowej śmierci.

Parametry `max_health` i `invulnerability_seconds` są eksportowane w skrypcie postaci; obrażenia przeciwnika reguluje `damage` w `scripts/damage_zone.gd`.

Widoczny jest licznik `HP: x/3` pod licznikiem monet. Testy regresyjne sprawdzają obrażenia, nietykalność, śmierć i kolizje z przeciwnikiem.
