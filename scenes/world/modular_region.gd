class_name ModularRegion
extends Node3D
## Cena modular reutilizável para o staging e execução das regiões de mundo aberto.
## Constrói dinamicamente o terreno, iluminação, limites, POIs, portões, portais,
## áreas de inimigos e chefes com base no RegionData fornecido.

const WorldBoundaryScript := preload("res://scenes/world/components/world_boundary.gd")
const PointOfInterestScript := preload("res://scenes/world/components/point_of_interest.gd")
const SafeZoneScript := preload("res://scenes/world/components/safe_zone.gd")
const DungeonEntranceScript := preload("res://scenes/world/components/dungeon_entrance.gd")
const RegionGateScript := preload("res://scenes/world/components/region_gate.gd")
const WorldPortalScript := preload("res://scenes/world/components/world_portal.gd")
const EnemySpawnerZoneScript := preload("res://scenes/world/components/enemy_spawner_zone.gd")
const BossArenaZoneScript := preload("res://scenes/world/components/boss_arena_zone.gd")

const CONTINENT_PALETTES := {
	"CONT-01": { # Veyrath (Vulcânico / Cinzas)
		"ground_color": Color(0.16, 0.14, 0.16),
		"sun_color": Color(0.95, 0.65, 0.5),
		"ambient_color": Color(0.22, 0.14, 0.16),
		"fog_color": Color(0.28, 0.16, 0.18),
		"sky_top": Color(0.18, 0.12, 0.15),
		"sky_horizon": Color(0.38, 0.22, 0.2)
	},
	"CONT-02": { # Sylvaran (Floresta Ancestral / Pântano Espectral)
		"ground_color": Color(0.12, 0.18, 0.14),
		"sun_color": Color(0.65, 0.85, 0.7),
		"ambient_color": Color(0.12, 0.22, 0.16),
		"fog_color": Color(0.15, 0.28, 0.2),
		"sky_top": Color(0.08, 0.18, 0.12),
		"sky_horizon": Color(0.18, 0.35, 0.25)
	},
	"CONT-03": { # Khar-Duum (Deserto de Areias / Cânions de Pedra)
		"ground_color": Color(0.28, 0.22, 0.18),
		"sun_color": Color(0.98, 0.82, 0.6),
		"ambient_color": Color(0.25, 0.18, 0.14),
		"fog_color": Color(0.32, 0.25, 0.18),
		"sky_top": Color(0.22, 0.16, 0.12),
		"sky_horizon": Color(0.45, 0.32, 0.22)
	},
	"CONT-04": { # Nhal'Kora (Costa Abissal / Névoas Glaciais)
		"ground_color": Color(0.1, 0.14, 0.2),
		"sun_color": Color(0.55, 0.75, 0.9),
		"ambient_color": Color(0.12, 0.16, 0.25),
		"fog_color": Color(0.14, 0.2, 0.32),
		"sky_top": Color(0.08, 0.12, 0.2),
		"sky_horizon": Color(0.16, 0.25, 0.4)
	}
}

@export var region_id_override: StringName = &""

var _data: RegionData = null
var _params: Dictionary = {}
var _spawns: Dictionary = {} # name -> Marker3D
var _boundary: Node3D = null
var _pois: Array[Area3D] = []
var _gates: Array[Area3D] = []
var _portals: Array[Area3D] = []
var _boss_arena: Node3D = null

@onready var _terrain_node: Node3D = $Terrain
@onready var _spawns_node: Node3D = $Spawns
@onready var _structures_node: Node3D = $Structures
@onready var _travel_node: Node3D = $Travel
@onready var _enemies_node: Node3D = $Enemies
@onready var _env_node: WorldEnvironment = $Environment/WorldEnvironment
@onready var _sun_light: DirectionalLight3D = $Environment/SunLight

func _ready() -> void:
	if _data == null and region_id_override != &"":
		var world := Game.get_system(SystemNames.WORLD) as WorldManager
		if world != null and world.has_region(region_id_override):
			setup({"region_data": world.get_region(region_id_override)})

## Contrato de cena SceneManager / WorldManager:
func setup(params: Dictionary = {}) -> void:
	_params = params
	if params.has("region_data") and params["region_data"] is RegionData:
		_data = params["region_data"] as RegionData
	elif params.has("region_id"):
		var world := Game.get_system(SystemNames.WORLD) as WorldManager
		if world != null:
			_data = world.get_region(StringName(String(params["region_id"])))

	if _data != null:
		_build_from_data()

func received_params() -> Dictionary:
	return _params

func region_id() -> StringName:
	return _data.id if _data != null else region_id_override

func region_data() -> RegionData:
	return _data

func spawn_point(marker_name: String = "default") -> Node3D:
	if _spawns.has(marker_name):
		return _spawns[marker_name]
	if _spawns.has("default"):
		return _spawns["default"]
	return self

func get_pois() -> Array[Area3D]:
	return _pois

func get_gates() -> Array[Area3D]:
	return _gates

func get_portals() -> Array[Area3D]:
	return _portals

func boss_arena() -> Node3D:
	return _boss_arena

func _build_from_data() -> void:
	if _data == null:
		return

	_clear_dynamic_nodes()
	_apply_environment()
	_build_terrain()
	_build_boundaries()
	_build_spawns()
	_build_pois()
	_build_travel()
	_build_enemies()
	_build_boss()

	var world := Game.get_system(SystemNames.WORLD) as WorldManager
	if world != null:
		world.discover_region(_data.id)

func _clear_dynamic_nodes() -> void:
	_spawns.clear()
	_pois.clear()
	_gates.clear()
	_portals.clear()
	_boss_arena = null

	for root in [_terrain_node, _spawns_node, _structures_node, _travel_node, _enemies_node]:
		if root != null:
			for child in root.get_children():
				child.queue_free()
	if _boundary != null:
		_boundary.queue_free()
		_boundary = null

func _apply_environment() -> void:
	var cont_id := String(_data.continent_id)
	var palette: Dictionary = CONTINENT_PALETTES.get(cont_id, CONTINENT_PALETTES["CONT-01"])

	if _sun_light != null:
		var sun_col_str := String(_data.lighting_profile.get("sun_color", ""))
		_sun_light.light_color = Color.from_string(sun_col_str, palette["sun_color"])
		_sun_light.light_energy = float(_data.lighting_profile.get("sun_energy", 1.2))

	if _env_node != null and _env_node.environment != null:
		var env := _env_node.environment
		var amb_str := String(_data.lighting_profile.get("ambient_color", ""))
		env.ambient_light_color = Color.from_string(amb_str, palette["ambient_color"])
		var fog_str := String(_data.lighting_profile.get("fog_color", ""))
		env.fog_light_color = Color.from_string(fog_str, palette["fog_color"])
		env.fog_density = float(_data.lighting_profile.get("fog_density", 0.012))
		env.fog_enabled = bool(_data.lighting_profile.get("fog_enabled", true))

func _build_terrain() -> void:
	if _terrain_node == null:
		return
	var cont_id := String(_data.continent_id)
	var palette: Dictionary = CONTINENT_PALETTES.get(cont_id, CONTINENT_PALETTES["CONT-01"])
	var radius: float = float(_data.boundaries.get("radius", 150.0))
	var size_x := radius * 2.2
	var size_z := radius * 2.2

	var static_body := StaticBody3D.new()
	static_body.name = "Ground"
	static_body.position.y = -1.0
	_terrain_node.add_child(static_body)

	var mesh_inst := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size_x, 2.0, size_z)
	mesh_inst.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = palette["ground_color"]
	mat.roughness = 0.9
	mesh_inst.material_override = mat
	static_body.add_child(mesh_inst)

	var col_shape := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(size_x, 2.0, size_z)
	col_shape.shape = shape
	static_body.add_child(col_shape)

	# Adiciona elevações decorativas / colinas do bioma
	for i in 3:
		var hill := StaticBody3D.new()
		hill.name = "Hill_%d" % i
		var angle := float(i) * 2.1
		var dist := radius * 0.45
		hill.position = Vector3(cos(angle) * dist, 2.0, sin(angle) * dist)
		_terrain_node.add_child(hill)

		var h_mesh := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 10.0
		cyl.bottom_radius = 20.0
		cyl.height = 4.0
		h_mesh.mesh = cyl
		h_mesh.material_override = mat
		hill.add_child(h_mesh)

		var h_col := CollisionShape3D.new()
		var h_shape := CylinderShape3D.new()
		h_shape.height = 4.0
		h_shape.radius = 20.0
		h_col.shape = h_shape
		hill.add_child(h_col)

func _build_boundaries() -> void:
	var boundary = WorldBoundaryScript.new()
	_boundary = boundary
	_boundary.name = "WorldBoundary"
	_boundary.radius = float(_data.boundaries.get("radius", 150.0))
	add_child(_boundary)

func _build_spawns() -> void:
	if _spawns_node == null:
		return
	# Spawn padrão
	var default_spawn := Marker3D.new()
	default_spawn.name = "Spawn_default"
	default_spawn.position = Vector3(0, 0.2, 0)
	_spawns_node.add_child(default_spawn)
	_spawns["default"] = default_spawn
	_spawns["Spawn_default"] = default_spawn

	# Spawns para cada portão
	for gate: Dictionary in _data.gates:
		var gate_id := String(gate.get("gate_id", ""))
		if gate_id.is_empty():
			continue
		var marker := Marker3D.new()
		marker.name = "Spawn_%s" % gate_id
		var pos: Vector3 = gate.get("position", Vector3.ZERO)
		# Posiciona um pouco à frente do portão
		marker.position = pos * 0.9 + Vector3(0, 0.2, 0)
		_spawns_node.add_child(marker)
		_spawns[gate_id] = marker
		_spawns[marker.name] = marker

	# Spawns para cada portal
	for portal: Dictionary in _data.portals:
		var port_id := String(portal.get("portal_id", ""))
		if port_id.is_empty():
			continue
		var p_marker := Marker3D.new()
		p_marker.name = "Spawn_%s" % port_id
		var p_pos: Vector3 = portal.get("position", Vector3.ZERO)
		p_marker.position = p_pos * 0.9 + Vector3(0, 0.2, 0)
		_spawns_node.add_child(p_marker)
		_spawns[port_id] = p_marker
		_spawns[p_marker.name] = p_marker

func _build_pois() -> void:
	if _structures_node == null:
		return

	for poi_data: Dictionary in _data.points_of_interest:
		var poi = PointOfInterestScript.new()
		poi.name = "POI_%s" % String(poi_data.get("id", "poi"))
		poi.setup(poi_data)
		_structures_node.add_child(poi)
		_pois.append(poi)

		var ptype := String(poi_data.get("type", ""))
		if ptype == "city" or ptype == "camp":
			var safe = SafeZoneScript.new()
			safe.name = "SafeZone"
			safe.radius = float(poi_data.get("radius", 20.0))
			safe.position = poi.position
			_structures_node.add_child(safe)
		elif ptype == "dungeon":
			var dung = DungeonEntranceScript.new()
			dung.name = "DungeonEntrance"
			dung.setup({
				"dungeon_id": poi_data.get("id", ""),
				"dungeon_name": poi_data.get("name", "Masmorra"),
				"position": poi.position,
				"min_level": _data.level_range.x
			})
			_structures_node.add_child(dung)

func _build_travel() -> void:
	if _travel_node == null:
		return

	for gate_data: Dictionary in _data.gates:
		var gate = RegionGateScript.new()
		gate.name = "Gate_%s" % String(gate_data.get("gate_id", "gate"))
		gate.setup(gate_data)
		_travel_node.add_child(gate)
		_gates.append(gate)

	for portal_data: Dictionary in _data.portals:
		var portal = WorldPortalScript.new()
		portal.name = "Portal_%s" % String(portal_data.get("portal_id", "portal"))
		portal.setup(portal_data)
		_travel_node.add_child(portal)
		_portals.append(portal)

func _build_enemies() -> void:
	if _enemies_node == null:
		return

	for spawn_data: Dictionary in _data.enemy_spawns:
		var spawner = EnemySpawnerZoneScript.new()
		spawner.name = "Spawner_%s" % String(spawn_data.get("spawn_id", "spawner"))
		spawner.setup(spawn_data)
		_enemies_node.add_child(spawner)

func _build_boss() -> void:
	if _structures_node == null or _data.boss_encounter_id.is_empty():
		return
	var arena = BossArenaZoneScript.new()
	_boss_arena = arena
	_boss_arena.name = "BossArena"
	var config := _data.boss_arena.duplicate()
	config["boss_id"] = _data.boss_encounter_id
	_boss_arena.setup(config)
	_structures_node.add_child(_boss_arena)
