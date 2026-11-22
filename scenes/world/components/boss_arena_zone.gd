class_name BossArenaZone
extends Node3D
## Zona de arena de chefe no mundo aberto com barreiras de combate e colunas circulares.

@export var boss_id: StringName = &"BOSS-001"
@export var arena_name: String = "Arena do Vazio"
@export var radius: float = 18.0
@export var pillar_count: int = 8

var _encounter: BossEncounter = null

func _ready() -> void:
	_build_arena()

func setup(data: Dictionary) -> void:
	boss_id = StringName(String(data.get("boss_id", boss_id)))
	arena_name = String(data.get("arena_name", arena_name))
	radius = float(data.get("radius", radius))
	if data.has("position") and data["position"] is Vector3:
		position = data["position"]
	_build_arena()

func boss_encounter() -> BossEncounter:
	return _encounter

func _build_arena() -> void:
	for child in get_children():
		child.queue_free()

	# Base circular do piso
	var floor_mesh := MeshInstance3D.new()
	floor_mesh.name = "ArenaFloor"
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius * 1.05
	cyl.height = 0.4
	floor_mesh.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.12, 0.16)
	floor_mesh.material_override = mat
	floor_mesh.position.y = 0.2
	add_child(floor_mesh)

	# Colunas circulares ao redor
	var angle_step := (PI * 2.0) / float(pillar_count)
	for i in range(pillar_count):
		var angle := float(i) * angle_step
		var px := cos(angle) * (radius - 1.0)
		var pz := sin(angle) * (radius - 1.0)
		var pillar := MeshInstance3D.new()
		pillar.name = "Pillar_%d" % i
		var pcyl := CylinderMesh.new()
		pcyl.top_radius = 0.6
		pcyl.bottom_radius = 0.8
		pcyl.height = 5.0
		pillar.mesh = pcyl
		var pmat := StandardMaterial3D.new()
		pmat.albedo_color = Color(0.25, 0.2, 0.22)
		pillar.material_override = pmat
		pillar.position = Vector3(px, 2.5, pz)
		add_child(pillar)

	# Label da arena
	var label := Label3D.new()
	label.name = "ArenaLabel"
	label.text = "ÁREA DE CHEFE\n%s (%s)" % [arena_name, boss_id]
	label.font_size = 30
	label.modulate = Color(1.0, 0.4, 0.2)
	label.position = Vector3(0, 4.0, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)

func spawn_boss_encounter() -> BossEncounter:
	if _encounter != null:
		return _encounter
	var scene := preload("res://enemies/boss_encounter.tscn")
	_encounter = scene.instantiate() as BossEncounter
	_encounter.name = "BossEncounter"
	_encounter.boss_id = boss_id
	_encounter.position = Vector3(0, 0.5, 0)
	add_child(_encounter)
	return _encounter
