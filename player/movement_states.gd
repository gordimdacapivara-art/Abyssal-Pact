class_name MovementStates
extends RefCounted
## Estados de movimento do controlador do personagem.
##
## Máquina explícita usada pelo PlayerController; os nomes são estáveis e
## servirão de âncora para os clipes de animação futuros (GLB + AnimationTree).

enum State {
	## Parado no chão.
	IDLE,
	## Caminhada (velocidade base, sem Shift).
	WALK,
	## Corrida (Shift segurado).
	RUN,
	## Sprint (Shift + direção mantidos além de `sprint_hold_time`).
	SPRINT,
	## Subida do salto.
	RISE,
	## Queda / ar (inclui sair da borda sem pular).
	FALL,
	## Aterrissagem (trava curta pós-contato com o chão).
	LAND,
	## Esquiva (Ctrl): impulso com direção travada durante a duração.
	DODGE,
}

## Nome estável do estado (âncora de animação e logs/HUD).
static func name_of(state: int) -> String:
	return State.keys()[state]

static func is_airborne(state: int) -> bool:
	return state == State.RISE or state == State.FALL

static func is_ground_move(state: int) -> bool:
	return state == State.IDLE or state == State.WALK \
		or state == State.RUN or state == State.SPRINT

## Estado que indica deslocamento intencional (usado para razão de velocidade
## na animação: WALK/RUN/SPRINT).
static func is_locomotion(state: int) -> bool:
	return state == State.WALK or state == State.RUN or state == State.SPRINT
