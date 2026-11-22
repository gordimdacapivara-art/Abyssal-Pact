"""
ABYSSAL PACT — FRAMEWORK DE INTEGRAÇÃO E AUTOMAÇÃO COM BLENDER
Modulo Python canônico para automação headless e interativa via API bpy no Blender 5.3+.

Capacidades:
1. Limpeza e configuração de cena (unidades métricas, 24/60 fps, gerenciamento de cor).
2. Materiais PBR via conversão de cores HEX para Linear sRGB, suporte a emissão abissal e shaders avançados.
3. Modelagem procedural com anatomia precisa, quads, bevels e modificadores não destrutivos.
4. Criação de armatures/esqueletos, rigs deformadores e mapeamento de grupos de vértices.
5. Sistema de animações e NLA tracks com interpolação de poses e loops precisos.
6. Iluminação de estúdio trifásica (Key, Fill, Rim) e câmera orbital para pré-visualização.
7. Renderizador de miniaturas/previews em PNG de alta resolução.
8. Salvamento direto de projetos .blend dentro da estrutura de pastas do Abyssal Pact.
9. Exportação otimizada glTF 2.0 (.glb) com compressão e suporte a animações para Godot 4.
"""

import bpy
import math
import os
import sys
from mathutils import Vector, Euler, Matrix

# ==============================================================================
# 1. CONSTANTES E GERENCIAMENTO DE CAMINHOS
# ==============================================================================
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))

BLENDER_ASSETS_DIR = os.path.join(PROJECT_DIR, "assets", "blender")
MODELS_EXPORT_DIR = os.path.join(PROJECT_DIR, "assets", "models")
PREVIEWS_DIR = os.path.join(PROJECT_DIR, "assets", "previews")

for directory in [
    os.path.join(BLENDER_ASSETS_DIR, "bosses"),
    os.path.join(BLENDER_ASSETS_DIR, "demons"),
    os.path.join(BLENDER_ASSETS_DIR, "characters"),
    os.path.join(BLENDER_ASSETS_DIR, "environment"),
    os.path.join(MODELS_EXPORT_DIR, "bosses"),
    os.path.join(MODELS_EXPORT_DIR, "demons"),
    os.path.join(MODELS_EXPORT_DIR, "characters"),
    os.path.join(MODELS_EXPORT_DIR, "environment"),
    os.path.join(PREVIEWS_DIR, "bosses"),
    os.path.join(PREVIEWS_DIR, "demons"),
    os.path.join(PREVIEWS_DIR, "characters"),
    os.path.join(PREVIEWS_DIR, "environment"),
]:
    os.makedirs(directory, exist_ok=True)


# ==============================================================================
# 2. CONVERSÃO DE CORES E MATERIAIS PBR
# ==============================================================================
def hex_to_linear_rgb(hex_str):
    """Converte string HEX ('#RRGGBB' ou 'RRGGBB') para tupla Linear sRGB (R, G, B, A)."""
    h = hex_str.lstrip("#")
    if len(h) == 6:
        r = int(h[0:2], 16) / 255.0
        g = int(h[2:4], 16) / 255.0
        b = int(h[4:6], 16) / 255.0
    elif len(h) == 3:
        r = int(h[0] * 2, 16) / 255.0
        g = int(h[1] * 2, 16) / 255.0
        b = int(h[2] * 2, 16) / 255.0
    else:
        return (0.8, 0.8, 0.8, 1.0)

    # Conversão de sRGB para espaço linear para fidelidade PBR no Blender
    def srgb_to_linear(c):
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    return (srgb_to_linear(r), srgb_to_linear(g), srgb_to_linear(b), 1.0)


def create_pbr_material(name, hex_color, roughness=0.6, metallic=0.0, emission_hex=None, emission_strength=1.0):
    """Cria ou recupera um material PBR Principled BSDF com cores HEX e emissão."""
    mat = bpy.data.materials.get(name)
    if mat is None:
        mat = bpy.data.materials.new(name=name)
    
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    nodes.clear()

    output_node = nodes.new(type="ShaderNodeOutputMaterial")
    output_node.location = (400, 0)

    bsdf = nodes.new(type="ShaderNodeBsdfPrincipled")
    bsdf.location = (0, 0)

    # Cor base
    base_rgba = hex_to_linear_rgb(hex_color)
    for col_input in ("Base Color", "BaseColor"):
        if col_input in bsdf.inputs:
            bsdf.inputs[col_input].default_value = base_rgba
            break

    # Rugosidade e Metalicidade
    if "Roughness" in bsdf.inputs:
        bsdf.inputs["Roughness"].default_value = float(roughness)
    if "Metallic" in bsdf.inputs:
        bsdf.inputs["Metallic"].default_value = float(metallic)

    # Emissão
    if emission_hex:
        em_rgba = hex_to_linear_rgb(emission_hex)
        for em_input in ("Emission Color", "Emission"):
            if em_input in bsdf.inputs:
                bsdf.inputs[em_input].default_value = em_rgba
                break
        if "Emission Strength" in bsdf.inputs:
            bsdf.inputs["Emission Strength"].default_value = float(emission_strength)

    # Conectar ao Output
    mat.node_tree.links.new(bsdf.outputs["BSDF"], output_node.inputs["Surface"])
    return mat


def set_object_material(obj, mat):
    """Aplica o material ao objeto, limpando slots prévios."""
    if obj.type == "MESH":
        obj.data.materials.clear()
        obj.data.materials.append(mat)


# ==============================================================================
# 3. GERENCIAMENTO DE CENA E GEOMETRIA
# ==============================================================================
def reset_scene(fps=24):
    """Limpa todos os objetos, malhas, materiais e ações da cena atual."""
    if bpy.ops.object.mode_set.poll():
        bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)

    for block in (
        bpy.data.meshes,
        bpy.data.armatures,
        bpy.data.materials,
        bpy.data.actions,
        bpy.data.cameras,
        bpy.data.lights,
        bpy.data.images
    ):
        for item in list(block):
            if item.users == 0:
                block.remove(item)

    scene = bpy.context.scene
    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 1.0
    scene.render.fps = fps
    return scene


def add_primitive(shape_type, name, location=(0, 0, 0), scale=(1, 1, 1), rotation=(0, 0, 0), **kwargs):
    """Adiciona uma primitiva 3D com transformações aplicadas e escala limpa."""
    if shape_type == "cube":
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=location, rotation=rotation)
    elif shape_type == "cylinder":
        vertices = kwargs.get("vertices", 16)
        radius = kwargs.get("radius", 0.5)
        depth = kwargs.get("depth", 1.0)
        bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=location, rotation=rotation)
    elif shape_type == "cone":
        vertices = kwargs.get("vertices", 16)
        radius1 = kwargs.get("radius1", 0.5)
        depth = kwargs.get("depth", 1.0)
        bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=radius1, depth=depth, location=location, rotation=rotation)
    elif shape_type == "uv_sphere":
        segments = kwargs.get("segments", 16)
        ring_count = kwargs.get("ring_count", 12)
        radius = kwargs.get("radius", 0.5)
        bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=ring_count, radius=radius, location=location, rotation=rotation)
    elif shape_type == "ico_sphere":
        subdivisions = kwargs.get("subdivisions", 2)
        radius = kwargs.get("radius", 0.5)
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=radius, location=location, rotation=rotation)
    
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = Vector(scale)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return obj


def join_mesh_objects(objects, joined_name):
    """Une múltiplos objetos de malha em um único objeto consolidado."""
    valid_objs = [o for o in objects if o and o.name in bpy.data.objects and o.type == "MESH"]
    if not valid_objs:
        return None
    if len(valid_objs) == 1:
        valid_objs[0].name = joined_name
        return valid_objs[0]

    bpy.ops.object.select_all(action="DESELECT")
    for obj in valid_objs:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = valid_objs[0]
    bpy.ops.object.join()
    joined = bpy.context.active_object
    joined.name = joined_name
    return joined


# ==============================================================================
# 4. SISTEMA DE RIGGING E ARMATURE
# ==============================================================================
def create_armature(armature_name):
    """Cria uma estrutura de armature no centro da cena."""
    arm_data = bpy.data.armatures.new(name=f"{armature_name}_Data")
    arm_obj = bpy.data.objects.new(name=armature_name, object_data=arm_data)
    bpy.context.scene.collection.objects.link(arm_obj)
    bpy.context.view_layer.objects.active = arm_obj
    return arm_obj


def add_bone_hierarchy(armature_obj, bone_definitions):
    """
    Adiciona ossos na armature em modo EDIT.
    bone_definitions: lista de tuplas/dicts:
    [{"name": "Root", "head": (0,0,0), "tail": (0,0,0.5), "parent": None}, ...]
    """
    bpy.context.view_layer.objects.active = armature_obj
    bpy.ops.object.mode_set(mode="EDIT")
    edit_bones = armature_obj.data.edit_bones

    created_bones = {}
    for bdef in bone_definitions:
        name = bdef["name"]
        bone = edit_bones.new(name)
        bone.head = Vector(bdef["head"])
        bone.tail = Vector(bdef["tail"])
        bone.use_connect = False
        created_bones[name] = bone

    for bdef in bone_definitions:
        name = bdef["name"]
        parent_name = bdef.get("parent")
        if parent_name and parent_name in edit_bones:
            edit_bones[name].parent = edit_bones[parent_name]

    bpy.ops.object.mode_set(mode="OBJECT")
    return armature_obj


def bind_mesh_to_armature(mesh_obj, armature_obj, vertex_weights=None):
    """
    Vincula malha ao esqueleto via modificador Armature e define pesos de vértices.
    vertex_weights: dict {bone_name: [list_of_vertex_indices]} ou peso por proximidade.
    """
    bpy.context.view_layer.objects.active = mesh_obj
    mod = mesh_obj.modifiers.new(name="ArmatureModifier", type="ARMATURE")
    mod.object = armature_obj
    mesh_obj.parent = armature_obj

    if vertex_weights:
        for bone_name, v_indices in vertex_weights.items():
            vg = mesh_obj.vertex_groups.get(bone_name)
            if not vg:
                vg = mesh_obj.vertex_groups.new(name=bone_name)
            if v_indices:
                vg.add(v_indices, 1.0, "REPLACE")
    else:
        # Ponderação automática baseada em distância do centro do osso
        for bone in armature_obj.data.bones:
            vg = mesh_obj.vertex_groups.get(bone.name)
            if not vg:
                vg = mesh_obj.vertex_groups.new(name=bone.name)
            
            bone_center = (bone.head_local + bone.tail_local) * 0.5
            bone_len = max(0.1, (bone.tail_local - bone.head_local).length)
            
            close_vertices = []
            for v in mesh_obj.data.vertices:
                dist = (v.co - bone_center).length
                if dist <= bone_len * 1.5:
                    close_vertices.append(v.index)
            
            if close_vertices:
                vg.add(close_vertices, 1.0, "REPLACE")
            else:
                vg.add([0], 0.01, "REPLACE")


# ==============================================================================
# 5. SISTEMA DE ANIMAÇÃO
# ==============================================================================
def create_bone_action(armature_obj, action_name, keyframe_tracks, total_frames=24):
    """
    Cria uma ação de animação para os ossos de pose da armature.
    keyframe_tracks: lista de tuplas: (bone_name, property_type, frame, value)
    property_type: 'rotation_euler', 'location', 'scale'
    """
    if armature_obj.animation_data is None:
        armature_obj.animation_data_create()

    action = bpy.data.actions.new(name=action_name)
    action.use_fake_user = True
    armature_obj.animation_data.action = action

    bpy.context.view_layer.objects.active = armature_obj
    bpy.ops.object.mode_set(mode="POSE")

    pose_bones = armature_obj.pose.bones
    for bone_name, prop_type, frame, value in keyframe_tracks:
        if bone_name in pose_bones:
            pb = pose_bones[bone_name]
            if prop_type == "rotation_euler":
                pb.rotation_euler = Euler(value, "XYZ")
                pb.keyframe_insert(data_path="rotation_euler", frame=frame)
            elif prop_type == "location":
                pb.location = Vector(value)
                pb.keyframe_insert(data_path="location", frame=frame)
            elif prop_type == "scale":
                pb.scale = Vector(value)
                pb.keyframe_insert(data_path="scale", frame=frame)

    bpy.ops.object.mode_set(mode="OBJECT")
    return action


# ==============================================================================
# 6. ILUMINAÇÃO, CÂMERA E RENDER DE PREVIEW
# ==============================================================================
def setup_studio_rig(target_center=(0, 0, 1.0), distance=5.0, elevation=2.0, key_power=300.0, rim_color="#ff4400"):
    """Configura iluminação trifásica profissional e câmera para renderização de preview."""
    # 1. Key Light (Luz Principal Suave e Quente)
    key_data = bpy.data.lights.new(name="Studio_KeyLight", type="AREA")
    key_data.energy = key_power
    key_data.size = 2.0
    key_data.color = (1.0, 0.92, 0.85)
    key_obj = bpy.data.objects.new(name="Studio_KeyLight", object_data=key_data)
    key_obj.location = (target_center[0] - distance * 0.7, target_center[1] - distance * 0.7, target_center[2] + elevation)
    bpy.context.scene.collection.objects.link(key_obj)

    # 2. Fill Light (Luz de Preenchimento Fria)
    fill_data = bpy.data.lights.new(name="Studio_FillLight", type="AREA")
    fill_data.energy = key_power * 0.4
    fill_data.size = 3.0
    fill_data.color = (0.7, 0.8, 1.0)
    fill_obj = bpy.data.objects.new(name="Studio_FillLight", object_data=fill_data)
    fill_obj.location = (target_center[0] + distance * 0.8, target_center[1] - distance * 0.5, target_center[2] + elevation * 0.5)
    bpy.context.scene.collection.objects.link(fill_obj)

    # 3. Rim Light (Luz de Borda Demoníaca/Dramática)
    rim_data = bpy.data.lights.new(name="Studio_RimLight", type="SPOT")
    rim_data.energy = key_power * 1.5
    rim_rgba = hex_to_linear_rgb(rim_color)
    rim_data.color = (rim_rgba[0], rim_rgba[1], rim_rgba[2])
    rim_data.spot_size = math.radians(65)
    rim_obj = bpy.data.objects.new(name="Studio_RimLight", object_data=rim_data)
    rim_obj.location = (target_center[0] + distance * 0.2, target_center[1] + distance * 0.9, target_center[2] + elevation * 1.2)
    bpy.context.scene.collection.objects.link(rim_obj)

    # 4. Câmera
    cam_data = bpy.data.cameras.new(name="Studio_Camera")
    cam_data.lens = 50
    cam_data.clip_start = 0.1
    cam_data.clip_end = 100.0
    cam_obj = bpy.data.objects.new(name="Studio_Camera", object_data=cam_data)
    cam_obj.location = (target_center[0], target_center[1] - distance, target_center[2] + elevation * 0.4)
    cam_obj.rotation_euler = (math.radians(78), 0, 0)
    bpy.context.scene.collection.objects.link(cam_obj)
    bpy.context.scene.camera = cam_obj

    # Configuração de Render do Preview
    scene = bpy.context.scene
    scene.render.engine = "BLENDER_WORKBENCH"
    if hasattr(scene, "display") and hasattr(scene.display, "shading"):
        scene.display.shading.light = "STUDIO"
        scene.display.shading.color_type = "MATERIAL"
    scene.render.resolution_x = 1024
    scene.render.resolution_y = 1024
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.film_transparent = True

    return cam_obj


def render_preview_image(output_path):
    """Executa a renderização do frame atual para a imagem PNG de preview."""
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    bpy.context.scene.render.filepath = output_path
    bpy.ops.render.render(write_still=True)
    if os.path.exists(output_path) and os.path.getsize(output_path) > 0:
        print(f"[PREVIEW OK] Render gerado com sucesso: {output_path} ({os.path.getsize(output_path):,} bytes)")
        return True
    return False


# ==============================================================================
# 7. PERSISTÊNCIA E EXPORTAÇÃO
# ==============================================================================
def save_blend_project(blend_filepath):
    """Salva o projeto .blend completo diretamente nas pastas do Abyssal Pact."""
    os.makedirs(os.path.dirname(blend_filepath), exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=blend_filepath)
    if os.path.exists(blend_filepath):
        print(f"[BLEND OK] Projeto .blend salvo: {blend_filepath} ({os.path.getsize(blend_filepath):,} bytes)")
        return True
    return False


def export_glb_model(glb_filepath, include_animations=True):
    """Exporta cena/objetos para arquivo GLB otimizado para a Godot 4."""
    os.makedirs(os.path.dirname(glb_filepath), exist_ok=True)
    
    # Selecionar todos os objetos de malha e armatures
    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.context.scene.objects:
        if obj.type in ("MESH", "ARMATURE"):
            obj.select_set(True)

    export_args = {
        "filepath": glb_filepath,
        "export_format": "GLB",
        "use_selection": True,
        "export_apply": True,
        "export_yup": True,
        "export_skins": True,
        "export_all_influences": True
    }
    if include_animations:
        export_args["export_animations"] = True
        export_args["export_frame_range"] = False
        export_args["export_current_frame"] = False
        export_args["export_nla_strips"] = True

    bpy.ops.export_scene.gltf(**export_args)
    if os.path.exists(glb_filepath):
        print(f"[GLB OK] Modelo 3D exportado para o jogo: {glb_filepath} ({os.path.getsize(glb_filepath):,} bytes)")
        return True
    return False


# ==============================================================================
# 8. INSPEÇÃO E AUDITORIA DE MODELOS
# ==============================================================================
def inspect_scene_stats():
    """Gera um dicionário detalhado com estatísticas do modelo criado."""
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    armatures = [o for o in bpy.context.scene.objects if o.type == "ARMATURE"]
    
    total_verts = sum(len(m.data.vertices) for m in meshes)
    total_polys = sum(len(m.data.polygons) for m in meshes)
    bones = []
    for a in armatures:
        bones.extend([b.name for b in a.data.bones])

    actions = [act.name for act in bpy.data.actions]
    materials = [mat.name for mat in bpy.data.materials]

    return {
        "mesh_count": len(meshes),
        "total_vertices": total_verts,
        "total_polygons": total_polys,
        "armature_count": len(armatures),
        "bones_count": len(bones),
        "bones": bones,
        "animations": actions,
        "materials": materials
    }
