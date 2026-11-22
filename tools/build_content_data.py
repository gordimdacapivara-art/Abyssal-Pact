# tools/build_content_data.py
import os

EQUIPMENT_DATA = [
    {
        "file": "eq_001.tres",
        "id": "EQ-001",
        "name": "Espada das Cinzas",
        "category": "equipment",
        "slot": "weapon",
        "type": "weapon",
        "rarity": "common",
        "desc": "Lâmina forjada em aço vulcânico resfriado nas cinzas de Veyrath.",
        "stats": '{\n"attack": 18,\n"crit_chance": 5\n}',
        "use": "{}",
        "val": 45,
        "stack": 1
    },
    {
        "file": "eq_002.tres",
        "id": "EQ-002",
        "name": "Cajado do Vazio Vulcânico",
        "category": "equipment",
        "slot": "weapon",
        "type": "weapon",
        "rarity": "rare",
        "desc": "Cajado esculpido em obsidiana pura que canaliza energias do núcleo cáustico.",
        "stats": '{\n"attack": 14,\n"magic_power": 32,\n"max_mana": 40\n}',
        "use": "{}",
        "val": 180,
        "stack": 1
    },
    {
        "file": "eq_003.tres",
        "id": "EQ-003",
        "name": "Adaga de Obsidiana",
        "category": "equipment",
        "slot": "weapon",
        "type": "weapon",
        "rarity": "uncommon",
        "desc": "Gume afiado como vidro negro, ideal para ataques rápidos e furtivos.",
        "stats": '{\n"attack": 22,\n"crit_chance": 12,\n"attack_speed": 15\n}',
        "use": "{}",
        "val": 90,
        "stack": 1
    },
    {
        "file": "eq_004.tres",
        "id": "EQ-004",
        "name": "Machado Rúnico de Basalto",
        "category": "equipment",
        "slot": "weapon",
        "type": "weapon",
        "rarity": "epic",
        "desc": "Arma pesada gravada com runas de destruição dos antigos forjadores.",
        "stats": '{\n"attack": 46,\n"armor_penetration": 18\n}',
        "use": "{}",
        "val": 350,
        "stack": 1
    },
    {
        "file": "eq_005.tres",
        "id": "EQ-005",
        "name": "Elmo de Cinzas",
        "category": "equipment",
        "slot": "head",
        "type": "armor_head",
        "rarity": "common",
        "desc": "Proteção para a cabeça forjada com ligas de ferro e cinzas comprimidas.",
        "stats": '{\n"defense": 8,\n"max_health": 25\n}',
        "use": "{}",
        "val": 40,
        "stack": 1
    },
    {
        "file": "eq_006.tres",
        "id": "EQ-006",
        "name": "Peitoral de Ferro Profundo",
        "category": "equipment",
        "slot": "chest",
        "type": "armor_chest",
        "rarity": "rare",
        "desc": "Armadura pesada de placas de ferro temperadas nas forjas abissais.",
        "stats": '{\n"defense": 26,\n"max_health": 80,\n"physical_resistance": 10\n}',
        "use": "{}",
        "val": 220,
        "stack": 1
    },
    {
        "file": "eq_007.tres",
        "id": "EQ-007",
        "name": "Perneiras de Obsidiana",
        "category": "equipment",
        "slot": "legs",
        "type": "armor_legs",
        "rarity": "uncommon",
        "desc": "Grevas articuladas que conferem mobilidade e proteção consistente.",
        "stats": '{\n"defense": 14,\n"max_stamina": 20\n}',
        "use": "{}",
        "val": 110,
        "stack": 1
    },
    {
        "file": "eq_008.tres",
        "id": "EQ-008",
        "name": "Botas da Forja",
        "category": "equipment",
        "slot": "boots",
        "type": "armor_boots",
        "rarity": "common",
        "desc": "Botas reforçadas com solado térmico imune a brasas e calor abrasador.",
        "stats": '{\n"defense": 6,\n"move_speed": 5\n}',
        "use": "{}",
        "val": 35,
        "stack": 1
    },
    {
        "file": "eq_009.tres",
        "id": "EQ-009",
        "name": "Amuleto da Maré Eterna",
        "category": "equipment",
        "slot": "amulet",
        "type": "accessory_amulet",
        "rarity": "epic",
        "desc": "Jóia abissal que ressoa com os fluxos arcanos de Nhal'Kora.",
        "stats": '{\n"max_mana": 50,\n"magic_power": 18,\n"mana_regen": 10\n}',
        "use": "{}",
        "val": 400,
        "stack": 1
    },
    {
        "file": "eq_010.tres",
        "id": "EQ-010",
        "name": "Anel do Primeiro Pacto",
        "category": "equipment",
        "slot": "ring",
        "type": "accessory_ring",
        "rarity": "rare",
        "desc": "Anel forjado na Hell Forge no momento da criação do primeiro laço abissal.",
        "stats": '{\n"attack": 10,\n"crit_chance": 8\n}',
        "use": "{}",
        "val": 250,
        "stack": 1
    },
    {
        "file": "eq_011.tres",
        "id": "EQ-011",
        "name": "Selo de Basalto",
        "category": "equipment",
        "slot": "ring2",
        "type": "accessory_ring",
        "rarity": "uncommon",
        "desc": "Anel esculpido na rocha matriz dos cânions de Khar-Duum.",
        "stats": '{\n"defense": 12,\n"health_regen": 4\n}',
        "use": "{}",
        "val": 130,
        "stack": 1
    },
    {
        "file": "eq_012.tres",
        "id": "EQ-012",
        "name": "Elixir de Vida Abissal",
        "category": "consumable",
        "slot": "none",
        "type": "none",
        "rarity": "common",
        "desc": "Poção revigorante destilada a partir de seiva de Sylvaran. Recupera 120 de vida.",
        "stats": "{}",
        "use": '{\n"type": "heal",\n"value": 120\n}',
        "val": 25,
        "stack": 20
    },
    {
        "file": "eq_013.tres",
        "id": "EQ-013",
        "name": "Frasco de Mana Corrompida",
        "category": "consumable",
        "slot": "none",
        "type": "none",
        "rarity": "common",
        "desc": "Líquido cintilante de energia mística. Recupera 80 de mana instantaneamente.",
        "stats": "{}",
        "use": '{\n"type": "mana",\n"value": 80\n}',
        "val": 25,
        "stack": 20
    },
    {
        "file": "eq_014.tres",
        "id": "EQ-014",
        "name": "Antídoto de Enxofre",
        "category": "consumable",
        "slot": "none",
        "type": "none",
        "rarity": "common",
        "desc": "Neutraliza toxinas cáusticas e venenos biológicos.",
        "stats": "{}",
        "use": '{\n"type": "cure_poison",\n"value": 1\n}',
        "val": 15,
        "stack": 20
    },
    {
        "file": "eq_015.tres",
        "id": "EQ-015",
        "name": "Minério de Basalto",
        "category": "material",
        "slot": "none",
        "type": "none",
        "rarity": "common",
        "desc": "Pedra vulcânica densa usada em reforços e aprimoramento de equipamentos.",
        "stats": "{}",
        "use": "{}",
        "val": 10,
        "stack": 99
    },
    {
        "file": "eq_016.tres",
        "id": "EQ-016",
        "name": "Essência de Cinzas",
        "category": "material",
        "slot": "none",
        "type": "none",
        "rarity": "uncommon",
        "desc": "Resíduo espiritual colhido das criaturas de cinzas de Veyrath.",
        "stats": "{}",
        "use": "{}",
        "val": 30,
        "stack": 99
    },
    {
        "file": "eq_017.tres",
        "id": "EQ-017",
        "name": "Fragmento de Obsidiana",
        "category": "material",
        "slot": "none",
        "type": "none",
        "rarity": "rare",
        "desc": "Cristal vulcânico negro com capacidade de reter calor e canalizar energia.",
        "stats": "{}",
        "use": "{}",
        "val": 65,
        "stack": 99
    },
    {
        "file": "eq_018.tres",
        "id": "EQ-018",
        "name": "Relíquia da Hell Forge",
        "category": "relic",
        "slot": "none",
        "type": "none",
        "rarity": "legendary",
        "desc": "Artefato primordial pulsante de poder demoníaco que amplifica pactos abissais.",
        "stats": '{\n"all_attributes": 12,\n"abyssal_resonance": 25\n}',
        "use": "{}",
        "val": 800,
        "stack": 1
    },
    {
        "file": "eq_019.tres",
        "id": "EQ-019",
        "name": "Olho de Veyrath",
        "category": "relic",
        "slot": "none",
        "type": "none",
        "rarity": "epic",
        "desc": "Gema extraída do coração da grande caldeira, emitindo luz vermelha intensa.",
        "stats": '{\n"fire_power": 25,\n"burn_resistance": 30\n}',
        "use": "{}",
        "val": 450,
        "stack": 1
    },
    {
        "file": "eq_020.tres",
        "id": "EQ-020",
        "name": "Chave das Catacumbas",
        "category": "quest",
        "slot": "none",
        "type": "none",
        "rarity": "rare",
        "desc": "Chave entalhada em ferro negro necessária para destravar os portões inferiores de Basalto.",
        "stats": "{}",
        "use": "{}",
        "val": 0,
        "stack": 1
    },
    {
        "file": "eq_021.tres",
        "id": "EQ-021",
        "name": "Tabuleta Rúnica Antiga",
        "category": "quest",
        "slot": "none",
        "type": "none",
        "rarity": "rare",
        "desc": "Inscrições primordiais que revelam as fraquezas dos chefes demoníacos de Veyrath.",
        "stats": "{}",
        "use": "{}",
        "val": 0,
        "stack": 1
    }
]

QUESTS_DATA = [
    {
        "file": "quest_001.tres",
        "id": "QUEST-001",
        "name": "O Despertar da Hell Forge",
        "category": "main",
        "level": 1,
        "region": "REG-001",
        "class_id": "",
        "race_id": "",
        "desc": "Desperte a forja ancestral e sele o primeiro pacto de vínculo abissal.",
        "rewards": '{\n"xp": 150,\n"souls": 80\n}',
        "objs": '{\n"OBJ-001": {\n"description": "Ativar o Altar Central da Hell Forge",\n"required": 2\n}\n}'
    },
    {
        "file": "quest_002.tres",
        "id": "QUEST-002",
        "name": "A Fenda Abissal de Veyrath",
        "category": "main",
        "level": 3,
        "region": "REG-001",
        "class_id": "",
        "race_id": "",
        "desc": "Investigue a fenda de lava ativa ao norte do Baluarte das Cinzas e derrote os demônios invasores.",
        "rewards": '{\n"xp": 250,\n"souls": 120\n}',
        "objs": '{\n"OBJ-001": {\n"description": "Eliminar Demônios das Cinzas na Fenda",\n"required": 4\n}\n}'
    },
    {
        "file": "quest_003.tres",
        "id": "QUEST-003",
        "name": "Ecos do Passado Vulcânico",
        "category": "side",
        "level": 2,
        "region": "REG-001",
        "class_id": "",
        "race_id": "",
        "desc": "Colete fragmentos de obsidiana deixados nos cumes ao redor do Baluarte.",
        "rewards": '{\n"xp": 120,\n"souls": 50\n}',
        "objs": '{\n"OBJ-001": {\n"description": "Coletar Fragmentos de Obsidiana",\n"required": 5\n}\n}'
    },
    {
        "file": "quest_004.tres",
        "id": "QUEST-004",
        "name": "Tesouros de Enxofre",
        "category": "side",
        "level": 4,
        "region": "REG-002",
        "class_id": "",
        "race_id": "",
        "desc": "Explore as fendas de enxofre e resgate os pertences da caravana perdida.",
        "rewards": '{\n"xp": 180,\n"souls": 90\n}',
        "objs": '{\n"OBJ-001": {\n"description": "Encontrar Caixas de Suprimentos",\n"required": 3\n}\n}'
    },
    {
        "file": "quest_005.tres",
        "id": "QUEST-005",
        "name": "Purificação das Cinzas",
        "category": "regional",
        "level": 5,
        "region": "REG-001",
        "class_id": "",
        "race_id": "",
        "desc": "Limpe as proximidades do Baluarte das Cinzas derrotando patrulhas corrompidas.",
        "rewards": '{\n"xp": 300,\n"souls": 150\n}',
        "objs": '{\n"OBJ-001": {\n"description": "Derrotar Demônios Regionais",\n"required": 8\n}\n}'
    },
    {
        "file": "quest_006.tres",
        "id": "QUEST-006",
        "name": "Segredos dos Salgueiros Negros",
        "category": "regional",
        "level": 12,
        "region": "REG-015",
        "class_id": "",
        "race_id": "",
        "desc": "Descubra as inscrições fúnebres no vale pantanoso de Sylvaran.",
        "rewards": '{\n"xp": 450,\n"souls": 220\n}',
        "objs": '{\n"OBJ-001": {\n"description": "Examinar Lápides Antigas",\n"required": 4\n}\n}'
    },
    {
        "file": "quest_007.tres",
        "id": "QUEST-007",
        "name": "O Domínio do Arcanista",
        "category": "class",
        "level": 3,
        "region": "REG-001",
        "class_id": "CLASS-001",
        "race_id": "",
        "desc": "Conduza conjurações precisas para sintonizar sua essência arcana aos fluxos do mundo.",
        "rewards": '{\n"xp": 200,\n"souls": 100\n}',
        "objs": '{\n"OBJ-001": {\n"description": "Executar Conjurações com Sucesso",\n"required": 5\n}\n}'
    },
    {
        "file": "quest_008.tres",
        "id": "QUEST-008",
        "name": "Provações de Combate",
        "category": "class",
        "level": 5,
        "region": "REG-001",
        "class_id": "CLASS-002",
        "race_id": "",
        "desc": "Demonstre maestria em postura defensiva contra criaturas brutas.",
        "rewards": '{\n"xp": 220,\n"souls": 110\n}',
        "objs": '{\n"OBJ-001": {\n"description": "Aparar Golpes Inimigos",\n"required": 3\n}\n}'
    },
    {
        "file": "quest_009.tres",
        "id": "QUEST-009",
        "name": "Herança Primordial",
        "category": "race",
        "level": 2,
        "region": "REG-001",
        "class_id": "",
        "race_id": "RACE-001",
        "desc": "Conecte-se com o monólito primordial de sua linhagem em Veyrath.",
        "rewards": '{\n"xp": 180,\n"souls": 70\n}',
        "objs": '{\n"OBJ-001": {\n"description": "Tocar o Monólito Ancestral",\n"required": 1\n}\n}'
    },
    {
        "file": "quest_010.tres",
        "id": "QUEST-010",
        "name": "Tradições Ancestrais",
        "category": "race",
        "level": 4,
        "region": "REG-011",
        "class_id": "",
        "race_id": "RACE-002",
        "desc": "Preste homenagem aos espíritos arbóreos nas raízes de Sylvaran.",
        "rewards": '{\n"xp": 240,\n"souls": 110\n}',
        "objs": '{\n"OBJ-001": {\n"description": "Oferecer Seiva Sagrada ao Altar",\n"required": 2\n}\n}'
    }
]

PACTS_DATA = [
    {
        "file": "pact_001.tres",
        "id": "PACT-001",
        "name": "Pacto das Cinzas Primordiais",
        "desc": "Vínculo sagrado com os espíritos vulcânicos de Veyrath. Concede poder de fogo e tenacidade.",
        "lore": "Forjado no primeiro despertar das fissuras da terra, quando os habitantes aprenderam a respirar fuligem e forjar almas em brasas.",
        "tier": 1,
        "max_tier": 5,
        "unlocked": True,
        "level": 1,
        "ability": "burst_flame",
        "passives": '["Resistência ao fogo +15%", "Ataques causam dano de queimadura residual", "Gera calor em combate prolongado"]',
        "stats": '{\n"fire_power": 12,\n"physical_defense": 8,\n"max_health": 30\n}',
        "reqs": '{\n"souls_cost": 100,\n"required_item_id": "EQ-016",\n"item_quantity": 2\n}'
    },
    {
        "file": "pact_002.tres",
        "id": "PACT-002",
        "name": "Pacto das Raízes Espectrais",
        "desc": "Simbionte espiritual com as árvores milenares de Sylvaran. Regenera vida e canaliza feitiçaria vegetal.",
        "lore": "Os bosques de Sylvaran não esquecem nada. Aqueles que abraçam suas raízes tornam-se guardiões das brumas e da memória perdida.",
        "tier": 1,
        "max_tier": 5,
        "unlocked": True,
        "level": 1,
        "ability": "spectral_vines",
        "passives": '["Regeneração de vida passiva", "Dano arcano aumentado em 10%", "Passo silencioso em terreno natural"]',
        "stats": '{\n"spirit_power": 15,\n"health_regen": 5,\n"max_mana": 35\n}',
        "reqs": '{\n"souls_cost": 120,\n"required_item_id": "EQ-015",\n"item_quantity": 3\n}'
    },
    {
        "file": "pact_003.tres",
        "id": "PACT-003",
        "name": "Pacto da Forja de Basalto",
        "desc": "Pacto inabalável com a rocha sólida e as muralhas de Khar-Duum. Focado em defesa pesada e resistência.",
        "lore": "Nem o vento nem o tempo quebram o basalto. Quem carrega este selo torna sua própria pele uma couraça de pedra viva.",
        "tier": 1,
        "max_tier": 5,
        "unlocked": False,
        "level": 5,
        "ability": "stone_skin",
        "passives": '["Redução de dano físico recebido em 12%", "Imunidade a atordoamentos curtos", "Reflexão de dano por impacto"]',
        "stats": '{\n"physical_defense": 22,\n"max_health": 60,\n"poise": 20\n}',
        "reqs": '{\n"souls_cost": 250,\n"required_item_id": "EQ-017",\n"item_quantity": 2\n}'
    },
    {
        "file": "pact_004.tres",
        "id": "PACT-004",
        "name": "Pacto do Vórtice Abissal",
        "desc": "Comunhão com as profundezas gélidas e correntes submersas de Nhal'Kora. Focado em dano sombrio e velocidade.",
        "lore": "O mar das profundezas não perdoa fraqueza. Ao aceitar o vórtice, sua mente mergulha na escuridão onde os leviatãs repousam.",
        "tier": 1,
        "max_tier": 5,
        "unlocked": False,
        "level": 10,
        "ability": "abyssal_surge",
        "passives": '["Ataques aplicam lentidão no alvo", "Aumento da velocidade de movimento", "Absorção de mana em acertos críticos"]',
        "stats": '{\n"abyssal_damage": 20,\n"mana_regen": 8,\n"move_speed": 10\n}',
        "reqs": '{\n"souls_cost": 400,\n"required_item_id": "EQ-018",\n"item_quantity": 1\n}'
    },
    {
        "file": "pact_005.tres",
        "id": "PACT-005",
        "name": "Pacto da Chama Eterna da Hell Forge",
        "desc": "O vínculo definitivo que ancora o jogador à Hell Forge, garantindo sobrevivência e transcendência ao renascer.",
        "lore": "A forja é o ventre de todos os caçadores abissais. Ela acolhe as almas derrotadas e as devolve ao mundo temperadas pelo fogo eterno.",
        "tier": 1,
        "max_tier": 5,
        "unlocked": True,
        "level": 1,
        "ability": "hell_resurgence",
        "passives": '["Ressurgimento preserva 100% dos pactos ativos", "Dano aumentado em 8% após renascer", "Bônus de atributos globais"]',
        "stats": '{\n"all_attributes": 8,\n"max_health": 40,\n"max_stamina": 30\n}',
        "reqs": '{\n"souls_cost": 300,\n"required_item_id": "EQ-016",\n"item_quantity": 4\n}'
    }
]

def generate():
    os.makedirs("data/content/equipment", exist_ok=True)
    os.makedirs("data/content/quests", exist_ok=True)
    os.makedirs("data/content/pacts", exist_ok=True)

    # Equipment
    for item in EQUIPMENT_DATA:
        path = os.path.join("data/content/equipment", item["file"])
        content = f'''[gd_resource type="Resource" script_class="EquipmentData" load_steps=2 format=3]

[ext_resource type="Script" path="res://data/models/equipment_data.gd" id="1_item"]

[resource]
script = ExtResource("1_item")
id = &"{item['id']}"
display_name = "{item['name']}"
description = "{item['desc']}"
category = &"{item['category']}"
slot = &"{item['slot']}"
equipment_type = &"{item['type']}"
rarity = &"{item['rarity']}"
stats = {item['stats']}
use_effect = {item['use']}
value = {item['val']}
max_stack = {item['stack']}
'''
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
    print(f"Generated {len(EQUIPMENT_DATA)} equipment files.")

    # Quests
    for q in QUESTS_DATA:
        path = os.path.join("data/content/quests", q["file"])
        content = f'''[gd_resource type="Resource" script_class="QuestData" load_steps=2 format=3]

[ext_resource type="Script" path="res://data/models/quest_data.gd" id="1_quest"]

[resource]
script = ExtResource("1_quest")
id = &"{q['id']}"
display_name = "{q['name']}"
description = "{q['desc']}"
category = &"{q['category']}"
level_requirement = {q['level']}
region_id = &"{q['region']}"
class_id = &"{q['class_id']}"
race_id = &"{q['race_id']}"
rewards = {q['rewards']}
objectives = {q['objs']}
'''
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
    print(f"Generated {len(QUESTS_DATA)} quest files.")

    # Pacts
    for p in PACTS_DATA:
        path = os.path.join("data/content/pacts", p["file"])
        content = f'''[gd_resource type="Resource" script_class="PactData" load_steps=2 format=3]

[ext_resource type="Script" path="res://data/models/pact_data.gd" id="1_pact"]

[resource]
script = ExtResource("1_pact")
id = &"{p['id']}"
display_name = "{p['name']}"
description = "{p['desc']}"
lore = "{p['lore']}"
tier = {p['tier']}
max_tier = {p['max_tier']}
unlocked = {str(p['unlocked']).lower()}
unlock_level = {p['level']}
active_ability_id = &"{p['ability']}"
passive_descriptions = PackedStringArray({p['passives'].strip('[]')})
stat_modifiers = {p['stats']}
evolution_requirements = {p['reqs']}
'''
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
    print(f"Generated {len(PACTS_DATA)} pact files.")

if __name__ == "__main__":
    generate()
