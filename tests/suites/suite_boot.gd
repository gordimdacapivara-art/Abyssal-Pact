extends TestCase
## Suite BOOT — boot do GameManager, registro de todos os sistemas e verificações.

func system_label() -> String:
	return "boot"

func execute() -> void:
	section("GameManager: boot concluído e sucesso")
	check_true(Game.is_booted(), "boot deve estar concluído quando os testes rodam")
	check_true(Game.boot_success, "boot deve terminar sem problemas (issues: %s)" % [Game.boot_issues])
	check_eq(Game.state, GameStates.State.MENU, "estado pós-boot deve ser MENU")
	check_not_null(Game.registry(), "registry deve existir")

	section("Registry: todos os sistemas canônicos registrados")
	var registry := Game.registry()
	for key in SystemNames.ALL:
		check_not_null(registry.get_system(key), "sistema registrado: %s" % key)
	check_eq(registry.count(), SystemNames.ALL.size(), "nenhum sistema extra/ausente")
	check_eq(SystemNames.INIT_ORDER[SystemNames.INIT_ORDER.size() - 1], SystemNames.SAVE,
		"Save é o último serviço da ordem (Game inicializa a si mesmo primeiro)")

	section("Serviços: criados como filhos do GameManager (não autoload)")
	var world := system(SystemNames.WORLD)
	check_eq(world.get_parent(), Game, "serviço World deve ser filho do autoload Game")
	check_true(world.has_method("initialize"), "serviços seguem o contrato ManagerBase")

	section("Verificações agregadas: verify_all() sem problemas")
	var report := Game.verify_all()
	check_eq(report.size(), 0, "nenhum sistema pode reportar issues (relatório: %s)" % [report])
	check_eq(Game.boot_issues.size(), 0, "boot_issues deve estar vazio")

	section("Contratos base presentes em todos os sistemas")
	for node in registry.all_systems():
		check_true(node.has_method("verify"), "%s deve implementar verify()" % node.system_key())
		check_true(node.has_method("collect_save_data"), "%s deve implementar collect_save_data()" % node.system_key())
