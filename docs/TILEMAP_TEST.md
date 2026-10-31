# Test TileMapLayer — world_tileset.png

Otworz `scenes/test_tilemap_level.tscn` w Godot i uruchom **F6** (Biezaca scena). Nie zmieniono poziomu 1 ani proceduralnego poziomu 2.

Scena uzywa oryginalnego atlasu `assets/sprites/world_tileset.png` z siatka 16x16 px. Gorna warstwa to trawa (0,0), ponizej rozmieszczane sa dwa warianty skal (1,0), (1,1) i ziemia (0,1). Tlo (4,9) i (4,12) nie posiada kolizji. Zastosowano dwie warstwy TileMapLayer; fizyka gruntu opiera sie na osobnych, pelnych prostokatach SolidTerrain. Dodano rycerza, 6 monet, jednego slime'a oraz portal.

Wspolrzedne tła i warianty wypelnienia to wstepne mapowanie atlasu; docelowo wymagaja przegladu przy rozszerzaniu katalogu. Portal uzywa obecnej logiki GameFlow; dla bezpiecznego testowania uruchom scene przez F6.

## Korekta warstwy tła
Współrzędne atlasu (4,9) i (4,12) okazały się nieodpowiednie do jednolitego wypełnienia: powodowały powtarzane pasy i fioletowy obszar. Do czasu dokładnej klasyfikacji atlasu scena używa niekolizyjnych wielokątów jednolitego błękitu i ciemniejszego horyzontu. Sama warstwa TileMapLayer tła pozostaje gotowa do przyszłego użycia.
