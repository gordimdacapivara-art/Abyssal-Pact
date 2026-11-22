"""
ABYSSAL PACT — Modelagem 3D dos Monumentos e Ambientes de Nhal'Kora (Blender 5.3+ Headless)

Constrói proceduralmente os assets e estruturas exclusivas para as 10 regiões de NHAL'KORA (REG-031 a REG-040):
31. Geleira dos Ecos:
    - rock_glacial_echo_cliff (Rocks): Falésia glacial de gelo azul com agulhas e caverna de eco
    - prop_ice_resonator_crystal (Props): Pináculo ressonador de gelo acústico
32. Cidade Submersa de Gelo:
    - structure_submerged_ice_citadel (Structures): Cidadela com torres e arcos parcialmente preservados sob placas de gelo translúcido
33. Tundra Branca:
    - prop_tundra_bone_cairn_marker (Props): Marco de tundra com ossos petrificados, correntes e lanterna de gelo
34. Pináculo do Silêncio:
    - rock_needle_peak_ice_spire (Rocks): Agulha montanhosa vertiginosa envolta em gelo azul e rocha escura
35. Bosque de Cristal:
    - nature_crystal_canopy_tree (Nature): Árvore monumental congelada com copa de prismas cristalinos emissivos
36. Fenda do Inverno:
    - rock_winter_chasm_crevasse (Rocks): Grande abertura de fenda glacial com pontes de gelo naturais e estalactites
37. Costa Boreal:
    - structure_boreal_coastal_pier (Structures): Píer costeiro de pedra e madeira gélida com arcos de ossos e braseiro
38. Palácio Adormecido:
    - structure_sleeping_palace_monument (Structures): Monumental palácio gótico de gelo com torres, balcões e frontão
39. Cemitério das Estrelas:
    - prop_astral_star_geode_shrine (Props): Altar de meteorito com geodo estelar aberto de cristais astrais violetas
40. Trono da Aurora Morta:
    - structure_dead_aurora_throne (Structures): Trono monumental de gelo negro sobre 3 terraços com auréola de aurora boreal flutuante
    - rock_aurora_monolith_sentinel (Rocks): Monolito sentinela de basalto gélido com runas astrais

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
# 31. GELEIRA DOS ECOS (REG-031)
# ==============================================================================

def build_glacial_echo_cliff():
    clear_scene()
    mat_blue_ice = create_material("mat_glacial_blue_ice", (0.28, 0.65, 0.88, 1.0), roughness=0.18, metallic=0.15)
    mat_snow = create_material("mat_packed_snow", (0.92, 0.95, 0.98, 1.0), roughness=0.85)

    # Maciço da falésia glacial de gelo azul
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 8.0))
    cliff = bpy.context.active_object
    cliff.name = "Glacial_Cliff_Massif"
    cliff.scale = (20.0, 8.0, 16.0)
    cliff.rotation_euler = (math.radians(-6), 0, 0)
    cliff.data.materials.append(mat_blue_ice)

    # Manto de neve compactada no topo
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 16.2))
    snow_top = bpy.context.active_object
    snow_top.name = "Snow_Crust_Apex"
    snow_top.scale = (20.5, 8.5, 1.2)
    snow_top.data.materials.append(mat_snow)

    # Agulhas e estalagmites de gelo ressonante na base
    spires = []
    for i in range(5):
        sx = -8.0 + i * 4.0
        sy = -3.5 + (i % 2) * 1.5
        bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=1.4, radius2=0.15, depth=7.0, location=(sx, sy, 3.5))
        spire = bpy.context.active_object
        spire.name = f"Ice_Needle_{i+1}"
        spire.rotation_euler = (math.radians(12), math.radians(-10 * (i % 3 - 1)), math.radians(i * 20))
        spire.data.materials.append(mat_blue_ice)
        spires.append(spire)

    objs = [cliff, snow_top] + spires
    return export_asset("rock_glacial_echo_cliff", "Rocks", objs)

def build_ice_resonator_crystal():
    clear_scene()
    mat_crystal = create_material(
        "mat_ice_resonator",
        (0.35, 0.80, 1.0, 1.0),
        roughness=0.1,
        metallic=0.1,
        emission=(0.40, 0.85, 1.0, 1.0),
        emission_strength=4.0
    )

    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=1.2, depth=6.0, location=(0, 0, 3.0))
    cryst = bpy.context.active_object
    cryst.name = "Resonator_Main_Prism"
    cryst.data.materials.append(mat_crystal)

    # 3 Cristais satélites menores na base
    satellites = []
    for i in range(3):
        sa = (2.0 * math.pi / 3.0) * i
        sx = math.cos(sa) * 1.8
        sy = math.sin(sa) * 1.8
        bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.55, depth=3.5, location=(sx, sy, 1.75))
        sat = bpy.context.active_object
        sat.name = f"Satellite_Prism_{i+1}"
        sat.rotation_euler = (math.radians(18 * math.cos(sa)), math.radians(18 * math.sin(sa)), sa)
        sat.data.materials.append(mat_crystal)
        satellites.append(sat)

    objs = [cryst] + satellites
    return export_asset("prop_ice_resonator_crystal", "Props", objs)

# ==============================================================================
# 32. CIDADE SUBMERSA DE GELO (REG-032) — ESTRUTURAS SOB O GELO
# ==============================================================================

def build_submerged_ice_citadel():
    clear_scene()
    mat_frozen_stone = create_material("mat_ancient_submerged_stone", (0.30, 0.35, 0.42, 1.0), roughness=0.7)
    mat_ice_crust = create_material(
        "mat_translucent_sheet_ice",
        (0.40, 0.72, 0.90, 1.0),
        roughness=0.1,
        emission=(0.35, 0.75, 0.95, 1.0),
        emission_strength=1.5
    )

    # Placa translúcida da superfície de gelo congelado
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 4.0))
    ice_sheet = bpy.context.active_object
    ice_sheet.name = "Translucent_Ice_Sheet"
    ice_sheet.scale = (18.0, 14.0, 1.0)
    ice_sheet.data.materials.append(mat_ice_crust)

    # Torres da catedral submersa projetando-se parcialmente através do gelo
    towers = []
    tower_coords = [(-6.0, -4.0), (6.0, -4.0), (-6.0, 4.0), (6.0, 4.0)]
    for idx, (tx, ty) in enumerate(tower_coords):
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(tx, ty, 5.0))
        t = bpy.context.active_object
        t.name = f"Submerged_Tower_{idx+1}"
        t.scale = (3.2, 3.2, 10.0)
        t.data.materials.append(mat_frozen_stone)
        towers.append(t)

        # Pináculo quebrado acima do gelo
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=1.8, radius2=0.2, depth=3.5, location=(tx, ty, 11.5))
        sp = bpy.context.active_object
        sp.name = f"Tower_Spire_{idx+1}"
        sp.data.materials.append(mat_frozen_stone)
        towers.append(sp)

    # Arcada central submersa
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 2.0))
    nave = bpy.context.active_object
    nave.name = "Submerged_Central_Nave"
    nave.scale = (8.0, 10.0, 4.0)
    nave.data.materials.append(mat_frozen_stone)

    objs = [ice_sheet, nave] + towers
    return export_asset("structure_submerged_ice_citadel", "Structures", objs)

# ==============================================================================
# 33. TUNDRA BRANCA (REG-033)
# ==============================================================================

def build_tundra_bone_cairn_marker():
    clear_scene()
    mat_mammoth_bone = create_material("mat_petrified_mammoth_bone", (0.85, 0.82, 0.78, 1.0), roughness=0.75)
    mat_cairn_stone = create_material("mat_tundra_frost_rock", (0.32, 0.35, 0.40, 1.0), roughness=0.85)
    mat_frost_lantern = create_material(
        "mat_blue_moss_lantern",
        (0.30, 0.85, 1.0, 1.0),
        roughness=0.2,
        emission=(0.35, 0.90, 1.0, 1.0),
        emission_strength=4.0
    )

    # Pilha de pedras do cairn
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.5, depth=2.0, location=(0, 0, 1.0))
    cairn = bpy.context.active_object
    cairn.name = "Tundra_Cairn_Base"
    cairn.data.materials.append(mat_cairn_stone)

    # 3 Presas / ossos de mamute arqueados sobre o marco
    bones = []
    for i in range(3):
        ba = (2.0 * math.pi / 3.0) * i
        bx = math.cos(ba) * 1.5
        by = math.sin(ba) * 1.5
        bpy.ops.mesh.primitive_cylinder_add(radius=0.25, depth=4.5, location=(bx, by, 3.2))
        bone = bpy.context.active_object
        bone.name = f"Mammoth_Tusk_{i+1}"
        bone.rotation_euler = (math.radians(20 * math.cos(ba)), math.radians(20 * math.sin(ba)), ba)
        bone.data.materials.append(mat_mammoth_bone)
        bones.append(bone)

    # Lanterna de gelo suspensa no ponto central
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.55, location=(0, 0, 4.2))
    lantern = bpy.context.active_object
    lantern.name = "Frost_Moss_Lantern"
    lantern.data.materials.append(mat_frost_lantern)

    objs = [cairn, lantern] + bones
    return export_asset("prop_tundra_bone_cairn_marker", "Props", objs)

# ==============================================================================
# 34. PINÁCULO DO SILÊNCIO (REG-034)
# ==============================================================================

def build_needle_peak_ice_spire():
    clear_scene()
    mat_peak_slate = create_material("mat_frozen_slate", (0.18, 0.20, 0.25, 1.0), roughness=0.8)
    mat_needle_ice = create_material(
        "mat_sheer_blue_ice",
        (0.30, 0.70, 0.95, 1.0),
        roughness=0.15,
        emission=(0.35, 0.75, 1.0, 1.0),
        emission_strength=2.2
    )

    # Agulha montanhosa principal afiada (altura 18m)
    bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=4.5, radius2=0.4, depth=18.0, location=(0, 0, 9.0))
    peak = bpy.context.active_object
    peak.name = "Needle_Peak_Summit"
    peak.rotation_euler = (math.radians(5), math.radians(-4), 0)
    peak.data.materials.append(mat_peak_slate)

    # Lâmina de gelo que embainha um dos lados do pináculo
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=3.8, radius2=0.2, depth=16.0, location=(0.6, 0.4, 8.5))
    glacier_sheath = bpy.context.active_object
    glacier_sheath.name = "Glacier_Sheath"
    glacier_sheath.data.materials.append(mat_needle_ice)

    objs = [peak, glacier_sheath]
    return export_asset("rock_needle_peak_ice_spire", "Rocks", objs)

# ==============================================================================
# 35. BOSQUE DE CRISTAL (REG-035)
# ==============================================================================

def build_crystal_canopy_tree():
    clear_scene()
    mat_frozen_bark = create_material("mat_ice_encased_bark", (0.24, 0.32, 0.40, 1.0), roughness=0.6)
    mat_prismatic_branch = create_material(
        "mat_prismatic_crystal_leaves",
        (0.35, 0.90, 1.0, 1.0),
        roughness=0.1,
        emission=(0.40, 0.95, 1.0, 1.0),
        emission_strength=4.5
    )

    # Tronco cristalizado
    bpy.ops.mesh.primitive_cylinder_add(radius=1.8, depth=9.0, location=(0, 0, 4.5))
    trunk = bpy.context.active_object
    trunk.name = "Crystal_Tree_Trunk"
    trunk.data.materials.append(mat_frozen_bark)

    # Galhos e copa em prismas cristalinos radiantes
    clusters = []
    coords = [
        (0, 0, 11.5, 3.8),
        (3.0, 1.5, 9.5, 2.5),
        (-2.5, 2.2, 10.0, 2.6),
        (-1.5, -3.0, 9.8, 2.4),
        (2.5, -2.0, 9.2, 2.3)
    ]
    for idx, (cx, cy, cz, cr) in enumerate(coords):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=cr, location=(cx, cy, cz))
        cluster = bpy.context.active_object
        cluster.name = f"Prismatic_Cluster_{idx+1}"
        cluster.data.materials.append(mat_prismatic_branch)
        clusters.append(cluster)

    objs = [trunk] + clusters
    return export_asset("nature_crystal_canopy_tree", "Nature", objs)

# ==============================================================================
# 36. FENDA DO INVERNO (REG-036)
# ==============================================================================

def build_winter_chasm_crevasse():
    clear_scene()
    mat_crevasse_ice = create_material("mat_deep_crevasse_ice", (0.15, 0.45, 0.70, 1.0), roughness=0.25)
    mat_bridge_ice = create_material("mat_natural_ice_bridge", (0.45, 0.78, 0.95, 1.0), roughness=0.15)

    # Lábio esquerdo da fenda
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-6.5, 0, 4.0))
    lip_l = bpy.context.active_object
    lip_l.name = "Crevasse_Lip_Left"
    lip_l.scale = (5.0, 16.0, 8.0)
    lip_l.data.materials.append(mat_crevasse_ice)

    # Lábio direito da fenda
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(6.5, 0, 4.0))
    lip_r = bpy.context.active_object
    lip_r.name = "Crevasse_Lip_Right"
    lip_r.scale = (5.0, 16.0, 8.0)
    lip_r.data.materials.append(mat_crevasse_ice)

    # Ponte de gelo natural cruzando o abismo
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 6.5))
    bridge = bpy.context.active_object
    bridge.name = "Natural_Ice_Span"
    bridge.scale = (9.0, 3.2, 0.9)
    bridge.data.materials.append(mat_bridge_ice)

    objs = [lip_l, lip_r, bridge]
    return export_asset("rock_winter_chasm_crevasse", "Rocks", objs)

# ==============================================================================
# 37. COSTA BOREAL (REG-037)
# ==============================================================================

def build_boreal_coastal_pier():
    clear_scene()
    mat_frozen_wood = create_material("mat_boreal_driftwood", (0.28, 0.28, 0.32, 1.0), roughness=0.8)
    mat_shelf_ice = create_material("mat_shelf_pack_ice", (0.50, 0.75, 0.90, 1.0), roughness=0.3)
    mat_brazier = create_material(
        "mat_boreal_navigation_fire",
        (0.20, 0.80, 1.0, 1.0),
        roughness=0.2,
        emission=(0.25, 0.85, 1.0, 1.0),
        emission_strength=4.2
    )

    # Estrutura do píer costeiro (extensão 16m)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.5))
    pier = bpy.context.active_object
    pier.name = "Boreal_Pier_Deck"
    pier.scale = (4.5, 16.0, 1.0)
    pier.data.materials.append(mat_frozen_wood)

    # Pilares de sustentação revestidos de gelo marinho
    stilts = []
    for y in [-6.0, -2.0, 2.0, 6.0]:
        for x in [-1.8, 1.8]:
            bpy.ops.mesh.primitive_cylinder_add(radius=0.45, depth=4.0, location=(x, y, 0))
            stilt = bpy.context.active_object
            stilt.name = f"Ice_Stilt_{x}_{y}"
            stilt.data.materials.append(mat_shelf_ice)
            stilts.append(stilt)

    # Braseiro de navegação gélido na ponta do cais
    bpy.ops.mesh.primitive_cylinder_add(radius=0.7, depth=0.8, location=(0, -7.2, 2.4))
    brazier = bpy.context.active_object
    brazier.name = "Navigation_Brazier_Stand"
    brazier.data.materials.append(mat_frozen_wood)

    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.45, location=(0, -7.2, 3.0))
    flame = bpy.context.active_object
    flame.name = "Boreal_Soul_Flame"
    flame.data.materials.append(mat_brazier)

    objs = [pier, brazier, flame] + stilts
    return export_asset("structure_boreal_coastal_pier", "Structures", objs)

# ==============================================================================
# 38. PALÁCIO ADORMECIDO (REG-038) — ARQUITETURA MONUMENTAL
# ==============================================================================

def build_sleeping_palace_monument():
    clear_scene()
    mat_ice_palace_stone = create_material("mat_palace_ice_marble", (0.55, 0.68, 0.80, 1.0), roughness=0.35, metallic=0.1)
    mat_royal_frost = create_material(
        "mat_royal_frost_rune",
        (0.40, 0.85, 1.0, 1.0),
        roughness=0.15,
        emission=(0.45, 0.90, 1.0, 1.0),
        emission_strength=3.5
    )

    # Fundação palaciana monumental
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 3.5))
    foundation = bpy.context.active_object
    foundation.name = "Palace_Grand_Façade"
    foundation.scale = (22.0, 14.0, 7.0)
    foundation.data.materials.append(mat_ice_palace_stone)

    # Grande Portal Ogival de Gelo dos Reis do Norte
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -7.2, 4.0))
    portal = bpy.context.active_object
    portal.name = "Royal_Frost_Gate"
    portal.scale = (7.0, 1.5, 8.0)
    portal.data.materials.append(mat_royal_frost)

    # 4 Torres pontiagudas góticas monumentais (altura 18m)
    towers = []
    coords = [(-9.5, -6.0), (9.5, -6.0), (-9.5, 6.0), (9.5, 6.0)]
    for idx, (tx, ty) in enumerate(coords):
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.8, depth=14.0, location=(tx, ty, 9.0))
        t = bpy.context.active_object
        t.name = f"Palace_Spire_{idx+1}"
        t.data.materials.append(mat_ice_palace_stone)
        towers.append(t)

        bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=2.0, radius2=0.1, depth=5.0, location=(tx, ty, 18.0))
        sp = bpy.context.active_object
        sp.name = f"Palace_Cone_{idx+1}"
        sp.data.materials.append(mat_royal_frost)
        towers.append(sp)

    objs = [foundation, portal] + towers
    return export_asset("structure_sleeping_palace_monument", "Structures", objs)

# ==============================================================================
# 39. CEMITÉRIO DAS ESTRELAS (REG-039) — IDENTIDADE ASTRAL E CRISTALINA
# ==============================================================================

def build_astral_star_geode_shrine():
    clear_scene()
    mat_meteor_crust = create_material("mat_cosmic_meteorite_crust", (0.16, 0.14, 0.20, 1.0), roughness=0.85, metallic=0.3)
    mat_astral_crystal = create_material(
        "mat_astral_star_crystals",
        (0.65, 0.35, 0.95, 1.0),
        roughness=0.1,
        emission=(0.75, 0.45, 1.0, 1.0),
        emission_strength=4.8
    )

    # Casca hemisférica do meteorito caído
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=4.5, location=(0, 0, 2.0))
    meteor = bpy.context.active_object
    meteor.name = "Meteorite_Crater_Husk"
    meteor.scale = (1.2, 1.0, 0.6)
    meteor.data.materials.append(mat_meteor_crust)

    # Aglomerado interno de cristais geodo estelares violetas
    crystals = []
    for i in range(7):
        ca = (2.0 * math.pi / 7.0) * i
        cx = math.cos(ca) * 2.2
        cy = math.sin(ca) * 1.8
        bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.6, depth=4.0, location=(cx, cy, 3.0))
        c = bpy.context.active_object
        c.name = f"Astral_Crystal_{i+1}"
        c.rotation_euler = (math.radians(25 * math.cos(ca)), math.radians(25 * math.sin(ca)), ca)
        c.data.materials.append(mat_astral_crystal)
        crystals.append(c)

    # Núcleo da estrela caída
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=1.2, location=(0, 0, 3.2))
    star_heart = bpy.context.active_object
    star_heart.name = "Fallen_Star_Core"
    star_heart.data.materials.append(mat_astral_crystal)

    objs = [meteor, star_heart] + crystals
    return export_asset("prop_astral_star_geode_shrine", "Props", objs)

# ==============================================================================
# 40. TRONO DA AURORA MORTA (REG-040) — REGIÃO FINAL MARCANTE
# ==============================================================================

def build_dead_aurora_throne():
    clear_scene()
    mat_black_ice_stone = create_material("mat_black_ice_throne_stone", (0.12, 0.14, 0.18, 1.0), roughness=0.3, metallic=0.3)
    mat_dead_aurora = create_material(
        "mat_dead_aurora_glow",
        (0.20, 0.98, 0.85, 1.0),
        roughness=0.1,
        emission=(0.25, 1.0, 0.90, 1.0),
        emission_strength=5.2
    )

    # 3 Terraços de gelo negro escalonados
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=10.0, depth=1.5, location=(0, 0, 0.75))
    t1 = bpy.context.active_object
    t1.name = "Aurora_Terrace_1"
    t1.data.materials.append(mat_black_ice_stone)

    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=7.0, depth=1.2, location=(0, 0, 2.0))
    t2 = bpy.context.active_object
    t2.name = "Aurora_Terrace_2"
    t2.data.materials.append(mat_black_ice_stone)

    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.5, depth=1.0, location=(0, 0, 3.1))
    t3 = bpy.context.active_object
    t3.name = "Aurora_Terrace_3"
    t3.data.materials.append(mat_black_ice_stone)

    # Trono da Aurora esculpido em gelo negro
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 5.0))
    seat = bpy.context.active_object
    seat.name = "Throne_Seat"
    seat.scale = (3.2, 2.4, 2.8)
    seat.data.materials.append(mat_black_ice_stone)

    # Encosto monumental em asas de gelo pontiagudas
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 1.0, 7.8))
    back = bpy.context.active_object
    back.name = "Throne_Spired_Back"
    back.scale = (4.0, 0.8, 6.0)
    back.data.materials.append(mat_black_ice_stone)

    # Grande anel orbital da Aurora Boreal Morta flutuando atrás do trono
    bpy.ops.mesh.primitive_torus_add(major_radius=5.5, minor_radius=0.45, location=(0, 1.5, 8.5))
    aurora_ring = bpy.context.active_object
    aurora_ring.name = "Dead_Aurora_Halo"
    aurora_ring.rotation_euler = (math.radians(90), 0, 0)
    aurora_ring.data.materials.append(mat_dead_aurora)

    objs = [t1, t2, t3, seat, back, aurora_ring]
    return export_asset("structure_dead_aurora_throne", "Structures", objs)

def build_aurora_monolith_sentinel():
    clear_scene()
    mat_monolith = create_material("mat_sentinel_basalt", (0.16, 0.18, 0.22, 1.0), roughness=0.75)
    mat_runes = create_material(
        "mat_aurora_runic_inscriptions",
        (0.25, 0.95, 0.85, 1.0),
        roughness=0.2,
        emission=(0.30, 1.0, 0.90, 1.0),
        emission_strength=3.8
    )

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 4.5))
    pillar = bpy.context.active_object
    pillar.name = "Aurora_Sentinel_Pillar"
    pillar.scale = (1.8, 1.8, 9.0)
    pillar.data.materials.append(mat_monolith)

    # Inscrições e orbe no topo
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.9, location=(0, 0, 9.6))
    orb = bpy.context.active_object
    orb.name = "Sentinel_Runic_Orb"
    orb.data.materials.append(mat_runes)

    objs = [pillar, orb]
    return export_asset("rock_aurora_monolith_sentinel", "Rocks", objs)

# ==============================================================================
# EXECUÇÃO PRINCIPAL
# ==============================================================================

def main():
    print("======================================================================")
    print("ABYSSAL PACT — GERANDO ASSETS 3D DE NHAL'KORA (HEADLESS BLENDER)")
    print(f"Diretório ArtSource (.blend): {ART_SOURCE_DIR}")
    print(f"Diretório Modelos (.glb):     {MODELS_OUT_DIR}")
    print("======================================================================")

    generated = []

    # 31. Geleira dos Ecos
    generated.append(build_glacial_echo_cliff())
    generated.append(build_ice_resonator_crystal())

    # 32. Cidade Submersa de Gelo
    generated.append(build_submerged_ice_citadel())

    # 33. Tundra Branca
    generated.append(build_tundra_bone_cairn_marker())

    # 34. Pináculo do Silêncio
    generated.append(build_needle_peak_ice_spire())

    # 35. Bosque de Cristal
    generated.append(build_crystal_canopy_tree())

    # 36. Fenda do Inverno
    generated.append(build_winter_chasm_crevasse())

    # 37. Costa Boreal
    generated.append(build_boreal_coastal_pier())

    # 38. Palácio Adormecido
    generated.append(build_sleeping_palace_monument())

    # 39. Cemitério das Estrelas
    generated.append(build_astral_star_geode_shrine())

    # 40. Trono da Aurora Morta
    generated.append(build_dead_aurora_throne())
    generated.append(build_aurora_monolith_sentinel())

    print("======================================================================")
    print(f"SUCESSO: {len(generated)} assets 3D de Nhal'Kora gerados e exportados.")
    print("======================================================================")

if __name__ == "__main__":
    main()
