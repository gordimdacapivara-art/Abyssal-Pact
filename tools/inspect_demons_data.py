import glob
import re
import os

demon_files = sorted(glob.glob('data/content/demons/*.tres'))
boss_files = sorted(glob.glob('data/content/bosses/*.tres'))

print(f"Demons count: {len(demon_files)}")
print(f"Bosses count: {len(boss_files)}")

demon_data = []
for f in demon_files:
    with open(f, 'r', encoding='utf-8') as fp:
        txt = fp.read()
    did = re.search(r'id = &"([^"]+)"', txt)
    dname = re.search(r'display_name = "([^"]+)"', txt)
    fam = re.search(r'family = &"([^"]+)"', txt)
    reg = re.search(r'region_id = &"([^"]+)"', txt)
    cont = re.search(r'continent_id = &"([^"]+)"', txt)
    rarity = re.search(r'rarity = &"([^"]+)"', txt)
    hp = re.search(r'"max_health":\s*([0-9.]+)', txt)
    dmg = re.search(r'"damage":\s*([0-9.]+)', txt)
    demon_data.append({
        'id': did.group(1) if did else os.path.basename(f),
        'name': dname.group(1) if dname else 'Unknown',
        'family': fam.group(1) if fam else 'unknown',
        'continent': cont.group(1) if cont else 'unknown',
        'region': reg.group(1) if reg else 'unknown',
        'rarity': rarity.group(1) if rarity else 'common',
        'hp': hp.group(1) if hp else '0',
        'damage': dmg.group(1) if dmg else '0',
    })

boss_data = []
for f in boss_files:
    with open(f, 'r', encoding='utf-8') as fp:
        txt = fp.read()
    bid = re.search(r'id = &"([^"]+)"', txt)
    bname = re.search(r'display_name = "([^"]+)"', txt)
    reg = re.search(r'region_id = &"([^"]+)"', txt)
    cont = re.search(r'continent_id = &"([^"]+)"', txt)
    rarity = re.search(r'rarity = &"([^"]+)"', txt)
    hp = re.search(r'"max_health":\s*([0-9.]+)', txt)
    dmg = re.search(r'"damage":\s*([0-9.]+)', txt)
    boss_data.append({
        'id': bid.group(1) if bid else os.path.basename(f),
        'name': bname.group(1) if bname else 'Unknown',
        'continent': cont.group(1) if cont else 'unknown',
        'region': reg.group(1) if reg else 'unknown',
        'rarity': rarity.group(1) if rarity else 'boss',
        'hp': hp.group(1) if hp else '0',
        'damage': dmg.group(1) if dmg else '0',
    })

print(f"Parsed {len(demon_data)} demons and {len(boss_data)} bosses.")
print("\nFirst 5 demons:")
for d in demon_data[:5]:
    print(" ", d)

print("\nDemons 101-105:")
for d in demon_data[100:105]:
    print(" ", d)

print("\nDemons 191-195:")
for d in demon_data[190:195]:
    print(" ", d)

print("\nFirst 5 bosses:")
for b in boss_data[:5]:
    print(" ", b)
