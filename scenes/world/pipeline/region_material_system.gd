class_name RegionMaterialSystem
extends RefCounted
## Sistema 3: Sistema de Materiais 3D de Ambiente (Dark Fantasy PBR).
## Centraliza a criação e customização de StandardMaterial3D e Shaders
## por continente e bioma (Veyrath, Sylvaran, Khar-Duum, Nhal'Kora).

static func create_terrain_material(continent_id: StringName, biome: String) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.roughness = 0.92
	mat.metallic = 0.05

	match String(continent_id):
		"CONT-01": # Veyrath (Vulcânico / Cinzas)
			mat.albedo_color = Color(0.18, 0.15, 0.17)
			if biome == "obsidian_peaks":
				mat.roughness = 0.45
				mat.metallic = 0.25
				mat.albedo_color = Color(0.10, 0.09, 0.11)
		"CONT-02": # Sylvaran (Floresta / Musgo)
			mat.albedo_color = Color(0.14, 0.20, 0.15)
			mat.roughness = 0.85
		"CONT-03": # Khar-Duum (Areias Negras / Cânions)
			mat.albedo_color = Color(0.26, 0.20, 0.16)
			if biome == "salt_flats":
				mat.albedo_color = Color(0.85, 0.85, 0.88)
				mat.roughness = 0.4
		"CONT-04": # Nhal'Kora (Geleira / Boreal)
			mat.albedo_color = Color(0.14, 0.18, 0.24)
			if "frozen" in biome or "ice" in biome:
				mat.albedo_color = Color(0.45, 0.65, 0.8)
				mat.roughness = 0.25
				mat.metallic = 0.1
		_:
			mat.albedo_color = Color(0.2, 0.2, 0.2)

	return mat

static func create_lava_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.35, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.45, 0.1)
	mat.emission_energy_multiplier = 3.5
	mat.roughness = 0.3
	return mat

static func create_stone_ruin_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.24, 0.20, 0.19)
	mat.roughness = 0.8
	mat.metallic = 0.1
	return mat
