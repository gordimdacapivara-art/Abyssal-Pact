class_name AbilityData
extends Resource
## Dados de habilidade — tudo configurável por Resource, sem código por classe.
##
## Campos de combate (cooldown, custo, dano) estão tuneados APENAS no
## protótipo Arcanista; nas demais permanecem com placeholders neutros e
## `pending = true`. Catálogo carregado pelo ClassManager.

## active = ataque básico; special = ataque especial; passive = passiva.
@export var kind: StringName = &"active"
@export var id: StringName = &""
@export var display_name: String = ""
## Classe proprietária (ClassData.id), quando restrita a uma classe.
@export var class_id: StringName = &""
@export var description: String = ""
## true = aguardando decisão de design (não demonstrável).
@export var pending: bool = false
# ------------------------------------------------------------ execução ativa --
@export var cooldown: float = 0.0
@export var cast_time: float = 0.0
@export var range_m: float = 3.0
## &"burst_area" = área na frente do caster (protótipo). Outros modos pendentes.
@export var target_mode: StringName = &"burst_area"
# ------------------------------------------------------------------ recursos --
@export var cost: float = 0.0
@export var cost_resource: StringName = &"mana"
# -------------------------------------------------------------------- combate --
@export var damage: float = 0.0
## Tipo de dano (resistências do alvo consultam este id). Placeholder editorial.
@export var damage_type: StringName = &"abyssal"
# ---------------------------------------------------------------- apresentação --
## Nome de clipe de animação (contrato PlayerAnimator/pipeline). Vazio = pendente.
@export var animation: StringName = &""
## Id de efeito visual (registro editorial). Vazio = usa placeholder neutro.
@export var vfx: StringName = &""
## Efeitos de passiva (Dictionary aberto), ex.: {resource_regeneration_bonus: 0.5}.
@export var passive_effects: Dictionary = {}

func is_active() -> bool:
	return kind == &"active" or kind == &"special"

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"kind": String(kind),
		"class_id": String(class_id),
		"pending": pending,
		"cooldown": cooldown,
		"cast_time": cast_time,
		"range_m": range_m,
		"target_mode": String(target_mode),
		"cost": cost,
		"cost_resource": String(cost_resource),
		"damage": damage,
		"damage_type": String(damage_type),
		"animation": String(animation),
		"vfx": String(vfx),
		"passive_effects": passive_effects,
		"description": description,
	}
