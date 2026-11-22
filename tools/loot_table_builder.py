#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Abyssal Pact — Construtor de Tabelas e Fichas de Loot
Gera tabelas balanceadas com base na ontologia, regras matemáticas e fichas em Markdown padronizadas.
"""

import os
import re
from loot_item_database import FAMILY_MATERIALS, DEMON_TIER_MATERIALS, PRIMORDIAL_EXCLUSIVES, BOSS_EXCLUSIVE_CORES

# Mapeamento de armas do catálogo oficial
WEAPONS_BY_INDEX = {
    # 3.1 Espadas (WEP-001..010)
    1: ("WEP-001", "Espada das Cinzas", "weapon", "Espada de uma mão forjada em cinzas vulcânicas", {"attack": 18, "fire_damage": 8}),
    2: ("WEP-002", "Lâmina Rúnica de Basalto", "weapon", "Lâmina média com entalhes de proteção", {"attack": 22, "defense": 4}),
    3: ("WEP-003", "Alfanje da Fenda Abissal", "weapon", "Sabre curvo impregnado de miasma", {"attack": 25, "abyssal_damage": 10}),
    4: ("WEP-004", "Espada Larga do Cruzado Caído", "weapon", "Espada de duas mãos com corte pesado", {"attack": 34, "stagger": 15}),
    5: ("WEP-005", "Montante da Forja Sombria", "weapon", "Grande montante de aço temperado em magma", {"attack": 40, "burn_chance": 12}),
    # 3.2 Machados (WEP-011..020)
    11: ("WEP-011", "Machado Rúnico de Basalto", "weapon", "Machado de guerra equilibrado", {"attack": 46, "armor_penetration": 18}),
    12: ("WEP-012", "Machadinha do Carniceiro", "weapon", "Machadinha leve para combate veloz", {"attack": 20, "bleed": 10}),
    15: ("WEP-015", "Machado do Titã de Pedra", "weapon", "Machado lendário de impacto colossal", {"attack": 65, "stagger": 35}),
    # 3.3 Martelos e Maças (WEP-021..030)
    21: ("WEP-021", "Martelo Colossal da Forja", "weapon", "Martelo pesado com cabeça de bigorna", {"attack": 55, "impact_damage": 30}),
    25: ("WEP-025", "Clava dos Gigantes Ancestrais", "weapon", "Clava maciça de rocha mineralizada", {"attack": 50, "stun_chance": 15}),
    # 3.4 Lanças (WEP-031..040)
    31: ("WEP-031", "Lança das Cinzas Abissais", "weapon", "Lança pontiaguda de alcance estendido", {"attack": 28, "reach": 3.5}),
    35: ("WEP-035", "Alabarda do Baluarte", "weapon", "Haste reforçada com lâmina de corte e ponta de estocada", {"attack": 38, "reach": 3.0}),
    # 3.5 Adagas (WEP-041..050)
    41: ("WEP-041", "Adaga de Obsidiana", "weapon", "Adaga curva com corte hemorrágico", {"attack": 22, "crit_chance": 12}),
    45: ("WEP-045", "Estilete Espectral do Vazio", "weapon", "Lâmina fina que perfura armaduras", {"attack": 26, "crit_damage": 35}),
    # 3.6 Arcos (WEP-051..060)
    51: ("WEP-051", "Arco Recurvo de Caça", "weapon", "Arco rápido de madeira tenaz", {"attack": 24, "range": 25}),
    55: ("WEP-055", "Arco das Sombras Silenciosas", "weapon", "Arco longo que dispara flechas sem ruído", {"attack": 42, "shadow_damage": 18}),
    # 3.7 Armas de Fogo (WEP-061..070)
    61: ("WEP-061", "Bacamarte Rúnico de Fogo", "weapon", "Arma de fogo portátil de dispersão", {"attack": 48, "aoe_radius": 4}),
    # 3.8 Cajados (WEP-071..080)
    71: ("WEP-071", "Cajado da Maré Abissal", "weapon", "Báculo mágico canalizador de frio e água", {"attack": 14, "magic_power": 32}),
    75: ("WEP-075", "Cajado do Vazio Vulcânico", "weapon", "Cetro de obsidiana e magma concentrado", {"attack": 18, "fire_power": 38}),
    # 3.9 Armas Especiais (WEP-081..090)
    81: ("WEP-081", "Foice da Colheita Anímica", "weapon", "Foice curva que extrai almas derrotadas", {"attack": 36, "life_steal": 8}),
    85: ("WEP-085", "Chicote do Caos Abissal", "weapon", "Lâmina articulada flexível", {"attack": 30, "reach": 5.0}),
    # 3.10 Escudos (WEP-091..100)
    91: ("WEP-091", "Escudo Torre de Ferro Negro", "shield", "Escudo de corpo inteiro de alta absorção", {"defense": 35, "block_rate": 80}),
    95: ("WEP-095", "Broquel Rúnico de Basalto", "shield", "Escudo leve para aparo e contra-ataque", {"defense": 18, "parry_window": 0.3})
}

def get_difficulty_and_encounter(enemy_type, subcategory, numeric_id, name):
    """Determina a classificação de dificuldade e tipo de encontro."""
    if enemy_type == "demon":
        if subcategory == "primordial":
            return "Chefe Único", "Confronto da Fossa Primordial"
        elif subcategory == "supreme":
            return "Chefe", "Arena de Lorde Demoníaco"
        elif subcategory == "superior":
            return "Elite", "Tropa de Choque Abissal"
        else: # inferior
            return "Comum", "Vanguarda de Invasão / Patrulha da Fenda"
    else: # monster
        if subcategory == "rare_anomalies":
            return "Raro", "Anomalia Espacial / Aparição de Fenda"
        elif subcategory == "giants_colossi":
            return "Elite", "Desafio Colossal de Área"
        elif numeric_id % 10 == 0:
            return "Forte", "Predador Alfa / Guardião de Território"
        else:
            return "Comum", "Patrulha Selvagem / Fauna Hostil"

def build_monster_loot(monster):
    """Gera a tabela completa de loot e a ficha markdown de um monstro."""
    m_id = monster["id"]
    name = monster["name"]
    fam_key = monster.get("folder", "Humanoids").lower()
    # Mapeamento para chave de materiais
    fam_map = {
        "humanoids": "humanoids",
        "beasts": "beasts",
        "reptiles": "reptiles_dragons",
        "reptiles_dragons": "reptiles_dragons",
        "undead": "undead",
        "demons_abominations": "demons_abyssals",
        "demons_abyssals": "demons_abyssals",
        "giants": "giants_colossi",
        "giants_colossi": "giants_colossi",
        "elementals": "magical_elementals",
        "magical_elementals": "magical_elementals",
        "insects": "insects_arachnids",
        "insects_arachnids": "insects_arachnids",
        "aquatic": "aquatic",
        "anomalies": "rare_anomalies",
        "rare_anomalies": "rare_anomalies"
    }
    mats_key = fam_map.get(fam_key, "humanoids")
    mats = FAMILY_MATERIALS.get(mats_key, FAMILY_MATERIALS["humanoids"])
    
    num_id = monster.get("numeric_id", 1)
    diff, encounter = get_difficulty_and_encounter("monster", mats_key, num_id, name)
    
    # Drops garantidos: Moedas de ouro + resíduo primário
    gold_min = 5 if diff == "Comum" else (15 if diff == "Forte" else (30 if diff == "Elite" else 50))
    gold_max = gold_min * 2 + 5
    guaranteed = [
        {
            "item_id": "item_gold_coins",
            "name": "Moedas de Ouro Antigas",
            "chance": 100.0,
            "min_quantity": gold_min,
            "max_quantity": gold_max,
            "rarity": "common",
            "category": "currency",
            "purpose": "Comércio de provisões, poções e serviços de forja."
        },
        {
            "item_id": mats["common"][0][0],
            "name": mats["common"][0][1],
            "chance": 100.0,
            "min_quantity": 1,
            "max_quantity": 2,
            "rarity": "common",
            "category": "material",
            "purpose": mats["common"][0][5]
        }
    ]
    
    # Drops comuns (35% a 75%)
    common = []
    for c_mat in mats["common"][1:]:
        common.append({
            "item_id": c_mat[0],
            "name": c_mat[1],
            "chance": 65.0 if diff == "Comum" else 75.0,
            "min_quantity": 1,
            "max_quantity": 3,
            "rarity": "common",
            "category": "material",
            "purpose": c_mat[5]
        })
    
    # Drops incomuns (15% a 45%)
    uncommon = []
    for u_mat in mats["uncommon"]:
        uncommon.append({
            "item_id": u_mat[0],
            "name": u_mat[1],
            "chance": 30.0 if diff == "Comum" else 42.0,
            "min_quantity": 1,
            "max_quantity": 2,
            "rarity": "uncommon",
            "category": "material",
            "purpose": u_mat[5]
        })
        
    # Drops raros (3% a 25%)
    rare = []
    for r_mat in mats["rare"]:
        rare.append({
            "item_id": r_mat[0],
            "name": r_mat[1],
            "chance": 8.0 if diff == "Comum" else (16.0 if diff == "Forte" else 22.0),
            "min_quantity": 1,
            "max_quantity": 1,
            "rarity": "rare",
            "category": "material",
            "purpose": r_mat[5]
        })
        
    # Drops épicos (0.5% a 6%)
    epic = []
    for e_mat in mats["epic"]:
        epic.append({
            "item_id": e_mat[0],
            "name": e_mat[1],
            "chance": 1.5 if diff == "Comum" else (3.5 if diff == "Forte" else 6.0),
            "min_quantity": 1,
            "max_quantity": 1,
            "rarity": "epic",
            "category": "material",
            "purpose": e_mat[5]
        })
        
    # Drops lendários (0.1% a 1.5%)
    legendary = []
    for l_mat in mats["legendary"]:
        legendary.append({
            "item_id": l_mat[0],
            "name": l_mat[1],
            "chance": 0.2 if diff == "Comum" else (0.8 if diff == "Forte" else 1.5),
            "min_quantity": 1,
            "max_quantity": 1,
            "rarity": "legendary",
            "category": "material",
            "purpose": l_mat[5]
        })
        
    # Equipamentos
    equipment = []
    # Seleção de arma com base no ID
    wep_id_key = (num_id % 20) + 1
    if mats_key in ["humanoids", "giants_colossi"] or diff in ["Forte", "Elite", "Raro"]:
        if wep_id_key in WEAPONS_BY_INDEX:
            w_info = WEAPONS_BY_INDEX[wep_id_key]
            equipment.append({
                "item_id": w_info[0],
                "name": w_info[1],
                "type": w_info[2],
                "chance": 2.5 if diff == "Comum" else 6.0,
                "rarity": "rare" if diff == "Elite" else "uncommon",
                "stats": w_info[4],
                "description": w_info[3]
            })
            
    # Drop exclusivo
    clean_name = re.sub(r'[^a-zA-Z0-9_]', '_', name.lower())
    exclusive = {
        "item_id": f"mat_excl_{clean_name}_{num_id:03d}",
        "name": f"Troféu Anatômico de {name}",
        "chance": 5.0 if diff == "Comum" else (12.0 if diff == "Forte" else 20.0),
        "min_quantity": 1,
        "max_quantity": 1,
        "rarity": "rare" if diff == "Comum" else "epic",
        "category": "exclusive",
        "description": f"Parte corporal única preservada de {name}, reconhecida por mestres artesãos.",
        "usage": f"Fabricação de itens de prestígio, troféus de caça e elixires específicos de {monster.get('region', 'região')}."
    }
    
    table_data = {
        "enemy_id": m_id,
        "enemy_name": name,
        "category": "monster",
        "subcategory": mats_key,
        "family": monster.get("family", "Humanoides monstruosos"),
        "continent": monster.get("continent", "Veyrath"),
        "region": monster.get("region", "REG-001"),
        "biome": monster.get("biome", "Vulcânico"),
        "habitat": monster.get("habitat", "Caverna"),
        "difficulty": diff,
        "encounter_type": encounter,
        "guaranteed": guaranteed,
        "common": common,
        "uncommon": uncommon,
        "rare": rare,
        "epic": epic,
        "legendary": legendary,
        "equipment": equipment,
        "exclusive": exclusive
    }
    
    return table_data

def build_demon_loot(demon):
    """Gera a tabela completa de loot e a ficha markdown de um demônio."""
    d_id = demon["id"]
    name = demon["name"]
    tier = demon["tier"] # inferior, superior, supreme, primordial
    num_id = demon.get("numeric_id", 1)
    diff, encounter = get_difficulty_and_encounter("demon", tier, num_id, name)
    
    # Drops do tier
    if tier == "primordial":
        t_mats = DEMON_TIER_MATERIALS["supreme"] # base
        prim_data = PRIMORDIAL_EXCLUSIVES.get(d_id, PRIMORDIAL_EXCLUSIVES["DEMON-191"])
    elif tier == "supreme":
        t_mats = DEMON_TIER_MATERIALS["supreme"]
    elif tier == "superior":
        t_mats = DEMON_TIER_MATERIALS["superior"]
    else: # inferior
        t_mats = DEMON_TIER_MATERIALS["inferior"]
        
    gold_min = 12 if tier == "inferior" else (35 if tier == "superior" else (150 if tier == "supreme" else 400))
    gold_max = gold_min * 2 + 10
    
    # Garantidos: Moedas + Essência do grau
    guaranteed = [
        {
            "item_id": "item_gold_coins",
            "name": t_mats["guaranteed"][1],
            "chance": 100.0,
            "min_quantity": gold_min,
            "max_quantity": gold_max,
            "rarity": "common",
            "category": "currency",
            "purpose": t_mats["guaranteed"][5]
        },
        {
            "item_id": t_mats["common"][0][0],
            "name": t_mats["common"][0][1],
            "chance": 100.0,
            "min_quantity": 1 if tier != "supreme" else 3,
            "max_quantity": 2 if tier != "supreme" else 5,
            "rarity": "common" if tier == "inferior" else ("uncommon" if tier == "superior" else "rare"),
            "category": "material",
            "purpose": t_mats["common"][0][5]
        }
    ]
    
    # Comuns (40% a 85%)
    common = []
    for c_mat in t_mats["common"][1:]:
        common.append({
            "item_id": c_mat[0],
            "name": c_mat[1],
            "chance": 70.0 if tier == "inferior" else 80.0,
            "min_quantity": 1,
            "max_quantity": 3 if tier != "primordial" else 5,
            "rarity": "common",
            "category": "material",
            "purpose": c_mat[5]
        })
        
    # Incomuns (20% a 55%)
    uncommon = []
    for u_mat in t_mats["uncommon"]:
        uncommon.append({
            "item_id": u_mat[0],
            "name": u_mat[1],
            "chance": 35.0 if tier == "inferior" else (45.0 if tier == "superior" else 60.0),
            "min_quantity": 1,
            "max_quantity": 2,
            "rarity": "uncommon",
            "category": "material",
            "purpose": u_mat[5]
        })
        
    # Raros (5% a 30%)
    rare = []
    for r_mat in t_mats["rare"]:
        rare.append({
            "item_id": r_mat[0],
            "name": r_mat[1],
            "chance": 10.0 if tier == "inferior" else (18.0 if tier == "superior" else 35.0),
            "min_quantity": 1,
            "max_quantity": 1,
            "rarity": "rare",
            "category": "material",
            "purpose": r_mat[5]
        })
        
    # Épicos (0.5% a 15%)
    epic = []
    for e_mat in t_mats["epic"]:
        epic.append({
            "item_id": e_mat[0],
            "name": e_mat[1],
            "chance": 2.0 if tier == "inferior" else (5.0 if tier == "superior" else 18.0),
            "min_quantity": 1,
            "max_quantity": 1,
            "rarity": "epic",
            "category": "material",
            "purpose": e_mat[5]
        })
        
    # Lendários (0.1% a 8%)
    legendary = []
    for l_mat in t_mats["legendary"]:
        legendary.append({
            "item_id": l_mat[0],
            "name": l_mat[1],
            "chance": 0.3 if tier == "inferior" else (1.2 if tier == "superior" else 6.5),
            "min_quantity": 1,
            "max_quantity": 1,
            "rarity": "legendary",
            "category": "material",
            "purpose": l_mat[5]
        })
        
    # Equipamentos
    equipment = []
    if tier == "supreme":
        # 100% chance de drop de equipamento ou arma épica/lendária
        w_idx = ((num_id - 1) % 10) * 10 + 1 # espalha pelas 10 categorias
        w_info = WEAPONS_BY_INDEX.get(w_idx, WEAPONS_BY_INDEX[1])
        equipment.append({
            "item_id": w_info[0],
            "name": w_info[1],
            "type": w_info[2],
            "chance": 15.0,
            "rarity": "epic",
            "stats": w_info[4],
            "description": w_info[3]
        })
    elif tier == "superior" and num_id % 5 == 0:
        w_info = WEAPONS_BY_INDEX.get(num_id % 20 + 1, WEAPONS_BY_INDEX[1])
        equipment.append({
            "item_id": w_info[0],
            "name": w_info[1],
            "type": w_info[2],
            "chance": 4.5,
            "rarity": "rare",
            "stats": w_info[4],
            "description": w_info[3]
        })
        
    # Drops exclusivos
    if tier == "primordial":
        # Os 7 itens obrigatórios do Primordial
        prim_items = PRIMORDIAL_EXCLUSIVES.get(d_id, PRIMORDIAL_EXCLUSIVES["DEMON-191"])
        exclusive = {
            "is_primordial": True,
            "items": [
                {
                    "item_id": prim_items["anatomical"][0],
                    "name": prim_items["anatomical"][1],
                    "type": "Material Anatômico Exclusivo",
                    "chance": 60.0,
                    "quantity": "1–2",
                    "rarity": prim_items["anatomical"][4],
                    "description": prim_items["anatomical"][2],
                    "usage": prim_items["anatomical"][6]
                },
                {
                    "item_id": prim_items["essence"][0],
                    "name": prim_items["essence"][1],
                    "type": "Essência Primordial Exclusiva",
                    "chance": 45.0,
                    "quantity": "1",
                    "rarity": prim_items["essence"][4],
                    "description": prim_items["essence"][2],
                    "usage": prim_items["essence"][6]
                },
                {
                    "item_id": prim_items["core"][0],
                    "name": prim_items["core"][1],
                    "type": "Núcleo Primordial Exclusivo",
                    "chance": 35.0,
                    "quantity": "1",
                    "rarity": prim_items["core"][4],
                    "description": prim_items["core"][2],
                    "usage": prim_items["core"][6]
                },
                {
                    "item_id": prim_items["equipment_comp"][0],
                    "name": prim_items["equipment_comp"][1],
                    "type": "Componente de Equipamento Exclusivo",
                    "chance": 40.0,
                    "quantity": "1",
                    "rarity": prim_items["equipment_comp"][4],
                    "description": prim_items["equipment_comp"][2],
                    "usage": prim_items["equipment_comp"][6]
                },
                {
                    "item_id": prim_items["special_identity"][0],
                    "name": prim_items["special_identity"][1],
                    "type": "Drop Especial de Identidade",
                    "chance": 30.0,
                    "quantity": "1",
                    "rarity": prim_items["special_identity"][4],
                    "description": prim_items["special_identity"][2],
                    "usage": prim_items["special_identity"][6]
                },
                {
                    "item_id": prim_items["progression_reward"][0],
                    "name": prim_items["progression_reward"][1],
                    "type": "Recompensa Rara de Progressão",
                    "chance": 25.0,
                    "quantity": "1",
                    "rarity": prim_items["progression_reward"][4],
                    "description": prim_items["progression_reward"][2],
                    "usage": prim_items["progression_reward"][6]
                },
                {
                    "item_id": prim_items["crafting_mat"][0],
                    "name": prim_items["crafting_mat"][1],
                    "type": "Material de Crafting Avançado",
                    "chance": 20.0,
                    "quantity": "1",
                    "rarity": prim_items["crafting_mat"][4],
                    "description": prim_items["crafting_mat"][2],
                    "usage": prim_items["crafting_mat"][6]
                }
            ]
        }
    elif tier == "supreme":
        core_info = BOSS_EXCLUSIVE_CORES.get(d_id, ("mat_core_generic_boss", f"Núcleo Abissal de {name}", "Núcleo de Lorde Demoníaco.", 1.5, "epic", 250, "Forja de armas épicas."))
        exclusive = {
            "is_primordial": False,
            "items": [
                {
                    "item_id": core_info[0],
                    "name": core_info[1],
                    "type": "Núcleo Exclusivo de Lorde Demoníaco",
                    "chance": 50.0,
                    "quantity": "1",
                    "rarity": "epic",
                    "description": core_info[2],
                    "usage": core_info[6]
                }
            ]
        }
    else:
        exclusive = {
            "is_primordial": False,
            "items": [
                {
                    "item_id": f"mat_trophy_{d_id.lower().replace('-', '_')}",
                    "name": f"Troféu de Guerra de {name.split('(')[0].strip()}",
                    "type": "Insignia Militar Demoníaca",
                    "chance": 6.0 if tier == "inferior" else 14.0,
                    "quantity": "1",
                    "rarity": "rare",
                    "description": f"Distintivo profano carregado por {name}.",
                    "usage": "Missões de expurgo, contratos de recompensa e forja de armas."
                }
            ]
        }
        
    table_data = {
        "enemy_id": d_id,
        "enemy_name": name,
        "category": "demon",
        "subcategory": tier,
        "family": demon.get("family", "brute"),
        "continent": demon.get("continent", "Veyrath"),
        "region": demon.get("region", "REG-001"),
        "biome": demon.get("biome", "Vulcânico"),
        "difficulty": diff,
        "encounter_type": encounter,
        "guaranteed": guaranteed,
        "common": common,
        "uncommon": uncommon,
        "rare": rare,
        "epic": epic,
        "legendary": legendary,
        "equipment": equipment,
        "exclusive": exclusive
    }
    
    return table_data

def format_loot_markdown(table):
    """Gera o documento Markdown com os 10 blocos A a J."""
    e_id = table["enemy_id"]
    name = table["enemy_name"]
    cat = "Monstro" if table["category"] == "monster" else f"Demônio {table['subcategory'].capitalize()}"
    
    md = f"""# FICHA DE LOOT: {name} ({e_id})

> **Documento Oficial de Distribuição de Recompensas e Drops**  
> **Universo:** Abyssal Pact | **Identificador:** `{e_id}` | **Categoria:** {cat}  
> **Compatibilidade:** Godot Engine v4.7.2 | **Regras de Drop:** Rolagem Independente

---

## A. Identificação
- **ID do Inimigo:** `{e_id}`
- **Nome Original:** {name}
- **Categoria:** {cat}
- **Família Canônica:** `{table['family']}`
- **Subespécie:** Fauna regional e forças da invasão abissal
- **Continente de Origem:** {table['continent']}
- **Região Canônica:** {table['region']}
- **Bioma:** {table['biome']}
- **Classificação de Dificuldade:** {table['difficulty']}
- **Tipo de Encontro:** {table['encounter_type']}

---

## B. Drops Garantidos
*Itens entregues com 100% de probabilidade após a confirmação da morte do inimigo.*
"""
    for g in table["guaranteed"]:
        md += f"- **Item:** {g['name']} (`{g['item_id']}`) | **Probabilidade:** 100% | **Quantidade:** {g['min_quantity']}–{g['max_quantity']} un | **Finalidade:** {g['purpose']}\n"
        
    md += """
---

## C. Drops Comuns
*Materiais de frequência elevada, essenciais para consumo regular e refino inicial.*
"""
    for c in table["common"]:
        md += f"- **Item:** {c['name']} (`{c['item_id']}`) | **Probabilidade:** {c['chance']}% | **Quantidade:** {c['min_quantity']}–{c['max_quantity']} un | **Raridade:** Comum | **Utilização:** {c['purpose']}\n"

    md += """
---

## D. Drops Incomuns
*Materiais intermediários para alfaiataria reforçada, ferraria e alquimia militar.*
"""
    for u in table["uncommon"]:
        md += f"- **Item:** {u['name']} (`{u['item_id']}`) | **Probabilidade:** {u['chance']}% | **Quantidade:** {u['min_quantity']}–{u['max_quantity']} un | **Raridade:** Incomum | **Utilização:** {u['purpose']}\n"

    md += """
---

## E. Drops Raros
*Núcleos de energia, órgãos sensoriais refinados e cristais puros.*
"""
    for r in table["rare"]:
        md += f"- **Item:** {r['name']} (`{r['item_id']}`) | **Probabilidade:** {r['chance']}% | **Quantidade:** {r['min_quantity']}–{r['max_quantity']} un | **Raridade:** Raro | **Utilização:** {r['purpose']}\n"

    md += """
---

## F. Drops Épicos
*Componentes de mestre artífice, tecidos arcanos e materiais de alta forja.*
"""
    for ep in table["epic"]:
        md += f"- **Item:** {ep['name']} (`{ep['item_id']}`) | **Probabilidade:** {ep['chance']}% | **Quantidade:** {ep['min_quantity']}–{ep['max_quantity']} un | **Raridade:** Épico | **Utilização:** {ep['purpose']}\n"

    md += """
---

## G. Drops Lendários
*Relíquias antigas, selos divinos e catalisadores de imenso poder.*
"""
    for leg in table["legendary"]:
        md += f"- **Item:** {leg['name']} (`{leg['item_id']}`) | **Probabilidade:** {leg['chance']}% | **Quantidade:** {leg['min_quantity']}–{leg['max_quantity']} un | **Raridade:** Lendário | **Utilização:** {leg['purpose']}\n"

    md += """
---

## H. Equipamentos
*Peças de combate empunhadas ou resguardadas pelo inimigo.*
"""
    if table["equipment"]:
        for eq in table["equipment"]:
            stats_str = ", ".join([f"{k}: +{v}" for k, v in eq.get('stats', {}).items()])
            md += f"- **Equipamento:** {eq['name']} (`{eq['item_id']}`) | **Tipo:** {eq['type'].capitalize()} | **Probabilidade:** {eq['chance']}% | **Raridade:** {eq['rarity'].capitalize()} | **Atributos:** {stats_str}\n"
            md += f"  - *Descrição:* {eq['description']}\n"
    else:
        md += "- **Equipamento Direto:** Nenhum equipamento inteiro dropado diretamente. O inimigo provê matérias-primas e componentes de forja para manufatura de armaduras e armas na Hell Forge.\n"

    md += """
---

## I. Drops Exclusivos
*Materiais singulares associados estritamente à identidade anatômica ou heráldica desta criatura.*
"""
    excl = table["exclusive"]
    if isinstance(excl, dict) and excl.get("is_primordial"):
        md += "> **ATENÇÃO: Demônio Primordial — Contém os 7 Drops Exclusivos Obrigatórios.**\n\n"
        for idx, item in enumerate(excl["items"], 1):
            md += f"### I.{idx} — {item['type']}\n"
            md += f"- **Item:** {item['name']} (`{item['item_id']}`)\n"
            md += f"- **Probabilidade:** {item['chance']}% | **Quantidade:** {item['quantity']} un | **Raridade:** {item['rarity'].capitalize()}\n"
            md += f"- **Identidade Visual & Descrição:** {item['description']}\n"
            md += f"- **Destino & Utilização:** {item['usage']}\n\n"
    elif isinstance(excl, dict) and "items" in excl:
        for item in excl["items"]:
            md += f"- **Drop Exclusivo:** {item['name']} (`{item['item_id']}`) | **Chance:** {item['chance']}% | **Qtd:** {item['quantity']} un | **Raridade:** {item['rarity'].capitalize()}\n"
            md += f"  - *Identidade Singular:* {item['description']}\n"
            md += f"  - *Aplicação Especial:* {item['usage']}\n"
    elif isinstance(excl, dict):
        md += f"- **Drop Exclusivo:** {excl['name']} (`{excl['item_id']}`) | **Chance:** {excl['chance']}% | **Qtd:** {excl['min_quantity']}–{excl['max_quantity']} un | **Raridade:** {excl['rarity'].capitalize()}\n"
        md += f"  - *Identidade Singular:* {excl['description']}\n"
        md += f"  - *Aplicação Especial:* {excl['usage']}\n"

    md += """
---

## J. Utilização dos Drops
*Mapeamento rigoroso de consumo econômico e progressão dos itens obtidos.*

1. **Crafting & Forja de Equipamentos:**
   - Materiais comuns e incomuns são convertidos em ligas metálicas, placas de couro reforçado e cabos na Hell Forge.
   - Partes anatômicas abastecem receitas das 10 categorias canônicas de armas e 5 tipos de armadura.
2. **Aprimoramento & Refino:**
   - Núcleos e essências alimentam bancadas de têmpera para elevação de nível de itens (+1 a +10).
   - Sangue e fragmentos minerais servem de catalisadores em encantamentos elementais.
3. **Alquimia & Consumíveis:**
   - Glândulas e pós são destilados em elixires de regeneração, antídotos e frascos de mana concentrada.
   - Óleos de lâmina temporários fornecem dano adicional contra criaturas da mesma família.
4. **Missões, Pactos & Economia:**
   - Moedas de ouro sustentam o comércio entre jogadores nos acampamentos seguros de cada continente.
   - Troféus e selos abissais são aceitos por emissários de facção para avanço de reputação e progressão de pactos mundiais.
"""
    return md

print("[Loot Table Builder] Construtor de tabelas e formatador markdown inicializado com sucesso.")
