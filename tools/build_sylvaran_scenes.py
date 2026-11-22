"""
ABYSSAL PACT — Construtor e Integrador das 10 Regiões 3D de Sylvaran
Gera:
1. Os 10 GDScripts dedicados em scenes/world/regions/
2. As 10 cenas 3D (.tscn) em scenes/world/regions/ (e seus aliases region_0XX.tscn)
3. Atualiza os 10 Resources RegionData em data/content/regions/ (region_011.tres..region_020.tres)
"""

import os
import re

SYLVARAN_REGIONS = [
    {
        "num": 11,
        "id": "REG-011",
        "slug": "raiz_antiga",
        "name": "Raiz Antiga",
        "class_name": "RaizAntigaRegion",
        "script_rel": "scenes/world/regions/raiz_antiga.gd",
        "biome": "whispering_woods",
        "level_min": 1,
        "level_max": 6,
        "sky_top": "Color(0.10, 0.18, 0.14, 1)",
        "sky_horizon": "Color(0.20, 0.40, 0.28, 1)",
        "fog_color": "Color(0.12, 0.26, 0.18, 1)",
        "fog_density": 0.012,
        "sun_color": "Color(0.70, 0.95, 0.75, 1)",
        "sun_energy": 1.1,
        "ground_color": "Color(0.14, 0.22, 0.12, 1)",
        "city_id": "poi_reg011_city",
        "city_name": "Refúgio da Seiva",
        "dungeon_id": "dungeon_ancient_roots",
        "dungeon_name": "Catacumbas das Raízes",
        "boss_id": "BOSS-009",
        "boss_name": "Santuário das Raízes Ancestrais",
        "exp_id": "poi_colossal_tree",
        "exp_name": "O Tronco Ancestral",
        "gates": [
            {"name": "GateNorth", "target": "REG-012", "spawn": "gate_south", "label": "Trilha para o Pântano das Lanternas (REG-012)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-013", "spawn": "gate_north", "label": "Ascensão para a Copa Celeste (REG-013)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": True,
        "demons": ["DEMON-051", "DEMON-052", "DEMON-053", "DEMON-054", "DEMON-055"],
        "monument_cat": "nature",
        "monument_name": "nature_colossal_tree_ancient",
        "check_node": "Structures/ColossalTreeAncient",
        "extra_monument": {"cat": "nature", "name": "nature_monumental_roots_arch", "node": "RootsArchway", "pos": "Vector3(0, 0, 15)"}
    },
    {
        "num": 12,
        "id": "REG-012",
        "slug": "pantano_das_lanternas",
        "name": "Pântano das Lanternas",
        "class_name": "PantanoDasLanternasRegion",
        "script_rel": "scenes/world/regions/pantano_das_lanternas.gd",
        "biome": "thorn_marsh",
        "level_min": 4,
        "level_max": 8,
        "sky_top": "Color(0.08, 0.15, 0.18, 1)",
        "sky_horizon": "Color(0.15, 0.35, 0.32, 1)",
        "fog_color": "Color(0.10, 0.25, 0.24, 1)",
        "fog_density": 0.016,
        "sun_color": "Color(0.55, 0.90, 0.85, 1)",
        "sun_energy": 0.95,
        "ground_color": "Color(0.10, 0.16, 0.14, 1)",
        "city_id": "poi_reg012_city",
        "city_name": "Acampamento dos Vagalumes",
        "dungeon_id": "dungeon_drowned_gallery",
        "dungeon_name": "Galeria dos Afogados",
        "boss_id": "BOSS-010",
        "boss_name": "Lodaçal das Lanternas Espectrais",
        "exp_id": "poi_lantern_grove",
        "exp_name": "Bosque das Lanternas Vivas",
        "gates": [
            {"name": "GateNorth", "target": "REG-011", "spawn": "gate_south", "label": "Retorno para Raiz Antiga (REG-011)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-014", "spawn": "gate_north", "label": "Caminho d'Água para o Jardim Afogado (REG-014)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-056", "DEMON-057", "DEMON-058", "DEMON-059", "DEMON-060"],
        "monument_cat": "nature",
        "monument_name": "nature_bioluminescent_lantern_plant",
        "check_node": "Structures/LanternPlantCluster",
        "extra_monument": {"cat": "props", "name": "prop_swamp_lantern_post", "node": "SwampLanternPost", "pos": "Vector3(8, 0, -10)"}
    },
    {
        "num": 13,
        "id": "REG-013",
        "slug": "copa_celeste",
        "name": "Copa Celeste",
        "class_name": "CopaCelesteRegion",
        "script_rel": "scenes/world/regions/copa_celeste.gd",
        "biome": "ancient_canopy",
        "level_min": 6,
        "level_max": 10,
        "sky_top": "Color(0.12, 0.28, 0.35, 1)",
        "sky_horizon": "Color(0.35, 0.60, 0.45, 1)",
        "fog_color": "Color(0.22, 0.42, 0.35, 1)",
        "fog_density": 0.006,
        "sun_color": "Color(0.95, 0.92, 0.70, 1)",
        "sun_energy": 1.45,
        "ground_color": "Color(0.22, 0.18, 0.14, 1)",
        "city_id": "poi_reg013_city",
        "city_name": "Aldeia das Alturas",
        "dungeon_id": "dungeon_iron_leaf_crypt",
        "dungeon_name": "Cripta das Folhas de Ferro",
        "boss_id": "BOSS-011",
        "boss_name": "Dossel dos Ventos Celestes",
        "exp_id": "poi_canopy_lookout",
        "exp_name": "Mirante da Grande Copa",
        "gates": [
            {"name": "GateNorth", "target": "REG-011", "spawn": "gate_south", "label": "Descida para Raiz Antiga (REG-011)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-015", "spawn": "gate_north", "label": "Pontes Aéreas para o Arquipélago Suspenso (REG-015)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-061", "DEMON-062", "DEMON-063", "DEMON-064", "DEMON-065"],
        "monument_cat": "nature",
        "monument_name": "nature_canopy_platform_branch",
        "check_node": "Structures/CanopyPlatformBranch",
        "extra_monument": {"cat": "nature", "name": "nature_vine_suspension_bridge", "node": "VineBridgeWalkway", "pos": "Vector3(0, 3.5, 20)"}
    },
    {
        "num": 14,
        "id": "REG-014",
        "slug": "jardim_afogado",
        "name": "Jardim Afogado",
        "class_name": "JardimAfogadoRegion",
        "script_rel": "scenes/world/regions/jardim_afogado.gd",
        "biome": "spectral_glade",
        "level_min": 8,
        "level_max": 13,
        "sky_top": "Color(0.10, 0.22, 0.26, 1)",
        "sky_horizon": "Color(0.25, 0.48, 0.50, 1)",
        "fog_color": "Color(0.16, 0.35, 0.38, 1)",
        "fog_density": 0.010,
        "sun_color": "Color(0.65, 0.90, 0.95, 1)",
        "sun_energy": 1.25,
        "ground_color": "Color(0.15, 0.25, 0.25, 1)",
        "city_id": "poi_reg014_city",
        "city_name": "Posto do Lótus Pálido",
        "dungeon_id": "dungeon_submerged_fountains",
        "dungeon_name": "Salão das Fontes Submersas",
        "boss_id": "BOSS-012",
        "boss_name": "Espelho d'Água Submerso",
        "exp_id": "poi_drowned_pavilion",
        "exp_name": "Pavilhão do Lótus de Mármore",
        "gates": [
            {"name": "GateNorth", "target": "REG-012", "spawn": "gate_south", "label": "Passo para o Pântano das Lanternas (REG-012)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-016", "spawn": "gate_north", "label": "Trilha Floral para o Vale das Mariposas (REG-016)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-066", "DEMON-067", "DEMON-068", "DEMON-069", "DEMON-070"],
        "monument_cat": "structures",
        "monument_name": "structure_drowned_garden_pavilion",
        "check_node": "Structures/DrownedGardenPavilion",
        "extra_monument": None
    },
    {
        "num": 15,
        "id": "REG-015",
        "slug": "arquipelago_suspenso",
        "name": "Arquipélago Suspenso",
        "class_name": "ArquipelagoSuspensoRegion",
        "script_rel": "scenes/world/regions/arquipelago_suspenso.gd",
        "biome": "abyssal_roots",
        "level_min": 11,
        "level_max": 16,
        "sky_top": "Color(0.15, 0.22, 0.35, 1)",
        "sky_horizon": "Color(0.32, 0.52, 0.55, 1)",
        "fog_color": "Color(0.20, 0.38, 0.45, 1)",
        "fog_density": 0.005,
        "sun_color": "Color(0.85, 0.95, 0.90, 1)",
        "sun_energy": 1.5,
        "ground_color": "Color(0.18, 0.28, 0.18, 1)",
        "city_id": "poi_reg015_city",
        "city_name": "Enclave Flutuante",
        "dungeon_id": "dungeon_lost_gravity",
        "dungeon_name": "Câmara da Gravidade Perdida",
        "boss_id": "BOSS-013",
        "boss_name": "Plataforma dos Ventos Abissais",
        "exp_id": "poi_floating_keystone",
        "exp_name": "Ilha do Cristal de Sustentação",
        "gates": [
            {"name": "GateNorth", "target": "REG-013", "spawn": "gate_south", "label": "Passarela para Copa Celeste (REG-013)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-016", "spawn": "gate_north", "label": "Descida Aérea para o Vale das Mariposas (REG-016)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-071", "DEMON-072", "DEMON-073", "DEMON-074", "DEMON-075"],
        "monument_cat": "rocks",
        "monument_name": "rock_floating_island_chunk",
        "check_node": "Structures/FloatingIslandChunk",
        "extra_monument": {"cat": "nature", "name": "nature_vine_suspension_bridge", "node": "AerialVineBridge", "pos": "Vector3(0, 2.5, 10)"}
    },
    {
        "num": 16,
        "id": "REG-016",
        "slug": "vale_das_mariposas",
        "name": "Vale das Mariposas",
        "class_name": "ValeDasMariposasRegion",
        "script_rel": "scenes/world/regions/vale_das_mariposas.gd",
        "biome": "fungal_hollow",
        "level_min": 14,
        "level_max": 18,
        "sky_top": "Color(0.18, 0.12, 0.25, 1)",
        "sky_horizon": "Color(0.42, 0.28, 0.50, 1)",
        "fog_color": "Color(0.30, 0.20, 0.38, 1)",
        "fog_density": 0.009,
        "sun_color": "Color(0.92, 0.70, 0.95, 1)",
        "sun_energy": 1.2,
        "ground_color": "Color(0.18, 0.16, 0.22, 1)",
        "city_id": "poi_reg016_city",
        "city_name": "Vila da Seda Mística",
        "dungeon_id": "dungeon_ravenous_nest",
        "dungeon_name": "Ninho das Larvas Vorazes",
        "boss_id": "BOSS-014",
        "boss_name": "Prado das Asas Efêmeras",
        "exp_id": "poi_chrysalis_shrine",
        "exp_name": "Altar da Crisálida de Mana",
        "gates": [
            {"name": "GateNorth", "target": "REG-014", "spawn": "gate_south", "label": "Subida para o Jardim Afogado (REG-014)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-015", "spawn": "gate_north", "label": "Acesso para o Arquipélago Suspenso (REG-015)", "pos": "Vector3(0, 0, 95)"},
            {"name": "GateEast", "target": "REG-017", "spawn": "gate_west", "label": "Passo Montanhoso para a Espinha Verde (REG-017)", "pos": "Vector3(95, 0, 0)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-076", "DEMON-077", "DEMON-078", "DEMON-079", "DEMON-080"],
        "monument_cat": "props",
        "monument_name": "prop_butterfly_mana_shrine",
        "check_node": "Structures/ButterflyManaShrine",
        "extra_monument": {"cat": "nature", "name": "nature_bioluminescent_lantern_plant", "node": "ManaFlowerGrove", "pos": "Vector3(-15, 0, -40)"}
    },
    {
        "num": 17,
        "id": "REG-017",
        "slug": "espinha_verde",
        "name": "Espinha Verde",
        "class_name": "EspinhaVerdeRegion",
        "script_rel": "scenes/world/regions/espinha_verde.gd",
        "biome": "petrified_grove",
        "level_min": 17,
        "level_max": 21,
        "sky_top": "Color(0.12, 0.18, 0.20, 1)",
        "sky_horizon": "Color(0.28, 0.45, 0.36, 1)",
        "fog_color": "Color(0.20, 0.32, 0.28, 1)",
        "fog_density": 0.008,
        "sun_color": "Color(0.85, 0.98, 0.80, 1)",
        "sun_energy": 1.4,
        "ground_color": "Color(0.20, 0.22, 0.18, 1)",
        "city_id": "poi_reg017_city",
        "city_name": "Fortaleza da Crista Verde",
        "dungeon_id": "dungeon_primal_emerald_mines",
        "dungeon_name": "Minas de Esmeralda Primitiva",
        "boss_id": "BOSS-015",
        "boss_name": "Pico dos Cristais Esmeralda",
        "exp_id": "poi_emerald_crag",
        "exp_name": "Rochedo dos Cristais Ressonantes",
        "gates": [
            {"name": "GateNorth", "target": "REG-016", "spawn": "gate_south", "label": "Descida para o Vale das Mariposas (REG-016)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-018", "spawn": "gate_north", "label": "Desfiladeiro para o Ninho das Brumas (REG-018)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-081", "DEMON-082", "DEMON-083", "DEMON-084", "DEMON-085"],
        "monument_cat": "rocks",
        "monument_name": "rock_sylvaran_emerald_crystal",
        "check_node": "Structures/EmeraldCrystalCrag",
        "extra_monument": None
    },
    {
        "num": 18,
        "id": "REG-018",
        "slug": "ninho_das_brumas",
        "name": "Ninho das Brumas",
        "class_name": "NinhoDasBrumasRegion",
        "script_rel": "scenes/world/regions/ninho_das_brumas.gd",
        "biome": "black_marsh",
        "level_min": 19,
        "level_max": 23,
        "sky_top": "Color(0.12, 0.14, 0.16, 1)",
        "sky_horizon": "Color(0.25, 0.30, 0.32, 1)",
        "fog_color": "Color(0.22, 0.28, 0.30, 1)",
        "fog_density": 0.022,
        "sun_color": "Color(0.60, 0.75, 0.80, 1)",
        "sun_energy": 0.85,
        "ground_color": "Color(0.12, 0.14, 0.12, 1)",
        "city_id": "poi_reg018_city",
        "city_name": "Vigília do Véu Enevoado",
        "dungeon_id": "dungeon_thick_shadow_pit",
        "dungeon_name": "Poço das Sombras Espessas",
        "boss_id": "BOSS-016",
        "boss_name": "Torre das Brumas Eternas",
        "exp_id": "poi_mist_spire",
        "exp_name": "Agulha das Brumas Vigilantes",
        "gates": [
            {"name": "GateNorth", "target": "REG-017", "spawn": "gate_south", "label": "Subida para a Espinha Verde (REG-017)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-019", "spawn": "gate_north", "label": "Passo Obscuro para as Ruínas de Lyth (REG-019)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-086", "DEMON-087", "DEMON-088", "DEMON-089", "DEMON-090"],
        "monument_cat": "structures",
        "monument_name": "structure_mist_nest_spire",
        "check_node": "Structures/MistNestSpire",
        "extra_monument": {"cat": "props", "name": "prop_swamp_lantern_post", "node": "MistSentinelPost", "pos": "Vector3(-12, 0, -30)"}
    },
    {
        "num": 19,
        "id": "REG-019",
        "slug": "ruinas_de_lyth",
        "name": "Ruínas de Lyth",
        "class_name": "RuinasDeLythRegion",
        "script_rel": "scenes/world/regions/ruinas_de_lyth.gd",
        "biome": "twilight_canopy",
        "level_min": 22,
        "level_max": 26,
        "sky_top": "Color(0.14, 0.12, 0.22, 1)",
        "sky_horizon": "Color(0.32, 0.26, 0.42, 1)",
        "fog_color": "Color(0.24, 0.20, 0.32, 1)",
        "fog_density": 0.010,
        "sun_color": "Color(0.85, 0.78, 0.90, 1)",
        "sun_energy": 1.15,
        "ground_color": "Color(0.24, 0.22, 0.24, 1)",
        "city_id": "poi_reg019_city",
        "city_name": "Acampamento dos Arqueólogos de Lyth",
        "dungeon_id": "dungeon_lyth_forgotten_halls",
        "dungeon_name": "Salões Esquecidos da Dinastia Lyth",
        "boss_id": "",
        "boss_name": "",
        "exp_id": "poi_lyth_ruins",
        "exp_name": "Portal Ogival da Cidade Ancestral",
        "gates": [
            {"name": "GateNorth", "target": "REG-018", "spawn": "gate_south", "label": "Passo das Brumas para o Ninho das Brumas (REG-018)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-020", "spawn": "gate_north", "label": "Avenida Sagrada para Fonte do Primeiro Broto (REG-020)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-091", "DEMON-092", "DEMON-093", "DEMON-094", "DEMON-095"],
        "monument_cat": "structures",
        "monument_name": "structure_lyth_ancient_ruin",
        "check_node": "Structures/LythAncientRuin",
        "extra_monument": None
    },
    {
        "num": 20,
        "id": "REG-020",
        "slug": "fonte_do_primeiro_broto",
        "name": "Fonte do Primeiro Broto",
        "class_name": "FonteDoPrimeiroBrotoRegion",
        "script_rel": "scenes/world/regions/fonte_do_primeiro_broto.gd",
        "biome": "heart_of_black_sap",
        "level_min": 25,
        "level_max": 30,
        "sky_top": "Color(0.10, 0.24, 0.18, 1)",
        "sky_horizon": "Color(0.28, 0.55, 0.35, 1)",
        "fog_color": "Color(0.18, 0.40, 0.28, 1)",
        "fog_density": 0.007,
        "sun_color": "Color(0.95, 0.98, 0.65, 1)",
        "sun_energy": 1.6,
        "ground_color": "Color(0.16, 0.28, 0.15, 1)",
        "city_id": "poi_reg020_city",
        "city_name": "Santuário dos Guardiões da Vida",
        "dungeon_id": "dungeon_first_sprout_core",
        "dungeon_name": "Coração Telúrico do Broto",
        "boss_id": "",
        "boss_name": "",
        "exp_id": "poi_first_sprout_monument",
        "exp_name": "O Monumento do Primeiro Broto",
        "gates": [
            {"name": "GateNorth", "target": "REG-019", "spawn": "gate_south", "label": "Caminho Ancestral para Ruínas de Lyth (REG-019)", "pos": "Vector3(0, 0, -95)"}
        ],
        "has_hellforge": True,
        "demons": ["DEMON-096", "DEMON-097", "DEMON-098", "DEMON-099", "DEMON-100"],
        "monument_cat": "structures",
        "monument_name": "structure_first_sprout_monument",
        "check_node": "Structures/FirstSproutMonument",
        "extra_monument": {"cat": "rocks", "name": "rock_sylvaran_emerald_crystal", "node": "SanctuaryCrystalWest", "pos": "Vector3(-22, 0, -35)"}
    }
]

def generate_region_script(r):
    code = f'''class_name {r["class_name"]}
extends SylvaranRegionBase
## Região {r["id"]}: {r["name"]} (Continente SYLVARAN).
## Apresenta arquitetura de natureza ancestral com relevos e monumentos dedicados.

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
\t\t\tRegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(12.0, 10.0, 12.0), Vector3(0, 5.0, 0))
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
    lines.append('ground_bottom_color = Color(0.08, 0.12, 0.08, 1)')
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
    lines.append('roughness = 0.85')
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
    lines.append('[node name="CitySanctuary" type="Node3D" parent="Structures"]')
    lines.append('')
    lines.append('[node name="POI_City" type="Area3D" parent="Structures/CitySanctuary"]')
    lines.append('script = ExtResource("3_poi")')
    lines.append(f'poi_id = &"{r["city_id"]}"')
    lines.append(f'poi_name = "{r["city_name"]}"')
    lines.append('poi_type = "city"')
    lines.append(f'description = "Assentamento ancestral e zona segura em {r["name"]}."')
    lines.append('discovery_radius = 22.0')
    lines.append('discovery_xp = 100')
    lines.append('')
    lines.append('[node name="SafeZone" type="Area3D" parent="Structures/CitySanctuary"]')
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
    lines.append(f'description = "Masmorra ancestral {r["dungeon_name"]} de nível {r["level_min"]}+."')
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
    print("ABYSSAL PACT — CONSTRUINDO AS 10 REGIÕES 3D DE SYLVARAN")
    print("======================================================================")

    # 1. Gera GDScripts
    for r in SYLVARAN_REGIONS:
        script_code = generate_region_script(r)
        script_path = r["script_rel"]
        with open(script_path, "w", encoding="utf-8") as f:
            f.write(script_code)
        print(f"[OK] GDScript gerado: {script_path}")

    # 2. Gera cenas 3D (.tscn)
    for r in SYLVARAN_REGIONS:
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
    for r in SYLVARAN_REGIONS:
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
    print("CONCLUÍDO COM SUCESSO: 10 regiões de Sylvaran integradas em 3D.")
    print("======================================================================")

if __name__ == "__main__":
    main()
