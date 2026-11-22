import os

REGIONS_DATA = [
    # Veyrath (CONT-01)
    {"id": "REG-001", "name": "Planície Cinzenta de Veyrath", "cont": "CONT-01", "biome": "ash_plains", "lvl": (1, 10), "boss": "BOSS-001", "status": "full_production", "scene": "res://scenes/world/regions/region_001.tscn", "conns": ["REG-002", "REG-003"], "city": "Baluarte das Cinzas", "dung": "Catacumbas de Basalto"},
    {"id": "REG-002", "name": "Fendas de Enxofre", "cont": "CONT-01", "biome": "sulfur_fissures", "lvl": (5, 15), "boss": "BOSS-002", "conns": ["REG-001", "REG-004"], "city": "Acampamento dos Fundidores", "dung": "Fossa Fumegante"},
    {"id": "REG-003", "name": "Picos de Basalto", "cont": "CONT-01", "biome": "basalt_peaks", "lvl": (8, 18), "boss": "BOSS-003", "conns": ["REG-001", "REG-005"], "city": "Guarnição da Rocha Negra", "dung": "Mina de Ferro Negro"},
    {"id": "REG-004", "name": "Caldeira Ardente", "cont": "CONT-01", "biome": "magma_caldera", "lvl": (12, 22), "boss": "BOSS-004", "conns": ["REG-002", "REG-006"], "city": "Refúgio da Brasa", "dung": "Templo do Magma"},
    {"id": "REG-005", "name": "Garganta de Lava", "cont": "CONT-01", "biome": "lava_canyon", "lvl": (15, 25), "boss": "BOSS-005", "conns": ["REG-003", "REG-006"], "city": "Posto da Ponte de Ferro", "dung": "Profundezas Ígneas"},
    {"id": "REG-006", "name": "Ermos Calcinados", "cont": "CONT-01", "biome": "charred_wastes", "lvl": (18, 28), "boss": "BOSS-006", "conns": ["REG-004", "REG-005", "REG-007"], "city": "Acampamento Cinzento", "dung": "Cripta das Cinzas"},
    {"id": "REG-007", "name": "Vale das Brasas", "cont": "CONT-01", "biome": "ember_valley", "lvl": (22, 32), "boss": "BOSS-007", "conns": ["REG-006", "REG-008"], "city": "Vila dos Vidreiros", "dung": "Caverna Rubra"},
    {"id": "REG-008", "name": "Fronteira Obsidiana", "cont": "CONT-01", "biome": "obsidian_border", "lvl": (25, 35), "boss": "BOSS-008", "conns": ["REG-007", "REG-009"], "city": "Fortaleza Obsidiana", "dung": "Labirinto Vitrificado"},
    {"id": "REG-009", "name": "Cratera do Eco Ígneo", "cont": "CONT-01", "biome": "fire_crater", "lvl": (28, 38), "boss": "", "conns": ["REG-008", "REG-010"], "city": "Observatório Calcinado", "dung": "Poço Primordial"},
    {"id": "REG-010", "name": "Altar da Forja Antiga", "cont": "CONT-01", "biome": "ancient_forge_altar", "lvl": (30, 40), "boss": "", "conns": ["REG-009"], "city": "Santuário dos Martelos", "dung": "Câmara do Grande Fole"},

    # Sylvaran (CONT-02)
    {"id": "REG-011", "name": "Bosque dos Sussurros", "cont": "CONT-02", "biome": "whispering_woods", "lvl": (10, 20), "boss": "BOSS-009", "conns": ["REG-012", "REG-013"], "city": "Vila da Seiva", "dung": "Catacumbas das Raízes"},
    {"id": "REG-012", "name": "Pântano de Espinhos", "cont": "CONT-02", "biome": "thorn_marsh", "lvl": (14, 24), "boss": "BOSS-010", "conns": ["REG-011", "REG-014"], "city": "Refúgio do Lodo", "dung": "Covil da Peçonha"},
    {"id": "REG-013", "name": "Copas Ancestrais", "cont": "CONT-02", "biome": "ancient_canopy", "lvl": (18, 28), "boss": "BOSS-011", "conns": ["REG-011", "REG-015"], "city": "Aldeia das Pontes", "dung": "Ninho dos Galhos"},
    {"id": "REG-014", "name": "Clareira Espectral", "cont": "CONT-02", "biome": "spectral_glade", "lvl": (20, 30), "boss": "BOSS-012", "conns": ["REG-012", "REG-016"], "city": "Círculo dos Druidas Negros", "dung": "Túmulo das Fadas Afogadas"},
    {"id": "REG-015", "name": "Raízes Abissais", "cont": "CONT-02", "biome": "abyssal_roots", "lvl": (24, 34), "boss": "BOSS-013", "conns": ["REG-013", "REG-016"], "city": "Posto da Madeira Oca", "dung": "Labirinto Subterrâneo"},
    {"id": "REG-016", "name": "Garganta dos Fungos", "cont": "CONT-02", "biome": "fungal_hollow", "lvl": (26, 36), "boss": "BOSS-014", "conns": ["REG-014", "REG-015", "REG-017"], "city": "Colônia dos Esporos", "dung": "Caverna da Bioluminescência"},
    {"id": "REG-017", "name": "Bosque Petrificado de Sylvaran", "cont": "CONT-02", "biome": "petrified_grove", "lvl": (30, 40), "boss": "BOSS-015", "conns": ["REG-016", "REG-018"], "city": "Vila da Pedra Viva", "dung": "Monólito Arbóreo"},
    {"id": "REG-018", "name": "Pântano Negro", "cont": "CONT-02", "biome": "black_marsh", "lvl": (32, 42), "boss": "BOSS-016", "conns": ["REG-017", "REG-019"], "city": "Acampamento do Nevoeiro", "dung": "Abismo de Lodo"},
    {"id": "REG-019", "name": "Dossel Crepuscular", "cont": "CONT-02", "biome": "twilight_canopy", "lvl": (35, 45), "boss": "", "conns": ["REG-018", "REG-020"], "city": "Observatório das Brumas", "dung": "Torre dos Galhos Quebrados"},
    {"id": "REG-020", "name": "Coração da Seiva Negra", "cont": "CONT-02", "biome": "heart_of_black_sap", "lvl": (38, 48), "boss": "", "conns": ["REG-019"], "city": "Altar da Árvore Mãe", "dung": "Santuário Primordial da Corrupção"},

    # Khar-Duum (CONT-03)
    {"id": "REG-021", "name": "Deserto de Cinzas", "cont": "CONT-03", "biome": "ash_desert", "lvl": (20, 30), "boss": "BOSS-017", "conns": ["REG-022", "REG-023"], "city": "Caravansarai das Dunas", "dung": "Cripta dos Nômades"},
    {"id": "REG-022", "name": "Cânion dos Ossos", "cont": "CONT-03", "biome": "bone_canyon", "lvl": (24, 34), "boss": "BOSS-018", "conns": ["REG-021", "REG-024"], "city": "Posto da Mandíbula", "dung": "Fossa dos Titãs"},
    {"id": "REG-023", "name": "Ruínas Ciclópicas", "cont": "CONT-03", "biome": "cyclopean_ruins", "lvl": (26, 36), "boss": "BOSS-019", "conns": ["REG-021", "REG-025"], "city": "Bastião de Pedra Polida", "dung": "Templo dos Pilares Quebrados"},
    {"id": "REG-024", "name": "Planalto dos Titãs", "cont": "CONT-03", "biome": "titans_plateau", "lvl": (28, 38), "boss": "BOSS-020", "conns": ["REG-022", "REG-026"], "city": "Acampamento da Viga Alta", "dung": "Túmulo do Colosso"},
    {"id": "REG-025", "name": "Dunas Vermelhas", "cont": "CONT-03", "biome": "red_dunes", "lvl": (30, 40), "boss": "BOSS-021", "conns": ["REG-023", "REG-026"], "city": "Oásis Carmesim", "dung": "Pirâmide Soterrada"},
    {"id": "REG-026", "name": "Necrópole das Areias", "cont": "CONT-03", "biome": "sand_necropolis", "lvl": (34, 44), "boss": "BOSS-022", "conns": ["REG-024", "REG-025", "REG-027"], "city": "Posto dos Guardiões", "dung": "Câmara dos Sarcófagos"},
    {"id": "REG-027", "name": "Passo dos Ventos Uivantes", "cont": "CONT-03", "biome": "howling_pass", "lvl": (36, 46), "boss": "BOSS-023", "conns": ["REG-026", "REG-028"], "city": "Fortaleza do Desfiladeiro", "dung": "Garganta do Eco"},
    {"id": "REG-028", "name": "Ravina Solar", "cont": "CONT-03", "biome": "solar_ravine", "lvl": (38, 48), "boss": "", "conns": ["REG-027", "REG-029"], "city": "Mosteiro do Eclipse", "dung": "Templo da Luz Morta"},
    {"id": "REG-029", "name": "Oásis do Sangue Seco", "cont": "CONT-03", "biome": "dried_blood_oasis", "lvl": (40, 50), "boss": "", "conns": ["REG-028", "REG-030"], "city": "Aldeia do Poço Amargo", "dung": "Profundezas Áridas"},
    {"id": "REG-030", "name": "Monólitos Esquecidos", "cont": "CONT-03", "biome": "forgotten_megaliths", "lvl": (42, 52), "boss": "", "conns": ["REG-029"], "city": "Santuário de Basalto e Areia", "dung": "Círculo dos Titãs de Pedra"},

    # Nhal'Kora (CONT-04)
    {"id": "REG-031", "name": "Falésias Espectrais", "cont": "CONT-04", "biome": "spectral_cliffs", "lvl": (30, 40), "boss": "BOSS-024", "conns": ["REG-032", "REG-033"], "city": "Porto dos Desesperados", "dung": "Caverna da Maré Alta"},
    {"id": "REG-032", "name": "Recife da Maré Negra", "cont": "CONT-04", "biome": "black_tide_reef", "lvl": (32, 42), "boss": "BOSS-025", "conns": ["REG-031", "REG-034"], "city": "Vila dos Pescadores Cegos", "dung": "Covil do Coral Negro"},
    {"id": "REG-033", "name": "Fossa dos Lamentos", "cont": "CONT-04", "biome": "trench_of_wails", "lvl": (35, 45), "boss": "BOSS-026", "conns": ["REG-031", "REG-035"], "city": "Acampamento da Borda Abissal", "dung": "Garganta Submersa"},
    {"id": "REG-034", "name": "Geleiras Abissais", "cont": "CONT-04", "biome": "abyssal_glaciers", "lvl": (38, 48), "boss": "BOSS-027", "conns": ["REG-032", "REG-036"], "city": "Refúgio do Gelo Quebrado", "dung": "Catacumbas Congeladas"},
    {"id": "REG-035", "name": "Angra das Almas Afogadas", "cont": "CONT-04", "biome": "drowned_cove", "lvl": (40, 50), "boss": "BOSS-028", "conns": ["REG-033", "REG-036"], "city": "Aldeia das Quinas de Naufrágio", "dung": "Cripta das Marés Fétidas"},
    {"id": "REG-036", "name": "Costa Tóxica", "cont": "CONT-04", "biome": "toxic_coast", "lvl": (42, 52), "boss": "BOSS-029", "conns": ["REG-034", "REG-035", "REG-037"], "city": "Posto dos Alquimistas da Névoa", "dung": "Fossa dos Vapores Verdes"},
    {"id": "REG-037", "name": "Fiorde das Sombras", "cont": "CONT-04", "biome": "shadow_fjord", "lvl": (44, 54), "boss": "BOSS-030", "conns": ["REG-036", "REG-038"], "city": "Fortaleza da Vigia Negra", "dung": "Cidadela do Fiorde Profundo"},
    {"id": "REG-038", "name": "Gruta da Maré Eterna", "cont": "CONT-04", "biome": "eternal_surge_grotto", "lvl": (46, 56), "boss": "", "conns": ["REG-037", "REG-039"], "city": "Santuário dos Ecos Marinhos", "dung": "Labirinto das Cavernas Alagadas"},
    {"id": "REG-039", "name": "Promontório dos Naufrágios", "cont": "CONT-04", "biome": "shipwreck_promontory", "lvl": (48, 58), "boss": "", "conns": ["REG-038", "REG-040"], "city": "Farol da Luz Morta", "dung": "Cemitério das Quilhas Quebradas"},
    {"id": "REG-040", "name": "Abismo Oceânico Primordial", "cont": "CONT-04", "biome": "primordial_ocean_abyss", "lvl": (50, 60), "boss": "", "conns": ["REG-039"], "city": "Plataforma do Vazio Oceânico", "dung": "Portal das Fossas Profundas"},
]

LIGHTING_PROFILES = {
    "CONT-01": {"sun_color": "#e8a478", "sun_energy": 1.3, "ambient_color": "#2c1d24", "fog_enabled": True, "fog_color": "#382329", "fog_density": 0.008},
    "CONT-02": {"sun_color": "#9be0b2", "sun_energy": 1.1, "ambient_color": "#182a20", "fog_enabled": True, "fog_color": "#1f382b", "fog_density": 0.012},
    "CONT-03": {"sun_color": "#f8c888", "sun_energy": 1.4, "ambient_color": "#32241c", "fog_enabled": True, "fog_color": "#3d2e24", "fog_density": 0.006},
    "CONT-04": {"sun_color": "#88c2e8", "sun_energy": 1.0, "ambient_color": "#182236", "fog_enabled": True, "fog_color": "#1e2a44", "fog_density": 0.015},
}

def generate_region_tres(reg_info):
    r_id = reg_info["id"]
    r_num = int(r_id.split("-")[1])
    c_id = reg_info["cont"]
    name = reg_info["name"]
    biome = reg_info["biome"]
    lvl = reg_info["lvl"]
    boss = reg_info.get("boss", "")
    status = reg_info.get("status", "modular_staging")
    scene = reg_info.get("scene", "res://scenes/world/modular_region.tscn")
    conns = reg_info["conns"]
    city = reg_info["city"]
    dung = reg_info["dung"]
    light = LIGHTING_PROFILES[c_id]

    # Calculate demons assigned (5 per region)
    start_demon = (r_num - 1) * 5 + 1
    end_demon = start_demon + 4
    demons = [f"DEMON-{i:03d}" for i in range(start_demon, end_demon + 1)]

    # Generate POIs
    pois = [
        {
            "id": f"poi_{r_id.lower()}_city",
            "name": city,
            "type": "city",
            "position": "Vector3(0, 0, 0)",
            "description": f"Assentamento e zona segura da região {name}.",
            "discovery_xp": 100
        },
        {
            "id": f"poi_{r_id.lower()}_dung",
            "name": dung,
            "type": "dungeon",
            "position": "Vector3(-50, 0, -40)",
            "description": f"Entrada da masmorra {dung} (nível recomendado {lvl[0]}+).",
            "discovery_xp": 80
        },
        {
            "id": f"poi_{r_id.lower()}_landmark",
            "name": f"Marco de {name}",
            "type": "exploration",
            "position": "Vector3(45, 3, 30)",
            "description": f"Ponto de observação e marco de exploração de {name}.",
            "discovery_xp": 60
        }
    ]

    if boss:
        pois.append({
            "id": f"poi_{r_id.lower()}_boss_arena",
            "name": f"Arena de {boss}",
            "type": "boss_arena",
            "position": "Vector3(0, 0, -60)",
            "description": f"Recinto de combate onde habita o Chefe {boss}.",
            "discovery_xp": 150
        })

    pois.append({
        "id": f"poi_{r_id.lower()}_portal",
        "name": f"Portal de {name}",
        "type": "portal",
        "position": "Vector3(30, 0, 20)",
        "description": "Portal arcano conectado à rede de viagem rápida.",
        "discovery_xp": 50
    })

    # Gates to connections
    gates = []
    positions = [
        "Vector3(0, 0, -95)",
        "Vector3(0, 0, 95)",
        "Vector3(95, 0, 0)",
        "Vector3(-95, 0, 0)"
    ]
    gate_names = ["gate_north", "gate_south", "gate_east", "gate_west"]
    opp_names = ["gate_south", "gate_north", "gate_west", "gate_east"]

    for idx, target in enumerate(conns):
        gates.append({
            "gate_id": gate_names[idx % 4],
            "target_region": target,
            "target_spawn": opp_names[idx % 4],
            "position": positions[idx % 4],
            "radius": 5.0
        })

    portals = [
        {
            "portal_id": f"portal_{r_id.lower()}_hub",
            "target_region": "hell_forge",
            "target_spawn": "default",
            "position": "Vector3(30, 0, 20)",
            "is_intercontinental": True
        }
    ]

    # Enemy spawns
    spawns = []
    offsets = [
        "Vector3(35, 0, -45)",
        "Vector3(-40, 0, 60)",
        "Vector3(-70, 0, -15)",
        "Vector3(20, 0, 65)",
        "Vector3(-30, 0, -75)"
    ]
    for idx, d_id in enumerate(demons):
        spawns.append({
            "spawn_id": f"spawn_{d_id.lower()}",
            "demon_id": d_id,
            "position": offsets[idx],
            "radius": 6.0,
            "count": 2 if idx != 3 else 4
        })

    # Pending assets for modular staging
    pending = []
    if status != "full_production":
        pending = [
            f"model_glb_terrain_{r_id.lower()}",
            f"model_glb_foliage_{biome}",
            f"model_glb_structures_{city.lower().replace(' ', '_')}",
            f"vfx_{biome}_environment"
        ]

    # Build TRES text
    conns_str = ", ".join(['"' + c + '"' for c in conns])
    lines = [
        '[gd_resource type="Resource" script_class="RegionData" load_steps=2 format=3]',
        '',
        '[ext_resource type="Script" path="res://data/models/region_data.gd" id="1_region"]',
        '',
        '[resource]',
        'script = ExtResource("1_region")',
        f'id = &"{r_id}"',
        f'display_name = "{name}"',
        f'continent_id = &"{c_id}"',
        f'description = "Região {name} no continente {c_id}. Bioma {biome}, nível recomendado {lvl[0]}-{lvl[1]}."',
        f'biome = "{biome}"',
        f'level_range = Vector2i({lvl[0]}, {lvl[1]})',
        f'connections = PackedStringArray({conns_str})',
        'boundaries = {',
        '"border_barrier": true,',
        '"center": Vector3(0, 0, 0),',
        '"radius": 120.0',
        '}',
        'lighting_profile = {',
        f'"ambient_color": "{light["ambient_color"]}",',
        f'"fog_color": "{light["fog_color"]}",',
        f'"fog_density": {light["fog_density"]},',
        f'"fog_enabled": {"true" if light["fog_enabled"] else "false"},',
        f'"sun_color": "{light["sun_color"]}",',
        f'"sun_energy": {light["sun_energy"]}',
        '}',
        f'scene_path = "{scene}"',
        f'status = "{status}"',
    ]

    # POIs string
    pois_str_list = []
    for p in pois:
        pois_str_list.append('{\n' + f'"description": "{p["description"]}",\n"discovery_xp": {p["discovery_xp"]},\n"id": "{p["id"]}",\n"name": "{p["name"]}",\n"position": {p["position"]},\n"type": "{p["type"]}"\n' + '}')
    lines.append('points_of_interest = [' + ', '.join(pois_str_list) + ']')

    # Gates string
    gates_str_list = []
    for g in gates:
        gates_str_list.append('{\n' + f'"gate_id": "{g["gate_id"]}",\n"position": {g["position"]},\n"radius": {g["radius"]},\n"target_region": "{g["target_region"]}",\n"target_spawn": "{g["target_spawn"]}"\n' + '}')
    lines.append('gates = [' + ', '.join(gates_str_list) + ']')

    # Portals string
    portals_str_list = []
    for pt in portals:
        portals_str_list.append('{\n' + f'"is_intercontinental": {"true" if pt["is_intercontinental"] else "false"},\n"portal_id": "{pt["portal_id"]}",\n"position": {pt["position"]},\n"target_region": "{pt["target_region"]}",\n"target_spawn": "{pt["target_spawn"]}"\n' + '}')
    lines.append('portals = [' + ', '.join(portals_str_list) + ']')

    # Spawns string
    spawns_str_list = []
    for s in spawns:
        spawns_str_list.append('{\n' + f'"count": {s["count"]},\n"demon_id": "{s["demon_id"]}",\n"position": {s["position"]},\n"radius": {s["radius"]},\n"spawn_id": "{s["spawn_id"]}"\n' + '}')
    lines.append('enemy_spawns = [' + ', '.join(spawns_str_list) + ']')

    if boss:
        lines.append(f'boss_encounter_id = &"{boss}"')
        lines.append('boss_arena = {\n"arena_name": "Arena de ' + boss + '",\n"hazards": PackedStringArray(),\n"position": Vector3(0, 0, -60),\n"radius": 18.0\n}')
    else:
        lines.append('boss_encounter_id = &""')
        lines.append('boss_arena = {}')

    if pending:
        lines.append('pending_assets = PackedStringArray(' + ', '.join([f'"{pa}"' for pa in pending]) + ')')
    else:
        lines.append('pending_assets = PackedStringArray()')

    return "\n".join(lines) + "\n"

def main():
    out_dir = r"c:\Users\fred_\Downloads\Abyssal Pact\data\content\regions"
    for reg in REGIONS_DATA:
        filename = f"region_{int(reg['id'].split('-')[1]):03d}.tres"
        path = os.path.join(out_dir, filename)
        content = generate_region_tres(reg)
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Generated {filename}")

if __name__ == "__main__":
    main()
