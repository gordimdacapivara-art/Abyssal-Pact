class_name WorldBossData
extends Resource
## WorldBossData — Modelo de dados canônico do único World Boss de Abyssal Pact: Azaroth.
##
## Representa o Titã Abissal com ciclo persistente de 5 horas, 4 fases de combate épico,
## atributos massivos balanceados para cooperação de até 8 jogadores e recompensas míticas.

@export var id: StringName = Invariants.WORLD_BOSS_ID
@export var display_name: String = Invariants.WORLD_BOSS_NAME
@export var title: String = "Titã Abissal Primordial"
@export var description: String = "O único World Boss global de Abyssal Pact. Um titã cósmico de fogo e sombras abissais que emerge ciclicamente a cada 5 horas para devorar a essência do mundo."

@export var max_health: float = Invariants.WORLD_BOSS_MAX_HEALTH
@export var attack_power: float = 850.0
@export var defense: float = 450.0
@export var move_speed: float = 6.5

## Fases de combate (4 fases por thresholds de HP: 100%, 75%, 50%, 25%)
@export var phases: Array = []

## Habilidades especiais utilizadas durante o encontro
@export var ability_ids: PackedStringArray = PackedStringArray([
	"ABIL-BOSS-SLAM",
	"ABIL-BOSS-BEAM",
	"ABIL-BOSS-ENRAGE",
	"ABIL-BOSS-HAZARD",
	"ABIL-BOSS-SUMMON"
])

## Recompensas massivas concedidas na vitória
@export var rewards: Dictionary = {
	"xp": 10000,
	"gold": 5000,
	"title": "Flagelo de Azaroth",
	"mythic_essence": "Essência do Devorador",
	"achievement_id": "ach_world_boss_azaroth_slain"
}

@export var arena_radius: float = 75.0
@export var scale_factor: float = 3.5

## Retorna a definição da fase de combate ativa para uma dada fração de vida [0.0, 1.0]
func phase_at(health_ratio: float) -> Dictionary:
	var active: Dictionary = {}
	for phase: Dictionary in phases:
		if health_ratio <= float(phase.get("at_health_pct", 1.0)) + 0.0001:
			active = phase
	return active

func get_phase_by_index(idx: int) -> Dictionary:
	for phase: Dictionary in phases:
		if int(phase.get("index", 1)) == idx:
			return phase
	return phases[0] if not phases.is_empty() else {}

static func get_ability_metadata(ability_id: StringName) -> Dictionary:
	match ability_id:
		Invariants.ABIL_AZAROTH_TECTONIC_SLAM:
			return {
				"name": "Impacto Tectônico",
				"damage": 450.0,
				"radius": 18.0,
				"telegraph_time": 2.0,
				"is_cone": true,
				"animation": "slam_tectonic",
				"description": "Golpe telúrico massivo frontal que racha o solo e atordoa alvos atingidos."
			}
		Invariants.ABIL_AZAROTH_ABYSSAL_RIFT:
			return {
				"name": "Fenda Abissal",
				"damage": 380.0,
				"radius": 14.0,
				"telegraph_time": 1.8,
				"is_cone": false,
				"animation": "channel_rift",
				"description": "Linhas magmáticas rasgam o terreno, criando campos de magma abrasador."
			}
		Invariants.ABIL_AZAROTH_ABYSSAL_BEAM:
			return {
				"name": "Feixe do Abismo",
				"damage": 580.0,
				"radius": 35.0,
				"telegraph_time": 1.6,
				"is_cone": false,
				"animation": "beam_sweep",
				"description": "Feixe cósmico de fogo sombrio disparado em varredura circular de 360 graus."
			}
		Invariants.ABIL_AZAROTH_MAGMA_RAIN:
			return {
				"name": "Chuva de Magma",
				"damage": 320.0,
				"radius": 8.0,
				"telegraph_time": 1.5,
				"is_cone": false,
				"animation": "magma_rain",
				"description": "Bombardeio piroclástico com múltiplos meteoros caindo telegrafados na arena."
			}
		Invariants.ABIL_AZAROTH_CHAOS_VORTEX:
			return {
				"name": "Vórtice do Caos",
				"damage": 420.0,
				"radius": 28.0,
				"telegraph_time": 1.4,
				"is_cone": false,
				"animation": "channel_vortex",
				"description": "Atração gravitacional centrípeta que puxa todos os jogadores ao epicentro de matéria escura."
			}
		Invariants.ABIL_AZAROTH_VOID_NOVA:
			return {
				"name": "Nova do Vazio",
				"damage": 650.0,
				"radius": 40.0,
				"telegraph_time": 2.2,
				"is_cone": false,
				"animation": "void_nova",
				"description": "Onda de choque radial de trevas cósmicas que requer recuo ou proteção atrás de fendas seladas."
			}
		Invariants.ABIL_AZAROTH_CATACLYSMIC_DEVOUR:
			return {
				"name": "Devoração Cataclísmica",
				"damage": 850.0,
				"radius": 50.0,
				"telegraph_time": 2.5,
				"is_cone": false,
				"animation": "enrage_roar",
				"description": "Canalização primordial de aniquilação total que drena a vida do mundo caso não seja interrompida."
			}
		Invariants.ABIL_AZAROTH_APOCALYPTIC_BARRAGE:
			return {
				"name": "Bombardeio Apocalíptico",
				"damage": 520.0,
				"radius": 22.0,
				"telegraph_time": 1.2,
				"is_cone": false,
				"animation": "apocalyptic_barrage",
				"description": "Sequência frenética de explosões abissais caindo sucessivamente em todos os quadrantes da arena."
			}
		_:
			return {
				"name": "Ataque Abissal",
				"damage": 250.0,
				"radius": 12.0,
				"telegraph_time": 1.5,
				"is_cone": false,
				"animation": "basic_attack",
				"description": "Ataque colossal básico de Azaroth."
			}

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"title": title,
		"description": description,
		"max_health": max_health,
		"attack_power": attack_power,
		"defense": defense,
		"move_speed": move_speed,
		"phases": phases,
		"ability_ids": Array(ability_ids),
		"rewards": rewards,
		"arena_radius": arena_radius,
		"scale_factor": scale_factor,
	}

## Fábrica estática que gera a instância canônica oficial de Azaroth
static func create_canonical() -> Resource:
	var script: GDScript = load("res://data/models/world_boss_data.gd")
	var wb = script.new()
	wb.id = Invariants.WORLD_BOSS_ID
	wb.display_name = Invariants.WORLD_BOSS_NAME
	wb.title = "Titã Abissal Primordial"
	wb.description = "O único World Boss global de Abyssal Pact. Um titã cósmico de fogo e sombras abissais que emerge ciclicamente a cada 5 horas para devorar a essência do mundo."
	wb.max_health = Invariants.WORLD_BOSS_MAX_HEALTH
	wb.attack_power = 850.0
	wb.defense = 450.0
	wb.move_speed = 6.5
	wb.arena_radius = 75.0
	wb.scale_factor = 3.5

	wb.phases = [
		{
			"index": 1,
			"name": "Ascensão da Fenda",
			"at_health_pct": 1.0,
			"behavior": &"tectonic_awakening",
			"animation": "slam_tectonic",
			"abilities": PackedStringArray([String(Invariants.ABIL_AZAROTH_TECTONIC_SLAM), String(Invariants.ABIL_AZAROTH_ABYSSAL_RIFT)]),
			"damage_mult": Invariants.AZAROTH_P1_DMG_MULT,
			"speed_mult": Invariants.AZAROTH_P1_SPEED_MULT,
			"attack_cooldown": 4.0,
			"telegraph_duration": 2.2,
			"army_command": "patrol_flank",
			"description": "Azaroth emerge da fenda dimensional desferindo ondas de choque tectônicas e comandando patrulhas de infantaria."
		},
		{
			"index": 2,
			"name": "Fúria Vulcânica",
			"at_health_pct": 0.75,
			"behavior": &"volcanic_eruption",
			"animation": "beam_sweep",
			"abilities": PackedStringArray([String(Invariants.ABIL_AZAROTH_TECTONIC_SLAM), String(Invariants.ABIL_AZAROTH_ABYSSAL_BEAM), String(Invariants.ABIL_AZAROTH_MAGMA_RAIN)]),
			"damage_mult": Invariants.AZAROTH_P2_DMG_MULT,
			"speed_mult": Invariants.AZAROTH_P2_SPEED_MULT,
			"attack_cooldown": 3.2,
			"telegraph_duration": 1.8,
			"army_command": "summon_superiors",
			"description": "Chamas abissais inflamam o titã, disparando feixes cósmicos, chuvas de magma e convocando comandantes superiores."
		},
		{
			"index": 3,
			"name": "Tempestade do Caos",
			"at_health_pct": 0.50,
			"behavior": &"chaos_vortex",
			"animation": "channel_vortex",
			"abilities": PackedStringArray([String(Invariants.ABIL_AZAROTH_CHAOS_VORTEX), String(Invariants.ABIL_AZAROTH_VOID_NOVA), String(Invariants.ABIL_AZAROTH_ABYSSAL_BEAM)]),
			"damage_mult": Invariants.AZAROTH_P3_DMG_MULT,
			"speed_mult": Invariants.AZAROTH_P3_SPEED_MULT,
			"attack_cooldown": 2.5,
			"telegraph_duration": 1.5,
			"army_command": "accelerate_primordials",
			"description": "Vórtices de matéria escura atraem os jogadores enquanto fendas aceleradas liberam colossos primordiais."
		},
		{
			"index": 4,
			"name": "O Devorador Despertado",
			"at_health_pct": 0.25,
			"behavior": &"primordial_enrage",
			"animation": "enrage_roar",
			"abilities": PackedStringArray([String(Invariants.ABIL_AZAROTH_CATACLYSMIC_DEVOUR), String(Invariants.ABIL_AZAROTH_APOCALYPTIC_BARRAGE), String(Invariants.ABIL_AZAROTH_TECTONIC_SLAM), String(Invariants.ABIL_AZAROTH_VOID_NOVA)]),
			"damage_mult": Invariants.AZAROTH_P4_DMG_MULT,
			"speed_mult": Invariants.AZAROTH_P4_SPEED_MULT,
			"attack_cooldown": 1.8,
			"telegraph_duration": 1.2,
			"army_command": "army_frenzy",
			"description": "Enrage primordial total: canalização apocalíptica contínua e todo o exército em investida frenética suicida."
		}
	]

	wb.ability_ids = PackedStringArray([
		String(Invariants.ABIL_AZAROTH_TECTONIC_SLAM),
		String(Invariants.ABIL_AZAROTH_ABYSSAL_RIFT),
		String(Invariants.ABIL_AZAROTH_ABYSSAL_BEAM),
		String(Invariants.ABIL_AZAROTH_MAGMA_RAIN),
		String(Invariants.ABIL_AZAROTH_CHAOS_VORTEX),
		String(Invariants.ABIL_AZAROTH_VOID_NOVA),
		String(Invariants.ABIL_AZAROTH_CATACLYSMIC_DEVOUR),
		String(Invariants.ABIL_AZAROTH_APOCALYPTIC_BARRAGE)
	])

	wb.rewards = {
		"xp": 10000,
		"gold": 5000,
		"title": "Flagelo de Azaroth",
		"mythic_essence": "Essência do Devorador",
		"achievement_id": "ach_world_boss_azaroth_slain"
	}

	return wb
