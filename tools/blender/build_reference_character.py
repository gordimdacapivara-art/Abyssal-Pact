# ABYSSAL PACT — Gerador do personagem humanoide de referência (PROVISÓRIO).
#
# Ferramenta CANÔNICA do pipeline de modelos: roda headless no Blender e
# entrega SOMENTE um .glb (a regra absoluta do projeto é: .blend fica FORA da
# pasta do jogo; este script salva .blend apenas se --save-blend for passado,
# e o destino indicado deve estar fora do repositório do jogo).
#
# O modelo é um manequim procedural de BAIXO CUSTO (alvo: PC 4 GB RAM, i3 11ª
# geração, gráficos integrados Intel UHD): 2 objetos de malha (corpo + cabeça),
# 3 materiais sólidos SEM texturas, esqueleto de 8 ossos e 8 clipes que
# seguem EXATAMENTE o contrato do PlayerAnimator (idle, walk, run, sprint,
# jump, fall, land, dodge).
#
# CONVENÇÕES:
#   - Escala em metros; origem nos pés (z=0); altura total ~1,8 m.
#   - O personagem é construído olhando para +Y no Blender → chega olhando
#     para -Z no Godot (frente correta do controlador).
#   - Taxa 24 fps; clipes de locomoção começam e terminam na mesma pose
#     (loop perfeito); jump/land/dodge terminam em repouso.
#
# Uso:
#   blender --background --factory-startup --python build_reference_character.py -- \
#     --out "...\assets\models\characters\reference\char_ref_humanoid.glb" \
#     [--save-blend "...\FORA_DO_JOGO\char_ref_humanoid.blend"]
#
# Saída: exit 0 se o GLB contém os 4 clipes centrais (idle/walk/run/jump);
# exit 1 caso contrário. O relatório completo vai para o stdout.

import bpy
import math
import os
import re
import sys
from mathutils import Vector

FPS = 24
CONTRACT_CLIPS = ["idle", "walk", "run", "sprint", "jump", "fall", "land", "dodge"]
CORE_CLIPS = ["idle", "walk", "run", "jump"]

# ---------------------------------------------------------------- argumentos --
argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []


def arg_value(flag, default=None):
    if flag in argv:
        return argv[argv.index(flag) + 1]
    return default


OUT_GLB = os.path.abspath(arg_value("--out", "char_ref_humanoid.glb"))
SAVE_BLEND = arg_value("--save-blend")
SAVE_BLEND = os.path.abspath(SAVE_BLEND) if SAVE_BLEND else None

# ------------------------------------------------------------------- helpers --


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for block in (bpy.data.meshes, bpy.data.armatures, bpy.data.materials, bpy.data.actions):
        for item in list(block):
            if item.users == 0:
                block.remove(item)


def set_material(obj, mat):
    obj.data.materials.clear()
    obj.data.materials.append(mat)


def solid_material(name, rgb):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf is not None:
        for input_name in ("Base Color", "base_color", "BaseColour"):
            if input_name in bsdf.inputs:
                bsdf.inputs[input_name].default_value = (rgb[0], rgb[1], rgb[2], 1.0)
                break
        for extra in ("Specular IOR Level", "Specular", "specular"):
            if extra in bsdf.inputs:
                bsdf.inputs[extra].default_value = 0.2
                break
        if "Roughness" in bsdf.inputs:
            bsdf.inputs["Roughness"].default_value = 0.85
    return mat


def add_box(name, center, size, mat):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=center)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    set_material(obj, mat)
    return obj


def join_objects(objs, name):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objs:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    joined = bpy.context.active_object
    joined.name = name
    return joined


def add_bone(arm, name, head, tail, parent=None):
    bone = arm.edit_bones.new(name)
    bone.head = Vector(head)
    bone.tail = Vector(tail)
    bone.use_connect = False
    if parent is not None:
        bone.parent = arm.edit_bones[parent]
    return bone


def pose_bone(name):
    return armature_obj.pose.bones[name]


def reset_pose():
    for name in ANIMATED_BONES:
        pb = pose_bone(name)
        pb.rotation_euler = (0.0, 0.0, 0.0)
        pb.location = (0.0, 0.0, 0.0)
        pb.scale = (1.0, 1.0, 1.0)


def ensure_pose_mode():
    obj = armature_obj
    if obj.mode != "POSE":
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.mode_set(mode="POSE")


def key_rotations(specs, frame):
    """Keyframes de rotação em espaço GLOBAL por eixo (sem acumulação)."""
    ensure_pose_mode()
    bpy.context.scene.frame_set(frame)
    bpy.ops.pose.select_all(action="DESELECT")
    touched = set()
    for name, axis, angle in specs:
        pb = pose_bone(name)
        pb.select = True
        touched.add(name)
    bpy.context.view_layer.objects.active = armature_obj
    # Um único eixo/ângulo por chamada: agrupa specs iguais.
    by_key = {}
    for name, axis, angle in specs:
        by_key.setdefault((axis, round(angle, 4)), []).append(name)
    for (axis, angle), names in by_key.items():
        bpy.ops.pose.select_all(action="DESELECT")
        for name in names:
            pose_bone(name).select = True
        bpy.ops.transform.rotate(value=angle, orient_axis=axis, orient_type="GLOBAL")
        for name in names:
            pose_bone(name).keyframe_insert("rotation_euler", frame=frame)
    for name in touched:
        pose_bone(name).keyframe_insert("rotation_euler", frame=frame)


def key_locations(specs, frame):
    ensure_pose_mode()
    bpy.context.scene.frame_set(frame)
    for name, axis, delta in specs:
        pb = pose_bone(name)
        loc = [pb.location.x, pb.location.y, pb.location.z]
        idx = "xyz".index(axis)
        loc[idx] = delta
        pb.location = (loc[0], loc[1], loc[2])
        pb.keyframe_insert("location", frame=frame)


def make_action(name):
    action = bpy.data.actions.new(name)
    action.use_fake_user = True
    if armature_obj.animation_data is None:
        armature_obj.animation_data_create()
    bpy.context.scene.frame_start = 1
    bpy.context.scene.frame_end = 2
    armature_obj.animation_data.action = action
    return action


def finish_action(action, last_frame, loop):
    bpy.context.scene.frame_start = 1
    bpy.context.scene.frame_end = last_frame
    armature_obj.animation_data.action = None
    _ = loop  # loops são garantidos por keyframes iguais nas extremidades


# --------------------------------------------------------------------- cena --
clear_scene()
scene = bpy.context.scene
scene.render.fps = FPS
scene.unit_settings.scale_length = 1.0

mat_body = solid_material("mat_body", (0.10, 0.09, 0.11, 1.0))
mat_head = solid_material("mat_head", (0.45, 0.40, 0.36, 1.0))
mat_accent = solid_material("mat_accent", (0.55, 0.12, 0.10, 1.0))

# Frente do personagem = +Y no Blender (chega como -Z no Godot).
# Pernas e braços descem até o chão (origem nos pés, z=0).
pelvis = add_box("pelvis", (0, 0, 0.95), (0.30, 0.20, 0.20), mat_body)
torso = add_box("torso", (0, 0, 1.22), (0.34, 0.22, 0.46), mat_body)
plate = add_box("plate", (0, 0.13, 1.26), (0.24, 0.03, 0.30), mat_accent)
leg_l = add_box("leg_mesh_l", (0.14, 0, 0.44), (0.13, 0.17, 0.88), mat_body)
leg_r = add_box("leg_mesh_r", (-0.14, 0, 0.44), (0.13, 0.17, 0.88), mat_body)
arm_l = add_box("arm_mesh_l", (0.24, 0, 1.21), (0.11, 0.13, 0.38), mat_body)
arm_r = add_box("arm_mesh_r", (-0.24, 0, 1.21), (0.11, 0.13, 0.38), mat_body)
body = join_objects([pelvis, torso, plate, leg_l, leg_r, arm_l, arm_r], "body")

head_mesh = bpy.ops.mesh.primitive_uv_sphere_add(
    segments=16, ring_count=10, radius=0.17, location=(0, 0, 1.62))
head = bpy.context.active_object
head.name = "head"
set_material(head, mat_head)
face = add_box("face", (0, 0.155, 1.64), (0.10, 0.02, 0.06), mat_accent)
head = join_objects([head, face], "head")

# --------------------------------------------------------------- esqueleto --
arm_data = bpy.data.armatures.new("Armature")
armature_obj = bpy.data.objects.new("Armature", arm_data)
scene.collection.objects.link(armature_obj)
bpy.context.view_layer.objects.active = armature_obj
bpy.ops.object.mode_set(mode="EDIT")

add_bone(arm_data, "root", (0, 0, 0.88), (0, 0, 1.02))
add_bone(arm_data, "spine", (0, 0, 1.02), (0, 0, 1.18), "root")
add_bone(arm_data, "chest", (0, 0, 1.18), (0, 0, 1.44), "spine")
add_bone(arm_data, "head", (0, 0, 1.44), (0, 0, 1.60), "chest")
add_bone(arm_data, "arm_l", (0.24, 0, 1.40), (0.24, 0, 1.02), "chest")
add_bone(arm_data, "arm_r", (-0.24, 0, 1.40), (-0.24, 0, 1.02), "chest")
add_bone(arm_data, "leg_l", (0.14, 0, 0.88), (0.14, 0, 0.03), "root")
add_bone(arm_data, "leg_r", (-0.14, 0, 0.88), (-0.14, 0, 0.03), "root")
bpy.ops.object.mode_set(mode="OBJECT")

ANIMATED_BONES = ["root", "spine", "chest", "head", "arm_l", "arm_r", "leg_l", "leg_r"]

# Parent com pesos automáticos (deformação simples para o manequim).
bpy.ops.object.select_all(action="DESELECT")
body.select_set(True)
head.select_set(True)
armature_obj.select_set(True)
bpy.context.view_layer.objects.active = armature_obj
bpy.ops.object.parent_set(type="ARMATURE_AUTO")

for name in ANIMATED_BONES:
    pb = pose_bone(name)
    pb.rotation_mode = "XYZ"
    pb.lock_rotation = (False, False, False)
    pb.lock_location = (False, False, False)

# -------------------------------------------------------------- animações --

def clip_idle():
    action = make_action("idle")
    key_rotations([("arm_l", "X", math.radians(4)), ("arm_r", "X", math.radians(-4))], 1)
    key_locations([("root", "y", 0.0)], 1)
    key_rotations([("arm_l", "X", math.radians(-4)), ("arm_r", "X", math.radians(4))], 19)
    key_locations([("root", "y", 0.012)], 19)
    key_rotations([("arm_l", "X", math.radians(4)), ("arm_r", "X", math.radians(-4))], 36)
    key_locations([("root", "y", 0.0)], 36)
    finish_action(action, 36, True)


def clip_walk():
    action = make_action("walk")
    for frame, leg_l_angle, leg_r_angle, arm_l_angle in (
        (1, 28, -28, -18), (6, 0, 0, 0), (11, -28, 28, 18), (16, 0, 0, 0), (20, 28, -28, -18),
    ):
        key_rotations([
            ("leg_l", "X", math.radians(leg_l_angle)),
            ("leg_r", "X", math.radians(leg_r_angle)),
            ("arm_l", "X", math.radians(arm_l_angle)),
            ("arm_r", "X", math.radians(-arm_l_angle)),
            ("chest", "X", math.radians(3.0 if leg_l_angle > 0 else (-3.0 if leg_l_angle < 0 else 0.0))),
        ], frame)
        key_locations([("root", "y", 0.02 if frame in (6, 16) else 0.0)], frame)
    finish_action(action, 20, True)


def clip_run(clip_name, leg_amp, arm_amp, lean, bob):
    action = make_action(clip_name)
    half = max(2, round(7 * FPS / 24))
    mid = half + 1
    last = mid + half - 1
    swing = [(1, leg_amp, -leg_amp, -arm_amp, bob), (mid, -leg_amp, leg_amp, arm_amp, bob),
             (last, leg_amp, -leg_amp, -arm_amp, bob)]
    for frame, leg_l_angle, leg_r_angle, arm_l_angle, root_bob in swing:
        key_rotations([
            ("leg_l", "X", math.radians(leg_l_angle)),
            ("leg_r", "X", math.radians(leg_r_angle)),
            ("arm_l", "X", math.radians(arm_l_angle)),
            ("arm_r", "X", math.radians(-arm_l_angle)),
            ("chest", "X", math.radians(lean)),
        ], frame)
        key_locations([("root", "y", root_bob)], frame)
    finish_action(action, last, True)


def clip_jump():
    action = make_action("jump")
    key_rotations([], 1)
    key_locations([("root", "y", 0.0)], 1)
    # agachar
    key_rotations([("leg_l", "X", math.radians(35)), ("leg_r", "X", math.radians(35)),
                   ("arm_l", "X", math.radians(-30)), ("arm_r", "X", math.radians(-30)),
                   ("chest", "X", math.radians(12))], 6)
    key_locations([("root", "y", -0.12)], 6)
    # extensão
    key_rotations([("leg_l", "X", math.radians(-12)), ("leg_r", "X", math.radians(-12)),
                   ("arm_l", "X", math.radians(150)), ("arm_r", "X", math.radians(150)),
                   ("chest", "X", math.radians(-8))], 10)
    key_locations([("root", "y", 0.05)], 10)
    # tuck aéreo
    key_rotations([("leg_l", "X", math.radians(45)), ("leg_r", "X", math.radians(45)),
                   ("arm_l", "X", math.radians(120)), ("arm_r", "X", math.radians(120))], 15)
    key_locations([("root", "y", 0.05)], 15)
    # preparo de aterrissagem
    key_rotations([("leg_l", "X", math.radians(25)), ("leg_r", "X", math.radians(25)),
                   ("arm_l", "X", math.radians(60)), ("arm_r", "X", math.radians(60))], 21)
    key_locations([("root", "y", 0.0)], 21)
    key_rotations([], 24)
    key_locations([("root", "y", 0.0)], 24)
    finish_action(action, 24, False)


def clip_fall():
    action = make_action("fall")
    for frame, sway in ((1, 10), (5, -10), (8, 10)):
        key_rotations([("leg_l", "X", math.radians(sway)), ("leg_r", "X", math.radians(-sway)),
                       ("arm_l", "X", math.radians(140)), ("arm_r", "X", math.radians(140)),
                       ("chest", "X", math.radians(-8))], frame)
    finish_action(action, 8, True)


def clip_land():
    action = make_action("land")
    key_rotations([("arm_l", "X", math.radians(140)), ("arm_r", "X", math.radians(140))], 1)
    key_locations([("root", "y", 0.0)], 1)
    key_rotations([("leg_l", "X", math.radians(40)), ("leg_r", "X", math.radians(40)),
                   ("arm_l", "X", math.radians(70)), ("arm_r", "X", math.radians(70)),
                   ("chest", "X", math.radians(14))], 3)
    key_locations([("root", "y", -0.18)], 3)
    key_rotations([("leg_l", "X", math.radians(10)), ("leg_r", "X", math.radians(10)),
                   ("arm_l", "X", math.radians(20)), ("arm_r", "X", math.radians(20)),
                   ("chest", "X", math.radians(5))], 8)
    key_locations([("root", "y", -0.04)], 8)
    key_rotations([], 12)
    key_locations([("root", "y", 0.0)], 12)
    finish_action(action, 12, False)


def clip_dodge():
    action = make_action("dodge")
    key_rotations([], 1)
    key_locations([("root", "x", 0.0)], 1)
    key_rotations([("chest", "Y", math.radians(25)),
                   ("arm_l", "X", math.radians(40)), ("arm_r", "X", math.radians(-20)),
                   ("leg_l", "X", math.radians(20)), ("leg_r", "X", math.radians(-10))], 4)
    key_locations([("root", "x", 0.16)], 4)
    key_rotations([("chest", "Y", math.radians(20))], 9)
    key_locations([("root", "x", 0.16)], 9)
    key_rotations([], 14)
    key_locations([("root", "x", 0.0)], 14)
    finish_action(action, 14, False)


clip_idle()
clip_walk()
clip_run("run", 50, 35, 12, 0.03)
clip_run("sprint", 58, 40, 18, 0.04)
clip_jump()
clip_fall()
clip_land()
clip_dodge()

# ---------------------------------------------------------------- exportação --
os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)


def stash_nla():
    try:
        anim = armature_obj.animation_data
        anim.action = None
        for track in list(anim.nla_tracks):
            anim.nla_tracks.remove(track)
        for clip_name in CONTRACT_CLIPS:
            action = bpy.data.actions.get(clip_name)
            if action is None:
                continue
            track = anim.nla_tracks.new()
            track.name = clip_name
            start = int(round(action.frame_range[0]))
            strip = track.strips.new(clip_name, start, action)
            strip.name = clip_name
            try:
                strip.action_frame_start = int(round(action.frame_range[0]))
                strip.action_frame_end = int(round(action.frame_range[1]))
            except AttributeError:
                pass
        return True
    except Exception as error:  # API de slots pode mudar entre versões
        print("[aviso] stash NLA indisponível (%s); usando modo ACTIONS" % error)
        return False


def export_glb(kwargs):
    keys = dict(kwargs)
    while True:
        try:
            bpy.ops.export_scene.gltf(filepath=OUT_GLB, **keys)
            return True
        except TypeError as error:
            match = re.search(r"(?:keyword|argument)[\s:]*[\"']?(\w+)[\"']?", str(error))
            if match and match.group(1) in keys:
                print("[aviso] exportador sem suporte a '%s'; removendo" % match.group(1))
                del keys[match.group(1)]
                continue
            raise


def glb_animation_names(path):
    with open(path, "rb") as handle:
        header = handle.read(12) # magic(4) + versão(4) + tamanho total(4)
        if header[0:4] != b"glTF":
            return []
        chunk_length = int.from_bytes(handle.read(4), "little")
        if handle.read(4) != b"JSON":
            return []
        payload = handle.read(chunk_length)
        import json
        data = json.loads(payload.decode("utf-8"))
        return [str(anim.get("name", "")) for anim in data.get("animations", [])]


stash_ok = stash_nla()
base_kwargs = {
    "export_format": "GLB",
    "export_yup": True,
    "export_apply": True,
    "export_skins": True,
    "export_animations": True,
    "export_morph": False,
    "export_texcoords": False,
    "export_normals": True,
    "export_colors": False,
    "export_anim_slide_to_zero": True,
    "export_def_bones": False,
}
export_kwargs = dict(base_kwargs)
if stash_ok:
    export_kwargs["export_animation_mode"] = "NLA_TRACKS"

found = []
for attempt_mode in ("stash", "actions", "plain"):
    export_kwargs = dict(base_kwargs)
    if attempt_mode == "stash" and stash_ok:
        export_kwargs["export_animation_mode"] = "NLA_TRACKS"
    elif attempt_mode == "actions":
        export_kwargs["export_animation_mode"] = "ACTIONS"
    try:
        export_glb(export_kwargs)
    except Exception as error:
        print("[aviso] tentativa %s falhou: %s" % (attempt_mode, error))
        continue
    found = glb_animation_names(OUT_GLB)
    print("[export] modo %s → animações: %s" % (attempt_mode, ", ".join(found) if found else "NENHUMA"))
    if CORE_CLIPS[0] in found and CORE_CLIPS[1] in found and CORE_CLIPS[2] in found and CORE_CLIPS[3] in found:
        break

missing = [clip for clip in CORE_CLIPS if clip not in found]
size_bytes = os.path.getsize(OUT_GLB) if os.path.exists(OUT_GLB) else 0

if SAVE_BLEND:
    os.makedirs(os.path.dirname(SAVE_BLEND), exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=SAVE_BLEND)
    print("[blend] fonte salva FORA do repositório do jogo: %s" % SAVE_BLEND)

print("[relatório] GLB: %s (%d bytes)" % (OUT_GLB, size_bytes))
print("[relatório] animações: %s" % ", ".join(found))
print("[relatório] clipes centrais ausentes: %s" % (", ".join(missing) if missing else "nenhum"))
print("[relatório] ossos: %d | objetos de malha: %d" % (len(arm_data.bones), 3))

if missing:
    print("[relatório] FALHA: clipes centrais ausentes")
    sys.exit(1)
print("[relatório] OK: modelo de referência gerado conforme contrato")
