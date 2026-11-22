class_name EnemySpawnerZone
extends Node3D
## Zona de surgimento de inimigos no mundo aberto vinculada aos dados do DemonManager.

@export var demon_id: StringName = &"DEMON-001"
@export var spawn_count: int = 2
@export var spawn_radius: float = 6.0
@export var auto_spawn: bool = false

var _spawned_creatures: Array[Creature] = []

func _ready() -> void:
	_build_marker()
	if auto_spawn:
		spawn_enemies()

func setup(data: Dictionary) -> void:
	demon_id = StringName(String(data.get("demon_id", demon_id)))
	spawn_count = int(data.get("count", spawn_count))
	spawn_radius = float(data.get("radius", spawn_radius))
	if data.has("position") and data["position"] is Vector3:
		position = data["position"]
	_build_marker()

func spawned_creatures() -> Array[Creature]:
	return _spawned_creatures

func spawn_enemies() -> void:
	var demons := Game.get_system(SystemNames.DEMONS) as DemonManager
	if demons == null or not demons.has_demon(demon_id):
		return
	var demon_data := demons.get_demon(demon_id)
	var creature_scene := preload("res://enemies/creature.tscn")

	for i in range(spawn_count):
		var creature := creature_scene.instantiate() as Creature
		creature.name = "Enemy_%s_%d" % [demon_id, i]
		var angle := (PI * 2.0 / float(max(1, spawn_count))) * float(i)
		var offset := Vector3(cos(angle) * spawn_radius * 0.5, 0, sin(angle) * spawn_radius * 0.5)
		creature.position = offset
		add_child(creature)
		creature.setup(demon_data)
		_spawned_creatures.append(creature)

func _build_marker() -> void:
	for child in get_children():
		if child is Label3D:
			child.queue_free()
	var label := Label3D.new()
	label.name = "SpawnLabel"
	label.text = "ÁREA DE INIMIGOS\n%s (%d)" % [demon_id, spawn_count]
	label.font_size = 22
	label.modulate = Color(0.9, 0.3, 0.3, 0.8)
	label.position.y = 2.0
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
