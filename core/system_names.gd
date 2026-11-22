class_name SystemNames
## Chaves canônicas do registro de sistemas (SystemRegistry).
##
## Os gerenciadores NUNCA se referenciam por classe entre si: resolvem os
## demais sistemas pelo registry usando estas chaves. Isso elimina
## dependências circulares entre scripts (ver ARCHITECTURE.md).

## Autoloads (7 entradas em project.godot).
const EVENT_BUS := &"EventBus"
const GAME := &"Game"
const SCENES := &"Scenes"
const UI := &"UI"
const AUDIO := &"Audio"
const NET := &"Net"
const SAVE := &"Save"

## Serviços registrados por GameManager em tempo de boot (não são autoload).
const WORLD := &"World"
const CHARACTER := &"Character"
const RACE := &"Race"
const CLASS := &"Class"
const DEMONS := &"Demons"
const BOSSES := &"Bosses"
const INVENTORY := &"Inventory"
const QUESTS := &"Quests"

## Ordem de inicialização definida por GameManager (dependências explícitas).
const INIT_ORDER: Array[StringName] = [
	SCENES, UI, AUDIO,
	RACE, CLASS, DEMONS, BOSSES,
	INVENTORY, QUESTS, CHARACTER, WORLD,
	NET, SAVE,
]

## Lista completa de chaves gerenciadas pelo registry.
const ALL: Array[StringName] = [
	GAME, SCENES, UI, AUDIO, NET, SAVE,
	WORLD, CHARACTER, RACE, CLASS, DEMONS, BOSSES, INVENTORY, QUESTS,
]
