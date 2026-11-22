class_name SystemRegistry
extends RefCounted
## Registro de sistemas (service locator) do Abyssal Pact.
##
## Papel: permitir que gerenciadores se descubram SEM referências de classe
## cruzadas (zero dependências circulares). Nunca guarda lógica de domínio.
##
## Regras de uso:
##   - Registro é feito APENAS pelo GameManager no boot.
##   - Consultas: get_system()/has_system(); leituras nunca criam sistemas.
## Chaves válidas: SystemNames (validação em register()).

var _systems: Dictionary = {} # StringName -> Node

func _init() -> void:
	pass

## Registra um sistema. Falha (push_error + false) em chave inválida/duplicada.
func register(key: StringName, system: Node) -> bool:
	if not SystemNames.ALL.has(key):
		push_error("SystemRegistry: chave inválida '%s'." % key)
		return false
	if _systems.has(key):
		push_error("SystemRegistry: sistema '%s' já registrado." % key)
		return false
	if system == null:
		push_error("SystemRegistry: sistema nulo para '%s'." % key)
		return false
	_systems[key] = system
	return true

## Remove um sistema do registro (usado em desligamento/testes).
func unregister(key: StringName) -> bool:
	return _systems.erase(key)

## Retorna o sistema ou null. Nunca falha de forma ruidosa: chamador valida.
func get_system(key: StringName) -> Node:
	if not _systems.has(key):
		push_warning("SystemRegistry: sistema não registrado '%s'." % key)
		return null
	return _systems[key] as Node

func has_system(key: StringName) -> bool:
	return _systems.has(key)

## Chaves registradas, na ordem de registro (determinística).
func system_names() -> Array[StringName]:
	var names: Array[StringName] = []
	for key: StringName in _systems.keys():
		names.append(key)
	return names

## Todos os nós de sistema registrados (ordem de registro).
func all_systems() -> Array[Node]:
	var systems: Array[Node] = []
	for key: StringName in _systems.keys():
		systems.append(_systems[key])
	return systems

func count() -> int:
	return _systems.size()
