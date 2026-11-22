extends TestCase
## Suite CORE — EventBus e SystemRegistry (fundamentos da comunicação).

func system_label() -> String:
	return "core"

func execute() -> void:
	await _test_event_bus_roundtrip()
	await _test_registry_lifecycle()
	await _test_system_names_integrity()

func _test_event_bus_roundtrip() -> void:
	section("EventBus: conexão/emit e tipagem dos autoloads")
	var received := []
	var callable := func(text: String) -> void:
		received.append(text)
	EventBus.notification_requested.connect(callable)
	EventBus.notification_requested.emit("mensagem-teste")
	EventBus.notification_requested.disconnect(callable)
	check_eq(received.size(), 1, "sinal do EventBus deve alcançar ouvinte")
	check_eq(received[0], "mensagem-teste", "argumento do sinal deve preservar valor")

func _test_registry_lifecycle() -> void:
	section("SystemRegistry: registrar/obter/verificar/remover")
	var registry := Game.registry()
	var dummy := Node.new()
	dummy.name = "TestDummy"
	check_true(registry.register(&"GAME", dummy) == false, "chave duplicada deve falhar")
	check_true(registry.register(StringName("NOME_INVALIDO"), dummy) == false, "chave fora de SystemNames deve falhar")
	check_true(registry.register(SystemNames.SAVE, dummy) == false, "chave já ocupada deve falhar")
	check_not_null(registry.get_system(SystemNames.GAME), "Game deve estar registrado")
	check_true(registry.has_system(SystemNames.WORLD), "serviço World deve estar registrado")
	check_eq(registry.count(), SystemNames.ALL.size(), "registry deve conter exatamente os sistemas canônicos")
	var missing := registry.get_system(StringName("CHAVE_INEXISTENTE"))
	check_null(missing, "sistema inexistente deve retornar null")
	dummy.free()

func _test_system_names_integrity() -> void:
	section("SystemNames: ordem de inicialização e cobertura")
	check_eq(SystemNames.INIT_ORDER.size(), SystemNames.ALL.size() - 1,
		"INIT_ORDER cobre todos os sistemas exceto o orquestrador (Game)")
	var covered := {}
	for key in SystemNames.INIT_ORDER:
		covered[key] = true
	for key in SystemNames.ALL:
		if key == SystemNames.GAME:
			continue
		check_true(covered.has(key), "INIT_ORDER deve conter '%s'" % key)
	check_eq(SystemNames.INIT_ORDER[SystemNames.INIT_ORDER.size() - 1], SystemNames.SAVE,
		"Save é o último serviço inicializado (Game inicializa a si mesmo antes)")
	check_eq(Invariants.MAX_PARTICIPANTS, 8, "invariante: 8 jogadores por mundo, anfitrião incluído")
	check_eq(String(Invariants.HUB_REGION_ID), "hell_forge", "invariante: ressurgimento na Hell Forge")
