class_name CodexScreen
extends ScreenBase
## Tela de Códice Completo: Demônios, Chefes, Raças, Sub-raças, Classes, Continentes, Regiões, História e Facções.

var _active_section: StringName = &"demons"
var _search_filter: String = ""
var _selected_entry: Dictionary = {}

var _header: DarkFantasyHeader
var _nav_bar: DarkFantasyNavBar
var _input_search: LineEdit
var _lbl_count: Label
var _entries_vbox: VBoxContainer
var _lbl_entry_title: Label
var _lbl_entry_subtitle: Label
var _lbl_entry_text: Label
var _vbox_meta: VBoxContainer

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"codex"
	if params.has("section"):
		_active_section = StringName(String(params["section"]))
	_build_ui()
	_refresh_codex()

func _ready() -> void:
	_build_ui()
	_refresh_codex()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	theme = DarkFantasyTheme.create()

	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.035, 0.05, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.offset_left = 20
	main_vbox.offset_right = -20
	main_vbox.offset_top = 16
	main_vbox.offset_bottom = -16
	main_vbox.add_theme_constant_override("separation", 10)
	add_child(main_vbox)

	_header = DarkFantasyHeader.new("CÓDICE DE ABYSSAL PACT", "Compêndio de conhecimento, bestiário, povos, classes e lore")
	_header.close_requested.connect(_on_close_pressed)
	main_vbox.add_child(_header)

	_nav_bar = DarkFantasyNavBar.new(&"codex")
	main_vbox.add_child(_nav_bar)

	# Seletor de Seções do Códice
	var sections_scroll := ScrollContainer.new()
	sections_scroll.custom_minimum_size = Vector2(0, 40)
	main_vbox.add_child(sections_scroll)

	var sections_hbox := HBoxContainer.new()
	sections_hbox.add_theme_constant_override("separation", 8)
	sections_scroll.add_child(sections_hbox)

	var sections := [
		{"id": &"demons", "label": "👹 Demônios (200)"},
		{"id": &"bosses", "label": "👑 Chefes (30)"},
		{"id": &"races", "label": "🧝 Raças (40)"},
		{"id": &"subraces", "label": "🧬 Sub-raças (80)"},
		{"id": &"classes", "label": "⚔️ Classes (80)"},
		{"id": &"continents", "label": "🌍 Continentes (4)"},
		{"id": &"regions", "label": "🗺️ Regiões (40)"},
		{"id": &"history", "label": "📜 História"},
		{"id": &"factions", "label": "🛡️ Facções"},
	]

	for s in sections:
		var sid: StringName = s["id"]
		var btn := Button.new()
		btn.text = " " + s["label"] + " "
		btn.custom_minimum_size = Vector2(0, 32)
		btn.pressed.connect(func(): _select_section(sid))
		sections_hbox.add_child(btn)

	# Barra de Busca
	var search_hbox := HBoxContainer.new()
	search_hbox.add_theme_constant_override("separation", 8)
	main_vbox.add_child(search_hbox)

	_input_search = LineEdit.new()
	_input_search.placeholder_text = "Buscar por nome, id ou bioma..."
	_input_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_input_search.text_changed.connect(_on_search_changed)
	search_hbox.add_child(_input_search)

	_lbl_count = Label.new()
	_lbl_count.add_theme_color_override("font_color", Color(0.8, 0.75, 0.65))
	_lbl_count.add_theme_font_size_override("font_size", 12)
	search_hbox.add_child(_lbl_count)

	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 16)
	main_vbox.add_child(content_hbox)

	# --- COLUNA 1: LISTA DE ENTRADAS ---
	var list_panel := PanelContainer.new()
	list_panel.custom_minimum_size = Vector2(340, 0)
	list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(list_panel)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 10
	scroll.offset_right = -10
	scroll.offset_top = 10
	scroll.offset_bottom = -10
	list_panel.add_child(scroll)

	_entries_vbox = VBoxContainer.new()
	_entries_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_entries_vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(_entries_vbox)

	# --- COLUNA 2: DETALHES COMPLETOS DA ENTRADA ---
	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(detail_panel)

	var detail_vbox := VBoxContainer.new()
	detail_vbox.add_theme_constant_override("separation", 10)
	detail_vbox.offset_left = 16
	detail_vbox.offset_right = -16
	detail_vbox.offset_top = 12
	detail_vbox.offset_bottom = -12
	detail_panel.add_child(detail_vbox)

	_lbl_entry_title = Label.new()
	_lbl_entry_title.text = "Selecione uma Entrada"
	_lbl_entry_title.add_theme_font_size_override("font_size", 20)
	_lbl_entry_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	detail_vbox.add_child(_lbl_entry_title)

	_lbl_entry_subtitle = Label.new()
	_lbl_entry_subtitle.text = ""
	_lbl_entry_subtitle.add_theme_font_size_override("font_size", 12)
	_lbl_entry_subtitle.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
	detail_vbox.add_child(_lbl_entry_subtitle)

	detail_vbox.add_child(HSeparator.new())

	_lbl_entry_text = Label.new()
	_lbl_entry_text.text = "Os detalhes e propriedades da entrada selecionada serão exibidos aqui."
	_lbl_entry_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_entry_text.add_theme_font_size_override("font_size", 12)
	detail_vbox.add_child(_lbl_entry_text)

	detail_vbox.add_child(HSeparator.new())

	var meta_title := Label.new()
	meta_title.text = "DADOS TÉCNICOS & PROPRIEDADES:"
	meta_title.add_theme_font_size_override("font_size", 12)
	meta_title.add_theme_color_override("font_color", Color(0.85, 0.8, 0.6))
	detail_vbox.add_child(meta_title)

	var meta_scroll := ScrollContainer.new()
	meta_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_vbox.add_child(meta_scroll)

	_vbox_meta = VBoxContainer.new()
	_vbox_meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vbox_meta.add_theme_constant_override("separation", 4)
	meta_scroll.add_child(_vbox_meta)

func _select_section(s: StringName) -> void:
	_active_section = s
	_search_filter = ""
	if _input_search != null:
		_input_search.text = ""
	_refresh_codex()

func _on_search_changed(text: String) -> void:
	_search_filter = text.strip_edges().to_lower()
	_refresh_codex()

func _refresh_codex() -> void:
	for child in _entries_vbox.get_children():
		child.queue_free()

	var raw_entries := _fetch_section_entries()
	var filtered_entries: Array[Dictionary] = []

	for e in raw_entries:
		var name_str: String = String(e.get("name", "")).to_lower()
		var id_str: String = String(e.get("id", "")).to_lower()
		var sub_str: String = String(e.get("subtitle", "")).to_lower()
		if _search_filter.is_empty() or _search_filter in name_str or _search_filter in id_str or _search_filter in sub_str:
			filtered_entries.append(e)

	_lbl_count.text = "Registros: %d / %d" % [filtered_entries.size(), raw_entries.size()]

	for e in filtered_entries:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 36)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = " %s  —  %s" % [String(e.get("id", "")), String(e.get("name", ""))]
		btn.pressed.connect(func(): _display_entry(e))
		_entries_vbox.add_child(btn)

	if not filtered_entries.is_empty():
		_display_entry(filtered_entries[0])
	else:
		_display_entry({})

func _fetch_section_entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	match _active_section:
		&"demons":
			var dm := Game.get_system(SystemNames.DEMONS) as DemonManager
			if dm != null:
				for d in dm.demons():
					result.append({
						"id": String(d.id),
						"name": d.display_name,
						"subtitle": "Região: %s (%s) | Categoria: %s | Raridade: %s" % [String(d.region_id), String(d.continent_id), String(d.category), String(d.rarity)],
						"text": d.description,
						"props": {
							"Vida": d.health(),
							"Ataque": d.stats.get("damage", 20),
							"Defesa": d.stats.get("defense", 10),
							"Resistências": d.resistances,
							"Habilidades": d.ability_ids,
							"Modelo GLB": d.model_path if not d.model_pending else "Asset Pendente (Placeholder Ativo)"
						}
					})
		&"bosses":
			var bm := Game.get_system(SystemNames.BOSSES) as BossManager
			if bm != null:
				for b in bm.bosses():
					var arena_name: String = str(b.arena.get("name", "Arena Principal")) if b.arena is Dictionary else str(b.arena)
					result.append({
						"id": String(b.id),
						"name": b.display_name,
						"subtitle": "Chefe de %s | Arena: %s | Fases: %d" % [String(b.continent_id), arena_name, b.phases.size()],
						"text": "%s\n\nIdentidade Narrativa: %s" % [b.description, b.narrative_identity],
						"props": {
							"Vida Total": b.health(),
							"Arena": arena_name,
							"Fases de Combate": b.phases.size(),
							"Habilidades": b.special_abilities if not b.special_abilities.is_empty() else b.ability_ids,
							"Recompensas": b.rewards,
							"Modelo GLB": b.model_path if not b.model_pending else "Asset Pendente (Placeholder Ativo)"
						}
					})
		&"races":
			var rm := Game.get_system(SystemNames.RACE) as RaceManager
			if rm != null:
				for r in rm.races():
					result.append({
						"id": String(r.id),
						"name": r.display_name,
						"subtitle": "Sub-raças: %s e %s" % [String(r.subrace_ids[0]) if r.subrace_ids.size() > 0 else "-", String(r.subrace_ids[1]) if r.subrace_ids.size() > 1 else "-"],
						"text": r.description,
						"props": {
							"Sub-raças Vinculadas": r.subrace_ids,
							"Tipo de Corpo": r.visual_profile.get("body_type", "humanoid_shared"),
							"Estruturas Especiais": r.visual_profile.get("special_structures", []),
							"Acessórios": r.visual_profile.get("accessories", [])
						}
					})
		&"subraces":
			var rm := Game.get_system(SystemNames.RACE) as RaceManager
			if rm != null:
				for s in rm.subraces():
					result.append({
						"id": String(s.id),
						"name": s.display_name,
						"subtitle": "Raça Mãe: %s" % String(s.parent_race_id),
						"text": s.description,
						"props": {
							"Raça Vinculada": String(s.parent_race_id),
							"Diferenças Visuais": s.visual_overrides,
							"Animações Extras": s.animation_extras
						}
					})
		&"classes":
			var cm := Game.get_system(SystemNames.CLASS) as ClassManager
			if cm != null:
				for c in cm.classes():
					result.append({
						"id": String(c.id),
						"name": c.display_name,
						"subtitle": "Grupo: %s | Fantasia: %s" % [String(c.group_id), c.identity],
						"text": c.identity if not c.identity.is_empty() else "Classe de combate de ABYSSAL PACT.",
						"props": {
							"Atributos Iniciais": c.base_attributes,
							"Habilidades Ativas": c.active_abilities,
							"Habilidades Passivas": c.passive_abilities,
							"Especializações": c.specializations
						}
					})
		&"continents":
			var wm := Game.get_system(SystemNames.WORLD) as WorldManager
			if wm != null:
				for c in wm.continents():
					result.append({
						"id": String(c.id),
						"name": c.display_name,
						"subtitle": "Capital: %s | Clima: %s" % [String(c.capital_region_id), c.climate],
						"text": c.description,
						"props": {
							"Capital Regional": String(c.capital_region_id),
							"Clima": c.climate,
							"Tema Visual": c.theme,
							"Total de Regiões": c.region_ids.size(),
							"Regiões": c.region_ids
						}
					})
		&"regions":
			var wm := Game.get_system(SystemNames.WORLD) as WorldManager
			if wm != null:
				for r in wm.regions():
					result.append({
						"id": String(r.id),
						"name": r.display_name,
						"subtitle": "Continente: %s | Bioma: %s | Nível %d–%d" % [String(r.continent_id), r.biome, r.level_range.x, r.level_range.y],
						"text": r.description,
						"props": {
							"Continente": String(r.continent_id),
							"Bioma": r.biome,
							"Faixa de Nível": "%d a %d" % [r.level_range.x, r.level_range.y],
							"Raio Limítrofe": float(r.boundaries.get("radius", 150.0)),
							"Conexões de Fronteira": r.connections,
							"Chefe Regional": r.boss_encounter_id if not r.boss_encounter_id.is_empty() else "Nenhum",
							"POIs": r.points_of_interest.size(),
							"Status de Produção": r.status
						}
					})
		&"history":
			for h in CodexLore.get_history_entries():
				result.append({
					"id": h["id"],
					"name": h["title"],
					"subtitle": "Era: %s" % h["era"],
					"text": h["text"],
					"props": {
						"Período Histórico": h["era"],
						"Importância": "Cânone Primário (WORLD_LORE.md)"
					}
				})
		&"factions":
			for f in CodexLore.get_faction_entries():
				result.append({
					"id": f["id"],
					"name": f["name"],
					"subtitle": "Continente: %s | Alinhamento: %s" % [f["continent"], f["alignment"]],
					"text": "%s\n\nLema: « %s »" % [f["description"], f["motto"]],
					"props": {
						"Continente": f["continent"],
						"Líder": f["leader"],
						"Alinhamento": f["alignment"],
						"Lema Oficial": f["motto"]
					}
				})
	return result

func _display_entry(e: Dictionary) -> void:
	_selected_entry = e
	for child in _vbox_meta.get_children():
		child.queue_free()

	if e.is_empty():
		_lbl_entry_title.text = "Nenhum Registro Encontrado"
		_lbl_entry_subtitle.text = ""
		_lbl_entry_text.text = "Ajuste os filtros de busca ou selecione outra categoria."
		return

	_lbl_entry_title.text = "%s  (ID: %s)" % [String(e.get("name", "")), String(e.get("id", ""))]
	_lbl_entry_subtitle.text = String(e.get("subtitle", ""))
	_lbl_entry_text.text = String(e.get("text", ""))

	var props: Dictionary = e.get("props", {})
	for k in props.keys():
		var row := HBoxContainer.new()
		var k_lbl := Label.new()
		k_lbl.text = "• " + k + ":"
		k_lbl.custom_minimum_size = Vector2(160, 0)
		k_lbl.add_theme_font_size_override("font_size", 11)
		k_lbl.add_theme_color_override("font_color", Color(0.85, 0.8, 0.65))
		row.add_child(k_lbl)

		var v_lbl := Label.new()
		v_lbl.text = str(props[k])
		v_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v_lbl.add_theme_font_size_override("font_size", 11)
		v_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
		row.add_child(v_lbl)
		_vbox_meta.add_child(row)

func _on_close_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.close_screen(&"codex")
