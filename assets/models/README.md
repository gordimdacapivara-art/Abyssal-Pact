# assets/models — Modelos do Pipeline GLB

Aqui entram **somente modelos exportados** (`.glb`, glTF 2.0 binário).

## REGRA ABSOLUTA

**Nenhum arquivo `.blend` pode existir neste repositório.** Fontes Blender
ficam em pasta separada FORA do jogo (ex.: `…\Abyssal Pact Sources\`).
A auditoria (`tools/audit_runner.gd`) reprova o projeto se encontrar
`.blend`/`.blend1` dentro do jogo.

## Organização

```
characters/<papel>/<id>/char_<id>.glb    (player, npc, enemy, boss)
props/<categoria>/<id>/prop_<id>.glb
effects/<id>/fx_<id>.glb
```

## Modelo atual

- `characters/reference/char_ref_humanoid.glb` — humanoide de referência
  **provisório** (manequim procedural): 2 malhas (corpo + cabeça), 4
  materiais sólidos sem texturas, 9 ossos, 8 clipes do contrato
  (`idle, walk, run, sprint, jump, fall, land, dodge`), ~87 KB.
- Fonte: `…\Abyssal Pact Sources\char_ref_humanoid.blend`.
- Gerador: `tools/blender/build_reference_character.py` (Blender headless).

## Orçamentos (PC 4 GB RAM / Intel UHD)

- ≤ 5 MB por personagem; ≤ 50k triângulos; ≤ 12 malhas.
- Texturas ≤ 1024 px, ≤ 8 por modelo, embutidas no GLB.
- Esqueleto ≤ 96 ossos; altura 1,2–2,4 m; origem nos pés.

Ver detalhes: `MODEL_PIPELINE.md`.
