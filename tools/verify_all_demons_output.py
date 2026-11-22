import glob
import os
import re

folders = {
    "Inferior": 100,
    "Superior": 90,
    "Supreme": 30,
    "Primordial": 10
}

all_files = []
errors = []

for folder, expected in folders.items():
    files = glob.glob(f"Demons/{folder}/*.md")
    print(f"Folder Demons/{folder}: {len(files)} files (Expected: {expected})")
    if len(files) != expected:
        errors.append(f"Folder {folder} has {len(files)} files, expected {expected}")
    all_files.extend(files)

print(f"\nTotal files checked: {len(all_files)}")

# Check each file for all 15 fields and the audit table
mandatory_fields = [
    "## TABELA DE AUDITORIA INICIAL E RESOLUÇÃO TÉCNICA",
    "## 01 — IDENTIFICAÇÃO",
    "## 02 — FAMÍLIA E SUBESPÉCIE",
    "## 03 — CONTINENTE E REGIÃO",
    "## 04 — BIOMA E HABITAT",
    "## 05 — ANATOMIA COMPLETA",
    "## 06 — DIMENSÕES E PROPORÇÕES",
    "## 07 — PALETA DE CORES HEX",
    "## 08 — MATERIAIS E TEXTURAS",
    "## 09 — MODELO 3D E ACESSÓRIOS",
    "## 10 — ANIMAÇÕES E RIG",
    "## 11 — IA E COMPORTAMENTO",
    "## 12 — HABILIDADES E ATAQUES",
    "## 13 — RESISTÊNCIAS E FRAQUEZAS",
    "## 14 — DROPS E MATERIAIS",
    "## 15 — VARIANTES E RARIDADE"
]

missing_fields_count = 0
for f in all_files:
    with open(f, 'r', encoding='utf-8') as fp:
        txt = fp.read()
    for field in mandatory_fields:
        if field not in txt:
            errors.append(f"File {f} is missing section '{field}'")
            missing_fields_count += 1
            
    # Check HEX codes
    hex_codes = re.findall(r'#[0-9A-Fa-f]{6}', txt)
    if len(hex_codes) < 6:
        errors.append(f"File {f} has fewer than 6 HEX codes ({len(hex_codes)})")

print(f"Missing mandatory sections across all files: {missing_fields_count}")

# Check Master Index
master_index_path = "Demons/DEMON_TECHNICAL_MASTER_INDEX.md"
if os.path.exists(master_index_path):
    with open(master_index_path, 'r', encoding='utf-8') as fp:
        m_txt = fp.read()
    table_rows = [line for line in m_txt.split('\n') if line.startswith('| `DEMON-') or line.startswith('| `BOSS-')]
    print(f"Master Index table rows: {len(table_rows)} (Expected: 230)")
    if len(table_rows) != 230:
        errors.append(f"Master Index has {len(table_rows)} rows, expected 230")
else:
    errors.append("Master Index does not exist")

# Check Audit Report
audit_path = "Demons/Audit/AUDIT_REPORT_230_DEMONS.md"
print(f"Audit Report exists: {os.path.exists(audit_path)}")

# Check Technical Reference Guide
tech_ref_path = "Demons/Technical_Reference/DEMON_TECHNICAL_REFERENCE_GUIDE.md"
print(f"Technical Reference Guide exists: {os.path.exists(tech_ref_path)}")

if not errors:
    print("\n>>> ALL VERIFICATION CHECKS PASSED PERFECTLY (100% COMPLETE)! <<<")
else:
    print(f"\nFOUND {len(errors)} ERRORS:")
    for e in errors[:10]:
        print(" -", e)
