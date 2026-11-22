#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Abyssal Pact — Banco de Dados Central de Itens, Materiais e Receitas de Loot
Contém a ontologia de materiais por família, continente, bioma, essências demoníacas,
os 70 itens exclusivos dos 10 Primordiais, os 30 núcleos dos Supremos e receitas de crafting.
"""

# Materiais base por família de monstros
FAMILY_MATERIALS = {
    "humanoids": {
        "common": [
            ("mat_leather_crude", "Couro Rústico", "Couro cru obtido de monstros humanoides.", 0.5, 6, "Alfaiataria e curtimento básico."),
            ("mat_bone_splinter", "Lasca de Osso Monstruoso", "Fragmento ósseo resistente.", 0.2, 4, "Criação de cabos de armas e flechas."),
            ("mat_scrap_metal", "Sucata de Ferro Rústico", "Pedaços de metal reaproveitados de armas tribais.", 0.8, 8, "Reforço de armaduras básicas."),
        ],
        "uncommon": [
            ("mat_hide_reinforced", "Couro Trançado Reforçado", "Couro espesso trabalhado para combate.", 0.8, 18, "Armaduras leves e médias."),
            ("mat_sinew_tough", "Tendão Tenaz", "Tendão resistente de guerreiro monstruoso.", 0.3, 14, "Arcos, cordas de disparo e empunhaduras."),
        ],
        "rare": [
            ("mat_tribal_totem", "Totem Tribal Gravado", "Amuleto entalhado com ritos xamânicos.", 0.4, 45, "Acessórios e encantamento de armas."),
            ("mat_muscle_fiber", "Fibra Muscular Densificada", "Tecido muscular endurecido por esforço extremo.", 0.5, 50, "Elixires de força física."),
        ],
        "epic": [
            ("mat_chieftain_crest", "Crista de Líder de Guerra", "Ornamento cerimonial de campeão de tribo.", 0.6, 120, "Forja de elmos e peitorais pesados."),
        ],
        "legendary": [
            ("mat_ancient_warlord_skull", "Crânio de Senhor da Guerra Ancestral", "Relíquia óssea imbuída de fúria bélica.", 1.2, 350, "Forja de armas lendárias e pactos."),
        ]
    },
    "beasts": {
        "common": [
            ("mat_beast_fur", "Pelagem Espessa Selvagem", "Pele felpuda com isolamento térmico.", 0.6, 7, "Forros de armadura e capas térmicas."),
            ("mat_beast_fang", "Presa Afiada Bestial", "Dente pontiagudo de predador selvagem.", 0.2, 5, "Pontas de flechas e lâminas de adagas."),
            ("mat_raw_meat", "Carne Crua de Caça", "Carne densa de criatura selvagem.", 1.0, 3, "Culinária de sobrevivência e iscas."),
        ],
        "uncommon": [
            ("mat_beast_claw", "Garra Curva de Predador", "Garra afiada capaz de rasgar couro.", 0.3, 16, "Manoplas e lâminas serrilhadas."),
            ("mat_beast_leather", "Couro Flexível de Fera", "Pele curtida de alta mobilidade.", 0.7, 20, "Botas, cinturões e estojos de aljava."),
        ],
        "rare": [
            ("mat_beast_heart", "Coração Feroz", "Músculo cardíaco pulsante de fera alfa.", 0.8, 55, "Tônicos de vigor e fúria bestial."),
            ("mat_alpha_fang", "Presa de Predador Alfa", "Presa maciça com resíduos tóxicos.", 0.4, 60, "Armas perfurantes raras."),
        ],
        "epic": [
            ("mat_beast_great_mane", "Juba Imponente de Predador Real", "Pelagem dourada ou cinzenta de grande poder.", 1.0, 140, "Capas majestosas e elmos comemorativos."),
        ],
        "legendary": [
            ("mat_beast_soul_crystal", "Cristal de Alma Bestial", "Alma cristalizada de predador supremo.", 0.5, 400, "Encantamentos supremos e armas míticas."),
        ]
    },
    "reptiles_dragons": {
        "common": [
            ("mat_reptile_scale", "Escama Serpentina Lisa", "Escama flexível e impermeável.", 0.3, 8, "Cotas de escamas e proteção cáustica."),
            ("mat_reptile_bone", "Osso Oco Dracônico", "Osso leve e incrivelmente rígido.", 0.4, 6, "Estruturas de arcos compósitos."),
        ],
        "uncommon": [
            ("mat_dragon_scale_hard", "Placa Dracônica Endurecida", "Escama espessa resistente a calor e cortes.", 0.8, 22, "Armaduras pesadas e escudos."),
            ("mat_venom_sac", "Bolsa de Veneno Reptiliano", "Glândula com toxina hemotóxica concentrada.", 0.4, 18, "Veneno de armas e antídotos potentes."),
        ],
        "rare": [
            ("mat_dragon_blood", "Frasco de Sangue Dracônico", "Sangue fervente que irradia calor térmico.", 0.5, 65, "Elixires de transmutação e forja de lâminas de fogo."),
            ("mat_reptile_eye", "Olho Ambarino de Basilisco", "Globo ocular com reflexos hipnóticos.", 0.3, 70, "Catalisadores mágicos e anéis de percepção."),
        ],
        "epic": [
            ("mat_dragon_horn", "Chifre Espiralado de Serpe", "Chifre denso impregnado de poder elemental.", 1.5, 160, "Lanças dracônicas e martelos de impacto."),
        ],
        "legendary": [
            ("mat_dragon_heart_core", "Núcleo de Coração de Dragão", "Coração ígneo que nunca resfria.", 2.0, 450, "Forja de armas lendárias elementais."),
        ]
    },
    "undead": {
        "common": [
            ("mat_undead_bone", "Osso Quebradiço Tumular", "Fragmento ósseo embranquecido pela morte.", 0.3, 5, "Pós alquímicos e flechas necróticas."),
            ("mat_grave_dust", "Poeira de Cripta", "Cinzas e terra de tumbas antigas.", 0.2, 4, "Rituais de camuflagem e venenos necróticos."),
        ],
        "uncommon": [
            ("mat_cursed_cloth", "Farrapo de Mortalha Amaldiçoada", "Tecido impregnado com energia de maldição.", 0.3, 15, "Túnicas arcanas e proteções espectrais."),
            ("mat_necro_fluid", "Fluido Funerário Embalsamado", "Composto cáustico utilizado em mumificação.", 0.4, 18, "Óleos de corrosão de armadura."),
        ],
        "rare": [
            ("mat_spectral_essence", "Essência Espectral Frigente", "Vapor etéreo recolhido de aparições.", 0.2, 50, "Encantamentos de toque gélido e anéis de mana."),
            ("mat_cursed_skull", "Crânio Sussurrante de Penitente", "Crânio de onde emanam vozes das catacumbas.", 0.8, 55, "Cajados necromânticos e talismãs."),
        ],
        "epic": [
            ("mat_lich_phylactery_shard", "Estilhaço de Filactéria Rompida", "Fragmento de receptáculo anímico profano.", 0.3, 130, "Acessórios de ressurreição e cajados épicos."),
        ],
        "legendary": [
            ("mat_death_monarch_jewel", "Joia da Morte Eterna", "Gema escura lapidada pelos reis das catacumbas.", 0.4, 420, "Relíquias necromânticas supremas."),
        ]
    },
    "demons_abyssals": {
        "common": [
            ("mat_abyssal_fragment", "Fragmento de Rocha Abissal", "Pedra porosa exalando miasma vulcânico.", 0.5, 8, "Ligas de ferro profano na Hell Forge."),
            ("mat_corrupted_flesh", "Retalho de Carne Corrompida", "Massa biológica alterada pela fenda abissal.", 0.4, 6, "Iscas de demônios e alquimia sombria."),
        ],
        "uncommon": [
            ("mat_abyssal_chitin", "Carapaça Miasmática Abissal", "Quitina avermelhada endurecida por fogo infernal.", 0.7, 24, "Armaduras resistentes a dano abissal."),
            ("mat_corrupted_blood", "Sangue Corrompido Fervente", "Ichor negro que corrói solo comum.", 0.4, 20, "Revestimento venenoso e óleos de lâmina."),
        ],
        "rare": [
            ("mat_abyssal_crystal", "Cristal de Fenda Abissal", "Cristal que pulsa em sintonia com Azaroth.", 0.5, 60, "Catalisadores mágicos e forja de pacto."),
            ("mat_demon_gland", "Glândula Pirocáustica", "Órgão interno capaz de produzir chamas fétidas.", 0.6, 65, "Granadas alquímicas e cajados de fogo."),
        ],
        "epic": [
            ("mat_abyssal_core_lesser", "Núcleo de Terror Abissal", "Núcleo compacto de energia do vácuo.", 0.8, 150, "Forja de armas épicas de corrupção."),
        ],
        "legendary": [
            ("mat_abyssal_singularity", "Singularidade Abissal Instável", "Microfenda estilhaçada contida em orbe.", 1.0, 480, "Armas de ruptura dimensional."),
        ]
    },
    "giants_colossi": {
        "common": [
            ("mat_colossus_rubble", "Cascilho de Basalto Maciço", "Fragmento de rocha de grande densidade.", 1.5, 10, "Moagem para argamassa de forja e projéteis."),
            ("mat_giant_bone", "Osso de Gigante Mineralizado", "Osso gigantesco pesado como ferro.", 2.0, 9, "Clavas rústicas e reforços de ariete."),
        ],
        "uncommon": [
            ("mat_colossus_plate", "Placa de Rocha Tectônica", "Placa de pedra vulcânica espessa.", 2.5, 28, "Escudos-torre e peitorais pesadíssimos."),
            ("mat_giant_tendon", "Tendão de Colosso", "Cabo fibroso de tração colossal.", 1.0, 25, "Cordas de balistas e catapultas de cerco."),
        ],
        "rare": [
            ("mat_titan_core", "Núcleo Sísmico de Titã", "Esfera de rocha magnetizada vibrante.", 1.8, 75, "Martelos colossais e runas de terremoto."),
            ("mat_basalt_marrow", "Medula Ígnea de Colosso", "Substância pastosa incandescente retirada de ossos.", 1.2, 70, "Combustível de alta intensidade para a Hell Forge."),
        ],
        "epic": [
            ("mat_tectonic_heart", "Coração Tectônico Pulsante", "Massa rochosa que imita batimento cardíaco.", 3.0, 180, "Armaduras titânicas completas."),
        ],
        "legendary": [
            ("mat_primordial_stone_monolith", "Monólito de Pedra Primordial", "Fragmento original da crosta de Abyssal Pact.", 4.0, 500, "Forja do Martelo do Titã e relíquias de terra."),
        ]
    },
    "magical_elementals": {
        "common": [
            ("mat_magic_dust", "Poeira de Cristal Encantado", "Pó fino brilhante de resíduos arcanos.", 0.2, 8, "Tintas de escriba para pergaminhos e runas."),
            ("mat_elemental_mote", "Centelha de Energia Pura", "Pequeno lampejo elemental instável.", 0.1, 7, "Recarga de varinhas e catalisadores."),
        ],
        "uncommon": [
            ("mat_condensed_ether", "Éter Condensado Líquido", "Fluido mágico translúcido de alta densidade.", 0.3, 22, "Poções de mana pura e solventes arcanos."),
            ("mat_quartz_shard", "Lasca de Quartzo Rúnico", "Cristal piezoelétrico que armazena feitiços.", 0.4, 20, "Anéis arcanos e punhais rúnicos."),
        ],
        "rare": [
            ("mat_elemental_core", "Núcleo de Espírito Elemental", "Orbe luminoso girando em suspensão.", 0.6, 68, "Cajados elementais e amuletos de proteção."),
            ("mat_arcane_prism", "Prisma de Foco Espectral", "Cristal facetado que refrata feixes mágicos.", 0.5, 72, "Catalisadores de feitiço AoE."),
        ],
        "epic": [
            ("mat_elemental_heart", "Coração de Puro Éter", "Massa de pura magia sem forma física fixa.", 0.8, 160, "Mantos arquimagos e cetros supremos."),
        ],
        "legendary": [
            ("mat_primordial_magic_orb", "Orbe de Magia Primordial", "Esfera ancestral contendo leis arcanas intocadas.", 1.0, 460, "Grimórios lendários e cajados supremos."),
        ]
    },
    "insects_arachnids": {
        "common": [
            ("mat_chitin_plate", "Placa de Quitina Lisa", "Segmento de exoesqueleto brilhante e leve.", 0.4, 7, "Armaduras leves de caçador."),
            ("mat_insect_leg", "Pata Espinhosa de Inseto", "Membro articulado com garras pontiagudas.", 0.3, 5, "Agulhas de alfaiataria e flechas de dardo."),
        ],
        "uncommon": [
            ("mat_spider_silk", "Seda de Aranha Abissal", "Fio elástico dez vezes mais forte que o aço.", 0.2, 22, "Arcos, túnicas leves e mantos flexíveis."),
            ("mat_toxic_gland", "Glândula Cáustica de Inseto", "Reservatório de ácido corrosivo concentrado.", 0.4, 18, "Frascos de ácido para quebra de escudo."),
        ],
        "rare": [
            ("mat_venomous_mandible", "Mandíbula Serrilhada Tóxica", "Pinça bucal capaz de esmagar armaduras de placas.", 0.7, 62, "Garras de combate e adagas curvas."),
            ("mat_compound_eye", "Olho Composto Multifacetado", "Órgão sensorial com visão de 360 graus.", 0.3, 58, "Capacetes de rastreamento e óculos de tiro."),
        ],
        "epic": [
            ("mat_hive_queen_carapace", "Carapaça Real de Rainha do Enxame", "Exoesqueleto reforçado por secreção mineral.", 1.2, 145, "Armaduras completas de quitina régia."),
        ],
        "legendary": [
            ("mat_abyssal_arachnid_heart", "Coração do Enxame Infinito", "Núcleo vivo que vibra em frequência de feromônios.", 0.8, 430, "Lâminas-chicote e relíquias de enxame."),
        ]
    },
    "aquatic": {
        "common": [
            ("mat_fish_scale", "Escama Ictíica Iridescente", "Escama cintilante com reflexos marinhos.", 0.3, 7, "Proteção aquática e mantos impermeáveis."),
            ("mat_aquatic_fin", "Barbatana Espinhosa de Maré", "Aleta rígida pontilhada de espículas.", 0.4, 6, "Lâminas de arpão e lemes de canoa."),
        ],
        "uncommon": [
            ("mat_brine_pearl", "Pérola de Salmoura", "Esfera calcária formada em águas abissais frias.", 0.2, 25, "Joias de resistência a frio e água."),
            ("mat_kraken_cartilage", "Cartilagem Tenaz de Mar Profundo", "Tecido flexível capaz de suportar pressões extremas.", 0.6, 22, "Arcos náuticos e cotas flexíveis."),
        ],
        "rare": [
            ("mat_abyssal_coral", "Coral Negro Luminescente", "Ramificação mineral viva que emite luz azulada.", 0.5, 65, "Báculos marinhos e poções de respiração aquática."),
            ("mat_oceanic_heart", "Coração Branquial de Fossa", "Órgão de alta oxigenação adaptado a fossas oceânicas.", 0.7, 70, "Elixires de estamina infinita sob a água."),
        ],
        "epic": [
            ("mat_leviathan_vertebra", "Vértebra de Serpente Marinha", "Segmento de coluna maciço e articulado.", 2.0, 170, "Grandes arcos marinhos e escudos de concha."),
        ],
        "legendary": [
            ("mat_neptunian_pearl", "Pérola dos Abismos Profundos", "Pérola colossal recolhida do leito do mundo.", 1.5, 480, "Tridentes lendários e relíquias do oceano."),
        ]
    },
    "rare_anomalies": {
        "common": [
            ("mat_anomaly_shard", "Fragmento de Realidade Rompida", "Estilhaço de matéria instável que treme ao toque.", 0.3, 12, "Catalisador de transmutação química."),
            ("mat_distorted_dust", "Poeira de Vácuo Distorcido", "Pó acinzentado que absorve raios de luz ao redor.", 0.2, 10, "Tintas de ilusão e capas de invisibilidade."),
        ],
        "uncommon": [
            ("mat_unstable_quartz", "Quartzo de Fenda Instável", "Cristal cuja estrutura atômica oscila continuamente.", 0.4, 30, "Lâminas de dano caótico aleatório."),
            ("mat_spatial_membrane", "Membrana de Dobra Espacial", "Tecido elástico que parece maior por dentro.", 0.3, 28, "Bolsas de inventário expandido e aljavas infinitas."),
        ],
        "rare": [
            ("mat_void_essence", "Essência Pura do Vazio", "Líquido negro fosco contido em ampola de vidro reforçado.", 0.4, 80, "Encantamentos de toque aniquilador."),
            ("mat_mirage_gem", "Gema da Miragem Eterna", "Pedra facetada que projeta clones ilusórios do portador.", 0.5, 85, "Acessórios de esquiva e teletransporte."),
        ],
        "epic": [
            ("mat_anomaly_core", "Núcleo Gravitacional Anômalo", "Esfera microscópica com atração de massa própria.", 1.0, 200, "Armas de vórtice e foices de buraco negro."),
        ],
        "legendary": [
            ("mat_cosmic_fragment", "Estilhaço de Astro Caído", "Matéria estelar anterior à criação dos continentes.", 1.5, 550, "Armas de cataclismo e pactos cósmicos."),
        ]
    }
}

# Materiais específicos dos Demônios por Grau
DEMON_TIER_MATERIALS = {
    "inferior": {
        "guaranteed": ("item_gold_coins", "Moedas de Ouro Demoníacas", "Moeda cunhada em ouro e enxofre.", 0.01, 1, "Comércio em acampamentos e forja."),
        "common": [
            ("mat_demon_essence_inf", "Essência Demoníaca Inferior", "Resíduo de alma condenada do exército invasor.", 0.2, 8, "Criação de elixires de resistência a fogo e forja inicial."),
            ("mat_corrupted_blood_inf", "Sangue Corrompido Inferior", "Ichor escuro recolhido de soldados demoníacos comuns.", 0.3, 6, "Têmpera de lâminas na Hell Forge."),
            ("mat_demon_ash", "Cinzas de Demônio Incinerado", "Cinzas cinzentas impregnadas de calor sulfúrico.", 0.2, 5, "Pólvora rúnica e alquimia."),
        ],
        "uncommon": [
            ("mat_demon_horn_inf", "Chifre Curvo de Soldado Demoníaco", "Chifre rígido arrancado de demônio inferior.", 0.4, 18, "Empunhaduras de armas e elmos cônicos."),
            ("mat_infernal_iron_scrap", "Sucata de Ferro Infernal", "Fragmento de armadura forjada nas fornalhas de Azaroth.", 0.8, 22, "Reforço de placas de combate."),
        ],
        "rare": [
            ("mat_hell_fire_gland", "Glândula de Fogo Infernal", "Órgão interno inflamável em contato com ar vulgar.", 0.5, 55, "Óleos de fogo para armas e flechas incendiárias."),
            ("mat_lesser_demon_core", "Núcleo de Demônio Menor", "Cristal de energia que alimenta os demônios inferiores.", 0.4, 60, "Encantamento de armas nível 1-20."),
        ],
        "epic": [
            ("mat_infernal_sergeant_crest", "Insígnia de Sargento Abissal", "Medalha de ferro forjado que lidera esquadrões de fenda.", 0.6, 120, "Forja de armas avançadas do exército."),
        ],
        "legendary": [
            ("mat_demon_vanguard_banner", "Estandarte da Vanguarda Corrompida", "Flâmula imbuída do ódio de Azaroth.", 1.0, 320, "Relíquias militares e aprimoramento de pactos."),
        ]
    },
    "superior": {
        "guaranteed": ("item_gold_coins", "Moedas de Ouro Demoníacas", "Moeda cunhada em ouro e enxofre.", 0.01, 1, "Comércio e forja avançada."),
        "common": [
            ("mat_demon_essence_sup", "Essência Demoníaca Superior", "Concentrado etéreo de oficial demoníaco.", 0.3, 16, "Forja de armas raras e elixires avançados."),
            ("mat_abyssal_crystal_shard", "Estilhaço de Cristal Abissal", "Fragmento vítreo escuro pulsando com poder corrosivo.", 0.4, 15, "Catalisadores mágicos e pontas de projéteis."),
        ],
        "uncommon": [
            ("mat_corrupted_carapace_sup", "Couraça de Demônio Superior", "Placa de quitina demoníaca tratada em magma.", 1.0, 35, "Armaduras pesadas anti-abissais."),
            ("mat_superior_demon_horn", "Chifre Rúnico Espiralado", "Chifre entalhado com runas de submissão a Azaroth.", 0.7, 32, "Cajados e machados de combate."),
        ],
        "rare": [
            ("mat_superior_demon_core", "Núcleo de Demônio Superior", "Orbe incandescente de energia abissal concentrada.", 0.6, 90, "Forja épica na Hell Forge e encantamentos."),
            ("mat_abyssal_officer_blade_part", "Guarda de Espada de Oficial Abissal", "Pedaço de armamento de comando demoníaco.", 0.8, 85, "Restauração de armas de generais."),
        ],
        "epic": [
            ("mat_commander_seal_shard", "Fragmento de Selo de Comandante", "Selo gravado com a bênção direta de Azaroth.", 0.5, 200, "Aprimoramento de equipamentos lendários."),
        ],
        "legendary": [
            ("mat_superior_dominion_stone", "Pedra do Domínio Superior", "Gema que reverbera ordens de invasão por telepatia.", 0.9, 450, "Criação de anéis de soberania demoníaca."),
        ]
    },
    "supreme": {
        "guaranteed": ("item_gold_coins", "Tesouro de Lorde Demoníaco", "Grande soma de moedas antigas e ouro profano.", 0.01, 1, "Economia maior e forjas lendárias."),
        "common": [
            ("mat_demon_essence_supreme", "Essência Demoníaca Suprema", "Emanação cósmica de lorde soberano do Abismo.", 0.5, 35, "Elixires transcendentais e forja de armas supremas."),
            ("mat_pure_abyssal_ore", "Minério Puro do Vazio Abissal", "Metal pesado indestrutível por fogo comum.", 1.5, 30, "Ligas titânicas de placas de lorde."),
        ],
        "uncommon": [
            ("mat_supreme_lord_bone", "Osso Sacro de Lorde da Calamidade", "Vértebra de general demoníaco milenar.", 1.2, 60, "Armaduras colossais e escudos supremos."),
            ("mat_supreme_carapace_fragment", "Fragmento de Placa Soberana", "Placa de armadura com gravuras da linhagem de Azaroth.", 1.4, 65, "Peitorais lendários."),
        ],
        "rare": [
            ("mat_abyssal_authority_shard", "Fragmento de Autoridade Abissal", "Parte da coroa de comando de um Lorde Supremo.", 0.6, 160, "Acessórios lendários de liderança."),
            ("mat_lord_heart_fire", "Fogo de Coração de Soberano", "Labareda eterna que queima sem oxigênio.", 0.5, 180, "Têmpera das 100 armas do jogo."),
        ],
        "epic": [
            ("mat_supreme_relic_shard", "Relíquia da Legião das Cinzas", "Artefato ancestral que presenciou a queda de reinos.", 0.8, 300, "Armas míticas e catalisadores de classe."),
        ],
        "legendary": [
            ("mat_crown_fragment_supreme", "Estilhaço de Coroa Demoníaca Suprema", "Fragmento do diadema de autoridade militar.", 1.0, 750, "Criação de elmos e coroas lendárias."),
        ]
    }
}

# Definição dos 70 itens exclusivos dos 10 Primordiais (DEMON-191 a DEMON-200)
PRIMORDIAL_EXCLUSIVES = {
    "DEMON-191": { # Carniceiro-Aéreo de Fossa Oceânica
        "anatomical": ("mat_primordial_wing_191", "Membrana Alar do Vazio Oceânico", "Asa membranosa indestrutível adaptada a pressões abissais.", 1.5, "rare", 90, "Forja de asas planadoras e mantos de evasão."),
        "essence": ("mat_primordial_essence_191", "Essência do Ceifador Alado", "Vapor de tempestade oceânica profunda de tonalidade ciano escura.", 0.4, "epic", 220, "Elixir de velocidade aérea e feitiços de rajada cérebro-espinal."),
        "core": ("mat_primordial_core_191", "Núcleo das Alturas Abissais", "Coração pulsante envolto em correntes de vento sulfuroso.", 0.8, "epic", 260, "Catalisador para o Arco das Tempestades Submarinas."),
        "equipment_comp": ("mat_primordial_feather_191", "Pálio Ósseo dos Céus Negros", "Espigão terminal de asa afiado como bisturi cirúrgico.", 0.6, "rare", 130, "Ponta da Lança das Cinzas Abissais (WEP-031)."),
        "special_identity": ("mat_primordial_eye_191", "Olho Nictitante das Profundezas", "Globo ocular quádruplo com visão translúcida em trevas absolutas.", 0.3, "epic", 190, "Lentes de visão verdadeira e anéis de caça noturna."),
        "progression_reward": ("mat_primordial_seal_191", "Selo da Calamidade Alada", "Emblema gravado na carne do Primordial pelo próprio Azaroth.", 0.5, "legendary", 600, "Liberação do Tier 5 de Forja Demoníaca na Hell Forge."),
        "crafting_mat": ("mat_primordial_ingot_191", "Lingote dos Ventos Cáusticos", "Metal forjado com pó de ossos do Carniceiro e basalto fundido.", 2.0, "legendary", 450, "Forja da Armadura Alada do Vazio.")
    },
    "DEMON-192": { # Sentinela-de-Basalto de Fossa Oceânica
        "anatomical": ("mat_primordial_plating_192", "Placa Basáltica de Carne Viva", "Carapaça rochosa irrigada por vasos sanguíneos incandescentes.", 3.0, "rare", 95, "Escudos maciços e peitorais impenetráveis."),
        "essence": ("mat_primordial_essence_192", "Essência do Baluarte Inquebrável", "Emanação mineral densa que desacelera impactos cinéticos.", 0.5, "epic", 230, "Elixir de casca de ferro e encantamentos de bloqueio."),
        "core": ("mat_primordial_core_192", "Núcleo Sísmico da Sentinela", "Massa de quartzo e ferro abissal fundidos sob pressão de 10.000m.", 1.2, "epic", 270, "Núcleo de reforço do Escudo Torre de Ferro Negro (WEP-091)."),
        "equipment_comp": ("mat_primordial_whip_192", "Açoite de Tendão Basáltico", "Chicote segmentado de rocha flexível e queratina demoníaca.", 1.0, "rare", 140, "Componente de empunhadura do Chicote do Caos (WEP-085)."),
        "special_identity": ("mat_primordial_monolith_192", "Estela da Guarda Eterna", "Pilar ósseo cravado nas costas da Sentinela.", 2.5, "epic", 200, "Totens de proteção territorial de guildas."),
        "progression_reward": ("mat_primordial_seal_192", "Selo da Sentinela de Pedra", "Fragmento de rocha rúnica que destranca as muralhas do Abismo.", 0.5, "legendary", 620, "Acesso à Cidadela Submersa Profunda."),
        "crafting_mat": ("mat_primordial_ingot_192", "Lingote de Basalto Titânico", "Liga metálica que absorve 40% de dano contundente.", 3.5, "legendary", 480, "Forja da Marreta Sísmica do Juízo.")
    },
    "DEMON-193": { # Quebra-Ossos de Fossa Oceânica
        "anatomical": ("mat_primordial_crusher_193", "Pata Esmagadora Hipertrofiada", "Membro de impacto contendo nós de osso sólido como bigornas.", 4.0, "rare", 100, "Maças pesadas e aríetes de demolição."),
        "essence": ("mat_primordial_essence_193", "Essência da Ruptura Óssea", "Vapor vermelho-escuro emanando sede de fragmentação mecânica.", 0.4, "epic", 240, "Óleo de ruptura de armadura para armas de impacto."),
        "core": ("mat_primordial_core_193", "Núcleo da Fúria Estilhaçadora", "Coração petrificado que explode em ondas de choque a cada batimento.", 1.5, "epic", 280, "Núcleo do Martelo Colossal da Forja (WEP-021)."),
        "equipment_comp": ("mat_primordial_spike_193", "Espigão Cônico Quebra-Couraça", "Chifre frontal rombudo capaz de furar chapas de aço.", 1.8, "rare", 150, "Ponta do Alabarde Quebra-Muralha (WEP-035)."),
        "special_identity": ("mat_primordial_jaw_193", "Mandíbula Moedora de Granito", "Mola mandibular tripla com dentes de pedra afiada.", 2.0, "epic", 210, "Manoplas de agarre e armaduras de queixo."),
        "progression_reward": ("mat_primordial_seal_193", "Selo do Esmagador Primordial", "Placa de bronze infernal cravada no crânio da fera.", 0.5, "legendary", 640, "Desbloqueio de Habilidades Mestras de Guerreiro."),
        "crafting_mat": ("mat_primordial_ingot_193", "Lingote de Ferro Quebrador", "Metal de peso extraordinário com bônus de dano de impacto.", 4.0, "legendary", 500, "Forja do Peitoral do Destruidor de Reinos.")
    },
    "DEMON-194": { # Lacerador de Fossa Oceânica
        "anatomical": ("mat_primordial_scythe_194", "Lâmina Óssea de Braço Lacerador", "Falcão biológico retrátil com fio molecularmente afiado.", 1.2, "rare", 105, "Forja de adagas duplas e garras de combate."),
        "essence": ("mat_primordial_essence_194", "Essência da Emboscada Perfeita", "Névoa translúcida que camufla o portador em sombras abissais.", 0.3, "epic", 250, "Poção de furtividade total e velocidade crítica."),
        "core": ("mat_primordial_core_194", "Núcleo do Caçador Fantasma", "Órgão sensorial que detecta batimentos cardíacos a 2 km.", 0.7, "epic", 290, "Núcleo da Adaga Espectral do Vazio (WEP-045)."),
        "equipment_comp": ("mat_primordial_fang_194", "Presa Hemotóxica Perfurante", "Canino oco canalizador de veneno paralisante imediato.", 0.4, "rare", 160, "Ponta da Espada Rúnica da Agonia (WEP-005)."),
        "special_identity": ("mat_primordial_stealth_skin_194", "Couro de Camuflagem Miasmática", "Epiderme fotossensível que muda de padrão conforme o terreno.", 1.0, "epic", 220, "Capa dos Assassinos da Noite Eterna."),
        "progression_reward": ("mat_primordial_seal_194", "Selo do Predador das Sombras", "Garra fossilizada que representa o pacto de velocidade.", 0.5, "legendary", 650, "Acesso aos atalhos submarinos de Nhal'Kora."),
        "crafting_mat": ("mat_primordial_ingot_194", "Liga das Sombras Lacerantes", "Metal escuro e leve que não reflete nenhuma fonte de luz.", 1.8, "legendary", 520, "Forja do Conjunto Completo do Lacerador.")
    },
    "DEMON-195": { # Invocador de Fossa Oceânica
        "anatomical": ("mat_primordial_horn_195", "Chifre Litomântico do Caos", "Antena mística espiralada que conduz energias telúricas.", 1.4, "rare", 110, "Cajados arcanos de litomancia e orbes."),
        "essence": ("mat_primordial_essence_195", "Essência do Conjurador Abissal", "Resíduo de encantamentos proibidos de invocação em massa.", 0.4, "epic", 260, "Elixires de regeneração de mana e poder mágico puro."),
        "core": ("mat_primordial_core_195", "Núcleo Taumatúrgico do Vórtice", "Cristal octaédrico que armazena feitiços de alto círculo.", 0.9, "epic", 300, "Núcleo do Cajado da Maré Abissal (EQ-002 / WEP-071)."),
        "equipment_comp": ("mat_primordial_tome_page_195", "Papiro de Carne com Glifos de Fenda", "Pedaço de pergaminho de pele com rituais da Hell Forge.", 0.2, "rare", 170, "Encadernação de grimórios épicos."),
        "special_identity": ("mat_primordial_third_eye_195", "Terceiro Olho Mágico Cristalizado", "Olho frontal translúcido capaz de enxergar linhas de ley.", 0.3, "epic", 230, "Amuleto do Vidente Abissal."),
        "progression_reward": ("mat_primordial_seal_195", "Selo da Magia Proibida", "Orbe místico que desbloqueia magias de 6º Círculo.", 0.5, "legendary", 660, "Desbloqueio de Habilidades Mestras de Mago/Arcanista."),
        "crafting_mat": ("mat_primordial_ingot_195", "Metal de Ressonância Etérea", "Ouro alquímico que amplifica dano elemental em 25%.", 2.2, "legendary", 540, "Forja do Báculo Supremo do Caos.")
    },
    "DEMON-196": { # Cardume-de-Trevas de Fim do Abismo
        "anatomical": ("mat_primordial_swarm_carapace_196", "Placa de Enxame Multissegmentada", "Quitina minúscula sobreposta formando uma cota flexível.", 1.6, "rare", 115, "Armaduras elásticas e cotas de anéis de inseto."),
        "essence": ("mat_primordial_essence_196", "Essência da Consciência Coletiva", "Pensamento coletivo destilado em poção de sincronia mental.", 0.3, "epic", 270, "Elixir de telepatia e buff de dano em grupo de 8 jogadores."),
        "core": ("mat_primordial_core_196", "Núcleo da Rainha do Vácuo", "Esfera de biogelatina negra que pulsa como um coração de colmeia.", 1.1, "epic", 310, "Núcleo de armamentos com dano de dispersão em área."),
        "equipment_comp": ("mat_primordial_stinger_196", "Ferrão Penetrante de Bando", "Ferrão translúcido que injeta toxina necrótica.", 0.5, "rare", 180, "Dardos de zarabatana e flechas de enxame."),
        "special_identity": ("mat_primordial_pheromones_196", "Glândula de Feromônio da Fenda", "Substância que atrai ou dispersa criaturas menores.", 0.4, "epic", 240, "Iscas de caça lendárias para eventos de invasão."),
        "progression_reward": ("mat_primordial_seal_196", "Selo da Colmeia das Trevas", "Fóssil de mandíbula que unifica o controle sobre a fauna hostil.", 0.5, "legendary", 670, "Pacto do Enxame Voraz com Azaroth."),
        "crafting_mat": ("mat_primordial_ingot_196", "Liga Quitino-Metálica de Enxame", "Material hiperleve que confere bônus de velocidade de ataque.", 2.5, "legendary", 560, "Forja do Conjunto das Trevas Infinitas.")
    },
    "DEMON-197": { # Arpão-dos-Ventos de Fim do Abismo
        "anatomical": ("mat_primordial_talon_197", "Garra Adunca de Mergulho Abissal", "Garra de rapina gigante adaptada a interceptações supersônicas.", 1.8, "rare", 120, "Ganchos de escalada e pontas de arpões pesados."),
        "essence": ("mat_primordial_essence_197", "Essência da Corrente Térmica Polar", "Ar liquefeito a temperaturas próximas do zero absoluto.", 0.4, "epic", 280, "Óleos de dano glacial supremo para flechas e lâminas."),
        "core": ("mat_primordial_core_197", "Núcleo do Caçador dos Céus Finais", "Esfera de tempestade e granizo que congela o ar ao redor.", 1.3, "epic", 320, "Núcleo do Machado Rúnico de Basalto (EQ-004 / WEP-011)."),
        "equipment_comp": ("mat_primordial_beak_197", "Bico Perfurador de Blindagem", "Mandíbula óssea capaz de quebrar escudos de ferro negro.", 1.5, "rare", 190, "Ponta da Lança das Cinzas (WEP-031)."),
        "special_identity": ("mat_primordial_tail_rudder_197", "Leme Caudal Cruciforme", "Estrutura cartilaginosa que estabiliza manobras bruscas.", 1.2, "epic", 250, "Capa dos Cavaleiros do Vento Negro."),
        "progression_reward": ("mat_primordial_seal_197", "Selo do Arpão dos Ventos", "Bússola de ossos que aponta para as fendas de Azaroth.", 0.5, "legendary", 680, "Rastreamento automático de invasões no mapa-múndi."),
        "crafting_mat": ("mat_primordial_ingot_197", "Lingote de Prata Glacial Profunda", "Metal brilhante imune a fogo vulgar e derretimento.", 2.8, "legendary", 580, "Forja do Arco Longo do Fim do Abismo.")
    },
    "DEMON-198": { # Couraçado de Fim do Abismo
        "anatomical": ("mat_primordial_bastion_shell_198", "Carapaça de Ferro Vulcânico Solidificado", "Casco espesso de 15 cm de espessura de rocha e ferro negro.", 5.0, "rare", 125, "Escudos de cerco e blindagem de carruagens de guerra."),
        "essence": ("mat_primordial_essence_198", "Essência da Fortaleza Eterna", "Aura estática de imobilidade que rejeita repulsões físicas.", 0.6, "epic", 290, "Elixir de imunidade a atordoamento e queda."),
        "core": ("mat_primordial_core_198", "Núcleo do Baluarte Inexpugnável", "Motor biológico de magma que alimenta a couraça viva.", 2.0, "epic", 330, "Núcleo da Armadura Peitoral de Ferro Profundo (EQ-006)."),
        "equipment_comp": ("mat_primordial_spine_plate_198", "Placa Dorsal Espinhosa de Ferro", "Lâmina dorsal defensiva que devolve dano a atacantes corpo a corpo.", 2.5, "rare", 200, "Espinhos de armaduras de retaliação."),
        "special_identity": ("mat_primordial_molten_blood_198", "Sangue de Ferro Fundido", "Líquido metálico a 1200°C que endurece imediatamente ao ar.", 1.5, "epic", 260, "Têmpera das 10 armaduras lendárias do jogo."),
        "progression_reward": ("mat_primordial_seal_198", "Selo do Couraçado Invencível", "Placa heráldica gravada no peito da criatura.", 0.5, "legendary", 700, "Liberação da Forja de Armaduras Nível 60."),
        "crafting_mat": ("mat_primordial_ingot_198", "Lingote de Aço Abissal Impenetrável", "O metal mais resistente conhecido no mundo de Abyssal Pact.", 5.0, "legendary", 600, "Forja do Escudo-Torre Imperial do Abismo.")
    },
    "DEMON-199": { # Triturador de Fim do Abismo
        "anatomical": ("mat_primordial_grinder_teeth_199", "Dente Moedor de Cordilheiras", "Molar monolítico de basalto com ranhuras de moagem contínua.", 3.5, "rare", 130, "Moendas de alquimia e martelos de impacto pesado."),
        "essence": ("mat_primordial_essence_199", "Essência da Pulverização Cósmica", "Força centrífuga destrutiva que esmaga matéria em átomos.", 0.5, "epic", 300, "Óleo de quebra de resistências mágicas e físicas."),
        "core": ("mat_primordial_core_199", "Núcleo Moedor de Mundos", "Engrenagem orgânica colossal girando com fogo subterrâneo.", 2.5, "epic", 340, "Núcleo do Machado do Titã de Pedra (EQ-004 / WEP-015)."),
        "equipment_comp": ("mat_primordial_crusher_horn_199", "Chifre Aríete da Destruição", "Chifre central de 2 metros curvado em ângulo de cunha.", 3.0, "rare", 210, "Ponta da Clava Colossal de Guerra (WEP-025)."),
        "special_identity": ("mat_primordial_stomach_stone_199", "Gastrolito Mineralizado de Magma", "Pedra polida no estômago do Triturador por séculos.", 2.0, "epic", 270, "Pedra de amolar divina para bônus de afiação permanente."),
        "progression_reward": ("mat_primordial_seal_199", "Selo da Calamidade da Terra", "Fragmento de rocha que estremece quando monstros se aproximam.", 0.5, "legendary", 720, "Aumento permanente de inventário e estamina."),
        "crafting_mat": ("mat_primordial_ingot_199", "Liga de Tungstênio Abissal", "Densidade incomparável para armas de devastação em massa.", 5.5, "legendary", 620, "Forja do Martelo da Ruína Total.")
    },
    "DEMON-200": { # Predador de Fim do Abismo (O Ápice Primordial)
        "anatomical": ("mat_primordial_apex_claw_200", "Garra do Ápice do Vazio", "Garra translúcida que corta matéria física e espiritual.", 2.2, "rare", 140, "Forja da Lâmina das Cinzas Lendária (EQ-001 / WEP-001)."),
        "essence": ("mat_primordial_essence_200", "Essência da Singularidade Primordial", "A quintessência do poder demoníaco antes da manifestação de Azaroth.", 0.5, "epic", 320, "Elixir dos Deuses Caídos (Aumento de todos os atributos)."),
        "core": ("mat_primordial_core_200", "Coração do Primeiro Abismo", "O núcleo primordial supremo, pulsando em sintonia com o World Boss.", 2.0, "epic", 360, "Catalisador para a forja das 5 armas míticas do fim do jogo."),
        "equipment_comp": ("mat_primordial_crown_spike_200", "Chifre da Coroa do Fim dos Tempos", "Chifre em formato de tiara régia do senhor das trevas.", 2.0, "rare", 220, "Peça central da Coroa da Desolação."),
        "special_identity": ("mat_primordial_shadow_cloak_200", "Manto Espectral da Não-Existência", "Farrapo de trevas sólidas que envolve o corpo da criatura.", 1.5, "epic", 290, "Manto Supremo de Resistência Universal."),
        "progression_reward": ("mat_primordial_seal_200", "Selo do Soberano do Vácuo", "O selo supremo de maestria sobre as criaturas de Abyssal Pact.", 0.5, "legendary", 800, "Conquista do Códice Completo e Acesso ao Altar de Azaroth."),
        "crafting_mat": ("mat_primordial_ingot_200", "Lingote de Éter Sólido e Ferro Estelar", "A liga mítica suprema para as obras de arte da Hell Forge.", 6.0, "legendary", 700, "Forja da Lâmina Devoradora de Reinos.")
    }
}

# 30 Núcleos exclusivos dos Chefes Supremos (BOSS-001 a BOSS-030)
BOSS_EXCLUSIVE_CORES = {
    "BOSS-001": ("mat_core_igniskhar", "Núcleo Vulcânico de Ignis'Khar", "Coração de lava petrificada do Lorde da Forja.", 1.2, "epic", 220, "Forja do Martelo Vulcânico de Veyrath."),
    "BOSS-002": ("mat_core_magmatron", "Núcleo Candente de Magmatron", "Câmara de fusão de basalto e enxofre em brasa.", 1.5, "epic", 220, "Armadura de Chamas Imortais."),
    "BOSS-003": ("mat_core_obsidiar", "Lâmina Negra de Obsidiar", "Pedaço da espada carniceira de obsidiana viva.", 1.1, "epic", 230, "Forja da Espada de Lâminas Negras."),
    "BOSS-004": ("mat_core_ferrumgorg", "Coroa de Escória de Ferrum'Gorg", "Placa de ferro retorcida por fogo abissal.", 1.8, "epic", 230, "Escudo Pavese da Cratera."),
    "BOSS-005": ("mat_core_malakor", "Foice da Garganta de Malakor", "Fragmento de foice óssea que ceifou exércitos.", 1.0, "epic", 240, "Foice da Colheita de Almas."),
    "BOSS-006": ("mat_core_veyrathor", "Pena de Cinzas Negras de Veyrathor", "Pluma incandescente da Fênix de Cinzas.", 0.4, "epic", 240, "Arco Flamejante de Veyrath."),
    "BOSS-007": ("mat_core_ashkazzar", "Veste Férrea de Ash'Kazzar", "Tecido metálico que exala miasma de peste.", 1.3, "epic", 250, "Manto da Peste Vulcânica."),
    "BOSS-008": ("mat_core_ignacius", "Coração do Deserto de Ignacius", "Núcleo de vidro vulcânico forjado sob tempestade de cinzas.", 1.2, "epic", 250, "Cajado do Sol Negro de Veyrath."),
    "BOSS-009": ("mat_core_sylvath", "Raiz Sussurrante de Sylvath", "Fibra vegetal pulsando com espíritos aprisionados.", 1.0, "epic", 230, "Arco das Sombras Silenciosas (EQ-003)."),
    "BOSS-010": ("mat_core_runicar", "Glifo de Proteção de Runicar", "Estela rúnica de salgueiro com feitiços arcanos.", 0.8, "epic", 230, "Escudo Rúnico de Sylvaran."),
    "BOSS-011": ("mat_core_lacrimosa", "Lágrima Venenosa de Lacrimosa", "Gema escura destilada das lágrimas da senhora.", 0.5, "epic", 240, "Amuleto das Lamentações Tóxicas."),
    "BOSS-012": ("mat_core_cruorzul", "Ichor do Lodaçal de Cruor'Zul", "Sangue pastoso que recusa a decomposição.", 1.4, "epic", 240, "Peitoral de Sangue Corrompido."),
    "BOSS-013": ("mat_core_esmeraldor", "Cristal Esmeralda de Esmeraldor", "Prisma verde gigante que refrata energias da floresta.", 1.6, "epic", 250, "Cajado das Esmeraldas Silvestres."),
    "BOSS-014": ("mat_core_sylvanor", "Coração de Seiva de Sylv'Ankor", "Orbe orgânico translúcido que bombeia seiva negra.", 1.2, "epic", 250, "Lança de Seiva Endurecida."),
    "BOSS-015": ("mat_core_brumalis", "Véu da Névoa de Brumalis", "Condensação de bruma espectral que confere intangibilidade.", 0.6, "epic", 260, "Manto das Névoas Sangrentas."),
    "BOSS-016": ("mat_core_vinchora", "Chicote de Vinhas Negras de Vinchora", "Cipó espinhoso animado por magia ancestral.", 1.1, "epic", 260, "Chicote de Vinhas Espinhosas."),
    "BOSS-017": ("mat_core_kharzul", "Placa de Basalto de Khar'Zul", "Escama dorsal de serpente gigante mineralizada.", 2.2, "epic", 240, "Escudo Serpentino de Basalto."),
    "BOSS-018": ("mat_core_serpentis", "Canino de Víbora de Serpentis", "Presa com veneno fóssil de milênios.", 0.8, "epic", 240, "Adaga da Víbora Dourada."),
    "BOSS-019": ("mat_core_monolithor", "Pedra Angular de Monolithor", "Fragmento de obelisco sagrado do deserto.", 2.5, "epic", 250, "Martelo do Guardião de Pedra."),
    "BOSS-020": ("mat_core_kharbael", "Espada do Marechal de Khar'Bael", "Lâmina pesada de ferro rubro gravada com táticas de guerra.", 2.0, "epic", 250, "Montante da Cidadela Rubra."),
    "BOSS-021": ("mat_core_vanthduum", "Sussurro do Vento de Vanth'Duum", "Pó fino do vale que canta com o vento.", 0.5, "epic", 260, "Flauta Rúnica dos Túmulos."),
    "BOSS-022": ("mat_core_abyssuskhar", "Carapaça de Fenda de Abyssus'Khar", "Quitina espessa impregnada de sal e fogo subterrâneo.", 1.7, "epic", 260, "Armadura das Fendas de Sal."),
    "BOSS-023": ("mat_core_solariskhar", "Lente Solar de Solaris'Khar", "Cristal que foca os raios do sol em calor mortal.", 1.0, "epic", 270, "Elmo da Coroa Solar."),
    "BOSS-024": ("mat_core_dagonkora", "Tentáculo Petrificado de Dagon'Kora", "Membro de horror abissal preservado em salmoura.", 1.8, "epic", 250, "Arpão do Caçador dos Afogados."),
    "BOSS-025": ("mat_core_corallion", "Espícula de Recife de Corallion", "Coral endurecido com navalhas de calcário vítreo.", 1.3, "epic", 250, "Lança de Recife Negro."),
    "BOSS-026": ("mat_core_glaciaroth", "Gelo Eterno de Glaciaroth", "Bloco de gelo azul que nunca derrete sob o sol.", 1.5, "epic", 260, "Machado Glacial dos Fiordes."),
    "BOSS-027": ("mat_core_naufragor", "Madeira de Galeão de Naufragor", "Pedaço de casco de navio fantasma encantado.", 1.4, "epic", 260, "Escudo de Pinho Fantasma."),
    "BOSS-028": ("mat_core_marialis", "Tridente Quebrado de Marialis", "Haste de tridente com símbolos da maré primordial.", 1.6, "epic", 270, "Tridente da Maré Eterna."),
    "BOSS-029": ("mat_core_leviathankora", "Olho de Leviatã de Leviathan'Kora", "Orbe colossal azul-turquesa de criatura titânica.", 2.8, "epic", 280, "Orbe da Fossa Oceânica Profunda."),
    "BOSS-030": ("mat_core_vorthul", "Vórtice Congelado de Vor'Thul", "Remoinho de água e miasma solidificado por mágica.", 2.0, "epic", 300, "Cajado do Vórtice Final.")
}

print("[Item Database] Módulo de itens, materiais e tabelas carregado com sucesso.")
