import glob
import re
import json

with open('CONTINENTS_AND_REGIONS.md', 'r', encoding='utf-8') as f:
    creg_text = f.read()

# Extract table of 40 regions
# | REG-001 | Planície Cinzenta de Veyrath | CONT-01 | ash_plains | 1–5 | Baluarte das Cinzas | Catacumbas de Basalto | BOSS-001 | `full_production` |
region_pattern = re.compile(r'\|\s*(REG-\d+)\s*\|\s*([^|]+)\s*\|\s*(CONT-\d+)\s*\|\s*([^|]+)\s*\|\s*([^|]+)\s*\|\s*([^|]+)\s*\|\s*([^|]+)\s*\|\s*([^|]+)\s*\|')
matches = region_pattern.findall(creg_text)

regions_dict = {}
for m in matches:
    reg_id, name, cont_id, biome, lvl, city, dungeon, boss = [x.strip() for x in m]
    regions_dict[reg_id] = {
        'name': name,
        'continent': cont_id,
        'biome': biome,
        'level_range': lvl,
        'settlement': city,
        'dungeon': dungeon,
        'boss_associated': boss
    }

print(f"Parsed {len(regions_dict)} regions from CONTINENTS_AND_REGIONS.md")
for r in sorted(regions_dict.keys())[:5]:
    print(r, regions_dict[r])
