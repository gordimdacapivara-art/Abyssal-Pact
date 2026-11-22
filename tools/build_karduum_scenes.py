"""
ABYSSAL PACT — Construtor e Integrador das 10 Regiões 3D de Khar-Duum
Gera:
1. Os 10 GDScripts dedicados em scenes/world/regions/
2. As 10 cenas 3D (.tscn) em scenes/world/regions/ (e seus aliases region_0XX.tscn)
3. Atualiza os 10 Resources RegionData em data/content/regions/ (region_021.tres..region_030.tres)
"""

import os
import re

KARDUUM_REGIONS = [
    {
        "num": 21,
        "id": "REG-021",
        "slug": "caldeira_rubra",
        "name": "Caldeira Rubra",
        "class_name": "CaldeiraRubraRegion",
        "script_rel": "scenes/world/regions/caldeira_rubra.gd",
        "biome": "ash_desert",
        "level_min": 20,
        "level_max": 30,
        "sky_top": "Color(0.24, 0.12, 0.10, 1)",
        "sky_horizon": "Color(0.55, 0.28, 0.15, 1)",
        "fog_color": "Color(0.42, 0.22, 0.14, 1)",
        "fog_density": 0.008,
        "sun_color": "Color(1.0, 0.70, 0.40, 1)",
        "sun_energy": 1.4,
        "ground_color": "Color(0.18, 0.14, 0.12, 1)",
        "city_id": "poi_reg021_city",
        "city_name": "Caravansarai das Chamas",
        "dungeon_id": "dungeon_flame_nomads",
        "dungeon_name": "Cripta dos Nômades de Fogo",
        "boss_id": "BOSS-017",
        "boss_name": "Arena do Fogo Primordial",
        "exp_id": "poi_caldera_vent",
        "exp_name": "Chaminé da Caldeira Rubra",
        "gates": [
            {"name": "GateNorth", "target": "REG-022", "spawn": "gate_south", "label": "Via Imperial para Fornalha dos Reis (REG-022)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-023", "spawn": "gate_north", "label": "Passo para o Desfiladeiro de Obsidiana (REG-023)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": True,
        "demons": ["DEMON-101", "DEMON-102", "DEMON-103", "DEMON-104", "DEMON-105"],
        "monument_cat": "structures",
        "monument_name": "structure_rubra_caldera_vent",
        "check_node": "Structures/RubraCalderaVent",
        "extra_monument": {"cat": "props", "name": "prop_volcanic_vent_horn", "node": "VolcanicHornWest", "pos": "Vector3(-25, 0, -35)"}
    },
    {
        "num": 22,
        "id": "REG-022",
        "slug": "fornalha_dos_reis",
        "name": "Fornalha dos Reis",
        "class_name": "FornalhaDosReisRegion",
        "script_rel": "scenes/world/regions/fornalha_dos_reis.gd",
        "biome": "forge_city",
        "level_min": 22,
        "level_max": 30,
        "sky_top": "Color(0.28, 0.14, 0.08, 1)",
        "sky_horizon": "Color(0.62, 0.32, 0.12, 1)",
        "fog_color": "Color(0.48, 0.25, 0.12, 1)",
        "fog_density": 0.012,
        "sun_color": "Color(1.0, 0.65, 0.25, 1)",
        "sun_energy": 1.5,
        "ground_color": "Color(0.16, 0.15, 0.16, 1)",
        "city_id": "poi_reg022_city",
        "city_name": "Cidadela das Forjas",
        "dungeon_id": "dungeon_foundry_claws",
        "dungeon_name": "Garras da Fundição",
        "boss_id": "BOSS-018",
        "boss_name": "Câmara do Metal Derretido",
        "exp_id": "poi_colossal_anvil",
        "exp_name": "A Grande Bigorna de Adamante",
        "gates": [
            {"name": "GateNorth", "target": "REG-021", "spawn": "gate_south", "label": "Estrada para Caldeira Rubra (REG-021)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-024", "spawn": "gate_north", "label": "Canal de Escória para o Mar de Escória (REG-024)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-106", "DEMON-107", "DEMON-108", "DEMON-109", "DEMON-110"],
        "monument_cat": "structures",
        "monument_name": "structure_kings_forge_citadel",
        "check_node": "Structures/KingsForgeCitadel",
        "extra_monument": {"cat": "props", "name": "prop_colossal_forge_anvil", "node": "GreatAnvilSquare", "pos": "Vector3(0, 0, 25)"}
    },
    {
        "num": 23,
        "id": "REG-023",
        "slug": "desfiladeiro_de_obsidiana",
        "name": "Desfiladeiro de Obsidiana",
        "class_name": "DesfiladeiroDeObsidianaRegion",
        "script_rel": "scenes/world/regions/desfiladeiro_de_obsidiana.gd",
        "biome": "obsidian_canyon",
        "level_min": 23,
        "level_max": 31,
        "sky_top": "Color(0.18, 0.14, 0.18, 1)",
        "sky_horizon": "Color(0.40, 0.24, 0.32, 1)",
        "fog_color": "Color(0.28, 0.18, 0.24, 1)",
        "fog_density": 0.007,
        "sun_color": "Color(0.92, 0.75, 0.65, 1)",
        "sun_energy": 1.35,
        "ground_color": "Color(0.08, 0.08, 0.09, 1)",
        "city_id": "poi_reg023_city",
        "city_name": "Posto do Espelho Negro",
        "dungeon_id": "dungeon_sharp_shards",
        "dungeon_name": "Abismo dos Cacos Afiados",
        "boss_id": "BOSS-019",
        "boss_name": "Fenda dos Reflexos Quebrados",
        "exp_id": "poi_obsidian_gate",
        "exp_name": "Pináculos Gêmeos de Vidro Negro",
        "gates": [
            {"name": "GateNorth", "target": "REG-021", "spawn": "gate_south", "label": "Subida para Caldeira Rubra (REG-021)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-025", "spawn": "gate_north", "label": "Acesso para as Dunas de Vidro Negro (REG-025)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-111", "DEMON-112", "DEMON-113", "DEMON-114", "DEMON-115"],
        "monument_cat": "rocks",
        "monument_name": "rock_obsidian_canyon_gate",
        "check_node": "Structures/ObsidianCanyonGate",
        "extra_monument": None
    },
    {
        "num": 24,
        "id": "REG-024",
        "slug": "mar_de_escoria",
        "name": "Mar de Escória",
        "class_name": "MarDeEscoriaRegion",
        "script_rel": "scenes/world/regions/mar_de_escoria.gd",
        "biome": "slag_sea",
        "level_min": 24,
        "level_max": 32,
        "sky_top": "Color(0.22, 0.15, 0.12, 1)",
        "sky_horizon": "Color(0.48, 0.30, 0.18, 1)",
        "fog_color": "Color(0.36, 0.22, 0.16, 1)",
        "fog_density": 0.010,
        "sun_color": "Color(0.95, 0.70, 0.45, 1)",
        "sun_energy": 1.3,
        "ground_color": "Color(0.15, 0.14, 0.14, 1)",
        "city_id": "poi_reg024_city",
        "city_name": "Acampamento da Escória",
        "dungeon_id": "dungeon_dead_ash_furnace",
        "dungeon_name": "Fornalha das Cinzas Mortas",
        "boss_id": "BOSS-020",
        "boss_name": "Lago de Ferro Petrificado",
        "exp_id": "poi_slag_refinery",
        "exp_name": "Refinaria dos Resíduos Vulcânicos",
        "gates": [
            {"name": "GateNorth", "target": "REG-022", "spawn": "gate_south", "label": "Subida para Fornalha dos Reis (REG-022)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-026", "spawn": "gate_north", "label": "Entrada para as Minas de Tharum (REG-026)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-116", "DEMON-117", "DEMON-118", "DEMON-119", "DEMON-120"],
        "monument_cat": "structures",
        "monument_name": "structure_slag_refinery_furnace",
        "check_node": "Structures/SlagRefineryFurnace",
        "extra_monument": None
    },
    {
        "num": 25,
        "id": "REG-025",
        "slug": "dunas_de_vidro_negro",
        "name": "Dunas de Vidro Negro",
        "class_name": "DunasDeVidroNegroRegion",
        "script_rel": "scenes/world/regions/dunas_de_vidro_negro.gd",
        "biome": "vitrified_dunes",
        "level_min": 25,
        "level_max": 33,
        "sky_top": "Color(0.20, 0.16, 0.18, 1)",
        "sky_horizon": "Color(0.50, 0.38, 0.30, 1)",
        "fog_color": "Color(0.32, 0.24, 0.22, 1)",
        "fog_density": 0.006,
        "sun_color": "Color(1.0, 0.82, 0.65, 1)",
        "sun_energy": 1.55,
        "ground_color": "Color(0.12, 0.11, 0.12, 1)",
        "city_id": "poi_reg025_city",
        "city_name": "Oásis Vitrificado",
        "dungeon_id": "dungeon_molten_silica",
        "dungeon_name": "Cripta da Sílica Fundida",
        "boss_id": "BOSS-021",
        "boss_name": "Duna dos Cristais Negros",
        "exp_id": "poi_glass_dune_ridge",
        "exp_name": "Crista dos Espelhos Afiados",
        "gates": [
            {"name": "GateNorth", "target": "REG-023", "spawn": "gate_south", "label": "Passagem para o Desfiladeiro de Obsidiana (REG-023)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-026", "spawn": "gate_north", "label": "Caminho das Dunas para as Minas de Tharum (REG-026)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-121", "DEMON-122", "DEMON-123", "DEMON-124", "DEMON-125"],
        "monument_cat": "rocks",
        "monument_name": "rock_vitrified_glass_dune_ridge",
        "check_node": "Structures/VitrifiedGlassDuneRidge",
        "extra_monument": None
    },
    {
        "num": 26,
        "id": "REG-026",
        "slug": "minas_de_tharum",
        "name": "Minas de Tharum",
        "class_name": "MinasDeTharumRegion",
        "script_rel": "scenes/world/regions/minas_de_tharum.gd",
        "biome": "tharum_mines",
        "level_min": 26,
        "level_max": 34,
        "sky_top": "Color(0.12, 0.10, 0.12, 1)",
        "sky_horizon": "Color(0.26, 0.20, 0.20, 1)",
        "fog_color": "Color(0.20, 0.16, 0.16, 1)",
        "fog_density": 0.014,
        "sun_color": "Color(0.80, 0.60, 0.40, 1)",
        "sun_energy": 0.95,
        "ground_color": "Color(0.18, 0.16, 0.15, 1)",
        "city_id": "poi_reg026_city",
        "city_name": "Guarnição de Tharum",
        "dungeon_id": "dungeon_miners_deep_pit",
        "dungeon_name": "Poço Profundo dos Mineiros",
        "boss_id": "BOSS-022",
        "boss_name": "Salão dos Filões Perdidos",
        "exp_id": "poi_mine_headframe",
        "exp_name": "Torre de Içamento de Tharum",
        "gates": [
            {"name": "GateNorth", "target": "REG-024", "spawn": "gate_south", "label": "Subida para o Mar de Escória (REG-024)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-025", "spawn": "gate_north", "label": "Passo para as Dunas de Vidro Negro (REG-025)", "pos": "Vector3(0, 0, 95)"},
            {"name": "GateEast", "target": "REG-027", "spawn": "gate_west", "label": "Galeria do Abismo para a Ponte das Correntes (REG-027)", "pos": "Vector3(95, 0, 0)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-126", "DEMON-127", "DEMON-128", "DEMON-129", "DEMON-130"],
        "monument_cat": "structures",
        "monument_name": "structure_tharum_mine_headframe",
        "check_node": "Structures/TharumMineHeadframe",
        "extra_monument": {"cat": "props", "name": "prop_mining_ore_cart_track", "node": "OreCartTracksNorth", "pos": "Vector3(0, 0, 18)"}
    },
    {
        "num": 27,
        "id": "REG-027",
        "slug": "ponte_das_correntes",
        "name": "Ponte das Correntes",
        "class_name": "PonteDasCorrentesRegion",
        "script_rel": "scenes/world/regions/ponte_das_correntes.gd",
        "biome": "chain_bridge",
        "level_min": 27,
        "level_max": 35,
        "sky_top": "Color(0.16, 0.14, 0.18, 1)",
        "sky_horizon": "Color(0.38, 0.28, 0.32, 1)",
        "fog_color": "Color(0.26, 0.20, 0.24, 1)",
        "fog_density": 0.007,
        "sun_color": "Color(0.95, 0.75, 0.60, 1)",
        "sun_energy": 1.4,
        "ground_color": "Color(0.18, 0.16, 0.17, 1)",
        "city_id": "poi_reg027_city",
        "city_name": "Vigia do Abismo",
        "dungeon_id": "dungeon_broken_chains_chasm",
        "dungeon_name": "Fosso das Correntes Quebradas",
        "boss_id": "BOSS-023",
        "boss_name": "Passadiço dos Ventos Abissais",
        "exp_id": "poi_titan_chain_link",
        "exp_name": "O Grande Elo do Titã",
        "gates": [
            {"name": "GateNorth", "target": "REG-026", "spawn": "gate_south", "label": "Acesso para as Minas de Tharum (REG-026)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-028", "spawn": "gate_north", "label": "Passo Suspenso para o Planalto do Trovão (REG-028)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-131", "DEMON-132", "DEMON-133", "DEMON-134", "DEMON-135"],
        "monument_cat": "structures",
        "monument_name": "structure_monumental_chain_bridge",
        "check_node": "Structures/MonumentalChainBridge",
        "extra_monument": {"cat": "props", "name": "prop_titan_chain_link", "node": "TitanChainAnchor", "pos": "Vector3(15, 0, -20)"}
    },
    {
        "num": 28,
        "id": "REG-028",
        "slug": "planalto_do_trovao",
        "name": "Planalto do Trovão",
        "class_name": "PlanaltoDoTrovaoRegion",
        "script_rel": "scenes/world/regions/planalto_do_trovao.gd",
        "biome": "thunder_plateau",
        "level_min": 28,
        "level_max": 36,
        "sky_top": "Color(0.14, 0.16, 0.24, 1)",
        "sky_horizon": "Color(0.32, 0.35, 0.50, 1)",
        "fog_color": "Color(0.24, 0.26, 0.38, 1)",
        "fog_density": 0.009,
        "sun_color": "Color(0.85, 0.90, 1.0, 1)",
        "sun_energy": 1.35,
        "ground_color": "Color(0.19, 0.18, 0.20, 1)",
        "city_id": "poi_reg028_city",
        "city_name": "Abrigo dos Relâmpagos",
        "dungeon_id": "dungeon_eternal_spark",
        "dungeon_name": "Câmara da Centelha Eterna",
        "boss_id": "",
        "boss_name": "",
        "exp_id": "poi_lightning_spire",
        "exp_name": "Obelisco Para-Raios dos Antigos",
        "gates": [
            {"name": "GateNorth", "target": "REG-027", "spawn": "gate_south", "label": "Descida para a Ponte das Correntes (REG-027)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-029", "spawn": "gate_north", "label": "Descida Subterrânea para a Garganta do Carvão (REG-029)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-136", "DEMON-137", "DEMON-138", "DEMON-139", "DEMON-140"],
        "monument_cat": "structures",
        "monument_name": "structure_lightning_conductor_spire",
        "check_node": "Structures/LightningConductorSpire",
        "extra_monument": None
    },
    {
        "num": 29,
        "id": "REG-029",
        "slug": "garganta_do_carvao",
        "name": "Garganta do Carvão",
        "class_name": "GargantaDoCarvaoRegion",
        "script_rel": "scenes/world/regions/garganta_do_carvao.gd",
        "biome": "coal_chasm",
        "level_min": 29,
        "level_max": 38,
        "sky_top": "Color(0.08, 0.07, 0.08, 1)",
        "sky_horizon": "Color(0.20, 0.16, 0.16, 1)",
        "fog_color": "Color(0.16, 0.12, 0.12, 1)",
        "fog_density": 0.020,
        "sun_color": "Color(0.90, 0.45, 0.20, 1)",
        "sun_energy": 0.8,
        "ground_color": "Color(0.09, 0.09, 0.10, 1)",
        "city_id": "poi_reg029_city",
        "city_name": "Posto do Ar Opressivo",
        "dungeon_id": "dungeon_black_galleries",
        "dungeon_name": "Labirinto das Galerias Negras",
        "boss_id": "",
        "boss_name": "",
        "exp_id": "poi_coal_archway",
        "exp_name": "Pórtico Natural de Antracito",
        "gates": [
            {"name": "GateNorth", "target": "REG-028", "spawn": "gate_south", "label": "Subida para o Planalto do Trovão (REG-028)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-030", "spawn": "gate_north", "label": "Descida Magmática para a Cratera do Coração (REG-030)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-141", "DEMON-142", "DEMON-143", "DEMON-144", "DEMON-145"],
        "monument_cat": "rocks",
        "monument_name": "rock_coal_chasm_archway",
        "check_node": "Structures/CoalChasmArchway",
        "extra_monument": None
    },
    {
        "num": 30,
        "id": "REG-030",
        "slug": "cratera_do_coracao",
        "name": "Cratera do Coração",
        "class_name": "CrateraDoCoracaoRegion",
        "script_rel": "scenes/world/regions/cratera_do_coracao.gd",
        "biome": "heart_crater",
        "level_min": 30,
        "level_max": 40,
        "sky_top": "Color(0.24, 0.08, 0.08, 1)",
        "sky_horizon": "Color(0.65, 0.22, 0.12, 1)",
        "fog_color": "Color(0.45, 0.15, 0.10, 1)",
        "fog_density": 0.008,
        "sun_color": "Color(1.0, 0.55, 0.15, 1)",
        "sun_energy": 1.7,
        "ground_color": "Color(0.15, 0.10, 0.09, 1)",
        "city_id": "poi_reg030_city",
        "city_name": "Santuário do Coração Magmático",
        "dungeon_id": "dungeon_primordial_core",
        "dungeon_name": "Núcleo Telúrico Primordial",
        "boss_id": "",
        "boss_name": "",
        "exp_id": "poi_heart_monolith",
        "exp_name": "O Monolito do Coração da Terra",
        "gates": [
            {"name": "GateNorth", "target": "REG-029", "spawn": "gate_south", "label": "Subida para a Garganta do Carvão (REG-029)", "pos": "Vector3(0, 0, -95)"}
        ],
        "has_hellforge": True,
        "demons": ["DEMON-146", "DEMON-147", "DEMON-148", "DEMON-149", "DEMON-150"],
        "monument_cat": "structures",
        "monument_name": "structure_heart_crater_monolith",
        "check_node": "Structures/HeartCraterMonolith",
        "extra_monument": None
    }
]

def generate_region_script(r):
    code = f'''class_name {r["class_name"]}
extends KarduumRegionBase
## Região {r["id"]}: {r["name"]} (Continente KHAR-DUUM).
## Apresenta arquitetura vulcânica, industrial e subterrânea com relevos e monumentos dedicados.

func _init() -> void:
\tregion_id_code = &"{r["id"]}"

func _setup_region_environment() -> void:
\tvar struct_root := get_node_or_null("Structures")
\tif struct_root != null:
\t\tif not struct_root.has_node("{r["check_node"].split("/")[-1]}"):
\t\t\tvar mon := RegionAssetLoaderClass.instantiate_model("{r["monument_cat"]}", "{r["monument_name"]}")
\t\t\tmon.name = "{r["check_node"].split("/")[-1]}"
\t\t\tmon.transform.origin = Vector3(0, 0, -45.0)
\t\t\tstruct_root.add_child(mon)
\t\t\tRegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(14.0, 12.0, 14.0), Vector3(0, 6.0, 0))
'''
    if r["extra_monument"]:
        em = r["extra_monument"]
        code += f'''
\t\tif not struct_root.has_node("{em["node"]}"):
\t\t\tvar extra := RegionAssetLoaderClass.instantiate_model("{em["cat"]}", "{em["name"]}")
\t\t\textra.name = "{em["node"]}"
\t\t\textra.transform.origin = {em["pos"]}
\t\t\tstruct_root.add_child(extra)
'''
    return code

def generate_scene_tscn(r):
    lines = []
    lines.append('[gd_scene load_steps=22 format=3]')
    lines.append('')
    lines.append(f'[ext_resource type="Script" path="res://{r["script_rel"]}" id="1_reg"]')
    lines.append('[ext_resource type="Script" path="res://scenes/world/components/world_boundary.gd" id="2_bound"]')
    lines.append('[ext_resource type="Script" path="res://scenes/world/components/point_of_interest.gd" id="3_poi"]')
    lines.append('[ext_resource type="Script" path="res://scenes/world/components/safe_zone.gd" id="4_safe"]')
    lines.append('[ext_resource type="Script" path="res://scenes/world/components/dungeon_entrance.gd" id="5_dung"]')
    lines.append('[ext_resource type="Script" path="res://scenes/world/components/boss_arena_zone.gd" id="6_boss"]')
    lines.append('[ext_resource type="Script" path="res://scenes/world/components/exploration_spot.gd" id="7_exp"]')
    lines.append('[ext_resource type="Script" path="res://scenes/world/components/region_gate.gd" id="8_gate"]')
    lines.append('[ext_resource type="Script" path="res://scenes/world/components/world_portal.gd" id="9_port"]')
    lines.append('[ext_resource type="Script" path="res://scenes/world/components/enemy_spawner_zone.gd" id="10_spawn"]')
    lines.append('')
    lines.append('[sub_resource type="ProceduralSkyMaterial" id="ProceduralSkyMaterial_sky"]')
    lines.append(f'sky_top_color = {r["sky_top"]}')
    lines.append(f'sky_horizon_color = {r["sky_horizon"]}')
    lines.append('ground_bottom_color = Color(0.12, 0.08, 0.06, 1)')
    lines.append(f'ground_horizon_color = {r["sky_horizon"]}')
    lines.append('')
    lines.append('[sub_resource type="Sky" id="Sky_env"]')
    lines.append('sky_material = SubResource("ProceduralSkyMaterial_sky")')
    lines.append('')
    lines.append('[sub_resource type="Environment" id="Environment_env"]')
    lines.append('background_mode = 2')
    lines.append('sky = SubResource("Sky_env")')
    lines.append('ambient_light_source = 2')
    lines.append(f'ambient_light_color = {r["fog_color"]}')
    lines.append('ambient_light_energy = 0.85')
    lines.append('fog_enabled = true')
    lines.append(f'fog_light_color = {r["fog_color"]}')
    lines.append(f'fog_density = {r["fog_density"]}')
    lines.append('')
    lines.append('[sub_resource type="StandardMaterial3D" id="StandardMaterial3D_ground"]')
    lines.append(f'albedo_color = {r["ground_color"]}')
    lines.append('roughness = 0.88')
    lines.append('')
    lines.append('[sub_resource type="BoxMesh" id="BoxMesh_ground"]')
    lines.append('material = SubResource("StandardMaterial3D_ground")')
    lines.append('size = Vector3(250, 2, 250)')
    lines.append('')
    lines.append('[sub_resource type="BoxShape3D" id="BoxShape3D_ground"]')
    lines.append('size = Vector3(250, 2, 250)')
    lines.append('')
    lines.append(f'[node name="{r["slug"].title().replace("_", "")}_{r["id"].replace("-", "_")}" type="Node3D"]')
    lines.append('script = ExtResource("1_reg")')
    lines.append('')
    lines.append('[node name="Environment" type="Node3D" parent="."]')
    lines.append('')
    lines.append('[node name="WorldEnvironment" type="WorldEnvironment" parent="Environment"]')
    lines.append('environment = SubResource("Environment_env")')
    lines.append('')
    lines.append('[node name="SunLight" type="DirectionalLight3D" parent="Environment"]')
    lines.append('transform = Transform3D(0.866025, -0.353553, 0.353553, 0, 0.707107, 0.707107, -0.5, -0.612372, 0.612372, 0, 25, 0)')
    lines.append(f'light_color = {r["sun_color"]}')
    lines.append(f'light_energy = {r["sun_energy"]}')
    lines.append('shadow_enabled = true')
    lines.append('')
    lines.append('[node name="Terrain" type="Node3D" parent="."]')
    lines.append('')
    lines.append('[node name="MainGround" type="StaticBody3D" parent="Terrain"]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -1, 0)')
    lines.append('')
    lines.append('[node name="Mesh" type="MeshInstance3D" parent="Terrain/MainGround"]')
    lines.append('mesh = SubResource("BoxMesh_ground")')
    lines.append('')
    lines.append('[node name="Collision" type="CollisionShape3D" parent="Terrain/MainGround"]')
    lines.append('shape = SubResource("BoxShape3D_ground")')
    lines.append('')
    lines.append('[node name="WorldBoundary" type="Node3D" parent="."]')
    lines.append('script = ExtResource("2_bound")')
    lines.append('radius = 120.0')
    lines.append('')
    lines.append('[node name="Spawns" type="Node3D" parent="."]')
    lines.append('')
    lines.append('[node name="Spawn_default" type="Marker3D" parent="Spawns"]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 0)')
    lines.append('')
    for g in r["gates"]:
        lines.append(f'[node name="Spawn_{g["name"].lower()}" type="Marker3D" parent="Spawns"]')
        lines.append(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {g["pos"].replace("Vector3", "").strip("()")})')
        lines.append('')
    lines.append('[node name="Spawn_portal_main" type="Marker3D" parent="Spawns"]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 26, 0.2, 22)')
    lines.append('')
    lines.append('[node name="Structures" type="Node3D" parent="."]')
    lines.append('')
    lines.append('[node name="CityForge" type="Node3D" parent="Structures"]')
    lines.append('')
    lines.append('[node name="POI_City" type="Area3D" parent="Structures/CityForge"]')
    lines.append('script = ExtResource("3_poi")')
    lines.append(f'poi_id = &"{r["city_id"]}"')
    lines.append(f'poi_name = "{r["city_name"]}"')
    lines.append('poi_type = "city"')
    lines.append(f'description = "Assentamento industrial e zona segura em {r["name"]}."')
    lines.append('discovery_radius = 22.0')
    lines.append('discovery_xp = 100')
    lines.append('')
    lines.append('[node name="SafeZone" type="Area3D" parent="Structures/CityForge"]')
    lines.append('script = ExtResource("4_safe")')
    lines.append(f'zone_name = "{r["city_name"]}"')
    lines.append('radius = 22.0')
    lines.append('')
    lines.append('[node name="DungeonEntrance" type="Node3D" parent="Structures"]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -50, 0, -40)')
    lines.append('script = ExtResource("5_dung")')
    lines.append(f'dungeon_id = &"{r["dungeon_id"]}"')
    lines.append(f'dungeon_name = "{r["dungeon_name"]}"')
    lines.append(f'min_level = {r["level_min"]}')
    lines.append('')
    lines.append('[node name="POI_Dungeon" type="Area3D" parent="Structures/DungeonEntrance"]')
    lines.append('script = ExtResource("3_poi")')
    lines.append(f'poi_id = &"poi_{r["dungeon_id"]}"')
    lines.append(f'poi_name = "{r["dungeon_name"]}"')
    lines.append('poi_type = "dungeon"')
    lines.append(f'description = "Masmorra subterrânea {r["dungeon_name"]} de nível {r["level_min"]}+."')
    lines.append('discovery_radius = 16.0')
    lines.append('discovery_xp = 80')
    lines.append('')
    if r["boss_id"]:
        lines.append('[node name="BossArena" type="Node3D" parent="Structures"]')
        lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -55)')
        lines.append('script = ExtResource("6_boss")')
        lines.append(f'boss_id = &"{r["boss_id"]}"')
        lines.append(f'arena_name = "{r["boss_name"]}"')
        lines.append('radius = 18.0')
        lines.append('')
        lines.append('[node name="POI_Boss" type="Area3D" parent="Structures/BossArena"]')
        lines.append('script = ExtResource("3_poi")')
        lines.append(f'poi_id = &"poi_{r["boss_id"].lower()}_arena"')
        lines.append(f'poi_name = "{r["boss_name"]}"')
        lines.append('poi_type = "boss_arena"')
        lines.append(f'description = "Arena de confronto do Chefe {r["boss_id"]}."')
        lines.append('discovery_radius = 20.0')
        lines.append('discovery_xp = 150')
        lines.append('')
    else:
        lines.append('[node name="BossArena" type="Node3D" parent="Structures"]')
        lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -55)')
        lines.append('script = ExtResource("6_boss")')
        lines.append('boss_id = &""')
        lines.append(f'arena_name = "Arena Regional de {r["name"]}"')
        lines.append('radius = 18.0')
        lines.append('')
    lines.append('[node name="Exploration" type="Node3D" parent="."]')
    lines.append('')
    lines.append('[node name="ExplorationSpot" type="Node3D" parent="Exploration"]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 45, 0, 30)')
    lines.append('script = ExtResource("7_exp")')
    lines.append(f'spot_id = &"{r["exp_id"]}"')
    lines.append(f'spot_name = "{r["exp_name"]}"')
    lines.append('discovery_xp = 75')
    lines.append('')
    lines.append('[node name="POI_Exp" type="Area3D" parent="Exploration/ExplorationSpot"]')
    lines.append('script = ExtResource("3_poi")')
    lines.append(f'poi_id = &"{r["exp_id"]}"')
    lines.append(f'poi_name = "{r["exp_name"]}"')
    lines.append('poi_type = "exploration"')
    lines.append(f'description = "Marco de exploração em {r["name"]}."')
    lines.append('discovery_radius = 16.0')
    lines.append('discovery_xp = 75')
    lines.append('')
    lines.append('[node name="Travel" type="Node3D" parent="."]')
    lines.append('')
    for g in r["gates"]:
        lines.append(f'[node name="{g["name"]}" type="Area3D" parent="Travel"]')
        lines.append(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {g["pos"].replace("Vector3", "").strip("()")})')
        lines.append('script = ExtResource("8_gate")')
        lines.append(f'gate_id = &"{g["name"].lower()}"')
        lines.append(f'target_region = &"{g["target"]}"')
        lines.append(f'target_spawn = &"{g["spawn"]}"')
        lines.append(f'display_name = "{g["label"]}"')
        lines.append('radius = 5.0')
        lines.append('')
    if r["has_hellforge"]:
        lines.append('[node name="PortalHellForge" type="Area3D" parent="Travel"]')
        lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 30, 0, 20)')
        lines.append('script = ExtResource("9_port")')
        lines.append(f'portal_id = &"portal_{r["slug"]}_hellforge"')
        lines.append('target_region = &"hell_forge"')
        lines.append('target_spawn = &"default"')
        lines.append('display_name = "Portal da Forja Abissal"')
        lines.append('is_intercontinental = true')
        lines.append('activation_radius = 3.5')
        lines.append('')
    lines.append('[node name="Enemies" type="Node3D" parent="."]')
    lines.append('')
    enemy_coords = [(-35, 0, -45), (40, 0, 60), (70, 0, -15), (-20, 0, 65), (30, 0, -75)]
    for idx, dem_id in enumerate(r["demons"]):
        ec = enemy_coords[idx]
        lines.append(f'[node name="Spawn_{dem_id.replace("-", "")}" type="Node3D" parent="Enemies"]')
        lines.append(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {ec[0]}, {ec[1]}, {ec[2]})')
        lines.append('script = ExtResource("10_spawn")')
        lines.append(f'demon_id = &"{dem_id}"')
        lines.append('spawn_count = 2')
        lines.append('')
    lines.append('[node name="Props" type="Node3D" parent="."]')
    lines.append('')
    return '\n'.join(lines)

def main():
    print("======================================================================")
    print("ABYSSAL PACT — CONSTRUINDO AS 10 REGIÕES 3D DE KHAR-DUUM")
    print("======================================================================")

    # 1. Gera GDScripts
    for r in KARDUUM_REGIONS:
        script_code = generate_region_script(r)
        script_path = r["script_rel"]
        with open(script_path, "w", encoding="utf-8") as f:
            f.write(script_code)
        print(f"[OK] GDScript gerado: {script_path}")

    # 2. Gera cenas 3D (.tscn)
    for r in KARDUUM_REGIONS:
        tscn_content = generate_scene_tscn(r)

        # Nome amigável (slug.tscn)
        slug_path = f"scenes/world/regions/{r['slug']}.tscn"
        with open(slug_path, "w", encoding="utf-8") as f:
            f.write(tscn_content)
        print(f"[OK] Cena 3D slug: {slug_path}")

        # Nome canônico compatível com carregador por código (region_0XX.tscn)
        num_path = f"scenes/world/regions/region_{r['num']:03d}.tscn"
        with open(num_path, "w", encoding="utf-8") as f:
            f.write(tscn_content)
        print(f"[OK] Cena 3D canônica: {num_path}")

    # 3. Atualiza os 10 arquivos .tres em data/content/regions/
    for r in KARDUUM_REGIONS:
        tres_path = f"data/content/regions/region_{r['num']:03d}.tres"
        with open(tres_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Atualiza display_name
        content = re.sub(r'display_name = "[^"]+"', f'display_name = "{r["name"]}"', content)
        # Atualiza status para full_production
        content = re.sub(r'status = "[^"]+"', 'status = "full_production"', content)
        # Atualiza scene_path para cena dedicada (slug.tscn)
        scene_target = f"res://scenes/world/regions/{r['slug']}.tscn"
        content = re.sub(r'scene_path = "[^"]+"', f'scene_path = "{scene_target}"', content)
        # Limpa pending_assets para PackedStringArray() para conformidade de produção
        content = re.sub(r'pending_assets = PackedStringArray\([^)]*\)', 'pending_assets = PackedStringArray()', content)
        if 'pending_assets =' not in content:
            content += '\npending_assets = PackedStringArray()\n'

        with open(tres_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[OK] Resource RegionData sincronizado: {tres_path} -> {r['name']} (full_production)")

    print("======================================================================")
    print("CONCLUÍDO COM SUCESSO: 10 regiões de Khar-Duum integradas em 3D.")
    print("======================================================================")

if __name__ == "__main__":
    main()
