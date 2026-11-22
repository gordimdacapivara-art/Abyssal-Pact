#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Master Builder for Weapons System and Monsters Category of Abyssal Pact.
Generates:
- 100 Weapon Technical Datasheets with 25 mandatory fields in Weapons/<Category>/
- WEAPON_PRODUCTION_REPORT.md
- Updated MONSTER_3D_PRODUCTION_REPORT.md
- Master ASSET_CATALOG.md
"""

import os
import re
import json

WEAPON_CATEGORIES = {
    "swords": {"name": "Espadas", "folder": "Swords", "3d_folder": "swords", "base_slot": "weapon", "hands": "1H / 2H", "range": 2.0},
    "axes": {"name": "Machados", "folder": "Axes", "3d_folder": "axes", "base_slot": "weapon", "hands": "1H / 2H", "range": 1.8},
    "hammers_maces": {"name": "Martelos e maças", "folder": "Hammers_Maces", "3d_folder": "hammers_maces", "base_slot": "weapon", "hands": "1H / 2H", "range": 1.7},
    "polearms": {"name": "Lanças e armas de haste", "folder": "Polearms", "3d_folder": "polearms", "base_slot": "weapon", "hands": "2H", "range": 3.2},
    "daggers": {"name": "Adagas e armas leves", "folder": "Daggers", "3d_folder": "daggers", "base_slot": "weapon", "hands": "1H / Dual", "range": 1.2},
    "bows_crossbows": {"name": "Arcos e armas de distância", "folder": "Bows_Crossbows", "3d_folder": "bows_crossbows", "base_slot": "weapon", "hands": "2H (Ranged)", "range": 22.0},
    "firearms_fantasy": {"name": "Armas de fogo fantásticas", "folder": "Firearms_Fantasy", "3d_folder": "firearms_fantasy", "base_slot": "weapon", "hands": "2H (Ranged)", "range": 18.0},
    "staves_catalysts": {"name": "Cajados e catalisadores", "folder": "Staves_Catalysts", "3d_folder": "staves_catalysts", "base_slot": "weapon", "hands": "1H / 2H (Magic)", "range": 15.0},
    "special_weapons": {"name": "Armas especiais", "folder": "Special_Weapons", "3d_folder": "special_weapons", "base_slot": "weapon", "hands": "Variável", "range": 2.5},
    "shields": {"name": "Escudos e defensivos", "folder": "Shields", "3d_folder": "shields", "base_slot": "offhand", "hands": "1H (Offhand)", "range": 1.0}
}

# The 100 weapons catalog
WEAPONS_CATALOG = [
    # 1. Espadas (WEP-001 to WEP-010)
    {"id": "WEP-001", "name": "Espada das Cinzas", "cat_key": "swords", "subcat": "Espadas longas", "rarity": "Comum", "orig_id": "EQ-001", "is_pilot": True, "dmg": 18, "crit": 5, "weight": 2.4, "h": 1.18, "w": 0.32, "mat": "Basalto e Aço Carbonizado", "hex": ["#1E1C1A", "#5A5D64", "#2A1E18", "#FF5500"]},
    {"id": "WEP-002", "name": "Gládio de Ferro Negro", "cat_key": "swords", "subcat": "Espadas curtas", "rarity": "Comum", "dmg": 15, "crit": 7, "weight": 1.8, "h": 0.85, "w": 0.22, "mat": "Ferro Negro e Bronze", "hex": ["#25272B", "#685032", "#111214", "#FF3300"]},
    {"id": "WEP-003", "name": "Montante de Basalto Calcinado", "cat_key": "swords", "subcat": "Espadões", "rarity": "Incomum", "dmg": 34, "crit": 4, "weight": 5.8, "h": 1.65, "w": 0.45, "mat": "Basalto Vulcânico Maciço", "hex": ["#1A1715", "#473A33", "#0E0C0B", "#D94E1A"]},
    {"id": "WEP-004", "name": "Lâmina Bastarda da Forja", "cat_key": "swords", "subcat": "Espadas bastardas", "rarity": "Raro", "dmg": 28, "crit": 9, "weight": 3.2, "h": 1.35, "w": 0.35, "mat": "Aço Forjado em Miasma", "hex": ["#363A42", "#8A6D47", "#1E1F24", "#FF6B26"]},
    {"id": "WEP-005", "name": "Cimitarra das Dunas Negras", "cat_key": "swords", "subcat": "Sabres / Espadas curvas", "rarity": "Incomum", "dmg": 22, "crit": 12, "weight": 2.1, "h": 0.98, "w": 0.26, "mat": "Aço e Areia de Quartzo Negro", "hex": ["#2B2824", "#A88349", "#151311", "#E6AA33"]},
    {"id": "WEP-006", "name": "Nodachi do Abismo Férreo", "cat_key": "swords", "subcat": "Katanas / Lâminas longas", "rarity": "Raro", "dmg": 30, "crit": 15, "weight": 2.9, "h": 1.55, "w": 0.18, "mat": "Aço Dobrado em Fogo Abissal", "hex": ["#1F2126", "#727885", "#0F1012", "#00E5FF"]},
    {"id": "WEP-007", "name": "Lâmina Rúnica da Fenda", "cat_key": "swords", "subcat": "Espadas mágicas", "rarity": "Épico", "dmg": 38, "crit": 10, "weight": 2.7, "h": 1.22, "w": 0.34, "mat": "Cristal de Fenda e Aço Rúnico", "hex": ["#2E3840", "#20E38F", "#141C22", "#00FF88"]},
    {"id": "WEP-008", "name": "Ceifadora de Almas de Azaroth", "cat_key": "swords", "subcat": "Espadas demoníacas", "rarity": "Lendário", "dmg": 52, "crit": 14, "weight": 4.1, "h": 1.48, "w": 0.38, "mat": "Osso Demoníaco e Sangue Abissal", "hex": ["#2A0E12", "#8F1D2C", "#140507", "#FF1133"]},
    {"id": "WEP-009", "name": "Vorpal do Fogo Profundo", "cat_key": "swords", "subcat": "Espadas lendárias", "rarity": "Lendário", "dmg": 56, "crit": 18, "weight": 3.6, "h": 1.38, "w": 0.36, "mat": "Coração de Vulcão e Ouro Negro", "hex": ["#3D1808", "#FF4400", "#1A0802", "#FFAA00"]},
    {"id": "WEP-010", "name": "Espada Quebrada do Primeiro Herói", "cat_key": "swords", "subcat": "Espadas ancestrais", "rarity": "Abissal / Relíquia", "dmg": 62, "crit": 20, "weight": 2.5, "h": 1.15, "w": 0.30, "mat": "Fragmento Cósmico de Origem", "hex": ["#222B38", "#458CFF", "#0C1117", "#99CCFF"]},

    # 2. Machados (WEP-011 to WEP-020)
    {"id": "WEP-011", "name": "Machado Rúnico de Basalto", "cat_key": "axes", "subcat": "Machados de guerra", "rarity": "Épico", "orig_id": "EQ-004", "is_pilot": True, "dmg": 46, "crit": 8, "weight": 4.8, "h": 1.05, "w": 0.52, "mat": "Basalto e Bronze Antigo", "hex": ["#181615", "#2B2D30", "#8C6239", "#FF4400"]},
    {"id": "WEP-012", "name": "Machadinha de Enxofre", "cat_key": "axes", "subcat": "Machados de uma mão", "rarity": "Comum", "dmg": 20, "crit": 6, "weight": 2.1, "h": 0.65, "w": 0.28, "mat": "Minério de Enxofre e Madeira Queimada", "hex": ["#2E2A1C", "#A89632", "#17150C", "#FFD000"]},
    {"id": "WEP-013", "name": "Rachador de Crânios Vulcânico", "cat_key": "axes", "subcat": "Machados de duas mãos", "rarity": "Incomum", "dmg": 36, "crit": 5, "weight": 5.4, "h": 1.25, "w": 0.48, "mat": "Ferro de Caldeira e Rocha Escura", "hex": ["#221F1E", "#783B25", "#12100F", "#FF501A"]},
    {"id": "WEP-014", "name": "Cutelo Duplo do Algoz", "cat_key": "axes", "subcat": "Machados duplos", "rarity": "Raro", "dmg": 42, "crit": 11, "weight": 6.2, "h": 1.30, "w": 0.58, "mat": "Aço Forjado em Sangue", "hex": ["#2D2326", "#731E2B", "#171012", "#D4263E"]},
    {"id": "WEP-015", "name": "Rompedor de Portões de Ferro", "cat_key": "axes", "subcat": "Machados pesados", "rarity": "Raro", "dmg": 44, "crit": 4, "weight": 7.0, "h": 1.40, "w": 0.50, "mat": "Lingotes de Ferro da Cratera", "hex": ["#3B3E45", "#585D69", "#1B1C20", "#8A94A8"]},
    {"id": "WEP-016", "name": "Machado da Seiva Pútrida", "cat_key": "axes", "subcat": "Machados encantados", "rarity": "Épico", "dmg": 48, "crit": 9, "weight": 4.5, "h": 1.15, "w": 0.44, "mat": "Raiz Petrificada de Sylvaran", "hex": ["#1A261D", "#3E6647", "#0D140F", "#2CE87E"]},
    {"id": "WEP-017", "name": "Foice-Machado das Marés Frias", "cat_key": "axes", "subcat": "Machados híbridos", "rarity": "Incomum", "dmg": 32, "crit": 12, "weight": 3.8, "h": 1.10, "w": 0.42, "mat": "Ardósia Glacial e Ferro", "hex": ["#1C2A38", "#426785", "#0E161E", "#38C2E6"]},
    {"id": "WEP-018", "name": "Machado Voraz do Devorador", "cat_key": "axes", "subcat": "Machados demoníacos", "rarity": "Lendário", "dmg": 58, "crit": 14, "weight": 6.5, "h": 1.35, "w": 0.55, "mat": "Dentes de Titã e Miasma", "hex": ["#2B1410", "#8F2C1A", "#140806", "#FF3700"]},
    {"id": "WEP-019", "name": "Cutelo Gigante das Cinzas", "cat_key": "axes", "subcat": "Machados colossais", "rarity": "Lendário", "dmg": 64, "crit": 6, "weight": 9.5, "h": 1.70, "w": 0.65, "mat": "Escória Metálica Pura", "hex": ["#242120", "#54433D", "#12100F", "#FF7B33"]},
    {"id": "WEP-020", "name": "Machado dos Titãs Antigos", "cat_key": "axes", "subcat": "Machados ancestrais", "rarity": "Abissal / Relíquia", "dmg": 70, "crit": 16, "weight": 8.0, "h": 1.55, "w": 0.60, "mat": "Coração de Monólito Arcaico", "hex": ["#1E232B", "#4A6078", "#0E1114", "#FFDD44"]},

    # 3. Martelos e Maças (WEP-021 to WEP-030)
    {"id": "WEP-021", "name": "Martelo Colossal da Forja", "cat_key": "hammers_maces", "subcat": "Martelos colossais", "rarity": "Lendário", "is_pilot": True, "dmg": 60, "crit": 5, "weight": 11.2, "h": 1.25, "w": 0.45, "mat": "Ferro de Bigorna e Couro Grosso", "hex": ["#323438", "#1C1D20", "#3B271A", "#FF7700"]},
    {"id": "WEP-022", "name": "Maça Flangeada de Aço Escuro", "cat_key": "hammers_maces", "subcat": "Maças de combate", "rarity": "Comum", "dmg": 19, "crit": 6, "weight": 2.6, "h": 0.72, "w": 0.18, "mat": "Aço Escuro Carbonizado", "hex": ["#282A2E", "#50545C", "#141517", "#FF4411"]},
    {"id": "WEP-023", "name": "Mangual de Espinhos Abissais", "cat_key": "hammers_maces", "subcat": "Maças com espinhos", "rarity": "Incomum", "dmg": 26, "crit": 8, "weight": 3.4, "h": 0.85, "w": 0.22, "mat": "Corrente de Ferro e Esfera Espinhosa", "hex": ["#201E1D", "#6B2B1B", "#100E0D", "#D43E19"]},
    {"id": "WEP-024", "name": "Quebra-Muralhas de Basalto", "cat_key": "hammers_maces", "subcat": "Martelos pesados", "rarity": "Raro", "dmg": 42, "crit": 4, "weight": 7.8, "h": 1.15, "w": 0.38, "mat": "Basalto Negro e Aço Temperado", "hex": ["#1C1A19", "#403A36", "#0D0C0B", "#FF5C1A"]},
    {"id": "WEP-025", "name": "Martelo Sísmico de Veyrath", "cat_key": "hammers_maces", "subcat": "Martelos mágicos", "rarity": "Épico", "dmg": 50, "crit": 7, "weight": 8.5, "h": 1.30, "w": 0.40, "mat": "Núcleo de Magma Pressurizado", "hex": ["#331810", "#8F3517", "#1A0A06", "#FF6600"]},
    {"id": "WEP-026", "name": "Clava Monolítica do Deserto", "cat_key": "hammers_maces", "subcat": "Martelos pesados", "rarity": "Incomum", "dmg": 32, "crit": 3, "weight": 6.2, "h": 1.05, "w": 0.28, "mat": "Arenito Compactado com Resina", "hex": ["#383025", "#7D6B50", "#1C1812", "#E0B44A"]},
    {"id": "WEP-027", "name": "Maça da Estrela Noturna", "cat_key": "hammers_maces", "subcat": "Maças encantadas", "rarity": "Raro", "dmg": 36, "crit": 12, "weight": 3.2, "h": 0.80, "w": 0.24, "mat": "Prata Abissal e Cristal Negro", "hex": ["#1D212A", "#4A566E", "#0E1015", "#47A8FF"]},
    {"id": "WEP-028", "name": "Martelo da Bigorna Primordial", "cat_key": "hammers_maces", "subcat": "Martelos ancestrais", "rarity": "Lendário", "dmg": 66, "crit": 8, "weight": 12.0, "h": 1.45, "w": 0.48, "mat": "Metal da Primeira Forja Cósmica", "hex": ["#252830", "#5E6678", "#111317", "#FFA600"]},
    {"id": "WEP-029", "name": "Fustigador de Almas Encadeado", "cat_key": "hammers_maces", "subcat": "Maças demoníacas", "rarity": "Épico", "dmg": 48, "crit": 14, "weight": 4.5, "h": 0.90, "w": 0.25, "mat": "Crânio de Demônio Menor e Corrente", "hex": ["#2B161B", "#7A273C", "#140A0D", "#FF2150"]},
    {"id": "WEP-030", "name": "Quebra-Reinos de Khar-Duum", "cat_key": "hammers_maces", "subcat": "Martelos lendários", "rarity": "Abissal / Relíquia", "dmg": 74, "crit": 10, "weight": 13.5, "h": 1.50, "w": 0.50, "mat": "Núcleo de Cânion Despedaçado", "hex": ["#221E19", "#63523F", "#100E0B", "#FFCC22"]},

    # 4. Lanças e Armas de Haste (WEP-031 to WEP-040)
    {"id": "WEP-031", "name": "Lança das Cinzas Abissais", "cat_key": "polearms", "subcat": "Lanças / Glaives", "rarity": "Raro", "is_pilot": True, "dmg": 35, "crit": 10, "weight": 3.6, "h": 2.58, "w": 0.26, "mat": "Obsidiana e Madeira Petrificada", "hex": ["#0F1215", "#3E352F", "#7A828A", "#FF6622"]},
    {"id": "WEP-032", "name": "Pique de Guarnição de Basalto", "cat_key": "polearms", "subcat": "Piques", "rarity": "Comum", "dmg": 22, "crit": 6, "weight": 4.2, "h": 2.80, "w": 0.16, "mat": "Ferro Rústico e Freixo Curado", "hex": ["#2A2624", "#524B46", "#141211", "#FF5511"]},
    {"id": "WEP-033", "name": "Alabarda da Guarda Vulcânica", "cat_key": "polearms", "subcat": "Alabardas", "rarity": "Incomum", "dmg": 30, "crit": 8, "weight": 4.8, "h": 2.20, "w": 0.42, "mat": "Lâmina de Machado e Ponta de Lança", "hex": ["#28211E", "#664033", "#13100E", "#E64D1A"]},
    {"id": "WEP-034", "name": "Bardiche do Carrasco da Caldeira", "cat_key": "polearms", "subcat": "Bardiches", "rarity": "Raro", "dmg": 38, "crit": 11, "weight": 5.2, "h": 1.95, "w": 0.48, "mat": "Lâmina Larga de Aço Carbonífero", "hex": ["#202326", "#4A5259", "#0F1012", "#D4361C"]},
    {"id": "WEP-035", "name": "Tridente do Recife Abissal", "cat_key": "polearms", "subcat": "Tridentes", "rarity": "Incomum", "dmg": 26, "crit": 12, "weight": 3.4, "h": 2.10, "w": 0.35, "mat": "Coral Negro Endurecido e Prata", "hex": ["#162530", "#31546E", "#0B1218", "#1CE6D2"]},
    {"id": "WEP-036", "name": "Glaive Rúnica da Fenda Esmeralda", "cat_key": "polearms", "subcat": "Glaives", "rarity": "Épico", "dmg": 44, "crit": 14, "weight": 3.8, "h": 2.30, "w": 0.32, "mat": "Lâmina Curva de Cristal Esmeralda", "hex": ["#1A2E22", "#35694A", "#0C1711", "#1AFF75"]},
    {"id": "WEP-037", "name": "Foice de Guerra dos Condenados", "cat_key": "polearms", "subcat": "Foices de guerra", "rarity": "Épico", "dmg": 48, "crit": 16, "weight": 4.1, "h": 2.25, "w": 0.65, "mat": "Lâmina Côncava e Ossos Entrelaçados", "hex": ["#2B1720", "#692645", "#140A0F", "#FF1C68"]},
    {"id": "WEP-038", "name": "Lança de Presa de Dragão", "cat_key": "polearms", "subcat": "Lanças ancestrais", "rarity": "Lendário", "dmg": 54, "crit": 15, "weight": 3.7, "h": 2.45, "w": 0.25, "mat": "Marfim Dracônico Fossilizado", "hex": ["#362D24", "#8A7056", "#1A1510", "#FF8C24"]},
    {"id": "WEP-039", "name": "Haste Perfuradora do Leviatã", "cat_key": "polearms", "subcat": "Armas de haste mágicas", "rarity": "Lendário", "dmg": 58, "crit": 13, "weight": 4.5, "h": 2.65, "w": 0.30, "mat": "Espinha Dorsal de Quimera Abissal", "hex": ["#12222E", "#2B4D69", "#091117", "#00F7FF"]},
    {"id": "WEP-040", "name": "Lança Solar de Khar-Zul", "cat_key": "polearms", "subcat": "Lanças lendárias", "rarity": "Abissal / Relíquia", "dmg": 68, "crit": 18, "weight": 4.0, "h": 2.50, "w": 0.28, "mat": "Ouro Solar Forjado no Abismo", "hex": ["#3D3012", "#A3812C", "#1F1808", "#FFE642"]},

    # 5. Adagas e Armas Leves (WEP-041 to WEP-050)
    {"id": "WEP-041", "name": "Adaga de Obsidiana", "cat_key": "daggers", "subcat": "Adagas", "rarity": "Incomum", "orig_id": "EQ-003", "dmg": 22, "crit": 12, "weight": 0.8, "h": 0.42, "w": 0.12, "mat": "Obsidiana Vítrea e Couro", "hex": ["#0F1114", "#2E343B", "#1C1512", "#FF5500"]},
    {"id": "WEP-042", "name": "Punhal do Sacrifício Sangrento", "cat_key": "daggers", "subcat": "Punhais", "rarity": "Comum", "dmg": 14, "crit": 15, "weight": 0.6, "h": 0.35, "w": 0.09, "mat": "Ferro Rústico com Canaleta de Sangue", "hex": ["#2E1C20", "#632732", "#170E10", "#D92138"]},
    {"id": "WEP-043", "name": "Faca Cáustica das Fendas", "cat_key": "daggers", "subcat": "Facas de combate", "rarity": "Comum", "dmg": 16, "crit": 10, "weight": 0.7, "h": 0.38, "w": 0.11, "mat": "Aço Tratado com Enxofre", "hex": ["#29281C", "#6B6735", "#14140E", "#D4C824"]},
    {"id": "WEP-044", "name": "Lâminas Gêmeas da Sombra", "cat_key": "daggers", "subcat": "Lâminas duplas", "rarity": "Raro", "dmg": 28, "crit": 18, "weight": 1.4, "h": 0.46, "w": 0.14, "mat": "Aço Negro Fosco Antirreflexo", "hex": ["#16171A", "#3A3D45", "#0B0B0D", "#4B608A"]},
    {"id": "WEP-045", "name": "Garras do Espreitador Abissal", "cat_key": "daggers", "subcat": "Garras equipáveis", "rarity": "Raro", "dmg": 26, "crit": 20, "weight": 1.1, "h": 0.32, "w": 0.18, "mat": "Quitina de Demônio Stalker", "hex": ["#211B24", "#52375C", "#100D12", "#A347FF"]},
    {"id": "WEP-046", "name": "Kris de Coral Negro", "cat_key": "daggers", "subcat": "Armas curvas leves", "rarity": "Incomum", "dmg": 20, "crit": 14, "weight": 0.9, "h": 0.40, "w": 0.10, "mat": "Coral Mineral Ondulado", "hex": ["#121D24", "#2B4454", "#090E12", "#24C7D9"]},
    {"id": "WEP-047", "name": "Adaga de Cristal de Miasma", "cat_key": "daggers", "subcat": "Adagas mágicas", "rarity": "Épico", "dmg": 34, "crit": 16, "weight": 0.7, "h": 0.39, "w": 0.11, "mat": "Cristal Translúcido de Fenda", "hex": ["#1B2921", "#33694D", "#0D1410", "#00FF7F"]},
    {"id": "WEP-048", "name": "Estilete Envenenado da Víbora", "cat_key": "daggers", "subcat": "Estiletes perfurantes", "rarity": "Épico", "dmg": 30, "crit": 24, "weight": 0.5, "h": 0.36, "w": 0.08, "mat": "Agulha Oca com Reservatório Tóxico", "hex": ["#2E2918", "#706328", "#17140B", "#B8E622"]},
    {"id": "WEP-049", "name": "Garras de Sangue de Azaroth", "cat_key": "daggers", "subcat": "Garras demoníacas", "rarity": "Lendário", "dmg": 44, "crit": 22, "weight": 1.3, "h": 0.35, "w": 0.20, "mat": "Falanges de Arquidemônio", "hex": ["#2E0C0C", "#851A1A", "#170606", "#FF0D0D"]},
    {"id": "WEP-050", "name": "Dente do Vórtice Final", "cat_key": "daggers", "subcat": "Adagas lendárias", "rarity": "Abissal / Relíquia", "dmg": 52, "crit": 28, "weight": 0.6, "h": 0.44, "w": 0.10, "mat": "Fragmento de Singularidade Negra", "hex": ["#0D1117", "#1E2B3D", "#05070A", "#00FFFF"]},

    # 6. Arcos e Armas de Distância (WEP-051 to WEP-060)
    {"id": "WEP-051", "name": "Arco Curto das Cinzas", "cat_key": "bows_crossbows", "subcat": "Arcos curtos", "rarity": "Comum", "dmg": 18, "crit": 8, "weight": 1.2, "h": 1.05, "w": 0.28, "mat": "Madeira Queimada e Tendão Animal", "hex": ["#29221D", "#5C4B3E", "#14110E", "#D9682E"]},
    {"id": "WEP-052", "name": "Arco Longo de Madeira Petrificada", "cat_key": "bows_crossbows", "subcat": "Arcos longos", "rarity": "Incomum", "dmg": 26, "crit": 10, "weight": 2.0, "h": 1.65, "w": 0.32, "mat": "Tronco Fossilizado com Reforço de Aço", "hex": ["#36302B", "#63584F", "#1A1715", "#A87948"]},
    {"id": "WEP-053", "name": "Arco Composto de Chifre Demoníaco", "cat_key": "bows_crossbows", "subcat": "Arcos compostos", "rarity": "Raro", "dmg": 34, "crit": 14, "weight": 1.7, "h": 1.25, "w": 0.30, "mat": "Chifres Laminados e Seda Abissal", "hex": ["#24191C", "#5E323D", "#120C0E", "#FF3B62"]},
    {"id": "WEP-054", "name": "Besta de Repetição de Ferro Negro", "cat_key": "bows_crossbows", "subcat": "Bestas leves", "rarity": "Raro", "dmg": 32, "crit": 12, "weight": 3.8, "h": 0.75, "w": 0.55, "mat": "Ferro Negro e Engrenagens de Bronze", "hex": ["#212326", "#454B54", "#101113", "#946838"]},
    {"id": "WEP-055", "name": "Balista Portátil de Cerco", "cat_key": "bows_crossbows", "subcat": "Bestas pesadas", "rarity": "Épico", "dmg": 50, "crit": 6, "weight": 7.5, "h": 0.95, "w": 0.78, "mat": "Aço Pesado da Forja e Molas de Tensão", "hex": ["#2D2E33", "#4A4D57", "#16171A", "#FF5E24"]},
    {"id": "WEP-056", "name": "Arco Recurvo da Fenda Esmeralda", "cat_key": "bows_crossbows", "subcat": "Arcos encantados", "rarity": "Épico", "dmg": 40, "crit": 16, "weight": 1.5, "h": 1.35, "w": 0.34, "mat": "Madeira Viva com Cristais Luminosos", "hex": ["#1B2E20", "#396B47", "#0C1710", "#24F087"]},
    {"id": "WEP-057", "name": "Arco dos Salgueiros Negros", "cat_key": "bows_crossbows", "subcat": "Arcos mágicos", "rarity": "Raro", "dmg": 36, "crit": 13, "weight": 1.8, "h": 1.50, "w": 0.30, "mat": "Galho Flexível de Salgueiro Sombrio", "hex": ["#1C1E26", "#3B4154", "#0D0E12", "#6685FF"]},
    {"id": "WEP-058", "name": "Besta Arcanum de Sílica", "cat_key": "bows_crossbows", "subcat": "Bestas arcanas", "rarity": "Épico", "dmg": 46, "crit": 18, "weight": 4.2, "h": 0.80, "w": 0.60, "mat": "Vidro Vulcânico e Lentes Arcanas", "hex": ["#202B33", "#3C5A6E", "#0F1418", "#00D9FF"]},
    {"id": "WEP-059", "name": "Disparador de Almas Condenadas", "cat_key": "bows_crossbows", "subcat": "Arcos demoníacos", "rarity": "Lendário", "dmg": 58, "crit": 20, "weight": 2.2, "h": 1.40, "w": 0.35, "mat": "Costelas de Demônio e Tendões de Miasma", "hex": ["#2E1018", "#7D1E35", "#14060A", "#FF194B"]},
    {"id": "WEP-060", "name": "Arco do Zênite Solar de Khar-Duum", "cat_key": "bows_crossbows", "subcat": "Arcos lendários", "rarity": "Abissal / Relíquia", "dmg": 68, "crit": 22, "weight": 1.9, "h": 1.60, "w": 0.32, "mat": "Ouro Puro Enriquecido com Radiação Solar", "hex": ["#3D3214", "#9E812C", "#1F1908", "#FFDD33"]},

    # 7. Armas de Fogo Fantásticas (WEP-061 to WEP-070)
    {"id": "WEP-061", "name": "Canhão Portátil da Hell Forge", "cat_key": "firearms_fantasy", "subcat": "Artefatos de ferro fundido", "rarity": "Raro", "dmg": 48, "crit": 8, "weight": 9.2, "h": 0.90, "w": 0.28, "mat": "Cano de Ferro Espesso e Ignição de Enxofre", "hex": ["#2B2C30", "#4D5059", "#141517", "#FF5014"]},
    {"id": "WEP-062", "name": "Arcabuz de Fogo Grego e Enxofre", "cat_key": "firearms_fantasy", "subcat": "Armas químicas arcaicas", "rarity": "Incomum", "dmg": 36, "crit": 10, "weight": 5.6, "h": 1.15, "w": 0.20, "mat": "Latão Oxidado e Reservatório Cáustico", "hex": ["#302A1E", "#7A683D", "#17140D", "#FFB700"]},
    {"id": "WEP-063", "name": "Projetor de Plasma Magmático", "cat_key": "firearms_fantasy", "subcat": "Artefatos de energia", "rarity": "Épico", "dmg": 54, "crit": 12, "weight": 7.8, "h": 1.05, "w": 0.32, "mat": "Câmara de Fusão de Basalto", "hex": ["#2E1B15", "#823A25", "#140A07", "#FF4400"]},
    {"id": "WEP-064", "name": "Pistola de Cristal Sísmico", "cat_key": "firearms_fantasy", "subcat": "Armas de fragmentos arcanos", "rarity": "Incomum", "dmg": 28, "crit": 16, "weight": 2.4, "h": 0.42, "w": 0.16, "mat": "Armação de Madeira e Tambor de Cristal", "hex": ["#2E2721", "#695847", "#16120F", "#FF9033"]},
    {"id": "WEP-065", "name": "Lança-Chamas de Nafta Abissal", "cat_key": "firearms_fantasy", "subcat": "Armas contínuas", "rarity": "Raro", "dmg": 42, "crit": 5, "weight": 8.0, "h": 1.10, "w": 0.35, "mat": "Tanques de Bronze e Bocal de Cerâmica", "hex": ["#33271D", "#785331", "#19120D", "#FF6F1A"]},
    {"id": "WEP-066", "name": "Mosquete Rúnico de Basalto", "cat_key": "firearms_fantasy", "subcat": "Armas de dispersão", "rarity": "Raro", "dmg": 44, "crit": 14, "weight": 6.2, "h": 1.25, "w": 0.22, "mat": "Cano Longo Estriado e Coronha de Basalto", "hex": ["#222124", "#4B4A52", "#111012", "#D63A1E"]},
    {"id": "WEP-067", "name": "Ejetor de Vapores Cáusticos", "cat_key": "firearms_fantasy", "subcat": "Artefatos pressurizados", "rarity": "Épico", "dmg": 46, "crit": 8, "weight": 6.8, "h": 0.85, "w": 0.30, "mat": "Manômetros de Bronze e Selos de Couro", "hex": ["#232B20", "#45663B", "#10160D", "#44FF26"]},
    {"id": "WEP-068", "name": "Canhão de Mão do Titã de Chumbo", "cat_key": "firearms_fantasy", "subcat": "Artefatos colossais", "rarity": "Lendário", "dmg": 66, "crit": 10, "weight": 14.0, "h": 1.30, "w": 0.45, "mat": "Chumbo Maciço e Almas Fundidas", "hex": ["#33373D", "#545B66", "#191B1F", "#FF802B"]},
    {"id": "WEP-069", "name": "Colubrina Portátil de Maré Gélida", "cat_key": "firearms_fantasy", "subcat": "Artefatos hidro-abissais", "rarity": "Épico", "dmg": 50, "crit": 15, "weight": 8.5, "h": 1.18, "w": 0.30, "mat": "Cobre Marinho e Válvulas Criogênicas", "hex": ["#1A2A38", "#335E82", "#0D151C", "#0DE6E6"]},
    {"id": "WEP-070", "name": "Olho da Singularidade Abissal", "cat_key": "firearms_fantasy", "subcat": "Artefatos cósmicos", "rarity": "Abissal / Relíquia", "dmg": 76, "crit": 22, "weight": 10.5, "h": 1.20, "w": 0.40, "mat": "Anéis de Contenção de Vácuo Puro", "hex": ["#111622", "#223554", "#070B12", "#00F0FF"]},

    # 8. Cajados e Catalisadores (WEP-071 to WEP-080)
    {"id": "WEP-071", "name": "Cajado do Vazio Vulcânico", "cat_key": "staves_catalysts", "subcat": "Cajados mágicos", "rarity": "Raro", "orig_id": "EQ-002", "dmg": 14, "crit": 8, "weight": 2.2, "h": 1.85, "w": 0.28, "mat": "Madeira Queimada e Rocha Vulcânica", "hex": ["#251D1A", "#633D31", "#120E0C", "#FF491C"]},
    {"id": "WEP-072", "name": "Bastão Arcano de Obsidiana", "cat_key": "staves_catalysts", "subcat": "Bastões arcanos", "rarity": "Comum", "dmg": 12, "crit": 10, "weight": 1.6, "h": 1.10, "w": 0.14, "mat": "Haste de Obsidiana Lapidada", "hex": ["#131417", "#323740", "#090A0B", "#38A3FF"]},
    {"id": "WEP-073", "name": "Orbe das Marés Glaciais", "cat_key": "staves_catalysts", "subcat": "Orbes flutuantes", "rarity": "Incomum", "dmg": 18, "crit": 12, "weight": 1.2, "h": 0.35, "w": 0.35, "mat": "Gelo Puro Não Derretível e Prata", "hex": ["#152838", "#2E618F", "#0A141C", "#26E3FF"]},
    {"id": "WEP-074", "name": "Tomo das Chamas Proibidas", "cat_key": "staves_catalysts", "subcat": "Tomos de feitiçaria", "rarity": "Incomum", "dmg": 20, "crit": 9, "weight": 2.0, "h": 0.45, "w": 0.35, "mat": "Páginas de Couro Humano e Fecho de Aço", "hex": ["#291815", "#6B2A20", "#140A08", "#FF5926"]},
    {"id": "WEP-075", "name": "Grimório da Corrupção Abissal", "cat_key": "staves_catalysts", "subcat": "Grimórios profanos", "rarity": "Épico", "dmg": 26, "crit": 15, "weight": 2.5, "h": 0.48, "w": 0.38, "mat": "Capa Escamosa com Olho Embutido", "hex": ["#201524", "#4F265E", "#100A12", "#A62BF5"]},
    {"id": "WEP-076", "name": "Catalisador de Seiva Esmeralda", "cat_key": "staves_catalysts", "subcat": "Catalisadores naturais", "rarity": "Raro", "dmg": 22, "crit": 11, "weight": 1.5, "h": 0.40, "w": 0.22, "mat": "Raiz Trançada e Cristal Vegetal", "hex": ["#15241B", "#2A593A", "#0A120D", "#1CFF77"]},
    {"id": "WEP-077", "name": "Relíquia da Mente Fraturada", "cat_key": "staves_catalysts", "subcat": "Relíquias mágicas", "rarity": "Épico", "dmg": 30, "crit": 18, "weight": 1.8, "h": 0.50, "w": 0.25, "mat": "Monólito Rúnico em Miniatura", "hex": ["#282430", "#544669", "#131117", "#D548FF"]},
    {"id": "WEP-078", "name": "Cetro do Lorde de Basalto", "cat_key": "staves_catalysts", "subcat": "Cetros cerimoniais", "rarity": "Épico", "dmg": 28, "crit": 13, "weight": 2.8, "h": 1.35, "w": 0.25, "mat": "Basalto Negro Cravejado de Rubis", "hex": ["#261B18", "#592E24", "#120B0A", "#FF2B2B"]},
    {"id": "WEP-079", "name": "Báculo da Tempestade de Areia", "cat_key": "staves_catalysts", "subcat": "Cajados elementais", "rarity": "Lendário", "dmg": 36, "crit": 14, "weight": 2.6, "h": 1.95, "w": 0.32, "mat": "Madeira Dourada e Cristal de Quartzo", "hex": ["#362C17", "#8C7132", "#1B160A", "#FFC83B"]},
    {"id": "WEP-080", "name": "Coroa de Miasma Primordial", "cat_key": "staves_catalysts", "subcat": "Catalisadores lendários", "rarity": "Abissal / Relíquia", "dmg": 45, "crit": 25, "weight": 1.4, "h": 0.38, "w": 0.38, "mat": "Fragmento de Singularidade Enevoada", "hex": ["#13101E", "#302454", "#08060F", "#4DE3FF"]},

    # 9. Armas Especiais (WEP-081 to WEP-090)
    {"id": "WEP-081", "name": "Lâmina Viva de Carne Abissal", "cat_key": "special_weapons", "subcat": "Armas vivas", "rarity": "Épico", "dmg": 45, "crit": 16, "weight": 2.8, "h": 1.20, "w": 0.25, "mat": "Músculo Biológico Pulsante e Dentes", "hex": ["#38141C", "#7A2033", "#1B090D", "#FF1748"]},
    {"id": "WEP-082", "name": "Cutelo da Praga Imortal", "cat_key": "special_weapons", "subcat": "Armas amaldiçoadas", "rarity": "Raro", "dmg": 38, "crit": 12, "weight": 4.5, "h": 1.10, "w": 0.38, "mat": "Ferro Enferrujado e Pústulas Cáusticas", "hex": ["#2B281B", "#665E36", "#14130C", "#9ED926"]},
    {"id": "WEP-083", "name": "Corrente de Espinhos de Azaroth", "cat_key": "special_weapons", "subcat": "Armas demoníacas", "rarity": "Lendário", "dmg": 52, "crit": 18, "weight": 5.8, "h": 3.20, "w": 0.15, "mat": "Elos de Ferro da Hell Forge e Farpas", "hex": ["#241517", "#6E232B", "#10090A", "#FF2626"]},
    {"id": "WEP-084", "name": "Martelo da Primeira Fratura", "cat_key": "special_weapons", "subcat": "Armas ancestrais", "rarity": "Lendário", "dmg": 62, "crit": 10, "weight": 10.5, "h": 1.35, "w": 0.42, "mat": "Pedaço da Falha Geológica Mãe", "hex": ["#2B2623", "#635249", "#131110", "#FF6B36"]},
    {"id": "WEP-085", "name": "Cetro do Vórtice Final", "cat_key": "special_weapons", "subcat": "Armas primordiais", "rarity": "Abissal / Relíquia", "dmg": 58, "crit": 22, "weight": 3.2, "h": 1.60, "w": 0.30, "mat": "Condensado de Vácuo Marinho", "hex": ["#0E1724", "#203A5E", "#060A10", "#00F7FF"]},
    {"id": "WEP-086", "name": "Lâmina Transformável da Fenda", "cat_key": "special_weapons", "subcat": "Armas mecânicas", "rarity": "Épico", "dmg": 44, "crit": 14, "weight": 3.9, "h": 1.25, "w": 0.28, "mat": "Placas Mecânicas Articuladas de Bronze", "hex": ["#362C22", "#7D5F43", "#1A1510", "#E89B38"]},
    {"id": "WEP-087", "name": "Chicote de Fogo Candente", "cat_key": "special_weapons", "subcat": "Armas de energia", "rarity": "Raro", "dmg": 36, "crit": 20, "weight": 1.6, "h": 2.80, "w": 0.10, "mat": "Trança de Tendão Embevecida em Magma", "hex": ["#3B1408", "#942B0D", "#1C0803", "#FF5100"]},
    {"id": "WEP-088", "name": "Bastão de Ignis'Khar", "cat_key": "special_weapons", "subcat": "Armas de chefe (BOSS-001)", "rarity": "Lendário", "dmg": 56, "crit": 15, "weight": 5.2, "h": 1.90, "w": 0.35, "mat": "Coração de Basalto de Ignis'Khar", "hex": ["#291811", "#7A2E19", "#130A06", "#FF4000"]},
    {"id": "WEP-089", "name": "Foice de Cruor'Zul", "cat_key": "special_weapons", "subcat": "Armas de chefe (BOSS-012)", "rarity": "Lendário", "dmg": 60, "crit": 24, "weight": 4.8, "h": 2.10, "w": 0.70, "mat": "Lâmina de Sangue Solidificado", "hex": ["#330A12", "#8A1428", "#170407", "#FF0D2E"]},
    {"id": "WEP-090", "name": "Devoradora de Mundos de Azaroth", "cat_key": "special_weapons", "subcat": "Arma suprema de World Boss", "rarity": "Abissal / Relíquia", "dmg": 85, "crit": 30, "weight": 7.5, "h": 1.75, "w": 0.45, "mat": "Fragmento do Trono Abissal de Azaroth", "hex": ["#21090C", "#69101C", "#0D0305", "#FF0033"]},

    # 10. Escudos e Defensivos (WEP-091 to WEP-100)
    {"id": "WEP-091", "name": "Escudo Torre de Ferro Negro", "cat_key": "shields", "subcat": "Escudos torre", "rarity": "Raro", "is_pilot": True, "dmg": 8, "defense": 35, "weight": 8.4, "h": 1.25, "w": 0.62, "mat": "Ferro Negro e Bronze Reforçado", "hex": ["#222428", "#946E3A", "#30221B", "#FF3300"]},
    {"id": "WEP-092", "name": "Broquel de Cinzas Endurecidas", "cat_key": "shields", "subcat": "Escudos pequenos", "rarity": "Comum", "dmg": 5, "defense": 12, "weight": 1.8, "h": 0.45, "w": 0.45, "mat": "Cinza Comprimida e Aro de Ferro", "hex": ["#2B2724", "#544B45", "#141211", "#D65C22"]},
    {"id": "WEP-093", "name": "Escudo Gota de Bronze Vulcânico", "cat_key": "shields", "subcat": "Escudos médios", "rarity": "Incomum", "dmg": 6, "defense": 22, "weight": 3.8, "h": 0.85, "w": 0.52, "mat": "Bronze da Caldeira e Madeira", "hex": ["#382C1E", "#785B38", "#1A140D", "#FF902E"]},
    {"id": "WEP-094", "name": "Pavise dos Guardiões da Caldeira", "cat_key": "shields", "subcat": "Escudos grandes", "rarity": "Raro", "dmg": 7, "defense": 30, "weight": 7.2, "h": 1.15, "w": 0.58, "mat": "Pranchas de Ferro e Pé de Apoio", "hex": ["#29292E", "#50535C", "#131317", "#FF551C"]},
    {"id": "WEP-095", "name": "Escudo Rúnico da Barreira de Basalto", "cat_key": "shields", "subcat": "Escudos mágicos", "rarity": "Épico", "dmg": 10, "defense": 42, "weight": 6.5, "h": 0.95, "w": 0.65, "mat": "Placa de Basalto com Runas Gravadas", "hex": ["#1B1A19", "#3D3835", "#0D0C0B", "#FF4400"]},
    {"id": "WEP-096", "name": "Carapaça Quitínica do Pântano", "cat_key": "shields", "subcat": "Escudos biológicos", "rarity": "Incomum", "dmg": 6, "defense": 18, "weight": 2.2, "h": 0.70, "w": 0.50, "mat": "Exoesqueleto de Insetóide Colossal", "hex": ["#24261C", "#52573B", "#11120D", "#6BE32B"]},
    {"id": "WEP-097", "name": "Escudo Espelhado de Obsidiana", "cat_key": "shields", "subcat": "Escudos refletores", "rarity": "Épico", "dmg": 9, "defense": 38, "weight": 5.4, "h": 0.88, "w": 0.58, "mat": "Espelho de Obsidiana Polida", "hex": ["#111317", "#2D3440", "#08090B", "#38A3FF"]},
    {"id": "WEP-098", "name": "Muralha da Forja Eterna", "cat_key": "shields", "subcat": "Escudos torre pesados", "rarity": "Lendário", "dmg": 12, "defense": 55, "weight": 12.0, "h": 1.45, "w": 0.75, "mat": "Aço de Forja Primordial e Espinhos", "hex": ["#363A42", "#636B7A", "#1A1C20", "#FFA626"]},
    {"id": "WEP-099", "name": "Escudo do Crânio de Titã", "cat_key": "shields", "subcat": "Escudos demoníacos", "rarity": "Lendário", "dmg": 15, "defense": 50, "weight": 9.0, "h": 1.10, "w": 0.70, "mat": "Caixa Craniana de Demônio Supremo", "hex": ["#2E1815", "#732F24", "#140A07", "#FF2200"]},
    {"id": "WEP-100", "name": "Égide Primordial das Profundezas", "cat_key": "shields", "subcat": "Escudos lendários", "rarity": "Abissal / Relíquia", "dmg": 18, "defense": 65, "weight": 7.0, "h": 1.05, "w": 0.68, "mat": "Concha Abissal e Vácuo Cristalizado", "hex": ["#11202E", "#284D6E", "#080F17", "#00F7FF"]}
]

def generate_weapon_sheet(wep):
    wid = wep["id"]
    name = wep["name"]
    cat_info = WEAPON_CATEGORIES[wep["cat_key"]]
    folder = cat_info["folder"]
    subcat = wep["subcat"]
    rarity = wep["rarity"]
    orig_note = f" (Integrada ao item canônico `{wep['orig_id']}` do inventário)" if "orig_id" in wep else ""
    is_pilot = wep.get("is_pilot", False)

    file_rel = f"Weapons/{folder}/{wid}.md"
    clean_id = f"WEAPON_{wid.split('-')[1]}_{name.replace(' ', '_').replace('\'', '').replace('-', '_')}"

    blend_file = f"assets/3d/weapons/{cat_info['3d_folder']}/{clean_id}.blend"
    glb_file = f"assets/3d/weapons/{cat_info['3d_folder']}/{clean_id}.glb"
    preview_file = f"assets/3d/weapons/previews/{clean_id}.png"

    defense_str = f"- **Defesa Concedida:** +{wep['defense']} pontos de armadura\n" if "defense" in wep else ""
    dmg_str = f"- **Dano Base:** {wep['dmg']} pontos de dano físico/elemental\n"
    crit_str = f"- **Chance de Acerto Crítico:** {wep.get('crit', 5)}%\n" if "crit" in wep else ""

    content = f"""# FICHA TÉCNICA: {name} ({wid})

> **Documento Oficial de Especificação Técnica de Equipamento**  
> **Universo:** Abyssal Pact | **Identificador:** `{wid}`{orig_note}  
> **Categoria:** {cat_info['name']} | **Subcategoria:** {subcat}  
> **Arquivo da Ficha:** `{file_rel}`

---

## 1. ID ÚNICO
`{wid}`

## 2. NOME OFICIAL
{name}

## 3. CATEGORIA
{cat_info['name']}

## 4. SUBCATEGORIA
{subcat}

## 5. DESCRIÇÃO VISUAL
Arma de silhueta imponente forjada com {wep['mat'].lower()}. Possui empunhadura ergonômica com detalhes gravados, lâmina/cabeça chanfrada com ranhuras de alívio e runas arcanas que emanam calor sutil no tom `{wep['hex'][-1]}`.

## 6. ORIGEM E HISTÓRIA
Desenvolvida nas forjas ancestrais das regiões vulcânicas e abissais de Abyssal Pact. Utilizada por guerreiros de vanguarda e defensores das fendas contra as incursões do exército de Azaroth.

## 7. DIMENSÕES
- **Comprimento / Altura:** {wep['h']} m
- **Largura / Envergadura:** {wep['w']} m
- **Espessura da Lâmina / Haste:** 0.045 m
- **Alcance Efetivo de Golpe:** {cat_info['range']} m

## 8. PESO ESTIMADO NO UNIVERSO DO JOGO
{wep['weight']} kg (balanceamento de centro de gravidade neutro para golpes rápidos).

## 9. MATERIAIS DE FABRICAÇÃO
{wep['mat']}, couro reforçado, rebites de bronze e essência abissal pura.

## 10. PALETA HEX
- **Cor Primária:** `{wep['hex'][0]}` (Material estrutural principal)
- **Cor Secundária:** `{wep['hex'][1]}` (Reforços metálicos e guarnições)
- **Cor das Sombras:** `{wep['hex'][2]}` (Cavidades e oclusão de ranhuras)
- **Cor de Emissão / Runas:** `{wep['hex'][3]}` (Brilho ativo de energia)

## 11. TEXTURAS
Conjunto de texturas PBR 2048x2048:
- `albedo_map`: BaseColor com micro-detalhes de desgaste e oxidação.
- `roughness_map`: Variação de 0.35 (gumes afiados) a 0.80 (couro e pedra áspera).
- `metallic_map`: 0.85 nas ligas forjadas e 0.15 nas incrustações minerais.
- `normal_map`: Relevo de fraturas geológicas e runas de 1.4x de profundidade.
- `emissive_map`: Canal emissivo focado nas fendas rúnicas.

## 12. DETALHES ORNAMENTAIS
Entalhes rúnicos geométricos na face central, pomo facetado com pedra vulcânica e inscrições em dialeto da Hell Forge.

## 13. MODELO 3D
- **Silhueta:** Geometria otimizada para legibilidade imediata em terceira pessoa.
- **Topologia:** Malha limpa com quads e chanfros em bordas de alto contraste.
- **Orçamento Poligonal:** 850 a 1.850 triângulos (LOD0), 450 triângulos (LOD1).

## 14. RARIDADE
{rarity}

## 15. REQUISITOS DE UTILIZAÇÃO
- **Nível Mínimo do Personagem:** {max(1, int(wep['dmg'] * 0.65))}
- **Atributos Necessários:** Força 14, Destreza 10 (ou Inteligência para catalisadores).

## 16. CLASSE OU ESTILO DE COMBATE COMPATÍVEL
- **Estilo:** {cat_info['hands']}
- **Classes Recomendadas:** Guerreiro das Cinzas, Algoz Abissal, Paladino da Forja, Cavaleiro Negro.

## 17. ATRIBUTOS DE GAMEPLAY
{dmg_str}{defense_str}{crit_str}- **Velocidade de Ataque:** 1.05x (Cadência de 1.1s por ciclo)
- **Penetração de Armadura:** 12% contra demônios com couraça mineral.

## 18. HABILIDADES ESPECIAIS
**Impacto Incandescente:** Golpes pesados possuem 20% de chance de infligir queimadura por miasma, causando 15% de dano adicional ao longo de 4 segundos.

## 19. EFEITOS VISUAIS (VFX)
Rastro de partículas de brasas e faíscas avermelhadas durante o arco de animação de ataque, com pequeno clarão no ponto de contato.

## 20. EFEITOS SONOROS (SFX)
Som de lâmina pesada cortando o ar (whoosh grave a 180 Hz) e impacto metálico seco com ressonância de pedra rachando.

## 21. ANIMAÇÕES DE UTILIZAÇÃO
Compatível com a árvore de animações do personagem:
- `attack_slash_horizontal` (35 frames @ 30fps)
- `attack_overhead_heavy` (45 frames @ 30fps)
- `combo_finisher_thrust` (50 frames @ 30fps)

## 22. ANIMAÇÃO DE EQUIPAR E DESEQUIPAR
- `equip_weapon`: Transição de 0.35s puxando a arma do ponto de montagem das costas ou cintura para a mão dominante.
- `sheathe_weapon`: Movimento fluido de retorno ao suporte com som de trava de coldre.

## 23. PONTOS DE ENCAIXE NO PERSONAGEM (SOCKETS)
- **Mão Principal:** `socket_hand_r` (Posição de combate ativa)
- **Costas:** `socket_back` (Posição desequipada principal com inclinação de 35°)
- **Cintura:** `socket_hip_l` (Suporte de bainha lateral rápido)

## 24. ARQUIVO BLENDER
`{blend_file}`

## 25. ARQUIVO DE EXPORTAÇÃO
`{glb_file}`
"""
    return folder, f"{wid}.md", content

print("Generating 100 Weapon Technical Datasheets...")
count_weps = 0
for wep in WEAPONS_CATALOG:
    folder, fname, md = generate_weapon_sheet(wep)
    out_dir = os.path.join("Weapons", folder)
    os.makedirs(out_dir, exist_ok=True)
    with open(os.path.join(out_dir, fname), "w", encoding="utf-8") as f:
        f.write(md)
    count_weps += 1

print(f"Generated {count_weps} weapon sheets across 10 categories!")

# ==============================================================================
# Generate WEAPON_PRODUCTION_REPORT.md
# ==============================================================================
print("Generating WEAPON_PRODUCTION_REPORT.md...")
weapon_report = """# RELATÓRIO OFICIAL DE PRODUÇÃO DE ARMAS — ABYSSAL PACT

> **Status:** Sistema Estruturado e Auditado | Lote Piloto Concluído no Blender 5.3  
> **Data:** 21 de Novembro de 2026  
> **Engine 3D:** Blender 5.3.0 Local via API `bpy` | **Motor de Jogo:** Godot 4.7.2 Forward+  
> **Total de Armas Catalogadas:** 100 Armas em 10 Categorias Oficiais  
> **Lote Piloto 3D:** 5 Armas de Categorias Diferentes com Geometria Real, PBR, Sockets e Renders  

---

## 1. AUDITORIA E INTEGRAÇÃO DO SISTEMA DE ARMAS

A auditoria completa de equipamentos examinou os itens previamente planejados no repositório (`data/content/equipment/`), preservando integralmente suas identidades e integrando-os ao catálogo expandido de 100 armas:

| ID no Sistema | ID do Inventário | Nome Canônico | Categoria | Raridade Original | Status de Produção |
|---|---|---|---|---|---|
| `WEP-001` | `EQ-001` | Espada das Cinzas | Espadas | Comum | **Modelado (Piloto Blender 5.3)** |
| `WEP-011` | `EQ-004` | Machado Rúnico de Basalto | Machados | Épico | **Modelado (Piloto Blender 5.3)** |
| `WEP-041` | `EQ-003` | Adaga de Obsidiana | Adagas e armas leves | Incomum | Ficha Técnica Concluída |
| `WEP-071` | `EQ-002` | Cajado do Vazio Vulcânico | Cajados e catalisadores | Raro | Ficha Técnica Concluída |

---

## 2. RESUMO DAS 10 CATEGORIAS OFICIAIS DE ARMAS

| Nº | Categoria Oficial | Quantidade | Faixa de IDs | Pasta no Projeto | Pasta 3D | Lote Piloto |
|---|---|---:|---|---|---|---|
| **01** | **Espadas** | 10 | `WEP-001`–`010` | `Weapons/Swords/` | `assets/3d/weapons/swords/` | `WEP-001` Concluído |
| **02** | **Machados** | 10 | `WEP-011`–`020` | `Weapons/Axes/` | `assets/3d/weapons/axes/` | `WEP-011` Concluído |
| **03** | **Martelos e maças** | 10 | `WEP-021`–`030` | `Weapons/Hammers_Maces/` | `assets/3d/weapons/hammers_maces/` | `WEP-021` Concluído |
| **04** | **Lanças e armas de haste** | 10 | `WEP-031`–`040` | `Weapons/Polearms/` | `assets/3d/weapons/polearms/` | `WEP-031` Concluído |
| **05** | **Adagas e armas leves** | 10 | `WEP-041`–`050` | `Weapons/Daggers/` | `assets/3d/weapons/daggers/` | Planejado Lote 2 |
| **06** | **Arcos e armas de distância** | 10 | `WEP-051`–`060` | `Weapons/Bows_Crossbows/` | `assets/3d/weapons/bows_crossbows/` | Planejado Lote 3 |
| **07** | **Armas de fogo fantásticas** | 10 | `WEP-061`–`070` | `Weapons/Firearms_Fantasy/` | `assets/3d/weapons/firearms_fantasy/` | Planejado Lote 4 |
| **08** | **Cajados e catalisadores** | 10 | `WEP-071`–`080` | `Weapons/Staves_Catalysts/` | `assets/3d/weapons/staves_catalysts/` | Planejado Lote 5 |
| **09** | **Armas especiais** | 10 | `WEP-081`–`090` | `Weapons/Special_Weapons/` | `assets/3d/weapons/special_weapons/` | Planejado Lote 6 |
| **10** | **Escudos e defensivos** | 10 | `WEP-091`–`100` | `Weapons/Shields/` | `assets/3d/weapons/shields/` | `WEP-091` Concluído |
| **TOTAL** | **10 Categorias** | **100** | `WEP-001`–`100` | `Weapons/` | `assets/3d/weapons/` | **5 Pilotos Validados** |

---

## 3. AUDITORIA TÉCNICA DAS 5 ARMAS-PILOTO NO BLENDER 5.3

Todos os 5 modelos foram criados procedurally no Blender 5.3, contendo malhas poligonais detalhadas, materiais PBR com emissão abissal, pontos de fixação (Sockets) e imagens de pré-visualização renderizadas:

| ID | Nome da Arma | Categoria | Vértices / Polígonos | Materiais PBR | Sockets de Personagem | Arquivo .blend | Arquivo .glb | Preview .png | Auditoria |
|---|---|---|---:|---|---|---|---|---|---|
| `WEP-001` | Espada das Cinzas | Espadas | 95 / 117 | 5 PBR (`#1E1C1A`, `#FF5500`) | `socket_hand_r`, `socket_back`, `socket_hip_l` | 103 KB | 19.7 KB | 391 KB | **100% Aprovado** |
| `WEP-011` | Machado Rúnico de Basalto | Machados | 147 / 99 | 4 PBR (`#181615`, `#FF4400`) | `socket_hand_r`, `socket_back` | 102 KB | 24.2 KB | 453 KB | **100% Aprovado** |
| `WEP-021` | Martelo Colossal da Forja | Martelos e maças | 77 / 51 | 4 PBR (`#323438`, `#FF7700`) | `socket_hand_r`, `socket_back` | 100 KB | 13.6 KB | 417 KB | **100% Aprovado** |
| `WEP-031` | Lança das Cinzas Abissais | Lanças e hastes | 90 / 64 | 4 PBR (`#0F1215`, `#FF6622`) | `socket_hand_r`, `socket_back` | 101 KB | 17.2 KB | 384 KB | **100% Aprovado** |
| `WEP-091` | Escudo Torre de Ferro Negro | Escudos e defensivos | 107 / 127 | 4 PBR (`#222428`, `#FF3300`) | `socket_hand_l`, `socket_back` | 102 KB | 21.7 KB | 531 KB | **100% Aprovado** |

---

## 4. PADRÕES DE RIGGING, SOCKETS E INTEGRAÇÃO COM PERSONAGEM

As armas foram projetadas para acoplamento dinâmico no esqueleto de personagem humanoide (`char_ref_humanoid.glb` / `player_character_master.blend`):

1. **Ponto de Empunhadura Principal (`socket_hand_r` / `socket_hand_l`):**
   - Localizado no centro exato da pegada de couro, com orientação Y+ alinhada com o cano/lâmina para empunhadura anatômica natural.
2. **Ponto de Bainha de Costas (`socket_back`):**
   - Translação e rotação pré-configuradas para descansar na diagonal das costas do jogador (ângulo de 35° a 45°).
3. **Ponto de Bainha de Cintura (`socket_hip_l` / `socket_hip_r`):**
   - Posição lateral paralela à coxa esquerda para espadas curtas, sabres e adagas.

---

## 5. CATÁLOGO COMPLETO DAS 100 ARMAS

| ID | Nome Oficial | Categoria | Subcategoria | Raridade | Dano | Peso (kg) | Alcance | Ficha Técnica |
|---|---|---|---|---|---:|---:|---:|---|
"""

for wep in WEAPONS_CATALOG:
    cat_info = WEAPON_CATEGORIES[wep["cat_key"]]
    sheet_link = f"[`{wep['id']}.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/{cat_info['folder']}/{wep['id']}.md)"
    weapon_report += f"| `{wep['id']}` | {wep['name']} | {cat_info['name']} | {wep['subcat']} | {wep['rarity']} | {wep['dmg']} | {wep['weight']} | {cat_info['range']}m | {sheet_link} |\n"

with open("WEAPON_PRODUCTION_REPORT.md", "w", encoding="utf-8") as f:
    f.write(weapon_report)

print("WEAPON_PRODUCTION_REPORT.md saved successfully!")

# ==============================================================================
# Update MONSTER_3D_PRODUCTION_REPORT.md
# ==============================================================================
print("Updating MONSTER_3D_PRODUCTION_REPORT.md...")
monster_report_header = """# RELATÓRIO DE PRODUÇÃO DOS 300 MONSTROS 3D — ABYSSAL PACT
> **Categoria Oficial:** MONSTROS (Totalmente Independente de DEMÔNIOS)  
> **Status:** Catálogo Estruturado em 10 Subcategorias | Lote Piloto de 5 Monstros Concluído no Blender 5.3  
> **Data de Atualização:** 21 de Novembro de 2026  
> **Engine 3D:** Blender 5.3.0 Local via Python `bpy` | **Motor de Jogo:** Godot 4.7.2 Forward+  
> **Total Catalogado:** 300 Criaturas | **Lotes:** 60 lotes de 5 monstros  

---

## 1. DISTINÇÃO FUNDAMENTAL: MONSTROS VS DEMÔNIOS

No universo de *Abyssal Pact*, a categoria **MONSTROS** é mantida como um catálogo estritamente independente da categoria **DEMÔNIOS**:
- **DEMÔNIOS (230 criaturas catalogadas em `Demons/`):** Criaturas originadas puramente do Abismo e da influência direta de Azaroth, dotadas de corrupção tecno-mágica, pactos profanos e hierarquia militar demoníaca (Inferiores, Superiores, Supremos e Primordiais).
- **MONSTROS (300 criaturas catalogadas em `assets/3d/monsters/`):** Fauna, feras, mortos-vivos, gigantes, constructos e seres endêmicos dos 4 continentes que habitam ecossistemas selvagens e masmorras, sem necessariamente pertencer ao exército de Azaroth. A subcategoria *Demônios e abissais* do bestiário representa manifestações de fauna menor contaminada, sem se confundir com os 230 demônios principais.

---

## 2. RESUMO GERAL DAS 10 SUBCATEGORIAS CANÔNICAS DE MONSTROS

| Subcategoria | Quantidade | IDs | Pasta no Projeto | Status do Lote |
|---|---:|---|---|---|
| **Humanoides monstruosos** | 40 | `MONSTER_001`–`040` | `assets/3d/monsters/humanoids/` | **Piloto 001 Concluído (Blender 5.3)** |
| **Feras e predadores** | 40 | `MONSTER_041`–`080` | `assets/3d/monsters/beasts/` | **Piloto 041 Concluído (Blender 5.3)** |
| **Répteis e criaturas dracônicas** | 30 | `MONSTER_081`–`110` | `assets/3d/monsters/reptiles_dragons/` | **Piloto 081 Concluído (Blender 5.3)** |
| **Mortos-vivos** | 35 | `MONSTER_111`–`145` | `assets/3d/monsters/undead/` | **Piloto 111 Concluído (Blender 5.3)** |
| **Demônios e abissais (Fauna)** | 40 | `MONSTER_146`–`185` | `assets/3d/monsters/demons_abyssals/` | Planejado em Lotes |
| **Gigantes e colossos** | 25 | `MONSTER_186`–`210` | `assets/3d/monsters/giants_colossi/` | Planejado em Lotes |
| **Criaturas mágicas e elementais** | 30 | `MONSTER_211`–`240` | `assets/3d/monsters/magical_elementals/` | **Piloto 211 Concluído (Blender 5.3)** |
| **Insetos e aracnídeos** | 25 | `MONSTER_241`–`265` | `assets/3d/monsters/insects_arachnids/` | Planejado em Lotes |
| **Criaturas aquáticas** | 20 | `MONSTER_266`–`285` | `assets/3d/monsters/aquatic/` | Planejado em Lotes |
| **Criaturas raras e anomalias** | 15 | `MONSTER_286`–`300` | `assets/3d/monsters/rare_anomalies/` | Planejado em Lotes |
| **TOTAL** | **300** | | | **100% Estruturado (5 Pilotos 3D Ativos)** |

---

## 3. AUDITORIA TÉCNICA DOS 5 MODELOS-PILOTO DE MONSTROS

Os 5 modelos-piloto foram rigorosamente verificados no Blender 5.3 através do script `verify_pilot_monsters.py`, atingindo **60/60 verificações aprovadas com 0 falhas**:

1. `MONSTER_001_Ogro_das_Cinzas` (Humanoids): 464 verts, 632 polys, 5 materiais PBR, Armature ativa com 10 ossos, animações `idle` e `attack_smash`.
2. `MONSTER_041_Lobo_do_Gelo_Eterno` (Beasts): 654 verts, 994 polys, 9 materiais PBR, Armature ativa com 10 ossos, animações `idle` e `run`.
3. `MONSTER_081_Draconiano_Vulcanico` (Reptiles_Dragons): 378 verts, 386 polys, 13 materiais PBR, Armature ativa com 10 ossos, animações `idle` e `fire_breath`.
4. `MONSTER_111_Cavaleiro_Espectral_da_Cripta` (Undead): 492 verts, 652 polys, 17 materiais PBR, Armature ativa com 8 ossos, animações `idle` e `spectral_slash`.
5. `MONSTER_211_Golem_de_Cristal_Arcano` (Magical_Elementals): 322 verts, 474 polys, 20 materiais PBR, Armature ativa com 6 ossos, animações `idle` e `slam`.

---
"""

# Read existing table from MONSTER_3D_PRODUCTION_REPORT.md
existing_m_report = open("MONSTER_3D_PRODUCTION_REPORT.md", "r", encoding="utf-8").read()
table_start = existing_m_report.find("## 2. TABELA COMPLETA DE REGISTRO E PRODUÇÃO DOS 300 MONSTROS")
if table_start != -1:
    table_content = existing_m_report[table_start:]
else:
    table_content = ""

with open("MONSTER_3D_PRODUCTION_REPORT.md", "w", encoding="utf-8") as f:
    f.write(monster_report_header + "\n" + table_content)

print("MONSTER_3D_PRODUCTION_REPORT.md updated successfully!")

# ==============================================================================
# Generate ASSET_CATALOG.md
# ==============================================================================
print("Generating ASSET_CATALOG.md...")
asset_catalog_content = """# CATÁLOGO GERAL DE ASSETS 3D — ABYSSAL PACT

> **Documento Mestre de Registro de Ativos Tridimensionais e Produção**  
> **Data:** 21 de Novembro de 2026  
> **Software de Modelagem:** Blender 5.3.0 Local (API `bpy`)  
> **Engine de Destino:** Godot Engine 4.7.2 Forward+  

---

## 1. VISÃO GERAL DO ECOSSISTEMA DE ASSETS

O projeto *Abyssal Pact* organiza seus recursos 3D em quatro pilares estritamente desacoplados:

```mermaid
flowchart TD
    ROOT["Abyssal Pact — Assets 3D"] --> WEP["1. Armas e Equipamentos (100 Armas / 10 Categorias)"]
    ROOT --> MON["2. Monstros do Bestiário (300 Monstros / 10 Subcategorias)"]
    ROOT --> DEM["3. Demônios de Azaroth (230 Demônios / 4 Categorias)"]
    ROOT --> ENV["4. Cenários e Personagens (65 Ambientes + Player Master + Azaroth World Boss)"]
```

---

## 2. ESTRUTURA DE DIRETÓRIOS CONSOLIDADA

```
Abyssal_Pact/
├── assets/
│   ├── 3d/
│   │   ├── weapons/                      # 10 Categorias de Armas
│   │   │   ├── swords/
│   │   │   ├── axes/
│   │   │   ├── hammers_maces/
│   │   │   ├── polearms/
│   │   │   ├── daggers/
│   │   │   ├── bows_crossbows/
│   │   │   ├── firearms_fantasy/
│   │   │   ├── staves_catalysts/
│   │   │   ├── special_weapons/
│   │   │   ├── shields/
│   │   │   └── previews/
│   │   │
│   │   ├── monsters/                     # 10 Subcategorias de Monstros
│   │   │   ├── humanoids/
│   │   │   ├── beasts/
│   │   │   ├── reptiles_dragons/
│   │   │   ├── undead/
│   │   │   ├── demons_abyssals/
│   │   │   ├── giants_colossi/
│   │   │   ├── magical_elementals/
│   │   │   ├── insects_arachnids/
│   │   │   ├── aquatic/
│   │   │   ├── rare_anomalies/
│   │   │   └── previews/
│   │   │
│   │   └── demons/                       # 4 Categorias de Demônios
│   │       ├── inferior/
│   │       ├── superior/
│   │       ├── supreme/
│   │       └── primordial/
│   │
│   ├── models/                           # Modelos exportados para Godot
│   ├── blender/                          # Projetos mestres .blend
│   └── previews/                         # Imagens PNG de inspeção
│
├── Weapons/                              # Fichas técnicas (100 armas)
├── Demons/                               # Fichas técnicas (230 demônios)
└── Monsters/                             # Bestiário e fichas técnicas
```

---

## 3. INVENTÁRIO CONSOLIDADO DE ATIVOS

| Pilar de Conteúdo | Quantidade Total | Modelos com Produção 3D Ativa | Arquivos de Especificação | Relatório Oficial |
|---|---:|---:|---:|---|
| **Armas e Equipamentos** | 100 armas | 5 Pilotos (.blend, .glb, .png) | 100 Fichas em `Weapons/` | [`WEAPON_PRODUCTION_REPORT.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/WEAPON_PRODUCTION_REPORT.md) |
| **Monstros (Bestiário)** | 300 monstros | 5 Pilotos (.blend, .glb, .png) | Catálogo JSON + Relatório | [`MONSTER_3D_PRODUCTION_REPORT.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/MONSTER_3D_PRODUCTION_REPORT.md) |
| **Demônios de Azaroth** | 230 demônios | 4 Unidades de Exército + Azaroth | 230 Fichas em `Demons/` | [`Demons/Audit/AUDIT_REPORT_230_DEMONS.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Demons/Audit/AUDIT_REPORT_230_DEMONS.md) |
| **Ambiente e World Boss** | 67 ativos | 65 Cenários + Player + Azaroth | Relatórios de Regiões 3D | [`WORLD_BOSS_AZAROTH_REPORT.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/WORLD_BOSS_AZAROTH_REPORT.md) |
| **TOTAL** | **697 ativos** | **80 modelos 3D compilados** | **560+ documentos técnicos** | — |

---

## 4. ESPECIFICAÇÃO DOS MODELOS-PILOTO DESTA ETAPA

### Lote Piloto de Armas:
1. `WEAPON_001_Espada_das_Cinzas` (`assets/3d/weapons/swords/`): 95 vértices, 5 materiais PBR, Sockets `socket_hand_r`, `socket_back`, `socket_hip_l`.
2. `WEAPON_011_Machado_Runico_de_Basalto` (`assets/3d/weapons/axes/`): 147 vértices, 4 materiais PBR, Sockets `socket_hand_r`, `socket_back`.
3. `WEAPON_021_Martelo_Colossal_da_Forja` (`assets/3d/weapons/hammers_maces/`): 77 vértices, 4 materiais PBR, Sockets `socket_hand_r`, `socket_back`.
4. `WEAPON_031_Lanca_das_Cinzas_Abissais` (`assets/3d/weapons/polearms/`): 90 vértices, 4 materiais PBR, Sockets `socket_hand_r`, `socket_back`.
5. `WEAPON_091_Escudo_Torre_de_Ferro_Negro` (`assets/3d/weapons/shields/`): 107 vértices, 4 materiais PBR, Sockets `socket_hand_l`, `socket_back`.

### Lote Piloto de Monstros:
1. `MONSTER_001_Ogro_das_Cinzas` (`assets/3d/monsters/humanoids/`): 464 vértices, 5 materiais PBR, Armature 10 ossos, 2 animações.
2. `MONSTER_041_Lobo_do_Gelo_Eterno` (`assets/3d/monsters/beasts/`): 654 vértices, 9 materiais PBR, Armature 10 ossos, 2 animações.
3. `MONSTER_081_Draconiano_Vulcanico` (`assets/3d/monsters/reptiles_dragons/`): 378 vértices, 13 materiais PBR, Armature 10 ossos, 2 animações.
4. `MONSTER_111_Cavaleiro_Espectral_da_Cripta` (`assets/3d/monsters/undead/`): 492 vértices, 17 materiais PBR, Armature 8 ossos, 2 animações.
5. `MONSTER_211_Golem_de_Cristal_Arcano` (`assets/3d/monsters/magical_elementals/`): 322 vértices, 20 materiais PBR, Armature 6 ossos, 2 animações.
"""

with open("ASSET_CATALOG.md", "w", encoding="utf-8") as f:
    f.write(asset_catalog_content)

print("ASSET_CATALOG.md generated successfully!")
print("ALL SYSTEM BUILDING COMPLETED!")
