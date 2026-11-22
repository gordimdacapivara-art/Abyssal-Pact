class_name RegionLightingSystem
extends RefCounted
## Sistema 9: Sistema de Iluminação 3D de Região (Dark Fantasy Lighting).
## Configura luz direcional (Sol/Lua), sombras suaves em cascata (PSSM),
## luzes locais de atmosfera (braseiros, lava, portais) e perfis por continente.

static func setup_lighting(parent: Node3D, continent_id: StringName, profile: Dictionary = {}) -> DirectionalLight3D:
	var sun := DirectionalLight3D.new()
	sun.name = "SunLight"
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = 180.0
	sun.directional_shadow_blend_splits = true
	sun.shadow_bias = 0.04
	sun.shadow_normal_bias = 1.5

	# Posição angular dramática (estilo Dark Fantasy)
	sun.transform.basis = Basis.from_euler(Vector3(deg_to_rad(-48.0), deg_to_rad(35.0), 0.0))
	sun.transform.origin = Vector3(0, 30.0, 0)

	var sun_color := Color(0.95, 0.65, 0.5)
	var sun_energy := 1.3

	if profile.has("sun_color"):
		sun_color = Color(profile["sun_color"])
	elif continent_id == &"CONT-02": # Sylvaran
		sun_color = Color(0.65, 0.85, 0.6)
		sun_energy = 0.95
	elif continent_id == &"CONT-03": # Khar-Duum
		sun_color = Color(1.0, 0.55, 0.3)
		sun_energy = 1.4
	elif continent_id == &"CONT-04": # Nhal'Kora
		sun_color = Color(0.6, 0.75, 0.95)
		sun_energy = 1.1

	if profile.has("sun_energy"):
		sun_energy = float(profile["sun_energy"])

	sun.light_color = sun_color
	sun.light_energy = sun_energy

	parent.add_child(sun)
	return sun

static func create_localized_light(parent: Node3D, node_name: String, pos: Vector3, color: Color, energy: float = 2.0, range_m: float = 12.0) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.name = node_name
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_m
	light.shadow_enabled = true
	light.transform.origin = pos
	parent.add_child(light)
	return light
