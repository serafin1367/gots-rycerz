# World TileSet — katalog i zasady generatora

Źródło: `assets/sprites/world_tileset.png`. Kafelek bazowy ma **16×16 px**. Dane strukturalne znajdują się w `assets/data/world_tile_catalog.json`, a odczyt w `scripts/world_tile_catalog.gd`.

## Status rozpoznania
- **confirmed**: potwierdzone przez użytkownika lub sprawdzone na istniejącej scenie; mogą być użyte zgodnie z metadanymi.
- **probable**: wstępna klasyfikacja na podstawie obrazu; **współrzędne i granice obiektu mogą wymagać korekty**.
- **unknown**: nie przypisujemy kolizji ani zachowania bez ustalenia mechaniki.

### Potwierdzone do generowania
- `grass_top` (0,0): warstwa nośna, pełna kolizja.
- `rock_a` (1,0), `rock_b` (1,1), `dirt` (0,1): pełne podłoże pod trawą.
- `wave_blue` (4,9) i `wave_variant` (4,12): kafelki o tematyce wodnej **nie nadają się na kafelkowane niebo**. Kolizję / reakcję na wodę należy zdefiniować osobno.

### Wstępnie rozpoznane
- Inne palety podłoża: jasny piasek, szary kamień, żółty, różowy, lodowy.
- Roślinność: drzewa, krzewy i palmy; część grafik zajmuje obszar większy niż 16×16.
- Grzyby i drewniane konstrukcje.
- Bloki specjalne ze znakami zapytania i wykrzyknika.

Nie zakładamy, że inne palety mają takie same właściwości jak trawa, ani że obiekty ozdobne mają kolizję.

## Otwarte kwestie wymagające potwierdzenia
1. Czy różnokolorowe powierzchnie oznaczają osobne biomy, czy inne zachowanie fizyczne?
2. Czy bloki z `?` i `!` aktywują mechaniki; jakie?
3. Czy woda, kolorowe płyny i fale mają być wyłącznie wizualne, śmiertelne czy umożliwiać pływanie?
4. Czy drzewa, grzyby i drewniane elementy blokują ruch?
5. Które wielokafelkowe dekoracje są kompletne i jakie mają wymiary?

## Zasady implementacyjne
Oddzielne warstwy: Sky (jednolita barwa), Background (bez kolizji), Water (złożona powierzchnia), Terrain (kolizja), Decoration, Objects. Nigdy nie powielać kafelka fali jako całego nieba. Tylko `confirmed` może trafić automatycznie do geometrii kolizyjnej. Powtarzanie układu opiera się na seedzie.

Ta klasyfikacja jest **wersją 1**; nie jest kompletną, zweryfikowaną listą wszystkich komórek atlasu.
