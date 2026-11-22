"""
ABYSSAL PACT — GERADOR DOS MODELOS 3D DO EXÉRCITO DEMONÍACO (BLENDER 5.3+)
Cria os 3 escalões do exército de Azaroth:
1. Demônio Inferior (Soldado / Rastreador Farpado)
2. Demônio Superior (Campeão / Belicista de Obsidiana)
3. Primordial (Colosso Abissal de Quatro Braços)

Gera para cada unidade:
- Arquivo de projeto .blend em: assets/blender/demons/
- Render de preview PNG em: assets/previews/demons/
- Export glTF 2.0 (.glb) em: assets/models/demons/
"""

import bpy
import math
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.append(SCRIPT_DIR)

import abyssal_blender_framework as abf


def build_demon_inferior():
    print("----------------------------------------------------------------------")
    print("CONSTRUINDO DEMÔNIO INFERIOR (SOLDADO / RASTREADOR)")
    print("----------------------------------------------------------------------")
    abf.reset_scene(fps=24)

    mat_carapace = abf.create_pbr_material("Mat_Inferior_Carapace", "#160b0e", roughness=0.4, metallic=0.7)
    mat_flesh = abf.create_pbr_material("Mat_Inferior_Flesh", "#331215", roughness=0.8, metallic=0.1)
    mat_ember = abf.create_pbr_material("Mat_Inferior_Ember", "#ff4400", roughness=0.3, metallic=0.1, emission_hex="#ff4400", emission_strength=4.0)

    parts = []
    # Corpo ágil e agachado (Altura ~1.8m)
    pelvis = abf.add_primitive("cube", "Inf_Pelvis", location=(0, 0, 0.9), scale=(0.5, 0.4, 0.35))
    abf.set_object_material(pelvis, mat_carapace)
    parts.append(pelvis)

    chest = abf.add_primitive("cube", "Inf_Chest", location=(0, -0.15, 1.3), scale=(0.7, 0.55, 0.55))
    abf.set_object_material(chest, mat_carapace)
    parts.append(chest)

    # Espinhos dorsais
    for idx, z in enumerate([1.1, 1.3, 1.5]):
        spk = abf.add_primitive("cone", f"Inf_Spike_{idx}", location=(0, 0.25, z), scale=(0.1, 0.1, 0.35), rotation=(math.radians(45), 0, 0))
        abf.set_object_material(spk, mat_ember)
        parts.append(spk)

    # Cabeça predatória
    head = abf.add_primitive("cube", "Inf_Head", location=(0, -0.45, 1.6), scale=(0.35, 0.5, 0.35))
    abf.set_object_material(head, mat_flesh)
    parts.append(head)

    # Olhos em brasa
    eye_l = abf.add_primitive("ico_sphere", "Inf_Eye_L", location=(-0.14, -0.7, 1.65), scale=(0.06, 0.06, 0.06), subdivisions=2)
    eye_r = abf.add_primitive("ico_sphere", "Inf_Eye_R", location=(0.14, -0.7, 1.65), scale=(0.06, 0.06, 0.06), subdivisions=2)
    abf.set_object_material(eye_l, mat_ember)
    abf.set_object_material(eye_r, mat_ember)
    parts.extend([eye_l, eye_r])

    # Membros Superiores (Garras em foice)
    for side, mult in [("L", -1), ("R", 1)]:
        arm = abf.add_primitive("cylinder", f"Inf_Arm_{side}", location=(mult * 0.5, -0.1, 1.25), scale=(0.18, 0.18, 0.45), vertices=8)
        abf.set_object_material(arm, mat_flesh)
        parts.append(arm)

        blade = abf.add_primitive("cone", f"Inf_Blade_{side}", location=(mult * 0.6, -0.35, 0.85), scale=(0.1, 0.1, 0.7), rotation=(math.radians(50), 0, 0))
        abf.set_object_material(blade, mat_carapace)
        parts.append(blade)

    # Membros Inferiores (Pernas digitígradas)
    for side, mult in [("L", -1), ("R", 1)]:
        thigh = abf.add_primitive("cylinder", f"Inf_Thigh_{side}", location=(mult * 0.3, 0.1, 0.7), scale=(0.2, 0.2, 0.5), vertices=8)
        abf.set_object_material(thigh, mat_flesh)
        parts.append(thigh)

        shin = abf.add_primitive("cylinder", f"Inf_Shin_{side}", location=(mult * 0.35, -0.05, 0.3), scale=(0.16, 0.16, 0.5), vertices=8)
        abf.set_object_material(shin, mat_carapace)
        parts.append(shin)

    inf_mesh = abf.join_mesh_objects(parts, "Demon_Inferior_Mesh")

    # Armature
    arm_obj = abf.create_armature("Demon_Inferior_Armature")
    bdefs = [
        {"name": "Root", "head": (0, 0, 0), "tail": (0, 0, 0.3), "parent": None},
        {"name": "Pelvis", "head": (0, 0, 0.8), "tail": (0, 0, 1.0), "parent": "Root"},
        {"name": "Chest", "head": (0, 0, 1.0), "tail": (0, -0.1, 1.5), "parent": "Pelvis"},
        {"name": "Head", "head": (0, -0.1, 1.5), "tail": (0, -0.4, 1.7), "parent": "Chest"},
        {"name": "Arm_L", "head": (-0.4, -0.1, 1.3), "tail": (-0.6, -0.3, 0.8), "parent": "Chest"},
        {"name": "Arm_R", "head": (0.4, -0.1, 1.3), "tail": (0.6, -0.3, 0.8), "parent": "Chest"},
        {"name": "Leg_L", "head": (-0.3, 0, 0.8), "tail": (-0.35, 0, 0.1), "parent": "Pelvis"},
        {"name": "Leg_R", "head": (0.3, 0, 0.8), "tail": (0.35, 0, 0.1), "parent": "Pelvis"},
    ]
    abf.add_bone_hierarchy(arm_obj, bdefs)
    abf.bind_mesh_to_armature(inf_mesh, arm_obj)

    # Animações
    abf.create_bone_action(arm_obj, "idle", [
        ("Chest", "location", 1, (0, 0, 0)),
        ("Chest", "location", 12, (0, 0, 0.03)),
        ("Chest", "location", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "run", [
        ("Leg_L", "rotation_euler", 1, (math.radians(30), 0, 0)),
        ("Leg_L", "rotation_euler", 12, (math.radians(-30), 0, 0)),
        ("Leg_L", "rotation_euler", 24, (math.radians(30), 0, 0)),
        ("Leg_R", "rotation_euler", 1, (math.radians(-30), 0, 0)),
        ("Leg_R", "rotation_euler", 12, (math.radians(30), 0, 0)),
        ("Leg_R", "rotation_euler", 24, (math.radians(-30), 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "attack", [
        ("Arm_R", "rotation_euler", 1, (0, 0, 0)),
        ("Arm_R", "rotation_euler", 10, (math.radians(-60), math.radians(40), 0)),
        ("Arm_R", "rotation_euler", 16, (math.radians(70), math.radians(-30), 0)),
        ("Arm_R", "rotation_euler", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "death", [
        ("Pelvis", "location", 1, (0, 0, 0)),
        ("Pelvis", "location", 24, (0, 0, -0.7)),
        ("Chest", "rotation_euler", 24, (math.radians(75), 0, 0)),
    ], total_frames=24)

    # Rig de Estúdio, Salvar e Exportar
    abf.setup_studio_rig(target_center=(0, 0, 1.0), distance=3.5, elevation=1.5, key_power=200.0, rim_color="#ff5500")
    blend_path = os.path.join(abf.BLENDER_ASSETS_DIR, "demons", "demon_inferior.blend")
    abf.save_blend_project(blend_path)
    preview_path = os.path.join(abf.PREVIEWS_DIR, "demons", "demon_inferior.png")
    abf.render_preview_image(preview_path)
    glb_path = os.path.join(abf.MODELS_EXPORT_DIR, "demons", "demon_inferior.glb")
    abf.export_glb_model(glb_path, include_animations=True)
    return True


def build_demon_superior():
    print("----------------------------------------------------------------------")
    print("CONSTRUINDO DEMÔNIO SUPERIOR (CAMPEÃO BELICISTA DE OBSIDIANA)")
    print("----------------------------------------------------------------------")
    abf.reset_scene(fps=24)

    mat_plate = abf.create_pbr_material("Mat_Superior_Plate", "#0a0709", roughness=0.25, metallic=0.9)
    mat_flesh = abf.create_pbr_material("Mat_Superior_Flesh", "#2c0909", roughness=0.6, metallic=0.2)
    mat_glow = abf.create_pbr_material("Mat_Superior_Glow", "#ff2200", roughness=0.2, metallic=0.1, emission_hex="#ff2200", emission_strength=5.0)
    mat_horns = abf.create_pbr_material("Mat_Superior_Horn", "#1a120c", roughness=0.4, metallic=0.3)

    parts = []
    # Campeão pesado e blindado (Altura ~3.2m)
    pelvis = abf.add_primitive("cube", "Sup_Pelvis", location=(0, 0, 1.5), scale=(0.9, 0.7, 0.6))
    abf.set_object_material(pelvis, mat_plate)
    parts.append(pelvis)

    chest = abf.add_primitive("cube", "Sup_Chest", location=(0, 0, 2.2), scale=(1.4, 0.9, 0.9))
    abf.set_object_material(chest, mat_plate)
    parts.append(chest)

    # Núcleo peitoral incandescente
    core = abf.add_primitive("cube", "Sup_Core", location=(0, -0.48, 2.2), scale=(0.35, 0.1, 0.35))
    abf.set_object_material(core, mat_glow)
    parts.append(core)

    head = abf.add_primitive("cube", "Sup_Head", location=(0, -0.1, 2.9), scale=(0.6, 0.65, 0.6))
    abf.set_object_material(head, mat_flesh)
    parts.append(head)

    # Chifres pesados em arco
    horn_l = abf.add_primitive("cone", "Sup_Horn_L", location=(-0.4, 0, 3.4), scale=(0.2, 0.2, 0.9), rotation=(math.radians(-20), math.radians(-30), 0))
    horn_r = abf.add_primitive("cone", "Sup_Horn_R", location=(0.4, 0, 3.4), scale=(0.2, 0.2, 0.9), rotation=(math.radians(-20), math.radians(30), 0))
    abf.set_object_material(horn_l, mat_horns)
    abf.set_object_material(horn_r, mat_horns)
    parts.extend([horn_l, horn_r])

    # Braços maciços e manopla armada
    for side, mult in [("L", -1), ("R", 1)]:
        arm = abf.add_primitive("cylinder", f"Sup_Arm_{side}", location=(mult * 1.0, 0, 2.1), scale=(0.35, 0.35, 0.8), vertices=10)
        abf.set_object_material(arm, mat_flesh)
        parts.append(arm)

        gauntlet = abf.add_primitive("cube", f"Sup_Gauntlet_{side}", location=(mult * 1.15, -0.15, 1.2), scale=(0.45, 0.5, 0.7))
        abf.set_object_material(gauntlet, mat_plate)
        parts.append(gauntlet)

    # Pernas pesadas blindadas
    for side, mult in [("L", -1), ("R", 1)]:
        leg = abf.add_primitive("cylinder", f"Sup_Leg_{side}", location=(mult * 0.5, 0, 0.75), scale=(0.35, 0.35, 1.2), vertices=10)
        abf.set_object_material(leg, mat_plate)
        parts.append(leg)

    sup_mesh = abf.join_mesh_objects(parts, "Demon_Superior_Mesh")

    # Armature
    arm_obj = abf.create_armature("Demon_Superior_Armature")
    bdefs = [
        {"name": "Root", "head": (0, 0, 0), "tail": (0, 0, 0.5), "parent": None},
        {"name": "Pelvis", "head": (0, 0, 1.4), "tail": (0, 0, 1.8), "parent": "Root"},
        {"name": "Chest", "head": (0, 0, 1.8), "tail": (0, 0, 2.6), "parent": "Pelvis"},
        {"name": "Head", "head": (0, 0, 2.6), "tail": (0, -0.1, 3.2), "parent": "Chest"},
        {"name": "Arm_L", "head": (-0.7, 0, 2.3), "tail": (-1.1, 0, 1.1), "parent": "Chest"},
        {"name": "Arm_R", "head": (0.7, 0, 2.3), "tail": (1.1, 0, 1.1), "parent": "Chest"},
        {"name": "Leg_L", "head": (-0.5, 0, 1.4), "tail": (-0.5, 0, 0.1), "parent": "Pelvis"},
        {"name": "Leg_R", "head": (0.5, 0, 1.4), "tail": (0.5, 0, 0.1), "parent": "Pelvis"},
    ]
    abf.add_bone_hierarchy(arm_obj, bdefs)
    abf.bind_mesh_to_armature(sup_mesh, arm_obj)

    # Animações
    abf.create_bone_action(arm_obj, "idle", [
        ("Chest", "location", 1, (0, 0, 0)),
        ("Chest", "location", 12, (0, 0, 0.05)),
        ("Chest", "location", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "walk", [
        ("Leg_L", "rotation_euler", 1, (math.radians(20), 0, 0)),
        ("Leg_L", "rotation_euler", 12, (math.radians(-20), 0, 0)),
        ("Leg_L", "rotation_euler", 24, (math.radians(20), 0, 0)),
        ("Leg_R", "rotation_euler", 1, (math.radians(-20), 0, 0)),
        ("Leg_R", "rotation_euler", 12, (math.radians(20), 0, 0)),
        ("Leg_R", "rotation_euler", 24, (math.radians(-20), 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "slam_attack", [
        ("Arm_R", "rotation_euler", 1, (0, 0, 0)),
        ("Arm_R", "rotation_euler", 8, (math.radians(-90), 0, 0)),
        ("Arm_R", "rotation_euler", 14, (math.radians(60), 0, 0)),
        ("Arm_R", "rotation_euler", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "death", [
        ("Pelvis", "location", 1, (0, 0, 0)),
        ("Pelvis", "location", 24, (0, 0, -1.2)),
        ("Chest", "rotation_euler", 24, (math.radians(70), 0, 0)),
    ], total_frames=24)

    # Rig de Estúdio, Salvar e Exportar
    abf.setup_studio_rig(target_center=(0, 0, 1.8), distance=5.5, elevation=2.5, key_power=400.0, rim_color="#ff2200")
    blend_path = os.path.join(abf.BLENDER_ASSETS_DIR, "demons", "demon_superior.blend")
    abf.save_blend_project(blend_path)
    preview_path = os.path.join(abf.PREVIEWS_DIR, "demons", "demon_superior.png")
    abf.render_preview_image(preview_path)
    glb_path = os.path.join(abf.MODELS_EXPORT_DIR, "demons", "demon_superior.glb")
    abf.export_glb_model(glb_path, include_animations=True)
    return True


def build_demon_primordial():
    print("----------------------------------------------------------------------")
    print("CONSTRUINDO DEMÔNIO PRIMORDIAL (COLOSSO ABISSAL DE 4 BRAÇOS)")
    print("----------------------------------------------------------------------")
    abf.reset_scene(fps=24)

    mat_crust = abf.create_pbr_material("Mat_Primordial_Crust", "#100608", roughness=0.5, metallic=0.7)
    mat_magma = abf.create_pbr_material("Mat_Primordial_Magma", "#ff4400", roughness=0.2, metallic=0.1, emission_hex="#ff4400", emission_strength=6.0)
    mat_eyes = abf.create_pbr_material("Mat_Primordial_Eyes", "#ffaa00", roughness=0.1, metallic=0.0, emission_hex="#ffaa00", emission_strength=8.0)

    parts = []
    # Colosso primordial (Altura ~5.5m)
    pelvis = abf.add_primitive("cube", "Pri_Pelvis", location=(0, 0, 2.4), scale=(1.6, 1.2, 0.9))
    abf.set_object_material(pelvis, mat_crust)
    parts.append(pelvis)

    chest = abf.add_primitive("cube", "Pri_Chest", location=(0, 0, 3.5), scale=(2.4, 1.6, 1.5))
    abf.set_object_material(chest, mat_crust)
    parts.append(chest)

    # Fendas de magma no peito
    for idx, (offset_x, offset_z) in enumerate([(-0.6, 3.5), (0.6, 3.5), (0, 3.2)]):
        fissure = abf.add_primitive("cube", f"Pri_Fissure_{idx}", location=(offset_x, -0.82, offset_z), scale=(0.4, 0.1, 0.5))
        abf.set_object_material(fissure, mat_magma)
        parts.append(fissure)

    # Cabeça colossal com múltiplos olhos
    head = abf.add_primitive("cube", "Pri_Head", location=(0, -0.2, 4.6), scale=(1.1, 1.1, 1.0))
    abf.set_object_material(head, mat_crust)
    parts.append(head)

    for e_idx, (ex, ey, ez) in enumerate([(-0.35, -0.75, 4.8), (0.35, -0.75, 4.8), (-0.2, -0.75, 4.5), (0.2, -0.75, 4.5)]):
        eye = abf.add_primitive("ico_sphere", f"Pri_Eye_{e_idx}", location=(ex, ey, ez), scale=(0.12, 0.12, 0.12), subdivisions=2)
        abf.set_object_material(eye, mat_eyes)
        parts.append(eye)

    # Quatro Braços Maciços (Par Superior e Par Inferior)
    for side, mult in [("L", -1), ("R", 1)]:
        # Par Superior (Braços Pesados)
        arm_up = abf.add_primitive("cylinder", f"Pri_ArmUp_{side}", location=(mult * 1.8, 0, 4.0), scale=(0.5, 0.5, 1.1), vertices=10)
        abf.set_object_material(arm_up, mat_crust)
        parts.append(arm_up)

        fist_up = abf.add_primitive("cube", f"Pri_FistUp_{side}", location=(mult * 2.2, -0.3, 2.8), scale=(0.6, 0.7, 0.7))
        abf.set_object_material(fist_up, mat_magma)
        parts.append(fist_up)

        # Par Inferior (Braços Secundários Garrados)
        arm_low = abf.add_primitive("cylinder", f"Pri_ArmLow_{side}", location=(mult * 1.5, 0.1, 3.0), scale=(0.4, 0.4, 0.9), vertices=10)
        abf.set_object_material(arm_low, mat_crust)
        parts.append(arm_low)

        fist_low = abf.add_primitive("cube", f"Pri_FistLow_{side}", location=(mult * 1.8, -0.2, 1.9), scale=(0.45, 0.55, 0.55))
        abf.set_object_material(fist_low, mat_crust)
        parts.append(fist_low)

    # Pernas Colossais de Rocha
    for side, mult in [("L", -1), ("R", 1)]:
        leg = abf.add_primitive("cylinder", f"Pri_Leg_{side}", location=(mult * 0.9, 0, 1.2), scale=(0.6, 0.6, 1.9), vertices=12)
        abf.set_object_material(leg, mat_crust)
        parts.append(leg)

        foot = abf.add_primitive("cube", f"Pri_Foot_{side}", location=(mult * 0.95, -0.2, 0.25), scale=(0.8, 1.1, 0.5))
        abf.set_object_material(foot, mat_crust)
        parts.append(foot)

    pri_mesh = abf.join_mesh_objects(parts, "Demon_Primordial_Mesh")

    # Armature
    arm_obj = abf.create_armature("Demon_Primordial_Armature")
    bdefs = [
        {"name": "Root", "head": (0, 0, 0), "tail": (0, 0, 0.8), "parent": None},
        {"name": "Pelvis", "head": (0, 0, 2.2), "tail": (0, 0, 2.8), "parent": "Root"},
        {"name": "Chest", "head": (0, 0, 2.8), "tail": (0, 0, 4.2), "parent": "Pelvis"},
        {"name": "Head", "head": (0, 0, 4.2), "tail": (0, -0.2, 5.2), "parent": "Chest"},
        {"name": "ArmUp_L", "head": (-1.2, 0, 4.0), "tail": (-2.0, -0.2, 2.6), "parent": "Chest"},
        {"name": "ArmUp_R", "head": (1.2, 0, 4.0), "tail": (2.0, -0.2, 2.6), "parent": "Chest"},
        {"name": "ArmLow_L", "head": (-1.0, 0.1, 3.2), "tail": (-1.7, -0.1, 1.8), "parent": "Chest"},
        {"name": "ArmLow_R", "head": (1.0, 0.1, 3.2), "tail": (1.7, -0.1, 1.8), "parent": "Chest"},
        {"name": "Leg_L", "head": (-0.8, 0, 2.2), "tail": (-0.9, 0, 0.2), "parent": "Pelvis"},
        {"name": "Leg_R", "head": (0.8, 0, 2.2), "tail": (0.9, 0, 0.2), "parent": "Pelvis"},
    ]
    abf.add_bone_hierarchy(arm_obj, bdefs)
    abf.bind_mesh_to_armature(pri_mesh, arm_obj)

    # Animações
    abf.create_bone_action(arm_obj, "idle", [
        ("Chest", "location", 1, (0, 0, 0)),
        ("Chest", "location", 12, (0, 0, 0.07)),
        ("Chest", "location", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "walk", [
        ("Leg_L", "rotation_euler", 1, (math.radians(18), 0, 0)),
        ("Leg_L", "rotation_euler", 12, (math.radians(-18), 0, 0)),
        ("Leg_L", "rotation_euler", 24, (math.radians(18), 0, 0)),
        ("Leg_R", "rotation_euler", 1, (math.radians(-18), 0, 0)),
        ("Leg_R", "rotation_euler", 12, (math.radians(18), 0, 0)),
        ("Leg_R", "rotation_euler", 24, (math.radians(-18), 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "cleave_attack", [
        ("ArmUp_R", "rotation_euler", 1, (0, 0, 0)),
        ("ArmUp_R", "rotation_euler", 8, (math.radians(-80), math.radians(45), 0)),
        ("ArmUp_R", "rotation_euler", 14, (math.radians(60), math.radians(-30), 0)),
        ("ArmUp_R", "rotation_euler", 24, (0, 0, 0)),
        ("ArmLow_L", "rotation_euler", 1, (0, 0, 0)),
        ("ArmLow_L", "rotation_euler", 10, (math.radians(-50), 0, 0)),
        ("ArmLow_L", "rotation_euler", 16, (math.radians(45), 0, 0)),
        ("ArmLow_L", "rotation_euler", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "death", [
        ("Pelvis", "location", 1, (0, 0, 0)),
        ("Pelvis", "location", 24, (0, 0, -1.8)),
        ("Chest", "rotation_euler", 24, (math.radians(70), 0, 0)),
    ], total_frames=24)

    # Rig de Estúdio, Salvar e Exportar
    abf.setup_studio_rig(target_center=(0, 0, 3.0), distance=8.5, elevation=3.5, key_power=800.0, rim_color="#ff7700")
    blend_path = os.path.join(abf.BLENDER_ASSETS_DIR, "demons", "demon_primordial.blend")
    abf.save_blend_project(blend_path)
    preview_path = os.path.join(abf.PREVIEWS_DIR, "demons", "demon_primordial.png")
    abf.render_preview_image(preview_path)
    glb_path = os.path.join(abf.MODELS_EXPORT_DIR, "demons", "demon_primordial.glb")
    abf.export_glb_model(glb_path, include_animations=True)
    return True


if __name__ == "__main__":
    build_demon_inferior()
    build_demon_superior()
    build_demon_primordial()
    print("======================================================================")
    print("EXÉRCITO DEMONÍACO COMPLETO GERADO COM SUCESSO NO BLENDER 5.3!")
    print("======================================================================")
