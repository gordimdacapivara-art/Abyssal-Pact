import json, re

print("--- REGIONAL_MAPS_INDEX.md (Sylvaran) ---")
with open("REGIONAL_MAPS_INDEX.md", "r", encoding="utf-8") as f:
    text = f.read()
for line in text.splitlines():
    if any(k in line for k in ["REG-01", "REG-020", "Sylvaran", "Raiz Antiga", "Lanternas", "Copa Celeste", "Jardim Afogado", "Arquipélago", "Mariposas", "Espinha Verde", "Brumas", "Lyth", "Primeiro Broto"]):
        print(line)

print("\n--- CONTINENTS_AND_REGIONS.md (Sylvaran) ---")
with open("CONTINENTS_AND_REGIONS.md", "r", encoding="utf-8") as f:
    text = f.read()
sylv = False
for line in text.splitlines():
    if "Sylvaran" in line or "SYLVARAN" in line:
        sylv = True
    if sylv and ("Khar-Duum" in line or "KHAR-DUUM" in line):
        break
    if sylv:
        print(line)
