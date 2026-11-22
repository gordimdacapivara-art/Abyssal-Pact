"""
ABYSSAL PACT — Construtor e Integrador das 10 Regiões 3D de Nhal'Kora
Gera:
1. Os 10 GDScripts dedicados em scenes/world/regions/
2. As 10 cenas 3D (.tscn) em scenes/world/regions/ (e seus aliases region_0XX.tscn)
3. Atualiza os 10 Resources RegionData em data/content/regions/ (region_031.tres..region_040.tres)
"""

import os
import re

NHALKORA_REGIONS = [
    {
        "num": 31,
        "id": "REG-031",
        "slug": "geleira_dos_ecos",
        "name": "Geleira dos Ecos",
        "class_name": "GeleiraDosEcosRegion",
        "script_rel": "scenes/world/regions/geleira_dos_ecos.gd",
        "biome": "glacial_echoes",
        "level_min": 35,
        "level_max": 45,
        "sky_top": "Color(0.10, 0.16, 0.28, 1)",
        "sky_horizon": "Color(0.25, 0.42, 0.60, 1)",
        "fog_color": "Color(0.18, 0.32, 0.48, 1)",
        "fog_density": 0.010,
        "sun_color": "Color(0.75, 0.90, 1.0, 1)",
        "sun_energy": 1.3,
        "ground_color": "Color(0.80, 0.88, 0.95, 1)",
        "city_id": "poi_reg031_city",
        "city_name": "Refúgio dos Ecos",
        "dungeon_id": "dungeon_frozen_resonance",
        "dungeon_name": "Câmara da Ressonância Gélida",
        "boss_id": "BOSS-024",
        "boss_name": "Santuário do Eco Profundo",
        "exp_id": "poi_echo_monolith",
        "exp_name": "Pináculo Ressonante de Gelo",
        "gates": [
            {"name": "GateNorth", "target": "REG-032", "spawn": "gate_south", "label": "Geleiras para a Cidade Submersa de Gelo (REG-032)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-033", "spawn": "gate_north", "label": "Descida para a Tundra Branca (REG-033)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": True,
        "demons": ["DEMON-151", "DEMON-152", "DEMON-153", "DEMON-154", "DEMON-155"],
        "monument_cat": "rocks",
        "monument_name": "rock_glacial_echo_cliff",
        "check_node": "Structures/GlacialEchoCliff",
        "extra_monument": {"cat": "props", "name": "prop_ice_resonator_crystal", "node": "IceResonatorCrystal", "pos": "Vector3(20, 0, -25)"}
    },
    {
        "num": 32,
        "id": "REG-032",
        "slug": "cidade_submersa_de_gelo",
        "name": "Cidade Submersa de Gelo",
        "class_name": "CidadeSubmersaDeGeloRegion",
        "script_rel": "scenes/world/regions/cidade_submersa_de_gelo.gd",
        "biome": "submerged_ice_city",
        "level_min": 36,
        "level_max": 45,
        "sky_top": "Color(0.08, 0.14, 0.25, 1)",
        "sky_horizon": "Color(0.20, 0.38, 0.55, 1)",
        "fog_color": "Color(0.15, 0.28, 0.45, 1)",
        "fog_density": 0.012,
        "sun_color": "Color(0.70, 0.88, 0.98, 1)",
        "sun_energy": 1.15,
        "ground_color": "Color(0.65, 0.80, 0.90, 1)",
        "city_id": "poi_reg032_city",
        "city_name": "Cidadela Glacial Espectro",
        "dungeon_id": "dungeon_sunken_catacombs",
        "dungeon_name": "Catacumbas Submersas do Gelo",
        "boss_id": "BOSS-025",
        "boss_name": "Ágora do Gelo Submerso",
        "exp_id": "poi_submerged_citadel",
        "exp_name": "Cúpula Congelada do Senado Imperial",
        "gates": [
            {"name": "GateNorth", "target": "REG-031", "spawn": "gate_south", "label": "Subida para a Geleira dos Ecos (REG-031)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-034", "spawn": "gate_north", "label": "Acesso para o Pináculo do Silêncio (REG-034)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-156", "DEMON-157", "DEMON-158", "DEMON-159", "DEMON-160"],
        "monument_cat": "structures",
        "monument_name": "structure_submerged_ice_citadel",
        "check_node": "Structures/SubmergedIceCitadel",
        "extra_monument": None
    },
    {
        "num": 33,
        "id": "REG-033",
        "slug": "tundra_branca",
        "name": "Tundra Branca",
        "class_name": "TundraBrancaRegion",
        "script_rel": "scenes/world/regions/tundra_branca.gd",
        "biome": "white_tundra",
        "level_min": 37,
        "level_max": 46,
        "sky_top": "Color(0.14, 0.18, 0.26, 1)",
        "sky_horizon": "Color(0.40, 0.48, 0.58, 1)",
        "fog_color": "Color(0.32, 0.40, 0.50, 1)",
        "fog_density": 0.007,
        "sun_color": "Color(0.95, 0.95, 1.0, 1)",
        "sun_energy": 1.35,
        "ground_color": "Color(0.88, 0.90, 0.92, 1)",
        "city_id": "poi_reg033_city",
        "city_name": "Acampamento dos Caçadores da Tundra",
        "dungeon_id": "dungeon_mammoth_hollow",
        "dungeon_name": "Caverna dos Ossos Congelados",
        "boss_id": "BOSS-026",
        "boss_name": "Túmulo do Titã dos Ventos",
        "exp_id": "poi_tundra_cairn",
        "exp_name": "Cairn Ancestral de Ossos de Mamute",
        "gates": [
            {"name": "GateNorth", "target": "REG-031", "spawn": "gate_south", "label": "Passagem para a Geleira dos Ecos (REG-031)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-035", "spawn": "gate_north", "label": "Trilha para o Bosque de Cristal (REG-035)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-161", "DEMON-162", "DEMON-163", "DEMON-164", "DEMON-165"],
        "monument_cat": "props",
        "monument_name": "prop_tundra_bone_cairn_marker",
        "check_node": "Structures/TundraBoneCairn",
        "extra_monument": None
    },
    {
        "num": 34,
        "id": "REG-034",
        "slug": "pinaculo_do_silencio",
        "name": "Pináculo do Silêncio",
        "class_name": "PinaculoDoSilencioRegion",
        "script_rel": "scenes/world/regions/pinaculo_do_silencio.gd",
        "biome": "silence_pinnacle",
        "level_min": 38,
        "level_max": 47,
        "sky_top": "Color(0.06, 0.10, 0.22, 1)",
        "sky_horizon": "Color(0.22, 0.35, 0.55, 1)",
        "fog_color": "Color(0.18, 0.26, 0.42, 1)",
        "fog_density": 0.009,
        "sun_color": "Color(0.82, 0.92, 1.0, 1)",
        "sun_energy": 1.45,
        "ground_color": "Color(0.55, 0.65, 0.75, 1)",
        "city_id": "poi_reg034_city",
        "city_name": "Refúgio da Agulha",
        "dungeon_id": "dungeon_windless_peak",
        "dungeon_name": "Abismo do Vento Mudo",
        "boss_id": "BOSS-027",
        "boss_name": "Plataforma dos Ventos Silenciosos",
        "exp_id": "poi_ice_spire",
        "exp_name": "A Agulha Eterna de Gelo",
        "gates": [
            {"name": "GateNorth", "target": "REG-032", "spawn": "gate_south", "label": "Descida para a Cidade Submersa de Gelo (REG-032)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-036", "spawn": "gate_north", "label": "Despenhadeiro para a Fenda do Inverno (REG-036)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-166", "DEMON-167", "DEMON-168", "DEMON-169", "DEMON-170"],
        "monument_cat": "rocks",
        "monument_name": "rock_needle_peak_ice_spire",
        "check_node": "Structures/NeedlePeakIceSpire",
        "extra_monument": None
    },
    {
        "num": 35,
        "id": "REG-035",
        "slug": "bosque_de_cristal",
        "name": "Bosque de Cristal",
        "class_name": "BosqueDeCristalRegion",
        "script_rel": "scenes/world/regions/bosque_de_cristal.gd",
        "biome": "crystal_forest",
        "level_min": 39,
        "level_max": 48,
        "sky_top": "Color(0.12, 0.08, 0.26, 1)",
        "sky_horizon": "Color(0.35, 0.28, 0.60, 1)",
        "fog_color": "Color(0.28, 0.22, 0.50, 1)",
        "fog_density": 0.011,
        "sun_color": "Color(0.85, 0.75, 1.0, 1)",
        "sun_energy": 1.25,
        "ground_color": "Color(0.70, 0.75, 0.90, 1)",
        "city_id": "poi_reg035_city",
        "city_name": "Enclave dos Prismas",
        "dungeon_id": "dungeon_shattered_glasswood",
        "dungeon_name": "Bosque das Fraturas de Quartzo",
        "boss_id": "BOSS-028",
        "boss_name": "Clareira do Cristal Mestre",
        "exp_id": "poi_crystal_canopy",
        "exp_name": "A Árvore Patriarca de Quartzo Glacial",
        "gates": [
            {"name": "GateNorth", "target": "REG-033", "spawn": "gate_south", "label": "Trilha para a Tundra Branca (REG-033)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-036", "spawn": "gate_north", "label": "Desfiladeiro para a Fenda do Inverno (REG-036)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-171", "DEMON-172", "DEMON-173", "DEMON-174", "DEMON-175"],
        "monument_cat": "nature",
        "monument_name": "nature_crystal_canopy_tree",
        "check_node": "Structures/CrystalCanopyTree",
        "extra_monument": None
    },
    {
        "num": 36,
        "id": "REG-036",
        "slug": "fenda_do_inverno",
        "name": "Fenda do Inverno",
        "class_name": "FendaDoInvernoRegion",
        "script_rel": "scenes/world/regions/fenda_do_inverno.gd",
        "biome": "winter_chasm",
        "level_min": 40,
        "level_max": 49,
        "sky_top": "Color(0.08, 0.12, 0.22, 1)",
        "sky_horizon": "Color(0.24, 0.36, 0.52, 1)",
        "fog_color": "Color(0.16, 0.26, 0.40, 1)",
        "fog_density": 0.013,
        "sun_color": "Color(0.75, 0.88, 1.0, 1)",
        "sun_energy": 1.2,
        "ground_color": "Color(0.40, 0.50, 0.65, 1)",
        "city_id": "poi_reg036_city",
        "city_name": "Posto da Fenda Fria",
        "dungeon_id": "dungeon_abyssal_crevasse",
        "dungeon_name": "Fosso dos Espinhos de Gelo",
        "boss_id": "BOSS-029",
        "boss_name": "A Fenda Abissal do Inverno",
        "exp_id": "poi_winter_crevasse",
        "exp_name": "A Garganta Glacial Profunda",
        "gates": [
            {"name": "GateNorth", "target": "REG-034", "spawn": "gate_south", "label": "Subida para o Pináculo do Silêncio (REG-034)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-035", "spawn": "gate_north", "label": "Trilha para o Bosque de Cristal (REG-035)", "pos": "Vector3(0, 0, 95)"},
            {"name": "GateEast", "target": "REG-037", "spawn": "gate_west", "label": "Travessia para a Costa Boreal (REG-037)", "pos": "Vector3(95, 0, 0)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-176", "DEMON-177", "DEMON-178", "DEMON-179", "DEMON-180"],
        "monument_cat": "rocks",
        "monument_name": "rock_winter_chasm_crevasse",
        "check_node": "Structures/WinterChasmCrevasse",
        "extra_monument": None
    },
    {
        "num": 37,
        "id": "REG-037",
        "slug": "costa_boreal",
        "name": "Costa Boreal",
        "class_name": "CostaBorealRegion",
        "script_rel": "scenes/world/regions/costa_boreal.gd",
        "biome": "boreal_coast",
        "level_min": 41,
        "level_max": 50,
        "sky_top": "Color(0.06, 0.14, 0.25, 1)",
        "sky_horizon": "Color(0.20, 0.42, 0.58, 1)",
        "fog_color": "Color(0.15, 0.32, 0.46, 1)",
        "fog_density": 0.009,
        "sun_color": "Color(0.80, 0.94, 1.0, 1)",
        "sun_energy": 1.3,
        "ground_color": "Color(0.50, 0.60, 0.70, 1)",
        "city_id": "poi_reg037_city",
        "city_name": "Porto de Vidro Frio",
        "dungeon_id": "dungeon_drowned_ice_cavern",
        "dungeon_name": "Caverna da Maré Congelada",
        "boss_id": "BOSS-030",
        "boss_name": "O Quebra-Mar do Gelo Ártico",
        "exp_id": "poi_boreal_pier",
        "exp_name": "O Antigo Píer Boreal Abandonado",
        "gates": [
            {"name": "GateNorth", "target": "REG-036", "spawn": "gate_east", "label": "Retorno para a Fenda do Inverno (REG-036)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-038", "spawn": "gate_north", "label": "Avenida Congelada para o Palácio Adormecido (REG-038)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-181", "DEMON-182", "DEMON-183", "DEMON-184", "DEMON-185"],
        "monument_cat": "structures",
        "monument_name": "structure_boreal_coastal_pier",
        "check_node": "Structures/BorealCoastalPier",
        "extra_monument": None
    },
    {
        "num": 38,
        "id": "REG-038",
        "slug": "palacio_adormecido",
        "name": "Palácio Adormecido",
        "class_name": "PalacioAdormecidoRegion",
        "script_rel": "scenes/world/regions/palacio_adormecido.gd",
        "biome": "sleeping_palace",
        "level_min": 42,
        "level_max": 50,
        "sky_top": "Color(0.10, 0.10, 0.28, 1)",
        "sky_horizon": "Color(0.30, 0.30, 0.62, 1)",
        "fog_color": "Color(0.22, 0.22, 0.50, 1)",
        "fog_density": 0.010,
        "sun_color": "Color(0.85, 0.85, 1.0, 1)",
        "sun_energy": 1.2,
        "ground_color": "Color(0.72, 0.76, 0.88, 1)",
        "city_id": "poi_reg038_city",
        "city_name": "Claustro do Palácio",
        "dungeon_id": "dungeon_forgotten_crypts_of_ice",
        "dungeon_name": "Cripta das Rainhas de Gelo",
        "boss_id": "",
        "boss_name": "",
        "exp_id": "poi_sleeping_palace",
        "exp_name": "A Grande Nave do Palácio Gótico Adormecido",
        "gates": [
            {"name": "GateNorth", "target": "REG-037", "spawn": "gate_south", "label": "Acesso ao Litoral da Costa Boreal (REG-037)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-039", "spawn": "gate_north", "label": "Passagem para o Cemitério das Estrelas (REG-039)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-186", "DEMON-187", "DEMON-188", "DEMON-189", "DEMON-190"],
        "monument_cat": "structures",
        "monument_name": "structure_sleeping_palace_monument",
        "check_node": "Structures/SleepingPalaceMonument",
        "extra_monument": None
    },
    {
        "num": 39,
        "id": "REG-039",
        "slug": "cemiterio_das_estrelas",
        "name": "Cemitério das Estrelas",
        "class_name": "CemiterioDasEstrelasRegion",
        "script_rel": "scenes/world/regions/cemiterio_das_estrelas.gd",
        "biome": "star_graveyard",
        "level_min": 43,
        "level_max": 50,
        "sky_top": "Color(0.08, 0.06, 0.25, 1)",
        "sky_horizon": "Color(0.28, 0.18, 0.52, 1)",
        "fog_color": "Color(0.22, 0.15, 0.42, 1)",
        "fog_density": 0.008,
        "sun_color": "Color(0.90, 0.78, 1.0, 1)",
        "sun_energy": 1.35,
        "ground_color": "Color(0.25, 0.20, 0.35, 1)",
        "city_id": "poi_reg039_city",
        "city_name": "Acampamento dos Astrólogos",
        "dungeon_id": "dungeon_celestial_meteor_core",
        "dungeon_name": "O Núcleo da Estrela Caída",
        "boss_id": "",
        "boss_name": "",
        "exp_id": "poi_star_geode",
        "exp_name": "O Grande Geodo de Quartzo Cósmico",
        "gates": [
            {"name": "GateNorth", "target": "REG-038", "spawn": "gate_south", "label": "Subida para o Palácio Adormecido (REG-038)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-040", "spawn": "gate_north", "label": "Marcha para o Trono da Aurora Morta (REG-040)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-191", "DEMON-192", "DEMON-193", "DEMON-194", "DEMON-195"],
        "monument_cat": "props",
        "monument_name": "prop_astral_star_geode_shrine",
        "check_node": "Structures/AstralStarGeode",
        "extra_monument": None
    },
    {
        "num": 40,
        "id": "REG-040",
        "slug": "trono_da_aurora_morta",
        "name": "Trono da Aurora Morta",
        "class_name": "TronoDaAuroraMortaRegion",
        "script_rel": "scenes/world/regions/trono_da_aurora_morta.gd",
        "biome": "dead_aurora_throne",
        "level_min": 45,
        "level_max": 50,
        "sky_top": "Color(0.04, 0.12, 0.22, 1)",
        "sky_horizon": "Color(0.15, 0.48, 0.42, 1)",
        "fog_color": "Color(0.12, 0.36, 0.34, 1)",
        "fog_density": 0.012,
        "sun_color": "Color(0.60, 1.0, 0.88, 1)",
        "sun_energy": 1.4,
        "ground_color": "Color(0.10, 0.14, 0.16, 1)",
        "city_id": "poi_reg040_city",
        "city_name": "Santuário da Aurora Polar",
        "dungeon_id": "dungeon_dead_aurora_vault",
        "dungeon_name": "Câmara do Gelo Negro Eterno",
        "boss_id": "",
        "boss_name": "",
        "exp_id": "poi_aurora_throne",
        "exp_name": "O Trono de Gelo Negro com a Auréola da Aurora",
        "gates": [
            {"name": "GateNorth", "target": "REG-039", "spawn": "gate_south", "label": "Retorno para o Cemitério das Estrelas (REG-039)", "pos": "Vector3(0, 0, -95)"}
        ],
        "has_hellforge": True,
        "demons": ["DEMON-196", "DEMON-197", "DEMON-198", "DEMON-199", "DEMON-200"],
        "monument_cat": "structures",
        "monument_name": "structure_dead_aurora_throne",
        "check_node": "Structures/DeadAuroraThrone",
        "extra_monument": {"cat": "rocks", "name": "rock_aurora_monolith_sentinel", "node": "AuroraMonolithSentinel", "pos": "Vector3(-25, 0, -35)"}
    }
]

def generate_region_script(r):
    code = f'''class_name {r["class_name"]}
extends NhalkoraRegionBase
## Região {r["id"]}: {r["name"]} (Continente NHAL'KORA).
## Apresenta arquitetura glacial, misteriosa, cristalina e monumental com relevos e monumentos dedicados.

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
    lines.append('ground_bottom_color = Color(0.08, 0.10, 0.16, 1)')
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
    lines.append('roughness = 0.75')
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
    if r["num"] == 37:
        # Provide gate_west alias for gate from REG-036
        lines.append('[node name="Spawn_gate_west" type="Marker3D" parent="Spawns"]')
        lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -95, 0, 0)')
        lines.append('')
    lines.append('[node name="Spawn_portal_main" type="Marker3D" parent="Spawns"]')
    lines.append('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 26, 0.2, 22)')
    lines.append('')
    lines.append('[node name="Structures" type="Node3D" parent="."]')
    lines.append('')
    lines.append('[node name="CityCitadel" type="Node3D" parent="Structures"]')
    lines.append('')
    lines.append('[node name="POI_City" type="Area3D" parent="Structures/CityCitadel"]')
    lines.append('script = ExtResource("3_poi")')
    lines.append(f'poi_id = &"{r["city_id"]}"')
    lines.append(f'poi_name = "{r["city_name"]}"')
    lines.append('poi_type = "city"')
    lines.append(f'description = "Assentamento e zona segura em {r["name"]}."')
    lines.append('discovery_radius = 22.0')
    lines.append('discovery_xp = 100')
    lines.append('')
    lines.append('[node name="SafeZone" type="Area3D" parent="Structures/CityCitadel"]')
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
    lines.append(f'description = "Masmorra glacial {r["dungeon_name"]} de nível {r["level_min"]}+."')
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
    print("ABYSSAL PACT — CONSTRUINDO AS 10 REGIÕES 3D DE NHAL'KORA")
    print("======================================================================")

    # 1. Gera GDScripts
    for r in NHALKORA_REGIONS:
        script_code = generate_region_script(r)
        script_path = r["script_rel"]
        with open(script_path, "w", encoding="utf-8") as f:
            f.write(script_code)
        print(f"[OK] GDScript gerado: {script_path}")

    # 2. Gera cenas 3D (.tscn)
    for r in NHALKORA_REGIONS:
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
    for r in NHALKORA_REGIONS:
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
    print("CONCLUÍDO COM SUCESSO: 10 regiões de Nhal'Kora integradas em 3D.")
    print("======================================================================")

if __name__ == "__main__":
    main()
