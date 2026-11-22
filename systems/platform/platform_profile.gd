class_name PlatformProfile
extends Resource
## PlatformProfile — Perfil de configuração de hardware e plataforma.
##
## Centraliza especificações técnicas, orçamentos de memória, alvos de resolução,
## taxas de quadros e parâmetros de fidelidade gráfica para Windows PC, Xbox Series S e Xbox Series X.

enum PlatformType {
	PC_WINDOWS,
	XBOX_SERIES_S,
	XBOX_SERIES_X
}

enum RenderBackend {
	D3D12,
	VULKAN,
	COMPATIBILITY
}

enum InputDeviceType {
	KEYBOARD_MOUSE,
	XBOX_CONTROLLER,
	DUALSHOCK_GENERIC
}

@export var platform_type: PlatformType = PlatformType.PC_WINDOWS
@export var platform_name: String = "Windows PC"
@export var backend: RenderBackend = RenderBackend.VULKAN

# Alvos de Exibição e Desempenho
@export var target_resolution: Vector2i = Vector2i(1920, 1080)
@export var target_fps: int = 60
@export var dynamic_resolution_enabled: bool = false
@export var min_resolution_scale: float = 0.70
@export var max_resolution_scale: float = 1.0

# Orçamentos de Memória e VRAM
@export var memory_budget_mb: int = 8000 # Orçamento de RAM do jogo
@export var vram_texture_max_size: int = 4096
@export var import_astc_etc2: bool = true

# Fidelidade Gráfica e Culling
@export var msaa_3d_quality: int = 2
@export var shadow_atlas_size: int = 4096
@export var particle_budget_per_emitter: int = 1500
@export var lod_threshold_pixels: float = 1.0
@export var occlusion_culling_enabled: bool = true
@export var distance_fade_max_distance: float = 120.0

# Recursos de Rede e Crossplay
@export var crossplay_enabled: bool = true
@export var max_private_world_players: int = 8

static func create_pc_profile() -> Resource:
	var script: GDScript = load("res://systems/platform/platform_profile.gd")
	var p = script.new()
	p.platform_type = PlatformType.PC_WINDOWS
	p.platform_name = "Windows PC"
	p.backend = RenderBackend.VULKAN
	p.target_resolution = Vector2i(1920, 1080)
	p.target_fps = 60
	p.dynamic_resolution_enabled = false
	p.memory_budget_mb = 8192
	p.vram_texture_max_size = 4096
	p.msaa_3d_quality = 2
	p.shadow_atlas_size = 4096
	p.particle_budget_per_emitter = 2000
	p.lod_threshold_pixels = 1.0
	p.occlusion_culling_enabled = true
	p.crossplay_enabled = true
	return p

static func create_series_s_profile() -> Resource:
	var script: GDScript = load("res://systems/platform/platform_profile.gd")
	var p = script.new()
	p.platform_type = PlatformType.XBOX_SERIES_S
	p.platform_name = "Xbox Series S"
	p.backend = RenderBackend.D3D12
	# Series S: Meta 1080p nativo ou 1440p dinâmico (FSR 2.2 / temporal)
	p.target_resolution = Vector2i(1920, 1080)
	p.target_fps = 60
	p.dynamic_resolution_enabled = true
	p.min_resolution_scale = 0.67 # ~720p base mínima sob carga extrema
	p.max_resolution_scale = 1.0 # 1080p nativo
	# Series S possui 10 GB unificados (8 GB @ 224 GB/s + 2 GB @ 56 GB/s), ~7.5 GB para o título
	p.memory_budget_mb = 7500
	p.vram_texture_max_size = 2048 # Otimização de texturas para Series S
	p.msaa_3d_quality = 2
	p.shadow_atlas_size = 2048
	p.particle_budget_per_emitter = 600
	p.lod_threshold_pixels = 1.6 # LOD mais agressivo em distância
	p.occlusion_culling_enabled = true
	p.distance_fade_max_distance = 90.0
	p.crossplay_enabled = true
	return p

static func create_series_x_profile() -> Resource:
	var script: GDScript = load("res://systems/platform/platform_profile.gd")
	var p = script.new()
	p.platform_type = PlatformType.XBOX_SERIES_X
	p.platform_name = "Xbox Series X"
	p.backend = RenderBackend.D3D12
	# Series X: Meta 4K nativo (3840x2160) @ 60 FPS
	p.target_resolution = Vector2i(3840, 2160)
	p.target_fps = 60
	p.dynamic_resolution_enabled = false
	p.min_resolution_scale = 0.85
	p.max_resolution_scale = 1.0
	# Series X possui 16 GB unificados (10 GB @ 560 GB/s + 6 GB @ 336 GB/s), ~13.5 GB para o título
	p.memory_budget_mb = 13500
	p.vram_texture_max_size = 4096
	p.msaa_3d_quality = 4
	p.shadow_atlas_size = 4096
	p.particle_budget_per_emitter = 2500
	p.lod_threshold_pixels = 0.9 # Alta fidelidade de malhas
	p.occlusion_culling_enabled = true
	p.distance_fade_max_distance = 150.0
	p.crossplay_enabled = true
	return p
