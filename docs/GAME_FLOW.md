# Przebieg gry

Menu główne uruchamia pierwszy poziom. Klawisz Escape otwiera menu pauzy z opcjami wznowienia, restartu i powrotu do menu. Animowany portal pulsuje i obraca świetlne pierścienie; wejście rycerza powoduje ukończenie poziomu. Kolejny poziom jest prototypową drugą planszą. Po ukończeniu drugiej planszy następuje powrót do menu. Następne poziomy dopisuje się do tablicy LEVELS w scripts/game_flow.gd.

## Portal pixel art
Portal na obu poziomach używa dziewięciu klatek animacji po 32×64 px z `assets/sprites/portal_atlas.png`. Oryginalny GIF został przetworzony do przezroczystego arkusza (zielone tło zostało usunięte). Mechanika końca poziomu pozostała bez zmian. Animacja odtwarza się z szybkością 10 FPS, filtrowanie Nearest.

## Zapisywanie postępu
Postęp gry jest zapisywany w `user://rycerz_progress.cfg`. Przy rozpoczęciu nowej gry zapis jest resetowany do pierwszego poziomu, a po przejściu przez portal odblokowywany jest kolejny (lub zachowany ostatni, jeśli nie ma kolejnych). W menu głównym przycisk „Kontynuuj” jest niedostępny bez poprawnego zapisu. Kontynuacja uruchamia zapisany poziom od początku; nie zachowuje aktualnej pozycji rycerza, zdrowia ani monet. Błędne i niekompatybilne pliki zapisu są ignorowane.

## Poziom 2 — Zielone Wyspy
Nowa plansza obejmuje cztery wyspy oddzielone przepaściami, pomosty skokowe, 12 monet, trzech przeciwników slime, wodne tło i końcowy animowany portal. Układ zachowuje kolorystykę pierwszej planszy i korzysta z oryginalnego zasobu `platform_green.tscn`. Punkty i serca korzystają z istniejącego HUD-u, a strefa śmierci działa pod wyspami. Przejście do poziomu 2 wykorzystuje istniejący GameFlow.
