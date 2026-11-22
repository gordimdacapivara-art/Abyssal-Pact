"""
ABYSSAL PACT — VERIFICADOR DE INTEGRIDADE DOS 5 MODELOS-PILOTO
Inspeciona os projetos .blend gerados para garantir abertura limpa, malha, materiais, rigs e animações.
"""

import bpy
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.append(SCRIPT_DIR)

import abyssal_blender_framework as abf

PILOTS = [
    {
        "id": "MONSTER_001",
        "name": "Ogro das Cinzas",
        "family": "Humanoids",
        "blend": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Humanoids", "MONSTER_001_Ogro_das_Cinzas.blend"),
        "glb": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Humanoids", "MONSTER_001_Ogro_das_Cinzas.glb"),
        "preview": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Previews", "MONSTER_001_Ogro_das_Cinzas.png"),
        "expected_bones": 10,
        "expected_actions": ["idle", "attack_smash"],
    },
    {
        "id": "MONSTER_041",
        "name": "Lobo do Gelo Eterno",
        "family": "Beasts",
        "blend": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Beasts", "MONSTER_041_Lobo_do_Gelo_Eterno.blend"),
        "glb": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Beasts", "MONSTER_041_Lobo_do_Gelo_Eterno.glb"),
        "preview": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Previews", "MONSTER_041_Lobo_do_Gelo_Eterno.png"),
        "expected_bones": 10,
        "expected_actions": ["idle", "run"],
    },
    {
        "id": "MONSTER_081",
        "name": "Draconiano Vulcânico",
        "family": "Reptiles_Dragons",
        "blend": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Reptiles_Dragons", "MONSTER_081_Draconiano_Vulcanico.blend"),
        "glb": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Reptiles_Dragons", "MONSTER_081_Draconiano_Vulcanico.glb"),
        "preview": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Previews", "MONSTER_081_Draconiano_Vulcanico.png"),
        "expected_bones": 10,
        "expected_actions": ["idle", "fire_breath"],
    },
    {
        "id": "MONSTER_111",
        "name": "Cavaleiro Espectral da Cripta",
        "family": "Undead",
        "blend": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Undead", "MONSTER_111_Cavaleiro_Espectral_da_Cripta.blend"),
        "glb": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Undead", "MONSTER_111_Cavaleiro_Espectral_da_Cripta.glb"),
        "preview": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Previews", "MONSTER_111_Cavaleiro_Espectral_da_Cripta.png"),
        "expected_bones": 8,
        "expected_actions": ["idle", "spectral_slash"],
    },
    {
        "id": "MONSTER_211",
        "name": "Golem de Cristal Arcano",
        "family": "Magical_Elementals",
        "blend": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Magical_Elementals", "MONSTER_211_Golem_de_Cristal_Arcano.blend"),
        "glb": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Magical_Elementals", "MONSTER_211_Golem_de_Cristal_Arcano.glb"),
        "preview": os.path.join(abf.PROJECT_DIR, "assets", "3d", "monsters", "Previews", "MONSTER_211_Golem_de_Cristal_Arcano.png"),
        "expected_bones": 6,
        "expected_actions": ["idle", "slam"],
    },
]

def verify_pilots():
    print("======================================================================")
    print("VERIFICAÇÃO DE INTEGRIDADE DOS 5 MODELOS-PILOTO NO BLENDER 5.3")
    print("======================================================================")

    total_checks = 0
    passed_checks = 0
    failed_checks = 0

    def assert_check(condition, msg):
        nonlocal total_checks, passed_checks, failed_checks
        total_checks += 1
        if condition:
            passed_checks += 1
            print(f"  [PASS] {msg}")
        else:
            failed_checks += 1
            print(f"  [FAIL] {msg}")

    for pilot in PILOTS:
        p_id = pilot["id"]
        p_name = pilot["name"]
        print(f"\n-> Auditando {p_id}: {p_name}")

        # 1. Checagem de existência dos arquivos
        assert_check(os.path.exists(pilot["blend"]) and os.path.getsize(pilot["blend"]) > 1024,
                     f"Projeto .blend existe e não está vazio ({os.path.basename(pilot['blend'])})")
        assert_check(os.path.exists(pilot["glb"]) and os.path.getsize(pilot["glb"]) > 1024,
                     f"Modelo .glb exportado existe ({os.path.basename(pilot['glb'])})")
        assert_check(os.path.exists(pilot["preview"]) and os.path.getsize(pilot["preview"]) > 1024,
                     f"Preview .png renderizado existe ({os.path.basename(pilot['preview'])})")

        # 2. Abertura do projeto no Blender
        try:
            bpy.ops.wm.open_mainfile(filepath=pilot["blend"])
            assert_check(True, f"Arquivo .blend aberto com sucesso no Blender 5.3")
        except Exception as e:
            assert_check(False, f"Falha ao abrir .blend: {e}")
            continue

        # 3. Estatísticas da malha
        stats = abf.inspect_scene_stats()
        assert_check(stats["mesh_count"] > 0, f"Malhas presentes: {stats['mesh_count']}")
        assert_check(stats["total_vertices"] > 50, f"Vértices: {stats['total_vertices']}")
        assert_check(stats["total_polygons"] > 40, f"Polígonos: {stats['total_polygons']}")
        assert_check(len(stats["materials"]) > 0, f"Materiais PBR aplicados: {len(stats['materials'])}")

        # 4. Rigging e Ossos
        assert_check(stats["armature_count"] > 0, "Armature presente")
        assert_check(stats["bones_count"] >= pilot["expected_bones"],
                     f"Ossos deformadores ({stats['bones_count']} >= {pilot['expected_bones']})")

        # 5. Animações
        for act in pilot["expected_actions"]:
            assert_check(act in stats["animations"], f"Ação de animação presente: '{act}'")

    print("\n======================================================================")
    print(f"TOTAL: {passed_checks}/{total_checks} verificações aprovadas ({failed_checks} falhas)")
    print("======================================================================")
    return failed_checks == 0

if __name__ == "__main__":
    success = verify_pilots()
    sys.exit(0 if success else 1)
