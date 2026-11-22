"""
ABYSSAL PACT — Pipeline de Modelagem de Ambientes 3D (Blender 5.3+ Headless)

Constrói proceduralmente os assets 3D de referência para a região Cinzália (Veyrath):
- Rochas e crateras vulcânicas (Rocks)
- Vegetação escassa / árvores calcinadas (Nature)
- Ruínas e estruturas imperiais abandonadas (Structures / Buildings)
- Objetos ambientais, monólitos e braseiros (Props)

REGRA ABSOLUTA DO PIPELINE:
- Os arquivos .blend são salvos na pasta externa: AbyssalPact_ArtSource/Blender/...
- Os arquivos .glb são exportados diretamente para: assets/models/environment/...
"""

import bpy
import math
import os
import sys

# Paths
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
            # Blender 4+ / 5+ emission input
            if "Emission Color" in bsdf.inputs:
                bsdf.inputs["Emission Color"].default_value = emission
            elif "Emission" in bsdf.inputs:
                bsdf.inputs["Emission"].default_value = emission
            if "Emission Strength" in bsdf.inputs:
                bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat

def export_asset(name, category, obj_list):
    # Ensure directories
    blend_dir = os.path.join(ART_SOURCE_DIR, category)
    glb_dir = os.path.join(MODELS_OUT_DIR, category.lower())
    os.makedirs(blend_dir, exist_ok=True)
    os.makedirs(glb_dir, exist_ok=True)

    blend_path = os.path.join(blend_dir, f"{name}.blend")
    glb_path = os.path.join(glb_dir, f"{name}.glb")

    # Select all objects to export
    bpy.ops.object.select_all(action="DESELECT")
    for obj in obj_list:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = obj_list[0]

    # Save .blend in external ArtSource
    bpy.ops.wm.save_as_mainfile(filepath=blend_path)

    # Export .glb to Godot assets
    # In Blender 5.x: bpy.ops.export_scene.gltf
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
# 1. ROCKS & CRATERS (ROCKS)
# ==============================================================================

def build_rock_volcanic_boulder():
    clear_scene()
    mat_basalt = create_material("mat_basalt_dark", (0.12, 0.10, 0.11, 1.0), roughness=0.85, metallic=0.1)

    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.2, location=(0, 0, 1.0))
    boulder = bpy.context.active_object
    boulder.name = "rock_volcanic_boulder"
    boulder.scale = (1.4, 1.1, 0.85)
    bpy.ops.object.transform_apply(scale=True)

    # Displace slightly
    mod = boulder.modifiers.new(name="Bevel", type='BEVEL')
    mod.width = 0.12
    mod.segments = 1
    bpy.ops.object.modifier_apply(modifier="Bevel")

    boulder.data.materials.append(mat_basalt)
    return export_asset("rock_volcanic_boulder", "Rocks", [boulder])

def build_rock_volcanic_crag():
    clear_scene()
    mat_obsidian = create_material("mat_obsidian_crag", (0.08, 0.08, 0.09, 1.0), roughness=0.45, metallic=0.3)

    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=1.1, radius2=0.15, depth=4.2, location=(0, 0, 2.1))
    crag = bpy.context.active_object
    crag.name = "rock_volcanic_crag"
    crag.scale = (1.0, 0.7, 1.0)
    bpy.ops.object.transform_apply(scale=True)

    mod = crag.modifiers.new(name="Bevel", type='BEVEL')
    mod.width = 0.15
    bpy.ops.object.modifier_apply(modifier="Bevel")

    crag.data.materials.append(mat_obsidian)
    return export_asset("rock_volcanic_crag", "Rocks", [crag])

def build_rock_crater_rim():
    clear_scene()
    mat_scorched = create_material("mat_scorched_rock", (0.15, 0.12, 0.12, 1.0), roughness=0.9, metallic=0.05)

    # Arc-shaped curved rim
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=3.2, depth=1.6, location=(0, 0, 0.8))
    rim = bpy.context.active_object
    rim.name = "rock_crater_rim"
    rim.scale = (1.0, 0.5, 0.8)
    bpy.ops.object.transform_apply(scale=True)

    rim.data.materials.append(mat_scorched)
    return export_asset("rock_crater_rim", "Rocks", [rim])

# ==============================================================================
# 2. NATURE & CHARRED VEGETATION (NATURE)
# ==============================================================================

def build_tree_charred_ash():
    clear_scene()
    mat_charred = create_material("mat_charred_wood", (0.07, 0.06, 0.06, 1.0), roughness=0.95, metallic=0.0)

    # Trunk
    bpy.ops.mesh.primitive_cylinder_add(vertices=7, radius=0.45, depth=4.6, location=(0, 0, 2.3))
    trunk = bpy.context.active_object
    trunk.name = "tree_charred_ash"

    # Branch 1
    bpy.ops.mesh.primitive_cylinder_add(vertices=5, radius=0.22, depth=2.4, location=(0.7, 0, 3.4), rotation=(0, 0.75, 0.3))
    b1 = bpy.context.active_object

    # Branch 2
    bpy.ops.mesh.primitive_cylinder_add(vertices=5, radius=0.18, depth=2.0, location=(-0.6, 0.3, 3.8), rotation=(0, -0.65, -0.5))
    b2 = bpy.context.active_object

    # Join
    bpy.ops.object.select_all(action="DESELECT")
    trunk.select_set(True)
    b1.select_set(True)
    b2.select_set(True)
    bpy.context.view_layer.objects.active = trunk
    bpy.ops.object.join()

    trunk.data.materials.append(mat_charred)
    return export_asset("tree_charred_ash", "Nature", [trunk])

def build_shrub_ashen_thorn():
    clear_scene()
    mat_thorn = create_material("mat_ashen_thorn", (0.10, 0.09, 0.08, 1.0), roughness=0.9, metallic=0.0)

    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.6, location=(0, 0, 0.45))
    shrub = bpy.context.active_object
    shrub.name = "shrub_ashen_thorn"
    shrub.scale = (1.2, 1.0, 0.7)
    bpy.ops.object.transform_apply(scale=True)

    shrub.data.materials.append(mat_thorn)
    return export_asset("shrub_ashen_thorn", "Nature", [shrub])

# ==============================================================================
# 3. STRUCTURES & IMPERIAL RUINS (STRUCTURES)
# ==============================================================================

def build_ruin_imperial_arch():
    clear_scene()
    mat_stone = create_material("mat_imperial_stone", (0.22, 0.18, 0.17, 1.0), roughness=0.75, metallic=0.15)
    mat_iron = create_material("mat_rusty_iron", (0.16, 0.11, 0.10, 1.0), roughness=0.6, metallic=0.7)

    # Left Pillar
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-2.0, 0, 2.5))
    left = bpy.context.active_object
    left.scale = (0.9, 0.9, 5.0)

    # Right Pillar
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(2.0, 0, 2.5))
    right = bpy.context.active_object
    right.scale = (0.9, 0.9, 5.0)

    # Top Lintel Arch
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 5.2))
    lintel = bpy.context.active_object
    lintel.scale = (5.2, 1.1, 0.8)

    # Join
    bpy.ops.object.select_all(action="DESELECT")
    left.select_set(True)
    right.select_set(True)
    lintel.select_set(True)
    bpy.context.view_layer.objects.active = lintel
    bpy.ops.object.join()
    arch = bpy.context.active_object
    arch.name = "ruin_imperial_arch"
    bpy.ops.object.transform_apply(scale=True)

    arch.data.materials.append(mat_stone)
    return export_asset("ruin_imperial_arch", "Structures", [arch])

def build_ruin_broken_pillar():
    clear_scene()
    mat_stone = create_material("mat_imperial_stone", (0.22, 0.18, 0.17, 1.0), roughness=0.75, metallic=0.15)

    # Column base + fluted cylinder
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.6, depth=3.2, location=(0, 0, 1.6))
    col = bpy.context.active_object
    col.name = "ruin_broken_pillar"

    # Base plinth
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.25))
    base = bpy.context.active_object
    base.scale = (1.5, 1.5, 0.5)

    bpy.ops.object.select_all(action="DESELECT")
    col.select_set(True)
    base.select_set(True)
    bpy.context.view_layer.objects.active = col
    bpy.ops.object.join()
    pillar = bpy.context.active_object
    bpy.ops.object.transform_apply(scale=True)

    pillar.data.materials.append(mat_stone)
    return export_asset("ruin_broken_pillar", "Structures", [pillar])

def build_structure_bastion_wall():
    clear_scene()
    mat_stone = create_material("mat_imperial_stone", (0.22, 0.18, 0.17, 1.0), roughness=0.75, metallic=0.15)

    # Main Wall
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.8))
    wall = bpy.context.active_object
    wall.name = "structure_bastion_wall"
    wall.scale = (6.0, 1.2, 3.6)

    # Crenellations
    for ox in [-2.2, 0, 2.2]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(ox, 0, 3.9))
        cren = bpy.context.active_object
        cren.scale = (1.0, 1.3, 0.7)

    bpy.ops.object.select_all(action="SELECT")
    bpy.context.view_layer.objects.active = wall
    bpy.ops.object.join()
    b_wall = bpy.context.active_object
    bpy.ops.object.transform_apply(scale=True)

    b_wall.data.materials.append(mat_stone)
    return export_asset("structure_bastion_wall", "Structures", [b_wall])

def build_structure_watchtower_ruin():
    clear_scene()
    mat_stone = create_material("mat_imperial_stone", (0.22, 0.18, 0.17, 1.0), roughness=0.75, metallic=0.15)

    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=2.2, depth=5.5, location=(0, 0, 2.75))
    tower = bpy.context.active_object
    tower.name = "structure_watchtower_ruin"

    tower.data.materials.append(mat_stone)
    return export_asset("structure_watchtower_ruin", "Structures", [tower])

# ==============================================================================
# 4. PROPS & MONOLITHS (PROPS)
# ==============================================================================

def build_prop_ash_monolith():
    clear_scene()
    mat_obsidian = create_material("mat_obsidian_pact", (0.10, 0.09, 0.11, 1.0), roughness=0.35, metallic=0.2)
    mat_rune = create_material("mat_rune_glow", (0.9, 0.4, 0.1, 1.0), roughness=0.2, emission=(1.0, 0.45, 0.1, 1.0), emission_strength=4.0)

    # Monolith obelisk
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.7, radius2=0.45, depth=3.6, location=(0, 0, 1.8), rotation=(0, 0, math.radians(45)))
    obelisk = bpy.context.active_object
    obelisk.name = "prop_ash_monolith"

    # Inlaid rune band
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 2.0), rotation=(0, 0, math.radians(45)))
    rune_band = bpy.context.active_object
    rune_band.scale = (0.75, 0.75, 0.15)
    rune_band.data.materials.append(mat_rune)

    bpy.ops.object.select_all(action="DESELECT")
    obelisk.select_set(True)
    rune_band.select_set(True)
    bpy.context.view_layer.objects.active = obelisk
    bpy.ops.object.join()
    monolith = bpy.context.active_object
    bpy.ops.object.transform_apply(scale=True)

    monolith.data.materials.append(mat_obsidian)
    return export_asset("prop_ash_monolith", "Props", [monolith])

def build_prop_volcanic_brazier():
    clear_scene()
    mat_iron = create_material("mat_brazier_iron", (0.15, 0.14, 0.14, 1.0), roughness=0.6, metallic=0.8)
    mat_ember = create_material("mat_ember_fire", (1.0, 0.3, 0.05, 1.0), roughness=0.3, emission=(1.0, 0.35, 0.05, 1.0), emission_strength=5.0)

    # Pedestal
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.4, depth=1.0, location=(0, 0, 0.5))
    ped = bpy.context.active_object
    ped.name = "prop_volcanic_brazier"

    # Bowl
    bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=0.8, radius2=0.4, depth=0.5, location=(0, 0, 1.25))
    bowl = bpy.context.active_object

    # Embers
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.6, location=(0, 0, 1.35))
    embers = bpy.context.active_object
    embers.data.materials.append(mat_ember)

    bpy.ops.object.select_all(action="DESELECT")
    ped.select_set(True)
    bowl.select_set(True)
    embers.select_set(True)
    bpy.context.view_layer.objects.active = ped
    bpy.ops.object.join()
    brazier = bpy.context.active_object
    bpy.ops.object.transform_apply(scale=True)

    brazier.data.materials.append(mat_iron)
    return export_asset("prop_volcanic_brazier", "Props", [brazier])

# ==============================================================================
# MAIN BATCH EXECUTION
# ==============================================================================

def main():
    print("=== EXECUTANDO PIPELINE BLENDER 3D HEADLESS ===")
    print("ArtSource Externa (.blend):", ART_SOURCE_DIR)
    print("Godot Assets (.glb):", MODELS_OUT_DIR)

    exported = []
    exported.append(build_rock_volcanic_boulder())
    exported.append(build_rock_volcanic_crag())
    exported.append(build_rock_crater_rim())
    exported.append(build_tree_charred_ash())
    exported.append(build_shrub_ashen_thorn())
    exported.append(build_ruin_imperial_arch())
    exported.append(build_ruin_broken_pillar())
    exported.append(build_structure_bastion_wall())
    exported.append(build_structure_watchtower_ruin())
    exported.append(build_prop_ash_monolith())
    exported.append(build_prop_volcanic_brazier())

    print(f"\n[SUCESSO] Total de {len(exported)} modelos 3D produzidos e exportados!")
    for p in exported:
        print(f"  - {os.path.basename(p)} ({os.path.getsize(p):,} B)")

if __name__ == "__main__":
    main()
