class_name PlatformManager
extends Node
## PlatformManager — Coordenador Central de Plataforma, Hardware e Otimização.
##
## Centraliza a gestão de perfis técnicos para Windows PC, Xbox Series S e Xbox Series X.
## Integra adaptadores de persistência, detecção de dispositivos de controle,
## políticas de Crossplay e monitoramento ativo do orçamento de memória.

const PlatformProfile := preload("res://systems/platform/platform_profile.gd")
const DeviceManager := preload("res://systems/platform/device_manager.gd")
const PlatformStorageAdapter := preload("res://systems/platform/platform_storage_adapter.gd")
const MultiplayerCrossplayManager := preload("res://systems/platform/multiplayer_crossplay_manager.gd")

signal platform_profile_changed(new_profile: Resource)
signal memory_warning(used_mb: float, budget_mb: float, percentage: float)

@export var auto_detect_platform: bool = true

var active_profile: Resource
var device_manager: Node
var storage_adapter: RefCounted
var crossplay_manager: Node

var _memory_check_timer: float = 0.0
const MEMORY_CHECK_INTERVAL_SEC: float = 5.0
const MEMORY_WARNING_THRESHOLD_PCT: float = 85.0 # Alerta ao ultrapassar 85% do orçamento

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_initialize_subsystems()

func _ready() -> void:
	if auto_detect_platform:
		detect_and_apply_platform()
	else:
		apply_profile(PlatformProfile.create_pc_profile())

func _process(delta: float) -> void:
	_memory_check_timer += delta
	if _memory_check_timer >= MEMORY_CHECK_INTERVAL_SEC:
		_memory_check_timer = 0.0
		_check_memory_budget()

func _initialize_subsystems() -> void:
	if device_manager == null:
		device_manager = DeviceManager.new()
		device_manager.name = "DeviceManager"
		add_child(device_manager)
		
	if crossplay_manager == null:
		crossplay_manager = MultiplayerCrossplayManager.new()
		crossplay_manager.name = "MultiplayerCrossplayManager"
		add_child(crossplay_manager)

## Detecta a plataforma alvo por argumentos de inicialização, recursos do SO ou padrão
func detect_and_apply_platform() -> void:
	var cmdline_args := OS.get_cmdline_args()
	for arg in cmdline_args:
		if arg == "--platform=series_s" or arg == "--xbox-series-s":
			apply_profile(PlatformProfile.create_series_s_profile())
			return
		elif arg == "--platform=series_x" or arg == "--xbox-series-x":
			apply_profile(PlatformProfile.create_series_x_profile())
			return
		elif arg == "--platform=pc":
			apply_profile(PlatformProfile.create_pc_profile())
			return

	# Checa recursos de compilação ou ambiente
	if OS.has_feature("xbox_series_s"):
		apply_profile(PlatformProfile.create_series_s_profile())
	elif OS.has_feature("xbox_series_x") or OS.has_feature("xbox"):
		apply_profile(PlatformProfile.create_series_x_profile())
	else:
		# Padrão para ambiente Windows PC
		apply_profile(PlatformProfile.create_pc_profile())

## Aplica integralmente as configurações gráficas, limites e orçamentos do perfil
func apply_profile(profile: Resource) -> void:
	active_profile = profile
	
	# 1. Configuração do adaptador de persistência de acordo com a plataforma
	match profile.platform_type:
		PlatformProfile.PlatformType.XBOX_SERIES_S, PlatformProfile.PlatformType.XBOX_SERIES_X:
			storage_adapter = PlatformStorageAdapter.XboxConnectedStorageAdapterStub.new()
		_:
			storage_adapter = PlatformStorageAdapter.LocalStorageAdapter.new()

	# 2. Resolução e Taxa de Quadros
	Engine.max_fps = profile.target_fps
	
	# 3. Aplicar parâmetros do viewport e renderizador se houver viewport disponível
	var vp := get_viewport()
	if vp != null:
		if "mesh_lod_threshold" in vp:
			vp.mesh_lod_threshold = profile.lod_threshold_pixels
		var vp_rid := vp.get_viewport_rid()
		if vp_rid.is_valid():
			var msaa_val: RenderingServer.ViewportMSAA = RenderingServer.VIEWPORT_MSAA_DISABLED
			match profile.msaa_3d_quality:
				1: msaa_val = RenderingServer.VIEWPORT_MSAA_2X
				2: msaa_val = RenderingServer.VIEWPORT_MSAA_4X
				3: msaa_val = RenderingServer.VIEWPORT_MSAA_8X
			RenderingServer.viewport_set_msaa_3d(vp_rid, msaa_val)

	# 4. Ajuste dinâmico de resolução (Scaling 3D)
	if profile.dynamic_resolution_enabled:
		ProjectSettings.set_setting("rendering/scaling_3d/mode", 1) # FSR 1.0 ou 2.2
		ProjectSettings.set_setting("rendering/scaling_3d/scale", profile.min_resolution_scale)
	else:
		ProjectSettings.set_setting("rendering/scaling_3d/scale", 1.0)

	# 5. Sombra e Oclusão
	RenderingServer.directional_shadow_atlas_set_size(profile.shadow_atlas_size, true)

	platform_profile_changed.emit(active_profile)

## Alterna manualmente a plataforma ativa
func switch_to_platform(type: int) -> void:
	match type:
		PlatformProfile.PlatformType.PC_WINDOWS:
			apply_profile(PlatformProfile.create_pc_profile())
		PlatformProfile.PlatformType.XBOX_SERIES_S:
			apply_profile(PlatformProfile.create_series_s_profile())
		PlatformProfile.PlatformType.XBOX_SERIES_X:
			apply_profile(PlatformProfile.create_series_x_profile())

## Verifica o consumo de memória estática em relação ao orçamento do perfil
func _check_memory_budget() -> void:
	if active_profile == null or active_profile.memory_budget_mb <= 0:
		return
		
	var used_bytes := OS.get_static_memory_usage()
	var used_mb := float(used_bytes) / (1024.0 * 1024.0)
	var budget_mb := float(active_profile.memory_budget_mb)
	var pct := (used_mb / budget_mb) * 100.0
	
	if pct >= MEMORY_WARNING_THRESHOLD_PCT:
		memory_warning.emit(used_mb, budget_mb, pct)

func get_memory_status() -> Dictionary:
	var used_bytes := OS.get_static_memory_usage()
	var used_mb := float(used_bytes) / (1024.0 * 1024.0)
	var budget_mb := float(active_profile.memory_budget_mb) if active_profile != null else 8192.0
	return {
		"used_mb": used_mb,
		"budget_mb": budget_mb,
		"usage_pct": (used_mb / budget_mb) * 100.0,
		"within_budget": used_mb <= budget_mb
	}
