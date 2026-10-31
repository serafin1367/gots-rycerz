# Prototyp animacji ataku rycerza

Arkusz: `res://assets/sprites/knight_attack_32x32.png` (192 × 32 px, sześć klatek 32 × 32 px, RGBA).

Scena podglądu: `res://scenes/attack_preview.tscn`. Otwórz ją w Godot 4.4 i uruchom bieżącą scenę (F6), aby obejrzeć zapętloną animację w powiększeniu 4×. Podgląd nie zmienia sceny startowej ani działającego systemu sterowania.

To prototyp wygenerowany i zmniejszony do formatu 32×32. Przed włączeniem go do rozgrywki należy wizualnie zatwierdzić spójność z bazowym rycerzem oraz ocenić czy szerszy łuk miecza nie wymaga oddzielnej nakładki. Klatki nie są jeszcze podłączone do kolizji i nie zadają obrażeń.

Zalecane ustawienia importu w Godot: filtr tekstur Nearest; bez interpolacji krawędzi. Obraz ma oszczędną paletę 32 kolorów.
