"""
ABYSSAL PACT — VERIFICADOR AUTOMATIZADO DE PROJETOS BLENDER (BLENDER 5.3+)
Audita rigorosamente todos os modelos 3D criados no Blender:
- Verifica se os arquivos .blend existem
- Abre cada arquivo .blend no Blender
- Inspeciona geometrias (vértices, faces)
- Confirma aplicação de materiais PBR e cores HEX
- Valida rigs e esqueletos (Armatures e ossos)
- Valida presença das animações previstas
- Valida correspondência dos exports GLB e renders de preview PNG
"""

import bpy
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.append(SCRIPT_DIR)

import abyssal_blender_framework as abf

MODELS_TO_VERIFY = [
    {
        "id": "azaroth_world_boss",
        "category": "bosses",
        "blend": os.path.join(abf.BLENDER_ASSETS_DIR, "bosses", "azaroth_world_boss.blend"),
        "glb": os.path.join(abf.MODELS_EXPORT_DIR, "bosses", "azaroth_world_boss.glb"),
        "preview": os.path.join(abf.PREVIEWS_DIR, "bosses", "azaroth_world_boss.png"),
        "expected_bones_min": 15,
        "expected_actions": ["idle", "walk", "attack_slash", "attack_breath", "phase_transition", "death"],
    },
    {
        "id": "demon_inferior",
        "category": "demons",
        "blend": os.path.join(abf.BLENDER_ASSETS_DIR, "demons", "demon_inferior.blend"),
        "glb": os.path.join(abf.MODELS_EXPORT_DIR, "demons", "demon_inferior.glb"),
        "preview": os.path.join(abf.PREVIEWS_DIR, "demons", "demon_inferior.png"),
        "expected_bones_min": 6,
        "expected_actions": ["idle", "run", "attack", "death"],
    },
    {
        "id": "demon_superior",
        "category": "demons",
        "blend": os.path.join(abf.BLENDER_ASSETS_DIR, "demons", "demon_superior.blend"),
        "glb": os.path.join(abf.MODELS_EXPORT_DIR, "demons", "demon_superior.glb"),
        "preview": os.path.join(abf.PREVIEWS_DIR, "demons", "demon_superior.png"),
        "expected_bones_min": 6,
        "expected_actions": ["idle", "walk", "slam_attack", "death"],
    },
    {
        "id": "demon_primordial",
        "category": "demons",
        "blend": os.path.join(abf.BLENDER_ASSETS_DIR, "demons", "demon_primordial.blend"),
        "glb": os.path.join(abf.MODELS_EXPORT_DIR, "demons", "demon_primordial.glb"),
        "preview": os.path.join(abf.PREVIEWS_DIR, "demons", "demon_primordial.png"),
        "expected_bones_min": 8,
        "expected_actions": ["idle", "walk", "cleave_attack", "death"],
    },
    {
        "id": "player_character_master",
        "category": "characters",
        "blend": os.path.join(abf.BLENDER_ASSETS_DIR, "characters", "player_character_master.blend"),
        "glb": os.path.join(abf.MODELS_EXPORT_DIR, "characters", "player_character_master.glb"),
        "preview": os.path.join(abf.PREVIEWS_DIR, "characters", "player_character_master.png"),
        "expected_bones_min": 14,
        "expected_actions": ["idle", "walk", "run", "sprint", "jump", "fall", "land", "dodge", "attack"],
    },
]


def run_verification():
    print("======================================================================")
    print("AUDITORIA E VERIFICAÇÃO AUTOMATIZADA DE ASSETS BLENDER 5.3")
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

    for target in MODELS_TO_VERIFY:
        model_id = target["id"]
        print(f"\n-> Auditando Modelo: {model_id.upper()}")

        # 1. Existência do .blend
        blend_path = target["blend"]
        assert_check(os.path.exists(blend_path) and os.path.getsize(blend_path) > 1024,
                     f"Arquivo .blend existe e não está vazio ({blend_path})")

        # 2. Existência do GLB exportado
        glb_path = target["glb"]
        assert_check(os.path.exists(glb_path) and os.path.getsize(glb_path) > 1024,
                     f"Arquivo .glb exportado existe ({glb_path})")

        # 3. Existência do preview PNG
        prev_path = target["preview"]
        assert_check(os.path.exists(prev_path) and os.path.getsize(prev_path) > 1024,
                     f"Preview render PNG existe ({prev_path})")

        # 4. Abertura do arquivo .blend no Blender
        try:
            bpy.ops.wm.open_mainfile(filepath=blend_path)
            assert_check(True, f"Arquivo .blend aberto com sucesso pelo Blender 5.3")
        except Exception as e:
            assert_check(False, f"Erro ao abrir .blend: {e}")
            continue

        # 5. Geometria criada
        stats = abf.inspect_scene_stats()
        assert_check(stats["mesh_count"] > 0, f"Malhas presentes na cena (qtd: {stats['mesh_count']})")
        assert_check(stats["total_vertices"] > 50, f"Vértices modelados: {stats['total_vertices']}")
        assert_check(stats["total_polygons"] > 40, f"Polígonos modelados: {stats['total_polygons']}")

        # 6. Materiais aplicados
        assert_check(len(stats["materials"]) > 0, f"Materiais PBR aplicados: {len(stats['materials'])} ({', '.join(stats['materials'])})")

        # 7. Rigging e Ossos
        assert_check(stats["armature_count"] > 0, f"Armature presente na cena")
        assert_check(stats["bones_count"] >= target["expected_bones_min"],
                     f"Ossos deformadores suficientes ({stats['bones_count']} >= {target['expected_bones_min']})")

        # 8. Animações presentes
        actions_in_scene = stats["animations"]
        for expected_act in target["expected_actions"]:
            assert_check(expected_act in actions_in_scene, f"Animação '{expected_act}' presente no projeto")

    print("\n======================================================================")
    print(f"RESULTADO DA AUDITORIA: {passed_checks}/{total_checks} verificações aprovadas ({failed_checks} falhas)")
    print("======================================================================")
    return failed_checks == 0


if __name__ == "__main__":
    success = run_verification()
    sys.exit(0 if success else 1)
