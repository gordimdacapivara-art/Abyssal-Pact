class_name AudioManager
extends ManagerBase
## AudioManager â€” barras de Ã¡udio e toca-discos persistentes.
##
## Responsabilidade: garantir buses (Music/SFX/UI) e players persistentes;
## expor pedidos de Ã¡udio por id. Assets de Ã¡udio nÃ£o existem ainda: os
## pedidos sÃ£o sinalizados no EventBus e retornam ERR_UNAVAILABLE atÃ© que
## streams sejam atribuÃ­dos (produÃ§Ã£o de Ã¡udio pendente).
##
## IntegraÃ§Ã£o:
##   - Emite (EventBus): music_requested / sfx_requested / ui_audio_requested.
##   - Consome (registry): nenhum nesta etapa.
## Autoload: "Audio" (cena: autoload/audio_manager.tscn).

const KEY: StringName = SystemNames.AUDIO

## Expõe a chave constante (constantes não são sobrescíveis em GDScript).
func system_key() -> StringName:
	return KEY

const BUS_MASTER := &"Master"
const BUS_MUSIC := &"Music"
const BUS_SFX := &"SFX"
const BUS_UI := &"UI"

@onready var _music_player: AudioStreamPlayer = $MusicPlayer
@onready var _ui_player: AudioStreamPlayer = $UIPlayer
@onready var _sfx_players: Array[AudioStreamPlayer] = [
	$SfxPlayer1 as AudioStreamPlayer,
	$SfxPlayer2 as AudioStreamPlayer,
	$SfxPlayer3 as AudioStreamPlayer,
	$SfxPlayer4 as AudioStreamPlayer,
]

var _sfx_cursor := 0

func initialize() -> void:
	super()
	_ensure_bus(BUS_MUSIC)
	_ensure_bus(BUS_SFX)
	_ensure_bus(BUS_UI)
	log_info("Ãudio pronto: buses Music/SFX/UI garantidos.")

# --------------------------------------------------------------------- API --

func play_music(track_id: StringName) -> Error:
	EventBus.music_requested.emit(track_id)
	if _music_player == null or _music_player.stream == null:
		log_warn("MÃºsica '%s' sem stream atribuÃ­do (produÃ§Ã£o pendente)." % track_id)
		return ERR_UNAVAILABLE
	_music_player.play()
	return OK

func stop_music() -> void:
	if _music_player != null:
		_music_player.stop()

## Toca um efeito no primeiro player SFX livre (pool round-robin).
func play_sfx(sfx_id: StringName) -> Error:
	EventBus.sfx_requested.emit(sfx_id)
	var player := _next_sfx_player()
	if player == null or player.stream == null:
		log_warn("SFX '%s' sem stream atribuÃ­do (produÃ§Ã£o pendente)." % sfx_id)
		return ERR_UNAVAILABLE
	player.play()
	return OK

func play_ui(audio_id: StringName) -> Error:
	EventBus.ui_audio_requested.emit(audio_id)
	if _ui_player == null or _ui_player.stream == null:
		log_warn("Ãudio de UI '%s' sem stream atribuÃ­do (produÃ§Ã£o pendente)." % audio_id)
		return ERR_UNAVAILABLE
	_ui_player.play()
	return OK

## Volume linear 0..1 (clamped). Builtin "Master" ou buses garantidos.
func set_bus_volume(bus_name: StringName, linear_volume: float) -> Error:
	var index := AudioServer.get_bus_index(String(bus_name))
	if index < 0:
		return ERR_DOES_NOT_EXIST
	AudioServer.set_bus_volume_db(index, linear_to_db(clampf(linear_volume, 0.0, 1.0)))
	return OK

func mute_bus(bus_name: StringName, muted: bool) -> Error:
	var index := AudioServer.get_bus_index(String(bus_name))
	if index < 0:
		return ERR_DOES_NOT_EXIST
	AudioServer.set_bus_mute(index, muted)
	return OK

func has_bus(bus_name: StringName) -> bool:
	return AudioServer.get_bus_index(String(bus_name)) >= 0

# ------------------------------------------------------------------ INTERNO --

## Cria o bus caso nÃ£o exista (Master Ã© builtin).
func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(String(bus_name)) >= 0:
		return
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, String(bus_name))
	AudioServer.set_bus_send(index, String(BUS_MASTER))

func _next_sfx_player() -> AudioStreamPlayer:
	if _sfx_players.is_empty():
		return null
	var player := _sfx_players[_sfx_cursor % _sfx_players.size()]
	_sfx_cursor += 1
	return player

func verify() -> PackedStringArray:
	var issues := super()
	for bus_name: StringName in [BUS_MUSIC, BUS_SFX, BUS_UI]:
		if not has_bus(bus_name):
			issues.append("bus ausente: %s" % bus_name)
	if _music_player == null or _ui_player == null:
		issues.append("players de mÃºsica/UI ausentes")
	if _sfx_players.size() == 0:
		issues.append("pool de SFX vazio")
	return issues
