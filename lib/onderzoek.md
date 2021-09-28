# Onderzoek Reusable Flutter Google Maps Track&Trace Widget #


## Inleiding ##
Aanleiding: 
Doel van dit onderzoek is om uit te vinden hoe ik in dart een package kan maken die door andere apps gebruikt kan worden om gemakkelijk een google map te gebruiken met 2 locaties en een route daartussen.
Aan de hand van dit onderzoek wordt er een Proof of Concept uitgewerkt en deze wordt gedurende de Beep app uitgewerkt in een volwaardige package die ook voor andere apps gebruikt kan gaan worden.


## Stappenplan ##
Uitzoeken hoe de basis Google Map flutter plugin werkt
* aanvragen google API key
* benodigde plugins ophalen
* klein demoproject maken om een map te laten zien van doetinchem
* 2 marker posities toevoegen voor de start en eindlocatie van de track&trace route
* via google apis de route tussen de twee punten ophalen en deze aan de gebruiker laten zien.

~Dit is voltooid~

Uitzoeken hoe je een eigen package maakt in flutter
* bestaande packages bekijken, in dit geval heb ik google_maps_flutter als voorbeeld genomen.
* in flutter een nieuwe package maken met de juiste package instellingen
* opzetten van de hoofdstruktuur en de nodige dependencies van de package(package is afhankelijk van 3 andere packages (dit moet zo laag mogelijk blijven))
* Example project toevoegen aan de package waarin het basis GoogleTrackTraceMap() component wordt gedemonstreerd. Zoals ook wordt gedaan voor de mainstream flutter packages.
* Benodigde basisfunctionaliteit voor track&trace schrijven voor de package(route tussen 2 punten laten zien).

~Dit is voltooid~

Flexibel maken van de package zodat het makkelijker/beter te gebruiken is
* Bij het aanmaken van GoogleTrackTraceMap() zorgen dat de nodige argumenten kunnen worden meegegeven zoals start en eindlocatie
* Controller toevoegen die kan worden opgehaald door de parent app om controle op de GoogleTrackTraceMap() uit te oefenen.
* Periodieke timer toevoegen die de route in een custom interval kan ophalen
* Controller laten luisteren naar een Stream om updates te krijgen van de huidige locatie van de target.
* Configureerbare map styling toevoegen
* Goed handelen van de Google API Key


Advanced
* Schrijven van unit tests voor de component


## Onderzoekgedeelte ##

Onderzoek naar de werken van de Google Maps API

Onderzoek naar flutter packages

Onderzoek naar Controllers

Onderzoek naar Stream listeneners en Futures voor de controllers

Onderzoek naar het testen van een dart/flutter component

### links used: ###
* https://flutter.dev/docs/cookbook/networking/fetch-data voor het maken van requests naar google apis en het omzetten van de response
* https://stackoverflow.com/questions/56200113/flutter-google-maps-remove-poi-layer remove google maps layers

* https://developers.google.com/maps/documentation/javascript/style-reference google styling reference

* https://mapstyle.withgoogle.com/ mapstyle configurator

* https://www.raywenderlich.com/19421827-creating-and-publishing-a-flutter-package blog about creating packages

* https://flutter.dev/docs/development/packages-and-plugins/developing-packages flutter official package documentation

* https://stackoverflow.com/questions/67323570/how-to-add-live-location-tracking-in-flutter-map
