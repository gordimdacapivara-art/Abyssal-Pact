class_name Combatant
extends Node
## Componente de vida/recurso/resistências (camada de cena, NÃO gerenciador).
##
## Subconjunto mínimo do combate usado pelo protótipo de classes: vida, recurso
## (regeneração), resistências por tipo de dano, morte com sinal único e
## ressurgimento. O sistema de combate completo (bloqueio, esquiva integrada,
## efeitos de estado, hitboxes dedicadas) é o próximo passo documentado.

signal health_changed(current: float, maximum: float)
signal resource_changed(current: float, maximum: float)
signal damaged(amount: float, damage_type: StringName)
signal died()

@export var max_health: float = 100.0
@export var max_resource: float = 100.0
@export var resource_regeneration: float = 4.0
## StringName do tipo de dano → fator multiplicativo (1.0 = sem resistência).
@export var resistances: Dictionary = {}
## Reação de impacto: trava curta de controle (s) — placeholder até o combate.
@export var stagger_time: float = 0.15

var health: float = 100.0
var resource: float = 100.0
var resource_regeneration_bonus: float = 0.0
var is_dead: bool = false

var _stagger: float = 0.0
var _died_emitted: bool = false

func _ready() -> void:
	health = max_health
	resource = max_resource

func _process(delta: float) -> void:
	if _stagger > 0.0:
		_stagger = maxf(_stagger - delta, 0.0)
	if not is_dead and resource < max_resource and resource_regeneration + resource_regeneration_bonus > 0.0:
		resource = minf(resource + (resource_regeneration + resource_regeneration_bonus) * delta, max_resource)
		resource_changed.emit(resource, max_resource)

## true quando em reação de impacto (trava curta).
func is_staggered() -> bool:
	return _stagger > 0.0

## Aplica dano bruto; retorna o dano EFETIVO (após resistência). 0 se morto.
func take_damage(amount: float, damage_type: StringName = &"physical") -> float:
	if is_dead or amount <= 0.0:
		return 0.0
	var factor := 1.0
	if resistances.has(String(damage_type)):
		factor = float(resistances[String(damage_type)])
	var effective := amount * factor
	health = maxf(health - effective, 0.0)
	_stagger = stagger_time
	health_changed.emit(health, max_health)
	damaged.emit(effective, damage_type)
	if health <= 0.0 and not _died_emitted:
		_died_emitted = true
		is_dead = true
		died.emit()
		# Ponte para o domínio: EventBus espera o id da ENTIDADE (pai).
		var entity := get_parent()
		EventBus.target_died.emit(entity.get_instance_id() if entity != null else get_instance_id())
	return effective

## Gasta recurso; false quando insuficiente (cast recusado).
func spend_resource(cost: float, resource_type: StringName = &"mana") -> bool:
	if is_dead or cost < 0.0 or resource < cost:
		return false
	resource = maxf(resource - cost, 0.0)
	resource_changed.emit(resource, max_resource)
	return true

## Restaura vida/recurso (protótipo: ressurgimento instantâneo do alvo).
func respawn() -> void:
	is_dead = false
	_died_emitted = false
	health = max_health
	resource = max_resource
	health_changed.emit(health, max_health)
	resource_changed.emit(resource, max_resource)
