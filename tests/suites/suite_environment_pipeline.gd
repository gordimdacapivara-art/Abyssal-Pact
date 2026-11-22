extends TestCase
## Suite ENVIRONMENT_PIPELINE — Pipeline de Construção de Ambientes 3D (Blender -> Godot 4).
## Valida os 12 subsistemas do pipeline, o carregamento dos assets GLB modelados,
## a cena protótipo de referência CINZÁLIA (Veyrath / REG-001) e o builder modular.

const CINZALIA_SCENE := "res://scenes/world/regions/cinzalia.tscn"
const REGION_001_SCENE := "res://scenes/world/regions/region_001.tscn"

const RegionSceneBuilderClass := preload("res://scenes/world/pipeline/region_scene_builder.gd")
const RegionTerrainSystemClass := preload("res://scenes/world/pipeline/region_terrain_system.gd")
const RegionMaterialSystemClass := preload("res://scenes/world/pipeline/region_material_system.gd")
const RegionVegetationSystemClass := preload("res://scenes/world/pipeline/region_vegetation_system.gd")
const RegionStructureSystemClass := preload("res://scenes/world/pipeline/region_structure_system.gd")
const RegionPropsSystemClass := preload("res://scenes/world/pipeline/region_props_system.gd")
const RegionCollisionSystemClass := preload("res://scenes/world/pipeline/region_collision_system.gd")
const RegionNavigationSystemClass := preload("res://scenes/world/pipeline/region_navigation_system.gd")
const RegionLightingSystemClass := preload("res://scenes/world/pipeline/region_lighting_system.gd")
const RegionAtmosphereSystemClass := preload("res://scenes/world/pipeline/region_atmosphere_system.gd")
const RegionPOISystemClass := preload("res://scenes/world/pipeline/region_poi_system.gd")
const RegionAssetLoaderClass := preload("res://scenes/world/pipeline/region_asset_loader.gd")

const GLB_MODELS := [
	{"cat": "rocks", "name": "rock_volcanic_boulder"},
	{"cat": "rocks", "name": "rock_volcanic_crag"},
	{"cat": "rocks", "name": "rock_crater_rim"},
	{"cat": "nature", "name": "tree_charred_ash"},
	{"cat": "nature", "name": "shrub_ashen_thorn"},
	{"cat": "structures", "name": "ruin_imperial_arch"},
	{"cat": "structures", "name": "ruin_broken_pillar"},
	{"cat": "structures", "name": "structure_bastion_wall"},
	{"cat": "structures", "name": "structure_watchtower_ruin"},
	{"cat": "props", "name": "prop_ash_monolith"},
	{"cat": "props", "name": "prop_volcanic_brazier"},
	{"cat": "nature", "name": "nature_colossal_tree_ancient"},
	{"cat": "nature", "name": "nature_monumental_roots_arch"},
	{"cat": "nature", "name": "nature_bioluminescent_lantern_plant"},
	{"cat": "nature", "name": "nature_canopy_platform_branch"},
	{"cat": "nature", "name": "nature_vine_suspension_bridge"},
	{"cat": "structures", "name": "structure_drowned_garden_pavilion"},
	{"cat": "structures", "name": "structure_mist_nest_spire"},
	{"cat": "structures", "name": "structure_lyth_ancient_ruin"},
	{"cat": "structures", "name": "structure_first_sprout_monument"},
	{"cat": "props", "name": "prop_swamp_lantern_post"},
	{"cat": "props", "name": "prop_butterfly_mana_shrine"},
	{"cat": "rocks", "name": "rock_floating_island_chunk"},
	{"cat": "rocks", "name": "rock_sylvaran_emerald_crystal"},
	{"cat": "structures", "name": "structure_rubra_caldera_vent"},
	{"cat": "props", "name": "prop_volcanic_vent_horn"},
	{"cat": "structures", "name": "structure_kings_forge_citadel"},
	{"cat": "props", "name": "prop_colossal_forge_anvil"},
	{"cat": "rocks", "name": "rock_obsidian_canyon_gate"},
	{"cat": "structures", "name": "structure_slag_refinery_furnace"},
	{"cat": "rocks", "name": "rock_vitrified_glass_dune_ridge"},
	{"cat": "structures", "name": "structure_tharum_mine_headframe"},
	{"cat": "props", "name": "prop_mining_ore_cart_track"},
	{"cat": "structures", "name": "structure_monumental_chain_bridge"},
	{"cat": "props", "name": "prop_titan_chain_link"},
	{"cat": "structures", "name": "structure_lightning_conductor_spire"},
	{"cat": "rocks", "name": "rock_coal_chasm_archway"},
	{"cat": "structures", "name": "structure_heart_crater_monolith"},
	{"cat": "rocks", "name": "rock_glacial_echo_cliff"},
	{"cat": "props", "name": "prop_ice_resonator_crystal"},
	{"cat": "structures", "name": "structure_submerged_ice_citadel"},
	{"cat": "props", "name": "prop_tundra_bone_cairn_marker"},
	{"cat": "rocks", "name": "rock_needle_peak_ice_spire"},
	{"cat": "nature", "name": "nature_crystal_canopy_tree"},
	{"cat": "rocks", "name": "rock_winter_chasm_crevasse"},
	{"cat": "structures", "name": "structure_boreal_coastal_pier"},
	{"cat": "structures", "name": "structure_sleeping_palace_monument"},
	{"cat": "props", "name": "prop_astral_star_geode_shrine"},
	{"cat": "structures", "name": "structure_dead_aurora_throne"},
	{"cat": "rocks", "name": "rock_aurora_monolith_sentinel"}
]

func system_label() -> String:
	return "environment_pipeline"

func execute() -> void:
	await _test_12_systems_defined()
	await _test_asset_loader_and_glbs()
	await _test_cinzalia_reference_prototype()
	await _test_ten_veyrath_3d_scenes()
	await _test_ten_sylvaran_3d_scenes()
	await _test_ten_karduum_3d_scenes()
	await _test_ten_nhalkora_3d_scenes()
	await _test_region_scene_builder_dynamic()

# ------------------------------------------------------------- 12 SUBSISTEMAS --

func _test_12_systems_defined() -> void:
	section("Pipeline 3D: Validação dos 12 subsistemas arquiteturais")
	check_not_null(RegionSceneBuilderClass, "Sistema 1: RegionSceneBuilder carregado")
	check_not_null(RegionTerrainSystemClass, "Sistema 2: RegionTerrainSystem carregado")
	check_not_null(RegionMaterialSystemClass, "Sistema 3: RegionMaterialSystem carregado")
	check_not_null(RegionVegetationSystemClass, "Sistema 4: RegionVegetationSystem carregado")
	check_not_null(RegionStructureSystemClass, "Sistema 5: RegionStructureSystem carregado")
	check_not_null(RegionPropsSystemClass, "Sistema 6: RegionPropsSystem carregado")
	check_not_null(RegionCollisionSystemClass, "Sistema 7: RegionCollisionSystem carregado")
	check_not_null(RegionNavigationSystemClass, "Sistema 8: RegionNavigationSystem carregado")
	check_not_null(RegionLightingSystemClass, "Sistema 9: RegionLightingSystem carregado")
	check_not_null(RegionAtmosphereSystemClass, "Sistema 10: RegionAtmosphereSystem carregado")
	check_not_null(RegionPOISystemClass, "Sistema 11: RegionPOISystem carregado")
	check_not_null(RegionAssetLoaderClass, "Sistema 12: RegionAssetLoader carregado")

# -------------------------------------------------------- ASSETS E MODELOS GLB --

func _test_asset_loader_and_glbs() -> void:
	section("RegionAssetLoader: Carregamento de modelos GLB exportados pelo Blender")
	for model_info in GLB_MODELS:
		var cat: String = model_info["cat"]
		var m_name: String = model_info["name"]
		var packed: PackedScene = RegionAssetLoaderClass.load_model(cat, m_name)
		check_not_null(packed, "GLB carregado com sucesso: %s/%s" % [cat, m_name])
		var inst: Node3D = RegionAssetLoaderClass.instantiate_model(cat, m_name)
		check_not_null(inst, "Instanciação do modelo 3D bem-sucedida: %s" % m_name)
		inst.free()

	# Fallback gracioso com placeholder para modelos não existentes
	var missing_inst: Node3D = RegionAssetLoaderClass.instantiate_model("structures", "non_existent_fortress")
	check_not_null(missing_inst, "Fallback de asset ausente retorna placeholder identificado")
	check_true("Placeholder" in missing_inst.name or "Fallback" in missing_inst.name, "Placeholder devidamente identificado")
	missing_inst.free()

# ------------------------------------------------- PROTÓTIPO CINZÁLIA (REG-001) --

func _test_cinzalia_reference_prototype() -> void:
	section("Protótipo de Referência: CINZÁLIA (Veyrath / REG-001)")
	var packed := load(CINZALIA_SCENE) as PackedScene
	check_not_null(packed, "Cena cinzalia.tscn encontrada e carregada")
	if packed == null:
		return

	var cinz_node := packed.instantiate() as Node3D
	check_not_null(cinz_node, "Instanciação de cinzalia.tscn bem-sucedida")
	host.add_child(cinz_node)

	# Verificação de identidade e contrato
	check_eq(String(cinz_node.region_id()), "REG-001", "Identificador canônico coincide com REG-001")
	check_not_null(cinz_node.safe_zone(), "SafeZone Baluarte das Cinzas presente")
	check_not_null(cinz_node.boss_arena(), "Arena de chefe BOSS-001 presente")
	check_not_null(cinz_node.spawn_point("default"), "Spawn default presente")

	# Verificação dos 12 subsistemas integrados na cena
	check_not_null(cinz_node.get_node_or_null("Terrain/MainGround"), "Terreno principal presente com colisores")
	check_not_null(cinz_node.get_node_or_null("Terrain/LavaFissure"), "Fenda de lava com emissão presente")
	check_not_null(cinz_node.get_node_or_null("NavigationRegion3D"), "Malha de navegação (NavigationRegion3D) ativa")
	check_not_null(cinz_node.get_node_or_null("AtmosphericParticles"), "Emissor de partículas atmosféricas ativo")
	check_not_null(cinz_node.get_node_or_null("ModularStructures"), "Estruturas modulares integradas")
	check_not_null(cinz_node.get_node_or_null("ModularStructures/ImperialArch_Main"), "Arco imperial instanciado na cena")
	check_not_null(cinz_node.get_node_or_null("ModularStructures/BastionWall_West"), "Muralha de bastião instanciada")
	check_not_null(cinz_node.get_node_or_null("ModularStructures/Watchtower_Ruin_West"), "Torre em ruínas instanciada")
	check_not_null(cinz_node.get_node_or_null("EnvironmentalProps"), "Props ambientais integrados")
	check_not_null(cinz_node.get_node_or_null("EnvironmentalProps/VolcanicBoulder_01"), "Rochas vulcânicas instanciadas")
	check_not_null(cinz_node.get_node_or_null("EnvironmentalProps/Brazier_01"), "Braseiro com iluminação de fogo ativo")
	check_not_null(cinz_node.get_node_or_null("Vegetation"), "Vegetação de cinzas calcinada instanciada")
	check_not_null(cinz_node.get_node_or_null("Exploration/MonolithPact/MonolithGLB"), "Monólito decorado com modelo GLB real")

	cinz_node.queue_free()
	await wait_frames(2)

# --------------------------------------------- 10 REGIÕES 3D DE VEYRATH --

func _test_ten_veyrath_3d_scenes() -> void:
	section("Veyrath: Validação das 10 regiões 3D funcionais com seus monumentos e identidades")
	var veyrath_scenes := [
		{"id": "REG-001", "name": "Cinzália", "path": "res://scenes/world/regions/cinzalia.tscn", "check_node": "ModularStructures/ImperialArch_Main"},
		{"id": "REG-002", "name": "Coroa Partida", "path": "res://scenes/world/regions/coroa_partida.tscn", "check_node": "Structures/ImperialPalaceRuin"},
		{"id": "REG-003", "name": "Vale dos Sinos", "path": "res://scenes/world/regions/vale_dos_sinos.tscn", "check_node": "Structures/BellTowerMain"},
		{"id": "REG-004", "name": "Bosque Oco", "path": "res://scenes/world/regions/bosque_oco.tscn", "check_node": "Structures/HollowTreeCenter"},
		{"id": "REG-005", "name": "Lago de Vidro", "path": "res://scenes/world/regions/lago_de_vidro.tscn", "check_node": "Exploration/ObsidianSpireCluster/CentralCrystalSpire"},
		{"id": "REG-006", "name": "Costa das Cinzas", "path": "res://scenes/world/regions/costa_das_cinzas.tscn", "check_node": "Structures/SeaPier"},
		{"id": "REG-007", "name": "Passo da Vigília", "path": "res://scenes/world/regions/passo_da_vigilia.tscn", "check_node": "Structures/MountainBastion"},
		{"id": "REG-008", "name": "Catacumbas de Orun", "path": "res://scenes/world/regions/catacumbas_de_orun.tscn", "check_node": "Structures/MausoleumEntrance"},
		{"id": "REG-009", "name": "Campos de Sal", "path": "res://scenes/world/regions/campos_de_sal.tscn", "check_node": "Exploration/GreatSaltCrust"},
		{"id": "REG-010", "name": "Torre de Aster", "path": "res://scenes/world/regions/torre_de_aster.tscn", "check_node": "Structures/AsterTowerMonument"}
	]

	for r_info in veyrath_scenes:
		var scene_path: String = r_info["path"]
		var reg_id: String = r_info["id"]
		var reg_name: String = r_info["name"]
		var check_node_path: String = r_info["check_node"]

		check_true(ResourceLoader.exists(scene_path), "Cena 3D existe no disco: %s (%s)" % [scene_path, reg_name])
		var packed := load(scene_path) as PackedScene
		check_not_null(packed, "Cena carrega com sucesso: %s" % reg_name)
		if packed == null:
			continue

		var inst := packed.instantiate() as Node3D
		check_not_null(inst, "Instanciação 3D bem-sucedida: %s" % reg_name)
		host.add_child(inst)

		check_eq(String(inst.call("region_id")), reg_id, "%s: ID canônico coincide" % reg_name)
		check_not_null(inst.call("safe_zone"), "%s: SafeZone ativa" % reg_name)
		check_not_null(inst.call("boss_arena"), "%s: Boss Arena presente" % reg_name)
		check_not_null(inst.call("spawn_point", "default"), "%s: Spawn default presente" % reg_name)
		check_not_null(inst.get_node_or_null("Terrain/MainGround"), "%s: Terreno colidente presente" % reg_name)
		check_not_null(inst.get_node_or_null("WorldBoundary"), "%s: Limites perimetrais presentes" % reg_name)
		check_not_null(inst.get_node_or_null("NavigationRegion3D"), "%s: Malha de navegação (NavMesh) presente" % reg_name)
		check_not_null(inst.get_node_or_null("AtmosphericParticles"), "%s: Efeitos atmosféricos de cinzas presentes" % reg_name)
		check_not_null(inst.get_node_or_null(check_node_path), "%s: Estrutura/monumento exclusivo instanciado (%s)" % [reg_name, check_node_path])

		inst.queue_free()
		await wait_frames(1)

# --------------------------------------------- 10 REGIÕES 3D DE SYLVARAN --

func _test_ten_sylvaran_3d_scenes() -> void:
	section("Sylvaran: Validação das 10 regiões 3D funcionais com seus monumentos e natureza ancestral")
	var sylvaran_scenes := [
		{"id": "REG-011", "name": "Raiz Antiga", "path": "res://scenes/world/regions/raiz_antiga.tscn", "check_node": "Structures/ColossalTreeAncient"},
		{"id": "REG-012", "name": "Pântano das Lanternas", "path": "res://scenes/world/regions/pantano_das_lanternas.tscn", "check_node": "Structures/LanternPlantCluster"},
		{"id": "REG-013", "name": "Copa Celeste", "path": "res://scenes/world/regions/copa_celeste.tscn", "check_node": "Structures/CanopyPlatformBranch"},
		{"id": "REG-014", "name": "Jardim Afogado", "path": "res://scenes/world/regions/jardim_afogado.tscn", "check_node": "Structures/DrownedGardenPavilion"},
		{"id": "REG-015", "name": "Arquipélago Suspenso", "path": "res://scenes/world/regions/arquipelago_suspenso.tscn", "check_node": "Structures/FloatingIslandChunk"},
		{"id": "REG-016", "name": "Vale das Mariposas", "path": "res://scenes/world/regions/vale_das_mariposas.tscn", "check_node": "Structures/ButterflyManaShrine"},
		{"id": "REG-017", "name": "Espinha Verde", "path": "res://scenes/world/regions/espinha_verde.tscn", "check_node": "Structures/EmeraldCrystalCrag"},
		{"id": "REG-018", "name": "Ninho das Brumas", "path": "res://scenes/world/regions/ninho_das_brumas.tscn", "check_node": "Structures/MistNestSpire"},
		{"id": "REG-019", "name": "Ruínas de Lyth", "path": "res://scenes/world/regions/ruinas_de_lyth.tscn", "check_node": "Structures/LythAncientRuin"},
		{"id": "REG-020", "name": "Fonte do Primeiro Broto", "path": "res://scenes/world/regions/fonte_do_primeiro_broto.tscn", "check_node": "Structures/FirstSproutMonument"}
	]

	for r_info in sylvaran_scenes:
		var scene_path: String = r_info["path"]
		var reg_id: String = r_info["id"]
		var reg_name: String = r_info["name"]
		var check_node_path: String = r_info["check_node"]

		check_true(ResourceLoader.exists(scene_path), "Cena 3D existe no disco: %s (%s)" % [scene_path, reg_name])
		var packed := load(scene_path) as PackedScene
		check_not_null(packed, "Cena carrega com sucesso: %s" % reg_name)
		if packed == null:
			continue

		var inst := packed.instantiate() as Node3D
		check_not_null(inst, "Instanciação 3D bem-sucedida: %s" % reg_name)
		host.add_child(inst)

		check_eq(String(inst.call("region_id")), reg_id, "%s: ID canônico coincide" % reg_name)
		check_not_null(inst.call("safe_zone"), "%s: SafeZone ativa" % reg_name)
		check_not_null(inst.call("boss_arena"), "%s: Boss Arena presente" % reg_name)
		check_not_null(inst.call("spawn_point", "default"), "%s: Spawn default presente" % reg_name)
		check_not_null(inst.get_node_or_null("Terrain/MainGround"), "%s: Terreno colidente presente" % reg_name)
		check_not_null(inst.get_node_or_null("WorldBoundary"), "%s: Limites perimetrais presentes" % reg_name)
		check_not_null(inst.get_node_or_null("NavigationRegion3D"), "%s: Malha de navegação (NavMesh) presente" % reg_name)
		check_not_null(inst.get_node_or_null("AtmosphericParticles"), "%s: Efeitos atmosféricos de esporos/névoa presentes" % reg_name)
		check_not_null(inst.get_node_or_null(check_node_path), "%s: Estrutura/monumento exclusivo instanciado (%s)" % [reg_name, check_node_path])

		inst.queue_free()
		await wait_frames(1)

# --------------------------------------------- 10 REGIÕES 3D DE KHAR-DUUM --

func _test_ten_karduum_3d_scenes() -> void:
	section("Khar-Duum: Validação das 10 regiões 3D funcionais com seus monumentos e arquitetura forja/vulcânica")
	var karduum_scenes := [
		{"id": "REG-021", "name": "Caldeira Rubra", "path": "res://scenes/world/regions/caldeira_rubra.tscn", "check_node": "Structures/RubraCalderaVent"},
		{"id": "REG-022", "name": "Fornalha dos Reis", "path": "res://scenes/world/regions/fornalha_dos_reis.tscn", "check_node": "Structures/KingsForgeCitadel"},
		{"id": "REG-023", "name": "Desfiladeiro de Obsidiana", "path": "res://scenes/world/regions/desfiladeiro_de_obsidiana.tscn", "check_node": "Structures/ObsidianCanyonGate"},
		{"id": "REG-024", "name": "Mar de Escória", "path": "res://scenes/world/regions/mar_de_escoria.tscn", "check_node": "Structures/SlagRefineryFurnace"},
		{"id": "REG-025", "name": "Dunas de Vidro Negro", "path": "res://scenes/world/regions/dunas_de_vidro_negro.tscn", "check_node": "Structures/VitrifiedGlassDuneRidge"},
		{"id": "REG-026", "name": "Minas de Tharum", "path": "res://scenes/world/regions/minas_de_tharum.tscn", "check_node": "Structures/TharumMineHeadframe"},
		{"id": "REG-027", "name": "Ponte das Correntes", "path": "res://scenes/world/regions/ponte_das_correntes.tscn", "check_node": "Structures/MonumentalChainBridge"},
		{"id": "REG-028", "name": "Planalto do Trovão", "path": "res://scenes/world/regions/planalto_do_trovao.tscn", "check_node": "Structures/LightningConductorSpire"},
		{"id": "REG-029", "name": "Garganta do Carvão", "path": "res://scenes/world/regions/garganta_do_carvao.tscn", "check_node": "Structures/CoalChasmArchway"},
		{"id": "REG-030", "name": "Cratera do Coração", "path": "res://scenes/world/regions/cratera_do_coracao.tscn", "check_node": "Structures/HeartCraterMonolith"}
	]

	for r_info in karduum_scenes:
		var scene_path: String = r_info["path"]
		var reg_id: String = r_info["id"]
		var reg_name: String = r_info["name"]
		var check_node_path: String = r_info["check_node"]

		check_true(ResourceLoader.exists(scene_path), "Cena 3D existe no disco: %s (%s)" % [scene_path, reg_name])
		var packed := load(scene_path) as PackedScene
		check_not_null(packed, "Cena carrega com sucesso: %s" % reg_name)
		if packed == null:
			continue

		var inst := packed.instantiate() as Node3D
		check_not_null(inst, "Instanciação 3D bem-sucedida: %s" % reg_name)
		host.add_child(inst)

		check_eq(String(inst.call("region_id")), reg_id, "%s: ID canônico coincide" % reg_name)
		check_not_null(inst.call("safe_zone"), "%s: SafeZone ativa" % reg_name)
		check_not_null(inst.call("boss_arena"), "%s: Boss Arena presente" % reg_name)
		check_not_null(inst.call("spawn_point", "default"), "%s: Spawn default presente" % reg_name)
		check_not_null(inst.get_node_or_null("Terrain/MainGround"), "%s: Terreno colidente presente" % reg_name)
		check_not_null(inst.get_node_or_null("WorldBoundary"), "%s: Limites perimetrais presentes" % reg_name)
		check_not_null(inst.get_node_or_null("NavigationRegion3D"), "%s: Malha de navegação (NavMesh) presente" % reg_name)
		check_not_null(inst.get_node_or_null("AtmosphericParticles"), "%s: Efeitos atmosféricos de cinzas/brasas presentes" % reg_name)
		check_not_null(inst.get_node_or_null(check_node_path), "%s: Estrutura/monumento exclusivo instanciado (%s)" % [reg_name, check_node_path])

		inst.queue_free()
		await wait_frames(1)

# -------------------------------------------- 10 REGIÕES 3D DE NHAL'KORA --

func _test_ten_nhalkora_3d_scenes() -> void:
	section("Nhal'Kora: Validação das 10 regiões 3D funcionais com seus monumentos e arquitetura glacial/cristalina")
	var nhalkora_scenes := [
		{"id": "REG-031", "name": "Geleira dos Ecos", "path": "res://scenes/world/regions/geleira_dos_ecos.tscn", "check_node": "Structures/GlacialEchoCliff"},
		{"id": "REG-032", "name": "Cidade Submersa de Gelo", "path": "res://scenes/world/regions/cidade_submersa_de_gelo.tscn", "check_node": "Structures/SubmergedIceCitadel"},
		{"id": "REG-033", "name": "Tundra Branca", "path": "res://scenes/world/regions/tundra_branca.tscn", "check_node": "Structures/TundraBoneCairn"},
		{"id": "REG-034", "name": "Pináculo do Silêncio", "path": "res://scenes/world/regions/pinaculo_do_silencio.tscn", "check_node": "Structures/NeedlePeakIceSpire"},
		{"id": "REG-035", "name": "Bosque de Cristal", "path": "res://scenes/world/regions/bosque_de_cristal.tscn", "check_node": "Structures/CrystalCanopyTree"},
		{"id": "REG-036", "name": "Fenda do Inverno", "path": "res://scenes/world/regions/fenda_do_inverno.tscn", "check_node": "Structures/WinterChasmCrevasse"},
		{"id": "REG-037", "name": "Costa Boreal", "path": "res://scenes/world/regions/costa_boreal.tscn", "check_node": "Structures/BorealCoastalPier"},
		{"id": "REG-038", "name": "Palácio Adormecido", "path": "res://scenes/world/regions/palacio_adormecido.tscn", "check_node": "Structures/SleepingPalaceMonument"},
		{"id": "REG-039", "name": "Cemitério das Estrelas", "path": "res://scenes/world/regions/cemiterio_das_estrelas.tscn", "check_node": "Structures/AstralStarGeode"},
		{"id": "REG-040", "name": "Trono da Aurora Morta", "path": "res://scenes/world/regions/trono_da_aurora_morta.tscn", "check_node": "Structures/DeadAuroraThrone"}
	]

	for r_info in nhalkora_scenes:
		var scene_path: String = r_info["path"]
		var reg_id: String = r_info["id"]
		var reg_name: String = r_info["name"]
		var check_node_path: String = r_info["check_node"]

		check_true(ResourceLoader.exists(scene_path), "Cena 3D existe no disco: %s (%s)" % [scene_path, reg_name])
		var packed := load(scene_path) as PackedScene
		check_not_null(packed, "Cena carrega com sucesso: %s" % reg_name)
		if packed == null:
			continue

		var inst := packed.instantiate() as Node3D
		check_not_null(inst, "Instanciação 3D bem-sucedida: %s" % reg_name)
		host.add_child(inst)

		check_eq(String(inst.call("region_id")), reg_id, "%s: ID canônico coincide" % reg_name)
		check_not_null(inst.call("safe_zone"), "%s: SafeZone ativa" % reg_name)
		check_not_null(inst.call("boss_arena"), "%s: Boss Arena presente" % reg_name)
		check_not_null(inst.call("spawn_point", "default"), "%s: Spawn default presente" % reg_name)
		check_not_null(inst.get_node_or_null("Terrain/MainGround"), "%s: Terreno colidente presente" % reg_name)
		check_not_null(inst.get_node_or_null("WorldBoundary"), "%s: Limites perimetrais presentes" % reg_name)
		check_not_null(inst.get_node_or_null("NavigationRegion3D"), "%s: Malha de navegação (NavMesh) presente" % reg_name)
		check_not_null(inst.get_node_or_null("AtmosphericParticles"), "%s: Efeitos atmosféricos de neve/cristais presentes" % reg_name)
		check_not_null(inst.get_node_or_null(check_node_path), "%s: Estrutura/monumento exclusivo instanciado (%s)" % [reg_name, check_node_path])

		inst.queue_free()
		await wait_frames(1)

# ------------------------------------------------- BUILDER REGIONAL MODULAR --

func _test_region_scene_builder_dynamic() -> void:
	section("RegionSceneBuilder: Construção procedural de região a partir de RegionData")
	var world := system(SystemNames.WORLD) as WorldManager
	var reg12 := world.get_region(&"REG-012")
	check_not_null(reg12, "Dados da região REG-012 (Sylvaran) carregados")

	var dynamic_root := Node3D.new()
	dynamic_root.name = "DynamicRegion_012"
	host.add_child(dynamic_root)

	RegionSceneBuilderClass.build_complete_region(dynamic_root, reg12)

	check_not_null(dynamic_root.get_node_or_null("Environment/WorldEnvironment"), "WorldEnvironment gerado")
	check_not_null(dynamic_root.get_node_or_null("Environment/SunLight"), "SunLight gerado")
	check_not_null(dynamic_root.get_node_or_null("AtmosphericParticles"), "Partículas atmosféricas de Sylvaran geradas")
	check_not_null(dynamic_root.get_node_or_null("Terrain/MainGround"), "Terreno gerado")
	check_not_null(dynamic_root.get_node_or_null("NavigationRegion3D"), "NavigationRegion3D gerado")
	check_not_null(dynamic_root.get_node_or_null("ModularStructures"), "Estruturas modulares geradas")
	check_not_null(dynamic_root.get_node_or_null("EnvironmentalProps"), "Props ambientais gerados")
	check_not_null(dynamic_root.get_node_or_null("Vegetation"), "Vegetação gerada")
	check_not_null(dynamic_root.get_node_or_null("PerimeterCollision"), "Barreiras perimetrais geradas")
	check_not_null(dynamic_root.get_node_or_null("POIs"), "Pontos de interesse gerados")
	check_not_null(dynamic_root.get_node_or_null("Travel"), "Portões e portais gerados")

	dynamic_root.queue_free()
	await wait_frames(2)
