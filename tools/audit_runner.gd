extends SceneTree
## Runner standalone da auditoria de modelos do pipeline GLB.
##
## Uso:
##   Godot_v4.7.2_console.exe --headless --path "<projeto>" --script res://tools/audit_runner.gd
##
## Código de saída: 0 = aprovado; 1 = problemas (issues ou .blend no repositório).
## Warnings não falham a auditoria — são apontados no relatório.

func _initialize() -> void:
	var issues := PackedStringArray()
	var warnings := PackedStringArray()
	var summary := ModelAudit.audit_reference(issues, warnings)
	var blends := ModelAudit.find_blend_files()

	print("=== ABYSSAL PACT — AUDITORIA DE MODELOS (pipeline GLB) ===")
	print("Modelo: %s" % ModelAudit.REFERENCE_MODEL_PATH)
	print("Tamanho: %d bytes (orçamento %d)" % [summary.get("bytes", 0), ModelAudit.BUDGET_MAX_GLB_BYTES])
	print("Malhas: %d | Triângulos: %d | Materiais: %d | Texturas: %d" % [
		summary.get("meshes", 0), summary.get("triangles", 0),
		summary.get("materials", 0), summary.get("textures", 0)])
	print("Ossos: %d | Altura: %.2f m | Offset de origem: %.3f m" % [
		summary.get("bones", 0), summary.get("height", 0.0), summary.get("origin_offset", 0.0)])
	var clips: Array = summary.get("clips", [])
	print("Clipes: %s" % (", ".join(PackedStringArray(clips)) if clips.size() > 0 else "NENHUM"))
	for issue in issues:
		printerr("[ISSUE] %s" % issue)
	for warning in warnings:
		printerr("[AVISO] %s" % warning)
	for blend in blends:
		printerr("[ISSUE] arquivo .blend dentro do repositório do jogo (REGRA ABSOLUTA): %s" % blend)

	var failed := not issues.is_empty() or not blends.is_empty()
	if failed:
		printerr("=== AUDITORIA: REPROVADO ===")
		quit(1)
		return
	print("=== AUDITORIA: APROVADO (avisos: %d) ===" % warnings.size())
	quit(0)
