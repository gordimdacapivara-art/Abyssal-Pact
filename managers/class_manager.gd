class_name ClassManager
extends ManagerBase
## ClassManager — catálogo de classes e habilidades (80 classes, CLASSES.md).
##
## Responsabilidade: carregar/validar ClassData (data/content/classes) e
## AbilityData (data/content/abilities); responder consultas do domínio;
## validar equipamento de habilidades (slots) e progressão de desbloqueios.
## Sistema baseado em DADOS: nenhuma classe tem código próprio.
##
## Integração:
##   - Emite (EventBus): catalog_loaded / catalog_invalid.
##   - Consumido via registry por: CharacterManager (criação/validação),
##     PlayerClassComponent (equipar/executar), UI de seleção.
##   - Save: catálogo é conteúdo do projeto, não estado de save.
## Serviço: registro "Class" (criado por GameManager).

const KEY: StringName = SystemNames.CLASS

## Expõe a chave constante (constantes não são sobrescíveis em GDScript).
func system_key() -> StringName:
	return KEY

const CLASSES_DIR := "res://data/content/classes"
const ABILITIES_DIR := "res://data/content/abilities"

const EXPECTED_CLASS_COUNT := 80
const FIRST_CLASS_NUMBER := 1
const GROUP_COUNT := 8
const CLASSES_PER_GROUP := 10

var _classes: Dictionary = {} # String(id) -> ClassData
var _abilities: Dictionary = {} # String(id) -> AbilityData

func initialize() -> void:
	super()
	load_catalog()

# --------------------------------------------------------------------- API --

func load_catalog() -> bool:
	_classes.clear()
	_abilities.clear()
	var issues := PackedStringArray()
	_load_resources(CLASSES_DIR, _classes, "classe", issues)
	_load_resources(ABILITIES_DIR, _abilities, "habilidade", issues)
	_validate_ability_links(issues)
	_validate_catalog(issues)

	if issues.is_empty():
		log_info("Catálogo de classes carregado: %d classes, %d habilidades." % [_classes.size(), _abilities.size()])
		EventBus.catalog_loaded.emit(&"classes", _classes.size())
		EventBus.catalog_loaded.emit(&"abilities", _abilities.size())
		return true
	EventBus.catalog_invalid.emit(&"classes", issues)
	return false

func has_class(class_id: StringName) -> bool:
	return _classes.has(String(class_id))

func get_class_data(class_id: StringName) -> ClassData:
	return _classes.get(String(class_id)) as ClassData

func has_ability(ability_id: StringName) -> bool:
	return _abilities.has(String(ability_id))

func get_ability(ability_id: StringName) -> AbilityData:
	return _abilities.get(String(ability_id)) as AbilityData

func classes() -> Array[ClassData]:
	var result: Array[ClassData] = []
	for value in _classes.values():
		result.append(value as ClassData)
	return result

func abilities() -> Array[AbilityData]:
	var result: Array[AbilityData] = []
	for value in _abilities.values():
		result.append(value as AbilityData)
	return result

## Habilidades declaradas por uma classe (validadas contra o catálogo).
func abilities_of(class_id: StringName) -> Array[AbilityData]:
	var result: Array[AbilityData] = []
	var class_data := get_class_data(class_id)
	if class_data == null:
		return result
	for ability_id in class_data.ability_ids:
		var ability := get_ability(StringName(ability_id))
		if ability != null:
			result.append(ability)
	return result

## Classes de um grupo editorial (CLASS-GROUP-01..08).
func classes_in_group(group_id: StringName) -> Array[ClassData]:
	var result: Array[ClassData] = []
	for class_data in classes():
		if class_data.group_id == group_id:
			result.append(class_data)
	return result

## IDs dos grupos editoriais presentes no catálogo.
func group_ids() -> PackedStringArray:
	var groups := PackedStringArray()
	for class_data in classes():
		if not groups.has(class_data.group_id):
			groups.append(class_data.group_id)
	groups.sort()
	return groups

## Classes protótipo (funcionais). Esperado: apenas CLASS-001 Arcanista.
func prototype_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for class_data in classes():
		if class_data.is_prototype:
			ids.append(String(class_data.id))
	return ids

## Classes pendentes de design (todas as não-protótipo).
func pending_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for class_data in classes():
		if not class_data.is_prototype:
			ids.append(String(class_data.id))
	return ids

## Relatório de completude (critério do pedido): {complete: [], prototype: [], pending: []}.
func completeness_report() -> Dictionary:
	var complete := PackedStringArray()
	var pending := PackedStringArray()
	for class_data in classes():
		if class_data.is_prototype:
			continue
		if class_data.pending_fields.is_empty():
			complete.append(String(class_data.id))
		else:
			pending.append(String(class_data.id))
	return {"complete": complete, "prototype": prototype_ids(), "pending": pending}

## Nós da árvore de habilidades de uma classe.
func skill_tree_of(class_id: StringName) -> Array:
	var class_data := get_class_data(class_id)
	return [] if class_data == null else class_data.skill_tree

## Habilidades desbloqueadas pela árvore/progressão em um nível.
func unlocked_abilities(class_id: StringName, level: int) -> PackedStringArray:
	var result := PackedStringArray()
	var class_data := get_class_data(class_id)
	if class_data == null:
		return result
	for node: Dictionary in class_data.skill_tree:
		var unlock_level := int(node.get("unlocks_at_level", 1))
		if level < unlock_level:
			continue
		if not _tree_requirements_met(class_data, node, level):
			continue
		var ability_id := String(node.get("ability_id", ""))
		if not ability_id.is_empty() and not result.has(ability_id):
			result.append(ability_id)
	return result

## Regras de equipamento: habilidade pertence à classe, tipo casa com o slot
## e está desbloqueada no nível. Slots: &"active" (básica/especial), &"passive".
func can_equip(class_id: StringName, ability_id: StringName, slot_kind: StringName, level: int = 1) -> bool:
	var class_data := get_class_data(class_id)
	var ability := get_ability(ability_id)
	if class_data == null or ability == null:
		return false
	if not class_data.ability_ids.has(String(ability_id)):
		return false
	if slot_kind == &"passive":
		if ability.kind != &"passive" or not class_data.passive_ability_ids.has(String(ability_id)):
			return false
	else:
		if not ability.is_active() or not class_data.active_ability_ids.has(String(ability_id)):
			return false
	return unlocked_abilities(class_id, level).has(String(ability_id))

func all_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for id in _classes.keys():
		ids.append(String(id))
	for id in _abilities.keys():
		ids.append(String(id))
	return ids

# ------------------------------------------------------------------ INTERNO --

func _load_resources(dir_path: String, target: Dictionary, label: String, issues: PackedStringArray) -> void:
	if not DirAccess.dir_exists_absolute(dir_path):
		issues.append("diretório ausente: %s" % dir_path)
		return
	for file_name in DirAccess.get_files_at(dir_path):
		if not file_name.ends_with(".tres"):
			continue
		var resource: Resource = load(dir_path + "/" + file_name)
		if resource == null:
			issues.append("falha ao carregar %s" % file_name)
			continue
		var data_id := String(resource.get("id"))
		if data_id.is_empty():
			issues.append("id vazio em %s" % file_name)
			continue
		if target.has(data_id):
			issues.append("%s duplicado: %s" % [label, data_id])
			continue
		target[data_id] = resource

func _validate_ability_links(issues: PackedStringArray) -> void:
	for class_data: ClassData in _classes.values():
		for ability_id in class_data.ability_ids:
			if not has_ability(StringName(ability_id)):
				issues.append("classe '%s' referencia habilidade ausente '%s'" % [class_data.id, ability_id])
		for node: Dictionary in class_data.skill_tree:
			var tree_ability := String(node.get("ability_id", ""))
			if not tree_ability.is_empty() and not class_data.ability_ids.has(tree_ability):
				issues.append("classe '%s': nó '%s' referencia habilidade fora da classe '%s'" % [
					class_data.id, node.get("node_id", ""), tree_ability])

## Validação estrutural do catálogo completo (80 classes, 8 grupos, protótipo).
func _validate_catalog(issues: PackedStringArray) -> void:
	if _classes.size() != EXPECTED_CLASS_COUNT:
		issues.append("catálogo deve ter %d classes, tem %d" % [EXPECTED_CLASS_COUNT, _classes.size()])
		return
	for number in range(FIRST_CLASS_NUMBER, EXPECTED_CLASS_COUNT + 1):
		var expected_id := "CLASS-%03d" % number
		if not _classes.has(expected_id):
			issues.append("id esperado ausente: %s" % expected_id)
			continue
		var class_data := _classes[expected_id] as ClassData
		var expected_group := "CLASS-GROUP-%02d" % (int((number - 1) / CLASSES_PER_GROUP) + 1)
		if class_data.group_id != StringName(expected_group):
			issues.append("%s: grupo editorial incorreto (%s, esperado %s)" % [
				expected_id, class_data.group_id, expected_group])
		if class_data.is_prototype:
			_validate_prototype(class_data, issues)
		elif class_data.pending_fields.is_empty():
			issues.append("%s marcada como não-protótipo sem campos pendentes declarados" % expected_id)

func _validate_prototype(class_data: ClassData, issues: PackedStringArray) -> void:
	if class_data.base_attributes.is_empty():
		issues.append("protótipo '%s' sem atributos iniciais" % class_data.id)
	var active_count := 0
	for ability_id in class_data.active_ability_ids:
		var ability := get_ability(StringName(ability_id))
		if ability == null:
			issues.append("protótipo '%s': ativa ausente '%s'" % [class_data.id, ability_id])
			continue
		if ability.pending:
			issues.append("protótipo '%s': ativa '%s' está pendente" % [class_data.id, ability_id])
			continue
		if ability.cooldown <= 0.0:
			issues.append("protótipo '%s': ativa '%s' sem cooldown" % [class_data.id, ability_id])
		active_count += 1
	if active_count < 2:
		issues.append("protótipo '%s' precisa de ao menos 2 ativas demonstráveis" % class_data.id)
	var passive_count := 0
	for ability_id in class_data.passive_ability_ids:
		var ability := get_ability(StringName(ability_id))
		if ability == null:
			issues.append("protótipo '%s': passiva ausente '%s'" % [class_data.id, ability_id])
			continue
		if not ability.pending and ability.passive_effects.is_empty():
			issues.append("protótipo '%s': passiva demonstrável '%s' sem efeitos" % [class_data.id, ability_id])
		if not ability.pending:
			passive_count += 1
	if passive_count < 1:
		issues.append("protótipo '%s' precisa de ao menos 1 passiva demonstrável" % class_data.id)
	if class_data.skill_tree.is_empty():
		issues.append("protótipo '%s' sem árvore de habilidades" % class_data.id)
	var tree_nodes := PackedStringArray()
	for node: Dictionary in class_data.skill_tree:
		var node_id := String(node.get("node_id", ""))
		if node_id.is_empty() or tree_nodes.has(node_id):
			issues.append("protótipo '%s': nó de árvore inválido/duplicado '%s'" % [class_data.id, node_id])
			continue
		tree_nodes.append(node_id)
		for requirement: String in node.get("requires", []):
			if not tree_nodes.has(requirement):
				issues.append("protótipo '%s': nó '%s' requer nó não resolvido '%s'" % [
					class_data.id, node_id, requirement])
	if class_data.progression.is_empty():
		issues.append("protótipo '%s' sem progressão" % class_data.id)

func _tree_requirements_met(class_data: ClassData, node: Dictionary, level: int) -> bool:
	var requirements: Array = node.get("requires", [])
	if requirements.is_empty():
		return true
	# Um requisito é atendido quando a habilidade dele já está desbloqueada
	# no nível (checagem por nível, sem estado de save).
	for requirement: String in requirements:
		for other: Dictionary in class_data.skill_tree:
			if String(other.get("node_id", "")) == requirement:
				if int(other.get("unlocks_at_level", 1)) > level:
					return false
				break
	return true

func verify() -> PackedStringArray:
	var issues := super()
	if _classes.is_empty():
		issues.append("catálogo de classes vazio")
	if _abilities.is_empty():
		issues.append("catálogo de habilidades vazio")
	if not _classes.is_empty() and _classes.size() != EXPECTED_CLASS_COUNT:
		issues.append("catálogo de classes incompleto: %d/%d" % [_classes.size(), EXPECTED_CLASS_COUNT])
	return issues
