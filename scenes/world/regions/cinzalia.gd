class_name CinzaliaRegion
extends Region001Veyrath
## Protótipo Canônico de Referência: CINZÁLIA (Veyrath / REG-001).
##
## Modelo de referência do Pipeline de Construção de Ambientes 3D de ABYSSAL PACT.
## Incorpora:
## - Terreno próprio com elevação, rochas vulcânicas e fenda de magma.
## - Malha de navegação (NavigationRegion3D) para IA de demônios e jogador.
## - Vegetação escassa calcinada (árvores e arbustos de espinhos de cinzas).
## - Estruturas modulares e ruínas imperiais (arcos, pilares caídos, muralhas de bastião, torre em ruínas).
## - Props ambientais (boulders, agulhas basálticas, bordas de cratera, braseiros acesos).
## - Sistema atmosférico (WorldEnvironment, neblina volumétrica, partículas de cinzas caindo).
## - Iluminação Dark Fantasy (luz direcional com sombras em cascata e luzes de fogo).
## - Pontos de interesse: Baluarte das Cinzas (SafeZone), Catacumbas de Basalto (Dungeon),
##   Arena de BOSS-001, Monólito do Primeiro Pacto, Mirante da Fenda e Portais.

func _ready() -> void:
	super._ready()
