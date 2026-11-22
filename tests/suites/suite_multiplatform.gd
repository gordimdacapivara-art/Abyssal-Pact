extends TestCase
## Suite MULTIPLATFORM — Preparação Técnica para Xbox Series X|S e Windows PC.
##
## Valida:
## 1. Perfis de Plataforma (PlatformProfile) para PC, Series S e Series X.
## 2. Gerenciador de Plataforma (PlatformManager) e orçamentos de hardware.
## 3. Gerenciamento de dispositivos de entrada (DeviceManager), glifos Xbox e navegação por controle.
## 4. Camada de abstração de armazenamento (PlatformStorageAdapter: LocalStorage e Xbox XGameSave Stub).
## 5. Sessões privadas (máx. 8 jogadores), Crossplay PC-Xbox e tickets de reconexão.
## 6. Exclusividade e autoridade da Hell Forge por mundo privado.

const PlatformProfileScript := preload("res://systems/platform/platform_profile.gd")
const PlatformManagerScript := preload("res://systems/platform/platform_manager.gd")
const DeviceManagerScript := preload("res://systems/platform/device_manager.gd")
const PlatformStorageScript := preload("res://systems/platform/platform_storage_adapter.gd")
const MultiplayerCrossplayScript := preload("res://systems/platform/multiplayer_crossplay_manager.gd")

func system_label() -> String:
	return "multiplatform"

func execute() -> void:
	await _test_platform_profiles()
	await _test_platform_manager_and_budgets()
	await _test_input_and_device_manager()
	await _test_storage_adapters()
	await _test_crossplay_and_multiplayer_limits()
	await _test_world_exclusive_hell_forge()

# -------------------------------------------------------- 1. Perfis de Plataforma --

func _test_platform_profiles() -> void:
	section("PlatformProfile: Especificações técnicas e orçamentos de PC, Series S e Series X")
	
	# Perfil PC Windows
	var pc = PlatformProfileScript.create_pc_profile()
	check_eq(pc.platform_type, PlatformProfileScript.PlatformType.PC_WINDOWS, "tipo de perfil deve ser PC_WINDOWS")
	check_eq(pc.target_fps, 60, "alvo de FPS no PC deve ser 60")
	check_false(pc.dynamic_resolution_enabled, "resolução dinâmica não é obrigatória por padrão no PC")
	check_true(pc.crossplay_enabled, "crossplay deve estar habilitado no perfil PC")
	
	# Perfil Xbox Series S (Prioridade de Otimização)
	var series_s = PlatformProfileScript.create_series_s_profile()
	check_eq(series_s.platform_type, PlatformProfileScript.PlatformType.XBOX_SERIES_S, "tipo de perfil deve ser XBOX_SERIES_S")
	check_eq(series_s.target_resolution, Vector2i(1920, 1080), "Series S deve mirar 1080p")
	check_eq(series_s.target_fps, 60, "Series S deve travar em 60 FPS")
	check_true(series_s.dynamic_resolution_enabled, "Series S deve utilizar resolução dinâmica")
	check_true(series_s.min_resolution_scale < 1.0, "escala mínima de resolução do Series S deve permitir até ~720p sob estresse")
	check_eq(series_s.vram_texture_max_size, 2048, "texturas no Series S devem ser limitadas a 2048 para preservar VRAM")
	check_true(series_s.memory_budget_mb <= 8000, "orçamento de memória do Series S deve respeitar os 7.5~8.0 GB disponíveis para o jogo")
	check_true(series_s.lod_threshold_pixels > 1.0, "threshold de LOD do Series S deve ser mais agressivo")
	
	# Perfil Xbox Series X
	var series_x = PlatformProfileScript.create_series_x_profile()
	check_eq(series_x.platform_type, PlatformProfileScript.PlatformType.XBOX_SERIES_X, "tipo de perfil deve ser XBOX_SERIES_X")
	check_eq(series_x.target_resolution, Vector2i(3840, 2160), "Series X deve mirar 4K nativo")
	check_eq(series_x.target_fps, 60, "Series X deve travar em 60 FPS")
	check_eq(series_x.vram_texture_max_size, 4096, "Series X suporta texturas em 4096")
	check_true(series_x.memory_budget_mb >= 12000, "Series X possui orçamento amplo de memória para o jogo (13.5 GB)")

# ------------------------------------------------------- 2. PlatformManager --

func _test_platform_manager_and_budgets() -> void:
	section("PlatformManager: Comutação de perfis, orçamentos e monitoramento de memória")
	
	var mgr = PlatformManagerScript.new()
	mgr.auto_detect_platform = false
	host.add_child(mgr)
	
	# Inicialização com perfil PC
	mgr.switch_to_platform(PlatformProfileScript.PlatformType.PC_WINDOWS)
	check_eq(mgr.active_profile.platform_type, PlatformProfileScript.PlatformType.PC_WINDOWS, "manager deve assumir perfil PC")
	check_eq(mgr.storage_adapter.get_adapter_name(), "PC_LocalStorage", "adaptador de armazenamento no PC deve ser LocalStorage")
	
	# Alternância para Xbox Series S
	mgr.switch_to_platform(PlatformProfileScript.PlatformType.XBOX_SERIES_S)
	check_eq(mgr.active_profile.platform_type, PlatformProfileScript.PlatformType.XBOX_SERIES_S, "manager deve assumir perfil Series S")
	check_eq(mgr.storage_adapter.get_adapter_name(), "Xbox_ConnectedStorage_GDK_Stub", "adaptador no Series S deve ser Xbox Connected Storage Stub")
	check_eq(Engine.max_fps, 60, "Engine.max_fps deve ser sincronizado com o perfil")
	
	# Status de memória
	var mem_status = mgr.get_memory_status()
	check_true(mem_status.has("used_mb"), "status de memória deve conter used_mb")
	check_true(mem_status.has("budget_mb"), "status de memória deve conter budget_mb")
	check_true(mem_status["within_budget"], "consumo atual deve estar dentro do orçamento")
	
	mgr.queue_free()

# ------------------------------------------------------- 3. Dispositivos & Input --

func _test_input_and_device_manager() -> void:
	section("DeviceManager: Detecção de periféricos, prompts Xbox e navegação por controle")
	
	var dev_mgr = DeviceManagerScript.new()
	host.add_child(dev_mgr)
	
	# Estado inicial: Teclado/Mouse
	check_eq(dev_mgr.active_device, DeviceManagerScript.DeviceType.KEYBOARD_MOUSE, "dispositivo inicial deve ser Teclado/Mouse")
	
	# Simulação de entrada por controle
	var joy_event := InputEventJoypadButton.new()
	joy_event.button_index = JOY_BUTTON_A
	joy_event.pressed = true
	dev_mgr._input(joy_event)
	
	check_eq(dev_mgr.active_device, DeviceManagerScript.DeviceType.XBOX_CONTROLLER, "deve comutar para XBOX_CONTROLLER ao receber evento de joypad")
	
	# Glifos visuais Xbox
	check_eq(dev_mgr.XBOX_GLYPHS[JOY_BUTTON_A], "[A]", "botão A deve mapear para [A]")
	check_eq(dev_mgr.XBOX_GLYPHS[JOY_BUTTON_B], "[B]", "botão B deve mapear para [B]")
	check_eq(dev_mgr.XBOX_GLYPHS[JOY_BUTTON_X], "[X]", "botão X deve mapear para [X]")
	check_eq(dev_mgr.XBOX_GLYPHS[JOY_BUTTON_Y], "[Y]", "botão Y deve mapear para [Y]")
	check_eq(dev_mgr.XBOX_GLYPHS[JOY_BUTTON_LEFT_SHOULDER], "[LB]", "bumper esquerdo deve ser [LB]")
	check_eq(dev_mgr.XBOX_GLYPHS[JOY_BUTTON_RIGHT_SHOULDER], "[RB]", "bumper direito deve ser [RB]")
	check_eq(dev_mgr.XBOX_AXIS_GLYPHS[JOY_AXIS_TRIGGER_LEFT], "[LT]", "gatilho esquerdo deve ser [LT]")
	check_eq(dev_mgr.XBOX_AXIS_GLYPHS[JOY_AXIS_TRIGGER_RIGHT], "[RT]", "gatilho direito deve ser [RT]")
	check_eq(dev_mgr.XBOX_GLYPHS[JOY_BUTTON_START], "[Menu]", "botão start deve ser [Menu]")
	check_eq(dev_mgr.XBOX_GLYPHS[JOY_BUTTON_BACK], "[View]", "botão back deve ser [View]")
	
	# Teste de foco para navegação por controle (XR-051)
	var test_container = VBoxContainer.new()
	var btn1 = Button.new()
	var btn2 = Button.new()
	var btn3 = Button.new()
	test_container.add_child(btn1)
	test_container.add_child(btn2)
	test_container.add_child(btn3)
	host.add_child(test_container)
	
	dev_mgr.setup_focus_tree(test_container)
	check_eq(btn1.focus_mode, Control.FOCUS_ALL, "botões devem ter foco habilitado")
	check_not_null(btn1.focus_neighbor_bottom, "vizinho de foco inferior de btn1 deve ser configurado")
	check_not_null(btn2.focus_neighbor_top, "vizinho de foco superior de btn2 deve ser configurado")
	
	test_container.queue_free()
	dev_mgr.queue_free()

# ------------------------------------------------------- 4. Adaptadores de Storage --

func _test_storage_adapters() -> void:
	section("PlatformStorageAdapter: LocalStorage e Xbox Connected Storage (XR-052 Quota)")
	
	# 4.1 LocalStorageAdapter
	var local_adapter = PlatformStorageScript.LocalStorageAdapter.new("user://test_multiplatform_saves")
	var test_data: Dictionary = {
		"player": "TestHero",
		"level": 45,
		"private_world": "Sanctuary"
	}
	var err_save = local_adapter.save_data(99, test_data)
	check_eq(err_save, OK, "LocalStorage deve salvar com sucesso")
	check_true(local_adapter.has_data(99), "has_data(99) deve ser verdadeiro")
	
	var loaded_data = local_adapter.load_data(99)
	check_eq(loaded_data.get("player", ""), "TestHero", "dados carregados devem coincidir")
	check_true(local_adapter.list_slots().has(99), "list_slots deve conter slot 99")
	
	var err_del = local_adapter.delete_data(99)
	check_eq(err_del, OK, "remover slot deve retornar OK")
	check_false(local_adapter.has_data(99), "slot 99 não deve mais existir")
	
	# 4.2 XboxConnectedStorageAdapterStub (XR-052)
	var xbox_adapter = PlatformStorageScript.XboxConnectedStorageAdapterStub.new("XUID_TEST_USER_999")
	check_true(xbox_adapter.is_cloud_synced(), "Xbox Storage deve ter sincronização em nuvem ativa")
	check_eq(xbox_adapter.get_quota_bytes(), 64 * 1024 * 1024, "quota do Connected Storage deve ser 64 MB")
	
	var err_xbox_save = xbox_adapter.save_data(1, test_data)
	check_eq(err_xbox_save, OK, "Xbox stub deve salvar snapshot com sucesso")
	check_true(xbox_adapter.has_data(1), "Xbox stub deve possuir slot 1")
	
	var xbox_loaded = xbox_adapter.load_data(1)
	check_eq(xbox_loaded.get("level", 0), 45, "dados do slot Xbox devem ser íntegros")
	check_true(xbox_adapter.get_used_bytes() > 0, "espaço utilizado deve ser positivo")
	
	var err_xbox_del = xbox_adapter.delete_data(1)
	check_eq(err_xbox_del, OK, "exclusão no Xbox stub deve funcionar")

# ------------------------------------------------------- 5. Crossplay & Multiplayer --

func _test_crossplay_and_multiplayer_limits() -> void:
	section("MultiplayerCrossplay: Limite de 8 jogadores, privilégios Xbox (XR-053) e reconexão")
	
	var net_mgr = MultiplayerCrossplayScript.new()
	host.add_child(net_mgr)
	
	# Checagem de privilégios Xbox
	var priv = net_mgr.check_xbox_privileges("XUID_SAMPLE_USER")
	check_true(priv["allowed"], "usuário com privilégios padrão deve ter acesso permitido")
	
	net_mgr.crossplay_enabled = false
	var priv_denied = net_mgr.check_xbox_privileges("XUID_SAMPLE_USER")
	check_false(priv_denied["allowed"], "acesso crossplay deve ser bloqueado quando desativado pelo anfitrião")
	net_mgr.crossplay_enabled = true
	
	# Limite estrito de 8 jogadores (Invariants.MAX_PARTICIPANTS)
	for i in range(1, 9):
		var registered = net_mgr.register_client(i, MultiplayerCrossplayScript.PlatformClientType.XBOX_SERIES_S, "Player_%d" % i)
		check_true(registered, "jogador %d (de 8) deve ser admitido no mundo privado" % i)
	
	check_eq(net_mgr.get_connected_count(), 8, "mundo privado deve ter exatamente 8 participantes")
	
	# 9º jogador tentando entrar deve ser categoricamente rejeitado
	var extra_registered = net_mgr.register_client(9, MultiplayerCrossplayScript.PlatformClientType.PC_WINDOWS, "Player_9")
	check_false(extra_registered, "9º jogador deve ser categoricamente REJEITADO (teto de 8 atingido)")
	
	# Validação de mutação de inventário pelo Host (prevenção de cheat crossplay)
	var inv_valid = net_mgr.validate_inventory_mutation(1, "ABYSS_CORE_01", 5)
	check_true(inv_valid, "mutação de inventário válida deve ser autorizada pelo host")
	
	var inv_invalid = net_mgr.validate_inventory_mutation(1, "ABYSS_CORE_01", -10)
	check_false(inv_invalid, "mutação com quantidade negativa deve ser rejeitada pelo host")
	
	# Tolerância a quedas: reconexão dentro da janela de 60 segundos
	var client_1_info = net_mgr.get_client_info(1)
	var reconnect_token: String = client_1_info.get("reconnect_token", "")
	check_true(reconnect_token != "", "cliente deve receber token de reconexão seguro")
	
	# Queda abrupta do cliente 1
	net_mgr.unregister_client(1, false)
	check_eq(net_mgr.get_connected_count(), 7, "após desconexão, contagem ativa deve cair para 7")
	
	# Reconexão com novo peer_id usando o mesmo token
	var reconnected = net_mgr.register_client(101, MultiplayerCrossplayScript.PlatformClientType.XBOX_SERIES_S, "Player_1", reconnect_token)
	check_true(reconnected, "cliente deve reconectar com sucesso usando seu session ticket")
	check_eq(net_mgr.get_connected_count(), 8, "após reconexão, contagem deve voltar para 8")
	
	net_mgr.queue_free()

# ------------------------------------------------------- 6. Hell Forge Exclusiva --

func _test_world_exclusive_hell_forge() -> void:
	section("Hell Forge Exclusiva: Autoridade do Host e acesso mútuo exclusivo no mundo privado")
	
	var net_mgr = MultiplayerCrossplayScript.new()
	host.add_child(net_mgr)
	
	net_mgr.register_client(1, MultiplayerCrossplayScript.PlatformClientType.PC_WINDOWS, "HostPlayer")
	net_mgr.register_client(2, MultiplayerCrossplayScript.PlatformClientType.XBOX_SERIES_X, "XboxGuest")
	
	# Jogador 1 solicita uso da Hell Forge
	var access1 = net_mgr.request_hell_forge_access(1)
	check_true(access1, "jogador 1 deve conseguir acessar a Hell Forge")
	
	# Jogador 2 tenta usar a mesma Hell Forge enquanto 1 a utiliza
	var access2 = net_mgr.request_hell_forge_access(2)
	check_false(access2, "jogador 2 deve ter acesso negado enquanto a Hell Forge estiver em uso exclusivo")
	
	# Atualização autoritativa de corrupção
	net_mgr.update_hell_forge_state(35.5, ["INFUSION_FIRE_DRAKE", "INFUSION_VOID_CRYSTAL"])
	var state = net_mgr.get_hell_forge_state()
	check_eq(state["corruption_level"], 35.5, "nível de corrupção da Hell Forge deve ser replicado com exatidão")
	check_eq(state["active_infusions"].size(), 2, "devem haver 2 infusões ativas")
	
	# Jogador 1 libera a Hell Forge
	net_mgr.release_hell_forge(1)
	
	# Jogador 2 tenta novamente
	var access2_retry = net_mgr.request_hell_forge_access(2)
	check_true(access2_retry, "jogador 2 deve conseguir acessar a Hell Forge após a liberação pelo jogador 1")
	
	net_mgr.queue_free()
