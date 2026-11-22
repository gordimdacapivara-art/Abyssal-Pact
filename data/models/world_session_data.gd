class_name WorldSessionData
extends Resource
## Estado de um mundo privado ativo. Regras codificadas:
##   - participantes ≤ Invariants.MAX_PARTICIPANTS (8, anfitrião incluído);
##   - sessões são privadas: não há matchmaking/listas públicas;
##   - ressurgimento resolve sempre para Invariants.HUB_REGION_ID (Hell Forge);
##   - persistência de exploração de mundo aberto: regiões descobertas, POIs e portais.

var world_id: StringName = &""
var world_name: String = ""
var host_participant: int = Invariants.HOST_PEER_ID
var participants: PackedInt64Array = PackedInt64Array()
## Região atual do grupo. &"" quando o grupo ainda não viajou.
var region_id: StringName = &""
## Ressurgimentos pendentes de posicionamento (participant -> hub_id).
var pending_respawns: Dictionary = {} # String(participant) -> String(hub_id)

## Estado de exploração persistente da sessão:
var discovered_regions: PackedStringArray = PackedStringArray()
var discovered_pois: PackedStringArray = PackedStringArray()
var activated_portals: PackedStringArray = PackedStringArray()
var last_spawn_marker: String = "default"

func has_participant(participant: int) -> bool:
	return participants.has(participant)

func participant_count() -> int:
	return participants.size()

func can_accept_participant() -> bool:
	return participants.size() < Invariants.MAX_PARTICIPANTS

func discover_region(target_region: StringName) -> bool:
	var key := String(target_region)
	if discovered_regions.has(key):
		return false
	discovered_regions.append(key)
	return true

func is_region_discovered(target_region: StringName) -> bool:
	return discovered_regions.has(String(target_region))

func discover_poi(poi_id: StringName) -> bool:
	var key := String(poi_id)
	if discovered_pois.has(key):
		return false
	discovered_pois.append(key)
	return true

func is_poi_discovered(poi_id: StringName) -> bool:
	return discovered_pois.has(String(poi_id))

func activate_portal(portal_id: StringName) -> bool:
	var key := String(portal_id)
	if activated_portals.has(key):
		return false
	activated_portals.append(key)
	return true

func is_portal_activated(portal_id: StringName) -> bool:
	return activated_portals.has(String(portal_id))

func to_dict() -> Dictionary:
	var pending: Dictionary = {}
	for participant: String in pending_respawns.keys():
		pending[participant] = String(pending_respawns[participant])
	return {
		"world_id": String(world_id),
		"world_name": world_name,
		"host_participant": host_participant,
		"participants": Array(participants),
		"region_id": String(region_id),
		"pending_respawns": pending,
		"discovered_regions": Array(discovered_regions),
		"discovered_pois": Array(discovered_pois),
		"activated_portals": Array(activated_portals),
		"last_spawn_marker": last_spawn_marker,
	}

func from_dict(data: Dictionary) -> bool:
	if not data.has("world_id"):
		return false
	world_id = StringName(String(data.get("world_id", "")))
	world_name = String(data.get("world_name", ""))
	host_participant = int(data.get("host_participant", Invariants.HOST_PEER_ID))
	participants = PackedInt64Array(data.get("participants", []))
	region_id = StringName(String(data.get("region_id", "")))
	pending_respawns = {}
	var pending: Dictionary = data.get("pending_respawns", {})
	for participant: String in pending.keys():
		pending_respawns[participant] = String(pending[participant])
	discovered_regions = PackedStringArray(data.get("discovered_regions", []))
	discovered_pois = PackedStringArray(data.get("discovered_pois", []))
	activated_portals = PackedStringArray(data.get("activated_portals", []))
	last_spawn_marker = String(data.get("last_spawn_marker", "default"))
	return true
