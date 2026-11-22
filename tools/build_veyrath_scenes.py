"""
ABYSSAL PACT — Gerador de Cenas 3D das 10 Regiões de Veyrath
Cria as cenas 3D funcionais e sincroniza os resources RegionData em data/content/regions/.
"""

import os
import re

REGIONS = [
    {
        "num": 1,
        "id": "REG-001",
        "slug": "cinzalia",
        "name": "Cinzália",
        "script": "res://scenes/world/regions/cinzalia.gd",
        "biome": "ash_plains",
        "level_min": 1,
        "level_max": 5,
        "sky_top": "Color(0.18, 0.12, 0.15, 1)",
        "sky_horizon": "Color(0.38, 0.22, 0.2, 1)",
        "fog_color": "Color(0.28, 0.16, 0.18, 1)",
        "fog_density": 0.008,
        "sun_color": "Color(0.95, 0.65, 0.5, 1)",
        "sun_energy": 1.3,
        "ground_color": "Color(0.16, 0.14, 0.16, 1)",
        "city_id": "poi_reg001_city",
        "city_name": "Baluarte das Cinzas",
        "dungeon_id": "dungeon_basalt_catacombs",
        "dungeon_name": "Catacumbas de Basalto",
        "boss_id": "BOSS-001",
        "boss_name": "Arena do Vazio Vulcânico",
        "exp_id": "poi_monolith_pact",
        "exp_name": "Monólito do Primeiro Pacto",
        "gates": [
            {"name": "GateNorth", "target": "REG-002", "spawn": "gate_south", "label": "Estrada para a Coroa Partida (REG-002)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-003", "spawn": "gate_north", "label": "Passo para o Vale dos Sinos (REG-003)", "pos": "Vector3(0, 0, 95)"}
        ],
        "has_hellforge": True,
        "demons": ["DEMON-001", "DEMON-002", "DEMON-003", "DEMON-004", "DEMON-005"]
    },
    {
        "num": 2,
        "id": "REG-002",
        "slug": "coroa_partida",
        "name": "Coroa Partida",
        "script": "res://scenes/world/regions/coroa_partida.gd",
        "biome": "imperial_capital_ruins",
        "level_min": 3,
        "level_max": 8,
        "sky_top": "Color(0.22, 0.16, 0.12, 1)",
        "sky_horizon": "Color(0.48, 0.32, 0.18, 1)",
        "fog_color": "Color(0.35, 0.25, 0.18, 1)",
        "fog_density": 0.009,
        "sun_color": "Color(0.96, 0.72, 0.42, 1)",
        "sun_energy": 1.35,
        "ground_color": "Color(0.22, 0.20, 0.20, 1)",
        "city_id": "poi_reg002_city",
        "city_name": "Cidadela da Coroa",
        "dungeon_id": "dungeon_pyrite_mines",
        "dungeon_name": "Minas de Pirita",
        "boss_id": "BOSS-002",
        "boss_name": "Sala do Trono Despedaçado",
        "exp_id": "poi_broken_throne",
        "exp_name": "O Trono Caído da Dinastia",
        "gates": [
            {"name": "GateSouth", "target": "REG-001", "spawn": "gate_north", "label": "Passagem para Cinzália (REG-001)", "pos": "Vector3(0, 0, 95)"},
            {"name": "GateEast", "target": "REG-004", "spawn": "gate_west", "label": "Trilha para o Bosque Oco (REG-004)", "pos": "Vector3(95, 0, 0)"},
            {"name": "GateNorth", "target": "REG-008", "spawn": "gate_south", "label": "Via dos Mortos para Catacumbas de Orun (REG-008)", "pos": "Vector3(0, 0, -95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-006", "DEMON-007", "DEMON-008", "DEMON-009", "DEMON-010"]
    },
    {
        "num": 3,
        "id": "REG-003",
        "slug": "vale_dos_sinos",
        "name": "Vale dos Sinos",
        "script": "res://scenes/world/regions/vale_dos_sinos.gd",
        "biome": "bell_valley",
        "level_min": 5,
        "level_max": 10,
        "sky_top": "Color(0.14, 0.12, 0.18, 1)",
        "sky_horizon": "Color(0.32, 0.24, 0.35, 1)",
        "fog_color": "Color(0.24, 0.18, 0.26, 1)",
        "fog_density": 0.014,
        "sun_color": "Color(0.78, 0.58, 0.85, 1)",
        "sun_energy": 1.05,
        "ground_color": "Color(0.15, 0.14, 0.18, 1)",
        "city_id": "poi_reg003_city",
        "city_name": "Santuário do Eco",
        "dungeon_id": "dungeon_caverns_candent",
        "dungeon_name": "Cavernas Candentes",
        "boss_id": "BOSS-003",
        "boss_name": "Campanário das Lamentações",
        "exp_id": "poi_abyssal_bell",
        "exp_name": "O Grande Sino Abissal",
        "gates": [
            {"name": "GateNorth", "target": "REG-001", "spawn": "gate_south", "label": "Subida para Cinzália (REG-001)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateWest", "target": "REG-005", "spawn": "gate_east", "label": "Passagem para o Lago de Vidro (REG-005)", "pos": "Vector3(-95, 0, 0)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-011", "DEMON-012", "DEMON-013", "DEMON-014", "DEMON-015"]
    },
    {
        "num": 4,
        "id": "REG-004",
        "slug": "bosque_oco",
        "name": "Bosque Oco",
        "script": "res://scenes/world/regions/bosque_oco.gd",
        "biome": "hollow_woods",
        "level_min": 8,
        "level_max": 12,
        "sky_top": "Color(0.16, 0.10, 0.14, 1)",
        "sky_horizon": "Color(0.35, 0.18, 0.22, 1)",
        "fog_color": "Color(0.26, 0.14, 0.18, 1)",
        "fog_density": 0.012,
        "sun_color": "Color(0.85, 0.45, 0.40, 1)",
        "sun_energy": 0.95,
        "ground_color": "Color(0.14, 0.11, 0.12, 1)",
        "city_id": "poi_reg004_city",
        "city_name": "Refúgio do Tronco Velho",
        "dungeon_id": "dungeon_muddy_pit",
        "dungeon_name": "Fosso Lamacento",
        "boss_id": "BOSS-004",
        "boss_name": "Antro das Raízes Calcinadas",
        "exp_id": "poi_hollow_monument",
        "exp_name": "Carvalho Oco Ancestral",
        "gates": [
            {"name": "GateWest", "target": "REG-002", "spawn": "gate_east", "label": "Estrada para a Coroa Partida (REG-002)", "pos": "Vector3(-95, 0, 0)"},
            {"name": "GateNorth", "target": "REG-007", "spawn": "gate_south", "label": "Subida para o Passo da Vigília (REG-007)", "pos": "Vector3(0, 0, -95)"},
            {"name": "GateSouth", "target": "REG-001", "spawn": "gate_north", "label": "Passagem para Cinzália (REG-001)", "pos": "Vector3(0, 0, 95)"},
            {"name": "GateEast", "target": "REG-008", "spawn": "gate_west", "label": "Trilha Fúnebre para Catacumbas de Orun (REG-008)", "pos": "Vector3(95, 0, 0)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-016", "DEMON-017", "DEMON-018", "DEMON-019", "DEMON-020"]
    },
    {
        "num": 5,
        "id": "REG-005",
        "slug": "lago_de_vidro",
        "name": "Lago de Vidro",
        "script": "res://scenes/world/regions/lago_de_vidro.gd",
        "biome": "glass_lake",
        "level_min": 10,
        "level_max": 15,
        "sky_top": "Color(0.12, 0.14, 0.22, 1)",
        "sky_horizon": "Color(0.25, 0.32, 0.45, 1)",
        "fog_color": "Color(0.18, 0.22, 0.30, 1)",
        "fog_density": 0.007,
        "sun_color": "Color(0.68, 0.78, 0.98, 1)",
        "sun_energy": 1.25,
        "ground_color": "Color(0.08, 0.08, 0.11, 1)",
        "city_id": "poi_reg005_city",
        "city_name": "Posto das Agulhas de Vidro",
        "dungeon_id": "dungeon_glass_blades",
        "dungeon_name": "Câmara das Lâminas",
        "boss_id": "BOSS-005",
        "boss_name": "Espelho da Perdição",
        "exp_id": "poi_obsidian_crystal",
        "exp_name": "Pináculo de Cristais de Obsidiana",
        "gates": [
            {"name": "GateEast", "target": "REG-003", "spawn": "gate_west", "label": "Passo para o Vale dos Sinos (REG-003)", "pos": "Vector3(95, 0, 0)"},
            {"name": "GateSouth", "target": "REG-001", "spawn": "gate_north", "label": "Passagem para Cinzália (REG-001)", "pos": "Vector3(0, 0, 95)"},
            {"name": "GateNorth", "target": "REG-006", "spawn": "gate_south", "label": "Descida para a Costa das Cinzas (REG-006)", "pos": "Vector3(0, 0, -95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-021", "DEMON-022", "DEMON-023", "DEMON-024", "DEMON-025"]
    },
    {
        "num": 6,
        "id": "REG-006",
        "slug": "costa_das_cinzas",
        "name": "Costa das Cinzas",
        "script": "res://scenes/world/regions/costa_das_cinzas.gd",
        "biome": "ashen_coast",
        "level_min": 13,
        "level_max": 17,
        "sky_top": "Color(0.15, 0.16, 0.20, 1)",
        "sky_horizon": "Color(0.38, 0.32, 0.30, 1)",
        "fog_color": "Color(0.25, 0.22, 0.26, 1)",
        "fog_density": 0.010,
        "sun_color": "Color(0.92, 0.75, 0.60, 1)",
        "sun_energy": 1.25,
        "ground_color": "Color(0.13, 0.13, 0.15, 1)",
        "city_id": "poi_reg006_city",
        "city_name": "Enseada dos Naufrágios",
        "dungeon_id": "dungeon_tomb_winds",
        "dungeon_name": "Túmulo dos Ventos",
        "boss_id": "BOSS-006",
        "boss_name": "Farol das Sombras Náuticas",
        "exp_id": "poi_shipwreck_keel",
        "exp_name": "Naufrágio da Nau Imperial",
        "gates": [
            {"name": "GateSouth", "target": "REG-005", "spawn": "gate_north", "label": "Subida para o Lago de Vidro (REG-005)", "pos": "Vector3(0, 0, 95)"},
            {"name": "GateEast", "target": "REG-007", "spawn": "gate_west", "label": "Garganta para o Passo da Vigília (REG-007)", "pos": "Vector3(95, 0, 0)"},
            {"name": "GateNorth", "target": "REG-009", "spawn": "gate_south", "label": "Estrada Litorânea para Campos de Sal (REG-009)", "pos": "Vector3(0, 0, -95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-026", "DEMON-027", "DEMON-028", "DEMON-029", "DEMON-030"]
    },
    {
        "num": 7,
        "id": "REG-007",
        "slug": "passo_da_vigilia",
        "name": "Passo da Vigília",
        "script": "res://scenes/world/regions/passo_da_vigilia.gd",
        "biome": "watchers_pass",
        "level_min": 15,
        "level_max": 20,
        "sky_top": "Color(0.18, 0.16, 0.22, 1)",
        "sky_horizon": "Color(0.44, 0.36, 0.38, 1)",
        "fog_color": "Color(0.30, 0.24, 0.28, 1)",
        "fog_density": 0.007,
        "sun_color": "Color(0.98, 0.78, 0.62, 1)",
        "sun_energy": 1.45,
        "ground_color": "Color(0.20, 0.18, 0.19, 1)",
        "city_id": "poi_reg007_city",
        "city_name": "Guarnição de Chumbo",
        "dungeon_id": "dungeon_deep_iron",
        "dungeon_name": "Complexo de Ferro Profundo",
        "boss_id": "BOSS-007",
        "boss_name": "Pico dos Guardiões Pétreos",
        "exp_id": "poi_mountain_bastion",
        "exp_name": "Bastião das Alturas",
        "gates": [
            {"name": "GateSouth", "target": "REG-004", "spawn": "gate_north", "label": "Descida para o Bosque Oco (REG-004)", "pos": "Vector3(0, 0, 95)"},
            {"name": "GateWest", "target": "REG-006", "spawn": "gate_east", "label": "Passo para a Costa das Cinzas (REG-006)", "pos": "Vector3(-95, 0, 0)"},
            {"name": "GateEast", "target": "REG-008", "spawn": "gate_west", "label": "Descida para Catacumbas de Orun (REG-008)", "pos": "Vector3(95, 0, 0)"},
            {"name": "GateNorth", "target": "REG-009", "spawn": "gate_south", "label": "Desfiladeiro para Campos de Sal (REG-009)", "pos": "Vector3(0, 0, -95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-031", "DEMON-032", "DEMON-033", "DEMON-034", "DEMON-035"]
    },
    {
        "num": 8,
        "id": "REG-008",
        "slug": "catacumbas_de_orun",
        "name": "Catacumbas de Orun",
        "script": "res://scenes/world/regions/catacumbas_de_orun.gd",
        "biome": "orun_catacombs",
        "level_min": 18,
        "level_max": 22,
        "sky_top": "Color(0.12, 0.14, 0.18, 1)",
        "sky_horizon": "Color(0.24, 0.30, 0.38, 1)",
        "fog_color": "Color(0.18, 0.22, 0.28, 1)",
        "fog_density": 0.013,
        "sun_color": "Color(0.65, 0.78, 0.95, 1)",
        "sun_energy": 0.95,
        "ground_color": "Color(0.16, 0.15, 0.17, 1)",
        "city_id": "poi_reg008_city",
        "city_name": "Fortim de Ferro de Orun",
        "dungeon_id": "dungeon_condemned_mine",
        "dungeon_name": "Mina dos Condenados",
        "boss_id": "BOSS-008",
        "boss_name": "Hipogeu dos Reis de Orun",
        "exp_id": "poi_mausoleum_entrance",
        "exp_name": "Mausoléu da Primeira Dinastia",
        "gates": [
            {"name": "GateSouth", "target": "REG-002", "spawn": "gate_north", "label": "Via Imperial para Coroa Partida (REG-002)", "pos": "Vector3(0, 0, 95)"},
            {"name": "GateWest", "target": "REG-007", "spawn": "gate_east", "label": "Subida para o Passo da Vigília (REG-007)", "pos": "Vector3(-95, 0, 0)"},
            {"name": "GateNorth", "target": "REG-010", "spawn": "gate_south", "label": "Passagem Sagrada para Torre de Aster (REG-010)", "pos": "Vector3(0, 0, -95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-036", "DEMON-037", "DEMON-038", "DEMON-039", "DEMON-040"]
    },
    {
        "num": 9,
        "id": "REG-009",
        "slug": "campos_de_sal",
        "name": "Campos de Sal",
        "script": "res://scenes/world/regions/campos_de_sal.gd",
        "biome": "salt_plains",
        "level_min": 20,
        "level_max": 25,
        "sky_top": "Color(0.24, 0.20, 0.18, 1)",
        "sky_horizon": "Color(0.55, 0.45, 0.38, 1)",
        "fog_color": "Color(0.42, 0.36, 0.32, 1)",
        "fog_density": 0.007,
        "sun_color": "Color(1.0, 0.92, 0.82, 1)",
        "sun_energy": 1.55,
        "ground_color": "Color(0.82, 0.82, 0.85, 1)",
        "city_id": "poi_reg009_city",
        "city_name": "Posto da Salmoura",
        "dungeon_id": "dungeon_salt_crypt",
        "dungeon_name": "Cripta dos Condenados",
        "boss_id": "",
        "boss_name": "",
        "exp_id": "poi_great_salt_crust",
        "exp_name": "Grande Crosta de Sal Cáustica",
        "gates": [
            {"name": "GateSouth", "target": "REG-006", "spawn": "gate_north", "label": "Estrada para a Costa das Cinzas (REG-006)", "pos": "Vector3(0, 0, 95)"},
            {"name": "GateEast", "target": "REG-007", "spawn": "gate_west", "label": "Subida para o Passo da Vigília (REG-007)", "pos": "Vector3(95, 0, 0)"},
            {"name": "GateNorth", "target": "REG-010", "spawn": "gate_west", "label": "Ascensão para a Torre de Aster (REG-010)", "pos": "Vector3(0, 0, -95)"}
        ],
        "has_hellforge": False,
        "demons": ["DEMON-041", "DEMON-042", "DEMON-043", "DEMON-044", "DEMON-045"]
    },
    {
        "num": 10,
        "id": "REG-010",
        "slug": "torre_de_aster",
        "name": "Torre de Aster",
        "script": "res://scenes/world/regions/torre_de_aster.gd",
        "biome": "aster_caldera",
        "level_min": 23,
        "level_max": 28,
        "sky_top": "Color(0.18, 0.08, 0.25, 1)",
        "sky_horizon": "Color(0.45, 0.18, 0.55, 1)",
        "fog_color": "Color(0.32, 0.14, 0.40, 1)",
        "fog_density": 0.011,
        "sun_color": "Color(0.85, 0.45, 1.0, 1)",
        "sun_energy": 1.6,
        "ground_color": "Color(0.10, 0.08, 0.12, 1)",
        "city_id": "poi_reg010_city",
        "city_name": "Círculo de Aster",
        "dungeon_id": "dungeon_deep_fire",
        "dungeon_name": "Santuário do Fogo Profundo",
        "boss_id": "",
        "boss_name": "",
        "exp_id": "poi_aster_vortex",
        "exp_name": "Vórtice da Torre de Aster",
        "gates": [
            {"name": "GateSouth", "target": "REG-008", "spawn": "gate_north", "label": "Passo Fúnebre para Catacumbas de Orun (REG-008)", "pos": "Vector3(0, 0, 95)"},
            {"name": "GateWest", "target": "REG-009", "spawn": "gate_north", "label": "Descida para os Campos de Sal (REG-009)", "pos": "Vector3(-95, 0, 0)"}
        ],
        "has_hellforge": True,
        "demons": ["DEMON-046", "DEMON-047", "DEMON-048", "DEMON-049", "DEMON-050"]
    }
]

def generate_scene_tscn(r):
    # Builds standard complete 3D scene file (.tscn)
    lines = []
    lines.append('[gd_scene load_steps=22 format=3]')
    lines.append('')
    lines.append(f'[ext_resource type="Script" path="{r["script"]}" id="1_reg"]')
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
    lines.append('ground_bottom_color = Color(0.10, 0.08, 0.10, 1)')
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
    lines.append('roughness = 0.90')
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
    lines.append('[node name="CityBastion" type="Node3D" parent="Structures"]')
    lines.append('')
    lines.append('[node name="POI_City" type="Area3D" parent="Structures/CityBastion"]')
    lines.append('script = ExtResource("3_poi")')
    lines.append(f'poi_id = &"{r["city_id"]}"')
    lines.append(f'poi_name = "{r["city_name"]}"')
    lines.append('poi_type = "city"')
    lines.append(f'description = "Assentamento e zona segura em {r["name"]}."')
    lines.append('discovery_radius = 22.0')
    lines.append('discovery_xp = 100')
    lines.append('')
    lines.append('[node name="SafeZone" type="Area3D" parent="Structures/CityBastion"]')
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
    lines.append(f'description = "Masmorra {r["dungeon_name"]} de nível {r["level_min"]}+."')
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
    enemy_coords = [Vector3(35, 0, -45), Vector3(-40, 0, 60), Vector3(-70, 0, -15), Vector3(20, 0, 65), Vector3(-30, 0, -75)]
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

class Vector3(tuple):
    def __new__(cls, x, y, z):
        return super(Vector3, cls).__new__(cls, (x, y, z))

def main():
    print("=== GERANDO CENAS 3D E ATUALIZANDO RESOURCES DE VEYRATH ===")
    
    # 1. Gera cenas para regiões 02 a 10
    for r in REGIONS[1:]: # region 1 already has cinzalia.tscn & region_001.tscn
        tscn_content = generate_scene_tscn(r)
        
        # Nome amigável (slug)
        slug_path = f"scenes/world/regions/{r['slug']}.tscn"
        with open(slug_path, "w", encoding="utf-8") as f:
            f.write(tscn_content)
        print(f"[OK] Gravada cena: {slug_path}")
        
        # Nome canônico compatível com carregador por código (region_00X.tscn)
        num_path = f"scenes/world/regions/region_{r['num']:03d}.tscn"
        with open(num_path, "w", encoding="utf-8") as f:
            f.write(tscn_content)
        print(f"[OK] Gravada cena compatível: {num_path}")

    # 2. Atualiza os 10 arquivos .tres em data/content/regions/
    for r in REGIONS:
        tres_path = f"data/content/regions/region_{r['num']:03d}.tres"
        with open(tres_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Altera display_name
        content = re.sub(r'display_name = "[^"]+"', f'display_name = "{r["name"]}"', content)
        # Altera status para full_production
        content = re.sub(r'status = "[^"]+"', 'status = "full_production"', content)
        # Altera scene_path para a cena dedicada
        scene_target = f"res://scenes/world/regions/{r['slug']}.tscn"
        content = re.sub(r'scene_path = "[^"]+"', f'scene_path = "{scene_target}"', content)
        # Limpa pending_assets para PackedStringArray()
        content = re.sub(r'pending_assets = PackedStringArray\([^)]*\)', 'pending_assets = PackedStringArray()', content)
        if 'pending_assets =' not in content:
            content += '\npending_assets = PackedStringArray()\n'

        with open(tres_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[OK] Atualizado Resource RegionData: {tres_path} -> {r['name']} (full_production)")

if __name__ == "__main__":
    main()
