import re

path = "data/content/regions/region_031.tres"
with open(path, "r", encoding="utf-8") as f:
    text = f.read()

print(text[:1500])
