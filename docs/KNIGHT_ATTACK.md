# Atak mieczem — wersja eksperymentalna

Grafika `assets/sprites/knight_attack_32x32.png` to sześć osobnych klatek po 32×32 px (łącznie 192×32), wykonanych na bazie *rzeczywistej pierwszej klatki* z `knight.png`. Postać zachowuje dokładnie tę samą kolorystykę i sylwetkę; miecz i efekt cięcia są nakładane wewnątrz poszczególnych klatek, bez przenikania pomiędzy nimi.

Klawisz `J` aktywuje atak. Czas ataku: 0,6 s. Obrażenia trafiają w oknie 0,2–0,5 s, maksymalnie jeden raz dla każdego przeciwnika podczas zamachu. Slime ma domyślnie 1 HP. Nie zmieniano pozostałych animacji, HUD ani poziomu. Podgląd: `scenes/attack_preview.tscn` (F6).

Atak jest prototypem do weryfikacji wizualnej i manualnego sprawdzenia kolizji w Godot.
