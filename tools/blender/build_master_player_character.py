"""
ABYSSAL PACT — MODELO 3D MESTRE DO PERSONAGEM JOGADOR (BLENDER 5.3+)
Cria o modelo 3D do personagem jogável em padrão de alta fidelidade:
- Anatomia humanoide proporcional (~1.8m de altura)
- Armadura segmentada (peitoral, ombreiras, manoplas, grevas)
- Rigging humanoide com esqueleto padrão
- Suíte completa de 9 animações do contrato PlayerAnimator (idle, walk, run, sprint, jump, fall, land, dodge, attack)
- Preview render PNG
- Arquivo .blend nativo em: assets/blender/characters/
- Export glTF 2.0 (.glb) em: assets/models/characters/ e assets/models/characters/reference/
"""

import bpy
import math
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.append(SCRIPT_DIR)

import abyssal_blender_framework as abf


def build_player_character():
    print("======================================================================")
    print("CONSTRUINDO MODELO MESTRE DO PERSONAGEM JOGADOR (BLENDER 5.3)")
    print("======================================================================")
    abf.reset_scene(fps=24)

    # Materiais PBR
    mat_plate = abf.create_pbr_material("Mat_Player_IronPlate", "#282a2e", roughness=0.35, metallic=0.85)
    mat_leather = abf.create_pbr_material("Mat_Player_Leather", "#3a2518", roughness=0.75, metallic=0.1)
    mat_cloth = abf.create_pbr_material("Mat_Player_AbyssalCloth", "#6e1c24", roughness=0.6, metallic=0.15)
    mat_trim = abf.create_pbr_material("Mat_Player_SilverTrim", "#a5abb0", roughness=0.2, metallic=0.95)

    parts = []
    # 1. Pelve e Cinturão
    pelvis = abf.add_primitive("cube", "Player_Pelvis", location=(0, 0, 0.95), scale=(0.36, 0.24, 0.2))
    abf.set_object_material(pelvis, mat_leather)
    parts.append(pelvis)

    belt = abf.add_primitive("cube", "Player_Belt", location=(0, -0.01, 1.05), scale=(0.38, 0.26, 0.08))
    abf.set_object_material(belt, mat_trim)
    parts.append(belt)

    # 2. Abdômen e Peitoral com Armadura Segmentada
    torso = abf.add_primitive("cylinder", "Player_Torso", location=(0, 0, 1.15), scale=(0.32, 0.22, 0.3), vertices=12)
    abf.set_object_material(torso, mat_cloth)
    parts.append(torso)

    chestplate = abf.add_primitive("cube", "Player_Chestplate", location=(0, -0.03, 1.35), scale=(0.42, 0.28, 0.35))
    abf.set_object_material(chestplate, mat_plate)
    parts.append(chestplate)

    # 3. Cabeça e Elmo Imperial
    neck = abf.add_primitive("cylinder", "Player_Neck", location=(0, 0, 1.55), scale=(0.14, 0.14, 0.15), vertices=10)
    abf.set_object_material(neck, mat_leather)
    parts.append(neck)

    helmet = abf.add_primitive("ico_sphere", "Player_Helmet", location=(0, 0, 1.72), scale=(0.22, 0.25, 0.24), subdivisions=3)
    abf.set_object_material(helmet, mat_plate)
    parts.append(helmet)

    visor = abf.add_primitive("cube", "Player_Visor", location=(0, -0.18, 1.72), scale=(0.18, 0.08, 0.06))
    abf.set_object_material(visor, mat_trim)
    parts.append(visor)

    # 4. Braços e Ombreiras
    for side, mult in [("L", -1), ("R", 1)]:
        pauldron = abf.add_primitive("ico_sphere", f"Player_Pauldron_{side}", location=(mult * 0.32, 0, 1.48), scale=(0.16, 0.18, 0.15), subdivisions=2)
        abf.set_object_material(pauldron, mat_plate)
        parts.append(pauldron)

        arm = abf.add_primitive("cylinder", f"Player_UpperArm_{side}", location=(mult * 0.32, 0, 1.25), scale=(0.11, 0.11, 0.3), vertices=10)
        abf.set_object_material(arm, mat_cloth)
        parts.append(arm)

        bracer = abf.add_primitive("cylinder", f"Player_Bracer_{side}", location=(mult * 0.35, -0.02, 0.95), scale=(0.12, 0.12, 0.3), vertices=10)
        abf.set_object_material(bracer, mat_plate)
        parts.append(bracer)

        glove = abf.add_primitive("cube", f"Player_Glove_{side}", location=(mult * 0.36, -0.03, 0.75), scale=(0.1, 0.12, 0.14))
        abf.set_object_material(glove, mat_leather)
        parts.append(glove)

    # 5. Pernas e Botas
    for side, mult in [("L", -1), ("R", 1)]:
        thigh = abf.add_primitive("cylinder", f"Player_Thigh_{side}", location=(mult * 0.16, 0, 0.72), scale=(0.14, 0.14, 0.4), vertices=10)
        abf.set_object_material(thigh, mat_cloth)
        parts.append(thigh)

        greave = abf.add_primitive("cylinder", f"Player_Greave_{side}", location=(mult * 0.16, 0.02, 0.38), scale=(0.13, 0.13, 0.4), vertices=10)
        abf.set_object_material(greave, mat_plate)
        parts.append(greave)

        boot = abf.add_primitive("cube", f"Player_Boot_{side}", location=(mult * 0.16, -0.06, 0.09), scale=(0.13, 0.24, 0.14))
        abf.set_object_material(boot, mat_leather)
        parts.append(boot)

    char_mesh = abf.join_mesh_objects(parts, "Player_Character_Mesh")

    # Armature Humanoide Completa
    arm_obj = abf.create_armature("Player_Character_Armature")
    bdefs = [
        {"name": "Root", "head": (0, 0, 0), "tail": (0, 0, 0.2), "parent": None},
        {"name": "Hips", "head": (0, 0, 0.9), "tail": (0, 0, 1.1), "parent": "Root"},
        {"name": "Spine", "head": (0, 0, 1.1), "tail": (0, 0, 1.3), "parent": "Hips"},
        {"name": "Chest", "head": (0, 0, 1.3), "tail": (0, 0, 1.55), "parent": "Spine"},
        {"name": "Neck", "head": (0, 0, 1.55), "tail": (0, 0, 1.65), "parent": "Chest"},
        {"name": "Head", "head": (0, 0, 1.65), "tail": (0, 0, 1.85), "parent": "Neck"},
        {"name": "LeftShoulder", "head": (-0.1, 0, 1.48), "tail": (-0.3, 0, 1.48), "parent": "Chest"},
        {"name": "LeftArm", "head": (-0.3, 0, 1.48), "tail": (-0.35, 0, 1.1), "parent": "LeftShoulder"},
        {"name": "LeftForeArm", "head": (-0.35, 0, 1.1), "tail": (-0.36, 0, 0.75), "parent": "LeftArm"},
        {"name": "RightShoulder", "head": (0.1, 0, 1.48), "tail": (0.3, 0, 1.48), "parent": "Chest"},
        {"name": "RightArm", "head": (0.3, 0, 1.48), "tail": (0.35, 0, 1.1), "parent": "RightShoulder"},
        {"name": "RightForeArm", "head": (0.35, 0, 1.1), "tail": (0.36, 0, 0.75), "parent": "RightArm"},
        {"name": "LeftUpLeg", "head": (-0.16, 0, 0.9), "tail": (-0.16, 0, 0.55), "parent": "Hips"},
        {"name": "LeftLeg", "head": (-0.16, 0, 0.55), "tail": (-0.16, 0, 0.1), "parent": "LeftUpLeg"},
        {"name": "RightUpLeg", "head": (0.16, 0, 0.9), "tail": (0.16, 0, 0.55), "parent": "Hips"},
        {"name": "RightLeg", "head": (0.16, 0, 0.55), "tail": (0.16, 0, 0.1), "parent": "RightUpLeg"},
    ]
    abf.add_bone_hierarchy(arm_obj, bdefs)
    abf.bind_mesh_to_armature(char_mesh, arm_obj)

    # Contrato de 9 Animações Canônicas
    # 1. idle
    abf.create_bone_action(arm_obj, "idle", [
        ("Chest", "location", 1, (0, 0, 0)),
        ("Chest", "location", 12, (0, 0, 0.015)),
        ("Chest", "location", 24, (0, 0, 0)),
    ], total_frames=24)

    # 2. walk
    abf.create_bone_action(arm_obj, "walk", [
        ("LeftUpLeg", "rotation_euler", 1, (math.radians(25), 0, 0)),
        ("LeftUpLeg", "rotation_euler", 12, (math.radians(-25), 0, 0)),
        ("LeftUpLeg", "rotation_euler", 24, (math.radians(25), 0, 0)),
        ("RightUpLeg", "rotation_euler", 1, (math.radians(-25), 0, 0)),
        ("RightUpLeg", "rotation_euler", 12, (math.radians(25), 0, 0)),
        ("RightUpLeg", "rotation_euler", 24, (math.radians(-25), 0, 0)),
    ], total_frames=24)

    # 3. run
    abf.create_bone_action(arm_obj, "run", [
        ("LeftUpLeg", "rotation_euler", 1, (math.radians(45), 0, 0)),
        ("LeftUpLeg", "rotation_euler", 12, (math.radians(-45), 0, 0)),
        ("LeftUpLeg", "rotation_euler", 24, (math.radians(45), 0, 0)),
        ("RightUpLeg", "rotation_euler", 1, (math.radians(-45), 0, 0)),
        ("RightUpLeg", "rotation_euler", 12, (math.radians(45), 0, 0)),
        ("RightUpLeg", "rotation_euler", 24, (math.radians(-45), 0, 0)),
    ], total_frames=24)

    # 4. sprint
    abf.create_bone_action(arm_obj, "sprint", [
        ("Chest", "rotation_euler", 1, (math.radians(15), 0, 0)),
        ("LeftUpLeg", "rotation_euler", 1, (math.radians(55), 0, 0)),
        ("LeftUpLeg", "rotation_euler", 12, (math.radians(-55), 0, 0)),
        ("LeftUpLeg", "rotation_euler", 24, (math.radians(55), 0, 0)),
    ], total_frames=24)

    # 5. jump
    abf.create_bone_action(arm_obj, "jump", [
        ("Hips", "location", 1, (0, 0, 0)),
        ("Hips", "location", 12, (0, 0, 0.4)),
        ("Hips", "location", 24, (0, 0, 0)),
    ], total_frames=24)

    # 6. fall
    abf.create_bone_action(arm_obj, "fall", [
        ("LeftArm", "rotation_euler", 1, (math.radians(-30), 0, 0)),
        ("RightArm", "rotation_euler", 1, (math.radians(-30), 0, 0)),
    ], total_frames=24)

    # 7. land
    abf.create_bone_action(arm_obj, "land", [
        ("Hips", "location", 1, (0, 0, -0.15)),
        ("Hips", "location", 24, (0, 0, 0)),
    ], total_frames=24)

    # 8. dodge
    abf.create_bone_action(arm_obj, "dodge", [
        ("Hips", "location", 1, (0, 0, -0.2)),
        ("Chest", "rotation_euler", 12, (math.radians(35), 0, 0)),
        ("Hips", "location", 24, (0, 0, 0)),
    ], total_frames=24)

    # 9. attack
    abf.create_bone_action(arm_obj, "attack", [
        ("RightArm", "rotation_euler", 1, (0, 0, 0)),
        ("RightArm", "rotation_euler", 8, (math.radians(-80), math.radians(40), 0)),
        ("RightArm", "rotation_euler", 16, (math.radians(65), math.radians(-30), 0)),
        ("RightArm", "rotation_euler", 24, (0, 0, 0)),
    ], total_frames=24)

    # Rig de Estúdio, Salvar e Exportar
    abf.setup_studio_rig(target_center=(0, 0, 1.0), distance=3.2, elevation=1.2, key_power=250.0, rim_color="#4488ff")
    
    blend_path = os.path.join(abf.BLENDER_ASSETS_DIR, "characters", "player_character_master.blend")
    abf.save_blend_project(blend_path)
    
    preview_path = os.path.join(abf.PREVIEWS_DIR, "characters", "player_character_master.png")
    abf.render_preview_image(preview_path)
    
    # Exportação tanto para char_ref_humanoid.glb quanto para player_character_master.glb
    glb_ref = os.path.join(abf.MODELS_EXPORT_DIR, "characters", "reference", "char_ref_humanoid.glb")
    glb_master = os.path.join(abf.MODELS_EXPORT_DIR, "characters", "player_character_master.glb")
    
    abf.export_glb_model(glb_ref, include_animations=True)
    abf.export_glb_model(glb_master, include_animations=True)

    print("======================================================================")
    print("PERSONAGEM MESTRE DO JOGADOR CONSTRUÍDO E EXPORTADO COM SUCESSO!")
    print("======================================================================")
    return True


if __name__ == "__main__":
    build_player_character()
