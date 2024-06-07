# Design document
## Speler interacties
Bruikbare knoppen
W,A,S,D - Bewegen
Spatie - Springen
K - Item oppakken / Item gooien (als item in hand is)
L - Duwen / Item gebruiken (als item in hand is)
Bewegen en springen
Maakt gebruik van input buffering
Maakt gebruik van “coyote time”
Spelers kunnen niet door elkaar of door items heen bewegen, er vindt collision plaats
Als spelers tegen een speler of item aan bewegen wordt het item in de beweegrichting van de speler geduwd
Dit gebeurt met een lagere snelheid dan normaal
Als twee speler richting elkaar bewegen vindt er geen verplaatsing plaats
W wordt niet gebruikt om te springen maar om te richten
S wordt gebruikt om te bukken en is niet bruikbaar wanneer een item wordt vastgehouden
Item oppakken
Items worden boven het hoofd van de speler gehouden
Het item in de kijkrichting van de speler wordt opgepakt
Als twee spelers tegelijk een item op proberen te pakken krijgt een willekeurig persoon het item
Je kan 1 item tegelijk vasthouden
Het is mogelijk om spelers op te pakken
In de context van het gooien en oppakken gelden dezelfde regels voor spelers als voor items
Opgepakte spelers kunnen niet bewegen
Opgepakte spelers kunnen wel hun kijkrichting veranderen
Opgepakte spelers behouden de oppak, gooi en item functionaliteiten
Het is mogelijk om een speler op te pakken die een item of een speler vasthoudt
Opgepakte spelers kunnen heen en weer bewegen om vrij te komen?
