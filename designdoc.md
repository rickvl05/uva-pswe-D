# Design document
## De game
* Cooperatieve 2-8 multiplayer platformer puzzel game
* Doel is om met het hele team van het startpunt naar het eindpunt van een level te komen
* Spelers gaan door naar het volgende level als het level gehaald is
* Als een speler doodgaat respawnt deze direct weer bij het begin / checkpoint

## Speler interacties
* Bruikbare knoppen
  * W,A,S,D - Bewegen
  * Spatie - Springen
  * K - Item oppakken / Item gooien (als item in hand is)
  * L - Duwen / Item gebruiken (als item in hand is)
* Bewegen en springen
  * Maakt gebruik van input buffering
  * Maakt gebruik van “coyote time”
  * Spelers kunnen niet door elkaar of door items heen bewegen, er vindt collision plaats
  * Als spelers tegen een speler of item aan bewegen wordt het item in de beweegrichting van de speler geduwd
    * Als twee speler richting elkaar bewegen vindt er geen verplaatsing plaats
  * W wordt niet gebruikt om te springen maar om te richten
  * S wordt gebruikt om te bukken en is niet bruikbaar wanneer een item wordt vastgehouden
* Item oppakken
  * Items worden boven het hoofd van de speler gehouden
  * Het item in de kijkrichting van de speler wordt opgepakt
  * Je kan 1 item tegelijk vasthouden
  * Het is mogelijk om spelers op te pakken
  * In de context van het gooien en oppakken gelden dezelfde regels voor spelers als voor items
    * Opgepakte spelers kunnen niet bewegen
    * Opgepakte spelers kunnen wel hun kijkrichting veranderen
    * Opgepakte spelers behouden de oppak, gooi en item functionaliteiten
    * Het is mogelijk om een speler op te pakken die een item of een speler vasthoudt
## Items
* Alle items zijn oppakbare en duwbare rigidbody's
* Krat
  * Vierkante doos die geduwd kan worden
* Tijdbom
  * Bom die na een bepaald aantal seconden explodeert
  * De timer start zodra de bom wordt geduwd of opgepakt
  * De explosie dood spelers en breekt opblaasbare blokken
* Sleutel
  * Opent deurblokken met dezelfde kleur
* Lamp
  * Geeft licht in donkere levels
* Blok onthullende lamp
  * Lamp die verborgen blokken binnen een circulaire radius zichtbaar maakt
## Wereld elementen
* IJsblok
  * Blok met lage wrijving
* Opblaasbaar blok
  * Blok dat opgeblazen kan worden door een tijdbom
* Lage zwaartekracht zone
  * Zone waarin een lagere zwaartekracht werkt dan in andere delen van het spel
* Verborgen blokken
  * Blokken die alleen zichtbaar worden wanneer ze in de buurt zijn van een blok onthullende lamp
  * De texture en collider zijn niet aanwezig wanneer het blok niet in de buurt is van de lamp
* Deur met knop
  * Deur die geopend kan worden door de knop in te drukken
  * De knop kan ingedrukt worden door rigidbody objecten
  * Deuren zijn aan knoppen verbonden op basis van kleur
* Sleuteldeur
  * Deur die geopend wordt door een sleutel item
  * De deur en sleutel zijn verbonden op basis van kleur
## UI
* Hoofdmenu
  * Start - Gaat over naar het "Join menu"
  * Level editor - Gaat over naar de level editor
  * Settings - Gaat over naar het instellingen menu waarin de audio, resolutie en keybinds zijn bij te stellen
  * Quit - Verlaat het spel
* Join menu
  * Geeft de mogelijkheid om een lobby te joinen
* Escape menu
  * Wordt geopend bij het indrukken van escape
  * Bevat settings en quit mogelijkheden
## Lobby
* Spelers worden in dit level geplaatst na het joinen van een spel
* Level waarin het mogelijk is om levels te kiezen
* Wordt gedeeld door meerdere spelers
* Mogelijk om je karakter rond te bewegen in dit level
* Levels worden gekozen op basis van een majority vote
* Het is mogelijk om je vote terug te trekken
