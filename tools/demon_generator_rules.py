#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Master Builder for the 230 Demon Technical Specifications of Abyssal Pact.
"""

import os
import re
import glob

from demon_generator_data import REGIONS_INFO, demons_data, bosses_data

# Dictionaries of specialized names, titles and lore tailored to regions and families
FAMILY_TRAITS = {
    "brute": {
        "title_suffix": "Colosso Esmagador",
        "subspecies": "Demoníaco Blindado de Choque Sísmico",
        "danger_tier": "Ameaça C - Destrutivo",
        "skull": "Crânio maciço braquicefálico com placas ósseas reforçadas de 8 cm de espessura e crista sagital espessada",
        "eyes": "Dois olhos pequenos encovados em órbitas profundas, com pupilas horizontais vermelhas",
        "mouth": "Mandíbula prognata massiva com dentes molares triangulares de ferro abissal e caninos inferiores saltados de 20 cm",
        "horns": "Par de chifres frontais espessos de basalto, curvados para frente em ângulo de 45 graus com 65 cm de comprimento",
        "torso": "Tronco largo em barril hipertrofiado com musculatura dorsal densa e placas de couraça escura fundidas à coluna",
        "arms": "Braços desproporcionalmente longos e pesados, antebraços nodulares terminando em punhos de pedra com 4 garras rombudas",
        "legs": "Pernas colunares digitígradas curtas e musculosas, preparadas para suportar toneladas de impacto sísmico",
        "tail": "Cauda curta e cônica terminando em nódulo ósseo achatado utilizado para estabilização de centro de massa",
        "bones_count": 42,
        "rig_name": "rig_demon_brute_heavy_v2",
        "h_base": 2.8, "w_base": 1.9, "l_base": 1.7, "weight_base": 850,
        "anim_idle": "idle_heavy_breathing (60 frames @ 30fps) - respiração lenta e arfante com expansão torácica e vapor nasal",
        "anim_walk": "walk_ground_shake (45 frames @ 30fps) - passos pesados alternados com afundamento leve no solo",
        "anim_run": "run_charging_charge (30 frames @ 30fps) - investida feroz com cabeça inclinada e passos sísmicos",
        "anim_atk1": "attack_crushing_overhead (45 frames @ 30fps) - golpe descendente com os dois punhos unidos esmagando o chão",
        "anim_atk2": "attack_earth_shatter (60 frames @ 30fps) - pisada sísmica com o pé direito gerando rachadura radial",
        "anim_hurt": "hurt_chest_flinch (20 frames @ 30fps) - recuo seco do tronco absorvendo impacto sem desequilíbrio",
        "anim_death": "death_heavy_collapse (75 frames @ 30fps) - desabamento de joelhos seguido de impacto frontal levantando poeira",
        "tactics": "Avanço frontal ininterrupto com foco em quebrar a linha de frente dos jogadores através de investidas pesadas e concussão sísmica"
    },
    "stalker": {
        "title_suffix": "Espreitador das Sombras",
        "subspecies": "Predador Ágil de Emboscada Abissal",
        "danger_tier": "Ameaça C - Predatório",
        "skull": "Crânio dolicocéfalo esguio com focinho alongado, narinas termo-sensíveis e fendas auditivas laterais",
        "eyes": "Quatro olhos estigmáticos dispostos em arco com pupilas verticais luminescentes e percepção de calor",
        "mouth": "Mandíbula bipartida retrátil com fileiras duplas de dentes afiados recurvados como agulhas de vidro",
        "horns": "Espigões cefálicos delgados e curvados para trás rentes ao pescoço, servindo como lemes aerodinâmicos",
        "torso": "Tronco delgado e altamente flexível com caixa torácica elástica e espinha dorsal saliente com espinhos",
        "arms": "Membros anteriores ágeis com cotovelos de articulação estendida, mãos com 3 dedos longos e garras em foice de 25 cm",
        "legs": "Pernas digitígradas alongadas com tendões de alta tensão que permitem saltos parabólicos de até 12 metros",
        "tail": "Cauda longa e chicoteadora de 2.2 metros com lâmina terminal serrilhada para ataque de retaguarda",
        "bones_count": 48,
        "rig_name": "rig_demon_stalker_agile_v2",
        "h_base": 1.7, "w_base": 0.9, "l_base": 2.3, "weight_base": 180,
        "anim_idle": "idle_predator_stalk (45 frames @ 30fps) - postura agachada inquieta com cabeça oscilando lateralmente",
        "anim_walk": "walk_silent_prowl (35 frames @ 30fps) - deslocamento rasteiro e furtivo mantendo centro de gravidade baixo",
        "anim_run": "run_lunge_sprint (25 frames @ 30fps) - corrida quadrupedal em zig-zag veloz rente ao chão",
        "anim_atk1": "attack_twin_claw_slash (30 frames @ 30fps) - golpe cruzado veloz com as duas garras em foice",
        "anim_atk2": "attack_pounce_latch (50 frames @ 30fps) - salto acrobático sobre o alvo tentando derrubá-lo ao solo",
        "anim_hurt": "hurt_sidestep_flinch (15 frames @ 30fps) - recuo rápido com meia esquiva lateral ágil",
        "anim_death": "death_spasm_sprawl (45 frames @ 30fps) - salto espasmódico no ar seguido de colapso estendido e inerte",
        "tactics": "Flanqueamento furtivo contornando tanques para alcançar curandeiros e conjuradores, atacando pelas costas em saltos súbitos"
    },
    "caster": {
        "title_suffix": "Invocador da Fenda",
        "subspecies": "Litomante / Taumaturgo do Caos Abissal",
        "danger_tier": "Ameaça C - Ocultista",
        "skull": "Crânio alongado sem mandíbula móvel convencional, revestido por máscara óssea ritual fundida ao rosto",
        "eyes": "Três olhos alinhados verticalmente na fronte com chamas etéreas pulsando no lugar de globos oculares",
        "mouth": "Fenda respiratória estreita que projeta fumaça e sussurros incompreensíveis em dialeto das fendas abissais",
        "horns": "Diadema natural de seis finos espinhos córneos que irradiam arcos de eletricidade estática abissal",
        "torso": "Tronco esguio e macilento com costelas visíveis sob uma membrana mumificada de pele ressequida",
        "arms": "Braços longos e delgados com três articulações de cotovelo, dedos afilados terminando em garras condutoras",
        "legs": "Membros inferiores atrofiados e envoltos em mantos esfarrapados que levitam a 20 cm do piso",
        "tail": "Tentáculos vestigiais de energia escura que escorrem da base da espinha tocando o solo como névoa",
        "bones_count": 46,
        "rig_name": "rig_demon_caster_mystic_v2",
        "h_base": 2.1, "w_base": 0.8, "l_base": 0.8, "weight_base": 110,
        "anim_idle": "idle_levitate_pulse (60 frames @ 30fps) - flutuação suave ondulatória com mãos emanando runas luminosas",
        "anim_walk": "walk_ethereal_glide (40 frames @ 30fps) - deslocamento por levitação deixando rastro de fagulhas no ar",
        "anim_run": "run_void_drift (30 frames @ 30fps) - impulso etéreo rápido com o corpo inclinado para frente",
        "anim_atk1": "attack_orb_cast (40 frames @ 30fps) - canalização frontal com mãos projetando projétil abissal",
        "anim_atk2": "attack_sigil_eruption (70 frames @ 30fps) - invocação de círculo rúnico sob os pés do alvo com detonação",
        "anim_hurt": "hurt_barrier_crack (20 frames @ 30fps) - estalo de escudo protetor com pequeno recuo da cabeça",
        "anim_death": "death_void_implosion (60 frames @ 30fps) - corpo se desfaz em fumaça e cinzas enquanto as vestes caem vazias",
        "tactics": "Manutenção rigorosa de distância máxima, conjurando barreiras defensivas e bombardeando alvos com projéteis e áreas de dano contínuo"
    },
    "swarm": {
        "title_suffix": "Rastejador da Colmeia",
        "subspecies": "Insetóide / Miriápode Voraz de Bando",
        "danger_tier": "Ameaça D - Enxame",
        "skull": "Cápsula cefálica quitinosa blindada com antenas sensoriais vibratórias e peças bucais mastigadoras",
        "eyes": "Múltiplos ocelos laterais com visão de 360 graus e alta sensibilidade ao menor movimento",
        "mouth": "Par de quelíceras horizontais denteadas com glândulas que secretam toxina corrosiva necrotizante",
        "horns": "Espinhos occipitais quitinosos voltados para trás que protegem o colar cervical contra golpes verticais",
        "torso": "Tronco segmentado em cinco anéis de carapaça dura, abrigando órgãos viscerais densamente empacotados",
        "arms": "Par frontal de patas raptoriais com bordas denteadas especializadas em agarrar membros da presa",
        "legs": "Quatro pares de patas locomotoras articuladas com garras duplas de fixação para escalar qualquer superfície",
        "tail": "Segmento terminal em ferrão bulhoso retrátil capaz de injetar fluido digestivo sob pressão",
        "bones_count": 36,
        "rig_name": "rig_demon_swarm_skitter_v2",
        "h_base": 0.85, "w_base": 1.1, "l_base": 1.4, "weight_base": 65,
        "anim_idle": "idle_chitter_twitch (30 frames @ 30fps) - movimentos espasmódicos rápidos de quelíceras e patas",
        "anim_walk": "walk_scuttle_rapid (20 frames @ 30fps) - marcha rápida e coordenada de múltiplas pernas em terreno irregular",
        "anim_run": "run_swarm_dash (15 frames @ 30fps) - disparada frenética com o corpo rente ao chão em alta cadência",
        "anim_atk1": "attack_mandible_bite (25 frames @ 30fps) - mordida dupla violenta para frente cravando ferrões",
        "anim_atk2": "attack_frenzy_latch (40 frames @ 30fps) - salto curto em grupo grudando no alvo e mastigando a couraça",
        "anim_hurt": "hurt_shell_rattle (12 frames @ 30fps) - retração instantânea das patas sob o exoesqueleto",
        "anim_death": "death_invert_curl (35 frames @ 30fps) - pernas se enrolam para dentro e o corpo tomba de dorso inerte",
        "tactics": "Ataque em matilha coordenada, sobrecarregando alvos isolados por meio de números e aplicando lentidão através de toxinas"
    },
    "flyer": {
        "title_suffix": "Gárgula dos Céus Abissais",
        "subspecies": "Quiróptero / Pterossauro Carniceiro Alado",
        "danger_tier": "Ameaça C - Aéreo",
        "skull": "Crânio alongado com bico ósseo parcialmente emplumado de espinhos e narinas afuniladas para voo veloz",
        "eyes": "Dois grandes olhos esféricos amarelos com membranas nictitantes translúcidas para proteção contra vento",
        "mouth": "Bico serrilhado internamente com ponta ganchuda capaz de rasgar couro reforçado e metal fino",
        "horns": "Crista craniana triangular que se projeta para trás, funcionando como estabilizador de voo",
        "torso": "Tórax estreito e profundo com quilha pronunciada para fixação de grandes massas musculares peitorais",
        "arms": "Membros superiores transformados em asas membranosas de couro tenaz com garras carpais funcionais",
        "legs": "Patas posteriores curtas e potentes em garras de rapina com 4 dígitos oponíveis armados de unhas aduncas",
        "tail": "Cauda esguia terminando em leme cruciforme de cartilagem e membrana para manobras rápidas de mergulho",
        "bones_count": 52,
        "rig_name": "rig_demon_flyer_wings_v2",
        "h_base": 1.9, "w_base": 1.2, "l_base": 1.8, "weight_base": 140, "wingspan_base": 4.6,
        "anim_idle": "idle_hover_flap (45 frames @ 30fps) - batimento ritmado e potente de asas mantendo sustentação estática",
        "anim_walk": "walk_knuckle_perch (40 frames @ 30fps) - andar quadrúpede desajeitado no solo apoiado nos nós das asas",
        "anim_run": "run_launch_takeoff (25 frames @ 30fps) - salto vigoroso com patas traseiras abrindo asas em ascensão",
        "anim_atk1": "attack_dive_talons (35 frames @ 30fps) - mergulho rasante com corte de garras e subida imediata",
        "anim_atk2": "attack_sonic_screech (50 frames @ 30fps) - emissão de grito estridente frontal causando desorientação e atordoamento",
        "anim_hurt": "hurt_wing_stall (18 frames @ 30fps) - perda de altitude momentânea com batimento descompassado",
        "anim_death": "death_spiral_plummet (55 frames @ 30fps) - asas recolhidas em espiral descontrolada até o choque contra o piso",
        "tactics": "Ataques rasantes em mergulho com recuo para fora do alcance de armas de corpo a corpo, forçando o uso de projéteis e magias"
    },
    "sentinel": {
        "title_suffix": "Baluarte Implacável",
        "subspecies": "Golem de Carne e Açoite Abissal",
        "danger_tier": "Ameaça B - Blindado",
        "skull": "Elmo ósseo monolítico embutido diretamente nos ombros, sem pescoço aparente, com uma fenda ocular horizontal",
        "eyes": "Visor luminoso contínuo de energia pulsante avermelhada que varre o horizonte em arco de 180 graus",
        "mouth": "Sem boca funcional visível; respira por grades de exaustão térmica dispostas nas laterais do colar",
        "horns": "Espigões dorsais retos de ferro negro que atuam como para-raios de energia profana e ancoragem",
        "torso": "Tronco maciço em forma de bigorna revestido por couraça de escória basáltica impenetrável a flechas",
        "arms": "Braço esquerdo fundido a uma lâmina-escudo de 1.8 metro; braço direito armado com clava contundente de espinhos",
        "legs": "Pernas pesadas com esporões retráteis que se cravam no solo para resistir a empurrões e arremessos",
        "tail": "Sem cauda; possui placas de cobertura glútea e coxais protetores que selam completamente a retaguarda",
        "bones_count": 40,
        "rig_name": "rig_demon_sentinel_bastion_v2",
        "h_base": 2.6, "w_base": 1.7, "l_base": 1.4, "weight_base": 920,
        "anim_idle": "idle_guard_stance (60 frames @ 30fps) - postura de bloqueio firme com escudo levantado e olho pulsando",
        "anim_walk": "walk_iron_march (45 frames @ 30fps) - passos lentos e estrondosos com som de metal pesado batendo no chão",
        "anim_run": "run_battering_ram (35 frames @ 30fps) - corrida retilínea com escudo à frente como aríete de demolição",
        "anim_atk1": "attack_shield_bash (40 frames @ 30fps) - avanço de escudo com projeção de ar e empurrão violento",
        "anim_atk2": "attack_spiked_cleave (55 frames @ 30fps) - arco horizontal devastador com a clava pesada de espinhos",
        "anim_hurt": "hurt_spark_deflect (15 frames @ 30fps) - faíscas ricocheteando no escudo sem perda de postura",
        "anim_death": "death_core_shatter (65 frames @ 30fps) - trinca luminosa no núcleo do peito seguida de colapso de peças metálicas",
        "tactics": "Criação de bloqueios intransponíveis em corredores e acessos, protegendo aliados mais frágeis e repelindo atacantes de perto"
    }
}

# Continental Palettes to make colors culturally and geologically cohesive
CONTINENT_PALETTES = {
    "CONT-01": { # Veyrath - Vulcânico, Cinzas, Enxofre, Obsidiana
        "primary": ("#2A1810", "Carvão Vulcânico Profundo"),
        "secondary": ("#8C250E", "Vermelho Magma Escuro"),
        "shadow": ("#120B08", "Cinza Basáltico Sombrio"),
        "details": ("#D95A1E", "Laranja Brasa Ardente"),
        "eyes": ("#FFAA00", "Âmbar Incandescente"),
        "supernatural": ("#FF3300", "Fogo Demoníaco de Veyrath"),
        "emission": ("#FF5500", "Emissão Magmática Brilhante")
    },
    "CONT-02": { # Sylvaran - Floresta Ancestral, Pântano, Névoa Espectral, Seiva Corrompida
        "primary": ("#1A241C", "Verde Musgo Corrompido"),
        "secondary": ("#4D3222", "Madeira Apodrecida"),
        "shadow": ("#0A110D", "Sombra das Raízes Abissais"),
        "details": ("#286B48", "Esmeralda Pútrida"),
        "eyes": ("#00FF88", "Fogo Fátuo Espectral"),
        "supernatural": ("#6B1D52", "Seiva de Sangue Corrompida"),
        "emission": ("#20E38F", "Emissão Bioluminescente de Sylvaran")
    },
    "CONT-03": { # Khar-Duum - Cânions, Areias Negras, Oásis Tóxico, Basalto
        "primary": ("#29221C", "Arenito Calcinado"),
        "secondary": ("#6E5136", "Ocre Desértico Escuro"),
        "shadow": ("#14110E", "Negro de Areia Basáltica"),
        "details": ("#B38244", "Bronze Antigo Oxidado"),
        "eyes": ("#E0B020", "Topázio Solar Tóxico"),
        "supernatural": ("#8F1D1D", "Poeira de Sangue Seco"),
        "emission": ("#FFCC33", "Emissão Solar Cáustica de Khar-Duum")
    },
    "CONT-04": { # Nhal'Kora - Litoral Abissal, Fiordes, Fossa Oceânica, Gelo Profundo
        "primary": ("#0D1B2A", "Azul Fossa Abissal"),
        "secondary": ("#1B3B52", "Ardósia Marinha Gélida"),
        "shadow": ("#050B12", "Vácuo Oceânico Escuro"),
        "details": ("#3A7D8C", "Coral Negro Espectro"),
        "eyes": ("#00E5FF", "Cyan Abissal Puro"),
        "supernatural": ("#2A0845", "Trevas de Maré Cósmica"),
        "emission": ("#18D2E6", "Emissão Glacial Profunda de Nhal'Kora")
    }
}

# Boss custom titles and arena assignments
BOSS_LORE = {
    "BOSS-001": {"name": "Ignis'Khar, o Lorde da Forja Vulcânica", "title": "Guardião das Catacumbas de Basalto", "arena": "Catacumbas de Basalto (REG-001)", "element": "Fogo Primordial"},
    "BOSS-002": {"name": "Magmatron, o Colosso Candente", "title": "Terror das Profundezas Ardentes", "arena": "Cavernas Candentes (REG-003)", "element": "Magma e Enxofre"},
    "BOSS-003": {"name": "Obsidiar, o Carrasco das Lâminas Negras", "title": "Comandante das Agulhas de Vidro", "arena": "Câmara das Lâminas (REG-005)", "element": "Vidro Vulcânico e Trevas"},
    "BOSS-004": {"name": "Ferrum'Gorg, o Soberano da Cratera", "title": "Forjador de Autômatos Profanos", "arena": "Complexo de Ferro Profundo (REG-007)", "element": "Metal Corrompido"},
    "BOSS-005": {"name": "Malakor, o Ceifador da Garganta", "title": "Senhor dos Vapores Férreos", "arena": "Cripta dos Condenados (REG-009)", "element": "Vapores Cáusticos"},
    "BOSS-006": {"name": "Veyrathor, a Fênix de Cinzas Negras", "title": "Soberano dos Picos da Caldeira", "arena": "Santuário do Fogo Profundo (REG-010)", "element": "Chamas Calcinadas"},
    "BOSS-007": {"name": "Ash'Kazzar, o Demônio da Peste Férrea", "title": "Bastião da Escória Férrea", "arena": "Mina dos Condenados (REG-008)", "element": "Peste e Escória"},
    "BOSS-008": {"name": "Ignacius, o Tirano do Deserto Fuliginoso", "title": "Devorador dos Ventos de Cinza", "arena": "Túmulo dos Ventos (REG-006)", "element": "Tempestade de Cinzas"},
    "BOSS-009": {"name": "Sylvath, o Espectro das Raízes Esquecidas", "title": "Coração Pútrido do Bosque", "arena": "Raízes Esquecidas (REG-011)", "element": "Almas e Raízes Espectrais"},
    "BOSS-010": {"name": "Runicar, o Guardião dos Símbolos Profanos", "title": "Tecelão de Runas Antigas", "arena": "Cripta dos Símbolos (REG-013)", "element": "Magia Rúnica Abissal"},
    "BOSS-011": {"name": "Lacrimosa, a Senhora dos Salgueiros Negros", "title": "Mártir do Vale Fúnebre", "arena": "Túmulo das Lágrimas (REG-015)", "element": "Névoa Fúnebre"},
    "BOSS-012": {"name": "Cruor'Zul, o Tirano do Lodaçal Sangrento", "title": "Comandante do Fosso dos Sacrifícios", "arena": "Fosso dos Sacrifícios (REG-017)", "element": "Sangue Abissal"},
    "BOSS-013": {"name": "Esmeraldor, o Patriarca dos Cristais Verdes", "title": "Horror da Fenda Luminescente", "arena": "Cavernas dos Cristais Verdes (REG-019)", "element": "Cristais Tóxicos"},
    "BOSS-014": {"name": "Sylv'Ankor, o Coração da Seiva Corrompida", "title": "Entidade Raiz do Santuário", "arena": "Santuário Corrompido (REG-020)", "element": "Seiva Abissal Pura"},
    "BOSS-015": {"name": "Brumalis, o Carrasco do Cume Enevoado", "title": "Espectro do Salão Branco", "arena": "Salão Enevoado (REG-016)", "element": "Gelo e Neblina"},
    "BOSS-016": {"name": "Vinchora, a Imperatriz das Vinhas Negras", "title": "Predadora do Dossel Oculto", "arena": "Antro das Vinhas Negras (REG-018)", "element": "Vinhas Carnívoras"},
    "BOSS-017": {"name": "Khar'Zul, a Serpente de Basalto", "title": "Senhor das Areias Devoradoras", "arena": "Templo Soterrado (REG-021)", "element": "Areia e Basalto"},
    "BOSS-018": {"name": "Serpentis, a Víbora do Poço Antigo", "title": "Guardiã da Miragem Tóxica", "arena": "Poço dos Antigos (REG-023)", "element": "Veneno Cáustico"},
    "BOSS-019": {"name": "Monolithor, o Colosso das Estelas", "title": "Titã da Cripta dos Gigantes", "arena": "Cripta dos Gigantes (REG-025)", "element": "Rocha Titânica"},
    "BOSS-020": {"name": "Khar'Bael, o Marechal da Cidadela Rubra", "title": "Senhor das Masmorras da Forja", "arena": "Masmorras da Forja (REG-027)", "element": "Arenito e Fogo Férreo"},
    "BOSS-021": {"name": "Vanth'Duum, o Vento do Túmulo Silencioso", "title": "Aniquilador do Som", "arena": "Tumba do Vento Perdido (REG-029)", "element": "Vácuo Sonoro"},
    "BOSS-022": {"name": "Abyssus'Khar, o Demônio das Profundezas", "title": "Comandante do Altar do Fogo", "arena": "Altar das Profundezas (REG-030)", "element": "Fogo Abissal Sísmico"},
    "BOSS-023": {"name": "Solaris'Khar, o Algoz do Platô Solar", "title": "Incinera-Almas do Deserto", "arena": "Mina de Enxofre Solar (REG-024)", "element": "Radiação Solar Maligna"},
    "BOSS-024": {"name": "Dagon'Kora, o Arauto dos Afogados", "title": "Terror do Naufrágio Imperial", "arena": "Naufrágio do Leviatã (REG-031)", "element": "Água Abissal e Almas"},
    "BOSS-025": {"name": "Corallion, o Flagelo do Recife Negro", "title": "Soberano dos Corais Malditos", "arena": "Fenda de Coral Negro (REG-033)", "element": "Coral e Espinhos Tóxicos"},
    "BOSS-026": {"name": "Glaciaroth, o Carrasco dos Fiordes", "title": "Devorador da Caverna das Almas", "arena": "Caverna das Almas Perdidas (REG-035)", "element": "Gelo Negro Perpétuo"},
    "BOSS-027": {"name": "Naufragor, o Espectro do Estuário", "title": "Comandante dos Túmulos Submersos", "arena": "Túmulo do Naufrágio (REG-037)", "element": "Lodo e Almas Afogadas"},
    "BOSS-028": {"name": "Marialis, o Senhor da Maré Eterna", "title": "Regente da Fenda das Conchas", "arena": "Fenda Profunda das Conchas (REG-038)", "element": "Pressão Hidrostática"},
    "BOSS-029": {"name": "Leviathan'Kora, o Titã da Fossa Abissal", "title": "Guardião do Altar das Correntes", "arena": "Altar das Correntes (REG-039)", "element": "Vácuo Oceânico Titânico"},
    "BOSS-030": {"name": "Vor'Thul, o Soberano do Vórtice Final", "title": "Portador da Escuridão Cósmica", "arena": "Vórtice Final (REG-040)", "element": "Singularidade Abissal"}
}

def determine_progression(did):
    # Early Game: 50 demônios
    # - DEMON-001..DEMON-045 (45) + BOSS-001..BOSS-005 (5) = 50
    # Mid Game: 95 demônios
    # - DEMON-046..DEMON-050 (5) + BOSS-006..BOSS-008 (3)
    # - DEMON-051..DEMON-100 (50) + BOSS-009..BOSS-016 (8)
    # - DEMON-101..DEMON-125 (25) + BOSS-017..BOSS-020 (4)
    # Subtotal = 5+3+50+8+25+4 = 95
    # End Game: 85 demônios
    # - DEMON-126..DEMON-150 (25) + BOSS-021..BOSS-023 (3)
    # - DEMON-151..DEMON-190 (40) + BOSS-024..BOSS-030 (7)
    # - DEMON-191..DEMON-200 (10)
    # Subtotal = 25+3+40+7+10 = 85
    # Total = 50 + 95 + 85 = 230
    if did.startswith("DEMON-"):
        num = int(did.split("-")[1])
        if num <= 45:
            return "Early Game", "Níveis 1–15", "Ameaça E (Comum) a D (Incomum)"
        elif num <= 125:
            return "Mid Game", "Níveis 16–35", "Ameaça C (Perigoso) a B (Veterano)"
        elif num <= 190:
            return "End Game", "Níveis 36–55", "Ameaça A (Letal) a S (Elite Superior)"
        else:
            return "End Game", "Níveis 55–65+", "Ameaça SS (Primordial / Calamidade)"
    elif did.startswith("BOSS-"):
        num = int(did.split("-")[1])
        if num <= 5:
            return "Early Game", "Níveis 10–18", "Ameaça S (Chefe Regional - Inicial)"
        elif num <= 20:
            return "Mid Game", "Níveis 20–40", "Ameaça S+ (Chefe Regional - Veterano)"
        else:
            return "End Game", "Níveis 45–60+", "Ameaça SS (Lorde Supremo de Masmorra)"
    return "Mid Game", "Níveis 20–30", "Ameaça B"

print("Setup complete. Ready to build files.")
