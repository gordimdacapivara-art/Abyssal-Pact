class_name RegionPOISystem
extends RefCounted
## Sistema 11: Sistema de Pontos de Interesse (POIs) e Interações de Região.
## Constrói e padroniza a instanciação de Cidades/Zonas Seguras, Masmorras,
## Arenas de Chefes, Marcos de Exploração, Portais Dimensionais e Portões Regionais.

static func create_safe_zone(parent: Node3D, zone_name: String, pos: Vector3, radius: float = 22.0) -> SafeZone:
	var sz := SafeZone.new()
	sz.name = "SafeZone"
	sz.zone_name = zone_name
	sz.radius = radius
	sz.transform.origin = pos
	parent.add_child(sz)
	return sz

static func create_poi(parent: Node3D, poi_data: Dictionary) -> PointOfInterest:
	var poi := PointOfInterest.new()
	var poi_id := StringName(String(poi_data.get("id", "poi_unknown")))
	poi.name = "POI_" + String(poi_id)
	poi.setup(poi_data)
	parent.add_child(poi)
	return poi

static func create_dungeon_entrance(parent: Node3D, dungeon_id: StringName, dungeon_name: String, pos: Vector3, min_level: int = 1) -> DungeonEntrance:
	var dungeon := DungeonEntrance.new()
	dungeon.name = "DungeonEntrance_" + String(dungeon_id)
	dungeon.dungeon_id = dungeon_id
	dungeon.dungeon_name = dungeon_name
	dungeon.min_level = min_level
	dungeon.transform.origin = pos
	parent.add_child(dungeon)
	return dungeon

static func create_boss_arena(parent: Node3D, boss_id: StringName, arena_name: String, pos: Vector3, radius: float = 18.0) -> BossArenaZone:
	var arena := BossArenaZone.new()
	arena.name = "BossArena"
	arena.boss_id = boss_id
	arena.arena_name = arena_name
	arena.radius = radius
	arena.transform.origin = pos
	parent.add_child(arena)
	return arena

static func create_exploration_spot(parent: Node3D, spot_id: StringName, spot_name: String, pos: Vector3, xp: int = 75) -> ExplorationSpot:
	var spot := ExplorationSpot.new()
	spot.name = "ExplorationSpot_" + String(spot_id)
	spot.spot_id = spot_id
	spot.spot_name = spot_name
	spot.discovery_xp = xp
	spot.transform.origin = pos
	parent.add_child(spot)
	return spot

static func create_region_gate(parent: Node3D, gate_id: StringName, target_reg: StringName, target_spawn: StringName, display_name: String, pos: Vector3, radius: float = 5.0) -> RegionGate:
	var gate := RegionGate.new()
	gate.name = "Gate_" + String(gate_id)
	gate.gate_id = gate_id
	gate.target_region = target_reg
	gate.target_spawn = target_spawn
	gate.display_name = display_name
	gate.radius = radius
	gate.transform.origin = pos
	parent.add_child(gate)
	return gate

static func create_world_portal(parent: Node3D, portal_id: StringName, target_reg: StringName, target_spawn: StringName, display_name: String, pos: Vector3, is_intercontinental: bool = false, radius: float = 3.5) -> WorldPortal:
	var portal := WorldPortal.new()
	portal.name = "Portal_" + String(portal_id)
	portal.portal_id = portal_id
	portal.target_region = target_reg
	portal.target_spawn = target_spawn
	portal.display_name = display_name
	portal.is_intercontinental = is_intercontinental
	portal.activation_radius = radius
	portal.transform.origin = pos
	parent.add_child(portal)
	return portal
