"""
ABYSSAL PACT — Modelagem 3D dos Monumentos e Ambientes de Khar-Duum (Blender 5.3+ Headless)

Constrói proceduralmente os assets e estruturas exclusivas para as 10 regiões de KHAR-DUUM (REG-021 a REG-030):
21. Caldeira Rubra:
    - structure_rubra_caldera_vent (Structures): Chaminé vulcânica monumental com anéis de magma
    - prop_volcanic_vent_horn (Props): Corneta vulcânica com fenda de lava ativa
22. Fornalha dos Reis:
    - structure_kings_forge_citadel (Structures): Cidadela-forja monumental com 4 chaminés industriais
    - prop_colossal_forge_anvil (Props): Bigorna colossal de adamante com martelo suspenso
23. Desfiladeiro de Obsidiana:
    - rock_obsidian_canyon_gate (Rocks): Portal natural de pináculos facetados de obsidiana negra
24. Mar de Escória:
    - structure_slag_refinery_furnace (Structures): Fornalha de refino e torres de decantação de escória
25. Dunas de Vidro Negro:
    - rock_vitrified_glass_dune_ridge (Rocks): Crista de duna vitrificada com espículas de vidro escuro
26. Minas de Tharum:
    - structure_tharum_mine_headframe (Structures): Torre de extração mineira com roda de cabos e pórtico
    - prop_mining_ore_cart_track (Props): Vagonete de minério pesado sobre trilhos retorcidos
27. Ponte das Correntes:
    - structure_monumental_chain_bridge (Structures): Pilar colossal com elos titânicos de sustentação
    - prop_titan_chain_link (Props): Elo ciclópeo de ferro forjado ancorado em rocha
28. Planalto do Trovão:
    - structure_lightning_conductor_spire (Structures): Obelisco metálico condutor de relâmpagos
29. Garganta do Carvão:
    - rock_coal_chasm_archway (Rocks): Arco monumental de caverna subterrânea em antracito
30. Cratera do Coração:
    - structure_heart_crater_monolith (Structures): Monolito primordial com anéis de contenção runados

Regras:
- Arquivos .blend salvos em: AbyssalPact_ArtSource/Blender/{Structures, Props, Rocks}
- Arquivos .glb exportados para: assets/models/environment/{structures, props, rocks}
"""

import bpy
import math
import os
import sys

GAME_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ART_SOURCE_DIR = os.path.abspath(os.path.join(GAME_DIR, "..", "AbyssalPact_ArtSource", "Blender"))
MODELS_OUT_DIR = os.path.join(GAME_DIR, "assets", "models", "environment")

def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for block in (bpy.data.meshes, bpy.data.materials, bpy.data.textures, bpy.data.images):
        for item in list(block):
            block.remove(item)

def create_material(name, base_color, roughness=0.8, metallic=0.0, emission=None, emission_strength=1.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = base_color
        bsdf.inputs["Roughness"].default_value = roughness
        bsdf.inputs["Metallic"].default_value = metallic
        if emission:
            if "Emission Color" in bsdf.inputs:
                bsdf.inputs["Emission Color"].default_value = emission
            elif "Emission" in bsdf.inputs:
                bsdf.inputs["Emission"].default_value = emission
            if "Emission Strength" in bsdf.inputs:
                bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat

def export_asset(name, category, obj_list):
    blend_dir = os.path.join(ART_SOURCE_DIR, category)
    glb_dir = os.path.join(MODELS_OUT_DIR, category.lower())
    os.makedirs(blend_dir, exist_ok=True)
    os.makedirs(glb_dir, exist_ok=True)

    blend_path = os.path.join(blend_dir, f"{name}.blend")
    glb_path = os.path.join(glb_dir, f"{name}.glb")

    bpy.ops.object.select_all(action="DESELECT")
    for obj in obj_list:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = obj_list[0]

    bpy.ops.wm.save_as_mainfile(filepath=blend_path)

    bpy.ops.export_scene.gltf(
        filepath=glb_path,
        export_format='GLB',
        use_selection=True,
        export_apply=True,
        export_yup=True
    )

    size = os.path.getsize(glb_path)
    print(f"[EXPORT OK] {category}/{name} -> GLB: {size:,} bytes | BLEND: {blend_path}")
    return glb_path

# ==============================================================================
# 21. CALDEIRA RUBRA (REG-021)
# ==============================================================================

def build_rubra_caldera_vent():
    clear_scene()
    mat_basalt = create_material("mat_caldera_basalt", (0.16, 0.13, 0.12, 1.0), roughness=0.9, metallic=0.1)
    mat_magma = create_material(
        "mat_caldera_magma",
        (1.0, 0.35, 0.05, 1.0),
        roughness=0.2,
        emission=(1.0, 0.40, 0.08, 1.0),
        emission_strength=4.8
    )

    # Chaminé vulcânica principal truncada
    bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=6.5, radius2=3.8, depth=9.0, location=(0, 0, 4.5))
    vent = bpy.context.active_object
    vent.name = "Caldera_Vent_Cone"
    vent.data.materials.append(mat_basalt)

    # Bacia de magma incandescente no topo da cratera
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=3.4, depth=0.6, location=(0, 0, 8.8))
    magma_pool = bpy.context.active_object
    magma_pool.name = "Crater_Magma_Pool"
    magma_pool.data.materials.append(mat_magma)

    # Nervuras rochosas basálticas em volta
    ribs = []
    for i in range(4):
        angle = (math.pi / 2.0) * i
        rx = math.cos(angle) * 5.2
        ry = math.sin(angle) * 5.2
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(rx, ry, 3.5))
        rib = bpy.context.active_object
        rib.name = f"Caldera_Rib_{i+1}"
        rib.scale = (2.2, 1.2, 7.0)
        rib.rotation_euler = (0, math.radians(15), angle)
        rib.data.materials.append(mat_basalt)
        ribs.append(rib)

    objs = [vent, magma_pool] + ribs
    return export_asset("structure_rubra_caldera_vent", "Structures", objs)

def build_volcanic_vent_horn():
    clear_scene()
    mat_crust = create_material("mat_horn_crust", (0.18, 0.14, 0.12, 1.0), roughness=0.85)
    mat_lava = create_material(
        "mat_horn_lava",
        (1.0, 0.42, 0.05, 1.0),
        roughness=0.2,
        emission=(1.0, 0.45, 0.05, 1.0),
        emission_strength=4.0
    )

    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=2.2, radius2=0.6, depth=4.2, location=(0, 0, 2.1))
    horn = bpy.context.active_object
    horn.name = "Vent_Horn"
    horn.rotation_euler = (math.radians(8), math.radians(-5), 0)
    horn.data.materials.append(mat_crust)

    # Fenda de lava no ápice
    bpy.ops.mesh.primitive_cylinder_add(radius=0.5, depth=0.4, location=(0.1, -0.1, 4.1))
    lava = bpy.context.active_object
    lava.name = "Vent_Lava_Mouth"
    lava.data.materials.append(mat_lava)

    objs = [horn, lava]
    return export_asset("prop_volcanic_vent_horn", "Props", objs)

# ==============================================================================
# 22. FORNALHA DOS REIS (REG-022) — CIDADE-FORJA MONUMENTAL
# ==============================================================================

def build_kings_forge_citadel():
    clear_scene()
    mat_iron = create_material("mat_forge_iron", (0.16, 0.15, 0.17, 1.0), roughness=0.45, metallic=0.85)
    mat_stone = create_material("mat_forge_masonry", (0.24, 0.20, 0.18, 1.0), roughness=0.8, metallic=0.1)
    mat_molten = create_material(
        "mat_molten_gold_iron",
        (1.0, 0.55, 0.12, 1.0),
        roughness=0.15,
        emission=(1.0, 0.60, 0.15, 1.0),
        emission_strength=5.0
    )

    # Base da grande cidadela-forja
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 3.0))
    base = bpy.context.active_object
    base.name = "Forge_Citadel_Keep"
    base.scale = (20.0, 16.0, 6.0)
    base.data.materials.append(mat_stone)

    # Grande Portal da Fornalha com arco de ferro maciço
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -8.2, 3.5))
    gate = bpy.context.active_object
    gate.name = "Furnace_Gate_Arch"
    gate.scale = (8.0, 1.5, 6.5)
    gate.data.materials.append(mat_iron)

    # Calha de metal fundido saindo do portal
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -6.5, 0.4))
    gutter = bpy.context.active_object
    gutter.name = "Molten_Metal_Gutter"
    gutter.scale = (3.5, 9.0, 0.6)
    gutter.data.materials.append(mat_molten)

    # 4 Chaminés industriais colossais nos vértices
    chimneys = []
    coords = [(-8.0, -6.0), (8.0, -6.0), (-8.0, 6.0), (8.0, 6.0)]
    for idx, (cx, cy) in enumerate(coords):
        bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=1.6, depth=14.0, location=(cx, cy, 10.0))
        ch = bpy.context.active_object
        ch.name = f"Great_Smokestack_{idx+1}"
        ch.data.materials.append(mat_iron)
        chimneys.append(ch)

    # Bigorna heráldica no topo central da cidadela
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 7.5))
    crest = bpy.context.active_object
    crest.name = "Forge_Crest_Pedestal"
    crest.scale = (6.0, 5.0, 3.0)
    crest.data.materials.append(mat_iron)

    objs = [base, gate, gutter, crest] + chimneys
    return export_asset("structure_kings_forge_citadel", "Structures", objs)

def build_colossal_forge_anvil():
    clear_scene()
    mat_anvil_steel = create_material("mat_anvil_steel", (0.18, 0.17, 0.20, 1.0), roughness=0.35, metallic=0.9)
    mat_heat_core = create_material(
        "mat_anvil_heat",
        (1.0, 0.48, 0.10, 1.0),
        roughness=0.2,
        emission=(1.0, 0.50, 0.12, 1.0),
        emission_strength=4.2
    )

    # Base da bigorna
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.0))
    base = bpy.context.active_object
    base.name = "Anvil_Plinth"
    base.scale = (4.5, 3.5, 2.0)
    base.data.materials.append(mat_anvil_steel)

    # Corpo e chifre da bigorna
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 2.8))
    body = bpy.context.active_object
    body.name = "Anvil_Face"
    body.scale = (6.0, 2.6, 1.6)
    body.data.materials.append(mat_anvil_steel)

    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=1.3, radius2=0.2, depth=2.8, location=(3.8, 0, 2.8))
    horn = bpy.context.active_object
    horn.name = "Anvil_Horn"
    horn.rotation_euler = (0, math.radians(90), 0)
    horn.data.materials.append(mat_anvil_steel)

    # Núcleo incandescente de forjamento
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 3.65))
    core = bpy.context.active_object
    core.name = "Ingot_Forging_Glow"
    core.scale = (2.2, 1.2, 0.3)
    core.data.materials.append(mat_heat_core)

    objs = [base, body, horn, core]
    return export_asset("prop_colossal_forge_anvil", "Props", objs)

# ==============================================================================
# 23. DESFILADEIRO DE OBSIDIANA (REG-023)
# ==============================================================================

def build_obsidian_canyon_gate():
    clear_scene()
    mat_obsidian = create_material("mat_pure_obsidian", (0.05, 0.05, 0.06, 1.0), roughness=0.08, metallic=0.2)
    mat_lava_seam = create_material(
        "mat_obsidian_lava_seam",
        (1.0, 0.35, 0.05, 1.0),
        roughness=0.2,
        emission=(1.0, 0.38, 0.06, 1.0),
        emission_strength=4.0
    )

    # Agulha esquerda de obsidiana facetada
    bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=4.2, radius2=0.6, depth=16.0, location=(-6.0, 0, 8.0))
    left_spire = bpy.context.active_object
    left_spire.name = "Obsidian_Spire_Left"
    left_spire.rotation_euler = (math.radians(-6), math.radians(8), math.radians(15))
    left_spire.data.materials.append(mat_obsidian)

    # Agulha direita de obsidiana facetada
    bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=4.5, radius2=0.5, depth=17.5, location=(6.0, 0, 8.75))
    right_spire = bpy.context.active_object
    right_spire.name = "Obsidian_Spire_Right"
    right_spire.rotation_euler = (math.radians(5), math.radians(-8), math.radians(-12))
    right_spire.data.materials.append(mat_obsidian)

    # Veio de lava entre os pilares
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.2))
    seam = bpy.context.active_object
    seam.name = "Lava_Seam_Passage"
    seam.scale = (8.0, 3.0, 0.4)
    seam.data.materials.append(mat_lava_seam)

    objs = [left_spire, right_spire, seam]
    return export_asset("rock_obsidian_canyon_gate", "Rocks", objs)

# ==============================================================================
# 24. MAR DE ESCÓRIA (REG-024)
# ==============================================================================

def build_slag_refinery_furnace():
    clear_scene()
    mat_slag_crust = create_material("mat_slag_iron_crust", (0.15, 0.13, 0.13, 1.0), roughness=0.88, metallic=0.4)
    mat_furnace_glow = create_material(
        "mat_slag_combustion",
        (0.95, 0.40, 0.08, 1.0),
        roughness=0.25,
        emission=(0.98, 0.42, 0.10, 1.0),
        emission_strength=4.2
    )

    # Cuba cilíndrica de fundição
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=5.5, depth=6.0, location=(0, 0, 3.0))
    vat = bpy.context.active_object
    vat.name = "Slag_Refinery_Vat"
    vat.data.materials.append(mat_slag_crust)

    # Torre de escape cônica superior
    bpy.ops.mesh.primitive_cone_add(vertices=10, radius1=5.0, radius2=2.2, depth=7.0, location=(0, 0, 9.5))
    funnel = bpy.context.active_object
    funnel.name = "Slag_Exhaust_Funnel"
    funnel.data.materials.append(mat_slag_crust)

    # Aberturas incandescentes de purga de escória
    ports = []
    for i in range(3):
        pa = (2.0 * math.pi / 3.0) * i
        px = math.cos(pa) * 5.2
        py = math.sin(pa) * 5.2
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(px, py, 1.6))
        port = bpy.context.active_object
        port.name = f"Slag_Purge_Port_{i+1}"
        port.scale = (1.8, 1.2, 1.6)
        port.rotation_euler = (0, 0, pa)
        port.data.materials.append(mat_furnace_glow)
        ports.append(port)

    objs = [vat, funnel] + ports
    return export_asset("structure_slag_refinery_furnace", "Structures", objs)

# ==============================================================================
# 25. DUNAS DE VIDRO NEGRO (REG-025)
# ==============================================================================

def build_vitrified_glass_dune_ridge():
    clear_scene()
    mat_vitrified = create_material("mat_vitrified_glass", (0.08, 0.10, 0.12, 1.0), roughness=0.12, metallic=0.3)
    mat_black_sand = create_material("mat_magnetic_black_sand", (0.12, 0.11, 0.11, 1.0), roughness=0.92)

    # Crista da duna de areia negra fundida
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.8))
    dune = bpy.context.active_object
    dune.name = "Black_Sand_Dune_Base"
    dune.scale = (16.0, 7.0, 3.5)
    dune.rotation_euler = (math.radians(10), math.radians(-6), math.radians(20))
    dune.data.materials.append(mat_black_sand)

    # Espículas e lascas de vidro escuro projetando-se da areia
    spicules = []
    for i in range(5):
        sx = -6.0 + i * 3.0
        sy = 0.5 * (i % 2)
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=1.4, radius2=0.1, depth=5.5, location=(sx, sy, 4.0))
        spic = bpy.context.active_object
        spic.name = f"Glass_Shard_{i+1}"
        spic.rotation_euler = (math.radians(15 * (i % 3 - 1)), math.radians(-25), math.radians(i * 35))
        spic.data.materials.append(mat_vitrified)
        spicules.append(spic)

    objs = [dune] + spicules
    return export_asset("rock_vitrified_glass_dune_ridge", "Rocks", objs)

# ==============================================================================
# 26. MINAS DE THARUM (REG-026) — COMPLEXIDADE SUBTERRÂNEA
# ==============================================================================

def build_tharum_mine_headframe():
    clear_scene()
    mat_mine_timber = create_material("mat_mine_petrified_timber", (0.22, 0.17, 0.14, 1.0), roughness=0.85)
    mat_mine_iron = create_material("mat_mine_riveted_iron", (0.17, 0.16, 0.18, 1.0), roughness=0.5, metallic=0.8)

    # Pórtico de escoramento de galeria em madeira petrificada
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-4.0, 0, 4.5))
    leg_l = bpy.context.active_object
    leg_l.name = "Timber_Post_Left"
    leg_l.scale = (1.2, 1.2, 9.0)
    leg_l.data.materials.append(mat_mine_timber)

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(4.0, 0, 4.5))
    leg_r = bpy.context.active_object
    leg_r.name = "Timber_Post_Right"
    leg_r.scale = (1.2, 1.2, 9.0)
    leg_r.data.materials.append(mat_mine_timber)

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 9.2))
    lintel = bpy.context.active_object
    lintel.name = "Timber_Crossbeam"
    lintel.scale = (10.0, 1.4, 1.4)
    lintel.data.materials.append(mat_mine_timber)

    # Torre de extração com roda de cabos (headframe)
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=2.5, depth=0.8, location=(0, 0, 12.0))
    wheel = bpy.context.active_object
    wheel.name = "Mine_Headframe_Sheave_Wheel"
    wheel.rotation_euler = (math.radians(90), 0, 0)
    wheel.data.materials.append(mat_mine_iron)

    # Suportes metálicos diagonais de contraventamento
    diags = []
    for side in [-3.5, 3.5]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(side, 0, 10.5))
        d = bpy.context.active_object
        d.name = f"Headframe_Brace_{'L' if side < 0 else 'R'}"
        d.scale = (0.5, 0.5, 5.0)
        d.rotation_euler = (0, math.radians(25 if side < 0 else -25), 0)
        d.data.materials.append(mat_mine_iron)
        diags.append(d)

    objs = [leg_l, leg_r, lintel, wheel] + diags
    return export_asset("structure_tharum_mine_headframe", "Structures", objs)

def build_mining_ore_cart_track():
    clear_scene()
    mat_iron = create_material("mat_cart_iron", (0.16, 0.15, 0.17, 1.0), roughness=0.55, metallic=0.75)
    mat_ore = create_material(
        "mat_raw_tharum_ore",
        (0.65, 0.40, 0.15, 1.0),
        roughness=0.7,
        metallic=0.4,
        emission=(0.85, 0.45, 0.10, 1.0),
        emission_strength=2.2
    )

    # Trilhos duplos
    tracks = []
    for side in [-1.0, 1.0]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(side, 0, 0.15))
        rail = bpy.context.active_object
        rail.name = f"Mine_Rail_{'L' if side < 0 else 'R'}"
        rail.scale = (0.2, 9.0, 0.3)
        rail.data.materials.append(mat_iron)
        tracks.append(rail)

    # Dormentes de madeira
    sleepers = []
    for i in range(6):
        py = -3.5 + i * 1.4
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, py, 0.08))
        s = bpy.context.active_object
        s.name = f"Sleeper_{i+1}"
        s.scale = (2.8, 0.4, 0.16)
        s.data.materials.append(mat_iron)
        sleepers.append(s)

    # Vagonete
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.2))
    cart = bpy.context.active_object
    cart.name = "Heavy_Ore_Cart_Body"
    cart.scale = (2.2, 3.2, 1.4)
    cart.data.materials.append(mat_iron)

    # Minério bruto dentro do vagonete
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.0, location=(0, 0, 1.8))
    ore = bpy.context.active_object
    ore.name = "Ore_Payload"
    ore.scale = (1.0, 1.4, 0.7)
    ore.data.materials.append(mat_ore)

    objs = [cart, ore] + tracks + sleepers
    return export_asset("prop_mining_ore_cart_track", "Props", objs)

# ==============================================================================
# 27. PONTE DAS CORRENTES (REG-027) — ESTRUTURAS SUSPENSAS SOBRE ABISMOS
# ==============================================================================

def build_monumental_chain_bridge():
    clear_scene()
    mat_pylon_stone = create_material("mat_chain_pylon_stone", (0.20, 0.18, 0.18, 1.0), roughness=0.85)
    mat_titan_chain = create_material("mat_titan_iron_chain", (0.14, 0.13, 0.15, 1.0), roughness=0.4, metallic=0.9)
    mat_plank_deck = create_material("mat_bridge_deck_ironwood", (0.28, 0.22, 0.16, 1.0), roughness=0.75)

    # Pilar monumental duplo de sustentação do abismo
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-5.5, 0, 8.0))
    pylon_l = bpy.context.active_object
    pylon_l.name = "Abyss_Pylon_Left"
    pylon_l.scale = (2.8, 4.0, 16.0)
    pylon_l.data.materials.append(mat_pylon_stone)

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(5.5, 0, 8.0))
    pylon_r = bpy.context.active_object
    pylon_r.name = "Abyss_Pylon_Right"
    pylon_r.scale = (2.8, 4.0, 16.0)
    pylon_r.data.materials.append(mat_pylon_stone)

    # Arco de topo ligando os pilares
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 15.5))
    arch = bpy.context.active_object
    arch.name = "Pylon_Connecting_Arch"
    arch.scale = (12.0, 3.5, 2.0)
    arch.data.materials.append(mat_pylon_stone)

    # Deck da passarela suspensa
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 4.0))
    deck = bpy.context.active_object
    deck.name = "Suspended_Deck_Platform"
    deck.scale = (7.5, 18.0, 0.6)
    deck.data.materials.append(mat_plank_deck)

    # Correntes titânicas suspensas
    chains = []
    for side in [-3.8, 3.8]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.45, depth=18.0, location=(side, 0, 7.5))
        ch = bpy.context.active_object
        ch.name = f"Titan_Cable_Chain_{'L' if side < 0 else 'R'}"
        ch.rotation_euler = (math.radians(90), 0, 0)
        ch.data.materials.append(mat_titan_chain)
        chains.append(ch)

    objs = [pylon_l, pylon_r, arch, deck] + chains
    return export_asset("structure_monumental_chain_bridge", "Structures", objs)

def build_titan_chain_link():
    clear_scene()
    mat_chain = create_material("mat_anchor_chain_iron", (0.15, 0.14, 0.16, 1.0), roughness=0.45, metallic=0.88)
    mat_rock = create_material("mat_anchor_basalt", (0.20, 0.18, 0.18, 1.0), roughness=0.85)

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.0))
    base = bpy.context.active_object
    base.name = "Anchor_Basalt_Block"
    base.scale = (4.0, 4.0, 2.0)
    base.data.materials.append(mat_rock)

    # 3 Elos titânicos entrelaçados
    links = []
    for i in range(3):
        bpy.ops.mesh.primitive_torus_add(major_radius=1.4, minor_radius=0.35, location=(0, 0, 2.2 + i * 1.5))
        lk = bpy.context.active_object
        lk.name = f"Titan_Link_{i+1}"
        lk.rotation_euler = (0, math.radians(90 if i % 2 == 1 else 0), 0)
        lk.data.materials.append(mat_chain)
        links.append(lk)

    objs = [base] + links
    return export_asset("prop_titan_chain_link", "Props", objs)

# ==============================================================================
# 28. PLANALTO DO TROVÃO (REG-028)
# ==============================================================================

def build_lightning_conductor_spire():
    clear_scene()
    mat_iron = create_material("mat_lightning_rod_iron", (0.16, 0.16, 0.18, 1.0), roughness=0.35, metallic=0.92)
    mat_plasma = create_material(
        "mat_plasma_energy_arc",
        (0.65, 0.85, 1.0, 1.0),
        roughness=0.15,
        emission=(0.70, 0.90, 1.0, 1.0),
        emission_strength=4.5
    )

    # Agulha condutora vertical de ferro (altura 16m)
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.75, depth=16.0, location=(0, 0, 8.0))
    spire = bpy.context.active_object
    spire.name = "Conductor_Spire_Shaft"
    spire.data.materials.append(mat_iron)

    # Anéis coletores de tempestade toroidais
    rings = []
    for i in range(3):
        rz = 7.0 + i * 3.5
        bpy.ops.mesh.primitive_torus_add(major_radius=2.2 - i*0.4, minor_radius=0.25, location=(0, 0, rz))
        ring = bpy.context.active_object
        ring.name = f"Plasma_Collector_Ring_{i+1}"
        ring.data.materials.append(mat_iron)
        rings.append(ring)

    # Esfera captadora de plasma no topo
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.0, location=(0, 0, 16.5))
    orb = bpy.context.active_object
    orb.name = "Lightning_Plasma_Receiver"
    orb.data.materials.append(mat_plasma)

    objs = [spire, orb] + rings
    return export_asset("structure_lightning_conductor_spire", "Structures", objs)

# ==============================================================================
# 29. GARGANTA DO CARVÃO (REG-029)
# ==============================================================================

def build_coal_chasm_archway():
    clear_scene()
    mat_coal = create_material("mat_anthracite_coal", (0.08, 0.08, 0.09, 1.0), roughness=0.95, metallic=0.05)
    mat_heat_fissure = create_material(
        "mat_coal_chasm_fissure",
        (0.95, 0.35, 0.05, 1.0),
        roughness=0.2,
        emission=(0.98, 0.38, 0.06, 1.0),
        emission_strength=3.5
    )

    # Arco de caverna colossal em antracito
    bpy.ops.mesh.primitive_torus_add(major_radius=6.5, minor_radius=2.2, location=(0, 0, 6.0))
    arch = bpy.context.active_object
    arch.name = "Anthracite_Cavern_Arch"
    arch.rotation_euler = (math.radians(90), 0, 0)
    arch.scale = (1.0, 0.7, 1.2)
    arch.data.materials.append(mat_coal)

    # Estalagmites pontiagudas laterais
    spikes = []
    for i in range(4):
        sx = -5.0 + i * 3.3
        sy = 1.0 if i % 2 == 0 else -1.0
        bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=1.5, radius2=0.2, depth=6.0, location=(sx, sy, 3.0))
        spk = bpy.context.active_object
        spk.name = f"Coal_Stalagmite_{i+1}"
        spk.data.materials.append(mat_coal)
        spikes.append(spk)

    # Fenda de brasa rasteira no chão
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.15))
    fissure = bpy.context.active_object
    fissure.name = "Glowing_Coal_Fissure"
    fissure.scale = (7.0, 2.5, 0.3)
    fissure.data.materials.append(mat_heat_fissure)

    objs = [arch, fissure] + spikes
    return export_asset("rock_coal_chasm_archway", "Rocks", objs)

# ==============================================================================
# 30. CRATERA DO CORAÇÃO (REG-030) — DESTAQUE VISUAL MONUMENTAL
# ==============================================================================

def build_heart_crater_monolith():
    clear_scene()
    mat_dark_iron = create_material("mat_ancient_containment_iron", (0.14, 0.14, 0.16, 1.0), roughness=0.4, metallic=0.9)
    mat_heart_core = create_material(
        "mat_primal_heart_magma",
        (1.0, 0.50, 0.08, 1.0),
        roughness=0.15,
        emission=(1.0, 0.55, 0.10, 1.0),
        emission_strength=5.5
    )
    mat_runic_gold = create_material(
        "mat_heart_runes",
        (0.95, 0.75, 0.20, 1.0),
        roughness=0.3,
        metallic=0.7,
        emission=(0.98, 0.80, 0.25, 1.0),
        emission_strength=3.5
    )

    # Terraço de contenção octogonal
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=10.0, depth=2.0, location=(0, 0, 1.0))
    terrace = bpy.context.active_object
    terrace.name = "Containment_Terrace_Plinth"
    terrace.data.materials.append(mat_dark_iron)

    # Monolito vertical colossal no centro
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 8.0))
    monolith = bpy.context.active_object
    monolith.name = "Heart_Central_Pillar"
    monolith.scale = (4.0, 4.0, 14.0)
    monolith.data.materials.append(mat_dark_iron)

    # Núcleo do Coração Vulcânico (esfera pulsante no ápice)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=2.5, location=(0, 0, 16.5))
    core = bpy.context.active_object
    core.name = "Primal_Heart_Fire_Core"
    core.data.materials.append(mat_heart_core)

    # 4 Anéis orbitais de ferro rúnico flutuando ao redor do núcleo
    rings = []
    for i in range(4):
        bpy.ops.mesh.primitive_torus_add(major_radius=4.5, minor_radius=0.35, location=(0, 0, 16.5))
        ring = bpy.context.active_object
        ring.name = f"Heart_Runic_Ring_{i+1}"
        ring.rotation_euler = (math.radians(35 * i), math.radians(25 * (i % 2)), 0)
        ring.data.materials.append(mat_runic_gold)
        rings.append(ring)

    objs = [terrace, monolith, core] + rings
    return export_asset("structure_heart_crater_monolith", "Structures", objs)

# ==============================================================================
# EXECUÇÃO PRINCIPAL
# ==============================================================================

def main():
    print("======================================================================")
    print("ABYSSAL PACT — GERANDO ASSETS 3D DE KHAR-DUUM (HEADLESS BLENDER)")
    print(f"Diretório ArtSource (.blend): {ART_SOURCE_DIR}")
    print(f"Diretório Modelos (.glb):     {MODELS_OUT_DIR}")
    print("======================================================================")

    generated = []

    # 21. Caldeira Rubra
    generated.append(build_rubra_caldera_vent())
    generated.append(build_volcanic_vent_horn())

    # 22. Fornalha dos Reis
    generated.append(build_kings_forge_citadel())
    generated.append(build_colossal_forge_anvil())

    # 23. Desfiladeiro de Obsidiana
    generated.append(build_obsidian_canyon_gate())

    # 24. Mar de Escória
    generated.append(build_slag_refinery_furnace())

    # 25. Dunas de Vidro Negro
    generated.append(build_vitrified_glass_dune_ridge())

    # 26. Minas de Tharum
    generated.append(build_tharum_mine_headframe())
    generated.append(build_mining_ore_cart_track())

    # 27. Ponte das Correntes
    generated.append(build_monumental_chain_bridge())
    generated.append(build_titan_chain_link())

    # 28. Planalto do Trovão
    generated.append(build_lightning_conductor_spire())

    # 29. Garganta do Carvão
    generated.append(build_coal_chasm_archway())

    # 30. Cratera do Coração
    generated.append(build_heart_crater_monolith())

    print("======================================================================")
    print(f"SUCESSO: {len(generated)} assets 3D de Khar-Duum gerados e exportados.")
    print("======================================================================")

if __name__ == "__main__":
    main()
