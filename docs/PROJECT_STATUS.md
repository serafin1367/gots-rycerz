# RYCERZ — stan projektu i ustalenia robocze

Aktualizacja: 2026-11-01. Repozytorium: `serafin1367/gots-rycerz`, gałąź `main`.
Punkt odniesienia audytu: commit `cf87e8019aa44dfb1d50fc566bae16cccea16302` (2026-11-01, czas polski).

## Cel dokumentu
To jest punkt startowy następnych sesji. Na początku kolejnej pracy przeczytaj ten plik, sprawdź aktualne commity i CI, a dopiero potem planuj zmiany. Po większej zmianie aktualizuj stan, potwierdzone decyzje, problemy i kolejny krok. Dokument odróżnia funkcję obecną w kodzie od funkcji przetestowanej ręcznie.

## Potwierdzony stan kodu
- Projekt Godot, scena startowa `scenes/main_menu.tscn`; w `project.godot` zadeklarowano funkcje `4.7`. CI korzysta z Godot 4.4.1 — zgodność należy monitorować.
- `scripts/game_flow.gd`: trzy poziomy (`scenes/game.tscn`, `scenes/level_02.tscn`, `scenes/level_03.tscn`), pauza, restart, portale, przechodzenie między scenami oraz zapis postępu w `user://rycerz_progress.cfg`. Zapis obejmuje indeks poziomu i seed, ale nie pozycję gracza, HP ani monety.
- `scripts/player.gd`: ruch, skok, trzy bazowe HP, czasowa nietykalność po trafieniu, HUD serc i monet, eksperymentalny atak mieczem klawiszem J.
- `scripts/slime.gd`: przeciwnik o bazowym 1 HP, patrolowanie i przyjmowanie obrażeń.
- `scripts/coin.gd` i `scripts/game_manager.gd`: zbieranie monet, odnajdowanie GameManager w przodkach sceny i aktualizowanie licznika.
- `scripts/level_02.gd`: ręcznie rozplanowana, stała plansza Zielone Wyspy: 14 wysp, 61 monet (56 na trasie + 5 bonusowych), 7 slime'ów, 13 mostków i 10 dodatkowych platform. Zróżnicowane wysokości, TileMapLayer z zatwierdzonymi kafelkami i osobne bryły kolizyjne. Starszy `docs/GAME_FLOW.md` jest nieaktualny.
- `scenes/test_tilemap_level.tscn` + `scripts/test_tilemap_level.gd`: osobna scena testowa TileMapLayer, uruchamiana F6, z terenem, 6 monetami, jednym slime'em i portalem. Kolizje terenu realizują osobne `StaticBody2D`; nie jest to jeszcze pełny generator świata oparty na TileMap.
- `assets/data/world_tile_catalog.json` + `scripts/world_tile_catalog.gd`: wspólne źródło współrzędnych atlasu `world_tileset.png` (kafelki 16×16). Domyślnie funkcja `find_tile` dopuszcza tylko wpisy ze statusem `confirmed`. Istnieje dokument `docs/WORLD_TILE_CATALOG.md`.
- Dla nieba sceny testowej użyto jednolitego tła: kafelki wodne (4,9) i (4,12) dawały widoczne powtórzenia i nie powinny pełnić roli jednolitego nieba.
- Istnieją skrypty testowe w `tests/` i workflow GitHub Actions. Dla commita `cf87e801` workflow „Godot tests” i „Game flow validation” miały status **success** (sprawdzone 2026-11-01). To potwierdza przejście CI, nie zastępuje manualnego testu rozgrywki i grafiki.

## Wnioski z przeglądu — nie mylić z potwierdzonymi awariami
1. **P1: przeprowadzić test grywalności planszy 2.** Teren jest już rysowany przez TileMapLayer, natomiast kolizje realizują osobne bryły StaticBody2D. Należy sprawdzić ułożenie grafik względem powierzchni kolizji, osiągalność górnej ścieżki i czytelność podwyższeń.
2. **P1: ustalić mapowanie całego atlasu.** Katalog jawnie rozróżnia `confirmed`, `probable`, `unknown`. Nie przypisywać automatycznie kolizji ani mechanik kafelkom niezweryfikowanym.
3. **P1: manualny smoke test pozostałych mechanik.** Użytkownik potwierdził 2026-11-01 weryfikację sceny testowej TileMapLayer. Nie mamy osobnego potwierdzenia, że sprawdzono wszystkie interakcje (w szczególności portal), ani pełnej ścieżki menu, kontynuacji, obu poziomów, zapisu/odczytu seeda, monet, obrażeń, ataku J, śmierci/restartu i pauzy. Tych testów nie oznaczamy jako zaliczonych bez potwierdzenia.
4. **P2: zgodność wersji Godot.** `project.godot` deklaruje cechy 4.7, a `.github/workflows/godot-tests.yml` używa 4.4.1. Mimo zielonego CI należy ustalić docelową wersję edytora i wyrównać konfiguracje.
5. **P2: uaktualnić opisy plansz.** `docs/GAME_FLOW.md` powinien odzwierciedlać 5 wysp/15 monet lub wyraźnie dokumentować historyczną wersję.
6. **P2: sprawdzić bojowy hitbox i kolizje.** `docs/KNIGHT_ATTACK.md` określa atak jako eksperymentalny; wymaga oceny wizualnej i testów podczas faktycznej gry.
7. **P2: zweryfikować odporność sceny testowej.** Portal w `test_tilemap_level.gd` korzysta z `GameFlow` mimo że scena jest uruchamiana samodzielnie (F6); wykonać próbę wejścia w portal i sprawdzić pożądane zachowanie.

## Ustalenia robocze
- Modyfikujemy **wyłącznie** repozytorium `https://github.com/serafin1367/gots-rycerz`; zmiany zapisujemy bezpośrednio w kodzie i dokumentacji tego repozytorium.
- Nie zgadujemy, co przedstawiają nieznane kafelki ani jakie mają kolizje. Potwierdzone dane zapisujemy w katalogu i dokumentujemy.
- Generator powinien być odtwarzalny po seedzie.
- Każdą większą modyfikację weryfikujemy testami CI, a zachowanie wymagające obrazu/manualnej interakcji oznaczamy jako niezweryfikowane do czasu sprawdzenia w Godot.
- Ten dokument jest żywym dziennikiem projektu. Po pracach aktualizujemy „Potwierdzony stan”, „Wnioski”, „Następny krok” i datę.

## Rekomendowana kolejność prac
1. Przyjąć weryfikację sceny testowej TileMapLayer zgłoszoną przez użytkownika; osobno potwierdzić zachowanie portalu i wykonać smoke test pozostałych mechanik, jeśli nie były sprawdzane.
2. Projektować TileMapLayer jako fundament proceduralnego świata; doprecyzować podział na regiony/chunki, trwałość mapy i schemat warstw: Sky / Background / Water / Terrain / Decoration / Objects.
3. Rozszerzać katalog atlasu tylko o zweryfikowane pozycje; najpierw grunt i krawędzie, potem dekoracje i interakcje.
4. Zrobić niewielki, odtwarzalny generator terenu TileMapLayer z testami, nie naruszając działających poziomów.
5. Po testach migrować wybrany fragment poziomu 2; zsynchronizować dokumentację i wersje środowiska.

## Nierozstrzygnięte pytania projektowe
- **Aktualna decyzja (2026-11-01):** najpierw grywalne demo z kilkoma wcześniej zaplanowanymi, stałymi poziomami. Odkładamy proceduralny otwarty świat na później. Poprzednia preferencja proceduralnego świata jest nieaktualna.
- Czy różne kolory podłoża to biomy, czy odmienne zasady fizyki?
- Jak mają działać woda, bloki ?/!, dekoracje i elementy drewniane (kolizja/interakcja)?
- Jaka wersja Godot jest docelowa dla developmentu i eksportu?

## Historia audytu
- 2026-11-01: przegląd konfiguracji, logiki przepływu gry, gracza, monet, slime'ów, poziomu 2, sceny testowej TileMap i dokumentacji; zweryfikowano najnowszy commit i wynik CI. Bez zmian w mechanice gry.

- 2026-11-01: użytkownik potwierdził, że scena testowa została zweryfikowana. Odnotowano weryfikację sceny TileMapLayer jako deklarację użytkownika; zakres szczegółowych testów interakcji pozostaje nieokreślony.
- 2026-11-01: użytkownik wskazał wstępne preferowanie gry z generowanym światem. Kierunek zapisano bez przesądzania architektury szczegółowej.

## Demo — zmiana priorytetu 2026-11-01
- Cel bieżący: **trzy poziomy o powtarzalnym układzie**, z menu, monetami, przeciwnikami, portalami i przejściami między scenami.
- Poziom 1: istniejąca scena `scenes/game.tscn`.
- Poziom 2: `scenes/level_02.tscn`, układ generowany technicznie, ale z **ustalonym seedem 20261031**; w demie nie losujemy nowej planszy.
- Poziom 3: nowy `scenes/level_03.tscn` i `scripts/level_03.gd`, ręcznie określonych sześć wysp, 18 monet, czterech przeciwników i portal finałowy.
- `GameFlow.LEVELS` prowadzi przez trzy sceny; po trzeciej wraca do menu. Zachowujemy kompatybilny system zapisów; wcześniejszy `level_seed` pozostaje w zapisie, choć nie steruje demem.
- **Weryfikacja:** kod dodany; testy CI i ręczne przejście poziomu 3 wymagają potwierdzenia po commitach. Nie uznajemy nowego poziomu za przetestowany w rozgrywce.
- Kolejna praca: ocenić wizualnie układ, wykonać przejście wszystkich 3 poziomów, poprawić balans skoków i walki, dodać ekran ukończenia dema.

## Docelowy czas rozgrywki — decyzja użytkownika 2026-11-01
- **15 minut na całe demo; około 5 minut na poziom.** Jest to cel do potwierdzenia testami z zegarem, NIE aktualnie zmierzony czas.
- Poziomy 2 i 3 mają wymagać więcej pracy nad kompozycją, oprawą, mechanikami i balansem. Nie uznajemy samego zwiększenia długości za ukończone dopracowanie.
- Poziom 2: 14 przygotowanych wysp o stałych szerokościach i przerwach (odstępy 28–43 px), 56 monet, 7 slime'ów; istniejące zasoby i stały seed. Kod generuje bryły z danych, ale nie losuje projektu.
- Poziom 3: 16 zaplanowanych wysp, 64 monety i 9 slime'ów; stopniowanie sekcji przez szerokości i pozycje pomostów. Układ jest stały.
- Poziom 1 nie został jeszcze przebudowany do pięciu minut; jego czas jest niezweryfikowany.
- Następne priorytety: (1) pomiar czasów przejścia wszystkich trzech poziomów, (2) balans trudności przy restarcie całego poziomu po śmierci, (3) różne rodzaje wyzwań zamiast samych powtarzalnych wysp i slime'ów, (4) dekoracje i tematy poziomów, (5) ekran zakończenia dema.
- Weryfikować w Godot manualnie osiągalność wszystkich pomostów i monet oraz czas przejścia. Testy CI sprawdzają tylko część właściwości i nie potwierdzają pięciominutowego tempa.
- **Nadrzędne ustalenie:** najpierw dopracowane, stałe demo; proceduralny otwarty świat poza aktualnym zakresem.

## Zasada śmierci — decyzja użytkownika 2026-11-01
- Po śmierci rycerz **zaczyna bieżący poziom od początku**. Nie dodajemy checkpointów.
- Cel około 5 minut na poziom pozostaje; poziomy 2 i 3 trzeba projektować tak, by pełny restart był wyzwaniem, ale nie wynikał z nieczytelnych lub nieuczciwych przeszkód.
- Obecne `scripts/player.gd` już restartuje bieżącą scenę po śmierci; `kill_zone` również wymaga kontroli w testach gry. Nie jest potrzebna zmiana modelu zapisu postępów: zapis nadal wskazuje odblokowany poziom, a nie miejsce w jego obrębie.

## Zielone Wyspy — przebudowa 2026-11-01
- Plik: `scripts/level_02.gd`, scena: `scenes/level_02.tscn` (bez zmian w korzeniu sceny).
- Zastąpiono pozorną losowość świadomie dobranym zestawem szerokości 14 wysp, wysokości (-16 / 0 / +16) i odstępów 32 px. To stała plansza demo, nie otwarty generator świata.
- Dla terenu używane są tylko potwierdzone pozycje atlasu: `grass_top`, `rock_a`, `rock_b`, `dirt`. Użyty jest `TileMapLayer`; osobne `StaticBody2D` zapewniają fizykę lądu. Nie nadano właściwości fizycznych niepewnym kafelkom.
- Dodano układ kolorystyczny nieba, odległych wysp, morza, chmur i wodospadów, dekoracyjne kępki traw i słupki informacyjne (figury Polygon2D, bez kolizji). Nie są to nowe ręcznie malowane sprite'y.
- 13 pomostów między wyspami, 10 dodatkowych platform wysokiej trasy na 5 wyspach; 61 monet (w tym 5 nagród za ścieżkę górną) i 7 slime'ów na określonych wyspach. Portal końcowy, HUD, śmierć i restart korzystają z istniejących mechanik.
- Testy `tests/game_flow_test.gd` rozszerzono o liczbę wysp, monet, wrogów, podwyższone trasy i teren TileMapLayer. Status CI ustalić po zakończeniu pipeline.
- **Niezweryfikowane:** pełne przejście w edytorze Godot, osiągalność bonusów i skoków, wygląd styku kolizji/kafelków oraz cel 5 minut. Nie nazywać poziomu w pełni dopracowanym ani certyfikowanym czasowo przed playtestem.
- Brak checkpointów — po śmierci restart całego poziomu, zgodnie z decyzją użytkownika.

## Playtest poziomu 2 — 2026-11-01
- Użytkownik potwierdził, że poziom 2 da się ukończyć.
- Użytkownik ocenił aktualny poziom jako monotonny. **To otwarty problem projektowy**, nie brak grywalności.
- Następny priorytet: zastąpić powtarzalny schemat wyspa–monety–slime pięcioma odmiennymi sekwencjami (polana, przeprawy, ruiny, trasa górna, finał), z różną geometrią, układem nagród i tempem walki. Projekt do implementacji i manualnej oceny.
- Brak checkpointów i restart całego poziomu po śmierci pozostają wymaganiami.

## Nowe mechaniki poziomu 2 — 2026-11-01
- Użytkownik zaakceptował dodanie nowych mechanik lub wykorzystanie elementów z poziomu 1, aby ograniczyć monotonię.
- Dodano `scripts/moving_platform.gd`: ruchome platformy, sinusoidalny, przewidywalny ruch, parametry okresu i przemieszczenia. W Zielonych Wyspach występują 3 egzemplarze na wyższej trasie.
- Dodano `scripts/crumbling_platform.gd`: platformy zapadające się po wejściu gracza (opóźnienie 0,55 s, odtworzenie po 2 s), z sygnalizacją kolorem. Na poziomie 2 występują 3 egzemplarze, ustawione nad bezpiecznym terenem, aby uczyć mechaniki przed użyciem jej jako wymagającej przeszkody.
- Zaktualizowano `tests/game_flow_test.gd` o obecność i podstawową reakcję nowych elementów; wynik GitHub Actions należy zweryfikować.
- Nadal obowiązuje pełny restart poziomu po śmierci, bez checkpointów. Cel 5 minut nie jest potwierdzony pomiarem.
- Test ręczny: sprawdzić ruch platform wraz z graczem, aktywację zapadających się pomostów, poprawność odtwarzania kolizji oraz czy nowe mechaniki faktycznie zmniejszają monotonię. W następnej iteracji można budować sekwencje bardziej angażujące, ale dopiero po weryfikacji bazowych mechanik.

## Przeprawa wahadłowa — 2026-11-01
- Życzenie użytkownika: szeroka przepaść, oczekiwanie aż ruchoma platforma przypłynie do brzegu, przejazd i zeskok na drugi brzeg.
- Po wyspie nr 7 w indeksowaniu od 1 (indeks 6 w kodzie) ustawiono **przepaść 144 px** zamiast 32 px; usunięto standardowy stały mostek w tym miejscu.
- `GapShuttle` kursuje poziomo na środku przepaści (amplituda 54 px, okres 4 s). Na brzegu dodano znacznik miejsca oczekiwania. Platforma korzysta z istniejącego `scripts/moving_platform.gd` i grafiki `platform_green.tscn`.
- Test `tests/game_flow_test.gd` sprawdza szerokość wyróżnionej przepaści, brak stałego mostku i obecność kursującej platformy.
- Manualnie do sprawdzenia: czy rycerz stabilnie stoi na ruchomej platformie, potrafi na nią wskoczyć i wyskoczyć oraz czy ruchomy pomost nie zostawia możliwości nieuczciwej śmierci. Brak checkpointów; śmierć restartuje cały poziom.
