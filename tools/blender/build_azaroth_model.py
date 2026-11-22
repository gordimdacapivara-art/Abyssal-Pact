"""
ABYSSAL PACT — GERADOR DO MODELO 3D DE AZAROTH (WORLD BOSS)
Utiliza Blender 5.3+ com a API bpy para modelagem procedural de alta qualidade,
materiais PBR com emissão abissal, armature completa, animações e renderização de preview.

Saídas:
- .blend: assets/blender/bosses/azaroth_world_boss.blend
- .png: assets/previews/bosses/azaroth_world_boss.png
- .glb: assets/models/bosses/azaroth_world_boss.glb
"""

import bpy
import math
import os
import sys

# Adicionar pasta tools/blender ao sys.path para importar o framework
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.append(SCRIPT_DIR)

import abyssal_blender_framework as abf

def build_azaroth():
    print("======================================================================")
    print("INICIANDO CONSTRUÇÃO DE AZAROTH (WORLD BOSS SUPREMO) NO BLENDER 5.3")
    print("======================================================================")

    # 1. Reset da cena
    scene = abf.reset_scene(fps=24)

    # 2. Materiais PBR
    mat_armor = abf.create_pbr_material("Mat_Azaroth_ObsidianArmor", "#0c0608", roughness=0.3, metallic=0.85)
    mat_skin = abf.create_pbr_material("Mat_Azaroth_DemonSkin", "#240b0b", roughness=0.7, metallic=0.15)
    mat_veins = abf.create_pbr_material("Mat_Azaroth_MoltenVeins", "#400800", roughness=0.4, metallic=0.2, emission_hex="#ff3b00", emission_strength=4.5)
    mat_core = abf.create_pbr_material("Mat_Azaroth_FireCore", "#ff5500", roughness=0.2, metallic=0.0, emission_hex="#ffaa00", emission_strength=8.0)
    mat_horns = abf.create_pbr_material("Mat_Azaroth_BoneHorns", "#171210", roughness=0.45, metallic=0.4)
    mat_wings = abf.create_pbr_material("Mat_Azaroth_WingMembrane", "#300e12", roughness=0.75, metallic=0.1, emission_hex="#aa1100", emission_strength=1.2)

    parts = []

    # 3. Modelagem Anatômica de Azaroth (Escala Colossal: ~7.5m)
    # 3.1. Pelve e Quadril
    pelvis = abf.add_primitive("cube", "Azaroth_Pelvis", location=(0, 0, 3.2), scale=(1.4, 1.1, 0.9))
    abf.set_object_material(pelvis, mat_armor)
    parts.append(pelvis)

    # 3.2. Abdômen com fendas de magma
    abdomen = abf.add_primitive("cylinder", "Azaroth_Abdomen", location=(0, 0, 3.8), scale=(1.2, 0.9, 0.8), vertices=12)
    abf.set_object_material(abdomen, mat_veins)
    parts.append(abdomen)

    # 3.3. Tórax Colossal e Placa Peitoral de Obsidiana
    chest = abf.add_primitive("cube", "Azaroth_Chest", location=(0, 0, 4.6), scale=(2.2, 1.5, 1.4))
    abf.set_object_material(chest, mat_armor)
    parts.append(chest)

    # 3.4. Núcleo Infernal (Coração Abissal no centro do peito)
    core = abf.add_primitive("ico_sphere", "Azaroth_InfernalCore", location=(0, -0.65, 4.6), scale=(0.55, 0.35, 0.55), subdivisions=3)
    abf.set_object_material(core, mat_core)
    parts.append(core)

    # 3.5. Espigões Dorsais de Rocha Vulcânica
    for idx, z_offset in enumerate([4.3, 4.8, 5.3]):
        spike_l = abf.add_primitive("cone", f"Azaroth_BackSpike_L_{idx}", location=(-0.5, 0.8, z_offset), scale=(0.25, 0.25, 0.9), rotation=(math.radians(35), math.radians(-20), 0))
        spike_r = abf.add_primitive("cone", f"Azaroth_BackSpike_R_{idx}", location=(0.5, 0.8, z_offset), scale=(0.25, 0.25, 0.9), rotation=(math.radians(35), math.radians(20), 0))
        abf.set_object_material(spike_l, mat_horns)
        abf.set_object_material(spike_r, mat_horns)
        parts.extend([spike_l, spike_r])

    # 3.6. Pescoço e Cabeça Demoníaca
    neck = abf.add_primitive("cylinder", "Azaroth_Neck", location=(0, 0.1, 5.5), scale=(0.7, 0.7, 0.6), vertices=10)
    abf.set_object_material(neck, mat_skin)
    parts.append(neck)

    head = abf.add_primitive("cube", "Azaroth_Head", location=(0, -0.2, 6.0), scale=(0.9, 1.1, 0.9))
    abf.set_object_material(head, mat_armor)
    parts.append(head)

    # Chifres Demoníacos Maciços
    horn_l1 = abf.add_primitive("cone", "Azaroth_Horn_L1", location=(-0.6, 0.1, 6.6), scale=(0.35, 0.35, 1.6), rotation=(math.radians(-25), math.radians(-35), math.radians(15)))
    horn_r1 = abf.add_primitive("cone", "Azaroth_Horn_R1", location=(0.6, 0.1, 6.6), scale=(0.35, 0.35, 1.6), rotation=(math.radians(-25), math.radians(35), math.radians(-15)))
    abf.set_object_material(horn_l1, mat_horns)
    abf.set_object_material(horn_r1, mat_horns)
    parts.extend([horn_l1, horn_r1])

    # Olhos Flamejantes
    eye_l = abf.add_primitive("ico_sphere", "Azaroth_Eye_L", location=(-0.3, -0.7, 6.1), scale=(0.12, 0.12, 0.12), subdivisions=2)
    eye_r = abf.add_primitive("ico_sphere", "Azaroth_Eye_R", location=(0.3, -0.7, 6.1), scale=(0.12, 0.12, 0.12), subdivisions=2)
    abf.set_object_material(eye_l, mat_core)
    abf.set_object_material(eye_r, mat_core)
    parts.extend([eye_l, eye_r])

    # 3.7. Ombros, Braços e Garras Devastadoras
    for side, mult in [("L", -1), ("R", 1)]:
        # Ombro / Dragonne
        shoulder = abf.add_primitive("ico_sphere", f"Azaroth_Shoulder_{side}", location=(mult * 1.6, 0, 4.9), scale=(0.8, 0.8, 0.8), subdivisions=2)
        abf.set_object_material(shoulder, mat_armor)
        parts.append(shoulder)

        # Braço Superior
        upper_arm = abf.add_primitive("cylinder", f"Azaroth_UpperArm_{side}", location=(mult * 1.8, 0, 4.1), scale=(0.55, 0.55, 1.2), vertices=10)
        abf.set_object_material(upper_arm, mat_skin)
        parts.append(upper_arm)

        # Antebraço com manopla
        forearm = abf.add_primitive("cube", f"Azaroth_Forearm_{side}", location=(mult * 2.0, -0.2, 2.9), scale=(0.65, 0.65, 1.3))
        abf.set_object_material(forearm, mat_armor)
        parts.append(forearm)

        # Mão com 4 garras
        hand = abf.add_primitive("cube", f"Azaroth_Hand_{side}", location=(mult * 2.1, -0.3, 1.9), scale=(0.5, 0.6, 0.4))
        abf.set_object_material(hand, mat_skin)
        parts.append(hand)

        for c_idx, c_x in enumerate([-0.18, -0.06, 0.06, 0.18]):
            claw = abf.add_primitive("cone", f"Azaroth_Claw_{side}_{c_idx}", location=(mult * 2.1 + c_x, -0.6, 1.7), scale=(0.08, 0.08, 0.4), rotation=(math.radians(60), 0, 0))
            abf.set_object_material(claw, mat_horns)
            parts.append(claw)

    # 3.8. Asas Demoníacas Colossais (4 Asas: Par Superior Principal e Par Inferior)
    for side, mult in [("L", -1), ("R", 1)]:
        # Asa Superior Principal (Envergadura ~12m)
        wing_spar1 = abf.add_primitive("cylinder", f"Azaroth_WingMain_Spar_{side}", location=(mult * 1.8, 0.8, 5.8), scale=(0.25, 0.25, 2.6), rotation=(0, math.radians(mult * 55), math.radians(mult * 25)))
        abf.set_object_material(wing_spar1, mat_horns)
        parts.append(wing_spar1)

        wing_mem1 = abf.add_primitive("cube", f"Azaroth_WingMain_Mem_{side}", location=(mult * 3.2, 0.9, 5.5), scale=(2.2, 0.06, 1.8), rotation=(0, math.radians(mult * 25), 0))
        abf.set_object_material(wing_mem1, mat_wings)
        parts.append(wing_mem1)

        # Asa Inferior Secundária
        wing_spar2 = abf.add_primitive("cylinder", f"Azaroth_WingSub_Spar_{side}", location=(mult * 1.4, 0.7, 4.4), scale=(0.2, 0.2, 1.8), rotation=(0, math.radians(mult * 45), math.radians(mult * -20)))
        abf.set_object_material(wing_spar2, mat_horns)
        parts.append(wing_spar2)

        wing_mem2 = abf.add_primitive("cube", f"Azaroth_WingSub_Mem_{side}", location=(mult * 2.4, 0.8, 4.2), scale=(1.5, 0.05, 1.2), rotation=(0, math.radians(mult * 15), 0))
        abf.set_object_material(wing_mem2, mat_wings)
        parts.append(wing_mem2)

    # 3.9. Pernas, Cascos e Cauda
    for side, mult in [("L", -1), ("R", 1)]:
        thigh = abf.add_primitive("cylinder", f"Azaroth_Thigh_{side}", location=(mult * 0.8, 0, 2.4), scale=(0.65, 0.65, 1.2), vertices=10)
        abf.set_object_material(thigh, mat_skin)
        parts.append(thigh)

        shin = abf.add_primitive("cylinder", f"Azaroth_Shin_{side}", location=(mult * 0.85, 0.1, 1.3), scale=(0.55, 0.55, 1.2), vertices=10)
        abf.set_object_material(shin, mat_armor)
        parts.append(shin)

        hoof = abf.add_primitive("cube", f"Azaroth_Hoof_{side}", location=(mult * 0.9, -0.1, 0.3), scale=(0.7, 0.9, 0.6))
        abf.set_object_material(hoof, mat_horns)
        parts.append(hoof)

    # Cauda Farpada com espigão terminal
    for t_idx, (t_y, t_z) in enumerate([(0.8, 2.6), (1.4, 2.0), (2.0, 1.3), (2.5, 0.7)]):
        tail_seg = abf.add_primitive("cylinder", f"Azaroth_Tail_Seg_{t_idx}", location=(0, t_y, t_z), scale=(0.35 - t_idx * 0.06, 0.35 - t_idx * 0.06, 0.6), rotation=(math.radians(35), 0, 0))
        abf.set_object_material(tail_seg, mat_skin)
        parts.append(tail_seg)

    tail_spike = abf.add_primitive("cone", "Azaroth_Tail_Spike", location=(0, 2.9, 0.4), scale=(0.25, 0.25, 0.8), rotation=(math.radians(65), 0, 0))
    abf.set_object_material(tail_spike, mat_horns)
    parts.append(tail_spike)

    # Consolidar Malha Principal de Azaroth
    print(f"-> Unindo {len(parts)} componentes anatômicos de Azaroth...")
    azaroth_mesh = abf.join_mesh_objects(parts, "Azaroth_Mesh")

    # 4. Criação do Esqueleto / Armature
    print("-> Construindo Armature e Rig de Azaroth...")
    arm_obj = abf.create_armature("Azaroth_Armature")
    bone_defs = [
        {"name": "Root", "head": (0, 0, 0), "tail": (0, 0, 0.5), "parent": None},
        {"name": "Pelvis", "head": (0, 0, 3.0), "tail": (0, 0, 3.5), "parent": "Root"},
        {"name": "Spine", "head": (0, 0, 3.5), "tail": (0, 0, 4.4), "parent": "Pelvis"},
        {"name": "Chest", "head": (0, 0, 4.4), "tail": (0, 0, 5.4), "parent": "Spine"},
        {"name": "Neck", "head": (0, 0, 5.4), "tail": (0, 0, 5.9), "parent": "Chest"},
        {"name": "Head", "head": (0, -0.1, 5.9), "tail": (0, -0.3, 6.8), "parent": "Neck"},
        {"name": "Tail_01", "head": (0, 0.5, 3.0), "tail": (0, 1.2, 2.3), "parent": "Pelvis"},
        {"name": "Tail_02", "head": (0, 1.2, 2.3), "tail": (0, 2.4, 0.9), "parent": "Tail_01"},
        # Braço Esquerdo
        {"name": "Shoulder_L", "head": (-0.8, 0, 5.1), "tail": (-1.6, 0, 4.9), "parent": "Chest"},
        {"name": "Arm_L", "head": (-1.6, 0, 4.9), "tail": (-2.0, -0.1, 3.2), "parent": "Shoulder_L"},
        {"name": "Forearm_L", "head": (-2.0, -0.1, 3.2), "tail": (-2.1, -0.3, 1.8), "parent": "Arm_L"},
        # Braço Direito
        {"name": "Shoulder_R", "head": (0.8, 0, 5.1), "tail": (1.6, 0, 4.9), "parent": "Chest"},
        {"name": "Arm_R", "head": (1.6, 0, 4.9), "tail": (2.0, -0.1, 3.2), "parent": "Shoulder_R"},
        {"name": "Forearm_R", "head": (2.0, -0.1, 3.2), "tail": (2.1, -0.3, 1.8), "parent": "Arm_R"},
        # Asas Principais
        {"name": "WingBase_L", "head": (-0.6, 0.6, 5.2), "tail": (-2.2, 0.9, 6.4), "parent": "Chest"},
        {"name": "WingTip_L", "head": (-2.2, 0.9, 6.4), "tail": (-4.5, 1.1, 7.5), "parent": "WingBase_L"},
        {"name": "WingBase_R", "head": (0.6, 0.6, 5.2), "tail": (2.2, 0.9, 6.4), "parent": "Chest"},
        {"name": "WingTip_R", "head": (2.2, 0.9, 6.4), "tail": (4.5, 1.1, 7.5), "parent": "WingBase_R"},
        # Pernas
        {"name": "Thigh_L", "head": (-0.7, 0, 3.0), "tail": (-0.8, 0.1, 1.5), "parent": "Pelvis"},
        {"name": "Shin_L", "head": (-0.8, 0.1, 1.5), "tail": (-0.9, -0.1, 0.2), "parent": "Thigh_L"},
        {"name": "Thigh_R", "head": (0.7, 0, 3.0), "tail": (0.8, 0.1, 1.5), "parent": "Pelvis"},
        {"name": "Shin_R", "head": (0.8, 0.1, 1.5), "tail": (0.9, -0.1, 0.2), "parent": "Thigh_R"},
    ]
    abf.add_bone_hierarchy(arm_obj, bone_defs)

    # 5. Vinculação da Malha à Armature
    print("-> Vinculando malha ao esqueleto e aplicando pesos...")
    abf.bind_mesh_to_armature(azaroth_mesh, arm_obj)

    # 6. Criação de Ações / Animações de Azaroth
    print("-> Gerando suíte de 6 animações canônicas de Azaroth...")
    # 6.1. IDLE (Loop de respiração pesada e movimento de asas)
    idle_keys = [
        ("Chest", "location", 1, (0, 0, 0)),
        ("Chest", "location", 12, (0, 0, 0.08)),
        ("Chest", "location", 24, (0, 0, 0)),
        ("WingBase_L", "rotation_euler", 1, (0, 0, 0)),
        ("WingBase_L", "rotation_euler", 12, (math.radians(-8), math.radians(10), 0)),
        ("WingBase_L", "rotation_euler", 24, (0, 0, 0)),
        ("WingBase_R", "rotation_euler", 1, (0, 0, 0)),
        ("WingBase_R", "rotation_euler", 12, (math.radians(-8), math.radians(-10), 0)),
        ("WingBase_R", "rotation_euler", 24, (0, 0, 0)),
        ("Head", "rotation_euler", 1, (0, 0, 0)),
        ("Head", "rotation_euler", 12, (math.radians(4), 0, 0)),
        ("Head", "rotation_euler", 24, (0, 0, 0)),
    ]
    abf.create_bone_action(arm_obj, "idle", idle_keys, total_frames=24)

    # 6.2. WALK (Passos colossais)
    walk_keys = [
        ("Thigh_L", "rotation_euler", 1, (math.radians(20), 0, 0)),
        ("Thigh_L", "rotation_euler", 12, (math.radians(-20), 0, 0)),
        ("Thigh_L", "rotation_euler", 24, (math.radians(20), 0, 0)),
        ("Thigh_R", "rotation_euler", 1, (math.radians(-20), 0, 0)),
        ("Thigh_R", "rotation_euler", 12, (math.radians(20), 0, 0)),
        ("Thigh_R", "rotation_euler", 24, (math.radians(-20), 0, 0)),
        ("Chest", "rotation_euler", 1, (0, 0, math.radians(-4))),
        ("Chest", "rotation_euler", 12, (0, 0, math.radians(4))),
        ("Chest", "rotation_euler", 24, (0, 0, math.radians(-4))),
    ]
    abf.create_bone_action(arm_obj, "walk", walk_keys, total_frames=24)

    # 6.3. ATTACK_SLASH (Varredura com garra)
    slash_keys = [
        ("Arm_R", "rotation_euler", 1, (0, 0, 0)),
        ("Arm_R", "rotation_euler", 8, (math.radians(-45), math.radians(60), math.radians(30))),
        ("Arm_R", "rotation_euler", 16, (math.radians(60), math.radians(-50), math.radians(-20))),
        ("Arm_R", "rotation_euler", 24, (0, 0, 0)),
    ]
    abf.create_bone_action(arm_obj, "attack_slash", slash_keys, total_frames=24)

    # 6.4. ATTACK_BREATH (Sopro Apocalíptico de Chamas)
    breath_keys = [
        ("Chest", "rotation_euler", 1, (0, 0, 0)),
        ("Chest", "rotation_euler", 8, (math.radians(-25), 0, 0)),
        ("Head", "rotation_euler", 8, (math.radians(-35), 0, 0)),
        ("Chest", "rotation_euler", 16, (math.radians(20), 0, 0)),
        ("Head", "rotation_euler", 16, (math.radians(25), 0, 0)),
        ("Chest", "rotation_euler", 24, (0, 0, 0)),
        ("Head", "rotation_euler", 24, (0, 0, 0)),
    ]
    abf.create_bone_action(arm_obj, "attack_breath", breath_keys, total_frames=24)

    # 6.5. PHASE_TRANSITION (Rugido e expansão do Escudo Abissal)
    phase_keys = [
        ("WingBase_L", "rotation_euler", 1, (0, 0, 0)),
        ("WingBase_L", "rotation_euler", 10, (math.radians(45), math.radians(30), 0)),
        ("WingBase_L", "rotation_euler", 16, (math.radians(-40), math.radians(-50), 0)),
        ("WingBase_L", "rotation_euler", 24, (0, 0, 0)),
        ("WingBase_R", "rotation_euler", 1, (0, 0, 0)),
        ("WingBase_R", "rotation_euler", 10, (math.radians(45), math.radians(-30), 0)),
        ("WingBase_R", "rotation_euler", 16, (math.radians(-40), math.radians(50), 0)),
        ("WingBase_R", "rotation_euler", 24, (0, 0, 0)),
    ]
    abf.create_bone_action(arm_obj, "phase_transition", phase_keys, total_frames=24)

    # 6.6. DEATH (Queda de joelhos e colapso)
    death_keys = [
        ("Pelvis", "location", 1, (0, 0, 0)),
        ("Pelvis", "location", 14, (0, 0, -1.2)),
        ("Pelvis", "location", 24, (0, 0, -2.5)),
        ("Chest", "rotation_euler", 1, (0, 0, 0)),
        ("Chest", "rotation_euler", 24, (math.radians(65), 0, 0)),
    ]
    abf.create_bone_action(arm_obj, "death", death_keys, total_frames=24)

    # 7. Iluminação de Estúdio e Câmera
    print("-> Posicionando iluminação de estúdio trifásica e câmera...")
    abf.setup_studio_rig(target_center=(0, 0, 4.5), distance=11.0, elevation=4.0, key_power=1200.0, rim_color="#ff3300")

    # 8. Salvamento do Arquivo .blend Diretamente nas Pastas do Jogo
    blend_path = os.path.join(abf.BLENDER_ASSETS_DIR, "bosses", "azaroth_world_boss.blend")
    abf.save_blend_project(blend_path)

    # 9. Renderização do Preview PNG
    preview_path = os.path.join(abf.PREVIEWS_DIR, "bosses", "azaroth_world_boss.png")
    abf.render_preview_image(preview_path)

    # 10. Exportação do GLB para a Godot 4
    glb_path = os.path.join(abf.MODELS_EXPORT_DIR, "bosses", "azaroth_world_boss.glb")
    abf.export_glb_model(glb_path, include_animations=True)

    # 11. Estatísticas Finais
    stats = abf.inspect_scene_stats()
    print("======================================================================")
    print("AZAROTH WORLD BOSS GERADO COM SUCESSO!")
    print(f"- Vértices: {stats['total_vertices']} | Polígonos: {stats['total_polygons']}")
    print(f"- Ossos de Deformação: {stats['bones_count']} ossos")
    print(f"- Animações Embutidas: {len(stats['animations'])} ({', '.join(stats['animations'])})")
    print(f"- Materiais PBR: {len(stats['materials'])} ({', '.join(stats['materials'])})")
    print(f"- Arquivo Blend: {blend_path}")
    print(f"- Preview Render: {preview_path}")
    print(f"- Export GLB: {glb_path}")
    print("======================================================================")
    return True

if __name__ == "__main__":
    build_azaroth()
