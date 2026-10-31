# Przebieg gry

Menu główne uruchamia pierwszy poziom. Klawisz Escape otwiera menu pauzy z opcjami wznowienia, restartu i powrotu do menu. Animowany portal pulsuje i obraca świetlne pierścienie; wejście rycerza powoduje ukończenie poziomu. Kolejny poziom jest prototypową drugą planszą. Po ukończeniu drugiej planszy następuje powrót do menu. Następne poziomy dopisuje się do tablicy LEVELS w scripts/game_flow.gd.

## Portal pixel art
Portal na obu poziomach używa dziewięciu klatek animacji po 32×64 px z `assets/sprites/portal_atlas.png`. Oryginalny GIF został przetworzony do przezroczystego arkusza (zielone tło zostało usunięte). Mechanika końca poziomu pozostała bez zmian. Animacja odtwarza się z szybkością 10 FPS, filtrowanie Nearest.
