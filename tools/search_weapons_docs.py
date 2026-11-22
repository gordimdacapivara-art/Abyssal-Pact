import glob
import re

print("Searching markdown documents for weapons...")
for f in sorted(glob.glob('*.md')):
    txt = open(f, 'r', encoding='utf-8').read()
    txt_lower = txt.lower()
    terms = ['arma', 'espada', 'machado', 'martelo', 'lança', 'adaga', 'arco', 'cajado', 'escudo']
    found = [t for t in terms if t in txt_lower]
    if found:
        print(f"File {f}: terms found: {found}")
