class_name BossData
extends Resource
## Dados de CHEFE demoníaco (BOSS-001..BOSS-030). NÃO é criatura regional:
## contagens não se sobrepõem com DemonData (BOSS_CATALOG.md).
##
## Catálogo editorial: nomes/lore canônicos NÃO existem na documentação
## (BOSS_CATALOG.md). Nomes editoriais e campos de lore marcados como
## pendentes — nada é inventado.
##
## Modelos: nenhum GLB de chefe existe (verificado em assets/models/).
## `model_pending = true` e cena placeholder identificada para testes.

const RARITIES: PackedStringArray = ["boss", "boss_elite", "boss_final"]

@export var id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
## Identidade narrativa editorial (PENDENTE de lore canônica).
@export var narrative_identity: String = ""
@export var continent_id: StringName = &""
@export var region_id: StringName = &""
## Arena: {name, radius, hazards: PackedStringArray, entrance_marker}.
@export var arena: Dictionary = {}
@export var category: StringName = &"boss"
@export var rarity: StringName = &"boss"
## Atributos de combate (mesmo esquema do DemonData).
@export var stats: Dictionary = {}
@export var resistances: Dictionary = {}
## Habilidades compartilhadas (AbilityData.id) usadas nas fases.
@export var ability_ids: PackedStringArray = PackedStringArray()
## Habilidades especiais (subconjunto de ability_ids).
@export var special_abilities: PackedStringArray = PackedStringArray()
## Fases: Array de {index, at_health_pct, behavior, abilities, animation}.
@export var phases: Array = []
@export var phase_count: int = 1
## Animações exclusivas: {entrance, phase_2, phase_3, death, cast}.
@export var exclusive_animations: Dictionary = {}
## Interface de chefe: {bar_style, name_color, phase_markers, show_cast_bar}.
@export var boss_ui: Dictionary = {}
## Entrada cinematográfica: {cinematic, duration_seconds, camera_move, title_card}.
@export var entrance: Dictionary = {}
## Condições de derrota editoriais (ex.: health_zero).
@export var defeat_conditions: PackedStringArray = PackedStringArray()
## Recompensas: {xp, gold, items, unlocks}.
@export var rewards: Dictionary = {}
@export var model_path: String = ""
@export var model_pending: bool = true
@export var placeholder_scene: String = "res://enemies/boss.tscn"
## Animações do contrato: {idle, walk, attack, hurt, death}.
@export var animations: Dictionary = {}
## Configuração de IA (mesmo esquema do DemonData; fases alteram padrões).
@export var ai: Dictionary = {}

func has_model() -> bool:
	return not model_pending and not model_path.is_empty() and ResourceLoader.exists(model_path)

func health() -> float:
	return float(stats.get("max_health", 1.0))

## Fase ativa para uma fração de vida (1.0 = cheio). Última fase que ainda vale.
func phase_at(health_ratio: float) -> Dictionary:
	var active: Dictionary = {}
	for phase: Dictionary in phases:
		if health_ratio <= float(phase.get("at_health_pct", 1.0)) + 0.0001:
			active = phase
	return active

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"description": description,
		"narrative_identity": narrative_identity,
		"continent_id": String(continent_id),
		"region_id": String(region_id),
		"arena": arena,
		"category": String(category),
		"rarity": String(rarity),
		"stats": stats,
		"resistances": resistances,
		"ability_ids": Array(ability_ids),
		"special_abilities": Array(special_abilities),
		"phases": phases,
		"phase_count": phase_count,
		"exclusive_animations": exclusive_animations,
		"boss_ui": boss_ui,
		"entrance": entrance,
		"defeat_conditions": Array(defeat_conditions),
		"rewards": rewards,
		"model_path": model_path,
		"model_pending": model_pending,
		"placeholder_scene": placeholder_scene,
		"animations": animations,
		"ai": ai,
	}
