class_name RegionAtmosphereSystem
extends RefCounted
## Sistema 10: Sistema de Efeitos Atmosféricos 3D de Região.
## Configura WorldEnvironment (céu procedural Dark Fantasy, iluminação ambiente, neblina volumétrica)
## e emissores de partículas atmosféricas (cinzas incandescentes, esporos, poeira e nevascas).

static func setup_world_environment(parent: Node3D, continent_id: StringName, biome: String, profile: Dictionary = {}) -> WorldEnvironment:
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"

	var env := Environment.new()
	env.background_mode = Environment.BG_SKY

	var sky_mat := ProceduralSkyMaterial.new()
	_configure_sky_by_continent(sky_mat, continent_id, biome)

	var sky := Sky.new()
	sky.sky_material = sky_mat
	env.sky = sky

	# Iluminação ambiente
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	var ambient_color := Color(0.22, 0.14, 0.16)
	if profile.has("ambient_color"):
		ambient_color = Color(profile["ambient_color"])
	elif continent_id == &"CONT-02":
		ambient_color = Color(0.12, 0.18, 0.14)
	elif continent_id == &"CONT-03":
		ambient_color = Color(0.24, 0.15, 0.10)
	elif continent_id == &"CONT-04":
		ambient_color = Color(0.12, 0.16, 0.22)

	env.ambient_light_color = ambient_color
	env.ambient_light_energy = 0.85

	# Neblina atmosférica
	env.fog_enabled = true
	var fog_color := Color(0.28, 0.16, 0.18)
	var fog_density := 0.008

	if profile.has("fog_color"):
		fog_color = Color(profile["fog_color"])
	if profile.has("fog_density"):
		fog_density = float(profile["fog_density"])

	env.fog_light_color = fog_color
	env.fog_density = fog_density

	# Tonemapper Dark Fantasy ACES
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.05

	world_env.environment = env
	parent.add_child(world_env)
	return world_env

static func setup_atmosphere_particles(parent: Node3D, continent_id: StringName) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "AtmosphericParticles"
	particles.amount = 350
	particles.lifetime = 6.0
	particles.visibility_aabb = AABB(Vector3(-75, -5, -75), Vector3(150, 40, 150))
	particles.transform.origin = Vector3(0, 15.0, 0)

	var p_mat := ParticleProcessMaterial.new()
	p_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	p_mat.emission_box_extents = Vector3(70, 10, 70)
	p_mat.direction = Vector3(0.2, -1.0, 0.1)
	p_mat.spread = 25.0
	p_mat.initial_velocity_min = 1.0
	p_mat.initial_velocity_max = 2.5
	p_mat.gravity = Vector3(0, -0.6, 0)
	p_mat.scale_min = 0.04
	p_mat.scale_max = 0.12

	var draw_mat := StandardMaterial3D.new()
	draw_mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	draw_mat.billboard_mode = StandardMaterial3D.BILLBOARD_PARTICLES

	match String(continent_id):
		"CONT-01": # Veyrath (Cinzas vulcânicas e fagulhas)
			p_mat.color = Color(0.9, 0.45, 0.2, 0.85)
			draw_mat.albedo_color = Color(0.9, 0.45, 0.2, 0.85)
		"CONT-02": # Sylvaran (Esporos luminescentes)
			p_mat.color = Color(0.4, 0.9, 0.5, 0.75)
			draw_mat.albedo_color = Color(0.4, 0.9, 0.5, 0.75)
			p_mat.gravity = Vector3(0, -0.1, 0)
		"CONT-03": # Khar-Duum (Poeira e areia de cinzas)
			p_mat.color = Color(0.85, 0.65, 0.35, 0.8)
			draw_mat.albedo_color = Color(0.85, 0.65, 0.35, 0.8)
			p_mat.direction = Vector3(1.0, -0.2, 0.3)
		"CONT-04": # Nhal'Kora (Neve e cristais de gelo)
			p_mat.color = Color(0.85, 0.92, 1.0, 0.9)
			draw_mat.albedo_color = Color(0.85, 0.92, 1.0, 0.9)
			p_mat.gravity = Vector3(0, -1.2, 0)
		_:
			p_mat.color = Color(0.7, 0.7, 0.7, 0.6)
			draw_mat.albedo_color = Color(0.7, 0.7, 0.7, 0.6)

	particles.process_material = p_mat

	var quad := QuadMesh.new()
	quad.size = Vector2(0.12, 0.12)
	quad.material = draw_mat
	particles.draw_pass_1 = quad

	parent.add_child(particles)
	return particles

static func _configure_sky_by_continent(mat: ProceduralSkyMaterial, continent_id: StringName, biome: String) -> void:
	match String(continent_id):
		"CONT-01": # Veyrath
			mat.sky_top_color = Color(0.18, 0.12, 0.15)
			mat.sky_horizon_color = Color(0.38, 0.22, 0.2)
			mat.ground_bottom_color = Color(0.12, 0.08, 0.1)
			mat.ground_horizon_color = Color(0.25, 0.15, 0.16)
		"CONT-02": # Sylvaran
			mat.sky_top_color = Color(0.10, 0.18, 0.16)
			mat.sky_horizon_color = Color(0.22, 0.32, 0.22)
			mat.ground_bottom_color = Color(0.08, 0.12, 0.09)
			mat.ground_horizon_color = Color(0.15, 0.22, 0.16)
		"CONT-03": # Khar-Duum
			mat.sky_top_color = Color(0.22, 0.15, 0.12)
			mat.sky_horizon_color = Color(0.48, 0.30, 0.18)
			mat.ground_bottom_color = Color(0.14, 0.09, 0.07)
			mat.ground_horizon_color = Color(0.30, 0.18, 0.12)
		"CONT-04": # Nhal'Kora
			mat.sky_top_color = Color(0.12, 0.16, 0.24)
			mat.sky_horizon_color = Color(0.28, 0.36, 0.46)
			mat.ground_bottom_color = Color(0.08, 0.10, 0.15)
			mat.ground_horizon_color = Color(0.18, 0.24, 0.32)
		_:
			mat.sky_top_color = Color(0.2, 0.2, 0.25)
			mat.sky_horizon_color = Color(0.3, 0.3, 0.35)
