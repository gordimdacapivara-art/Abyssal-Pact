class_name RaceData
extends Resource
## Dados de raça. Escopo confirmado: 40 raças (RACE-001..RACE-040),
## nomes/identidades pendentes (RACES_AND_SUBRACES.md).
##
## Sistema baseado em dados: cadastro, aparência modular e compatibilidade
## com classes sem código por raça. Distribuição de 2 sub-raças por raça foi
## DEFINIDA nesta fase (antes era apenas média matemática — anotado em
## RACES_AND_SUBRACES.md).
##
## Protótipo funcional: RACE-001 (visual demonstrável via construtor modular;
## peças provisórias do pipeline GLB). As demais 39 são registros estruturais
## com pending_fields declarados.

@export var id: StringName = &""
@export var display_name: String = ""
## IDs de sub-raças vinculadas (SubraceData.id) — exatamente 2 por raça.
@export var subrace_ids: PackedStringArray = PackedStringArray()
## true somente no protótipo visual (RACE-001).
@export var is_prototype: bool = false
## Campos aguardando decisão de design (honestidade do catálogo).
@export var pending_fields: PackedStringArray = PackedStringArray()
## Descrição editorial (pendente nas não-protótipo).
@export var description: String = ""

# --------------------------------------------------------- aparência modular --
## Perfil visual (Dictionary aberto, lido pelo RaceVisualBuilder):
##   body_type: "humanoid_shared" (esqueleto compartilhado char_ref) ou
##              "specialized" (rig próprio — quadrúpede/anatomia especial)
##   model_glb: caminho do GLB; vazio = manequim compartilhado PROVISÓRIO
##   body_tint/head_tint: Color aplicado aos materiais do manequim
##   accessories: PackedStringArray de &"horn"/&"antenna"/&"tail"/&"wing"/
##               &"crystal"/&"antler" (peças PROVISÓRIAS do builder)
##   scale/height: fator de escala do modelo
##   special_structures: marcas editoriais (&"scales"/&"crystal"/...) sem
##               mesh dedicada ainda (pending — só registro)
@export var visual_profile: Dictionary = {}
## Animações complementares por estrutura: {tail: ..., wings: ...} → nome de
## clipe. PENDENTE em todas as raças (o manequim não tem clipes extras).
@export var animation_extras: Dictionary = {}

# --------------------------------------------------- compatibilidade (dados) --
## Grupos de classe compatíveis (CLASS-GROUP-01..08). VAZIO = compatível com
## todos (estado provisório; restrições oficiais pendentes de design).
@export var compatible_class_groups: PackedStringArray = PackedStringArray()
## Atributos raciais: NÃO PRESUMIDOS (RACES_AND_SUBRACES.md). Estrutura
## aberta; preenchida APENAS quando o design decidir (protótipo usa {}).
@export var racial_attributes: Dictionary = {}

## true quando NÃO há campo pendente declarado.
func is_complete() -> bool:
	return pending_fields.is_empty()

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"subrace_ids": Array(subrace_ids),
		"is_prototype": is_prototype,
		"pending_fields": Array(pending_fields),
		"description": description,
		"visual_profile": visual_profile,
		"animation_extras": animation_extras,
		"compatible_class_groups": Array(compatible_class_groups),
		"racial_attributes": racial_attributes,
	}
