class_name ManagerBase
extends Node
## Contrato base de todos os gerenciadores do Abyssal Pact.
##
## Ciclo de vida definido pelo GameManager:
##   1. setup(registry)     — injeção de dependências (antes de add_child).
##   2. initialize()        — carga de dados própria + conexões do EventBus.
##   3. post_initialize()   — integrações que exigem TODOS os sistemas vivos.
##   4. verify()            — verificações básicas (GameManager agrega).
##   5. collect_save_data()/apply_save_data() — contrato de salvamento.
##
## Regras de arquitetura (ARCHITECTURE.md):
##   - Gerenciadores não se tipam entre si; resolvem serviços via registry.
##   - Eventos de domínio cruzado vão ao EventBus; sinais locais são mínimos.
##   - Dados configuráveis vivem em Resources (data/); lógica vive aqui.

var _registry: SystemRegistry
var _initialized := false

## Chave do sistema no registry. Constantes não podem ser sobrescritas em
## GDScript: cada gerenciador declara seu próprio `const KEY` e sobrescreve
## system_key() para expô-lo ao GameManager e ao EventBus.
func system_key() -> StringName:
	return &""

# ------------------------------------------------------------------ LIFECYCLE --

## Injeção de dependência. Chamado pelo GameManager antes de add_child.
func setup(registry: SystemRegistry) -> void:
	_registry = registry

func _ready() -> void:
	# Autoloads entram na árvore ANTES do boot do GameManager; o registry é
	# injetado depois, em setup(). get_system()/reporta ausência quando usado.
	set_process(false)
	set_physics_process(false)

## Inicialização self-contained. Implementações idempotentes.
func initialize() -> void:
	_initialized = true

## Integrações cruzadas pós-inicialização (default: nada).
func post_initialize() -> void:
	pass

## Retorna `true` quando initialize() já executou com sucesso.
func is_initialized() -> bool:
	return _initialized

# ------------------------------------------------------------------- LOOKUP --

## Resolve outro sistema pelo registry (dinâmico, sem dependência circular).
func get_system(key: StringName) -> Node:
	if _registry == null:
		push_error("[%s] registry não injetado; impossível resolver '%s'." % [system_key(), key])
		return null
	return _registry.get_system(key)

## Como get_system, mas trata ausência como erro de arquitetura (debug).
func require_system(key: StringName) -> Node:
	var system := get_system(key)
	if system == null:
		push_error("[%s] sistema obrigatório ausente: '%s'." % [system_key(), key])
	return system

# ------------------------------------------------------------------- CHECKS --

## Verificações básicas de integridade. Retorna lista de problemas; vazio = ok.
func verify() -> PackedStringArray:
	var issues := PackedStringArray()
	if not _initialized:
		issues.append("initialize() não executado")
	return issues

# ---------------------------------------------------------------------- SAVE --

## Contrato de salvamento: retorna payload JSON-safe do domínio deste gerador.
## Default: {} (gerenciador não participa do save). Override opcional.
func collect_save_data() -> Dictionary:
	return {}

## Contrato de carga: aplica payload previamente coletado. Retorna sucesso.
## Implementações devem limpar estado antigo antes de aplicar (idempotência).
func apply_save_data(_data: Dictionary) -> bool:
	return false

# ------------------------------------------------------------------- LOGGING --

func log_info(message: String) -> void:
	print("[%s] %s" % [system_key(), message])

func log_warn(message: String) -> void:
	push_warning("[%s] %s" % [system_key(), message])

func log_error(message: String) -> void:
	push_error("[%s] %s" % [system_key(), message])
