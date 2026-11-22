"""
ABYSSAL PACT — Modelagem 3D dos Monumentos e Ambientes de Sylvaran (Blender 5.3+ Headless)

Constrói proceduralmente os assets e estruturas exclusivas para as 10 regiões de SYLVARAN:
11. Raiz Antiga:
    - nature_colossal_tree_ancient (Nature): Árvore colossal ancestral com tronco oco e raízes tabulares
    - nature_monumental_roots_arch (Nature): Grande arco de raízes monumentais sobre o caminho
12. Pântano das Lanternas:
    - nature_bioluminescent_lantern_plant (Nature): Planta palustre com bulbos bioluminescentes
    - prop_swamp_lantern_post (Props): Poste rústico de pântano com cesto de fungos luminosos
13. Copa Celeste:
    - nature_canopy_platform_branch (Nature): Plataforma horizontal em galho colossal com balaustrada
14. Jardim Afogado:
    - structure_drowned_garden_pavilion (Structures): Pavilhão circular de colunata de mármore submerso
15. Arquipélago Suspenso:
    - rock_floating_island_chunk (Rocks): Ilha flutuante com estalactites rochosas e cristal de levitação
    - nature_vine_suspension_bridge (Nature): Ponte suspensa de cipós ancestrais e tábuas rústicas
16. Vale das Mariposas:
    - prop_butterfly_mana_shrine (Props): Altar místico de mariposas com crisálida de mana emissiva
17. Espinha Verde:
    - rock_sylvaran_emerald_crystal (Rocks): Rochedo montanhoso cravejado de cristais de esmeralda
18. Ninho das Brumas:
    - structure_mist_nest_spire (Structures): Torre espiral de raízes e vime com mirante superior
19. Ruínas de Lyth:
    - structure_lyth_ancient_ruin (Structures): Fachada em ruínas da cidade ancestral de Lyth com arcos ogivais e hera
20. Fonte do Primeiro Broto:
    - structure_first_sprout_monument (Structures): Monumento sagrado com terraços rúnicos e o Broto Primordial emissivo

Regras:
- Arquivos .blend salvos em: AbyssalPact_ArtSource/Blender/{Nature, Structures, Props, Rocks}
- Arquivos .glb exportados para: assets/models/environment/{nature, structures, props, rocks}
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
# 11. RAIZ ANTIGA (REG-011): Árvore Colossal & Arco de Raízes Monumentais
# ==============================================================================

def build_colossal_tree_ancient():
    clear_scene()
    mat_bark = create_material("mat_ancient_bark", (0.20, 0.14, 0.10, 1.0), roughness=0.9, metallic=0.0)
    mat_moss = create_material("mat_ancient_moss", (0.12, 0.28, 0.12, 1.0), roughness=0.85, metallic=0.0)
    mat_leaves = create_material("mat_sylvaran_canopy", (0.08, 0.35, 0.16, 1.0), roughness=0.7, metallic=0.0)

    # Tronco colossal central
    bpy.ops.mesh.primitive_cylinder_add(radius=4.5, depth=18.0, location=(0, 0, 9.0))
    trunk = bpy.context.active_object
    trunk.name = "Tree_Trunk"
    trunk.scale = (1.0, 0.9, 1.0)
    trunk.data.materials.append(mat_bark)

    # Raízes tabulares monumentais projetando-se no solo
    roots = []
    for i in range(5):
        angle = (2.0 * math.pi / 5.0) * i
        rx = math.cos(angle) * 7.5
        ry = math.sin(angle) * 7.5
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(rx, ry, 2.5))
        root = bpy.context.active_object
        root.name = f"Tabular_Root_{i+1}"
        root.scale = (3.5, 1.2, 5.0)
        root.rotation_euler = (0, math.radians(20), angle)
        root.data.materials.append(mat_moss)
        roots.append(root)

    # Galhos principais superiores
    branches = []
    branch_coords = [
        (4.5, 0, 15.0, 0, math.radians(40), 0),
        (-3.5, 3.5, 16.0, math.radians(35), math.radians(-30), 0),
        (-2.0, -4.0, 15.5, math.radians(-35), math.radians(-25), 0)
    ]
    for idx, (bx, by, bz, rx, ry, rz) in enumerate(branch_coords):
        bpy.ops.mesh.primitive_cylinder_add(radius=1.6, depth=9.0, location=(bx, by, bz))
        branch = bpy.context.active_object
        branch.name = f"Great_Branch_{idx+1}"
        branch.rotation_euler = (rx, ry, rz)
        branch.data.materials.append(mat_bark)
        branches.append(branch)

    # Folhagens volumétricas da copa
    canopies = []
    canopy_coords = [
        (0, 0, 21.0, 8.5, 5.0),
        (6.0, 1.0, 18.5, 6.0, 4.0),
        (-5.0, 4.0, 19.5, 6.5, 4.2),
        (-3.0, -5.5, 19.0, 5.8, 3.8)
    ]
    for idx, (cx, cy, cz, cr, ch) in enumerate(canopy_coords):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=cr, location=(cx, cy, cz))
        foliage = bpy.context.active_object
        foliage.name = f"Canopy_Cluster_{idx+1}"
        foliage.scale = (1.0, 1.0, ch / cr)
        foliage.data.materials.append(mat_leaves)
        canopies.append(foliage)

    objs = [trunk] + roots + branches + canopies
    return export_asset("nature_colossal_tree_ancient", "Nature", objs)

def build_monumental_roots_arch():
    clear_scene()
    mat_bark = create_material("mat_root_bark", (0.22, 0.15, 0.11, 1.0), roughness=0.88, metallic=0.0)
    mat_moss = create_material("mat_root_moss", (0.15, 0.32, 0.14, 1.0), roughness=0.8, metallic=0.0)
    mat_vines = create_material("mat_hanging_vines", (0.18, 0.40, 0.16, 1.0), roughness=0.75, metallic=0.0)

    # Pilar esquerdo de raiz
    bpy.ops.mesh.primitive_cylinder_add(radius=1.8, depth=8.0, location=(-4.5, 0, 4.0))
    left_root = bpy.context.active_object
    left_root.name = "Root_Left_Pillar"
    left_root.rotation_euler = (0, math.radians(18), 0)
    left_root.data.materials.append(mat_bark)

    # Pilar direito de raiz
    bpy.ops.mesh.primitive_cylinder_add(radius=1.8, depth=8.0, location=(4.5, 0, 4.0))
    right_root = bpy.context.active_object
    right_root.name = "Root_Right_Pillar"
    right_root.rotation_euler = (0, math.radians(-18), 0)
    right_root.data.materials.append(mat_bark)

    # Arco superior conector
    bpy.ops.mesh.primitive_torus_add(major_radius=4.8, minor_radius=1.2, location=(0, 0, 7.2))
    arch = bpy.context.active_object
    arch.name = "Root_Arch_Apex"
    arch.rotation_euler = (math.radians(90), 0, 0)
    arch.scale = (1.0, 0.6, 1.0)
    arch.data.materials.append(mat_moss)

    # Cipós suspensos no vão
    vines = []
    for i in range(5):
        vx = -3.0 + i * 1.5
        vh = 3.5 - abs(vx) * 0.4
        bpy.ops.mesh.primitive_cylinder_add(radius=0.12, depth=vh, location=(vx, 0.1 * (i % 2), 6.5 - vh/2))
        vine = bpy.context.active_object
        vine.name = f"Hanging_Vine_{i+1}"
        vine.data.materials.append(mat_vines)
        vines.append(vine)

    objs = [left_root, right_root, arch] + vines
    return export_asset("nature_monumental_roots_arch", "Nature", objs)

# ==============================================================================
# 12. PÂNTANO DAS LANTERNAS (REG-012): Planta Bioluminescente & Poste de Pântano
# ==============================================================================

def build_bioluminescent_lantern_plant():
    clear_scene()
    mat_stem = create_material("mat_swamp_reed", (0.16, 0.26, 0.14, 1.0), roughness=0.8)
    mat_glow = create_material(
        "mat_bioluminescent_bulb",
        (0.20, 0.95, 0.70, 1.0),
        roughness=0.2,
        metallic=0.1,
        emission=(0.20, 0.95, 0.75, 1.0),
        emission_strength=4.0
    )
    mat_petal = create_material("mat_luminescent_frond", (0.10, 0.45, 0.30, 1.0), roughness=0.6)

    # Caule curvo principal
    bpy.ops.mesh.primitive_cylinder_add(radius=0.35, depth=5.5, location=(0, 0, 2.75))
    stem = bpy.context.active_object
    stem.name = "Lantern_Stem"
    stem.rotation_euler = (math.radians(12), 0, 0)
    stem.data.materials.append(mat_stem)

    # 3 Bulbos luminosos pendentes
    bulbs = []
    bulb_positions = [
        (0, 0.8, 5.4, 0.75),
        (-0.6, 0.4, 4.3, 0.55),
        (0.6, 0.3, 3.6, 0.50)
    ]
    for idx, (bx, by, bz, br) in enumerate(bulb_positions):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=br, location=(bx, by, bz))
        bulb = bpy.context.active_object
        bulb.name = f"Luminous_Bulb_{idx+1}"
        bulb.scale = (1.0, 1.0, 1.35)
        bulb.data.materials.append(mat_glow)
        bulbs.append(bulb)

    # Samambaias e folhas na base
    fronds = []
    for i in range(6):
        fa = (2.0 * math.pi / 6.0) * i
        fx = math.cos(fa) * 1.4
        fy = math.sin(fa) * 1.4
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(fx, fy, 0.4))
        frond = bpy.context.active_object
        frond.name = f"Base_Frond_{i+1}"
        frond.scale = (1.6, 0.35, 0.1)
        frond.rotation_euler = (math.radians(-25), 0, fa)
        frond.data.materials.append(mat_petal)
        fronds.append(frond)

    objs = [stem] + bulbs + fronds
    return export_asset("nature_bioluminescent_lantern_plant", "Nature", objs)

def build_swamp_lantern_post():
    clear_scene()
    mat_wood = create_material("mat_peat_wood", (0.16, 0.12, 0.10, 1.0), roughness=0.9)
    mat_cage = create_material("mat_wicker_iron", (0.10, 0.09, 0.09, 1.0), roughness=0.7, metallic=0.5)
    mat_fungus_glow = create_material(
        "mat_swamp_fungus_glow",
        (0.85, 0.80, 0.25, 1.0),
        roughness=0.3,
        emission=(0.95, 0.85, 0.20, 1.0),
        emission_strength=3.5
    )

    # Poste de madeira retorcido fincado no lodo
    bpy.ops.mesh.primitive_cylinder_add(radius=0.28, depth=4.2, location=(0, 0, 2.1))
    post = bpy.context.active_object
    post.name = "Peat_Post"
    post.rotation_euler = (math.radians(5), math.radians(-4), 0)
    post.data.materials.append(mat_wood)

    # Braço horizontal de suporte
    bpy.ops.mesh.primitive_cylinder_add(radius=0.15, depth=1.6, location=(0.6, 0, 3.8))
    arm = bpy.context.active_object
    arm.name = "Post_Arm"
    arm.rotation_euler = (0, math.radians(90), 0)
    arm.data.materials.append(mat_wood)

    # Gaiola / lanterna de vime suspensa
    bpy.ops.mesh.primitive_cylinder_add(radius=0.35, depth=0.8, location=(1.2, 0, 3.2))
    cage = bpy.context.active_object
    cage.name = "Wicker_Cage"
    cage.data.materials.append(mat_cage)

    # Núcleo de fungos brilhantes dentro da gaiola
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.25, location=(1.2, 0, 3.2))
    core = bpy.context.active_object
    core.name = "Glowing_Fungus_Core"
    core.data.materials.append(mat_fungus_glow)

    objs = [post, arm, cage, core]
    return export_asset("prop_swamp_lantern_post", "Props", objs)

# ==============================================================================
# 13. COPA CELESTE (REG-013): Plataforma em Galho Elevado (Canopy Walkway)
# ==============================================================================

def build_canopy_platform_branch():
    clear_scene()
    mat_bark = create_material("mat_canopy_branch_bark", (0.24, 0.17, 0.12, 1.0), roughness=0.85)
    mat_wood_deck = create_material("mat_carved_deck", (0.35, 0.25, 0.16, 1.0), roughness=0.75)
    mat_rope = create_material("mat_canopy_rope", (0.42, 0.35, 0.22, 1.0), roughness=0.8)

    # Galho colossal estrutural (comprimento 18m)
    bpy.ops.mesh.primitive_cylinder_add(radius=2.8, depth=18.0, location=(0, 0, 0))
    branch = bpy.context.active_object
    branch.name = "Colossal_Branch_Base"
    branch.rotation_euler = (0, math.radians(90), 0)
    branch.data.materials.append(mat_bark)

    # Deck de caminhada aplanado entalhado na parte superior
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 2.7))
    deck = bpy.context.active_object
    deck.name = "Deck_Walkway"
    deck.scale = (17.5, 4.2, 0.4)
    deck.data.materials.append(mat_wood_deck)

    # Balaustradas laterais e postes de corda
    railings = []
    for side in [-1.9, 1.9]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, side, 3.8))
        rail = bpy.context.active_object
        rail.name = f"Railing_Beam_{'L' if side < 0 else 'R'}"
        rail.scale = (17.5, 0.25, 0.3)
        rail.data.materials.append(mat_bark)
        railings.append(rail)

        for i in range(5):
            px = -7.0 + i * 3.5
            bpy.ops.mesh.primitive_cylinder_add(radius=0.15, depth=1.2, location=(px, side, 3.3))
            post = bpy.context.active_object
            post.name = f"Railing_Post_{px:.1f}_{side}"
            post.data.materials.append(mat_rope)
            railings.append(post)

    objs = [branch, deck] + railings
    return export_asset("nature_canopy_platform_branch", "Nature", objs)

# ==============================================================================
# 14. JARDIM AFOGADO (REG-014): Pavilhão de Colunata de Mármore Submerso
# ==============================================================================

def build_drowned_garden_pavilion():
    clear_scene()
    mat_marble = create_material("mat_drowned_marble", (0.58, 0.62, 0.58, 1.0), roughness=0.6, metallic=0.05)
    mat_algae = create_material("mat_water_algae", (0.12, 0.32, 0.18, 1.0), roughness=0.9)
    mat_crystal_urn = create_material(
        "mat_aquatic_mana_urn",
        (0.20, 0.70, 0.85, 1.0),
        roughness=0.15,
        emission=(0.25, 0.80, 0.95, 1.0),
        emission_strength=2.8
    )

    # Base circular octogonal do pavilhão (submersa em espelho d'água)
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=7.5, depth=1.2, location=(0, 0, 0.6))
    base = bpy.context.active_object
    base.name = "Pavilion_Platform"
    base.data.materials.append(mat_marble)

    # Degrau inferior
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=8.8, depth=0.6, location=(0, 0, 0.3))
    step = bpy.context.active_object
    step.name = "Submerged_Plinth"
    step.data.materials.append(mat_algae)

    # 8 Colunas dóricas clássicas com hera e musgo aquático
    columns = []
    for i in range(8):
        ca = (2.0 * math.pi / 8.0) * i
        cx = math.cos(ca) * 6.0
        cy = math.sin(ca) * 6.0
        # Algumas colunas estão partidas pela água
        ch = 5.5 if (i % 3 != 0) else 3.2
        bpy.ops.mesh.primitive_cylinder_add(radius=0.55, depth=ch, location=(cx, cy, 1.2 + ch/2))
        col = bpy.context.active_object
        col.name = f"Sunken_Col_{i+1}"
        col.data.materials.append(mat_marble)
        columns.append(col)

    # Anel de entablamento superior (parcialmente preservado)
    bpy.ops.mesh.primitive_torus_add(major_radius=6.0, minor_radius=0.6, location=(0, 0, 7.0))
    entablature = bpy.context.active_object
    entablature.name = "Pavilion_Entablature"
    entablature.data.materials.append(mat_marble)

    # Urna mística central com relíquia marinha brilhante
    bpy.ops.mesh.primitive_cylinder_add(radius=1.2, depth=1.4, location=(0, 0, 1.9))
    urn_base = bpy.context.active_object
    urn_base.name = "Urn_Pedestal"
    urn_base.data.materials.append(mat_marble)

    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.65, location=(0, 0, 2.9))
    relic = bpy.context.active_object
    relic.name = "Aquatic_Relic_Heart"
    relic.data.materials.append(mat_crystal_urn)

    objs = [base, step, entablature, urn_base, relic] + columns
    return export_asset("structure_drowned_garden_pavilion", "Structures", objs)

# ==============================================================================
# 15. ARQUIPÉLAGO SUSPENSO (REG-015): Ilha Flutuante & Ponte de Cipó
# ==============================================================================

def build_floating_island_chunk():
    clear_scene()
    mat_rock = create_material("mat_floating_rock", (0.28, 0.26, 0.24, 1.0), roughness=0.85)
    mat_grass = create_material("mat_island_grass", (0.16, 0.38, 0.18, 1.0), roughness=0.8)
    mat_gravity_crystal = create_material(
        "mat_levitation_emerald",
        (0.15, 0.95, 0.50, 1.0),
        roughness=0.15,
        emission=(0.20, 0.98, 0.55, 1.0),
        emission_strength=4.5
    )

    # Topo plano habitável da ilha
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=9.0, depth=2.5, location=(0, 0, 1.25))
    top = bpy.context.active_object
    top.name = "Island_Top_Surface"
    top.data.materials.append(mat_grass)

    # Quilha rochosa invertida (estalactite de rochas pontiagudas para baixo)
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=8.5, radius2=0.8, depth=8.0, location=(0, 0, -4.0))
    cone = bpy.context.active_object
    cone.name = "Island_Under_Crag"
    cone.rotation_euler = (math.radians(180), 0, 0)
    cone.data.materials.append(mat_rock)

    # Agulhas menores de rocha pendente
    spires = []
    for i in range(4):
        sa = (2.0 * math.pi / 4.0) * i + 0.3
        sx = math.cos(sa) * 5.2
        sy = math.sin(sa) * 5.2
        bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=2.2, radius2=0.2, depth=5.5, location=(sx, sy, -2.5))
        spire = bpy.context.active_object
        spire.name = f"Inverted_Spire_{i+1}"
        spire.rotation_euler = (math.radians(180), 0, sa)
        spire.data.materials.append(mat_rock)
        spires.append(spire)

    # Cristal de levitação abissal cravado no fundo inferior
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=1.3, depth=3.5, location=(0, 0, -7.0))
    crystal = bpy.context.active_object
    crystal.name = "Gravity_Levitation_Crystal"
    crystal.data.materials.append(mat_gravity_crystal)

    objs = [top, cone, crystal] + spires
    return export_asset("rock_floating_island_chunk", "Rocks", objs)

def build_vine_suspension_bridge():
    clear_scene()
    mat_vine = create_material("mat_bridge_thick_vine", (0.22, 0.16, 0.10, 1.0), roughness=0.85)
    mat_plank = create_material("mat_bridge_wood_plank", (0.32, 0.24, 0.16, 1.0), roughness=0.8)

    # 4 Cabos principais de cipó arqueados (extensão 18m)
    cables = []
    for side in [-1.6, 1.6]:
        # Cabo inferior
        bpy.ops.mesh.primitive_cylinder_add(radius=0.18, depth=18.0, location=(0, side, 0.0))
        cab_low = bpy.context.active_object
        cab_low.name = f"Main_Cable_Low_{'L' if side < 0 else 'R'}"
        cab_low.rotation_euler = (0, math.radians(90), 0)
        cab_low.data.materials.append(mat_vine)
        cables.append(cab_low)

        # Corrimão de cipó superior
        bpy.ops.mesh.primitive_cylinder_add(radius=0.14, depth=18.0, location=(0, side, 1.4))
        cab_high = bpy.context.active_object
        cab_high.name = f"Handrail_Cable_{'L' if side < 0 else 'R'}"
        cab_high.rotation_euler = (0, math.radians(90), 0)
        cab_high.data.materials.append(mat_vine)
        cables.append(cab_high)

    # Pranchas rústicas transversais
    planks = []
    for i in range(16):
        px = -8.0 + i * 1.06
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(px, 0, 0.08))
        plank = bpy.context.active_object
        plank.name = f"Bridge_Plank_{i+1}"
        plank.scale = (0.7, 3.4, 0.12)
        plank.data.materials.append(mat_plank)
        planks.append(plank)

    objs = cables + planks
    return export_asset("nature_vine_suspension_bridge", "Nature", objs)

# ==============================================================================
# 16. VALE DAS MARIPOSAS (REG-016): Altar de Crisálida e Mana de Insetos
# ==============================================================================

def build_butterfly_mana_shrine():
    clear_scene()
    mat_shrine_stone = create_material("mat_ancient_shrine_stone", (0.35, 0.33, 0.36, 1.0), roughness=0.7)
    mat_chrysalis_core = create_material(
        "mat_mana_chrysalis",
        (0.65, 0.25, 0.95, 1.0),
        roughness=0.2,
        emission=(0.75, 0.35, 1.0, 1.0),
        emission_strength=4.2
    )
    mat_flower = create_material("mat_mana_flower_petal", (0.85, 0.40, 0.70, 1.0), roughness=0.5)

    # Base em pedestal triplo escalonado
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=4.2, depth=0.8, location=(0, 0, 0.4))
    base1 = bpy.context.active_object
    base1.name = "Shrine_Terrace_1"
    base1.data.materials.append(mat_shrine_stone)

    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=3.2, depth=0.6, location=(0, 0, 1.0))
    base2 = bpy.context.active_object
    base2.name = "Shrine_Terrace_2"
    base2.data.materials.append(mat_shrine_stone)

    # 3 Estelas em formato de asa de mariposa cercando o centro
    wings = []
    for i in range(3):
        wa = (2.0 * math.pi / 3.0) * i
        wx = math.cos(wa) * 2.2
        wy = math.sin(wa) * 2.2
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(wx, wy, 2.5))
        wing = bpy.context.active_object
        wing.name = f"Butterfly_Wing_Stele_{i+1}"
        wing.scale = (0.3, 1.8, 3.2)
        wing.rotation_euler = (math.radians(10), math.radians(15), wa)
        wing.data.materials.append(mat_shrine_stone)
        wings.append(wing)

    # Grande Crisálida de Mana Flutuante no centro
    bpy.ops.mesh.primitive_cylinder_add(radius=0.9, depth=2.4, location=(0, 0, 2.6))
    chrysalis = bpy.context.active_object
    chrysalis.name = "Great_Mana_Chrysalis"
    chrysalis.scale = (1.0, 0.7, 1.0)
    chrysalis.data.materials.append(mat_chrysalis_core)

    objs = [base1, base2, chrysalis] + wings
    return export_asset("prop_butterfly_mana_shrine", "Props", objs)

# ==============================================================================
# 17. ESPINHA VERDE (REG-017): Rochedo de Cristais de Esmeralda
# ==============================================================================

def build_sylvaran_emerald_crystal():
    clear_scene()
    mat_crag = create_material("mat_overgrown_slate", (0.20, 0.22, 0.18, 1.0), roughness=0.9)
    mat_emerald = create_material(
        "mat_sylvaran_emerald_cluster",
        (0.12, 0.95, 0.38, 1.0),
        roughness=0.15,
        metallic=0.1,
        emission=(0.15, 0.98, 0.42, 1.0),
        emission_strength=4.5
    )

    # Maciço rochoso montanhoso central
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 3.0))
    crag = bpy.context.active_object
    crag.name = "Mountain_Crag_Ridge"
    crag.scale = (8.0, 5.0, 6.0)
    crag.rotation_euler = (math.radians(8), math.radians(-12), math.radians(25))
    crag.data.materials.append(mat_crag)

    # Aglomerado de prismas hexagonais de esmeralda brotando da rocha
    crystals = []
    crystal_specs = [
        (0, 0, 6.5, 1.2, 5.5, 0, math.radians(10), 0),
        (2.0, 1.2, 5.2, 0.8, 4.2, math.radians(20), math.radians(15), 0),
        (-1.8, -0.8, 4.8, 0.9, 4.0, math.radians(-15), math.radians(-20), 0),
        (1.2, -1.8, 4.2, 0.7, 3.5, math.radians(-25), math.radians(10), 0),
        (-1.5, 1.6, 4.0, 0.75, 3.8, math.radians(22), math.radians(-15), 0)
    ]
    for idx, (cx, cy, cz, cr, ch, rx, ry, rz) in enumerate(crystal_specs):
        bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=cr, depth=ch, location=(cx, cy, cz))
        cryst = bpy.context.active_object
        cryst.name = f"Emerald_Prism_{idx+1}"
        cryst.rotation_euler = (rx, ry, rz)
        cryst.data.materials.append(mat_emerald)
        crystals.append(cryst)

    objs = [crag] + crystals
    return export_asset("rock_sylvaran_emerald_crystal", "Rocks", objs)

# ==============================================================================
# 18. NINHO DAS BRUMAS (REG-018): Torre Espiral de Raízes e Vime
# ==============================================================================

def build_mist_nest_spire():
    clear_scene()
    mat_spire_wood = create_material("mat_petrified_bramble", (0.18, 0.15, 0.13, 1.0), roughness=0.88)
    mat_wicker = create_material("mat_woven_wicker", (0.28, 0.22, 0.14, 1.0), roughness=0.82)
    mat_mist_orb = create_material(
        "mat_mist_eye_orb",
        (0.60, 0.85, 0.95, 1.0),
        roughness=0.2,
        emission=(0.65, 0.90, 1.0, 1.0),
        emission_strength=3.2
    )

    # Pilares de raiz espiralada formando o tronco da torre (altura 15m)
    bpy.ops.mesh.primitive_cylinder_add(radius=2.5, depth=15.0, location=(0, 0, 7.5))
    spire_core = bpy.context.active_object
    spire_core.name = "Bramble_Spire_Core"
    spire_core.data.materials.append(mat_spire_wood)

    # Degraus espiralados externos contornando a torre
    steps = []
    for i in range(12):
        sa = (math.pi / 4.0) * i
        sx = math.cos(sa) * 3.2
        sy = math.sin(sa) * 3.2
        sz = 1.0 + i * 1.1
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx, sy, sz))
        step = bpy.context.active_object
        step.name = f"Spiral_Step_{i+1}"
        step.scale = (1.6, 0.8, 0.25)
        step.rotation_euler = (0, 0, sa)
        step.data.materials.append(mat_spire_wood)
        steps.append(step)

    # Ninho / mirante superior de vime trançado
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=4.2, depth=2.0, location=(0, 0, 15.5))
    nest = bpy.context.active_object
    nest.name = "Upper_Wicker_Nest"
    nest.data.materials.append(mat_wicker)

    # Orbe guardião das brumas no topo
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.9, location=(0, 0, 17.5))
    orb = bpy.context.active_object
    orb.name = "Mist_Watcher_Orb"
    orb.data.materials.append(mat_mist_orb)

    objs = [spire_core, nest, orb] + steps
    return export_asset("structure_mist_nest_spire", "Structures", objs)

# ==============================================================================
# 19. RUÍNAS DE LYTH (REG-019): Fachada em Ruínas da Cidade Ancestral
# ==============================================================================

def build_lyth_ancient_ruin():
    clear_scene()
    mat_stone = create_material("mat_lyth_ancient_masonry", (0.42, 0.40, 0.38, 1.0), roughness=0.75)
    mat_ivy = create_material("mat_creeping_ivy_roots", (0.14, 0.32, 0.12, 1.0), roughness=0.85)

    # Estrado e alicerces
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.6))
    base = bpy.context.active_object
    base.name = "Lyth_Foundation"
    base.scale = (16.0, 6.0, 1.2)
    base.data.materials.append(mat_stone)

    # Grande Portal Central Ogival
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-3.2, 0, 5.0))
    p_left = bpy.context.active_object
    p_left.name = "Pillar_Left"
    p_left.scale = (1.6, 1.8, 8.0)
    p_left.data.materials.append(mat_stone)

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(3.2, 0, 5.0))
    p_right = bpy.context.active_object
    p_right.name = "Pillar_Right"
    p_right.scale = (1.6, 1.8, 8.0)
    p_right.data.materials.append(mat_stone)

    # Arco quebrado superior
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 9.4))
    arch = bpy.context.active_object
    arch.name = "Gothic_Arch_Lintel"
    arch.scale = (7.5, 2.0, 1.4)
    arch.data.materials.append(mat_stone)

    # Frontão quebrado com relevo élfico
    bpy.ops.mesh.primitive_cone_add(vertices=3, radius1=4.5, radius2=0, depth=2.8, location=(0, 0, 11.2))
    pediment = bpy.context.active_object
    pediment.name = "Broken_Pediment"
    pediment.scale = (1.0, 0.4, 1.0)
    pediment.rotation_euler = (0, 0, 0)
    pediment.data.materials.append(mat_stone)

    # Raízes invasoras que abraçam a estrutura
    roots = []
    for i in range(3):
        ra = math.radians(25 * (i - 1))
        bpy.ops.mesh.primitive_cylinder_add(radius=0.45, depth=9.5, location=(-3.2 + i*3.0, 0.8, 5.0))
        r = bpy.context.active_object
        r.name = f"Invading_Root_{i+1}"
        r.rotation_euler = (math.radians(12), ra, math.radians(-10))
        r.data.materials.append(mat_ivy)
        roots.append(r)

    objs = [base, p_left, p_right, arch, pediment] + roots
    return export_asset("structure_lyth_ancient_ruin", "Structures", objs)

# ==============================================================================
# 20. FONTE DO PRIMEIRO BROTO (REG-020): Monumento Sagrado da Vida Mágica
# ==============================================================================

def build_first_sprout_monument():
    clear_scene()
    mat_font_stone = create_material("mat_primal_font_stone", (0.32, 0.35, 0.33, 1.0), roughness=0.65)
    mat_gold_runes = create_material(
        "mat_life_runes",
        (0.85, 0.72, 0.20, 1.0),
        roughness=0.3,
        metallic=0.4,
        emission=(0.95, 0.80, 0.25, 1.0),
        emission_strength=3.0
    )
    mat_sprout_core = create_material(
        "mat_first_sprout_glow",
        (0.25, 0.98, 0.55, 1.0),
        roughness=0.15,
        emission=(0.30, 1.0, 0.60, 1.0),
        emission_strength=5.0
    )

    # Terraço 1 (Base circular inferior - raio 12m)
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=12.0, depth=1.0, location=(0, 0, 0.5))
    t1 = bpy.context.active_object
    t1.name = "Sacred_Terrace_1"
    t1.data.materials.append(mat_font_stone)

    # Terraço 2 (Intermediário - raio 8.5m)
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=8.5, depth=0.8, location=(0, 0, 1.4))
    t2 = bpy.context.active_object
    t2.name = "Sacred_Terrace_2"
    t2.data.materials.append(mat_font_stone)

    # Bacia de Água Primordial (Terraço 3 com anel rúnico)
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=5.5, depth=0.9, location=(0, 0, 2.25))
    basin = bpy.context.active_object
    basin.name = "Primal_Water_Basin"
    basin.data.materials.append(mat_gold_runes)

    # 4 Pilares espiralados de pedra circundando a fonte
    pillars = []
    for i in range(4):
        pa = (math.pi / 2.0) * i + math.pi/4.0
        px = math.cos(pa) * 6.5
        py = math.sin(pa) * 6.5
        bpy.ops.mesh.primitive_cylinder_add(radius=0.7, depth=5.5, location=(px, py, 4.5))
        p = bpy.context.active_object
        p.name = f"Guardian_Pillar_{i+1}"
        p.rotation_euler = (math.radians(8 * math.sin(pa)), math.radians(8 * math.cos(pa)), 0)
        p.data.materials.append(mat_font_stone)
        pillars.append(p)

    # O Broto Primordial (Apex luminoso)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=1.6, location=(0, 0, 4.2))
    seed = bpy.context.active_object
    seed.name = "Primal_Sprout_Core"
    seed.scale = (0.85, 0.85, 1.5)
    seed.data.materials.append(mat_sprout_core)

    # Folhas nascentes radiantes em cone
    leaves = []
    for i in range(4):
        la = (math.pi / 2.0) * i
        lx = math.cos(la) * 1.5
        ly = math.sin(la) * 1.5
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.8, radius2=0, depth=3.0, location=(lx, ly, 6.0))
        leaf = bpy.context.active_object
        leaf.name = f"Radiant_Leaf_{i+1}"
        leaf.rotation_euler = (math.radians(25 * math.sin(la)), math.radians(-25 * math.cos(la)), la)
        leaf.data.materials.append(mat_sprout_core)
        leaves.append(leaf)

    objs = [t1, t2, basin, seed] + pillars + leaves
    return export_asset("structure_first_sprout_monument", "Structures", objs)

# ==============================================================================
# EXECUÇÃO PRINCIPAL
# ==============================================================================

def main():
    print("======================================================================")
    print("ABYSSAL PACT — GERANDO ASSETS 3D DE SYLVARAN (HEADLESS BLENDER)")
    print(f"Diretório ArtSource (.blend): {ART_SOURCE_DIR}")
    print(f"Diretório Modelos (.glb):     {MODELS_OUT_DIR}")
    print("======================================================================")

    generated = []

    # 11. Raiz Antiga
    generated.append(build_colossal_tree_ancient())
    generated.append(build_monumental_roots_arch())

    # 12. Pântano das Lanternas
    generated.append(build_bioluminescent_lantern_plant())
    generated.append(build_swamp_lantern_post())

    # 13. Copa Celeste
    generated.append(build_canopy_platform_branch())

    # 14. Jardim Afogado
    generated.append(build_drowned_garden_pavilion())

    # 15. Arquipélago Suspenso
    generated.append(build_floating_island_chunk())
    generated.append(build_vine_suspension_bridge())

    # 16. Vale das Mariposas
    generated.append(build_butterfly_mana_shrine())

    # 17. Espinha Verde
    generated.append(build_sylvaran_emerald_crystal())

    # 18. Ninho das Brumas
    generated.append(build_mist_nest_spire())

    # 19. Ruínas de Lyth
    generated.append(build_lyth_ancient_ruin())

    # 20. Fonte do Primeiro Broto
    generated.append(build_first_sprout_monument())

    print("======================================================================")
    print(f"SUCESSO: {len(generated)} assets 3D de Sylvaran gerados e exportados.")
    print("======================================================================")

if __name__ == "__main__":
    main()
