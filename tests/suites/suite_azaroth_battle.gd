class_name SuiteAzarothBattle
extends TestCase
## SuiteAzarothBattle — Testes da Batalha Exclusiva contra Azaroth (PROMPT 05).
##
## Validações:
##   1. Identidade única do World Boss Azaroth (não é inimigo comum nem demônio superior).
##   2. Padrões de combate da Fase 1: Ascensão da Fenda (Despertar Tectônico, infantaria de flanco).
##   3. Padrões de combate da Fase 2: Fúria Vulcânica (Feixe cósmico, chuva de magma, guarda superior).
##   4. Padrões de combate da Fase 3: Tempestade do Caos (Vórtice gravitacional, nova do vazio, primordiais).
##   5. Padrões de combate da Fase 4: O Devorador Despertado (Enrage, devoração cataclísmica, frenesi total).
##   6. Transições cinematográficas invulneráveis entre fases (4.5s) e banners na interface.
##   7. Dificuldade progressiva estrita (dano, velocidade, tempo de telegrafia e recarga).
##   8. Sincronização multiplayer de habilidades, telegrafias e fases via RPC.
##   9. Conclusão cinematográfica de vitória: queda do Titã (6.0s), expurgamento do território e recompensas.
##   10. Persistência de save/load e restauração do ciclo em combate.

const WorldBossSystemScript := preload("res://core/world_boss_system.gd")
const AzarothCombatControllerScript := preload("res://scenes/world/components/azaroth_combat_controller.gd")
const BannerScript := preload("res://scenes/ui/components/azaroth_phase_cinematic_banner.gd")
const WorldBossDataScript := preload("res://data/models/world_boss_data.gd")
const DemonicInvasionSystemScript := preload("res://core/demonic_invasion_system.gd")

func suite_name() -> String:
	return "azaroth_battle"

func execute() -> void:
	await _test_exclusive_world_boss_identity()
	await _test_combat_patterns_phase_1()
	await _test_combat_patterns_phase_2()
	await _test_combat_patterns_phase_3()
	await _test_combat_patterns_phase_4_enrage()
	await _test_cinematic_phase_transitions_and_invulnerability()
	await _test_progressive_difficulty_evolution()
	await _test_multiplayer_synchronization_of_battle()
	await _test_victory_sequence_and_world_territory_update()
	await _test_persistence_and_cycle_restoration()

# -------------------------------- 1. IDENTIDADE ÚNICA DE AZAROTH --

func _test_exclusive_world_boss_identity() -> void:
	section("1. Identidade Única do World Boss: Comandante Supremo da Invasão")
	var bosses := system(SystemNames.BOSSES) as Node
	check_not_null(bosses, "BossManager disponível")

	var wb_sys: Node = bosses.call("world_boss_system")
	check_not_null(wb_sys, "WorldBossSystem disponível")

	var data: Resource = wb_sys.call("boss_data")
	check_not_null(data, "WorldBossData carregado")

	check_eq(data.get("id"), Invariants.WORLD_BOSS_ID, "ID canônico WB-AZAROTH")
	check_eq(data.get("display_name"), Invariants.WORLD_BOSS_NAME, "Nome Azaroth, o Devorador de Reinos")
	check_true(is_equal_approx(float(data.get("max_health")), Invariants.WORLD_BOSS_MAX_HEALTH), "1.000.000 HP")
	check_true(float(data.get("attack_power")) >= 800.0, "Poder de ataque titânico (>= 800)")
	check_true(float(data.get("scale_factor")) >= 3.5, "Escala colossal de 3.5x")

	# Verifica que Azaroth NÃO é tratado como inimigo comum nem como demônio superior
	check_false(String(data.get("id")).begins_with("DEMON-"), "Azaroth não é monstro comum do catálogo DEMON-XXX")
	check_false(String(data.get("id")).begins_with("BOSS-"), "Azaroth não é chefe individual de dungeon BOSS-XXX")

	var phases_arr: Array = data.get("phases")
	check_eq(phases_arr.size(), 4, "possui exatamente 4 fases canônicas de combate")

# -------------------------------- 2. PADRÕES DA FASE 1 --

func _test_combat_patterns_phase_1() -> void:
	section("2. Padrões de Combate — Fase 1: Ascensão da Fenda (Despertar Tectônico)")
	var data: Resource = WorldBossDataScript.create_canonical()
	var inv_sys: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys)
	inv_sys.call("start_invasion", &"REG-001", DemonicInvasionSystemScript.Phase.EXPANSION)

	var controller: Node = AzarothCombatControllerScript.new()
	host.add_child(controller)
	controller.call("setup", data, inv_sys)

	check_eq(int(controller.call("get_current_phase")), 1, "inicia na Fase 1")
	check_true(is_equal_approx(float(controller.call("get_damage_multiplier")), 1.0), "multiplicador de dano 1.0x na Fase 1")
	check_true(is_equal_approx(float(controller.call("get_speed_multiplier")), 1.0), "multiplicador de velocidade 1.0x na Fase 1")

	var tel_cap := capture(EventBus.azaroth_ability_telegraphed)
	var cast_cap := capture(EventBus.azaroth_ability_cast)

	# Simula avanço de combate com jogador próximo (10m)
	var players_near := [Vector3(0.0, 0.0, 10.0)]
	controller.call("advance_combat", 4.1, players_near) # Dispara telegrafia de Impacto Tectônico

	check_eq(int(controller.call("get_current_combat_state")), int(AzarothCombatControllerScript.CombatState.TELEGRAPHING), "estado TELEGRAPHING")
	check_true(tel_cap.count() >= 1, "sinal azaroth_ability_telegraphed emitido")
	check_eq(controller.call("get_active_ability_id"), Invariants.ABIL_AZAROTH_TECTONIC_SLAM, "habilidade selecionada é Impacto Tectônico para alvos próximos")

	# Avança o tempo de telegrafia (2.2s) para executar o golpe
	controller.call("advance_combat", 2.3, players_near)
	check_eq(int(controller.call("get_current_combat_state")), int(AzarothCombatControllerScript.CombatState.CASTING), "estado CASTING após telegrafia")
	check_true(cast_cap.count() >= 1, "sinal azaroth_ability_cast emitido")

	controller.queue_free()
	inv_sys.call("cleanse_invasion")
	inv_sys.queue_free()

# -------------------------------- 3. PADRÕES DA FASE 2 --

func _test_combat_patterns_phase_2() -> void:
	section("3. Padrões de Combate — Fase 2: Fúria Vulcânica (Feixes e Guarda Superior)")
	var data: Resource = WorldBossDataScript.create_canonical()
	var inv_sys: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys)
	inv_sys.call("start_invasion", &"REG-002", DemonicInvasionSystemScript.Phase.EXPANSION)

	var controller: Node = AzarothCombatControllerScript.new()
	host.add_child(controller)
	controller.call("setup", data, inv_sys)

	# Transiciona para Fase 2
	controller.call("trigger_phase_transition", 2, "Fúria Vulcânica")
	controller.call("advance_combat", Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION + 0.1, [])

	check_eq(int(controller.call("get_current_phase")), 2, "controlador na Fase 2")
	check_true(is_equal_approx(float(controller.call("get_damage_multiplier")), Invariants.AZAROTH_P2_DMG_MULT), "dano aumentado para 1.2x na Fase 2")
	check_true(is_equal_approx(float(controller.call("get_speed_multiplier")), Invariants.AZAROTH_P2_SPEED_MULT), "velocidade aumentada para 1.1x na Fase 2")

	# Verifica que demônios superiores foram convocados como guarda
	var superiors: Array = inv_sys.call("get_superior_units")
	check_true(superiors.size() >= 1, "exército convocou demônios superiores para suporte tático")

	controller.queue_free()
	inv_sys.call("cleanse_invasion")
	inv_sys.queue_free()

# -------------------------------- 4. PADRÕES DA FASE 3 --

func _test_combat_patterns_phase_3() -> void:
	section("4. Padrões de Combate — Fase 3: Tempestade do Caos (Vórtices e Primordiais)")
	var data: Resource = WorldBossDataScript.create_canonical()
	var inv_sys: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys)
	inv_sys.call("start_invasion", &"REG-015", DemonicInvasionSystemScript.Phase.EXPANSION)

	var controller: Node = AzarothCombatControllerScript.new()
	host.add_child(controller)
	controller.call("setup", data, inv_sys)

	# Transiciona para Fase 3
	controller.call("trigger_phase_transition", 3, "Tempestade do Caos")
	controller.call("advance_combat", Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION + 0.1, [])

	check_eq(int(controller.call("get_current_phase")), 3, "controlador na Fase 3")
	check_true(is_equal_approx(float(controller.call("get_damage_multiplier")), Invariants.AZAROTH_P3_DMG_MULT), "dano aumentado para 1.35x na Fase 3")
	check_true(is_equal_approx(float(controller.call("get_speed_multiplier")), Invariants.AZAROTH_P3_SPEED_MULT), "velocidade aumentada para 1.2x na Fase 3")

	# Primordiais acelerados no campo
	var primordials: Array = inv_sys.call("get_primordial_units")
	check_true(primordials.size() >= 1, "criaturas primordiais emergiram em suporte à Fase 3")

	controller.queue_free()
	inv_sys.call("cleanse_invasion")
	inv_sys.queue_free()

# -------------------------------- 5. PADRÕES DA FASE 4 (ENRAGE) --

func _test_combat_patterns_phase_4_enrage() -> void:
	section("5. Padrões de Combate — Fase 4: O Devorador Despertado (Enrage Apocalíptico)")
	var data: Resource = WorldBossDataScript.create_canonical()
	var inv_sys: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys)
	inv_sys.call("start_invasion", &"REG-025", DemonicInvasionSystemScript.Phase.EXPANSION)

	var controller: Node = AzarothCombatControllerScript.new()
	host.add_child(controller)
	controller.call("setup", data, inv_sys)

	# Transiciona para Fase 4
	controller.call("trigger_phase_transition", 4, "O Devorador Despertado")
	controller.call("advance_combat", Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION + 0.1, [])

	check_eq(int(controller.call("get_current_phase")), 4, "controlador na Fase 4 (Enrage)")
	check_true(is_equal_approx(float(controller.call("get_damage_multiplier")), Invariants.AZAROTH_P4_DMG_MULT), "dano massivo aumentado para 1.6x no Enrage")
	check_true(is_equal_approx(float(controller.call("get_speed_multiplier")), Invariants.AZAROTH_P4_SPEED_MULT), "velocidade aumentada para 1.35x no Enrage")

	var all_units: Array = inv_sys.call("get_active_units")
	check_true(all_units.size() >= 4, "exército em mobilização total na Fase 4")

	controller.queue_free()
	inv_sys.call("cleanse_invasion")
	inv_sys.queue_free()

# -------------------------------- 6. TRANSIÇÕES CINEMATOGRÁFICAS --

func _test_cinematic_phase_transitions_and_invulnerability() -> void:
	section("6. Transições Cinematográficas entre Fases e Invulnerabilidade")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")
	wb_sys.call("reset_cycle")
	wb_sys.call("trigger_spawn") # Entra em State.ACTIVE

	var controller: Node = wb_sys.call("get_combat_controller")
	check_not_null(controller, "combat controller ativo")
	check_false(bool(controller.call("is_invulnerable")), "não invulnerável em combate normal")

	var cin_start_cap := capture(EventBus.azaroth_phase_cinematic_started)
	var cin_end_cap := capture(EventBus.azaroth_phase_cinematic_ended)

	# Reduz HP para 74% (cruza o limiar de 75% -> Fase 2)
	wb_sys.call("apply_damage", Invariants.WORLD_BOSS_MAX_HEALTH * 0.26)

	check_eq(int(wb_sys.call("current_phase")), 2, "transicionou para Fase 2")
	check_true(bool(controller.call("is_invulnerable")), "Azaroth fica invulnerável durante a transição cinematográfica")
	check_eq(int(controller.call("get_current_combat_state")), int(AzarothCombatControllerScript.CombatState.PHASE_TRANSITION), "estado é PHASE_TRANSITION")
	check_true(cin_start_cap.count() >= 1, "sinal azaroth_phase_cinematic_started emitido")

	# Testa bloqueio de dano durante invulnerabilidade
	var hp_before := float(wb_sys.call("current_hp"))
	var hp_after := float(wb_sys.call("apply_damage", 5000.0))
	check_true(is_equal_approx(hp_before, hp_after), "dano bloqueado enquanto canaliza transição de fase")

	# Avança o tempo da transição cinematográfica (4.5s)
	wb_sys.call("advance_timer", Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION + 0.5)
	check_false(bool(controller.call("is_invulnerable")), "invulnerabilidade removida após a conclusão da cinemática")
	check_true(cin_end_cap.count() >= 1, "sinal azaroth_phase_cinematic_ended emitido")

	wb_sys.call("reset_cycle")

# -------------------------------- 7. DIFICULDADE PROGRESSIVA ESTRITA --

func _test_progressive_difficulty_evolution() -> void:
	section("7. Dificuldade Progressiva: Escalonamento de Dano, Velocidade e Recargas")
	var data: Resource = WorldBossDataScript.create_canonical()
	var phases_arr: Array = data.get("phases")

	var prev_dmg := 0.0
	var prev_spd := 0.0
	var prev_cd := 999.0
	var prev_tel := 999.0

	for i in range(phases_arr.size()):
		var p: Dictionary = phases_arr[i]
		var dmg: float = float(p.get("damage_mult", 1.0))
		var spd: float = float(p.get("speed_mult", 1.0))
		var cd: float = float(p.get("attack_cooldown", 4.0))
		var tel: float = float(p.get("telegraph_duration", 2.0))

		check_true(dmg > prev_dmg, "multiplicador de dano aumenta estritamente na Fase %d (%.2f > %.2f)" % [i + 1, dmg, prev_dmg])
		check_true(spd > prev_spd, "multiplicador de velocidade aumenta estritamente na Fase %d (%.2f > %.2f)" % [i + 1, spd, prev_spd])
		check_true(cd < prev_cd, "tempo de recarga diminui estritamente na Fase %d (%.2fs < %.2fs)" % [i + 1, cd, prev_cd])
		check_true(tel < prev_tel, "janela de telegrafia fica mais rápida na Fase %d (%.2fs < %.2fs)" % [i + 1, tel, prev_tel])

		prev_dmg = dmg
		prev_spd = spd
		prev_cd = cd
		prev_tel = tel

# -------------------------------- 8. SINCRONIZAÇÃO MULTIPLAYER --

func _test_multiplayer_synchronization_of_battle() -> void:
	section("8. Sincronização Multiplayer da Batalha (RPCs e Fases)")
	var net_mgr := system(SystemNames.NET) as MultiplayerManager
	check_not_null(net_mgr, "MultiplayerManager disponível")

	check_true(net_mgr.has_method("rpc_azaroth_ability_telegraphed"), "rpc_azaroth_ability_telegraphed registrado")
	check_true(net_mgr.has_method("rpc_azaroth_ability_cast"), "rpc_azaroth_ability_cast registrado")
	check_true(net_mgr.has_method("rpc_azaroth_phase_cinematic"), "rpc_azaroth_phase_cinematic registrado")
	check_true(net_mgr.has_method("rpc_azaroth_victory_sequence"), "rpc_azaroth_victory_sequence registrado")

	var tel_cap := capture(EventBus.azaroth_ability_telegraphed)
	var cin_cap := capture(EventBus.azaroth_phase_cinematic_started)

	net_mgr.rpc_azaroth_ability_telegraphed(Invariants.ABIL_AZAROTH_ABYSSAL_BEAM, "Feixe do Abismo", Vector3(20, 0, 20), 1.6)
	check_true(tel_cap.count() >= 1, "sinal emitido no recebimento de telegrafia RPC")

	net_mgr.rpc_azaroth_phase_cinematic(2, 3, "Tempestade do Caos", 4.5)
	check_true(cin_cap.count() >= 1, "sinal emitido no recebimento de transição de fase RPC")

# -------------------------------- 9. SEQUÊNCIA DE VITÓRIA E EXPURGAMENTO --

func _test_victory_sequence_and_world_territory_update() -> void:
	section("9. Conclusão Cinematográfica de Vitória e Expurgamento do Território")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")
	wb_sys.call("reset_cycle")
	wb_sys.call("trigger_spawn") # Entra em State.ACTIVE

	var inv_sys: Node = wb_sys.call("get_invasion_system")
	inv_sys.call("start_invasion", &"REG-011", DemonicInvasionSystemScript.Phase.EXPANSION)
	check_true(float(inv_sys.call("get_corruption_level")) > 0.5, "território corrompido durante a invasão")

	var vic_start_cap := capture(EventBus.azaroth_victory_cinematic_started)
	var vic_end_cap := capture(EventBus.azaroth_victory_cinematic_ended)

	# Aplica dano letal a Azaroth
	wb_sys.call("apply_damage", Invariants.WORLD_BOSS_MAX_HEALTH * 2.0)

	check_true(bool(wb_sys.call("is_defeated")), "Azaroth derrotado")
	check_true(vic_start_cap.count() >= 1, "sinal azaroth_victory_cinematic_started emitido")

	# Verifica que o território foi expurgado imediatamente na vitória
	check_true(is_equal_approx(float(inv_sys.call("get_corruption_level")), 0.0), "corrupção do território zerada (expurgada)")
	check_eq(int(inv_sys.call("get_fissures_count")), 0, "todas as fendas foram seladas")
	check_eq(int(inv_sys.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.CLEANSED), "status da região: CLEANSED")

	# Avança colapso cinematográfico (6.0s)
	wb_sys.call("advance_timer", Invariants.WORLD_BOSS_VICTORY_COLLAPSE_DURATION + 0.5)
	check_true(vic_end_cap.count() >= 1, "sinal azaroth_victory_cinematic_ended emitido")

	wb_sys.call("reset_cycle")

# -------------------------------- 10. PERSISTÊNCIA DE SAVE/LOAD EM COMBATE --

func _test_persistence_and_cycle_restoration() -> void:
	section("10. Persistência de Save/Load e Restauração de Combate")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")
	wb_sys.call("reset_cycle")
	wb_sys.call("trigger_spawn")
	wb_sys.call("apply_damage", Invariants.WORLD_BOSS_MAX_HEALTH * 0.55) # Reduz para 45% (Fase 3)

	check_eq(int(wb_sys.call("current_phase")), 3, "em combate na Fase 3")

	var save_data: Dictionary = wb_sys.call("collect_save_data")
	check_eq(int(save_data.get("state")), int(WorldBossSystemScript.State.ACTIVE), "estado ACTIVE salvo")
	check_eq(int(save_data.get("current_phase")), 3, "Fase 3 salva")
	check_true(float(save_data.get("current_hp")) < Invariants.WORLD_BOSS_MAX_HEALTH * 0.5, "HP reduzido salvo")

	# Restaura estado
	wb_sys.call("reset_cycle")
	check_eq(int(wb_sys.call("state")), int(WorldBossSystemScript.State.DORMANT), "reset para DORMANT")

	wb_sys.call("apply_save_data", save_data)
	check_eq(int(wb_sys.call("state")), int(WorldBossSystemScript.State.ACTIVE), "estado ACTIVE restaurado")
	check_eq(int(wb_sys.call("current_phase")), 3, "Fase 3 restaurada")

	wb_sys.call("reset_cycle")
