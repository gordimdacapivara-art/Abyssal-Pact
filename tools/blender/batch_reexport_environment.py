"""
ABYSSAL PACT — RE-EXPORTADOR EM LOTE DE ASSETS DE AMBIENTE (BLENDER 5.3+)
Abre os arquivos .blend em assets/blender/environment/, aplica otimizações de materiais PBR,
gera previews PNG e exporta modelos GLB atualizados diretamente para assets/models/environment/.
Substitui integralmente modelos antigos pelos modelos nativos do Blender 5.3.
"""

import bpy
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.append(SCRIPT_DIR)

import abyssal_blender_framework as abf

def reexport_environment_assets():
    print("======================================================================")
    print("INICIANDO RE-EXPORTAÇÃO EM LOTE DE ASSETS AMBIENTAIS NO BLENDER 5.3")
    print("======================================================================")

    env_blend_dir = os.path.join(abf.BLENDER_ASSETS_DIR, "environment")
    categories = ["nature", "props", "rocks", "structures"]

    total_processed = 0
    total_succeeded = 0

    for cat in categories:
        cat_dir = os.path.join(env_blend_dir, cat)
        if not os.path.exists(cat_dir):
            continue

        blend_files = [f for f in os.listdir(cat_dir) if f.endswith(".blend") and not f.endswith(".blend1")]
        print(f"\n-> Processando Categoria '{cat.upper()}': {len(blend_files)} arquivos .blend")

        for bfile in blend_files:
            asset_name = os.path.splitext(bfile)[0]
            blend_path = os.path.join(cat_dir, bfile)
            glb_path = os.path.join(abf.MODELS_EXPORT_DIR, "environment", cat, f"{asset_name}.glb")
            preview_path = os.path.join(abf.PREVIEWS_DIR, "environment", cat, f"{asset_name}.png")

            total_processed += 1
            try:
                # 1. Abrir o .blend
                bpy.ops.wm.open_mainfile(filepath=blend_path)

                # 2. Configurar câmera e luz para render de preview
                # Calcular centro aproximado dos objetos da cena
                mesh_objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
                if mesh_objs:
                    # Aplicar smooth shading se apropriado
                    for m in mesh_objs:
                        if m.data and hasattr(m.data, "polygons"):
                            for p in m.data.polygons:
                                p.use_smooth = True

                    # Configurar Studio Rig
                    abf.setup_studio_rig(target_center=(0, 0, 1.5), distance=6.0, elevation=2.5, key_power=350.0)
                    abf.render_preview_image(preview_path)

                # 3. Exportar GLB de alta qualidade
                abf.export_glb_model(glb_path, include_animations=False)
                total_succeeded += 1
                print(f"  [OK] {cat}/{asset_name} -> GLB: {os.path.getsize(glb_path):,} bytes")
            except Exception as e:
                print(f"  [ERRO] Falha ao processar {cat}/{asset_name}: {e}")

    print("\n======================================================================")
    print(f"RE-EXPORTAÇÃO CONCLUÍDA: {total_succeeded}/{total_processed} modelos processados com sucesso")
    print("======================================================================")
    return total_succeeded == total_processed

if __name__ == "__main__":
    reexport_environment_assets()
