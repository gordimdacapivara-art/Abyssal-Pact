class_name Invariants
## Invariantes de produto do Abyssal Pact (fonte única de verdade em código).
##
## Cada constante espelha uma decisão confirmada na documentação de Fase 0.
## GameManager.verify_all() valida que os gerenciadores usam estes valores,
## evitando constantes divergentes espalhadas pelo projeto.

## Limite total de jogadores por mundo privado, anfitrião incluído
## (PROJECT_OVERVIEW.md / GAMEPLAY_SYSTEMS.md).
const MAX_PARTICIPANTS := 8

## Id do peer do anfitrião no transporte padrão da Godot (ENet usa 1).
const HOST_PEER_ID := 1

## Destino OBRIGATÓRIO de ressurgimento: hub Hell Forge
## (HELL_FORGE.md — regra de produto, não substituível por spawn local).
## Observação: o hub é tratado como entidade própria ("hell_forge"), fora das
## 40 regiões reservadas (REG-001..REG-040); se o design futuro considerar o
## hub uma região, esta constante e o catálogo devem ser reconciliados.
const HUB_REGION_ID := &"hell_forge"

## Prefixos editoriais reservados pela documentação (não são nomes de lore):
## demônios regionais e chefes NÃO podem se sobrepor (PROJECT_OVERVIEW.md).
const DEMON_ID_PREFIX := "DEMON-"
const BOSS_ID_PREFIX := "BOSS-"
const REGION_ID_PREFIX := "REG-"
const RACE_ID_PREFIX := "RACE-"
const SUBRACE_ID_PREFIX := "SUBRACE-"
const CLASS_ID_PREFIX := "CLASS-"

## World Boss Azaroth: Titã Abissal único de Abyssal Pact (PROMPT 01 & PROMPT 02)
const WORLD_BOSS_ID := &"WB-AZAROTH"
const WORLD_BOSS_NAME := "Azaroth, o Devorador de Reinos"
const WORLD_BOSS_CYCLE_DURATION := 18000.0 # 5 horas por ciclo (18.000 segundos)
const WORLD_BOSS_DORMANT_DURATION := 15300.0 # 4 horas e 15 minutos de calmaria
const WORLD_BOSS_WARNING_DURATION := 900.0 # 15 minutos de aviso prévio
const WORLD_BOSS_COMBAT_DURATION := 1800.0 # 30 minutos de combate ativo
const WORLD_BOSS_MAX_HEALTH := 1000000.0 # Vida massiva para cooperação até 8 jogadores
const WORLD_BOSS_ONE_HOUR_ALERT_REMAINING := 3600.0 # 1 hora antes do spawn (3.600 segundos)
const WORLD_BOSS_ONE_HOUR_CYCLE_TIME := 12600.0 # Segundo 12.600 do ciclo (16.200 - 3.600)
const WORLD_BOSS_SPAWN_DISTANCE := 1000.0 # ~1 km dos jogadores (PROMPT 03)
const WORLD_BOSS_ARRIVAL_TREMOR_DURATION := 4.0 # Duração do abalo sísmico inicial (s)
const WORLD_BOSS_ARRIVAL_EMERGENCE_DURATION := 6.0 # Duração da subida vertical das profundezas (s)
const WORLD_BOSS_ARRIVAL_SHOCKWAVE_DURATION := 3.0 # Duração do rugido e onda de choque (s)
const WORLD_BOSS_TOTAL_ARRIVAL_DURATION := 13.0 # Duração total da chegada demoníaca sem teletransporte (s)

## Exército de Azaroth: Invasão e Hierarquia Militar (PROMPT 04)
const AZAROTH_ARMY_FACTION := &"ARMY_AZAROTH"
const AZAROTH_ARMY_NAME := "Exército de Azaroth"
const DEMON_RANK_INFERIOR := 0   # Demônios inferiores: unidades comuns do exército
const DEMON_RANK_SUPERIOR := 1   # Demônios superiores: unidades militares de elite com habilidades especiais
const DEMON_RANK_PRIMORDIAL := 2 # Primordiais: criaturas especiais fortalecidas com atributos massivos
const INVASION_PHASE_DORMANT := 0
const INVASION_PHASE_CORRUPTION := 1 # Primeira fase: A Corrupção
const INVASION_PHASE_EXPANSION := 2  # Segunda fase: Expansão da Invasão
const INVASION_PHASE_CULMINATION := 3 # Culminação: Azaroth no campo
const INVASION_PHASE_CLEANSED := 4

# Multiplicadores de atributos da hierarquia militar
const SUPERIOR_DEMON_HP_MULT := 1.75
const SUPERIOR_DEMON_DMG_MULT := 1.5
const PRIMORDIAL_DEMON_HP_MULT := 3.0
const PRIMORDIAL_DEMON_DMG_MULT := 2.0
const PRIMORDIAL_DEMON_DEF_MULT := 1.5

## Batalha Exclusiva contra Azaroth: Fases e Habilidades (PROMPT 05)
const WORLD_BOSS_PHASE_TRANSITION_DURATION := 4.5 # Segundos de transição cinematográfica invulnerável entre fases
const WORLD_BOSS_VICTORY_COLLAPSE_DURATION := 6.0 # Segundos de animação e colapso na vitória sobre o Titã
const AZAROTH_P1_DMG_MULT := 1.0
const AZAROTH_P1_SPEED_MULT := 1.0
const AZAROTH_P2_DMG_MULT := 1.2
const AZAROTH_P2_SPEED_MULT := 1.1
const AZAROTH_P3_DMG_MULT := 1.35
const AZAROTH_P3_SPEED_MULT := 1.2
const AZAROTH_P4_DMG_MULT := 1.6
const AZAROTH_P4_SPEED_MULT := 1.35

# Identificadores canônicos das habilidades de Azaroth
const ABIL_AZAROTH_TECTONIC_SLAM := &"ABIL_AZAROTH_TECTONIC_SLAM"
const ABIL_AZAROTH_ABYSSAL_RIFT := &"ABIL_AZAROTH_ABYSSAL_RIFT"
const ABIL_AZAROTH_ABYSSAL_BEAM := &"ABIL_AZAROTH_ABYSSAL_BEAM"
const ABIL_AZAROTH_MAGMA_RAIN := &"ABIL_AZAROTH_MAGMA_RAIN"
const ABIL_AZAROTH_CHAOS_VORTEX := &"ABIL_AZAROTH_CHAOS_VORTEX"
const ABIL_AZAROTH_VOID_NOVA := &"ABIL_AZAROTH_VOID_NOVA"
const ABIL_AZAROTH_CATACLYSMIC_DEVOUR := &"ABIL_AZAROTH_CATACLYSMIC_DEVOUR"
const ABIL_AZAROTH_APOCALYPTIC_BARRAGE := &"ABIL_AZAROTH_APOCALYPTIC_BARRAGE"

## Versão do formato de save (SaveManager + ARCHITECTURE.md).
const SAVE_FORMAT_ID := "abyssal_pact_save"
const SAVE_FORMAT_VERSION := 1
