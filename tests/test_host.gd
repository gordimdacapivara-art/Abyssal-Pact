extends Node
## TestHost — executor das suítes (nó persistente, fora da cena corrente).
##
## Adicionado diretamente a root pelo bootstrapper: sobrevive a trocas de
## cena feitas pela suíte de SceneManager. Roda as suítes em ordem fixa,
## mantém watchdog (suíte travada → quit(2)) e encerra com código de saída:
##   0 = todos os checks passaram; 1 = falhas; 2 = watchdog.
##
## Uso (console): Godot_console.exe --headless --path <projeto> res://tests/run_tests.tscn

const SUITES: Array[GDScript] = [
	preload("res://tests/suites/suite_core.gd"),
	preload("res://tests/suites/suite_boot.gd"),
	preload("res://tests/suites/suite_catalogs.gd"),
	preload("res://tests/suites/suite_character.gd"),
	preload("res://tests/suites/suite_inventory.gd"),
	preload("res://tests/suites/suite_world.gd"),
	preload("res://tests/suites/suite_quest.gd"),
	preload("res://tests/suites/suite_save.gd"),
	preload("res://tests/suites/suite_scene_ui.gd"),
	preload("res://tests/suites/suite_net.gd"),
	preload("res://tests/suites/suite_integration.gd"),
	preload("res://tests/suites/suite_player.gd"),
	preload("res://tests/suites/suite_models.gd"),
	preload("res://tests/suites/suite_classes.gd"),
	preload("res://tests/suites/suite_races.gd"),
	preload("res://tests/suites/suite_bestiary.gd"),
	preload("res://tests/suites/suite_open_world.gd"),
	preload("res://tests/suites/suite_ui_systems.gd"),
	preload("res://tests/suites/suite_multiplayer_complete.gd"),
	preload("res://tests/suites/suite_environment_pipeline.gd"),
	preload("res://tests/suites/suite_world_connection_loading.gd"),
	preload("res://tests/suites/suite_map_navigation.gd"),
	preload("res://tests/suites/suite_world_boss.gd"),
	preload("res://tests/suites/suite_world_boss_alert.gd"),
	preload("res://tests/suites/suite_world_boss_location.gd"),
	preload("res://tests/suites/suite_demonic_invasion.gd"),
	preload("res://tests/suites/suite_azaroth_battle.gd"),
	preload("res://tests/suites/suite_azaroth_invasion_restructure.gd"),
	preload("res://tests/suites/suite_loot.gd"),
	preload("res://tests/suites/suite_multiplatform.gd"),
]

const WATCHDOG_FRAMES := 7200 # ~2 minutos a 60 fps
const TOTAL_CHECKS_MIN := 40 # Guarda-mínimo: suítes devem exercitar bastante.

var _section := ""
var _elapsed_frames := 0
var _finished := false

func _ready() -> void:
	_run_all()

func _process(_delta: float) -> void:
	if _finished:
		return
	_elapsed_frames += 1
	if _elapsed_frames > WATCHDOG_FRAMES:
		printerr("WATCHDOG: testes travados após %d frames — seção: %s" % [WATCHDOG_FRAMES, _section])
		_finished = true
		get_tree().quit(2)

func set_section(label: String) -> void:
	_section = label

## Reinicia o watchdog (suítes longas de física chamam por seção).
func heartbeat() -> void:
	_elapsed_frames = 0

func report_failure(entry: String) -> void:
	printerr(entry)

func _run_all() -> void:
	await get_tree().process_frame
	print("=== ABYSSAL PACT — SUÍTE DE TESTES DE ARQUITETURA ===")
	var total_failures := 0
	var total_checks := 0
	for suite_script in SUITES:
		var suite: TestCase = suite_script.new()
		suite.host = self
		print("--- %s ---" % suite.system_label())
		await suite.execute()
		total_checks += suite.check_count()
		total_failures += suite.failure_count()
		print("--- %s: %d checks, %d falhas ---" % [suite.system_label(), suite.check_count(), suite.failure_count()])

	print("=== RESUMO: %d checks, %d falhas ===" % [total_checks, total_failures])
	_finished = true
	if total_failures == 0 and total_checks >= TOTAL_CHECKS_MIN:
		print("RESULTADO: TODOS OS TESTES PASSARAM")
		get_tree().quit(0)
	else:
		printerr("RESULTADO: TESTES COM FALHAS (checks=%d)" % total_checks)
		get_tree().quit(1)
