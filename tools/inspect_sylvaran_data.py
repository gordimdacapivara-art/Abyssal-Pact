import re

for i in range(11, 21):
    path = f"data/content/regions/region_{i:03d}.tres"
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    demons = re.findall(r'"demon_id":\s*"([^"]+)"', text)
    print(f"REG-{i:03d} demons: {demons}")
