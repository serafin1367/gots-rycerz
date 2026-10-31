# Testy regresyjne gry Rycerz

Wymagany jest Godot 4.4.1 (bez .NET). Testy nie wymagają dodatków.

```bash
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/run_tests.gd
```

Skrypt sprawdza: przynależność gracza do grupy, hamowanie zależne od czasu, ignorowanie obcych obiektów w strefie śmierci, uruchomienie i nieponawianie timera śmierci, obecność monety i GameManagera, jednokrotne przyznawanie punktu.

GitHub Actions uruchamia te same polecenia przy push, PR oraz ręcznie. Testy headless nie sprawdzają jakości grafiki, odtwarzania audio ani odczuć z rozgrywki.
