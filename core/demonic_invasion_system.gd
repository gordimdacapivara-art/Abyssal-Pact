class_name DemonicInvasionSystem
extends Node
## DemonicInvasionSystem — Sistema de Invasão do Exército de Azaroth (PROMPT 04).
##
## Responsabilidade:
##   1. Transformar a região selecionada em território ameaçado com corrupção demoníaca.
##   2. Gerenciar a Primeira Fase (A Corrupção): fendas pelo território, atmosfera progressiva,
##      emergência física de criaturas do solo, demônios inferiores/superiores e emboscadas táticas.
##   3. Gerenciar a Segunda Fase (Expansão da Invasão): intensidade elevada, reforços contínuos,
##      fendas de grande perigo com dano em área, criaturas primordiais fortalecidas e pressão multidirecional.
##   4. Manter a Hierarquia Militar: Inferiores (comuns), Superiores (tropas de elite com habilidades,
##      NÃO são chefes individuais) e Primordiais (fortalecidos com auras e atributos massivos).
##   5. Todas as unidades obrigatoriamente integram o exército de Azaroth (ARMY_AZAROTH).

enum Phase {
	DORMANT = 0,    ## Região pacífica / sem invasão ativa
	CORRUPTION = 1, ## Primeira Fase: A Corrupção
	EXPANSION = 2,  ## Segunda Fase: Expansão da Invasão
	CULMINATION = 3,## Culminação: Azaroth no campo
	CLEANSED = 4    ## Território expurgado
}

enum MilitaryRank {
	INFERIOR = 0,
	SUPERIOR = 1,
	PRIMORDIAL = 2
}

const FissureScript := preload("res://scenes/world/components/demonic_fissure.gd")
const UnitDataScript := preload("res://data/models/invasion_army_unit_data.gd")

const BASE_FOG_DENSITY := 0.008
const CORRUPTION_FOG_DENSITY := 0.022
const EXPANSION_FOG_DENSITY := 0.045

const BASE_FOG_COLOR := Color(0.28, 0.16, 0.18)
const CORRUPTION_FOG_COLOR := Color(0.38, 0.14, 0.16)
const EXPANSION_FOG_COLOR := Color(0.55, 0.08, 0.10)

var _current_phase: Phase = Phase.DORMANT
var _target_region: StringName = &"REG-001"
var _corruption_level: float = 0.0 # [0.0, 1.0]
var _active_fissures: Dictionary = {} # StringName(fissure_id) -> DemonicFissure
var _active_army_units: Dictionary = {} # StringName(unit_id) -> InvasionArmyUnitData
var _unit_counter: int = 0
var _fissure_counter: int = 0

var _reinforcement_timer: float = 0.0
const REINFORCEMENT_INTERVAL: float = 12.0 # Segundos entre ondas de reforço

var _ambush_cooldown: float = 0.0
const AMBUSH_INTERVAL: float = 35.0 # Segundos entre potenciais emboscadas

var _pincer_cooldown: float = 0.0
const PINCER_INTERVAL: float = 45.0 # Segundos entre investidas em pinça (Fase 2)

var _fog_density: float = BASE_FOG_DENSITY
var _fog_color: Color = BASE_FOG_COLOR
var _sky_corruption_ratio: float = 0.0

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	set_process(true)

# ------------------------------------------------------------- CONTROLE DE FASES --

## Inicia a invasão demoníaca na região designada pelo World Boss
func start_invasion(region_id: StringName, initial_phase: Phase = Phase.CORRUPTION) -> void:
	_target_region = region_id
	set_phase(initial_phase)

## Altera a fase da invasão do exército de Azaroth
func set_phase(new_phase: Phase) -> void:
	if _current_phase == new_phase:
		return

	var prev := _current_phase
	_current_phase = new_phase

	match new_phase:
		Phase.CORRUPTION:
			_corruption_level = 0.3
			_fog_density = CORRUPTION_FOG_DENSITY
			_fog_color = CORRUPTION_FOG_COLOR
			_sky_corruption_ratio = 0.4
			_ensure_initial_fissures(3)
			EventBus.notification_requested.emit("ALERTA: Corrupção demoníaca detectada em %s! O exército de Azaroth avança!" % _target_region)

		Phase.EXPANSION:
			_corruption_level = 0.75
			_fog_density = EXPANSION_FOG_DENSITY
			_fog_color = EXPANSION_FOG_COLOR
			_sky_corruption_ratio = 0.85
			_expand_all_fissures()
			_ensure_initial_fissures(6)
			_spawn_primordials_for_expansion(2)
			EventBus.notification_requested.emit("PERIGO EXTREMO: Expansão da invasão em %s! Criaturas primordiais emergiram!" % _target_region)

		Phase.CULMINATION:
			_corruption_level = 1.0
			_fog_density = EXPANSION_FOG_DENSITY * 1.2
			_fog_color = EXPANSION_FOG_COLOR
			_sky_corruption_ratio = 1.0

		Phase.CLEANSED, Phase.DORMANT:
			cleanse_invasion()

	EventBus.invasion_phase_changed.emit(_target_region, int(prev), int(new_phase))
	EventBus.region_corruption_level_changed.emit(_target_region, _corruption_level, _fog_density)

func get_current_phase() -> Phase:
	return _current_phase

func get_phase_name(p: Phase = _current_phase) -> String:
	match p:
		Phase.DORMANT: return "Dormência / Pacífico"
		Phase.CORRUPTION: return "Primeira Fase: A Corrupção"
		Phase.EXPANSION: return "Segunda Fase: Expansão da Invasão"
		Phase.CULMINATION: return "Culminação: Azaroth no Campo"
		Phase.CLEANSED: return "Território Expurgado"
		_: return "Desconhecido"

func get_corruption_level() -> float:
	return _corruption_level

func get_target_region() -> StringName:
	return _target_region

func get_fog_density() -> float:
	return _fog_density

func get_fog_color() -> Color:
	return _fog_color

# -------------------------------------------------------- FENDAS DEMONÍACAS --

## Abre uma fenda demoníaca no terreno da região invadida
func open_demonic_fissure(fissure_pos: Vector3, threat_level: int = 1) -> Node:
	_fissure_counter += 1
	var f_id := StringName("FISSURE-%03d" % _fissure_counter)

	var fissure: Node = FissureScript.new()
	fissure.name = String(f_id)
	add_child(fissure)
	fissure.call("setup", f_id, _target_region, fissure_pos, threat_level)

	_active_fissures[f_id] = fissure
	EventBus.demonic_fissure_opened.emit(f_id, _target_region, fissure_pos, threat_level)
	return fissure

func get_active_fissures() -> Array:
	var result: Array = []
	for f in _active_fissures.values():
		if is_instance_valid(f) and bool(f.call("is_active")):
			result.append(f)
	return result

func get_fissures_count() -> int:
	return get_active_fissures().size()

func _ensure_initial_fissures(target_count: int) -> void:
	var current_count := get_fissures_count()
	var needed := target_count - current_count
	if needed <= 0:
		return

	for i in range(needed):
		var angle := randf() * TAU
		var dist := randf_range(30.0, 110.0)
		var f_pos := Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
		var threat := 2 if _current_phase == Phase.EXPANSION else 1
		open_demonic_fissure(f_pos, threat)

func _expand_all_fissures() -> void:
	for f in _active_fissures.values():
		if is_instance_valid(f):
			f.call("expand_threat")

# -------------------------------------------------------- HIERARQUIA MILITAR --

## Cria e registra uma nova unidade militar do exército de Azaroth
func spawn_army_unit(
	rank: int,
	spawn_pos: Vector3,
	emerge_from_ground: bool = true,
	base_demon: DemonData = null
) -> Resource:
	_unit_counter += 1
	var prefix := "INF"
	match rank:
		MilitaryRank.SUPERIOR: prefix = "SUP"
		MilitaryRank.PRIMORDIAL: prefix = "PRI"

	var unit_id := StringName("ARMY-%s-%04d" % [prefix, _unit_counter])
	var unit: Resource = UnitDataScript.create_army_unit(unit_id, rank, _target_region, base_demon)

	if emerge_from_ground and unit != null:
		unit.call("start_emergence")

	_active_army_units[unit_id] = unit
	EventBus.invasion_unit_emerged.emit(unit_id, rank, spawn_pos, Invariants.AZAROTH_ARMY_FACTION)
	return unit

func get_active_units() -> Array:
	return _active_army_units.values()

func get_units_count() -> int:
	return _active_army_units.size()

func get_units_by_rank(rank: int) -> Array:
	var res: Array = []
	for u in _active_army_units.values():
		if u != null and int(u.get("military_rank")) == rank:
			res.append(u)
	return res

func get_inferior_units() -> Array:
	return get_units_by_rank(MilitaryRank.INFERIOR)

func get_superior_units() -> Array:
	return get_units_by_rank(MilitaryRank.SUPERIOR)

func get_primordial_units() -> Array:
	return get_units_by_rank(MilitaryRank.PRIMORDIAL)

# ---------------------------------------------------- TÁTICAS: EMBOSCADAS & PINÇA --

## Desencadeia uma emboscada tática coordenada de demônios inferiores e superiores (Fase 1)
func trigger_ambush(player_pos: Vector3, squad_size: int = 4) -> Array:
	if _current_phase == Phase.DORMANT or _current_phase == Phase.CLEANSED:
		return []

	var squad: Array = []
	# Distribuição: 75% inferiores, 25% superiores
	var superiors_count := maxi(1, squad_size / 3)
	var inferiors_count := squad_size - superiors_count

	# Ângulo de flanqueamento (arco atrás ou ao lado dos jogadores)
	var base_angle := randf() * TAU
	for i in range(inferiors_count):
		var offset_angle := base_angle + randf_range(-0.8, 0.8)
		var dist := randf_range(12.0, 22.0)
		var spawn_pos := player_pos + Vector3(cos(offset_angle) * dist, 0.0, sin(offset_angle) * dist)
		var unit: Resource = spawn_army_unit(MilitaryRank.INFERIOR, spawn_pos, true)
		squad.append(unit)

	for i in range(superiors_count):
		var offset_angle := base_angle + randf_range(-0.4, 0.4)
		var dist := randf_range(15.0, 25.0)
		var spawn_pos := player_pos + Vector3(cos(offset_angle) * dist, 0.0, sin(offset_angle) * dist)
		var unit: Resource = spawn_army_unit(MilitaryRank.SUPERIOR, spawn_pos, true)
		squad.append(unit)

	EventBus.invasion_ambush_triggered.emit(squad_size, player_pos)
	EventBus.notification_requested.emit("EMBOSCADA DEMONÍACA! O exército de Azaroth cerca sua posição!")
	return squad

## Desencadeia uma investida em pinça com pressão simultânea de múltiplas direções (Fase 2)
func trigger_pincer_assault(player_pos: Vector3, directions_count: int = 3, units_per_dir: int = 2) -> Array:
	if _current_phase != Phase.EXPANSION and _current_phase != Phase.CULMINATION:
		return []

	var all_assault_units: Array = []
	var angle_step := TAU / float(directions_count)

	for d in range(directions_count):
		var cardinal_angle := d * angle_step + randf_range(-0.2, 0.2)
		for u in range(units_per_dir):
			var dist := randf_range(18.0, 32.0) + (u * 4.0)
			var spawn_pos := player_pos + Vector3(cos(cardinal_angle) * dist, 0.0, sin(cardinal_angle) * dist)
			# Na investida em pinça: alterna entre Superior e Inferior, e 1 Primordial de vanguarda
			var rank := MilitaryRank.INFERIOR
			if d == 0 and u == 0:
				rank = MilitaryRank.PRIMORDIAL
			elif u == 0:
				rank = MilitaryRank.SUPERIOR
			var unit: Resource = spawn_army_unit(rank, spawn_pos, true)
			all_assault_units.append(unit)

	EventBus.invasion_pincer_assault_triggered.emit(directions_count, player_pos)
	EventBus.notification_requested.emit("CERCO TOTAL! O exército de Azaroth ataca de múltiplas direções simultâneas!")
	return all_assault_units

func _spawn_primordials_for_expansion(count: int = 2) -> void:
	for i in range(count):
		var angle := randf() * TAU
		var dist := randf_range(40.0, 80.0)
		var pos := Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
		spawn_army_unit(MilitaryRank.PRIMORDIAL, pos, true)

# ------------------------------------------------------------- GAME LOOP --

## Avança a simulação da invasão e gerencia reforços e perigos
func advance_invasion(delta: float, player_positions: Array = []) -> void:
	if _current_phase == Phase.DORMANT or _current_phase == Phase.CLEANSED:
		return

	# 1. Avança subida física das unidades emergindo do chão
	for u in _active_army_units.values():
		if u != null and bool(u.get("is_emerging")):
			u.call("advance_emergence", delta)

	# 2. Perigo ativo das fendas (dano corrosivo aos jogadores próximos em Fase 2)
	if _current_phase == Phase.EXPANSION or _current_phase == Phase.CULMINATION:
		for f in _active_fissures.values():
			if is_instance_valid(f) and bool(f.call("is_active")):
				f.call("deal_hazard_damage", delta, player_positions)

	# 3. Temporizadores táticos
	_reinforcement_timer += delta
	if _reinforcement_timer >= REINFORCEMENT_INTERVAL:
		_reinforcement_timer = 0.0
		_dispatch_reinforcements()

	_ambush_cooldown += delta
	_pincer_cooldown += delta

	# Disparo de emboscadas e pinça caso jogadores estejam presentes
	if not player_positions.is_empty():
		var p_first: Vector3 = player_positions[0] if player_positions[0] is Vector3 else Vector3.ZERO
		if _current_phase == Phase.CORRUPTION and _ambush_cooldown >= AMBUSH_INTERVAL:
			_ambush_cooldown = 0.0
			trigger_ambush(p_first, 4)
		elif _current_phase == Phase.EXPANSION and _pincer_cooldown >= PINCER_INTERVAL:
			_pincer_cooldown = 0.0
			trigger_pincer_assault(p_first, 3, 2)

func _dispatch_reinforcements() -> void:
	var fissures := get_active_fissures()
	if fissures.is_empty():
		return

	# Em Fase 1: reforços leves; Em Fase 2: reforços pesados
	var reinforcements_count := 2 if _current_phase == Phase.CORRUPTION else 4
	for i in range(reinforcements_count):
		var target_fissure: Node = fissures[randi() % fissures.size()]
		var rank := MilitaryRank.INFERIOR
		var roll := randf()
		if _current_phase == Phase.EXPANSION:
			if roll > 0.65:
				rank = MilitaryRank.SUPERIOR
			elif roll > 0.90:
				rank = MilitaryRank.PRIMORDIAL
		else:
			if roll > 0.75:
				rank = MilitaryRank.SUPERIOR

		var f_origin: Vector3 = target_fissure.global_position if target_fissure.is_inside_tree() else target_fissure.position
		var spawn_pos: Vector3 = f_origin + Vector3(randf_range(-3.0, 3.0), 0.0, randf_range(-3.0, 3.0))
		spawn_army_unit(rank, spawn_pos, true)

## Aplica os efeitos de corrupção atmosférica no WorldEnvironment ativo
func apply_atmosphere_corruption(world_environment: WorldEnvironment) -> void:
	if world_environment == null or world_environment.environment == null:
		return
	var env := world_environment.environment
	env.fog_enabled = true
	env.fog_density = _fog_density
	env.fog_light_color = _fog_color

	if env.sky != null and env.sky.sky_material is ProceduralSkyMaterial:
		var sky_mat := env.sky.sky_material as ProceduralSkyMaterial
		var lerp_r := clampf(_sky_corruption_ratio, 0.0, 1.0)
		sky_mat.sky_top_color = sky_mat.sky_top_color.lerp(Color(0.45, 0.08, 0.12), lerp_r)
		sky_mat.sky_horizon_color = sky_mat.sky_horizon_color.lerp(Color(0.65, 0.15, 0.08), lerp_r)

## Limpa a invasão e expurga o território
func cleanse_invasion() -> void:
	_current_phase = Phase.CLEANSED
	_corruption_level = 0.0
	_fog_density = BASE_FOG_DENSITY
	_fog_color = BASE_FOG_COLOR
	_sky_corruption_ratio = 0.0

	for f in _active_fissures.values():
		if is_instance_valid(f):
			f.call("seal")
			f.queue_free()
	_active_fissures.clear()
	_active_army_units.clear()
	EventBus.region_corruption_level_changed.emit(_target_region, 0.0, BASE_FOG_DENSITY)

# ---------------------------------------------------------------- PERSISTÊNCIA --

func collect_save_data() -> Dictionary:
	var fissures_data: Array = []
	for f in _active_fissures.values():
		if is_instance_valid(f) and bool(f.call("is_active")):
			var f_pos: Vector3 = f.global_position if f.is_inside_tree() else f.position
			fissures_data.append({
				"id": String(f.fissure_id),
				"threat": int(f.threat_level),
				"pos": [f_pos.x, f_pos.y, f_pos.z]
			})

	var units_data: Array = []
	for u in _active_army_units.values():
		if u != null and u.has_method("to_dict"):
			units_data.append(u.call("to_dict"))

	return {
		"phase": int(_current_phase),
		"target_region": String(_target_region),
		"corruption_level": _corruption_level,
		"fog_density": _fog_density,
		"fissures": fissures_data,
		"units": units_data,
		"unit_counter": _unit_counter,
		"fissure_counter": _fissure_counter
	}

func apply_save_data(data: Dictionary) -> void:
	if data.is_empty():
		return

	_current_phase = int(data.get("phase", int(Phase.DORMANT))) as Phase
	_target_region = StringName(data.get("target_region", "REG-001"))
	_corruption_level = float(data.get("corruption_level", 0.0))
	_fog_density = float(data.get("fog_density", BASE_FOG_DENSITY))
	_unit_counter = int(data.get("unit_counter", 0))
	_fissure_counter = int(data.get("fissure_counter", 0))

	# Recria fendas salvas
	for f in _active_fissures.values():
		if is_instance_valid(f):
			f.queue_free()
	_active_fissures.clear()

	var fissures_arr: Array = data.get("fissures", [])
	for fd in fissures_arr:
		var pos_arr: Array = fd.get("pos", [0, 0, 0])
		var pos := Vector3(float(pos_arr[0]), float(pos_arr[1]), float(pos_arr[2]))
		open_demonic_fissure(pos, int(fd.get("threat", 1)))

	EventBus.invasion_phase_changed.emit(_target_region, int(Phase.DORMANT), int(_current_phase))
