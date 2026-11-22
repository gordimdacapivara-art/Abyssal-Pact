class_name ClassData
extends Resource
## Dados de classe — 80 registros (CLASS-001..CLASS-080, CLASSES.md).
##
## Sistema baseado em dados: registrar/carregar/configurar/evoluir qualquer
## classe sem modificar código central. Campos PENDENTES de design ficam
## marcados em `pending_fields` — NADA é inventado para preencher lacunas.
##
## Organização editorial: 8 grupos de 10 classes (CLASS-GROUP-01..08).
## Os NOMES dos grupos não estão definidos na documentação (CLASSES.md não
## registra grupos) — os IDs de grupo são editoriais e pendentes de nome.
##
## Protótipo completo: CLASS-001 "Arcanista" (única classe implementada com
## habilidades demonstráveis e funcionamento real). As demais 79 são registros
## de capacidade estruturados e prontos para receber conteúdo.

@export var id: StringName = &""
@export var display_name: String = ""
## Grupo editorial (CLASS-GROUP-01..08); nome canônico pendente de design.
@export var group_id: StringName = &""
## Tags de papel (StringName livres). Papéis oficiais pendentes de design.
@export var role_tags: PackedStringArray = PackedStringArray()
## Fantasia de poder (uma frase). Pendente nas classes não-protótipo.
@export var identity: String = ""
## true somente no protótipo funcional (CLASS-001 Arcanista).
@export var is_prototype: bool = false
## Campos aguardando decisão de design (contrato de honestidade do catálogo).
@export var pending_fields: PackedStringArray = PackedStringArray()
## Atributos iniciais (Dictionary aberto): health, mana, might, spell_power,
## defense, speed_ratio. Completo APENAS no protótipo.
@export var base_attributes: Dictionary = {}
## Habilidades vinculadas (AbilityData.id) — catálogo pertence ao ClassManager.
@export var ability_ids: PackedStringArray = PackedStringArray()
## Habilidades ATIVAS (básicas + especiais) equipáveis em slots de ataque.
@export var active_ability_ids: PackedStringArray = PackedStringArray()
## Habilidades PASSIVAS equipáveis no slot de passiva.
@export var passive_ability_ids: PackedStringArray = PackedStringArray()
## Especializações (Array de Dictionary): {id, name, description}.
## Pendentes em TODAS as classes (decisão de design de progressão).
@export var specializations: Array = []
## Árvore de habilidades (Array de Dictionary):
## {node_id, tier, ability_id, requires: [node_id...], unlocks_at_level}.
@export var skill_tree: Array = []
## Progressão: {max_level, xp_base, xp_growth, unlock_schedule: {nivel: [ability_id]}}.
@export var progression: Dictionary = {}
## Desbloqueios de acesso (requisitos de raça/nível/quest). Pendentes.
@export var unlock_requirements: Dictionary = {}
## Animações por contexto: {cast, cast_special, hurt, death} → nome de clipe.
## Pendente para o pipeline GLB (o manequim não tem clipes de combate).
@export var animation_set: Dictionary = {}
## Efeitos visuais por habilidade: {ability_id: vfx_id}. Placeholder no protótipo.
@export var vfx_map: Dictionary = {}
@export var description: String = ""

const PENDING_ALL: PackedStringArray = [
	"display_name", "identity", "attributes", "abilities", "specializations",
	"skill_tree", "progression", "unlocks", "animations", "vfx",
]

## true quando NÃO há campo pendente (classe completa de verdade).
func is_complete() -> bool:
	return not is_prototype or pending_fields.is_empty()

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"group_id": String(group_id),
		"role_tags": Array(role_tags),
		"identity": identity,
		"is_prototype": is_prototype,
		"pending_fields": Array(pending_fields),
		"base_attributes": base_attributes,
		"ability_ids": Array(ability_ids),
		"active_ability_ids": Array(active_ability_ids),
		"passive_ability_ids": Array(passive_ability_ids),
		"specializations": specializations,
		"skill_tree": skill_tree,
		"progression": progression,
		"unlock_requirements": unlock_requirements,
		"animation_set": animation_set,
		"vfx_map": vfx_map,
		"description": description,
	}
