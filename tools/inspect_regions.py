import glob
import re

files = [f"data/content/regions/region_{i:03d}.tres" for i in range(1, 11)]
for f in files:
    content = open(f, encoding="utf-8").read()
    reg_id = re.search(r'id = &"([^"]+)"', content).group(1)
    name = re.search(r'display_name = "([^"]+)"', content).group(1)
    biome = re.search(r'biome = "([^"]+)"', content).group(1)
    boss = re.search(r'boss_encounter_id = &"([^"]*)"', content).group(1)
    print(f"{reg_id}: {name} ({biome}) | Boss: {boss}")
