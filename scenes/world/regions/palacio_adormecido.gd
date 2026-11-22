class_name PalacioAdormecidoRegion
extends NhalkoraRegionBase
## Região REG-038: Palácio Adormecido (Continente NHAL'KORA).
## Apresenta arquitetura glacial, misteriosa, cristalina e monumental com relevos e monumentos dedicados.

func _init() -> void:
	region_id_code = &"REG-038"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("SleepingPalaceMonument"):
			var mon := RegionAssetLoaderClass.instantiate_model("structures", "structure_sleeping_palace_monument")
			mon.name = "SleepingPalaceMonument"
			mon.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(mon)
			RegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(14.0, 12.0, 14.0), Vector3(0, 6.0, 0))
