"""
ABYSSAL PACT — GERADOR DO CATÁLOGO DOS 300 MONSTROS E RELATÓRIO DE PRODUÇÃO 3D
Estrutura os 300 monstros distribuídos rigorosamente nas 10 famílias canônicas:
- Humanoides monstruosos: 001–040 (40)
- Feras e predadores: 041–080 (40)
- Répteis e criaturas dracônicas: 081–110 (30)
- Mortos-vivos: 111–145 (35)
- Demônios e abissais: 146–185 (40)
- Gigantes e colossos: 186–210 (25)
- Criaturas mágicas e elementais: 211–240 (30)
- Insetos e aracnídeos: 241–265 (25)
- Criaturas aquáticas: 266–285 (20)
- Criaturas raras e anomalias: 286–300 (15)
TOTAL = 300 monstros
"""

import json
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))

DATA_OUT_DIR = os.path.join(PROJECT_DIR, "data", "content", "monsters")
REPORT_PATH = os.path.join(PROJECT_DIR, "MONSTER_3D_PRODUCTION_REPORT.md")
JSON_CATALOG_PATH = os.path.join(DATA_OUT_DIR, "monsters_300_catalog.json")

os.makedirs(DATA_OUT_DIR, exist_ok=True)

# Definição dos metadados das 10 famílias e nomes canônicos das 300 criaturas
FAMILIES_CONFIG = [
    {
        "family": "Humanoides monstruosos",
        "folder": "Humanoids",
        "start_id": 1,
        "count": 40,
        "base_names": [
            ("Ogro das Cinzas", "Veyrath (Zareth)", "REG-001", "Vulcânico", "Pântano de Escória", "#3d3733", "#ff5500"),
            ("Ciclope da Cordilheira", "Khar'Duum (Varkhenn)", "REG-021", "Glacial", "Picos de Gelo", "#5a6577", "#a0c4ff"),
            ("Orc Corrupto das Fendas", "Veyrath (Zareth)", "REG-003", "Cinzas", "Cavernas de Fogo", "#2d4428", "#ff3300"),
            ("Troll das Cavernas Profundas", "Nhal'Kora (Nythoria)", "REG-031", "Rochoso", "Subterrâneo", "#4a4238", "#88aa33"),
            ("Goblin Rastreador de Pântano", "Sylvaran (Eldrath)", "REG-011", "Pântano", "Manguezal Oculto", "#3a5c2d", "#ddff44"),
            ("Minotauro do Labirinto de Ferro", "Veyrath (Zareth)", "REG-007", "Basalto", "Forte em Ruínas", "#422818", "#ffaa00"),
            ("Gnoll Hiena Carniceiro", "Nhal'Kora (Nythoria)", "REG-034", "Árido", "Estepes Rochosas", "#7c5e3f", "#ff2200"),
            ("Homem-Lagarto das Marismas", "Sylvaran (Eldrath)", "REG-015", "Aquático", "Deltas Alagados", "#2b6348", "#ffcc00"),
            ("Xamã Bugbear dos Bosques", "Sylvaran (Eldrath)", "REG-013", "Florestal", "Bosque Ancestral", "#533827", "#9933ff"),
            ("Sátiro Corrompido pelo Abismo", "Sylvaran (Eldrath)", "REG-018", "Mágico", "Arboretos Negros", "#4d3040", "#ff0066"),
            ("Morlock Cego dos Abismos", "Nhal'Kora (Nythoria)", "REG-038", "Subterrâneo", "Fossas Causticas", "#8c949e", "#ffffff"),
            ("Canibal das Terras Ermas", "Veyrath (Zareth)", "REG-005", "Desolado", "Planícies de Cinza", "#6e4d41", "#cc1100"),
            ("Homem-Fera Uivador", "Sylvaran (Eldrath)", "REG-014", "Selvagem", "Penhascos Verdes", "#594236", "#eeaa44"),
            ("Guerreiro Kobold das Minas", "Khar'Duum (Varkhenn)", "REG-025", "Mineral", "Galerias de Prata", "#6b3324", "#ff8800"),
            ("Espreitador Troglodita", "Nhal'Kora (Nythoria)", "REG-033", "Cavernas", "Lagos Subterrâneos", "#4b5742", "#88ffcc"),
            ("Ogro Berzerker Blindado", "Veyrath (Zareth)", "REG-002", "Militar", "Muralha Imperial", "#34373d", "#ff4411"),
            ("Assassino Rato-Humanoide", "Nhal'Kora (Nythoria)", "REG-032", "Urbano", "Esgotos Antigos", "#403532", "#bb3333"),
            ("Gigante das Colinas Caçador", "Sylvaran (Eldrath)", "REG-017", "Montanhoso", "Vales Abertos", "#735c49", "#ddaa55"),
            ("Feiticeiro Harpia Alada", "Khar'Duum (Varkhenn)", "REG-023", "Picos", "Ninhos Suspensos", "#4c485c", "#aa44ff"),
            ("Centauro Guardião Decadente", "Sylvaran (Eldrath)", "REG-019", "Estepes", "Campos Corrompidos", "#503829", "#33ccaa"),
            ("Matriarca Medusa de Pedra", "Nhal'Kora (Nythoria)", "REG-036", "Ruínas", "Templos Esquecidos", "#3d473d", "#00ff88"),
            ("Hobgoblin General de Cerco", "Veyrath (Zareth)", "REG-008", "Militar", "Acampamentos Fortificados", "#592b23", "#ff6622"),
            ("Guardião Ciclope Forjado", "Khar'Duum (Varkhenn)", "REG-028", "Gélido", "Forjas de Gelo", "#384759", "#44ffff"),
            ("Bandido Feral das Dunas", "Nhal'Kora (Nythoria)", "REG-035", "Desértico", "Ravinas de Areia", "#87684b", "#ff9933"),
            ("Fanático Herege das Cinzas", "Veyrath (Zareth)", "REG-009", "Cálido", "Altares Profanados", "#382e2c", "#ff2211"),
            ("Guardião Minotauro Rúnico", "Veyrath (Zareth)", "REG-004", "Rúnico", "Santuários Ocultos", "#2e2118", "#ffaa33"),
            ("Troll das Geadas Boreal", "Khar'Duum (Varkhenn)", "REG-022", "Nevado", "Glaciares Eternos", "#4b607a", "#aae0ff"),
            ("Ogro Flagelador Abissal", "Veyrath (Zareth)", "REG-010", "Corrompido", "Fendas do Selo", "#2b1418", "#ff0033"),
            ("Ladrão de Sepulcros Mumificado", "Nhal'Kora (Nythoria)", "REG-037", "Criptas", "Mausoléus", "#695b45", "#ccccaa"),
            ("Campeão Orc da Guarda Negra", "Veyrath (Zareth)", "REG-006", "Fortaleza", "Baluartes de Basalto", "#1e2b1c", "#ff3322"),
            ("Bárbaro Primitivo Selvagem", "Sylvaran (Eldrath)", "REG-012", "Selva", "Florestas Nebulosas", "#634735", "#ffaa66"),
            ("Necromante Humanoide Exilado", "Nhal'Kora (Nythoria)", "REG-039", "Sombrio", "Laboratórios Ocultos", "#262330", "#33ffaa"),
            ("Espreitador das Sombras Feral", "Khar'Duum (Varkhenn)", "REG-026", "Subalpino", "Túneis de Neve", "#22252e", "#6688ff"),
            ("Cultista Dracônico Escamado", "Veyrath (Zareth)", "REG-001", "Vulcânico", "Crateras de Lava", "#4a1c18", "#ff7700"),
            ("Atirador Goblin de Pólvora", "Khar'Duum (Varkhenn)", "REG-024", "Industrial", "Minas de Ferro", "#4d5435", "#ffcc22"),
            ("Guardião Gárgula Viva", "Nhal'Kora (Nythoria)", "REG-040", "Monumentos", "Cúpulas da Necrópole", "#424247", "#88aaff"),
            ("Homem-Fera Predador Alfa", "Sylvaran (Eldrath)", "REG-016", "Floresta", "Cordilheiras Ancestrais", "#423024", "#ee7722"),
            ("Verme-Humanoide das Profundezas", "Nhal'Kora (Nythoria)", "REG-034", "Abissal", "Fossas Causticas", "#5e4b52", "#ff3388"),
            ("Soldado de Ferro Corrompido", "Veyrath (Zareth)", "REG-007", "Blindado", "Oficinas Abandonadas", "#2b2e36", "#ff5522"),
            ("Matriarca Lamia Serpentina", "Nhal'Kora (Nythoria)", "REG-036", "Oásis", "Ruínas de Jade", "#284a3c", "#ffee33"),
        ]
    },
    {
        "family": "Feras e predadores",
        "folder": "Beasts",
        "start_id": 41,
        "count": 40,
        "base_names": [
            ("Lobo do Gelo Eterno", "Khar'Duum (Varkhenn)", "REG-021", "Tundra", "Cordilheira Boreal", "#dbe8f5", "#00ffff"),
            ("Urso Couraçado das Neves", "Khar'Duum (Varkhenn)", "REG-023", "Glacial", "Cavernas de Nevasca", "#e5ecf0", "#77aaff"),
            ("Pantera das Sombras Abissais", "Sylvaran (Eldrath)", "REG-014", "Selva", "Copas das Árvores", "#18141f", "#bb44ff"),
            ("Javali Fendido de Magma", "Veyrath (Zareth)", "REG-003", "Vulcânico", "Encostas Ardentes", "#3b1e16", "#ff4400"),
            ("Dente-de-Sabre do Deserto", "Nhal'Kora (Nythoria)", "REG-032", "Árido", "Canyons Vermelhos", "#8f6b43", "#ffaa33"),
            ("Hiena Carniceira Corrompida", "Nhal'Kora (Nythoria)", "REG-035", "Savana", "Campos de Ossos", "#5c4832", "#ff2200"),
            ("Serpente Constritora de Espinhos", "Sylvaran (Eldrath)", "REG-012", "Pântano", "Rios de Lodo", "#274728", "#88ff33"),
            ("Morcego Vampiro Titânico", "Nhal'Kora (Nythoria)", "REG-037", "Cavernas", "Galerias Escuras", "#2b2024", "#cc0033"),
            ("Rinoceronte Pedregoso", "Veyrath (Zareth)", "REG-006", "Rochoso", "Desfiladeiros de Basalto", "#474542", "#dd6622"),
            ("Lobo Cinzento das Cinzas", "Veyrath (Zareth)", "REG-001", "Cálido", "Planície das Cinzas", "#423e3d", "#ff6600"),
            ("Águia Gigante dos Cumes", "Khar'Duum (Varkhenn)", "REG-022", "Picos", "Ninhos de Vento", "#54463d", "#ffdd88"),
            ("Gorila Prateado da Selva", "Sylvaran (Eldrath)", "REG-015", "Montanha", "Penhascos Verdes", "#38373b", "#77ccff"),
            ("Mastodonte Lanoso Ancestral", "Khar'Duum (Varkhenn)", "REG-025", "Planície Gélida", "Tundra de Permafrost", "#523c2d", "#ffffff"),
            ("Raposa Espiritual do Bosque", "Sylvaran (Eldrath)", "REG-018", "Mágico", "Arboretos Feéricos", "#bf5e26", "#00ffaa"),
            ("Leão Alado Manticoriano", "Nhal'Kora (Nythoria)", "REG-039", "Deserto", "Dunas Esculpidas", "#916f43", "#ff3322"),
            ("Escorpião-Lobo Caçador", "Nhal'Kora (Nythoria)", "REG-033", "Rochas", "Ravinas de Areia", "#423226", "#ff8800"),
            ("Crocodilo Couraçado de Lodo", "Sylvaran (Eldrath)", "REG-013", "Aquático", "Deltas Lamacentos", "#2a3d2c", "#aacc44"),
            ("Chacal das Tumbas Profanadas", "Nhal'Kora (Nythoria)", "REG-038", "Ruínas", "Cemitérios de Basalto", "#40372f", "#44ffaa"),
            ("Lince da Tundra Furtivo", "Khar'Duum (Varkhenn)", "REG-024", "Taiga", "Florestas Congeladas", "#8593a3", "#aaddff"),
            ("Búfalo das Chamas Abissais", "Veyrath (Zareth)", "REG-008", "Vulcânico", "Lagos de Piche", "#261a1a", "#ff5500"),
            ("Cão Infernal Voraz", "Veyrath (Zareth)", "REG-004", "Enxofre", "Crateras Ardentes", "#211516", "#ff2200"),
            ("Falcão de Obsidiana Afiado", "Veyrath (Zareth)", "REG-002", "Picos", "Torres Caídas", "#1f1f21", "#ff7733"),
            ("Urso de Magma da Caldeira", "Veyrath (Zareth)", "REG-010", "Caldeira", "Fendas Terrestres", "#301d18", "#ff6600"),
            ("Tigre Dourado das Dunas", "Nhal'Kora (Nythoria)", "REG-036", "Areias", "Oásis Secos", "#c4923b", "#ffffff"),
            ("Salamandra Gigante do Limo", "Sylvaran (Eldrath)", "REG-017", "Submerso", "Córregos Musgosos", "#294034", "#44ff88"),
            ("Texugo Gigante Enfurecido", "Sylvaran (Eldrath)", "REG-011", "Tocas", "Raízes Antigas", "#3d3228", "#ee9944"),
            ("Morcego Glacial Sônico", "Khar'Duum (Varkhenn)", "REG-027", "Cavernas de Gelo", "Estalactites", "#6b839e", "#88ffff"),
            ("Alce Sagrado Corrompido", "Sylvaran (Eldrath)", "REG-019", "Clareira", "Bosque das Flores", "#523f32", "#ff0088"),
            ("Leopardo das Neves Feral", "Khar'Duum (Varkhenn)", "REG-028", "Escarpas", "Cordilheiras Altas", "#bfc7cf", "#55bbff"),
            ("Coiote Espinhoso de Ferro", "Veyrath (Zareth)", "REG-005", "Minérios", "Campos de Sucata", "#3b3836", "#ffaa44"),
            ("Serpente de Coral Venenosa", "Sylvaran (Eldrath)", "REG-016", "Marismas", "Costas Tropicais", "#8f2222", "#00ffcc"),
            ("Urso Pardo Guardião da Caverna", "Sylvaran (Eldrath)", "REG-020", "Montanhoso", "Florestas Altas", "#453225", "#dd9944"),
            ("Doninha Caçadora Carnívora", "Khar'Duum (Varkhenn)", "REG-029", "Túneis", "Galerias de Neve", "#dedede", "#ff5555"),
            ("Macaco Titânico das Selvas", "Sylvaran (Eldrath)", "REG-014", "Densa", "Floresta Equatorial", "#3b2c24", "#eedd88"),
            ("Tatu Couraçado Megalítico", "Nhal'Kora (Nythoria)", "REG-031", "Savana", "Campos Pedregosos", "#5e5244", "#ff8844"),
            ("Lobo Espectral Uivador", "Khar'Duum (Varkhenn)", "REG-030", "Gélido", "Lagos Congelados", "#7d97b3", "#44eeff"),
            ("Warg de Montaria Selvagem", "Veyrath (Zareth)", "REG-007", "Planaltos", "Gargantas Profundas", "#382924", "#ff4422"),
            ("Pássaro do Trovão Tempestuoso", "Khar'Duum (Varkhenn)", "REG-026", "Tempestuoso", "Nuvens de Gelo", "#394d69", "#ffff44"),
            ("Glutão Voraz da Meia-Noite", "Sylvaran (Eldrath)", "REG-012", "Noturno", "Pântano Negro", "#241f21", "#ff3355"),
            ("Gato Selvagem das Brumas", "Sylvaran (Eldrath)", "REG-018", "Neblina", "Vales Encantados", "#5a6369", "#44ffaa"),
        ]
    },
    {
        "family": "Répteis e criaturas dracônicas",
        "folder": "Reptiles_Dragons",
        "start_id": 81,
        "count": 30,
        "base_names": [
            ("Draconiano Vulcânico", "Veyrath (Zareth)", "REG-001", "Magma", "Gargantas de Lava", "#2b1410", "#ff9900"),
            ("Wyrm do Gelo Boreal", "Khar'Duum (Varkhenn)", "REG-021", "Glacial", "Fissuras de Neve", "#40647a", "#00eeff"),
            ("Basilisco dos Olhos Petrificantes", "Nhal'Kora (Nythoria)", "REG-033", "Rochas", "Ruínas Antigas", "#2b3b29", "#00ff66"),
            ("Hidra das Sete Cabeças Venenosas", "Sylvaran (Eldrath)", "REG-013", "Pântano", "Lodaçais Fétidos", "#1f3b2e", "#88ff22"),
            ("Drake das Chamas Rastejante", "Veyrath (Zareth)", "REG-005", "Basalto", "Campos de Cinzas", "#421812", "#ff3300"),
            ("Serpente Alada Emplumada", "Sylvaran (Eldrath)", "REG-016", "Tropical", "Copas Altas", "#1c4a3e", "#ffdd33"),
            ("Lagarto Espinhoso do Deserto", "Nhal'Kora (Nythoria)", "REG-031", "Árido", "Dunas de Areia", "#7a5c37", "#ff8833"),
            ("Dragão-Tartaruga de Casco Rochoso", "Sylvaran (Eldrath)", "REG-015", "Aquático", "Costas e Estuários", "#2e4236", "#66ccaa"),
            ("Wyvern das Tempestades", "Khar'Duum (Varkhenn)", "REG-024", "Picos", "Cumes Congelados", "#304359", "#44bbff"),
            ("Crocodilo Ancião Dracônico", "Sylvaran (Eldrath)", "REG-011", "Alagado", "Pântano de Cipós", "#243322", "#ffbb22"),
            ("Salamandra Flamejante Incandescente", "Veyrath (Zareth)", "REG-008", "Vulcânico", "Lagos de Enxofre", "#3b170e", "#ff7700"),
            ("Lagarto Eletrizado das Fendas", "Veyrath (Zareth)", "REG-003", "Mineral", "Minas de Ferro", "#273340", "#ffee22"),
            ("Serpente do Abismo Sombria", "Nhal'Kora (Nythoria)", "REG-037", "Subterrâneo", "Fossas Negras", "#171821", "#9933ff"),
            ("Víbora Alada das Neves", "Khar'Duum (Varkhenn)", "REG-027", "Gélido", "Florestas Congeladas", "#7b91a3", "#aae0ff"),
            ("Tartaruga Blindada do Magma", "Veyrath (Zareth)", "REG-009", "Lava", "Rios Incandescentes", "#381a14", "#ff4411"),
            ("Drake da Areia Devorador", "Nhal'Kora (Nythoria)", "REG-035", "Desértico", "Ravinas Esculpidas", "#87663e", "#dd7722"),
            ("Iguana Gigante Venenosa", "Sylvaran (Eldrath)", "REG-017", "Úmido", "Cachoeiras e Musgos", "#2f5235", "#ff2266"),
            ("Wyrm de Pedra Ancestral", "Nhal'Kora (Nythoria)", "REG-038", "Cavernas", "Salões Monumentais", "#454341", "#ffbb66"),
            ("Lagarto Camaleão Furtivo", "Sylvaran (Eldrath)", "REG-014", "Densa", "Selva Alta", "#385e43", "#ffff55"),
            ("Drake Glacial de Chifres Cristalinos", "Khar'Duum (Varkhenn)", "REG-022", "Picos", "Penhascos de Gelo", "#567794", "#77ffff"),
            ("Verme Dracônico do Subsolo", "Nhal'Kora (Nythoria)", "REG-034", "Criptas", "Galerias Cegas", "#403130", "#ff4455"),
            ("Serpente de Obsidiana Venenosa", "Veyrath (Zareth)", "REG-004", "Rochoso", "Canions Escuros", "#1a171c", "#aa22ff"),
            ("Gargula Reptiliana dos Telhados", "Nhal'Kora (Nythoria)", "REG-040", "Cidades", "Templos Perdidos", "#444447", "#88ccff"),
            ("Dragão Pigmeu dos Bosques", "Sylvaran (Eldrath)", "REG-018", "Mágico", "Clareiras Antigas", "#28543f", "#33ffaa"),
            ("Drake das Neves Caçador", "Khar'Duum (Varkhenn)", "REG-023", "Nevado", "Vales Alpinos", "#8ea1b0", "#66ccee"),
            ("Basilisco Vulcânico Incandescente", "Veyrath (Zareth)", "REG-007", "Basalto", "Gargantas de Cinza", "#361612", "#ff6600"),
            ("Wyrm de Cristal das Maravilhas", "Khar'Duum (Varkhenn)", "REG-026", "Cristalino", "Grutas de Geleira", "#4a6d8c", "#88ffff"),
            ("Lagarto Aquático Couraçado", "Sylvaran (Eldrath)", "REG-019", "Rios", "Lagoas Profundas", "#1d362a", "#55dd99"),
            ("Drake da Morte Decadente", "Nhal'Kora (Nythoria)", "REG-039", "Sepulcros", "Tumbas Profanadas", "#2b292c", "#00ff88"),
            ("Dragão Esmeralda da Floresta", "Sylvaran (Eldrath)", "REG-020", "Ancestral", "Coração do Bosque", "#174730", "#44ffaa"),
        ]
    },
    {
        "family": "Mortos-vivos",
        "folder": "Undead",
        "start_id": 111,
        "count": 35,
        "base_names": [
            ("Cavaleiro Espectral da Cripta", "Nhal'Kora (Nythoria)", "REG-031", "Sombrio", "Mausoléus Antigos", "#32383a", "#00ffaa"),
            ("Zumbi Gladiador Putrefato", "Nhal'Kora (Nythoria)", "REG-033", "Ruínas", "Arenas de Sangue", "#47453b", "#ff2222"),
            ("Lich Menor dos Segredos Ocultos", "Nhal'Kora (Nythoria)", "REG-038", "Arcano", "Bibliotecas Esquecidas", "#232130", "#aa44ff"),
            ("Esqueleto Guerreiro da Legião", "Veyrath (Zareth)", "REG-002", "Militar", "Muralha Imperial", "#8a8377", "#ffaa33"),
            ("Aparição Gélida Vingativa", "Khar'Duum (Varkhenn)", "REG-022", "Glacial", "Passos Congelados", "#708ba1", "#55ffff"),
            ("Carniçal Carnívoro dos Túmulos", "Nhal'Kora (Nythoria)", "REG-034", "Criptas", "Necrópoles", "#3d3830", "#cc4433"),
            ("Banshee dos Bosques Lamuriosos", "Sylvaran (Eldrath)", "REG-013", "Místico", "Pântanos Solitários", "#3a4a47", "#66ffcc"),
            ("Esqueleto Arqueiro Incandescente", "Veyrath (Zareth)", "REG-006", "Vulcânico", "Torres de Cinza", "#4a4441", "#ff5500"),
            ("Múmia Preservada em Betume", "Nhal'Kora (Nythoria)", "REG-036", "Deserto", "Câmaras de Pirâmide", "#61533c", "#dd9933"),
            ("Senhor dos Túmulos Blindado", "Nhal'Kora (Nythoria)", "REG-039", "Sepulcro", "Criptas Imperiais", "#24252b", "#33ffaa"),
            ("Espectro das Brumas Nebulosas", "Sylvaran (Eldrath)", "REG-018", "Neblina", "Pântanos Mágicos", "#394547", "#55ddff"),
            ("Cavaleiro da Morte Sem Cabeça", "Veyrath (Zareth)", "REG-008", "Maldito", "Campos de Batalha", "#28262e", "#ff0044"),
            ("Zumbi de Gelo Preservado", "Khar'Duum (Varkhenn)", "REG-025", "Permafrost", "Fossas de Gelo", "#5c7385", "#88eeff"),
            ("Esqueleto Lanceiro do Forte", "Veyrath (Zareth)", "REG-004", "Fortaleza", "Bastiões de Basalto", "#78736b", "#ff8833"),
            ("Vampiro Nobre Decadente", "Nhal'Kora (Nythoria)", "REG-040", "Urbano", "Palácios Abandonados", "#211c24", "#cc1133"),
            ("Noviço Cultista Esquelético", "Nhal'Kora (Nythoria)", "REG-032", "Templos", "Altares Profanados", "#59544c", "#9955ff"),
            ("Vulto Sombrio Sugador de Almas", "Sylvaran (Eldrath)", "REG-017", "Escuro", "Cavernas Úmidas", "#191921", "#33ffbb"),
            ("Zumbi Couraçado com Escudo", "Veyrath (Zareth)", "REG-007", "Blindado", "Portais Imperial", "#3b3d42", "#ee6622"),
            ("Espectro do Vento Uivador", "Khar'Duum (Varkhenn)", "REG-026", "Tempestuoso", "Geleiras de Altitude", "#5e778f", "#77ffff"),
            ("Abominação Suturada de Corpos", "Nhal'Kora (Nythoria)", "REG-035", "Laboratório", "Valas Comuns", "#423832", "#ff3322"),
            ("Sombra Rastejante Noturna", "Sylvaran (Eldrath)", "REG-014", "Noite", "Copas Densas", "#17141f", "#aa00ff"),
            ("Esqueleto Montado em Cervo Morto", "Sylvaran (Eldrath)", "REG-019", "Estepes", "Campos Secos", "#4f4a43", "#44eeaa"),
            ("Guardião da Cripta Imortal", "Nhal'Kora (Nythoria)", "REG-037", "Portais", "Santuários Mortuários", "#303238", "#22ff99"),
            ("Zumbi Alagado de Pântano", "Sylvaran (Eldrath)", "REG-012", "Aquático", "Deltas Alagados", "#334032", "#88cc44"),
            ("Fantasma de Mineiro Aprisionado", "Khar'Duum (Varkhenn)", "REG-028", "Minas", "Galerias de Prata", "#4e6375", "#66ffff"),
            ("Feiticeira Necrótica Voraz", "Nhal'Kora (Nythoria)", "REG-034", "Círculos", "Túmulos Coletivos", "#2d2636", "#ee44ff"),
            ("Esqueleto Gigante Quebrado", "Veyrath (Zareth)", "REG-005", "Ruínas", "Cemitérios de Titãs", "#635f58", "#ff9922"),
            ("Zumbi Devorador de Cérebros", "Nhal'Kora (Nythoria)", "REG-031", "Subterrâneo", "Criptas Ocultas", "#403934", "#dd4433"),
            ("Espírito das Cinzas Errante", "Veyrath (Zareth)", "REG-003", "Cinzas", "Caldeiras Ardentes", "#3b393b", "#ff5500"),
            ("Banshee dos Glaciares Eternos", "Khar'Duum (Varkhenn)", "REG-023", "Frio Extremo", "Cavernas de Cristal", "#698399", "#88eeff"),
            ("Guardião Faraônico Mumificado", "Nhal'Kora (Nythoria)", "REG-036", "Monumentos", "Templos de Ouro", "#544936", "#ffbb33"),
            ("Cavaleiro Zumbi com Lança", "Veyrath (Zareth)", "REG-009", "Militar", "Bastião das Cinzas", "#38363b", "#ff4411"),
            ("Aparição dos Naufrágios", "Sylvaran (Eldrath)", "REG-015", "Costeiro", "Carcaças de Barcos", "#334547", "#33ffcc"),
            ("Esqueleto Mago de Gelo", "Khar'Duum (Varkhenn)", "REG-027", "Glacial", "Torres Boreal", "#596f85", "#66ddff"),
            ("Lorde Cadavérico das Sombras", "Nhal'Kora (Nythoria)", "REG-040", "Necrópole", "Trono Caído", "#1f1d26", "#00ffaa"),
        ]
    },
    {
        "family": "Demônios e abissais",
        "folder": "Demons_Abyssals",
        "start_id": 146,
        "count": 40,
        "base_names": [
            ("Demônio Farpado dos Abismos", "Verdadeiro Inferno", "REG-000", "Abissal", "Fendas do Selo", "#1f1115", "#ff2200"),
            ("Empalador Demoníaco Alado", "Verdadeiro Inferno", "REG-000", "Abissal", "Picos de Sangue", "#241416", "#ff3322"),
            ("Besta de Enxofre Abissal", "Veyrath (Zareth)", "REG-001", "Vulcânico", "Lagos de Enxofre", "#331c12", "#ff7700"),
            ("Súcubo Tentadora do Vazio", "Verdadeiro Inferno", "REG-000", "Sobrenatural", "Palácios de Tortura", "#2b1626", "#ff0077"),
            ("Demônio Devorador de Fogo", "Veyrath (Zareth)", "REG-008", "Fogo", "Fornalhas do Inferno", "#3b160e", "#ff5500"),
            ("Espreitador Abissal Quatro-Olhos", "Verdadeiro Inferno", "REG-000", "Sombrio", "Cavernas de Sangue", "#17121c", "#9922ff"),
            ("Cão do Tártaro de Três Cabeças", "Verdadeiro Inferno", "REG-000", "Guarda", "Portões da Forja", "#1c1417", "#ff3300"),
            ("Demônio Encouraçado de Basalto", "Veyrath (Zareth)", "REG-004", "Rochoso", "Desfiladeiros Negros", "#2b292c", "#ff6622"),
            ("Bruxa do Caos Infernal", "Verdadeiro Inferno", "REG-000", "Mágico", "Altares de Sacrifício", "#241829", "#cc22ff"),
            ("Demônio de Gelo Abissal", "Khar'Duum (Varkhenn)", "REG-025", "Gélido", "Fissuras de Permafrost", "#253b4d", "#00ffff"),
            ("Carrasco Abissal com Machado", "Verdadeiro Inferno", "REG-000", "Brutal", "Pátios de Execução", "#211517", "#ee2211"),
            ("Demônio Serpentino Rastejante", "Verdadeiro Inferno", "REG-000", "Marismas", "Poços de Veneno", "#1c261e", "#33ff44"),
            ("Vorme do Sangue Fervente", "Verdadeiro Inferno", "REG-000", "Fossas", "Rios de Sangue", "#381014", "#ff1133"),
            ("Inquisidor Alado da Perdição", "Verdadeiro Inferno", "REG-000", "Aéreo", "Torres Espetadas", "#1f1721", "#ff44aa"),
            ("Demônio da Peste Putrefato", "Sylvaran (Eldrath)", "REG-011", "Pântano", "Pântanos Corrompidos", "#2b3624", "#88cc22"),
            ("Lorde Demoníaco dos Espinhos", "Verdadeiro Inferno", "REG-000", "Coroado", "Tronos de Ossos", "#1c141a", "#ff0055"),
            ("Demônio Soldado da Guarda Vermelha", "Veyrath (Zareth)", "REG-002", "Militar", "Muralhas da Invasão", "#361618", "#ff3311"),
            ("Aberração Caótica Multifacetada", "Verdadeiro Inferno", "REG-000", "Anomalia", "Fendas do Tempo", "#24182c", "#ee33ff"),
            ("Demônio Forjador das Almas", "Veyrath (Zareth)", "REG-007", "Forja", "Bigornas de Ferro", "#2e1e18", "#ffaa33"),
            ("Espírito Vingador do Purgatório", "Verdadeiro Inferno", "REG-000", "Eclético", "Caminho dos Condenados", "#2b212e", "#8844ff"),
            ("Gárgula Abissal de Chifres Longos", "Verdadeiro Inferno", "REG-000", "Sentinela", "Muralhas do Tártaro", "#211f24", "#ff5544"),
            ("Demônio Rastreador Veloz", "Sylvaran (Eldrath)", "REG-014", "Selva", "Florestas Ocultas", "#261d19", "#ff6633"),
            ("Flagelo Demoníaco com Chicote", "Verdadeiro Inferno", "REG-000", "Punição", "Calabouços do Horror", "#2b141a", "#ff2244"),
            ("Criatura Abissal Tentacular", "Nhal'Kora (Nythoria)", "REG-038", "Subterrâneo", "Poços Negros", "#1a1721", "#6622ff"),
            ("Demônio dos Olhos de Chama", "Veyrath (Zareth)", "REG-005", "Cinzas", "Planalto Vulcânico", "#2b1c19", "#ffaa00"),
            ("Lorde da Praga de Moscas", "Sylvaran (Eldrath)", "REG-013", "Praga", "Manguezais Podres", "#262b1e", "#aacc33"),
            ("Besta Abissal da Devastação", "Verdadeiro Inferno", "REG-000", "Pesado", "Planícies de Ossos", "#211215", "#ff1122"),
            ("Demônio Guardião do Portal", "Veyrath (Zareth)", "REG-010", "Portal", "Selo da Fenda", "#1c1921", "#ff4422"),
            ("Sombra Demoníaca Furtiva", "Nhal'Kora (Nythoria)", "REG-035", "Areia", "Canyons Escuros", "#141417", "#ff00aa"),
            ("Demônio das Correntes de Aço", "Verdadeiro Inferno", "REG-000", "Prisão", "Torres de Suplício", "#2b292e", "#ff7744"),
            ("Incendiário Abissal Voraz", "Veyrath (Zareth)", "REG-009", "Incêndio", "Bosques Queimados", "#381711", "#ff8800"),
            ("Demônio Carniceiro com Cutelo", "Verdadeiro Inferno", "REG-000", "Carnificina", "Matadouros", "#2e1418", "#cc2233"),
            ("Espectro Abissal das Profundezas", "Verdadeiro Inferno", "REG-000", "Vazio", "Abismo Sem Fim", "#13131c", "#3388ff"),
            ("Demônio Rúnico Guardião do Pacto", "Veyrath (Zareth)", "REG-006", "Rúnico", "Santuários Ocultos", "#291b1f", "#ff9944"),
            ("Criatura Abissal Parasita", "Sylvaran (Eldrath)", "REG-017", "Parasitismo", "Raízes Corrompidas", "#291d24", "#ff3399"),
            ("Titã Demoníaco do Cerco", "Verdadeiro Inferno", "REG-000", "Colossal", "Acampamento Militar", "#211417", "#ff2211"),
            ("Arauto da Destruição Abissal", "Verdadeiro Inferno", "REG-000", "Arauto", "Trono do Caos", "#241521", "#ff4466"),
            ("Demônio de Sangue Mágico", "Verdadeiro Inferno", "REG-000", "Feitiço", "Círculos de Invocação", "#26131c", "#ee2244"),
            ("Demônio Alado Guarda-Costas", "Verdadeiro Inferno", "REG-000", "Guarda", "Fortaleza do Inferno", "#1f171b", "#ff5533"),
            ("Monarca Abissal da Escuridão", "Verdadeiro Inferno", "REG-000", "Rei", "Câmara Central", "#17121a", "#ff0066"),
        ]
    },
    {
        "family": "Gigantes e colossos",
        "folder": "Giants_Colossi",
        "start_id": 186,
        "count": 25,
        "base_names": [
            ("Gigante do Fogo Ancestral", "Veyrath (Zareth)", "REG-001", "Vulcânico", "Crateras Ardentes", "#3b1e19", "#ff6600"),
            ("Colosso de Gelo Boreal", "Khar'Duum (Varkhenn)", "REG-021", "Glacial", "Glaciares Eternos", "#4b6782", "#77ffff"),
            ("Gigante das Montanhas Rochoso", "Khar'Duum (Varkhenn)", "REG-024", "Rochoso", "Picos Elevados", "#57524d", "#ddaa66"),
            ("Colosso de Granito Guardião", "Sylvaran (Eldrath)", "REG-019", "Granito", "Monumentos Arcanos", "#404245", "#00ffaa"),
            ("Gigante das Tempestades de Raio", "Khar'Duum (Varkhenn)", "REG-026", "Tempestuoso", "Nuvens de Trovão", "#374354", "#ffee33"),
            ("Colosso das Areias Desértico", "Nhal'Kora (Nythoria)", "REG-032", "Deserto", "Dunas Gigantes", "#806648", "#ffaa44"),
            ("Gigante da Floresta Ancião", "Sylvaran (Eldrath)", "REG-020", "Florestal", "Árvores Gigantes", "#364536", "#88ee44"),
            ("Colosso de Ferro Forjado", "Veyrath (Zareth)", "REG-007", "Metálico", "Oficinas da Forja", "#30333b", "#ff8822"),
            ("Gigante das Cavernas Cego", "Nhal'Kora (Nythoria)", "REG-037", "Subterrâneo", "Salões Monumentais", "#4a423a", "#dd7744"),
            ("Colosso de Magma Indomável", "Veyrath (Zareth)", "REG-008", "Magma", "Lagos de Fogo", "#301812", "#ff4400"),
            ("Gigante das Geadas de Duas Cabeças", "Khar'Duum (Varkhenn)", "REG-023", "Gélido", "Vales Congelados", "#526e8a", "#aae0ff"),
            ("Colosso Esmeralda de Jade", "Sylvaran (Eldrath)", "REG-016", "Místico", "Templos de Jade", "#1f4a38", "#44ffaa"),
            ("Gigante Corrompido pelo Selo", "Veyrath (Zareth)", "REG-010", "Abissal", "Fendas do Vazio", "#291b21", "#ff0044"),
            ("Colosso de Ossos de Titãs", "Nhal'Kora (Nythoria)", "REG-035", "Necrótico", "Campos de Guerra", "#63594b", "#33ff99"),
            ("Gigante Lançador de Pedras", "Khar'Duum (Varkhenn)", "REG-022", "Escarpas", "Desfiladeiros", "#544c45", "#eeaa55"),
            ("Colosso das Brumas Flutuante", "Sylvaran (Eldrath)", "REG-018", "Nebuloso", "Arboretos Feéricos", "#4c5c5c", "#77ffdd"),
            ("Gigante Encouraçado de Bronze", "Nhal'Kora (Nythoria)", "REG-031", "Bronze", "Portões Antigos", "#6e5535", "#ffbb44"),
            ("Colosso de Cristal Ressonante", "Khar'Duum (Varkhenn)", "REG-027", "Cristal", "Cavernas de Luz", "#43657a", "#88ffff"),
            ("Gigante de Cinzas Flamejante", "Veyrath (Zareth)", "REG-003", "Cinzas", "Chaminés Vulcânicas", "#3d3330", "#ff7711"),
            ("Colosso dos Mares Costeiro", "Sylvaran (Eldrath)", "REG-015", "Marinho", "Falésias do Oceano", "#284447", "#55ccbb"),
            ("Gigante Carniceiro com Porrete", "Nhal'Kora (Nythoria)", "REG-034", "Ruínas", "Arenas de Pedra", "#594a3d", "#dd4422"),
            ("Colosso Necrótico Imortal", "Nhal'Kora (Nythoria)", "REG-039", "Maldito", "Necrópoles Reais", "#2e2b33", "#00ff88"),
            ("Gigante Couraçado com Martelo", "Veyrath (Zareth)", "REG-006", "Fortaleza", "Baluartes Altos", "#38373b", "#ff9933"),
            ("Colosso de Gelo com Chifres", "Khar'Duum (Varkhenn)", "REG-025", "Gelo", "Paredões Alpinos", "#587a94", "#99ffff"),
            ("Titã Colossal do Juízo Final", "Verdadeiro Inferno", "REG-000", "Apocalíptico", "Portões do Inferno", "#1f1519", "#ff2200"),
        ]
    },
    {
        "family": "Criaturas mágicas e elementais",
        "folder": "Magical_Elementals",
        "start_id": 211,
        "count": 30,
        "base_names": [
            ("Golem de Cristal Arcano", "Sylvaran (Eldrath)", "REG-019", "Arcano", "Monólitos Mágicos", "#374151", "#10b981"),
            ("Elemental do Fogo Primordial", "Veyrath (Zareth)", "REG-001", "Fogo", "Fissuras de Magma", "#38150d", "#ff5500"),
            ("Elemental do Gelo Puro", "Khar'Duum (Varkhenn)", "REG-021", "Gelo", "Geleiras Eternas", "#3d647d", "#44eeff"),
            ("Elemental da Terra Viva", "Sylvaran (Eldrath)", "REG-012", "Terra", "Raízes Ancestrais", "#453b30", "#88ee44"),
            ("Elemental do Ar Tempestuoso", "Khar'Duum (Varkhenn)", "REG-026", "Vento", "Vórtices de Altitude", "#45596e", "#ffff66"),
            ("Fada Negra da Ilusão", "Sylvaran (Eldrath)", "REG-018", "Feérico", "Arboretos Negros", "#2e1a2b", "#ff00bb"),
            ("Golem de Pedra Rúnica", "Nhal'Kora (Nythoria)", "REG-031", "Rúnico", "Santuários Perdidos", "#474645", "#33aaff"),
            ("Espírito da Chama Azul", "Veyrath (Zareth)", "REG-007", "Chama Mágica", "Forjas Místicas", "#172738", "#00bbff"),
            ("Golem de Areia Movediça", "Nhal'Kora (Nythoria)", "REG-033", "Areia", "Dunas Vivas", "#7a6245", "#ffaa44"),
            ("Elemental da Luz Radiante", "Sylvaran (Eldrath)", "REG-020", "Sagrado", "Clareiras Solares", "#69634b", "#ffffaa"),
            ("Golem de Magma Vulcânico", "Veyrath (Zareth)", "REG-008", "Vulcânico", "Caldeiras Ardentes", "#30150e", "#ff4400"),
            ("Espírito da Água Curativa", "Sylvaran (Eldrath)", "REG-015", "Água", "Fontes Cristalinas", "#213f47", "#33ffff"),
            ("Ent Protetor da Floresta", "Sylvaran (Eldrath)", "REG-017", "Madeira", "Bosque de Carvalho", "#3b3024", "#66cc33"),
            ("Fênix de Cinzas Ressurgida", "Veyrath (Zareth)", "REG-002", "Picos", "Ninhos de Cinza", "#4a1c12", "#ffaa22"),
            ("Golem de Gelo e Espinhos", "Khar'Duum (Varkhenn)", "REG-023", "Gélido", "Cavernas de Cristal", "#506e87", "#88ffff"),
            ("Elemental das Sombras do Vazio", "Nhal'Kora (Nythoria)", "REG-038", "Sombra", "Salões Escuros", "#16151c", "#8822ff"),
            ("Espírito da Tempestade de Neve", "Khar'Duum (Varkhenn)", "REG-024", "Neve", "Nevascas Cegas", "#657d94", "#bbeeaa"),
            ("Golem de Lama Fétida", "Sylvaran (Eldrath)", "REG-011", "Lama", "Pântano de Lodo", "#333829", "#88aa22"),
            ("Elemental do Raio Fulgurante", "Khar'Duum (Varkhenn)", "REG-028", "Eletricidade", "Picos de Atração", "#353d4f", "#ffee33"),
            ("Fada da Morte Noturna", "Sylvaran (Eldrath)", "REG-014", "Noite", "Floresta Negra", "#211b29", "#ff22aa"),
            ("Golem de Obsidiana Lapidada", "Veyrath (Zareth)", "REG-004", "Obsidiana", "Fendas Vitrificadas", "#17181c", "#ff6622"),
            ("Espírito Guardião da Árvore-Mãe", "Sylvaran (Eldrath)", "REG-016", "Natureza", "Tronco Monumental", "#28452f", "#44ff88"),
            ("Elemental de Piche e Fogo", "Veyrath (Zareth)", "REG-009", "Piche", "Lagos Negros", "#211917", "#ff5500"),
            ("Golem de Cristal de Ametista", "Nhal'Kora (Nythoria)", "REG-036", "Cristal", "Minas de Gemas", "#362142", "#cc44ff"),
            ("Elemental do Vento Cortante", "Khar'Duum (Varkhenn)", "REG-022", "Vento", "Desfiladeiros de Gelo", "#51697d", "#99ffff"),
            ("Espírito do Rio Encantado", "Sylvaran (Eldrath)", "REG-013", "Fluvial", "Cachoeiras de Jade", "#1f4741", "#33ffcc"),
            ("Golem de Ouro Amaldiçoado", "Nhal'Kora (Nythoria)", "REG-037", "Tesouro", "Tumbas Reais", "#66542c", "#ffdd44"),
            ("Elemental da Gravidade Distorcida", "Verdadeiro Inferno", "REG-000", "Espacial", "Fendas Dimensionais", "#1b1926", "#aa00ff"),
            ("Golem de Sangue Conjurado", "Verdadeiro Inferno", "REG-000", "Sangue", "Altares Carmesins", "#381216", "#ff1133"),
            ("Seráfico Caído de Asas Quebradas", "Verdadeiro Inferno", "REG-000", "Luz Corrompida", "Trono Quebrado", "#2e2b36", "#ffee88"),
        ]
    },
    {
        "family": "Insetos e aracnídeos",
        "folder": "Insects_Arachnids",
        "start_id": 241,
        "count": 25,
        "base_names": [
            ("Aranha Tecelã das Sombras", "Sylvaran (Eldrath)", "REG-014", "Teias", "Copas Densas", "#1c1821", "#9900ff"),
            ("Escorpião Titânico das Areias", "Nhal'Kora (Nythoria)", "REG-032", "Deserto", "Dunas Vermelhas", "#6e4b2d", "#ff6600"),
            ("Besouro Couraçado das Cinzas", "Veyrath (Zareth)", "REG-001", "Vulcânico", "Planícies de Cinza", "#292625", "#ff4411"),
            ("Louva-a-Deus Gigante Carnívoro", "Sylvaran (Eldrath)", "REG-016", "Tropical", "Folhagens Altas", "#2c4f2e", "#88ff33"),
            ("Centopeia Monstruosa do Subsolo", "Nhal'Kora (Nythoria)", "REG-034", "Túneis", "Galerias Cegas", "#4a2d28", "#ff3322"),
            ("Vespa Gigante Ferrão-de-Fogo", "Veyrath (Zareth)", "REG-005", "Ninhos", "Penhascos de Basalto", "#3d2b18", "#ffbb00"),
            ("Aranha do Gelo e Presas de Cristal", "Khar'Duum (Varkhenn)", "REG-023", "Glacial", "Cavernas Congeladas", "#466278", "#00ffff"),
            ("Escaravelho Necrótico Dourado", "Nhal'Kora (Nythoria)", "REG-036", "Criptas", "Sarcófagos", "#5c4a24", "#ffd700"),
            ("Barata Gigante Carniceira", "Nhal'Kora (Nythoria)", "REG-033", "Esgotos", "Fossas Antigas", "#3b2b22", "#aa4422"),
            ("Aranha Viúva-Negra Venenosa", "Sylvaran (Eldrath)", "REG-012", "Pântano", "Troncos Ocos", "#141417", "#ff0022"),
            ("Besouro Rinoceronte Blindado", "Sylvaran (Eldrath)", "REG-017", "Florestal", "Raízes de Carvalho", "#2b2a29", "#eeaa44"),
            ("Formiga Soldado Titânica", "Nhal'Kora (Nythoria)", "REG-035", "Formigueiro", "Canyons Escavados", "#40201c", "#ff4422"),
            ("Mariposa Venenosa da Morte", "Sylvaran (Eldrath)", "REG-018", "Noturno", "Clareiras Místicas", "#3d3240", "#cc44ff"),
            ("Escorpião Cavernoso de Obsidiana", "Veyrath (Zareth)", "REG-004", "Subterrâneo", "Grutas de Ferro", "#19191c", "#ff5500"),
            ("Aranha Saltadora dos Penhascos", "Khar'Duum (Varkhenn)", "REG-025", "Escarpas", "Paredões de Pedra", "#404c57", "#77ccff"),
            ("Centopeia Glacial Gélida", "Khar'Duum (Varkhenn)", "REG-027", "Neve", "Geleiras Profundas", "#58728a", "#88eeff"),
            ("Gafanhoto Devorador de Safra", "Nhal'Kora (Nythoria)", "REG-031", "Campos", "Estepes Abertas", "#4a4c28", "#eedd44"),
            ("Besouro Explosivo de Enxofre", "Veyrath (Zareth)", "REG-008", "Enxofre", "Crateras Gasosas", "#382414", "#ff8800"),
            ("Aranha Carnívora das Marismas", "Sylvaran (Eldrath)", "REG-013", "Lodaçal", "Raízes Submersas", "#263628", "#44dd66"),
            ("Larva Gigante Devoradora", "Nhal'Kora (Nythoria)", "REG-037", "Carniça", "Valas Fétidas", "#6b5e52", "#ff3333"),
            ("Escaravelho Blindado de Rocha", "Veyrath (Zareth)", "REG-006", "Basalto", "Trilhas Pedregosas", "#3b3836", "#dd8844"),
            ("Vespa da Tempestade de Raios", "Khar'Duum (Varkhenn)", "REG-028", "Alta Altitude", "Ninhos Elétricos", "#283445", "#ffff33"),
            ("Aranha das Profundezas Abissais", "Verdadeiro Inferno", "REG-000", "Abissal", "Fendas do Tártaro", "#1a1219", "#ff0066"),
            ("Escorpião Flamejante de Magma", "Veyrath (Zareth)", "REG-010", "Lava", "Fornos do Inferno", "#3b1510", "#ff6600"),
            ("Louva-a-Deus Fantasma das Brumas", "Sylvaran (Eldrath)", "REG-020", "Ancestral", "Coração da Névoa", "#42574e", "#88ffcc"),
        ]
    },
    {
        "family": "Criaturas aquáticas",
        "folder": "Aquatic",
        "start_id": 266,
        "count": 20,
        "base_names": [
            ("Leviatã das Profundezas Abissais", "Sylvaran (Eldrath)", "REG-015", "Oceano", "Fossas Marinhas", "#172b38", "#00ffff"),
            ("Tubarão Couraçado dos Recifes", "Sylvaran (Eldrath)", "REG-016", "Marinho", "Recifes de Coral", "#2b404d", "#77ddff"),
            ("Kraken Menor dos Mares do Sul", "Sylvaran (Eldrath)", "REG-015", "Profundo", "Abismos Oceânicos", "#2e2133", "#ff0066"),
            ("Serpente Marinha das Tempestades", "Khar'Duum (Varkhenn)", "REG-029", "Costeiro Gélido", "Fiordes Congelados", "#334c61", "#55ccff"),
            ("Peixe-Lanterna Abissal Caçador", "Sylvaran (Eldrath)", "REG-015", "Fossas Escuras", "Fundos Oceânicos", "#15181f", "#00ff88"),
            ("Caranguejo Gigante dos Naufrágios", "Veyrath (Zareth)", "REG-002", "Costa", "Carcaças de Navios", "#4a241c", "#ff7700"),
            ("Polvo Camuflado das Rochas", "Sylvaran (Eldrath)", "REG-016", "Rochas Marinhas", "Enseadas Ocultas", "#382936", "#ee44aa"),
            ("Enguia Elétrica dos Rios Negros", "Sylvaran (Eldrath)", "REG-013", "Fluvial", "Rios de Pântano", "#1f3333", "#ffff33"),
            ("Sereia Voraz das Falésias", "Sylvaran (Eldrath)", "REG-019", "Falésias", "Rochedos Marítimos", "#244240", "#66ffcc"),
            ("Tartaruga Gigante dos Corais", "Sylvaran (Eldrath)", "REG-016", "Coral", "Lagunas Azuis", "#294d3f", "#44ffaa"),
            ("Tubarão-Duende das Fossas Cegas", "Sylvaran (Eldrath)", "REG-015", "Profundezas", "Fendas sem Sol", "#453842", "#ff4477"),
            ("Arraia Espinhosa Venenosa", "Nhal'Kora (Nythoria)", "REG-040", "Costeiro", "Deltas Alagados", "#303d36", "#aadd44"),
            ("Serpente do Gelo Submarina", "Khar'Duum (Varkhenn)", "REG-029", "Glacial", "Águas sob o Gelo", "#4c667a", "#88ffff"),
            ("Lula Vampira das Trevas", "Sylvaran (Eldrath)", "REG-015", "Abissal", "Abismos Marinhas", "#24151b", "#cc1144"),
            ("Caranguejo Ermitão de Crânio", "Nhal'Kora (Nythoria)", "REG-038", "Litoral", "Praias de Cinza", "#4d3a2f", "#ff8833"),
            ("Crocodilo Marinho Colossal", "Sylvaran (Eldrath)", "REG-011", "Estuário", "Foz de Rios Grandes", "#233324", "#aacc22"),
            ("Anêmona Gigante Devoradora", "Sylvaran (Eldrath)", "REG-016", "Fundos Rasos", "Recifes Antigos", "#3b213b", "#ff33cc"),
            ("Moreia de Dentes de Sabre", "Sylvaran (Eldrath)", "REG-015", "Fendas Submersas", "Cavernas Marinhas", "#263b36", "#33ff99"),
            ("Medusa Luminosa Letal", "Sylvaran (Eldrath)", "REG-015", "Pelágico", "Mar Aberto", "#2c3b52", "#44eeff"),
            ("Besta Aquática das Enxurradas", "Khar'Duum (Varkhenn)", "REG-030", "Gélido", "Lagos Boreal", "#364c5e", "#77e0ff"),
        ]
    },
    {
        "family": "Criaturas raras e anomalias",
        "folder": "Rare_Anomalies",
        "start_id": 286,
        "count": 15,
        "base_names": [
            ("Anomalia Espacial do Vazio", "Verdadeiro Inferno", "REG-000", "Cósmico", "Fendas Interdimensionais", "#140e1f", "#bb00ff"),
            ("Devorador de Almas Sem Rosto", "Verdadeiro Inferno", "REG-000", "Abissal", "Fronteira da Forja", "#1c141e", "#ff0066"),
            ("Colosso de Mercúrio Líquido", "Nhal'Kora (Nythoria)", "REG-039", "Metálico Raro", "Laboratórios Perdidos", "#788796", "#ffffff"),
            ("Quimera do Caos Elemental", "Verdadeiro Inferno", "REG-000", "Híbrido", "Crateras da Loucura", "#331c29", "#ff5500"),
            ("Serpente do Eclipse Eterno", "Nhal'Kora (Nythoria)", "REG-040", "Celestial", "Torres Astrológicas", "#12141c", "#ffdd33"),
            ("Besta de Pesadelo Onírico", "Sylvaran (Eldrath)", "REG-018", "Onírico", "Clareira dos Sonhos", "#211a2e", "#ee33aa"),
            ("Gárgula de Sangue Cristalizado", "Verdadeiro Inferno", "REG-000", "Cristal de Sangue", "Altares Místicos", "#330f16", "#ff1144"),
            ("Titã do Tempo Fraturado", "Nhal'Kora (Nythoria)", "REG-038", "Temporal", "Câmaras de Ampulheta", "#383630", "#33ffff"),
            ("Olho Flutuante da Loucura", "Verdadeiro Inferno", "REG-000", "Ocular", "Cúpulas do Tártaro", "#261a29", "#ff0055"),
            ("Elemental de Antimatéria Pura", "Verdadeiro Inferno", "REG-000", "Energia Escura", "Fosso Sem Fim", "#0d0b14", "#7700ff"),
            ("Horror Cego das Raízes do Mundo", "Sylvaran (Eldrath)", "REG-020", "Subterrâneo Profundo", "Raiz Primordial", "#1c2419", "#33ff66"),
            ("Colosso Gravitacional Implosivo", "Veyrath (Zareth)", "REG-010", "Gravidade", "Epicentro do Selo", "#241f2e", "#ff8800"),
            ("Besta Amorfa das Sombras", "Nhal'Kora (Nythoria)", "REG-035", "Mórfico", "Oásis Negro", "#14141a", "#00ffcc"),
            ("Arauto do Fim dos Reinos", "Verdadeiro Inferno", "REG-000", "Apocalipse", "Portão da Ruína", "#1f1017", "#ff2200"),
            ("Anomalia da Criação Corrompida", "Verdadeiro Inferno", "REG-000", "Primordial", "Origem Abissal", "#211429", "#ff00aa"),
        ]
    }
]

def generate_catalog():
    print("======================================================================")
    print("GERANDO CATÁLOGO CANÔNICO DOS 300 MONSTROS DE ABYSSAL PACT")
    print("======================================================================")

    monsters = []
    current_global_id = 1

    for config in FAMILIES_CONFIG:
        family_name = config["family"]
        folder_name = config["folder"]
        count = config["count"]
        start_id = config["start_id"]
        base_names = config["base_names"]

        for idx in range(count):
            monster_id = f"MONSTER_{current_global_id:03d}"
            name_tuple = base_names[idx] if idx < len(base_names) else (f"{family_name[:-1]} Espécime {idx+1}", "Veyrath (Zareth)", "REG-001", "Geral", "Terrenos Ermos", "#3a3a3a", "#ff5500")
            
            nome = name_tuple[0]
            continente = name_tuple[1]
            regiao = name_tuple[2]
            bioma = name_tuple[3]
            habitat = name_tuple[4]
            cor_base = name_tuple[5]
            cor_emissao = name_tuple[6]

            # Arquivos associados
            clean_name = nome.replace(" ", "_").replace("'", "").replace("-", "_")
            blend_file = f"assets/3d/monsters/{folder_name}/{monster_id}_{clean_name}.blend"
            glb_file = f"assets/3d/monsters/{folder_name}/{monster_id}_{clean_name}.glb"
            preview_file = f"assets/3d/monsters/Previews/{monster_id}_{clean_name}.png"

            # Marcar os 5 primeiros pilotos
            is_pilot = current_global_id in [1, 41, 81, 111, 211]

            monster_entry = {
                "id": monster_id,
                "numeric_id": current_global_id,
                "name": nome,
                "clean_id": f"{monster_id}_{clean_name}",
                "family": family_name,
                "folder": folder_name,
                "continent": continente,
                "region": regiao,
                "biome": bioma,
                "habitat": habitat,
                "base_color_hex": cor_base,
                "emission_color_hex": cor_emissao,
                "is_pilot": is_pilot,
                "blend_path": blend_file,
                "glb_path": glb_file,
                "preview_path": preview_file,
                "status": "Concluído (Piloto)" if is_pilot else "Catalogado / Planejado",
                "model_state": "Modelado (Blender 5.3)" if is_pilot else "Pendente",
                "materials_state": "PBR Aplicado" if is_pilot else "Pendente",
                "textures_state": "Mapeado" if is_pilot else "Pendente",
                "uv_state": "Funcional" if is_pilot else "Pendente",
                "rig_state": "Armature Ativa" if is_pilot else "Pendente",
                "animations_state": "Animações Ativas" if is_pilot else "Pendente",
                "inspection_state": "Aprovado (Piloto)" if is_pilot else "Pendente"
            }
            monsters.append(monster_entry)
            current_global_id += 1

    # 1. Salvar JSON Estruturado
    with open(JSON_CATALOG_PATH, "w", encoding="utf-8") as f:
        json.dump({"total_monsters": len(monsters), "monsters": monsters}, f, indent=2, ensure_ascii=False)
    print(f"-> Catálogo JSON salvo com sucesso: {JSON_CATALOG_PATH} ({len(monsters)} monstros)")

    # 2. Salvar Relatório Markdown MONSTER_3D_PRODUCTION_REPORT.md
    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        f.write("# RELATÓRIO DE PRODUÇÃO DOS 300 MONSTROS 3D — ABYSSAL PACT\n\n")
        f.write("**Engine 3D:** Blender 5.3.0 Local via Python `bpy` | **Motor de Jogo:** Godot 4.7.2 Forward+\n")
        f.write(f"**Total Catalogado:** {len(monsters)} Criaturas | **Lotes:** 60 lotes de 5 monstros\n\n")
        f.write("---\n\n")
        f.write("## 1. RESUMO GERAL DAS 10 FAMÍLIAS CANÔNICAS\n\n")
        f.write("| Família | Quantidade | IDs | Pasta no Projeto | Status do Lote |\n")
        f.write("|---|---:|---|---|---|\n")
        f.write("| Humanoides monstruosos | 40 | MONSTER_001–040 | `Assets/3D/Monsters/Humanoids/` | Piloto 001 Concluído |\n")
        f.write("| Feras e predadores | 40 | MONSTER_041–080 | `Assets/3D/Monsters/Beasts/` | Piloto 041 Concluído |\n")
        f.write("| Répteis e criaturas dracônicas | 30 | MONSTER_081–110 | `Assets/3D/Monsters/Reptiles_Dragons/` | Piloto 081 Concluído |\n")
        f.write("| Mortos-vivos | 35 | MONSTER_111–145 | `Assets/3D/Monsters/Undead/` | Piloto 111 Concluído |\n")
        f.write("| Demônios e abissais | 40 | MONSTER_146–185 | `Assets/3D/Monsters/Demons_Abyssals/` | Planejado em Lotes |\n")
        f.write("| Gigantes e colossos | 25 | MONSTER_186–210 | `Assets/3D/Monsters/Giants_Colossi/` | Planejado em Lotes |\n")
        f.write("| Criaturas mágicas e elementais | 30 | MONSTER_211–240 | `Assets/3D/Monsters/Magical_Elementals/` | Piloto 211 Concluído |\n")
        f.write("| Insetos e aracnídeos | 25 | MONSTER_241–265 | `Assets/3D/Monsters/Insects_Arachnids/` | Planejado em Lotes |\n")
        f.write("| Criaturas aquáticas | 20 | MONSTER_266–285 | `Assets/3D/Monsters/Aquatic/` | Planejado em Lotes |\n")
        f.write("| Criaturas raras e anomalias | 15 | MONSTER_286–300 | `Assets/3D/Monsters/Rare_Anomalies/` | Planejado em Lotes |\n")
        f.write("| **TOTAL** | **300** | | | **100% Mapeado** |\n\n")
        f.write("---\n\n")
        f.write("## 2. TABELA COMPLETA DE REGISTRO E PRODUÇÃO DOS 300 MONSTROS\n\n")
        f.write("| ID | Nome Original | Família | Continente | Modelagem | Materiais | Texturas | UV | Rig | Animações | Blender (.blend) | Export (.glb) | Inspeção |\n")
        f.write("|---|---|---|---|---|---|---|---|---|---|---|---|---|\n")

        for m in monsters:
            f.write(f"| {m['id']} | {m['name']} | {m['family']} | {m['continent']} | {m['model_state']} | {m['materials_state']} | {m['textures_state']} | {m['uv_state']} | {m['rig_state']} | {m['animations_state']} | `{os.path.basename(m['blend_path'])}` | `{os.path.basename(m['glb_path'])}` | {m['inspection_state']} |\n")

    print(f"-> Relatório Markdown salvo com sucesso: {REPORT_PATH}")
    return monsters

if __name__ == "__main__":
    generate_catalog()
