# ABYSSAL PACT — Pipeline Oficial de Modelos 3D

> **REGRA ABSOLUTA:** arquivos `.blend` ficam **FORA da pasta do jogo**.
> Somente modelos exportados (`.glb`) entram no repositório Godot.

## 1. Ferramentas

| Papel | Ferramenta | Uso no projeto |
|---|---|---|
| Modelagem/Animação | Blender 5.3+ (headless) | `tools/blender/*.py` geram a cena e exportam GLB |
| Motor | Godot 4.7 | importa GLB, instancia, anima via AnimationTree |
| Entrega | GLB (binário glTF 2.0) | único formato aceito em `assets/models/` |

## 2. Organização de diretórios

```
assets/models/
  characters/<papel>/<id>/char_<id>.glb     (personagens: player, npc, enemy, boss)
  props/<categoria>/<id>/prop_<id>.glb      (objetos de cena)
  effects/<id>/fx_<id>.glb                  (efeitos animados)
  README.md
```

- Onde entra o GLB: `assets/models/…` (versão final, sem fontes).
- Onde NUNCA entra `.blend`: em qualquer lugar do repositório. As fontes vivem
  em uma pasta irmã fora do jogo (ex.: `…\Abyssal Pact Sources\`).

## 3. Padrão de nomes

- GLB: `char_ref_humanoid.glb` — prefixo do tipo (`char_`, `prop_`, `fx_`),
  identificador editorial em snake_case, sem espaços/acentos.
- Ossos/clipes: nomes ASCII estáveis; clipes seguem o **contrato do
  PlayerAnimator**: `idle, walk, run, sprint, jump, fall, land, dodge`.
  Renomear um clipe é quebra de contrato (requer renomear a âncora em
  `player/player_animator.gd`).
- Materiais: `mat_<nome>` sólido ou com texturas embutidas no GLB.

## 4. Pipeline de exportação (Blender → GLB)

Ferramenta canônica: `tools/blender/build_reference_character.py`.

```
blender --background --factory-startup --python tools/blender/build_reference_character.py -- \
  --out "<jogo>\assets\models\characters\reference\char_ref_humanoid.glb" \
  --save-blend "<FORA DO JOGO>\char_ref_humanoid.blend"
```

Regras de exportação (já resolvidas para Blender 5.x):

- Escala em metros; origem nos pés (z=0); personagem olhando **+Y no Blender
  → -Z no Godot**; taxa 24 fps.
- Animações: cada clipe é uma Action stashed em trilha NLA própria
  (`export_animation_mode="NLA_TRACKS"`); loops têm extremos idênticos.
- Parâmetros não suportados (ex.: `export_colors`) são descartados com aviso —
  o script tenta `stash → actions → plain` e falha se os clipes centrais
  (`idle/walk/run/jump`) não saírem no GLB.
- O script valida o GLB lendo o JSON do próprio arquivo (header 12 bytes +
  chunk `JSON`).

## 5. Pipeline de importação (Godot)

- O GLB é importado pelo pipeline padrão do Godot (`.godot/imported/`).
- `player/player_model_loader.gd` (`PlayerModelLoader.attach`) instancia o
  GLB no slot do player (`ModelRoot`), oculta o placeholder (cápsula),
  descobre o `AnimationPlayer` importado e liga o `PlayerAnimator`.
- `player/player_animator.gd` constrói uma **AnimationTree PADRÃO** via
  `player/animation_tree_builder.gd` sobre a biblioteca do GLB (biblioteca
  compartilhada, sem duplicação): máquina de estados com transições
  all-pairs IMMEDIATE (crossfade 0,18 s) + auto-loop AT_END (0,12 s) nos
  clipes `idle/walk/run/sprint/fall`.
- Controlador: `player/player_controller.gd` anexa automaticamente o modelo
  de referência em `_ready` (`load_reference_model`).

## 6–10. Verificações (`tools/model_audit.gd`, runner: `tools/audit_runner.gd`)

Auditoria headless com código de saída (0 aprovado / 1 reprovado):

```
Godot_v4.7.2_console.exe --headless --path "<jogo>" --script res://tools/audit_runner.gd
```

Orçamentos calibrados para o alvo de hardware (PC 4 GB RAM, i3 11ª gen,
Intel UHD, Windows 11):

| # | Verificação | Critério |
|---|---|---|
| 5 | Modelo | GLB ≤ 5 MB; carrega/instancia como PackedScene |
| 6 | Texturas | ≤ 8 texturas, cada uma ≤ 1024 px, embutidas no GLB |
| 7 | Materiais | pelo menos 1 material por superfície |
| 8 | Esqueleto | `Skeleton3D` presente; ≤ 96 ossos |
| 9 | Animações | `AnimationPlayer` presente; centrais `idle/walk/run/jump` obrigatórias; contrato completo é warning |
| 10 | Escalas | altura 1,2–2,4 m; origem nos pés (min_y ≤ 0,15 m) |

Bônus: triângulos ≤ 50k; ≤ 12 objetos de malha; **política .blend**: varre o
repositório e reprova se qualquer `.blend`/`.blend1` existir dentro do jogo.

Resultado do modelo de referência: **APROVADO** — 87 KB, 384 triângulos,
4 materiais sólidos, 0 texturas, 9 ossos, 1,79 m, origem nos pés, 8 clipes.

## 11. Compatibilidade com AnimationTree

- `AnimationTreeBuilder` opera sobre QUALQUER GLB cujos clipes sigam o
  contrato: estados ausentes simplesmente não existem (aviso, sem quebra).
- Suíte `tests/suites/suite_models.gd` valida: `has_state/start/travel/
  current_node`, auto-loop e recusa de estado inexistente.

## 12. Documentação do processo

Este arquivo + `assets/models/README.md` + `ARCHITECTURE.md` (seção
`player/` e `tools/`). A fonte `.blend` do modelo de referência fica em
`…\Abyssal Pact Sources\char_ref_humanoid.blend` (FORA do repositório).

## Limitações honestas

- O modelo de referência é um **manequim procedural provisório** (caixas +
  esfera, materiais sólidos) para validar pipeline, animação e gameplay —
  não é um asset profissional. Arte final virá de modelagem manual no
  Blender seguindo este mesmo pipeline.
- Animações são procedurais e simples (sem IK/corrida realista).
