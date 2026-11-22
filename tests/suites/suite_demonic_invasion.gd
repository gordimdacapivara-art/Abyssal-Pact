class_name SuiteDemonicInvasion
extends TestCase
## SuiteDemonicInvasion — Testes do Sistema de Invasão do Exército de Azaroth (PROMPT 04).
##
## Validações:
##   1. Primeira fase — A Corrupção:
##      - Corrupção demoníaca do ambiente (nível 0.3, atmosfera e névoa carmesim).
##      - Fendas demoníacas pelo território (surgimento, contagem mínima e registro).
##      - Mudança progressiva da atmosfera (densidade de neblina 0.022, céu corrompido).
##      - Emergência física das criaturas do solo (-8.0m até 0.0m sem teletransporte).
##      - Demônios inferiores e superiores atacando os jogadores.
##      - Emboscadas táticas em flancos e pontos cegos.
##   2. Segunda fase — Expansão da Invasão:
##      - Intensidade aumentada (nível 0.75, névoa carmesim densa 0.045).
##      - Reforços contínuos do exército emergindo das fendas.
##      - Fendas tornam-se grandes ameaças com campo de dano em área (hazard DPS).
##      - Criaturas primordiais com atributos fortalecidos (3x HP, 2x DMG, 1.5x DEF, aura e escala 1.6x).
##      - Investidas em pinça pressionando os jogadores de múltiplas direções simultâneas.
##   3. Hierarquia militar:
##      - Demônios inferiores (comuns).
##      - Demônios superiores (elites militares com habilidades, NÃO são chefes individuais).
##      - Primordiais (fortalecidos com auras maciças).
##      - Todas as unidades pertencem estritamente à facção ARMY_AZAROTH.
##   4. Integração com WorldBossSystem, ciclo de 5h, persistência (save/load) e sincronização multiplayer.

const WorldBossSystemScript := preload("res://core/world_boss_system.gd")
const DemonicInvasionSystemScript := preload("res://core/demonic_invasion_system.gd")
const FissureScript := preload("res://scenes/world/components/demonic_fissure.gd")
const UnitDataScript := preload("res://data/models/invasion_army_unit_data.gd")

func suite_name() -> String:
	return "demonic_invasion"

func execute() -> void:
	await _test_corruption_phase_activation()
	await _test_fissures_and_subterranean_emergence()
	await _test_military_hierarchy_inferior_and_superior()
	await _test_tactical_ambush()
	await _test_expansion_phase_and_fissure_hazard()
	await _test_primordial_creatures()
	await _test_pincer_assault()
	await _test_strict_army_faction_verification()
	await _test_world_boss_system_integration_and_lifecycle()
	await _test_save_load_persistence_and_multiplayer_rpc()

# -------------------------------- 1. PRIMEIRA FASE — A CORRUPÇÃO --

func _test_corruption_phase_activation() -> void:
	section("1. Primeira Fase — A Corrupção (Ambiente e Atmosfera)")
	var inv_sys: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys)

	check_eq(int(inv_sys.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.DORMANT), "fase inicial é DORMANT")
	check_true(is_equal_approx(float(inv_sys.call("get_corruption_level")), 0.0), "corrupção inicial é 0.0")

	var phase_cap := capture(EventBus.invasion_phase_changed)
	var corr_cap := capture(EventBus.region_corruption_level_changed)

	# Inicia invasão na região REG-003 (Planície das Cinzas)
	inv_sys.call("start_invasion", &"REG-003", DemonicInvasionSystemScript.Phase.CORRUPTION)

	check_eq(int(inv_sys.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.CORRUPTION), "fase atual é CORRUPTION")
	check_eq(inv_sys.call("get_target_region"), &"REG-003", "região alvo registrada como REG-003")
	check_true(absf(float(inv_sys.call("get_corruption_level")) - 0.3) < 0.05, "nível de corrupção atinge 0.3 na Fase 1")
	check_true(absf(float(inv_sys.call("get_fog_density")) - DemonicInvasionSystemScript.CORRUPTION_FOG_DENSITY) < 0.005, "densidade de neblina aumenta para 0.022")
	check_eq(inv_sys.call("get_fog_color"), DemonicInvasionSystemScript.CORRUPTION_FOG_COLOR, "cor da neblina muda para carmesim sombrio")

	# Pelo menos 3 fendas devem ter sido abertas automaticamente
	check_true(int(inv_sys.call("get_fissures_count")) >= 3, "pelo menos 3 fendas abertas na Fase 1")
	check_true(phase_cap.count() >= 1, "sinal invasion_phase_changed emitido")
	check_true(corr_cap.count() >= 1, "sinal region_corruption_level_changed emitido")

	inv_sys.call("cleanse_invasion")
	inv_sys.queue_free()

# -------------------------------- 2. FENDAS E EMERGÊNCIA SUBTERRÂNEA --

func _test_fissures_and_subterranean_emergence() -> void:
	section("2. Fendas Demoníacas e Emergência Física do Solo (-8m a 0m)")
	var fissure: Node = FissureScript.new()
	host.add_child(fissure)
	fissure.call("setup", &"FISSURE-TEST-01", &"REG-001", Vector3(50, 0, 50), 1)

	check_true(bool(fissure.call("is_active")), "fenda ativa após setup")
	check_eq(int(fissure.call("get_threat_level")), 1, "nível de ameaça inicial é MINOR (1)")
	check_true(is_equal_approx(float(fissure.call("get_hazard_radius")), 6.0), "raio de perigo inicial é 6.0m")

	# Cria unidade militar e testa subida física
	var unit: Resource = UnitDataScript.create_army_unit(&"ARMY-INF-001", UnitDataScript.MilitaryRank.INFERIOR, &"REG-001")
	check_not_null(unit, "unidade do exército criada com sucesso")
	check_true(is_equal_approx(float(unit.get("current_y_offset")), 0.0), "offset Y padrão é 0.0")

	unit.call("start_emergence")
	check_true(bool(unit.get("is_emerging")), "emergência ativada")
	check_true(is_equal_approx(float(unit.get("current_y_offset")), -8.0), "inicia nas profundezas do solo a -8.0m")

	# Avança 1 segundo de emergência (50% do tempo de 2s)
	unit.call("advance_emergence", 1.0)
	check_true(bool(unit.get("is_emerging")), "ainda emergindo aos 1.0s")
	check_true(float(unit.get("current_y_offset")) > -8.0, "unidade subiu fisicamente")
	check_true(float(unit.get("current_y_offset")) < 0.0, "unidade ainda não atingiu a superfície")

	# Completa os 2 segundos
	unit.call("advance_emergence", 1.5)
	check_false(bool(unit.get("is_emerging")), "emergência concluída aos 2.0s")
	check_true(is_equal_approx(float(unit.get("current_y_offset")), 0.0), "unidade atinge exatamente a superfície (0.0m)")

	fissure.call("seal")
	check_true(bool(fissure.call("is_sealed")), "fenda selada com sucesso")
	fissure.queue_free()

# -------------------------------- 3. HIERARQUIA MILITAR: INFERIORES E SUPERIORES --

func _test_military_hierarchy_inferior_and_superior() -> void:
	section("3. Hierarquia Militar: Demônios Inferiores e Superiores (Elites Militares)")
	var inf_unit: Resource = UnitDataScript.create_army_unit(&"ARMY-INF-001", UnitDataScript.MilitaryRank.INFERIOR, &"REG-005")
	var sup_unit: Resource = UnitDataScript.create_army_unit(&"ARMY-SUP-001", UnitDataScript.MilitaryRank.SUPERIOR, &"REG-005")

	# Inferiores
	check_true(bool(inf_unit.call("is_inferior")), "unidade inferior classificada corretamente")
	check_false(bool(inf_unit.call("is_superior")), "unidade inferior não é superior")
	check_true(is_equal_approx(float(inf_unit.get("visual_scale")), 1.0), "escala padrão 1.0")
	var inf_abils: PackedStringArray = inf_unit.get("special_abilities")
	check_true(inf_abils.has("golpe_abissal"), "inferior possui golpe abissal")
	check_eq(inf_unit.get("army_faction"), Invariants.AZAROTH_ARMY_FACTION, "facção estritamente ARMY_AZAROTH")

	# Superiores: tropas de elite, atributos maiores, habilidades especiais, NÃO chefes individuais
	check_true(bool(sup_unit.call("is_superior")), "unidade superior classificada corretamente")
	check_false(bool(sup_unit.call("is_inferior")), "unidade superior não é inferior")
	check_false(bool(sup_unit.call("is_primordial")), "unidade superior não é primordial")
	check_true(float(sup_unit.get("max_health")) > float(inf_unit.get("max_health")), "HP superior maior que inferior")
	check_true(float(sup_unit.get("attack_damage")) > float(inf_unit.get("attack_damage")), "dano superior maior que inferior")
	check_true(float(sup_unit.get("visual_scale")) > float(inf_unit.get("visual_scale")), "porte visual maior (1.25x)")

	var sup_abils: PackedStringArray = sup_unit.get("special_abilities")
	check_true(sup_abils.has("grito_de_guerra"), "superior possui grito de guerra")
	check_true(sup_abils.has("rajada_carmesim"), "superior possui rajada carmesim")
	check_true(sup_abils.has("esmagar_abissal"), "superior possui esmagar abissal")
	var sup_auras: Dictionary = sup_unit.get("aura_effects")
	check_true(sup_auras.has("command_radius"), "superior possui aura de comando militar")
	check_false(String(sup_unit.get("unit_id")).begins_with("BOSS-"), "superior NÃO é chefe individual do catálogo BOSS-XXX")
	check_eq(sup_unit.get("army_faction"), Invariants.AZAROTH_ARMY_FACTION, "facção estritamente ARMY_AZAROTH")

# -------------------------------- 4. EMBOSCADAS TÁTICAS --

func _test_tactical_ambush() -> void:
	section("4. Táticas Militares: Emboscadas Coordenadas (Fase 1)")
	var inv_sys: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys)
	inv_sys.call("start_invasion", &"REG-002", DemonicInvasionSystemScript.Phase.CORRUPTION)

	var ambush_cap := capture(EventBus.invasion_ambush_triggered)
	var player_pos := Vector3(100.0, 0.0, 150.0)

	var squad: Array = inv_sys.call("trigger_ambush", player_pos, 4)
	check_eq(squad.size(), 4, "esquadrão de emboscada contém 4 tropas")
	check_true(ambush_cap.count() >= 1, "sinal invasion_ambush_triggered emitido")

	var has_inferior := false
	var has_superior := false
	for u in squad:
		if u != null:
			if bool(u.call("is_inferior")): has_inferior = true
			if bool(u.call("is_superior")): has_superior = true
			check_true(bool(u.get("is_emerging")), "unidades de emboscada emergem fisicamente")
			check_eq(u.get("army_faction"), Invariants.AZAROTH_ARMY_FACTION, "tropas da emboscada integram ARMY_AZAROTH")

	check_true(has_inferior, "emboscada contém demônios inferiores")
	check_true(has_superior, "emboscada é liderada por demônio superior")

	inv_sys.call("cleanse_invasion")
	inv_sys.queue_free()

# -------------------------------- 5. SEGUNDA FASE — EXPANSÃO E PERIGO DAS FENDAS --

func _test_expansion_phase_and_fissure_hazard() -> void:
	section("5. Segunda Fase — Expansão da Invasão e Campo de Dano das Fendas")
	var inv_sys: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys)
	inv_sys.call("start_invasion", &"REG-011", DemonicInvasionSystemScript.Phase.CORRUPTION)

	# Fenda de teste
	var f_node: Node = inv_sys.call("open_demonic_fissure", Vector3(0, 0, 0), 1)
	check_eq(int(f_node.call("get_threat_level")), 1, "fenda começa como nível 1")

	# Transição para Fase 2: Expansão
	inv_sys.call("set_phase", DemonicInvasionSystemScript.Phase.EXPANSION)

	check_eq(int(inv_sys.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.EXPANSION), "fase avançou para EXPANSION")
	check_true(absf(float(inv_sys.call("get_corruption_level")) - 0.75) < 0.05, "nível de corrupção atinge 0.75")
	check_true(absf(float(inv_sys.call("get_fog_density")) - DemonicInvasionSystemScript.EXPANSION_FOG_DENSITY) < 0.005, "neblina densa em 0.045")
	check_eq(inv_sys.call("get_fog_color"), DemonicInvasionSystemScript.EXPANSION_FOG_COLOR, "neblina carmesim profunda")

	# Fenda expandida para GREATER (2)
	check_eq(int(f_node.call("get_threat_level")), 2, "fenda expandida para ameaça GREATER (2)")
	check_true(is_equal_approx(float(f_node.call("get_hazard_radius")), 12.0), "raio de perigo ampliado para 12.0m")
	check_true(is_equal_approx(float(f_node.call("get_hazard_dps")), 16.0), "DPS perigoso da fenda ampliado para 16.0/s")

	# Teste de dano de proximidade aos combatentes
	var player_in_hazard := [Vector3(5.0, 0.0, 0.0)] # Dentro do raio de 12m
	var player_outside := [Vector3(25.0, 0.0, 0.0)]  # Fora do raio de 12m

	var dmg_taken := float(f_node.call("deal_hazard_damage", 1.0, player_in_hazard))
	check_true(absf(dmg_taken - 16.0) < 0.5, "jogador dentro da área da fenda recebe dano de área (16.0 DPS)")

	var safe_dmg := float(f_node.call("deal_hazard_damage", 1.0, player_outside))
	check_true(is_equal_approx(safe_dmg, 0.0), "jogador fora do raio da fenda não sofre dano")

	inv_sys.call("cleanse_invasion")
	inv_sys.queue_free()

# -------------------------------- 6. CRIATURAS PRIMORDIAIS FORTALECIDAS --

func _test_primordial_creatures() -> void:
	section("6. Criaturas Primordiais: Atributos Fortalecidos e Auras")
	var pri: Resource = UnitDataScript.create_army_unit(&"ARMY-PRI-001", UnitDataScript.MilitaryRank.PRIMORDIAL, &"REG-021")

	check_true(bool(pri.call("is_primordial")), "unidade classificada como Primordial")
	check_false(bool(pri.call("is_inferior")), "primordial não é inferior")
	check_false(bool(pri.call("is_superior")), "primordial não é superior")

	# Multiplicadores canônicos de atributos
	var base_hp := 120.0
	var base_dmg := 18.0
	var base_def := 8.0
	check_true(absf(float(pri.get("max_health")) - base_hp * Invariants.PRIMORDIAL_DEMON_HP_MULT) < 1.0, "HP 3.0x de criatura primordial")
	check_true(absf(float(pri.get("attack_damage")) - base_dmg * Invariants.PRIMORDIAL_DEMON_DMG_MULT) < 1.0, "Dano 2.0x de criatura primordial")
	check_true(absf(float(pri.get("defense")) - base_def * Invariants.PRIMORDIAL_DEMON_DEF_MULT) < 1.0, "Defesa 1.5x de criatura primordial")
	check_true(is_equal_approx(float(pri.get("visual_scale")), 1.6), "escala colossal de 1.6x")

	# Habilidades e auras
	var pri_abils: PackedStringArray = pri.get("special_abilities")
	check_true(pri_abils.has("furia_primordial"), "habilidade furia_primordial")
	check_true(pri_abils.has("onda_magmatica"), "habilidade onda_magmatica")
	check_true(pri_abils.has("abismo_devorador"), "habilidade abismo_devorador")
	var pri_auras: Dictionary = pri.get("aura_effects")
	check_true(pri_auras.has("corruption_dps"), "aura de corrupção contínua (8.0 DPS)")
	check_eq(pri.get("army_faction"), Invariants.AZAROTH_ARMY_FACTION, "facção obrigatória ARMY_AZAROTH")

# -------------------------------- 7. INVESTIDA EM PINÇA MULTIDIRECIONAL --

func _test_pincer_assault() -> void:
	section("7. Táticas Militares: Cerco e Investida em Pinça Multidirecional (Fase 2)")
	var inv_sys: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys)
	inv_sys.call("start_invasion", &"REG-025", DemonicInvasionSystemScript.Phase.EXPANSION)

	var pincer_cap := capture(EventBus.invasion_pincer_assault_triggered)
	var player_pos := Vector3(0.0, 0.0, 0.0)

	var assault_units: Array = inv_sys.call("trigger_pincer_assault", player_pos, 3, 2)
	check_eq(assault_units.size(), 6, "investida em pinça gerou 6 tropas no total (3 direções x 2 tropas)")
	check_true(pincer_cap.count() >= 1, "sinal invasion_pincer_assault_triggered emitido")

	var primordials: Array = inv_sys.call("get_primordial_units")
	var superiors: Array = inv_sys.call("get_superior_units")
	var inferiors: Array = inv_sys.call("get_inferior_units")

	check_true(primordials.size() >= 1, "investida inclui pelo menos 1 criatura primordial na vanguarda")
	check_true(superiors.size() >= 1, "investida inclui demônios superiores nos flancos")
	check_true(inferiors.size() >= 1, "investida inclui tropas inferiores de suporte")

	inv_sys.call("cleanse_invasion")
	inv_sys.queue_free()

# -------------------------------- 8. VERIFICAÇÃO ESTRITA DE FACÇÃO --

func _test_strict_army_faction_verification() -> void:
	section("8. Verificação Estrita: 100% das Unidades Pertencem a ARMY_AZAROTH")
	var inv_sys: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys)
	inv_sys.call("start_invasion", &"REG-008", DemonicInvasionSystemScript.Phase.EXPANSION)

	# Gera várias tropas de diferentes patentes
	inv_sys.call("spawn_army_unit", DemonicInvasionSystemScript.MilitaryRank.INFERIOR, Vector3(10, 0, 10))
	inv_sys.call("spawn_army_unit", DemonicInvasionSystemScript.MilitaryRank.SUPERIOR, Vector3(20, 0, 20))
	inv_sys.call("spawn_army_unit", DemonicInvasionSystemScript.MilitaryRank.PRIMORDIAL, Vector3(30, 0, 30))

	var all_units: Array = inv_sys.call("get_active_units")
	check_true(all_units.size() >= 3, "unidades registradas no sistema")

	for u in all_units:
		if u != null:
			check_eq(u.get("army_faction"), Invariants.AZAROTH_ARMY_FACTION, "unidade %s pertence estritamente a ARMY_AZAROTH" % String(u.get("unit_id")))
			check_false(String(u.get("unit_id")).begins_with("BOSS-"), "unidade %s NÃO colide com catálogo individual BOSS-XXX" % String(u.get("unit_id")))

	inv_sys.call("cleanse_invasion")
	inv_sys.queue_free()

# -------------------------------- 9. INTEGRAÇÃO COM WORLD BOSS SYSTEM --

func _test_world_boss_system_integration_and_lifecycle() -> void:
	section("9. Integração com WorldBossSystem: Transições de Fase e Expurgamento")
	var bosses := system(SystemNames.BOSSES) as Node
	check_not_null(bosses, "BossManager disponível")

	var wb_sys: Node = bosses.call("world_boss_system")
	check_not_null(wb_sys, "WorldBossSystem disponível")

	var inv_sys: Node = wb_sys.call("get_invasion_system")
	check_not_null(inv_sys, "DemonicInvasionSystem integrado no WorldBossSystem")

	wb_sys.call("reset_cycle")
	check_eq(int(inv_sys.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.CLEANSED), "invasão dormente/expurgada no início do ciclo")

	# Avança até o aviso prévio de 15 minutos (15.300s)
	wb_sys.call("set_cycle_time", 15305.0)
	wb_sys.call("advance_timer", 1.0)
	check_true(bool(wb_sys.call("is_warning")), "WorldBossSystem entrou em State.WARNING")
	check_eq(int(inv_sys.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.CORRUPTION), "invasão entrou automaticamente em Fase 1 (CORRUPTION)")
	check_true(int(inv_sys.call("get_fissures_count")) >= 3, "fendas abertas pelo exército de Azaroth")

	# Avança para os últimos 5 minutos de aviso (15.910s — faltam 290s para Azaroth)
	wb_sys.call("set_cycle_time", 15910.0)
	wb_sys.call("advance_timer", 1.0)
	check_eq(int(inv_sys.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.EXPANSION), "invasão entrou em Fase 2 (EXPANSION) nos 5m finais")
	check_true(int(inv_sys.call("get_fissures_count")) >= 6, "fendas ampliadas e reforços convocados")

	# Avança para spawn de Azaroth (16.200s — State.ACTIVE)
	wb_sys.call("set_cycle_time", 16205.0)
	wb_sys.call("advance_timer", 1.0)
	check_true(bool(wb_sys.call("is_active")), "WorldBossSystem ativo no combate")
	check_eq(int(inv_sys.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.CULMINATION), "invasão em fase de culminação com Azaroth no campo")

	# Derrota de Azaroth expurga o território
	wb_sys.call("apply_damage", Invariants.WORLD_BOSS_MAX_HEALTH * 2.0)
	check_true(bool(wb_sys.call("is_defeated")), "Azaroth derrotado pelos guerreiros")
	check_eq(int(inv_sys.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.CLEANSED), "território expurgado após vitória sobre Azaroth")
	check_eq(int(inv_sys.call("get_fissures_count")), 0, "todas as fendas foram seladas")
	check_true(is_equal_approx(float(inv_sys.call("get_corruption_level")), 0.0), "nível de corrupção zerado")

	# Restaura estado
	wb_sys.call("reset_cycle")

# -------------------------------- 10. PERSISTÊNCIA E RPC MULTIPLAYER --

func _test_save_load_persistence_and_multiplayer_rpc() -> void:
	section("10. Persistência de Save/Load e Sincronização RPC em Rede")
	var inv_sys1: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys1)
	inv_sys1.call("start_invasion", &"REG-014", DemonicInvasionSystemScript.Phase.EXPANSION)
	inv_sys1.call("spawn_army_unit", DemonicInvasionSystemScript.MilitaryRank.SUPERIOR, Vector3(15, 0, 15))

	var saved_dict: Dictionary = inv_sys1.call("collect_save_data")
	check_eq(int(saved_dict.get("phase")), int(DemonicInvasionSystemScript.Phase.EXPANSION), "fase salva com precisão")
	check_eq(String(saved_dict.get("target_region")), "REG-014", "região salva com precisão")
	check_true(absf(float(saved_dict.get("corruption_level")) - 0.75) < 0.05, "nível de corrupção salvo")
	check_true((saved_dict.get("fissures", []) as Array).size() > 0, "fendas serializadas")
	check_true((saved_dict.get("units", []) as Array).size() > 0, "tropas serializadas")

	# Restaura em novo sistema
	var inv_sys2: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys2)
	inv_sys2.call("apply_save_data", saved_dict)

	check_eq(int(inv_sys2.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.EXPANSION), "fase restaurada")
	check_eq(inv_sys2.call("get_target_region"), &"REG-014", "região restaurada")
	check_true(absf(float(inv_sys2.call("get_corruption_level")) - 0.75) < 0.05, "corrupção restaurada")
	check_eq(int(inv_sys2.call("get_fissures_count")), int(inv_sys1.call("get_fissures_count")), "quantidade de fendas restaurada")

	# RPC multiplayer
	var net_mgr := system(SystemNames.NET) as MultiplayerManager
	check_not_null(net_mgr, "MultiplayerManager disponível")
	check_true(net_mgr.has_method("rpc_sync_demonic_invasion_phase"), "rpc_sync_demonic_invasion_phase registrado")
	check_true(net_mgr.has_method("rpc_trigger_invasion_ambush"), "rpc_trigger_invasion_ambush registrado")
	check_true(net_mgr.has_method("rpc_trigger_invasion_pincer"), "rpc_trigger_invasion_pincer registrado")

	inv_sys1.call("cleanse_invasion")
	inv_sys1.queue_free()
	inv_sys2.call("cleanse_invasion")
	inv_sys2.queue_free()
