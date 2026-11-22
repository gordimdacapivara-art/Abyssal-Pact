class_name SubraceData
extends Resource
## Dados de sub-raça. Escopo: 80 sub-raças (SUBRACE-001..080), 2 por raça.
## A relação raça-mãe é via parent_race_id (validada no RaceManager).

@export var id: StringName = &""
@export var display_name: String = ""
## Raça-mãe (RaceData.id). Validação: RaceManager.validate_link().
@export var parent_race_id: StringName = &""
## true somente nas duas sub-raças do protótipo visual (RACE-001).
@export var is_prototype: bool = false
## Campos aguardando decisão de design.
@export var pending_fields: PackedStringArray = PackedStringArray()
## Descrição editorial (pendente nas não-protótipo).
@export var description: String = ""
## Diferenças visuais SOBRE o perfil da raça-mãe (Dictionary aberto):
## {body_tint, head_tint, accessories, scale, head_style, ...}. O construtor
## modular mescla profile_da_raça + overrides_da_sub-raça.
@export var visual_overrides: Dictionary = {}
## Animações complementares exclusivas (pendente em todas).
@export var animation_extras: Dictionary = {}

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"parent_race_id": String(parent_race_id),
		"is_prototype": is_prototype,
		"pending_fields": Array(pending_fields),
		"description": description,
		"visual_overrides": visual_overrides,
		"animation_extras": animation_extras,
	}
