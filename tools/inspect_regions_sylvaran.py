import re

for i in range(11, 21):
    f = f"data/content/regions/region_{i:03d}.tres"
    content = open(f, encoding="utf-8").read()
    reg_id = re.search(r'id = &"([^"]+)"', content).group(1)
    name = re.search(r'display_name = "([^"]+)"', content).group(1)
    biome = re.search(r'biome = "([^"]+)"', content).group(1)
    boss = re.search(r'boss_encounter_id = &"([^"]*)"', content).group(1)
    print(f"{reg_id}: {name} ({biome}) | Boss: {boss}")
