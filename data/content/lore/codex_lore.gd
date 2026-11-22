class_name CodexLore
extends RefCounted
## Dados canônicos de História e Facções do Códice de ABYSSAL PACT.
## Baseado em WORLD_LORE.md e nos cânones dos quatro continentes.

static func get_history_entries() -> Array[Dictionary]:
	return [
		{
			"id": "HIST-001",
			"title": "A Grande Ruptura e a Fenda Abissal",
			"era": "Era Antiga",
			"text": "Nos primórdios dos quatro continentes, o véu entre a realidade física e o vazio abissal se desfez através de uma catástrofe telúrica. As energias primordiais corromperam os ecossistemas, erguendo vulcões perpétuos em Veyrath, despertando as brumas fantasmagóricas de Sylvaran, calcinando as terras de Khar-Duum e submergindo as falésias de Nhal'Kora sob marés de névoa fria."
		},
		{
			"id": "HIST-002",
			"title": "A Queda dos Quatro Reinos",
			"era": "Primeiro Século do Abismo",
			"text": "As civilizações ancestrais que dominavam as planícies e florestas sucumbiram à primeira invasão dos duzentos demônios regionais e seus trinta soberanos. Os castelos e ciadadelas foram reduzidos a cinzas e escombros, forçando os sobreviventes a fundar postos fortificados e baluartes subterrâneos para preservar sua linhagem."
		},
		{
			"id": "HIST-003",
			"title": "O Despertar da Hell Forge",
			"era": "Era dos Pactos",
			"text": "Nas entranhas do cosmos abissal, a Hell Forge acendeu suas chamas perpétuas. Conhecida como o coração do renascimento, tornou-se o refúgio inescapável e ponto de ressurgimento sagrado para todos os portadores da marca abissal. Nenhum herói ou guerreiro que perece em batalha encontra o descanso final: a Forja reclama sua essência e o devolve ao combate, eternamente vinculado ao destino do mundo."
		},
		{
			"id": "HIST-004",
			"title": "A Doutrina dos Pactos Abissais",
			"era": "Presente",
			"text": "Incapazes de derrotar as hordas demoníacas apenas com aço comum, os guerreiros aprenderam a forjar Pactos com as forças telúricas e espirituais de cada continente. Ao canalizar as cinzas de Veyrath, as raízes de Sylvaran, a pedra de Khar-Duum ou o vórtice de Nhal'Kora, o combatente transcende seus limites em troca de carregar o fardo das profundezas."
		}
	]

static func get_faction_entries() -> Array[Dictionary]:
	return [
		{
			"id": "FACT-001",
			"name": "Os Forjadores das Cinzas",
			"continent": "Veyrath",
			"leader": "Guardião Ignis de Basalto",
			"alignment": "Militar / Defensivo",
			"motto": "No calor da forja, a fraqueza é consumida.",
			"description": "Ordem de artífices, ferreiros e sentinelas baseada no Baluarte das Cinzas. Dedicam-se a manter as barreiras de contenção das fendas de lava e fornecer armas temperadas aos caçadores."
		},
		{
			"id": "FACT-002",
			"name": "O Círculo Espectral de Sylvaran",
			"continent": "Sylvaran",
			"leader": "Arquidruidesa Althea das Raízes",
			"alignment": "Místico / Protetor",
			"motto": "As árvores antigas tudo sentem, a terra tudo lembra.",
			"description": "Comunidade de arcanistas e xamãs que habitam o Bosque das Almas. Estudam as perturbações na seiva vital e combatem a corrupção das criaturas errantes nos pântanos."
		},
		{
			"id": "FACT-003",
			"name": "A Legião de Basalto",
			"continent": "Khar-Duum",
			"leader": "Senhor da Fortaleza Kaelen",
			"alignment": "Guerreiros Disciplinados",
			"motto": "Inabaláveis como o penhasco, implacáveis como a tempestade.",
			"description": "Força marcial sediada na Fortaleza de Basalto que patrulha os cânions e as dunas de areia negra, contendo os leviatãs terrestres e desenterrando artefatos dos templos soterrados."
		},
		{
			"id": "FACT-004",
			"name": "Os Sentinelas do Abismo Oceânico",
			"continent": "Nhal'Kora",
			"leader": "Vigia Thalor das Marés",
			"alignment": "Sentinelas Herméticos",
			"motto": "Nas profundezas do silêncio repousa a vigília eterna.",
			"description": "Ordem litorânea que vigia os faróis e quebra-mares da Cidadela dos Afogados. Monitoram o fluxo de névoas marinhas e os vórtices abissais que ameaçam arrastar a costa para as fossas."
		}
	]
