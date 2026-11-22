class_name SuiteWorldBossLocation
extends TestCase
## SuiteWorldBossLocation — Testes de validação da Localização Dinâmica da Invasão de Azaroth (PROMPT 03).
##
## Valida:
##   1. Seleção aleatória de região dentre os três continentes disponíveis (Veyrath, Sylvaran, Khar-Duum — 30 regiões).
##   2. Exclusão estrita e inviolável do Verdadeiro Inferno (Hell Forge / DIM-HELL-FORGE).
##   3. Autoridade do servidor para escolha da região e sincronização multiplayer.
##   4. Compatibilidade da localização com o relevo natural, terreno e fora de zonas de segurança.
##   5. Spawn de Azaroth a aproximadamente 1 km (~1.000m) dos jogadores.
##   6. Sequência demoníaca de chegada (sem teletransporte visível ou surgimento artificial).
##   7. Mapa-múndi e mapa regional com marcação da região, continente, coordenadas e progressão de indicadores.
##   8. Sincronização em rede: todos os jogadores visualizam a mesma localização.

const WorldBossSystemScript := preload("res://core/world_boss_system.gd")
const AzarothSpawnSequenceScript := preload("res://scenes/world/components/azaroth_spawn_sequence.gd")

func suite_name() -> String:
	return "world_boss_location"

func execute() -> void:
	await _test_geographic_restrictions_and_three_continents()
	await _test_strict_exclusion_of_verdadeiro_inferno()
	await _test_server_authority_and_random_selection()
	await _test_terrain_and_environment_compatibility()
	await _test_spawn_distance_from_players_approximately_1km()
	await _test_demonic_arrival_sequence_no_teleportation()
	await _test_map_indicators_and_progression()
	await _test_multiplayer_synchronization_of_location()

# -------------------------------- 1. RESTRIÇÕES GEOGRÁFICAS E OS TRÊS CONTINENTES --

func _test_geographic_restrictions_and_three_continents() -> void:
	section("1. Restrições Geográficas e os Três Continentes Permitidos (30 Regiões)")
	var bosses := system(SystemNames.BOSSES) as Node
	check_not_null(bosses, "BossManager disponível no SystemRegistry")

	var wb: Node = bosses.call("world_boss_system")
	check_not_null(wb, "WorldBossSystem instanciado")

	# Continentes permitidos: Veyrath (CONT-01), Sylvaran (CONT-02), Khar-Duum (CONT-03)
	var conts: Array[StringName] = wb.call("get_valid_invasion_continents")
	check_eq(conts.size(), 3, "exatamente três continentes permitidos para invasão")
	check_true(conts.has(&"CONT-01"), "continente Veyrath presente")
	check_true(conts.has(&"CONT-02"), "continente Sylvaran presente")
	check_true(conts.has(&"CONT-03"), "continente Khar-Duum presente")
	check_false(conts.has(&"CONT-04"), "Nhal'Kora (CONT-04) não pertence aos três continentes disponíveis de invasão")

	# Regiões permitidas: 30 regiões (REG-001 a REG-030)
	var regions: Array[StringName] = wb.call("get_valid_invasion_regions")
	check_eq(regions.size(), 30, "exatamente 30 regiões válidas nos três continentes")

	for i in range(1, 31):
		var reg_id := StringName("REG-%03d" % i)
		check_true(wb.call("is_valid_invasion_region", reg_id), "região %s é válida" % reg_id)

	# Regiões acima de 30 não são permitidas
	check_false(wb.call("is_valid_invasion_region", &"REG-031"), "REG-031 fora do escopo dos três continentes")
	check_false(wb.call("is_valid_invasion_region", &"REG-040"), "REG-040 fora do escopo dos três continentes")

# -------------------------------- 2. EXCLUSÃO ESTRITA DO VERDADEIRO INFERNO --

func _test_strict_exclusion_of_verdadeiro_inferno() -> void:
	section("2. Exclusão Estrita do Verdadeiro Inferno (Hell Forge NUNCA selecionado)")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb: Node = bosses.call("world_boss_system")

	# Validação direta das constantes e checagem de regras de produto
	check_false(wb.call("is_valid_invasion_region", Invariants.HUB_REGION_ID), "hub hell_forge rejeitado como região de invasão")
	check_false(wb.call("is_valid_invasion_region", &"DIM-HELL-FORGE"), "DIM-HELL-FORGE rejeitado")
	check_false(wb.call("is_valid_invasion_region", &"verdadeiro_inferno"), "verdadeiro_inferno rejeitado")

	# 100 sorteios aleatórios sucessivos para garantir que NUNCA seleciona o Verdadeiro Inferno
	var valid_regions: Array[StringName] = wb.call("get_valid_invasion_regions")
	for i in range(100):
		var loc: Dictionary = wb.call("select_random_invasion_location", i * 17 + 3)
		var chosen: StringName = loc.get("region_id", &"")
		check_ne(chosen, Invariants.HUB_REGION_ID, "sorteio %d nunca é hell_forge" % i)
		check_ne(chosen, &"DIM-HELL-FORGE", "sorteio %d nunca é DIM-HELL-FORGE" % i)
		check_true(valid_regions.has(chosen), "sorteio %d (%s) é uma região válida dos 3 continentes" % [i, chosen])
		var cont_id: StringName = loc.get("continent_id", &"")
		check_true(cont_id == &"CONT-01" or cont_id == &"CONT-02" or cont_id == &"CONT-03", "continente é um dos 3 permitidos")

# -------------------------------- 3. AUTORIDADE DO SERVIDOR E SELEÇÃO --

func _test_server_authority_and_random_selection() -> void:
	section("3. Autoridade do Servidor na Seleção da Localização de Invasão")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb: Node = bosses.call("world_boss_system")

	var loc_capture := capture(EventBus.world_boss_invasion_location_selected)

	# Executa seleção autoritativa com semente definida
	var loc_res: Dictionary = wb.call("select_random_invasion_location", 42)
	check_not_null(loc_res, "resultado do sorteio não nulo")
	check_eq(loc_capture.count(), 1, "evento world_boss_invasion_location_selected disparado")

	var reg_id: StringName = loc_res.get("region_id", &"")
	var pos: Vector3 = loc_res.get("world_position", Vector3.ZERO)
	var reg_name: String = loc_res.get("region_name", "")
	var cont_name: String = loc_res.get("continent_name", "")

	check_ne(reg_id, &"", "ID da região selecionada preenchido")
	check_ne(reg_name, "", "Nome da região preenchido")
	check_ne(cont_name, "", "Nome do continente preenchido")
	check_eq(wb.call("get_threatened_region_id"), reg_id, "estado interno do World Boss sincronizado com o sorteio")
	check_eq(wb.call("invasion_position"), pos, "posição interna sincronizada com o sorteio")

	# Consistência determinística quando fornecida semente
	var loc_repeat: Dictionary = wb.call("select_random_invasion_location", 42)
	check_eq(loc_repeat.get("region_id"), reg_id, "semente idêntica seleciona a mesma região")

# -------------------------------- 4. COMPATIBILIDADE DE TERRENO E RELEVO --

func _test_terrain_and_environment_compatibility() -> void:
	section("4. Compatibilidade com o Terreno, Relevo Natural e Zonas de Segurança")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb: Node = bosses.call("world_boss_system")

	# Testa coordenadas e relevo em múltiplas regiões dos 3 continentes
	var sample_regions: Array[StringName] = [&"REG-001", &"REG-011", &"REG-021"] # Veyrath, Sylvaran, Khar-Duum
	for reg_id in sample_regions:
		wb.call("set_invasion_target", reg_id, Vector3(0.0, 0.0, 0.0))
		var pos_comp: Vector3 = wb.call("_compute_terrain_compatible_position", reg_id)
		check_true(is_finite(pos_comp.x), "coordenada X finita para %s" % reg_id)
		check_true(is_finite(pos_comp.y), "coordenada Y finita para %s" % reg_id)
		check_true(is_finite(pos_comp.z), "coordenada Z finita para %s" % reg_id)
		check_true(pos_comp.y >= 0.0, "elevação do terreno Y >= 0.0 para %s (assentado no solo)" % reg_id)

		# Verifica que não está colado no centro seguro (distância >= 50m)
		var center_dist := Vector2(pos_comp.x, pos_comp.z).length()
		check_true(center_dist >= 50.0, "coordenada fora da safe zone central da região (dist: %.1fm)" % center_dist)
		check_true(center_dist <= 150.0, "coordenada dentro dos limites da região (dist: %.1fm <= 150m)" % center_dist)

# -------------------------------- 5. DISTÂNCIA DE SPAWN (~1 KM DOS JOGADORES) --

func _test_spawn_distance_from_players_approximately_1km() -> void:
	section("5. Spawn de Azaroth a ~1 km (~1.000m) dos Jogadores")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb: Node = bosses.call("world_boss_system")

	# Cenário A: Jogador solo na posição (0, 0, 0)
	var single_player: Array[Vector3] = [Vector3(0.0, 0.0, 0.0)]
	var spawn_a: Vector3 = wb.call("compute_spawn_position_for_players", single_player)
	var dist_a := spawn_a.distance_to(single_player[0])
	check_true(wb.call("is_spawn_distance_valid", spawn_a, single_player[0]), "distância de spawn válida para jogador solo (~1km)")
	check_true(dist_a >= 850.0 and dist_a <= 1150.0, "distância calculada (%.1fm) está entre 850m e 1150m (~1 km)" % dist_a)

	# Cenário B: Grupo de jogadores espalhados na região
	var party_players: Array[Vector3] = [
		Vector3(150.0, 5.0, 100.0),
		Vector3(-80.0, 2.0, -50.0),
		Vector3(40.0, 0.0, -120.0),
		Vector3(-30.0, 1.0, 80.0)
	]
	var centroid := Vector3.ZERO
	for p in party_players:
		centroid += p
	centroid /= float(party_players.size())

	var spawn_b: Vector3 = wb.call("compute_spawn_position_for_players", party_players)
	var dist_centroid := spawn_b.distance_to(centroid)
	check_true(wb.call("is_spawn_distance_valid", spawn_b, centroid), "distância de spawn válida em relação ao centróide do grupo")
	check_true(dist_centroid >= 850.0 and dist_centroid <= 1150.0, "distância do centróide (%.1fm) está a ~1 km" % dist_centroid)

# -------------------------------- 6. SEQUÊNCIA DEMONÍACA DE CHEGADA --

func _test_demonic_arrival_sequence_no_teleportation() -> void:
	section("6. Sequência Demoníaca de Chegada sem Teletransporte ou Pop-in Artificial")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb: Node = bosses.call("world_boss_system")

	var seq: Node = wb.call("get_spawn_sequence")
	check_not_null(seq, "componente AzarothSpawnSequence instanciado")

	seq.call("reset_sequence")
	check_eq(int(seq.call("get_current_stage")), int(AzarothSpawnSequenceScript.Stage.NONE), "estado inicial inativo")
	check_false(bool(seq.call("is_in_progress")), "sequência não está em progresso antes de iniciar")

	var dummy_boss := Node3D.new()
	host.add_child(dummy_boss)
	var test_pos := Vector3(500.0, 0.0, 500.0)
	seq.call("start_sequence", test_pos, dummy_boss)

	# Fase 1: Abalo Sísmico e Fissura Magmática
	check_eq(int(seq.call("get_current_stage")), int(AzarothSpawnSequenceScript.Stage.TECTONIC_TREMOR), "fase 1: abalo sísmico iniciado")
	check_true(bool(seq.call("is_in_progress")), "sequência ativa durante abalo sísmico")
	check_true(dummy_boss.global_position.y <= -30.0, "titã posicionado abaixo da terra (-35m), invisível na superfície")

	# Avança tempo do abalo sísmico (4 segundos)
	seq.call("advance_sequence", 4.1)
	# Fase 2: Ascensão Física das Profundezas
	check_eq(int(seq.call("get_current_stage")), int(AzarothSpawnSequenceScript.Stage.EMERGENCE), "fase 2: ascensão abissal iniciada")
	check_eq(seq.call("get_stage_name", AzarothSpawnSequenceScript.Stage.EMERGENCE), "Ascensão Abissal das Profundezas", "nome da fase de ascensão correto")

	# Simula meio caminho da subida (3.0s de 6.0s)
	seq.call("advance_sequence", 3.0)
	var mid_y: float = float(seq.call("get_boss_vertical_offset"))
	check_true(mid_y > -35.0 and mid_y < 0.0, "subida física contínua: Y atual é %.1fm (sem teletransporte)" % mid_y)
	check_true(is_equal_approx(dummy_boss.global_position.y, mid_y), "posição do nó 3D do chefe acompanha a subida física")

	# Conclui a ascensão
	seq.call("advance_sequence", 3.5)
	# Fase 3: Rugido Titânico e Onda de Choque
	check_eq(int(seq.call("get_current_stage")), int(AzarothSpawnSequenceScript.Stage.SHOCKWAVE_ROAR), "fase 3: rugido e onda de choque iniciados")
	check_eq(dummy_boss.global_position.y, 0.0, "titã assentado na superfície (Y = 0.0m)")

	# Expansão da onda de choque (3.0s)
	seq.call("advance_sequence", 1.5)
	var shock_r: float = float(seq.call("get_shockwave_radius"))
	check_true(shock_r >= 50.0 and shock_r <= 150.0, "onda de choque expandindo radialmente: %.1fm" % shock_r)

	seq.call("advance_sequence", 2.0)
	# Fase 4: Concluído
	check_eq(int(seq.call("get_current_stage")), int(AzarothSpawnSequenceScript.Stage.COMPLETED), "fase 4: chegada concluída")
	check_true(bool(seq.call("is_completed")), "sequência finalizada com sucesso para combate ativo")

	dummy_boss.queue_free()

# -------------------------------- 7. MAPA E PROGRESSÃO DE INDICADORES --

func _test_map_indicators_and_progression() -> void:
	section("7. Mapa-múndi e Regional: Região, Continente, Coordenadas e Indicadores")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb: Node = bosses.call("world_boss_system")
	var ui := system(SystemNames.UI) as UIManager

	wb.call("reset_cycle")
	wb.call("set_invasion_target", &"REG-007", Vector3(100.0, 5.0, -80.0))

	# Consulta sumário oficial de invasão
	var summary: Dictionary = wb.call("get_invasion_status_summary")
	check_eq(summary.get("region_id"), &"REG-007", "ID da região no sumário")
	check_eq(summary.get("region_name"), "Passo da Vigília", "Nome amigável da região correto")
	check_eq(summary.get("continent_id"), &"CONT-01", "ID do continente correto")
	check_eq(summary.get("continent_name"), "Veyrath", "Nome do continente correto")
	check_eq(summary.get("invasion_position"), Vector3(100.0, 5.0, -80.0), "coordenadas 3D registradas")

	# Abre tela do Mapa-Múndi
	ui.open_screen(&"world_map", {"region_id": &"REG-007"})
	await wait_frames(2)

	var world_map := ui.current_screen() as WorldMapScreen
	check_not_null(world_map, "WorldMapScreen aberta e responsiva")

	# Abre tela do Mapa Regional para a região ameaçada
	ui.open_screen(&"regional_map", {"region_id": &"REG-007"})
	await wait_frames(2)

	var reg_map := ui.current_screen() as RegionalMapScreen
	check_not_null(reg_map, "RegionalMapScreen aberta")

	var reg_markers := reg_map.get_all_regional_markers()
	var found_azaroth_marker := false
	for m in reg_markers:
		if String(m.get("id", "")) == "wb_azaroth_invasion":
			found_azaroth_marker = true
			check_eq(m.get("type"), "world_boss", "tipo do marcador é world_boss")
			check_eq(m.get("position"), Vector3(100.0, 5.0, -80.0), "posição do marcador no mapa regional corresponde ao spawn")
			break
	check_true(found_azaroth_marker, "marcador oficial de invasão de Azaroth presente no mapa regional")

	ui.close_screen(&"regional_map")

# -------------------------------- 8. SINCRONIZAÇÃO MULTIPLAYER DA LOCALIZAÇÃO --

func _test_multiplayer_synchronization_of_location() -> void:
	section("8. Sincronização em Rede da Mesma Localização para Todos os Jogadores")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb: Node = bosses.call("world_boss_system")
	var net_mgr := system(SystemNames.NET) as MultiplayerManager
	check_not_null(net_mgr, "MultiplayerManager disponível")

	var sync_capture := capture(EventBus.world_boss_invasion_location_selected)

	# Simula aplicação de pacote autoritativo recebido via RPC
	wb.call("apply_invasion_target_sync", &"REG-022", Vector3(250.0, 10.0, -150.0), 2)

	check_eq(wb.call("get_threatened_region_id"), &"REG-022", "região atualizada para REG-022 (Fornalha dos Reis)")
	check_eq(wb.call("get_threatened_region_name"), "Fornalha dos Reis", "nome da região identificado")
	check_eq(wb.call("get_threatened_continent_name"), "Khar-Duum", "continente Khar-Duum identificado")
	check_eq(wb.call("invasion_position"), Vector3(250.0, 10.0, -150.0), "coordenadas sincronizadas identicamente")
	check_eq(sync_capture.count(), 1, "evento world_boss_invasion_location_selected disparado no cliente")
	check_eq(wb.call("get_arrival_stage"), 2, "fase de chegada atualizada para ascensão (estágio 2)")
