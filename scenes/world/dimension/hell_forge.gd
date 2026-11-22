class_name HellForgeDimension
extends Node3D
## Dimensão independente da Hell Forge (DIM-HELL-FORGE / hell_forge).
## Hub central extracartográfico, forja cósmica ancestral e destino OBRIGATÓRIO
## de ressurgimento para todos os jogadores de ABYSSAL PACT (Invariants.HUB_REGION_ID).
##
## Cada mundo privado possui sua própria instância lógica isolada da Hell Forge,
## com conduítes dimensionais e portais arcanos conectados às capitais e regiões
## terminais dos quatro continentes.

const RegionAssetLoaderClass := preload("res://scenes/world/pipeline/region_asset_loader.gd")
const RegionAtmosphereSystemClass := preload("res://scenes/world/pipeline/region_atmosphere_system.gd")
const RegionNavigationSystemClass := preload("res://scenes/world/pipeline/region_navigation_system.gd")
const RegionCollisionSystemClass := preload("res://scenes/world/pipeline/region_collision_system.gd")

@export var dimension_id: StringName = Invariants.HUB_REGION_ID
@export var dimension_name: String = "Hell Forge"

var _params: Dictionary = {}
var _spawns: Dictionary = {}

func _ready() -> void:
	_collect_spawns()
	_setup_dimension_pipeline()
	_notify_world_manager()

func setup(params: Dictionary = {}) -> void:
	_params = params

func received_params() -> Dictionary:
	return _params

func region_id() -> StringName:
	return dimension_id

func region_data() -> RegionData:
	var world := Game.get_system(SystemNames.WORLD) as WorldManager
	if world != null:
		return world.get_region(dimension_id)
	return null

func spawn_point(marker_name: String = "default") -> Node3D:
	if _spawns.has(marker_name):
		return _spawns[marker_name]
	if _spawns.has("respawn"):
		return _spawns["respawn"]
	if _spawns.has("default"):
		return _spawns["default"]
	return self

func safe_zone() -> Area3D:
	if has_node("Structures/RespawnSanctuary/SafeZone"):
		return get_node("Structures/RespawnSanctuary/SafeZone") as Area3D
	if has_node("Structures/CityHaven/SafeZone"):
		return get_node("Structures/CityHaven/SafeZone") as Area3D
	return null

func boss_arena() -> Node3D:
	return null # A Hell Forge é um refúgio e hub dimensional sagrado; não possui arena de combate regional

func _collect_spawns() -> void:
	_spawns.clear()
	var spawn_root := get_node_or_null("Spawns")
	if spawn_root != null:
		for child in spawn_root.get_children():
			if child is Marker3D:
				var clean_name := child.name.trim_prefix("Spawn_")
				_spawns[clean_name] = child
				_spawns[child.name] = child

func _setup_dimension_pipeline() -> void:
	# NavMesh garantido
	if not has_node("NavigationRegion3D"):
		RegionNavigationSystemClass.create_navigation_region(self, 150.0)

	# Partículas de brasas e cinzas abissais da Hell Forge
	if not has_node("AtmosphericParticles"):
		RegionAtmosphereSystemClass.setup_atmosphere_particles(self, &"CONT-01")

func _notify_world_manager() -> void:
	var world := Game.get_system(SystemNames.WORLD) as WorldManager
	if world != null:
		world.discover_region(dimension_id)
