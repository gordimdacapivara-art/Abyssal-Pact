class_name Region001Veyrath
extends Node3D
## Região completa de Veyrath: REG-001 "Planície Cinzenta de Veyrath".
##
## Implementação completa de produção: terreno estruturado, vegetação petrificada,
## cidade Baluarte das Cinzas (safe zone), masmorra Catacumbas de Basalto,
## arena de chefe BOSS-001, portal para Hell Forge, portões de fronteira,
## áreas de exploração e zonas de inimigos para os 5 demônios catalogados (DEMON-001..005).

const REGION_ID: StringName = &"REG-001"

const RegionAssetLoaderClass := preload("res://scenes/world/pipeline/region_asset_loader.gd")
const RegionAtmosphereSystemClass := preload("res://scenes/world/pipeline/region_atmosphere_system.gd")
const RegionNavigationSystemClass := preload("res://scenes/world/pipeline/region_navigation_system.gd")
const RegionStructureSystemClass := preload("res://scenes/world/pipeline/region_structure_system.gd")
const RegionPropsSystemClass := preload("res://scenes/world/pipeline/region_props_system.gd")
const RegionVegetationSystemClass := preload("res://scenes/world/pipeline/region_vegetation_system.gd")

@export var region_resource: RegionData = null

var _params: Dictionary = {}
var _spawns: Dictionary = {} # String(marker_name) -> Marker3D

@onready var _spawn_default: Marker3D = $Spawns/Spawn_default
@onready var _spawn_gate_north: Marker3D = $Spawns/Spawn_gate_north
@onready var _spawn_gate_south: Marker3D = $Spawns/Spawn_gate_south
@onready var _spawn_portal_main: Marker3D = $Spawns/Spawn_portal_main
@onready var _boss_arena: Node3D = $Structures/BossArena
@onready var _safe_zone: Area3D = $Structures/CityBastion/SafeZone

func _ready() -> void:
	_collect_spawns()
	_notify_world_manager()
	_integrate_3d_pipeline()

func _integrate_3d_pipeline() -> void:
	# Integração do pipeline de construção 3D:
	if not has_node("AtmosphericParticles"):
		RegionAtmosphereSystemClass.setup_atmosphere_particles(self, &"CONT-01")
	if not has_node("NavigationRegion3D"):
		RegionNavigationSystemClass.create_navigation_region(self, 120.0)
	if not has_node("ModularStructures"):
		RegionStructureSystemClass.spawn_ruins(self, "ash_plains")
	if not has_node("EnvironmentalProps"):
		RegionPropsSystemClass.spawn_environmental_props(self, "ash_plains")
	if not has_node("Vegetation"):
		RegionVegetationSystemClass.spawn_vegetation(self, "ash_plains", 120.0)

	# Decora Monólito do Primeiro Pacto com o modelo GLB real
	var monolith_node := get_node_or_null("Exploration/MonolithPact")
	if monolith_node != null and not monolith_node.has_node("MonolithGLB"):
		var monolith_glb: Node3D = RegionAssetLoaderClass.instantiate_model("props", "prop_ash_monolith")
		monolith_glb.name = "MonolithGLB"
		monolith_node.add_child(monolith_glb)

## Contrato de cena do SceneManager / WorldManager:
func setup(params: Dictionary = {}) -> void:
	_params = params
	if params.has("region_data") and params["region_data"] is RegionData:
		region_resource = params["region_data"] as RegionData

func received_params() -> Dictionary:
	return _params

func region_id() -> StringName:
	return REGION_ID

func region_data() -> RegionData:
	if region_resource == null:
		var world := Game.get_system(SystemNames.WORLD) as WorldManager
		if world != null:
			region_resource = world.get_region(REGION_ID)
	return region_resource

func spawn_point(marker_name: String = "default") -> Node3D:
	if _spawns.has(marker_name):
		return _spawns[marker_name]
	if _spawns.has("default"):
		return _spawns["default"]
	return self

func boss_arena() -> Node3D:
	return _boss_arena

func safe_zone() -> Area3D:
	return _safe_zone

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
		world.discover_region(REGION_ID)
