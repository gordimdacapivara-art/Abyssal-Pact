class_name GameManager
extends ManagerBase
## GameManager — raiz de composição e orquestrador do boot.
##
## Responsabilidade:
##   1. Criar o SystemRegistry e registrar os autoloads de infraestrutura.
##   2. Instanciar e registrar os 8 serviços (World/Character/Race/Class/
##      Demons/Bosses/Inventory/Quests) — NÃO são autoload (ver regra de
##      autoload mínimo em TECHNICAL_ARCHITECTURE.md).
##   3. Inicializar tudo na ordem SystemNames.INIT_ORDER.
##   4. Rodar verificações básicas (inclui invariantes de produto globais).
##   5. Controlar a máquina de estados global (GameStates.State).
##
## Integração:
##   - Emite (EventBus): boot_started, boot_completed, game_state_changed,
##     shutdown_requested.
##   - Escuta (EventBus): transições de cena (LOADING) e sessões de mundo.
##   - Consulta (registry): todos, apenas em verify_all().
## Autoload: "Game" (ÚLTIMO da lista — garante autoloads prontos antes do boot).

const KEY: StringName = SystemNames.GAME

## Exp�e a chave constante (constantes n�o s�o sobresc�veis em GDScript).
func system_key() -> StringName:
	return KEY

## Serviços registrados no boot (scripts puros; instanciados como filhos).
const SERVICE_SCRIPTS: Array[GDScript] = [
	preload("res://managers/world_manager.gd"),
	preload("res://managers/character_manager.gd"),
	preload("res://managers/race_manager.gd"),
	preload("res://managers/class_manager.gd"),
	preload("res://managers/demon_manager.gd"),
	preload("res://managers/boss_manager.gd"),
	preload("res://managers/inventory_manager.gd"),
	preload("res://managers/quest_manager.gd"),
]

var state: GameStates.State = GameStates.State.BOOT
var boot_success := false
var boot_issues: PackedStringArray = PackedStringArray()

var _booted := false

func _ready() -> void:
	set_process(false)
	boot()

# --------------------------------------------------------------------- BOOT --

func boot() -> void:
	if _booted:
		return
	initialize() # Contrato próprio do ManagerBase (o boot É a inicialização).
	EventBus.boot_started.emit()
	log_info("Boot iniciado.")

	_registry = SystemRegistry.new()
	_register_autoloads()
	_register_services()

	for key in SystemNames.INIT_ORDER:
		var system := _registry.get_system(key)
		if system == null:
			boot_issues.append("sistema ausente na ordem de init: %s" % key)
			continue
		system.call("initialize")

	for key in SystemNames.INIT_ORDER:
		var system := _registry.get_system(key)
		if system != null and system.has_method("post_initialize"):
			system.call("post_initialize")

	boot_issues.append_array(_verify_product_invariants())
	var report := verify_all()
	for system_key: StringName in report.keys():
		for issue in report[system_key]:
			boot_issues.append("[%s] %s" % [system_key, issue])

	boot_success = boot_issues.is_empty()
	if not boot_success:
		for issue in boot_issues:
			push_error("[Boot] %s" % issue)

	_set_state(GameStates.State.MENU)
	_booted = true
	log_info("Boot concluído (sucesso=%s; sistemas=%d)." % [boot_success, _registry.count()])
	connect_state_watchers()
	EventBus.boot_completed.emit(boot_success)

func is_booted() -> bool:
	return _booted

func request_shutdown() -> void:
	_set_state(GameStates.State.SHUTDOWN)
	EventBus.shutdown_requested.emit()
	log_info("Encerramento solicitado.")
	get_tree().quit.call_deferred(0)

# ----------------------------------------------------------------- REGISTRY --

func registry() -> SystemRegistry:
	return _registry

func get_system(key: StringName) -> Node:
	if _registry == null:
		return null
	return _registry.get_system(key)

func _register_autoloads() -> void:
	# Paths string evitam acoplamento do analyzer a scripts de autoload.
	var autoload_paths: Dictionary = {
		SystemNames.GAME: "/root/Game",
		SystemNames.SCENES: "/root/Scenes",
		SystemNames.UI: "/root/UI",
		SystemNames.AUDIO: "/root/Audio",
		SystemNames.NET: "/root/Net",
		SystemNames.SAVE: "/root/Save",
	}
	for key: StringName in autoload_paths.keys():
		var system := get_node(autoload_paths[key]) as Node
		if system == null:
			boot_issues.append("autoload ausente: %s" % key)
			continue
		if system.has_method("setup"):
			system.call("setup", _registry)
		if not _registry.register(key, system):
			boot_issues.append("falha ao registrar autoload: %s" % key)

func _register_services() -> void:
	for script in SERVICE_SCRIPTS:
		var service := script.new() as Node
		if service == null:
			boot_issues.append("serviço não instanciado: %s" % script.resource_path)
			continue
		if service.has_method("setup"):
			service.call("setup", _registry)
		add_child(service)
		if not _registry.register(service.call("system_key"), service):
			boot_issues.append("falha ao registrar serviço: %s" % script.resource_path)

# --------------------------------------------------------------- VERIFICAÇÃO --

## Agrega verify() de todos os sistemas: { chave: PackedStringArray }.
func verify_all() -> Dictionary:
	var report := {}
	if _registry == null:
		report[KEY] = PackedStringArray(["registry não criado"])
		return report
	for system in _registry.all_systems():
		var issues := PackedStringArray()
		if system.has_method("verify"):
			issues = system.call("verify")
		if not issues.is_empty():
			report[system.system_key()] = issues
	return report

## Invariantes de produto que cruzam gerenciadores (fontes: PROJECT_OVERVIEW.md,
## DEMON_BESTIARY.md, BOSS_CATALOG.md, HELL_FORGE.md).
func _verify_product_invariants() -> PackedStringArray:
	var issues := PackedStringArray()

	var net := get_system(SystemNames.NET)
	if net != null and net.call("max_participants") != Invariants.MAX_PARTICIPANTS:
		issues.append("limite de participantes diverge de 8 (anfitrião incluído)")

	var world := get_system(SystemNames.WORLD)
	if world != null and world.call("max_participants") != Invariants.MAX_PARTICIPANTS:
		issues.append("WorldManager diverge do limite de 8 participantes")
	if world != null and String(world.HUB_ID) != String(Invariants.HUB_REGION_ID):
		issues.append("hub de ressurgimento diverge da Hell Forge")

	# Demônios regionais e chefes NÃO podem se sobrepor.
	var demons := get_system(SystemNames.DEMONS)
	var bosses := get_system(SystemNames.BOSSES)
	if demons != null and bosses != null:
		for demon_id in demons.call("all_ids"):
			if String(demon_id).begins_with(Invariants.BOSS_ID_PREFIX):
				issues.append("id de chefe no catálogo regional: %s" % demon_id)
		for boss_id in bosses.call("all_ids"):
			if String(boss_id).begins_with(Invariants.DEMON_ID_PREFIX):
				issues.append("id de criatura regional no catálogo de chefes: %s" % boss_id)

	return issues

# ------------------------------------------------------------------ ESTADOS --

func _set_state(to_state: GameStates.State) -> void:
	if state == to_state:
		return
	var from_state := state
	state = to_state
	EventBus.game_state_changed.emit(from_state, to_state)

func connect_state_watchers() -> void:
	# Conectado após o boot para não interferir na própria inicialização.
	EventBus.scene_transition_started.connect(_on_scene_transition_started)
	EventBus.scene_transition_completed.connect(_on_scene_transition_done)
	EventBus.scene_transition_failed.connect(_on_scene_transition_failed)
	EventBus.world_created.connect(_on_world_created)
	EventBus.world_closed.connect(_on_world_closed)

func _on_scene_transition_started(_scene_path: String) -> void:
	if state != GameStates.State.SHUTDOWN:
		_set_state(GameStates.State.LOADING)

func _on_scene_transition_done(_scene_path: String) -> void:
	if state != GameStates.State.LOADING:
		return
	var world := get_system(SystemNames.WORLD)
	var has_world := world != null and world.call("active_world") != null
	_set_state(GameStates.State.WORLD if has_world else GameStates.State.MENU)

func _on_scene_transition_failed(_scene_path: String, _error: int) -> void:
	_on_scene_transition_done(_scene_path)

func _on_world_created(_world_id: StringName, _host: int) -> void:
	_set_state(GameStates.State.WORLD)

func _on_world_closed(_world_id: StringName) -> void:
	if state == GameStates.State.WORLD:
		_set_state(GameStates.State.MENU)

func verify() -> PackedStringArray:
	var issues := PackedStringArray()
	# O estado "_booted" não é verificado aqui: verify_all() roda DURANTE o
	# boot (verificação interna). Serviços ausentes são capturados em boot().
	return issues

func collect_save_data() -> Dictionary:
	return {} # Estado global (idioma etc.) pendente de decisão de UI.
