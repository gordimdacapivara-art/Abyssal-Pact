"""
ABYSSAL PACT — PRODUÇÃO DO LOTE PILOTO DE 5 ARMAS EM BLENDER 5.3
Gera 5 modelos 3D com geometria real, materiais PBR, unwrap, sockets de personagem,
renders de pré-visualização e exportação .blend e .glb.
"""

import bpy
import math
import os
import sys

# Add framework to path
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.append(SCRIPT_DIR)

import abyssal_blender_framework as abf

PROJECT_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))

def add_socket(name, location=(0, 0, 0), rotation=(0, 0, 0)):
    """Cria um Empty para ponto de encaixe de equipamento/personagem."""
    empty = bpy.data.objects.new(name=name, object_data=None)
    empty.empty_display_type = "ARROWS"
    empty.empty_display_size = 0.15
    empty.location = location
    empty.rotation_euler = rotation
    bpy.context.scene.collection.objects.link(empty)
    return empty

def join_meshes_into(main_obj, other_objs):
    """Funde uma lista de objetos na malha principal."""
    bpy.ops.object.select_all(action="DESELECT")
    for o in other_objs:
        o.select_set(True)
    main_obj.select_set(True)
    bpy.context.view_layer.objects.active = main_obj
    bpy.ops.object.join()
    return main_obj

# ==============================================================================
# 1. WEAPON_001: Espada das Cinzas (Swords)
# ==============================================================================
def build_sword_ashes():
    print(">>> Building WEAPON_001_Espada_das_Cinzas...")
    abf.reset_scene(fps=24)

    # Materiais
    m_blade = abf.create_pbr_material("mat_blade_basalt", "#1E1C1A", roughness=0.55, metallic=0.3)
    m_edge = abf.create_pbr_material("mat_blade_edge", "#5A5D64", roughness=0.35, metallic=0.85)
    m_leather = abf.create_pbr_material("mat_grip_leather", "#2A1E18", roughness=0.8, metallic=0.05)
    m_brass = abf.create_pbr_material("mat_crossguard_brass", "#8C6A3D", roughness=0.3, metallic=0.9)
    m_runes = abf.create_pbr_material("mat_runes_ember", "#FF5500", roughness=0.2, metallic=0.1, emission_hex="#FF5500", emission_strength=4.5)

    # 1. Punho (Grip)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.022, depth=0.22, location=(0, 0, 0))
    grip = bpy.context.active_object
    grip.name = "Sword_Grip"
    abf.set_object_material(grip, m_leather)

    # 2. Pomo (Pommel)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.045, location=(0, 0, -0.13))
    pommel = bpy.context.active_object
    pommel.name = "Sword_Pommel"
    pommel.scale = (0.8, 1.2, 1.0)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(pommel, m_brass)

    # 3. Guarda em cruz (Crossguard)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.12))
    guard = bpy.context.active_object
    guard.name = "Sword_Crossguard"
    guard.scale = (0.32, 0.05, 0.035)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(guard, m_brass)

    # 4. Lâmina (Blade)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.62))
    blade = bpy.context.active_object
    blade.name = "Sword_Blade"
    blade.scale = (0.055, 0.018, 0.96)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(blade, m_blade)

    # 5. Ponta da lâmina (Tip)
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.045, depth=0.18, location=(0, 0, 1.18))
    tip = bpy.context.active_object
    tip.name = "Sword_Tip"
    tip.scale = (1.2, 0.4, 1.0)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(tip, m_edge)

    # 6. Friso rúnico emissivo (Fuller Runes)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.58))
    runes = bpy.context.active_object
    runes.name = "Sword_Runes"
    runes.scale = (0.015, 0.022, 0.72)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(runes, m_runes)

    # Sockets de fixação
    add_socket("socket_hand_r", location=(0, 0, 0))
    add_socket("socket_back", location=(0, -0.05, 0.5), rotation=(0, math.radians(180), 0))
    add_socket("socket_hip_l", location=(0.05, 0, 0.1), rotation=(math.radians(25), 0, 0))

    # Luz de exibição e câmera
    abf.setup_studio_rig(target_center=(0, 0, 0.55), distance=1.8, elevation=0.6)

    # Salvar e exportar
    blend_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "swords", "WEAPON_001_Espada_das_Cinzas.blend")
    glb_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "swords", "WEAPON_001_Espada_das_Cinzas.glb")
    preview_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "previews", "WEAPON_001_Espada_das_Cinzas.png")

    abf.save_blend_project(blend_path)
    abf.export_glb_model(glb_path, include_animations=False)
    abf.render_preview_image(preview_path)
    print(">>> Finished WEAPON_001!")

# ==============================================================================
# 2. WEAPON_011: Machado Rúnico de Basalto (Axes)
# ==============================================================================
def build_axe_basalt():
    print(">>> Building WEAPON_011_Machado_Runico_de_Basalto...")
    abf.reset_scene(fps=24)

    # Materiais
    m_shaft = abf.create_pbr_material("mat_axe_shaft", "#2B2D30", roughness=0.5, metallic=0.75)
    m_head = abf.create_pbr_material("mat_axe_basalt", "#181615", roughness=0.7, metallic=0.25)
    m_bronze = abf.create_pbr_material("mat_axe_bronze", "#8C6239", roughness=0.3, metallic=0.9)
    m_magma = abf.create_pbr_material("mat_axe_runes", "#FF4400", roughness=0.2, metallic=0.1, emission_hex="#FF4400", emission_strength=4.8)

    # 1. Haste do Machado (Shaft)
    bpy.ops.mesh.primitive_cylinder_add(vertices=14, radius=0.026, depth=0.95, location=(0, 0, 0.42))
    shaft = bpy.context.active_object
    shaft.name = "Axe_Shaft"
    abf.set_object_material(shaft, m_shaft)

    # 2. Anéis reforçados de bronze
    for z in (0.1, 0.4, 0.75):
        bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.034, depth=0.04, location=(0, 0, z))
        ring = bpy.context.active_object
        abf.set_object_material(ring, m_bronze)

    # 3. Cabeça de lâmina dupla (Double Axe Head)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.78))
    head = bpy.context.active_object
    head.name = "Axe_Head_Core"
    head.scale = (0.48, 0.045, 0.28)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(head, m_head)

    # 4. Gumes chanfrados curvos (Lâmina Direita e Esquerda)
    for x, rot in ((0.28, math.radians(-15)), (-0.28, math.radians(15))):
        bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.18, depth=0.03, location=(x, 0, 0.78), rotation=(0, rot, 0))
        blade_curve = bpy.context.active_object
        blade_curve.scale = (1.0, 0.6, 1.4)
        bpy.ops.object.transform_apply(scale=True)
        abf.set_object_material(blade_curve, m_head)

    # 5. Espigão superior (Top Spike)
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.035, depth=0.16, location=(0, 0, 0.98))
    spike = bpy.context.active_object
    spike.name = "Axe_Top_Spike"
    abf.set_object_material(spike, m_shaft)

    # 6. Runas gravadas emissivas
    for x in (0.15, -0.15):
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, 0, 0.78))
        rune_plate = bpy.context.active_object
        rune_plate.scale = (0.08, 0.052, 0.12)
        bpy.ops.object.transform_apply(scale=True)
        abf.set_object_material(rune_plate, m_magma)

    # Sockets
    add_socket("socket_hand_r", location=(0, 0, 0.35))
    add_socket("socket_back", location=(0, -0.06, 0.65), rotation=(0, math.radians(180), 0))

    abf.setup_studio_rig(target_center=(0, 0, 0.55), distance=1.7, elevation=0.5)

    blend_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "axes", "WEAPON_011_Machado_Runico_de_Basalto.blend")
    glb_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "axes", "WEAPON_011_Machado_Runico_de_Basalto.glb")
    preview_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "previews", "WEAPON_011_Machado_Runico_de_Basalto.png")

    abf.save_blend_project(blend_path)
    abf.export_glb_model(glb_path, include_animations=False)
    abf.render_preview_image(preview_path)
    print(">>> Finished WEAPON_011!")

# ==============================================================================
# 3. WEAPON_021: Martelo Colossal da Forja (Hammers & Maces)
# ==============================================================================
def build_hammer_forge():
    print(">>> Building WEAPON_021_Martelo_Colossal_da_Forja...")
    abf.reset_scene(fps=24)

    m_iron = abf.create_pbr_material("mat_hammer_iron", "#323438", roughness=0.6, metallic=0.8)
    m_dark = abf.create_pbr_material("mat_hammer_dark", "#1C1D20", roughness=0.45, metallic=0.85)
    m_leather = abf.create_pbr_material("mat_hammer_leather", "#3B271A", roughness=0.8, metallic=0.05)
    m_glow = abf.create_pbr_material("mat_hammer_heat", "#FF7700", roughness=0.2, metallic=0.1, emission_hex="#FF7700", emission_strength=4.0)

    # 1. Haste pesada
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.035, depth=1.1, location=(0, 0, 0.45))
    haft = bpy.context.active_object
    haft.name = "Hammer_Haft"
    abf.set_object_material(haft, m_dark)

    # 2. Empunhadura de couro duplo
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.042, depth=0.4, location=(0, 0, 0.25))
    grip = bpy.context.active_object
    abf.set_object_material(grip, m_leather)

    # 3. Cabeça de Bigorna Maciça
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.95))
    head = bpy.context.active_object
    head.name = "Hammer_Head_Block"
    head.scale = (0.28, 0.42, 0.24)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(head, m_iron)

    # 4. Face de impacto frontal reforçada
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.22, 0.95))
    front_plate = bpy.context.active_object
    front_plate.scale = (0.24, 0.04, 0.20)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(front_plate, m_dark)

    # 5. Espigão piramidal traseiro (Back Spike)
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.12, depth=0.22, location=(0, -0.26, 0.95), rotation=(math.radians(-90), 0, 0))
    rear_spike = bpy.context.active_object
    abf.set_object_material(rear_spike, m_iron)

    # 6. Fissuras incandescentes na cabeça
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.95))
    fissure = bpy.context.active_object
    fissure.scale = (0.29, 0.36, 0.035)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(fissure, m_glow)

    add_socket("socket_hand_r", location=(0, 0, 0.3))
    add_socket("socket_back", location=(0, -0.15, 0.7), rotation=(0, math.radians(180), 0))

    abf.setup_studio_rig(target_center=(0, 0, 0.65), distance=1.9, elevation=0.6)

    blend_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "hammers_maces", "WEAPON_021_Martelo_Colossal_da_Forja.blend")
    glb_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "hammers_maces", "WEAPON_021_Martelo_Colossal_da_Forja.glb")
    preview_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "previews", "WEAPON_021_Martelo_Colossal_da_Forja.png")

    abf.save_blend_project(blend_path)
    abf.export_glb_model(glb_path, include_animations=False)
    abf.render_preview_image(preview_path)
    print(">>> Finished WEAPON_021!")

# ==============================================================================
# 4. WEAPON_031: Lança das Cinzas Abissais (Polearms)
# ==============================================================================
def build_spear_ashes():
    print(">>> Building WEAPON_031_Lanca_das_Cinzas_Abissais...")
    abf.reset_scene(fps=24)

    m_obsidian = abf.create_pbr_material("mat_spear_obsidian", "#0F1215", roughness=0.25, metallic=0.2)
    m_wood = abf.create_pbr_material("mat_spear_wood", "#3E352F", roughness=0.75, metallic=0.08)
    m_silver = abf.create_pbr_material("mat_spear_silver", "#7A828A", roughness=0.35, metallic=0.85)
    m_glow = abf.create_pbr_material("mat_spear_ember", "#FF6622", roughness=0.2, metallic=0.1, emission_hex="#FF6622", emission_strength=4.2)

    # 1. Haste longa esguia
    bpy.ops.mesh.primitive_cylinder_add(vertices=14, radius=0.022, depth=1.9, location=(0, 0, 0.95))
    shaft = bpy.context.active_object
    shaft.name = "Spear_Shaft"
    abf.set_object_material(shaft, m_wood)

    # 2. Ponteira de apoio e contrapeso na base
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.03, depth=0.12, location=(0, 0, 0.04), rotation=(math.radians(180), 0, 0))
    butt_cap = bpy.context.active_object
    abf.set_object_material(butt_cap, m_silver)

    # 3. Colar de encaixe com rebites
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.032, depth=0.14, location=(0, 0, 1.88))
    collar = bpy.context.active_object
    abf.set_object_material(collar, m_silver)

    # 4. Lâmina Foliar de Obsidiana
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 2.22))
    blade = bpy.context.active_object
    blade.name = "Spear_Blade"
    blade.scale = (0.075, 0.016, 0.54)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(blade, m_obsidian)

    # 5. Ponta perfurante afiada
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.065, depth=0.22, location=(0, 0, 2.58))
    tip = bpy.context.active_object
    tip.scale = (1.1, 0.3, 1.0)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(tip, m_obsidian)

    # 6. Ganchos laterais de desarmamento
    for x, rot in ((0.08, math.radians(35)), (-0.08, math.radians(-35))):
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.025, depth=0.15, location=(x, 0, 1.98), rotation=(0, rot, 0))
        wing = bpy.context.active_object
        abf.set_object_material(wing, m_silver)

    # 7. Núcleo de cinza fosforescente
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 2.22))
    core = bpy.context.active_object
    core.scale = (0.02, 0.022, 0.38)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(core, m_glow)

    add_socket("socket_hand_r", location=(0, 0, 0.9))
    add_socket("socket_back", location=(0, -0.06, 1.1), rotation=(0, math.radians(180), 0))

    abf.setup_studio_rig(target_center=(0, 0, 1.3), distance=2.6, elevation=0.7)

    blend_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "polearms", "WEAPON_031_Lanca_das_Cinzas_Abissais.blend")
    glb_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "polearms", "WEAPON_031_Lanca_das_Cinzas_Abissais.glb")
    preview_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "previews", "WEAPON_031_Lanca_das_Cinzas_Abissais.png")

    abf.save_blend_project(blend_path)
    abf.export_glb_model(glb_path, include_animations=False)
    abf.render_preview_image(preview_path)
    print(">>> Finished WEAPON_031!")

# ==============================================================================
# 5. WEAPON_091: Escudo Torre de Ferro Negro (Shields)
# ==============================================================================
def build_shield_tower():
    print(">>> Building WEAPON_091_Escudo_Torre_de_Ferro_Negro...")
    abf.reset_scene(fps=24)

    m_plate = abf.create_pbr_material("mat_shield_iron", "#222428", roughness=0.55, metallic=0.82)
    m_bronze = abf.create_pbr_material("mat_shield_bronze", "#946E3A", roughness=0.35, metallic=0.9)
    m_leather = abf.create_pbr_material("mat_shield_back", "#30221B", roughness=0.8, metallic=0.05)
    m_glow = abf.create_pbr_material("mat_shield_glow", "#FF3300", roughness=0.2, metallic=0.1, emission_hex="#FF3300", emission_strength=3.8)

    # 1. Corpo curvo do Escudo Torre (Placa Frontal)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0))
    plate = bpy.context.active_object
    plate.name = "Shield_Plate"
    plate.scale = (0.58, 0.05, 1.25)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(plate, m_plate)

    # 2. Moldura e Bordas de Bronze
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.015, 0))
    frame = bpy.context.active_object
    frame.name = "Shield_Rim"
    frame.scale = (0.62, 0.06, 1.29)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(frame, m_bronze)

    # 3. Umbo Cônico Central de Impacto
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.14, depth=0.12, location=(0, 0.08, 0), rotation=(math.radians(90), 0, 0))
    umbo = bpy.context.active_object
    umbo.name = "Shield_Umbo"
    abf.set_object_material(umbo, m_bronze)

    # 4. Núcleo rúnico no topo do umbo
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.045, location=(0, 0.15, 0))
    crest = bpy.context.active_object
    crest.name = "Shield_Rune_Crest"
    abf.set_object_material(crest, m_glow)

    # 5. Painel traseiro e braçadeira de couro
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.04, 0))
    back_pad = bpy.context.active_object
    back_pad.scale = (0.46, 0.02, 0.8)
    bpy.ops.object.transform_apply(scale=True)
    abf.set_object_material(back_pad, m_leather)

    # 6. Alça e correia de pegada (Grip & Strap)
    for z in (0.1, -0.15):
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.018, depth=0.28, location=(0, -0.08, z), rotation=(0, math.radians(90), 0))
        strap = bpy.context.active_object
        abf.set_object_material(strap, m_leather)

    add_socket("socket_hand_l", location=(0, -0.08, 0))
    add_socket("socket_back", location=(0, 0.05, 0), rotation=(0, 0, math.radians(180)))

    abf.setup_studio_rig(target_center=(0, 0, 0), distance=2.2, elevation=0.4)

    blend_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "shields", "WEAPON_091_Escudo_Torre_de_Ferro_Negro.blend")
    glb_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "shields", "WEAPON_091_Escudo_Torre_de_Ferro_Negro.glb")
    preview_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "previews", "WEAPON_091_Escudo_Torre_de_Ferro_Negro.png")

    abf.save_blend_project(blend_path)
    abf.export_glb_model(glb_path, include_animations=False)
    abf.render_preview_image(preview_path)
    print(">>> Finished WEAPON_091!")

if __name__ == "__main__":
    print("=== STARTING PILOT WEAPONS PRODUCTION ===")
    build_sword_ashes()
    build_axe_basalt()
    build_hammer_forge()
    build_spear_ashes()
    build_shield_tower()
    print("=== ALL 5 PILOT WEAPONS CREATED SUCCESSFULLY! ===")
