class_name SceneManager
extends ManagerBase
## SceneManager â€” trocas de cena com sinalizaÃ§Ã£o no EventBus.
##
## Responsabilidade: transiÃ§Ã£o determinÃ­stica de cena corrente + parÃ¢metros.
## NÃƒO decide para onde o fluxo vai (isso Ã© dos fluxos de jogo/persistente).
##
## IntegraÃ§Ã£o:
##   - Emite (EventBus): scene_transition_started / completed / failed.
##   - Usado por: fluxos de UI (menus), WorldManager (viagem â€” pendente),
##     testes de integraÃ§Ã£o.
## Autoload: "Scenes".

const KEY: StringName = SystemNames.SCENES

## Expõe a chave constante (constantes não são sobrescíveis em GDScript).
func system_key() -> StringName:
	return KEY

const TRANSITION_FRAMES_TIMEOUT := 600

var _transitioning := false

func initialize() -> void:
	super()
	log_info("SceneManager pronto; cena corrente: %s" % _current_path())

## Troca a cena corrente. AssÃ­ncrono por dentro: retorna imediatamente o
## resultado do disparo; conclusÃ£o chega via EventBus (scene_transition_*).
func change_scene(scene_path: String, params: Dictionary = {}) -> Error:
	if _transitioning:
		log_warn("TransiÃ§Ã£o jÃ¡ em andamento; pedido ignorado (%s)." % scene_path)
		return ERR_BUSY
	if not ResourceLoader.exists(scene_path):
		log_error("Cena inexistente: %s" % scene_path)
		EventBus.scene_transition_failed.emit(scene_path, ERR_FILE_NOT_FOUND)
		return ERR_FILE_NOT_FOUND

	_transitioning = true
	EventBus.scene_transition_started.emit(scene_path)
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		_transitioning = false
		log_error("Falha ao trocar para %s (erro %d)." % [scene_path, error])
		EventBus.scene_transition_failed.emit(scene_path, error)
		return error

	_finish_transition.call_deferred(scene_path, params)
	return OK

func reload_current_scene() -> Error:
	var path := _current_path()
	if path.is_empty():
		return ERR_UNAVAILABLE
	return change_scene(path)

func is_transitioning() -> bool:
	return _transitioning

func current_scene_path() -> String:
	return _current_path()

# ------------------------------------------------------------------ INTERNO --

func _current_path() -> String:
	var current := get_tree().current_scene
	return current.scene_file_path if current != null else ""

func _finish_transition(scene_path: String, params: Dictionary) -> void:
	var frames := 0
	while frames < TRANSITION_FRAMES_TIMEOUT:
		await get_tree().process_frame
		frames += 1
		var current := get_tree().current_scene
		if current != null and current.scene_file_path == scene_path:
			_apply_params(current, params)
			_transitioning = false
			EventBus.scene_transition_completed.emit(scene_path)
			return
	_transitioning = false
	log_error("Timeout aguardando carregamento de %s." % scene_path)
	EventBus.scene_transition_failed.emit(scene_path, ERR_TIMEOUT)

## Entrega parÃ¢metros Ã  cena nova quando ela expÃµe setup(params) â€” contrato
## de cenas reutilizÃ¡veis (ver scenes/README dos contratos em ARCHITECTURE.md).
func _apply_params(scene: Node, params: Dictionary) -> void:
	if params.is_empty() or not scene.has_method("setup"):
		return
	scene.call("setup", params)

func verify() -> PackedStringArray:
	var issues := super()
	var current := get_tree().current_scene
	if current == null:
		issues.append("nenhuma cena corrente definida")
	return issues
