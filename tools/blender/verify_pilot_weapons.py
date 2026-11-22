"""
ABYSSAL PACT — VERIFICAÇÃO DE INTEGRIDADE DAS 5 ARMAS-PILOTO NO BLENDER 5.3
"""

import bpy
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))

PILOT_WEAPONS = [
    {
        "id": "WEP-001",
        "name": "Espada das Cinzas",
        "folder": "swords",
        "filename": "WEAPON_001_Espada_das_Cinzas",
        "category": "Espadas",
        "expected_sockets": ["socket_hand_r", "socket_back"]
    },
    {
        "id": "WEP-011",
        "name": "Machado Rúnico de Basalto",
        "folder": "axes",
        "filename": "WEAPON_011_Machado_Runico_de_Basalto",
        "category": "Machados",
        "expected_sockets": ["socket_hand_r", "socket_back"]
    },
    {
        "id": "WEP-021",
        "name": "Martelo Colossal da Forja",
        "folder": "hammers_maces",
        "filename": "WEAPON_021_Martelo_Colossal_da_Forja",
        "category": "Martelos e maças",
        "expected_sockets": ["socket_hand_r", "socket_back"]
    },
    {
        "id": "WEP-031",
        "name": "Lança das Cinzas Abissais",
        "folder": "polearms",
        "filename": "WEAPON_031_Lanca_das_Cinzas_Abissais",
        "category": "Lanças e armas de haste",
        "expected_sockets": ["socket_hand_r", "socket_back"]
    },
    {
        "id": "WEP-091",
        "name": "Escudo Torre de Ferro Negro",
        "folder": "shields",
        "filename": "WEAPON_091_Escudo_Torre_de_Ferro_Negro",
        "category": "Escudos e defensivos",
        "expected_sockets": ["socket_hand_l", "socket_back"]
    }
]

print("=" * 70)
print("AUDITORIA TÉCNICA DAS 5 ARMAS-PILOTO NO BLENDER 5.3")
print("=" * 70)

total_checks = 0
passed_checks = 0

for wep in PILOT_WEAPONS:
    print(f"\n-> Auditando {wep['id']}: {wep['name']} ({wep['category']})")
    blend_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", wep["folder"], wep["filename"] + ".blend")
    glb_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", wep["folder"], wep["filename"] + ".glb")
    preview_path = os.path.join(PROJECT_DIR, "assets", "3d", "weapons", "previews", wep["filename"] + ".png")

    # 1. Arquivos existem
    for path, desc in [(blend_path, ".blend"), (glb_path, ".glb"), (preview_path, ".png")]:
        total_checks += 1
        if os.path.exists(path) and os.path.getsize(path) > 0:
            print(f"  [PASS] Arquivo {desc} existe: {os.path.basename(path)} ({os.path.getsize(path):,} bytes)")
            passed_checks += 1
        else:
            print(f"  [FAIL] Arquivo {desc} ausente ou vazio: {path}")

    # 2. Ler .blend
    total_checks += 1
    try:
        bpy.ops.wm.open_mainfile(filepath=blend_path)
        print("  [PASS] Arquivo .blend aberto com sucesso no Blender 5.3")
        passed_checks += 1
    except Exception as e:
        print(f"  [FAIL] Erro ao abrir .blend: {e}")
        continue

    # 3. Malhas
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    total_checks += 1
    if len(meshes) > 0:
        verts = sum(len(m.data.vertices) for m in meshes)
        polys = sum(len(m.data.polygons) for m in meshes)
        print(f"  [PASS] Malhas 3D válidas: {len(meshes)} objetos, {verts} vértices, {polys} polígonos")
        passed_checks += 1
    else:
        print("  [FAIL] Nenhuma malha 3D encontrada na cena")

    # 4. Materiais
    mats = list(bpy.data.materials)
    total_checks += 1
    if len(mats) > 0:
        print(f"  [PASS] Materiais PBR configurados: {len(mats)} ({', '.join(m.name for m in mats[:3])})")
        passed_checks += 1
    else:
        print("  [FAIL] Nenhum material configurado")

    # 5. Sockets
    empties = [o.name for o in bpy.context.scene.objects if o.type == "EMPTY"]
    for s in wep["expected_sockets"]:
        total_checks += 1
        if s in empties:
            print(f"  [PASS] Socket de personagem configurado: '{s}'")
            passed_checks += 1
        else:
            print(f"  [FAIL] Socket ausente: '{s}'")

print("\n" + "=" * 70)
print(f"TOTAL: {passed_checks}/{total_checks} verificações aprovadas ({total_checks - passed_checks} falhas)")
print("=" * 70)
