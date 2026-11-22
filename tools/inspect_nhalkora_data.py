import re

print("=== NHAL'KORA REGIONS (31 to 40) ===")
for i in range(31, 41):
    path = f"data/content/regions/region_{i:03d}.tres"
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    id_m = re.findall(r'id = &"([^"]+)"', text)
    name_m = re.findall(r'display_name = "([^"]+)"', text)
    biome_m = re.findall(r'biome = "([^"]+)"', text)
    boss_m = re.findall(r'boss_encounter_id = &"([^"]*)"', text)
    conn_m = re.findall(r'connections = PackedStringArray\(([^)]*)\)', text)
    status_m = re.findall(r'status = "([^"]+)"', text)
    demons_m = re.findall(r'"demon_id":\s*"([^"]+)"', text)
    gates_m = re.findall(r'"gate_id":\s*"([^"]+)"', text)
    
    reg_id = id_m[0] if id_m else f"REG-{i:03d}"
    print(f"\n{reg_id}:")
    print(f"  Name: {name_m[0] if name_m else 'Unknown'}")
    print(f"  Biome: {biome_m[0] if biome_m else 'Unknown'}")
    print(f"  Boss: {boss_m[0] if boss_m else 'None'}")
    print(f"  Status: {status_m[0] if status_m else 'Unknown'}")
    print(f"  Connections: {conn_m[0] if conn_m else 'None'}")
    print(f"  Gates: {gates_m}")
    print(f"  Demons: {demons_m}")
