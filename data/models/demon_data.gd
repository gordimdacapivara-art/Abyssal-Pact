class_name DemonData
extends Resource
## Dados de demônio REGIONAL (DEMON-001..DEMON-200). NUNCA inclui chefes:
## as categorias não podem se sobrepor (PROJECT_OVERVIEW.md). A sobreposição
## é validada por GameManager.verify_all() via prefixos de Invariants.
##
## Catálogo editorial: nomes canônicos NÃO existem na documentação
## (DEMON_BESTIARY.md). Os registros usam nomes editoriais ("... (editorial)")
## e campos de lore permanecem marcados como pendentes. Nada é inventado.
##
## Modelos: nenhum GLB de criatura existe no projeto (verificado em
## assets/models/). Todo `model_path` é o caminho CONVENCIONAL do pipeline e
## `model_pending = true`; a cena de teste usa placeholder identificado.

## Famílias de combate compartilhadas (reutilizam a MESMA cena/IA).
const FAMILIES: PackedStringArray = ["brute", "stalker", "caster", "swarm", "flyer", "sentinel"]
const RARITIES: PackedStringArray = ["common", "uncommon", "rare", "elite"]

@export var id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
## Continente de ocorrência (ContinentData.id) e região (RegionData.id).
@export var continent_id: StringName = &""
@export var region_id: StringName = &""
## Família de combate (uma das FAMILIES): define componente/IA compartilhada.
@export var family: StringName = &"brute"
## Categoria editorial. Sempre "regional" (chefes vivem no BossData).
@export var category: StringName = &"regional"
## Raridade editorial (common/uncommon/rare/elite).
@export var rarity: StringName = &"common"
## Atributos de combate: max_health, damage, defense, move_speed,
## attack_range, attack_cooldown, xp_reward, gold_reward.
@export var stats: Dictionary = {}
## Resistências por tipo de dano: {tipo: fator multiplicativo} (1.0 = neutro).
@export var resistances: Dictionary = {}
## Habilidades (AbilityData.id) — compartilhadas por família no catálogo.
@export var ability_ids: PackedStringArray = PackedStringArray()
## Recompensas: {xp, gold, items: PackedStringArray}.
@export var rewards: Dictionary = {}
## Caminho CONVENCIONAL do GLB (pipeline): res://assets/models/demons/<id>.glb.
@export var model_path: String = ""
## true quando o GLB ainda não existe no repositório (asset pendente).
@export var model_pending: bool = true
## Cena reutilizável usada enquanto o modelo definitivo não existe.
@export var placeholder_scene: String = "res://enemies/creature.tscn"
## Animações do contrato: {idle, walk, attack, hurt, death} → nome de clipe.
@export var animations: Dictionary = {}
## Configuração de IA (lida pelo componente compartilhado de criatura):
## perception_radius, fov_degrees, aggro_radius, deaggro_radius, leash_radius,
## patrol_radius, move_speed, chase_speed, attack_range, attack_cooldown,
## defend_chance, defend_duration, stunned_duration, respawn_seconds,
## respawn_enabled, return_speed, states.
@export var ai: Dictionary = {}

func has_model() -> bool:
	return not model_pending and not model_path.is_empty() and ResourceLoader.exists(model_path)

func health() -> float:
	return float(stats.get("max_health", 1.0))

func xp_reward() -> int:
	return int(rewards.get("xp", stats.get("xp_reward", 0)))

func gold_reward() -> int:
	return int(rewards.get("gold", stats.get("gold_reward", 0)))

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"description": description,
		"continent_id": String(continent_id),
		"region_id": String(region_id),
		"family": String(family),
		"category": String(category),
		"rarity": String(rarity),
		"stats": stats,
		"resistances": resistances,
		"ability_ids": Array(ability_ids),
		"rewards": rewards,
		"model_path": model_path,
		"model_pending": model_pending,
		"placeholder_scene": placeholder_scene,
		"animations": animations,
		"ai": ai,
	}
