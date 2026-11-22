import glob
import re
import os

print("--- DEMONS ANALYSIS ---")
patterns = {}
for i in range(1, 201):
    path = f"data/content/demons/demon_{i:03d}.tres"
    if not os.path.exists(path):
        continue
    with open(path, 'r', encoding='utf-8') as f:
        txt = f.read()
    fam_m = re.search(r'family = &"([^"]+)"', txt)
    rar_m = re.search(r'rarity = &"([^"]+)"', txt)
    reg_m = re.search(r'region_id = &"([^"]+)"', txt)
    cont_m = re.search(r'continent_id = &"([^"]+)"', txt)
    hp_m = re.search(r'"max_health":\s*([0-9.]+)', txt)
    dmg_m = re.search(r'"damage":\s*([0-9.]+)', txt)
    abil_m = re.search(r'ability_ids = PackedStringArray\(([^)]*)\)', txt)
    
    fam = fam_m.group(1) if fam_m else 'unknown'
    rar = rar_m.group(1) if rar_m else 'unknown'
    reg = reg_m.group(1) if reg_m else 'unknown'
    cont = cont_m.group(1) if cont_m else 'unknown'
    abils = abil_m.group(1).replace('"', '').strip() if abil_m else ''
    
    patterns[fam] = patterns.get(fam, 0) + 1

print(f"Total demons found: {200}")
print("Family counts:", patterns)

print("\n--- BOSSES ANALYSIS ---")
boss_abilities = set()
for i in range(1, 31):
    path = f"data/content/bosses/boss_{i:03d}.tres"
    if not os.path.exists(path):
        continue
    with open(path, 'r', encoding='utf-8') as f:
        txt = f.read()
    b_abils = re.findall(r'"ABIL-BOSS-[^"]+"', txt)
    for b in b_abils:
        boss_abilities.add(b.replace('"', ''))

print(f"Total boss unique abilities: {len(boss_abilities)}")
print("Boss abilities:", sorted(list(boss_abilities)))
