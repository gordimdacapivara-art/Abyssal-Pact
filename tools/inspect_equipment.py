import glob
import re
import os

files = sorted(glob.glob('data/content/equipment/*.tres'))
print(f"Total equipment files: {len(files)}")

for f in files:
    with open(f, 'r', encoding='utf-8') as fp:
        txt = fp.read()
    eid = re.search(r'id = &"([^"]+)"', txt)
    name = re.search(r'display_name = "([^"]+)"', txt)
    slot = re.search(r'slot = &"([^"]+)"', txt)
    etype = re.search(r'equipment_type = &"([^"]+)"', txt)
    rarity = re.search(r'rarity = &"([^"]+)"', txt)
    stats = re.search(r'stats = ({[^}]+})', txt)
    
    id_str = eid.group(1) if eid else os.path.basename(f)
    name_str = name.group(1) if name else "?"
    slot_str = slot.group(1) if slot else "?"
    etype_str = etype.group(1) if etype else "?"
    rarity_str = rarity.group(1) if rarity else "?"
    stats_str = stats.group(1).replace('\n', ' ') if stats else "{}"
    
    print(f"{id_str:8s} | {name_str:30s} | slot={slot_str:10s} | type={etype_str:15s} | rar={rarity_str:10s} | {stats_str}")
