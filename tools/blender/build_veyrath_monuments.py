"""
ABYSSAL PACT — Modelagem 3D dos Monumentos de Veyrath (Blender 5.3+ Headless)

Constrói proceduralmente os assets e estruturas exclusivas para as 10 regiões de Veyrath:
- Coroa Partida (REG-002): Palácio Imperial em Ruínas, Trono Caído, Casa de Guarda Imperial
- Vale dos Sinos (REG-003): Torre Sineira Arcaica, Grande Sino Abissal
- Bosque Oco (REG-004): Árvore Monumental Oca de Cinzas
- Lago de Vidro (REG-005): Pináculo de Cristais de Obsidiana
- Costa das Cinzas (REG-006): Carcaça de Navio Naufragado, Píer de Fortaleza Costeira
- Passo da Vigília (REG-007): Bastião de Alta Montanha Fortificado
- Catacumbas de Orun (REG-008): Pórtico de Mausoléu Subterrâneo, Sarcófago Imperial
- Campos de Sal (REG-009): Formação de Crosta de Sal Cáustica
- Torre de Aster (REG-010): Torre Arcana Monumental de Aster, Anel Orbital Flutuante

Regras:
- Arquivos .blend salvos em: AbyssalPact_ArtSource/Blender/...
- Arquivos .glb exportados para: assets/models/environment/...
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
# 1. COROA PARTIDA (REG-002): Palácio Imperial, Trono Caído, Casa de Guarda
# ==============================================================================

def build_imperial_palace_ruin():
    clear_scene()
    mat_stone = create_material("mat_palace_stone", (0.28, 0.25, 0.26, 1.0), roughness=0.75, metallic=0.1)
    mat_gold = create_material("mat_imperial_gold", (0.65, 0.50, 0.18, 1.0), roughness=0.45, metallic=0.7)

    # Base e estrado
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.75))
    base = bpy.context.active_object
    base.name = "Palace_Foundation"
    base.scale = (16.0, 12.0, 1.5)
    base.data.materials.append(mat_stone)

    # Degraus
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -6.5, 0.35))
    stairs = bpy.context.active_object
    stairs.scale = (8.0, 2.0, 0.7)
    stairs.data.materials.append(mat_stone)

    # Colunas frontais quebradas
    columns = []
    for i in range(4):
        x = -6.0 + i * 4.0
        h = 6.0 if i in [0, 3] else 4.0
        bpy.ops.mesh.primitive_cylinder_add(radius=0.7, depth=h, location=(x, -4.5, 1.5 + h/2))
        col = bpy.context.active_object
        col.name = f"Palace_Col_{i+1}"
        col.data.materials.append(mat_stone)
        columns.append(col)

    # Entablamento e frontão desabado
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -4.5, 7.8))
    arch = bpy.context.active_object
    arch.scale = (15.0, 1.8, 1.2)
    arch.data.materials.append(mat_stone)

    # Parede de fundo do trono com brasão
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 5.0, 4.5))
    backwall = bpy.context.active_object
    backwall.scale = (14.0, 1.6, 7.5)
    backwall.data.materials.append(mat_stone)

    # Brasão imperial dourado partido
    bpy.ops.mesh.primitive_cylinder_add(radius=1.2, depth=0.3, location=(0, 4.1, 6.0))
    emblem = bpy.context.active_object
    emblem.rotation_euler = (math.radians(90), 0, 0)
    emblem.data.materials.append(mat_gold)

    objs = [base, stairs, arch, backwall, emblem] + columns
    return export_asset("structure_imperial_palace_ruin", "Structures", objs)

def build_broken_throne():
    clear_scene()
    mat_iron = create_material("mat_throne_iron", (0.15, 0.14, 0.16, 1.0), roughness=0.6, metallic=0.6)
    mat_ruby = create_material("mat_throne_gem", (0.75, 0.08, 0.12, 1.0), roughness=0.2, emission=(0.8, 0.1, 0.15, 1.0), emission_strength=2.0)

    # Pódio do trono
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.2, depth=0.6, location=(0, 0, 0.3))
    podium = bpy.context.active_object
    podium.data.materials.append(mat_iron)

    # Assento do trono
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.1))
    seat = bpy.context.active_object
    seat.scale = (1.6, 1.4, 1.0)
    seat.data.materials.append(mat_iron)

    # Encosto partido em forma de coroa de espadas
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.6, 2.3))
    back = bpy.context.active_object
    back.scale = (1.5, 0.35, 1.6)
    back.data.materials.append(mat_iron)

    # Espadas cravadas no encosto
    blades = []
    for angle in [-30, -15, 0, 20]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=4, radius=0.08, depth=1.6, location=(math.sin(math.radians(angle))*0.6, 0.7, 3.0))
        blade = bpy.context.active_object
        blade.rotation_euler = (0, math.radians(angle), 0)
        blade.data.materials.append(mat_iron)
        blades.append(blade)

    # Joia abissal rachada no centro
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.22, location=(0, 0.45, 2.8))
    gem = bpy.context.active_object
    gem.data.materials.append(mat_ruby)

    objs = [podium, seat, back, gem] + blades
    return export_asset("prop_broken_throne", "Props", objs)

def build_imperial_gatehouse():
    clear_scene()
    mat_stone = create_material("mat_gate_stone", (0.24, 0.22, 0.24, 1.0), roughness=0.8, metallic=0.1)

    # Duas torres laterais
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=2.2, depth=8.0, location=(-5.0, 0, 4.0))
    tower_l = bpy.context.active_object
    tower_l.data.materials.append(mat_stone)

    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=2.2, depth=8.0, location=(5.0, 0, 4.0))
    tower_r = bpy.context.active_object
    tower_r.data.materials.append(mat_stone)

    # Arco central conectando as torres
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 6.5))
    arch = bpy.context.active_object
    arch.scale = (6.0, 3.0, 2.0)
    arch.data.materials.append(mat_stone)

    # Ameias nas torres
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=2.5, depth=0.8, location=(-5.0, 0, 8.4))
    battle_l = bpy.context.active_object
    battle_l.data.materials.append(mat_stone)

    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=2.5, depth=0.8, location=(5.0, 0, 8.4))
    battle_r = bpy.context.active_object
    battle_r.data.materials.append(mat_stone)

    objs = [tower_l, tower_r, arch, battle_l, battle_r]
    return export_asset("structure_imperial_gatehouse", "Structures", objs)

# ==============================================================================
# 2. VALE DOS SINOS (REG-003): Torre Sineira Arcaica e Grande Sino Abissal
# ==============================================================================

def build_bell_tower_ruin():
    clear_scene()
    mat_dark_stone = create_material("mat_tower_stone", (0.20, 0.18, 0.22, 1.0), roughness=0.85, metallic=0.1)
    mat_bell_bronze = create_material("mat_bronze_bell", (0.35, 0.26, 0.18, 1.0), roughness=0.6, metallic=0.7)

    # Base de sustentação da torre
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 5.0))
    tower_body = bpy.context.active_object
    tower_body.scale = (4.5, 4.5, 10.0)
    tower_body.data.materials.append(mat_dark_stone)

    # Abertura do campanário
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 11.5))
    belfry = bpy.context.active_object
    belfry.scale = (3.8, 3.8, 3.2)
    belfry.data.materials.append(mat_dark_stone)

    # Telhado pontiagudo em ruínas
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=3.2, depth=3.5, location=(0, 0, 14.5))
    roof = bpy.context.active_object
    roof.rotation_euler = (0, 0, math.radians(45))
    roof.data.materials.append(mat_dark_stone)

    # Viga de madeira/ferro do sino
    bpy.ops.mesh.primitive_cylinder_add(radius=0.15, depth=3.0, location=(0, 0, 11.8))
    beam = bpy.context.active_object
    beam.rotation_euler = (0, math.radians(90), 0)
    beam.data.materials.append(mat_dark_stone)

    # Sino pequeno decorativo suspenso na torre
    bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=0.7, radius2=0.3, depth=1.1, location=(0, 0, 11.0))
    bell = bpy.context.active_object
    bell.data.materials.append(mat_bell_bronze)

    objs = [tower_body, belfry, roof, beam, bell]
    return export_asset("structure_bell_tower_ruin", "Structures", objs)

def build_abyssal_bell():
    clear_scene()
    mat_bell = create_material("mat_abyssal_bell", (0.25, 0.20, 0.16, 1.0), roughness=0.5, metallic=0.75, emission=(0.3, 0.1, 0.05, 1.0), emission_strength=1.2)
    mat_chain = create_material("mat_chain_iron", (0.12, 0.12, 0.14, 1.0), roughness=0.7, metallic=0.8)

    # Corpo principal do sino
    bpy.ops.mesh.primitive_cone_add(vertices=16, radius1=1.8, radius2=0.7, depth=2.4, location=(0, 0, 1.4))
    bell = bpy.context.active_object
    bell.data.materials.append(mat_bell)

    # Borda reforçada do sino
    bpy.ops.mesh.primitive_torus_add(major_radius=1.8, minor_radius=0.15, location=(0, 0, 0.2))
    rim = bpy.context.active_object
    rim.data.materials.append(mat_bell)

    # Argola superior de suspensão
    bpy.ops.mesh.primitive_torus_add(major_radius=0.45, minor_radius=0.1, location=(0, 0, 2.7))
    ring = bpy.context.active_object
    ring.rotation_euler = (math.radians(90), 0, 0)
    ring.data.materials.append(mat_chain)

    # Badalo inferior
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.35, location=(0, 0, 0.4))
    clapper = bpy.context.active_object
    clapper.data.materials.append(mat_chain)

    objs = [bell, rim, ring, clapper]
    return export_asset("prop_abyssal_bell", "Props", objs)

# ==============================================================================
# 3. BOSQUE OCO (REG-004): Árvore Monumental Oca de Cinzas
# ==============================================================================

def build_hollow_tree_monument():
    clear_scene()
    mat_charred_wood = create_material("mat_charred_bark", (0.12, 0.10, 0.11, 1.0), roughness=0.9, metallic=0.05)
    mat_inner_ember = create_material("mat_ember_core", (0.8, 0.3, 0.08, 1.0), roughness=0.4, emission=(1.0, 0.35, 0.08, 1.0), emission_strength=2.5)

    # Casca cilíndrica oca
    bpy.ops.mesh.primitive_cylinder_add(vertices=14, radius=3.2, depth=9.0, location=(0, 0, 4.5))
    outer_trunk = bpy.context.active_object
    outer_trunk.data.materials.append(mat_charred_wood)

    # Raízes expansivas retorcidas
    roots = []
    for i in range(5):
        ang = i * (2 * math.pi / 5)
        rx = math.cos(ang) * 4.2
        ry = math.sin(ang) * 4.2
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(rx, ry, 0.8))
        root = bpy.context.active_object
        root.scale = (1.8, 1.4, 1.6)
        root.rotation_euler = (0, 0, ang)
        root.data.materials.append(mat_charred_wood)
        roots.append(root)

    # Galhos superiores secos quebrados
    branches = []
    for i in range(3):
        ang = i * (2 * math.pi / 3) + 0.3
        bx = math.cos(ang) * 2.2
        by = math.sin(ang) * 2.2
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.6, depth=4.0, location=(bx, by, 9.5))
        branch = bpy.context.active_object
        branch.rotation_euler = (math.sin(ang)*0.4, -math.cos(ang)*0.4, ang)
        branch.data.materials.append(mat_charred_wood)
        branches.append(branch)

    # Núcleo interior em brasas
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.0, location=(0, 0, 1.5))
    ember = bpy.context.active_object
    ember.data.materials.append(mat_inner_ember)

    objs = [outer_trunk, ember] + roots + branches
    return export_asset("nature_hollow_tree_monument", "Nature", objs)

# ==============================================================================
# 4. LAGO DE VIDRO (REG-005): Pináculo de Cristais de Obsidiana
# ==============================================================================

def build_obsidian_crystal_spire():
    clear_scene()
    mat_obsidian = create_material("mat_crystal_obsidian", (0.06, 0.06, 0.08, 1.0), roughness=0.15, metallic=0.35, emission=(0.1, 0.15, 0.25, 1.0), emission_strength=0.8)

    # Agulha central monumental
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=1.4, depth=8.5, location=(0, 0, 4.25))
    main_spire = bpy.context.active_object
    main_spire.data.materials.append(mat_obsidian)

    # Cristais menores em torno da base
    crystals = []
    for i in range(5):
        ang = i * (2 * math.pi / 5) + 0.2
        cx = math.cos(ang) * 1.8
        cy = math.sin(ang) * 1.8
        h = 3.0 + (i % 3) * 1.2
        bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.6, depth=h, location=(cx, cy, h/2))
        cry = bpy.context.active_object
        cry.rotation_euler = (math.sin(ang)*0.25, -math.cos(ang)*0.25, ang)
        cry.data.materials.append(mat_obsidian)
        crystals.append(cry)

    objs = [main_spire] + crystals
    return export_asset("rock_obsidian_crystal_spire", "Rocks", objs)

# ==============================================================================
# 5. COSTA DAS CINZAS (REG-006): Carcaça de Navio e Píer de Fortaleza Costeira
# ==============================================================================

def build_shipwreck_ribs():
    clear_scene()
    mat_wood = create_material("mat_ship_rotwood", (0.18, 0.15, 0.14, 1.0), roughness=0.9, metallic=0.05)

    # Quilha do navio
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.5))
    keel = bpy.context.active_object
    keel.scale = (1.2, 14.0, 1.0)
    keel.data.materials.append(mat_wood)

    # Costelas curvadas da carcaça
    ribs = []
    for i in range(7):
        y = -5.0 + i * 1.8
        # Costela esquerda
        bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.25, depth=4.2, location=(-2.2, y, 2.2))
        rib_l = bpy.context.active_object
        rib_l.rotation_euler = (0, math.radians(-35), 0)
        rib_l.data.materials.append(mat_wood)
        ribs.append(rib_l)

        # Costela direita
        bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.25, depth=4.2, location=(2.2, y, 2.2))
        rib_r = bpy.context.active_object
        rib_r.rotation_euler = (0, math.radians(35), 0)
        rib_r.data.materials.append(mat_wood)
        ribs.append(rib_r)

    # Mastro quebrado inclinado
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.45, depth=7.5, location=(0, -1.0, 3.8))
    mast = bpy.context.active_object
    mast.rotation_euler = (math.radians(25), math.radians(15), 0)
    mast.data.materials.append(mat_wood)

    objs = [keel, mast] + ribs
    return export_asset("prop_shipwreck_ribs", "Props", objs)

def build_sea_fortress_pier():
    clear_scene()
    mat_basalt_sea = create_material("mat_pier_basalt", (0.16, 0.16, 0.18, 1.0), roughness=0.8, metallic=0.15)

    # Plataforma do cais avançando no mar
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.5))
    dock = bpy.context.active_object
    dock.scale = (6.0, 16.0, 3.0)
    dock.data.materials.append(mat_basalt_sea)

    # Pilares de sustentação marinhos
    pilings = []
    for i in range(4):
        y = -6.0 + i * 4.0
        for x in [-3.2, 3.2]:
            bpy.ops.mesh.primitive_cylinder_add(radius=0.6, depth=4.0, location=(x, y, 1.0))
            p = bpy.context.active_object
            p.data.materials.append(mat_basalt_sea)
            pilings.append(p)

    # Amarras de pedra e postes de atracação
    bpy.ops.mesh.primitive_cylinder_add(radius=0.35, depth=1.2, location=(-2.4, 6.5, 3.6))
    post_l = bpy.context.active_object
    post_l.data.materials.append(mat_basalt_sea)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.35, depth=1.2, location=(2.4, 6.5, 3.6))
    post_r = bpy.context.active_object
    post_r.data.materials.append(mat_basalt_sea)

    objs = [dock, post_l, post_r] + pilings
    return export_asset("structure_sea_fortress_pier", "Structures", objs)

# ==============================================================================
# 6. PASSO DA VIGÍLIA (REG-007): Bastião de Alta Montanha Fortificado
# ==============================================================================

def build_mountain_fortress_bastion():
    clear_scene()
    mat_rock_wall = create_material("mat_mountain_fortress", (0.22, 0.20, 0.21, 1.0), roughness=0.85, metallic=0.1)

    # Baluarte central maciço
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 4.5))
    bastion = bpy.context.active_object
    bastion.scale = (12.0, 7.0, 9.0)
    bastion.data.materials.append(mat_rock_wall)

    # Portão em arco fortificado encravado no bastião
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -3.6, 2.5))
    gate_arch = bpy.context.active_object
    gate_arch.scale = (3.5, 1.2, 5.0)
    gate_arch.data.materials.append(mat_rock_wall)

    # Ameias superiores defensivas
    crenels = []
    for i in range(5):
        x = -5.0 + i * 2.5
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, -3.3, 9.5))
        c = bpy.context.active_object
        c.scale = (1.2, 0.8, 1.2)
        c.data.materials.append(mat_rock_wall)
        crenels.append(c)

    # Duas torres de flanqueamento angulares
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.5, depth=11.0, location=(-6.5, -1.0, 5.5))
    tower_l = bpy.context.active_object
    tower_l.data.materials.append(mat_rock_wall)

    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.5, depth=11.0, location=(6.5, -1.0, 5.5))
    tower_r = bpy.context.active_object
    tower_r.data.materials.append(mat_rock_wall)

    objs = [bastion, gate_arch, tower_l, tower_r] + crenels
    return export_asset("structure_mountain_fortress_bastion", "Structures", objs)

# ==============================================================================
# 7. CATACUMBAS DE ORUN (REG-008): Pórtico de Mausoléu e Sarcófago Imperial
# ==============================================================================

def build_mausoleum_crypt_entrance():
    clear_scene()
    mat_crypt = create_material("mat_crypt_slate", (0.16, 0.14, 0.17, 1.0), roughness=0.8, metallic=0.1)
    mat_grave_rune = create_material("mat_grave_rune", (0.4, 0.5, 0.6, 1.0), roughness=0.3, emission=(0.2, 0.5, 0.7, 1.0), emission_strength=1.5)

    # Portal frontal de cantaria maciça
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 4.0))
    frame = bpy.context.active_object
    frame.scale = (9.0, 3.5, 8.0)
    frame.data.materials.append(mat_crypt)

    # Arco da cripta
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -1.5, 6.0))
    pediment = bpy.context.active_object
    pediment.scale = (10.0, 2.0, 2.5)
    pediment.data.materials.append(mat_crypt)

    # Pilares fúnebres esculpidos
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.8, depth=6.0, location=(-3.5, -1.8, 3.0))
    col_l = bpy.context.active_object
    col_l.data.materials.append(mat_crypt)

    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.8, depth=6.0, location=(3.5, -1.8, 3.0))
    col_r = bpy.context.active_object
    col_r.data.materials.append(mat_crypt)

    # Runa fúnebre de Orun incandescente no frontão
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.6, location=(0, -1.8, 6.2))
    rune = bpy.context.active_object
    rune.data.materials.append(mat_grave_rune)

    objs = [frame, pediment, col_l, col_r, rune]
    return export_asset("structure_mausoleum_crypt_entrance", "Structures", objs)

def build_imperial_sarcophagus():
    clear_scene()
    mat_stone = create_material("mat_sarcophagus_marble", (0.30, 0.28, 0.30, 1.0), roughness=0.7, metallic=0.1)
    mat_gold = create_material("mat_sarcophagus_gold", (0.7, 0.55, 0.2, 1.0), roughness=0.4, metallic=0.8)

    # Base da tumba
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.6))
    base = bpy.context.active_object
    base.scale = (2.6, 4.2, 1.2)
    base.data.materials.append(mat_stone)

    # Tampa do sarcófago chanfrada
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.45))
    lid = bpy.context.active_object
    lid.scale = (2.4, 4.0, 0.5)
    lid.data.materials.append(mat_stone)

    # Efígie esculpida no topo da tampa
    bpy.ops.mesh.primitive_cylinder_add(radius=0.4, depth=2.8, location=(0, 0, 1.8))
    effigy = bpy.context.active_object
    effigy.rotation_euler = (math.radians(90), 0, 0)
    effigy.data.materials.append(mat_gold)

    objs = [base, lid, effigy]
    return export_asset("prop_imperial_sarcophagus", "Props", objs)

# ==============================================================================
# 8. CAMPOS DE SAL (REG-009): Formação de Crosta de Sal Cáustica
# ==============================================================================

def build_salt_crust_formation():
    clear_scene()
    mat_salt = create_material("mat_salt_white", (0.85, 0.85, 0.88, 1.0), roughness=0.4, metallic=0.05)

    # Placa base de crosta
    bpy.ops.mesh.primitive_cylinder_add(vertices=7, radius=3.2, depth=0.4, location=(0, 0, 0.2))
    plate = bpy.context.active_object
    plate.data.materials.append(mat_salt)

    # Pilhas de cristais afiados
    crystals = []
    for i in range(6):
        ang = i * (2 * math.pi / 6)
        x = math.cos(ang) * 1.5
        y = math.sin(ang) * 1.5
        h = 1.2 + (i % 3) * 0.8
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=0.5, depth=h, location=(x, y, h/2))
        c = bpy.context.active_object
        c.data.materials.append(mat_salt)
        crystals.append(c)

    objs = [plate] + crystals
    return export_asset("rock_salt_crust_formation", "Rocks", objs)

# ==============================================================================
# 9. TORRE DE ASTER (REG-010): Torre Arcana Monumental e Anel Orbital
# ==============================================================================

def build_aster_arcane_tower():
    clear_scene()
    mat_obsidian_tower = create_material("mat_aster_blackstone", (0.12, 0.10, 0.14, 1.0), roughness=0.6, metallic=0.3)
    mat_arcane_core = create_material("mat_aster_core", (0.5, 0.2, 0.9, 1.0), roughness=0.2, emission=(0.7, 0.2, 1.0, 1.0), emission_strength=4.0)

    # Nível 1: Base monumental com 8 contrafortes
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=7.0, depth=8.0, location=(0, 0, 4.0))
    base = bpy.context.active_object
    base.data.materials.append(mat_obsidian_tower)

    buttresses = []
    for i in range(8):
        ang = i * (2 * math.pi / 8)
        bx = math.cos(ang) * 7.5
        by = math.sin(ang) * 7.5
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(bx, by, 4.0))
        b = bpy.context.active_object
        b.scale = (1.8, 3.2, 7.5)
        b.rotation_euler = (0, 0, ang)
        b.data.materials.append(mat_obsidian_tower)
        buttresses.append(b)

    # Nível 2: Corpo médio cilíndrico
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=5.2, depth=10.0, location=(0, 0, 13.0))
    mid = bpy.context.active_object
    mid.data.materials.append(mat_obsidian_tower)

    # Nível 3: Agulha superior e cúpula focal
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=3.6, depth=9.0, location=(0, 0, 22.5))
    upper = bpy.context.active_object
    upper.data.materials.append(mat_obsidian_tower)

    # Agulha pontiaguda terminal
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=3.0, depth=7.0, location=(0, 0, 30.5))
    spire = bpy.context.active_object
    spire.data.materials.append(mat_obsidian_tower)

    # Cristal focal da Hell Forge suspenso no pináculo
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=1.6, location=(0, 0, 34.5))
    crystal = bpy.context.active_object
    crystal.data.materials.append(mat_arcane_core)

    objs = [base, mid, upper, spire, crystal] + buttresses
    return export_asset("structure_aster_arcane_tower", "Structures", objs)

def build_aster_arcane_ring():
    clear_scene()
    mat_ring_gold = create_material("mat_arcane_ring_gold", (0.75, 0.60, 0.25, 1.0), roughness=0.3, metallic=0.85)
    mat_glyph = create_material("mat_arcane_glyph", (0.6, 0.2, 1.0, 1.0), roughness=0.2, emission=(0.8, 0.3, 1.0, 1.0), emission_strength=3.5)

    # Anel circular colossal que flutua ao redor da torre
    bpy.ops.mesh.primitive_torus_add(major_radius=6.8, minor_radius=0.45, location=(0, 0, 1.0))
    ring = bpy.context.active_object
    ring.data.materials.append(mat_ring_gold)

    # Orbes/glifos orbitais de poder
    glyphs = []
    for i in range(4):
        ang = i * (math.pi / 2)
        gx = math.cos(ang) * 6.8
        gy = math.sin(ang) * 6.8
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.7, location=(gx, gy, 1.0))
        g = bpy.context.active_object
        g.data.materials.append(mat_glyph)
        glyphs.append(g)

    objs = [ring] + glyphs
    return export_asset("prop_aster_arcane_ring", "Props", objs)

# ==============================================================================
# MAIN EXECUTOR
# ==============================================================================

if __name__ == "__main__":
    print("=== INICIANDO MODELAGEM 3D DOS MONUMENTOS DE VEYRATH ===")

    # 1. Coroa Partida
    build_imperial_palace_ruin()
    build_broken_throne()
    build_imperial_gatehouse()

    # 2. Vale dos Sinos
    build_bell_tower_ruin()
    build_abyssal_bell()

    # 3. Bosque Oco
    build_hollow_tree_monument()

    # 4. Lago de Vidro
    build_obsidian_crystal_spire()

    # 5. Costa das Cinzas
    build_shipwreck_ribs()
    build_sea_fortress_pier()

    # 6. Passo da Vigília
    build_mountain_fortress_bastion()

    # 7. Catacumbas de Orun
    build_mausoleum_crypt_entrance()
    build_imperial_sarcophagus()

    # 8. Campos de Sal
    build_salt_crust_formation()

    # 9. Torre de Aster
    build_aster_arcane_tower()
    build_aster_arcane_ring()

    print("=== MODELAGEM DOS 15 MONUMENTOS DE VEYRATH CONCLUÍDA ===")
