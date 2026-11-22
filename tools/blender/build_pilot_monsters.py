"""
ABYSSAL PACT — GERADOR DOS 5 MODELOS-PILOTO DO BESTIÁRIO 3D (BLENDER 5.3+)
Cria 5 criaturas de 5 famílias distintas com silhuetas, anatomias, materiais e rigs únicos:
1. MONSTER_001: Ogro das Cinzas (Humanoides monstruosos) - Veyrath / Vulcânico
2. MONSTER_041: Lobo do Gelo Eterno (Feras e predadores) - Khar'Duum / Glacial
3. MONSTER_081: Draconiano Vulcânico (Répteis e criaturas dracônicas) - Veyrath / Magma
4. MONSTER_111: Cavaleiro Espectral da Cripta (Mortos-vivos) - Nhal'Kora / Sombrio
5. MONSTER_211: Golem de Cristal Arcano (Criaturas mágicas e elementais) - Sylvaran / Arcano

Saídas por criatura:
- Arquivo .blend editável em: assets/3d/monsters/<Família>/
- Modelo glTF 2.0 (.glb) em: assets/3d/monsters/<Família>/
- Render de prévia PNG em: assets/3d/monsters/Previews/
"""

import bpy
import math
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.append(SCRIPT_DIR)

import abyssal_blender_framework as abf

MONSTERS_ROOT = os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters")
PREVIEWS_ROOT = os.path.join(MONSTERS_ROOT, "Previews")


# ==============================================================================
# PILOTO 1: MONSTER_001_Ogro_das_Cinzas (Humanoides monstruosos)
# ==============================================================================
def build_monster_001():
    print("\n----------------------------------------------------------------------")
    print("PILOTO 1: MONSTER_001_Ogro_das_Cinzas (Humanoides monstruosos)")
    print("----------------------------------------------------------------------")
    abf.reset_scene(fps=24)

    mat_skin = abf.create_pbr_material("Mat_Ogre_AshSkin", "#3d3733", roughness=0.8, metallic=0.1)
    mat_leather = abf.create_pbr_material("Mat_Ogre_ScorchedLeather", "#241812", roughness=0.7, metallic=0.2)
    mat_iron = abf.create_pbr_material("Mat_Ogre_Iron", "#282a2e", roughness=0.4, metallic=0.85)
    mat_glow = abf.create_pbr_material("Mat_Ogre_EyeGlow", "#ff5500", roughness=0.2, metallic=0.0, emission_hex="#ff5500", emission_strength=5.0)
    mat_bone = abf.create_pbr_material("Mat_Ogre_Tusk", "#d1c7b7", roughness=0.5, metallic=0.2)

    parts = []
    # Pelve e saia de batalha
    pelvis = abf.add_primitive("cube", "Ogre_Pelvis", location=(0, 0, 1.4), scale=(0.9, 0.7, 0.5))
    abf.set_object_material(pelvis, mat_leather)
    parts.append(pelvis)

    # Tronco colossal e corcunda
    belly = abf.add_primitive("ico_sphere", "Ogre_Belly", location=(0, -0.2, 2.0), scale=(1.1, 1.0, 0.9), subdivisions=3)
    abf.set_object_material(belly, mat_skin)
    parts.append(belly)

    chest = abf.add_primitive("cube", "Ogre_Chest", location=(0, 0, 2.5), scale=(1.5, 1.1, 0.9))
    abf.set_object_material(chest, mat_skin)
    parts.append(chest)

    # Ombreira de ferro assimétrica
    pauldron = abf.add_primitive("ico_sphere", "Ogre_Pauldron_L", location=(-1.1, 0, 2.8), scale=(0.6, 0.65, 0.5), subdivisions=2)
    abf.set_object_material(pauldron, mat_iron)
    parts.append(pauldron)

    # Cabeça brutal com mandíbula pesada e presas
    head = abf.add_primitive("cube", "Ogre_Head", location=(0, -0.3, 3.1), scale=(0.7, 0.75, 0.65))
    abf.set_object_material(head, mat_skin)
    parts.append(head)

    eye = abf.add_primitive("ico_sphere", "Ogre_CyclopsEye", location=(0, -0.7, 3.2), scale=(0.18, 0.18, 0.18), subdivisions=2)
    abf.set_object_material(eye, mat_glow)
    parts.append(eye)

    tusk_l = abf.add_primitive("cone", "Ogre_Tusk_L", location=(-0.35, -0.7, 2.9), scale=(0.12, 0.12, 0.45), rotation=(math.radians(45), math.radians(-25), 0))
    tusk_r = abf.add_primitive("cone", "Ogre_Tusk_R", location=(0.35, -0.7, 2.9), scale=(0.12, 0.12, 0.45), rotation=(math.radians(45), math.radians(25), 0))
    abf.set_object_material(tusk_l, mat_bone)
    abf.set_object_material(tusk_r, mat_bone)
    parts.extend([tusk_l, tusk_r])

    # Braços musculosos
    for side, mult in [("L", -1), ("R", 1)]:
        arm = abf.add_primitive("cylinder", f"Ogre_UpperArm_{side}", location=(mult * 1.1, 0, 2.3), scale=(0.4, 0.4, 0.8), vertices=10)
        abf.set_object_material(arm, mat_skin)
        parts.append(arm)

        forearm = abf.add_primitive("cylinder", f"Ogre_Forearm_{side}", location=(mult * 1.25, -0.2, 1.4), scale=(0.35, 0.35, 0.9), vertices=10)
        abf.set_object_material(forearm, mat_skin)
        parts.append(forearm)

    # Clava de Basalto Spikada na mão direita
    club_handle = abf.add_primitive("cylinder", "Ogre_Club_Handle", location=(1.3, -0.3, 1.2), scale=(0.1, 0.1, 1.8), vertices=8)
    abf.set_object_material(club_handle, mat_leather)
    parts.append(club_handle)

    club_head = abf.add_primitive("cube", "Ogre_Club_Head", location=(1.3, -0.3, 2.2), scale=(0.45, 0.45, 0.8))
    abf.set_object_material(club_head, mat_iron)
    parts.append(club_head)

    # Pernas maciças
    for side, mult in [("L", -1), ("R", 1)]:
        leg = abf.add_primitive("cylinder", f"Ogre_Leg_{side}", location=(mult * 0.55, 0, 0.7), scale=(0.4, 0.4, 1.1), vertices=10)
        abf.set_object_material(leg, mat_skin)
        parts.append(leg)

        foot = abf.add_primitive("cube", f"Ogre_Foot_{side}", location=(mult * 0.55, -0.2, 0.15), scale=(0.5, 0.75, 0.3))
        abf.set_object_material(foot, mat_leather)
        parts.append(foot)

    ogre_mesh = abf.join_mesh_objects(parts, "MONSTER_001_Ogro_das_Cinzas_Mesh")

    # Armature Humanoide Bruta
    arm_obj = abf.create_armature("Ogre_Armature")
    bdefs = [
        {"name": "Root", "head": (0, 0, 0), "tail": (0, 0, 0.4), "parent": None},
        {"name": "Pelvis", "head": (0, 0, 1.3), "tail": (0, 0, 1.8), "parent": "Root"},
        {"name": "Chest", "head": (0, 0, 1.8), "tail": (0, 0, 2.8), "parent": "Pelvis"},
        {"name": "Head", "head": (0, -0.1, 2.8), "tail": (0, -0.2, 3.5), "parent": "Chest"},
        {"name": "Arm_L", "head": (-0.8, 0, 2.6), "tail": (-1.2, 0, 1.5), "parent": "Chest"},
        {"name": "Forearm_L", "head": (-1.2, 0, 1.5), "tail": (-1.3, -0.2, 0.8), "parent": "Arm_L"},
        {"name": "Arm_R", "head": (0.8, 0, 2.6), "tail": (1.2, 0, 1.5), "parent": "Chest"},
        {"name": "Forearm_R", "head": (1.2, 0, 1.5), "tail": (1.3, -0.2, 0.8), "parent": "Arm_R"},
        {"name": "Leg_L", "head": (-0.5, 0, 1.3), "tail": (-0.55, 0, 0.1), "parent": "Pelvis"},
        {"name": "Leg_R", "head": (0.5, 0, 1.3), "tail": (0.55, 0, 0.1), "parent": "Pelvis"},
    ]
    abf.add_bone_hierarchy(arm_obj, bdefs)
    abf.bind_mesh_to_armature(ogre_mesh, arm_obj)

    # Animações
    abf.create_bone_action(arm_obj, "idle", [
        ("Chest", "location", 1, (0, 0, 0)),
        ("Chest", "location", 12, (0, 0, 0.04)),
        ("Chest", "location", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "attack_smash", [
        ("Arm_R", "rotation_euler", 1, (0, 0, 0)),
        ("Arm_R", "rotation_euler", 8, (math.radians(-90), 0, 0)),
        ("Arm_R", "rotation_euler", 14, (math.radians(70), 0, 0)),
        ("Arm_R", "rotation_euler", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.setup_studio_rig(target_center=(0, 0, 1.8), distance=5.5, elevation=2.0, key_power=400.0, rim_color="#ff5500")

    blend_file = os.path.join(MONSTERS_ROOT, "Humanoids", "MONSTER_001_Ogro_das_Cinzas.blend")
    glb_file = os.path.join(MONSTERS_ROOT, "Humanoids", "MONSTER_001_Ogro_das_Cinzas.glb")
    preview_file = os.path.join(PREVIEWS_ROOT, "MONSTER_001_Ogro_das_Cinzas.png")

    abf.save_blend_project(blend_file)
    abf.render_preview_image(preview_file)
    abf.export_glb_model(glb_file, include_animations=True)
    return True


# ==============================================================================
# PILOTO 2: MONSTER_041_Lobo_do_Gelo_Eterno (Feras e predadores)
# ==============================================================================
def build_monster_041():
    print("\n----------------------------------------------------------------------")
    print("PILOTO 2: MONSTER_041_Lobo_do_Gelo_Eterno (Feras e predadores)")
    print("----------------------------------------------------------------------")
    abf.reset_scene(fps=24)

    mat_fur = abf.create_pbr_material("Mat_Wolf_GlacialFur", "#dbe8f5", roughness=0.85, metallic=0.05)
    mat_mane = abf.create_pbr_material("Mat_Wolf_DarkMane", "#8ea1b0", roughness=0.8, metallic=0.1)
    mat_crystal = abf.create_pbr_material("Mat_Wolf_IceSpikes", "#44ccee", roughness=0.15, metallic=0.2, emission_hex="#55ccff", emission_strength=4.0)
    mat_claw = abf.create_pbr_material("Mat_Wolf_Claws", "#1a202c", roughness=0.4, metallic=0.6)
    mat_eye = abf.create_pbr_material("Mat_Wolf_IceEye", "#00ffff", roughness=0.1, metallic=0.0, emission_hex="#00ffff", emission_strength=6.0)

    parts = []
    # Tronco de quadrúpede predador
    chest = abf.add_primitive("ico_sphere", "Wolf_Chest", location=(0, -0.3, 1.0), scale=(0.55, 0.75, 0.6), subdivisions=3)
    abf.set_object_material(chest, mat_fur)
    parts.append(chest)

    pelvis = abf.add_primitive("ico_sphere", "Wolf_Pelvis", location=(0, 0.55, 0.95), scale=(0.45, 0.6, 0.5), subdivisions=3)
    abf.set_object_material(pelvis, mat_fur)
    parts.append(pelvis)

    # Juba felpuda com espigões de gelo
    mane = abf.add_primitive("cube", "Wolf_Mane", location=(0, -0.4, 1.25), scale=(0.65, 0.5, 0.55))
    abf.set_object_material(mane, mat_mane)
    parts.append(mane)

    for idx, (oy, oz) in enumerate([(-0.3, 1.45), (0.0, 1.35), (0.3, 1.25), (0.6, 1.15)]):
        spike = abf.add_primitive("cone", f"Wolf_IceSpike_{idx}", location=(0, oy, oz), scale=(0.12, 0.12, 0.45), rotation=(math.radians(35), 0, 0))
        abf.set_object_material(spike, mat_crystal)
        parts.append(spike)

    # Cabeça e mandíbula lupina
    head = abf.add_primitive("cube", "Wolf_Head", location=(0, -0.9, 1.2), scale=(0.35, 0.45, 0.35))
    abf.set_object_material(head, mat_fur)
    parts.append(head)

    snout = abf.add_primitive("cylinder", "Wolf_Snout", location=(0, -1.3, 1.1), scale=(0.18, 0.18, 0.5), rotation=(math.radians(80), 0, 0), vertices=8)
    abf.set_object_material(snout, mat_mane)
    parts.append(snout)

    ear_l = abf.add_primitive("cone", "Wolf_Ear_L", location=(-0.22, -0.85, 1.55), scale=(0.1, 0.1, 0.3), rotation=(math.radians(-20), math.radians(-25), 0))
    ear_r = abf.add_primitive("cone", "Wolf_Ear_R", location=(0.22, -0.85, 1.55), scale=(0.1, 0.1, 0.3), rotation=(math.radians(-20), math.radians(25), 0))
    abf.set_object_material(ear_l, mat_fur)
    abf.set_object_material(ear_r, mat_fur)
    parts.extend([ear_l, ear_r])

    eye_l = abf.add_primitive("ico_sphere", "Wolf_Eye_L", location=(-0.16, -1.1, 1.28), scale=(0.06, 0.06, 0.06), subdivisions=2)
    eye_r = abf.add_primitive("ico_sphere", "Wolf_Eye_R", location=(0.16, -1.1, 1.28), scale=(0.06, 0.06, 0.06), subdivisions=2)
    abf.set_object_material(eye_l, mat_eye)
    abf.set_object_material(eye_r, mat_eye)
    parts.extend([eye_l, eye_r])

    # 4 Patas de caçador
    for side, mult in [("L", -1), ("R", 1)]:
        # Pata dianteira
        f_leg = abf.add_primitive("cylinder", f"Wolf_ForeLeg_{side}", location=(mult * 0.35, -0.35, 0.45), scale=(0.14, 0.14, 0.9), vertices=8)
        abf.set_object_material(f_leg, mat_fur)
        parts.append(f_leg)

        # Pata traseira
        b_leg = abf.add_primitive("cylinder", f"Wolf_BackLeg_{side}", location=(mult * 0.35, 0.55, 0.45), scale=(0.16, 0.16, 0.9), vertices=8)
        abf.set_object_material(b_leg, mat_fur)
        parts.append(b_leg)

    # Cauda de nevasca
    for t_idx, (ty, tz) in enumerate([(0.9, 0.9), (1.3, 0.7), (1.7, 0.5)]):
        t_seg = abf.add_primitive("cylinder", f"Wolf_Tail_{t_idx}", location=(0, ty, tz), scale=(0.18 - t_idx * 0.03, 0.18 - t_idx * 0.03, 0.45), rotation=(math.radians(-45), 0, 0), vertices=8)
        abf.set_object_material(t_seg, mat_fur)
        parts.append(t_seg)

    wolf_mesh = abf.join_mesh_objects(parts, "MONSTER_041_Lobo_do_Gelo_Eterno_Mesh")

    # Armature Quadrúpede Lupina
    arm_obj = abf.create_armature("Wolf_Armature")
    bdefs = [
        {"name": "Root", "head": (0, 0, 0), "tail": (0, 0, 0.3), "parent": None},
        {"name": "Pelvis", "head": (0, 0.5, 0.9), "tail": (0, 0.1, 0.95), "parent": "Root"},
        {"name": "Chest", "head": (0, 0.1, 0.95), "tail": (0, -0.5, 1.05), "parent": "Pelvis"},
        {"name": "Neck", "head": (0, -0.5, 1.05), "tail": (0, -0.8, 1.25), "parent": "Chest"},
        {"name": "Head", "head": (0, -0.8, 1.25), "tail": (0, -1.3, 1.2), "parent": "Neck"},
        {"name": "ForeLeg_L", "head": (-0.35, -0.35, 0.9), "tail": (-0.35, -0.35, 0.1), "parent": "Chest"},
        {"name": "ForeLeg_R", "head": (0.35, -0.35, 0.9), "tail": (0.35, -0.35, 0.1), "parent": "Chest"},
        {"name": "BackLeg_L", "head": (-0.35, 0.55, 0.9), "tail": (-0.35, 0.55, 0.1), "parent": "Pelvis"},
        {"name": "BackLeg_R", "head": (0.35, 0.55, 0.9), "tail": (0.35, 0.55, 0.1), "parent": "Pelvis"},
        {"name": "Tail", "head": (0, 0.8, 0.9), "tail": (0, 1.6, 0.4), "parent": "Pelvis"},
    ]
    abf.add_bone_hierarchy(arm_obj, bdefs)
    abf.bind_mesh_to_armature(wolf_mesh, arm_obj)

    # Animações
    abf.create_bone_action(arm_obj, "idle", [
        ("Chest", "location", 1, (0, 0, 0)),
        ("Chest", "location", 12, (0, 0, 0.03)),
        ("Chest", "location", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "run", [
        ("ForeLeg_L", "rotation_euler", 1, (math.radians(35), 0, 0)),
        ("ForeLeg_L", "rotation_euler", 12, (math.radians(-35), 0, 0)),
        ("ForeLeg_L", "rotation_euler", 24, (math.radians(35), 0, 0)),
        ("BackLeg_R", "rotation_euler", 1, (math.radians(35), 0, 0)),
        ("BackLeg_R", "rotation_euler", 12, (math.radians(-35), 0, 0)),
        ("BackLeg_R", "rotation_euler", 24, (math.radians(35), 0, 0)),
    ], total_frames=24)

    abf.setup_studio_rig(target_center=(0, 0, 1.0), distance=4.5, elevation=1.5, key_power=300.0, rim_color="#00ffff")

    blend_file = os.path.join(MONSTERS_ROOT, "Beasts", "MONSTER_041_Lobo_do_Gelo_Eterno.blend")
    glb_file = os.path.join(MONSTERS_ROOT, "Beasts", "MONSTER_041_Lobo_do_Gelo_Eterno.glb")
    preview_file = os.path.join(PREVIEWS_ROOT, "MONSTER_041_Lobo_do_Gelo_Eterno.png")

    abf.save_blend_project(blend_file)
    abf.render_preview_image(preview_file)
    abf.export_glb_model(glb_file, include_animations=True)
    return True


# ==============================================================================
# PILOTO 3: MONSTER_081_Draconiano_Vulcânico (Répteis e criaturas dracônicas)
# ==============================================================================
def build_monster_081():
    print("\n----------------------------------------------------------------------")
    print("PILOTO 3: MONSTER_081_Draconiano_Vulcânico (Répteis e criaturas dracônicas)")
    print("----------------------------------------------------------------------")
    abf.reset_scene(fps=24)

    mat_scales = abf.create_pbr_material("Mat_Drake_Scales", "#2b1410", roughness=0.6, metallic=0.4)
    mat_belly = abf.create_pbr_material("Mat_Drake_MagmaBelly", "#521b10", roughness=0.4, metallic=0.1, emission_hex="#ff4400", emission_strength=3.5)
    mat_horns = abf.create_pbr_material("Mat_Drake_ObsidianSpikes", "#140a08", roughness=0.3, metallic=0.8)
    mat_eye = abf.create_pbr_material("Mat_Drake_Eye", "#ff9900", roughness=0.1, metallic=0.0, emission_hex="#ff9900", emission_strength=6.0)

    parts = []
    # Tronco réptil bípede/quadrúpede
    pelvis = abf.add_primitive("cube", "Drake_Pelvis", location=(0, 0.2, 1.2), scale=(0.8, 0.9, 0.6))
    abf.set_object_material(pelvis, mat_scales)
    parts.append(pelvis)

    chest = abf.add_primitive("cube", "Drake_Chest", location=(0, -0.4, 1.7), scale=(1.1, 1.0, 0.8))
    abf.set_object_material(chest, mat_scales)
    parts.append(chest)

    belly = abf.add_primitive("cube", "Drake_Belly", location=(0, -0.5, 1.4), scale=(0.7, 0.6, 0.7))
    abf.set_object_material(belly, mat_belly)
    parts.append(belly)

    # Crista espinhosa dorsal
    for idx, (dy, dz) in enumerate([(-0.4, 2.2), (-0.1, 2.0), (0.2, 1.8), (0.5, 1.6)]):
        spike = abf.add_primitive("cone", f"Drake_Spike_{idx}", location=(0, dy, dz), scale=(0.14, 0.14, 0.5), rotation=(math.radians(35), 0, 0))
        abf.set_object_material(spike, mat_horns)
        parts.append(spike)

    # Cabeça draconiana com focinho comprido
    neck = abf.add_primitive("cylinder", "Drake_Neck", location=(0, -0.7, 2.1), scale=(0.4, 0.4, 0.7), rotation=(math.radians(45), 0, 0), vertices=8)
    abf.set_object_material(neck, mat_scales)
    parts.append(neck)

    head = abf.add_primitive("cube", "Drake_Head", location=(0, -1.1, 2.5), scale=(0.45, 0.7, 0.4))
    abf.set_object_material(head, mat_scales)
    parts.append(head)

    jaw = abf.add_primitive("cube", "Drake_Jaw", location=(0, -1.2, 2.25), scale=(0.4, 0.65, 0.2))
    abf.set_object_material(jaw, mat_belly)
    parts.append(jaw)

    # Chifres draconianos em curva
    horn_l = abf.add_primitive("cone", "Drake_Horn_L", location=(-0.35, -0.85, 2.8), scale=(0.14, 0.14, 0.8), rotation=(math.radians(-35), math.radians(-30), 0))
    horn_r = abf.add_primitive("cone", "Drake_Horn_R", location=(0.35, -0.85, 2.8), scale=(0.14, 0.14, 0.8), rotation=(math.radians(-35), math.radians(30), 0))
    abf.set_object_material(horn_l, mat_horns)
    abf.set_object_material(horn_r, mat_horns)
    parts.extend([horn_l, horn_r])

    eye_l = abf.add_primitive("ico_sphere", "Drake_Eye_L", location=(-0.25, -1.2, 2.6), scale=(0.07, 0.07, 0.07), subdivisions=2)
    eye_r = abf.add_primitive("ico_sphere", "Drake_Eye_R", location=(0.25, -1.2, 2.6), scale=(0.07, 0.07, 0.07), subdivisions=2)
    abf.set_object_material(eye_l, mat_eye)
    abf.set_object_material(eye_r, mat_eye)
    parts.extend([eye_l, eye_r])

    # Membros Dracônicos
    for side, mult in [("L", -1), ("R", 1)]:
        arm = abf.add_primitive("cylinder", f"Drake_Arm_{side}", location=(mult * 0.7, -0.5, 1.4), scale=(0.22, 0.22, 0.7), vertices=8)
        abf.set_object_material(arm, mat_scales)
        parts.append(arm)

        leg = abf.add_primitive("cylinder", f"Drake_Leg_{side}", location=(mult * 0.55, 0.3, 0.6), scale=(0.3, 0.3, 1.2), vertices=10)
        abf.set_object_material(leg, mat_scales)
        parts.append(leg)

    # Cauda de réptil farpada
    for t_idx, (ty, tz) in enumerate([(0.7, 1.1), (1.3, 0.9), (1.9, 0.6), (2.5, 0.3)]):
        t_seg = abf.add_primitive("cylinder", f"Drake_Tail_{t_idx}", location=(0, ty, tz), scale=(0.28 - t_idx * 0.05, 0.28 - t_idx * 0.05, 0.65), rotation=(math.radians(-45), 0, 0), vertices=8)
        abf.set_object_material(t_seg, mat_scales)
        parts.append(t_seg)

    drake_mesh = abf.join_mesh_objects(parts, "MONSTER_081_Draconiano_Vulcanico_Mesh")

    # Armature Draconiana
    arm_obj = abf.create_armature("Drake_Armature")
    bdefs = [
        {"name": "Root", "head": (0, 0, 0), "tail": (0, 0, 0.4), "parent": None},
        {"name": "Pelvis", "head": (0, 0.3, 1.1), "tail": (0, -0.1, 1.3), "parent": "Root"},
        {"name": "Chest", "head": (0, -0.1, 1.3), "tail": (0, -0.6, 1.8), "parent": "Pelvis"},
        {"name": "Neck", "head": (0, -0.6, 1.8), "tail": (0, -0.9, 2.3), "parent": "Chest"},
        {"name": "Head", "head": (0, -0.9, 2.3), "tail": (0, -1.4, 2.5), "parent": "Neck"},
        {"name": "Arm_L", "head": (-0.6, -0.4, 1.6), "tail": (-0.8, -0.6, 0.9), "parent": "Chest"},
        {"name": "Arm_R", "head": (0.6, -0.4, 1.6), "tail": (0.8, -0.6, 0.9), "parent": "Chest"},
        {"name": "Leg_L", "head": (-0.5, 0.3, 1.1), "tail": (-0.55, 0.3, 0.1), "parent": "Pelvis"},
        {"name": "Leg_R", "head": (0.5, 0.3, 1.1), "tail": (0.55, 0.3, 0.1), "parent": "Pelvis"},
        {"name": "Tail", "head": (0, 0.7, 1.1), "tail": (0, 2.3, 0.3), "parent": "Pelvis"},
    ]
    abf.add_bone_hierarchy(arm_obj, bdefs)
    abf.bind_mesh_to_armature(drake_mesh, arm_obj)

    # Animações
    abf.create_bone_action(arm_obj, "idle", [
        ("Chest", "location", 1, (0, 0, 0)),
        ("Chest", "location", 12, (0, 0, 0.03)),
        ("Chest", "location", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "fire_breath", [
        ("Head", "rotation_euler", 1, (0, 0, 0)),
        ("Head", "rotation_euler", 8, (math.radians(-25), 0, 0)),
        ("Head", "rotation_euler", 16, (math.radians(20), 0, 0)),
        ("Head", "rotation_euler", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.setup_studio_rig(target_center=(0, 0, 1.5), distance=5.5, elevation=2.0, key_power=380.0, rim_color="#ff5500")

    blend_file = os.path.join(MONSTERS_ROOT, "Reptiles_Dragons", "MONSTER_081_Draconiano_Vulcanico.blend")
    glb_file = os.path.join(MONSTERS_ROOT, "Reptiles_Dragons", "MONSTER_081_Draconiano_Vulcanico.glb")
    preview_file = os.path.join(PREVIEWS_ROOT, "MONSTER_081_Draconiano_Vulcanico.png")

    abf.save_blend_project(blend_file)
    abf.render_preview_image(preview_file)
    abf.export_glb_model(glb_file, include_animations=True)
    return True


# ==============================================================================
# PILOTO 4: MONSTER_111_Cavaleiro_Espectral_da_Cripta (Mortos-vivos)
# ==============================================================================
def build_monster_111():
    print("\n----------------------------------------------------------------------")
    print("PILOTO 4: MONSTER_111_Cavaleiro_Espectral_da_Cripta (Mortos-vivos)")
    print("----------------------------------------------------------------------")
    abf.reset_scene(fps=24)

    mat_armor = abf.create_pbr_material("Mat_Knight_AncientPlate", "#282d30", roughness=0.35, metallic=0.9)
    mat_gold = abf.create_pbr_material("Mat_Knight_TarnishedGold", "#786532", roughness=0.4, metallic=0.95)
    mat_bone = abf.create_pbr_material("Mat_Knight_DecayedBone", "#b0a58f", roughness=0.7, metallic=0.1)
    mat_spectral = abf.create_pbr_material("Mat_Knight_Soulflame", "#00ffaa", roughness=0.15, metallic=0.0, emission_hex="#00ffaa", emission_strength=7.0)

    parts = []
    # Armadura imperial arcaica deteriorada (Altura ~2.0m)
    pelvis = abf.add_primitive("cube", "Knight_Pelvis", location=(0, 0, 1.05), scale=(0.45, 0.32, 0.25))
    abf.set_object_material(pelvis, mat_armor)
    parts.append(pelvis)

    torso = abf.add_primitive("cylinder", "Knight_Torso", location=(0, 0, 1.3), scale=(0.4, 0.28, 0.35), vertices=10)
    abf.set_object_material(torso, mat_bone)
    parts.append(torso)

    cuirass = abf.add_primitive("cube", "Knight_Cuirass", location=(0, -0.02, 1.5), scale=(0.52, 0.36, 0.45))
    abf.set_object_material(cuirass, mat_armor)
    parts.append(cuirass)

    cuirass_trim = abf.add_primitive("cube", "Knight_Trim", location=(0, -0.19, 1.5), scale=(0.42, 0.05, 0.35))
    abf.set_object_material(cuirass_trim, mat_gold)
    parts.append(cuirass_trim)

    # Elmo alado com crânio espectral
    skull = abf.add_primitive("ico_sphere", "Knight_Skull", location=(0, 0, 1.88), scale=(0.24, 0.26, 0.25), subdivisions=3)
    abf.set_object_material(skull, mat_bone)
    parts.append(skull)

    eye_l = abf.add_primitive("ico_sphere", "Knight_Eye_L", location=(-0.09, -0.22, 1.9), scale=(0.04, 0.04, 0.04), subdivisions=2)
    eye_r = abf.add_primitive("ico_sphere", "Knight_Eye_R", location=(0.09, -0.22, 1.9), scale=(0.04, 0.04, 0.04), subdivisions=2)
    abf.set_object_material(eye_l, mat_spectral)
    abf.set_object_material(eye_r, mat_spectral)
    parts.extend([eye_l, eye_r])

    wing_l = abf.add_primitive("cone", "Knight_HelmWing_L", location=(-0.3, 0, 2.05), scale=(0.08, 0.08, 0.5), rotation=(0, math.radians(-35), math.radians(15)))
    wing_r = abf.add_primitive("cone", "Knight_HelmWing_R", location=(0.3, 0, 2.05), scale=(0.08, 0.08, 0.5), rotation=(0, math.radians(35), math.radians(-15)))
    abf.set_object_material(wing_l, mat_gold)
    abf.set_object_material(wing_r, mat_gold)
    parts.extend([wing_l, wing_r])

    # Braços e Espada Espectral
    for side, mult in [("L", -1), ("R", 1)]:
        pauldron = abf.add_primitive("cube", f"Knight_Pauldron_{side}", location=(mult * 0.38, 0, 1.62), scale=(0.22, 0.26, 0.22))
        abf.set_object_material(pauldron, mat_armor)
        parts.append(pauldron)

        arm = abf.add_primitive("cylinder", f"Knight_Arm_{side}", location=(mult * 0.38, 0, 1.35), scale=(0.11, 0.11, 0.35), vertices=8)
        abf.set_object_material(arm, mat_bone)
        parts.append(arm)

        gauntlet = abf.add_primitive("cylinder", f"Knight_Gauntlet_{side}", location=(mult * 0.42, -0.05, 1.0), scale=(0.13, 0.13, 0.35), vertices=8)
        abf.set_object_material(gauntlet, mat_armor)
        parts.append(gauntlet)

    # Espada Longa Espectral
    blade = abf.add_primitive("cube", "Knight_Blade", location=(0.55, -0.3, 1.3), scale=(0.06, 0.02, 1.4))
    abf.set_object_material(blade, mat_spectral)
    parts.append(blade)

    hilt = abf.add_primitive("cylinder", "Knight_Hilt", location=(0.55, -0.3, 0.55), scale=(0.05, 0.05, 0.3), vertices=8)
    abf.set_object_material(hilt, mat_gold)
    parts.append(hilt)

    # Pernas e Grevas
    for side, mult in [("L", -1), ("R", 1)]:
        thigh = abf.add_primitive("cylinder", f"Knight_Thigh_{side}", location=(mult * 0.2, 0, 0.8), scale=(0.14, 0.14, 0.45), vertices=8)
        abf.set_object_material(thigh, mat_bone)
        parts.append(thigh)

        greave = abf.add_primitive("cylinder", f"Knight_Greave_{side}", location=(mult * 0.2, 0, 0.4), scale=(0.15, 0.15, 0.45), vertices=8)
        abf.set_object_material(greave, mat_armor)
        parts.append(greave)

    knight_mesh = abf.join_mesh_objects(parts, "MONSTER_111_Cavaleiro_Espectral_da_Cripta_Mesh")

    # Armature Esquelética Guerreira
    arm_obj = abf.create_armature("Knight_Armature")
    bdefs = [
        {"name": "Root", "head": (0, 0, 0), "tail": (0, 0, 0.3), "parent": None},
        {"name": "Pelvis", "head": (0, 0, 1.0), "tail": (0, 0, 1.25), "parent": "Root"},
        {"name": "Chest", "head": (0, 0, 1.25), "tail": (0, 0, 1.7), "parent": "Pelvis"},
        {"name": "Head", "head": (0, 0, 1.7), "tail": (0, 0, 2.05), "parent": "Chest"},
        {"name": "Arm_L", "head": (-0.35, 0, 1.6), "tail": (-0.45, 0, 0.9), "parent": "Chest"},
        {"name": "Arm_R", "head": (0.35, 0, 1.6), "tail": (0.45, 0, 0.9), "parent": "Chest"},
        {"name": "Leg_L", "head": (-0.2, 0, 1.0), "tail": (-0.2, 0, 0.1), "parent": "Pelvis"},
        {"name": "Leg_R", "head": (0.2, 0, 1.0), "tail": (0.2, 0, 0.1), "parent": "Pelvis"},
    ]
    abf.add_bone_hierarchy(arm_obj, bdefs)
    abf.bind_mesh_to_armature(knight_mesh, arm_obj)

    # Animações
    abf.create_bone_action(arm_obj, "idle", [
        ("Chest", "location", 1, (0, 0, 0)),
        ("Chest", "location", 12, (0, 0, 0.02)),
        ("Chest", "location", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "spectral_slash", [
        ("Arm_R", "rotation_euler", 1, (0, 0, 0)),
        ("Arm_R", "rotation_euler", 8, (math.radians(-75), math.radians(45), 0)),
        ("Arm_R", "rotation_euler", 16, (math.radians(65), math.radians(-35), 0)),
        ("Arm_R", "rotation_euler", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.setup_studio_rig(target_center=(0, 0, 1.2), distance=3.8, elevation=1.5, key_power=280.0, rim_color="#00ffaa")

    blend_file = os.path.join(MONSTERS_ROOT, "Undead", "MONSTER_111_Cavaleiro_Espectral_da_Cripta.blend")
    glb_file = os.path.join(MONSTERS_ROOT, "Undead", "MONSTER_111_Cavaleiro_Espectral_da_Cripta.glb")
    preview_file = os.path.join(PREVIEWS_ROOT, "MONSTER_111_Cavaleiro_Espectral_da_Cripta.png")

    abf.save_blend_project(blend_file)
    abf.render_preview_image(preview_file)
    abf.export_glb_model(glb_file, include_animations=True)
    return True


# ==============================================================================
# PILOTO 5: MONSTER_211_Golem_de_Cristal_Arcano (Criaturas mágicas e elementais)
# ==============================================================================
def build_monster_211():
    print("\n----------------------------------------------------------------------")
    print("PILOTO 5: MONSTER_211_Golem_de_Cristal_Arcano (Criaturas mágicas e elementais)")
    print("----------------------------------------------------------------------")
    abf.reset_scene(fps=24)

    mat_stone = abf.create_pbr_material("Mat_Golem_Granite", "#374151", roughness=0.75, metallic=0.1)
    mat_crystal = abf.create_pbr_material("Mat_Golem_Emerald", "#10b981", roughness=0.15, metallic=0.2, emission_hex="#10b981", emission_strength=4.0)
    mat_core = abf.create_pbr_material("Mat_Golem_ArcaneCore", "#34d399", roughness=0.1, metallic=0.0, emission_hex="#34d399", emission_strength=8.0)

    parts = []
    # Colosso de pedras flutuantes e cristais arcanos
    # Núcleo / Coração Arcano Central
    core = abf.add_primitive("ico_sphere", "Golem_ArcaneCore", location=(0, 0, 2.0), scale=(0.45, 0.45, 0.55), subdivisions=3)
    abf.set_object_material(core, mat_core)
    parts.append(core)

    # Monólito Torso Superior
    torso_stone = abf.add_primitive("cube", "Golem_TorsoStone", location=(0, 0, 2.5), scale=(1.2, 0.7, 0.6))
    abf.set_object_material(torso_stone, mat_stone)
    parts.append(torso_stone)

    # Cristais brotando no ombro
    for side, mult in [("L", -1), ("R", 1)]:
        c_shoulder = abf.add_primitive("cone", f"Golem_CrystalShoulder_{side}", location=(mult * 0.75, 0, 2.9), scale=(0.2, 0.2, 0.7), rotation=(0, math.radians(mult * 35), 0))
        abf.set_object_material(c_shoulder, mat_crystal)
        parts.append(c_shoulder)

        arm_stone = abf.add_primitive("cube", f"Golem_ArmStone_{side}", location=(mult * 1.0, 0, 1.8), scale=(0.4, 0.45, 0.7))
        abf.set_object_material(arm_stone, mat_stone)
        parts.append(arm_stone)

        fist_crystal = abf.add_primitive("cone", f"Golem_FistCrystal_{side}", location=(mult * 1.1, -0.1, 1.0), scale=(0.25, 0.25, 0.8), rotation=(math.radians(180), 0, 0))
        abf.set_object_material(fist_crystal, mat_crystal)
        parts.append(fist_crystal)

    # Base Levitante Flutuante
    base_monolith = abf.add_primitive("cone", "Golem_LevitatingSpire", location=(0, 0, 1.1), scale=(0.6, 0.6, 1.2), rotation=(math.radians(180), 0, 0))
    abf.set_object_material(base_monolith, mat_stone)
    parts.append(base_monolith)

    for o_angle, o_rad in [(0, 0.6), (math.radians(120), 0.6), (math.radians(240), 0.6)]:
        ox = math.cos(o_angle) * o_rad
        oy = math.sin(o_angle) * o_rad
        orbit_shard = abf.add_primitive("cone", f"Golem_OrbitShard_{o_angle}", location=(ox, oy, 1.7), scale=(0.1, 0.1, 0.4), rotation=(math.radians(25), 0, o_angle))
        abf.set_object_material(orbit_shard, mat_crystal)
        parts.append(orbit_shard)

    golem_mesh = abf.join_mesh_objects(parts, "MONSTER_211_Golem_de_Cristal_Arcano_Mesh")

    # Armature Elementar Flutuante
    arm_obj = abf.create_armature("Golem_Armature")
    bdefs = [
        {"name": "Root", "head": (0, 0, 0), "tail": (0, 0, 0.5), "parent": None},
        {"name": "BaseSpire", "head": (0, 0, 0.6), "tail": (0, 0, 1.4), "parent": "Root"},
        {"name": "Core", "head": (0, 0, 1.4), "tail": (0, 0, 2.2), "parent": "BaseSpire"},
        {"name": "Torso", "head": (0, 0, 2.2), "tail": (0, 0, 2.9), "parent": "Core"},
        {"name": "Arm_L", "head": (-0.8, 0, 2.5), "tail": (-1.1, 0, 1.2), "parent": "Torso"},
        {"name": "Arm_R", "head": (0.8, 0, 2.5), "tail": (1.1, 0, 1.2), "parent": "Torso"},
    ]
    abf.add_bone_hierarchy(arm_obj, bdefs)
    abf.bind_mesh_to_armature(golem_mesh, arm_obj)

    # Animações
    abf.create_bone_action(arm_obj, "idle", [
        ("Core", "location", 1, (0, 0, 0)),
        ("Core", "location", 12, (0, 0, 0.08)),
        ("Core", "location", 24, (0, 0, 0)),
        ("Torso", "rotation_euler", 1, (0, 0, 0)),
        ("Torso", "rotation_euler", 12, (0, math.radians(5), 0)),
        ("Torso", "rotation_euler", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.create_bone_action(arm_obj, "slam", [
        ("Arm_L", "rotation_euler", 1, (0, 0, 0)),
        ("Arm_L", "rotation_euler", 8, (math.radians(-80), 0, 0)),
        ("Arm_L", "rotation_euler", 14, (math.radians(60), 0, 0)),
        ("Arm_L", "rotation_euler", 24, (0, 0, 0)),
        ("Arm_R", "rotation_euler", 1, (0, 0, 0)),
        ("Arm_R", "rotation_euler", 8, (math.radians(-80), 0, 0)),
        ("Arm_R", "rotation_euler", 14, (math.radians(60), 0, 0)),
        ("Arm_R", "rotation_euler", 24, (0, 0, 0)),
    ], total_frames=24)

    abf.setup_studio_rig(target_center=(0, 0, 1.8), distance=5.0, elevation=2.0, key_power=350.0, rim_color="#10b981")

    blend_file = os.path.join(MONSTERS_ROOT, "Magical_Elementals", "MONSTER_211_Golem_de_Cristal_Arcano.blend")
    glb_file = os.path.join(MONSTERS_ROOT, "Magical_Elementals", "MONSTER_211_Golem_de_Cristal_Arcano.glb")
    preview_file = os.path.join(PREVIEWS_ROOT, "MONSTER_211_Golem_de_Cristal_Arcano.png")

    abf.save_blend_project(blend_file)
    abf.render_preview_image(preview_file)
    abf.export_glb_model(glb_file, include_animations=True)
    return True


def build_all_pilots():
    print("======================================================================")
    print("CONSTRUINDO OS 5 MODELOS-PILOTO NO BLENDER 5.3")
    print("======================================================================")
    build_monster_001()
    build_monster_041()
    build_monster_081()
    build_monster_111()
    build_monster_211()
    print("\n======================================================================")
    print("TODOS OS 5 MODELOS-PILOTO GERADOS E EXPORTADOS COM SUCESSO!")
    print("======================================================================")


if __name__ == "__main__":
    build_all_pilots()
