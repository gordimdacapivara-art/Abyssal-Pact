#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Full Generator for the 230 Demon Technical Specifications of Abyssal Pact.
Generates:
- 100 Inferior Demons in Demons/Inferior/DEMON_001.md .. DEMON_100.md
- 90 Superior Demons in Demons/Superior/DEMON_101.md .. DEMON_190.md
- 30 Supreme Demons in Demons/Supreme/BOSS_001.md .. BOSS_030.md
- 10 Primordial Demons in Demons/Primordial/DEMON_191.md .. DEMON_200.md
- Master Index in Demons/DEMON_TECHNICAL_MASTER_INDEX.md
- Technical Reference Guide in Demons/Technical_Reference/DEMON_TECHNICAL_REFERENCE_GUIDE.md
"""

import os
import re
import glob

# Continents and Regions metadata
REGIONS_INFO = {
    # Veyrath (CONT-01) - Vulcânico
    "REG-001": {"name": "Planície Cinzenta de Veyrath", "continent": "Veyrath", "cont_id": "CONT-01", "biome": "Planícies de Cinzas Vulcânicas", "levels": "1–5", "settlement": "Baluarte das Cinzas", "dungeon": "Catacumbas de Basalto"},
    "REG-002": {"name": "Fendas de Enxofre", "continent": "Veyrath", "cont_id": "CONT-01", "biome": "Crateras e Escarpas Sulfurosas", "levels": "3–7", "settlement": "Posto de Enxofre", "dungeon": "Minas de Pirita"},
    "REG-003": {"name": "Desfiladeiro de Magma", "continent": "Veyrath", "cont_id": "CONT-01", "biome": "Cânion de Rios de Lava Candente", "levels": "5–10", "settlement": "Acampamento da Forja", "dungeon": "Cavernas Candentes"},
    "REG-004": {"name": "Pântano de Cinzas", "continent": "Veyrath", "cont_id": "CONT-01", "biome": "Charneca Cáustica de Cinzas Úmidas", "levels": "8–12", "settlement": "Aldeia Queimada", "dungeon": "Fosso Lamacento"},
    "REG-005": {"name": "Picos de Obsidiana", "continent": "Veyrath", "cont_id": "CONT-01", "biome": "Agulhas de Vidro Vulcânico e Penhascos", "levels": "10–15", "settlement": "Posto das Agulhas", "dungeon": "Câmara das Lâminas"},
    "REG-006": {"name": "Deserto Fuliginoso", "continent": "Veyrath", "cont_id": "CONT-01", "biome": "Dunas Negras de Fuligem e Areia Escura", "levels": "13–17", "settlement": "Refúgio de Sílica", "dungeon": "Túmulo dos Ventos"},
    "REG-007": {"name": "Cratera Abissal de Ferro", "continent": "Veyrath", "cont_id": "CONT-01", "biome": "Cratera Industrial de Minério Fundido", "levels": "15–20", "settlement": "Guarnição de Chumbo", "dungeon": "Complexo de Ferro Profundo"},
    "REG-008": {"name": "Terra Férrea", "continent": "Veyrath", "cont_id": "CONT-01", "biome": "Páramo de Escória Metálica e Chamas", "levels": "18–22", "settlement": "Fortim de Ferro", "dungeon": "Mina dos Condenados"},
    "REG-009": {"name": "Garganta Calcinada", "continent": "Veyrath", "cont_id": "CONT-01", "biome": "Fissura Tectônica de Vapores Tóxicos", "levels": "20–25", "settlement": "Posto do Abismo", "dungeon": "Cripta dos Condenados"},
    "REG-010": {"name": "Voo de Cinzas", "continent": "Veyrath", "cont_id": "CONT-01", "biome": "Borda da Caldeira e Picos Vulcânicos", "levels": "23–28", "settlement": "Santuário da Cinza", "dungeon": "Santuário do Fogo Profundo"},
    # Sylvaran (CONT-02) - Floresta Ancestral / Pântanos
    "REG-011": {"name": "Bosque Sussurrante", "continent": "Sylvaran", "cont_id": "CONT-02", "biome": "Floresta Ancestral de Névoas Densas", "levels": "1–6", "settlement": "Bosque das Almas", "dungeon": "Raízes Esquecidas"},
    "REG-012": {"name": "Pântano Espectral", "continent": "Sylvaran", "cont_id": "CONT-02", "biome": "Brejo Enevoado com Fogo Fátuo", "levels": "4–8", "settlement": "Refúgio da Bruma", "dungeon": "Galeria dos Afogados"},
    "REG-013": {"name": "Clareira das Runas", "continent": "Sylvaran", "cont_id": "CONT-02", "biome": "Arbustos Ancestrais e Monólitos Rúnicos", "levels": "6–10", "settlement": "Posto Rúnico", "dungeon": "Cripta dos Símbolos"},
    "REG-014": {"name": "Raízes Antigas", "continent": "Sylvaran", "cont_id": "CONT-02", "biome": "Labirinto Subterrâneo de Raízes Gigantes", "levels": "9–13", "settlement": "Vila do Tronco Oco", "dungeon": "Labirinto das Raízes"},
    "REG-015": {"name": "Vale dos Salgueiros Negros", "continent": "Sylvaran", "cont_id": "CONT-02", "biome": "Vale Sombrio de Árvores Choronas Corrompidas", "levels": "12–16", "settlement": "Acampamento Fúnebre", "dungeon": "Túmulo das Lágrimas"},
    "REG-016": {"name": "Cume das Névoas", "continent": "Sylvaran", "cont_id": "CONT-02", "biome": "Penhascos Florestais de Neblina Perpétua", "levels": "14–18", "settlement": "Mirante das Brumas", "dungeon": "Salão Enevoado"},
    "REG-017": {"name": "Pântano de Sangue", "continent": "Sylvaran", "cont_id": "CONT-02", "biome": "Lodaçal Carmesim Alimentado por Sacrifícios", "levels": "17–21", "settlement": "Fortaleza Rubra", "dungeon": "Fosso dos Sacrifícios"},
    "REG-018": {"name": "Selva das Sombras", "continent": "Sylvaran", "cont_id": "CONT-02", "biome": "Dossel Fechado com Vinhas Carnívoras", "levels": "19–23", "settlement": "Posto do Dossel", "dungeon": "Antro das Vinhas Negras"},
    "REG-019": {"name": "Fenda Esmeralda", "continent": "Sylvaran", "cont_id": "CONT-02", "biome": "Garganta com Cristais e Fungos Bioluminescentes", "levels": "22–26", "settlement": "Vila Esmeralda", "dungeon": "Cavernas dos Cristais Verdes"},
    "REG-020": {"name": "Coração da Floresta Abissal", "continent": "Sylvaran", "cont_id": "CONT-02", "biome": "Núcleo Corrompido com Raízes Carnudas e Seiva Abissal", "levels": "25–30", "settlement": "Santuário da Seiva", "dungeon": "Santuário Corrompido"},
    # Khar-Duum (CONT-03) - Cânions e Deserto de Areias Negras
    "REG-021": {"name": "Dunas de Areia Negra", "continent": "Khar-Duum", "cont_id": "CONT-03", "biome": "Deserto Tórrido de Quartzo e Areia Basáltica", "levels": "1–6", "settlement": "Fortaleza de Basalto", "dungeon": "Templo Soterrado"},
    "REG-022": {"name": "Cânion dos Ventos Áridos", "continent": "Khar-Duum", "cont_id": "CONT-03", "biome": "Desfiladeiro Erosivo de Ventos Cortantes", "levels": "4–8", "settlement": "Posto das Gargantas", "dungeon": "Fenda dos Uivos"},
    "REG-023": {"name": "Oásis da Serpente", "continent": "Khar-Duum", "cont_id": "CONT-03", "biome": "Poço de Água Venenosa Cercado por Palmeiras Negras", "levels": "7–11", "settlement": "Vila da Miragem", "dungeon": "Poço dos Antigos"},
    "REG-024": {"name": "Platô Escaldante", "continent": "Khar-Duum", "cont_id": "CONT-03", "biome": "Planalto Rochoso com Depósitos de Enxofre Solar", "levels": "10–14", "settlement": "Refúgio da Rocha", "dungeon": "Mina de Enxofre Solar"},
    "REG-025": {"name": "Vale dos Monólitos", "continent": "Khar-Duum", "cont_id": "CONT-03", "biome": "Planície Desértica com Pilares de Rocha Abissal", "levels": "13–17", "settlement": "Acampamento das Estelas", "dungeon": "Cripta dos Gigantes"},
    "REG-026": {"name": "Fenda de Sal", "continent": "Khar-Duum", "cont_id": "CONT-03", "biome": "Salinas Brancas Cristalinas e Rachaduras Cáusticas", "levels": "15–19", "settlement": "Posto do Sal Branco", "dungeon": "Catacumbas Cristalinas"},
    "REG-027": {"name": "Cidadela Vermelha", "continent": "Khar-Duum", "cont_id": "CONT-03", "biome": "Ruínas de Arenito Ocre e Fortalezas Corrompidas", "levels": "18–22", "settlement": "Baluarte Vermelho", "dungeon": "Masmorras da Forja"},
    "REG-028": {"name": "Labirinto de Cânions", "continent": "Khar-Duum", "cont_id": "CONT-03", "biome": "Gargantas Profundas e Passagens Estreitas", "levels": "20–24", "settlement": "Posto da Poeira", "dungeon": "Gruta das Sombras Quentes"},
    "REG-029": {"name": "Deserto Silencioso", "continent": "Khar-Duum", "cont_id": "CONT-03", "biome": "Vasto Ermo de Areias Vivas e Ausência de Som", "levels": "23–27", "settlement": "Acampamento Ermo", "dungeon": "Tumba do Vento Perdido"},
    "REG-030": {"name": "Garganta do Fogo Profundo", "continent": "Khar-Duum", "cont_id": "CONT-03", "biome": "Abismo Termal Subterrâneo com Fissuras de Chamas", "levels": "26–32", "settlement": "Fortaleza Subterrânea", "dungeon": "Altar das Profundezas"},
    # Nhal'Kora (CONT-04) - Litoral Abissal e Névoas Glaciais
    "REG-031": {"name": "Baía dos Afogados", "continent": "Nhal'Kora", "cont_id": "CONT-04", "biome": "Costa Rochosa Enevoada com Naufrágios Antigos", "levels": "1–6", "settlement": "Cidadela dos Afogados", "dungeon": "Naufrágio do Leviatã"},
    "REG-032": {"name": "Penhascos Espectrais", "continent": "Nhal'Kora", "cont_id": "CONT-04", "biome": "Falésias Vertiginosas Açoitadas por Marés Frias", "levels": "4–8", "settlement": "Posto do Farol", "dungeon": "Catacumbas da Falésia"},
    "REG-033": {"name": "Recife Abissal", "continent": "Nhal'Kora", "cont_id": "CONT-04", "biome": "Recife de Coral Negro e Poças de Maré Corrompida", "levels": "7–11", "settlement": "Aldeia das Marés", "dungeon": "Fenda de Coral Negro"},
    "REG-034": {"name": "Costa das Névoas Frias", "continent": "Nhal'Kora", "cont_id": "CONT-04", "biome": "Praia de Cascalho Escuro e Nevoeiro Gélido", "levels": "10–14", "settlement": "Vila do Quebra-Mar", "dungeon": "Grota dos Ventos Glaciais"},
    "REG-035": {"name": "Fjord dos Condenados", "continent": "Nhal'Kora", "cont_id": "CONT-04", "biome": "Fiorde Estreito de Águas Negras e Paredões Glaciais", "levels": "13–17", "settlement": "Refúgio dos Remadores", "dungeon": "Caverna das Almas Perdidas"},
    "REG-036": {"name": "Geleira Sussurrante", "continent": "Nhal'Kora", "cont_id": "CONT-04", "biome": "Geleira Antiga Rachada por Fendas Abissais Azuis", "levels": "16–20", "settlement": "Posto Glacial", "dungeon": "Mina de Gelo Negro"},
    "REG-037": {"name": "Estuário dos Sussurros", "continent": "Nhal'Kora", "cont_id": "CONT-04", "biome": "Delta de Maré com Manguezais Glaciais e Lodo", "levels": "19–23", "settlement": "Posto do Canal", "dungeon": "Túmulo do Naufrágio"},
    "REG-038": {"name": "Maré Eterna", "continent": "Nhal'Kora", "cont_id": "CONT-04", "biome": "Plataforma Marinha de Correntes Perpétuas", "levels": "22–26", "settlement": "Acampamento das Marés", "dungeon": "Fenda Profunda das Conchas"},
    "REG-039": {"name": "Fossa Oceânica", "continent": "Nhal'Kora", "cont_id": "CONT-04", "biome": "Fossa Abissal Submarina de Pressão Extrema e Trevas", "levels": "25–29", "settlement": "Cidadela Submersa", "dungeon": "Altar das Correntes"},
    "REG-040": {"name": "Fim do Abismo", "continent": "Nhal'Kora", "cont_id": "CONT-04", "biome": "Vórtice Primordial no Limite do Mundo Conhecido", "levels": "28–35", "settlement": "Santuário Abissal", "dungeon": "Vórtice Final"}
}

def parse_tres(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        txt = f.read()

    def s_group(pattern, default=""):
        m = re.search(pattern, txt)
        return m.group(1) if m else default

    def s_num(pattern, default=0.0):
        m = re.search(pattern, txt)
        return float(m.group(1)) if m else default

    did = s_group(r'id = &"([^"]+)"')
    dname = s_group(r'display_name = "([^"]+)"')
    fam = s_group(r'family = &"([^"]+)"', 'brute')
    cat = s_group(r'category = &"([^"]+)"', 'regional')
    rarity = s_group(r'rarity = &"([^"]+)"', 'common')
    cont = s_group(r'continent_id = &"([^"]+)"', 'CONT-01')
    reg = s_group(r'region_id = &"([^"]+)"', 'REG-001')

    hp = s_num(r'"max_health":\s*([0-9.]+)', 200.0)
    dmg = s_num(r'"damage":\s*([0-9.]+)', 15.0)
    defe = s_num(r'"defense":\s*([0-9.]+)', 0.75)
    spd = s_num(r'"move_speed":\s*([0-9.]+)', 2.2)
    rng = s_num(r'"attack_range":\s*([0-9.]+)', 2.0)
    cd = s_num(r'"attack_cooldown":\s*([0-9.]+)', 2.0)
    xp = int(s_num(r'"xp_reward":\s*([0-9.]+)', 20.0))
    gold = int(s_num(r'"gold_reward":\s*([0-9.]+)', 10.0))

    phys = s_num(r'"physical":\s*([0-9.]+)', 1.0)
    abyss = s_num(r'"abyssal":\s*([0-9.]+)', 1.0)
    fire = s_num(r'"fire":\s*([0-9.]+)', 1.0)

    abils = re.findall(r'"(ABIL-[^"]+)"', txt)
    if not abils:
        abils = ["ABIL-DEM-" + fam.upper()]

    return {
        "id": did,
        "display_name": dname,
        "family": fam,
        "category": cat,
        "rarity": rarity,
        "continent_id": cont,
        "region_id": reg,
        "hp": hp,
        "damage": dmg,
        "defense": defe,
        "speed": spd,
        "range": rng,
        "cooldown": cd,
        "xp": xp,
        "gold": gold,
        "res_phys": phys,
        "res_abyss": abyss,
        "res_fire": fire,
        "abilities": abils
    }

print("Loading existing .tres files...")
demons_data = {}
for i in range(1, 201):
    p = f"data/content/demons/demon_{i:03d}.tres"
    if os.path.exists(p):
        demons_data[f"DEMON-{i:03d}"] = parse_tres(p)

bosses_data = {}
for i in range(1, 31):
    p = f"data/content/bosses/boss_{i:03d}.tres"
    if os.path.exists(p):
        bosses_data[f"BOSS-{i:03d}"] = parse_tres(p)

print(f"Demons: {len(demons_data)}, Bosses: {len(bosses_data)}")
