import os

dirs = [
    'assets/3d/weapons/swords',
    'assets/3d/weapons/axes',
    'assets/3d/weapons/hammers_maces',
    'assets/3d/weapons/polearms',
    'assets/3d/weapons/daggers',
    'assets/3d/weapons/bows_crossbows',
    'assets/3d/weapons/firearms_fantasy',
    'assets/3d/weapons/staves_catalysts',
    'assets/3d/weapons/special_weapons',
    'assets/3d/weapons/shields',
    'assets/3d/weapons/previews',
    'assets/3d/monsters/humanoids',
    'assets/3d/monsters/beasts',
    'assets/3d/monsters/reptiles_dragons',
    'assets/3d/monsters/undead',
    'assets/3d/monsters/demons_abyssals',
    'assets/3d/monsters/giants_colossi',
    'assets/3d/monsters/magical_elementals',
    'assets/3d/monsters/insects_arachnids',
    'assets/3d/monsters/aquatic',
    'assets/3d/monsters/rare_anomalies',
    'assets/3d/monsters/previews',
    'assets/3d/demons/inferior',
    'assets/3d/demons/superior',
    'assets/3d/demons/supreme',
    'assets/3d/demons/primordial',
    'Weapons/Swords',
    'Weapons/Axes',
    'Weapons/Hammers_Maces',
    'Weapons/Polearms',
    'Weapons/Daggers',
    'Weapons/Bows_Crossbows',
    'Weapons/Firearms_Fantasy',
    'Weapons/Staves_Catalysts',
    'Weapons/Special_Weapons',
    'Weapons/Shields',
    'Monsters/Catalog'
]

for d in dirs:
    os.makedirs(d, exist_ok=True)

print(f"Created/verified {len(dirs)} directories successfully.")
