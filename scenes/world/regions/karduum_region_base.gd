class_name KarduumRegionBase
extends Node3D
## Classe base unificada para as dez regiões 3D do continente KHAR-DUUM.
## Padroniza o contrato de cena do SceneManager / WorldManager,
## a coleta de pontos de spawn, áreas seguras, arenas de chefes e o carregamento
## dos 12 subsistemas do pipeline de ambientes 3D com a identidade vulcânica,
## industrial e subterrânea de Khar-Duum.

const RegionAssetLoaderClass := preload("res://scenes/world/pipeline/region_asset_loader.gd")
const RegionAtmosphereSystemClass := preload("res://scenes/world/pipeline/region_atmosphere_system.gd")
const RegionNavigationSystemClass := preload("res://scenes/world/pipeline/region_navigation_system.gd")
const RegionCollisionSystemClass := preload("res://scenes/world/pipeline/region_collision_system.gd")
const RegionLightingSystemClass := preload("res://scenes/world/pipeline/region_lighting_system.gd")

@export var region_id_code: StringName = &"REG-021"
@export var region_resource: RegionData = null

var _params: Dictionary = {}
var _spawns: Dictionary = {}

func _ready() -> void:
	_collect_spawns()
	_notify_world_manager()
	_setup_base_pipeline()
	_setup_region_environment()

## Contrato do SceneManager / WorldManager:
func setup(params: Dictionary = {}) -> void:
	_params = params
	if params.has("region_data") and params["region_data"] is RegionData:
		region_resource = params["region_data"] as RegionData

func received_params() -> Dictionary:
	return _params

func region_id() -> StringName:
	return region_id_code

func region_data() -> RegionData:
	if region_resource == null:
		var world := Game.get_system(SystemNames.WORLD) as WorldManager
		if world != null:
			region_resource = world.get_region(region_id_code)
	return region_resource

func spawn_point(marker_name: String = "default") -> Node3D:
	if _spawns.has(marker_name):
		return _spawns[marker_name]
	if _spawns.has("default"):
		return _spawns["default"]
	return self

func boss_arena() -> Node3D:
	return get_node_or_null("Structures/BossArena")

func safe_zone() -> Area3D:
	if has_node("Structures/SafeZoneHolder/SafeZone"):
		return get_node("Structures/SafeZoneHolder/SafeZone") as Area3D
	if has_node("Structures/CitySanctuary/SafeZone"):
		return get_node("Structures/CitySanctuary/SafeZone") as Area3D
	if has_node("Structures/CityBastion/SafeZone"):
		return get_node("Structures/CityBastion/SafeZone") as Area3D
	if has_node("Structures/CityForge/SafeZone"):
		return get_node("Structures/CityForge/SafeZone") as Area3D
	return null

func _collect_spawns() -> void:
	_spawns.clear()
	var spawn_root := get_node_or_null("Spawns")
	if spawn_root != null:
		for child in spawn_root.get_children():
			if child is Marker3D:
				var clean_name := child.name.trim_prefix("Spawn_")
				_spawns[clean_name] = child
				_spawns[child.name] = child

func _notify_world_manager() -> void:
	var world := Game.get_system(SystemNames.WORLD) as WorldManager
	if world != null:
		world.discover_region(region_id_code)

func _setup_base_pipeline() -> void:
	# 1. NavigationRegion3D garantido
	if not has_node("NavigationRegion3D"):
		RegionNavigationSystemClass.create_navigation_region(self, 120.0)

	# 2. Partículas atmosféricas de Khar-Duum (poeira vulcânica, cinzas e brasas incandescentes)
	if not has_node("AtmosphericParticles"):
		RegionAtmosphereSystemClass.setup_atmosphere_particles(self, &"CONT-03")

## Sobrescrito por cada uma das 10 regiões de Khar-Duum para configurar seus monumentos e especificidades:
func _setup_region_environment() -> void:
	pass
