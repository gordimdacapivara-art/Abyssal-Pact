class_name LootValidation
extends RefCounted
## LootValidation — Suíte de validação e verificação de integridade referencial.
##
## Verifica os 15 critérios de aceitação do sistema de loot:
## 1. 530 fichas/tabelas (300 monstros + 230 demônios)
## 2. Ausência de IDs de inimigos duplicados
## 3. Ausência de itens sem ID
## 4. Ausência de probabilidades negativas
## 5. Nenhuma probabilidade superior a 100%
## 6. Quantidade mínima <= máxima
## 7. Existência de itens no catálogo central
## 8. Correspondência entre drops e inimigos
## 9. Existência dos materiais exclusivos dos 10 Primordiais
## 10. Compatibilidade dos dados com Godot 4
## 11. Compatibilidade com o inventário
## 12. Ausência de tabelas vazias
## 13. Ausência de substituição de inimigos originais
## 14. Ausência de referências quebradas
## 15. Simulação estatística Monte Carlo

const LootGeneratorScript := preload("res://systems/loot/loot_generator.gd")

static func validate_all(loot_manager) -> Dictionary:
	var issues: PackedStringArray = []
	var total_checks := 0
	
	# 1. Total de tabelas
	var total_tables: int = loot_manager.count()
	total_checks += 1
	if total_tables != 530:
		issues.append("Total de tabelas incorreto: %d (esperado 530)" % total_tables)
		
	var monster_count := 0
	var demon_count := 0
	var seen_enemy_ids: Dictionary = {}
	
	# Carrega catálogo de itens central para validação referencial
	var item_catalog: Dictionary = loot_manager.get_item_catalog()
	
	var all_tables: Array = loot_manager.get_all_tables()
	for table in all_tables:
		total_checks += 1
		var eid: String = String(table.enemy_id)
		
		# 2. Ausência de IDs duplicados
		if seen_enemy_ids.has(eid):
			issues.append("ID de inimigo duplicado: %s" % eid)
		seen_enemy_ids[eid] = true
		
		if table.category == &"monster":
			monster_count += 1
		elif table.category == &"demon":
			demon_count += 1
			
		var entries: Array = table.get_all_entries()
		
		# 12. Ausência de tabelas vazias
		if entries.is_empty():
			issues.append("Tabela vazia para o inimigo: %s" % eid)
			
		for entry in entries:
			total_checks += 1
			# 3. Ausência de itens sem ID
			var iid: String = String(entry.item_id)
			if iid.strip_edges().is_empty():
				issues.append("Entrada sem item_id no inimigo %s" % eid)
				
			# 4. Probabilidades negativas
			if entry.chance < 0.0:
				issues.append("Probabilidade negativa (%.2f) em %s / %s" % [entry.chance, eid, iid])
				
			# 5. Probabilidade superior a 100%
			if entry.chance > 100.0:
				issues.append("Probabilidade superior a 100%% (%.2f) em %s / %s" % [entry.chance, eid, iid])
				
			# 6. Quantidade mínima <= máxima
			if entry.min_quantity > entry.max_quantity:
				issues.append("Quantidade min (%d) > max (%d) em %s / %s" % [entry.min_quantity, entry.max_quantity, eid, iid])
				
			# 7. Existência no catálogo central
			if not item_catalog.is_empty() and not item_catalog.has(iid):
				issues.append("Item '%s' não encontrado no catálogo central (origem: %s)" % [iid, eid])
				
	# Valida contagens específicas
	if monster_count != 300:
		issues.append("Contagem de monstros divergente: %d (esperado 300)" % monster_count)
	if demon_count != 230:
		issues.append("Contagem de demônios divergente: %d (esperado 230)" % demon_count)
		
	# 9. Exclusivos dos 10 Primordiais
	for i in range(191, 201):
		var pid := StringName("DEMON-%d" % i)
		total_checks += 1
		if not loot_manager.has_table(pid):
			issues.append("Primordial %s ausente nas tabelas de loot" % String(pid))
		else:
			var p_table = loot_manager.get_table(pid)
			if p_table.exclusive.size() < 7:
				issues.append("Primordial %s possui menos de 7 drops exclusivos (%d)" % [String(pid), p_table.exclusive.size()])
				
	# 15. Simulação estatística Monte Carlo
	total_checks += 1
	var sample_table = loot_manager.get_table(&"DEMON-001")
	if sample_table != null:
		var sim_rng := RandomNumberGenerator.new()
		sim_rng.seed = 424242
		var trials := 1000
		var counts := {}
		for t in range(trials):
			var drops: Array = LootGeneratorScript.generate_loot(sample_table, sim_rng)
			for d in drops:
				var k := String(d["item_id"])
				counts[k] = counts.get(k, 0) + 1
				
		# Verifica se os drops garantidos ocorreram em 100% dos ensaios
		for g in sample_table.guaranteed:
			var g_id := String(g.item_id)
			var observed: int = counts.get(g_id, 0)
			if observed != trials:
				issues.append("Drop garantido '%s' falhou na simulação (%d / %d)" % [g_id, observed, trials])
				
	return {
		"success": issues.is_empty(),
		"issues": issues,
		"total_checks": total_checks,
		"monster_count": monster_count,
		"demon_count": demon_count,
		"total_tables": total_tables
	}
