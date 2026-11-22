extends Node
## EventBus — barramento central de sinais do Abyssal Pact.
##
## Contém APENAS declarações de sinais: nenhum estado, nenhuma lógica.
## Regra de uso (ver ARCHITECTURE.md):
##   - Eventos de DOMÍNIO CRUZADO são emitidos aqui.
##   - Cada gerenciador pode ter sinais locais para ouvintes diretos;
##     o EventBus é usado quando mais de um domínio reage ao evento.
## Autoload: "EventBus" (primeiro da lista — todos os demais podem conectá-lo).

# ---------------------------------------------------------------- LIFECYCLE --
## Emissor: GameManager. Início do boot dos sistemas.
signal boot_started()
## Emissor: GameManager. Fim do boot; `success` = false quando há problemas.
signal boot_completed(success: bool)
## Emissor: GameManager. Transição do estado global do jogo.
signal game_state_changed(from_state: int, to_state: int)
## Emissor: GameManager. Pedido de encerramento da aplicação.
signal shutdown_requested()

# ------------------------------------------------------------------- SCENE --
## Emissor: SceneManager. Uma troca de cena começou.
signal scene_transition_started(scene_path: String)
## Emissor: SceneManager. A cena nova está carregada e ativa.
signal scene_transition_completed(scene_path: String)
## Emissor: SceneManager. A troca de cena falhou.
signal scene_transition_failed(scene_path: String, error: int)

# ----------------------------------------------------------------- CATALOG --
## Emissor: gerenciadores de catálogo (Race/Class/Demon/Boss/World/...).
signal catalog_loaded(catalog: StringName, count: int)
## Emissor: gerenciadores de catálogo. `issues` descreve problemas de dados.
signal catalog_invalid(catalog: StringName, issues: PackedStringArray)

# ------------------------------------------------------------------- WORLD --
## Emissor: WorldManager. Mundo privado criado.
signal world_created(world_id: StringName, host_participant: int)
## Emissor: WorldManager. Mundo privado encerrado.
signal world_closed(world_id: StringName)
## Emissor: WorldManager. Participante entrou no mundo (limite de 8 respeitado).
signal participant_added(world_id: StringName, participant: int)
## Emissor: WorldManager. Participante saiu do mundo.
signal participant_removed(world_id: StringName, participant: int)
## Emissor: WorldManager. Entrada recusada por exceder o limite de 8.
signal participant_limit_rejected(world_id: StringName, participant: int)
## Emissor: WorldManager. Grupo entrou em uma região catalogada.
signal region_entered(region_id: StringName)
## Emissor: WorldManager. Região descoberta pela primeira vez na exploração.
signal region_discovered(region_id: StringName)
## Emissor: WorldManager / POI. Ponto de interesse descoberto.
signal poi_discovered(region_id: StringName, poi_id: StringName, poi_type: StringName)
## Emissor: WorldManager / Portal. Portal ativado para viagem rápida.
signal portal_activated(portal_id: StringName)
## Emissor: gatilhos de fronteira / portais. Solicitação de transição de mapa.
signal region_transition_requested(from_region: StringName, to_region: StringName, target_spawn: StringName)
signal region_transition_started(from_region: StringName, to_region: StringName)
signal region_transition_completed(from_region: StringName, to_region: StringName)
signal region_transition_failed(from_region: StringName, to_region: StringName, error_code: int)
## Emissor: WorldManager. Início e conclusão de carregamento de mapa/região.
signal region_load_started(region_id: StringName)
signal region_load_progress(region_id: StringName, progress: float)
signal region_load_completed(region_id: StringName)
signal region_unloaded(region_id: StringName)
## Emissor: qualquer sistema. Pedido de ressurgimento de um participante.
signal respawn_requested(participant: int)
## Emissor: WorldManager. Ressurgimento resolvido — destino é SEMPRE o hub
## Hell Forge (invariante de produto; ver HELL_FORGE.md).
signal respawn_resolved(participant: int, hub_id: StringName)

# ---------------------------------------------------------------------- MAP --
## Emissor: MapNavigationSystem / UI. Marcador pessoal adicionado.
signal map_marker_placed(region_id: StringName, marker_id: StringName, marker_type: StringName, position: Vector3, label: String)
## Emissor: MapNavigationSystem / UI. Marcador pessoal removido.
signal map_marker_removed(marker_id: StringName)
## Emissor: MapNavigationSystem / Multiplayer. Ping compartilhado pelo grupo.
signal map_ping_shared(sender_peer: int, region_id: StringName, position: Vector3, ping_type: StringName, label: String)
## Emissor: MapNavigationSystem. Novo setor de exploração revelado (Fog of War).
signal map_sector_explored(region_id: StringName, sector_coord: Vector2i, total_explored: int)
## Emissor: MinimapHUD. Visibilidade ou zoom do minimapa alterado.
signal minimap_visibility_toggled(visible: bool)
signal minimap_zoom_changed(zoom_factor: float)

# --------------------------------------------------------------- CHARACTER --
## Emissor: CharacterManager. Personagem criado com sucesso.
signal character_created(character_id: StringName)
## Emissor: CharacterManager. Personagem excluído.
signal character_deleted(character_id: StringName)
## Emissor: CharacterManager. Personagem selecionado como ativo local.
signal character_selected(character_id: StringName)
## Emissor: CharacterManager. Progressão alterada (`kind`: nível/xp/atributo).
signal progression_changed(character_id: StringName, kind: StringName, value: int)
## Emissor: CharacterManager. Descoberta registrada (demon/boss/region/...).
signal discovery_recorded(character_id: StringName, category: StringName, ref_id: StringName)

# ---------------------------------------------------------------- INVENTORY --
## Emissor: InventoryManager. Itens adicionados ao inventário do personagem.
signal item_added(character_id: StringName, item_id: StringName, total: int)
## Emissor: InventoryManager. Itens removidos do inventário do personagem.
signal item_removed(character_id: StringName, item_id: StringName, total: int)
## Emissor: InventoryManager. Slot de equipamento alterado (ou liberado).
signal equipment_changed(character_id: StringName, slot: StringName, item_id: StringName)

# ------------------------------------------------------------------- QUESTS --
## Emissor: QuestManager. Missão aceita pelo personagem.
signal quest_accepted(character_id: StringName, quest_id: StringName)
## Emissor: QuestManager. Missão abandonada.
signal quest_abandoned(character_id: StringName, quest_id: StringName)
## Emissor: QuestManager. Progresso de objetivo (clampado ao requerido).
signal objective_progress(character_id: StringName, quest_id: StringName, objective_id: StringName, value: int, required: int)
## Emissor: QuestManager. Todos os objetivos concluídos.
signal quest_completed(character_id: StringName, quest_id: StringName)

# ------------------------------------------------------------------ COMBAT --
## Emissor: DemonManager. Pedido de spawn (dados prontos; spawner pendente).
signal demon_spawn_requested(demon_id: StringName, region_id: StringName)
## Emissor: BossManager. Encontro de chefe iniciado (máx. 8 participantes).
signal boss_encounter_started(boss_id: StringName, participant_count: int)
## Emissor: BossManager. Encontro de chefe encerrado.
signal boss_encounter_ended(boss_id: StringName, defeated: bool)
## Emissor: executor de habilidades (PlayerClassComponent). Cast aceito.
## `caster` é o instance_id do emissor (substituto até o sistema de combate).
signal ability_cast_started(caster: int, ability_id: StringName)
## Emissor: executor de habilidades. Cast recusado (cooldown/recurso/dados).
signal ability_cast_failed(caster: int, ability_id: StringName, reason: StringName)
## Emissor: executor de habilidades. Efeito resolvido (dano aplicado ao alvo).
signal ability_cast_resolved(caster: int, ability_id: StringName)
## Emissor: componente de vida. Dano efetivo (após resistência) aplicado.
signal target_damaged(target: int, amount: float, source: int, ability_id: StringName)
## Emissor: componente de vida. Alvo morreu (uma vez por morte).
signal target_died(target: int)
## Emissor: PlayerClassComponent. Loadout de habilidades alterado.
signal class_loadout_changed(participant: int, class_id: StringName)

# ----------------------------------------------------------- BESTIARY / IA --
## Emissor: componente compartilhado de criatura. Criatura regional morreu.
## `instance_id` = id do nó da criatura; recompensas vêm dos dados (DemonData).
signal creature_defeated(demon_id: StringName, instance_id: int, xp: int, gold: int)
## Emissor: componente compartilhado de criatura. Criatura regional ressurgiu
## (respawn configurável nos dados de IA).
signal creature_respawned(demon_id: StringName, instance_id: int)
## Emissor: controlador de chefe. Mudança de fase por limiar de vida.
signal boss_phase_changed(boss_id: StringName, phase_index: int, behavior: StringName)
## Emissor: encontro de chefe. Entrada cinematográfica iniciada.
signal boss_entrance_started(boss_id: StringName, duration_seconds: float)
## Emissor: encontro de chefe. Recompensas especiais concedidas.
signal boss_rewards_granted(boss_id: StringName, xp: int, gold: int)

# ------------------------------------------------------------- WORLD BOSS --
## Emissor: WorldBossSystem. Atualização periódica do ciclo de 5 horas.
signal world_boss_cycle_updated(elapsed_seconds: float, total_seconds: float, state: int)
## Emissor: WorldBossSystem. Mudança de estado do ciclo de Azaroth.
signal world_boss_state_changed(previous_state: int, new_state: int)
## Emissor: WorldBossSystem. Alerta cinematográfico de 1 hora antes da invasão (PROMPT 02).
signal world_boss_one_hour_warning(time_until_spawn: float, region_id: StringName, invasion_pos: Vector3, region_name: String, continent_name: String)
## Emissor: WorldBossSystem. Alerta prévio de invasão (15 min antes).
signal world_boss_warning_issued(time_until_spawn: float, region_id: StringName, invasion_pos: Vector3)
## Emissor: WorldBossSystem. Azaroth emergiu e iniciou combate.
signal world_boss_spawned(boss_id: StringName, region_id: StringName, position: Vector3)
## Emissor: WorldBossSystem. Transição de fase de combate (1 a 4).
signal world_boss_phase_transitioned(boss_id: StringName, phase_index: int, phase_name: String)
## Emissor: WorldBossSystem. Atualização da vida do World Boss.
signal world_boss_health_changed(boss_id: StringName, current_hp: float, max_hp: float)
## Emissor: WorldBossSystem. Dano registrado no World Boss.
signal world_boss_damage_taken(boss_id: StringName, attacker_id: int, amount: float, new_hp: float)
## Emissor: WorldBossSystem. Azaroth foi derrotado pelos jogadores.
signal world_boss_defeated(boss_id: StringName, participants: PackedInt64Array, rewards: Dictionary)
## Emissor: WorldBossSystem. Tempo expirado sem derrota (Azaroth fugiu).
signal world_boss_retreated(boss_id: StringName)
## Emissor: WorldBossSystem. Nova localização dinâmica de invasão selecionada pelo servidor (PROMPT 03).
signal world_boss_invasion_location_selected(region_id: StringName, position: Vector3, region_name: String, continent_name: String)
## Emissor: WorldBossSystem / AzarothSpawnSequence. Progresso da sequência demoníaca de chegada (PROMPT 03).
signal world_boss_arrival_stage_changed(stage: int, stage_name: String, position: Vector3)

# -------------------------------------------------------- DEMONIC INVASION --
## Emissor: DemonicInvasionSystem. Mudança de fase da invasão do exército de Azaroth (PROMPT 04).
signal invasion_phase_changed(region_id: StringName, previous_phase: int, new_phase: int)
## Emissor: DemonicInvasionSystem. Fenda demoníaca aberta no território (PROMPT 04).
signal demonic_fissure_opened(fissure_id: StringName, region_id: StringName, position: Vector3, threat_level: int)
## Emissor: DemonicInvasionSystem. Fenda demoníaca selada ou colapsada (PROMPT 04).
signal demonic_fissure_sealed(fissure_id: StringName, region_id: StringName)
## Emissor: DemonicInvasionSystem. Unidade do exército de Azaroth emergiu do solo (PROMPT 04).
signal invasion_unit_emerged(unit_id: StringName, rank: int, position: Vector3, faction: StringName)
## Emissor: DemonicInvasionSystem. Emboscada tática do exército desencadeada contra jogadores (PROMPT 04).
signal invasion_ambush_triggered(squad_size: int, target_position: Vector3)
## Emissor: DemonicInvasionSystem. Ataque em pinça / pressão multidirecional ativado (PROMPT 04).
signal invasion_pincer_assault_triggered(directions_count: int, target_position: Vector3)
## Emissor: DemonicInvasionSystem. Nível de corrupção atmosférica do território alterado (PROMPT 04).
signal region_corruption_level_changed(region_id: StringName, corruption_ratio: float, fog_density: float)

# ---------------------------------------------------- AZAROTH COMBAT BATTLE --
## Emissor: AzarothCombatController. Habilidade de Azaroth telegrafada na arena (PROMPT 05).
signal azaroth_ability_telegraphed(ability_id: StringName, ability_name: String, target_pos: Vector3, telegraph_duration: float)
## Emissor: AzarothCombatController. Disparo/impacto de habilidade de combate de Azaroth (PROMPT 05).
signal azaroth_ability_cast(ability_id: StringName, ability_name: String, origin_pos: Vector3, radius: float, damage: float)
## Emissor: WorldBossSystem / AzarothCombatController. Início da transição cinematográfica de fase (PROMPT 05).
signal azaroth_phase_cinematic_started(from_phase: int, to_phase: int, phase_name: String, transition_duration: float)
## Emissor: WorldBossSystem / AzarothCombatController. Conclusão da transição cinematográfica de fase (PROMPT 05).
signal azaroth_phase_cinematic_ended(phase: int, phase_name: String)
## Emissor: WorldBossSystem. Início da sequência cinematográfica de vitória e queda do Titã (PROMPT 05).
signal azaroth_victory_cinematic_started(defeated_boss_id: StringName, participants: PackedInt64Array)
## Emissor: WorldBossSystem. Conclusão da vitória, território expurgado e recompensas concedidas (PROMPT 05).
signal azaroth_victory_cinematic_ended(rewards: Dictionary)

# ---------------------------------------------------------------- NETWORK --
## Emissor: MultiplayerManager. Sessão privada hospedada.
signal session_hosted(world_name: String, port: int)
## Emissor: MultiplayerManager. Conectado a uma sessão privada.
signal session_joined(address: String, port: int)
## Emissor: MultiplayerManager. Sessão encerrada/saída.
signal session_left(reason: String)
## Emissor: MultiplayerManager. Peer registrado no roster da sessão.
signal peer_registered(peer_id: int, display_name: String)
## Emissor: MultiplayerManager. Peer removido do roster.
signal peer_unregistered(peer_id: int)
## Emissor: MultiplayerManager. Peer recusado (limite global de 8 já ocupado).
signal peer_limit_rejected(peer_id: int)
## Emissor: MultiplayerManager. Peer rejeitado por validação (token/versão inválidos).
signal peer_rejected(peer_id: int, reason: String)
## Emissor: MultiplayerManager. Peer expulso pelo anfitrião.
signal peer_kicked(peer_id: int, reason: String)
## Emissor: MultiplayerManager. Falha de conexão/hospedagem.
signal connection_failed(reason: String)
## Emissor: NetworkReplication. Jogador em rede instanciado no mundo.
signal network_player_spawned(peer_id: int, character_data: Dictionary, spawn_position: Vector3)
## Emissor: NetworkReplication. Jogador em rede removido do mundo.
signal network_player_despawned(peer_id: int)
## Emissor: NetworkReplication. Ação de combate replicada aos clientes.
signal network_combat_replicated(caster_peer: int, ability_id: StringName, target_position: Vector3)
## Emissor: NetworkReplication. Dano replicado com autoridade do host.
signal network_damage_replicated(target_type: StringName, target_id: StringName, damage_amount: float, new_hp: float, is_dead: bool)
## Emissor: NetworkReplication. Mudança de fase de chefe sincronizada.
signal network_boss_phase_replicated(boss_id: StringName, phase_index: int, phase_name: StringName)
## Emissor: NetworkReplication. Ressurgimento sincronizado na Hell Forge.
signal network_respawn_replicated(peer_id: int, hub_position: Vector3)
## Emissor: NetworkReplication. Mudança de região sincronizada.
signal network_region_transition_replicated(target_region: StringName, spawn_marker: StringName)

# --------------------------------------------------------------------- UI --
## Emissor: UIManager. Tela aberta no router de telas.
signal screen_opened(screen_id: StringName)
## Emissor: UIManager. Tela fechada.
signal screen_closed(screen_id: StringName)
## Emissor: telas/controles. Ação de UI sem consumidor implementado ainda.
signal ui_action_requested(action: StringName)
## Emissor: qualquer sistema. Pedido de notificação visual ao jogador.
signal notification_requested(text: String)

# ------------------------------------------------------------------- AUDIO --
## Emissor: AudioManager. Pedido de música (stream pode não estar atribuído).
signal music_requested(track_id: StringName)
## Emissor: AudioManager. Pedido de efeito sonoro.
signal sfx_requested(sfx_id: StringName)
## Emissor: AudioManager. Pedido de som de interface.
signal ui_audio_requested(audio_id: StringName)

# -------------------------------------------------------------------- SAVE --
## Emissor: SaveManager. Gravação iniciada.
signal save_started(slot: int)
## Emissor: SaveManager. Gravação concluída.
signal save_completed(slot: int)
## Emissor: SaveManager. Gravação falhou (JSON inválido, E/S, dados).
signal save_failed(slot: int, reason: String)
## Emissor: SaveManager. Carga iniciada.
signal load_started(slot: int)
## Emissor: SaveManager. Carga aplicada aos contribuidores.
signal load_completed(slot: int)
## Emissor: SaveManager. Carga falhou.
signal load_failed(slot: int, reason: String)
