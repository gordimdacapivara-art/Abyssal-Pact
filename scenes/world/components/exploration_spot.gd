class_name ExplorationSpot
extends Node3D
## Ponto de exploração específico: monólitos, mirantes e altares que concedem descobertas.

signal spot_visited(spot_id: StringName, spot_name: String)

@export var spot_id: StringName = &"exp_001"
@export var spot_name: String = "Monólito do Primeiro Pacto"
@export var discovery_xp: int = 75

var _poi: PointOfInterest = null

func _ready() -> void:
	_build()

func setup(config: Dictionary) -> void:
	spot_id = StringName(String(config.get("id", spot_id)))
	spot_name = String(config.get("name", spot_name))
	discovery_xp = int(config.get("xp", discovery_xp))
	if config.has("position") and config["position"] is Vector3:
		position = config["position"]
	_build()

func _build() -> void:
	for child in get_children():
		child.queue_free()

	# Obelisco de pedra
	var obelisk := MeshInstance3D.new()
	obelisk.name = "Obelisk"
	var prism := CylinderMesh.new()
	prism.top_radius = 0.3
	prism.bottom_radius = 0.8
	prism.height = 4.5
	obelisk.mesh = prism
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.18, 0.25)
	mat.emission_enabled = true
	mat.emission = Color(0.4, 0.2, 0.6) * 0.4
	obelisk.material_override = mat
	obelisk.position.y = 2.25
	add_child(obelisk)

	# POI embutido
	_poi = PointOfInterest.new()
	_poi.name = "POI"
	_poi.poi_id = spot_id
	_poi.poi_name = spot_name
	_poi.poi_type = "exploration"
	_poi.discovery_xp = discovery_xp
	_poi.discovered.connect(func(id: StringName, n: String, _t: String) -> void: spot_visited.emit(id, n))
	add_child(_poi)
